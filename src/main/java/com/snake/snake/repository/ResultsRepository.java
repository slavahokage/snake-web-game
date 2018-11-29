package com.snake.snake.repository;

import com.snake.snake.model.Results;
import com.snake.snake.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ResultsRepository extends JpaRepository<Results, Long> {

    @Query("SELECT r FROM Results r WHERE r.user = ?1 ORDER BY r.score desc, r.time asc ")
    List<Results> findAllResultsOfUser(User user);

    @Query("SELECT r FROM Results r WHERE r.time = (SELECT MIN(time) FROM Results WHERE user = r.user and score = (SELECT MAX(score) from Results WHERE user = r.user )) GROUP by r.user")
    List<Results> findBestResultsOfUser();
}
