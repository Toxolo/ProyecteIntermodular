package org.padalustro.domain.repository;

import java.util.List;

import org.padalustro.infrastructure.DTO.SerieDTO;



public interface SerieRepository {


    List<SerieDTO> listAllSeries();
    List<SerieDTO> findAllDTO();
    void saveAll(List<SerieDTO> serie);
    
    List<SerieDTO> findByType(String type);

}
