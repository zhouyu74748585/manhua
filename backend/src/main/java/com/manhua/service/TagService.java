package com.manhua.service;

import com.manhua.dto.TagDTO;
import com.manhua.entity.Tag;
import com.manhua.repository.TagRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 标签服务层
 */
@Service
public class TagService {

    private static final Logger log = LoggerFactory.getLogger(TagService.class);
    @Autowired
    private TagRepository tagRepository;

    /**
     * 获取所有标签
     */
    public List<TagDTO> getAllTags() {
        log.debug("Getting all tags");
        return tagRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据ID获取标签
     */
    public Optional<TagDTO> getTagById(Long id) {
        log.debug("Getting tag by id: {}", id);
        return tagRepository.findById(id)
                .map(this::convertToDTO);
    }

    /**
     * 根据名称获取标签
     */
    public Optional<TagDTO> getTagByName(String name) {
        log.debug("Getting tag by name: {}", name);
        return tagRepository.findByName(name)
                .map(this::convertToDTO);
    }

    /**
     * 根据分类获取标签
     */
    public List<TagDTO> getTagsByCategory(String category) {
        log.debug("Getting tags by category: {}", category);
        return tagRepository.findByCategory(category).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 搜索标签
     */
    public List<TagDTO> searchTags(String keyword) {
        log.debug("Searching tags with keyword: {}", keyword);
        return tagRepository.findByNameContaining(keyword).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取热门标签
     */
    public List<TagDTO> getPopularTags() {
        log.debug("Getting popular tags");
        return tagRepository.findPopularTags().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取使用次数大于指定值的标签
     */
    public List<TagDTO> getTagsByUsageCount(Integer minCount) {
        log.debug("Getting tags with usage count > {}", minCount);
        return tagRepository.findByUsageCountGreaterThan(minCount).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取所有分类
     */
    public List<String> getAllCategories() {
        log.debug("Getting all categories");
        return tagRepository.findAllCategories();
    }

    /**
     * 根据漫画ID获取标签
     */
    public List<TagDTO> getTagsByComicId(Long comicId) {
        log.debug("Getting tags by comic id: {}", comicId);
        return tagRepository.findByComicId(comicId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据库ID获取标签
     */
    public List<TagDTO> getTagsByLibraryId(Long libraryId) {
        log.debug("Getting tags by library id: {}", libraryId);
        return tagRepository.findByLibraryId(libraryId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 创建标签
     */
    @Transactional
    public TagDTO createTag(String name, String color, String category, String description) {
        log.info("Creating tag: {}", name);
        
        // 检查标签是否已存在
        if (tagRepository.findByName(name).isPresent()) {
            throw new RuntimeException("Tag with name '" + name + "' already exists");
        }
        
        Tag tag = new Tag();
        tag.setName(name);
        tag.setColor(color);
        tag.setCategory(category);
        tag.setDescription(description);
        tag.setUsageCount(0);
        tag.setCreateTime(LocalDateTime.now());
        tag.setUpdateTime(LocalDateTime.now());
        
        Tag savedTag = tagRepository.save(tag);
        log.info("Tag created successfully: {}", savedTag.getId());
        
        return convertToDTO(savedTag);
    }

    /**
     * 更新标签
     */
    @Transactional
    public TagDTO updateTag(Long id, String name, String color, String category, String description) {
        log.info("Updating tag: {}", id);
        
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tag not found with id: " + id));
        
        // 检查名称是否与其他标签冲突
        if (name != null && !name.equals(tag.getName())) {
            Optional<Tag> existingByName = tagRepository.findByName(name);
            if (existingByName.isPresent() && !existingByName.get().getId().equals(id)) {
                throw new RuntimeException("Tag with name '" + name + "' already exists");
            }
            tag.setName(name);
        }
        
        if (color != null) {
            tag.setColor(color);
        }
        if (category != null) {
            tag.setCategory(category);
        }
        if (description != null) {
            tag.setDescription(description);
        }
        
        tag.setUpdateTime(LocalDateTime.now());
        
        Tag savedTag = tagRepository.save(tag);
        log.info("Tag updated successfully: {}", savedTag.getId());
        
        return convertToDTO(savedTag);
    }

    /**
     * 删除标签
     */
    @Transactional
    public void deleteTag(Long id) {
        log.info("Deleting tag: {}", id);
        
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tag not found with id: " + id));
        
        tagRepository.delete(tag);
        log.info("Tag deleted successfully: {}", id);
    }

    /**
     * 增加标签使用次数
     */
    @Transactional
    public void incrementUsageCount(Long id) {
        log.debug("Incrementing usage count for tag: {}", id);
        
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tag not found with id: " + id));
        
        tag.setUsageCount(tag.getUsageCount() + 1);
        tag.setUpdateTime(LocalDateTime.now());
        tagRepository.save(tag);
    }

    /**
     * 减少标签使用次数
     */
    @Transactional
    public void decrementUsageCount(Long id) {
        log.debug("Decrementing usage count for tag: {}", id);
        
        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tag not found with id: " + id));
        
        if (tag.getUsageCount() > 0) {
            tag.setUsageCount(tag.getUsageCount() - 1);
            tag.setUpdateTime(LocalDateTime.now());
            tagRepository.save(tag);
        }
    }

    /**
     * 获取未使用的标签
     */
    public List<TagDTO> getUnusedTags() {
        log.debug("Getting unused tags");
        return tagRepository.findUnusedTags().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 清理未使用的标签
     */
    @Transactional
    public int cleanupUnusedTags() {
        log.info("Cleaning up unused tags");
        
        List<Tag> unusedTags = tagRepository.findUnusedTags();
        int count = unusedTags.size();
        
        tagRepository.deleteAll(unusedTags);
        log.info("Cleaned up {} unused tags", count);
        
        return count;
    }

    /**
     * 统计标签数量
     */
    public Long countTags() {
        return tagRepository.countAllTags();
    }

    /**
     * 统计各分类的标签数量
     */
    public List<Object[]> countTagsByCategory() {
        return tagRepository.countByCategory();
    }

    /**
     * 转换为DTO
     */
    private TagDTO convertToDTO(Tag tag) {
        TagDTO dto = new TagDTO();
        dto.setId(tag.getId());
        dto.setName(tag.getName());
        dto.setColor(tag.getColor());
        dto.setCategory(tag.getCategory());
        dto.setDescription(tag.getDescription());
        dto.setUsageCount(tag.getUsageCount());
        dto.setCreateTime(tag.getCreateTime());
        dto.setUpdateTime(tag.getUpdateTime());
        dto.setComicCount(tag.getComicCount());
        return dto;
    }
}