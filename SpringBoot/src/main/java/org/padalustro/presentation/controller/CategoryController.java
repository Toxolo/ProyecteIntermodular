package org.padalustro.presentation.controller;

import java.util.List;

import org.padalustro.application.usecase.Category.GetAllCategoryUseCase;
import org.padalustro.infrastructure.DTO.CategoriaDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;





@RestController
@RequestMapping("")
public class CategoryController {

    private final GetAllCategoryUseCase getAllCategory;



    
    public CategoryController(
        GetAllCategoryUseCase getAllCategory) {

    this.getAllCategory = getAllCategory;
}



    @CrossOrigin(origins = "http://localhost:1420")
    @GetMapping("/Category")
    public ResponseEntity<List<CategoriaDTO>> getAll() {
        return ResponseEntity.ok(getAllCategory.execute());
    }


}
