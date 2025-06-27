package com.manhua.service;

import com.manhua.entity.MangaTag;
import com.manhua.entity.Manga;
import com.manhua.repository.MangaTagRepository;
import com.manhua.repository.MangaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 漫画标签服务类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Service
@Transactional
public class MangaTagService {

    private static final Logger logger = LoggerFactory.getLogger(MangaTagService.class);

    @Autowired
    private MangaTagRepository tagRepository;

    @Autowired
    private MangaRepository mangaRepository;

    /**
     * 获取所有标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> getAllTags() {
        return tagRepository.findAll();
    }

    /**
     * 根据ID获取标签
     */
    @Transactional(readOnly = true)
    public Optional<MangaTag> getTagById(Long id) {
        return tagRepository.findById(id);
    }

    /**
     * 根据名称获取标签
     */
    @Transactional(readOnly = true)
    public Optional<MangaTag> getTagByName(String name) {
        return tagRepository.findByName(name);
    }

    /**
     * 根据漫画ID获取所有标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> getTagsByMangaId(Long mangaId) {
        return tagRepository.findByMangaId(mangaId);
    }

    /**
     * 根据漫画库ID获取所有标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> getTagsByLibraryId(Long libraryId) {
        return tagRepository.findByLibraryId(libraryId);
    }

    /**
     * 获取所有不重复的标签名称
     */
    @Transactional(readOnly = true)
    public List<String> getDistinctTagNames() {
        return tagRepository.findDistinctTagNames();
    }

    /**
     * 获取指定漫画库中所有不重复的标签名称
     */
    @Transactional(readOnly = true)
    public List<String> getDistinctTagNamesByLibraryId(Long libraryId) {
        return tagRepository.findDistinctTagNamesByLibraryId(libraryId);
    }

    /**
     * 为漫画添加标签
     */
    public MangaTag addTagToManga(Long mangaId, String tagName) {
        return addTagToManga(mangaId, tagName, null, null);
    }

    /**
     * 为漫画添加标签（带颜色和描述）
     */
    public MangaTag addTagToManga(Long mangaId, String tagName, String color, String description) {
        if (!StringUtils.hasText(tagName)) {
            throw new IllegalArgumentException("标签名称不能为空");
        }

        Manga manga = mangaRepository.findById(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("漫画不存在: " + mangaId));

        // 检查标签是否已存在于该漫画中
        if (tagRepository.existsByNameAndMangaId(tagName, mangaId)) {
            throw new IllegalArgumentException("标签已存在于该漫画中: " + tagName);
        }

        MangaTag tag = new MangaTag();
        tag.setName(tagName.trim());
        tag.setManga(manga);

        if (StringUtils.hasText(color)) {
            tag.setColor(color);
        }
        if (StringUtils.hasText(description)) {
            tag.setDescription(description);
        }

        MangaTag savedTag = tagRepository.save(tag);
        logger.info("为漫画 {} 添加标签: {}", mangaId, tagName);

        return savedTag;
    }

    /**
     * 批量为漫画添加标签
     */
    public List<MangaTag> addTagsToManga(Long mangaId, List<String> tagNames) {
        Manga manga = mangaRepository.findById(mangaId)
                .orElseThrow(() -> new IllegalArgumentException("漫画不存在: " + mangaId));

        // 获取已存在的标签名称
        List<String> existingTagNames = tagRepository.findByMangaId(mangaId)
                .stream()
                .map(MangaTag::getName)
                .collect(Collectors.toList());

        // 过滤出新标签
        List<String> newTagNames = tagNames.stream()
                .filter(StringUtils::hasText)
                .map(String::trim)
                .filter(name -> !existingTagNames.contains(name))
                .distinct()
                .collect(Collectors.toList());

        // 创建新标签
        List<MangaTag> newTags = newTagNames.stream()
                .map(name -> {
                    MangaTag tag = new MangaTag();
                    tag.setName(name);
                    tag.setManga(manga);
                    return tag;
                })
                .collect(Collectors.toList());

        List<MangaTag> savedTags = tagRepository.saveAll(newTags);
        logger.info("为漫画 {} 批量添加 {} 个标签", mangaId, savedTags.size());

        return savedTags;
    }

