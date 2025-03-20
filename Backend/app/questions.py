import os
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from flask import Blueprint, request, jsonify
from langchain.vectorstores import Chroma
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.schema.runnable import RunnablePassthrough
from langchain.prompts import PromptTemplate
from langchain.schema import StrOutputParser
from langchain_groq import ChatGroq
from langchain.chains import LLMChain
from langchain.memory import ChatMessageHistory, ConversationBufferMemory
from langchain.schema import HumanMessage, AIMessage
import re
import json
from app.config import Config

# Define the chat routes Blueprint
ques_routes = Blueprint("questions", __name__)

# Define Pydantic models for structured output
class QuestionOption(BaseModel):
    text: str = Field(description="Option text")
    score: int = Field(description="Numerical score for this option (1-5)")
    mood_indicator: str = Field(description="What this choice indicates about mood")

class MoodQuestion(BaseModel):
    question_id: str = Field(description="Unique identifier for the question")
    question_text: str = Field(description="The actual question text")
    question_type: str = Field(description="Type of question (e.g., 'energy', 'mood', 'social')")
    options: List[QuestionOption] = Field(description="Available options for this question")

class MoodQuestionnaire(BaseModel):
    introduction: str = Field(description="Friendly introduction to the questionnaire")
    questions: List[MoodQuestion] = Field(description="List of mood assessment questions")
    conclusion: str = Field(description="Encouraging message after completing questions")

class EmotionAssessment(BaseModel):
    primary_emotion: str = Field(description="The dominant emotion detected")
    primary_confidence: float = Field(description="Confidence score for primary emotion (0-1)")
    secondary_emotion: str = Field(description="Secondary emotion detected")
    secondary_confidence: float = Field(description="Confidence score for secondary emotion (0-1)")
    tertiary_emotion: str = Field(description="Tertiary emotion detected")
    tertiary_confidence: float = Field(description="Confidence score for tertiary emotion (0-1)")

class MoodAnalysis(BaseModel):
    mood_assessment: str = Field(description="Brief assessment of current mood state")
    emotion_profile: EmotionAssessment = Field(description="Structured emotion assessment")
    conversation_starter: str = Field(description="Suggested conversation starter")
    recommended_tone: str = Field(description="Recommended tone for the chatbot")

# Initialize Groq LLM
llm = ChatGroq(
    api_key=Config.GROQ_API_KEY,
    model_name="llama-3.3-70b-specdec"
)

# Output parser for structured JSON
class PydanticOutputParser:
    def __init__(self, pydantic_model):
        self.pydantic_model = pydantic_model
        
    def parse(self, text):
        # Extract JSON from the text (handling cases where the LLM might add extra text)
        json_match = re.search(r'```json\s*([\s\S]*?)\s*```|(\{[\s\S]*\})', text)
        if json_match:
            json_str = json_match.group(1) or json_match.group(2)
            try:
                return self.pydantic_model.model_validate_json(json_str)
            except Exception as e:
                raise ValueError(f"Failed to parse JSON: {str(e)}, JSON: {json_str}")
        else:
            try:
                # Try to parse the entire text as JSON
                return self.pydantic_model.model_validate_json(text)
            except Exception as e:
                raise ValueError(f"Failed to extract JSON from response: {text}")

# Create prompt template for generating mood assessment questions
mood_questions_prompt = PromptTemplate(
    input_variables=["num_questions"],
    template="""
    Generate a fun and engaging mood assessment questionnaire with {num_questions} questions.
    
    The questions should be lighthearted yet insightful, using casual language, metaphors, 
    and relatable scenarios. Each question should have 4-5 options that help determine the user's 
    current mental state in a non-clinical way.
    
    Make the questions creative - they can be about preferences, hypothetical scenarios, 
    or indirect ways of gauging mood rather than directly asking "how do you feel?"
    
    Your response must be a valid JSON object in the following format:
    
    ```json
    {{
        "introduction": "A friendly welcome message",
        "questions": [
            {{
                "question_id": "q1",
                "question_text": "The question text",
                "question_type": "energy/mood/social/etc",
                "options": [
                    {{
                        "text": "Option text",
                        "score": 5,
                        "mood_indicator": "What this indicates"
                    }},
                    // More options...
                ]
            }},
            // More questions...
        ],
        "conclusion": "An encouraging message"
    }}
    ```
    
    Don't include any explanation or additional text - just the JSON object.
    """
)

