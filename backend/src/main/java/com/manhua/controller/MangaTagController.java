package com.manhua.controller;

import com.manhua.entity.MangaTag;
import com.manhua.service.MangaTagService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 漫画标签控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/manga-tags")
@CrossOrigin(origins = "*")
public class MangaTagController {

    private static final Logger logger = LoggerFactory.getLogger(MangaTagController.class);

    @Autowired
    private MangaTagService mangaTagService;

    /**
     * 获取所有标签
     */
    @GetMapping
    public ResponseEntity<List<MangaTag>> getAllTags() {
        try {
            List<MangaTag> tags = mangaTagService.getAllTags();
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            logger.error("获取标签列表失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据ID获取标签
     */
    @GetMapping("/{id}")
    public ResponseEntity<MangaTag> getTagById(@PathVariable Long id) {
        try {
            return mangaTagService.getTagById(id)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            logger.error("获取标签失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据名称获取标签
     */
    @GetMapping("/name/{name}")
    public ResponseEntity<MangaTag> getTagByName(@PathVariable String name) {
        try {
            return mangaTagService.getTagByName(name)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            logger.error("根据名称获取标签失败: {}", name, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 创建标签
     */
    @PostMapping
    public ResponseEntity<MangaTag> createTag(@Valid @RequestBody MangaTag tag) {
        try {
            MangaTag createdTag = mangaTagService.createTag(tag);
            return ResponseEntity.ok(createdTag);
        } catch (IllegalArgumentException e) {
            logger.warn("创建标签参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("创建标签失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新标签
     */
    @PutMapping("/{id}")
    public ResponseEntity<MangaTag> updateTag(
            @PathVariable Long id,
            @Valid @RequestBody MangaTag tag) {
        try {
            tag.setId(id);
            MangaTag updatedTag = mangaTagService.updateTag(id,tag);
            return ResponseEntity.ok(updatedTag);
        } catch (IllegalArgumentException e) {
            logger.warn("更新标签参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新标签失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 删除标签
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTag(@PathVariable Long id) {
        try {
            mangaTagService.deleteTag(id);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("删除标签参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("删除标签失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 为漫画添加标签
     */
    @PostMapping("/manga/{mangaId}/add")
    public ResponseEntity<Void> addTagToManga(
            @PathVariable Long mangaId,
            @RequestBody Map<String, String> request) {
        try {
            String tagName = request.get("tagName");
            if (tagName == null) {
                return ResponseEntity.badRequest().build();
            }

            mangaTagService.addTagToManga(mangaId, tagName);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("为漫画添加标签参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("为漫画添加标签失败: {} - {}", mangaId, request.get("tagName"), e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 从漫画移除标签
     */
    @DeleteMapping("/manga/{mangaId}/remove")
    public ResponseEntity<Void> removeTagFromManga(
            @PathVariable Long mangaId,
            @RequestParam String tagName) {
        try {
            mangaTagService.removeTagFromManga(mangaId, tagName);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("从漫画移除标签参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("从漫画移除标签失败: {} - {}", mangaId, tagName, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取漫画的所有标签
     */
    @GetMapping("/manga/{mangaId}")
    public ResponseEntity<List<MangaTag>> getTagsByMangaId(@PathVariable Long mangaId) {
        try {
            List<MangaTag> tags = mangaTagService.getTagsByMangaId(mangaId);
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            logger.error("获取漫画标签失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据标签获取漫画ID列表
     */
    @GetMapping("/{tagName}/mangas")
    public ResponseEntity<List<Long>> getMangaIdsByTagName(@PathVariable String tagName) {
        try {
            List<Long> mangaIds = mangaTagService.findMangaIdsByTag(tagName);
            return ResponseEntity.ok(mangaIds);
        } catch (Exception e) {
            logger.error("根据标签获取漫画ID失败: {}", tagName, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 批量为漫画添加标签
     */
    @PostMapping("/manga/{mangaId}/batch-add")
    public ResponseEntity<Map<String, Object>> batchAddTagsToManga(
            @PathVariable Long mangaId,
            @RequestBody Map<String, List<String>> request) {
        try {
            List<String> tagNames = request.get("tagNames");
            if (tagNames == null || tagNames.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "标签名字列表不能为空"));
            }

            mangaTagService.addTagsToManga(mangaId, tagNames);
            return ResponseEntity.ok(Map.of(
                    "message", "批量添加标签完成"
            ));
        } catch (Exception e) {
            logger.error("批量为漫画添加标签失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "批量添加标签失败"));
        }
    }

    /**
     * 批量从漫画移除标签
     */
    @DeleteMapping("/manga/{mangaId}/batch-remove")
    public ResponseEntity<Map<String, Object>> batchRemoveTagsFromManga(
            @PathVariable Long mangaId,
            @RequestBody Map<String, List<String>> request) {
        try {
            List<String> tagNames = request.get("tagNames");
            if (tagNames == null || tagNames.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "标签名字列表不能为空"));
            }

            mangaTagService.removeTagsFromManga(mangaId, tagNames);
            return ResponseEntity.ok(Map.of(
                    "message", "批量移除标签完成"
            ));
        } catch (Exception e) {
            logger.error("批量从漫画移除标签失败: {}", mangaId, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "批量移除标签失败"));
        }
    }


    /**
     * 搜索标签
     */
    @GetMapping("/search")
    public ResponseEntity<List<MangaTag>> searchTags(@RequestParam String keyword) {
        try {
            List<MangaTag> tags = mangaTagService.searchTags(keyword);
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            logger.error("搜索标签失败: {}", keyword, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据颜色获取标签
     */
    @GetMapping("/color/{color}")
    public ResponseEntity<List<MangaTag>> getTagsByColor(@PathVariable String color) {
        try {
            List<MangaTag> tags = mangaTagService.getTagsByColor(color);
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            logger.error("根据颜色获取标签失败: {}", color, e);
            return ResponseEntity.internalServerError().build();
        }
    }



    /**
     * 查找孤立标签（未被任何漫画使用）
     */
    @GetMapping("/orphaned")
    public ResponseEntity<List<MangaTag>> findOrphanedTags() {
        try {
            List<MangaTag> tags = mangaTagService.findOrphanedTags();
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            logger.error("查找孤立标签失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取标签使用统计
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getTagStatistics() {
        try {
            List<Object[]> list= mangaTagService.getTagUsageStatistics();
            Map<String, Object> stats=new HashMap<>();
            for (Object[] objects : list) {
                stats.put(objects[0].toString(), objects[1]);
            }
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            logger.error("获取标签统计信息失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }


}
