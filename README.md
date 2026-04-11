# MyMaps

An iOS social mapping app where users share location-tagged posts called "vibes" — places they've visited, loved, or want to remember. Built with SwiftUI, Firebase, and a clean MVVM architecture.

---

## Features

### Map
- Interactive Apple Maps view centered on the user's current location
- Friend posts appear as photo annotations pinned to their real-world coordinates
- Tap a pin to preview the post; tap again to open the full detail view
- Filter map pins by vibe category (Chill, Hype, Hidden Gem, Foodie, Adventure, etc.)
- Place search with live results — tap a result to preview it and create a post there
- Avatar button in the search bar opens the current user's profile

### Discovery Feed
- Instagram-style vertical feed of posts
- **Friends filter** — shows only posts from users you follow (default)
- **Vibe filters** — shows all posts globally for a selected category
- Like posts with an animated heart (optimistic update)
- Comment preview inline; tap to open full comments sheet
- Pull-to-refresh

### Explore
- Search for other users by username
- Follow / unfollow directly from search results
- Follow state updates optimistically

### Profile
- Grid, map, and bookmark tabs
- View your own posts, map of visited places, and saved bucket list items
- View another user's profile with the same three tabs — their bucket list is fetched from Firestore
- Follow / unfollow button on other user profiles with live follower count
- Edit profile photo directly from the avatar (PhotosPicker)
- Tap followers / following counts to see the full user list

### Posts
- Create a post by long-pressing the map or searching for a place
- Attach a photo, write a caption, pick a vibe category, and rate the place (1–5 stars)
- Edit or delete your own posts from the post detail screen
- Save any post to your personal bucket list (bookmark button)
- Open the post's location directly in Apple Maps

### Bucket List
- CoreData-backed local wishlist synced to Firestore
- Add, remove, and browse saved places
- View a friend's bucket list from their profile

### Authentication
- Email / password sign-in and registration
- Forgot password — sends a Firebase reset email with a confirmation screen
- Account deletion from settings

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Architecture | MVVM with Repository pattern |
| Auth | Firebase Authentication |
| Database | Cloud Firestore (real-time listeners) |
| Storage | Firebase Storage |
| Local persistence | CoreData |
| Image loading | SDWebImageSwiftUI |
| Maps | MapKit / Apple Maps |

---

## Architecture

The project follows a strict MVVM architecture with a repository layer separating all Firebase concerns from ViewModels.

```
Views           — SwiftUI views, no business logic
ViewModels      — @MainActor ObservableObject, drive view state
Repositories    — Single-responsibility Firebase data access
Services        — AuthService (Auth), WishlistService (CoreData + Firestore)
Models          — Pure Swift structs, no Firebase imports (except GeoPoint/DocumentID)
Components      — Reusable SwiftUI subviews
```

### Repositories

| Repository | Responsibility |
|---|---|
| `PostRepository` | CRUD + real-time listeners for posts |
| `UserRepository` | Firestore user documents, profile image upload |
| `FollowRepository` | Follow / unfollow batch writes, live follow state |
| `LikeRepository` | Atomic like toggle |
| `CommentRepository` | Comment writes + real-time listener |
| `WishlistRepository` | Fetch a user's public wishlist from Firestore |
| `AuthService` | Wraps all FirebaseAuth calls |
| `WishlistService` | Coordinates CoreData ↔ Firestore wishlist sync |

---

## Setup

### Prerequisites
- Xcode 15+
- iOS 17+ deployment target
- A Firebase project with Authentication, Firestore, and Storage enabled

### Installation

1. Clone the repo
   ```bash
   git clone https://github.com/llsaimur/MyMaps.git
   ```

2. Open `MyMaps.xcodeproj` in Xcode

3. Add your `GoogleService-Info.plist` to the `MyMaps/` target folder (not tracked in git)

4. Build and run on a simulator or device
