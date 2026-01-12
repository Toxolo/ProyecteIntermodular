package org.ieseljust.ad.DTO;

import java.io.Serializable;
import java.sql.Date;
import java.util.Set;

import org.ieseljust.ad.Model.categoria;
import org.ieseljust.ad.Model.estudi;
import org.ieseljust.ad.Model.serie;
import org.ieseljust.ad.Model.video_cataleg;

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

    /* 
	public static video_cataleg convertToEntity(VideoCatalegDTO videoCatalegDTO) {

		video_cataleg videoCataleg = new video_cataleg();

        videoCataleg.setId(videoCatalegDTO.getId());
		videoCataleg.setTitle(videoCatalegDTO.getTitle());
		videoCataleg.setDescription(videoCatalegDTO.getDescription());
		videoCataleg.setCategory(videoCatalegDTO.getCategory());
		videoCataleg.setClassification(videoCatalegDTO.getClassification());
		videoCataleg.setStudy(videoCatalegDTO.getStudy());
		videoCataleg.setRating(videoCatalegDTO.getRating());
        videoCataleg.setSeason(videoCatalegDTO.getSeason());
        videoCataleg.setSeries(videoCatalegDTO.getSeries());
        videoCataleg.setChapter(videoCatalegDTO.getChapter());
        videoCataleg.setDate_emission(videoCatalegDTO.getDate_emission());
        videoCataleg.setThumbnail(videoCatalegDTO.getThumbnail());
        videoCataleg.setDuration(videoCatalegDTO.getDuration());


		return videoCataleg;

	}
        */

}
