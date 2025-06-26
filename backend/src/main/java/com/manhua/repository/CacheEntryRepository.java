package com.manhua.repository;

import com.manhua.entity.CacheEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 缓存条目数据访问层
 */
@Repository
public interface CacheEntryRepository extends JpaRepository<CacheEntry, Long> {

    /**
     * 根据缓存键查找缓存条目
     */
    Optional<CacheEntry> findByCacheKey(String cacheKey);

    /**
     * 根据缓存类型查找缓存条目
     */
    List<CacheEntry> findByCacheType(String cacheType);

    /**
     * 根据漫画ID查找缓存条目
     */
    List<CacheEntry> findByComicId(Long comicId);

    /**
     * 根据MIME类型查找缓存条目
     */
    List<CacheEntry> findByMimeType(String mimeType);

    /**
     * 查找已过期的缓存条目
     */
    @Query("SELECT ce FROM CacheEntry ce WHERE ce.expiryTime < :currentTime")
    List<CacheEntry> findExpiredEntries(@Param("currentTime") LocalDateTime currentTime);

    /**
     * 查找未过期的缓存条目
     */
    @Query("SELECT ce FROM CacheEntry ce WHERE ce.expiryTime > :currentTime OR ce.expiryTime IS NULL")
    List<CacheEntry> findValidEntries(@Param("currentTime") LocalDateTime currentTime);

    /**
     * 根据访问次数查找缓存条目
     */
    @Query("SELECT ce FROM CacheEntry ce WHERE ce.accessCount >= :minCount ORDER BY ce.accessCount DESC")
    List<CacheEntry> findByAccessCountGreaterThanEqual(@Param("minCount") Integer minCount);

    /**
     * 查找最近访问的缓存条目
     */
    @Query("SELECT ce FROM CacheEntry ce ORDER BY ce.lastAccessTime DESC")
    List<CacheEntry> findRecentlyAccessed();

    /**
     * 查找最少访问的缓存条目
     */
    @Query("SELECT ce FROM CacheEntry ce ORDER BY ce.accessCount ASC, ce.lastAccessTime ASC")
    List<CacheEntry> findLeastAccessed();

    /**
     * 根据文件大小范围查找缓存条目
     */
    @Query("SELECT ce FROM CacheEntry ce WHERE ce.fileSize BETWEEN :minSize AND :maxSize")
    List<CacheEntry> findByFileSizeBetween(@Param("minSize") Long minSize, @Param("maxSize") Long maxSize);

    /**
     * 统计缓存条目总数
     */
    @Query("SELECT COUNT(ce) FROM CacheEntry ce")
    Long countAllEntries();

    /**
     * 统计各类型的缓存条目数量
     */
    @Query("SELECT ce.cacheType, COUNT(ce) FROM CacheEntry ce GROUP BY ce.cacheType")
    List<Object[]> countByCacheType();

    /**
     * 统计缓存总大小
     */
    @Query("SELECT SUM(ce.fileSize) FROM CacheEntry ce")
    Long sumTotalCacheSize();

    /**
     * 根据类型统计缓存大小
     */
    @Query("SELECT ce.cacheType, SUM(ce.fileSize) FROM CacheEntry ce GROUP BY ce.cacheType")
    List<Object[]> sumCacheSizeByType();

    /**
     * 删除过期的缓存条目
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM CacheEntry ce WHERE ce.expiryTime < :currentTime")
    int deleteExpiredEntries(@Param("currentTime") LocalDateTime currentTime);

    /**
     * 删除指定类型的缓存条目
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM CacheEntry ce WHERE ce.cacheType = :cacheType")
    int deleteByCacheType(@Param("cacheType") String cacheType);

    /**
     * 删除指定漫画的缓存条目
     */
    @Modifying
    @Transactional
    @Query("DELETE FROM CacheEntry ce WHERE ce.comicId = :comicId")
    int deleteByComicId(@Param("comicId") Long comicId);

    /**
     * 更新访问信息
     */
    @Modifying
    @Transactional
    @Query("UPDATE CacheEntry ce SET ce.accessCount = ce.accessCount + 1, ce.lastAccessTime = :accessTime WHERE ce.id = :id")
    int updateAccessInfo(@Param("id") Long id, @Param("accessTime") LocalDateTime accessTime);

    /**
     * 查找需要清理的缓存条目（按LRU策略）
     */
    @Query("SELECT ce FROM CacheEntry ce ORDER BY ce.lastAccessTime ASC")
    List<CacheEntry> findForCleanup();
}