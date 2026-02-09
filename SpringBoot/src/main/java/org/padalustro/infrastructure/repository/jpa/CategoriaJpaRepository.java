package org.padalustro.infrastructure.repository.jpa;

import java.util.List;

import org.padalustro.domain.entities.categoria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface CategoriaJpaRepository extends JpaRepository<categoria, Long> {
    // Spring Data genera automàticament findAll, findById, deleteById, existsById, etc.
    List<categoria> findByNameIgnoreCase(String name);
}


/**
 * VideoCatalegJpaRepository és una interfície que hereta de JpaRepository.
 * 
 * JpaRepository és part de Spring Data JPA i proporciona implementacions automàtiques
 * de les operacions bàsiques de persistència (CRUD), com ara:
 *   - findAll(): retorna totes les entitats de la taula.
 *   - findById(id): busca una entitat pel seu ID.
 *   - save(entity): guarda o actualitza una entitat.
 *   - deleteById(id): elimina una entitat pel seu ID.
 *   - existsById(id): comprova si existeix una entitat amb un ID determinat.
 * 
 * Això evita haver d’escriure manualment totes les consultes SQL per operacions comunes,
 * permetent centrar-se només en la lògica de negoci i, si cal, afegir mètodes personalitzats.
 */
