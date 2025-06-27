package com.manhua.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.lang.management.ManagementFactory;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 系统控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/system")
@CrossOrigin(origins = "*")
public class SystemController {

    private static final Logger logger = LoggerFactory.getLogger(SystemController.class);

    @Value("${manhua.version:1.0.0}")
    private String version;

    @Value("${manhua.cache-dir}")
    private String cacheDirectory;

    private final Map<String, Object> cacheStats = new HashMap<>();
    private final List<Map<String, Object>> systemLogs = new ArrayList<>();

    /**
     * 获取系统信息
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getSystemInfo() {
        try {
            Map<String, Object> systemInfo = new HashMap<>();
            
            systemInfo.put("version", version);
            systemInfo.put("platform", System.getProperty("os.name"));
            systemInfo.put("arch", System.getProperty("os.arch"));
            systemInfo.put("javaVersion", System.getProperty("java.version"));
            systemInfo.put("uptime", ManagementFactory.getRuntimeMXBean().getUptime());
            
            // 内存信息
            Runtime runtime = Runtime.getRuntime();
            Map<String, Object> memory = new HashMap<>();
            memory.put("total", runtime.totalMemory());
            memory.put("free", runtime.freeMemory());
            memory.put("used", runtime.totalMemory() - runtime.freeMemory());
            memory.put("max", runtime.maxMemory());
            systemInfo.put("memory", memory);
            
            return ResponseEntity.ok(systemInfo);
        } catch (Exception e) {
            logger.error("获取系统信息失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 检查更新
     */
    @GetMapping("/check-update")
    public ResponseEntity<Map<String, Object>> checkUpdate() {
        try {
            Map<String, Object> updateInfo = new HashMap<>();
            
            // 模拟检查更新逻辑
            updateInfo.put("hasUpdate", false);
            updateInfo.put("currentVersion", version);
            updateInfo.put("latestVersion", version);
            updateInfo.put("message", "当前已是最新版本");
            
            return ResponseEntity.ok(updateInfo);
        } catch (Exception e) {
            logger.error("检查更新失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取日志
     */
    @GetMapping("/logs")
    public ResponseEntity<Map<String, Object>> getLogs(
            @RequestParam(required = false) String level,
            @RequestParam(defaultValue = "100") int limit) {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 模拟日志数据
            List<Map<String, Object>> logs = new ArrayList<>();
            String[] levels = {"INFO", "WARN", "ERROR", "DEBUG"};
            String[] messages = {
                "应用启动成功",
                "扫描漫画库完成",
                "用户访问首页",
                "缓存清理完成",
                "数据库连接正常"
            };
            
            for (int i = 0; i < Math.min(limit, 50); i++) {
                Map<String, Object> log = new HashMap<>();
                log.put("timestamp", LocalDateTime.now().minusMinutes(i).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                log.put("level", levels[i % levels.length]);
                log.put("message", messages[i % messages.length]);
                
                if (level == null || level.equals(log.get("level"))) {
                    logs.add(log);
                }
            }
            
            result.put("logs", logs);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("获取日志失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 清理缓存
     */
    @PostMapping("/clear-cache")
    public ResponseEntity<Map<String, Object>> clearCache() {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 清理缓存目录
            long clearedSize = 0;
            int clearedCount = 0;
            
            File cacheDir = new File(cacheDirectory);
            if (cacheDir.exists() && cacheDir.isDirectory()) {
                File[] files = cacheDir.listFiles();
                if (files != null) {
                    for (File file : files) {
                        if (file.isFile()) {
                            clearedSize += file.length();
                            clearedCount++;
                            file.delete();
                        }
                    }
                }
            }
            
            // 清理JVM缓存
            System.gc();
            
            result.put("cleared", clearedCount);
            result.put("size", clearedSize);
            result.put("message", String.format("已清理 %d 个缓存文件，释放 %d 字节空间", clearedCount, clearedSize));
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            logger.error("清理缓存失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取缓存统计
     */
    @GetMapping("/cache-stats")
    public ResponseEntity<Map<String, Object>> getCacheStats() {
        try {
            Map<String, Object> stats = new HashMap<>();
            
            // 计算缓存目录大小
            long totalSize = 0;
            int itemCount = 0;
            
            File cacheDir = new File(cacheDirectory);
            if (cacheDir.exists() && cacheDir.isDirectory()) {
                File[] files = cacheDir.listFiles();
                if (files != null) {
                    for (File file : files) {
                        if (file.isFile()) {
                            totalSize += file.length();
                            itemCount++;
                        }
                    }
                }
            }
            
            stats.put("totalSize", totalSize);
            stats.put("itemCount", itemCount);
            stats.put("hitRate", 0.85); // 模拟命中率
            
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            logger.error("获取缓存统计失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}