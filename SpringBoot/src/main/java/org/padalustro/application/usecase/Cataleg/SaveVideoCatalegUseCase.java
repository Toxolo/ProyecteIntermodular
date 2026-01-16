package org.padalustro.application.usecase.Cataleg;

import org.padalustro.domain.entities.video_cataleg;
import org.padalustro.domain.repository.VideoCatalegRepository;

public class SaveVideoCatalegUseCase {

    private final VideoCatalegRepository videoCatalegRepository;

    public SaveVideoCatalegUseCase(VideoCatalegRepository videoCatalegRepository) {
        this.videoCatalegRepository = videoCatalegRepository;
    }

    public void execute(video_cataleg video) {
        videoCatalegRepository.save(video);
    }
}
