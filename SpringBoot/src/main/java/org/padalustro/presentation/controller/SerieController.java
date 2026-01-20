package org.padalustro.presentation.controller;

import java.util.List;

import org.padalustro.application.usecase.Serie.GetAllSerieUseCase;
import org.padalustro.infrastructure.DTO.SerieDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;





@RestController
@RequestMapping("")
public class SerieController {

    private final GetAllSerieUseCase getAllSerie;



    
    public SerieController(
        GetAllSerieUseCase getAllSerie) {
    this.getAllSerie = getAllSerie;
}



    @GetMapping("/Serie")
    public ResponseEntity<List<SerieDTO>> getAllSerie() {
        return ResponseEntity.ok(getAllSerie.execute());
    }


}
