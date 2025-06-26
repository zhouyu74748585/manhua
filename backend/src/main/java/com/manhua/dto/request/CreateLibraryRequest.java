package com.manhua.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 创建漫画库请求
 */
@Data
public class CreateLibraryRequest {

    @NotBlank(message = "库名称不能为空")
    private String name;

    private String description;

    @NotBlank(message = "库类型不能为空")
    private String type;

    @NotBlank(message = "库路径不能为空")
    private String path;

    @NotNull(message = "隐私设置不能为空")
    private Boolean isPrivate = false;

    private String networkConfig;
}