package com.manhua.service;

import org.imgscalr.Scalr;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

import static org.imgscalr.Scalr.Rotation.*;

/**
 * 图像处理服务类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Service
public class ImageService {

    private static final Logger logger = LoggerFactory.getLogger(ImageService.class);

    @Autowired
    private FileSystemService fileSystemService;

    @Value("${app.image.thumbnail.width:300}")
    private int thumbnailWidth;

    @Value("${app.image.thumbnail.height:450}")
    private int thumbnailHeight;

    @Value("${app.image.preview.width:800}")
    private int previewWidth;

    @Value("${app.image.preview.height:1200}")
    private int previewHeight;

    @Value("${app.image.quality:85}")
    private int imageQuality;

    @Value("${app.image.cache.enabled:true}")
    private boolean cacheEnabled;

    @Value("${manhua.cache-dir}")
    private String cacheDirectory;

    /**
     * 生成缩略图
     */
    @Cacheable(value = "thumbnails", condition = "#cacheEnabled == true")
    public byte[] generateThumbnail(byte[] imageData) throws IOException {
        return resizeImage(imageData, thumbnailWidth, thumbnailHeight, true);
    }

    /**
     * 生成预览图
     */
    @Cacheable(value = "previews", condition = "#cacheEnabled == true")
    public byte[] generatePreview(byte[] imageData) throws IOException {
        return resizeImage(imageData, previewWidth, previewHeight, false);
    }

    /**
     * 调整图像大小
     */
    public byte[] resizeImage(byte[] imageData, int targetWidth, int targetHeight, boolean crop) throws IOException {
        try (ByteArrayInputStream inputStream = new ByteArrayInputStream(imageData)) {
            BufferedImage originalImage = ImageIO.read(inputStream);

            if (originalImage == null) {
                throw new IOException("无法读取图像数据");
            }

            BufferedImage resizedImage;

            if (crop) {
                // 裁剪并调整大小，保持纵横比
                resizedImage = Scalr.resize(
                        originalImage,
                        Scalr.Method.QUALITY,
                        Scalr.Mode.AUTOMATIC,
                        targetWidth,
                        targetHeight,
                        Scalr.OP_ANTIALIAS
                );
            } else {
                // 仅调整大小，保持纵横比
                int originalWidth = originalImage.getWidth();
                int originalHeight = originalImage.getHeight();

                double widthRatio = (double) targetWidth / originalWidth;
                double heightRatio = (double) targetHeight / originalHeight;
                double ratio = Math.min(widthRatio, heightRatio);

                int newWidth = (int) (originalWidth * ratio);
                int newHeight = (int) (originalHeight * ratio);

                resizedImage = Scalr.resize(
                        originalImage,
                        Scalr.Method.QUALITY,
                        Scalr.Mode.FIT_EXACT,
                        newWidth,
                        newHeight,
                        Scalr.OP_ANTIALIAS
                );
            }

            // 转换为字节数组
            try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                ImageIO.write(resizedImage, "JPEG", outputStream);
                return outputStream.toByteArray();
            } finally {
                // 释放资源
                if (resizedImage != originalImage) {
                    resizedImage.flush();
                }
                originalImage.flush();
            }
        }
    }

    /**
     * 从压缩文件中提取并处理图像
     */
    public byte[] extractAndProcessImage(String archivePath, String entryName, boolean thumbnail) throws IOException {
        // 检查缓存
        if (cacheEnabled) {
            String cacheKey = getCacheKey(archivePath, entryName, thumbnail);
            String cachePath = fileSystemService.getCacheFilePath("images", cacheKey);

            if (Files.exists(Paths.get(cachePath))) {
                return Files.readAllBytes(Paths.get(cachePath));
            }
        }

        // 提取原始图像
        byte[] imageData = fileSystemService.extractFileFromArchive(archivePath, entryName);

        // 处理图像
        byte[] processedImage;
        if (thumbnail) {
            processedImage = generateThumbnail(imageData);
        } else {
            processedImage = generatePreview(imageData);
        }

        // 保存到缓存
        if (cacheEnabled) {
            String cacheKey = getCacheKey(archivePath, entryName, thumbnail);
            String cachePath = fileSystemService.getCacheFilePath("images", cacheKey);

            try {
                Files.write(Paths.get(cachePath), processedImage,
                        StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            } catch (IOException e) {
                logger.warn("保存图像缓存失败: {}", cachePath, e);
            }
        }

        return processedImage;
    }

    /**
     * 生成缓存键
     */
    private String getCacheKey(String archivePath, String entryName, boolean thumbnail) {
        String type = thumbnail ? "thumb" : "preview";
        String hash = String.valueOf(Math.abs((archivePath + entryName).hashCode()));
        return type + "_" + hash + ".jpg";
    }

    /**
     * 生成漫画封面
     */
    public String generateMangaCover(String archivePath, Long mangaId) throws IOException {
        try {
            // 获取压缩文件中的第一个图像
            String firstImageEntry = fileSystemService.listArchiveEntries(archivePath).stream()
                    .filter(this::isImageFile)
                    .sorted()
                    .findFirst()
                    .orElseThrow(() -> new IOException("压缩文件中没有图像"));

            // 提取并生成缩略图
            byte[] imageData = fileSystemService.extractFileFromArchive(archivePath, firstImageEntry);
            byte[] thumbnailData = generateThumbnail(imageData);

            // 保存封面图像
            String coverPath = fileSystemService.getDataFilePath("covers", mangaId + ".jpg");
            Files.write(Paths.get(coverPath), thumbnailData,
                    StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);

            return "covers/" + mangaId + ".jpg";
        } catch (Exception e) {
            logger.error("生成漫画封面失败: {}", archivePath, e);
            throw new IOException("生成封面失败: " + e.getMessage(), e);
        }
    }

    /**
     * 判断是否为图像文件
     */
    private boolean isImageFile(String fileName) {
        String lowerName = fileName.toLowerCase();
        return lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg") ||
               lowerName.endsWith(".png") || lowerName.endsWith(".gif") ||
               lowerName.endsWith(".bmp") || lowerName.endsWith(".webp");
    }

    /**
     * 旋转图像
     */
    public byte[] rotateImage(byte[] imageData, int degrees) throws IOException {
        try (ByteArrayInputStream inputStream = new ByteArrayInputStream(imageData)) {
            BufferedImage originalImage = ImageIO.read(inputStream);

            if (originalImage == null) {
                throw new IOException("无法读取图像数据");
            }
            Scalr.Rotation rotation=FLIP_HORZ;
            if (degrees ==90) {
                rotation=CW_90;
            }else if (degrees ==180) {
                rotation=CW_180 ;
            }else if (degrees ==270) {
                rotation=CW_270;
            }

            // 旋转图像
            BufferedImage rotatedImage = Scalr.rotate(
                    originalImage,
                    rotation,
                    Scalr.OP_ANTIALIAS
            );

            // 转换为字节数组
            try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                ImageIO.write(rotatedImage, "JPEG", outputStream);
                return outputStream.toByteArray();
            } finally {
                // 释放资源
                rotatedImage.flush();
                originalImage.flush();
            }
        }
    }

    /**
     * 调整图像亮度
     */
    public byte[] adjustBrightness(byte[] imageData, float factor) throws IOException {
        try (ByteArrayInputStream inputStream = new ByteArrayInputStream(imageData)) {
            BufferedImage originalImage = ImageIO.read(inputStream);

            if (originalImage == null) {
                throw new IOException("无法读取图像数据");
            }

            // 调整亮度
            BufferedImage adjustedImage = new BufferedImage(
                    originalImage.getWidth(),
                    originalImage.getHeight(),
                    originalImage.getType());

            for (int y = 0; y < originalImage.getHeight(); y++) {
                for (int x = 0; x < originalImage.getWidth(); x++) {
                    int rgb = originalImage.getRGB(x, y);

                    int alpha = (rgb >> 24) & 0xff;
                    int red = (int) (((rgb >> 16) & 0xff) * factor);
                    int green = (int) (((rgb >> 8) & 0xff) * factor);
                    int blue = (int) ((rgb & 0xff) * factor);

                    // 限制值范围
                    red = Math.min(255, Math.max(0, red));
                    green = Math.min(255, Math.max(0, green));
                    blue = Math.min(255, Math.max(0, blue));

                    int newRgb = (alpha << 24) | (red << 16) | (green << 8) | blue;
                    adjustedImage.setRGB(x, y, newRgb);
                }
            }

            // 转换为字节数组
            try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                ImageIO.write(adjustedImage, "JPEG", outputStream);
                return outputStream.toByteArray();
            } finally {
                // 释放资源
                adjustedImage.flush();
                originalImage.flush();
            }
        }
    }

    /**
     * 调整图像对比度
     */
    public byte[] adjustContrast(byte[] imageData, float factor) throws IOException {
        try (ByteArrayInputStream inputStream = new ByteArrayInputStream(imageData)) {
            BufferedImage originalImage = ImageIO.read(inputStream);

            if (originalImage == null) {
                throw new IOException("无法读取图像数据");
            }

            // 调整对比度
            BufferedImage adjustedImage = new BufferedImage(
                    originalImage.getWidth(),
                    originalImage.getHeight(),
                    originalImage.getType());

            float offset = (1.0f - factor) * 128f;

            for (int y = 0; y < originalImage.getHeight(); y++) {
                for (int x = 0; x < originalImage.getWidth(); x++) {
                    int rgb = originalImage.getRGB(x, y);

                    int alpha = (rgb >> 24) & 0xff;
                    int red = (int) (factor * ((rgb >> 16) & 0xff) + offset);
                    int green = (int) (factor * ((rgb >> 8) & 0xff) + offset);
                    int blue = (int) (factor * (rgb & 0xff) + offset);

                    // 限制值范围
                    red = Math.min(255, Math.max(0, red));
                    green = Math.min(255, Math.max(0, green));
                    blue = Math.min(255, Math.max(0, blue));

                    int newRgb = (alpha << 24) | (red << 16) | (green << 8) | blue;
                    adjustedImage.setRGB(x, y, newRgb);
                }
            }

            // 转换为字节数组
            try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
                ImageIO.write(adjustedImage, "JPEG", outputStream);
                return outputStream.toByteArray();
            } finally {
                // 释放资源
                adjustedImage.flush();
                originalImage.flush();
            }
        }
    }

    /**
     * 清理图像缓存
     */
    public void clearImageCache() {
        try {
            Path cachePath = Paths.get(cacheDirectory, "images");
            if (Files.exists(cachePath)) {
                Files.walk(cachePath)
                        .filter(Files::isRegularFile)
                        .forEach(path -> {
                            try {
                                Files.delete(path);
                            } catch (IOException e) {
                                logger.warn("删除缓存文件失败: {}", path, e);
                            }
                        });
                logger.info("图像缓存已清理");
            }
        } catch (IOException e) {
            logger.error("清理图像缓存失败", e);
        }
    }

    /**
     * 保存图像文件
     */
    public void saveImage(byte[] imageData, String filePath) throws IOException {
        Files.write(Paths.get(filePath), imageData,
                StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
    }

    /**
     * 获取图像信息
     */
    public ImageInfo getImageInfo(byte[] imageData) throws IOException {
        try (ByteArrayInputStream inputStream = new ByteArrayInputStream(imageData)) {
            BufferedImage image = ImageIO.read(inputStream);

            if (image == null) {
                throw new IOException("无法读取图像数据");
            }

            ImageInfo info = new ImageInfo();
            info.setWidth(image.getWidth());
            info.setHeight(image.getHeight());
            info.setSize(imageData.length);
            info.setType(image.getType());

            return info;
        }
    }

    /**
     * 图像信息类
     */
    public static class ImageInfo {
        private int width;
        private int height;
        private long size;
        private int type;

        // Getters and Setters
        public int getWidth() { return width; }
        public void setWidth(int width) { this.width = width; }

        public int getHeight() { return height; }
        public void setHeight(int height) { this.height = height; }

        public long getSize() { return size; }
        public void setSize(long size) { this.size = size; }

        public int getType() { return type; }
        public void setType(int type) { this.type = type; }
    }
}
