package com.manhua.dto.request;

import jakarta.validation.constraints.NotNull;

import java.util.List;

/**
 * 导入漫画请求
 */
public class ImportComicsRequest {

    @NotNull(message = "库ID不能为空")
    private Long libraryId;

    /**
     * 导入类型：files, folder, url
     */
    @NotNull(message = "导入类型不能为空")
    private String importType;

    /**
     * 文件路径列表（当importType为files时使用）
     */
    private List<String> filePaths;

    /**
     * 文件夹路径（当importType为folder时使用）
     */
    private String folderPath;

    /**
     * 是否包含子文件夹
     */
    private Boolean includeSubfolders = false;

    /**
     * URL列表（当importType为url时使用）
     */
    private List<String> urls;

    /**
     * 是否提取元数据
     */
    private Boolean extractMetadata = true;

    /**
     * 是否生成缩略图
     */
    private Boolean generateThumbnails = true;

    /**
     * 是否覆盖已存在的漫画
     */
    private Boolean overwriteExisting = false;

    public Long getLibraryId() {
        return libraryId;
    }

    public void setLibraryId(Long libraryId) {
        this.libraryId = libraryId;
    }

    public String getImportType() {
        return importType;
    }

    public void setImportType(String importType) {
        this.importType = importType;
    }

    public List<String> getFilePaths() {
        return filePaths;
    }

    public void setFilePaths(List<String> filePaths) {
        this.filePaths = filePaths;
    }

    public String getFolderPath() {
        return folderPath;
    }

    public void setFolderPath(String folderPath) {
        this.folderPath = folderPath;
    }

    public Boolean getIncludeSubfolders() {
        return includeSubfolders;
    }

    public void setIncludeSubfolders(Boolean includeSubfolders) {
        this.includeSubfolders = includeSubfolders;
    }

    public List<String> getUrls() {
        return urls;
    }

    public void setUrls(List<String> urls) {
        this.urls = urls;
    }

    public Boolean getExtractMetadata() {
        return extractMetadata;
    }

    public void setExtractMetadata(Boolean extractMetadata) {
        this.extractMetadata = extractMetadata;
    }

    public Boolean getGenerateThumbnails() {
        return generateThumbnails;
    }

    public void setGenerateThumbnails(Boolean generateThumbnails) {
        this.generateThumbnails = generateThumbnails;
    }

    public Boolean getOverwriteExisting() {
        return overwriteExisting;
    }

    public void setOverwriteExisting(Boolean overwriteExisting) {
        this.overwriteExisting = overwriteExisting;
    }
}