import os

from google import genai
from google.genai import types

from app.models.character import KinCharacter


class CreatorAgent:
    """Creates a structured KIN character from a natural-language description."""

    def __init__(self) -> None:
        api_key = os.getenv("GEMINI_API_KEY")

        if not api_key:
            raise RuntimeError("GEMINI_API_KEY is not configured.")

        self.client = genai.Client(api_key=api_key)

    async def create_character(self, description: str) -> KinCharacter:
        prompt = f"""
Create a complete KIN character from the user's description below.

KIN characters should feel like believable people, not generic AI assistants.

Infer reasonable details where the user is silent, but never contradict
anything explicitly stated.

Pay particular attention to:
- distinct personality traits
- believable backstory
- relationships and experiences
- behavioral rules
- likes, dislikes and emotional triggers
- secrets that can make conversations interesting
- voice and speaking style
- languages the character can naturally speak

The character should be internally consistent.
Do not invent conversation memories, relationship history with the user,
or current emotional state. Runtime state will be initialized separately.

User's character description:
{description}
"""

        response = await self.client.aio.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=KinCharacter,
            ),
        )

        if not response.parsed:
            raise RuntimeError("Gemini returned no structured character.")

        return KinCharacter.model_validate(response.parsed)