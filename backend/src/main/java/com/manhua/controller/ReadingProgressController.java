package com.manhua.controller;

import com.manhua.entity.ReadingProgress;
import com.manhua.service.ReadingProgressService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 阅读进度控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/reading-progress")
@CrossOrigin(origins = "*")
public class ReadingProgressController {

    private static final Logger logger = LoggerFactory.getLogger(ReadingProgressController.class);

    @Autowired
    private ReadingProgressService readingProgressService;

    /**
     * 获取所有阅读进度
     */
    @GetMapping
    public ResponseEntity<List<ReadingProgress>> getAllReadingProgress() {
        try {
            List<ReadingProgress> progressList = readingProgressService.getAllProgress();
            return ResponseEntity.ok(progressList);
        } catch (Exception e) {
            logger.error("获取阅读进度列表失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据ID获取阅读进度
     */
    @GetMapping("/{id}")
    public ResponseEntity<ReadingProgress> getReadingProgressById(@PathVariable Long id) {
        try {
            return readingProgressService.getProgressById(id)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            logger.error("获取阅读进度失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据漫画ID获取阅读进度
     */
    @GetMapping("/manga/{mangaId}")
    public ResponseEntity<ReadingProgress> getReadingProgressByMangaId(@PathVariable Long mangaId) {
        try {
            return readingProgressService.getProgressByMangaId(mangaId)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            logger.error("根据漫画ID获取阅读进度失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 创建阅读进度
     */
    @PostMapping
    public ResponseEntity<ReadingProgress> createReadingProgress(
            @Valid @RequestBody ReadingProgress readingProgress) {
        try {
            ReadingProgress created = readingProgressService.createProgress(readingProgress);
            return ResponseEntity.ok(created);
        } catch (IllegalArgumentException e) {
            logger.warn("创建阅读进度参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("创建阅读进度失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新阅读进度
     */
    @PutMapping("/{id}")
    public ResponseEntity<ReadingProgress> updateReadingProgress(
            @PathVariable Long id,
            @Valid @RequestBody ReadingProgress readingProgress) {
        try {
            readingProgress.setId(id);
            ReadingProgress updated = readingProgressService.updateProgress(readingProgress.getManga().getId(), readingProgress.getCurrentPage());
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            logger.warn("更新阅读进度参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新阅读进度失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 删除阅读进度
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReadingProgress(@PathVariable Long mangaId) {
        try {
            readingProgressService.deleteProgress(mangaId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("删除阅读进度参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("删除阅读进度失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新阅读进度（页数）
     */
    @PostMapping("/manga/{mangaId}/update")
    public ResponseEntity<ReadingProgress> updateProgress(
            @PathVariable Long mangaId,
            @RequestBody Map<String, Integer> request) {
        try {
            Integer currentPage = request.get("currentPage");
            if (currentPage == null || currentPage < 0) {
                return ResponseEntity.badRequest().build();
            }

            ReadingProgress progress = readingProgressService.updateProgress(mangaId, currentPage);
            return ResponseEntity.ok(progress);
        } catch (IllegalArgumentException e) {
            logger.warn("更新阅读进度参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新阅读进度失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 开始阅读会话
     */
    @PostMapping("/manga/{mangaId}/start-session")
    public ResponseEntity<ReadingProgress> startReadingSession(@PathVariable Long mangaId) {
        try {
            ReadingProgress progress = readingProgressService.startReadingSession(mangaId);
            return ResponseEntity.ok(progress);
        } catch (IllegalArgumentException e) {
            logger.warn("开始阅读会话参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("开始阅读会话失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 结束阅读会话
     */
    @PostMapping("/manga/{mangaId}/end-session")
    public ResponseEntity<ReadingProgress> endReadingSession(@PathVariable Long mangaId) {
        try {
            ReadingProgress progress = readingProgressService.endReadingSession(mangaId);
            return ResponseEntity.ok(progress);
        } catch (IllegalArgumentException e) {
            logger.warn("结束阅读会话参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("结束阅读会话失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 重置阅读进度
     */
    @PostMapping("/manga/{mangaId}/reset")
    public ResponseEntity<Boolean> resetProgress(@PathVariable Long mangaId) {
        try {
            readingProgressService.resetProgress(mangaId);
            return ResponseEntity.ok(true);
        } catch (IllegalArgumentException e) {
            logger.warn("重置阅读进度参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("重置阅读进度失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 标记为已完成
     */
    @PostMapping("/manga/{mangaId}/complete")
    public ResponseEntity<Boolean> markAsCompleted(@PathVariable Long mangaId) {
        try {
            readingProgressService.markAsCompleted(mangaId);
            return ResponseEntity.ok(true);
        } catch (IllegalArgumentException e) {
            logger.warn("标记完成参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("标记完成失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 添加书签
     */
    @PostMapping("/manga/{mangaId}/bookmark")
    public ResponseEntity<ReadingProgress> addBookmark(
            @PathVariable Long mangaId,
            @RequestBody Map<String, Integer> request) {
        try {
            Integer page = request.get("page");
            if (page == null || page < 0) {
                return ResponseEntity.badRequest().build();
            }

            ReadingProgress progress = readingProgressService.addBookmark(mangaId, page);
            return ResponseEntity.ok(progress);
        } catch (IllegalArgumentException e) {
            logger.warn("添加书签参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("添加书签失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 移除书签
     */
    @DeleteMapping("/manga/{mangaId}/bookmark")
    public ResponseEntity<ReadingProgress> removeBookmark(
            @PathVariable Long mangaId,
            @RequestParam Integer page) {
        try {
            if (page == null || page < 0) {
                return ResponseEntity.badRequest().build();
            }

            ReadingProgress progress = readingProgressService.removeBookmark(mangaId, page);
            return ResponseEntity.ok(progress);
        } catch (IllegalArgumentException e) {
            logger.warn("移除书签参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("移除书签失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取书签列表
     */
    @GetMapping("/manga/{mangaId}/bookmarks")
    public ResponseEntity<List<Integer>> getBookmarks(@PathVariable Long mangaId) {
        try {
            List<Integer> bookmarks = readingProgressService.getBookmarks(mangaId);
            return ResponseEntity.ok(bookmarks);
        } catch (Exception e) {
            logger.error("获取书签列表失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新笔记
     */
    @PostMapping("/manga/{mangaId}/notes")
    public ResponseEntity<ReadingProgress> updateNotes(
            @PathVariable Long mangaId,
            @RequestBody Map<String, String> request) {
        try {
            String notes = request.get("notes");
            ReadingProgress progress = readingProgressService.updateNotes(mangaId, notes);
            return ResponseEntity.ok(progress);
        } catch (IllegalArgumentException e) {
            logger.warn("更新笔记参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新笔记失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取已完成的漫画进度
     */
    @GetMapping("/completed")
    public ResponseEntity<List<ReadingProgress>> getCompletedProgress() {
        try {
            List<ReadingProgress> progressList = readingProgressService.getCompletedProgress();
            return ResponseEntity.ok(progressList);
        } catch (Exception e) {
            logger.error("获取已完成进度失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

}
