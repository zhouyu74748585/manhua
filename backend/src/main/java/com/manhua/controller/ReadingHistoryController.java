package com.manhua.controller;

import com.manhua.common.ApiResponse;
import com.manhua.dto.ReadingHistoryDTO;
import com.manhua.service.ReadingHistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 阅读历史控制器
 */
@RestController
@RequestMapping("/api/reading-history")
@CrossOrigin(origins = "*")
public class ReadingHistoryController {

    @Autowired
    private ReadingHistoryService readingHistoryService;

    /**
     * 获取所有阅读历史
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<ReadingHistoryDTO>>> getAllReadingHistories() {
        try {
            List<ReadingHistoryDTO> histories = readingHistoryService.getAllReadingHistories();
            return ResponseEntity.ok(ApiResponse.success(histories));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取阅读历史失败: " + e.getMessage()));
        }
    }

    /**
     * 分页获取阅读历史
     */
    @GetMapping("/page")
    public ResponseEntity<ApiResponse<Page<ReadingHistoryDTO>>> getReadingHistories(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Page<ReadingHistoryDTO> histories = readingHistoryService.getReadingHistories(page, size);
            return ResponseEntity.ok(ApiResponse.success(histories));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取阅读历史失败: " + e.getMessage()));
        }
    }

    /**
     * 根据ID获取阅读历史
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ReadingHistoryDTO>> getReadingHistoryById(@PathVariable Long id) {
        try {
            Optional<ReadingHistoryDTO> history = readingHistoryService.getReadingHistoryById(id);
            if (history.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(history.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取阅读历史失败: " + e.getMessage()));
        }
    }

    /**
     * 根据漫画ID获取阅读历史
     */
    @GetMapping("/comic/{comicId}")
    public ResponseEntity<ApiResponse<List<ReadingHistoryDTO>>> getReadingHistoriesByComicId(@PathVariable Long comicId) {
        try {
            List<ReadingHistoryDTO> histories = readingHistoryService.getReadingHistoriesByComicId(comicId);
            return ResponseEntity.ok(ApiResponse.success(histories));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取阅读历史失败: " + e.getMessage()));
        }
    }




    /**
     * 获取最近阅读历史
     */
    @GetMapping("/recent")
    public ResponseEntity<ApiResponse<List<ReadingHistoryDTO>>> getRecentReadingHistories(
            @RequestParam(defaultValue = "10") int limit) {
        try {
            List<ReadingHistoryDTO> histories = readingHistoryService.getRecentReadingHistories(limit);
            return ResponseEntity.ok(ApiResponse.success(histories));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取最近阅读历史失败: " + e.getMessage()));
        }
    }

    /**
     * 创建阅读历史
     */
    @PostMapping
    public ResponseEntity<ApiResponse<ReadingHistoryDTO>> createReadingHistory(@Valid @RequestBody ReadingHistoryDTO readingHistoryDTO) {
        try {
            ReadingHistoryDTO createdHistory = readingHistoryService.createReadingHistory(readingHistoryDTO);
            return ResponseEntity.ok(ApiResponse.success(createdHistory));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("创建阅读历史失败: " + e.getMessage()));
        }
    }

    /**
     * 更新阅读历史
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ReadingHistoryDTO>> updateReadingHistory(
            @PathVariable Long id,
            @Valid @RequestBody ReadingHistoryDTO readingHistoryDTO) {
        try {
            ReadingHistoryDTO updatedHistory = readingHistoryService.updateReadingHistory(id, readingHistoryDTO);
            return ResponseEntity.ok(ApiResponse.success(updatedHistory));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("更新阅读历史失败: " + e.getMessage()));
        }
    }

    /**
     * 删除阅读历史
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteReadingHistory(@PathVariable Long id) {
        try {
            readingHistoryService.deleteReadingHistory(id);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除阅读历史失败: " + e.getMessage()));
        }
    }



}