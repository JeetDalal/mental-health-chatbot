from flask import Flask
from flask_cors import CORS  # Import CORS
from app.routes import main_routes
from app.chat import chat_routes
from app.questions import ques_routes

def create_app():
    app = Flask(__name__)
    app.config.from_object("app.config.Config")  # Load configuration

    # Enable CORS
    CORS(app)  # This will allow all domains to access your API

    app.register_blueprint(main_routes)  # Register routes
    app.register_blueprint(chat_routes, url_prefix="/api/")  # Register routes
    app.register_blueprint(ques_routes, url_prefix="/api/")  # Register routes
    
    return app
