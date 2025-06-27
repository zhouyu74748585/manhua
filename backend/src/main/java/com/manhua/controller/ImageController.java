package com.manhua.controller;

import com.manhua.service.ImageService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 图像处理控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/images")
@CrossOrigin(origins = "*")
public class ImageController {

    private static final Logger logger = LoggerFactory.getLogger(ImageController.class);

    @Autowired
    private ImageService imageService;

    /**
     * 生成缩略图
     */
    @PostMapping("/thumbnail")
    public ResponseEntity<byte[]> generateThumbnail(
            @RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            byte[] thumbnailData = imageService.generateThumbnail(
                    file.getBytes());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(thumbnailData.length);

            return new ResponseEntity<>(thumbnailData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("生成缩略图失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 生成预览图
     */
    @PostMapping("/preview")
    public ResponseEntity<byte[]> generatePreview(
            @RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            byte[] previewData = imageService.generatePreview(
                    file.getBytes());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(previewData.length);

            return new ResponseEntity<>(previewData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("生成预览图失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 调整图像大小
     */
    @PostMapping("/resize")
    public ResponseEntity<byte[]> resizeImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam int width,
            @RequestParam int height,
            @RequestParam(defaultValue = "true") boolean keepAspectRatio) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            byte[] resizedData = imageService.resizeImage(
                    file.getBytes(), width, height, keepAspectRatio);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(resizedData.length);

            return new ResponseEntity<>(resizedData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("调整图像大小失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 旋转图像
     */
    @PostMapping("/rotate")
    public ResponseEntity<byte[]> rotateImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam int angle) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            byte[] rotatedData = imageService.rotateImage(file.getBytes(), angle);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(rotatedData.length);

            return new ResponseEntity<>(rotatedData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("旋转图像失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 调整图像亮度
     */
    @PostMapping("/brightness")
    public ResponseEntity<byte[]> adjustBrightness(
            @RequestParam("file") MultipartFile file,
            @RequestParam float brightness) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            byte[] adjustedData = imageService.adjustBrightness(file.getBytes(), brightness);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(adjustedData.length);

            return new ResponseEntity<>(adjustedData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("调整图像亮度失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 调整图像对比度
     */
    @PostMapping("/contrast")
    public ResponseEntity<byte[]> adjustContrast(
            @RequestParam("file") MultipartFile file,
            @RequestParam float contrast) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            byte[] adjustedData = imageService.adjustContrast(file.getBytes(), contrast);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(adjustedData.length);

            return new ResponseEntity<>(adjustedData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("调整图像对比度失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 从压缩文件提取图像
     */
    @GetMapping("/extract")
    public ResponseEntity<byte[]> extractImageFromArchive(
            @RequestParam String archivePath,
            @RequestParam String entryName,
            @RequestParam(defaultValue = "false") boolean thumbnail) {
        try {
            byte[] imageData = imageService.extractAndProcessImage(
                    archivePath, entryName, thumbnail);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(imageData.length);

            return new ResponseEntity<>(imageData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("从压缩文件提取图像失败: {} - {}", archivePath, entryName, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 生成漫画封面
     */
    @PostMapping("/generate-cover")
    public ResponseEntity<Map<String, Object>> generateMangaCover(
            @RequestBody Map<String, String> request) {
        try {
            String filePath = request.get("filePath");
            if (filePath == null || filePath.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "文件路径不能为空"));
            }
            Long mangaId = Long.valueOf(request.get("mangaId"));

            String coverPath = imageService.generateMangaCover(filePath,mangaId);
            return ResponseEntity.ok(Map.of(
                    "message", "封面生成成功",
                    "coverPath", coverPath
            ));
        } catch (Exception e) {
            logger.error("生成漫画封面失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "生成封面失败"));
        }
    }

    /**
     * 获取图像信息
     */
    @PostMapping("/info")
    public ResponseEntity<Object> getImageInfo(
            @RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "文件不能为空"));
            }

            ImageService.ImageInfo info = imageService.getImageInfo(file.getBytes());
            return ResponseEntity.ok(info);
        } catch (Exception e) {
            logger.error("获取图像信息失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "获取图像信息失败"));
        }
    }

    /**
     * 保存图像文件
     */
    @PostMapping("/save")
    public ResponseEntity<Map<String, Object>> saveImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam String fileName) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "文件不能为空"));
            }

            if (fileName == null || fileName.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "文件名不能为空"));
            }

            imageService.saveImage(file.getBytes(), fileName);
            return ResponseEntity.ok(Map.of(
                    "message", "图像保存成功"
            ));
        } catch (Exception e) {
            logger.error("保存图像失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "保存图像失败"));
        }
    }

    /**
     * 清理图像缓存
     */
    @PostMapping("/clear-cache")
    public ResponseEntity<Map<String, Object>> clearImageCache() {
        try {
            imageService.clearImageCache();
            return ResponseEntity.ok(Map.of("message", "图像缓存已清理"));
        } catch (Exception e) {
            logger.error("清理图像缓存失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "清理缓存失败"));
        }
    }
}
