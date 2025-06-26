package com.manhua.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

/**
 * 漫画实体类
 */
@Entity
@Table(name = "comics")
public class Comic {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 漫画标题
     */
    @Column(nullable = false, length = 500)
    private String title;

    /**
     * 漫画作者
     */
    @Column(length = 255)
    private String author;

    /**
     * 漫画描述
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * 文件路径
     */
    @Column(nullable = false, columnDefinition = "TEXT")
    private String filePath;

    /**
     * 文件类型：folder, zip, rar, 7z, cbz, cbr, cb7, pdf
     */
    @Column(nullable = false, length = 20)
    private String fileType;

    /**
     * 文件大小（字节）
     */
    private Long fileSize;

    /**
     * 封面图片路径
     */
    @Column(columnDefinition = "TEXT")
    private String coverPath;

    /**
     * 缩略图路径
     */
    @Column(columnDefinition = "TEXT")
    private String thumbnailPath;

    /**
     * 总页数
     */
    private Integer pageCount;

    /**
     * 当前阅读页数
     */
    private Integer currentPage = 0;

    /**
     * 阅读状态：unread, reading, completed
     */
    @Column(nullable = false, length = 20)
    private String readingStatus = "unread";

    /**
     * 评分（1-5星）
     */
    private Integer rating;

    /**
     * 是否为隐私漫画
     */
    @Column(nullable = false)
    private Boolean isPrivate = false;

    /**
     * 是否为收藏
     */
    @Column(nullable = false)
    private Boolean isFavorite = false;

    /**
     * 最后阅读时间
     */
    private LocalDateTime lastReadTime;

    /**
     * 文件最后修改时间
     */
    private LocalDateTime fileModifyTime;

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
     * 所属漫画库
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "library_id", nullable = false)
    private Library library;

    /**
     * 漫画标签
     */
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "comic_tags",
        joinColumns = @JoinColumn(name = "comic_id"),
        inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    private Set<Tag> tags;

    /**
     * 阅读历史记录
     */
    @OneToMany(mappedBy = "comic", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<ReadingHistory> readingHistories;

    /**
     * 获取阅读进度百分比
     */
    @Transient
    public double getProgressPercentage() {
        if (pageCount == null || pageCount == 0) {
            return 0.0;
        }
        return (double) currentPage / pageCount * 100;
    }

    /**
     * 是否已开始阅读
     */
    @Transient
    public boolean hasProgress() {
        return currentPage != null && currentPage > 0;
    }

    /**
     * 是否已读完
     */
    @Transient
    public boolean isCompleted() {
        return "completed".equals(readingStatus) || 
               (pageCount != null && currentPage != null && currentPage >= pageCount);
    }

    // Getter and Setter methods
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public String getCoverPath() {
        return coverPath;
    }

    public void setCoverPath(String coverPath) {
        this.coverPath = coverPath;
    }

    public String getThumbnailPath() {
        return thumbnailPath;
    }

    public void setThumbnailPath(String thumbnailPath) {
        this.thumbnailPath = thumbnailPath;
    }

    public Integer getPageCount() {
        return pageCount;
    }

    public void setPageCount(Integer pageCount) {
        this.pageCount = pageCount;
    }

    public Integer getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(Integer currentPage) {
        this.currentPage = currentPage;
    }

    public String getReadingStatus() {
        return readingStatus;
    }

    public void setReadingStatus(String readingStatus) {
        this.readingStatus = readingStatus;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public Boolean getIsPrivate() {
        return isPrivate;
    }

    public void setIsPrivate(Boolean isPrivate) {
        this.isPrivate = isPrivate;
    }

    public Boolean getIsFavorite() {
        return isFavorite;
    }

    public void setIsFavorite(Boolean isFavorite) {
        this.isFavorite = isFavorite;
    }

    public LocalDateTime getLastReadTime() {
        return lastReadTime;
    }

    public void setLastReadTime(LocalDateTime lastReadTime) {
        this.lastReadTime = lastReadTime;
    }

    public LocalDateTime getFileModifyTime() {
        return fileModifyTime;
    }

    public void setFileModifyTime(LocalDateTime fileModifyTime) {
        this.fileModifyTime = fileModifyTime;
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

    public Library getLibrary() {
        return library;
    }

    public void setLibrary(Library library) {
        this.library = library;
    }

    public Set<Tag> getTags() {
        return tags;
    }

    public void setTags(Set<Tag> tags) {
        this.tags = tags;
    }

    public List<ReadingHistory> getReadingHistories() {
        return readingHistories;
    }

    public void setReadingHistories(List<ReadingHistory> readingHistories) {
        this.readingHistories = readingHistories;
    }
}