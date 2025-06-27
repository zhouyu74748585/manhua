package com.manhua.service;

import com.manhua.entity.Manga;
import com.manhua.entity.MangaLibrary;
import com.manhua.entity.ReadingProgress;
import com.manhua.repository.MangaLibraryRepository;
import com.manhua.repository.MangaRepository;
import com.manhua.repository.ReadingProgressRepository;
import org.apache.tika.Tika;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * 文件扫描服务类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Service
@Transactional
public class FileScanService {

    private static final Logger logger = LoggerFactory.getLogger(FileScanService.class);

    // 支持的漫画文件格式
    private static final Set<String> SUPPORTED_EXTENSIONS = Set.of(
            ".zip", ".rar", ".7z", ".cbz", ".cbr", ".cb7",
            ".pdf", ".epub", ".mobi", ".azw3"
    );

    // 支持的图片格式
    private static final Set<String> IMAGE_EXTENSIONS = Set.of(
            ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tiff", ".tif"
    );

    @Autowired
    private MangaRepository mangaRepository;

    @Autowired
    private MangaLibraryRepository libraryRepository;

    @Autowired
    private ReadingProgressRepository progressRepository;

    @Autowired
    private MangaService mangaService;

    @Value("${app.scan.max-file-size:500MB}")
    private String maxFileSize;

    @Value("${app.scan.skip-hidden-files:true}")
    private boolean skipHiddenFiles;

    @Value("${app.scan.deep-scan:true}")
    private boolean deepScan;

    @Value("${app.scan.extract-metadata:true}")
    private boolean extractMetadata;

    private final Tika tika = new Tika();

