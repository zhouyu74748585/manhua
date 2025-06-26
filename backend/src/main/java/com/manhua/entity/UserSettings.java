package com.manhua.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 用户设置实体类
 */
@Data
@Entity
@Table(name = "user_settings")
@EqualsAndHashCode(callSuper = false)
public class UserSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 设置键
     */
    @Column(nullable = false, unique = true, length = 100)
    private String settingKey;

    /**
     * 设置值（JSON格式）
     */
    @Column(columnDefinition = "TEXT")
    private String settingValue;

    /**
     * 设置分类
     */
    @Column(length = 50)
    private String category;

    /**
     * 设置描述
     */
    @Column(length = 500)
    private String description;

    /**
     * 是否为系统设置
     */
    @Column(nullable = false)
    private Boolean isSystem = false;

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
}