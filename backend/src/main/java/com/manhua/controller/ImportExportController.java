package com.manhua.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.manhua.entity.Manga;
import com.manhua.entity.MangaLibrary;
import com.manhua.entity.ReadingProgress;
import com.manhua.service.AppSettingsService;
import com.manhua.service.MangaLibraryService;
import com.manhua.service.MangaService;
import com.manhua.service.ReadingProgressService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

/**
 * 导入导出控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@CrossOrigin(origins = "*")
public class ImportExportController {

    private static final Logger logger = LoggerFactory.getLogger(ImportExportController.class);

    @Autowired
    private MangaService mangaService;

    @Autowired
    private MangaLibraryService libraryService;

    @Autowired
    private ReadingProgressService progressService;

    @Autowired
    private AppSettingsService settingsService;

    @Autowired
    private ObjectMapper objectMapper;

    @Value("${manhua.temp-dir}")
    private String tempDirectory;

    /**
     * 导出数据
     */
    @PostMapping("/api/export")
    public ResponseEntity<Map<String, Object>> exportData(
            @RequestBody Map<String, Object> options) {
        try {
            boolean includeLibraries = (Boolean) options.getOrDefault("includeLibraries", true);
            boolean includeProgress = (Boolean) options.getOrDefault("includeProgress", true);
            boolean includeSettings = (Boolean) options.getOrDefault("includeSettings", true);

            // 创建导出文件名
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String fileName = "manhua_export_" + timestamp + ".zip";
            Path exportPath = Paths.get(tempDirectory, fileName);

            // 确保临时目录存在
            Files.createDirectories(exportPath.getParent());

            // 创建ZIP文件
            try (ZipOutputStream zos = new ZipOutputStream(Files.newOutputStream(exportPath))) {

                // 导出漫画库
                if (includeLibraries) {
                    List<MangaLibrary> libraries = libraryService.getAllLibraries();
                    String librariesJson = objectMapper.writeValueAsString(libraries);

                    ZipEntry librariesEntry = new ZipEntry("libraries.json");
                    zos.putNextEntry(librariesEntry);
                    zos.write(librariesJson.getBytes());
                    zos.closeEntry();

                    // 导出漫画数据
                    List<Manga> mangas = mangaService.getAllManga();
                    String mangasJson = objectMapper.writeValueAsString(mangas);

                    ZipEntry mangasEntry = new ZipEntry("mangas.json");
                    zos.putNextEntry(mangasEntry);
                    zos.write(mangasJson.getBytes());
                    zos.closeEntry();
                }

                // 导出阅读进度
                if (includeProgress) {
                    List<ReadingProgress> progress = progressService.getAllProgress();
                    String progressJson = objectMapper.writeValueAsString(progress);

                    ZipEntry progressEntry = new ZipEntry("reading_progress.json");
                    zos.putNextEntry(progressEntry);
                    zos.write(progressJson.getBytes());
                    zos.closeEntry();
                }

                // 导出设置
                if (includeSettings) {
                    Map<String, Object> settings = settingsService.getAllSettings();
                    String settingsJson = objectMapper.writeValueAsString(settings);

                    ZipEntry settingsEntry = new ZipEntry("settings.json");
                    zos.putNextEntry(settingsEntry);
                    zos.write(settingsJson.getBytes());
                    zos.closeEntry();
                }

                // 添加元数据
                Map<String, Object> metadata = new HashMap<>();
                metadata.put("exportDate", LocalDateTime.now().toString());
                metadata.put("version", "1.0.0");
                metadata.put("includeLibraries", includeLibraries);
                metadata.put("includeProgress", includeProgress);
                metadata.put("includeSettings", includeSettings);

                String metadataJson = objectMapper.writeValueAsString(metadata);
                ZipEntry metadataEntry = new ZipEntry("metadata.json");
                zos.putNextEntry(metadataEntry);
                zos.write(metadataJson.getBytes());
                zos.closeEntry();
            }

            // 返回下载URL
            Map<String, Object> result = new HashMap<>();
            result.put("downloadUrl", "/api/export/download/" + fileName);
            result.put("fileName", fileName);
            result.put("size", Files.size(exportPath));

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("导出数据失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 下载导出文件
     */
    @GetMapping("/api/export/download/{fileName}")
    public ResponseEntity<Resource> downloadExportFile(@PathVariable String fileName) {
        try {
            Path filePath = Paths.get(tempDirectory, fileName);

            if (!Files.exists(filePath)) {
                return ResponseEntity.notFound().build();
            }

            Resource resource = new UrlResource(filePath.toUri());

            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                .body(resource);
        } catch (Exception e) {
            logger.error("下载导出文件失败: {}", fileName, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 导入数据
     */
    @PostMapping("/api/import")
    public ResponseEntity<Map<String, Object>> importData(
            @RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            Map<String, Object> result = new HashMap<>();
            Map<String, Integer> imported = new HashMap<>();
            imported.put("libraries", 0);
            imported.put("mangas", 0);
            imported.put("progress", 0);

            // 保存上传的文件
            String fileName = "import_" + System.currentTimeMillis() + ".zip";
            Path tempFile = Paths.get(tempDirectory, fileName);
            Files.createDirectories(tempFile.getParent());
            file.transferTo(tempFile.toFile());

            // 解压并处理文件
            try (ZipInputStream zis = new ZipInputStream(Files.newInputStream(tempFile))) {
                ZipEntry entry;

                while ((entry = zis.getNextEntry()) != null) {
                    String entryName = entry.getName();

                    // 读取文件内容
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = zis.read(buffer)) > 0) {
                        baos.write(buffer, 0, len);
                    }
                    String content = baos.toString();

                    // 根据文件名处理不同类型的数据
                    switch (entryName) {
                        case "libraries.json":
                            List<MangaLibrary> libraries = objectMapper.readValue(content,
                                objectMapper.getTypeFactory().constructCollectionType(List.class, MangaLibrary.class));
                            for (MangaLibrary library : libraries) {
                                try {
                                    // 重置ID，让数据库自动生成
                                    library.setId(null);
                                    libraryService.createLibrary(library);
                                    imported.put("libraries", imported.get("libraries") + 1);
                                } catch (Exception e) {
                                    logger.warn("导入漫画库失败: {}", library.getName(), e);
                                }
                            }
                            break;

                        case "mangas.json":
                            List<Manga> mangas = objectMapper.readValue(content,
                                objectMapper.getTypeFactory().constructCollectionType(List.class, Manga.class));
                            for (Manga manga : mangas) {
                                try {
                                    // 重置ID，让数据库自动生成
                                    manga.setId(null);
                                    mangaService.createManga(manga);
                                    imported.put("mangas", imported.get("mangas") + 1);
                                } catch (Exception e) {
                                    logger.warn("导入漫画失败: {}", manga.getTitle(), e);
                                }
                            }
                            break;

                        case "reading_progress.json":
                            List<ReadingProgress> progressList = objectMapper.readValue(content,
                                objectMapper.getTypeFactory().constructCollectionType(List.class, ReadingProgress.class));
                            for (ReadingProgress progress : progressList) {
                                try {
                                    // 重置ID，让数据库自动生成
                                    progress.setId(null);
                                    progressService.createProgress(progress);
                                    imported.put("progress", imported.get("progress") + 1);
                                } catch (Exception e) {
                                    logger.warn("导入阅读进度失败: {}", progress.getManga().getId(), e);
                                }
                            }
                            break;

                        case "settings.json":
                            @SuppressWarnings("unchecked")
                            Map<String, Object> settings = objectMapper.readValue(content, Map.class);
                            try {
                                settingsService.saveSettings(settings);
                            } catch (Exception e) {
                                logger.warn("导入设置失败", e);
                            }
                            break;
                    }

                    zis.closeEntry();
                }
            }

            // 清理临时文件
            Files.deleteIfExists(tempFile);

            result.put("imported", imported);
            result.put("message", "导入完成");

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("导入数据失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}
