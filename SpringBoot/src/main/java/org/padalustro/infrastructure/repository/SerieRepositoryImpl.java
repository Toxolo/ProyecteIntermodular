package org.padalustro.infrastructure.repository;

import java.util.List;
import java.util.stream.Collectors;

import org.padalustro.domain.repository.SerieRepository;
import org.padalustro.infrastructure.DTO.SerieDTO;
import org.padalustro.infrastructure.repository.jpa.SerieJpaRepository;
import org.springframework.stereotype.Service;
@Service
public class SerieRepositoryImpl implements SerieRepository {

    private final SerieJpaRepository jpaRepository;

    public SerieRepositoryImpl(SerieJpaRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public List<SerieDTO> listAllSeries() {
        return jpaRepository.findAll()
                .stream()
                .map(SerieDTO::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<SerieDTO> findAllDTO() {
        return listAllSeries();
    }

    @Override
    public void saveAll(List<SerieDTO> Series) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'saveAll'");
    }
    @Override
    public List<SerieDTO> findByType(String type) {
        return jpaRepository.findByNameIgnoreCase(type)
            .stream()
            .map(SerieDTO::convertToDTO)
            .toList();
}


}
