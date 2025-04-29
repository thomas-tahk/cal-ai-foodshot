from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime

class FoodEntryBase(BaseModel):
    food_name: Optional[str] = None
    calories: Optional[int] = None
    protein_grams: Optional[int] = None
    carb_grams: Optional[int] = None
    fat_grams: Optional[int] = None
    quantity: int = 1
    ingredients: Optional[Dict[str, Any]] = None

class FoodEntryCreate(FoodEntryBase):
    image_url: str

class FoodEntry(FoodEntryBase):
    id: int
    image_url: str
    scan_timestamp: datetime

    class Config:
        orm_mode = True

class FoodEntryList(BaseModel):
    food_entries: List[FoodEntry]

class DashboardStats(BaseModel):
    total_calories: int
    remaining_calories: int
    protein_grams: int
    carb_grams: int
    fat_grams: int 