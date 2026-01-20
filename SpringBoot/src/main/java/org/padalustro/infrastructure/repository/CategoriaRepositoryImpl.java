package org.padalustro.infrastructure.repository;

import java.util.List;
import java.util.stream.Collectors;

import org.padalustro.domain.repository.CategoriaRepository;
import org.padalustro.infrastructure.DTO.CategoriaDTO;
import org.padalustro.infrastructure.repository.jpa.CategoriaJpaRepository;
import org.springframework.stereotype.Service;
@Service
public class CategoriaRepositoryImpl implements CategoriaRepository {

    private final CategoriaJpaRepository jpaRepository;

    public CategoriaRepositoryImpl(CategoriaJpaRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public List<CategoriaDTO> listAllCategories() {
        return jpaRepository.findAll()
                .stream()
                .map(CategoriaDTO::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<CategoriaDTO> findAllDTO() {
        return listAllCategories();
    }

    @Override
    public void saveAll(List<CategoriaDTO> categories) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'saveAll'");
    }
    @Override
    public List<CategoriaDTO> findByType(String type) {
        return jpaRepository.findByNameIgnoreCase(type)
            .stream()
            .map(CategoriaDTO::convertToDTO)
            .toList();
}


}
