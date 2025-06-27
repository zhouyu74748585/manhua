package com.manhua.repository;

import com.manhua.entity.Manga;
import com.manhua.entity.MangaTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 漫画标签数据访问接口
 * 
 * @author ManhuaReader
 * @version 1.0.0
 */
@Repository
public interface MangaTagRepository extends JpaRepository<MangaTag, Long> {

    /**
     * 根据标签名称查找标签
     */
    Optional<MangaTag> findByName(String name);

    /**
     * 根据漫画查找所有标签
     */
    List<MangaTag> findByManga(Manga manga);

    /**
     * 根据漫画ID查找所有标签
     */
    List<MangaTag> findByMangaId(Long mangaId);

    /**
     * 根据标签名称查找所有相关漫画的标签
     */
    List<MangaTag> findByNameIgnoreCase(String name);

    /**
     * 根据标签名称模糊查询
     */
    List<MangaTag> findByNameContainingIgnoreCase(String name);

    /**
     * 根据颜色查找标签
     */
    List<MangaTag> findByColor(String color);

    /**
     * 查找指定漫画库中的所有标签
     */
    @Query("SELECT mt FROM MangaTag mt WHERE mt.manga.library.id = :libraryId")
    List<MangaTag> findByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 查找所有不重复的标签名称
     */
    @Query("SELECT DISTINCT mt.name FROM MangaTag mt ORDER BY mt.name")
    List<String> findDistinctTagNames();

    /**
     * 查找指定漫画库中所有不重复的标签名称
     */
    @Query("SELECT DISTINCT mt.name FROM MangaTag mt WHERE mt.manga.library.id = :libraryId ORDER BY mt.name")
    List<String> findDistinctTagNamesByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 统计每个标签的使用次数
     */
    @Query("SELECT mt.name, COUNT(mt) FROM MangaTag mt GROUP BY mt.name ORDER BY COUNT(mt) DESC")
    List<Object[]> getTagUsageStatistics();

    /**
     * 统计指定漫画库中每个标签的使用次数
     */
    @Query("SELECT mt.name, COUNT(mt) FROM MangaTag mt WHERE mt.manga.library.id = :libraryId GROUP BY mt.name ORDER BY COUNT(mt) DESC")
    List<Object[]> getTagUsageStatisticsByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 查找最受欢迎的标签（使用次数最多）
     */
    @Query("SELECT mt.name FROM MangaTag mt GROUP BY mt.name ORDER BY COUNT(mt) DESC")
    List<String> findMostPopularTags(org.springframework.data.domain.Pageable pageable);

    /**
     * 查找最近创建的标签
     */
    List<MangaTag> findTop10ByOrderByCreatedAtDesc();

    /**
     * 检查标签是否已存在于指定漫画中
     */
    boolean existsByNameAndMangaId(String name, Long mangaId);

    /**
     * 检查标签名称是否已存在
     */
    boolean existsByNameIgnoreCase(String name);

    /**
     * 删除指定漫画的所有标签
     */
    void deleteByMangaId(Long mangaId);

    /**
     * 删除指定漫画库的所有标签
     */
    @Modifying
    @Query("DELETE FROM MangaTag mt WHERE mt.manga.library.id = :libraryId")
    void deleteByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 删除指定名称的所有标签
     */
    void deleteByNameIgnoreCase(String name);

    /**
     * 批量删除指定漫画的标签
     */
    @Modifying
    @Query("DELETE FROM MangaTag mt WHERE mt.manga.id = :mangaId AND mt.name IN :tagNames")
    void deleteByMangaIdAndNameIn(@Param("mangaId") Long mangaId, @Param("tagNames") List<String> tagNames);

    /**
     * 查找包含指定标签的所有漫画ID
     */
    @Query("SELECT DISTINCT mt.manga.id FROM MangaTag mt WHERE mt.name = :tagName")
    List<Long> findMangaIdsByTagName(@Param("tagName") String tagName);

    /**
     * 查找包含任意指定标签的所有漫画ID
     */
    @Query("SELECT DISTINCT mt.manga.id FROM MangaTag mt WHERE mt.name IN :tagNames")
    List<Long> findMangaIdsByTagNames(@Param("tagNames") List<String> tagNames);

