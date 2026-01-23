package org.padalustro.application.usecase.Cataleg;

import org.padalustro.domain.repository.VideoCatalegRepository;
import org.padalustro.infrastructure.DTO.VideoCatalegDTO;

public class UpdateVideoCatalegUseCase {

    private final VideoCatalegRepository videoCatalegRepository;

    public UpdateVideoCatalegUseCase(VideoCatalegRepository videoCatalegRepository) {
        this.videoCatalegRepository = videoCatalegRepository;
    }

    public void execute(Long id, VideoCatalegDTO dto) {
        videoCatalegRepository.updateVideoCataleg(id, dto);
    }
}