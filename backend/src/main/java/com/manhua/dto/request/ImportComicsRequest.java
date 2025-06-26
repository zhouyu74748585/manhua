package com.manhua.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

/**
 * 导入漫画请求
 */
@Data
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
}