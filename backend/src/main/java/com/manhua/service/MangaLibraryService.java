package com.manhua.service;

import com.manhua.entity.MangaLibrary;
import com.manhua.repository.MangaLibraryRepository;
import com.manhua.repository.MangaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.io.File;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 漫画库服务类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Service
@Transactional
public class MangaLibraryService {

    private static final Logger logger = LoggerFactory.getLogger(MangaLibraryService.class);

    @Autowired
    private MangaLibraryRepository libraryRepository;

    @Autowired
    private MangaRepository mangaRepository;

    /**
     * 获取所有漫画库
     */
    @Transactional(readOnly = true)
    public List<MangaLibrary> getAllLibraries() {
        return libraryRepository.findAll();
    }

    /**
     * 分页获取漫画库
     */
    @Transactional(readOnly = true)
    public Page<MangaLibrary> getLibraries(Pageable pageable) {
        return libraryRepository.findAll(pageable);
    }

    /**
     * 根据ID获取漫画库
     */
    @Transactional(readOnly = true)
    public Optional<MangaLibrary> getLibraryById(Long id) {
        return libraryRepository.findById(id);
    }

    /**
     * 根据名称获取漫画库
     */
    @Transactional(readOnly = true)
    public Optional<MangaLibrary> getLibraryByName(String name) {
        return libraryRepository.findByName(name);
    }

    /**
     * 根据路径获取漫画库
     */
    @Transactional(readOnly = true)
    public Optional<MangaLibrary> getLibraryByPath(String path) {
        return libraryRepository.findByPath(path);
    }

    /**
     * 获取所有激活的漫画库
     */
    @Transactional(readOnly = true)
    public List<MangaLibrary> getActiveLibraries() {
        return libraryRepository.findByIsActiveTrue();
    }

    /**
     * 获取当前漫画库
     */
    @Transactional(readOnly = true)
    public Optional<MangaLibrary> getCurrentLibrary() {
        return libraryRepository.findByIsCurrentTrue();
    }

    /**
     * 根据类型获取漫画库
     */
    @Transactional(readOnly = true)
    public List<MangaLibrary> getLibrariesByType(MangaLibrary.LibraryType type) {
        return libraryRepository.findByType(type);
    }

    /**
     * 创建漫画库
     */
    public MangaLibrary createLibrary(MangaLibrary library) {
        validateLibrary(library);

        // 检查名称是否已存在
        if (libraryRepository.findByName(library.getName()).isPresent()) {
            throw new IllegalArgumentException("漫画库名称已存在: " + library.getName());
        }

        // 检查路径是否已存在
        if (libraryRepository.findByPath(library.getPath()).isPresent()) {
            throw new IllegalArgumentException("漫画库路径已存在: " + library.getPath());
        }

        // 验证路径是否存在（仅对本地路径）
        if (library.getType() == MangaLibrary.LibraryType.LOCAL) {
            validateLocalPath(library.getPath());
        }

        // 设置默认值
        if (library.getIsActive() == null) {
            library.setIsActive(true);
        }
        if (library.getIsCurrent() == null) {
            library.setIsCurrent(false);
        }
        if (library.getAutoScan() == null) {
            library.setAutoScan(false);
        }
        if (library.getScanInterval() == null) {
            library.setScanInterval(24); // 默认24小时
        }
        if (library.getMangaCount() == null) {
            library.setMangaCount(0);
        }
        if (library.getTotalSize() == null) {
            library.setTotalSize(0L);
        }

        MangaLibrary savedLibrary = libraryRepository.save(library);
        logger.info("创建漫画库成功: {} (ID: {})", savedLibrary.getName(), savedLibrary.getId());

        return savedLibrary;
    }

