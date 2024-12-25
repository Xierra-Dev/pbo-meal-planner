package com.nutriguide.service;

import com.nutriguide.exception.BadRequestException;
import com.nutriguide.model.Category;
import com.nutriguide.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

    @Autowired
    private CategoryRepository categoryRepository;

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    public Category createCategory(Category category) {
        if (categoryRepository.existsByName(category.getName())) {
            throw new BadRequestException("Category name already exists");
        }
        return categoryRepository.save(category);
    }
}