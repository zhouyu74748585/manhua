package com.manhua.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

/**
 * 缓存配置类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Configuration
@EnableCaching
public class CacheConfig {

    /**
     * 配置缓存管理器
     */
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager();

        // 设置缓存名称
        cacheManager.setCacheNames(java.util.Arrays.asList(
            "manga-covers",
            "manga-pages",
            "manga-thumbnails",
            "library-scan",
            "file-info",
            "manga-metadata",
            "reading-progress",
            "manga-tags",
            "image-cache",
            "archive-entries"
        ));

        // 配置默认缓存
        cacheManager.setCaffeine(defaultCaffeineBuilder());

        return cacheManager;
    }

    /**
     * 默认Caffeine缓存构建器
     */
    private Caffeine<Object, Object> defaultCaffeineBuilder() {
        return Caffeine.newBuilder()
                .maximumSize(1000)
                .expireAfterWrite(30, TimeUnit.MINUTES)
                .expireAfterAccess(15, TimeUnit.MINUTES)
                .recordStats();
    }

    /**
     * 图像缓存构建器（较大容量，较长过期时间）
     */
    @Bean("imageCaffeine")
    public Caffeine<Object, Object> imageCaffeineBuilder() {
        return Caffeine.newBuilder()
                .maximumSize(500)
                .expireAfterWrite(2, TimeUnit.HOURS)
                .expireAfterAccess(1, TimeUnit.HOURS)
                .recordStats();
    }

    /**
     * 文件信息缓存构建器（中等容量，中等过期时间）
     */
    @Bean("fileInfoCaffeine")
    public Caffeine<Object, Object> fileInfoCaffeineBuilder() {
        return Caffeine.newBuilder()
                .maximumSize(2000)
                .expireAfterWrite(1, TimeUnit.HOURS)
                .expireAfterAccess(30, TimeUnit.MINUTES)
                .recordStats();
    }

    /**
     * 元数据缓存构建器（大容量，长过期时间）
     */
    @Bean("metadataCaffeine")
    public Caffeine<Object, Object> metadataCaffeineBuilder() {
        return Caffeine.newBuilder()
                .maximumSize(5000)
                .expireAfterWrite(6, TimeUnit.HOURS)
                .expireAfterAccess(3, TimeUnit.HOURS)
                .recordStats();
    }

    /**
     * 扫描结果缓存构建器（小容量，短过期时间）
     */
    @Bean("scanCaffeine")
    public Caffeine<Object, Object> scanCaffeineBuilder() {
        return Caffeine.newBuilder()
                .maximumSize(100)
                .expireAfterWrite(10, TimeUnit.MINUTES)
                .expireAfterAccess(5, TimeUnit.MINUTES)
                .recordStats();
    }
}
