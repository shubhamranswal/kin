from pydantic import BaseModel, Field


class Personality(BaseModel):
    traits: list[str] = Field(default_factory=list)
    humor: float = Field(default=0.5, ge=0.0, le=1.0)
    confidence: float = Field(default=0.5, ge=0.0, le=1.0)
    empathy: float = Field(default=0.5, ge=0.0, le=1.0)
    patience: float = Field(default=0.5, ge=0.0, le=1.0)
    emotional_volatility: float = Field(default=0.5, ge=0.0, le=1.0)


class Story(BaseModel):
    backstory: str = ""
    relationships: list[str] = Field(default_factory=list)
    experiences: list[str] = Field(default_factory=list)
    goals: list[str] = Field(default_factory=list)


class Behavior(BaseModel):
    rules: list[str] = Field(default_factory=list)
    likes: list[str] = Field(default_factory=list)
    dislikes: list[str] = Field(default_factory=list)
    triggers: list[str] = Field(default_factory=list)
    boundaries: list[str] = Field(default_factory=list)


class VoiceProfile(BaseModel):
    description: str = ""
    accent: str = ""
    tone: str = ""
    speaking_style: str = ""
    energy: float = Field(default=0.5, ge=0.0, le=1.0)
    speed: float = Field(default=1.0, ge=0.5, le=2.0)


class CharacterState(BaseModel):
    current_emotion: str = "neutral"
    emotional_intensity: float = Field(default=0.0, ge=0.0, le=1.0)
    relationship_score: float = Field(default=0.5, ge=0.0, le=1.0)
    memories: list[str] = Field(default_factory=list)


class KinCharacter(BaseModel):
    id: str
    name: str
    age: int | None = None
    role: str
    appearance: str

    personality: Personality
    story: Story
    behavior: Behavior
    secrets: list[str] = Field(default_factory=list)
    voice: VoiceProfile
    languages: list[str] = Field(default_factory=list)
    state: CharacterState = Field(default_factory=CharacterState)


class CharacterExtractionRequest(BaseModel):
    description: str = Field(min_length=1)