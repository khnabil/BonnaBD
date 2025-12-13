from sqlalchemy import Column, Integer, String, Float, DateTime,Boolean
from sqlalchemy.sql import func
from .database import Base

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
    created_at = Column(DateTime(timezone=True),server_default=func.now())