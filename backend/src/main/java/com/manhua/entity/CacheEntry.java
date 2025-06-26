package com.manhua.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 缓存条目实体类
 */
@Data
@Entity
@Table(name = "cache_entries")
@EqualsAndHashCode(callSuper = false)
public class CacheEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 缓存键
     */
    @Column(nullable = false, unique = true, length = 500)
    private String cacheKey;

    /**
     * 缓存类型：image, thumbnail, page, metadata
     */
    @Column(nullable = false, length = 20)
    private String cacheType;

    /**
     * 本地文件路径
     */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String localPath;

    /**
     * 原始文件路径
     */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String originalPath;

    /**
     * 文件大小（字节）
     */
    private Long fileSize;

    /**
     * 文件MIME类型
     */
    @Column(length = 100)
    private String mimeType;

    /**
     * 访问次数
     */
    @Column(nullable = false)
    private Integer accessCount = 0;

    /**
     * 最后访问时间
     */
    private LocalDateTime lastAccessTime;

    /**
     * 过期时间
     */
    private LocalDateTime expireTime;

    /**
     * 创建时间
     */
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updateTime;

    /**
     * 关联的漫画ID
     */
    @Column(name = "comic_id")
    private Long comicId;

    /**
     * 是否已过期
     */
    @Transient
    public boolean isExpired() {
        return expireTime != null && LocalDateTime.now().isAfter(expireTime);
    }
}