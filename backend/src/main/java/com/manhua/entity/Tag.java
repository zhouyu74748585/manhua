package com.manhua.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 标签实体类
 */
@Data
@Entity
@Table(name = "tags")
@EqualsAndHashCode(callSuper = false)
public class Tag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 标签名称
     */
    @Column(nullable = false, unique = true, length = 100)
    private String name;

    /**
     * 标签颜色（十六进制）
     */
    @Column(length = 7)
    private String color;

    /**
     * 标签分类
     */
    @Column(length = 50)
    private String category;

    /**
     * 标签描述
     */
    @Column(length = 500)
    private String description;

    /**
     * 使用次数
     */
    @Column(nullable = false)
    private Integer usageCount = 0;

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
     * 使用该标签的漫画
     */
    @ManyToMany(mappedBy = "tags", fetch = FetchType.LAZY)
    private List<Comic> comics;

    /**
     * 获取漫画数量
     */
    @Transient
    public int getComicCount() {
        return comics != null ? comics.size() : 0;
    }
}