package com.manhua.controller;

import com.manhua.entity.Manga;
import com.manhua.service.FileScanService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * 文件扫描控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/file-scan")
@CrossOrigin(origins = "*")
public class FileScanController {

    private static final Logger logger = LoggerFactory.getLogger(FileScanController.class);

    @Autowired
    private FileScanService fileScanService;

    /**
     * 扫描漫画库
     */
    @PostMapping("/library/{libraryId}")
    public ResponseEntity<Map<String, Object>> scanLibrary(@PathVariable Long libraryId) {
        try {
            CompletableFuture<FileScanService.ScanResult> future = fileScanService.scanLibrary(libraryId);
            Map<String, Object> result = Map.of(
                "message", "扫描任务已启动",
                "libraryId", libraryId,
                "status", "running"
            );
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            logger.warn("扫描漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("扫描漫画库失败: {}", libraryId, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "扫描失败"));
        }
    }

    /**
     * 快速扫描漫画库（仅检查新增和删除）
     */
    @PostMapping("/library/{libraryId}/quick")
    public ResponseEntity<Map<String, Object>> quickScanLibrary(@PathVariable Long libraryId) {
        try {
            CompletableFuture<FileScanService.ScanResult> future = fileScanService.quickScanLibrary(libraryId);
            Map<String, Object> result = Map.of(
                "message", "快速扫描任务已启动",
                "libraryId", libraryId,
                "status", "running"
            );
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            logger.warn("快速扫描漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("快速扫描漫画库失败: {}", libraryId, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "快速扫描失败"));
        }
    }

    /**
     * 扫描单个文件
     */
    @PostMapping("/file")
    public ResponseEntity<Object> scanFile(
            @RequestBody Map<String, Object> request) {
        try {
            String filePath = (String) request.get("filePath");
            Long libraryId = ((Number) request.get("libraryId")).longValue();

            if (filePath == null || libraryId == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "文件路径和漫画库ID不能为空"));
            }

            Manga result = fileScanService.scanSingleFile(filePath, libraryId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            logger.warn("扫描单个文件参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("扫描单个文件失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "扫描文件失败"));
        }
    }

    /**
     * 清理扫描历史
     */
    @DeleteMapping("/history")
    public ResponseEntity<Map<String, Object>> clearScanHistory() {
        try {
            fileScanService.clearScanHistory();
            return ResponseEntity.ok(Map.of("message", "扫描历史已清理"));
        } catch (Exception e) {
            logger.error("清理扫描历史失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "清理扫描历史失败"));
        }
    }

    /**
     * 获取扫描统计信息
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getScanStatistics() {
        try {
            Map<String, Object> stats = fileScanService.getScanStatistics();
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            logger.error("获取扫描统计信息失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "获取扫描统计信息失败"));
        }
    }

    /**
     * 验证文件
     */
    @PostMapping("/validate")
    public ResponseEntity<Map<String, Object>> validateFile(
            @RequestBody Map<String, String> request) {
        try {
            String filePath = request.get("filePath");
            if (filePath == null || filePath.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "文件路径不能为空"));
            }

            Map<String, Object> result = fileScanService.validateFile(filePath);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("验证文件失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "验证文件失败"));
        }
    }

    /**
     * 提取文件元数据
     */
    @PostMapping("/metadata")
    public ResponseEntity<Map<String, Object>> extractMetadata(
            @RequestBody Map<String, String> request) {
        try {
            String filePath = request.get("filePath");
            if (filePath == null || filePath.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "文件路径不能为空"));
            }

            Map<String, Object> metadata = fileScanService.extractMetadata(filePath);
            return ResponseEntity.ok(metadata);
        } catch (Exception e) {
            logger.error("提取文件元数据失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "提取元数据失败"));
        }
    }

}
