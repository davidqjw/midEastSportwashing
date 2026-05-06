import json
from typing import List
from pathlib import Path
from app.models.sport_event import SportEvent

DATA_FILE = Path("app/data/event.json")

def load_events() -> List[SportEvent]:
    """Load events from JSON file"""
    if not DATA_FILE.exists():
        return []
    
    with open(DATA_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
        return [SportEvent(**event) for event in data.get('events', [])]

def save_events(events: List[SportEvent]) -> None:
    """Save events to JSON file"""
    DATA_FILE.parent.mkdir(parents=True, exist_ok=True)
    
    data = {"events": [event.model_dump() for event in events]}
    
    with open(DATA_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
