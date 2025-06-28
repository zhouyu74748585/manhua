package com.manhua.repository;

import com.manhua.entity.Manga;
import com.manhua.entity.MangaLibrary;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 漫画数据访问接口
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Repository
public interface MangaRepository extends JpaRepository<Manga, Long> {

    /**
     * 根据标题查找漫画
     */
    Optional<Manga> findByTitle(String title);

    /**
     * 根据文件路径查找漫画
     */
    Optional<Manga> findByFilePath(String filePath);

    /**
     * 根据漫画库查找漫画
     */
    List<Manga> findByLibrary(MangaLibrary library);

    /**
     * 根据漫画库ID查找漫画
     */
    List<Manga> findByLibraryId(Long libraryId);

    /**
     * 分页查询指定漫画库的漫画
     */
    Page<Manga> findByLibraryId(Long libraryId, Pageable pageable);

    /**
     * 根据作者查找漫画
     */
    List<Manga> findByAuthorContainingIgnoreCase(String author);

    /**
     * 根据标题模糊查询
     */
    List<Manga> findByTitleContainingIgnoreCase(String title);

    /**
     * 根据类型查找漫画
     */
    List<Manga> findByGenreContainingIgnoreCase(String genre);

    /**
     * 根据状态查找漫画
     */
    List<Manga> findByStatus(Manga.MangaStatus status);

    /**
     * 查找指定评分范围的漫画
     */
    List<Manga> findByRatingBetween(Double minRating, Double maxRating);

    /**
     * 查找最近阅读的漫画
     */
    @Query("SELECT m FROM Manga m WHERE m.lastReadAt IS NOT NULL ORDER BY m.lastReadAt DESC")
    List<Manga> findRecentlyRead(Pageable pageable);

    /**
     * 查找最近添加的漫画
     */
    List<Manga> findTop10ByOrderByCreatedAtDesc();

    /**
     * 查找最近更新的漫画
     */
    List<Manga> findTop10ByOrderByUpdatedAtDesc();

    /**
     * 查找高评分漫画
     */
    @Query("SELECT m FROM Manga m WHERE m.rating >= :minRating ORDER BY m.rating DESC")
    List<Manga> findHighRatedManga(@Param("minRating") Double minRating, Pageable pageable);

    /**
     * 查找未完成的漫画
     */
    @Query("SELECT m FROM Manga m WHERE m.status != 'COMPLETED' ORDER BY m.lastReadAt DESC")
    List<Manga> findUnfinishedManga(Pageable pageable);

    /**
     * 查找已完成的漫画
     */
    List<Manga> findByStatusOrderByCompletedAtDesc(Manga.MangaStatus status);

    /**
     * 统计指定漫画库的漫画数量
     */
    long countByLibraryId(Long libraryId);

    /**
     * 统计指定状态的漫画数量
     */
    long countByStatus(Manga.MangaStatus status);

    /**
     * 统计指定作者的漫画数量
     */
    long countByAuthorContainingIgnoreCase(String author);

    /**
     * 计算指定漫画库的总大小
     */
    @Query("SELECT SUM(m.fileSize) FROM Manga m WHERE m.library.id = :libraryId")
    Long sumFileSizeByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 更新漫画的阅读时间
     */
    @Modifying
    @Query("UPDATE Manga m SET m.lastReadAt = :readTime WHERE m.id = :mangaId")
    void updateLastReadTime(@Param("mangaId") Long mangaId, @Param("readTime") LocalDateTime readTime);

    /**
     * 更新漫画状态
     */
    @Modifying
    @Query("UPDATE Manga m SET m.status = :status WHERE m.id = :mangaId")
    void updateStatus(@Param("mangaId") Long mangaId, @Param("status") Manga.MangaStatus status);

    /**
     * 更新漫画评分
     */
    @Modifying
    @Query("UPDATE Manga m SET m.rating = :rating WHERE m.id = :mangaId")
    void updateRating(@Param("mangaId") Long mangaId, @Param("rating") Double rating);

    /**
     * 批量删除指定漫画库的漫画
     */
    @Modifying
    void deleteByLibraryId(Long libraryId);

    /**
     * 检查文件路径是否已存在
     */
    boolean existsByFilePath(String filePath);

    /**
     * 检查标题是否已存在（在同一漫画库中）
     */
    boolean existsByTitleAndLibraryId(String title, Long libraryId);

