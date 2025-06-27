package com.manhua.repository;

import com.manhua.entity.AppSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 应用设置数据访问层
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Repository
public interface AppSettingsRepository extends JpaRepository<AppSettings, Long> {

    /**
     * 根据设置键查找设置
     */
    Optional<AppSettings> findByKey(String key);

    /**
     * 根据设置键删除设置
     */
    void deleteByKey(String key);

    /**
     * 检查设置键是否存在
     */
    boolean existsByKey(String key);
}