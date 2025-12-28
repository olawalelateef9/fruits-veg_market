// File: ProduceApp.java
package com.produce.vegetables;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@SpringBootApplication
@RestController
@CrossOrigin(origins = "*") // allow calls from your static index.html
public class ProduceApp {

  public static void main(String[] args) {
    SpringApplication.run(ProduceApp.class, args);
  }

  // simple item type (Java 17+ record)
  public record Item(String name, double price) {}

  @GetMapping("/vegetables")
  public Map<String, List<Item>> getVegetables() {
    var vegetables = List.of(
        new Item("Carrot", 0.60),
        new Item("Broccoli", 1.40),
        new Item("Tomato", 0.90),
        new Item("Spinach", 1.10),
        new Item("Potato", 0.50)
    );
    return Map.of("vegetables", vegetables);
  }
}