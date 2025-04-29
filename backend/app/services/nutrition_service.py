import requests
import os
from typing import Dict, Any, Optional, Tuple
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get Edamam API credentials from environment
EDAMAM_APP_ID = os.getenv("EDAMAM_APP_ID")
EDAMAM_APP_KEY = os.getenv("EDAMAM_APP_KEY")
EDAMAM_API_URL = "https://api.edamam.com/api/nutrition-data"

async def get_nutrition_data(food_label: str) -> Tuple[Optional[int], Optional[int], Optional[int], Optional[int], Optional[Dict[str, Any]]]:
    """
    Get nutrition data for a food item using the Edamam API
    Returns (calories, protein_grams, carb_grams, fat_grams, ingredients)
    """
    try:
        # Prepare query string (e.g., "1 apple")
        ingr = f"1 {food_label}"
        
        # Make request to Edamam API
        params = {
            "app_id": EDAMAM_APP_ID,
            "app_key": EDAMAM_APP_KEY,
            "ingr": ingr
        }
        
        response = requests.get(EDAMAM_API_URL, params=params)
        response.raise_for_status()
        
        data = response.json()
        
        # Check if we got valid nutrition data
        if not data.get("calories") and data.get("totalWeight", 0) == 0:
            print(f"No nutrition data found for: {food_label}")
            return None, None, None, None, None
        
        # Extract nutrition data
        calories = data.get("calories")
        protein = data.get("totalNutrients", {}).get("PROCNT", {}).get("quantity", 0)
        carbs = data.get("totalNutrients", {}).get("CHOCDF", {}).get("quantity", 0)
        fat = data.get("totalNutrients", {}).get("FAT", {}).get("quantity", 0)
        
        # Round to integers
        protein_grams = round(protein) if protein is not None else None
        carb_grams = round(carbs) if carbs is not None else None
        fat_grams = round(fat) if fat is not None else None
        
        # Extract ingredients information
        ingredients = data.get("ingredients", [])
        ingredients_data = {
            ingredient.get("text"): ingredient.get("parsed", [{}])[0].get("nutrients", {}).get("ENERC_KCAL", {}).get("quantity")
            for ingredient in ingredients
        } if ingredients else None
        
        return calories, protein_grams, carb_grams, fat_grams, ingredients_data
        
    except Exception as e:
        print(f"Error with Edamam API: {e}")
        return None, None, None, None, None 