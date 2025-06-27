package com.manhua.dto;

import org.springframework.data.domain.Page;

import java.util.List;

/**
 * 分页响应DTO
 * 
 * @param <T> 数据类型
 * @author ManhuaReader
 * @version 1.0.0
 */
public class PageResponse<T> {
    
    private List<T> content;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
    private boolean first;
    private boolean last;
    private boolean empty;
    private int numberOfElements;
    
    public PageResponse() {}
    
    public PageResponse(Page<T> page) {
        this.content = page.getContent();
        this.page = page.getNumber();
        this.size = page.getSize();
        this.totalElements = page.getTotalElements();
        this.totalPages = page.getTotalPages();
        this.first = page.isFirst();
        this.last = page.isLast();
        this.empty = page.isEmpty();
        this.numberOfElements = page.getNumberOfElements();
    }
    
    /**
     * 从Spring Data Page对象创建PageResponse
     */
    public static <T> PageResponse<T> of(Page<T> page) {
        return new PageResponse<>(page);
    }
    
    /**
     * 创建空的分页响应
     */
    public static <T> PageResponse<T> empty() {
        PageResponse<T> response = new PageResponse<>();
        response.content = List.of();
        response.page = 0;
        response.size = 0;
        response.totalElements = 0;
        response.totalPages = 0;
        response.first = true;
        response.last = true;
        response.empty = true;
        response.numberOfElements = 0;
        return response;
    }
    
    /**
     * 创建单页响应
     */
    public static <T> PageResponse<T> of(List<T> content) {
        PageResponse<T> response = new PageResponse<>();
        response.content = content;
        response.page = 0;
        response.size = content.size();
        response.totalElements = content.size();
        response.totalPages = content.isEmpty() ? 0 : 1;
        response.first = true;
        response.last = true;
        response.empty = content.isEmpty();
        response.numberOfElements = content.size();
        return response;
    }
    
    // Getters and Setters
    public List<T> getContent() {
        return content;
    }
    
    public void setContent(List<T> content) {
        this.content = content;
    }
    
    public int getPage() {
        return page;
    }
    
    public void setPage(int page) {
        this.page = page;
    }
    
    public int getSize() {
        return size;
    }
    
    public void setSize(int size) {
        this.size = size;
    }
    
    public long getTotalElements() {
        return totalElements;
    }
    
    public void setTotalElements(long totalElements) {
        this.totalElements = totalElements;
    }
    
    public int getTotalPages() {
        return totalPages;
    }
    
    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }
    
    public boolean isFirst() {
        return first;
    }
    
    public void setFirst(boolean first) {
        this.first = first;
    }
    
    public boolean isLast() {
        return last;
    }
    
    public void setLast(boolean last) {
        this.last = last;
    }
    
    public boolean isEmpty() {
        return empty;
    }
    
    public void setEmpty(boolean empty) {
        this.empty = empty;
    }
    
    public int getNumberOfElements() {
        return numberOfElements;
    }
    
    public void setNumberOfElements(int numberOfElements) {
        this.numberOfElements = numberOfElements;
    }
    
    @Override
    public String toString() {
        return "PageResponse{" +
                "page=" + page +
                ", size=" + size +
                ", totalElements=" + totalElements +
                ", totalPages=" + totalPages +
                ", first=" + first +
                ", last=" + last +
                ", empty=" + empty +
                ", numberOfElements=" + numberOfElements +
                '}';
    }
}