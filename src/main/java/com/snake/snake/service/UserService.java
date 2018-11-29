package com.snake.snake.service;

import com.snake.snake.model.Results;
import com.snake.snake.model.Role;
import com.snake.snake.model.User;

import java.util.List;

public interface UserService {
    void save(User user);
    void update(User user, String newName, String newPassword, String srcImage);
    void update(User user, String newName, String newPassword);
    User findByUsername(String username);
    void addResult(User user, Results result);
    void addRole(User user, Role role);
    List<Results> getUserResults(User user);
    List<Results> getBestUsersResults();
}
