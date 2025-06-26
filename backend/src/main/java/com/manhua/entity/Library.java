package com.manhua.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 漫画库实体类
 */
@Data
@Entity
@Table(name = "libraries")
@EqualsAndHashCode(callSuper = false)
public class Library {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 库名称
     */
    @Column(nullable = false, length = 255)
    private String name;

    /**
     * 库描述
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * 库类型：local_folder, archive, smb, ftp, webdav, nfs
     */
    @Column(nullable = false, length = 50)
    private String type;

    /**
     * 库路径
     */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String path;

    /**
     * 是否为隐私库
     */
    @Column(nullable = false)
    private Boolean isPrivate = false;

    /**
     * 库状态：active, inactive, error
     */
    @Column(nullable = false, length = 20)
    private String status = "active";

    /**
     * 最后扫描时间
     */
    private LocalDateTime lastScanTime;

    /**
     * 扫描状态：idle, scanning, error
     */
    @Column(length = 20)
    private String scanStatus = "idle";

    /**
     * 扫描错误信息
     */
    @Column(columnDefinition = "TEXT")
    private String scanError;

    /**
     * 网络配置（JSON格式存储）
     */
    @Column(columnDefinition = "TEXT")
    private String networkConfig;

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
     * 库中的漫画
     */
    @OneToMany(mappedBy = "library", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Comic> comics;

    /**
     * 获取漫画数量
     */
    @Transient
    public int getComicCount() {
        return comics != null ? comics.size() : 0;
    }
}