import os

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException

from app.models.character import (
    CharacterExtractionRequest,
    KinCharacter,
)
from app.agents.creator import CreatorAgent

load_dotenv()

app = FastAPI(
    title="KIN API",
    description="Backend for KIN voice-first AI characters.",
    version="0.2.1",
)


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "service": "kin-api",
    }


@app.post("/characters/extract", response_model=KinCharacter)
async def extract_character(
    request: CharacterExtractionRequest,
):
    try:
        agent = CreatorAgent()
        return await agent.create_character(request.description)

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Character creation failed: {exc}",
        ) from exc