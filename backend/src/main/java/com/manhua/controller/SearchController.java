package com.manhua.controller;

import com.manhua.entity.Manga;
import com.manhua.service.MangaService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 搜索控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/search")
@CrossOrigin(origins = "*")
public class SearchController {

    private static final Logger logger = LoggerFactory.getLogger(SearchController.class);

    @Autowired
    private MangaService mangaService;

    // 热门搜索词缓存
    private final List<String> popularSearches = Arrays.asList(
        "进击的巨人", "鬼灭之刃", "海贼王", "火影忍者", "龙珠",
        "死神", "妖精的尾巴", "银魂", "全职猎人", "钢之炼金术师"
    );

    /**
     * 搜索漫画
     */
    @GetMapping("/mangas")
    public ResponseEntity<List<Manga>> searchMangas(
            @RequestParam String query,
            @RequestParam(required = false) String libraryId,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(defaultValue = "false") boolean includeContent) {
        try {
            if (query == null || query.trim().isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            List<Manga> allMangas;
            if (libraryId != null && !libraryId.isEmpty()) {
                allMangas = mangaService.getMangaByLibrary(Long.parseLong(libraryId));
            } else {
                allMangas = mangaService.getAllManga();
            }

            // 简单的文本搜索实现
            String searchQuery = query.toLowerCase().trim();
            List<Manga> searchResults = allMangas.stream()
                .filter(manga -> {
                    if (manga.getTitle() != null && manga.getTitle().toLowerCase().contains(searchQuery)) {
                        return true;
                    }
                    if (manga.getAuthor() != null && manga.getAuthor().toLowerCase().contains(searchQuery)) {
                        return true;
                    }
                    if (manga.getDescription() != null && manga.getDescription().toLowerCase().contains(searchQuery)) {
                        return true;
                    }
                    if (manga.getTags() != null && manga.getTags().stream().anyMatch(e->e.getName().contains(searchQuery))) {
                        return true;
                    }
                    return false;
                })
                .limit(limit)
                .collect(Collectors.toList());

            return ResponseEntity.ok(searchResults);
        } catch (Exception e) {
            logger.error("搜索漫画失败: {}", query, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取搜索建议
     */
    @GetMapping("/suggestions")
    public ResponseEntity<List<String>> getSearchSuggestions(
            @RequestParam String query) {
        try {
            if (query == null || query.trim().isEmpty()) {
                return ResponseEntity.ok(Collections.emptyList());
            }

            String searchQuery = query.toLowerCase().trim();
            List<String> suggestions = new ArrayList<>();

            // 从漫画标题中获取建议
            List<Manga> allMangas = mangaService.getAllManga();
            Set<String> titleSuggestions = allMangas.stream()
                .filter(manga -> manga.getTitle() != null &&
                        manga.getTitle().toLowerCase().contains(searchQuery))
                .map(Manga::getTitle)
                .limit(5)
                .collect(Collectors.toSet());
            suggestions.addAll(titleSuggestions);

            // 从作者中获取建议
            Set<String> authorSuggestions = allMangas.stream()
                .filter(manga -> manga.getAuthor() != null &&
                        manga.getAuthor().toLowerCase().contains(searchQuery))
                .map(Manga::getAuthor)
                .limit(3)
                .collect(Collectors.toSet());
            suggestions.addAll(authorSuggestions);

            // 从热门搜索中获取建议
            List<String> popularSuggestions = popularSearches.stream()
                .filter(term -> term.toLowerCase().contains(searchQuery))
                .limit(2)
                .collect(Collectors.toList());
            suggestions.addAll(popularSuggestions);

            // 去重并限制数量
            List<String> result = suggestions.stream()
                .distinct()
                .limit(10)
                .collect(Collectors.toList());

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("获取搜索建议失败: {}", query, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取热门搜索
     */
    @GetMapping("/popular")
    public ResponseEntity<List<String>> getPopularSearches() {
        try {
            // 返回热门搜索词
            List<String> result = new ArrayList<>(popularSearches);
            Collections.shuffle(result); // 随机排序
            return ResponseEntity.ok(result.subList(0, Math.min(5, result.size())));
        } catch (Exception e) {
            logger.error("获取热门搜索失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 高级搜索
     */
    @PostMapping("/advanced")
    public ResponseEntity<List<Manga>> advancedSearch(
            @RequestBody Map<String, Object> searchCriteria) {
        try {
            List<Manga> allMangas = mangaService.getAllManga();

            List<Manga> results = allMangas.stream()
                .filter(manga -> matchesCriteria(manga, searchCriteria))
                .collect(Collectors.toList());

            return ResponseEntity.ok(results);
        } catch (Exception e) {
            logger.error("高级搜索失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 检查漫画是否匹配搜索条件
     */
    private boolean matchesCriteria(Manga manga, Map<String, Object> criteria) {
        // 标题搜索
        if (criteria.containsKey("title")) {
            String title = (String) criteria.get("title");
            if (title != null && !title.isEmpty()) {
                if (manga.getTitle() == null ||
                    !manga.getTitle().toLowerCase().contains(title.toLowerCase())) {
                    return false;
                }
            }
        }

        // 作者搜索
        if (criteria.containsKey("author")) {
            String author = (String) criteria.get("author");
            if (author != null && !author.isEmpty()) {
                if (manga.getAuthor() == null ||
                    !manga.getAuthor().toLowerCase().contains(author.toLowerCase())) {
                    return false;
                }
            }
        }

        // 状态搜索
        if (criteria.containsKey("status")) {
            String status = (String) criteria.get("status");
            if (status != null && !status.isEmpty()) {
                if (manga.getStatus() == null ||
                    !manga.getStatus().toString().equalsIgnoreCase(status)) {
                    return false;
                }
            }
        }

        // 标签搜索
        if (criteria.containsKey("tags")) {
            String tags = (String) criteria.get("tags");
            if (tags != null && !tags.isEmpty()) {
                if (manga.getTags() == null ||
                    !manga.getTags().stream().anyMatch(e->e.getName().contains(tags.toLowerCase()))) {
                    return false;
                }
            }
        }

        return true;
    }
}