    /**
     * 从漫画中移除标签
     */
    public void removeTagFromManga(Long mangaId, String tagName) {
        MangaTag tag = tagRepository.findByMangaId(mangaId)
                .stream()
                .filter(t -> t.getName().equals(tagName))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("标签不存在: " + tagName));

        tagRepository.delete(tag);
        logger.info("从漫画 {} 移除标签: {}", mangaId, tagName);
    }

    /**
     * 批量从漫画中移除标签
     */
    public void removeTagsFromManga(Long mangaId, List<String> tagNames) {
        tagRepository.deleteByMangaIdAndNameIn(mangaId, tagNames);
        logger.info("从漫画 {} 批量移除 {} 个标签", mangaId, tagNames.size());
    }

    /**
     * 删除漫画的所有标签
     */
    public void removeAllTagsFromManga(Long mangaId) {
        tagRepository.deleteByMangaId(mangaId);
        logger.info("删除漫画 {} 的所有标签", mangaId);
    }

    /**
     * 更新标签信息
     */
    public MangaTag updateTag(Long tagId, MangaTag tagDetails) {
        MangaTag tag = tagRepository.findById(tagId)
                .orElseThrow(() -> new IllegalArgumentException("标签不存在: " + tagId));

        if (StringUtils.hasText(tagDetails.getName())) {
            tag.setName(tagDetails.getName().trim());
        }
        if (StringUtils.hasText(tagDetails.getColor())) {
            tag.setColor(tagDetails.getColor().trim());
        }
        tag.setDescription(tagDetails.getDescription()); // 允许设置为null来清空描述

        MangaTag savedTag = tagRepository.save(tag);
        logger.info("更新标签: {} (ID: {})", savedTag.getName(), tagId);

        return savedTag;
    }

    /**
     * 更新标签颜色
     */
    public void updateTagColor(String tagName, String color) {
        tagRepository.updateTagColor(tagName, color);
        logger.info("更新标签 {} 颜色为: {}", tagName, color);
    }

    /**
     * 批量更新标签颜色
     */
    public void updateTagsColor(List<String> tagNames, String color) {
        tagRepository.updateTagsColor(tagNames, color);
        logger.info("批量更新 {} 个标签颜色为: {}", tagNames.size(), color);
    }

    /**
     * 重命名标签
     */
    public void renameTag(String oldName, String newName) {
        if (!StringUtils.hasText(newName)) {
            throw new IllegalArgumentException("新标签名称不能为空");
        }

        // 检查新名称是否已存在
        if (tagRepository.existsByNameIgnoreCase(newName)) {
            throw new IllegalArgumentException("标签名称已存在: " + newName);
        }

        tagRepository.renameTag(oldName, newName.trim());
        logger.info("重命名标签: {} -> {}", oldName, newName);
    }

    /**
     * 合并标签
     */
    public void mergeTags(String sourceName, String targetName) {
        if (!StringUtils.hasText(targetName)) {
            throw new IllegalArgumentException("目标标签名称不能为空");
        }

        tagRepository.mergeTags(sourceName, targetName.trim());
        logger.info("合并标签: {} -> {}", sourceName, targetName);
    }

    /**
     * 删除标签
     */
    public void deleteTag(Long tagId) {
        MangaTag tag = tagRepository.findById(tagId)
                .orElseThrow(() -> new IllegalArgumentException("标签不存在: " + tagId));

        tagRepository.delete(tag);
        logger.info("删除标签: {} (ID: {})", tag.getName(), tagId);
    }

    /**
     * 删除指定名称的所有标签
     */
    public void deleteTagsByName(String tagName) {
        tagRepository.deleteByNameIgnoreCase(tagName);
        logger.info("删除所有名为 {} 的标签", tagName);
    }

    /**
     * 搜索标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> searchTags(String keyword) {
        if (!StringUtils.hasText(keyword)) {
            return getAllTags();
        }
        return tagRepository.findByNameContainingIgnoreCase(keyword);
    }

    /**
     * 查找相似标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> findSimilarTags(String tagName) {
        return tagRepository.findSimilarTags(tagName, tagName);
    }

    /**
     * 获取标签使用统计
     */
    @Transactional(readOnly = true)
    public List<Object[]> getTagUsageStatistics() {
        return tagRepository.getTagUsageStatistics();
    }

    /**
     * 获取指定漫画库的标签使用统计
     */
    @Transactional(readOnly = true)
    public List<Object[]> getTagUsageStatisticsByLibraryId(Long libraryId) {
        return tagRepository.getTagUsageStatisticsByLibraryId(libraryId);
    }

    /**
     * 获取最受欢迎的标签
     */
    @Transactional(readOnly = true)
    public List<String> getMostPopularTags(int limit) {
        org.springframework.data.domain.Pageable pageable =
                org.springframework.data.domain.PageRequest.of(0, limit);
        return tagRepository.findMostPopularTags(pageable);
    }

    /**
     * 获取最近创建的标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> getRecentlyCreatedTags() {
        return tagRepository.findTop10ByOrderByCreatedAtDesc();
    }

    /**
     * 根据标签查找漫画ID
     */
    @Transactional(readOnly = true)
    public List<Long> findMangaIdsByTag(String tagName) {
        return tagRepository.findMangaIdsByTagName(tagName);
    }

    /**
     * 根据多个标签查找漫画ID（任意匹配）
     */
    @Transactional(readOnly = true)
    public List<Long> findMangaIdsByAnyTags(List<String> tagNames) {
        return tagRepository.findMangaIdsByTagNames(tagNames);
    }

    /**
     * 根据多个标签查找漫画ID（全部匹配）
     */
    @Transactional(readOnly = true)
    public List<Long> findMangaIdsByAllTags(List<String> tagNames) {
        return tagRepository.findMangaIdsWithAllTags(tagNames, tagNames.size());
    }

    /**
     * 统计标签数量
     */
    @Transactional(readOnly = true)
    public long countTags() {
        return tagRepository.count();
    }

    /**
     * 统计不重复标签名称数量
     */
    @Transactional(readOnly = true)
    public long countDistinctTagNames() {
        return tagRepository.countDistinctTagNames();
    }

    /**
     * 统计指定漫画的标签数量
     */
    @Transactional(readOnly = true)
    public long countTagsByMangaId(Long mangaId) {
        return tagRepository.countByMangaId(mangaId);
    }

    /**
     * 统计指定标签的使用次数
     */
    @Transactional(readOnly = true)
    public long countTagUsage(String tagName) {
        return tagRepository.countByNameIgnoreCase(tagName);
    }

    /**
     * 查找重复的标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> findDuplicateTags() {
        return tagRepository.findDuplicateTags();
    }

    /**
     * 查找孤立的标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> findOrphanedTags() {
        return tagRepository.findOrphanedTags();
    }

    /**
     * 清理重复标签
     */
    public void cleanupDuplicateTags() {
        tagRepository.cleanupDuplicateTags();
        logger.info("清理重复标签完成");
    }

    /**
     * 删除指定漫画库的所有标签
     */
    public void deleteTagsByLibraryId(Long libraryId) {
        tagRepository.deleteByLibraryId(libraryId);
        logger.info("删除漫画库 {} 的所有标签", libraryId);
    }

    /**
     * 根据颜色获取标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> getTagsByColor(String color) {
        return tagRepository.findByColor(color);
    }

    /**
     * 根据多个颜色获取标签
     */
    @Transactional(readOnly = true)
    public List<MangaTag> getTagsByColors(List<String> colors) {
        return tagRepository.findByColorIn(colors);
    }

    /**
     * 验证标签名称
     */
    private void validateTagName(String tagName) {
        if (!StringUtils.hasText(tagName)) {
            throw new IllegalArgumentException("标签名称不能为空");
        }
        if (tagName.length() > 50) {
            throw new IllegalArgumentException("标签名称不能超过50个字符");
        }
    }

    /**
     * 验证标签颜色
     */
    private void validateTagColor(String color) {
        if (StringUtils.hasText(color)) {
            if (!color.matches("^#[0-9A-Fa-f]{6}$")) {
                throw new IllegalArgumentException("标签颜色格式无效，应为 #RRGGBB 格式");
            }
        }
    }

    /**
     * 创建标签（不关联漫画）
     */
    public MangaTag createTag(MangaTag tag) {
        validateTagName(tag.getName());
        if (StringUtils.hasText(tag.getColor())) {
            validateTagColor(tag.getColor());
        }

        MangaTag savedTag = tagRepository.save(tag);
        logger.info("创建标签: {} (ID: {})", savedTag.getName(), savedTag.getId());

        return savedTag;
    }
}
