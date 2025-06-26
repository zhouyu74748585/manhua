package com.manhua.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 标签数据传输对象
 */
@Data
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
}