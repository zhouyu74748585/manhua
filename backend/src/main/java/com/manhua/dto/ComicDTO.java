package com.manhua.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 漫画数据传输对象
 */
@Data
public class ComicDTO {

    private Long id;
    private String title;
    private String author;
    private String description;
    private String filePath;
    private String fileType;
    private Long fileSize;
    private String coverPath;
    private String thumbnailPath;
    private Integer pageCount;
    private Integer currentPage;
    private String readingStatus;
    private Integer rating;
    private Boolean isPrivate;
    private Boolean isFavorite;
    private LocalDateTime lastReadTime;
    private LocalDateTime fileModifyTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Long libraryId;
    private String libraryName;
    private List<TagDTO> tags;
    private Double progressPercentage;
    private Boolean hasProgress;
    private Boolean isCompleted;
}