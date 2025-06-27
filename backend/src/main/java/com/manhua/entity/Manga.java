package com.manhua.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 漫画实体类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Entity
@Table(name = "mangas")
public class Manga {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @NotBlank(message = "漫画标题不能为空")
    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 200)
    private String author;

    @Column(length = 1000)
    private String description;

    @Column(length = 1000)
    private String coverImage;

    @Column(length = 100)
    private String genre;

    @Column(length = 50)
    private String language = "zh-CN";

    @NotNull(message = "漫画状态不能为空")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MangaStatus status = MangaStatus.UNREAD;

    @NotBlank(message = "文件路径不能为空")
    @Column(nullable = false, length = 1000)
    private String filePath;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "file_type", length = 20)
    private String fileType;

    @Column(name = "total_pages")
    private Integer totalPages = 0;

    @Column(name = "current_page")
    private Integer currentPage = 1;

    @Column(name = "cover_path", length = 1000)
    private String coverPath;

    @Column(name = "thumbnail_path", length = 1000)
    private String thumbnailPath;

    @Column
    private Double rating;

    @Column(name = "is_favorite")
    private Boolean isFavorite = false;

    @Column(name = "is_hidden")
    private Boolean isHidden = false;

    @Column(name = "reading_direction", length = 10)
    private String readingDirection = "ltr"; // ltr, rtl

    @Column(name = "last_read_at")
    private LocalDateTime lastReadAt;

    @Column(name = "added_at")
    private LocalDateTime addedAt;

    @Column(name = "complete_at")
    private LocalDateTime completedAt;

    @Column(name = "file_modified_at")
    private LocalDateTime fileModifiedAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // 关联关系
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "library_id", nullable = false)
    private MangaLibrary library;

    @OneToMany(mappedBy = "manga", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<ReadingProgress> readingProgresses = new ArrayList<>();

    @OneToMany(mappedBy = "manga", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<MangaTag> tags = new ArrayList<>();

    // 构造函数
    public Manga() {}

    public Manga(String title, String filePath, MangaLibrary library) {
        this.title = title;
        this.filePath = filePath;
        this.library = library;
        this.addedAt = LocalDateTime.now();
    }

    // Getter和Setter方法
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

    public String getCoverImage() {
        return coverImage;
    }

    public void setCoverImage(String coverImage) {
        this.coverImage = coverImage;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public MangaStatus getStatus() {
        return status;
    }

    public void setStatus(MangaStatus status) {
        this.status = status;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }

    public Integer getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(Integer currentPage) {
        this.currentPage = currentPage;
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

    public Double getRating() {
        return rating;
    }

    public void setRating(Double rating) {
        this.rating = rating;
    }

    public Boolean getIsFavorite() {
        return isFavorite;
    }

    public void setIsFavorite(Boolean isFavorite) {
        this.isFavorite = isFavorite;
    }

    public Boolean getIsHidden() {
        return isHidden;
    }

    public void setIsHidden(Boolean isHidden) {
        this.isHidden = isHidden;
    }

    public String getReadingDirection() {
        return readingDirection;
    }

    public void setReadingDirection(String readingDirection) {
        this.readingDirection = readingDirection;
    }

    public LocalDateTime getLastReadAt() {
        return lastReadAt;
    }

    public void setLastReadAt(LocalDateTime lastReadAt) {
        this.lastReadAt = lastReadAt;
    }

    public LocalDateTime getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(LocalDateTime addedAt) {
        this.addedAt = addedAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }

    public LocalDateTime getFileModifiedAt() {
        return fileModifiedAt;
    }

    public void setFileModifiedAt(LocalDateTime fileModifiedAt) {
        this.fileModifiedAt = fileModifiedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public MangaLibrary getLibrary() {
        return library;
    }

    public void setLibrary(MangaLibrary library) {
        this.library = library;
    }

    public List<ReadingProgress> getReadingProgresses() {
        return readingProgresses;
    }

    public void setReadingProgresses(List<ReadingProgress> readingProgresses) {
        this.readingProgresses = readingProgresses;
    }

    public List<MangaTag> getTags() {
        return tags;
    }

    public void setTags(List<MangaTag> tags) {
        this.tags = tags;
    }

    // 业务方法
    public void updateReadingProgress(int pageNumber) {
        this.currentPage = pageNumber;
        this.lastReadAt = LocalDateTime.now();

        // 更新状态
        if (pageNumber == 1) {
            this.status = MangaStatus.READING;
        } else if (pageNumber >= totalPages) {
            this.status = MangaStatus.COMPLETED;
        } else {
            this.status = MangaStatus.READING;
        }
    }

    public double getReadingProgress() {
        if (totalPages == null || totalPages == 0) {
            return 0.0;
        }
        return (double) currentPage / totalPages * 100;
    }

    public boolean isCompleted() {
        return status == MangaStatus.COMPLETED ||
               (currentPage != null && totalPages != null && currentPage >= totalPages);
    }

    public boolean isReading() {
        return status == MangaStatus.READING ||
               (currentPage != null && currentPage > 1);
    }

    public String getFileName() {
        if (filePath == null) {
            return null;
        }
        int lastSeparator = Math.max(filePath.lastIndexOf('/'), filePath.lastIndexOf('\\'));
        return lastSeparator >= 0 ? filePath.substring(lastSeparator + 1) : filePath;
    }

    public String getFileExtension() {
        String fileName = getFileName();
        if (fileName == null) {
            return null;
        }
        int lastDot = fileName.lastIndexOf('.');
        return lastDot >= 0 ? fileName.substring(lastDot + 1).toLowerCase() : null;
    }

    @Override
    public String toString() {
        return "Manga{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", author='" + author + '\'' +
                ", status=" + status +
                ", totalPages=" + totalPages +
                ", currentPage=" + currentPage +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Manga)) return false;
        Manga manga = (Manga) o;
        return id != null && id.equals(manga.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }

    /**
     * 漫画状态枚举
     */
    public enum MangaStatus {
        UNREAD("未读"),
        READING("阅读中"),
        COMPLETED("已完成"),
        ON_HOLD("暂停"),
        DROPPED("弃坑");

        private final String displayName;

        MangaStatus(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }
}
