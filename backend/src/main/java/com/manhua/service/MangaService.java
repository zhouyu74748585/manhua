package com.manhua.service;

import com.manhua.entity.Manga;
import com.manhua.entity.MangaLibrary;
import com.manhua.entity.ReadingProgress;
import com.manhua.repository.MangaLibraryRepository;
import com.manhua.repository.MangaRepository;
import com.manhua.repository.ReadingProgressRepository;
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
 * 漫画服务类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Service
@Transactional
public class MangaService {

    private static final Logger logger = LoggerFactory.getLogger(MangaService.class);

    @Autowired
    private MangaRepository mangaRepository;

    @Autowired
    private MangaLibraryRepository libraryRepository;

    @Autowired
    private ReadingProgressRepository progressRepository;

    /**
     * 获取所有漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getAllManga() {
        return mangaRepository.findAll();
    }

    /**
     * 分页获取漫画
     */
    @Transactional(readOnly = true)
    public Page<Manga> getManga(Pageable pageable) {
        return mangaRepository.findAll(pageable);
    }

    /**
     * 根据ID获取漫画
     */
    @Transactional(readOnly = true)
    public Optional<Manga> getMangaById(Long id) {
        return mangaRepository.findById(id);
    }

    /**
     * 根据标题获取漫画
     */
    @Transactional(readOnly = true)
    public Optional<Manga> getMangaByTitle(String title) {
        return mangaRepository.findByTitle(title);
    }

    /**
     * 根据文件路径获取漫画
     */
    @Transactional(readOnly = true)
    public Optional<Manga> getMangaByFilePath(String filePath) {
        return mangaRepository.findByFilePath(filePath);
    }

    /**
     * 根据漫画库获取漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getMangaByLibrary(Long libraryId) {
        return mangaRepository.findByLibraryId(libraryId);
    }

    /**
     * 分页获取指定漫画库的漫画
     */
    @Transactional(readOnly = true)
    public Page<Manga> getMangaByLibrary(Long libraryId, Pageable pageable) {
        return mangaRepository.findByLibraryId(libraryId, pageable);
    }

    /**
     * 根据作者搜索漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getMangaByAuthor(String author) {
        return mangaRepository.findByAuthorContainingIgnoreCase(author);
    }

    /**
     * 根据类型搜索漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getMangaByGenre(String genre) {
        return mangaRepository.findByGenreContainingIgnoreCase(genre);
    }

    /**
     * 根据状态获取漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getMangaByStatus(Manga.MangaStatus status) {
        return mangaRepository.findByStatus(status);
    }

    /**
     * 获取最近阅读的漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getRecentlyReadManga(Pageable pageable) {
        return mangaRepository.findRecentlyRead(pageable);
    }

    /**
     * 获取最近添加的漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getRecentlyAddedManga() {
        return mangaRepository.findTop10ByOrderByCreatedAtDesc();
    }

    /**
     * 获取高评分漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getHighRatedManga(Double minRating, Pageable pageable) {
        return mangaRepository.findHighRatedManga(minRating, pageable);
    }

    /**
     * 获取未完成的漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getUnfinishedManga(Pageable pageable) {
        return mangaRepository.findUnfinishedManga(pageable);
    }

    /**
     * 创建漫画
     */
    public Manga createManga(Manga manga) {
        validateManga(manga);

        // 检查文件路径是否已存在
        if (mangaRepository.existsByFilePath(manga.getFilePath())) {
            throw new IllegalArgumentException("漫画文件已存在: " + manga.getFilePath());
        }

        // 验证漫画库是否存在
        MangaLibrary library = libraryRepository.findById(manga.getLibrary().getId())
                .orElseThrow(() -> new IllegalArgumentException("漫画库不存在: " + manga.getLibrary().getId()));

        manga.setLibrary(library);

        // 设置默认值
        if (manga.getStatus() == null) {
            manga.setStatus(Manga.MangaStatus.UNREAD);
        }
        if (manga.getRating() == null) {
            manga.setRating(0.0);
        }
        if (manga.getTotalPages() == null) {
            manga.setTotalPages(0);
        }
        if (manga.getFileSize() == null) {
            manga.setFileSize(0L);
        }

        // 尝试从文件获取信息
        enrichMangaFromFile(manga);

        Manga savedManga = mangaRepository.save(manga);

        // 创建初始阅读进度
        createInitialReadingProgress(savedManga);

        logger.info("创建漫画成功: {} (ID: {})", savedManga.getTitle(), savedManga.getId());

        return savedManga;
    }

