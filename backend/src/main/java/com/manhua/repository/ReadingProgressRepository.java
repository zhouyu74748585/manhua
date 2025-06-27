package com.manhua.repository;

import com.manhua.entity.ReadingProgress;
import com.manhua.entity.Manga;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 阅读进度数据访问接口
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Repository
public interface ReadingProgressRepository extends JpaRepository<ReadingProgress, Long> {


    /**
     * 根据漫画ID查找阅读进度
     */
    Optional<ReadingProgress> findByMangaId(Long mangaId);



    /**
     * 查找最近阅读的进度记录
     */
    @Query("SELECT rp FROM ReadingProgress rp WHERE rp.lastReadAt IS NOT NULL ORDER BY rp.lastReadAt DESC")
    List<ReadingProgress> findRecentlyRead(org.springframework.data.domain.Pageable pageable);

    /**
     * 查找已完成的漫画进度
     */
    @Query("SELECT rp FROM ReadingProgress rp WHERE rp.currentPage >= rp.totalPages AND rp.totalPages > 0")
    List<ReadingProgress> findCompletedProgress();

    /**
     * 查找进行中的漫画进度
     */
    @Query("SELECT rp FROM ReadingProgress rp WHERE rp.currentPage > 0 AND rp.currentPage < rp.totalPages")
    List<ReadingProgress> findInProgressManga();

    /**
     * 重置阅读进度
     */
    @Modifying
    @Query("UPDATE ReadingProgress rp SET rp.currentPage = 0, rp.readingTime = 0, rp.sessionStart = NULL, rp.sessionEnd = NULL WHERE rp.manga.id = :mangaId")
    void resetProgress(@Param("mangaId") Long mangaId);

    /**
     * 标记为已完成
     */
    @Modifying
    @Query("UPDATE ReadingProgress rp SET rp.currentPage = rp.totalPages WHERE rp.manga.id = :mangaId")
    void markAsCompleted(@Param("mangaId") Long mangaId);

    /**
     * 删除指定漫画的阅读进度
     */
    void deleteByMangaId(Long mangaId);


}
