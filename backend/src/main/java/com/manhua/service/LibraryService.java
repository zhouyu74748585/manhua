package com.manhua.service;

import com.manhua.dto.LibraryDTO;
import com.manhua.dto.request.CreateLibraryRequest;
import com.manhua.entity.Library;
import com.manhua.repository.LibraryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 漫画库服务层
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LibraryService {

    private final LibraryRepository libraryRepository;

    /**
     * 创建漫画库
     */
    @Transactional
    public LibraryDTO createLibrary(CreateLibraryRequest request) {
        log.info("Creating library: {}", request.getName());
        
        // 检查库名是否已存在
        if (libraryRepository.findByName(request.getName()).isPresent()) {
            throw new RuntimeException("Library with name '" + request.getName() + "' already exists");
        }
        
        // 检查路径是否已存在
        if (libraryRepository.findByPath(request.getPath()).isPresent()) {
            throw new RuntimeException("Library with path '" + request.getPath() + "' already exists");
        }
        
        Library library = new Library();
        library.setName(request.getName());
        library.setDescription(request.getDescription());
        library.setType(request.getType());
        library.setPath(request.getPath());
        library.setIsPrivate(request.getIsPrivate());
        library.setNetworkConfig(request.getNetworkConfig());
        library.setScanStatus("pending");
        library.setCreateTime(LocalDateTime.now());
        library.setUpdateTime(LocalDateTime.now());
        
        Library savedLibrary = libraryRepository.save(library);
        log.info("Library created successfully: {}", savedLibrary.getId());
        
        return convertToDTO(savedLibrary);
    }

    /**
     * 获取所有漫画库
     */
    public List<LibraryDTO> getAllLibraries() {
        log.debug("Getting all libraries");
        return libraryRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 分页获取漫画库
     */
    public Page<LibraryDTO> getLibraries(Pageable pageable) {
        log.debug("Getting libraries with pagination");
        return libraryRepository.findAll(pageable)
                .map(this::convertToDTO);
    }

    /**
     * 根据ID获取漫画库
     */
    public Optional<LibraryDTO> getLibraryById(Long id) {
        log.debug("Getting library by id: {}", id);
        return libraryRepository.findById(id)
                .map(this::convertToDTO);
    }

    /**
     * 根据名称获取漫画库
     */
    public Optional<LibraryDTO> getLibraryByName(String name) {
        log.debug("Getting library by name: {}", name);
        return libraryRepository.findByName(name)
                .map(this::convertToDTO);
    }

    /**
     * 根据类型获取漫画库
     */
    public List<LibraryDTO> getLibrariesByType(String type) {
        log.debug("Getting libraries by type: {}", type);
        return libraryRepository.findByType(type).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取活跃的漫画库
     */
    public List<LibraryDTO> getActiveLibraries() {
        log.debug("Getting active libraries");
        return libraryRepository.findActiveLibraries().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 搜索漫画库
     */
    public List<LibraryDTO> searchLibraries(String keyword) {
        log.debug("Searching libraries with keyword: {}", keyword);
        return libraryRepository.searchLibraries(keyword).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 更新漫画库
     */
    @Transactional
    public LibraryDTO updateLibrary(Long id, CreateLibraryRequest request) {
        log.info("Updating library: {}", id);
        
        Library library = libraryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Library not found with id: " + id));
        
        // 检查名称是否与其他库冲突
        Optional<Library> existingByName = libraryRepository.findByName(request.getName());
        if (existingByName.isPresent() && !existingByName.get().getId().equals(id)) {
            throw new RuntimeException("Library with name '" + request.getName() + "' already exists");
        }
        
        // 检查路径是否与其他库冲突
        Optional<Library> existingByPath = libraryRepository.findByPath(request.getPath());
        if (existingByPath.isPresent() && !existingByPath.get().getId().equals(id)) {
            throw new RuntimeException("Library with path '" + request.getPath() + "' already exists");
        }
        
        library.setName(request.getName());
        library.setDescription(request.getDescription());
        library.setType(request.getType());
        library.setPath(request.getPath());
        library.setIsPrivate(request.getIsPrivate());
        library.setNetworkConfig(request.getNetworkConfig());
        library.setUpdateTime(LocalDateTime.now());
        
        Library savedLibrary = libraryRepository.save(library);
        log.info("Library updated successfully: {}", savedLibrary.getId());
        
        return convertToDTO(savedLibrary);
    }

    /**
     * 删除漫画库
     */
    @Transactional
    public void deleteLibrary(Long id) {
        log.info("Deleting library: {}", id);
        
        Library library = libraryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Library not found with id: " + id));
        
        libraryRepository.delete(library);
        log.info("Library deleted successfully: {}", id);
    }

    /**
     * 更新扫描状态
     */
    @Transactional
    public void updateScanStatus(Long id, String status) {
        log.info("Updating scan status for library {}: {}", id, status);
        
        Library library = libraryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Library not found with id: " + id));
        
        library.setScanStatus(status);
        library.setUpdateTime(LocalDateTime.now());
        libraryRepository.save(library);
    }

    /**
     * 获取需要扫描的漫画库
     */
    public List<LibraryDTO> getLibrariesNeedingScanning() {
        log.debug("Getting libraries needing scanning");
        return libraryRepository.findLibrariesNeedingScanning().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 统计漫画库数量
     */
    public Long countLibraries() {
        return libraryRepository.countAllLibraries();
    }

    /**
     * 统计各类型漫画库数量
     */
    public List<Object[]> countLibrariesByType() {
        return libraryRepository.countByType();
    }

    /**
     * 转换为DTO
     */
    private LibraryDTO convertToDTO(Library library) {
        LibraryDTO dto = new LibraryDTO();
        dto.setId(library.getId());
        dto.setName(library.getName());
        dto.setDescription(library.getDescription());
        dto.setType(library.getType());
        dto.setPath(library.getPath());
        dto.setIsPrivate(library.getIsPrivate());
        dto.setScanStatus(library.getScanStatus());
        dto.setNetworkConfig(library.getNetworkConfig());
        dto.setCreateTime(library.getCreateTime());
        dto.setUpdateTime(library.getUpdateTime());
        dto.setComicCount(library.getComicCount());
        return dto;
    }
}