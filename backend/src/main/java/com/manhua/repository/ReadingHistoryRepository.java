package com.manhua.repository;

import com.manhua.entity.ReadingHistory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 阅读历史数据访问层
 */
@Repository
public interface ReadingHistoryRepository extends JpaRepository<ReadingHistory, Long> {

    /**
     * 根据漫画ID查找阅读历史
     */
    List<ReadingHistory> findByComicId(Long comicId);

    /**
     * 根据漫画ID分页查找阅读历史
     */
    Page<ReadingHistory> findByComicId(Long comicId, Pageable pageable);

    /**
     * 根据漫画ID按时间倒序查找阅读历史
     */
    @Query("SELECT rh FROM ReadingHistory rh WHERE rh.comic.id = :comicId ORDER BY rh.readTime DESC")
    List<ReadingHistory> findByComicIdOrderByReadTimeDesc(@Param("comicId") Long comicId);

    /**
     * 查找指定时间范围内的阅读历史
     */
    @Query("SELECT rh FROM ReadingHistory rh WHERE rh.readTime BETWEEN :startTime AND :endTime ORDER BY rh.readTime DESC")
    List<ReadingHistory> findByReadTimeBetween(@Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);

    /**
     * 查找最近的阅读历史
     */
    @Query("SELECT rh FROM ReadingHistory rh ORDER BY rh.readTime DESC")
    Page<ReadingHistory> findRecentHistory(Pageable pageable);

    /**
     * 根据阅读模式查找历史
     */
    List<ReadingHistory> findByReadingMode(String readingMode);

    /**
     * 统计漫画的阅读次数
     */
    @Query("SELECT COUNT(rh) FROM ReadingHistory rh WHERE rh.comic.id = :comicId")
    Long countByComicId(@Param("comicId") Long comicId);

    /**
     * 统计漫画的总阅读时长
     */
    @Query("SELECT SUM(rh.readingDuration) FROM ReadingHistory rh WHERE rh.comic.id = :comicId")
    Long sumReadingDurationByComicId(@Param("comicId") Long comicId);

    /**
     * 查找漫画的最后阅读记录
     */
    @Query("SELECT rh FROM ReadingHistory rh WHERE rh.comic.id = :comicId ORDER BY rh.readTime DESC LIMIT 1")
    ReadingHistory findLastReadingByComicId(@Param("comicId") Long comicId);

    /**
     * 统计总阅读时长
     */
    @Query("SELECT SUM(rh.readingDuration) FROM ReadingHistory rh")
    Long sumTotalReadingDuration();

    /**
     * 统计阅读历史总数
     */
    @Query("SELECT COUNT(rh) FROM ReadingHistory rh")
    Long countAllHistory();

    /**
     * 根据设备信息查找阅读历史
     */
    List<ReadingHistory> findByDeviceInfo(String deviceInfo);

    /**
     * 删除指定时间之前的阅读历史
     */
    @Query("DELETE FROM ReadingHistory rh WHERE rh.readTime < :cutoffTime")
    void deleteOldHistory(@Param("cutoffTime") LocalDateTime cutoffTime);

    /**
     * 查找库的阅读历史
     */
    @Query("SELECT rh FROM ReadingHistory rh WHERE rh.comic.library.id = :libraryId ORDER BY rh.readTime DESC")
    List<ReadingHistory> findByLibraryId(@Param("libraryId") Long libraryId);

    /**
     * 统计各阅读模式的使用次数
     */
    @Query("SELECT rh.readingMode, COUNT(rh) FROM ReadingHistory rh GROUP BY rh.readingMode")
    List<Object[]> countByReadingMode();
}