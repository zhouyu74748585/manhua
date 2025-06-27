package com.manhua;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * 漫画阅读器应用主类
 * 
 * @author ManhuaReader
 * @version 1.0.0
 */
@SpringBootApplication
@EnableJpaRepositories
@EnableTransactionManagement
@EnableCaching
@EnableAsync
@EnableScheduling
public class ManhuaReaderApplication {

    public static void main(String[] args) {
        // 设置系统属性
        System.setProperty("java.awt.headless", "true");
        System.setProperty("file.encoding", "UTF-8");
        
        // 启动应用
        SpringApplication.run(ManhuaReaderApplication.class, args);
    }
}