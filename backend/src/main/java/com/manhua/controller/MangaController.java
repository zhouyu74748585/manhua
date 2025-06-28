package com.manhua.controller;

import com.manhua.entity.Manga;
import com.manhua.service.FileSystemService;
import com.manhua.service.ImageService;
import com.manhua.service.MangaService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 漫画控制器
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@RestController
@RequestMapping("/api/mangas")
@CrossOrigin(origins = "*")
public class MangaController {

    private static final Logger logger = LoggerFactory.getLogger(MangaController.class);

    @Autowired
    private MangaService mangaService;

    @Autowired
    private ImageService imageService;

    @Autowired
    private FileSystemService fileSystemService;

    /**
     * 获取所有漫画
     */
    @GetMapping
    public ResponseEntity<List<Manga>> getAllMangas() {
        try {
            List<Manga> mangas = mangaService.getAllManga();
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("获取漫画列表失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 分页获取漫画
     */
    @GetMapping("/page")
    public ResponseEntity<Page<Manga>> getMangasPage(Pageable pageable) {
        try {
            Page<Manga> mangas = mangaService.getMangas(pageable);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("分页获取漫画失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据查询参数获取漫画列表
     */
    @GetMapping("/filter")
    public ResponseEntity<Page<Manga>> getMangasWithFilters(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String genre,
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "title") String sort,
            @RequestParam(defaultValue = "asc") String order,
            @RequestParam(defaultValue = "true") boolean activeLibrariesOnly,
            @RequestParam(required = false) Long libraryId) {
        try {
            Page<Manga> mangas = mangaService.getMangasWithFilters(
                page, limit, search, genre, status, sort, order, activeLibrariesOnly, libraryId);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("获取漫画列表失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据ID获取漫画
     */
    @GetMapping("/{id}")
    public ResponseEntity<Manga> getMangaById(@PathVariable Long id) {
        try {
            return mangaService.getMangaById(id)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            logger.error("获取漫画失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据漫画库ID获取漫画
     */
    @GetMapping("/library/{libraryId}")
    public ResponseEntity<List<Manga>> getMangasByLibraryId(@PathVariable Long libraryId) {
        try {
            List<Manga> mangas = mangaService.getMangaByLibrary(libraryId);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("根据漫画库获取漫画失败: {}", libraryId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 分页获取漫画库中的漫画
     */
    @GetMapping("/library/{libraryId}/page")
    public ResponseEntity<Page<Manga>> getMangasByLibraryIdPage(
            @PathVariable Long libraryId, Pageable pageable) {
        try {
            Page<Manga> mangas = mangaService.getMangaByLibrary(libraryId, pageable);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("分页获取漫画库漫画失败: {}", libraryId, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 创建漫画
     */
    @PostMapping
    public ResponseEntity<Manga> createManga(@Valid @RequestBody Manga manga) {
        try {
            Manga createdManga = mangaService.createManga(manga);
            return ResponseEntity.ok(createdManga);
        } catch (IllegalArgumentException e) {
            logger.warn("创建漫画参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("创建漫画失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新漫画
     */
    @PutMapping("/{id}")
    public ResponseEntity<Manga> updateManga(
            @PathVariable Long id,
            @Valid @RequestBody Manga manga) {
        try {
            manga.setId(id);
            Manga updatedManga = mangaService.updateManga(id,manga);
            return ResponseEntity.ok(updatedManga);
        } catch (IllegalArgumentException e) {
            logger.warn("更新漫画参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新漫画失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 删除漫画
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteManga(@PathVariable Long id) {
        try {
            mangaService.deleteManga(id);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("删除漫画参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("删除漫画失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }


    /**
     * 分页搜索漫画
     */
    @GetMapping("/search/page")
    public ResponseEntity<Page<Manga>> searchMangasPage(
            @RequestParam String keyword,
            @RequestParam(required = false) Long libraryId,
            Pageable pageable) {
        try {
            Page<Manga> mangas;
            if (libraryId != null) {
                mangas = mangaService.searchMangaInLibrary(libraryId,keyword, pageable);
            } else {
                mangas = mangaService.searchManga(keyword, pageable);
            }
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("分页搜索漫画失败: {}", keyword, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据作者获取漫画
     */
    @GetMapping("/author/{author}")
    public ResponseEntity<List<Manga>> getMangasByAuthor(@PathVariable String author) {
        try {
            List<Manga> mangas = mangaService.getMangaByAuthor(author);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("根据作者获取漫画失败: {}", author, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 根据状态获取漫画
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<List<Manga>> getMangasByStatus(@PathVariable Manga.MangaStatus status) {
        try {
            List<Manga> mangas = mangaService.getMangaByStatus(status);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("根据状态获取漫画失败: {}", status, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取最近阅读的漫画
     */
    @GetMapping("/recent")
    public ResponseEntity<List<Manga>> getRecentlyReadMangas(Pageable pageable) {
        try {
            List<Manga> mangas = mangaService.getRecentlyReadManga(pageable);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("获取最近阅读漫画失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取最近添加的漫画
     */
    @GetMapping("/recent-added")
    public ResponseEntity<List<Manga>> getRecentlyAddedMangas() {
        try {
            List<Manga> mangas = mangaService.getRecentlyAddedManga();
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("获取最近添加漫画失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取高评分漫画
     */
    @GetMapping("/top-rated")
    public ResponseEntity<List<Manga>> getTopRatedMangas(Pageable pageable) {
        try {
            List<Manga> mangas = mangaService.getHighRatedManga(0.0,pageable);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("获取高评分漫画失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取未完成的漫画
     */
    @GetMapping("/unfinished")
    public ResponseEntity<List<Manga>> getUnfinishedMangas(Pageable pageable) {
        try {
            List<Manga> mangas = mangaService.getUnfinishedManga(pageable);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("获取未完成漫画失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取随机漫画
     */
    @GetMapping("/random")
    public ResponseEntity<List<Manga>> getRandomMangas(
            @RequestParam(defaultValue = "5") int count) {
        try {
            List<Manga> mangas = mangaService.getRandomManga(count);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("获取随机漫画失败", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新漫画评分
     */
    @PostMapping("/{id}/rating")
    public ResponseEntity<Void> updateMangaRating(
            @PathVariable Long id,
            @RequestBody Map<String, Double> request) {
        try {
            Double rating = request.get("rating");
            if (rating == null || rating < 0 || rating > 10) {
                return ResponseEntity.badRequest().build();
            }

            mangaService.updateMangaRating(id, rating);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("更新漫画评分参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新漫画评分失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新漫画状态
     */
    @PostMapping("/{id}/status")
    public ResponseEntity<Void> updateMangaStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        try {
            String statusStr = request.get("status");
            if (statusStr == null) {
                return ResponseEntity.badRequest().build();
            }

            Manga.MangaStatus status = Manga.MangaStatus.valueOf(statusStr.toUpperCase());
            mangaService.updateMangaStatus(id, status);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("更新漫画状态参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新漫画状态失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 更新最后阅读时间
     */
    @PostMapping("/{id}/last-read")
    public ResponseEntity<Void> updateLastReadTime(@PathVariable Long id) {
        try {
            mangaService.updateLastReadTime(id);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            logger.warn("更新最后阅读时间参数错误: {}", e.getMessage());
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("更新最后阅读时间失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取漫画封面
     */
    @GetMapping("/{id}/cover")
    public ResponseEntity<byte[]> getMangaCover(@PathVariable Long id) {
        try {
            Optional<Manga> mangaOpt = mangaService.getMangaById(id);
            if (mangaOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            Manga manga = mangaOpt.get();
            if (manga.getCoverImage() == null) {
                return ResponseEntity.notFound().build();
            }

            // 从文件系统读取封面图片
            String coverPath = fileSystemService.getDataFilePath(manga.getCoverImage());
            if (!fileSystemService.exists(coverPath)) {
                return ResponseEntity.notFound().build();
            }

            byte[] imageData = fileSystemService.readFile(coverPath);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(imageData.length);

            return new ResponseEntity<>(imageData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("获取漫画封面失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 获取漫画页面图片
     */
    @GetMapping("/{id}/page/{pageNumber}")
    public ResponseEntity<byte[]> getMangaPage(
            @PathVariable Long id,
            @PathVariable int pageNumber,
            @RequestParam(defaultValue = "false") boolean thumbnail) {
        try {
            Optional<Manga> mangaOpt = mangaService.getMangaById(id);
            if (mangaOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            Manga manga = mangaOpt.get();

            // 获取压缩文件中的图片列表
            List<String> imageEntries = fileSystemService.listArchiveEntries(manga.getFilePath())
                    .stream()
                    .filter(this::isImageFile)
                    .sorted()
                    .toList();

            if (pageNumber < 0 || pageNumber >= imageEntries.size()) {
                return ResponseEntity.notFound().build();
            }

            String entryName = imageEntries.get(pageNumber);

            // 提取并处理图片
            byte[] imageData = imageService.extractAndProcessImage(
                    manga.getFilePath(), entryName, thumbnail);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.IMAGE_JPEG);
            headers.setContentLength(imageData.length);

            return new ResponseEntity<>(imageData, headers, HttpStatus.OK);
        } catch (Exception e) {
            logger.error("获取漫画页面失败: {} - {}", id, pageNumber, e);
            return ResponseEntity.internalServerError().build();
        }
    }



    /**
     * 查找相似漫画
     */
    @GetMapping("/{id}/similar")
    public ResponseEntity<List<Manga>> getSimilarMangas(
            @PathVariable Long id,
            Pageable pageable) {
        try {
            List<Manga> mangas = mangaService.findSimilarManga(id, pageable);
            return ResponseEntity.ok(mangas);
        } catch (Exception e) {
            logger.error("查找相似漫画失败: {}", id, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 判断是否为图片文件
     */
    private boolean isImageFile(String fileName) {
        String lowerName = fileName.toLowerCase();
        return lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg") ||
               lowerName.endsWith(".png") || lowerName.endsWith(".gif") ||
               lowerName.endsWith(".bmp") || lowerName.endsWith(".webp");
    }
}
