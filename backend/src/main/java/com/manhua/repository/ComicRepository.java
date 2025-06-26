package com.manhua.repository;

import com.manhua.entity.Comic;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 漫画数据访问层
 */
@Repository
public interface ComicRepository extends JpaRepository<Comic, Long> {

    /**
     * 根据标题查找漫画
     */
    Optional<Comic> findByTitle(String title);

    /**
     * 根据文件路径查找漫画
     */
    Optional<Comic> findByFilePath(String filePath);

    /**
     * 根据库ID查找漫画
     */
    List<Comic> findByLibraryId(Long libraryId);

    /**
     * 根据库ID分页查找漫画
     */
    Page<Comic> findByLibraryId(Long libraryId, Pageable pageable);

    /**
     * 根据阅读状态查找漫画
     */
    List<Comic> findByReadingStatus(String readingStatus);

    /**
     * 根据隐私状态查找漫画
     */
    List<Comic> findByIsPrivate(Boolean isPrivate);

    /**
     * 根据收藏状态查找漫画
     */
    List<Comic> findByIsFavorite(Boolean isFavorite);

    /**
     * 根据作者查找漫画
     */
    List<Comic> findByAuthor(String author);

    /**
     * 根据评分查找漫画
     */
    List<Comic> findByRating(Integer rating);

    /**
     * 根据标题模糊查询
     */
    @Query("SELECT c FROM Comic c WHERE c.title LIKE %:title%")
    List<Comic> findByTitleContaining(@Param("title") String title);

    /**
     * 根据作者模糊查询
     */
    @Query("SELECT c FROM Comic c WHERE c.author LIKE %:author%")
    List<Comic> findByAuthorContaining(@Param("author") String author);

    /**
     * 根据描述模糊查询
     */
    @Query("SELECT c FROM Comic c WHERE c.description LIKE %:description%")
    List<Comic> findByDescriptionContaining(@Param("description") String description);

    /**
     * 综合搜索
     */
    @Query("SELECT c FROM Comic c WHERE c.title LIKE %:keyword% OR c.author LIKE %:keyword% OR c.description LIKE %:keyword%")
    Page<Comic> searchComics(@Param("keyword") String keyword, Pageable pageable);

    /**
     * 根据库ID和关键词搜索
     */
    @Query("SELECT c FROM Comic c WHERE c.library.id = :libraryId AND (c.title LIKE %:keyword% OR c.author LIKE %:keyword% OR c.description LIKE %:keyword%)")
    Page<Comic> searchComicsByLibrary(@Param("libraryId") Long libraryId, @Param("keyword") String keyword, Pageable pageable);

    /**
     * 查找最近阅读的漫画
     */
    @Query("SELECT c FROM Comic c WHERE c.lastReadTime IS NOT NULL ORDER BY c.lastReadTime DESC")
    Page<Comic> findRecentlyRead(Pageable pageable);

    /**
     * 查找正在阅读的漫画
     */
    @Query("SELECT c FROM Comic c WHERE c.readingStatus = 'reading' ORDER BY c.lastReadTime DESC")
    List<Comic> findCurrentlyReading();

    /**
     * 查找已完成的漫画
     */
    @Query("SELECT c FROM Comic c WHERE c.readingStatus = 'completed' ORDER BY c.updateTime DESC")
    List<Comic> findCompleted();

    /**
     * 查找未读的漫画
     */
    @Query("SELECT c FROM Comic c WHERE c.readingStatus = 'unread' ORDER BY c.createTime DESC")
    List<Comic> findUnread();

    /**
     * 根据标签查找漫画
     */
    @Query("SELECT c FROM Comic c JOIN c.tags t WHERE t.name IN :tagNames")
    List<Comic> findByTagNames(@Param("tagNames") List<String> tagNames);

    /**
     * 根据库ID和标签查找漫画
     */
    @Query("SELECT c FROM Comic c JOIN c.tags t WHERE c.library.id = :libraryId AND t.name IN :tagNames")
    Page<Comic> findByLibraryIdAndTagNames(@Param("libraryId") Long libraryId, @Param("tagNames") List<String> tagNames, Pageable pageable);

    /**
     * 根据库ID和阅读状态查找漫画
     */
    Page<Comic> findByLibraryIdAndReadingStatus(Long libraryId, String readingStatus, Pageable pageable);

    /**
     * 根据库ID和隐私状态查找漫画
     */
    Page<Comic> findByLibraryIdAndIsPrivate(Long libraryId, Boolean isPrivate, Pageable pageable);

    /**
     * 统计漫画总数
     */
    @Query("SELECT COUNT(c) FROM Comic c")
    Long countAllComics();

    /**
     * 统计库中的漫画数量
     */
    @Query("SELECT COUNT(c) FROM Comic c WHERE c.library.id = :libraryId")
    Long countByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 统计隐私漫画数量
     */
    @Query("SELECT COUNT(c) FROM Comic c WHERE c.isPrivate = true")
    Long countPrivateComics();

    /**
     * 统计各阅读状态的漫画数量
     */
    @Query("SELECT c.readingStatus, COUNT(c) FROM Comic c GROUP BY c.readingStatus")
    List<Object[]> countByReadingStatus();

    /**
     * 查找需要更新的漫画（文件修改时间晚于记录更新时间）
     */
    @Query("SELECT c FROM Comic c WHERE c.fileModifyTime > c.updateTime")
    List<Comic> findComicsNeedingUpdate();

    /**
     * 根据文件修改时间范围查找漫画
     */
    @Query("SELECT c FROM Comic c WHERE c.fileModifyTime BETWEEN :startTime AND :endTime")
    List<Comic> findByFileModifyTimeBetween(@Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);
}