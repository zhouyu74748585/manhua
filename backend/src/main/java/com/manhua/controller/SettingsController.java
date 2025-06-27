package com.manhua.controller;

import com.manhua.service.AppSettingsService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 设置控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/settings")
@CrossOrigin(origins = "*")
public class SettingsController {

    private static final Logger logger = LoggerFactory.getLogger(SettingsController.class);

    @Autowired
    private AppSettingsService settingsService;

    /**
     * 获取应用设置
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getSettings() {
        try {
            Map<String, Object> settings = settingsService.getAllSettings();
            return ResponseEntity.ok(settings);
        } catch (Exception e) {
            logger.error("获取设置失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 保存应用设置
     */
    @PutMapping
    public ResponseEntity<Map<String, Object>> saveSettings(
            @RequestBody Map<String, Object> settings) {
        try {
            settingsService.saveSettings(settings);
            Map<String, Object> updatedSettings = settingsService.getAllSettings();
            return ResponseEntity.ok(updatedSettings);
        } catch (Exception e) {
            logger.error("保存设置失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 重置设置
     */
    @PostMapping("/reset")
    public ResponseEntity<Map<String, Object>> resetSettings() {
        try {
            Map<String, Object> defaultSettings = settingsService.resetToDefaults();
            return ResponseEntity.ok(defaultSettings);
        } catch (Exception e) {
            logger.error("重置设置失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取单个设置
     */
    @GetMapping("/{key}")
    public ResponseEntity<Object> getSetting(@PathVariable String key) {
        try {
            Object value = settingsService.getSetting(key);
            return ResponseEntity.ok(value);
        } catch (Exception e) {
            logger.error("获取设置失败: {}", key, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 保存单个设置
     */
    @PutMapping("/{key}")
    public ResponseEntity<Object> saveSetting(
            @PathVariable String key,
            @RequestBody Object value) {
        try {
            settingsService.saveSetting(key, value);
            Object updatedValue = settingsService.getSetting(key);
            return ResponseEntity.ok(updatedValue);
        } catch (Exception e) {
            logger.error("保存设置失败: {} = {}", key, value, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 删除单个设置
     */
    @DeleteMapping("/{key}")
    public ResponseEntity<Void> deleteSetting(@PathVariable String key) {
        try {
            settingsService.deleteSetting(key);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            logger.error("删除设置失败: {}", key, e);
            return ResponseEntity.internalServerError().build();
        }
    }
}