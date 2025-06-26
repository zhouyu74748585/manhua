package com.manhua.service;

import com.manhua.dto.ReadingHistoryDTO;
import com.manhua.entity.Comic;
import com.manhua.entity.ReadingHistory;
import com.manhua.repository.ReadingHistoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 阅读历史服务
 */
@Service
@Transactional
public class ReadingHistoryService {

    @Autowired
    private ReadingHistoryRepository readingHistoryRepository;

    /**
     * 获取所有阅读历史
     */
    @Transactional(readOnly = true)
    public List<ReadingHistoryDTO> getAllReadingHistories() {
        return readingHistoryRepository.findAll(Sort.by(Sort.Direction.DESC, "readTime"))
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 分页获取阅读历史
     */
    @Transactional(readOnly = true)
    public Page<ReadingHistoryDTO> getReadingHistories(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "readTime"));
        return readingHistoryRepository.findAll(pageable)
                .map(this::convertToDTO);
    }

    /**
     * 根据ID获取阅读历史
     */
    @Transactional(readOnly = true)
    public Optional<ReadingHistoryDTO> getReadingHistoryById(Long id) {
        return readingHistoryRepository.findById(id)
                .map(this::convertToDTO);
    }

    /**
     * 根据漫画ID获取阅读历史
     */
    @Transactional(readOnly = true)
    public List<ReadingHistoryDTO> getReadingHistoriesByComicId(Long comicId) {
        return readingHistoryRepository.findByComicIdOrderByReadTimeDesc(comicId)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }


    /**
     * 获取最近阅读历史
     */
    @Transactional(readOnly = true)
    public List<ReadingHistoryDTO> getRecentReadingHistories(int limit) {
        Pageable pageable = PageRequest.of(0, limit, Sort.by(Sort.Direction.DESC, "readTime"));
        return readingHistoryRepository.findRecentHistory(pageable)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 创建阅读历史
     */
    public ReadingHistoryDTO createReadingHistory(ReadingHistoryDTO readingHistoryDTO) {
        ReadingHistory readingHistory = convertToEntity(readingHistoryDTO);
        readingHistory.setReadTime(LocalDateTime.now());
        ReadingHistory savedHistory = readingHistoryRepository.save(readingHistory);
        return convertToDTO(savedHistory);
    }

    /**
     * 更新阅读历史
     */
    public ReadingHistoryDTO updateReadingHistory(Long id, ReadingHistoryDTO readingHistoryDTO) {
        Optional<ReadingHistory> existingHistory = readingHistoryRepository.findById(id);
        if (existingHistory.isPresent()) {
            ReadingHistory readingHistory = existingHistory.get();
            
            if (readingHistoryDTO.getComicId() != null) {
                Comic comic = new Comic();
                comic.setId(readingHistoryDTO.getComicId());
                readingHistory.setComic(comic);
            }
            if (readingHistoryDTO.getPageNumber() != null) {
                readingHistory.setPageNumber(readingHistoryDTO.getPageNumber());
            }
            if (readingHistoryDTO.getReadingMode() != null) {
                readingHistory.setReadingMode(readingHistoryDTO.getReadingMode());
            }
            if (readingHistoryDTO.getReadingDuration() != null) {
                readingHistory.setReadingDuration(readingHistoryDTO.getReadingDuration());
            }
            if (readingHistoryDTO.getDeviceInfo() != null) {
                readingHistory.setDeviceInfo(readingHistoryDTO.getDeviceInfo());
            }
            
            ReadingHistory savedHistory = readingHistoryRepository.save(readingHistory);
            return convertToDTO(savedHistory);
        }
        throw new RuntimeException("阅读历史不存在，ID: " + id);
    }

    /**
     * 删除阅读历史
     */
    public void deleteReadingHistory(Long id) {
        if (readingHistoryRepository.existsById(id)) {
            readingHistoryRepository.deleteById(id);
        } else {
            throw new RuntimeException("阅读历史不存在，ID: " + id);
        }
    }


    /**
     * 实体转DTO
     */
    private ReadingHistoryDTO convertToDTO(ReadingHistory readingHistory) {
        ReadingHistoryDTO dto = new ReadingHistoryDTO();
        dto.setId(readingHistory.getId());
        dto.setPageNumber(readingHistory.getPageNumber());
        dto.setReadTime(readingHistory.getReadTime());
        dto.setReadingMode(readingHistory.getReadingMode());
        dto.setReadingDuration(readingHistory.getReadingDuration());
        dto.setDeviceInfo(readingHistory.getDeviceInfo());
        if (readingHistory.getComic() != null) {
            dto.setComicId(readingHistory.getComic().getId());
        }
        return dto;
    }

    /**
     * DTO转实体
     */
    private ReadingHistory convertToEntity(ReadingHistoryDTO dto) {
        ReadingHistory readingHistory = new ReadingHistory();
        readingHistory.setPageNumber(dto.getPageNumber());
        readingHistory.setReadingMode(dto.getReadingMode());
        readingHistory.setReadingDuration(dto.getReadingDuration());
        readingHistory.setDeviceInfo(dto.getDeviceInfo());
        if (dto.getComicId() != null) {
            Comic comic = new Comic();
            comic.setId(dto.getComicId());
            readingHistory.setComic(comic);
        }
        return readingHistory;
    }
}