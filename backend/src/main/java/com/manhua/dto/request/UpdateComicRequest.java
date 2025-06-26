package com.manhua.dto.request;

import lombok.Data;

import java.util.List;

/**
 * 更新漫画请求
 */
@Data
public class UpdateComicRequest {

    private String title;
    private String author;
    private String description;
    private Integer currentPage;
    private String readingStatus;
    private Integer rating;
    private Boolean isPrivate;
    private Boolean isFavorite;
    private List<String> tags;
}