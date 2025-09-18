from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI(title='trip-planner-server')

@app.get('/')
def default_func():
    try:
        return JSONResponse(status_code=200, content={
            "message": "Server is running"
        })
    except Exception as e:
        print(f"Error: {e}")
        return JSONResponse(status_code=400)
