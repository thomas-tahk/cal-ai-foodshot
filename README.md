# Cal Snap - Food Calorie Tracker

Cal Snap is a proof-of-concept application that allows users to track their calorie and macronutrient intake by analyzing photos of food using AI.

## Features

- Capture photos of food items using your device camera
- Identify food items using Google Cloud Vision API
- Retrieve nutritional information using Edamam Nutrition Analysis API
- Track daily calorie and macronutrient intake
- View detailed nutritional information for each food item

## Tech Stack

### Backend
- Python with FastAPI
- PostgreSQL database
- Google Cloud Vision API for image recognition
- Edamam Nutrition Analysis API for nutrition data
- Cloudinary for image storage
- In-memory rate limiting with fastapi-throttling

### Frontend
- Flutter for cross-platform mobile UI
- HTTP for API communication

## Getting Started

### Prerequisites

- Python 3.10+
- Flutter SDK
- PostgreSQL database
- API keys for:
  - Google Cloud Vision API
  - Edamam Nutrition Analysis API
  - Cloudinary

### Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/cal-snap.git
   cd cal-snap
   ```

2. Set up the backend:
   ```
   cd backend
   pip install -r requirements.txt
   cp env.example .env
   ```

3. Edit the `.env` file with your API keys and database connection.

4. Run the backend server:
   ```
   python run.py
   ```

5. Set up the Flutter frontend:
   ```
   cd ../frontend/cal_snap
   flutter pub get
   ```

6. Update the API URL in `lib/services/api_service.dart` to point to your backend server.

7. Run the Flutter app:
   ```
   flutter run
   ```

## Usage

1. Open the Cal Snap app
2. Tap the camera button to take a photo of a food item
3. The app will identify the food and display its nutritional information
4. View your daily calorie and macronutrient intake on the dashboard
5. Tap on a food entry to see detailed nutritional information

## Limitations

- The app relies on the accuracy of Google Cloud Vision API for food identification
- Nutritional data accuracy depends on the Edamam database
- Rate limiting is implemented using in-memory storage (not suitable for production)
- The app does not support user accounts or offline functionality

## License

This project is licensed under the MIT License. 