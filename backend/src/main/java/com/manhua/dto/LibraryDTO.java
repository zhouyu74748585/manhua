package com.manhua.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 漫画库数据传输对象
 */
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

    public Integer getComicCount() {
        return comicCount;
    }

    public void setComicCount(Integer comicCount) {
        this.comicCount = comicCount;
    }

    public List<ComicDTO> getComics() {
        return comics;
    }

    public void setComics(List<ComicDTO> comics) {
        this.comics = comics;
    }
}