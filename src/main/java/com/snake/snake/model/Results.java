package com.snake.snake.model;

import javax.persistence.*;
import java.sql.Time;

@Entity
@Table(name = "user_results")
public class Results{
    private int id;
    private Integer score;
    private Integer time;
    private User user;


    public Results() {
    }

    public Results(User user, Integer score, Integer time) {
        this.user = user;
        this.score = score;
        this.time = time;
    }

    public Results(Integer score, Integer time) {
        this.score = score;
        this.time = time;
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getScore() {
        return score;
    }

    public Integer getTime() {
        return time;
    }

    public void setTime(Integer time) {
        this.time = time;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    @ManyToOne(cascade=CascadeType.ALL)
    @JoinColumn(name = "user_id")
    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}

