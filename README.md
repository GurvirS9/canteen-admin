# Canteen Manager App 🍔

A robust, beautifully designed administrative dashboard and application built with Flutter. Inspired by the sleek interface flows of modern administrative panels, this app streamlines the manager's process by allowing them to oversee daily orders, configure menu items flexibly, and handle pickup slots dynamically.

## 🚀 Features
- **Real-Time Dashboard**: See your daily summary instantly—total orders, revenue, active and completed orders at a glance with a clean grid overview.
- **Order Lifecycle Management**: A dedicated screen to view, filter, and modify order statuses (Pending, Accepted, Preparing, Ready, Completed) with beautiful tag badges.
- **Smart Menu & Catalog**: Browse, add, and meticulously edit menu items, including categories, pricing, and toggling visibility availability instantly.
- **Dynamic Slot Booking Control**: Add, review, and toggle time slots. Monitor capacity against current orders dynamically to prevent overflow and ensure smooth student pickups.
- **Modern User Experience**: Built with Shimmer loading placeholders, responsive Bottom Sheets for quick edits, and seamless GoRouter navigation.
- **Universal Theme Support**: A fully responsive palette spanning system, light, and dark modes complete with custom reddish accents and iOS-style neutral deep grays configured using Material 3.

## 🏗️ Architecture
The project strictly adheres to a **Layer-First Clean Architecture**, deeply separating concerns for maximum scalability.

```text
lib/
├── core/
│   ├── constants/    # Essential string keys and branding parameters
│   ├── theme/        # Global overarching AppTheme data (Light & Dark)
│   └── utils/        # Global utilities, formatters, and Mock Data
├── data/
│   ├── models/       # Application models (User, Order, MenuItem, Slot)
│   └── services/     # External API and remote interactions
└── presentation/
    ├── providers/    # Riverpod state management and business logic
    ├── screens/      # Complex widget pages and routable shells
    └── widgets/      # Isolated, reusable UI components (Cards, Chips)
```

*Note: The entire codebase utilizes strict, absolute package imports (`import 'package:manager_app/...;`) to guarantee perfectly re-locatable components without relative path breakage.*

## 🛠️ Tech Stack
- **Framework**: `Flutter` (Material 3)
- **State Management**: `Riverpod` (`flutter_riverpod`)
- **Navigation**: `GoRouter`
- **Typography & UI**: `google_fonts`, `shimmer`, `cached_network_image`
- **Data Persistence**: `shared_preferences`
- **Backend & Realtime**: `Supabase`

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
