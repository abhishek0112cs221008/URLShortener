package model;

import java.sql.*;

public class UrlDao {
    
    private static final String URL = "jdbc:mysql://localhost:3306/url_shortener";
    private static final String USER = "root";
    private static final String PASSWORD = "0000";
    
    private static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); 
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public boolean saveUrlMapping(String longUrl, String shortCode) throws SQLException {
        String query = "INSERT INTO urls (long_url, short_code) VALUES (?, ?)";
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, longUrl);
            ps.setString(2, shortCode);
            return ps.executeUpdate() > 0;
        }
    }

    public String getLongUrl(String shortCode) throws SQLException {
        String query = "SELECT long_url FROM urls WHERE short_code = ?";
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, shortCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("long_url");
                }
            }
        }
        return null;
    }
    
    public boolean shortCodeExists(String shortCode) throws SQLException {
        String query = "SELECT COUNT(*) FROM urls WHERE short_code = ?";
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, shortCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    
    public int countCreated() {
        String query = "SELECT COUNT(*) FROM urls";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1); // Return the count
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0; // Default return if query fails
    }

    public String getShortCodeByLongUrl(String longUrl) throws SQLException {
        String query = "SELECT short_code FROM urls WHERE long_url = ? LIMIT 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, longUrl);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("short_code"); // return existing short code
                }
            }
        }
        return null; // not found
    }
}