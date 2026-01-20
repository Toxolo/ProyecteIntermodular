package org.padalustro.application.usecase.Category;

import java.util.List;

import org.padalustro.domain.repository.CategoriaRepository;
import org.padalustro.infrastructure.DTO.CategoriaDTO;
import org.springframework.stereotype.Service;

@Service
public class GetAllEstudiUseCase {

    private final CategoriaRepository categoriaRepository;

    public GetAllEstudiUseCase(CategoriaRepository categoriaRepository) {
        this.categoriaRepository = categoriaRepository;
    }

    public List<CategoriaDTO> execute() {
        return categoriaRepository.findByType("estudi");
    }
}
