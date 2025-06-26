package com.manhua;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 漫画阅读器后端应用主类
 * 
 * @author Manhua Reader Team
 * @version 1.0.0
 */
@SpringBootApplication
@EnableAsync
@EnableScheduling
public class ManhuaReaderApplication {

    public static void main(String[] args) {
        SpringApplication.run(ManhuaReaderApplication.class, args);
    }
}