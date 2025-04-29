from sqlalchemy import Column, Integer, String, TIMESTAMP, text
from sqlalchemy.dialects.postgresql import JSONB
from .database import Base

class FoodEntry(Base):
    __tablename__ = "food_entries"

    id = Column(Integer, primary_key=True, index=True)
    image_url = Column(String(255), nullable=False)
    food_name = Column(String(100))
    calories = Column(Integer)
    protein_grams = Column(Integer)
    carb_grams = Column(Integer)
    fat_grams = Column(Integer)
    quantity = Column(Integer, default=1)
    ingredients = Column(JSONB)
    scan_timestamp = Column(TIMESTAMP(timezone=True), 
                            server_default=text("CURRENT_TIMESTAMP"), 
                            nullable=False) 