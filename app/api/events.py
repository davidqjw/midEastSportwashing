from fastapi import APIRouter, HTTPException
from typing import List, Optional
from app.models.sport_event import SportEvent
from app.services.data_store import load_events

router = APIRouter(prefix="/api", tags=["events"])

@router.get("/events", response_model=List[SportEvent])
async def get_events(
    category: Optional[str] = None,
    country: Optional[str] = None,
    start_year: Optional[int] = None,
    end_year: Optional[int] = None
):
    """Get all events with optional filtering"""
    events = load_events()
    
    # Apply filters
    if category:
        events = [e for e in events if e.category == category]
    
    if country:
        events = [e for e in events if e.country == country]
    
    if start_year:
        events = [e for e in events if int(e.date[:4]) >= start_year]
    
    if end_year:
        events = [e for e in events if int(e.date[:4]) <= end_year]
    
    return events

@router.get("/events/{event_id}", response_model=SportEvent)
async def get_event_by_id(event_id: str):
    """Get a specific event by ID"""
    events = load_events()
    
    for event in events:
        if event.id == event_id:
            return event
    
    raise HTTPException(status_code=404, detail=f"Event with id '{event_id}' not found")

@router.get("/categories")
async def get_categories():
    """Get all available categories"""
    events = load_events()
    categories = list(set(event.category for event in events))
    return {"categories": sorted(categories)}

@router.get("/countries")
async def get_countries():
    """Get all available countries"""
    events = load_events()
    countries = list(set(event.country for event in events))
    return {"countries": sorted(countries)}
