package org.ieseljust.ad;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;


@EnableJpaAuditing
@SpringBootApplication
public class CatalegCRUD {

	public static void main(String[] args) {
		SpringApplication.run(CatalegCRUD.class, args);
	}

}
