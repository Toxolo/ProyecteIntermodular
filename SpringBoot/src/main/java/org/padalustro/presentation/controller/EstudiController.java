package org.padalustro.presentation.controller;

import java.util.List;

import org.padalustro.application.usecase.Estudi.GetAllEstudiUseCase;
import org.padalustro.infrastructure.DTO.EstudiDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;





@RestController
@RequestMapping("")
public class EstudiController {

    private final GetAllEstudiUseCase getAllEstudi;



    
    public EstudiController(
        GetAllEstudiUseCase getAllEstudi) {
    this.getAllEstudi = getAllEstudi;
}


    @GetMapping("/Estudi")
    public ResponseEntity<List<EstudiDTO>> getAllEstudi() {
        return ResponseEntity.ok(getAllEstudi.execute());
    }


}
