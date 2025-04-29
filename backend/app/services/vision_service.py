from google.cloud import vision
import os
from typing import Optional, List, Tuple
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Set Google Application Credentials
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "")

async def detect_labels(image_url: str) -> Optional[str]:
    """
    Detect labels in an image using Google Cloud Vision API
    Returns the most likely food label
    """
    try:
        # Create a client
        client = vision.ImageAnnotatorClient()

        # Create image object
        image = vision.Image()
        image.source.image_uri = image_url

        # Perform label detection
        response = client.label_detection(image=image)
        labels = response.label_annotations

        if response.error.message:
            print(f"Error from Vision API: {response.error.message}")
            return None

        # Filter for food-related labels with high confidence
        food_labels = [
            (label.description, label.score) 
            for label in labels 
            if label.score > 0.7
        ]
        
        # Sort by confidence score
        food_labels.sort(key=lambda x: x[1], reverse=True)
        
        # Return the highest confidence food label, or None if no suitable labels found
        return food_labels[0][0] if food_labels else None
        
    except Exception as e:
        print(f"Error with Vision API: {e}")
        return None 