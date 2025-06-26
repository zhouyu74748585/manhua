package com.manhua.repository;

import com.manhua.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 标签数据访问层
 */
@Repository
public interface TagRepository extends JpaRepository<Tag, Long> {

    /**
     * 根据名称查找标签
     */
    Optional<Tag> findByName(String name);

    /**
     * 根据分类查找标签
     */
    List<Tag> findByCategory(String category);

    /**
     * 根据名称模糊查询
     */
    @Query("SELECT t FROM Tag t WHERE t.name LIKE %:name%")
    List<Tag> findByNameContaining(@Param("name") String name);

    /**
     * 查找热门标签（按使用次数排序）
     */
    @Query("SELECT t FROM Tag t ORDER BY t.usageCount DESC")
    List<Tag> findPopularTags();

    /**
     * 查找使用次数大于指定值的标签
     */
    @Query("SELECT t FROM Tag t WHERE t.usageCount > :count ORDER BY t.usageCount DESC")
    List<Tag> findByUsageCountGreaterThan(@Param("count") Integer count);

    /**
     * 查找所有分类
     */
    @Query("SELECT DISTINCT t.category FROM Tag t WHERE t.category IS NOT NULL ORDER BY t.category")
    List<String> findAllCategories();

    /**
     * 统计标签总数
     */
    @Query("SELECT COUNT(t) FROM Tag t")
    Long countAllTags();

    /**
     * 统计各分类的标签数量
     */
    @Query("SELECT t.category, COUNT(t) FROM Tag t GROUP BY t.category")
    List<Object[]> countByCategory();

    /**
     * 查找未使用的标签
     */
    @Query("SELECT t FROM Tag t WHERE t.usageCount = 0")
    List<Tag> findUnusedTags();

    /**
     * 根据漫画ID查找标签
     */
    @Query("SELECT t FROM Tag t JOIN t.comics c WHERE c.id = :comicId")
    List<Tag> findByComicId(@Param("comicId") Long comicId);

    /**
     * 根据库ID查找标签
     */
    @Query("SELECT DISTINCT t FROM Tag t JOIN t.comics c WHERE c.library.id = :libraryId")
    List<Tag> findByLibraryId(@Param("libraryId") Long libraryId);
}