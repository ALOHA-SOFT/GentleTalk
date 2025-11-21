package com.gentle.talk.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping({"/", ""})
    public String home() {
        // ✅ Swagger 기본 경로 : /swagger-ui/index.html
        return "redirect:/swagger-ui/index.html";
    }
    
    
}