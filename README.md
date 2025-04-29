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
- Docker and Docker Compose (for containerized setup)

### Setup

#### Local Setup

1. Clone the repository:
   ```
   git clone https://github.com/thomas-tahk/cal-ai-foodshot.git
   cd cal-ai-foodshot
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

#### Docker Setup

1. Clone the repository:
   ```
   git clone https://github.com/thomas-tahk/cal-ai-foodshot.git
   cd cal-ai-foodshot
   ```

2. Create a `.env` file in the backend directory:
   ```
   cp backend/env.example backend/.env
   ```

3. Edit the `backend/.env` file with your API keys. The database URL is already configured in the docker-compose file.

4. Place your Google Cloud credentials JSON file in the project root as `google_credentials.json`.

5. Start the Docker containers:
   ```
   docker-compose up -d
   ```

6. The backend API will be available at `http://localhost:8000`

## Deployment to DigitalOcean

### Prerequisites

- DigitalOcean account
- Docker installed on your local machine
- `doctl` CLI tool installed (DigitalOcean command-line tool)

### Steps

1. Create a new Droplet on DigitalOcean using the Docker image, or use the App Platform.

2. For Droplet deployment:
   
   a. Create a new Droplet with Docker installed
   b. Connect to your Droplet via SSH
   c. Clone your repository
   d. Set up your .env file and Google credentials
   e. Run `docker-compose up -d`

3. For App Platform:
   
   a. Create a new App
   b. Connect to your GitHub repository
   c. Configure the app settings
   d. Set environment variables based on your .env file
   e. Deploy the app

4. Configure a domain name in DigitalOcean's Networking section if needed.

5. Set up SSL certificates through DigitalOcean or Let's Encrypt.

## Environment Variables

The application requires these environment variables in the `backend/.env` file:

- `DATABASE_URL`: PostgreSQL connection string
- `CLOUDINARY_CLOUD_NAME`: Your Cloudinary cloud name
- `CLOUDINARY_API_KEY`: Your Cloudinary API key
- `CLOUDINARY_API_SECRET`: Your Cloudinary API secret
- `GOOGLE_APPLICATION_CREDENTIALS`: Path to Google Cloud credentials JSON file
- `EDAMAM_APP_ID`: Edamam API application ID
- `EDAMAM_APP_KEY`: Edamam API key
- `DEFAULT_DAILY_CALORIES`: Default daily calorie goal (e.g., 2500)

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