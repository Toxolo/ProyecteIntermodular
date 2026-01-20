package org.padalustro.domain.repository;

import java.util.List;

import org.padalustro.infrastructure.DTO.EstudiDTO;



public interface EstudiRepository {


    List<EstudiDTO> listAllEstudis();
    List<EstudiDTO> findAllDTO();
    void saveAll(List<EstudiDTO> estudi);
    
    List<EstudiDTO> findByType(String type);

}
