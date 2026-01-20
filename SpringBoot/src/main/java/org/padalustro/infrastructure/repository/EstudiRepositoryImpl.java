package org.padalustro.infrastructure.repository;

import java.util.List;
import java.util.stream.Collectors;

import org.padalustro.domain.repository.EstudiRepository;
import org.padalustro.infrastructure.DTO.EstudiDTO;
import org.padalustro.infrastructure.repository.jpa.EstudiJpaRepository;
import org.springframework.stereotype.Service;
@Service
public class EstudiRepositoryImpl implements EstudiRepository {
    
    private final EstudiJpaRepository jpaRepository;

    public EstudiRepositoryImpl(EstudiJpaRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public List<EstudiDTO> listAllEstudis() {
        return jpaRepository.findAll()
                .stream()
                .map(EstudiDTO::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<EstudiDTO> findAllDTO() {
        return listAllEstudis();
    }

    @Override
    public void saveAll(List<EstudiDTO> estudis) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'saveAll'");
    }
    @Override
    public List<EstudiDTO> findByType(String type) {
        return jpaRepository.findByNameIgnoreCase(type)
            .stream()
            .map(EstudiDTO::convertToDTO)
            .toList();
}


}