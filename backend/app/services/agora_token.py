import os
import time

from agora_token_builder import RtcTokenBuilder


class AgoraTokenService:
    """Generates short-lived RTC tokens for KIN clients."""

    def __init__(self) -> None:
        self.app_id = os.getenv("AGORA_APP_ID")
        self.app_certificate = os.getenv("AGORA_APP_CERTIFICATE")

        if not self.app_id:
            raise RuntimeError("AGORA_APP_ID is not configured.")

        if not self.app_certificate:
            raise RuntimeError("AGORA_APP_CERTIFICATE is not configured.")

    def generate_rtc_token(
        self,
        channel: str,
        uid: int,
        expires_in: int = 3600,
    ) -> str:
        expire_timestamp = int(time.time()) + expires_in

        return RtcTokenBuilder.buildTokenWithUid(
            self.app_id,
            self.app_certificate,
            channel,
            uid,
            1,
            expire_timestamp,
        )