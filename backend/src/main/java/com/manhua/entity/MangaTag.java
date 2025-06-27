package com.manhua.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * 漫画标签实体类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Entity
@Table(name = "manga_tags")
public class MangaTag {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @NotBlank(message = "标签名称不能为空")
    @Column(nullable = false, length = 50)
    private String name;

    @Column(length = 7)
    private String color = "#409EFF"; // 默认蓝色

    @Column(length = 200)
    private String description;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // 关联关系
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manga_id", nullable = false)
    private Manga manga;

    // 构造函数
    public MangaTag() {}

    public MangaTag(String name, Manga manga) {
        this.name = name;
        this.manga = manga;
    }

    public MangaTag(String name, String color, Manga manga) {
        this.name = name;
        this.color = color;
        this.manga = manga;
    }

    // Getter和Setter方法
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

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Manga getManga() {
        return manga;
    }

    public void setManga(Manga manga) {
        this.manga = manga;
    }

    @Override
    public String toString() {
        return "MangaTag{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", color='" + color + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof MangaTag)) return false;
        MangaTag mangaTag = (MangaTag) o;
        return id != null && id.equals(mangaTag.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}
