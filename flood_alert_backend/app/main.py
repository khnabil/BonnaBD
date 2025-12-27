from fastapi import FastAPI, Depends, HTTPException,status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel,EmailStr
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import requests
from . import models, database,schemas
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from .auth import get_current_user

SECRET_KEY = "supersecretkey"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()
origins = [
    "http://localhost",
    "http://localhost:3000",
    "*"  # In development, allowing '*' makes life easier!
]


class NGOSignup(BaseModel):
    # Login Info
    full_name: str
    email: str
    password: str
    # Public Profile Info
    organization_name: str
    description: str
    contact_phone: str
    aid_types: str # "Food, Medicine"


app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


DATA_URL = "https://api3.ffwc.gov.bd/data_load/recent-observed/"
STATION_NAMES_URL = "https://api3.ffwc.gov.bd/data_load/stations/"

@app.get("/")
def home():
    return {"message": "Flood Alert System is Online 🚀"}

@app.post("/sync-water-levels")
def sync_data_from_govt(db: Session = Depends(database.get_db)):
    try:

        print("Fetching Water Levels...")
        response = requests.get(DATA_URL, timeout=15)
        water_data = response.json()
        
        # Fetch Station Names (Optional, but makes it look nicer)
        # We try to get real names. If it fails, we use "Station ID"
        station_map = {}
        try:
            print("Fetching Station Names...")
            meta_response = requests.get(STATION_NAMES_URL, timeout=5)
            meta_data = meta_response.json()
            if isinstance(meta_data, list):
                for s in meta_data:
                    s_id = str(s.get("id", ""))
                    s_name = s.get("name", s.get("station", "Unknown"))
                    station_map[s_id] = s_name
        except:
            print("Could not fetch station names, using IDs instead.")

        count = 0

        for station_id, readings_list in water_data.items():
            if not readings_list or not isinstance(readings_list, list):
                continue
            latest_reading = readings_list[-1] 
            level_str = list(latest_reading.values())[0]
            
            try:
                water_level = float(level_str)
            except:
                water_level = 0.0

            name = station_map.get(station_id, f"Station {station_id}")
            existing = db.query(models.WaterStation).filter(models.WaterStation.station_name == name).first()
            
            if existing:
                existing.water_level = water_level
            else:
                new_station = models.WaterStation(
                    station_name=name,
                    river_name=f"River ID {station_id}", 
                    water_level=water_level,
                    danger_level=0.0 
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


# --- AUTHENTICATION FEATURE ---

class UserSignup(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    confirm_password: str
    is_volunteer: bool

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    is_volunteer: bool

@app.post("/auth/signup", response_model=Token)
def signup(user: UserSignup, db: Session = Depends(database.get_db)):
    if user.password != user.confirm_password:
        raise HTTPException(status_code=400, detail="Passwords do not match")
    
    existing_user = db.query(models.User).filter(models.User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_pw = get_password_hash(user.password)
    new_user = models.User(
        full_name=user.full_name,
        email=user.email,
        hashed_password=hashed_pw,
        is_volunteer=user.is_volunteer
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    access_token = create_access_token(data={"sub": new_user.email})
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "user_id": new_user.id,
        "is_volunteer": new_user.is_volunteer
    }

@app.post("/auth/login", response_model=Token)
def login(user_credentials: UserLogin, db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.email == user_credentials.email).first()
    if not user or not verify_password(user_credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
        )
    access_token = create_access_token(data={"sub": user.email})
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "user_id": user.id,
        "is_volunteer": user.is_volunteer
    }


@app.post("/auth/signup-ngo")
def register_ngo(ngo_data: NGOSignup, db: Session = Depends(database.get_db)):
    # 1. Check if email exists
    existing_user = db.query(models.User).filter(models.User.email == ngo_data.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    # 2. Create the User Login
    hashed_pw = pwd_context.hash(ngo_data.password)
    new_user = models.User(
        full_name=ngo_data.full_name,
        email=ngo_data.email,
        hashed_password=hashed_pw,
        role="ngo",          # <--- IMPORTANT: Mark them as NGO
        is_volunteer=False
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # 3. Create the Public NGO Profile linked to that User
    new_ngo_profile = models.NGO(
        user_id=new_user.id,  # <--- Link to the new user
        name=ngo_data.organization_name,
        description=ngo_data.description,
        contact_phone=ngo_data.contact_phone,
        aid_types=ngo_data.aid_types,
        is_verified=False     # Default to False until Admin approves
    )
    db.add(new_ngo_profile)
    db.commit()

    return {"message": "NGO Registration Successful! Please wait for verification."}


# --- ADMIN ONLY: VERIFY AN NGO ---

@app.put("/admin/verify-ngo/{ngo_id}")
def verify_ngo(ngo_id: int, db: Session = Depends(database.get_db)):
    # 1. Find the NGO
    ngo = db.query(models.NGO).filter(models.NGO.id == ngo_id).first()
    if not ngo:
        raise HTTPException(status_code=404, detail="NGO not found")
    
    # 2. Approve them
    ngo.is_verified = True
    db.commit()
    
    return {"message": f"Success! {ngo.name} is now a verified NGO."}


# 1. Create a Campaign (Only NGOs can do this)
@app.post("/campaigns/", response_model=schemas.CampaignResponse)
def create_campaign(
    campaign: schemas.CampaignCreate, 
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Security Check: Is the user an NGO?
    if current_user.role != "ngo":
        raise HTTPException(status_code=403, detail="Only verified NGOs can create campaigns.")
    
    # Verify the NGO profile exists
    if not current_user.ngo_profile:
        raise HTTPException(status_code=400, detail="NGO profile incomplete.")

    new_campaign = models.Campaign(
        title=campaign.title,
        description=campaign.description,
        target_amount=campaign.target_amount,
        ngo_id=current_user.ngo_profile.id
    )
    db.add(new_campaign)
    db.commit()
    db.refresh(new_campaign)
    return new_campaign

# 2. List All Campaigns (Public - For the App)
@app.get("/campaigns/", response_model=List[schemas.CampaignResponse])
def get_campaigns(skip: int = 0, limit: int = 20, db: Session = Depends(database.get_db)):
    return db.query(models.Campaign).offset(skip).limit(limit).all()


# 3. Submit a Flood Report (Any logged-in user)
@app.post("/reports/", response_model=schemas.ReportResponse)
def create_report(
    report: schemas.ReportCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user)
):
    new_report = models.FloodReport(
        description=report.description,
        location=report.location,
        latitude=report.latitude,
        longitude=report.longitude,
        severity=report.severity,
        user_id=current_user.id
    )
    db.add(new_report)
    db.commit()
    db.refresh(new_report)
    return new_report
# --- ADD THIS TO MAIN.PY ---
@app.get("/auth/me")
def read_current_user(current_user: models.User = Depends(get_current_user)):
    # This automatically uses the token to find the user details
    return {
        "id": current_user.id,
        "full_name": current_user.full_name,
        "email": current_user.email,
        "role": current_user.role, 
        "is_volunteer": current_user.is_volunteer
    }
# 4. Get All Reports (For the Map Screen)
@app.get("/reports/", response_model=List[schemas.ReportResponse])
def get_reports(db: Session = Depends(database.get_db)):
    return db.query(models.FloodReport).all()

# --- ADD THIS TO MAIN.PY ---

@app.get("/admin/unverified-ngos")
def get_unverified_ngos(db: Session = Depends(database.get_db)):
    # Fetch all NGOs where is_verified is False
    return db.query(models.NGO).filter(models.NGO.is_verified == False).all()

# --- PUBLIC: GET VERIFIED NGOS ---
@app.get("/ngos/")
def get_verified_ngos(db: Session = Depends(database.get_db)):
    return db.query(models.NGO).filter(models.NGO.is_verified == True).all()