from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.events import router as events_router

app = FastAPI(title="Arab Sportswashing Timeline API")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(events_router)

@app.get("/")
async def root():
    return {"message": "Arab Sportswashing Timeline API", "docs": "/docs"}