# Function to generate mood questions
def generate_mood_questionnaire(num_questions=5):
    # Generate the questionnaire using the LLM
    chain = LLMChain(llm=llm, prompt=mood_questions_prompt)
    result = chain.run(num_questions=num_questions)
    
    # Parse the result
    parser = PydanticOutputParser(MoodQuestionnaire)
    try:
        return parser.parse(result)
    except Exception as e:
        raise ValueError(f"Failed to generate valid questionnaire: {str(e)}")

@ques_routes.route("/generate_mood_questions", methods=["GET"])
def generate_mood_questions_endpoint():
    try:
        # Get number of questions from query parameters (default to 5)
        num_questions = request.args.get("num_questions", default=5, type=int)
        
        # Generate the questionnaire
        questionnaire = generate_mood_questionnaire(num_questions)
        
        # Return as JSON
        return jsonify(questionnaire.model_dump())
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# Create prompt template for analyzing mood responses
mood_analysis_prompt = PromptTemplate(
    input_variables=["responses"],
    template="""
    Based on the user's responses to the mood assessment questionnaire:
    
    {responses}
    
    Generate a detailed mood analysis in the following JSON format:
    
    ```json
    {{
        "mood_assessment": "A brief, friendly assessment of their current mood state",
        "emotion_profile": {{
            "primary_emotion": "The dominant emotion detected",
            "primary_confidence": 0.85,
            "secondary_emotion": "Secondary emotion detected",
            "secondary_confidence": 0.65,
            "tertiary_emotion": "Tertiary emotion detected",
            "tertiary_confidence": 0.40
        }},
        "conversation_starter": "A suggested conversation starter appropriate for their mood",
        "recommended_tone": "A tone recommendation for the chatbot (supportive, energetic, calm, etc.)"
    }}
    ```
    
    Choose from these emotion categories: Joy, Sadness, Anger, Fear, Surprise, Disgust, Trust, Anticipation, 
    Calmness, Anxiety, Contentment, Frustration, Excitement, Boredom, Hope, Loneliness, Gratitude, Stress.
    
    Provide only the JSON object without any explanation or additional text.
    """
)

@ques_routes.route("/submit_mood_responses", methods=["POST"])
def submit_mood_responses():
    try:
        # Get responses from request body
        responses = request.json.get("responses", [])
        
        if not responses:
            return jsonify({"error": "No responses provided"}), 400
        
        # Create a prompt with the responses
        chain = LLMChain(llm=llm, prompt=mood_analysis_prompt)
        result = chain.run(responses=json.dumps(responses, indent=2))
        
        # Parse the result
        parser = PydanticOutputParser(MoodAnalysis)
        analysis = parser.parse(result)
        
        # Return the analysis
        return jsonify(analysis.model_dump())
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# Route to start a conversation based on mood analysis
@ques_routes.route("/start_conversation", methods=["POST"])
def start_conversation():
    try:
        # Get mood analysis from request body
        mood_analysis = request.json.get("mood_analysis", {})
        user_message = request.json.get("user_message", "")
        
        if not mood_analysis:
            return jsonify({"error": "No mood analysis provided"}), 400
        
        # Create a conversation starter prompt
        conversation_starter_prompt = PromptTemplate(
            input_variables=["mood_analysis", "user_message"],
            template="""
            You are a mental health support chatbot. Based on the following mood analysis and the user's message,
            respond in a helpful, supportive way. Use the recommended tone and conversation starter as guidance.
            
            Mood Analysis:
            {mood_analysis}
            
            User Message:
            {user_message}
            
            Your response should be empathetic, non-judgmental, and appropriate for the user's emotional state.
            If the user hasn't provided a specific message, use the conversation starter from the mood analysis.
            
            Respond in JSON format:
            ```json
            {{
                "response_text": "Your response to the user",
                "follow_up_questions": ["1-3 follow-up questions to keep the conversation going"]
            }}
            ```
            
            Provide only the JSON without any explanation or additional text.
            """
        )
        
        # Generate a response
        chain = LLMChain(llm=llm, prompt=conversation_starter_prompt)
        result = chain.run(
            mood_analysis=json.dumps(mood_analysis, indent=2),
            user_message=user_message
        )
        
        # Extract the JSON
        json_match = re.search(r'```json\s*([\s\S]*?)\s*```|(\{[\s\S]*\})', result)
        if json_match:
            json_str = json_match.group(1) or json_match.group(2)
            try:
                response_data = json.loads(json_str)
                return jsonify(response_data)
            except json.JSONDecodeError:
                return jsonify({"error": "Failed to parse response JSON"}), 500
        else:
            return jsonify({"error": "Failed to generate valid response"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 400