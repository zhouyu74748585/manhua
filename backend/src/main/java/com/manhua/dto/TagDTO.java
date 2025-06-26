package com.manhua.dto;

import java.time.LocalDateTime;

/**
 * 标签数据传输对象
 */
public class TagDTO {

    private Long id;
    private String name;
    private String color;
    private String category;
    private String description;
    private Integer usageCount;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer comicCount;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getUsageCount() {
        return usageCount;
    }

    public void setUsageCount(Integer usageCount) {
        this.usageCount = usageCount;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public Integer getComicCount() {
        return comicCount;
    }

    public void setComicCount(Integer comicCount) {
        this.comicCount = comicCount;
    }
}