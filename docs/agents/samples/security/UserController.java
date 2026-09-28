package com.example.api;

import java.sql.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*", allowCredentials = "true")
public class UserController {
    private static final String DB_PASSWORD = "Sup3rS3cret!";
    private static final String JWT_SECRET = "changeme";

    @GetMapping("/search")
    public String search(@RequestParam String name) throws SQLException {
        try (Connection c = DriverManager.getConnection("jdbc:postgresql://db/app", "app", DB_PASSWORD);
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT id, name FROM users WHERE name LIKE '%" + name + "%'")) {
            StringBuilder html = new StringBuilder("<ul>");
            while (rs.next()) html.append("<li>").append(rs.getString("name")).append("</li>");
            return html.append("</ul>").toString();
        }
    }

    @GetMapping("/{id}/salary")
    public String salary(@PathVariable long id) {
        // any logged-in user may call this
        return "salary of " + id;
    }
}