    /**
     * 扫描指定漫画库
     */
    @Async
    public CompletableFuture<ScanResult> scanLibrary(Long libraryId) {
        logger.info("开始扫描漫画库: {}", libraryId);

        MangaLibrary library = libraryRepository.findById(libraryId)
                .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + libraryId));

        // 更新扫描状态
        library.setCurrentStatus("扫描中");
        libraryRepository.save(library);

        ScanResult result = new ScanResult();

        try {
            Path libraryPath = Paths.get(library.getPath());

            if (!Files.exists(libraryPath)) {
                throw new IllegalArgumentException("漫画库路径不存在: " + library.getPath());
            }

            // 获取现有漫画文件路径
            Set<String> existingPaths = mangaRepository.findByLibraryId(libraryId)
                    .stream()
                    .map(Manga::getFilePath)
                    .collect(Collectors.toSet());

            // 扫描文件
            Set<String> scannedPaths = new HashSet<>();
            scanDirectory(libraryPath, library, scannedPaths, result);

            // 处理已删除的文件
            Set<String> deletedPaths = new HashSet<>(existingPaths);
            deletedPaths.removeAll(scannedPaths);

            for (String deletedPath : deletedPaths) {
                handleDeletedFile(deletedPath, library);
                result.deletedCount++;
            }

            // 更新库统计信息
            updateLibraryStatistics(library);

            // 更新扫描状态
            library.setCurrentStatus("空闲");
            library.setLastScanAt(LocalDateTime.now());
            libraryRepository.save(library);

            logger.info("漫画库扫描完成: {} - 新增: {}, 更新: {}, 删除: {}",
                    libraryId, result.addedCount, result.updatedCount, result.deletedCount);

        } catch (Exception e) {
            logger.error("扫描漫画库失败: {}", libraryId, e);
            library.setCurrentStatus("错误: " + e.getMessage());
            libraryRepository.save(library);
            result.error = e.getMessage();
        }

        return CompletableFuture.completedFuture(result);
    }

    /**
     * 扫描目录
     */
    private void scanDirectory(Path directory, MangaLibrary library, Set<String> scannedPaths, ScanResult result) {
        try {
            Files.walkFileTree(directory, new SimpleFileVisitor<Path>() {
                @Override
                public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) throws IOException {
                    if (skipHiddenFiles && dir.getFileName().toString().startsWith(".")) {
                        return FileVisitResult.SKIP_SUBTREE;
                    }

                    // 检查目录是否包含图片文件
                    if (!dir.equals(directory) && containsImageFiles(dir)) {
                        String dirPath = dir.toAbsolutePath().toString();
                        scannedPaths.add(dirPath);

                        try {
                            handleMangaDirectory(dir, library, result);
                        } catch (Exception e) {
                            logger.warn("处理漫画目录失败: {} - {}", dirPath, e.getMessage());
                        }
                        
                        // 跳过子目录，因为我们已经将整个目录作为一个漫画处理
                        return FileVisitResult.SKIP_SUBTREE;
                    }

                    return FileVisitResult.CONTINUE;
                }

                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    if (skipHiddenFiles && file.getFileName().toString().startsWith(".")) {
                        return FileVisitResult.CONTINUE;
                    }

                    String fileName = file.getFileName().toString().toLowerCase();
                    String extension = getFileExtension(fileName);

                    // 处理支持的压缩文件格式
                    if (SUPPORTED_EXTENSIONS.contains(extension)) {
                        String filePath = file.toAbsolutePath().toString();
                        scannedPaths.add(filePath);

                        try {
                            handleMangaFile(file, library, result);
                        } catch (Exception e) {
                            logger.warn("处理漫画文件失败: {} - {}", filePath, e.getMessage());
                        }
                    }

                    return FileVisitResult.CONTINUE;
                }

                @Override
                public FileVisitResult visitFileFailed(Path file, IOException exc) throws IOException {
                    logger.warn("访问文件失败: {} - {}", file, exc.getMessage());
                    return FileVisitResult.CONTINUE;
                }
            });
        } catch (IOException e) {
            logger.error("扫描目录失败: {}", directory, e);
            throw new RuntimeException("扫描目录失败", e);
        }
    }

    /**
     * 处理漫画文件
     */
    private void handleMangaFile(Path file, MangaLibrary library, ScanResult result) {
        String filePath = file.toAbsolutePath().toString();

        // 检查文件是否已存在
        Optional<Manga> existingManga = mangaRepository.findByFilePath(filePath);

        if (existingManga.isPresent()) {
            // 检查文件是否有更新
            Manga manga = existingManga.get();
            try {
                long currentSize = Files.size(file);
                long lastModified = Files.getLastModifiedTime(file).toMillis();

                if (manga.getFileSize() != currentSize ||
                    manga.getFileModifiedAt() == null ||
                    manga.getFileModifiedAt().atZone(java.time.ZoneId.systemDefault()).toEpochSecond() != lastModified) {

                    updateMangaFile(manga, file);
                    result.updatedCount++;
                }
            } catch (IOException e) {
                logger.warn("检查文件更新失败: {}", filePath, e);
            }
        } else {
            // 新文件，创建漫画记录
            try {
                Manga manga = createMangaFromFile(file, library);
                mangaRepository.save(manga);

                // 创建初始阅读进度
                ReadingProgress progress = new ReadingProgress();
                progress.setManga(manga);
                progress.setCurrentPage(1);
                progress.setTotalPages(manga.getTotalPages());
                progressRepository.save(progress);

                result.addedCount++;
                logger.debug("添加新漫画: {}", manga.getTitle());
            } catch (Exception e) {
                logger.warn("创建漫画记录失败: {}", filePath, e);
            }
        }
    }

    /**
     * 从文件创建漫画对象
     */
    private Manga createMangaFromFile(Path file, MangaLibrary library) throws IOException {
        Manga manga = new Manga();

        // 基本信息
        String fileName = file.getFileName().toString();
        manga.setTitle(extractTitleFromFileName(fileName));
        manga.setFilePath(file.toAbsolutePath().toString());
        manga.setLibrary(library);
        manga.setFileSize(Files.size(file));
        manga.setFileModifiedAt(Instant.ofEpochMilli(Files.getLastModifiedTime(file).toMillis())
                .atZone(java.time.ZoneId.systemDefault())
                .toLocalDateTime());

        // 提取元数据
        if (extractMetadata) {
            extractMangaMetadata(manga, file);
        }

        // 获取页数
        manga.setTotalPages(getTotalPages(file));

        // 生成封面
        if (deepScan) {
            generateCoverImage(manga, file);
        }

        return manga;
    }

    /**
     * 更新漫画文件信息
     */
    private void updateMangaFile(Manga manga, Path file) throws IOException {
        manga.setFileSize(Files.size(file));
        manga.setFileModifiedAt(Instant.ofEpochMilli(Files.getLastModifiedTime(file).toMillis())
                .atZone(java.time.ZoneId.systemDefault())
                .toLocalDateTime());

        // 重新获取页数
        int newTotalPages = getTotalPages(file);
        if (manga.getTotalPages() != newTotalPages) {
            manga.setTotalPages(newTotalPages);

            // 更新阅读进度的总页数
            ReadingProgress progress = progressRepository.findByMangaId(manga.getId())
                    .orElse(null);
            if (progress != null) {
                progress.setTotalPages(newTotalPages);
                progressRepository.save(progress);
            }
        }

        // 重新提取元数据
        if (extractMetadata) {
            extractMangaMetadata(manga, file);
        }

        mangaRepository.save(manga);
        logger.debug("更新漫画: {}", manga.getTitle());
    }

    /**
     * 处理已删除的文件
     */
    private void handleDeletedFile(String filePath, MangaLibrary library) {
        Optional<Manga> manga = mangaRepository.findByFilePath(filePath);
        if (manga.isPresent()) {
            // 删除相关的阅读进度
            progressRepository.deleteByMangaId(manga.get().getId());

            // 删除漫画记录
            mangaRepository.delete(manga.get());

            logger.debug("删除漫画记录: {}", manga.get().getTitle());
        }
    }

    /**
     * 从文件名提取标题
     */
    private String extractTitleFromFileName(String fileName) {
        // 移除文件扩展名
        String title = fileName.replaceAll("\\.(zip|cbz|rar|cbr|7z|cb7|pdf|epub)$", "");

        // 清理常见的文件名模式
        title = title.replaceAll("[\\[\\(].*?[\\]\\)]", ""); // 移除括号内容
        title = title.replaceAll("_+", " "); // 下划线替换为空格
        title = title.replaceAll("-+", " "); // 连字符替换为空格
        title = title.replaceAll("\\s+", " "); // 多个空格合并为一个
        title = title.trim();

        return StringUtils.hasText(title) ? title : "未知标题";
    }

    /**
     * 获取扫描统计信息
     */
    public Map<String, Object> getScanStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalLibraries", libraryRepository.count());
        stats.put("totalMangas", mangaRepository.count());
        stats.put("lastScanTime", LocalDateTime.now());
        stats.put("scanStatus", "idle");
        return stats;
    }

    /**
     * 验证文件
     */
    public Map<String, Object> validateFile(String filePath) {
        Map<String, Object> result = new HashMap<>();
        try {
            Path path = Paths.get(filePath);
            if (!Files.exists(path)) {
                result.put("valid", false);
                result.put("error", "文件不存在");
                return result;
            }

            if (!Files.isRegularFile(path)) {
                result.put("valid", false);
                result.put("error", "不是有效的文件");
                return result;
            }

            String fileName = path.getFileName().toString().toLowerCase();
            boolean isSupported = fileName.endsWith(".zip") || fileName.endsWith(".cbz") ||
                                fileName.endsWith(".rar") || fileName.endsWith(".cbr") ||
                                fileName.endsWith(".7z") || fileName.endsWith(".cb7") ||
                                fileName.endsWith(".pdf") || fileName.endsWith(".epub");

            result.put("valid", isSupported);
            result.put("fileSize", Files.size(path));
            result.put("fileName", path.getFileName().toString());
            result.put("fileType", getFileExtension(fileName));

            if (!isSupported) {
                result.put("error", "不支持的文件格式");
            }

        } catch (Exception e) {
            result.put("valid", false);
            result.put("error", "验证文件时发生错误: " + e.getMessage());
        }
        return result;
    }

    private String getFileExtension(String fileName) {
        int lastDot = fileName.lastIndexOf('.');
        return lastDot >= 0 ? fileName.substring(lastDot) : "";
    }

    /**
     * 清除扫描历史
     */
    public void clearScanHistory() {
        logger.info("清除扫描历史记录");
        // 这里可以实现清除扫描历史的逻辑
        // 例如清除缓存、重置统计信息等
    }

    /**
     * 提取文件元数据
     */
    public Map<String, Object> extractMetadata(String filePath) {
        Map<String, Object> metadata = new HashMap<>();
        try {
            Path path = Paths.get(filePath);
            if (!Files.exists(path)) {
                metadata.put("error", "文件不存在");
                return metadata;
            }

            BasicFileAttributes attrs = Files.readAttributes(path, BasicFileAttributes.class);
            metadata.put("fileName", path.getFileName().toString());
            metadata.put("fileSize", attrs.size());
            metadata.put("creationTime", attrs.creationTime().toString());
            metadata.put("lastModifiedTime", attrs.lastModifiedTime().toString());
            metadata.put("isDirectory", attrs.isDirectory());
            metadata.put("isRegularFile", attrs.isRegularFile());

            // 尝试使用Tika提取更多元数据
            try {
                String mimeType = tika.detect(path.toFile());
                metadata.put("mimeType", mimeType);
            } catch (Exception e) {
                logger.warn("无法检测文件MIME类型: {}", filePath, e);
            }

        } catch (Exception e) {
            logger.error("提取文件元数据失败: {}", filePath, e);
            metadata.put("error", "提取元数据失败: " + e.getMessage());
        }
        return metadata;
    }

    /**
     * 提取漫画元数据
     */
    private void extractMangaMetadata(Manga manga, Path file) {
        try {
            String mimeType = tika.detect(file.toFile());
            manga.setFileType(mimeType);

            // 根据文件类型提取特定元数据
            String extension = getFileExtension(file.getFileName().toString().toLowerCase());

            switch (extension) {
                case ".pdf":
                    extractPdfMetadata(manga, file);
                    break;
                case ".epub":
                    extractEpubMetadata(manga, file);
                    break;
                default:
                    // 对于压缩文件，尝试从文件名或目录结构提取信息
                    extractArchiveMetadata(manga, file);
                    break;
            }
        } catch (Exception e) {
            logger.warn("提取元数据失败: {} - {}", file, e.getMessage());
        }
    }

    /**
     * 提取PDF元数据
     */
    private void extractPdfMetadata(Manga manga, Path file) {
        // TODO: 使用PDFBox提取PDF元数据
        logger.debug("提取PDF元数据: {}", file);
    }

    /**
     * 提取EPUB元数据
     */
    private void extractEpubMetadata(Manga manga, Path file) {
        // TODO: 提取EPUB元数据
        logger.debug("提取EPUB元数据: {}", file);
    }

    /**
     * 提取压缩文件元数据
     */
    private void extractArchiveMetadata(Manga manga, Path file) {
        // 从文件路径推断作者和系列信息
        String parentDir = file.getParent().getFileName().toString();

        // 如果父目录看起来像作者名，设置为作者
        if (parentDir.matches("^[\\p{L}\\s]+$") && !parentDir.equalsIgnoreCase("manga")) {
            manga.setAuthor(parentDir);
        }

        logger.debug("提取压缩文件元数据: {}", file);
    }

    /**
     * 获取文件页数
     */
    private int getTotalPages(Path file) {
        try {
            String extension = getFileExtension(file.getFileName().toString().toLowerCase());

            switch (extension) {
                case ".zip":
                case ".cbz":
                    return getZipTotalPages(file);
                case ".rar":
                case ".cbr":
                    return getRarTotalPages(file);
                case ".7z":
                case ".cb7":
                    return get7zTotalPages(file);
                case ".pdf":
                    return getPdfTotalPages(file);
                default:
                    return 0;
            }
        } catch (Exception e) {
            logger.warn("获取页数失败: {} - {}", file, e.getMessage());
            return 0;
        }
    }

    /**
     * 获取ZIP文件页数
     */
    private int getZipTotalPages(Path file) throws IOException {
        try (ZipFile zipFile = new ZipFile(file.toFile())) {
            return (int) zipFile.stream()
                    .filter(entry -> !entry.isDirectory())
                    .filter(entry -> isImageFile(entry.getName()))
                    .count();
        }
    }

    /**
     * 获取RAR文件页数
     */
    private int getRarTotalPages(Path file) {
        // TODO: 使用junrar库获取RAR文件页数
        logger.debug("获取RAR文件页数: {}", file);
        return 0;
    }

    /**
     * 获取7Z文件页数
     */
    private int get7zTotalPages(Path file) {
        // TODO: 使用7zip库获取7Z文件页数
        logger.debug("获取7Z文件页数: {}", file);
        return 0;
    }

    /**
     * 获取PDF文件页数
     */
    private int getPdfTotalPages(Path file) {
        // TODO: 使用PDFBox获取PDF页数
        logger.debug("获取PDF文件页数: {}", file);
        return 0;
    }

    /**
     * 生成封面图片
     */
    private void generateCoverImage(Manga manga, Path file) {
        try {
            String extension = getFileExtension(file.getFileName().toString().toLowerCase());

            switch (extension) {
                case ".zip":
                case ".cbz":
                    generateZipCover(manga, file);
                    break;
                case ".rar":
                case ".cbr":
                    generateRarCover(manga, file);
                    break;
                case ".pdf":
                    generatePdfCover(manga, file);
                    break;
                default:
                    break;
            }
        } catch (Exception e) {
            logger.warn("生成封面失败: {} - {}", file, e.getMessage());
        }
    }

    /**
     * 生成ZIP文件封面
     */
    private void generateZipCover(Manga manga, Path file) throws IOException {
        try (ZipFile zipFile = new ZipFile(file.toFile())) {
            Optional<? extends ZipEntry> firstImage = zipFile.stream()
                    .filter(entry -> !entry.isDirectory())
                    .filter(entry -> isImageFile(entry.getName()))
                    .sorted((a, b) -> compareNatural(a.getName(), b.getName()))
                    .findFirst();
                    
            if (firstImage.isPresent()) {
                // 生成封面缓存路径
                String coverPath = "covers/zip_" + Math.abs(file.toString().hashCode()) + ".jpg";
                manga.setCoverImage(coverPath);
                
                // TODO: 实际提取并保存封面图片到缓存目录
                // 可以使用 zipFile.getInputStream(firstImage.get()) 获取图片流
                // 然后保存到缓存目录中
                logger.debug("生成ZIP封面: {} -> {}", firstImage.get().getName(), coverPath);
            }
        }
    }

    /**
     * 生成RAR文件封面
     */
    private void generateRarCover(Manga manga, Path file) {
        // TODO: 使用junrar库生成RAR文件封面
        logger.debug("生成RAR封面: {}", file);
    }

    /**
     * 生成PDF文件封面
     */
    private void generatePdfCover(Manga manga, Path file) {
        // TODO: 使用PDFBox生成PDF文件封面
        logger.debug("生成PDF封面: {}", file);
    }

    /**
     * 更新库统计信息
     */
    private void updateLibraryStatistics(MangaLibrary library) {
        List<Manga> mangas = mangaRepository.findByLibraryId(library.getId());

        library.setMangaCount(mangas.size());
        library.setTotalSize(mangas.stream().mapToLong(Manga::getFileSize).sum());

        libraryRepository.save(library);
    }

    /**
     * 判断是否为图片文件
     */
    private boolean isImageFile(String fileName) {
        String extension = getFileExtension(fileName.toLowerCase());
        return IMAGE_EXTENSIONS.contains(extension);
    }

    /**
     * 检查目录是否包含图片文件
     */
    private boolean containsImageFiles(Path directory) {
        try {
            return Files.list(directory)
                    .filter(Files::isRegularFile)
                    .anyMatch(file -> isImageFile(file.getFileName().toString()));
        } catch (IOException e) {
            logger.warn("检查目录图片文件失败: {}", directory, e);
            return false;
        }
    }

    /**
     * 处理漫画目录（包含图片的文件夹）
     */
    private void handleMangaDirectory(Path directory, MangaLibrary library, ScanResult result) {
        String dirPath = directory.toAbsolutePath().toString();

        // 检查目录是否已存在
        Optional<Manga> existingManga = mangaRepository.findByFilePath(dirPath);

        if (existingManga.isPresent()) {
            // 检查目录是否有更新
            Manga manga = existingManga.get();
            try {
                long lastModified = Files.getLastModifiedTime(directory).toMillis();
                
                if (manga.getFileModifiedAt() == null ||
                    manga.getFileModifiedAt().atZone(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli() != lastModified) {
                    
                    updateMangaDirectory(manga, directory);
                    result.updatedCount++;
                }
            } catch (IOException e) {
                logger.warn("检查目录更新失败: {}", dirPath, e);
            }
        } else {
            // 新目录，创建漫画记录
            try {
                Manga manga = createMangaFromDirectory(directory, library);
                mangaRepository.save(manga);

                // 创建初始阅读进度
                ReadingProgress progress = new ReadingProgress();
                progress.setManga(manga);
                progress.setCurrentPage(1);
                progress.setTotalPages(manga.getTotalPages());
                progressRepository.save(progress);

                result.addedCount++;
                logger.debug("添加新漫画目录: {}", manga.getTitle());
            } catch (Exception e) {
                logger.warn("创建漫画目录记录失败: {}", dirPath, e);
            }
        }
    }

    /**
     * 从目录创建漫画对象
     */
    private Manga createMangaFromDirectory(Path directory, MangaLibrary library) throws IOException {
        Manga manga = new Manga();

        // 基本信息
        String dirName = directory.getFileName().toString();
        manga.setTitle(extractTitleFromFileName(dirName));
        manga.setFilePath(directory.toAbsolutePath().toString());
        manga.setLibrary(library);
        manga.setFileSize(calculateDirectorySize(directory));
        manga.setFileModifiedAt(Instant.ofEpochMilli(Files.getLastModifiedTime(directory).toMillis())
                .atZone(java.time.ZoneId.systemDefault())
                .toLocalDateTime());

        // 设置文件类型为目录
        manga.setFileType("directory");

        // 获取页数（图片文件数量）
        manga.setTotalPages(getDirectoryImageCount(directory));

        // 生成封面
        if (deepScan) {
            generateDirectoryCover(manga, directory);
        }

        return manga;
    }

    /**
     * 更新漫画目录信息
     */
    private void updateMangaDirectory(Manga manga, Path directory) throws IOException {
        manga.setFileSize(calculateDirectorySize(directory));
        manga.setFileModifiedAt(Instant.ofEpochMilli(Files.getLastModifiedTime(directory).toMillis())
                .atZone(java.time.ZoneId.systemDefault())
                .toLocalDateTime());

        // 重新获取页数
        int newTotalPages = getDirectoryImageCount(directory);
        if (manga.getTotalPages() != newTotalPages) {
            manga.setTotalPages(newTotalPages);

            // 更新阅读进度的总页数
            ReadingProgress progress = progressRepository.findByMangaId(manga.getId())
                    .orElse(null);
            if (progress != null) {
                progress.setTotalPages(newTotalPages);
                progressRepository.save(progress);
            }
        }

        // 重新生成封面
        if (deepScan) {
            generateDirectoryCover(manga, directory);
        }

        mangaRepository.save(manga);
        logger.debug("更新漫画目录: {}", manga.getTitle());
    }

    /**
     * 计算目录大小
     */
    private long calculateDirectorySize(Path directory) {
        try {
            return Files.walk(directory)
                    .filter(Files::isRegularFile)
                    .filter(file -> isImageFile(file.getFileName().toString()))
                    .mapToLong(file -> {
                        try {
                            return Files.size(file);
                        } catch (IOException e) {
                            return 0L;
                        }
                    })
                    .sum();
        } catch (IOException e) {
            logger.warn("计算目录大小失败: {}", directory, e);
            return 0L;
        }
    }

    /**
     * 获取目录中图片文件数量
     */
    private int getDirectoryImageCount(Path directory) {
        try {
            return (int) Files.list(directory)
                    .filter(Files::isRegularFile)
                    .filter(file -> isImageFile(file.getFileName().toString()))
                    .count();
        } catch (IOException e) {
            logger.warn("获取目录图片数量失败: {}", directory, e);
            return 0;
        }
    }

    /**
     * 生成目录封面
     */
    private void generateDirectoryCover(Manga manga, Path directory) {
        try {
            // 获取目录中按文件名自然排序的第一张图片
            Optional<Path> firstImage = Files.list(directory)
                    .filter(Files::isRegularFile)
                    .filter(file -> isImageFile(file.getFileName().toString()))
                    .sorted(this::naturalSort)
                    .findFirst();

            if (firstImage.isPresent()) {
                // 生成封面缓存路径
                String coverPath = "covers/dir_" + Math.abs(directory.toString().hashCode()) + ".jpg";
                manga.setCoverImage(coverPath);
                
                // TODO: 实际复制或处理封面图片到缓存目录
                logger.debug("生成目录封面: {} -> {}", firstImage.get(), coverPath);
            }
        } catch (IOException e) {
            logger.warn("生成目录封面失败: {}", directory, e);
        }
    }

    /**
     * 自然排序比较器
     */
    private int naturalSort(Path a, Path b) {
        return compareNatural(a.getFileName().toString(), b.getFileName().toString());
    }

    /**
     * 自然排序字符串比较
     */
    private int compareNatural(String a, String b) {
        int aIndex = 0, bIndex = 0;
        
        while (aIndex < a.length() && bIndex < b.length()) {
            char aChar = a.charAt(aIndex);
            char bChar = b.charAt(bIndex);
            
            if (Character.isDigit(aChar) && Character.isDigit(bChar)) {
                // 比较数字部分
                StringBuilder aNum = new StringBuilder();
                StringBuilder bNum = new StringBuilder();
                
                while (aIndex < a.length() && Character.isDigit(a.charAt(aIndex))) {
                    aNum.append(a.charAt(aIndex++));
                }
                
                while (bIndex < b.length() && Character.isDigit(b.charAt(bIndex))) {
                    bNum.append(b.charAt(bIndex++));
                }
                
                int numCompare = Integer.compare(
                    Integer.parseInt(aNum.toString()),
                    Integer.parseInt(bNum.toString())
                );
                
                if (numCompare != 0) {
                    return numCompare;
                }
            } else {
                // 比较字符部分
                int charCompare = Character.compare(Character.toLowerCase(aChar), Character.toLowerCase(bChar));
                if (charCompare != 0) {
                    return charCompare;
                }
                aIndex++;
                bIndex++;
            }
        }
        
        return Integer.compare(a.length(), b.length());
    }

    /**
     * 扫描结果类
     */
    public static class ScanResult {
        public int addedCount = 0;
        public int updatedCount = 0;
        public int deletedCount = 0;
        public String error;

        public ScanResult() {}

        public ScanResult(int addedCount, int updatedCount, int deletedCount, String error) {
            this.addedCount = addedCount;
            this.updatedCount = updatedCount;
            this.deletedCount = deletedCount;
            this.error = error;
        }

        public int getTotalCount() {
            return addedCount + updatedCount + deletedCount;
        }

        public boolean hasError() {
            return error != null;
        }
    }

    /**
     * 快速扫描（仅检查文件存在性）
     */
    @Async
    public CompletableFuture<ScanResult> quickScanLibrary(Long libraryId) {
        logger.info("开始快速扫描漫画库: {}", libraryId);

        MangaLibrary library = libraryRepository.findById(libraryId)
                .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + libraryId));

        ScanResult result = new ScanResult();

        try {
            List<Manga> mangas = mangaRepository.findByLibraryId(libraryId);

            for (Manga manga : mangas) {
                Path filePath = Paths.get(manga.getFilePath());
                if (!Files.exists(filePath)) {
                    handleDeletedFile(manga.getFilePath(), library);
                    result.deletedCount++;
                }
            }

            updateLibraryStatistics(library);
            library.setLastScanAt(LocalDateTime.now());
            libraryRepository.save(library);

            logger.info("快速扫描完成: {} - 删除: {}", libraryId, result.deletedCount);

        } catch (Exception e) {
            logger.error("快速扫描失败: {}", libraryId, e);
            result.error = e.getMessage();
        }

        return CompletableFuture.completedFuture(result);
    }

    /**
     * 扫描单个文件
     */
    public Manga scanSingleFile(String filePath, Long libraryId) {
        Path file = Paths.get(filePath);

        if (!Files.exists(file)) {
            throw new IllegalArgumentException("文件不存在: " + filePath);
        }

        MangaLibrary library = libraryRepository.findById(libraryId)
                .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + libraryId));

        try {
            Manga manga = createMangaFromFile(file, library);
            manga = mangaRepository.save(manga);

            // 创建初始阅读进度
            ReadingProgress progress = new ReadingProgress();
            progress.setManga(manga);
            progress.setCurrentPage(1);
            progress.setTotalPages(manga.getTotalPages());
            progressRepository.save(progress);

            logger.info("扫描单个文件完成: {}", manga.getTitle());
            return manga;

        } catch (Exception e) {
            logger.error("扫描单个文件失败: {}", filePath, e);
            throw new RuntimeException("扫描文件失败", e);
        }
    }
}
