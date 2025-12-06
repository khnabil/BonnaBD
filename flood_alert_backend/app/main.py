from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
import requests
from . import models, database

# Create tables automatically
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()

# THE CORRECT URL YOU FOUND
DATA_URL = "https://api3.ffwc.gov.bd/data_load/recent-observed/"
STATION_NAMES_URL = "https://api3.ffwc.gov.bd/data_load/stations/"

@app.get("/")
def home():
    return {"message": "Flood Alert System is Online 🚀"}

@app.post("/sync-water-levels")
def sync_data_from_govt(db: Session = Depends(database.get_db)):
    try:
        # 1. Fetch the Water Data
        print("Fetching Water Levels...")
        response = requests.get(DATA_URL, timeout=15)
        water_data = response.json()
        
        # 2. Fetch Station Names (Optional, but makes it look nicer)
        # We try to get real names. If it fails, we use "Station ID"
        station_map = {}
        try:
            print("Fetching Station Names...")
            meta_response = requests.get(STATION_NAMES_URL, timeout=5)
            meta_data = meta_response.json()
            # Map ID to Name (Assuming structure, usually list of dicts)
            if isinstance(meta_data, list):
                for s in meta_data:
                    # Adjust keys based on actual metadata format if needed
                    s_id = str(s.get("id", ""))
                    s_name = s.get("name", s.get("station", "Unknown"))
                    station_map[s_id] = s_name
        except:
            print("Could not fetch station names, using IDs instead.")

        count = 0
        
        # 3. PARSE THE DICTIONARY (The logic for your specific JSON)
        # Structure: {"1": [{"date": "level"}, ...], "2": ...}
        for station_id, readings_list in water_data.items():
            if not readings_list or not isinstance(readings_list, list):
                continue
            
            # Get the LATEST reading (usually the last item in the list)
            latest_reading = readings_list[-1] 
            
            # The reading is like {"2025-10-25 09": "0.85"}
            # We need to extract the value "0.85" regardless of the date key
            level_str = list(latest_reading.values())[0]
            
            try:
                water_level = float(level_str)
            except:
                water_level = 0.0

            # Determine Name
            name = station_map.get(station_id, f"Station {station_id}")

            # 4. Save to Database
            # Check if exists first to update, or create new
            existing = db.query(models.WaterStation).filter(models.WaterStation.station_name == name).first()
            
            if existing:
                existing.water_level = water_level
                # existing.last_updated = func.now() (Auto updates)
            else:
                new_station = models.WaterStation(
                    station_name=name,
                    river_name=f"River ID {station_id}", # Placeholder until we parse river names
                    water_level=water_level,
                    danger_level=0.0 # Govt API didn't give danger level here
                )
                db.add(new_station)
            
            count += 1
            
        db.commit()
        return {"status": "success", "stations_synced": count}
        
    except Exception as e:
        print(f"ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to sync: {str(e)}")

@app.get("/water-levels")
def get_latest_levels(db: Session = Depends(database.get_db)):
    stations = db.query(models.WaterStation).all()
    return stations


# --- VOLUNTEER TASK FEATURE ---

class TaskCreate(BaseModel):
    title: str
    description: str
    priority: str      
    assigned_to: str    
    latitude: float
    longitude: float

@app.post("/tasks/create")
def create_new_task(task: TaskCreate, db: Session = Depends(database.get_db)):

    new_task = models.VolunteerTask(
        title=task.title,
        description=task.description,
        priority=task.priority,
        assigned_to=task.assigned_to,
        latitude=task.latitude,
        longitude=task.longitude,
        status="Pending" 
    )
    
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return {"status": "Task Created", "task_id": new_task.id}

@app.get("/tasks/{volunteer_id}")
def get_my_tasks(volunteer_id: str, db: Session = Depends(database.get_db)):

    tasks = db.query(models.VolunteerTask).filter(
        models.VolunteerTask.assigned_to == volunteer_id
    ).all()
    
    return tasks

@app.patch("/tasks/{task_id}/update-status")
def update_task_status(task_id: int, new_status: str, db: Session = Depends(database.get_db)):

    task = db.query(models.VolunteerTask).filter(models.VolunteerTask.id == task_id).first()
    
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    task.status = new_status
    db.commit()
    
    return {"status": "updated", "current_state": new_status}