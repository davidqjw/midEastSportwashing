from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
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

# Static event images
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Include routers
app.include_router(events_router)

app.mount("/", StaticFiles(directory="frontend/build/web", html=True), name="frontend")
