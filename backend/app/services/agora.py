import os

from agora_agent import Agora, Area


class AgoraService:
    """Thin wrapper around Agora Conversational AI."""

    def __init__(self) -> None:
        app_id = os.getenv("AGORA_APP_ID")
        app_certificate = os.getenv("AGORA_APP_CERTIFICATE")

        if not app_id:
            raise RuntimeError("AGORA_APP_ID is not configured.")

        if not app_certificate:
            raise RuntimeError("AGORA_APP_CERTIFICATE is not configured.")

        self.client = Agora(
            area=Area.AP,
            app_id=app_id,
            app_certificate=app_certificate,
        )