import cloudinary
import cloudinary.uploader
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure Cloudinary
cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET")
)

async def upload_image(file_path: str) -> str:
    """
    Upload an image to Cloudinary and return the URL
    """
    try:
        # Upload the image
        result = cloudinary.uploader.upload(file_path)
        
        # Return the URL
        return result.get("secure_url")
    except Exception as e:
        print(f"Error uploading to Cloudinary: {e}")
        raise 