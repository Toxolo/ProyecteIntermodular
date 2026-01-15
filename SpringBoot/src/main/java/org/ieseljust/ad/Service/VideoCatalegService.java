package org.ieseljust.ad.Service;

import java.util.List;

import org.ieseljust.ad.DTO.VideoCatalegDTO;

public interface VideoCatalegService {

    void saveVideoCataleg(VideoCatalegDTO videoCatalegDTO);

    VideoCatalegDTO getVideoCatalegById(Long id);

    List<VideoCatalegDTO> listAllVideoCatalegs();

    void deleteVideoCataleg(Long id);
}
