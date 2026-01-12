package org.ieseljust.ad.Controller;

import java.util.List;

import org.ieseljust.ad.DTO.VideoCatalegDTO;
import org.ieseljust.ad.Service.VideoCatalegService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;


@RestController
public class VideoCatalegController {
	
	@Autowired
	VideoCatalegService videoCatalegService;
	
	@GetMapping("/")
    public String helloWorld() {
        return "Benvinguts al Cataleg";
    }
	
	@GetMapping("/Cataleg")
    public List<VideoCatalegDTO> getAllVideoCatalegDTO() {
             
		return videoCatalegService.listAllVideoCatalegs();

    }

  @GetMapping("/Cataleg/{id}")
  public VideoCatalegDTO getVideoCataleg(@PathVariable Long id) {
      return videoCatalegService.getVideoCatalegById(id);
  }
  

}
