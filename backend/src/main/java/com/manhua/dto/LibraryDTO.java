package com.manhua.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 漫画库数据传输对象
 */
@Data
public class LibraryDTO {

    private Long id;
    private String name;
    private String description;
    private String type;
    private String path;
    private Boolean isPrivate;
    private String status;
    private LocalDateTime lastScanTime;
    private String scanStatus;
    private String scanError;
    private String networkConfig;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer comicCount;
    private List<ComicDTO> comics;
}