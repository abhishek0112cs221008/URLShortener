<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Short URL Generated</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
        }

        /* Loading animation and button hover states */
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
        <div class="w-full max-w-5xl text-center">
            <!-- Header -->
            <h1 class="text-4xl sm:text-5xl font-bold text-[#228B22] mb-8 w-full">URL Shortened Successfully!</h1>
            <p class="text-neutral-400 text-lg mb-8">Your long URL has been transformed into a short, shareable link</p>
            
            <!-- Two-part Layout -->
            <div class="flex flex-col sm:flex-row gap-8 w-full">

                <!-- URL Display and Action Buttons -->
                <div class="flex-1 w-full bg-neutral-800 rounded-xl p-6 sm:p-8 border border-neutral-700">
                    <% if (request.getAttribute("originalUrl") != null) { %>
                    <div class="original-url mb-4">
                        <div class="url-label text-sm font-semibold text-neutral-500 uppercase tracking-wide mb-1">Original URL</div>
                        <div class="url-value text-base break-all text-neutral-300"><%= request.getAttribute("originalUrl") %></div>
                    </div>
                    <% } %>
                    
                    <div class="short-url mb-8">
                        <div class="url-label text-sm font-semibold text-neutral-500 uppercase tracking-wide mb-1">Shortened URL</div>
                        <a href="${shortUrl}" target="_blank" class="url-value inline-block text-xl font-bold text-[#228B22] bg-neutral-700 py-3 px-4 rounded-lg mt-2 hover:bg-neutral-600 transition-all duration-200" id="shortUrl">${shortUrl}</a>
                    </div>

                    <div class="action-buttons flex flex-col sm:flex-row gap-4 justify-center">
                        <button class="btn btn-primary bg-[#228B22] text-white rounded-lg p-4 font-semibold cursor-pointer transition-colors duration-200 hover:bg-[#22AD22]" onclick="copyToClipboard()">
                            Copy Link
                        </button>
                        <a href="${shortUrl}" target="_blank" class="btn btn-secondary bg-neutral-700 text-neutral-200 rounded-lg p-4 font-semibold hover:bg-neutral-600 transition-colors duration-200 flex items-center justify-center">
                            Test Link
                        </a>
                    </div>
                </div>
                
                <!-- Stats Section -->
                <div class="flex-1 w-full stats bg-neutral-800 rounded-xl p-6 sm:p-8 border border-neutral-700">
                    <div class="stats-title text-lg font-semibold mb-4 text-[#228B22]">Quick Stats</div>
                    <div class="stats-grid grid grid-cols-3 gap-4">
                        <div class="stat-item text-center">
                            <span class="stat-number text-2xl font-bold text-[#228B22]" id="shortLength">-</span>
                            <div class="stat-label text-xs font-semibold uppercase tracking-wide text-neutral-500 mt-1">Characters</div>
                        </div>
                        <div class="stat-item text-center">
                            <span class="stat-number text-2xl font-bold text-[#228B22]" id="reduction">-</span>
                            <div class="stat-label text-xs font-semibold uppercase tracking-wide text-neutral-500 mt-1">Reduction</div>
                        </div>
                        <div class="stat-item text-center">
                            <span class="stat-number text-2xl font-bold text-[#228B22]">Forever</span>
                            <div class="stat-label text-xs font-semibold uppercase tracking-wide text-neutral-500 mt-1">Valid Until</div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Back Link -->
			<a href="<%= request.getContextPath() %>/" class="back-link px-4 py-2 bg-[#228B22] text-white font-semibold rounded hover:bg-[#22AD22] transition-colors duration-200 mt-8 inline-block">
			    Create Another Short URL
			</a>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-neutral-800/80 backdrop-blur-md text-neutral-500 text-xs text-center py-2 px-4 border-t border-neutral-700 mt-auto">
        <p>&copy; 2025 Shortener Guru. All rights reserved.</p>
    </footer>

    <!-- Toast notification -->
    <div class="toast fixed bottom-8 left-1/2 transform -translate-x-1/2 bg-[#228B22] text-white py-3 px-6 rounded-lg font-semibold opacity-0 transition-all duration-300 ease-in-out z-50" id="toast">
        Link copied to clipboard!
    </div>
    
    <script>
        function copyToClipboard() {
            const shortUrl = document.getElementById('shortUrl').textContent;
            
            // Check for navigator.clipboard API support
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(shortUrl).then(function() {
                    showToast();
                }).catch(function() {
                    fallbackCopy(shortUrl);
                });
            } else {
                fallbackCopy(shortUrl);
            }
        }

        // Fallback for older browsers
        function fallbackCopy(text) {
            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed'; // Prevents scrolling to bottom of page
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            try {
                document.execCommand('copy');
                showToast();
            } catch (err) {
                console.error('Failed to copy text', err);
            }
            document.body.removeChild(textArea);
        }

        function showToast() {
            const toast = document.getElementById('toast');
            toast.classList.add('opacity-100', 'bottom-8');
            setTimeout(() => {
                toast.classList.remove('opacity-100', 'bottom-8');
            }, 3000);
        }

        // Calculate and display stats
        window.addEventListener('load', function() {
            const shortUrl = document.getElementById('shortUrl').textContent;
            const originalUrl = '<%= request.getAttribute("originalUrl") != null ? request.getAttribute("originalUrl") : "" %>';
            
            if (originalUrl) {
                const shortLength = shortUrl.length;
                const originalLength = originalUrl.length;
                const reduction = Math.round(((originalLength - shortLength) / originalLength) * 100);
                
                document.getElementById('shortLength').textContent = shortLength;
                document.getElementById('reduction').textContent = reduction + '%';
            } else {
                document.getElementById('shortLength').textContent = shortUrl.length;
                document.getElementById('reduction').textContent = 'N/A';
            }
        });

        // Auto-select short URL for easy copying
        document.getElementById('shortUrl').addEventListener('click', function(e) {
            e.preventDefault();
            copyToClipboard();
        });
    </script>
</body>
</html>