    /**
     * 查找同时包含所有指定标签的漫画ID
     */
    @Query("SELECT mt.manga.id FROM MangaTag mt WHERE mt.name IN :tagNames " +
           "GROUP BY mt.manga.id HAVING COUNT(DISTINCT mt.name) = :tagCount")
    List<Long> findMangaIdsWithAllTags(@Param("tagNames") List<String> tagNames, 
                                       @Param("tagCount") long tagCount);

    /**
     * 查找相似的标签（基于名称相似度）
     */
    @Query("SELECT mt FROM MangaTag mt WHERE LOWER(mt.name) LIKE LOWER(CONCAT('%', :pattern, '%')) AND mt.name != :excludeName")
    List<MangaTag> findSimilarTags(@Param("pattern") String pattern, @Param("excludeName") String excludeName);

    /**
     * 统计指定漫画的标签数量
     */
    long countByMangaId(Long mangaId);

    /**
     * 统计指定标签名称的使用次数
     */
    long countByNameIgnoreCase(String name);

    /**
     * 统计指定漫画库的标签总数
     */
    @Query("SELECT COUNT(mt) FROM MangaTag mt WHERE mt.manga.library.id = :libraryId")
    long countByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 统计不重复标签名称的数量
     */
    @Query("SELECT COUNT(DISTINCT mt.name) FROM MangaTag mt")
    long countDistinctTagNames();

    /**
     * 统计指定漫画库中不重复标签名称的数量
     */
    @Query("SELECT COUNT(DISTINCT mt.name) FROM MangaTag mt WHERE mt.manga.library.id = :libraryId")
    long countDistinctTagNamesByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 查找未使用的标签（孤立标签）
     */
    @Query("SELECT mt FROM MangaTag mt WHERE mt.manga IS NULL")
    List<MangaTag> findOrphanedTags();

    /**
     * 查找重复的标签（相同名称但不同ID）
     */
    @Query("SELECT mt FROM MangaTag mt WHERE EXISTS (" +
           "SELECT mt2 FROM MangaTag mt2 WHERE mt2.id != mt.id AND " +
           "LOWER(mt2.name) = LOWER(mt.name) AND mt2.manga.id = mt.manga.id)")
    List<MangaTag> findDuplicateTags();

    /**
     * 查找指定颜色范围的标签
     */
    List<MangaTag> findByColorIn(List<String> colors);

    /**
     * 更新标签颜色
     */
    @Modifying
    @Query("UPDATE MangaTag mt SET mt.color = :color WHERE mt.name = :name")
    void updateTagColor(@Param("name") String name, @Param("color") String color);

    /**
     * 更新标签描述
     */
    @Modifying
    @Query("UPDATE MangaTag mt SET mt.description = :description WHERE mt.id = :tagId")
    void updateTagDescription(@Param("tagId") Long tagId, @Param("description") String description);

    /**
     * 批量更新标签颜色
     */
    @Modifying
    @Query("UPDATE MangaTag mt SET mt.color = :color WHERE mt.name IN :tagNames")
    void updateTagsColor(@Param("tagNames") List<String> tagNames, @Param("color") String color);

    /**
     * 重命名标签
     */
    @Modifying
    @Query("UPDATE MangaTag mt SET mt.name = :newName WHERE mt.name = :oldName")
    void renameTag(@Param("oldName") String oldName, @Param("newName") String newName);

    /**
     * 合并标签（将源标签重命名为目标标签）
     */
    @Modifying
    @Query("UPDATE MangaTag mt SET mt.name = :targetName WHERE mt.name = :sourceName")
    void mergeTags(@Param("sourceName") String sourceName, @Param("targetName") String targetName);

    /**
     * 清理重复标签（保留最早创建的）
     */
    @Modifying
    @Query("DELETE FROM MangaTag mt WHERE mt.id NOT IN (" +
           "SELECT MIN(mt2.id) FROM MangaTag mt2 WHERE " +
           "LOWER(mt2.name) = LOWER(mt.name) AND mt2.manga.id = mt.manga.id)")
    void cleanupDuplicateTags();
}