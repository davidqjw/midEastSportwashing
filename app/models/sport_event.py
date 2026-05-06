from pydantic import BaseModel
from typing import List
from datetime import date

class SportEvent(BaseModel):
    id: str
    title: str
    date: str  # Format: YYYY-MM-DD
    category: str  # football, f1, ufc, wrestling, golf, world_cup
    country: str  # UAE, Qatar, Saudi Arabia
    description: str
    impact_analysis: str
    image_url: str
    related_events: List[str]
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": "man-city-takeover-2008",
                "title": "Abu Dhabi Consortium Acquires Manchester City",
                "date": "2008-09-01",
                "category": "football",
                "country": "UAE",
                "description": "Abu Dhabi United Group acquired Manchester City Football Club...",
                "impact_analysis": "Through massive financial investment...",
                "image_url": "https://example.com/man-city-2008.jpg",
                "related_events": ["psg-takeover-2011"]
            }
        }
