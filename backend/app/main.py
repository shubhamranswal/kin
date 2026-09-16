import base64
import os

import httpx
from fastapi import HTTPException
from fastapi.responses import Response

import uuid

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

        session_id = uuid.uuid4().hex[:12]

        channel = f"kin-raj-{session_id}"
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


@app.post("/debug/tts")
async def debug_tts():
    api_key = os.getenv("SARVAM_API_KEY")

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="SARVAM_API_KEY is not configured",
        )

    payload = {
        "text": "Arre bhai, finally aa gaya? Kya scene hai?",
        "language_code": "en-IN",
        "speaker": "shubh",
        "model": "bulbul:v3",
        "speech_sample_rate": 24000,
        "output_audio_codec": "wav",
    }

    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(
            "https://api.sarvam.ai/text-to-speech",
            headers={
                "api-subscription-key": api_key,
                "Content-Type": "application/json",
            },
            json=payload,
        )

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail=response.text,
        )

    result = response.json()

    audios = result.get("audios")

    if not audios:
        raise HTTPException(
            status_code=500,
            detail="Sarvam returned no audio",
        )

    audio_bytes = base64.b64decode(audios[0])

    return Response(
        content=audio_bytes,
        media_type="audio/wav",
        headers={
            "X-Sarvam-Request-ID": result.get(
                "request_id",
                ""
            ),
        },
    )


@app.get("/debug/config")
async def debug_config():
    return {
        "gemini_configured": bool(os.getenv("GEMINI_API_KEY")),
        "sarvam_configured": bool(os.getenv("SARVAM_API_KEY")),
        "agora_configured": bool(
            os.getenv("AGORA_APP_ID")
            and os.getenv("AGORA_APP_CERTIFICATE")
        ),
    }