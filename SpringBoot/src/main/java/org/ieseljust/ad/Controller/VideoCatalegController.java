package org.ieseljust.ad.Controller;

import java.util.List;

import org.ieseljust.ad.DTO.VideoCatalegDTO;
import org.ieseljust.ad.Service.VideoCatalegService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
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
		  return videoCatalegService.listAllVideoCataleg();
    }


  // @DeleteMapping("/Cataleg/{id}")
  //   public VideoCatalegDTO deleteVideoCataleg(@PathVariable Long id) {
  //     return videoCatalegService.getVideoCatalegById(id);
  // }

  @GetMapping("/Cataleg/{id}")
  public ResponseEntity<VideoCatalegDTO> showVideoCatalegById(@PathVariable Long id){

    VideoCatalegDTO elVideoCataleg=videoCatalegService.getVideoCatalegById(id);
    if (elVideoCataleg==null)
      return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    else
      return new ResponseEntity<>(elVideoCataleg,HttpStatus.OK);
  }
  
@DeleteMapping("/Cataleg/{id}")
public ResponseEntity<String> deleteVideoCataleg(@PathVariable Long id) {
    boolean deleted = videoCatalegService.deleteVideoCataleg(id);

    if (!deleted) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("ID: " + id + " no trobat");
    }

    return ResponseEntity.ok("ID: " + id + " eliminat correctament");
}



}
