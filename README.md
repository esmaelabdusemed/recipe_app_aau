# Recipe Browser – AAU Gourmet

**Name:** Esuma Abdusemed  
**Student ID:** 9586  
**Track:** C – Recipe Browser (TheMealDB API)  
**Instructor:** Abel Tadesse  

## 📌 Description
A Flutter recipe browsing app that lets users explore meals by category (Beef, Chicken, Vegan, Dessert, Pasta, etc.), view full recipes including ingredients and cooking instructions, and watch YouTube tutorials – all with **offline caching**.  
The app uses TheMealDB API and stores the last viewed category and recipes locally, so you can browse even without an internet connection (cached data is shown with a badge, and fresh data is fetched when back online).

## ✨ Features (including bonuses)
- **Category browsing** – horizontal scrollable category bar with stylish animations.
- **Recipe grid** – 4‑column grid of meals with images and names.
- **Detailed floating card** – tap any meal to see a large modal card with:
  - Full ingredients list,
  - Step‑by‑step cooking instructions,
  - YouTube button (opens the official recipe video).
- **Persistent local cache** – uses `shared_preferences` to save API responses; when offline, the app displays previously loaded recipes and details (bonus +5 marks).
- **Error handling with Retry** – if network fails and no cache exists, a user‑friendly error screen appears with a Retry button.

## 🚀 How to run the project
1. **Clone the repository** (or open the extracted folder).
2. Open a terminal in the project root.
3. Run `flutter pub get` to install dependencies.
4. Run the app: `flutter run -d chrome` (or on an Android emulator).

## 🌐 API Endpoints used
| Endpoint | Purpose |
|----------|---------|
| `filter.php?c={category}` | Fetch meals by category (e.g., Beef, Chicken) |
| `lookup.php?i={mealId}` | Fetch full recipe details (ingredients, instructions, YouTube link) |

## 📂 Project structure (simplified)
lib/
├── main.dart # App entry
├── screens/
│ └── recipe_list_screen.dart # Main grid + category bar + detail floating card
## ⚠️ Known limitations / bugs
- The “All” category shows “Seafood” because TheMealDB doesn’t have an “All” endpoint – this is a known workaround.
- Cached data is stored in memory (shared_preferences) and persists until the app is cleared or uninstalled.
- YouTube button opens in an external browser (default system behaviour).

## 🎥 Demo video
[Replace with your Google Drive link – example: https://drive.google.com/file/d/your-file-id/view?usp=sharing]

## 🛠️ Built with
- Flutter 3.x / Dart 3.x
- `http` – API calls
- `shared_preferences` – local caching (bonus)
- `google_fonts` – custom typography
- `url_launcher` – YouTube button

---

**This assignment was completed individually and submitted on time.**  
If you have any questions, feel free to contact me.