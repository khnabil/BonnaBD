from sqlalchemy import Column, Integer, String, Float, DateTime,Boolean, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base
import datetime

class WaterStation(Base):
    __tablename__ = "water_stations"
    id = Column(Integer, primary_key=True, index=True)
    station_name = Column(String, index=True)
    river_name = Column(String)
    water_level = Column(Float)
    danger_level = Column(Float)
    last_updated = Column(DateTime(timezone=True), server_default=func.now())



class VolunteerTask(Base):
    __tablename__ = "volunteer_tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)              
    description = Column(String)       
    priority = Column(String)         
    status = Column(String, default="Pending") 
    assigned_to = Column(String, index=True) 
    
    latitude = Column(Float)
    longitude = Column(Float)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class User(Base):
    __tablename__="user"
    id = Column(Integer,primary_key=True,index=True)
    full_name = Column(String)
    email = Column(String,unique=True,index=True)
    hashed_password = Column(String)
    is_volunteer = Column(Boolean ,default=False)
    role = Column(String, default="user")
    ngo_profile = relationship("NGO", back_populates="owner", uselist=False)
    created_at = Column(DateTime(timezone=True),server_default=func.now())

class NGO(Base):
    __tablename__ = "ngos"
    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("user.id"))
    owner = relationship("User", back_populates="ngo_profile")

    name = Column(String, index=True)
    description = Column(String)
    is_verified = Column(Boolean, default=False) # Admin must approve this later
    contact_phone = Column(String)
    aid_types = Column(String) 
    
    campaigns = relationship("Campaign", back_populates="organizer")



class Campaign(Base):
    __tablename__ = "campaigns"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(String)
    target_amount = Column(Float)
    raised_amount = Column(Float, default=0.0)
    
    # Link to NGO
    ngo_id = Column(Integer, ForeignKey("ngos.id"))
    organizer = relationship("NGO", back_populates="campaigns")


class FloodReport(Base):
    __tablename__ = "flood_reports"

    id = Column(Integer, primary_key=True, index=True)
    description = Column(String)
    location = Column(String) # e.g., "Sylhet Sadar"
    latitude = Column(Float)
    longitude = Column(Float)
    image_url = Column(String, nullable=True) # For photo uploads
    severity = Column(String) # "Low", "Medium", "Critical"
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    
    # Link to the user who reported it
    user_id = Column(Integer, ForeignKey("user.id"))
    reporter = relationship("User")