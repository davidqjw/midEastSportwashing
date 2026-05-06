@echo off
title Arab Sportswashing Timeline

echo Starting backend (FastAPI)...
start "Backend" cmd /k "cd /d %~dp0 && venv\Scripts\activate && uvicorn main:app --reload --port 8000"

echo Starting frontend (Flutter Web)...
start "Frontend" cmd /k "cd /d %~dp0\frontend && flutter run -d chrome"

echo Both services launched.
pause
