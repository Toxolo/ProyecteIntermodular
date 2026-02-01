package org.padalustro.domain.repository;

import java.util.List;
import org.padalustro.infrastructure.DTO.CategoriaDTO;

public interface CategoriaRepository {

    // Retorna totes les categories
    List<CategoriaDTO> findAllDTO();


    // Crea o actualitza una categoria
    void save(CategoriaDTO categoria);

    // Actualitza una categoria existent per id
    void updateById(Long id, CategoriaDTO dto);

    // Elimina una categoria per id
    void deleteById(Long id);

    // Guarda una llista de categories
    void saveAll(List<CategoriaDTO> categories);
}
