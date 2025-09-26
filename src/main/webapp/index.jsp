<%@ page import="model.UrlDao" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shortener Guru</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
        }

        /* Subtle gradient background for the page */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: radial-gradient(circle at top left, rgba(23, 23, 23, 0.8) 0%, transparent 40%),
                        radial-gradient(circle at bottom right, rgba(23, 23, 23, 0.8) 0%, transparent 40%);
            z-index: -1;
            animation: backgroundFade 5s ease-in-out infinite alternate;
        }

        @keyframes backgroundFade {
            from { opacity: 0.9; }
            to { opacity: 1; }
        }
        
        /* Loading animation for the button */
        .loading {
            pointer-events: none;
            opacity: 0.7;
        }
        
        .loading::after {
            content: '';
            position: absolute;
            width: 20px;
            height: 20px;
            margin: auto;
            border: 2px solid transparent;
            border-top-color: #ffffff;
            border-radius: 50%;
            animation: spin 1s ease infinite;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body class="bg-neutral-900 text-neutral-50 flex flex-col min-h-screen">
    <main class="flex-grow flex flex-col items-center justify-center p-4">
        <!-- Header -->
        <h1 class="text-4xl sm:text-5xl font-bold text-[#228B22] mb-2 text-center">URL Shortener</h1>
        <p class="text-neutral-400 text-lg sm:text-xl mb-4 text-center">Instantly transform long URLs into sleek, shareable links.</p>
        
        <!-- URL Counter -->
        <%
	        UrlDao urlDao = new UrlDao();
			int count = urlDao.countCreated();
			LocalDateTime now = LocalDateTime.now();
		    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
		    String formattedNow = now.format(formatter);

        %>       
        <p class="text-neutral-500 text-sm mb-8 text-center">
            <span id="totalUrls" class="font-bold text-neutral-300"><%= count %></span> short URLs created till <%= formattedNow %>.
        </p>
        
        <!-- Error Message (Backend Driven) -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-900/50 text-red-300 p-4 rounded-lg mb-6 text-sm text-center border border-red-700 max-w-lg mx-auto">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <!-- Form Section -->
        <form method="post" action="shorten" class="form-container w-full max-w-lg mx-auto" id="shortenForm">
            <div class="flex flex-col sm:flex-row items-center justify-center w-full">
                <input 
                    type="url" 
                    name="longUrl" 
                    placeholder="Enter a URL to shorten" 
                    required
                    id="urlInput"
                    class="w-full p-4 text-base bg-neutral-700/50 text-[#228B22] rounded-xl sm:rounded-r-none border border-neutral-700 focus:outline-none placeholder-neutral-500 mb-4 sm:mb-0 transition-all duration-300 focus:border-[#228B22] focus:ring-2 focus:ring-[#228B22]/50"
                >
                <button type="submit" class="submit-btn w-full sm:w-auto p-4 bg-[#228B22] text-white rounded-xl sm:rounded-l-none font-semibold cursor-pointer transition-all duration-300 hover:bg-[#22AD22] active:bg-[#226622] relative overflow-hidden transform hover:-translate-y-1 shadow-lg" id="submitBtn">
                    <span class="px-6">Shorten</span>
                </button>
            </div>
        </form>
    </main>

    <!-- Footer -->
    <footer class="bg-neutral-800/80 backdrop-blur-md text-neutral-500 text-xs text-center py-2 px-4 border-t border-neutral-700 mt-auto">
        <p>&copy; 2025 Shortener Guru. All rights reserved.</p>
    </footer>

    <!-- Firebase SDKs -->
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import { getAuth, signInAnonymously } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
        import { getFirestore, collection, getDocs, setDoc, doc } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

        const firebaseConfig = JSON.parse(__firebase_config);
        const app = initializeApp(firebaseConfig);
        const db = getFirestore(app);
        const auth = getAuth(app);
        const appId = typeof __app_id !== 'undefined' ? __app_id : 'default-app-id';

        // Sign in anonymously to access the database
        signInAnonymously(auth).then(() => {
            console.log('Signed in anonymously');
        }).catch(error => {
            console.error('Anonymous sign-in failed', error);
        });

        // Function to get the total number of short URLs
        async function getShortUrlCount() {
            try {
                const publicCollectionPath = `artifacts/${appId}/public/data/shortUrls`;
                const querySnapshot = await getDocs(collection(db, publicCollectionPath));
                document.getElementById('totalUrls').textContent = querySnapshot.size;
            } catch (error) {
                console.error("Error fetching URL count: ", error);
            }
        }

        window.onload = function() {
            getShortUrlCount();
            document.getElementById('urlInput').focus();
        };

        document.getElementById('shortenForm').addEventListener('submit', function() {
            const btn = document.getElementById('submitBtn');
            btn.classList.add('loading');
            btn.innerHTML = '<span class="px-6">Creating...</span>';
        });

        document.getElementById('urlInput').addEventListener('blur', function() {
            let url = this.value.trim();
            if (url && !url.match(/^https?:\/\//)) {
                this.value = 'https://' + url;
            }
        });
    </script>
</body>
</html>
