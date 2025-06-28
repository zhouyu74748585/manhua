package com.manhua.service;

import com.manhua.entity.MangaLibrary;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * 文件系统服务类
 * 支持本地文件系统和网络文件系统（SMB、FTP、WebDAV）
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Service
public class FileSystemService {

    private static final Logger logger = LoggerFactory.getLogger(FileSystemService.class);

    @Value("${manhua.data-dir}")
    private String dataDirectory;

    @Value("${manhua.cache-dir}")
    private String cacheDirectory;

    @Value("${manhua.temp-dir}")
    private String tempDirectory;

    /**
     * 测试文件系统连接
     */
    public boolean testConnection(MangaLibrary library) {
        try {
            switch (library.getType()) {
                case LOCAL:
                    return testLocalConnection(library.getPath());
                case SMB:
                    return testSmbConnection(library);
                case FTP:
                    return testFtpConnection(library);
                case WEBDAV:
                    return testWebDavConnection(library);
                default:
                    return false;
            }
        } catch (Exception e) {
            logger.error("测试连接失败: {} - {}", library.getName(), e.getMessage());
            return false;
        }
    }

    /**
     * 测试本地文件系统连接
     */
    private boolean testLocalConnection(String path) {
        try {
            Path localPath = Paths.get(path);
            return Files.exists(localPath) && Files.isDirectory(localPath) && Files.isReadable(localPath);
        } catch (Exception e) {
            logger.warn("本地路径测试失败: {} - {}", path, e.getMessage());
            return false;
        }
    }

    /**
     * 测试SMB连接
     */
    private boolean testSmbConnection(MangaLibrary library) {
        // TODO: 实现SMB连接测试
        logger.debug("测试SMB连接: {}", library.getPath());
        return true;
    }

    /**
     * 测试FTP连接
     */
    private boolean testFtpConnection(MangaLibrary library) {
        // TODO: 实现FTP连接测试
        logger.debug("测试FTP连接: {}", library.getPath());
        return true;
    }

    /**
     * 测试WebDAV连接
     */
    private boolean testWebDavConnection(MangaLibrary library) {
        // TODO: 实现WebDAV连接测试
        logger.debug("测试WebDAV连接: {}", library.getPath());
        return true;
    }

    /**
     * 列出目录内容
     */
    public List<FileInfo> listDirectory(String path) throws IOException {
        Path dirPath = Paths.get(path);

        if (!Files.exists(dirPath)) {
            throw new FileNotFoundException("目录不存在: " + path);
        }

        if (!Files.isDirectory(dirPath)) {
            throw new IllegalArgumentException("路径不是目录: " + path);
        }

        try (Stream<Path> stream = Files.list(dirPath)) {
            return stream
                    .map(this::createFileInfo)
                    .filter(Objects::nonNull)
                    .sorted(Comparator.comparing(FileInfo::getName))
                    .collect(Collectors.toList());
        }
    }

    /**
     * 创建文件信息对象
     */
    private FileInfo createFileInfo(Path path) {
        try {
            BasicFileAttributes attrs = Files.readAttributes(path, BasicFileAttributes.class);

            FileInfo info = new FileInfo();
            info.setName(path.getFileName().toString());
            info.setPath(path.toAbsolutePath().toString());
            info.setDirectory(attrs.isDirectory());
            info.setSize(attrs.size());
            info.setLastModified(new Date(attrs.lastModifiedTime().toMillis()));
            info.setReadable(Files.isReadable(path));
            info.setWritable(Files.isWritable(path));

            return info;
        } catch (IOException e) {
            logger.warn("获取文件信息失败: {} - {}", path, e.getMessage());
            return null;
        }
    }

    /**
     * 读取文件内容
     */
    public byte[] readFile(String filePath) throws IOException {
        Path path = Paths.get(filePath);

        if (!Files.exists(path)) {
            throw new FileNotFoundException("文件不存在: " + filePath);
        }

        return Files.readAllBytes(path);
    }

