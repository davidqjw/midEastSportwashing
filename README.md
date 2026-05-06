# Arab Sportswashing Timeline

An interactive timeline website showcasing sportswashing events in the Arab world over the past 15 years.

## Project Introduction

Arab Sportswashing Timeline is a full-stack course project that presents major sports-related investments and events connected to Gulf and Arab states. The app combines a FastAPI backend with a Flutter Web frontend to let users browse events by year, open detailed event cards, and view supporting images for each case.

The project focuses on how high-profile sports acquisitions, tournaments, and entertainment partnerships can be used as soft-power tools. Each event includes a date, country, category, description, impact analysis, related events, and a local image served by the backend.

## Tech Stack

- **Backend**: FastAPI (Python)
- **Frontend**: Flutter Web
- **Data Storage**: JSON file
- **Static Assets**: Local images served by FastAPI

## Project Structure

```text
app/                    # Backend application
  api/                  # API endpoints
  models/               # Data models
  services/             # Business logic
  data/                 # JSON data storage
  static/image/         # Local event images
frontend/               # Flutter frontend
  lib/
    models/             # Dart data models
    services/           # API client
    providers/          # State management
    widgets/            # UI components
    screens/            # App screens
main.py                 # Backend entry point
app/data/event.json     # Event data source
```

## Setup and Run

### Prerequisites

- Python 3.10+
- Flutter SDK
- Git

### Install dependencies (first time only)

```bash
python -m venv venv
./venv/Scripts/activate  # Windows
source venv/bin/activate # macOS/Linux
pip install -r requirements.txt
cd frontend && flutter pub get
```

### Development mode

Double-click `start_dev.bat`, or run manually:

```bash
# Terminal 1 - Backend
./venv/Scripts/activate
uvicorn main:app --reload --port 8000

# Terminal 2 - Frontend (with hot reload)
cd frontend
flutter run -d chrome
```

### Production mode (pre-built)

Double-click `start.bat`, or run manually:

```bash
./venv/Scripts/activate
uvicorn main:app --port 8000
```

Then visit http://localhost:8000

If you changed frontend code, rebuild before starting:

```bash
cd frontend
flutter build web
```

### API documentation

- http://localhost:8000/docs

## API Endpoints

- `GET /api/events` - Get all events, with optional filtering by `category`, `country`, `start_year`, and `end_year`
- `GET /api/events/{event_id}` - Get a specific event
- `GET /api/categories` - Get all categories
- `GET /api/countries` - Get all countries
- `GET /static/image/...` - Serve local event images

## Features

- Interactive timeline with year nodes
- Event filtering by category, country, and year range
- Detailed event information with images
- Local static image support through the backend
- Responsive design for desktop and mobile
- Error handling and retry mechanism
