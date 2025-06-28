package com.manhua.controller;

import com.manhua.entity.Manga;
import com.manhua.service.MangaService;
import com.manhua.service.ReadingProgressService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * 阅读控制器 - 处理漫画内容的获取和阅读功能
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/reader")
@CrossOrigin(origins = "*")
public class ReaderController {

    private static final Logger logger = LoggerFactory.getLogger(ReaderController.class);

    @Autowired
    private MangaService mangaService;

    @Autowired
    private ReadingProgressService readingProgressService;

    // 支持的图片扩展名
    private static final List<String> IMAGE_EXTENSIONS = List.of(
            ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp"
    );

    /**
     * 获取漫画页面图片
     */
    @GetMapping("/manga/{mangaId}/page/{pageNumber}")
    public ResponseEntity<byte[]> getMangaPage(
            @PathVariable Long mangaId,
            @PathVariable int pageNumber,
            @RequestParam(defaultValue = "false") boolean thumbnail) {
        try {
            Optional<Manga> mangaOpt = mangaService.getMangaById(mangaId);
            if (mangaOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            Manga manga = mangaOpt.get();
            Path filePath = Paths.get(manga.getFilePath());

            if (!Files.exists(filePath)) {
                return ResponseEntity.notFound().build();
            }

            byte[] imageData = null;
            String fileType = manga.getFileType();

            // 根据文件类型提取图片
            switch (fileType.toLowerCase()) {
                case "directory":
                    imageData = getImageFromDirectory(filePath, pageNumber);
                    break;
                case "zip":
                case "cbz":
                    imageData = getImageFromZip(filePath, pageNumber);
                    break;
                case "rar":
                case "cbr":
                    imageData = getImageFromRar(filePath, pageNumber);
                    break;
                /*case "7z":
                    imageData = getImageFrom7z(filePath, pageNumber);
                    break;
                case "pdf":
                    imageData = getImageFromPdf(filePath, pageNumber);
                    break;*/
                default:
                    return ResponseEntity.badRequest().build();
            }

            if (imageData == null) {
                return ResponseEntity.notFound().build();
            }

            // 更新阅读进度
            try {
                readingProgressService.updateProgress(mangaId, pageNumber + 1);
            } catch (Exception e) {
                logger.warn("更新阅读进度失败: {} - {}", mangaId, e.getMessage());
            }

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(imageData.length);

            return new ResponseEntity<>(imageData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("获取漫画页面失败: {} - {}", mangaId, pageNumber, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取漫画页面列表
     */
    @GetMapping("/manga/{mangaId}/pages")
    public ResponseEntity<List<String>> getMangaPages(@PathVariable Long mangaId) {
        try {
            Optional<Manga> mangaOpt = mangaService.getMangaById(mangaId);
            if (mangaOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            Manga manga = mangaOpt.get();
            Path filePath = Paths.get(manga.getFilePath());

            if (!Files.exists(filePath)) {
                return ResponseEntity.notFound().build();
            }

            List<String> pageNames = new ArrayList<>();
            String fileType = manga.getFileType();

            // 根据文件类型获取页面列表
            switch (fileType.toLowerCase()) {
                case "directory":
                    pageNames = getPageNamesFromDirectory(filePath);
                    break;
                case "zip":
                case "cbz":
                    pageNames = getPageNamesFromZip(filePath);
                    break;
                case "rar":
                case "cbr":
                    pageNames = getPageNamesFromRar(filePath);
                    break;
                case "7z":
                    pageNames = getPageNamesFrom7z(filePath);
                    break;
                /*case "pdf":
                    pageNames = getPageNamesFromPdf(filePath);
                    break;*/
                default:
                    return ResponseEntity.badRequest().build();
            }

            return ResponseEntity.ok(pageNames);
        } catch (Exception e) {
            logger.error("获取漫画页面列表失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 从目录中获取图片
     */
    private byte[] getImageFromDirectory(Path directory, int pageNumber) throws IOException {
        List<Path> imageFiles = Files.list(directory)
                .filter(Files::isRegularFile)
                .filter(file -> isImageFile(file.getFileName().toString()))
                .sorted(this::naturalSort)
                .toList();

        if (pageNumber < 0 || pageNumber >= imageFiles.size()) {
            return null;
        }

        return Files.readAllBytes(imageFiles.get(pageNumber));
    }

    /**
     * 从ZIP文件中获取图片
     */
    private byte[] getImageFromZip(Path zipFile, int pageNumber) throws IOException {
        try (ZipFile zip = new ZipFile(zipFile.toFile())) {
            List<ZipEntry> imageEntries = (List<ZipEntry>) zip.stream()
                    .filter(entry -> !entry.isDirectory())
                    .filter(entry -> isImageFile(entry.getName()))
                    .sorted((a, b) -> compareNatural(a.getName(), b.getName()))
                    .toList();

            if (pageNumber < 0 || pageNumber >= imageEntries.size()) {
                return null;
            }

            ZipEntry entry = imageEntries.get(pageNumber);
            try (InputStream inputStream = zip.getInputStream(entry);
                 ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                
                inputStream.transferTo(outputStream);
                return outputStream.toByteArray();
            }
        }
    }

    /**
     * 从RAR文件中获取图片
     */
    private byte[] getImageFromRar(Path rarFile, int pageNumber) throws IOException {
        try {
            com.github.junrar.Archive archive = new com.github.junrar.Archive(rarFile.toFile());
            
            // 收集所有图片文件并排序
            List<com.github.junrar.rarfile.FileHeader> imageHeaders = new ArrayList<>();
            com.github.junrar.rarfile.FileHeader fileHeader = archive.nextFileHeader();
            
            while (fileHeader != null) {
                if (!fileHeader.isDirectory() && isImageFile(fileHeader.getFileName())) {
                    imageHeaders.add(fileHeader);
                }
                fileHeader = archive.nextFileHeader();
            }
            
            // 按文件名自然排序
            imageHeaders.sort((a, b) -> compareNatural(a.getFileName(), b.getFileName()));
            
            if (pageNumber < 0 || pageNumber >= imageHeaders.size()) {
                archive.close();
                return null;
            }
            
            // 重新打开archive来提取指定文件
            archive.close();
            archive = new com.github.junrar.Archive(rarFile.toFile());
            
            com.github.junrar.rarfile.FileHeader targetHeader = imageHeaders.get(pageNumber);
            
            try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                archive.extractFile(targetHeader, outputStream);
                archive.close();
                return outputStream.toByteArray();
            }
        } catch (Exception e) {
            logger.error("从RAR文件提取图片失败: {} - {}", rarFile, e.getMessage());
            return null;
        }
    }

   /* *//**
     * 从7Z文件中获取图片
     *//*
    private byte[] getImageFrom7z(Path sevenZFile, int pageNumber) throws IOException {
        try (org.apache.commons.compress.archivers.sevenz.SevenZFile sevenZ = 
                new org.apache.commons.compress.archivers.sevenz.SevenZFile(sevenZFile.toFile())) {
            
            // 收集所有图片文件并排序
            List<org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry> imageEntries = new ArrayList<>();
            org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry entry;
            
            while ((entry = sevenZ.getNextEntry()) != null) {
                if (!entry.isDirectory() && isImageFile(entry.getName())) {
                    imageEntries.add(entry);
                }
            }
            
            // 按文件名自然排序
            imageEntries.sort((a, b) -> compareNatural(a.getName(), b.getName()));
            
            if (pageNumber < 0 || pageNumber >= imageEntries.size()) {
                return null;
            }
            
            // 重新读取文件到指定位置
            try (org.apache.commons.compress.archivers.sevenz.SevenZFile sevenZ2 = 
                    new org.apache.commons.compress.archivers.sevenz.SevenZFile(sevenZFile.toFile())) {
                
                org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry targetEntry = imageEntries.get(pageNumber);
                
                // 跳过到目标文件
                org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry currentEntry;
                while ((currentEntry = sevenZ2.getNextEntry()) != null) {
                    if (currentEntry.getName().equals(targetEntry.getName())) {
                        byte[] content = new byte[(int) currentEntry.getSize()];
                        sevenZ2.read(content);
                        return content;
                    }
                }
            }
        } catch (Exception e) {
            logger.error("从7Z文件提取图片失败: {} - {}", sevenZFile, e.getMessage());
        }
        return null;
    }
*/
    /**
     * 从PDF文件中获取图片（页面）
     *//*
    private byte[] getImageFromPdf(Path pdfFile, int pageNumber) throws IOException {
        try {
            org.apache.pdfbox.pdmodel.PDDocument document = org.apache.pdfbox.pdmodel.PDDocument.load(pdfFile.toFile());
            
            if (pageNumber < 0 || pageNumber >= document.getNumberOfPages()) {
                document.close();
                return null;
            }
            
            // 渲染PDF页面为图片
            org.apache.pdfbox.rendering.PDFRenderer renderer = new org.apache.pdfbox.rendering.PDFRenderer(document);
            java.awt.image.BufferedImage image = renderer.renderImageWithDPI(pageNumber, 150, org.apache.pdfbox.rendering.ImageType.RGB);
            
            // 转换为字节数组
            try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                javax.imageio.ImageIO.write(image, "JPEG", outputStream);
                document.close();
                return outputStream.toByteArray();
            }
        } catch (Exception e) {
            logger.error("从PDF文件提取页面失败: {} - {}", pdfFile, e.getMessage());
            return null;
        }
    }*/

    // 获取页面名称的方法
    private List<String> getPageNamesFromDirectory(Path directory) throws IOException {
        return Files.list(directory)
                .filter(Files::isRegularFile)
                .filter(file -> isImageFile(file.getFileName().toString()))
                .sorted(this::naturalSort)
                .map(path -> path.getFileName().toString())
                .toList();
    }

    private List<String> getPageNamesFromZip(Path zipFile) throws IOException {
        try (ZipFile zip = new ZipFile(zipFile.toFile())) {
            return zip.stream()
                    .filter(entry -> !entry.isDirectory())
                    .filter(entry -> isImageFile(entry.getName()))
                    .sorted((a, b) -> compareNatural(a.getName(), b.getName()))
                    .map(ZipEntry::getName)
                    .toList();
        }
    }

    private List<String> getPageNamesFromRar(Path rarFile) throws IOException {
        try {
            com.github.junrar.Archive archive = new com.github.junrar.Archive(rarFile.toFile());
            List<String> pageNames = new ArrayList<>();
            
            com.github.junrar.rarfile.FileHeader fileHeader = archive.nextFileHeader();
            while (fileHeader != null) {
                if (!fileHeader.isDirectory() && isImageFile(fileHeader.getFileName())) {
                    pageNames.add(fileHeader.getFileName());
                }
                fileHeader = archive.nextFileHeader();
            }
            
            archive.close();
            pageNames.sort(this::compareNatural);
            return pageNames;
        } catch (Exception e) {
            logger.error("获取RAR文件页面列表失败: {}", rarFile, e);
            return new ArrayList<>();
        }
    }

    private List<String> getPageNamesFrom7z(Path sevenZFile) throws IOException {
        try (org.apache.commons.compress.archivers.sevenz.SevenZFile sevenZ = 
                new org.apache.commons.compress.archivers.sevenz.SevenZFile(sevenZFile.toFile())) {
            
            List<String> pageNames = new ArrayList<>();
            org.apache.commons.compress.archivers.sevenz.SevenZArchiveEntry entry;
            
            while ((entry = sevenZ.getNextEntry()) != null) {
                if (!entry.isDirectory() && isImageFile(entry.getName())) {
                    pageNames.add(entry.getName());
                }
            }
            
            pageNames.sort(this::compareNatural);
            return pageNames;
        } catch (Exception e) {
            logger.error("获取7Z文件页面列表失败: {}", sevenZFile, e);
            return new ArrayList<>();
        }
    }

   /* private List<String> getPageNamesFromPdf(Path pdfFile) throws IOException {
        try {
            org.apache.pdfbox.pdmodel.PDDocument document = org.apache.pdfbox.pdmodel.PDDocument.load(pdfFile.toFile());
            int pageCount = document.getNumberOfPages();
            document.close();
            
            List<String> pageNames = new ArrayList<>();
            for (int i = 0; i < pageCount; i++) {
                pageNames.add("Page " + (i + 1));
            }
            return pageNames;
        } catch (Exception e) {
            logger.error("获取PDF文件页面列表失败: {}", pdfFile, e);
            return new ArrayList<>();
        }
    }*/

    /**
     * 判断是否为图片文件
     */
    private boolean isImageFile(String fileName) {
        String lowerName = fileName.toLowerCase();
        return IMAGE_EXTENSIONS.stream().anyMatch(lowerName::endsWith);
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
}