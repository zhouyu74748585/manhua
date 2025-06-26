package com.manhua.controller;

import com.manhua.dto.LibraryDTO;
import com.manhua.dto.request.CreateLibraryRequest;
import com.manhua.dto.response.ApiResponse;
import com.manhua.dto.response.PageResponse;
import com.manhua.service.LibraryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.Optional;

/**
 * 漫画库控制器
 */
@RestController
@RequestMapping("/api/libraries")
@Validated
public class LibraryController {

    private static final Logger log = LoggerFactory.getLogger(LibraryController.class);
    @Autowired
    private LibraryService libraryService;


    /**
     * 创建漫画库
     */
    @PostMapping
    public ResponseEntity<ApiResponse<LibraryDTO>> createLibrary(@Valid @RequestBody CreateLibraryRequest request) {
        try {
            LibraryDTO library = libraryService.createLibrary(request);
            return ResponseEntity.ok(ApiResponse.success("Library created successfully", library));
        } catch (Exception e) {
            log.error("Failed to create library", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取所有漫画库
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<LibraryDTO>>> getAllLibraries() {
        try {
            List<LibraryDTO> libraries = libraryService.getAllLibraries();
            return ResponseEntity.ok(ApiResponse.success(libraries));
        } catch (Exception e) {
            log.error("Failed to get all libraries", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 分页获取漫画库
     */
    @GetMapping("/page")
    public ResponseEntity<ApiResponse<PageResponse<LibraryDTO>>> getLibrariesWithPagination(
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) int size,
            @RequestParam(defaultValue = "updateTime") String sortBy,
            @RequestParam(defaultValue = "desc") String sortDir) {
        try {
            Sort sort = Sort.by(Sort.Direction.fromString(sortDir), sortBy);
            Pageable pageable = PageRequest.of(page, size, sort);
            Page<LibraryDTO> libraryPage = libraryService.getLibraries(pageable);
            PageResponse<LibraryDTO> response = PageResponse.of(libraryPage);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (Exception e) {
            log.error("Failed to get libraries with pagination", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据ID获取漫画库
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<LibraryDTO>> getLibraryById(@PathVariable @Min(1) Long id) {
        try {
            Optional<LibraryDTO> library = libraryService.getLibraryById(id);
            if (library.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(library.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("Failed to get library by id: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据名称获取漫画库
     */
    @GetMapping("/name/{name}")
    public ResponseEntity<ApiResponse<LibraryDTO>> getLibraryByName(@PathVariable @NotBlank String name) {
        try {
            Optional<LibraryDTO> library = libraryService.getLibraryByName(name);
            if (library.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(library.get()));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("Failed to get library by name: {}", name, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 根据类型获取漫画库
     */
    @GetMapping("/type/{type}")
    public ResponseEntity<ApiResponse<List<LibraryDTO>>> getLibrariesByType(@PathVariable @NotBlank String type) {
        try {
            List<LibraryDTO> libraries = libraryService.getLibrariesByType(type);
            return ResponseEntity.ok(ApiResponse.success(libraries));
        } catch (Exception e) {
            log.error("Failed to get libraries by type: {}", type, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取活跃的漫画库
     */
    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<LibraryDTO>>> getActiveLibraries() {
        try {
            List<LibraryDTO> libraries = libraryService.getActiveLibraries();
            return ResponseEntity.ok(ApiResponse.success(libraries));
        } catch (Exception e) {
            log.error("Failed to get active libraries", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 搜索漫画库
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<LibraryDTO>>> searchLibraries(@RequestParam @NotBlank String keyword) {
        try {
            List<LibraryDTO> libraries = libraryService.searchLibraries(keyword);
            return ResponseEntity.ok(ApiResponse.success(libraries));
        } catch (Exception e) {
            log.error("Failed to search libraries with keyword: {}", keyword, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新漫画库
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<LibraryDTO>> updateLibrary(
            @PathVariable @Min(1) Long id,
            @Valid @RequestBody CreateLibraryRequest request) {
        try {
            LibraryDTO library = libraryService.updateLibrary(id, request);
            return ResponseEntity.ok(ApiResponse.success("Library updated successfully", library));
        } catch (Exception e) {
            log.error("Failed to update library: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 删除漫画库
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteLibrary(@PathVariable @Min(1) Long id) {
        try {
            libraryService.deleteLibrary(id);
            return ResponseEntity.ok(ApiResponse.success("Library deleted successfully", null));
        } catch (Exception e) {
            log.error("Failed to delete library: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 更新扫描状态
     */
    @PatchMapping("/{id}/scan-status")
    public ResponseEntity<ApiResponse<Void>> updateScanStatus(
            @PathVariable @Min(1) Long id,
            @RequestParam @NotBlank String status) {
        try {
            libraryService.updateScanStatus(id, status);
            return ResponseEntity.ok(ApiResponse.success("Scan status updated successfully", null));
        } catch (Exception e) {
            log.error("Failed to update scan status for library: {}", id, e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * 获取需要扫描的漫画库
     */
    @GetMapping("/scan/pending")
    public ResponseEntity<ApiResponse<List<LibraryDTO>>> getLibrariesNeedingScanning() {
        try {
            List<LibraryDTO> libraries = libraryService.getLibrariesNeedingScanning();
            return ResponseEntity.ok(ApiResponse.success(libraries));
        } catch (Exception e) {
            log.error("Failed to get libraries needing scanning", e);
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

}