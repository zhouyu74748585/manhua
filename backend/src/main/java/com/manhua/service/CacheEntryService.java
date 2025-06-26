package com.manhua.service;

import com.manhua.dto.CacheEntryDTO;
import com.manhua.entity.CacheEntry;
import com.manhua.repository.CacheEntryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 缓存条目服务
 */
@Service
@Transactional
public class CacheEntryService {

    @Autowired
    private CacheEntryRepository cacheEntryRepository;

    @Value("${app.data-path}")
    private String dataPath;

    @Value("${app.cache.max-size:1024}")
    private long maxCacheSize; // MB

    @Value("${app.cache.expire-hours:24}")
    private int cacheExpireHours;

    /**
     * 获取所有缓存条目
     */
    @Transactional(readOnly = true)
    public List<CacheEntryDTO> getAllCacheEntries() {
        return cacheEntryRepository.findAll(Sort.by(Sort.Direction.DESC, "lastAccessTime"))
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 分页获取缓存条目
     */
    @Transactional(readOnly = true)
    public Page<CacheEntryDTO> getCacheEntries(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "lastAccessTime"));
        return cacheEntryRepository.findAll(pageable)
                .map(this::convertToDTO);
    }

    /**
     * 根据ID获取缓存条目
     */
    @Transactional(readOnly = true)
    public Optional<CacheEntryDTO> getCacheEntryById(Long id) {
        return cacheEntryRepository.findById(id)
                .map(this::convertToDTO);
    }

    /**
     * 根据缓存键获取缓存条目
     */
    @Transactional(readOnly = true)
    public Optional<CacheEntryDTO> getCacheEntryByKey(String cacheKey) {
        return cacheEntryRepository.findByCacheKey(cacheKey)
                .map(this::convertToDTO);
    }

    /**
     * 根据类型获取缓存条目
     */
    @Transactional(readOnly = true)
    public List<CacheEntryDTO> getCacheEntriesByType(String cacheType) {
        return cacheEntryRepository.findByCacheType(cacheType)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据漫画ID获取缓存条目
     */
    @Transactional(readOnly = true)
    public List<CacheEntryDTO> getCacheEntriesByComicId(Long comicId) {
        return cacheEntryRepository.findByComicId(comicId)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据MIME类型获取缓存条目
     */
    @Transactional(readOnly = true)
    public List<CacheEntryDTO> getCacheEntriesByMimeType(String mimeType) {
        return cacheEntryRepository.findByMimeType(mimeType)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取过期的缓存条目
     */
    @Transactional(readOnly = true)
    public List<CacheEntryDTO> getExpiredCacheEntries() {
        LocalDateTime now = LocalDateTime.now();
        return cacheEntryRepository.findByExpireTimeBefore(now)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据访问次数范围获取缓存条目
     */
    @Transactional(readOnly = true)
    public List<CacheEntryDTO> getCacheEntriesByAccessCount(int minCount, int maxCount) {
        return cacheEntryRepository.findByAccessCountBetween(minCount, maxCount)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据文件大小范围获取缓存条目
     */
    @Transactional(readOnly = true)
    public List<CacheEntryDTO> getCacheEntriesByFileSize(long minSize, long maxSize) {
        return cacheEntryRepository.findByFileSizeBetween(minSize, maxSize)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取需要清理的缓存条目
     */
    @Transactional(readOnly = true)
    public List<CacheEntryDTO> getCacheEntriesToCleanup(int limit) {
        return cacheEntryRepository.findForCleanup()
                .stream()
                .limit(limit)
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 创建缓存条目
     */
    public CacheEntryDTO createCacheEntry(CacheEntryDTO cacheEntryDTO) {
        // 检查缓存键是否已存在
        if (cacheEntryRepository.findByCacheKey(cacheEntryDTO.getCacheKey()).isPresent()) {
            throw new RuntimeException("缓存键已存在: " + cacheEntryDTO.getCacheKey());
        }
        
        CacheEntry cacheEntry = convertToEntity(cacheEntryDTO);
        
        // 设置默认值
        if (cacheEntry.getLastAccessTime() == null) {
            cacheEntry.setLastAccessTime(LocalDateTime.now());
        }
        if (cacheEntry.getAccessCount() == null) {
            cacheEntry.setAccessCount(0);
        }
        if (cacheEntry.getExpireTime() == null) {
            cacheEntry.setExpireTime(LocalDateTime.now().plusHours(cacheExpireHours));
        }
        
        CacheEntry savedEntry = cacheEntryRepository.save(cacheEntry);
        return convertToDTO(savedEntry);
    }

    /**
     * 更新缓存条目
     */
    public CacheEntryDTO updateCacheEntry(Long id, CacheEntryDTO cacheEntryDTO) {
        Optional<CacheEntry> existingEntry = cacheEntryRepository.findById(id);
        if (existingEntry.isPresent()) {
            CacheEntry cacheEntry = existingEntry.get();
            
            // 检查缓存键是否与其他记录冲突
            if (cacheEntryDTO.getCacheKey() != null && 
                !cacheEntryDTO.getCacheKey().equals(cacheEntry.getCacheKey())) {
                Optional<CacheEntry> conflictEntry = cacheEntryRepository.findByCacheKey(cacheEntryDTO.getCacheKey());
                if (conflictEntry.isPresent() && !conflictEntry.get().getId().equals(id)) {
                    throw new RuntimeException("缓存键已存在: " + cacheEntryDTO.getCacheKey());
                }
                cacheEntry.setCacheKey(cacheEntryDTO.getCacheKey());
            }
            
            if (cacheEntryDTO.getCacheType() != null) {
                cacheEntry.setCacheType(cacheEntryDTO.getCacheType());
            }
            if (cacheEntryDTO.getLocalPath() != null) {
                cacheEntry.setLocalPath(cacheEntryDTO.getLocalPath());
            }
            if (cacheEntryDTO.getOriginalPath() != null) {
                cacheEntry.setOriginalPath(cacheEntryDTO.getOriginalPath());
            }
            if (cacheEntryDTO.getFileSize() != null) {
                cacheEntry.setFileSize(cacheEntryDTO.getFileSize());
            }
            if (cacheEntryDTO.getMimeType() != null) {
                cacheEntry.setMimeType(cacheEntryDTO.getMimeType());
            }
            if (cacheEntryDTO.getComicId() != null) {
                cacheEntry.setComicId(cacheEntryDTO.getComicId());
            }
            if (cacheEntryDTO.getExpireTime() != null) {
                cacheEntry.setExpireTime(cacheEntryDTO.getExpireTime());
            }
            
            CacheEntry savedEntry = cacheEntryRepository.save(cacheEntry);
            return convertToDTO(savedEntry);
        }
        throw new RuntimeException("缓存条目不存在，ID: " + id);
    }

    /**
     * 更新访问信息
     */
    public void updateAccessInfo(String cacheKey) {
        Optional<CacheEntry> entry = cacheEntryRepository.findByCacheKey(cacheKey);
        if (entry.isPresent()) {
            cacheEntryRepository.updateAccessInfo(entry.get().getId(), LocalDateTime.now());
        }
    }

    /**
     * 删除缓存条目
     */
    public void deleteCacheEntry(Long id) {
        Optional<CacheEntry> existingEntry = cacheEntryRepository.findById(id);
        if (existingEntry.isPresent()) {
            CacheEntry cacheEntry = existingEntry.get();
            
            // 删除物理文件
            deletePhysicalFile(cacheEntry.getLocalPath());
            
            // 删除数据库记录
            cacheEntryRepository.deleteById(id);
        } else {
            throw new RuntimeException("缓存条目不存在，ID: " + id);
        }
    }

    /**
     * 根据缓存键删除缓存条目
     */
    public void deleteCacheEntryByKey(String cacheKey) {
        Optional<CacheEntry> existingEntry = cacheEntryRepository.findByCacheKey(cacheKey);
        if (existingEntry.isPresent()) {
            CacheEntry cacheEntry = existingEntry.get();
            
            // 删除物理文件
            deletePhysicalFile(cacheEntry.getLocalPath());
            
            // 删除数据库记录
            cacheEntryRepository.deleteByCacheKey(cacheKey);
        }
    }

    /**
     * 删除过期的缓存条目
     */
    public int deleteExpiredCacheEntries() {
        List<CacheEntry> expiredEntries = cacheEntryRepository.findByExpireTimeBefore(LocalDateTime.now());
        
        // 删除物理文件
        for (CacheEntry entry : expiredEntries) {
            deletePhysicalFile(entry.getLocalPath());
        }
        
        // 删除数据库记录
        return cacheEntryRepository.deleteExpiredEntries(LocalDateTime.now());
    }

    /**
     * 删除指定类型的缓存条目
     */
    public int deleteCacheEntriesByType(String cacheType) {
        List<CacheEntry> entries = cacheEntryRepository.findByCacheType(cacheType);
        
        // 删除物理文件
        for (CacheEntry entry : entries) {
            deletePhysicalFile(entry.getLocalPath());
        }
        
        // 删除数据库记录
        return cacheEntryRepository.deleteByCacheType(cacheType);
    }

    /**
     * 删除指定漫画的缓存条目
     */
    public int deleteCacheEntriesByComicId(Long comicId) {
        List<CacheEntry> entries = cacheEntryRepository.findByComicId(comicId);
        
        // 删除物理文件
        for (CacheEntry entry : entries) {
            deletePhysicalFile(entry.getLocalPath());
        }
        
        // 删除数据库记录
        return cacheEntryRepository.deleteByComicId(comicId);
    }

    /**
     * 清理缓存（删除最少使用的条目）
     */
    public int cleanupCache(int limit) {
        List<CacheEntry> entriesToCleanup = cacheEntryRepository.findForCleanup().stream().limit(limit).collect(Collectors.toList());
        
        // 删除物理文件
        for (CacheEntry entry : entriesToCleanup) {
            deletePhysicalFile(entry.getLocalPath());
        }
        
        // 删除数据库记录
        List<Long> ids = entriesToCleanup.stream().map(CacheEntry::getId).collect(Collectors.toList());
        cacheEntryRepository.deleteAllById(ids);
        
        return entriesToCleanup.size();
    }

    /**
     * 统计缓存条目总数
     */
    @Transactional(readOnly = true)
    public long countCacheEntries() {
        return cacheEntryRepository.countAllEntries();
    }

    /**
     * 统计各类型缓存条目数量
     */
    @Transactional(readOnly = true)
    public List<Object[]> countCacheEntriesByType() {
        return cacheEntryRepository.countByCacheType();
    }

    /**
     * 统计缓存总大小
     */
    @Transactional(readOnly = true)
    public long getTotalCacheSize() {
        Long totalSize = cacheEntryRepository.sumTotalCacheSize();
        return totalSize != null ? totalSize : 0L;
    }

    /**
     * 按类型统计缓存大小
     */
    @Transactional(readOnly = true)
    public List<Object[]> getCacheSizeByType() {
        return cacheEntryRepository.sumCacheSizeByType();
    }

    /**
     * 检查缓存是否需要清理
     */
    @Transactional(readOnly = true)
    public boolean needsCleanup() {
        long totalSizeMB = getTotalCacheSize() / (1024 * 1024);
        return totalSizeMB > maxCacheSize;
    }

    /**
     * 删除物理文件
     */
    private void deletePhysicalFile(String filePath) {
        if (filePath != null && !filePath.isEmpty()) {
            try {
                Path path = Paths.get(filePath);
                if (Files.exists(path)) {
                    Files.delete(path);
                }
            } catch (Exception e) {
                // 记录日志但不抛出异常，避免影响数据库操作
                System.err.println("Failed to delete cache file: " + filePath + ", error: " + e.getMessage());
            }
        }
    }

    /**
     * 实体转DTO
     */
    private CacheEntryDTO convertToDTO(CacheEntry cacheEntry) {
        CacheEntryDTO dto = new CacheEntryDTO();
        dto.setId(cacheEntry.getId());
        dto.setCacheKey(cacheEntry.getCacheKey());
        dto.setCacheType(cacheEntry.getCacheType());
        dto.setLocalPath(cacheEntry.getLocalPath());
        dto.setOriginalPath(cacheEntry.getOriginalPath());
        dto.setFileSize(cacheEntry.getFileSize());
        dto.setMimeType(cacheEntry.getMimeType());
        dto.setComicId(cacheEntry.getComicId());
        dto.setCreateTime(cacheEntry.getCreateTime());
        dto.setUpdateTime(cacheEntry.getUpdateTime());
        dto.setLastAccessTime(cacheEntry.getLastAccessTime());
        dto.setAccessCount(cacheEntry.getAccessCount());
        dto.setExpireTime(cacheEntry.getExpireTime());
        return dto;
    }

    /**
     * DTO转实体
     */
    private CacheEntry convertToEntity(CacheEntryDTO dto) {
        CacheEntry cacheEntry = new CacheEntry();
        cacheEntry.setCacheKey(dto.getCacheKey());
        cacheEntry.setCacheType(dto.getCacheType());
        cacheEntry.setLocalPath(dto.getLocalPath());
        cacheEntry.setOriginalPath(dto.getOriginalPath());
        cacheEntry.setFileSize(dto.getFileSize());
        cacheEntry.setMimeType(dto.getMimeType());
        cacheEntry.setComicId(dto.getComicId());
        cacheEntry.setLastAccessTime(dto.getLastAccessTime());
        cacheEntry.setAccessCount(dto.getAccessCount());
        cacheEntry.setExpireTime(dto.getExpireTime());
        return cacheEntry;
    }
}