package com.manhua.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 漫画库实体类
 */
@Entity
@Table(name = "libraries")
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

    // Getter and Setter methods
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public Boolean getIsPrivate() {
        return isPrivate;
    }

    public void setIsPrivate(Boolean isPrivate) {
        this.isPrivate = isPrivate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getLastScanTime() {
        return lastScanTime;
    }

    public void setLastScanTime(LocalDateTime lastScanTime) {
        this.lastScanTime = lastScanTime;
    }

    public String getScanStatus() {
        return scanStatus;
    }

    public void setScanStatus(String scanStatus) {
        this.scanStatus = scanStatus;
    }

    public String getScanError() {
        return scanError;
    }

    public void setScanError(String scanError) {
        this.scanError = scanError;
    }

    public String getNetworkConfig() {
        return networkConfig;
    }

    public void setNetworkConfig(String networkConfig) {
        this.networkConfig = networkConfig;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }

    public List<Comic> getComics() {
        return comics;
    }

    public void setComics(List<Comic> comics) {
        this.comics = comics;
    }
}