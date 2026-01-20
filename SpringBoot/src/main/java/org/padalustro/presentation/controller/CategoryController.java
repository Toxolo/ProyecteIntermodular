package org.padalustro.presentation.controller;

import java.util.List;

import org.padalustro.application.usecase.Category.GetAllCategoryUseCase;
import org.padalustro.application.usecase.Category.GetAllEstudiUseCase;
import org.padalustro.application.usecase.Category.GetAllSerieUseCase;
import org.padalustro.infrastructure.DTO.CategoriaDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;





@RestController
@RequestMapping("")
public class CategoryController {

    private final GetAllCategoryUseCase getAllCategory;
    private final GetAllEstudiUseCase getAllEstudi;
    private final GetAllSerieUseCase getAllSerie;



    
    public CategoryController(
        GetAllCategoryUseCase getAllCategory,
        GetAllEstudiUseCase getAllEstudi,
        GetAllSerieUseCase getAllSerie) {

    this.getAllCategory = getAllCategory;
    this.getAllEstudi = getAllEstudi;
    this.getAllSerie = getAllSerie;
}



   
    @GetMapping("/Category")
    public ResponseEntity<List<CategoriaDTO>> getAll() {
        return ResponseEntity.ok(getAllCategory.execute());
    }
    @GetMapping("/Estudi")
    public ResponseEntity<List<CategoriaDTO>> getAllEstudi() {
        return ResponseEntity.ok(getAllEstudi.execute());
    }

    @GetMapping("/Serie")
    public ResponseEntity<List<CategoriaDTO>> getAllSerie() {
        return ResponseEntity.ok(getAllSerie.execute());
    }


}
