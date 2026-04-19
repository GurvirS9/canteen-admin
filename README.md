# Canteen Manager App 🍔

A robust, beautifully designed administrative dashboard and application built with Flutter. Inspired by the sleek interface flows of modern administrative panels, this app streamlines the manager's process by allowing them to oversee daily orders, configure menu items flexibly, and handle pickup slots dynamically.

## 🚀 Features
- **Intelligent Onboarding**: A comprehensive 5-step wizard for new managers to set up their shop details, location, categories, and initial menu.
- **Real-Time Dashboard**: Monitor daily performance with revenue tracking, order volume, and active status summaries.
- **Shop Profile Management**: Easily toggle your canteen's status (Open/Closed) and update shop information on the fly.
- **Order Lifecycle Management**: Process orders through a complete lifecycle—from Pending and Accepted to Preparing, Ready, and Completed—with real-time updates.
- **Shop-Specific Menu control**: Manage a catalog of items unique to your canteen, including category assignment, stock toggling, and image uploads.
- **Dynamic Slot Control**: Manage pickup windows and monitor capacity to ensure a smooth flow of student arrivals.
- **Modern UI/UX**: Built with Material 3, Shimmer loading states, and smooth navigation for a premium administrative experience.

## 🏗️ Architecture
The project strictly adheres to a **Layer-First Clean Architecture**, ensuring deep separation of concerns.

```text
lib/
├── core/
│   ├── constants/    # Essential branding and string keys
│   ├── router/       # GoRouter configuration and route definitions
│   ├── theme/        # Centralized AppTheme (Light & Dark)
│   └── utils/        # Generic helpers, loggers, and time formatters
├── data/
│   ├── models/       # Entities (Shop, MenuItem, Order, Slot, User)
│   └── services/     # API clients, Supabase interactions, and Sockets
└── presentation/
    ├── providers/    # Riverpod State Notifiers and business logic
    ├── screens/      # Feature-based pages and navigation shells
    └── widgets/      # Fragmented, reusable UI components
```

*Note: The entire codebase utilizes strict, absolute package imports (`import 'package:manager_app/...;`) to guarantee perfectly re-locatable components without relative path breakage.*

## 🛠️ Tech Stack
- **Framework**: `Flutter` (Material 3)
- **State Management**: `Riverpod` (`flutter_riverpod`)
- **Navigation**: `GoRouter`
- **typography & UI**: `google_fonts`, `shimmer`, `flutter_animate`, `cached_network_image`
- **Media**: `image_picker` & `image_cropper` for profile/menu photos
- **Data Persistence**: `shared_preferences`
- **Backend**: `Supabase` (Auth, Database, Storage)

## ⚙️ How to Run
1. Ensure you have the Flutter SDK installed and an emulator (or physical device) connected.
2. Clone or download the repository.
3. Install the dependencies:
   ```bash
   flutter pub get
   ```
4. Create a `.env` file in the root of the project with your Supabase keys:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
5. Run the application:
   ```bash
   flutter run
   ```
