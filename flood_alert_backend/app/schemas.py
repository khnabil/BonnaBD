from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

# --- CAMPAIGN SCHEMAS ---
class CampaignBase(BaseModel):
    title: str
    description: str
    target_amount: float

class CampaignCreate(CampaignBase):
    pass 

class CampaignResponse(CampaignBase):
    id: int
    raised_amount: float
    ngo_id: int
    
    class Config:
        orm_mode = True

# --- FLOOD REPORT SCHEMAS ---
class ReportCreate(BaseModel):
    description: str
    location: str
    latitude: float
    longitude: float
    severity: str # "Critical", "Moderate"

class ReportResponse(ReportCreate):
    id: int
    user_id: int
    timestamp: datetime

    class Config:
        orm_mode = True