from dotenv import load_dotenv
import os

load_dotenv()  # Load environment variables from .env

class Config:
    GROQ_API_KEY = os.getenv("GROQ_API_KEY", "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")  
    MONGODB_URI = os.getenv("MONGODB_URI", "mongodb+srv://quremkaif7:hello123@kaifcluster.oa5upzc.mongodb.net/?retryWrites=true&w=majority&appName=kaifcluster")
    MONGODB_NAME = os.getenv("MONGODB_NAME", "h2c")
    DEBUG = True
