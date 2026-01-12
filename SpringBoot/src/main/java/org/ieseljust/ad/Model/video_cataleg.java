package org.ieseljust.ad.Model;


import java.sql.Date;
import java.util.Set;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;



// many to one serie
// many to one estudi
// many to many categoria

@Data
@Entity
@Table(name = "video_cataleg")
public class video_cataleg {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_video_cataleg")
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String description;

    @ManyToMany
    @JoinTable(
        name = "video_categoria",
        joinColumns = @JoinColumn(name = "id_video_cataleg"),
        inverseJoinColumns = @JoinColumn(name = "categoria_id")
    )
    private Set<categoria> categori;

    @Column(nullable = false)
    private Integer classification;

    @ManyToOne
    @JoinColumn(name = "estudi_id", nullable = false)
    private estudi study;

    @Column(nullable = true)
    private double rating;
    
    @Column(nullable = true)
    private Integer season;

    @ManyToOne
    @JoinColumn(name = "serie_id", nullable = true)
    private serie series;

    @Column(nullable = false)
    private Integer chapter;

    @Column(nullable = false)
    private Date date_emission;

    @Column(nullable = false)
    private String thumbnail;

    @Column(nullable = false)
    private Integer duration;

    public video_cataleg() {
    }

    public video_cataleg(String title, String description, Set<categoria> categori, Integer classification, estudi study,
            double rating, Integer season, serie series, Integer chapter, Date date_emission, String thumbnail,
            Integer duration) {
        this.title = title;
        this.description = description;
        this.categori = categori;
        this.classification = classification;
        this.study = study;
        this.rating = rating;
        this.season = season;
        this.series = series;
        this.chapter = chapter;
        this.date_emission = date_emission;
        this.thumbnail = thumbnail;
        this.duration = duration;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Set<categoria> getCategori() {
        return categori;
    }

    public void setCategori(Set<categoria> categori) {
        this.categori = categori;
    }

    public Integer getClassification() {
        return classification;
    }

    public void setClassification(Integer classification) {
        this.classification = classification;
    }

    public estudi getStudy() {
        return study;
    }

    public void setStudy(estudi study) {
        this.study = study;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public Integer getSeason() {
        return season;
    }

    public void setSeason(Integer season) {
        this.season = season;
    }

    public serie getSeries() {
        return series;
    }

    public void setSeries(serie series) {
        this.series = series;
    }

    public Integer getChapter() {
        return chapter;
    }

    public void setChapter(Integer chapter) {
        this.chapter = chapter;
    }

    public Date getDateEmission() {
        return date_emission;
    }

    public void setDateEmission(Date date_emission) {
        this.date_emission = date_emission;
    }

    public String getThumbnail() {
        return thumbnail;
    }

    public void setThumbnail(String thumbnail) {
        this.thumbnail = thumbnail;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }


    
}