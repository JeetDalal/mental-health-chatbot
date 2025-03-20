import os
from typing import List, Optional
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
from app.config import Config 

# Define the chat routes Blueprint
chat_routes = Blueprint("chat", __name__)

# Define Pydantic models for structured outputs
class EmotionAnalysis(BaseModel):
    primary_emotion: str = Field(description="The primary emotion detected in the user's message")
    intensity: int = Field(description="Intensity of the emotion on a scale of 1-10")
    secondary_emotions: Optional[List[str]] = Field(description="Any secondary emotions detected")
    triggers: Optional[List[str]] = Field(description="Potential triggers identified in the message")
    
class ChatResponse(BaseModel):
    emotion_analysis: EmotionAnalysis = Field(description="Analysis of emotional content")
    response: str = Field(description="Supportive response to the user")
    resources: Optional[List[str]] = Field(description="Relevant resources or techniques to suggest")
    follow_up_questions: Optional[List[str]] = Field(description="Potential follow-up questions to ask the user")

# Dictionary to store chat histories by session ID
session_memories = {}

# Initialize the embedding function and retriever
def get_retriever():
    persist_directory = "./app/chroma_db"
    collection_name = "my_collection"
    embedding_function = HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")
    
    # Load the existing vector store
    vectorstore = Chroma(
        persist_directory=persist_directory,
        embedding_function=embedding_function,
        collection_name=collection_name
    )
    
    return vectorstore.as_retriever(search_kwargs={"k": 5})

# Initialize the Groq LLM
def get_llm():
    groq_api_key = Config.GROQ_API_KEY
    if not groq_api_key:
        raise ValueError("GROQ_API_KEY not found in environment variables")
    
    return ChatGroq(
        model_name="llama-3.3-70b-specdec",
        groq_api_key=groq_api_key,
        temperature=0.5,
        max_tokens=1024
    )

# Define the prompt template for emotion analysis
EMOTION_ANALYSIS_PROMPT = PromptTemplate(
    input_variables=["query"],
    template="""You are an empathetic mental health assistant trained to identify emotions in text.
    
    Analyze the following message and identify the emotional content, including:
    - Primary emotion
    - Intensity (1-10)
    - Any secondary emotions
    - Potential triggers mentioned
    
    USER MESSAGE: {query}
    
    Provide your analysis in a structured format. Be sensitive and avoid making assumptions beyond what's in the text.
    """
)

# Define the prompt template for generating responses with RAG
RAG_RESPONSE_PROMPT = PromptTemplate(
    input_variables=["context", "query", "emotion_analysis", "chat_history"],
    template="""You are an empathetic mental health support chatbot designed to provide helpful, compassionate responses based on professional mental health resources.

    EMOTION ANALYSIS:
    {emotion_analysis}
    
    CONTEXT FROM KNOWLEDGE BASE:
    {context}
    
    CHAT HISTORY:
    {chat_history}
    
    USER MESSAGE:
    {query}
    
    Based on the emotion analysis, context from the knowledge base, and the chat history, provide a supportive response that:
    1. Acknowledges their emotional state with empathy and without judgment
    2. Offers evidence-based guidance relevant to their situation
    3. Suggests relevant coping strategies or resources if appropriate
    4. Maintains a warm, supportive tone throughout
    
    Keep your response concise, genuine, and focused on the user's needs. Avoid clinical jargon unless necessary. If you detect a crisis situation, gently suggest professional help while being supportive.
    """
)

# Define prompt template for small talk responses
SMALL_TALK_PROMPT = PromptTemplate(
    input_variables=["query", "chat_history"],
    template="""You are MindfulAI, an empathetic mental health support chatbot. Respond warmly and conversationally to this casual message or question while maintaining your identity as a mental health assistant.

    CHAT HISTORY:
    {chat_history}
    
    USER MESSAGE:
    {query}
    
    Provide a friendly, concise response. If appropriate, gently guide the conversation toward mental well-being topics without being pushy. Always maintain a supportive and warm tone.
    """
)

# Function to format retrieved documents into a single context string
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

# Initialize the retriever and LLM at module level
retriever = get_retriever()
llm = get_llm()

# Create the emotion analysis chain
emotion_analysis_chain = LLMChain(
    llm=llm,
    prompt=EMOTION_ANALYSIS_PROMPT,
    output_key="emotion_analysis"
)

# Get or create memory for a session
def get_memory(session_id):
    if session_id not in session_memories:
        # Create a new memory object for this session
        memory = ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True
        )
        session_memories[session_id] = memory
    return session_memories[session_id]

# Function to detect small talk messages
def is_small_talk(message):
    # Convert to lowercase for easier matching
    msg = message.lower().strip()
    
    # Common greetings and casual questions
    greetings = ["hello", "hi", "hey", "greetings", "good morning", "good afternoon", "good evening"]
    bot_identity = ["who are you", "what are you", "what do you do", "who created you", "how do you work", 
                   "what's your name", "what is your name", "tell me about yourself"]
    well_being = ["how are you", "how are you doing", "how's it going", "what's up", "how do you feel"]
    casual_questions = ["what can you do", "can you help me", "what should i do", "help"]
    
    # Check if message matches any small talk patterns
    if any(msg == greeting for greeting in greetings):
        return True
    if any(query in msg for query in bot_identity):
        return True
    if any(query in msg for query in well_being):
        return True
    if any(query == msg for query in casual_questions):
        return True
    if len(msg.split()) <= 5:  # Very short messages might be small talk
        return True
        
    return False

