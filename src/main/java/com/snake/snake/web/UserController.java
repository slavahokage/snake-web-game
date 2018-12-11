package com.snake.snake.web;


import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.snake.snake.model.Results;
import com.snake.snake.model.User;
import com.snake.snake.random.RandomString;
import com.snake.snake.responces.MyResponse;
import com.snake.snake.service.SecurityService;
import com.snake.snake.service.UserService;
import com.snake.snake.storage.StorageService;
import com.snake.snake.validator.UserValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;

@Controller
public class UserController {
    @Autowired
    private UserService userService;

    @Autowired
    private SecurityService securityService;

    @Autowired
    private UserValidator userValidator;

    @Autowired
    private StorageService storageService;

    @Autowired
    private RandomString random;

    @RequestMapping(value = "/registration", method = RequestMethod.GET)
    public String registration(Model model) {
        model.addAttribute("userForm", new User());
        return "registration";
    }

    @RequestMapping(value = "/registration", method = RequestMethod.POST)
    public String registration(@ModelAttribute("userForm") User userForm, BindingResult bindingResult, Model model) {
        userValidator.validate(userForm, bindingResult);

        if (bindingResult.hasErrors()) {
            return "registration";
        }

        userService.save(userForm);

        securityService.autologin(userForm.getUsername(), userForm.getPasswordConfirm());

        return "redirect:/game";
    }

    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String login(Model model, String error, String logout) {
        if (error != null)
            model.addAttribute("error", "Your username and password is invalid.");

        if (logout != null)
            model.addAttribute("message", "You have been logged out successfully.");

        return "login";
    }

    @RequestMapping(value = {"/", "/game"}, method = RequestMethod.GET)
    public String game (HttpServletRequest request,Model model) {
        User currentUser = getCurrentUser(request);
        model.addAttribute("user",currentUser);
        return "game";
    }


    @RequestMapping(value = "/results", method = RequestMethod.POST)
    @ResponseBody
    public String saveResults(@RequestParam("score") Integer score, @RequestParam("time") Integer time, HttpServletRequest request) {

        User currentUser = getCurrentUser(request);
        Results newResult = createNewResult(currentUser,score, time);
        userService.addResult(currentUser,newResult);

        ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
        try {
            String json = ow.writeValueAsString(new MyResponse("ok"));
            return json;
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }

        return null;
    }

    @RequestMapping("/myResults")
    public ModelAndView myResults(HttpServletRequest request) {
        ModelAndView mav = new ModelAndView("my-results");
        User currentUser = getCurrentUser(request);
        List<Results> results = userService.getUserResults(currentUser);
        mav.addObject("user", currentUser);
        mav.addObject("results", results);
        mav.addObject("formatTime", getFormatDates(results));
        return mav;
    }

    @RequestMapping("/bestResults")
    public ModelAndView bestResults(HttpServletRequest request) {
        User currentUser = getCurrentUser(request);
        List<Results> bestResults = userService.getBestUsersResults();
        ModelAndView mav = new ModelAndView("best-results");
        mav.addObject("user", currentUser);
        mav.addObject("bestResults", bestResults);
        mav.addObject("formatTime", getFormatDates(bestResults));
        return mav;
    }


    @RequestMapping(value = "/editAccount", method = RequestMethod.GET)
    public String editAccount(Model model, HttpServletRequest request) {
        User currentUser = getCurrentUser(request);
        model.addAttribute("user",currentUser);
        model.addAttribute("userForm", new User());
        return "edit-account";
    }

    @RequestMapping(value = "/editAccount", method = RequestMethod.POST)
    public String editAccount(@ModelAttribute("userForm") User userForm, @RequestParam("file") MultipartFile file, BindingResult bindingResult, Model model, HttpServletRequest request) {
        User currentUser = getCurrentUser(request);

        userValidator.validateEdit(userForm, bindingResult,currentUser);
        if (bindingResult.hasErrors()) {
            return "edit-account";
        }

        String newName = userForm.getUsername();
        String newPassword = userForm.getPassword();
        String randomString = file.getName()+random.generateNewString();

        if (storageService.store(file,randomString)) {
            String srcImg = randomString;
            userService.update(currentUser, newName, newPassword, srcImg);
        } else {
            userService.update(currentUser, newName, newPassword);
        }

        securityService.autologin(userForm.getUsername(), userForm.getPasswordConfirm());

        return "redirect:/game";
    }

    private List getFormatDates(List<Results> results) {
        List<String> formatDate = new ArrayList<>();
        for (Results r : results) {
            formatDate.add(formatIntegerToTime(r.getTime()));
        }
        return formatDate;
    }

    private String formatIntegerToTime(Integer sec){
        Double hours = Math.floor(sec / 3600);
        Double minutes = Math.floor((sec - (hours * 3600)) / 60);
        Double seconds = sec - (hours * 3600) - (minutes * 60);

        String hoursString = String.valueOf(hours.intValue());
        String minutesString = String.valueOf(minutes.intValue());
        String secondsString = String.valueOf(seconds.intValue());

        if (hours < 10) {
            hoursString = "0" + hoursString;
        }
        if (minutes < 10) {
            minutesString = "0" + minutesString;
        }
        if (seconds < 10) {
            secondsString = "0" + secondsString;
        }

        return hoursString + ":" + minutesString + ":" + secondsString;
    }

    private User getCurrentUser(HttpServletRequest request) {
        String nameOfUser = request.getUserPrincipal().getName();
        return userService.findByUsername(nameOfUser);
    }

    private Results createNewResult(User user, Integer score, Integer time) {
        time = Math.round(time/1000);
        return new Results(user,score,time);
    }
}