    /**
     * 更新漫画库
     */
    public MangaLibrary updateLibrary(Long id, MangaLibrary updatedLibrary) {
        MangaLibrary existingLibrary = libraryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + id));

        // 检查名称是否与其他库冲突
        if (!existingLibrary.getName().equals(updatedLibrary.getName()) &&
            libraryRepository.existsByNameAndIdNot(updatedLibrary.getName(), id)) {
            throw new IllegalArgumentException("漫画库名称已存在: " + updatedLibrary.getName());
        }

        // 检查路径是否与其他库冲突
        if (!existingLibrary.getPath().equals(updatedLibrary.getPath()) &&
            libraryRepository.existsByPathAndIdNot(updatedLibrary.getPath(), id)) {
            throw new IllegalArgumentException("漫画库路径已存在: " + updatedLibrary.getPath());
        }

        // 验证新路径（仅对本地路径）
        if (updatedLibrary.getType() == MangaLibrary.LibraryType.LOCAL &&
            !existingLibrary.getPath().equals(updatedLibrary.getPath())) {
            validateLocalPath(updatedLibrary.getPath());
        }

        // 更新字段
        existingLibrary.setName(updatedLibrary.getName());
        existingLibrary.setDescription(updatedLibrary.getDescription());
        existingLibrary.setType(updatedLibrary.getType());
        existingLibrary.setPath(updatedLibrary.getPath());
        existingLibrary.setIsActive(updatedLibrary.getIsActive());
        existingLibrary.setAutoScan(updatedLibrary.getAutoScan());
        existingLibrary.setScanInterval(updatedLibrary.getScanInterval());

        // 更新网络文件系统配置
        if (updatedLibrary.getType() != MangaLibrary.LibraryType.LOCAL) {
            existingLibrary.setUsername(updatedLibrary.getUsername());
            existingLibrary.setPassword(updatedLibrary.getPassword());
            existingLibrary.setHost(updatedLibrary.getHost());
            existingLibrary.setPort(updatedLibrary.getPort());
            existingLibrary.setShareName(updatedLibrary.getShareName());
        }

        MangaLibrary savedLibrary = libraryRepository.save(existingLibrary);
        logger.info("更新漫画库成功: {} (ID: {})", savedLibrary.getName(), savedLibrary.getId());

        return savedLibrary;
    }

    /**
     * 删除漫画库
     */
    public void deleteLibrary(Long id) {
        MangaLibrary library = libraryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + id));

        // 删除相关的漫画记录
        long mangaCount = mangaRepository.countByLibraryId(id);
        if (mangaCount > 0) {
            mangaRepository.deleteByLibraryId(id);
            logger.info("删除漫画库 {} 中的 {} 个漫画记录", library.getName(), mangaCount);
        }

        libraryRepository.delete(library);
        logger.info("删除漫画库成功: {} (ID: {})", library.getName(), id);
    }

    /**
     * 设置当前漫画库
     */
    public void setCurrentLibrary(Long id) {
        if (!libraryRepository.existsById(id)) {
            throw new IllegalArgumentException("漫画库不存在: " + id);
        }

        libraryRepository.setCurrentLibrary(id);
        logger.info("设置当前漫画库: {}", id);
    }

    /**
     * 激活/停用漫画库
     */
    public void toggleLibraryStatus(Long id) {
        MangaLibrary library = libraryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + id));

        library.setIsActive(!library.getIsActive());
        libraryRepository.save(library);

        logger.info("漫画库 {} 状态变更为: {}", library.getName(),
                   library.getIsActive() ? "激活" : "停用");
    }

    /**
     * 更新漫画库统计信息
     */
    public void updateLibraryStatistics(Long id) {
        MangaLibrary library = libraryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + id));

        // 统计漫画数量
        long mangaCount = mangaRepository.countByLibraryId(id);

        // 统计总大小
        Long totalSize = mangaRepository.sumFileSizeByLibraryId(id);
        if (totalSize == null) {
            totalSize = 0L;
        }

        // 更新统计信息
        library.setMangaCount((int) mangaCount);
        library.setTotalSize(totalSize);

        libraryRepository.save(library);
        logger.info("更新漫画库 {} 统计信息: {} 个漫画, {} 字节",
                   library.getName(), mangaCount, totalSize);
    }

    /**
     * 更新最后扫描时间
     */
    public void updateLastScanTime(Long id) {
        libraryRepository.updateLastScanTime(id, LocalDateTime.now());
        logger.info("更新漫画库 {} 最后扫描时间", id);
    }

    /**
     * 获取需要自动扫描的漫画库
     */
    @Transactional(readOnly = true)
    public List<MangaLibrary> getLibrariesNeedingScan() {
        LocalDateTime threshold = LocalDateTime.now().minusHours(1); // 默认1小时间隔
        return libraryRepository.findLibrariesNeedingScan(threshold);
    }

    /**
     * 搜索漫画库
     */
    @Transactional(readOnly = true)
    public List<MangaLibrary> searchLibraries(String keyword) {
        if (!StringUtils.hasText(keyword)) {
            return getAllLibraries();
        }
        return libraryRepository.findByNameContainingIgnoreCase(keyword);
    }

    /**
     * 获取漫画库统计信息
     */
    @Transactional(readOnly = true)
    public List<Object[]> getLibraryStatistics() {
        return libraryRepository.getLibraryStatistics();
    }

    /**
     * 批量更新漫画库状态
     */
    public void updateLibrariesStatus(List<Long> ids, Boolean active) {
        libraryRepository.updateLibraryStatus(ids, active);
        logger.info("批量更新 {} 个漫画库状态为: {}", ids.size(), active ? "激活" : "停用");
    }

    /**
     * 清理非激活的漫画库
     */
    public void cleanupInactiveLibraries() {
        libraryRepository.deleteInactiveLibraries();
        logger.info("清理非激活漫画库完成");
    }

    /**
     * 验证漫画库信息
     */
    public void validateLibrary(MangaLibrary library) {
        if (!StringUtils.hasText(library.getName())) {
            throw new IllegalArgumentException("漫画库名称不能为空");
        }
        if (!StringUtils.hasText(library.getPath())) {
            throw new IllegalArgumentException("漫画库路径不能为空");
        }
        if (library.getType() == null) {
            throw new IllegalArgumentException("漫画库类型不能为空");
        }

        // 验证网络文件系统配置
        if (library.getType() != MangaLibrary.LibraryType.LOCAL) {
            if (!StringUtils.hasText(library.getHost())) {
                throw new IllegalArgumentException("网络文件系统主机地址不能为空");
            }
        }
    }

    /**
     * 验证本地路径
     */
    private void validateLocalPath(String path) {
        File file = new File(path);
        if (!file.exists()) {
            throw new IllegalArgumentException("路径不存在: " + path);
        }
        if (!file.isDirectory()) {
            throw new IllegalArgumentException("路径不是目录: " + path);
        }
        if (!file.canRead()) {
            throw new IllegalArgumentException("路径不可读: " + path);
        }
    }

    /**
     * 测试漫画库连接
     */
    public boolean testLibraryConnection(Long id) {
        try {
            MangaLibrary library= libraryRepository.findById(id)
                   .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + id));
            if (library.getType() == MangaLibrary.LibraryType.LOCAL) {
                validateLocalPath(library.getPath());
                return true;
            } else {
                // TODO: 实现网络文件系统连接测试
                logger.warn("网络文件系统连接测试尚未实现: {}", library.getType());
                return false;
            }
        } catch (Exception e) {
            logger.error("测试漫画库连接失败: {}", e.getMessage());
            return false;
        }
    }
}