    /**
     * 更新漫画
     */
    public Manga updateManga(Long id, Manga updatedManga) {
        Manga existingManga = mangaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("漫画不存在: " + id));

        // 检查文件路径是否与其他漫画冲突
        if (!existingManga.getFilePath().equals(updatedManga.getFilePath()) &&
            mangaRepository.existsByFilePath(updatedManga.getFilePath())) {
            throw new IllegalArgumentException("漫画文件已存在: " + updatedManga.getFilePath());
        }

        // 更新字段
        existingManga.setTitle(updatedManga.getTitle());
        existingManga.setAuthor(updatedManga.getAuthor());
        existingManga.setDescription(updatedManga.getDescription());
        existingManga.setGenre(updatedManga.getGenre());
        existingManga.setFilePath(updatedManga.getFilePath());
        existingManga.setFileSize(updatedManga.getFileSize());
        existingManga.setTotalPages(updatedManga.getTotalPages());
        existingManga.setCoverImage(updatedManga.getCoverImage());
        existingManga.setRating(updatedManga.getRating());
        existingManga.setStatus(updatedManga.getStatus());
        existingManga.setReadingDirection(updatedManga.getReadingDirection());

        Manga savedManga = mangaRepository.save(existingManga);
        logger.info("更新漫画成功: {} (ID: {})", savedManga.getTitle(), savedManga.getId());

