package com.manhua.controller;

import com.manhua.common.ApiResponse;
import com.manhua.dto.UserSettingsDTO;
import com.manhua.service.UserSettingsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 用户设置控制器
 */
@RestController
@RequestMapping("/api/user-settings")
@CrossOrigin(origins = "*")
public class UserSettingsController {

    @Autowired
    private UserSettingsService userSettingsService;

    /**
     * 获取所有用户设置
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<UserSettingsDTO>>> getAllUserSettings() {
        try {
            List<UserSettingsDTO> settings = userSettingsService.getAllUserSettings();
            return ResponseEntity.ok(ApiResponse.success(settings));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取用户设置失败: " + e.getMessage()));
        }
    }

    /**
     * 分页获取用户设置
     */
    @GetMapping("/page")
    public ResponseEntity<ApiResponse<Page<UserSettingsDTO>>> getUserSettings(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Page<UserSettingsDTO> settings = userSettingsService.getUserSettings(page, size);
            return ResponseEntity.ok(ApiResponse.success(settings));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取用户设置失败: " + e.getMessage()));
        }
    }

    /**
     * 根据ID获取用户设置
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserSettingsDTO>> getUserSettingsById(@PathVariable Long id) {
        try {
            Optional<UserSettingsDTO> settings = userSettingsService.getUserSettingsById(id);
            if (settings.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(settings.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取用户设置失败: " + e.getMessage()));
        }
    }

    /**
     * 根据设置键获取用户设置
     */
    @GetMapping("/key/{settingKey}")
    public ResponseEntity<ApiResponse<UserSettingsDTO>> getUserSettingsByKey(@PathVariable String settingKey) {
        try {
            Optional<UserSettingsDTO> settings = userSettingsService.getUserSettingsByKey(settingKey);
            if (settings.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(settings.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取用户设置失败: " + e.getMessage()));
        }
    }


    /**
     * 获取所有分类
     */
    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<String>>> getAllCategories() {
        try {
            List<String> categories = userSettingsService.getAllCategories();
            return ResponseEntity.ok(ApiResponse.success(categories));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取分类失败: " + e.getMessage()));
        }
    }

    /**
     * 创建用户设置
     */
    @PostMapping
    public ResponseEntity<ApiResponse<UserSettingsDTO>> createUserSettings(@Valid @RequestBody UserSettingsDTO userSettingsDTO) {
        try {
            UserSettingsDTO createdSettings = userSettingsService.createUserSettings(userSettingsDTO);
            return ResponseEntity.ok(ApiResponse.success(createdSettings));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("创建用户设置失败: " + e.getMessage()));
        }
    }

    /**
     * 更新用户设置
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<UserSettingsDTO>> updateUserSettings(
            @PathVariable Long id,
            @Valid @RequestBody UserSettingsDTO userSettingsDTO) {
        try {
            UserSettingsDTO updatedSettings = userSettingsService.updateUserSettings(id, userSettingsDTO);
            return ResponseEntity.ok(ApiResponse.success(updatedSettings));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("更新用户设置失败: " + e.getMessage()));
        }
    }

    /**
     * 更新设置值
     */
    @PutMapping("/value/{settingKey}")
    public ResponseEntity<ApiResponse<UserSettingsDTO>> updateSettingValue(
            @PathVariable String settingKey,
            @RequestBody Map<String, String> request) {
        try {
            String settingValue = request.get("settingValue");
            UserSettingsDTO updatedSettings = userSettingsService.updateSettingValue(settingKey, settingValue);
            return ResponseEntity.ok(ApiResponse.success(updatedSettings));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("更新设置值失败: " + e.getMessage()));
        }
    }

    /**
     * 重置设置为默认值
     */
    @PutMapping("/reset/{settingKey}")
    public ResponseEntity<ApiResponse<UserSettingsDTO>> resetToDefault(@PathVariable String settingKey) {
        try {
            UserSettingsDTO resetSettings = userSettingsService.resetToDefault(settingKey);
            return ResponseEntity.ok(ApiResponse.success(resetSettings));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("重置设置失败: " + e.getMessage()));
        }
    }

    /**
     * 删除用户设置
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUserSettings(@PathVariable Long id) {
        try {
            userSettingsService.deleteUserSettings(id);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除用户设置失败: " + e.getMessage()));
        }
    }

    /**
     * 根据设置键删除用户设置
     */
    @DeleteMapping("/key/{settingKey}")
    public ResponseEntity<ApiResponse<Void>> deleteUserSettingsByKey(@PathVariable String settingKey) {
        try {
            userSettingsService.deleteUserSettingsByKey(settingKey);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("删除用户设置失败: " + e.getMessage()));
        }
    }

    /**
     * 获取统计信息
     */
    @GetMapping("/statistics")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getStatistics() {
        try {
            Map<String, Object> statistics = new HashMap<>();
            
            // 统计用户设置总数
            long totalCount = userSettingsService.countUserSettings();
            statistics.put("totalCount", totalCount);

            return ResponseEntity.ok(ApiResponse.success(statistics));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取统计信息失败: " + e.getMessage()));
        }
    }

    /**
     * 获取设置值（带默认值）
     */
    @GetMapping("/value/{settingKey}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSettingValue(
            @PathVariable String settingKey,
            @RequestParam(required = false) String defaultValue) {
        try {
            String value = userSettingsService.getSettingValue(settingKey, defaultValue);
            Map<String, Object> result = new HashMap<>();
            result.put("settingKey", settingKey);
            result.put("settingValue", value);
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取设置值失败: " + e.getMessage()));
        }
    }

    /**
     * 获取布尔类型设置值
     */
    @GetMapping("/boolean/{settingKey}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getBooleanSetting(
            @PathVariable String settingKey,
            @RequestParam(defaultValue = "false") boolean defaultValue) {
        try {
            boolean value = userSettingsService.getBooleanSetting(settingKey, defaultValue);
            Map<String, Object> result = new HashMap<>();
            result.put("settingKey", settingKey);
            result.put("settingValue", value);
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取布尔设置值失败: " + e.getMessage()));
        }
    }

    /**
     * 获取整数类型设置值
     */
    @GetMapping("/integer/{settingKey}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getIntegerSetting(
            @PathVariable String settingKey,
            @RequestParam(defaultValue = "0") int defaultValue) {
        try {
            int value = userSettingsService.getIntegerSetting(settingKey, defaultValue);
            Map<String, Object> result = new HashMap<>();
            result.put("settingKey", settingKey);
            result.put("settingValue", value);
            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("获取整数设置值失败: " + e.getMessage()));
        }
    }
}