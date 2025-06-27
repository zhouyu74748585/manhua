package com.manhua.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 数据库配置
 */
@Configuration
@EnableJpaRepositories(basePackages = "com.manhua.repository")
@EnableTransactionManagement
public class DatabaseConfig {

    @Value("${app.data-path}")
    private String dataPath;

    /**
     * 初始化数据目录
     */
    @Bean
    public String initializeDataDirectory() {
        try {
            Path dataDir = Paths.get(dataPath);
            if (!Files.exists(dataDir)) {
                Files.createDirectories(dataDir);
            }

            // 创建子目录
            String[] subDirs = {
                "database",
                "cache",
                "thumbnails",
                "covers",
                "temp",
                "logs"
            };

            for (String subDir : subDirs) {
                Path subDirPath = dataDir.resolve(subDir);
                if (!Files.exists(subDirPath)) {
                    Files.createDirectories(subDirPath);
                }
            }

            return dataPath;
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize data directory: " + dataPath, e);
        }
    }
}