    /**
     * 读取文件的部分内容
     */
    public byte[] readFileRange(String filePath, long start, long length) throws IOException {
        Path path = Paths.get(filePath);

        if (!Files.exists(path)) {
            throw new FileNotFoundException("文件不存在: " + filePath);
        }

        try (RandomAccessFile file = new RandomAccessFile(path.toFile(), "r")) {
            file.seek(start);

            int bytesToRead = (int) Math.min(length, file.length() - start);
            byte[] buffer = new byte[bytesToRead];

            int bytesRead = file.read(buffer);
            if (bytesRead < bytesToRead) {
                return Arrays.copyOf(buffer, bytesRead);
            }

            return buffer;
        }
    }

    /**
     * 写入文件
     */
    public void writeFile(String filePath, byte[] content) throws IOException {
        Path path = Paths.get(filePath);

        // 创建父目录
        Path parentDir = path.getParent();
        if (parentDir != null && !Files.exists(parentDir)) {
            Files.createDirectories(parentDir);
        }

        Files.write(path, content, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
    }

    /**
     * 复制文件
     */
    public void copyFile(String sourcePath, String targetPath) throws IOException {
        Path source = Paths.get(sourcePath);
        Path target = Paths.get(targetPath);

        // 创建目标目录
        Path targetDir = target.getParent();
        if (targetDir != null && !Files.exists(targetDir)) {
            Files.createDirectories(targetDir);
        }

        Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
    }

    /**
     * 移动文件
     */
    public void moveFile(String sourcePath, String targetPath) throws IOException {
        Path source = Paths.get(sourcePath);
        Path target = Paths.get(targetPath);

        // 创建目标目录
        Path targetDir = target.getParent();
        if (targetDir != null && !Files.exists(targetDir)) {
            Files.createDirectories(targetDir);
        }

        Files.move(source, target, StandardCopyOption.REPLACE_EXISTING);
    }

    /**
     * 删除文件或目录
     */
    public void delete(String path) throws IOException {
        Path filePath = Paths.get(path);

        if (!Files.exists(filePath)) {
            return;
        }

        if (Files.isDirectory(filePath)) {
            deleteDirectory(filePath);
        } else {
            Files.delete(filePath);
        }
    }

    /**
     * 递归删除目录
     */
    private void deleteDirectory(Path directory) throws IOException {
        Files.walkFileTree(directory, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                Files.delete(file);
                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
                Files.delete(dir);
                return FileVisitResult.CONTINUE;
            }
        });
    }

    /**
     * 创建目录
     */
    public void createDirectory(String path) throws IOException {
        Path dirPath = Paths.get(path);
        Files.createDirectories(dirPath);
    }

    /**
     * 获取文件大小
     */
    public long getFileSize(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        return Files.size(path);
    }

    /**
     * 检查文件是否存在
     */
    public boolean exists(String path) {
        return Files.exists(Paths.get(path));
    }

    /**
     * 检查是否为目录
     */
    public boolean isDirectory(String path) {
        return Files.isDirectory(Paths.get(path));
    }

    /**
     * 检查是否为文件
     */
    public boolean isFile(String path) {
        return Files.isRegularFile(Paths.get(path));
    }

    /**
     * 获取文件最后修改时间
     */
    public Date getLastModified(String filePath) throws IOException {
        Path path = Paths.get(filePath);
        return new Date(Files.getLastModifiedTime(path).toMillis());
    }

    /**
     * 从压缩文件中提取文件
     */
    public byte[] extractFileFromArchive(String archivePath, String entryName) throws IOException {
        String extension = getFileExtension(archivePath).toLowerCase();

        switch (extension) {
            case ".zip":
            case ".cbz":
                return extractFromZip(archivePath, entryName);
            case ".rar":
            case ".cbr":
                return extractFromRar(archivePath, entryName);
            case ".7z":
            case ".cb7":
                return extractFrom7z(archivePath, entryName);
            default:
                throw new UnsupportedOperationException("不支持的压缩格式: " + extension);
        }
    }

    /**
     * 从ZIP文件中提取文件
     */
    private byte[] extractFromZip(String zipPath, String entryName) throws IOException {
        try (ZipFile zipFile = new ZipFile(zipPath)) {
            ZipEntry entry = zipFile.getEntry(entryName);
            if (entry == null) {
                throw new FileNotFoundException("压缩文件中不存在: " + entryName);
            }

            try (InputStream inputStream = zipFile.getInputStream(entry)) {
                return inputStream.readAllBytes();
            }
        }
    }

    /**
     * 从RAR文件中提取文件
     */
    private byte[] extractFromRar(String rarPath, String entryName) throws IOException {
        // TODO: 使用junrar库实现RAR文件提取
        throw new UnsupportedOperationException("RAR文件提取功能尚未实现");
    }

    /**
     * 从7Z文件中提取文件
     */
    private byte[] extractFrom7z(String sevenZPath, String entryName) throws IOException {
        try (org.apache.commons.compress.archivers.sevenz.SevenZFile sevenZFile = 
                new org.apache.commons.compress.archivers.sevenz.SevenZFile(new java.io.File(sevenZPath))) {
            
            org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry entry;
            while ((entry = sevenZFile.getNextEntry()) != null) {
                if (entry.getName().equals(entryName) && !entry.isDirectory()) {
                    byte[] content = new byte[(int) entry.getSize()];
                    sevenZFile.read(content);
                    return content;
                }
            }
            
            throw new java.io.FileNotFoundException("文件未找到: " + entryName);
        } catch (Exception e) {
            logger.error("从7Z文件提取失败: {} - {}", sevenZPath, entryName, e);
            throw new IOException("从7Z文件提取失败: " + e.getMessage(), e);
        }
    }

    /**
     * 列出压缩文件中的所有条目
     */
    public List<String> listArchiveEntries(String archivePath) throws IOException {
        String extension = getFileExtension(archivePath).toLowerCase();

        switch (extension) {
            case ".zip":
            case ".cbz":
                return listZipEntries(archivePath);
            case ".rar":
            case ".cbr":
                return listRarEntries(archivePath);
            case ".7z":
            case ".cb7":
                return list7zEntries(archivePath);
            default:
                throw new UnsupportedOperationException("不支持的压缩格式: " + extension);
        }
    }

    /**
     * 列出ZIP文件中的条目
     */
    private List<String> listZipEntries(String zipPath) throws IOException {
        List<String> entries = new ArrayList<>();

        try (ZipFile zipFile = new ZipFile(zipPath)) {
            zipFile.stream()
                    .filter(entry -> !entry.isDirectory())
                    .map(ZipEntry::getName)
                    .forEach(entries::add);
        }

        return entries;
    }

    /**
     * 列出RAR文件中的条目
     */
    private List<String> listRarEntries(String rarPath) throws IOException {
        List<String> entries = new ArrayList<>();
        
        try {
            com.github.junrar.Archive archive = new com.github.junrar.Archive(new java.io.File(rarPath));
            
            com.github.junrar.rarfile.FileHeader fileHeader = archive.nextFileHeader();
            while (fileHeader != null) {
                if (!fileHeader.isDirectory()) {
                    entries.add(fileHeader.getFileName());
                }
                fileHeader = archive.nextFileHeader();
            }
            
            archive.close();
        } catch (Exception e) {
            logger.error("列出RAR文件条目失败: {}", rarPath, e);
            throw new IOException("列出RAR文件条目失败: " + e.getMessage(), e);
        }
        
        return entries;
    }

    /**
     * 列出7Z文件中的条目
     */
    private List<String> list7zEntries(String sevenZPath) throws IOException {
        List<String> entries = new ArrayList<>();
        
        try (org.apache.commons.compress.archivers.sevenz.SevenZFile sevenZFile = 
                new org.apache.commons.compress.archivers.sevenz.SevenZFile(new java.io.File(sevenZPath))) {
            
            org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry entry;
            while ((entry = sevenZFile.getNextEntry()) != null) {
                if (!entry.isDirectory()) {
                    entries.add(entry.getName());
                }
            }
        } catch (Exception e) {
            logger.error("列出7Z文件条目失败: {}", sevenZPath, e);
            throw new IOException("列出7Z文件条目失败: " + e.getMessage(), e);
        }
        
        return entries;
    }

    /**
     * 获取临时文件路径
     */
    public String getTempFilePath(String prefix, String suffix) {
        try {
            Path tempDir = Paths.get(tempDirectory);
            if (!Files.exists(tempDir)) {
                Files.createDirectories(tempDir);
            }

            Path tempFile = Files.createTempFile(tempDir, prefix, suffix);
            return tempFile.toAbsolutePath().toString();
        } catch (IOException e) {
            logger.error("创建临时文件失败", e);
            throw new RuntimeException("创建临时文件失败", e);
        }
    }

    /**
     * 获取缓存文件路径
     */
    public String getCacheFilePath(String... pathSegments) {
        Path cachePath = Paths.get(cacheDirectory);

        for (String segment : pathSegments) {
            cachePath = cachePath.resolve(segment);
        }

        try {
            Path parentDir = cachePath.getParent();
            if (parentDir != null && !Files.exists(parentDir)) {
                Files.createDirectories(parentDir);
            }
        } catch (IOException e) {
            logger.error("创建缓存目录失败: {}", cachePath.getParent(), e);
        }

        return cachePath.toAbsolutePath().toString();
    }

    /**
     * 获取数据文件路径
     */
    public String getDataFilePath(String... pathSegments) {
        Path dataPath = Paths.get(dataDirectory);

        for (String segment : pathSegments) {
            dataPath = dataPath.resolve(segment);
        }

        try {
            Path parentDir = dataPath.getParent();
            if (parentDir != null && !Files.exists(parentDir)) {
                Files.createDirectories(parentDir);
            }
        } catch (IOException e) {
            logger.error("创建数据目录失败: {}", dataPath.getParent(), e);
        }

        return dataPath.toAbsolutePath().toString();
    }

    /**
     * 清理临时文件
     */
    public void cleanupTempFiles() {
        try {
            Path tempDir = Paths.get(tempDirectory);
            if (!Files.exists(tempDir)) {
                return;
            }

            long cutoffTime = System.currentTimeMillis() - (24 * 60 * 60 * 1000); // 24小时前

            Files.walkFileTree(tempDir, new SimpleFileVisitor<Path>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    if (attrs.lastModifiedTime().toMillis() < cutoffTime) {
                        Files.delete(file);
                        logger.debug("删除临时文件: {}", file);
                    }
                    return FileVisitResult.CONTINUE;
                }
            });

        } catch (IOException e) {
            logger.error("清理临时文件失败", e);
        }
    }

    /**
     * 清理缓存文件
     */
    public void cleanupCacheFiles(long maxAge) {
        try {
            Path cacheDir = Paths.get(cacheDirectory);
            if (!Files.exists(cacheDir)) {
                return;
            }

            long cutoffTime = System.currentTimeMillis() - maxAge;

            Files.walkFileTree(cacheDir, new SimpleFileVisitor<Path>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    if (attrs.lastModifiedTime().toMillis() < cutoffTime) {
                        Files.delete(file);
                        logger.debug("删除缓存文件: {}", file);
                    }
                    return FileVisitResult.CONTINUE;
                }
            });

        } catch (IOException e) {
            logger.error("清理缓存文件失败", e);
        }
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        return lastDotIndex > 0 ? fileName.substring(lastDotIndex) : "";
    }

    /**
     * 文件信息类
     */
    public static class FileInfo {
        private String name;
        private String path;
        private boolean directory;
        private long size;
        private Date lastModified;
        private boolean readable;
        private boolean writable;

        // Getters and Setters
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getPath() { return path; }
        public void setPath(String path) { this.path = path; }

        public boolean isDirectory() { return directory; }
        public void setDirectory(boolean directory) { this.directory = directory; }

        public long getSize() { return size; }
        public void setSize(long size) { this.size = size; }

        public Date getLastModified() { return lastModified; }
        public void setLastModified(Date lastModified) { this.lastModified = lastModified; }

        public boolean isReadable() { return readable; }
        public void setReadable(boolean readable) { this.readable = readable; }

        public boolean isWritable() { return writable; }
        public void setWritable(boolean writable) { this.writable = writable; }
    }
}
