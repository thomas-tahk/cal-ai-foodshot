# Product Requirements Document: Cal Snap (Proof of Concept)

**Version:** 0.5
**Date:** 2025-04-29

## 1. Introduction

This document outlines the requirements for the Cal Snap Proof of Concept (PoC). Cal Snap is envisioned as a mobile/web application designed to help users track their calorie and macronutrient intake by analyzing photos of food items using AI. The primary goal of this PoC is to validate the core feature: image recognition (label identification), nutritional data lookup, storage, and display using a defined tech stack, including basic error handling and simple API rate limiting. This PoC needs to be developed within a limited timeframe (<12 hours).

## 2. Goals

* Develop a functional PoC demonstrating the core feature: scan food -> identify label -> look up nutrition -> store data -> display data.
* Validate the use of **Google Cloud Vision API** for food label identification.
* Validate the use of **Edamam Nutrition Analysis API** for retrieving nutritional data based on identified labels.
* Establish a basic full-stack application structure using **Python (FastAPI)** for the backend and **Flutter** for the frontend.
* Utilize **PostgreSQL** for data storage and **Cloudinary** for image storage.
* Implement simple fallback logic for API failures.
* Implement simple **in-memory rate limiting** on critical backend endpoints.
* Provide a foundation for potential future development.

## 3. Features

### 3.1. Main Dashboard (Flutter Frontend)

* **App Name Display:** "Cal Snap" at the top.
* **Daily Calorie Tracker:**
    * Display remaining calories (starts at 2500).
    * Visual progress indicator (e.g., circle/bar).
    * Updates dynamically based on entries fetched from the backend.
* **Daily Macronutrient Tracker:**
    * Display remaining Protein, Carbs, Fats in grams (starts at 0g).
    * Visual progress indicators.
    * Updates dynamically based on entries fetched from the backend.
* **"Recently Eaten" Section:**
    * Display a list/grid of recent entries fetched from the backend (`GET /foods` endpoint).
    * Each entry shows: Thumbnail (URL from backend), Food Name (label), Calories, Macros (P/C/F), Timestamp. If nutritional data is unavailable due to fallback, display "0" or "N/A" for those values.
    * Card-like components.

### 3.2. Food Scanning ("Scan Food") (Flutter Frontend + Backend Interaction)

* **Access:** Floating action button (or similar) triggers the camera.
* **Functionality:**
    * Activate device camera via Flutter plugin.
    * Capture photo.
    * **PoC Scope:** Only direct photo capture. No barcode, label scan, gallery import.
* **Data Flow & Fallbacks:**
    1.  Flutter app sends captured image data to the backend (`POST /scan` endpoint). *This endpoint will be rate-limited.*
    2.  Backend uploads image to **Cloudinary**, gets back `image_url`.
    3.  Backend sends `image_url` to **Google Cloud Vision API** (using Label Detection).
    4.  Backend receives analysis results -> Extracts the most likely food label.
        * **Fallback 1:** If no usable label is identified (or confidence is too low), the backend returns an error (e.g., 400/422) with a message like "Could not identify food item from image." The Flutter app displays this error, and no entry is saved.
    5.  If a usable label is found, backend calls **Edamam Nutrition Analysis API** with the extracted food label (e.g., query text: "1 apple").
    6.  Backend receives nutritional data from Edamam.
        * **Fallback 2:** If Edamam API fails or returns no nutritional data for the label, the backend proceeds to the next step but uses default values (`0` or `NULL`) for `calories`, `protein_grams`, `carb_grams`, `fat_grams`, and `ingredients`.
    7.  Backend stores `image_url`, `food_name` (label), and nutritional data (either from Edamam or default fallback values) in **PostgreSQL**.
    8.  Backend returns the newly created food entry data (JSON, potentially with 0/null nutrition info if Fallback 2 occurred) to the Flutter app with a `201 Created` status.
    9.  Flutter app updates the UI (Main Dashboard), displaying the entry appropriately (showing "0" or "N/A" if nutritional data is missing).

### 3.3. Detailed Food View (Flutter Frontend)

* **Access:** Tapping an entry in "Recently Eaten".
* **Data:** Fetches detailed data for the selected item from the backend (`GET /foods/{food_id}` endpoint).
* **Layout:**
    * Larger image (URL from backend).
    * Food Name (label from backend).
    * Quantity (displays default '1' from backend).
    * Total Calories (from backend/Edamam, or "0"/"N/A" if fallback occurred).
    * Macronutrient breakdown (P/C/F grams, from backend/Edamam, or "0"/"N/A").
    * (Optional/Stretch) List of Ingredients with calories (if Edamam API provides it for the query).

## 4. Non-Goals (Out of Scope for PoC)

