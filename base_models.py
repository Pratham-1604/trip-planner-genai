from pydantic import BaseModel


class UserRequest(BaseModel):
    prompt: str

class ClarrifyingUserReq(BaseModel):
    prompt: str
    clarrifying_answers: str
    
class StoryTelling(BaseModel):
    iternary: dict