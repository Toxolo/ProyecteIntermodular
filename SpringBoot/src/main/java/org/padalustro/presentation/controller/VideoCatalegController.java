package org.padalustro.presentation.controller;

import java.util.List;

import org.padalustro.application.usecase.Cataleg.DeleteVideoCatalegUseCase;
import org.padalustro.application.usecase.Cataleg.GetAllVideoCatalegUseCase;
import org.padalustro.application.usecase.Cataleg.GetVideoCatalegByIdUseCase;
import org.padalustro.application.usecase.Cataleg.SaveVideoCatalegUseCase;
import org.padalustro.domain.repository.VideoCatalegRepository;
import org.padalustro.infrastructure.DTO.VideoCatalegDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;





@RestController
@RequestMapping("/Cataleg")
public class VideoCatalegController {
    @Autowired
    private VideoCatalegRepository videoCatalegRepository;
    private final SaveVideoCatalegUseCase postVideoCataleg;
    private final GetAllVideoCatalegUseCase getAllVideoCataleg;
    private final GetVideoCatalegByIdUseCase getVideoCatalegById;
    private final DeleteVideoCatalegUseCase deleteVideoCataleg;

    
    public VideoCatalegController(
            GetAllVideoCatalegUseCase getAllVideoCataleg,
            GetVideoCatalegByIdUseCase getVideoCatalegById,
            DeleteVideoCatalegUseCase deleteVideoCataleg,
            SaveVideoCatalegUseCase postVideoCataleg
        ) {

        this.getAllVideoCataleg = getAllVideoCataleg;
        this.getVideoCatalegById = getVideoCatalegById;
        this.deleteVideoCataleg = deleteVideoCataleg;
        this.postVideoCataleg = postVideoCataleg;
    }

    @GetMapping("/")
    public String helloWorld() {
        return "Benvinguts al Cataleg";
    }

   
    @GetMapping
    public ResponseEntity<List<VideoCatalegDTO>> getAll() {
        return ResponseEntity.ok(getAllVideoCataleg.execute());
    }

    @GetMapping("/{id}")
    public ResponseEntity<VideoCatalegDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(getVideoCatalegById.execute(id));
    }

    
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        deleteVideoCataleg.execute(id);
        return ResponseEntity.noContent().build(); // 204
    }


    @PostMapping
    public ResponseEntity<Void> createVideo(@RequestBody VideoCatalegDTO video) {
        postVideoCataleg.execute(video);
        return ResponseEntity.status(201).build();
    }



    // to-do:
    // cambiar a use case
    @PutMapping("/{id}")
    public ResponseEntity<Void> updateVideo(
            @PathVariable Long id,
            @RequestBody VideoCatalegDTO video
    ) {
        if (!videoCatalegRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }

        videoCatalegRepository.updateVideoCataleg(id, video);
        return ResponseEntity.ok().build();
    }


}
