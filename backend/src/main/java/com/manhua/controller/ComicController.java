package com.manhua.controller;

import com.manhua.dto.ComicDTO;
import com.manhua.dto.request.UpdateComicRequest;
import com.manhua.dto.response.ApiResponse;
import com.manhua.dto.response.PageResponse;
import com.manhua.service.ComicService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.Optional;

/**
 * 漫画控制器
 */
@RestController
@RequestMapping("/api/comics")
public class ComicController {

    private static final Logger log = LoggerFactory.getLogger(ComicController.class);
    @Autowired
    private  ComicService comicService;

    /**
     * 获取所有漫画
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<ComicDTO>>> getAllComics() {
        try {
            List<ComicDTO> comics = comicService.getAllComics();
            return ResponseEntity.ok(ApiResponse.success(comics));
        } catch (Exception e) {
            log.error("Failed to get all comics", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 分页获取漫画
     */
    @GetMapping("/page")
    public ResponseEntity<ApiResponse<PageResponse<ComicDTO>>> getComicsWithPagination(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) int size,
            @RequestParam(defaultValue = "updateTime") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        try {
            Sort sort = Sort.by(Sort.Direction.fromString(sortDir), sortBy);
            Pageable pageable = PageRequest.of(page, size, sort);
            Page<ComicDTO> comicPage = comicService.getComics(pageable);
            PageResponse<ComicDTO> response = PageResponse.of(comicPage);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            log.error("Failed to get comics with pagination", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据ID获取漫画
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ComicDTO>> getComicById(@PathVariable @Min(1) Long id) {
        try {
            Optional<ComicDTO> comic = comicService.getComicById(id);
            if (comic.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(comic.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("Failed to get comic by id: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据库ID获取漫画
     */
    @GetMapping("/library/{libraryId}")
    public ResponseEntity<ApiResponse<List<ComicDTO>>> getComicsByLibraryId(@PathVariable @Min(1) Long libraryId) {
        try {
            List<ComicDTO> comics = comicService.getComicsByLibraryId(libraryId);
            return ResponseEntity.ok(ApiResponse.success(comics));
        } catch (Exception e) {
            log.error("Failed to get comics by library id: {}", libraryId, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据库ID分页获取漫画
     */
    @GetMapping("/library/{libraryId}/page")
    public ResponseEntity<ApiResponse<PageResponse<ComicDTO>>> getComicsByLibraryIdWithPagination(
            @PathVariable @Min(1) Long libraryId,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) int size,
            @RequestParam(defaultValue = "updateTime") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        try {
            Sort sort = Sort.by(Sort.Direction.fromString(sortDir), sortBy);
            Pageable pageable = PageRequest.of(page, size, sort);
            Page<ComicDTO> comicPage = comicService.getComicsByLibraryId(libraryId, pageable);
            PageResponse<ComicDTO> response = PageResponse.of(comicPage);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            log.error("Failed to get comics by library id with pagination: {}", libraryId, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 搜索漫画
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<PageResponse<ComicDTO>>> searchComics(
            @RequestParam @NotBlank String keyword,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) int size,
            @RequestParam(defaultValue = "updateTime") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        try {
            Sort sort = Sort.by(Sort.Direction.fromString(sortDir), sortBy);
            Pageable pageable = PageRequest.of(page, size, sort);
            Page<ComicDTO> comicPage = comicService.searchComics(keyword, pageable);
            PageResponse<ComicDTO> response = PageResponse.of(comicPage);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            log.error("Failed to search comics with keyword: {}", keyword, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 在指定库中搜索漫画
     */
    @GetMapping("/library/{libraryId}/search")
    public ResponseEntity<ApiResponse<PageResponse<ComicDTO>>> searchComicsByLibrary(
            @PathVariable @Min(1) Long libraryId,
            @RequestParam @NotBlank String keyword,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) int size,
            @RequestParam(defaultValue = "updateTime") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        try {
            Sort sort = Sort.by(Sort.Direction.fromString(sortDir), sortBy);
            Pageable pageable = PageRequest.of(page, size, sort);
            Page<ComicDTO> comicPage = comicService.searchComicsByLibrary(libraryId, keyword, pageable);
            PageResponse<ComicDTO> response = PageResponse.of(comicPage);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            log.error("Failed to search comics in library {} with keyword: {}", libraryId, keyword, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取最近阅读的漫画
     */
    @GetMapping("/recent")
    public ResponseEntity<ApiResponse<PageResponse<ComicDTO>>> getRecentlyReadComics(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) int size) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<ComicDTO> comicPage = comicService.getRecentlyReadComics(pageable);
            PageResponse<ComicDTO> response = PageResponse.of(comicPage);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            log.error("Failed to get recently read comics", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取正在阅读的漫画
     */
    @GetMapping("/reading")
    public ResponseEntity<ApiResponse<List<ComicDTO>>> getCurrentlyReadingComics() {
        try {
            List<ComicDTO> comics = comicService.getCurrentlyReadingComics();
            return ResponseEntity.ok(ApiResponse.success(comics));
        } catch (Exception e) {
            log.error("Failed to get currently reading comics", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取已完成的漫画
     */
    @GetMapping("/completed")
    public ResponseEntity<ApiResponse<List<ComicDTO>>> getCompletedComics() {
        try {
            List<ComicDTO> comics = comicService.getCompletedComics();
            return ResponseEntity.ok(ApiResponse.success(comics));
        } catch (Exception e) {
            log.error("Failed to get completed comics", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取未读的漫画
     */
    @GetMapping("/unread")
    public ResponseEntity<ApiResponse<List<ComicDTO>>> getUnreadComics() {
        try {
            List<ComicDTO> comics = comicService.getUnreadComics();
            return ResponseEntity.ok(ApiResponse.success(comics));
        } catch (Exception e) {
            log.error("Failed to get unread comics", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取收藏的漫画
     */
    @GetMapping("/favorites")
    public ResponseEntity<ApiResponse<List<ComicDTO>>> getFavoriteComics() {
        try {
            List<ComicDTO> comics = comicService.getFavoriteComics();
            return ResponseEntity.ok(ApiResponse.success(comics));
        } catch (Exception e) {
            log.error("Failed to get favorite comics", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据标签获取漫画
     */
    @GetMapping("/tags")
    public ResponseEntity<ApiResponse<List<ComicDTO>>> getComicsByTags(@RequestParam List<String> tagNames) {
        try {
            List<ComicDTO> comics = comicService.getComicsByTags(tagNames);
            return ResponseEntity.ok(ApiResponse.success(comics));
        } catch (Exception e) {
            log.error("Failed to get comics by tags: {}", tagNames, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据阅读状态获取漫画
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<ApiResponse<List<ComicDTO>>> getComicsByReadingStatus(@PathVariable @NotBlank String status) {
        try {
            List<ComicDTO> comics = comicService.getComicsByReadingStatus(status);
            return ResponseEntity.ok(ApiResponse.success(comics));
        } catch (Exception e) {
            log.error("Failed to get comics by reading status: {}", status, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新漫画信息
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ComicDTO>> updateComic(
            @PathVariable @Min(1) Long id,
            @Valid @RequestBody UpdateComicRequest request) {
        try {
            ComicDTO comic = comicService.updateComic(id, request);
            return ResponseEntity.ok(ApiResponse.success("Comic updated successfully", comic));
        } catch (Exception e) {
            log.error("Failed to update comic: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新阅读进度
     */
    @PatchMapping("/{id}/progress")
    public ResponseEntity<ApiResponse<ComicDTO>> updateReadingProgress(
            @PathVariable @Min(1) Long id,
            @RequestParam @Min(0) Integer currentPage) {
        try {
            ComicDTO comic = comicService.updateReadingProgress(id, currentPage);
            return ResponseEntity.ok(ApiResponse.success("Reading progress updated successfully", comic));
        } catch (Exception e) {
            log.error("Failed to update reading progress for comic: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 删除漫画
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteComic(@PathVariable @Min(1) Long id) {
        try {
            comicService.deleteComic(id);
            return ResponseEntity.ok(ApiResponse.success("Comic deleted successfully", null));
        } catch (Exception e) {
            log.error("Failed to delete comic: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取漫画统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Object>> getComicStats() {
        try {
            Long totalCount = comicService.countComics();
            List<Object[]> countByStatus = comicService.countComicsByReadingStatus();
            
            return ResponseEntity.ok(ApiResponse.success(new Object() {
                public final Long totalCount = comicService.countComics();
                public final List<Object[]> countByReadingStatus = comicService.countComicsByReadingStatus();
            }));
        } catch (Exception e) {
            log.error("Failed to get comic stats", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}