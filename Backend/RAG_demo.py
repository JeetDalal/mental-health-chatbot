import streamlit as st
import os
import tempfile
from typing import List, Dict, Any, Optional
from pathlib import Path
import uuid
from pydantic import BaseModel, Field
import time

from langchain_community.document_loaders import PyPDFLoader
from langchain.embeddings import HuggingFaceEmbeddings  # Corrected import
from langchain.vectorstores import Chroma  # Changed from FAISS to Chroma
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.documents import Document
from langchain_core.prompts import ChatPromptTemplate
from langchain_groq import ChatGroq

# Pydantic models for data validation
class DocumentMetadata(BaseModel):
    source: str = Field(..., description="Source document filename")
    page: int = Field(..., description="Page number in the document")

class DocumentChunk(BaseModel):
    content: str = Field(..., description="Text content of the document chunk")
    metadata: DocumentMetadata = Field(..., description="Metadata about the document chunk")

class RAGResponse(BaseModel):
    answer: str = Field(..., description="LLM generated answer")
    sources: List[DocumentChunk] = Field(default_factory=list, description="Source documents used for the answer")

# Initialize Streamlit app
st.set_page_config(page_title="RAG PDF Assistant", layout="wide")
st.title("📚 PDF Question Answering System")

# Initialize session state variables
if "processed_files" not in st.session_state:
    st.session_state.processed_files = []
if "vector_store" not in st.session_state:
    st.session_state.vector_store = None
if "total_chunks" not in st.session_state:
    st.session_state.total_chunks = 0
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

# Configuration settings
with st.sidebar:
    st.header("Configuration")
    groq_api_key = st.text_input("Groq API Key", type="password")
    model_name = st.selectbox(
        "Select Groq Model",
        ["llama-3.3-70b-specdec", "llama3-70b-8192", "llama3-8b-8192", "mixtral-8x7b-32768", "gemma-7b-it"],
        index=0  # Default to llama-3.3-70b-specdec
    )
    
    chunk_size = st.slider("Chunk Size", 400, 1500, 1000, 100)
    chunk_overlap = st.slider("Chunk Overlap", 0, 500, 200, 50)
    
    k_documents = st.slider("Number of documents to retrieve", 1, 10, 4)
    
    st.subheader("Document Stats")
    st.write(f"Documents processed: {len(st.session_state.processed_files)}")
    st.write(f"Total chunks: {st.session_state.total_chunks}")
    
    if st.session_state.processed_files:
        st.subheader("Processed Files")
        for file in st.session_state.processed_files:
            st.write(f"- {file}")
    
    if st.button("Clear All Data"):
        st.session_state.processed_files = []
        st.session_state.vector_store = None
        st.session_state.total_chunks = 0
        st.session_state.chat_history = []
        st.success("All data cleared!")

# Main content area
col1, col2 = st.columns([2, 3])

with col1:
    st.header("Document Upload")
    uploaded_files = st.file_uploader("Upload PDF files", type="pdf", accept_multiple_files=True)
    
    if uploaded_files and st.button("Process PDFs"):
        if not groq_api_key:
            st.error("Please enter your Groq API Key in the sidebar!")
        else:
            with st.spinner("Processing PDF files..."):
                # Initialize text splitter
                text_splitter = RecursiveCharacterTextSplitter(
                    chunk_size=chunk_size,
                    chunk_overlap=chunk_overlap,
                    separators=["\n\n", "\n", " ", ""]
                )
                
                # Initialize embedding model
                embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
                
                all_docs = []
                temp_dir = tempfile.mkdtemp()
                persist_directory = os.path.join(temp_dir, "chroma_db")
                
                # Process each uploaded file
                for uploaded_file in uploaded_files:
                    if uploaded_file.name in st.session_state.processed_files:
                        st.info(f"Skipping {uploaded_file.name} - already processed")
                        continue
                    
                    # Save uploaded file to temporary directory
                    temp_filepath = os.path.join(temp_dir, uploaded_file.name)
                    with open(temp_filepath, "wb") as f:
                        f.write(uploaded_file.getbuffer())
                    
                    # Load and split the PDF
                    loader = PyPDFLoader(temp_filepath)
                    documents = loader.load()
                    
                    # Add file source to metadata
                    for doc in documents:
                        doc.metadata["source"] = uploaded_file.name
                    
                    # Split documents into chunks
                    split_docs = text_splitter.split_documents(documents)
                    all_docs.extend(split_docs)
                    
                    # Add to processed files list
                    st.session_state.processed_files.append(uploaded_file.name)
                
                # Create or update vector store
                if all_docs:
                    if st.session_state.vector_store is None:
                        st.session_state.vector_store = Chroma.from_documents(
                            all_docs, embeddings, persist_directory=persist_directory
                        )
                    else:
                        st.session_state.vector_store.add_documents(all_docs)
                    
                    st.session_state.total_chunks += len(all_docs)
                    st.success(f"Successfully processed {len(uploaded_files)} PDFs with {len(all_docs)} chunks!")

