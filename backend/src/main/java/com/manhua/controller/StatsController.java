package com.manhua.controller;

import com.manhua.entity.Manga;
import com.manhua.entity.MangaLibrary;
import com.manhua.entity.MangaTag;
import com.manhua.entity.ReadingProgress;
import com.manhua.service.MangaLibraryService;
import com.manhua.service.MangaService;
import com.manhua.service.ReadingProgressService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 统计控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/stats")
@CrossOrigin(origins = "*")
public class StatsController {

    private static final Logger logger = LoggerFactory.getLogger(StatsController.class);

    @Autowired
    private MangaService mangaService;

    @Autowired
    private MangaLibraryService libraryService;

    @Autowired
    private ReadingProgressService progressService;

    /**
     * 获取阅读统计
     */
    @GetMapping("/reading")
    public ResponseEntity<Map<String, Object>> getReadingStats() {
        try {
            Map<String, Object> stats = new HashMap<>();

            // 获取所有漫画
            List<Manga> allMangas = mangaService.getAllManga();
            stats.put("totalMangas", allMangas.size());

            // 获取所有阅读进度
            List<ReadingProgress> allProgress = progressService.getAllProgress();

            // 计算阅读中的漫画数量
            long readingMangas = allProgress.stream()
                .filter(progress -> progress.getCurrentPage() > 0 &&
                               progress.getCurrentPage() < progress.getTotalPages())
                .count();
            stats.put("readingMangas", readingMangas);

            // 计算已完成的漫画数量
            long completedMangas = allProgress.stream()
                .filter(progress -> progress.getCurrentPage() >= progress.getTotalPages())
                .count();
            stats.put("completedMangas", completedMangas);

            // 计算总页数和已读页数
            int totalPages = allMangas.stream()
                .mapToInt(manga -> manga.getTotalPages() != null ? manga.getTotalPages() : 0)
                .sum();
            stats.put("totalPages", totalPages);

            int readPages = allProgress.stream()
                .mapToInt(ReadingProgress::getCurrentPage)
                .sum();
            stats.put("readPages", readPages);

            // 计算总阅读时间（分钟）
            long totalReadingTime = allProgress.stream()
                .mapToLong(progress -> {
                    if (progress.getLastReadAt() != null && progress.getCreatedAt() != null) {
                        return java.time.Duration.between(progress.getCreatedAt(), progress.getLastReadAt()).toMinutes();
                    }
                    return 0;
                })
                .sum();
            stats.put("readingTime", totalReadingTime);

            // 计算平均评分
            double averageRating = allMangas.stream()
                .filter(manga -> manga.getRating() != null && manga.getRating() > 0)
                .mapToDouble(Manga::getRating)
                .average()
                .orElse(0.0);
            stats.put("averageRating", Math.round(averageRating * 100.0) / 100.0);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            logger.error("获取阅读统计失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取库统计
     */
    @GetMapping("/library")
    public ResponseEntity<Map<String, Object>> getLibraryStats() {
        try {
            Map<String, Object> stats = new HashMap<>();

            // 获取所有库
            List<MangaLibrary> allLibraries = libraryService.getAllLibraries();
            stats.put("totalLibraries", allLibraries.size());

            // 计算总大小
            long totalSize = allLibraries.stream()
                .mapToLong(library -> {
                    // 这里应该计算实际的库大小，暂时返回模拟数据
                    return 1024L * 1024L * 1024L; // 1GB per library
                })
                .sum();
            stats.put("totalSize", totalSize);

            // 获取所有漫画
            List<Manga> allMangas = mangaService.getAllManga();

            // 按类型分组统计
            Map<String, Long> mangasByGenre = allMangas.stream()
                .filter(manga -> manga.getTags() != null && !manga.getTags().isEmpty())
                .flatMap(manga -> manga.getTags().stream().map(MangaTag::getName))
                .map(String::trim)
                .filter(tag -> !tag.isEmpty())
                .collect(Collectors.groupingBy(
                    tag -> tag,
                    Collectors.counting()
                ));
            stats.put("mangasByGenre", mangasByGenre);

            // 按状态分组统计
            Map<String, Long> mangasByStatus = allMangas.stream()
                .filter(manga -> manga.getStatus() != null)
                .collect(Collectors.groupingBy(
                    manga -> manga.getStatus().toString(),
                    Collectors.counting()
                ));
            stats.put("mangasByStatus", mangasByStatus);

            // 最近添加的漫画（最近7天）
            LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(7);
            List<Manga> recentlyAdded = allMangas.stream()
                .filter(manga -> manga.getCreatedAt() != null &&
                               manga.getCreatedAt().isAfter(sevenDaysAgo))
                .sorted((m1, m2) -> m2.getCreatedAt().compareTo(m1.getCreatedAt()))
                .limit(10)
                .collect(Collectors.toList());
            stats.put("recentlyAdded", recentlyAdded);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            logger.error("获取库统计失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取详细统计
     */
    @GetMapping("/detailed")
    public ResponseEntity<Map<String, Object>> getDetailedStats() {
        try {
            Map<String, Object> stats = new HashMap<>();

            // 获取基础统计
            ResponseEntity<Map<String, Object>> readingStatsResponse = getReadingStats();
            ResponseEntity<Map<String, Object>> libraryStatsResponse = getLibraryStats();

            if (readingStatsResponse.getBody() != null) {
                stats.put("reading", readingStatsResponse.getBody());
            }

            if (libraryStatsResponse.getBody() != null) {
                stats.put("library", libraryStatsResponse.getBody());
            }

            // 添加额外的统计信息
            List<Manga> allMangas = mangaService.getAllManga();

            // 按作者统计
            Map<String, Long> mangasByAuthor = allMangas.stream()
                .filter(manga -> manga.getAuthor() != null && !manga.getAuthor().isEmpty())
                .collect(Collectors.groupingBy(
                    Manga::getAuthor,
                    Collectors.counting()
                ))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(10)
                .collect(Collectors.toMap(
                    Map.Entry::getKey,
                    Map.Entry::getValue,
                    (e1, e2) -> e1,
                    LinkedHashMap::new
                ));
            stats.put("mangasByAuthor", mangasByAuthor);

            // 按评分统计
            Map<String, Long> mangasByRating = allMangas.stream()
                .filter(manga -> manga.getRating() != null && manga.getRating() > 0)
                .collect(Collectors.groupingBy(
                    manga -> String.valueOf(Math.round(manga.getRating())),
                    Collectors.counting()
                ));
            stats.put("mangasByRating", mangasByRating);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            logger.error("获取详细统计失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取趋势统计
     */
    @GetMapping("/trends")
    public ResponseEntity<Map<String, Object>> getTrends(
            @RequestParam(defaultValue = "30") int days) {
        try {
            Map<String, Object> trends = new HashMap<>();

            LocalDateTime startDate = LocalDateTime.now().minusDays(days);

            // 获取时间范围内的数据
            List<Manga> allMangas = mangaService.getAllManga();
            List<ReadingProgress> allProgress = progressService.getAllProgress();

            // 按日期统计新增漫画
            Map<String, Long> dailyAddedMangas = allMangas.stream()
                .filter(manga -> manga.getCreatedAt() != null &&
                               manga.getCreatedAt().isAfter(startDate))
                .collect(Collectors.groupingBy(
                    manga -> manga.getCreatedAt().toLocalDate().toString(),
                    Collectors.counting()
                ));
            trends.put("dailyAddedMangas", dailyAddedMangas);

            // 按日期统计阅读活动
            Map<String, Long> dailyReadingActivity = allProgress.stream()
                .filter(progress -> progress.getLastReadAt() != null &&
                                  progress.getLastReadAt().isAfter(startDate))
                .collect(Collectors.groupingBy(
                    progress -> progress.getLastReadAt().toLocalDate().toString(),
                    Collectors.counting()
                ));
            trends.put("dailyReadingActivity", dailyReadingActivity);

            return ResponseEntity.ok(trends);
        } catch (Exception e) {
            logger.error("获取趋势统计失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}
