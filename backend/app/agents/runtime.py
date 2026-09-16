import os

from agora_agent import Agent, Gemini
from agora_agent.agentkit.vendors import GeminiSTT, SarvamTTS

from app.agents.runtime_prompt import build_character_system_prompt
from app.models.character import KinCharacter
from app.services.agora import AgoraService


class RuntimeAgent:
    """Runs a KIN character through Agora Conversational AI."""

    def __init__(self) -> None:
        self.agora = AgoraService()

        gemini_api_key = os.getenv("GEMINI_API_KEY")
        sarvam_api_key = os.getenv("SARVAM_API_KEY")

        if not gemini_api_key:
            raise RuntimeError("GEMINI_API_KEY is not configured.")

        if not sarvam_api_key:
            raise RuntimeError("SARVAM_API_KEY is not configured.")

        self.gemini_api_key = gemini_api_key
        self.sarvam_api_key = sarvam_api_key

    def start(
        self,
        character: KinCharacter,
        channel: str,
        remote_uid: str = "1001",
    ) -> str:
        system_prompt = build_character_system_prompt(character)

        llm = Gemini(
            api_key=self.gemini_api_key,
            model="gemini-2.5-flash",
            system_messages=[
                {
                    "role": "system",
                    "content": system_prompt,
                }
            ],
        )

        tts = SarvamTTS(
            key=self.sarvam_api_key,
            speaker='shubh',
            target_language_code='en-IN',
        )

        stt = GeminiSTT(
            api_key=self.gemini_api_key,
            language_codes=["en-IN", "hi-IN"],
        )

        agent = (
            Agent(self.agora.client, greeting="Yoo, wassup dawg!",)
            .with_stt(stt)
            .with_llm(llm)
            .with_tts(tts)
        )

        print("KIN AGENT CONFIG")
        print(agent.config)
        print("KIN AGENT PROPERTIES")
        print(agent.to_properties())

        session = agent.create_session(
            channel=channel,
            agent_uid="0",
            remote_uids=[remote_uid],
            name=f"kin-{character.id}-{channel}",
            idle_timeout=120,
            debug=True,
        )

        return session.start()