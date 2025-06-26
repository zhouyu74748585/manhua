package com.manhua.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * 阅读历史实体类
 */
@Entity
@Table(name = "reading_histories")
public class ReadingHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 阅读页数
     */
    @Column(nullable = false)
    private Integer pageNumber;

    /**
     * 阅读时长（秒）
     */
    private Integer readingDuration;

    /**
     * 阅读设备信息
     */
    @Column(length = 255)
    private String deviceInfo;

    /**
     * 阅读模式：single, double, continuous, webtoon
     */
    @Column(length = 20)
    private String readingMode;

    /**
     * 阅读时间
     */
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime readTime;

    /**
     * 所属漫画
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comic_id", nullable = false)
    private Comic comic;

    // Getter and Setter methods
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getPageNumber() {
        return pageNumber;
    }

    public void setPageNumber(Integer pageNumber) {
        this.pageNumber = pageNumber;
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

    public String getReadingMode() {
        return readingMode;
    }

    public void setReadingMode(String readingMode) {
        this.readingMode = readingMode;
    }

    public LocalDateTime getReadTime() {
        return readTime;
    }

    public void setReadTime(LocalDateTime readTime) {
        this.readTime = readTime;
    }

    public Comic getComic() {
        return comic;
    }

    public void setComic(Comic comic) {
        this.comic = comic;
    }
}