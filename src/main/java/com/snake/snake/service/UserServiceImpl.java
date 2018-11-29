package com.snake.snake.service;

import com.snake.snake.model.Results;
import com.snake.snake.model.Role;
import com.snake.snake.model.User;
import com.snake.snake.repository.ResultsRepository;
import com.snake.snake.repository.RoleRepository;
import com.snake.snake.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;

@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private RoleRepository roleRepository;
    @Autowired
    private ResultsRepository resultsRepository;


    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    @Override
    public void save(User user) {
        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
        user.setRoles(new HashSet<>(roleRepository.findAll()));
        user.setSrcImage("files/user_default_logo.png");
        userRepository.save(user);
    }

    @Override
    public void update(User user, String newName, String newPassword, String srcImage) {
        user.setPassword(bCryptPasswordEncoder.encode(newPassword));
        user.setUsername(newName);
        user.setRoles(new HashSet<>(roleRepository.findAll()));
        user.setSrcImage("files/"+srcImage);
        userRepository.save(user);
    }

    @Override
    public void update(User user, String newName, String newPassword) {
        user.setPassword(bCryptPasswordEncoder.encode(newPassword));
        user.setUsername(newName);
        user.setRoles(new HashSet<>(roleRepository.findAll()));
        userRepository.save(user);
    }

    @Override
    public User findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Override
    public void addResult(User user, Results result) {
        user.getResults().add(result);
        userRepository.save(user);
    }

    @Override
    public void addRole(User user, Role role) {
        user.getRoles().add(role);
        userRepository.save(user);
    }

    @Override
    public List<Results> getUserResults(User user) {
        List<Results> results = resultsRepository.findAllResultsOfUser(user);
        return results;
    }

    @Override
    public List<Results> getBestUsersResults() {
        List<Results> results = resultsRepository.findBestResultsOfUser();
        return results;
    }
}