# Generate response for small talk
def handle_small_talk(query, memory):
    # Get chat history from memory
    chat_history = memory.load_memory_variables({})["chat_history"]
    
    # Format chat history for the prompt
    formatted_history = ""
    for message in chat_history:
        if isinstance(message, HumanMessage):
            formatted_history += f"USER: {message.content}\n"
        elif isinstance(message, AIMessage):
            formatted_history += f"ASSISTANT: {message.content}\n"
    
    # Create a small talk chain
    small_talk_chain = (
        {
            "query": RunnablePassthrough(),
            "chat_history": lambda _: formatted_history
        }
        | SMALL_TALK_PROMPT
        | llm
        | StrOutputParser()
    )
    
    # Execute the chain
    return small_talk_chain.invoke(query)

# Create the RAG response chain
def generate_rag_response(query, emotion_analysis, memory):
    # Get chat history from memory
    chat_history = memory.load_memory_variables({})["chat_history"]
    
    # Format chat history for the prompt
    formatted_history = ""
    for message in chat_history:
        if isinstance(message, HumanMessage):
            formatted_history += f"USER: {message.content}\n"
        elif isinstance(message, AIMessage):
            formatted_history += f"ASSISTANT: {message.content}\n"
    
    # Define the chain
    rag_chain = (
        {
            "context": retriever | format_docs, 
            "query": RunnablePassthrough(), 
            "emotion_analysis": lambda _: emotion_analysis,
            "chat_history": lambda _: formatted_history
        }
        | RAG_RESPONSE_PROMPT
        | llm
        | StrOutputParser()
    )
    
    # Execute the chain
    return rag_chain.invoke(query)

# Function to detect potentially critical situations
def detect_crisis(query, emotion_analysis):
    crisis_keywords = ["suicide", "kill myself", "end my life", "don't want to live", "harm myself", "hurt myself"]
    query_lower = query.lower()
    
    # Check for crisis keywords in the query
    if any(keyword in query_lower for keyword in crisis_keywords):
        return True
    
    # Check for high intensity negative emotions
    if "emotion_analysis" in emotion_analysis:
        try:
            # Parse the emotion data from the LLM response
            primary_emotion = re.search(r"primary_emotion.*?:\s*(\w+)", emotion_analysis).group(1).lower()
            intensity_match = re.search(r"intensity.*?:\s*(\d+)", emotion_analysis)
            if intensity_match:
                intensity = int(intensity_match.group(1))
                
                high_risk_emotions = ["despair", "hopeless", "suicidal"]
                if (primary_emotion in high_risk_emotions and intensity > 7) or intensity == 10:
                    return True
        except:
            pass
    
    return False

# Define the route for chat interactions
@chat_routes.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    user_query = data.get("message", "")
    session_id = data.get("session_id", "default")
    
    if not user_query:
        return jsonify({"error": "No message provided"}), 400
    
    try:
        # Get or create memory for this session
        memory = get_memory(session_id)
        
        # Save the user message to memory
        memory.chat_memory.add_user_message(user_query)
        
        # Check if this is small talk
        if is_small_talk(user_query):
            # Handle as small talk
            response = handle_small_talk(user_query, memory)
            
            # Save the assistant's response to memory
            memory.chat_memory.add_ai_message(response)
                
            # Create structured response (without emotion analysis for small talk)
            api_response = {
                "message": response,
                "is_small_talk": True
            }
            
            return jsonify(api_response)
        else:
            # Process as a regular mental health query
            # Run emotion analysis
            emotion_result = emotion_analysis_chain.run(query=user_query)
            
            # Check for crisis situations
            is_crisis = detect_crisis(user_query, emotion_result)
            
            # Generate RAG response
            rag_response = generate_rag_response(user_query, emotion_result, memory)
            
            # If crisis is detected, prepend crisis resources
            if is_crisis:
                crisis_resources = (
                    "I notice you may be going through a difficult time. "
                    "Please consider reaching out to a mental health professional or crisis helpline:\n"
                    "- India Crisis Helpline: 9152987821\n"
                    "- NIMHANS Mental Health Helpline: 080-26995099\n"
                    "- Vandrevala Foundation: 1860-2662-345\n\n"
                )
                final_response = crisis_resources + rag_response
            else:
                final_response = rag_response
            
            # Save the assistant's response to memory
            memory.chat_memory.add_ai_message(final_response)
                
            # Create structured response
            api_response = {
                "message": final_response,
                "emotion_analysis": emotion_result,
                "is_crisis": is_crisis,
                "is_small_talk": False
            }
            
            return jsonify(api_response)
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"error": "An error occurred processing your request", "details": str(e)}), 500

# Route for getting emotional analysis only
@chat_routes.route("/analyze-emotion", methods=["POST"])
def analyze_emotion():
    data = request.get_json()
    user_query = data.get("message", "")
    
    if not user_query:
        return jsonify({"error": "No message provided"}), 400
    
    try:
        # Run emotion analysis
        emotion_result = emotion_analysis_chain.run(query=user_query)
        return jsonify({"emotion_analysis": emotion_result})
    
    except Exception as e:
        return jsonify({"error": "An error occurred processing your request", "details": str(e)}), 500

# Route for clearing chat history
@chat_routes.route("/clear-history", methods=["POST"])
def clear_history():
    data = request.get_json()
    session_id = data.get("session_id", "default")
    
    if session_id in session_memories:
        del session_memories[session_id]
        return jsonify({"status": "success", "message": "Chat history cleared"})
    else:
        return jsonify({"status": "success", "message": "No history found for this session"})