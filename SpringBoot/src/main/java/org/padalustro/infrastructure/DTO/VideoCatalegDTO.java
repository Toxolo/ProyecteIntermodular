package org.padalustro.infrastructure.DTO;

import java.io.Serializable;
import java.sql.Date;
import java.util.Set;

import org.padalustro.domain.entities.categoria;
import org.padalustro.domain.entities.estudi;
import org.padalustro.domain.entities.serie;
import org.padalustro.domain.entities.video_cataleg;

import lombok.Data;

@Data
public class VideoCatalegDTO implements Serializable {

	private Long id;

    private String title;

    private String description;

    private Set<categoria> category;

    private Integer classification;

    private estudi study;

    private double rating;

    private Integer season;

    private serie series;

    private Integer chapter;

    private Date date_emission;

    private String thumbnail;

    private Integer duration;

	// private LocalDateTime data_creacio;

	// private LocalDateTime data_modif;

	public static VideoCatalegDTO convertToDTO(video_cataleg videoCataleg) {

		VideoCatalegDTO videoCatalegDTO = new VideoCatalegDTO();

        videoCatalegDTO.setId(videoCataleg.getId());
		videoCatalegDTO.setTitle(videoCataleg.getTitle());
		videoCatalegDTO.setDescription(videoCataleg.getDescription());
		videoCatalegDTO.setCategory(videoCataleg.getCategory());
		videoCatalegDTO.setClassification(videoCataleg.getClassification());
		videoCatalegDTO.setStudy(videoCataleg.getStudy());
		videoCatalegDTO.setRating(videoCataleg.getRating());
        videoCatalegDTO.setSeason(videoCataleg.getSeason());
        videoCatalegDTO.setSeries(videoCataleg.getSeries());
        videoCatalegDTO.setChapter(videoCataleg.getChapter());
        videoCatalegDTO.setDate_emission(videoCataleg.getDate_emission());
        videoCatalegDTO.setThumbnail(videoCataleg.getThumbnail());
        videoCatalegDTO.setDuration(videoCataleg.getDuration());

		return videoCatalegDTO;

	}

    
	public video_cataleg toEntity() {
        video_cataleg videoCataleg = new video_cataleg();
        videoCataleg.setId(this.getId());
        videoCataleg.setTitle(this.getTitle());
        videoCataleg.setDescription(this.getDescription());
        videoCataleg.setCategory(this.getCategory());
        videoCataleg.setClassification(this.getClassification());
        videoCataleg.setStudy(this.getStudy());
        videoCataleg.setRating(this.getRating());
        videoCataleg.setSeason(this.getSeason());
        videoCataleg.setSeries(this.getSeries());
        videoCataleg.setChapter(this.getChapter());
        videoCataleg.setDate_emission(this.getDate_emission());
        videoCataleg.setThumbnail(this.getThumbnail());
        videoCataleg.setDuration(this.getDuration());
        return videoCataleg;
    }

        

}