* User accounts/authentication.
* Manual food entry/editing/deleting.
* Barcode/Label scanning, Gallery import.
* Exercise/Water tracking.
* Health Score.
* Complex state management (beyond basic PoC needs).
* Sophisticated error handling/retry logic beyond the simple fallbacks defined.
* Distributed/persistent rate limiting (PoC uses simple in-memory limiting).
* Offline functionality.
* Extensive UI polishing.
* Web version (focus on Android via Flutter).
* Handling ambiguous labels from Vision API (PoC will use the most specific/highest confidence label).
* Perfect nutritional accuracy (relies on Vision API label accuracy and Edamam's database/parsing).

## 5. Technical Specifications

* **Backend:** Python 3.10+ with **FastAPI**.
    * **Rate Limiting:** **`fastapi-throttle`** library for in-memory rate limiting.
* **Frontend:** **Flutter** (latest stable).
* **AI Label Recognition:** **Google Cloud Vision API** (Label Detection required). Requires Google Cloud account and API key setup. Free Tier: 1,000 units/month for Label Detection.
* **Nutritional Data API:** **Edamam Nutrition Analysis API**. Requires account setup and API key/credentials. Free Tier: e.g., 10,000 analysis lines/month or 400 calls/month depending on plan.
* **Database:** **PostgreSQL** (version 14+ recommended).
* **Image Storage:** **Cloudinary**. Requires account setup and API credentials. Free Tier: 25 Credits/month.
* **Version Control:** Git, hosted on GitHub (`cal-tracker-poc` repo).

## 6. Backend Implementation Details (FastAPI)

### 6.1. Database Schema (PostgreSQL)

```sql
CREATE TABLE food_entries (
    id SERIAL PRIMARY KEY,
    -- user_id INTEGER, -- Placeholder for future user accounts
    image_url VARCHAR(255) NOT NULL, -- URL from Cloudinary
    food_name VARCHAR(100),         -- Label from Vision API (can be NULL if Vision fails, though likely error returned before save)
    calories INTEGER,               -- From Edamam API (or 0/NULL on fallback)
    protein_grams INTEGER,          -- From Edamam API (or 0/NULL on fallback)
    carb_grams INTEGER,             -- From Edamam API (or 0/NULL on fallback)
    fat_grams INTEGER,              -- From Edamam API (or 0/NULL on fallback)
    quantity INTEGER DEFAULT 1,     -- Default to 1 for PoC
    ingredients JSONB,              -- Optional: From Edamam API (or NULL on fallback)
    scan_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Optional: Index for fetching recent items
-- CREATE INDEX idx_scan_timestamp ON food_entries (scan_timestamp DESC);
6.2. API Endpoints
Base URL: http://<your-backend-ip-or-domain>/api/v1

POST /scan

Rate Limit: Apply using fastapi-throttle. Example: @app.post("/scan", dependencies=[Depends(RateLimiter(times=5, seconds=60))]) (Allow 5 requests per minute per client IP).
Request: multipart/form-data containing the image file.
Processing:
Receive image file.
Upload image to Cloudinary -> Get image_url.
Call Google Cloud Vision API (Label Detection) with image_url -> Get label(s).
Error Check 1: If no usable label found, raise HTTPException(status_code=422, detail="Could not identify food item from image.").
Select primary food label.
Call Edamam Nutrition Analysis API with the label.
Error Check 2: If Edamam fails or returns no data, set nutritional fields to default 0 or None. Otherwise, extract data from Edamam response.
Save new entry to food_entries table.
Return created food_entry object.
Response: 201 Created with JSON body of the created food_entry. Or 422 Unprocessable Entity if Vision API fails. Or 429 Too Many Requests if rate limit is exceeded.
GET /foods

Request: No body. Optional query params like ?limit=10.
Processing: Fetch recent food entries from PostgreSQL.
Response: 200 OK with JSON array of food_entry objects.
GET /foods/{food_id}

Request: food_id as path parameter.
Processing: Fetch the specific food entry with the given id from PostgreSQL.
Response: 200 OK with JSON body of the full food_entry object, or 404 Not Found.
7. Design & Error Handling Considerations
Refer to provided reference images for layout inspiration.
Keep UI simple and functional for the PoC.
Frontend Error Handling:
If POST /scan returns an error (e.g., 4xx status code), display a user-friendly message (e.g., "Failed to analyze image, please try again.", or "Too many requests, please wait a moment.").
If POST /scan succeeds but returns data with 0/null nutritional info (due to Fallback 2), display the entry in "Recently Eaten" with the image/name but indicate data unavailability (e.g., show "0 kcal" or "N/A").
Backend Error Handling: Implement basic try...except blocks around API calls (Cloudinary, Vision, Edamam) to catch network errors or unexpected API responses. Log errors for debugging. The rate limiter handles 429 Too Many Requests automatically.
8. Potential Limitations (Acknowledged)
Accuracy depends on Vision API correctly identifying a label that Edamam API can understand and has data for. The implemented fallback handles cases where Edamam lookup fails.
Free tier limits of Cloudinary, Google Vision API, and Edamam API need to be monitored. The added backend rate limit provides a basic safeguard but does not guarantee staying within external API limits if multiple users make requests concurrently.
In-memory rate limiting (via fastapi-throttle) will reset if the backend server restarts. This is acceptable for a PoC but not suitable for production.