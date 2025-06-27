package com.manhua.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * 阅读进度实体类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Entity
@Table(name = "reading_progress")
public class ReadingProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "当前页数不能为空")
    @Min(value = 1, message = "当前页数必须大于0")
    @Column(name = "current_page", nullable = false)
    private Integer currentPage;

    @NotNull(message = "总页数不能为空")
    @Min(value = 1, message = "总页数必须大于0")
    @Column(name = "total_pages", nullable = false)
    private Integer totalPages;

    @Column(name = "reading_time")
    private Long readingTime = 0L; // 阅读时间（秒）

    @Column(name = "session_start")
    private LocalDateTime sessionStart;

    @Column(name = "session_end")
    private LocalDateTime sessionEnd;

    @Column(name = "last_read_at")
    private LocalDateTime lastReadAt;

    @Column(name = "reading_speed")
    private Double readingSpeed; // 页/分钟

    @Column(name = "bookmark_page")
    private Integer bookmarkPage;

    @Column(name = "bookmark_note", length = 500)
    private String bookmarkNote;

    @Column(name = "bookmark_pages", length = 1000)
    private String bookmarkPages;

    @Column(name = "notes", length = 2000)
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // 关联关系
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manga_id", nullable = false)
    private Manga manga;

    // 构造函数
    public ReadingProgress() {}

    public ReadingProgress(Manga manga, Integer currentPage, Integer totalPages) {
        this.manga = manga;
        this.currentPage = currentPage;
        this.totalPages = totalPages;
        this.sessionStart = LocalDateTime.now();
    }

    // Getter和Setter方法
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(Integer currentPage) {
        this.currentPage = currentPage;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }

    public Long getReadingTime() {
        return readingTime;
    }

    public void setReadingTime(Long readingTime) {
        this.readingTime = readingTime;
    }

    public LocalDateTime getSessionStart() {
        return sessionStart;
    }

    public void setSessionStart(LocalDateTime sessionStart) {
        this.sessionStart = sessionStart;
    }

    public LocalDateTime getSessionEnd() {
        return sessionEnd;
    }

    public void setSessionEnd(LocalDateTime sessionEnd) {
        this.sessionEnd = sessionEnd;
    }

    public LocalDateTime getLastReadAt() {
        return lastReadAt;
    }

    public void setLastReadAt(LocalDateTime lastReadAt) {
        this.lastReadAt = lastReadAt;
    }

    public Double getReadingSpeed() {
        return readingSpeed;
    }

    public void setReadingSpeed(Double readingSpeed) {
        this.readingSpeed = readingSpeed;
    }

    public Integer getBookmarkPage() {
        return bookmarkPage;
    }

    public void setBookmarkPage(Integer bookmarkPage) {
        this.bookmarkPage = bookmarkPage;
    }

    public String getBookmarkNote() {
        return bookmarkNote;
    }

    public void setBookmarkNote(String bookmarkNote) {
        this.bookmarkNote = bookmarkNote;
    }

    public String getBookmarkPages() {
        return bookmarkPages;
    }

    public void setBookmarkPages(String bookmarkPages) {
        this.bookmarkPages = bookmarkPages;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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

    public Manga getManga() {
        return manga;
    }

    public void setManga(Manga manga) {
        this.manga = manga;
    }

    // 业务方法
    public double getProgressPercentage() {
        if (totalPages == null || totalPages == 0) {
            return 0.0;
        }
        return (double) currentPage / totalPages * 100;
    }

    public boolean isCompleted() {
        return currentPage != null && totalPages != null && currentPage >= totalPages;
    }

    public void startSession() {
        this.sessionStart = LocalDateTime.now();
        this.sessionEnd = null;
    }

    public void endSession() {
        this.sessionEnd = LocalDateTime.now();
        if (sessionStart != null) {
            long sessionDuration = java.time.Duration.between(sessionStart, sessionEnd).getSeconds();
            this.readingTime = (this.readingTime != null ? this.readingTime : 0L) + sessionDuration;

            // 计算阅读速度（页/分钟）
            if (sessionDuration > 0) {
                double pagesRead = 1.0; // 假设每次会话至少读了1页
                double minutesRead = sessionDuration / 60.0;
                this.readingSpeed = pagesRead / minutesRead;
            }
        }
    }

    public void updateProgress(Integer newPage) {
        if (newPage != null && newPage > 0 && newPage <= totalPages) {
            this.currentPage = newPage;
        }
    }

    public void addBookmark(Integer page, String note) {
        this.bookmarkPage = page;
        this.bookmarkNote = note;
    }

    public void removeBookmark() {
        this.bookmarkPage = null;
        this.bookmarkNote = null;
    }

    public boolean hasBookmark() {
        return bookmarkPage != null;
    }

    public String getFormattedReadingTime() {
        if (readingTime == null || readingTime == 0) {
            return "0分钟";
        }

        long hours = readingTime / 3600;
        long minutes = (readingTime % 3600) / 60;
        long seconds = readingTime % 60;

        if (hours > 0) {
            return String.format("%d小时%d分钟", hours, minutes);
        } else if (minutes > 0) {
            return String.format("%d分钟", minutes);
        } else {
            return String.format("%d秒", seconds);
        }
    }

    public int getRemainingPages() {
        if (totalPages == null || currentPage == null) {
            return 0;
        }
        return Math.max(0, totalPages - currentPage);
    }

    public long getEstimatedRemainingTime() {
        if (readingSpeed == null || readingSpeed <= 0) {
            return 0;
        }

        int remainingPages = getRemainingPages();
        if (remainingPages <= 0) {
            return 0;
        }

        // 返回预估剩余时间（秒）
        return Math.round(remainingPages / readingSpeed * 60);
    }

    @Override
    public String toString() {
        return "ReadingProgress{" +
                "id=" + id +
                ", currentPage=" + currentPage +
                ", totalPages=" + totalPages +
                ", progressPercentage=" + String.format("%.1f", getProgressPercentage()) + "%" +
                ", readingTime=" + getFormattedReadingTime() +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ReadingProgress)) return false;
        ReadingProgress that = (ReadingProgress) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
