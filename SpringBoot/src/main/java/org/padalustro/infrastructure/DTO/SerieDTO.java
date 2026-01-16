package org.padalustro.infrastructure.DTO
;

import java.io.Serializable;

import org.padalustro.domain.entities.serie;

import lombok.Data;

@Data
public class SerieDTO implements Serializable {
    private Long id;
    private String name;

    public SerieDTO() {}

    public SerieDTO(Long id, String name) {
        this.id = id;
        this.name = name;
    }

    public static SerieDTO convertToDTO(serie serie) {
        SerieDTO SerieDTO = new SerieDTO();
        SerieDTO.setId(serie.getId());
        SerieDTO.setName(serie.getName());
        return SerieDTO;
    }

    public serie toEntity() {
        serie serie = new serie();
        serie.setId(this.id);
        serie.setName(this.name);
        return serie;
    }

    
}
