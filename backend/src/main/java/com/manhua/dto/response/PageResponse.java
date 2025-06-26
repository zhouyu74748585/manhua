package com.manhua.dto.response;

import lombok.Data;

import java.util.List;

/**
 * 分页响应
 */
@Data
public class PageResponse<T> {

    /**
     * 数据列表
     */
    private List<T> content;

    /**
     * 当前页码（从0开始）
     */
    private Integer page;

    /**
     * 每页大小
     */
    private Integer size;

    /**
     * 总元素数
     */
    private Long totalElements;

    /**
     * 总页数
     */
    private Integer totalPages;

    /**
     * 是否为第一页
     */
    private Boolean first;

    /**
     * 是否为最后一页
     */
    private Boolean last;

    /**
     * 是否有下一页
     */
    private Boolean hasNext;

    /**
     * 是否有上一页
     */
    private Boolean hasPrevious;

    public PageResponse() {}

    public PageResponse(List<T> content, Integer page, Integer size, Long totalElements) {
        this.content = content;
        this.page = page;
        this.size = size;
        this.totalElements = totalElements;
        this.totalPages = (int) Math.ceil((double) totalElements / size);
        this.first = page == 0;
        this.last = page >= totalPages - 1;
        this.hasNext = page < totalPages - 1;
        this.hasPrevious = page > 0;
    }

    /**
     * 创建分页响应
     */
    public static <T> PageResponse<T> of(List<T> content, Integer page, Integer size, Long totalElements) {
        return new PageResponse<>(content, page, size, totalElements);
    }

    /**
     * 创建空分页响应
     */
    public static <T> PageResponse<T> empty(Integer page, Integer size) {
        return new PageResponse<>(List.of(), page, size, 0L);
    }
}