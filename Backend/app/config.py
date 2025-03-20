from dotenv import load_dotenv
import os

load_dotenv()  # Load environment variables from .env

class Config:
    GROQ_API_KEY = os.getenv("GROQ_API_KEY", "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")  
    DEBUG = True
