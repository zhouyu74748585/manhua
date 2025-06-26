package com.manhua.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * 阅读历史实体类
 */
@Data
@Entity
@Table(name = "reading_histories")
@EqualsAndHashCode(callSuper = false)
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
}