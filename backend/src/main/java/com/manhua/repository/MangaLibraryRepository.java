package com.manhua.repository;

import com.manhua.entity.MangaLibrary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 漫画库数据访问接口
 * 
 * @author ManhuaReader
 * @version 1.0.0
 */
@Repository
public interface MangaLibraryRepository extends JpaRepository<MangaLibrary, Long> {

    /**
     * 根据名称查找漫画库
     */
    Optional<MangaLibrary> findByName(String name);

    /**
     * 根据路径查找漫画库
     */
    Optional<MangaLibrary> findByPath(String path);

    /**
     * 查找所有激活的漫画库
     */
    List<MangaLibrary> findByIsActiveTrue();

    /**
     * 查找当前漫画库
     */
    Optional<MangaLibrary> findByIsCurrentTrue();

    /**
     * 根据类型查找漫画库
     */
    List<MangaLibrary> findByType(MangaLibrary.LibraryType type);

    /**
     * 查找需要自动扫描的漫画库
     */
    @Query("SELECT l FROM MangaLibrary l WHERE l.isActive = true AND l.autoScan = true")
    List<MangaLibrary> findAutoScanLibraries();

    /**
     * 查找需要扫描的漫画库（基于扫描间隔）
     */
    @Query("SELECT l FROM MangaLibrary l WHERE l.isActive = true AND l.autoScan = true " +
           "AND (l.lastScanAt IS NULL OR l.lastScanAt < :threshold)")
    List<MangaLibrary> findLibrariesNeedingScan(@Param("threshold") LocalDateTime threshold);

    /**
     * 统计激活的漫画库数量
     */
    long countByIsActiveTrue();

    /**
     * 统计指定类型的漫画库数量
     */
    long countByType(MangaLibrary.LibraryType type);

    /**
     * 更新漫画库的漫画数量
     */
    @Modifying
    @Query("UPDATE MangaLibrary l SET l.mangaCount = :count WHERE l.id = :libraryId")
    void updateMangaCount(@Param("libraryId") Long libraryId, @Param("count") Integer count);

    /**
     * 更新漫画库的总大小
     */
    @Modifying
    @Query("UPDATE MangaLibrary l SET l.totalSize = :size WHERE l.id = :libraryId")
    void updateTotalSize(@Param("libraryId") Long libraryId, @Param("size") Long size);

    /**
     * 更新最后扫描时间
     */
    @Modifying
    @Query("UPDATE MangaLibrary l SET l.lastScanAt = :scanTime WHERE l.id = :libraryId")
    void updateLastScanTime(@Param("libraryId") Long libraryId, @Param("scanTime") LocalDateTime scanTime);

    /**
     * 设置当前漫画库
     */
    @Modifying
    @Query("UPDATE MangaLibrary l SET l.isCurrent = CASE WHEN l.id = :libraryId THEN true ELSE false END")
    void setCurrentLibrary(@Param("libraryId") Long libraryId);

    /**
     * 检查名称是否已存在（排除指定ID）
     */
    boolean existsByNameAndIdNot(String name, Long id);

    /**
     * 检查路径是否已存在（排除指定ID）
     */
    boolean existsByPathAndIdNot(String path, Long id);

    /**
     * 根据名称模糊查询
     */
    List<MangaLibrary> findByNameContainingIgnoreCase(String name);

    /**
     * 查找最近创建的漫画库
     */
    List<MangaLibrary> findTop5ByOrderByCreatedAtDesc();

    /**
     * 查找最近更新的漫画库
     */
    List<MangaLibrary> findTop5ByOrderByUpdatedAtDesc();

    /**
     * 获取漫画库统计信息
     */
    @Query("SELECT l.type, COUNT(l), SUM(l.mangaCount), SUM(l.totalSize) " +
           "FROM MangaLibrary l WHERE l.isActive = true GROUP BY l.type")
    List<Object[]> getLibraryStatistics();

    /**
     * 查找包含指定漫画数量范围的漫画库
     */
    List<MangaLibrary> findByMangaCountBetween(Integer minCount, Integer maxCount);

    /**
     * 查找大小在指定范围内的漫画库
     */
    List<MangaLibrary> findByTotalSizeBetween(Long minSize, Long maxSize);

    /**
     * 删除非激活状态的漫画库
     */
    @Modifying
    @Query("DELETE FROM MangaLibrary l WHERE l.isActive = false")
    void deleteInactiveLibraries();

    /**
     * 批量更新漫画库状态
     */
    @Modifying
    @Query("UPDATE MangaLibrary l SET l.isActive = :active WHERE l.id IN :ids")
    void updateLibraryStatus(@Param("ids") List<Long> ids, @Param("active") Boolean active);

    /**
     * 查找指定时间之后创建的漫画库
     */
    List<MangaLibrary> findByCreatedAtAfter(LocalDateTime dateTime);

    /**
     * 查找指定时间之后更新的漫画库
     */
    List<MangaLibrary> findByUpdatedAtAfter(LocalDateTime dateTime);

    /**
     * 查找指定时间之后扫描的漫画库
     */
    List<MangaLibrary> findByLastScanAtAfter(LocalDateTime dateTime);
}