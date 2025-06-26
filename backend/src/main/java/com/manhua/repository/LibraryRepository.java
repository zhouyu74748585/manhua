package com.manhua.repository;

import com.manhua.entity.Library;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 漫画库数据访问层
 */
@Repository
public interface LibraryRepository extends JpaRepository<Library, Long> {

    /**
     * 根据名称查找库
     */
    Optional<Library> findByName(String name);

    /**
     * 根据路径查找库
     */
    Optional<Library> findByPath(String path);

    /**
     * 根据类型查找库
     */
    List<Library> findByType(String type);

    /**
     * 根据隐私状态查找库
     */
    List<Library> findByIsPrivate(Boolean isPrivate);

    /**
     * 根据状态查找库
     */
    List<Library> findByStatus(String status);

    /**
     * 根据扫描状态查找库
     */
    List<Library> findByScanStatus(String scanStatus);

    /**
     * 查找活跃的库
     */
    @Query("SELECT l FROM Library l WHERE l.status = 'active'")
    List<Library> findActiveLibraries();

    /**
     * 查找需要扫描的库
     */
    @Query("SELECT l FROM Library l WHERE l.scanStatus = 'idle' AND l.status = 'active'")
    List<Library> findLibrariesNeedingScan();

    /**
     * 根据名称模糊查询
     */
    @Query("SELECT l FROM Library l WHERE l.name LIKE %:name%")
    List<Library> findByNameContaining(@Param("name") String name);

    /**
     * 统计库的数量
     */
    @Query("SELECT COUNT(l) FROM Library l WHERE l.status = 'active'")
    Long countActiveLibraries();

    /**
     * 统计隐私库的数量
     */
    @Query("SELECT COUNT(l) FROM Library l WHERE l.isPrivate = true AND l.status = 'active'")
    Long countPrivateLibraries();
}