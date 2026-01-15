package org.padalustro.domain.repository;

import java.util.List;

import org.padalustro.infrastructure.DTO.CategoriaDTO;



public interface CategoriaRepository {


    List<CategoriaDTO> listAllCategories();
    List<CategoriaDTO> findAllDTO();

}
