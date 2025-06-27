package com.manhua.service;

import com.manhua.entity.AppSettings;
import com.manhua.repository.AppSettingsRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 应用设置服务类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Service
@Transactional
public class AppSettingsService {

    private static final Logger logger = LoggerFactory.getLogger(AppSettingsService.class);

    @Autowired
    private AppSettingsRepository settingsRepository;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * 获取所有设置
     */
    public Map<String, Object> getAllSettings() {
        List<AppSettings> settings = settingsRepository.findAll();
        Map<String, Object> result = new HashMap<>();
        
        for (AppSettings setting : settings) {
            Object value = parseValue(setting.getValue(), setting.getType());
            result.put(setting.getKey(), value);
        }
        
        // 如果没有设置，返回默认设置
        if (result.isEmpty()) {
            return getDefaultSettings();
        }
        
        return result;
    }

    /**
     * 获取单个设置
     */
    public Object getSetting(String key) {
        Optional<AppSettings> setting = settingsRepository.findByKey(key);
        if (setting.isPresent()) {
            return parseValue(setting.get().getValue(), setting.get().getType());
        }
        
        // 返回默认值
        Map<String, Object> defaults = getDefaultSettings();
        return defaults.get(key);
    }

    /**
     * 保存设置
     */
    public void saveSetting(String key, Object value) {
        String stringValue = value != null ? value.toString() : null;
        String type = getValueType(value);
        
        Optional<AppSettings> existing = settingsRepository.findByKey(key);
        if (existing.isPresent()) {
            AppSettings setting = existing.get();
            setting.setValue(stringValue);
            setting.setType(type);
            settingsRepository.save(setting);
        } else {
            AppSettings setting = new AppSettings(key, stringValue, type);
            settingsRepository.save(setting);
        }
    }

    /**
     * 批量保存设置
     */
    public void saveSettings(Map<String, Object> settings) {
        for (Map.Entry<String, Object> entry : settings.entrySet()) {
            saveSetting(entry.getKey(), entry.getValue());
        }
    }

    /**
     * 删除设置
     */
    public void deleteSetting(String key) {
        settingsRepository.deleteByKey(key);
    }

    /**
     * 重置为默认设置
     */
    public Map<String, Object> resetToDefaults() {
        // 删除所有现有设置
        settingsRepository.deleteAll();
        
        // 保存默认设置
        Map<String, Object> defaults = getDefaultSettings();
        saveSettings(defaults);
        
        return defaults;
    }

    /**
     * 获取默认设置
     */
    private Map<String, Object> getDefaultSettings() {
        Map<String, Object> defaults = new HashMap<>();
        
        // 阅读设置
        defaults.put("reader.fitMode", "width");
        defaults.put("reader.readingDirection", "ltr");
        defaults.put("reader.enableZoom", true);
        defaults.put("reader.zoomLevel", 1.0);
        defaults.put("reader.backgroundColor", "#000000");
        defaults.put("reader.enableFullscreen", false);
        
        // 界面设置
        defaults.put("ui.theme", "light");
        defaults.put("ui.language", "zh-CN");
        defaults.put("ui.showThumbnails", true);
        defaults.put("ui.itemsPerPage", 20);
        
        // 扫描设置
        defaults.put("scan.autoScan", false);
        defaults.put("scan.scanInterval", 24);
        defaults.put("scan.deepScan", false);
        
        // 缓存设置
        defaults.put("cache.enabled", true);
        defaults.put("cache.maxSize", 1024);
        defaults.put("cache.ttl", 7);
        
        // 隐私设置
        defaults.put("privacy.enabled", false);
        defaults.put("privacy.clearOnExit", false);
        
        return defaults;
    }

    /**
     * 解析值
     */
    private Object parseValue(String value, String type) {
        if (value == null) {
            return null;
        }
        
        try {
            switch (type) {
                case "boolean":
                    return Boolean.parseBoolean(value);
                case "integer":
                    return Integer.parseInt(value);
                case "double":
                    return Double.parseDouble(value);
                case "long":
                    return Long.parseLong(value);
                default:
                    return value;
            }
        } catch (Exception e) {
            logger.warn("解析设置值失败: {} = {}, type = {}", value, type, e.getMessage());
            return value;
        }
    }

    /**
     * 获取值类型
     */
    private String getValueType(Object value) {
        if (value == null) {
            return "string";
        }
        
        if (value instanceof Boolean) {
            return "boolean";
        } else if (value instanceof Integer) {
            return "integer";
        } else if (value instanceof Double || value instanceof Float) {
            return "double";
        } else if (value instanceof Long) {
            return "long";
        } else {
            return "string";
        }
    }
}