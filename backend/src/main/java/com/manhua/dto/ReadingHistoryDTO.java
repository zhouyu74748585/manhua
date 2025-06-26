package com.manhua.dto;

import java.time.LocalDateTime;

/**
 * 阅读历史DTO
 */
public class ReadingHistoryDTO {
    private Long id;
    private Long comicId;
    private String comicTitle;
    private Integer pageNumber;
    private String readingMode;
    private Integer readingDuration;
    private String deviceInfo;
    private LocalDateTime readTime;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getComicId() {
        return comicId;
    }

    public void setComicId(Long comicId) {
        this.comicId = comicId;
    }

    public String getComicTitle() {
        return comicTitle;
    }

    public void setComicTitle(String comicTitle) {
        this.comicTitle = comicTitle;
    }

    public Integer getPageNumber() {
        return pageNumber;
    }

    public void setPageNumber(Integer pageNumber) {
        this.pageNumber = pageNumber;
    }

    public String getReadingMode() {
        return readingMode;
    }

    public void setReadingMode(String readingMode) {
        this.readingMode = readingMode;
    }

    public Integer getReadingDuration() {
        return readingDuration;
    }

    public void setReadingDuration(Integer readingDuration) {
        this.readingDuration = readingDuration;
    }

    public String getDeviceInfo() {
        return deviceInfo;
    }

    public void setDeviceInfo(String deviceInfo) {
        this.deviceInfo = deviceInfo;
    }

    public LocalDateTime getReadTime() {
        return readTime;
    }

    public void setReadTime(LocalDateTime readTime) {
        this.readTime = readTime;
    }
}