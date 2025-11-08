# Fruits And Veg App

A simple app to show how a 2 Tier app works. A list of **fruits** and **vegetables**

- **HTML + JS** frontend (Tier 1) - fetches data
- **FastAPI/Python** - backend  (Tier 2) provides `/fruits`

## Note

- The frontend points to python backend on `localhost:9000`. You might need to update this

## Frontend Requirments
 - Install Nginx/HTTPD and deploy index.html file as required

## Backend Python Requirments
 - ensure you python 3 on the server
 - Setup required scripts `python3 -m venv .venv`  
 - activate the script `source .venv/bin/activate`
 - install libraries `python -m pip install -r requirements.txt`
 - run app `uvicorn main:app --port 9000`

 