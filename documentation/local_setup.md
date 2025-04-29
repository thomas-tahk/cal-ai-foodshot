# Cal Snap Local Development Setup Guide

This guide provides detailed instructions for setting up and running the Cal Snap application locally for development.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- [Python 3.10+](https://www.python.org/downloads/)
- [PostgreSQL](https://www.postgresql.org/download/)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Docker](https://www.docker.com/get-started) (optional, for containerized development)
- [Git](https://git-scm.com/downloads)

## External Service Accounts

You'll need to create accounts and obtain API keys for:

1. [Google Cloud Platform](https://cloud.google.com/) - Vision API
   - Create a project
   - Enable the Vision API
   - Create a service account and download the JSON key

2. [Cloudinary](https://cloudinary.com/) - Image storage
   - Create an account
   - Note your cloud name, API key, and API secret

3. [Edamam](https://developer.edamam.com/) - Nutrition data
   - Sign up for the Nutrition Analysis API
   - Note your Application ID and Application Key

## Backend Setup

### Option 1: Local Python Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/thomas-tahk/cal-ai-foodshot.git
   cd cal-ai-foodshot
   ```

2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   # On Windows
   venv\Scripts\activate
   # On macOS/Linux
   source venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

4. Create a .env file:
   ```bash
   cp env.example .env
   ```

5. Edit the .env file with your API keys and database connection:
   ```
   # Database
   DATABASE_URL=postgresql://postgres:password@localhost:5432/calsnap

   # Cloudinary
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret

   # Google Cloud Vision API
   GOOGLE_APPLICATION_CREDENTIALS=path_to_your_google_credentials.json

   # Edamam API
   EDAMAM_APP_ID=your_edamam_app_id
   EDAMAM_APP_KEY=your_edamam_app_key

   # Defaults
   DEFAULT_DAILY_CALORIES=2500
   ```

6. Create PostgreSQL database:
   ```bash
   psql -U postgres
   CREATE DATABASE calsnap;
   \q
   ```

7. Run the backend server:
   ```bash
   python run.py
   ```

8. The API will be available at http://localhost:8000

### Option 2: Docker Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/thomas-tahk/cal-ai-foodshot.git
   cd cal-ai-foodshot
   ```

2. Create a .env file:
   ```bash
   cp backend/env.example backend/.env
   ```

3. Edit the .env file with your API keys (database URL is already configured for Docker).

4. Place your Google Cloud credentials JSON file in the project root as `google_credentials.json`.

5. Start the Docker containers:
   ```bash
   docker-compose up -d
   ```

6. The API will be available at http://localhost:8000

## Frontend Setup

1. Install Flutter dependencies:
   ```bash
   cd frontend/cal_snap
   flutter pub get
   ```

2. Update the API URL:
   Open `lib/services/api_service.dart` and ensure the `baseUrl` is set correctly:
   ```dart
   // For local development
   static const String baseUrl = 'http://localhost:8000/api/v1';
   ```

3. Run Flutter app:
   ```bash
   flutter run
   ```

## Testing the Application

### Testing the Backend API

1. Access the API documentation at http://localhost:8000/docs
2. Test endpoints using the Swagger UI

### Testing the Flutter App

1. Ensure the backend is running
2. Connect a device or emulator
3. Run `flutter run` from the frontend/cal_snap directory

## Development Workflow

### Backend Development

1. Make changes to the FastAPI code
2. The server will auto-reload thanks to uvicorn's reload flag
3. Test changes via the API documentation

### Frontend Development

1. Make changes to the Flutter code
2. Use Flutter's hot reload functionality (`r` in the terminal or save in your IDE)
3. Test changes in the running app

## Debugging

### Backend Debugging

- Check logs from the FastAPI server
- Use the FastAPI documentation to test endpoints
- Ensure the database is properly connected
- Verify API keys and credentials are correctly set

### Frontend Debugging

- Use Flutter DevTools for debugging (`flutter run --devtools`)
- Check for errors in the console
- Test API calls independently before integrating

## Common Issues

1. **Database Connection Issues**:
   - Ensure PostgreSQL is running
   - Check username, password, host, and database name in the connection string
   - Verify that the database exists

2. **API Key Problems**:
   - Double-check all API keys in the .env file
   - Ensure Google Cloud credentials path is correct
   - Verify API services are enabled and have proper permissions

3. **Flutter Build Issues**:
   - Run `flutter doctor` to check for any setup issues
   - Ensure all dependencies are properly installed
   - Try cleaning the project with `flutter clean`

4. **Network Connection Issues**:
   - Check if the backend server is running
   - Verify the API URL in the Flutter app is correct
   - For mobile devices, ensure they can access the backend server

## Advanced Configuration

### Customizing Rate Limiting

Edit the ThrottlingMiddleware configuration in `backend/app/main.py`:
```python
app.add_middleware(
    ThrottlingMiddleware,
    limit=100,  # Adjust this value
    interval=60,  # Adjust this value (in seconds)
)
```

### Changing Default Calorie Goals

Edit the DEFAULT_DAILY_CALORIES value in your .env file.

### Adding Support for Additional APIs

If you want to add support for additional food recognition or nutrition APIs:

1. Create a new service file in `backend/app/services/`
2. Implement the required API client
3. Add the necessary environment variables
4. Update the relevant routers to use the new service 