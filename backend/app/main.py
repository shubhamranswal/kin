import os

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException

from app.models.character import (
    CharacterExtractionRequest,
    KinCharacter,
)
from app.agents.creator import CreatorAgent
from app.agents.runtime import RuntimeAgent
from app.models.demo_character import raj
from app.services.agora_token import AgoraTokenService

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


@app.post("/runtime/test")
async def test_runtime():
    try:
        runtime = RuntimeAgent()

        agent_id = runtime.start(
            character=raj,
            channel="kin-raj-test",
            remote_uid="1001",
        )

        return {
            "status": "started",
            "agent_id": agent_id,
            "character_id": raj.id,
            "character_name": raj.name,
            "channel": "kin-raj-test",
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Runtime agent failed: {exc}",
        ) from exc


@app.post("/runtime/session")
async def create_runtime_session():
    try:
        runtime = RuntimeAgent()

        channel = "kin-raj-test"
        remote_uid = "1001"

        agent_id = runtime.start(
            character=raj,
            channel=channel,
            remote_uid=remote_uid,
        )

        token_service = AgoraTokenService()

        rtc_token = token_service.generate_rtc_token(
            channel=channel,
            uid=int(remote_uid),
        )

        return {
            "status": "started",
            "agent_id": agent_id,
            "character_id": raj.id,
            "character_name": raj.name,
            "channel": channel,
            "uid": int(remote_uid),
            "rtc_token": rtc_token,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Runtime session failed: {exc}",
        ) from exc