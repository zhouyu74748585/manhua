package com.manhua.controller;

import com.manhua.entity.MangaLibrary;
import com.manhua.service.FileScanService;
import com.manhua.service.MangaLibraryService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * 漫画库控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/libraries")
@CrossOrigin(origins = "*")
public class MangaLibraryController {

    private static final Logger logger = LoggerFactory.getLogger(MangaLibraryController.class);

    @Autowired
    private MangaLibraryService libraryService;

    @Autowired
    private FileScanService scanService;

    /**
     * 获取所有漫画库
     */
    @GetMapping
    public ResponseEntity<List<MangaLibrary>> getAllLibraries() {
        try {
            List<MangaLibrary> libraries = libraryService.getAllLibraries();
            return ResponseEntity.ok(libraries);
        } catch (Exception e) {
            logger.error("获取漫画库列表失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 分页获取漫画库
     */
    @GetMapping("/page")
    public ResponseEntity<Page<MangaLibrary>> getLibrariesPage(Pageable pageable) {
        try {
            Page<MangaLibrary> libraries = libraryService.getLibraries(pageable);
            return ResponseEntity.ok(libraries);
        } catch (Exception e) {
            logger.error("分页获取漫画库失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据ID获取漫画库
     */
    @GetMapping("/{id}")
    public ResponseEntity<MangaLibrary> getLibraryById(@PathVariable Long id) {
        try {
            return libraryService.getLibraryById(id)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            logger.error("获取漫画库失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 创建漫画库
     */
    @PostMapping
    public ResponseEntity<MangaLibrary> createLibrary(@Valid @RequestBody MangaLibrary library) {
        try {
            MangaLibrary createdLibrary = libraryService.createLibrary(library);
            return ResponseEntity.ok(createdLibrary);
        } catch (IllegalArgumentException e) {
            logger.warn("创建漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("创建漫画库失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新漫画库
     */
    @PutMapping("/{id}")
    public ResponseEntity<Object> updateLibrary(
            @PathVariable Long id,
            @Valid @RequestBody Map<String, Object> request) {
        try {
            // 从请求中提取漫画库信息和旧密码
            MangaLibrary library = new MangaLibrary();
            library.setId(id);
            library.setName((String) request.get("name"));
            library.setDescription((String) request.get("description"));
            library.setPath((String) request.get("path"));
            library.setIsActive((Boolean) request.get("isActive"));
            library.setIsPrivate((Boolean) request.get("isPrivate"));
            library.setAccessPassword((String) request.get("accessPassword"));
            library.setAutoScan((Boolean) request.get("autoScan"));
            library.setScanInterval((Integer) request.get("scanInterval"));
            
            // 处理库类型
            String typeStr = (String) request.get("type");
            if (typeStr != null) {
                library.setType(MangaLibrary.LibraryType.valueOf(typeStr));
            }
            
            // 处理网络文件系统配置
            library.setUsername((String) request.get("username"));
            library.setPassword((String) request.get("password"));
            library.setHost((String) request.get("host"));
            library.setPort((Integer) request.get("port"));
            library.setShareName((String) request.get("shareName"));
            
            String oldPassword = (String) request.get("oldPassword");
            
            MangaLibrary updatedLibrary = libraryService.updateLibrary(id, library, oldPassword);
            return ResponseEntity.ok(updatedLibrary);
        } catch (IllegalArgumentException e) {
            logger.warn("更新漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("更新漫画库失败: {}", id, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "更新失败"));
        }
    }

    /**
     * 删除漫画库
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLibrary(@PathVariable Long id) {
        try {
            libraryService.deleteLibrary(id);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("删除漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("删除漫画库失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 激活漫画库
     */
    @PostMapping("/{id}/activate")
    public ResponseEntity<Map<String, Object>> activateLibrary(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> request) {
        try {
            String password = request != null ? request.get("password") : null;
            libraryService.activateLibrary(id, password);
            return ResponseEntity.ok(Map.of("message", "漫画库激活成功"));
        } catch (IllegalArgumentException e) {
            logger.warn("激活漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("激活漫画库失败: {}", id, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "激活失败"));
        }
    }

    /**
     * 停用漫画库
     */
    @PostMapping("/{id}/deactivate")
    public ResponseEntity<Map<String, Object>> deactivateLibrary(@PathVariable Long id) {
        try {
            libraryService.deactivateLibrary(id);
            return ResponseEntity.ok(Map.of("message", "漫画库停用成功"));
        } catch (IllegalArgumentException e) {
            logger.warn("停用漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("停用漫画库失败: {}", id, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "停用失败"));
        }
    }

    /**
     * 设置当前漫画库
     */
    @PostMapping("/{id}/set-current")
    public ResponseEntity<Void> setCurrentLibrary(@PathVariable Long id) {
        try {
            libraryService.setCurrentLibrary(id);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("设置当前漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("设置当前漫画库失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取当前漫画库
     */
    @GetMapping("/current")
    public ResponseEntity<MangaLibrary> getCurrentLibrary() {
        try {
            return libraryService.getCurrentLibrary()
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            logger.error("获取当前漫画库失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取激活的漫画库
     */
    @GetMapping("/active")
    public ResponseEntity<List<MangaLibrary>> getActiveLibraries() {
        try {
            List<MangaLibrary> libraries = libraryService.getActiveLibraries();
            return ResponseEntity.ok(libraries);
        } catch (Exception e) {
            logger.error("获取激活漫画库失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据类型获取漫画库
     */
    @GetMapping("/type/{type}")
    public ResponseEntity<List<MangaLibrary>> getLibrariesByType(
            @PathVariable MangaLibrary.LibraryType type) {
        try {
            List<MangaLibrary> libraries = libraryService.getLibrariesByType(type);
            return ResponseEntity.ok(libraries);
        } catch (Exception e) {
            logger.error("根据类型获取漫画库失败: {}", type, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 搜索漫画库
     */
    @GetMapping("/search")
    public ResponseEntity<List<MangaLibrary>> searchLibraries(
            @RequestParam String keyword) {
        try {
            List<MangaLibrary> libraries = libraryService.searchLibraries(keyword);
            return ResponseEntity.ok(libraries);
        } catch (Exception e) {
            logger.error("搜索漫画库失败: {}", keyword, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 扫描漫画库
     */
    @PostMapping("/{id}/scan")
    public ResponseEntity<Object> scanLibrary(@PathVariable Long id) {
        try {
            CompletableFuture<FileScanService.ScanResult> future = scanService.scanLibrary(id);
            return ResponseEntity.ok(Map.of("msg", "开始扫描任务"));
        } catch (IllegalArgumentException e) {
            logger.warn("扫描漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("扫描漫画库失败: {}", id, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "扫描失败"));
        }
    }

    /**
     * 快速扫描漫画库
     */
    @PostMapping("/{id}/quick-scan")
    public ResponseEntity<Map<String, Object>> quickScanLibrary(@PathVariable Long id) {
        try {
            CompletableFuture<FileScanService.ScanResult> future = scanService.quickScanLibrary(id);

            return ResponseEntity.ok(Map.of(
                    "message", "快速扫描已开始",
                    "libraryId", id
            ));
        } catch (IllegalArgumentException e) {
            logger.warn("快速扫描漫画库参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("快速扫描漫画库失败: {}", id, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "快速扫描失败"));
        }
    }

    /**
     * 测试漫画库连接
     */
    @PostMapping("/{id}/test-connection")
    public ResponseEntity<Map<String, Object>> testConnection(@PathVariable Long id) {
        try {
            boolean connected = libraryService.testLibraryConnection(id);
            return ResponseEntity.ok(Map.of(
                    "connected", connected,
                    "message", connected ? "连接成功" : "连接失败"
            ));
        } catch (IllegalArgumentException e) {
            logger.warn("测试连接参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            logger.error("测试连接失败: {}", id, e);
            return ResponseEntity.internalServerError().body(Map.of("error", "测试连接失败"));
        }
    }

    /**
     * 更新漫画库统计信息
     */
    @PostMapping("/{id}/update-stats")
    public ResponseEntity<Void> updateLibraryStats(@PathVariable Long id) {
        try {
            libraryService.updateLibraryStatistics(id);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("更新统计信息参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新统计信息失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**

    /**
     * 批量更新漫画库状态
     */
    @PostMapping("/batch-update-status")
    public ResponseEntity<Void> batchUpdateStatus(
            @RequestBody Map<String, Object> request) {
        try {
            @SuppressWarnings("unchecked")
            List<Long> libraryIds = (List<Long>) request.get("libraryIds");
            Boolean active = (Boolean) request.get("active");

            if (libraryIds == null || active == null) {
                return ResponseEntity.badRequest().build();
            }

            libraryService.updateLibrariesStatus(libraryIds, active);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            logger.error("批量更新状态失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 清理非激活的漫画库
     */
    @PostMapping("/cleanup-inactive")
    public ResponseEntity<Map<String, Object>> cleanupInactiveLibraries() {
        try {
            libraryService.cleanupInactiveLibraries();
            return ResponseEntity.ok(Map.of(
                    "message", "清理完成"
            ));
        } catch (Exception e) {
            logger.error("清理非激活漫画库失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "清理失败"));
        }
    }

    /**
     * 获取需要扫描的漫画库
     */
    @GetMapping("/scan-needed")
    public ResponseEntity<List<MangaLibrary>> getLibrariesNeedingScan() {
        try {
            List<MangaLibrary> libraries = libraryService.getLibrariesNeedingScan();
            return ResponseEntity.ok(libraries);
        } catch (Exception e) {
            logger.error("获取需要扫描的漫画库失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 验证漫画库配置
     */
    @PostMapping("/validate")
    public ResponseEntity<Map<String, Object>> validateLibrary(
            @RequestBody MangaLibrary library) {
        try {
            libraryService.validateLibrary(library);
            return ResponseEntity.ok(Map.of(
                    "valid", "ok"
            ));
        } catch (Exception e) {
            logger.error("验证漫画库配置失败", e);
            return ResponseEntity.internalServerError().body(Map.of("error", "验证失败"));
        }
    }

    /**
     * 导出漫画库配置
     */
    @GetMapping("/export")
    public ResponseEntity<List<MangaLibrary>> exportLibraries() {
        try {
            List<MangaLibrary> libraries = libraryService.getAllLibraries();
            // 清除敏感信息
            libraries.forEach(library -> {
                library.setPassword(null);
            });
            return ResponseEntity.ok(libraries);
        } catch (Exception e) {
            logger.error("导出漫画库配置失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

}
