package com.manhua.service;

import com.manhua.dto.ComicDTO;
import com.manhua.dto.TagDTO;
import com.manhua.dto.request.UpdateComicRequest;
import com.manhua.entity.Comic;
import com.manhua.entity.Library;
import com.manhua.entity.Tag;
import com.manhua.repository.ComicRepository;
import com.manhua.repository.LibraryRepository;
import com.manhua.repository.TagRepository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cglib.beans.BeanCopier;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 漫画服务层
 */
@Service

public class ComicService {

    private static final Logger log = LoggerFactory.getLogger(ComicService.class);

    @Autowired
    private  ComicRepository comicRepository;
    @Autowired
    private  LibraryRepository libraryRepository;
    @Autowired
    private  TagRepository tagRepository;

    /**
     * 获取所有漫画
     */
    public List<ComicDTO> getAllComics() {
        log.debug("Getting all comics");
        return comicRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 分页获取漫画
     */
    public Page<ComicDTO> getComics(Pageable pageable) {
        log.debug("Getting comics with pagination");
        return comicRepository.findAll(pageable)
                .map(this::convertToDTO);
    }

    /**
     * 根据ID获取漫画
     */
    public Optional<ComicDTO> getComicById(Long id) {
        log.debug("Getting comic by id: {}", id);
        return comicRepository.findById(id)
                .map(this::convertToDTO);
    }

    /**
     * 根据库ID获取漫画
     */
    public List<ComicDTO> getComicsByLibraryId(Long libraryId) {
        log.debug("Getting comics by library id: {}", libraryId);
        return comicRepository.findByLibraryId(libraryId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据库ID分页获取漫画
     */
    public Page<ComicDTO> getComicsByLibraryId(Long libraryId, Pageable pageable) {
        log.debug("Getting comics by library id with pagination: {}", libraryId);
        return comicRepository.findByLibraryId(libraryId, pageable)
                .map(this::convertToDTO);
    }

    /**
     * 搜索漫画
     */
    public Page<ComicDTO> searchComics(String keyword, Pageable pageable) {
        log.debug("Searching comics with keyword: {}", keyword);
        return comicRepository.searchComics(keyword, pageable)
                .map(this::convertToDTO);
    }

    /**
     * 在指定库中搜索漫画
     */
    public Page<ComicDTO> searchComicsByLibrary(Long libraryId, String keyword, Pageable pageable) {
        log.debug("Searching comics in library {} with keyword: {}", libraryId, keyword);
        return comicRepository.searchComicsByLibrary(libraryId, keyword, pageable)
                .map(this::convertToDTO);
    }

    /**
     * 获取最近阅读的漫画
     */
    public Page<ComicDTO> getRecentlyReadComics(Pageable pageable) {
        log.debug("Getting recently read comics");
        return comicRepository.findRecentlyRead(pageable)
                .map(this::convertToDTO);
    }

    /**
     * 获取正在阅读的漫画
     */
    public List<ComicDTO> getCurrentlyReadingComics() {
        log.debug("Getting currently reading comics");
        return comicRepository.findCurrentlyReading().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取已完成的漫画
     */
    public List<ComicDTO> getCompletedComics() {
        log.debug("Getting completed comics");
        return comicRepository.findCompleted().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取未读的漫画
     */
    public List<ComicDTO> getUnreadComics() {
        log.debug("Getting unread comics");
        return comicRepository.findUnread().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据标签获取漫画
     */
    public List<ComicDTO> getComicsByTags(List<String> tagNames) {
        log.debug("Getting comics by tags: {}", tagNames);
        return comicRepository.findByTagNames(tagNames).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 根据阅读状态获取漫画
     */
    public List<ComicDTO> getComicsByReadingStatus(String readingStatus) {
        log.debug("Getting comics by reading status: {}", readingStatus);
        return comicRepository.findByReadingStatus(readingStatus).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取收藏的漫画
     */
    public List<ComicDTO> getFavoriteComics() {
        log.debug("Getting favorite comics");
        return comicRepository.findByIsFavorite(true).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 更新漫画信息
     */
    @Transactional
    public ComicDTO updateComic(Long id, UpdateComicRequest request) {
        log.info("Updating comic: {}", id);
        
        Comic comic = comicRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Comic not found with id: " + id));
        
        // 更新基本信息
        if (request.getTitle() != null) {
            comic.setTitle(request.getTitle());
        }
        if (request.getAuthor() != null) {
            comic.setAuthor(request.getAuthor());
        }
        if (request.getDescription() != null) {
            comic.setDescription(request.getDescription());
        }
        if (request.getCurrentPage() != null) {
            comic.setCurrentPage(request.getCurrentPage());
        }
        if (request.getReadingStatus() != null) {
            comic.setReadingStatus(request.getReadingStatus());
        }
        if (request.getRating() != null) {
            comic.setRating(request.getRating());
        }
        if (request.getIsPrivate() != null) {
            comic.setIsPrivate(request.getIsPrivate());
        }
        if (request.getIsFavorite() != null) {
            comic.setIsFavorite(request.getIsFavorite());
        }
        
        // 更新标签
        if (request.getTags() != null) {
            Set<Tag> tags = request.getTags().stream()
                    .map(this::getOrCreateTag)
                    .collect(Collectors.toSet());
            comic.setTags(tags);
        }
        
        comic.setUpdateTime(LocalDateTime.now());
        
        Comic savedComic = comicRepository.save(comic);
        log.info("Comic updated successfully: {}", savedComic.getId());
        
        return convertToDTO(savedComic);
    }

    /**
     * 更新阅读进度
     */
    @Transactional
    public ComicDTO updateReadingProgress(Long id, Integer currentPage) {
        log.info("Updating reading progress for comic {}: page {}", id, currentPage);
        
        Comic comic = comicRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Comic not found with id: " + id));
        
        comic.setCurrentPage(currentPage);
        comic.setLastReadTime(LocalDateTime.now());
        
        // 自动更新阅读状态
        if (currentPage > 0 && "unread".equals(comic.getReadingStatus())) {
            comic.setReadingStatus("reading");
        }
        if (currentPage >= comic.getPageCount()) {
            comic.setReadingStatus("completed");
        }
        
        comic.setUpdateTime(LocalDateTime.now());
        
        Comic savedComic = comicRepository.save(comic);
        log.info("Reading progress updated successfully: {}", savedComic.getId());
        
        return convertToDTO(savedComic);
    }

    /**
     * 删除漫画
     */
    @Transactional
    public void deleteComic(Long id) {
        log.info("Deleting comic: {}", id);
        
        Comic comic = comicRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Comic not found with id: " + id));
        
        comicRepository.delete(comic);
        log.info("Comic deleted successfully: {}", id);
    }

    /**
     * 统计漫画数量
     */
    public Long countComics() {
        return comicRepository.countAllComics();
    }

    /**
     * 统计各阅读状态的漫画数量
     */
    public List<Object[]> countComicsByReadingStatus() {
        return comicRepository.countByReadingStatus();
    }

    /**
     * 获取或创建标签
     */
    private Tag getOrCreateTag(String tagName) {
        return tagRepository.findByName(tagName)
                .orElseGet(() -> {
                    Tag tag = new Tag();
                    tag.setName(tagName);
                    tag.setUsageCount(0);
                    tag.setCreateTime(LocalDateTime.now());
                    tag.setUpdateTime(LocalDateTime.now());
                    return tagRepository.save(tag);
                });
    }

    /**
     * 转换为DTO
     */
    private ComicDTO convertToDTO(Comic comic) {
        ComicDTO dto = new ComicDTO();
        dto.setId(comic.getId());
        dto.setTitle(comic.getTitle());
        dto.setAuthor(comic.getAuthor());
        dto.setDescription(comic.getDescription());
        dto.setFilePath(comic.getFilePath());
        dto.setFileType(comic.getFileType());
        dto.setFileSize(comic.getFileSize());
        dto.setCoverPath(comic.getCoverPath());
        dto.setThumbnailPath(comic.getThumbnailPath());
        dto.setPageCount(comic.getPageCount());
        dto.setCurrentPage(comic.getCurrentPage());
        dto.setReadingStatus(comic.getReadingStatus());
        dto.setRating(comic.getRating());
        dto.setIsPrivate(comic.getIsPrivate());
        dto.setIsFavorite(comic.getIsFavorite());
        dto.setLastReadTime(comic.getLastReadTime());
        dto.setFileModifyTime(comic.getFileModifyTime());
        dto.setCreateTime(comic.getCreateTime());
        dto.setUpdateTime(comic.getUpdateTime());
        
        // 设置库信息
        if (comic.getLibrary() != null) {
            dto.setLibraryId(comic.getLibrary().getId());
            dto.setLibraryName(comic.getLibrary().getName());
        }
        
        // 设置标签
        if (comic.getTags() != null) {
            dto.setTags(comic.getTags().stream()
                    .map(e->{
                        TagDTO tagDTO=new TagDTO();
                        BeanUtils.copyProperties(e,tagDTO);
                        return tagDTO;
                    })
                    .collect(Collectors.toList()));
        }
        
        // 设置计算字段
        dto.setProgressPercentage(comic.getProgressPercentage());
        dto.setHasProgress(comic.hasProgress());
        dto.setIsCompleted(comic.isCompleted());
        
        return dto;
    }
}