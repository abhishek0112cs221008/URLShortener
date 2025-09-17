package controller;

import model.UrlDao;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/r/*")
public class RedirectServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Extract short code from URL path
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid short URL");
            return;
        }
        
        String shortCode = pathInfo.substring(1); // Remove leading '/'

        try {
            UrlDao dao = new UrlDao();
            String longUrl = dao.getLongUrl(shortCode);

            if (longUrl != null && !longUrl.trim().isEmpty()) {
                // Ensure the URL has a protocol
                if (!longUrl.startsWith("http://") && !longUrl.startsWith("https://")) {
                    longUrl = "http://" + longUrl;
                }
                response.sendRedirect(longUrl);
            } else {
                response.setContentType("text/html");
                response.getWriter().println(
                	    "<!DOCTYPE html>" +
                	    "<html lang=\"en\">" +
                	    "<head>" +
                	    "    <meta charset=\"UTF-8\">" +
                	    "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
                	    "    <title>URL Not Found</title>" +
                	    "    <style>" +
                	    "        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');" +
                	    "        body {" +
                	    "            font-family: 'Inter', sans-serif;" +
                	    "            background-color: #171717;" +
                	    "            color: #d4d4d4;" +
                	    "            display: flex;" +
                	    "            justify-content: center;" +
                	    "            align-items: center;" +
                	    "            min-height: 100vh;" +
                	    "            text-align: center;" +
                	    "            padding: 2rem;" +
                	    "            margin: 0;" +
                	    "        }" +
                	    "        .container {" +
                	    "            max-width: 500px;" +
                	    "            background-color: #262626;" +
                	    "            padding: 2rem;" +
                	    "            border-radius: 12px;" +
                	    "            border: 1px solid #404040;" +
                	    "            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);" +
                	    "        }" +
                	    "        h1 {" +
                	    "            font-size: 2.5rem;" +
                	    "            font-weight: 700;" +
                	    "            color: #228B22;" +
                	    "            margin-bottom: 1rem;" +
                	    "        }" +
                	    "        p {" +
                	    "            font-size: 1.125rem;" +
                	    "            color: #a3a3a3;" +
                	    "        }" +
                	    "        a {" +
                	    "            color: #228B22;" +
                	    "            text-decoration: none;" +
                	    "            font-weight: 600;" +
                	    "        }" +
                	    "        a:hover {" +
                	    "            text-decoration: underline;" +
                	    "        }" +
                	    "    </style>" +
                	    "</head>" +
                	    "<body>" +
                	    "    <div class=\"container\">" +
                	    "        <h1>URL Not Found</h1>" +
                	    "        <p>The requested short URL does not exist. Please check the URL or create a new one.</p>" +
                	    "        <p><a href=\"<%= request.getContextPath() %>/\">Create a new short URL</a></p>" +
                	    "    </div>" +
                	    "</body>" +
                	    "</html>"
                	);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                             "Database error occurred");
        }
    }
}