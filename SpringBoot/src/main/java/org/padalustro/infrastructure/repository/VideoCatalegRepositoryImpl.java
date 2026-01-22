package org.padalustro.infrastructure.repository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.padalustro.domain.entities.video_cataleg;
import org.padalustro.domain.repository.VideoCatalegRepository;
import org.padalustro.infrastructure.DTO.VideoCatalegDTO;
import org.padalustro.infrastructure.repository.jpa.VideoCatalegJpaRepository;
import org.springframework.stereotype.Service;

@Service
public class VideoCatalegRepositoryImpl implements VideoCatalegRepository {

    private final VideoCatalegJpaRepository jpaRepository;

    public VideoCatalegRepositoryImpl(VideoCatalegJpaRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public List<VideoCatalegDTO> listAllVideoCataleg() {
        return jpaRepository.findAll()
                .stream()
                .map(VideoCatalegDTO::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public VideoCatalegDTO getVideoCatalegById(Long id) {
        return jpaRepository.findById(id)
                .map(VideoCatalegDTO::convertToDTO)
                .orElse(null);
    }

    @Override
    public boolean deleteVideoCataleg(Long id) {
        Optional<video_cataleg> video = jpaRepository.findById(id);
        if (video.isPresent()) {
            jpaRepository.delete(video.get());
            return true;
        }
        return false;
    }

    @Override

    public void saveVideoCataleg(VideoCatalegDTO dto) {
        video_cataleg entity = dto.toEntity();
        jpaRepository.save(entity);
    }
    
    @Override
    public boolean existsById(Long id) {
        return jpaRepository.existsById(id);
    }

    @Override
    public void deleteById(Long id) {
        jpaRepository.deleteById(id);
    }

    @Override
    public List<VideoCatalegDTO> findAllDTO() {
        return listAllVideoCataleg();
    }

    @Override
    public Optional<VideoCatalegDTO> findByIdDTO(Long id) {
        return jpaRepository.findById(id).map(VideoCatalegDTO::convertToDTO);
    }

    @Override
    public Optional<video_cataleg> findById(Long id) {
        return jpaRepository.findById(id);
    }

    @Override
    public void delete(video_cataleg video_cataleg) {
        jpaRepository.delete(video_cataleg);
    }
    @Override
    public void updateVideoCataleg(Long id, VideoCatalegDTO dto) {
        Optional<video_cataleg> existingEntityOpt = jpaRepository.findById(id);
        if (existingEntityOpt.isPresent()) {
            video_cataleg existingEntity = existingEntityOpt.get();
            existingEntity.setTitle(dto.getTitle());
            existingEntity.setDescription(dto.getDescription());
            // Update other fields as necessary
            jpaRepository.save(existingEntity);
        }
    }
}
