from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.orm import Session
from typing import List, Optional
import os
import shutil
import tempfile
from datetime import datetime, date
from fastapi_throttling import ThrottlingMiddleware, RateLimiter

from ..models.database import get_db
from ..models.food_entry import FoodEntry
from ..schemas.food_entry import FoodEntry as FoodEntrySchema
from ..schemas.food_entry import FoodEntryList, DashboardStats
from ..services.cloudinary_service import upload_image
from ..services.vision_service import detect_labels
from ..services.nutrition_service import get_nutrition_data

# Create router
router = APIRouter()

# Rate limiter for scan endpoint
scan_rate_limiter = RateLimiter(times=5, seconds=60)

@router.post("/scan", response_model=FoodEntrySchema, status_code=status.HTTP_201_CREATED,
            dependencies=[Depends(scan_rate_limiter)])
async def scan_food(file: UploadFile = File(...), db: Session = Depends(get_db)):
    """
    Scan a food item image and create a new food entry
    """
    # Save the uploaded file temporarily
    temp_file = tempfile.NamedTemporaryFile(delete=False)
    try:
        # Write file contents
        shutil.copyfileobj(file.file, temp_file)
        temp_file.close()
        
        # Upload to Cloudinary
        image_url = await upload_image(temp_file.name)
        
        # Detect labels with Google Vision API
        food_label = await detect_labels(image_url)
        
        if not food_label:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Could not identify food item from image."
            )
        
        # Get nutrition data with Edamam API
        calories, protein_grams, carb_grams, fat_grams, ingredients = await get_nutrition_data(food_label)
        
        # Create food entry in database
        db_food_entry = FoodEntry(
            image_url=image_url,
            food_name=food_label,
            calories=calories if calories is not None else 0,
            protein_grams=protein_grams if protein_grams is not None else 0,
            carb_grams=carb_grams if carb_grams is not None else 0,
            fat_grams=fat_grams if fat_grams is not None else 0,
            quantity=1,
            ingredients=ingredients
        )
        
        db.add(db_food_entry)
        db.commit()
        db.refresh(db_food_entry)
        
        return db_food_entry
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        # Handle other exceptions
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An error occurred: {str(e)}"
        )
    finally:
        # Clean up the temp file
        if os.path.exists(temp_file.name):
            os.unlink(temp_file.name)

@router.get("/foods", response_model=FoodEntryList)
async def get_foods(limit: int = 10, db: Session = Depends(get_db)):
    """
    Get a list of recent food entries
    """
    foods = db.query(FoodEntry).order_by(FoodEntry.scan_timestamp.desc()).limit(limit).all()
    return {"food_entries": foods}

@router.get("/foods/{food_id}", response_model=FoodEntrySchema)
async def get_food(food_id: int, db: Session = Depends(get_db)):
    """
    Get a specific food entry by ID
    """
    food = db.query(FoodEntry).filter(FoodEntry.id == food_id).first()
    if not food:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Food entry with ID {food_id} not found"
        )
    return food

@router.get("/dashboard", response_model=DashboardStats)
async def get_dashboard_stats(db: Session = Depends(get_db)):
    """
    Get dashboard statistics
    """
    # Get default daily calories from environment
    DEFAULT_DAILY_CALORIES = int(os.getenv("DEFAULT_DAILY_CALORIES", 2500))
    
    # Get all food entries for today
    today = date.today()
    foods = db.query(FoodEntry).filter(
        FoodEntry.scan_timestamp >= datetime.combine(today, datetime.min.time())
    ).all()
    
    # Calculate totals
    total_calories = sum(food.calories or 0 for food in foods)
    total_protein = sum(food.protein_grams or 0 for food in foods)
    total_carbs = sum(food.carb_grams or 0 for food in foods)
    total_fat = sum(food.fat_grams or 0 for food in foods)
    
    # Calculate remaining calories
    remaining_calories = max(0, DEFAULT_DAILY_CALORIES - total_calories)
    
    return {
        "total_calories": total_calories,
        "remaining_calories": remaining_calories,
        "protein_grams": total_protein,
        "carb_grams": total_carbs,
        "fat_grams": total_fat
    } 