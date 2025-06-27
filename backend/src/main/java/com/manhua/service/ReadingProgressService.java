package com.manhua.service;

import com.manhua.entity.ReadingProgress;
import com.manhua.entity.Manga;
import com.manhua.repository.ReadingProgressRepository;
import com.manhua.repository.MangaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 阅读进度服务类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Service
@Transactional
public class ReadingProgressService {

    private static final Logger logger = LoggerFactory.getLogger(ReadingProgressService.class);

    @Autowired
    private ReadingProgressRepository progressRepository;

    @Autowired
    private MangaRepository mangaRepository;

    /**
     * 获取所有阅读进度
     */
    @Transactional(readOnly = true)
    public List<ReadingProgress> getAllProgress() {
        return progressRepository.findAll();
    }

    /**
     * 根据ID获取阅读进度
     */
    @Transactional(readOnly = true)
    public Optional<ReadingProgress> getProgressById(Long id) {
        return progressRepository.findById(id);
    }

    /**
     * 根据漫画ID获取阅读进度
     */
    @Transactional(readOnly = true)
    public Optional<ReadingProgress> getProgressByMangaId(Long mangaId) {
        return progressRepository.findByMangaId(mangaId);
    }

    /**
     * 获取最近阅读的进度记录
     */
    @Transactional(readOnly = true)
    public List<ReadingProgress> getRecentlyReadProgress(Pageable pageable) {
        return progressRepository.findRecentlyRead(pageable);
    }

    /**
     * 获取已完成的漫画进度
     */
    @Transactional(readOnly = true)
    public List<ReadingProgress> getCompletedProgress() {
        return progressRepository.findCompletedProgress();
    }

    /**
     * 获取进行中的漫画进度
     */
    @Transactional(readOnly = true)
    public List<ReadingProgress> getInProgressManga() {
        return progressRepository.findInProgressManga();
    }

    /**
     * 更新阅读进度
     */
    public ReadingProgress updateProgress(Long mangaId, Integer currentPage) {
        ReadingProgress progress = progressRepository.findByMangaId(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("阅读进度不存在: " + mangaId));

        // 验证页数
        if (currentPage < 0) {
            throw new IllegalArgumentException("当前页数不能小于0");
        }
        if (progress.getTotalPages() > 0 && currentPage > progress.getTotalPages()) {
            throw new IllegalArgumentException("当前页数不能大于总页数");
        }

        Integer oldPage = progress.getCurrentPage();
        progress.setCurrentPage(currentPage);
        progress.setLastReadAt(LocalDateTime.now());

        // 更新漫画的最后阅读时间
        mangaRepository.updateLastReadTime(mangaId, LocalDateTime.now());

        // 如果是第一次阅读，更新漫画状态
        if (oldPage == 0 && currentPage > 0) {
            mangaRepository.updateStatus(mangaId, Manga.MangaStatus.READING);
        }

        // 如果完成阅读，更新漫画状态
        if (progress.getTotalPages() > 0 && currentPage >= progress.getTotalPages()) {
            mangaRepository.updateStatus(mangaId, Manga.MangaStatus.COMPLETED);

            // 更新漫画完成时间
            Manga manga = mangaRepository.findById(mangaId).orElse(null);
            if (manga != null) {
                manga.setCompletedAt(LocalDateTime.now());
                mangaRepository.save(manga);
            }
        }

        ReadingProgress savedProgress = progressRepository.save(progress);
        logger.info("更新漫画 {} 阅读进度: {} / {}", mangaId, currentPage, progress.getTotalPages());

        return savedProgress;
    }

    /**
     * 开始阅读会话
     */
    public ReadingProgress startReadingSession(Long mangaId) {
        ReadingProgress progress = progressRepository.findByMangaId(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("阅读进度不存在: " + mangaId));

        progress.setSessionStart(LocalDateTime.now());
        progress.setLastReadAt(LocalDateTime.now());

        ReadingProgress savedProgress = progressRepository.save(progress);
        logger.info("开始漫画 {} 阅读会话", mangaId);

        return savedProgress;
    }

    /**
     * 结束阅读会话
     */
    public ReadingProgress endReadingSession(Long mangaId) {
        ReadingProgress progress = progressRepository.findByMangaId(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("阅读进度不存在: " + mangaId));

        if (progress.getSessionStart() != null) {
            LocalDateTime endTime = LocalDateTime.now();
            progress.setSessionEnd(endTime);

            // 计算本次会话阅读时间（分钟）
            long sessionTime = ChronoUnit.MINUTES.between(progress.getSessionStart(), endTime);
            if (sessionTime > 0) {
                progress.setReadingTime(progress.getReadingTime() + sessionTime);

                // 计算阅读速度（页/分钟）
                if (progress.getReadingTime() > 0) {
                    double speed = (double) progress.getCurrentPage() / progress.getReadingTime();
                    progress.setReadingSpeed(speed);
                }
            }
        }

        ReadingProgress savedProgress = progressRepository.save(progress);
        logger.info("结束漫画 {} 阅读会话", mangaId);

        return savedProgress;
    }

