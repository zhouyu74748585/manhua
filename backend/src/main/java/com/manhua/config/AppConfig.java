package com.manhua.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.concurrent.Executor;

/**
 * 应用程序配置类
 *
 * @author ManhuaReader
 * @version 1.0.0
 */
@Configuration
@EnableAsync
public class AppConfig implements WebMvcConfigurer {

    /**
     * 配置异步任务执行器
     */
    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);
        executor.setMaxPoolSize(16);
        executor.setQueueCapacity(100);
        executor.setKeepAliveSeconds(60);
        executor.setThreadNamePrefix("manhua-async-");
        executor.setRejectedExecutionHandler(new java.util.concurrent.ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }

    /**
     * 配置文件扫描任务执行器
     */
    @Bean(name = "scanExecutor")
    public Executor scanExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(8);
        executor.setQueueCapacity(50);
        executor.setKeepAliveSeconds(120);
        executor.setThreadNamePrefix("manhua-scan-");
        executor.setRejectedExecutionHandler(new java.util.concurrent.ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }

    /**
     * 配置图像处理任务执行器
     */
    @Bean(name = "imageExecutor")
    public Executor imageExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(6);
        executor.setQueueCapacity(30);
        executor.setKeepAliveSeconds(60);
        executor.setThreadNamePrefix("manhua-image-");
        executor.setRejectedExecutionHandler(new java.util.concurrent.ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }

    /**
     * 配置CORS
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(false)
                .maxAge(3600);
    }

    /**
     * 漫画应用配置属性
     */
    @Configuration
    @ConfigurationProperties(prefix = "manhua")
    public static class ManhuaProperties {

        private String dataDir = "./data";
        private String cacheDir = "./cache";
        private String tempDir = "./temp";
        private String logDir = "./logs";

        private ScanConfig scan = new ScanConfig();
        private ImageConfig image = new ImageConfig();
        private CacheConfig cache = new CacheConfig();
        private NetworkConfig network = new NetworkConfig();
        private SecurityConfig security = new SecurityConfig();
        private PerformanceConfig performance = new PerformanceConfig();

        // Getters and Setters
        public String getDataDir() { return dataDir; }
        public void setDataDir(String dataDir) { this.dataDir = dataDir; }

        public String getCacheDir() { return cacheDir; }
        public void setCacheDir(String cacheDir) { this.cacheDir = cacheDir; }

        public String getTempDir() { return tempDir; }
        public void setTempDir(String tempDir) { this.tempDir = tempDir; }

        public String getLogDir() { return logDir; }
        public void setLogDir(String logDir) { this.logDir = logDir; }

        public ScanConfig getScan() { return scan; }
        public void setScan(ScanConfig scan) { this.scan = scan; }

        public ImageConfig getImage() { return image; }
        public void setImage(ImageConfig image) { this.image = image; }

        public CacheConfig getCache() { return cache; }
        public void setCache(CacheConfig cache) { this.cache = cache; }

        public NetworkConfig getNetwork() { return network; }
        public void setNetwork(NetworkConfig network) { this.network = network; }

        public SecurityConfig getSecurity() { return security; }
        public void setSecurity(SecurityConfig security) { this.security = security; }

        public PerformanceConfig getPerformance() { return performance; }
        public void setPerformance(PerformanceConfig performance) { this.performance = performance; }

        /**
         * 扫描配置
         */
        public static class ScanConfig {
            private int threadPoolSize = 4;
            private int interval = 300;
            private java.util.List<String> supportedImageFormats = java.util.Arrays.asList(
                "jpg", "jpeg", "png", "gif", "bmp", "webp"
            );
            private java.util.List<String> supportedArchiveFormats = java.util.Arrays.asList(
                "zip", "rar", "7z", "cbz", "cbr"
            );

            // Getters and Setters
            public int getThreadPoolSize() { return threadPoolSize; }
            public void setThreadPoolSize(int threadPoolSize) { this.threadPoolSize = threadPoolSize; }

            public int getInterval() { return interval; }
            public void setInterval(int interval) { this.interval = interval; }

            public java.util.List<String> getSupportedImageFormats() { return supportedImageFormats; }
            public void setSupportedImageFormats(java.util.List<String> supportedImageFormats) {
                this.supportedImageFormats = supportedImageFormats;
            }

            public java.util.List<String> getSupportedArchiveFormats() { return supportedArchiveFormats; }
            public void setSupportedArchiveFormats(java.util.List<String> supportedArchiveFormats) {
                this.supportedArchiveFormats = supportedArchiveFormats;
            }
        }

        /**
         * 图像配置
         */
        public static class ImageConfig {
            private int thumbnailSize = 300;
            private int coverSize = 600;
            private double quality = 0.85;
            private boolean enableWebp = true;

            // Getters and Setters
            public int getThumbnailSize() { return thumbnailSize; }
            public void setThumbnailSize(int thumbnailSize) { this.thumbnailSize = thumbnailSize; }

            public int getCoverSize() { return coverSize; }
            public void setCoverSize(int coverSize) { this.coverSize = coverSize; }

            public double getQuality() { return quality; }
            public void setQuality(double quality) { this.quality = quality; }

            public boolean isEnableWebp() { return enableWebp; }
            public void setEnableWebp(boolean enableWebp) { this.enableWebp = enableWebp; }
        }

        /**
         * 缓存配置
         */
        public static class CacheConfig {
            private int maxSize = 1024;
            private int expireHours = 24;
            private int preloadPages = 3;

            // Getters and Setters
            public int getMaxSize() { return maxSize; }
            public void setMaxSize(int maxSize) { this.maxSize = maxSize; }

            public int getExpireHours() { return expireHours; }
            public void setExpireHours(int expireHours) { this.expireHours = expireHours; }

            public int getPreloadPages() { return preloadPages; }
            public void setPreloadPages(int preloadPages) { this.preloadPages = preloadPages; }
        }

        /**
         * 网络配置
         */
        public static class NetworkConfig {
            private int connectTimeout = 30;
            private int readTimeout = 60;
            private int retryCount = 3;

            // Getters and Setters
            public int getConnectTimeout() { return connectTimeout; }
            public void setConnectTimeout(int connectTimeout) { this.connectTimeout = connectTimeout; }

            public int getReadTimeout() { return readTimeout; }
            public void setReadTimeout(int readTimeout) { this.readTimeout = readTimeout; }

            public int getRetryCount() { return retryCount; }
            public void setRetryCount(int retryCount) { this.retryCount = retryCount; }
        }

        /**
         * 安全配置
         */
        public static class SecurityConfig {
            private boolean enableAuth = false;
            private String jwtSecret = "manhua-reader-secret-key-2024";
            private int jwtExpiration = 24;
            private boolean enableCors = true;
            private java.util.List<String> allowedOrigins = java.util.Arrays.asList(
                "http://localhost:3000", "http://localhost:5173",
                "http://127.0.0.1:3000", "http://127.0.0.1:5173"
            );

            // Getters and Setters
            public boolean isEnableAuth() { return enableAuth; }
            public void setEnableAuth(boolean enableAuth) { this.enableAuth = enableAuth; }

            public String getJwtSecret() { return jwtSecret; }
            public void setJwtSecret(String jwtSecret) { this.jwtSecret = jwtSecret; }

            public int getJwtExpiration() { return jwtExpiration; }
            public void setJwtExpiration(int jwtExpiration) { this.jwtExpiration = jwtExpiration; }

            public boolean isEnableCors() { return enableCors; }
            public void setEnableCors(boolean enableCors) { this.enableCors = enableCors; }

            public java.util.List<String> getAllowedOrigins() { return allowedOrigins; }
            public void setAllowedOrigins(java.util.List<String> allowedOrigins) {
                this.allowedOrigins = allowedOrigins;
            }
        }

        /**
         * 性能配置
         */
        public static class PerformanceConfig {
            private boolean enableAsync = true;
            private int asyncPoolSize = 8;
            private boolean enableCompression = true;
            private boolean enableCache = true;

            // Getters and Setters
            public boolean isEnableAsync() { return enableAsync; }
            public void setEnableAsync(boolean enableAsync) { this.enableAsync = enableAsync; }

            public int getAsyncPoolSize() { return asyncPoolSize; }
            public void setAsyncPoolSize(int asyncPoolSize) { this.asyncPoolSize = asyncPoolSize; }

            public boolean isEnableCompression() { return enableCompression; }
            public void setEnableCompression(boolean enableCompression) { this.enableCompression = enableCompression; }

            public boolean isEnableCache() { return enableCache; }
            public void setEnableCache(boolean enableCache) { this.enableCache = enableCache; }
        }
    }
}
