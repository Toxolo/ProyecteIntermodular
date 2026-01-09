package org.ieseljust.ad.Repository;

import org.ieseljust.ad.Model.video_cataleg;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import jakarta.transaction.Transactional;

@Repository
@Transactional
public interface VideoCatalegRepository extends JpaRepository<video_cataleg, Long>{

}
