package com.manhua.repository;

import com.manhua.entity.UserSettings;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 用户设置数据访问层
 */
@Repository
public interface UserSettingsRepository extends JpaRepository<UserSettings, Long> {

    /**
     * 根据设置键查找设置
     */
    Optional<UserSettings> findBySettingKey(String settingKey);

    /**
     * 根据分类查找设置
     */
    List<UserSettings> findByCategory(String category);

    /**
     * 查找系统设置
     */
    @Query("SELECT us FROM UserSettings us WHERE us.isSystemSetting = true")
    List<UserSettings> findSystemSettings();

    /**
     * 查找用户设置
     */
    @Query("SELECT us FROM UserSettings us WHERE us.isSystemSetting = false")
    List<UserSettings> findUserSettings();

    /**
     * 根据设置键模糊查询
     */
    @Query("SELECT us FROM UserSettings us WHERE us.settingKey LIKE %:key%")
    List<UserSettings> findBySettingKeyContaining(@Param("key") String key);

    /**
     * 查找所有分类
     */
    @Query("SELECT DISTINCT us.category FROM UserSettings us WHERE us.category IS NOT NULL ORDER BY us.category")
    List<String> findAllCategories();

    /**
     * 统计设置总数
     */
    @Query("SELECT COUNT(us) FROM UserSettings us")
    Long countAllSettings();

    /**
     * 统计各分类的设置数量
     */
    @Query("SELECT us.category, COUNT(us) FROM UserSettings us GROUP BY us.category")
    List<Object[]> countByCategory();

    /**
     * 根据分类和系统设置标志查找
     */
    List<UserSettings> findByCategoryAndIsSystemSetting(String category, Boolean isSystemSetting);
}