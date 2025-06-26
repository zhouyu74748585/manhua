package com.manhua.controller;

import com.manhua.dto.TagDTO;
import com.manhua.dto.response.ApiResponse;
import com.manhua.service.TagService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.Optional;

/**
 * 标签控制器
 */
@RestController
@RequestMapping("/api/tags")

public class TagController {

    private static final Logger log = LoggerFactory.getLogger(TagController.class);
    @Autowired
    private TagService tagService;

    /**
     * 获取所有标签
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<TagDTO>>> getAllTags() {
        try {
            List<TagDTO> tags = tagService.getAllTags();
            return ResponseEntity.ok(ApiResponse.success(tags));
        } catch (Exception e) {
            log.error("Failed to get all tags", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据ID获取标签
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<TagDTO>> getTagById(@PathVariable @Min(1) Long id) {
        try {
            Optional<TagDTO> tag = tagService.getTagById(id);
            if (tag.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(tag.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("Failed to get tag by id: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据名称获取标签
     */
    @GetMapping("/name/{name}")
    public ResponseEntity<ApiResponse<TagDTO>> getTagByName(@PathVariable @NotBlank String name) {
        try {
            Optional<TagDTO> tag = tagService.getTagByName(name);
            if (tag.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(tag.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("Failed to get tag by name: {}", name, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据分类获取标签
     */
    @GetMapping("/category/{category}")
    public ResponseEntity<ApiResponse<List<TagDTO>>> getTagsByCategory(@PathVariable @NotBlank String category) {
        try {
            List<TagDTO> tags = tagService.getTagsByCategory(category);
            return ResponseEntity.ok(ApiResponse.success(tags));
        } catch (Exception e) {
            log.error("Failed to get tags by category: {}", category, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 搜索标签
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<TagDTO>>> searchTags(@RequestParam @NotBlank String keyword) {
        try {
            List<TagDTO> tags = tagService.searchTags(keyword);
            return ResponseEntity.ok(ApiResponse.success(tags));
        } catch (Exception e) {
            log.error("Failed to search tags with keyword: {}", keyword, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取热门标签
     */
    @GetMapping("/popular")
    public ResponseEntity<ApiResponse<List<TagDTO>>> getPopularTags() {
        try {
            List<TagDTO> tags = tagService.getPopularTags();
            return ResponseEntity.ok(ApiResponse.success(tags));
        } catch (Exception e) {
            log.error("Failed to get popular tags", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取使用次数大于指定值的标签
     */
    @GetMapping("/usage/{minCount}")
    public ResponseEntity<ApiResponse<List<TagDTO>>> getTagsByUsageCount(@PathVariable @Min(0) Integer minCount) {
        try {
            List<TagDTO> tags = tagService.getTagsByUsageCount(minCount);
            return ResponseEntity.ok(ApiResponse.success(tags));
        } catch (Exception e) {
            log.error("Failed to get tags by usage count: {}", minCount, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取所有分类
     */
    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<String>>> getAllCategories() {
        try {
            List<String> categories = tagService.getAllCategories();
            return ResponseEntity.ok(ApiResponse.success(categories));
        } catch (Exception e) {
            log.error("Failed to get all categories", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据漫画ID获取标签
     */
    @GetMapping("/comic/{comicId}")
    public ResponseEntity<ApiResponse<List<TagDTO>>> getTagsByComicId(@PathVariable @Min(1) Long comicId) {
        try {
            List<TagDTO> tags = tagService.getTagsByComicId(comicId);
            return ResponseEntity.ok(ApiResponse.success(tags));
        } catch (Exception e) {
            log.error("Failed to get tags by comic id: {}", comicId, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据库ID获取标签
     */
    @GetMapping("/library/{libraryId}")
    public ResponseEntity<ApiResponse<List<TagDTO>>> getTagsByLibraryId(@PathVariable @Min(1) Long libraryId) {
        try {
            List<TagDTO> tags = tagService.getTagsByLibraryId(libraryId);
            return ResponseEntity.ok(ApiResponse.success(tags));
        } catch (Exception e) {
            log.error("Failed to get tags by library id: {}", libraryId, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 创建标签
     */
    @PostMapping
    public ResponseEntity<ApiResponse<TagDTO>> createTag(
            @RequestParam @NotBlank String name,
            @RequestParam(required = false) String color,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String description) {
        try {
            TagDTO tag = tagService.createTag(name, color, category, description);
            return ResponseEntity.ok(ApiResponse.success("Tag created successfully", tag));
        } catch (Exception e) {
            log.error("Failed to create tag", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新标签
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<TagDTO>> updateTag(
            @PathVariable @Min(1) Long id,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String color,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String description) {
        try {
            TagDTO tag = tagService.updateTag(id, name, color, category, description);
            return ResponseEntity.ok(ApiResponse.success("Tag updated successfully", tag));
        } catch (Exception e) {
            log.error("Failed to update tag: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 删除标签
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteTag(@PathVariable @Min(1) Long id) {
        try {
            tagService.deleteTag(id);
            return ResponseEntity.ok(ApiResponse.success("Tag deleted successfully", null));
        } catch (Exception e) {
            log.error("Failed to delete tag: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取未使用的标签
     */
    @GetMapping("/unused")
    public ResponseEntity<ApiResponse<List<TagDTO>>> getUnusedTags() {
        try {
            List<TagDTO> tags = tagService.getUnusedTags();
            return ResponseEntity.ok(ApiResponse.success(tags));
        } catch (Exception e) {
            log.error("Failed to get unused tags", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 清理未使用的标签
     */
    @DeleteMapping("/cleanup")
    public ResponseEntity<ApiResponse<Integer>> cleanupUnusedTags() {
        try {
            int count = tagService.cleanupUnusedTags();
            return ResponseEntity.ok(ApiResponse.success("Cleaned up " + count + " unused tags",count));
        } catch (Exception e) {
            log.error("Failed to cleanup unused tags", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取标签统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Object>> getTagStats() {
        try {
            Long totalCount = tagService.countTags();
            List<Object[]> countByCategory = tagService.countTagsByCategory();
            
            return ResponseEntity.ok(ApiResponse.success(new Object() {
                public final Long totalCount = tagService.countTags();
                public final List<Object[]> countByCategory = tagService.countTagsByCategory();
            }));
        } catch (Exception e) {
            log.error("Failed to get tag stats", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}