        return savedManga;
    }

    /**
     * 删除漫画
     */
    public void deleteManga(Long id) {
        Manga manga = mangaRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("漫画不存在: " + id));

        // 删除相关的阅读进度
        progressRepository.deleteByMangaId(id);

        mangaRepository.delete(manga);
        logger.info("删除漫画成功: {} (ID: {})", manga.getTitle(), id);
    }

    /**
     * 更新漫画评分
     */
    public void updateMangaRating(Long id, Double rating) {
        if (rating < 0.0 || rating > 5.0) {
            throw new IllegalArgumentException("评分必须在0-5之间");
        }

        mangaRepository.updateRating(id, rating);
        logger.info("更新漫画 {} 评分为: {}", id, rating);
    }

    /**
     * 更新漫画状态
     */
    public void updateMangaStatus(Long id, Manga.MangaStatus status) {
        mangaRepository.updateStatus(id, status);

        // 如果标记为已完成，更新完成时间
        if (status == Manga.MangaStatus.COMPLETED) {
            Manga manga = mangaRepository.findById(id).orElse(null);
            if (manga != null) {
                manga.setCompletedAt(LocalDateTime.now());
                mangaRepository.save(manga);
            }
        }

        logger.info("更新漫画 {} 状态为: {}", id, status);
    }

    /**
     * 更新最后阅读时间
     */
    public void updateLastReadTime(Long id) {
        mangaRepository.updateLastReadTime(id, LocalDateTime.now());
        logger.info("更新漫画 {} 最后阅读时间", id);
    }

    /**
     * 搜索漫画
     */
    @Transactional(readOnly = true)
    public Page<Manga> searchManga(String keyword, Pageable pageable) {
        if (!StringUtils.hasText(keyword)) {
            return mangaRepository.findAll(pageable);
        }
        return mangaRepository.searchManga(keyword, pageable);
    }

    /**
     * 在指定漫画库中搜索漫画
     */
    @Transactional(readOnly = true)
    public Page<Manga> searchMangaInLibrary(Long libraryId, String keyword, Pageable pageable) {
        if (!StringUtils.hasText(keyword)) {
            return mangaRepository.findByLibraryId(libraryId, pageable);
        }
        return mangaRepository.searchMangaInLibrary(libraryId, keyword, pageable);
    }

    /**
     * 查找相似漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> findSimilarManga(Long mangaId, Pageable pageable) {
        Manga manga = mangaRepository.findById(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("漫画不存在: " + mangaId));

        return mangaRepository.findSimilarManga(mangaId,
                manga.getAuthor() != null ? manga.getAuthor() : "",
                manga.getGenre() != null ? manga.getGenre() : "",
                pageable);
    }

    /**
     * 获取随机漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getRandomManga(int limit) {
        return mangaRepository.findRandomManga(limit);
    }

    /**
     * 获取热门漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> getPopularManga(Pageable pageable) {
        return mangaRepository.findPopularManga(pageable);
    }

    /**
     * 获取漫画统计信息
     */
    @Transactional(readOnly = true)
    public List<Object[]> getMangaStatistics() {
        return mangaRepository.getMangaStatistics();
    }

    /**
     * 获取指定漫画库的统计信息
     */
    @Transactional(readOnly = true)
    public List<Object[]> getMangaStatisticsByLibrary(Long libraryId) {
        return mangaRepository.getMangaStatisticsByLibrary(libraryId);
    }

    /**
     * 查找重复的漫画
     */
    @Transactional(readOnly = true)
    public List<Manga> findDuplicateManga() {
        return mangaRepository.findDuplicateManga();
    }

    /**
     * 查找孤立的漫画（文件不存在）
     */
    @Transactional(readOnly = true)
    public List<Manga> findOrphanedManga(Long libraryId) {
        return mangaRepository.findOrphanedManga(libraryId);
    }

    /**
     * 批量导入漫画
     */
    public List<Manga> batchImportManga(List<Manga> mangaList) {
        List<Manga> savedMangaList = mangaRepository.saveAll(mangaList);

        // 为每个漫画创建初始阅读进度
        for (Manga manga : savedMangaList) {
            createInitialReadingProgress(manga);
        }

        logger.info("批量导入 {} 个漫画", savedMangaList.size());
        return savedMangaList;
    }

    /**
     * 验证漫画信息
     */
    private void validateManga(Manga manga) {
        if (!StringUtils.hasText(manga.getTitle())) {
            throw new IllegalArgumentException("漫画标题不能为空");
        }
        if (!StringUtils.hasText(manga.getFilePath())) {
            throw new IllegalArgumentException("漫画文件路径不能为空");
        }
        if (manga.getLibrary() == null || manga.getLibrary().getId() == null) {
            throw new IllegalArgumentException("漫画库不能为空");
        }
    }

    /**
     * 从文件中获取漫画信息
     */
    private void enrichMangaFromFile(Manga manga) {
        try {
            File file = new File(manga.getFilePath());
            if (file.exists()) {
                // 设置文件大小
                if (manga.getFileSize() == null || manga.getFileSize() == 0) {
                    manga.setFileSize(file.length());
                }

                // 如果标题为空，使用文件名
                if (!StringUtils.hasText(manga.getTitle())) {
                    String fileName = file.getName();
                    int lastDotIndex = fileName.lastIndexOf('.');
                    if (lastDotIndex > 0) {
                        fileName = fileName.substring(0, lastDotIndex);
                    }
                    manga.setTitle(fileName);
                }

                // TODO: 实现从压缩文件中提取页数和封面
                // 这里可以添加解析压缩文件的逻辑
            }
        } catch (Exception e) {
            logger.warn("从文件获取漫画信息失败: {}", e.getMessage());
        }
    }

    /**
     * 创建初始阅读进度
     */
    private void createInitialReadingProgress(Manga manga) {
        try {
            // 检查是否已存在阅读进度
            if (progressRepository.findByMangaId(manga.getId()).isPresent()) {
                return;
            }

            ReadingProgress progress = new ReadingProgress();
            progress.setManga(manga);
            progress.setCurrentPage(1);
            progress.setTotalPages(manga.getTotalPages() != null ? manga.getTotalPages() : 0);
            progress.setReadingTime(0L);
            progress.setReadingSpeed(0.0);

            progressRepository.save(progress);
            logger.debug("为漫画 {} 创建初始阅读进度", manga.getTitle());
        } catch (Exception e) {
            logger.error("创建初始阅读进度失败: {}", e.getMessage());
        }
    }
}
