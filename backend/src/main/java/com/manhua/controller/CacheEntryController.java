package com.manhua.controller;

import com.manhua.common.ApiResponse;
import com.manhua.dto.CacheEntryDTO;
import com.manhua.service.CacheEntryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 缓存条目控制器
 */
@RestController
@RequestMapping("/api/cache-entries")
@CrossOrigin(origins = "*")
public class CacheEntryController {

    @Autowired
    private CacheEntryService cacheEntryService;

    /**
     * 获取所有缓存条目
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<CacheEntryDTO>>> getAllCacheEntries() {
        try {
            List<CacheEntryDTO> entries = cacheEntryService.getAllCacheEntries();
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 分页获取缓存条目
     */
    @GetMapping("/page")
    public ResponseEntity<ApiResponse<Page<CacheEntryDTO>>> getCacheEntries(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Page<CacheEntryDTO> entries = cacheEntryService.getCacheEntries(page, size);
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 根据ID获取缓存条目
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CacheEntryDTO>> getCacheEntryById(@PathVariable Long id) {
        try {
            Optional<CacheEntryDTO> entry = cacheEntryService.getCacheEntryById(id);
            if (entry.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(entry.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 根据缓存键获取缓存条目
     */
    @GetMapping("/key/{cacheKey}")
    public ResponseEntity<ApiResponse<CacheEntryDTO>> getCacheEntryByKey(@PathVariable String cacheKey) {
        try {
            Optional<CacheEntryDTO> entry = cacheEntryService.getCacheEntryByKey(cacheKey);
            if (entry.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(entry.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 根据类型获取缓存条目
     */
    @GetMapping("/type/{cacheType}")
    public ResponseEntity<ApiResponse<List<CacheEntryDTO>>> getCacheEntriesByType(@PathVariable String cacheType) {
        try {
            List<CacheEntryDTO> entries = cacheEntryService.getCacheEntriesByType(cacheType);
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 根据漫画ID获取缓存条目
     */
    @GetMapping("/comic/{comicId}")
    public ResponseEntity<ApiResponse<List<CacheEntryDTO>>> getCacheEntriesByComicId(@PathVariable Long comicId) {
        try {
            List<CacheEntryDTO> entries = cacheEntryService.getCacheEntriesByComicId(comicId);
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 根据MIME类型获取缓存条目
     */
    @GetMapping("/mime-type")
    public ResponseEntity<ApiResponse<List<CacheEntryDTO>>> getCacheEntriesByMimeType(@RequestParam String mimeType) {
        try {
            List<CacheEntryDTO> entries = cacheEntryService.getCacheEntriesByMimeType(mimeType);
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 获取过期的缓存条目
     */
    @GetMapping("/expired")
    public ResponseEntity<ApiResponse<List<CacheEntryDTO>>> getExpiredCacheEntries() {
        try {
            List<CacheEntryDTO> entries = cacheEntryService.getExpiredCacheEntries();
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取过期缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 根据访问次数范围获取缓存条目
     */
    @GetMapping("/access-count")
    public ResponseEntity<ApiResponse<List<CacheEntryDTO>>> getCacheEntriesByAccessCount(
            @RequestParam int minCount,
            @RequestParam int maxCount) {
        try {
            List<CacheEntryDTO> entries = cacheEntryService.getCacheEntriesByAccessCount(minCount, maxCount);
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 根据文件大小范围获取缓存条目
     */
    @GetMapping("/file-size")
    public ResponseEntity<ApiResponse<List<CacheEntryDTO>>> getCacheEntriesByFileSize(
            @RequestParam long minSize,
            @RequestParam long maxSize) {
        try {
            List<CacheEntryDTO> entries = cacheEntryService.getCacheEntriesByFileSize(minSize, maxSize);
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 获取需要清理的缓存条目
     */
    @GetMapping("/cleanup-candidates")
    public ResponseEntity<ApiResponse<List<CacheEntryDTO>>> getCacheEntriesToCleanup(
            @RequestParam(defaultValue = "100") int limit) {
        try {
            List<CacheEntryDTO> entries = cacheEntryService.getCacheEntriesToCleanup(limit);
            return ResponseEntity.ok(ApiResponse.success(entries));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取待清理缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 创建缓存条目
     */
    @PostMapping
    public ResponseEntity<ApiResponse<CacheEntryDTO>> createCacheEntry(@Valid @RequestBody CacheEntryDTO cacheEntryDTO) {
        try {
            CacheEntryDTO createdEntry = cacheEntryService.createCacheEntry(cacheEntryDTO);
            return ResponseEntity.ok(ApiResponse.success(createdEntry));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("创建缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 更新缓存条目
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CacheEntryDTO>> updateCacheEntry(
            @PathVariable Long id,
            @Valid @RequestBody CacheEntryDTO cacheEntryDTO) {
        try {
            CacheEntryDTO updatedEntry = cacheEntryService.updateCacheEntry(id, cacheEntryDTO);
            return ResponseEntity.ok(ApiResponse.success(updatedEntry));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("更新缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 更新访问信息
     */
    @PutMapping("/access/{cacheKey}")
    public ResponseEntity<ApiResponse<Void>> updateAccessInfo(@PathVariable String cacheKey) {
        try {
            cacheEntryService.updateAccessInfo(cacheKey);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("更新访问信息失败: " + e.getMessage()));
        }
    }

    /**
     * 删除缓存条目
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCacheEntry(@PathVariable Long id) {
        try {
            cacheEntryService.deleteCacheEntry(id);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 根据缓存键删除缓存条目
     */
    @DeleteMapping("/key/{cacheKey}")
    public ResponseEntity<ApiResponse<Void>> deleteCacheEntryByKey(@PathVariable String cacheKey) {
        try {
            cacheEntryService.deleteCacheEntryByKey(cacheKey);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 删除过期的缓存条目
     */
    @DeleteMapping("/expired")
    public ResponseEntity<ApiResponse<Map<String, Object>>> deleteExpiredCacheEntries() {
        try {
            int deletedCount = cacheEntryService.deleteExpiredCacheEntries();
            Map<String, Object> result = new HashMap<>();
            result.put("deletedCount", deletedCount);
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除过期缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 删除指定类型的缓存条目
     */
    @DeleteMapping("/type/{cacheType}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> deleteCacheEntriesByType(@PathVariable String cacheType) {
        try {
            int deletedCount = cacheEntryService.deleteCacheEntriesByType(cacheType);
            Map<String, Object> result = new HashMap<>();
            result.put("deletedCount", deletedCount);
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 删除指定漫画的缓存条目
     */
    @DeleteMapping("/comic/{comicId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> deleteCacheEntriesByComicId(@PathVariable Long comicId) {
        try {
            int deletedCount = cacheEntryService.deleteCacheEntriesByComicId(comicId);
            Map<String, Object> result = new HashMap<>();
            result.put("deletedCount", deletedCount);
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除缓存条目失败: " + e.getMessage()));
        }
    }

    /**
     * 清理缓存（删除最少使用的条目）
     */
    @DeleteMapping("/cleanup")
    public ResponseEntity<ApiResponse<Map<String, Object>>> cleanupCache(
            @RequestParam(defaultValue = "100") int limit) {
        try {
            int deletedCount = cacheEntryService.cleanupCache(limit);
            Map<String, Object> result = new HashMap<>();
            result.put("deletedCount", deletedCount);
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("清理缓存失败: " + e.getMessage()));
        }
    }

    /**
     * 获取统计信息
     */
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStatistics() {
        try {
            Map<String, Object> statistics = new HashMap<>();
            
            // 统计缓存条目总数
            long totalCount = cacheEntryService.countCacheEntries();
            statistics.put("totalCount", totalCount);
            
            // 统计各类型缓存条目数量
            List<Object[]> typeStats = cacheEntryService.countCacheEntriesByType();
            statistics.put("typeStatistics", typeStats);
            
            // 统计缓存总大小
            long totalSize = cacheEntryService.getTotalCacheSize();
            statistics.put("totalSize", totalSize);
            statistics.put("totalSizeMB", totalSize / (1024 * 1024));
            
            // 按类型统计缓存大小
            List<Object[]> sizeStats = cacheEntryService.getCacheSizeByType();
            statistics.put("sizeStatistics", sizeStats);
            
            // 检查是否需要清理
            boolean needsCleanup = cacheEntryService.needsCleanup();
            statistics.put("needsCleanup", needsCleanup);
            
            return ResponseEntity.ok(ApiResponse.success(statistics));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取统计信息失败: " + e.getMessage()));
        }
    }

    /**
     * 检查缓存状态
     */
    @GetMapping("/status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getCacheStatus() {
        try {
            Map<String, Object> status = new HashMap<>();
            
            // 缓存总大小
            long totalSize = cacheEntryService.getTotalCacheSize();
            status.put("totalSize", totalSize);
            status.put("totalSizeMB", totalSize / (1024 * 1024));
            
            // 缓存条目总数
            long totalCount = cacheEntryService.countCacheEntries();
            status.put("totalCount", totalCount);
            
            // 过期条目数量
            List<CacheEntryDTO> expiredEntries = cacheEntryService.getExpiredCacheEntries();
            status.put("expiredCount", expiredEntries.size());
            
            // 是否需要清理
            boolean needsCleanup = cacheEntryService.needsCleanup();
            status.put("needsCleanup", needsCleanup);
            
            return ResponseEntity.ok(ApiResponse.success(status));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取缓存状态失败: " + e.getMessage()));
        }
    }
}