package com.manhua.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 漫画库实体类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Entity
@Table(name = "manga_libraries")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class MangaLibrary {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @NotBlank(message = "库名称不能为空")
    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 500)
    private String description;

    @Column(name = "current_status", length = 20)
    private String currentStatus;

    @NotNull(message = "库类型不能为空")
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LibraryType type;

    @NotBlank(message = "路径不能为空")
    @Column(nullable = false, length = 1000)
    private String path;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "is_current")
    private Boolean isCurrent = false;

    @Column(name = "auto_scan")
    private Boolean autoScan = true;

    @Column(name = "scan_interval")
    private Integer scanInterval = 300; // 扫描间隔（秒）

    @Column(name = "last_scan_at")
    private LocalDateTime lastScanAt;

    @Column(name = "manga_count")
    private Integer mangaCount = 0;

    @Column(name = "total_size")
    private Long totalSize = 0L;

    // 网络文件系统配置
    @Column(length = 100)
    private String username;

    @Column(length = 100)
    private String password;

    @Column(length = 100)
    private String host;

    @Column
    private Integer port;

    @Column(name = "share_name", length = 100)
    private String shareName;

    @Column(name = "domain_name", length = 100)
    private String domainName;

    @Column(name = "use_ssl")
    private Boolean useSsl = false;

    @Column(name = "connection_timeout")
    private Integer connectionTimeout = 30;

    @Column(name = "read_timeout")
    private Integer readTimeout = 60;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // 关联关系
    @JsonIgnore
    @OneToMany(mappedBy = "library", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Manga> mangas = new ArrayList<>();

    // 构造函数
    public MangaLibrary() {}

    public MangaLibrary(String name, LibraryType type, String path) {
        this.name = name;
        this.type = type;
        this.path = path;
    }

    // Getter和Setter方法
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCurrentStatus() {
        return currentStatus;
    }

    public void setCurrentStatus(String currentStatus) {
        this.currentStatus = currentStatus;
    }

    public LibraryType getType() {
        return type;
    }

    public void setType(LibraryType type) {
        this.type = type;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Boolean getIsCurrent() {
        return isCurrent;
    }

    public void setIsCurrent(Boolean isCurrent) {
        this.isCurrent = isCurrent;
    }

    public Boolean getAutoScan() {
        return autoScan;
    }

    public void setAutoScan(Boolean autoScan) {
        this.autoScan = autoScan;
    }

    public Integer getScanInterval() {
        return scanInterval;
    }

    public void setScanInterval(Integer scanInterval) {
        this.scanInterval = scanInterval;
    }

    public LocalDateTime getLastScanAt() {
        return lastScanAt;
    }

    public void setLastScanAt(LocalDateTime lastScanAt) {
        this.lastScanAt = lastScanAt;
    }

    public Integer getMangaCount() {
        return mangaCount;
    }

    public void setMangaCount(Integer mangaCount) {
        this.mangaCount = mangaCount;
    }

    public Long getTotalSize() {
        return totalSize;
    }

    public void setTotalSize(Long totalSize) {
        this.totalSize = totalSize;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getHost() {
        return host;
    }

    public void setHost(String host) {
        this.host = host;
    }

    public Integer getPort() {
        return port;
    }

    public void setPort(Integer port) {
        this.port = port;
    }

    public String getShareName() {
        return shareName;
    }

    public void setShareName(String shareName) {
        this.shareName = shareName;
    }

    public String getDomainName() {
        return domainName;
    }

    public void setDomainName(String domainName) {
        this.domainName = domainName;
    }

    public Boolean getUseSsl() {
        return useSsl;
    }

    public void setUseSsl(Boolean useSsl) {
        this.useSsl = useSsl;
    }

    public Integer getConnectionTimeout() {
        return connectionTimeout;
    }

    public void setConnectionTimeout(Integer connectionTimeout) {
        this.connectionTimeout = connectionTimeout;
    }

    public Integer getReadTimeout() {
        return readTimeout;
    }

    public void setReadTimeout(Integer readTimeout) {
        this.readTimeout = readTimeout;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<Manga> getMangas() {
        return mangas;
    }

    public void setMangas(List<Manga> mangas) {
        this.mangas = mangas;
    }

    // 业务方法
    public void addManga(Manga manga) {
        mangas.add(manga);
        manga.setLibrary(this);
        this.mangaCount = mangas.size();
    }

    public void removeManga(Manga manga) {
        mangas.remove(manga);
        manga.setLibrary(null);
        this.mangaCount = mangas.size();
    }

    public boolean isNetworkLibrary() {
        return type != LibraryType.LOCAL;
    }

    public String getDisplayPath() {
        if (isNetworkLibrary()) {
            StringBuilder sb = new StringBuilder();
            sb.append(type.name().toLowerCase()).append("://");
            if (host != null) {
                sb.append(host);
                if (port != null) {
                    sb.append(":").append(port);
                }
            }
            if (shareName != null) {
                sb.append("/").append(shareName);
            }
            sb.append(path);
            return sb.toString();
        }
        return path;
    }

    @Override
    public String toString() {
        return "MangaLibrary{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", type=" + type +
                ", path='" + path + '\'' +
                ", isActive=" + isActive +
                ", isCurrent=" + isCurrent +
                ", mangaCount=" + mangaCount +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof MangaLibrary)) return false;
        MangaLibrary that = (MangaLibrary) o;
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }

    /**
     * 库类型枚举
     */
    public enum LibraryType {
        LOCAL("本地文件夹"),
        SMB("SMB/CIFS"),
        FTP("FTP"),
        WEBDAV("WebDAV"),
        NFS("NFS");

        private final String displayName;

        LibraryType(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }
}