    /**
     * 全文搜索漫画
     */
    @Query("SELECT m FROM Manga m WHERE " +
           "LOWER(m.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(m.author) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(m.description) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(m.genre) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Manga> searchManga(@Param("keyword") String keyword, Pageable pageable);

    /**
     * 在指定漫画库中搜索漫画
     */
    @Query("SELECT m FROM Manga m WHERE m.library.id = :libraryId AND (" +
           "LOWER(m.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(m.author) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(m.description) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(m.genre) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Manga> searchMangaInLibrary(@Param("libraryId") Long libraryId,
                                     @Param("keyword") String keyword,
                                     Pageable pageable);

    /**
     * 查找相似漫画（基于作者和类型）
     */
    @Query("SELECT m FROM Manga m WHERE m.id != :mangaId AND (" +
           "LOWER(m.author) LIKE LOWER(CONCAT('%', :author, '%')) OR " +
           "LOWER(m.genre) LIKE LOWER(CONCAT('%', :genre, '%')))")
    List<Manga> findSimilarManga(@Param("mangaId") Long mangaId,
                                 @Param("author") String author,
                                 @Param("genre") String genre,
                                 Pageable pageable);

    /**
     * 查找指定时间范围内添加的漫画
     */
    List<Manga> findByCreatedAtBetween(LocalDateTime startTime, LocalDateTime endTime);

    /**
     * 查找指定时间范围内阅读的漫画
     */
    List<Manga> findByLastReadAtBetween(LocalDateTime startTime, LocalDateTime endTime);


    /**
     * 查找指定文件大小范围的漫画
     */
    List<Manga> findByFileSizeBetween(Long minSize, Long maxSize);

    /**
     * 获取漫画统计信息
     */
    @Query("SELECT m.status, COUNT(m), AVG(m.rating), SUM(m.fileSize) " +
           "FROM Manga m GROUP BY m.status")
    List<Object[]> getMangaStatistics();

    /**
     * 获取指定漫画库的统计信息
     */
    @Query("SELECT m.status, COUNT(m), AVG(m.rating), SUM(m.fileSize) " +
           "FROM Manga m WHERE m.library.id = :libraryId GROUP BY m.status")
    List<Object[]> getMangaStatisticsByLibrary(@Param("libraryId") Long libraryId);

    /**
     * 查找孤立的漫画（文件不存在）
     */
    @Query("SELECT m FROM Manga m WHERE m.filePath NOT IN " +
           "(SELECT DISTINCT m2.filePath FROM Manga m2 WHERE m2.library.id = :libraryId)")
    List<Manga> findOrphanedManga(@Param("libraryId") Long libraryId);

    /**
     * 查找重复的漫画（相同标题和作者）
     */
    @Query("SELECT m FROM Manga m WHERE EXISTS (" +
           "SELECT m2 FROM Manga m2 WHERE m2.id != m.id AND " +
           "m2.title = m.title AND m2.author = m.author)")
    List<Manga> findDuplicateManga();

    /**
     * 随机获取漫画
     */
    @Query(value = "SELECT * FROM manga ORDER BY RANDOM() LIMIT :limit", nativeQuery = true)
    List<Manga> findRandomManga(@Param("limit") int limit);

    /**
     * 查找热门漫画（基于阅读次数和评分）
     */
    @Query("SELECT m FROM Manga m WHERE m.rating >= 4.0 ORDER BY m.lastReadAt DESC")
    List<Manga> findPopularManga(Pageable pageable);

    // 激活库相关查询方法
    
    /**
     * 查找激活库的所有漫画
     */
    Page<Manga> findByLibraryIsActiveTrue(Pageable pageable);
    
    /**
     * 查找指定激活库的漫画
     */
    Page<Manga> findByLibraryIdAndLibraryIsActiveTrue(Long libraryId, Pageable pageable);
    
    /**
     * 在激活库中按标题搜索漫画
     */
    Page<Manga> findByLibraryIsActiveTrueAndTitleContainingIgnoreCase(String title, Pageable pageable);
    
    /**
     * 在指定激活库中按标题搜索漫画
     */
    Page<Manga> findByLibraryIdAndLibraryIsActiveTrueAndTitleContainingIgnoreCase(
        Long libraryId, String title, Pageable pageable);
    
    /**
     * 在激活库中按类型搜索漫画
     */
    Page<Manga> findByLibraryIsActiveTrueAndGenreContainingIgnoreCase(String genre, Pageable pageable);
    
    /**
     * 在指定激活库中按类型搜索漫画
     */
    Page<Manga> findByLibraryIdAndLibraryIsActiveTrueAndGenreContainingIgnoreCase(
        Long libraryId, String genre, Pageable pageable);
    
    /**
     * 在激活库中按状态搜索漫画
     */
    Page<Manga> findByLibraryIsActiveTrueAndStatus(String status, Pageable pageable);
    
    /**
     * 在指定激活库中按状态搜索漫画
     */
    Page<Manga> findByLibraryIdAndLibraryIsActiveTrueAndStatus(
        Long libraryId, String status, Pageable pageable);
    
    /**
     * 按标题搜索漫画（分页）
     */
    Page<Manga> findByTitleContainingIgnoreCase(String title, Pageable pageable);
    
    /**
     * 在指定库中按标题搜索漫画（分页）
     */
    Page<Manga> findByLibraryIdAndTitleContainingIgnoreCase(Long libraryId, String title, Pageable pageable);
    
    /**
     * 按类型搜索漫画（分页）
     */
    Page<Manga> findByGenreContainingIgnoreCase(String genre, Pageable pageable);
    
    /**
     * 在指定库中按类型搜索漫画（分页）
     */
    Page<Manga> findByLibraryIdAndGenreContainingIgnoreCase(Long libraryId, String genre, Pageable pageable);
    
    /**
     * 按状态搜索漫画（分页）
     */
    Page<Manga> findByStatus(String status, Pageable pageable);
    
    /**
     * 在指定库中按状态搜索漫画（分页）
     */
    Page<Manga> findByLibraryIdAndStatus(Long libraryId, String status, Pageable pageable);
}
