from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi_throttling import ThrottlingMiddleware

from .routers import food
from .models.database import engine, Base

# Create database tables
Base.metadata.create_all(bind=engine)

# Create FastAPI app
app = FastAPI(title="Cal Snap API", description="Cal Snap Food Recognition API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins for PoC
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add global rate limiting middleware
app.add_middleware(
    ThrottlingMiddleware,
    limit=100,  # Max requests
    interval=60,  # Per minute
)

# Include routers
app.include_router(food.router, prefix="/api/v1", tags=["food"])

@app.get("/")
async def root():
    return {"message": "Welcome to Cal Snap API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True) 