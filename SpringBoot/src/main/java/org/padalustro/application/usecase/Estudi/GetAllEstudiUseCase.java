package org.padalustro.application.usecase.Estudi;

import java.util.List;

import org.padalustro.domain.repository.EstudiRepository;
import org.padalustro.infrastructure.DTO.EstudiDTO;
import org.springframework.stereotype.Service;
@Service
public class GetAllEstudiUseCase {

    private final EstudiRepository EstudiRepository;

    public GetAllEstudiUseCase(EstudiRepository EstudiRepository) {
        this.EstudiRepository = EstudiRepository;
    }

    public List<EstudiDTO> execute() {
        return EstudiRepository.findAllDTO();
    }
}