with col2:
    st.header("Ask Questions")
    
    # Display the conversation history
    for message in st.session_state.chat_history:
        if message["role"] == "user":
            st.chat_message("user").write(message["content"])
        else:
            with st.chat_message("assistant"):
                st.write(message["content"])
                if "sources" in message:
                    with st.expander("View Sources"):
                        for i, source in enumerate(message["sources"]):
                            st.markdown(f"**Source {i+1}**: {source['metadata']['source']}, Page {source['metadata']['page']}")
                            st.markdown(f"```\n{source['content']}\n```")
    
    # Input for new question
    user_question = st.chat_input("Ask a question about your documents...")
    
    if user_question:
        if not st.session_state.vector_store:
            st.error("Please upload and process documents before asking questions!")
        elif not groq_api_key:
            st.error("Please enter your Groq API Key in the sidebar!")
        else:
            # Add user question to history
            st.session_state.chat_history.append({"role": "user", "content": user_question})
            
            # Display user question
            st.chat_message("user").write(user_question)
            
            # Display assistant response with spinner
            with st.chat_message("assistant"):
                response_placeholder = st.empty()
                with st.spinner("Thinking..."):
                    # Get relevant documents
                    docs = st.session_state.vector_store.similarity_search(user_question, k=k_documents)
                    
                    # Format documents for context
                    formatted_docs = []
                    for doc in docs:
                        formatted_docs.append(DocumentChunk(
                            content=doc.page_content,
                            metadata=DocumentMetadata(
                                source=doc.metadata.get("source", "Unknown"),
                                page=doc.metadata.get("page", 0)
                            )
                        ))
                    
                    context_str = "\n\n".join([f"Document from {doc.metadata.source}, Page {doc.metadata.page}:\n{doc.content}" for doc in formatted_docs])
                    
                    # Setup Groq LLM
                    llm = ChatGroq(
                        api_key=groq_api_key,
                        model_name=model_name
                    )
                    
                    # Create prompt template
                    prompt = ChatPromptTemplate.from_messages([
                        ("system", """You are a helpful assistant that answers questions based on the provided document context.
                         When answering, use only the information from the provided documents.
                         If you can't find the answer in the documents, say so honestly and explain what information is missing.
                         Provide detailed, informative responses and cite specific documents as your sources where possible."""),
                        ("user", "Context:\n{context}\n\nQuestion: {question}")
                    ])
                    
                    # Create chain
                    chain = prompt | llm
                    
                    # Generate response
                    response = chain.invoke({
                        "context": context_str,
                        "question": user_question
                    })
                    
                    answer_text = response.content
                    
                    # Display response
                    response_placeholder.write(answer_text)
                    
                    # Display sources
                    with st.expander("View Sources"):
                        for i, doc in enumerate(formatted_docs):
                            st.markdown(f"**Source {i+1}**: {doc.metadata.source}, Page {doc.metadata.page}")
                            st.markdown(f"```\n{doc.content}\n```")
                    
                    # Add assistant response to history
                    st.session_state.chat_history.append({
                        "role": "assistant", 
                        "content": answer_text,
                        "sources": [{"content": doc.content, "metadata": doc.metadata.dict()} for doc in formatted_docs]
                    })

# Add some helpful instructions at the bottom
st.markdown("---")
st.markdown("""
### How to use this app:
1. Enter your Groq API key in the sidebar
2. Upload one or more PDF files
3. Click "Process PDFs" to extract and embed the content
4. Ask questions about your documents in the chat
5. View source documents that were used to generate the answer
""")