package controller;

import model.UrlDao;
import utils.HashGenerator;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;

@WebServlet("/shorten")
public class UrlShortenerServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String longUrl = request.getParameter("longUrl");
        
        // Validate input
        if (longUrl == null || longUrl.trim().isEmpty()) {
            request.setAttribute("error", "Please provide a valid URL");
            RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        longUrl = longUrl.trim();
        
        // Validate URL format
        if (!isValidUrl(longUrl)) {
            request.setAttribute("error", "Please provide a valid URL format");
            RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
            dispatcher.forward(request, response);
            return;
        }

        try {
            UrlDao dao = new UrlDao();
            String existingShortCode = dao.getShortCodeByLongUrl(longUrl);
            String shortCode;
            if (existingShortCode != null) {
                // Already exists → reuse old short code
                shortCode = existingShortCode;
            } else {
                // ✅ 2. Generate a new unique short code
                shortCode = generateUniqueShortCode(dao);
                dao.saveUrlMapping(longUrl, shortCode);
            }
            
            
            // Build the short URL
            String baseUrl = getBaseUrl(request);
            String shortUrl = baseUrl + "/r/" + shortCode;

            request.setAttribute("shortUrl", shortUrl);
            request.setAttribute("originalUrl", longUrl);
            RequestDispatcher dispatcher = request.getRequestDispatcher("result.jsp");
            dispatcher.forward(request, response);
            
            
            
			/*
			 * boolean saved = dao.saveUrlMapping(longUrl, shortCode);
			 * 
			 * if (saved) { // Build the short URL String baseUrl = getBaseUrl(request);
			 * String shortUrl = baseUrl + "/r/" + shortCode;
			 * 
			 * request.setAttribute("shortUrl", shortUrl);
			 * request.setAttribute("originalUrl", longUrl); RequestDispatcher dispatcher =
			 * request.getRequestDispatcher("result.jsp"); dispatcher.forward(request,
			 * response); } else { request.setAttribute("error",
			 * "Failed to create short URL. Please try again."); RequestDispatcher
			 * dispatcher = request.getRequestDispatcher("index.jsp");
			 * dispatcher.forward(request, response); }
			 */
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred. Please try again later.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    private String generateUniqueShortCode(UrlDao dao) throws SQLException {
        String shortCode;
        int attempts = 0;
        do {
            shortCode = HashGenerator.generateShortCode();
            attempts++;
            if (attempts > 10) { // Prevent infinite loop
                throw new SQLException("Unable to generate unique short code after multiple attempts");
            }
        } while (dao.shortCodeExists(shortCode));
        
        return shortCode;
    }
    
    private boolean isValidUrl(String url) {
        try {
            // Add protocol if missing
            if (!url.startsWith("http://") && !url.startsWith("https://")) {
                url = "http://" + url;
            }
            new URL(url);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    private String getBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();
        
        StringBuilder baseUrl = new StringBuilder();
        baseUrl.append(scheme).append("://").append(serverName);
        
        if ((scheme.equals("http") && serverPort != 80) || 
            (scheme.equals("https") && serverPort != 443)) {
            baseUrl.append(":").append(serverPort);
        }
        
        baseUrl.append(contextPath);
        return baseUrl.toString();
    }
}