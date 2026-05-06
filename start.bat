

@echo off
title Arab Sportswashing Timeline (Production)

echo Starting server...
cd /d %~dp0
call venv\Scripts\activate
start http://localhost:8000
uvicorn main:app --port 8000
