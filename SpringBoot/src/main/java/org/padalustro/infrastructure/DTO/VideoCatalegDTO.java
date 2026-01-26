package org.padalustro.infrastructure.DTO;

import java.io.Serializable;
import java.util.Set;
import java.util.stream.Collectors;

import org.padalustro.domain.entities.categoria;
import org.padalustro.domain.entities.estudi;
import org.padalustro.domain.entities.serie;
import org.padalustro.domain.entities.video_cataleg;
import org.padalustro.infrastructure.DTO.IDs.CategoriaIdDTO;
import org.padalustro.infrastructure.DTO.IDs.EstudiIdDTO;
import org.padalustro.infrastructure.DTO.IDs.SerieIdDTO;

import lombok.Data;

@Data
public class VideoCatalegDTO implements Serializable {

	private Long id;

    private String title;

    private String description;

    private Set<CategoriaIdDTO> category;

    private Integer classification;

    private EstudiIdDTO study;

    private double rating;

    private Integer season;

    private SerieIdDTO series;

    private Integer chapter;


    private Integer duration;

	// private LocalDateTime data_creacio;

	// private LocalDateTime data_modif;

	public static VideoCatalegDTO convertToDTO(video_cataleg videoCataleg) {

		VideoCatalegDTO videoCatalegDTO = new VideoCatalegDTO();

        videoCatalegDTO.setId(videoCataleg.getId());
		videoCatalegDTO.setTitle(videoCataleg.getTitle());
		videoCatalegDTO.setDescription(videoCataleg.getDescription());
		if (videoCataleg.getCategory() != null) {
            videoCatalegDTO.setCategory(videoCataleg.getCategory().stream()
                .map(c -> new CategoriaIdDTO(c.getId()))
                .collect(Collectors.toSet()));
        }
		videoCatalegDTO.setClassification(videoCataleg.getClassification());
		if (videoCataleg.getStudy() != null) {
            videoCatalegDTO.setStudy(new EstudiIdDTO(videoCataleg.getStudy().getId()));
        }

		videoCatalegDTO.setRating(videoCataleg.getRating());
        videoCatalegDTO.setSeason(videoCataleg.getSeason());
        if (videoCataleg.getSeries() != null) {
            videoCatalegDTO.setSeries(new SerieIdDTO(videoCataleg.getSeries().getId()));
        }
        videoCatalegDTO.setChapter(videoCataleg.getChapter());
        videoCatalegDTO.setDuration(videoCataleg.getDuration());

		return videoCatalegDTO;

	}

    
	public video_cataleg toEntity() {
        video_cataleg videoCataleg = new video_cataleg();
        videoCataleg.setId(this.getId());
        videoCataleg.setTitle(this.getTitle());
        videoCataleg.setDescription(this.getDescription());


        if (this.getCategory() != null) {
        videoCataleg.setCategory(
            this.getCategory().stream()
                .map(c -> {
                    categoria cat = new categoria();
                    cat.setId(c.getId());
                    return cat;
                })
                .collect(Collectors.toSet())
            );
        }
        videoCataleg.setClassification(this.getClassification());

        if (this.getStudy() != null) {
            estudi study = new estudi();
            study.setId(this.getStudy().getId());
            videoCataleg.setStudy(study);
        }
        videoCataleg.setRating(this.getRating());
        videoCataleg.setSeason(this.getSeason());
        if (this.getSeries() != null) {
            serie series = new serie();
            series.setId(this.getSeries().getId());
            videoCataleg.setSeries(series);
        }
        videoCataleg.setChapter(this.getChapter());
        videoCataleg.setDuration(this.getDuration());
        return videoCataleg;
    }

        

}
