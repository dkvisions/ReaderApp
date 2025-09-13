
A simple iOS news application built with Swift, featuring article fetching, bookmarking, and offline access.

#Features
Fetch latest news articles from API
Save and manage bookmarked articles
Pull-to-refresh for latest updates
Dark Mode and Light Mode toggle via switch
Works offline with cached data using Core Data
Tech Stack & Implementation
Search bar to quickly filter articles by title
User consent added if he try to remove saved Articles


#Tech Stack & Implementation
###Networking
Implemented with async/await for cleaner and modern asynchronous code.
Checks internet availability using Apple’s built-in Network framework before calling APIs.
Image Handling
Uses SDWebImage for efficient image downloading and caching from URLs.

###Data Persistence
Core Data is used to:
Cache the latest API response for offline usage.
Store, update, and retrieve bookmarked articles.

###UI/UX
UITableView + UICollectionView for listing articles and categories.
Built-in Dark Mode / Light Mode support with a toggle switch.
