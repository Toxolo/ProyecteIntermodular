package org.ieseljust.ad.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.ieseljust.ad.DTO.VideoCatalegDTO;
import org.ieseljust.ad.Model.video_cataleg;
import org.ieseljust.ad.Repository.VideoCatalegRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class VideoCatalegServiceImpl implements VideoCatalegService {

    @Autowired
    private VideoCatalegRepository videoCatalegRepository;

    /* 
    @Override
    public void saveVideoCataleg(VideoCatalegDTO videoCatalegDTO) {
        video_cataleg video = VideoCatalegDTO.convertToEntity(videoCatalegDTO);
        videoCatalegRepository.save(video);
    }
*/
    

    

    @Override
    public List<VideoCatalegDTO> listAllVideoCataleg() {
        List<video_cataleg> videoCatalegs = videoCatalegRepository.findAll();

        List<VideoCatalegDTO> dtoList = new ArrayList<>();
        for (video_cataleg v : videoCatalegs) {
            dtoList.add(VideoCatalegDTO.convertToDTO(v));
        }
        return dtoList;
    }

@Override
    public VideoCatalegDTO getVideoCatalegById(Long id) {
        Optional<video_cataleg> video = videoCatalegRepository.findById(id);

        if (video.isPresent())
            return VideoCatalegDTO.convertToDTO(video.get());
        
        return null;

    }



@Override
public boolean deleteVideoCataleg(Long id) {
    Optional<video_cataleg> video = videoCatalegRepository.findById(id);

    if (video.isPresent()) {
        videoCatalegRepository.delete(video.get());
        return true;
    }

    return false;
}



}
