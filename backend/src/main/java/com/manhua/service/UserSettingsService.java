package com.manhua.service;

import com.manhua.dto.UserSettingsDTO;
import com.manhua.entity.UserSettings;
import com.manhua.repository.UserSettingsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 用户设置服务
 */
@Service
@Transactional
public class UserSettingsService {

    @Autowired
    private UserSettingsRepository userSettingsRepository;

    /**
     * 获取所有用户设置
     */
    @Transactional(readOnly = true)
    public List<UserSettingsDTO> getAllUserSettings() {
        return userSettingsRepository.findAll(Sort.by(Sort.Direction.ASC, "category", "settingKey"))
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 分页获取用户设置
     */
    @Transactional(readOnly = true)
    public Page<UserSettingsDTO> getUserSettings(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "category", "settingKey"));
        return userSettingsRepository.findAll(pageable)
                .map(this::convertToDTO);
    }

    /**
     * 根据ID获取用户设置
     */
    @Transactional(readOnly = true)
    public Optional<UserSettingsDTO> getUserSettingsById(Long id) {
        return userSettingsRepository.findById(id)
                .map(this::convertToDTO);
    }

    /**
     * 根据设置键获取用户设置
     */
    @Transactional(readOnly = true)
    public Optional<UserSettingsDTO> getUserSettingsByKey(String settingKey) {
        return userSettingsRepository.findBySettingKey(settingKey)
                .map(this::convertToDTO);
    }

    /**
     * 获取所有分类
     */
    @Transactional(readOnly = true)
    public List<String> getAllCategories() {
        return userSettingsRepository.findAllCategories();
    }

    /**
     * 创建用户设置
     */
    public UserSettingsDTO createUserSettings(UserSettingsDTO userSettingsDTO) {
        // 检查设置键是否已存在
        if (userSettingsRepository.findBySettingKey(userSettingsDTO.getSettingKey()).isPresent()) {
            throw new RuntimeException("设置键已存在: " + userSettingsDTO.getSettingKey());
        }
        
        UserSettings userSettings = convertToEntity(userSettingsDTO);
        UserSettings savedSettings = userSettingsRepository.save(userSettings);
        return convertToDTO(savedSettings);
    }

    /**
     * 更新用户设置
     */
    public UserSettingsDTO updateUserSettings(Long id, UserSettingsDTO userSettingsDTO) {
        Optional<UserSettings> existingSettings = userSettingsRepository.findById(id);
        if (existingSettings.isPresent()) {
            UserSettings userSettings = existingSettings.get();
            
            // 检查设置键是否与其他记录冲突
            if (userSettingsDTO.getSettingKey() != null && 
                !userSettingsDTO.getSettingKey().equals(userSettings.getSettingKey())) {
                Optional<UserSettings> conflictSettings = userSettingsRepository.findBySettingKey(userSettingsDTO.getSettingKey());
                if (conflictSettings.isPresent() && !conflictSettings.get().getId().equals(id)) {
                    throw new RuntimeException("设置键已存在: " + userSettingsDTO.getSettingKey());
                }
                userSettings.setSettingKey(userSettingsDTO.getSettingKey());
            }
            
            if (userSettingsDTO.getSettingValue() != null) {
                userSettings.setSettingValue(userSettingsDTO.getSettingValue());
            }
            if (userSettingsDTO.getCategory() != null) {
                userSettings.setCategory(userSettingsDTO.getCategory());
            }
            if (userSettingsDTO.getDescription() != null) {
                userSettings.setDescription(userSettingsDTO.getDescription());
            }

            
            UserSettings savedSettings = userSettingsRepository.save(userSettings);
            return convertToDTO(savedSettings);
        }
        throw new RuntimeException("用户设置不存在，ID: " + id);
    }

    /**
     * 更新设置值
     */
    public UserSettingsDTO updateSettingValue(String settingKey, String settingValue) {
        Optional<UserSettings> existingSettings = userSettingsRepository.findBySettingKey(settingKey);
        if (existingSettings.isPresent()) {
            UserSettings userSettings = existingSettings.get();
            userSettings.setSettingValue(settingValue);
            UserSettings savedSettings = userSettingsRepository.save(userSettings);
            return convertToDTO(savedSettings);
        }
        throw new RuntimeException("用户设置不存在，设置键: " + settingKey);
    }

    /**
     * 重置设置为默认值
     */
    public UserSettingsDTO resetToDefault(String settingKey) {
        Optional<UserSettings> existingSettings = userSettingsRepository.findBySettingKey(settingKey);
        if (existingSettings.isPresent()) {
            UserSettings userSettings = existingSettings.get();
            UserSettings savedSettings = userSettingsRepository.save(userSettings);
            return convertToDTO(savedSettings);
        }
        throw new RuntimeException("用户设置不存在，设置键: " + settingKey);
    }

    /**
     * 删除用户设置
     */
    public void deleteUserSettings(Long id) {
        Optional<UserSettings> existingSettings = userSettingsRepository.findById(id);
        if (existingSettings.isPresent()) {
            UserSettings userSettings = existingSettings.get();
            userSettingsRepository.deleteById(id);
        } else {
            throw new RuntimeException("用户设置不存在，ID: " + id);
        }
    }

    /**
     * 根据设置键删除用户设置
     */
    public void deleteUserSettingsByKey(String settingKey) {
        Optional<UserSettings> existingSettings = userSettingsRepository.findBySettingKey(settingKey);
        if (existingSettings.isPresent()) {
            UserSettings userSettings = existingSettings.get();
            userSettingsRepository.delete(userSettings);
        } else {
            throw new RuntimeException("用户设置不存在，设置键: " + settingKey);
        }
    }

    /**
     * 统计用户设置总数
     */
    @Transactional(readOnly = true)
    public long countUserSettings() {
        return userSettingsRepository.countAllSettings();
    }


    /**
     * 获取设置值（带默认值）
     */
    @Transactional(readOnly = true)
    public String getSettingValue(String settingKey, String defaultValue) {
        Optional<UserSettings> settings = userSettingsRepository.findBySettingKey(settingKey);
        if (settings.isPresent()) {
            String value = settings.get().getSettingValue();
            return value != null ? value : defaultValue;
        }
        return defaultValue;
    }

    /**
     * 获取布尔类型设置值
     */
    @Transactional(readOnly = true)
    public boolean getBooleanSetting(String settingKey, boolean defaultValue) {
        String value = getSettingValue(settingKey, String.valueOf(defaultValue));
        return Boolean.parseBoolean(value);
    }

    /**
     * 获取整数类型设置值
     */
    @Transactional(readOnly = true)
    public int getIntegerSetting(String settingKey, int defaultValue) {
        String value = getSettingValue(settingKey, String.valueOf(defaultValue));
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * 实体转DTO
     */
    private UserSettingsDTO convertToDTO(UserSettings userSettings) {
        UserSettingsDTO dto = new UserSettingsDTO();
        dto.setId(userSettings.getId());
        dto.setSettingKey(userSettings.getSettingKey());
        dto.setSettingValue(userSettings.getSettingValue());
        dto.setCategory(userSettings.getCategory());
        dto.setDescription(userSettings.getDescription());
        return dto;
    }

    /**
     * DTO转实体
     */
    private UserSettings convertToEntity(UserSettingsDTO dto) {
        UserSettings userSettings = new UserSettings();
        userSettings.setSettingKey(dto.getSettingKey());
        userSettings.setSettingValue(dto.getSettingValue());
        userSettings.setCategory(dto.getCategory());
        userSettings.setDescription(dto.getDescription());
        return userSettings;
    }
}