    /**
     * 重置阅读进度
     */
    public void resetProgress(Long mangaId) {
        progressRepository.resetProgress(mangaId);
        mangaRepository.updateStatus(mangaId, Manga.MangaStatus.UNREAD);

        logger.info("重置漫画 {} 阅读进度", mangaId);
    }

    /**
     * 标记为已完成
     */
    public void markAsCompleted(Long mangaId) {
        progressRepository.markAsCompleted(mangaId);
        mangaRepository.updateStatus(mangaId, Manga.MangaStatus.COMPLETED);

        // 更新漫画完成时间
        Manga manga = mangaRepository.findById(mangaId).orElse(null);
        if (manga != null) {
            manga.setCompletedAt(LocalDateTime.now());
            mangaRepository.save(manga);
        }

        logger.info("标记漫画 {} 为已完成", mangaId);
    }

    /**
     * 添加书签
     */
    public ReadingProgress addBookmark(Long mangaId, Integer page) {
        ReadingProgress progress = progressRepository.findByMangaId(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("阅读进度不存在: " + mangaId));

        // 验证页数
        if (page < 1 || (progress.getTotalPages() > 0 && page > progress.getTotalPages())) {
            throw new IllegalArgumentException("书签页数无效: " + page);
        }

        // 获取现有书签
        List<Integer> bookmarks = getBookmarkPages(progress);

        // 添加新书签（如果不存在）
        if (!bookmarks.contains(page)) {
            bookmarks.add(page);
            bookmarks.sort(Integer::compareTo);

            // 保存书签
            String bookmarkStr = bookmarks.stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining(","));
            progress.setBookmarkPages(bookmarkStr);

            ReadingProgress savedProgress = progressRepository.save(progress);
            logger.info("为漫画 {} 添加书签: 第 {} 页", mangaId, page);

            return savedProgress;
        }

        return progress;
    }

    /**
     * 移除书签
     */
    public ReadingProgress removeBookmark(Long mangaId, Integer page) {
        ReadingProgress progress = progressRepository.findByMangaId(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("阅读进度不存在: " + mangaId));

        // 获取现有书签
        List<Integer> bookmarks = getBookmarkPages(progress);

        // 移除书签
        if (bookmarks.remove(page)) {
            // 保存书签
            String bookmarkStr = bookmarks.stream()
                    .map(String::valueOf)
                    .collect(Collectors.joining(","));
            progress.setBookmarkPages(bookmarkStr.isEmpty() ? null : bookmarkStr);

            ReadingProgress savedProgress = progressRepository.save(progress);
            logger.info("为漫画 {} 移除书签: 第 {} 页", mangaId, page);

            return savedProgress;
        }

        return progress;
    }

    /**
     * 获取书签页列表
     */
    @Transactional(readOnly = true)
    public List<Integer> getBookmarks(Long mangaId) {
        ReadingProgress progress = progressRepository.findByMangaId(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("阅读进度不存在: " + mangaId));

        return getBookmarkPages(progress);
    }

    /**
     * 更新笔记
     */
    public ReadingProgress updateNotes(Long mangaId, String notes) {
        ReadingProgress progress = progressRepository.findByMangaId(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("阅读进度不存在: " + mangaId));

        progress.setNotes(notes);

        ReadingProgress savedProgress = progressRepository.save(progress);
        logger.info("更新漫画 {} 笔记", mangaId);

        return savedProgress;
    }

    /**
     * 创建阅读进度
     */
    public ReadingProgress createProgress(ReadingProgress readingProgress) {
        // 检查是否已存在
        if (progressRepository.findByMangaId(readingProgress.getManga().getId()).isPresent()) {
            throw new IllegalArgumentException("阅读进度已存在: " + readingProgress.getManga().getId());
        }

        mangaRepository.findById(readingProgress.getManga().getId())
                .orElseThrow(() -> new IllegalArgumentException("漫画不存在: " + readingProgress.getManga().getId()));

        ReadingProgress savedProgress = progressRepository.save(readingProgress);
        logger.info("为漫画 {} 创建阅读进度", readingProgress.getManga().getId());

        return savedProgress;
    }

    /**
     * 删除阅读进度
     */
    public void deleteProgress(Long mangaId) {
        progressRepository.deleteByMangaId(mangaId);
        logger.info("删除漫画 {} 的阅读进度", mangaId);
    }


    /**
     * 解析书签页列表
     */
    private List<Integer> getBookmarkPages(ReadingProgress progress) {
        if (!StringUtils.hasText(progress.getBookmarkPages())) {
            return List.of();
        }

        try {
            return Arrays.stream(progress.getBookmarkPages().split(","))
                    .map(String::trim)
                    .filter(StringUtils::hasText)
                    .map(Integer::parseInt)
                    .sorted()
                    .collect(Collectors.toList());
        } catch (NumberFormatException e) {
            logger.warn("解析书签页失败: {}", progress.getBookmarkPages());
            return List.of();
        }
    }

}
