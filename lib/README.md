# AAU Gourmet - Premium Recipe Platform

A modular Flutter application built as a high-performance prototype for food discovery. This project demonstrates clean architectural standards by separating concerns into distinct layers.

## 📁 Modular Architecture
The project is organized into a modular structure to ensure maintainability and scalability:
*   **Models**: Defines the data structure and handles JSON serialization for recipe objects.
*   **Services**: Manages asynchronous API communication with MealDB and business logic.
*   **Screens**: Handles the UI layer, state management, and user interactions.

## ✨ Key Features
*   **High-Volume Data**: Fetches 50+ premium dishes across multiple categories.
*   **Real-time Search**: Instant filtering of recipes across the entire database.
*   **Robust Error Handling**: Custom connection-resilience UI with integrated retry logic.
*   **Premium UX/UI**: High-end aesthetic using Playfair Display typography and custom layouts.

## 🛠️ Technical Implementation
*   **Framework**: Flutter (Dart)
*   **Networking**: Http package for REST API consumption.
*   **Typography**: Google Fonts integration.
*   **Utilities**: Url_launcher for video tutorials.