package com.manhua.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 创建漫画库请求
 */
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

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public Boolean getIsPrivate() {
        return isPrivate;
    }

    public void setIsPrivate(Boolean isPrivate) {
        this.isPrivate = isPrivate;
    }

    public String getNetworkConfig() {
        return networkConfig;
    }

    public void setNetworkConfig(String networkConfig) {
        this.networkConfig = networkConfig;
    }
}