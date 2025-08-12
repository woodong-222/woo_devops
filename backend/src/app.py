from fastapi import FastAPI
import logging

app = FastAPI()

@app.get(
    "/",
    responses={
        200: {
            "description": "Successful Response",
            "content": {
                "application/json": {
                    "example": {"message": "예시입니다."}
                }
            },
        }
    },
)
async def root():
    logging.info("api run")
    return {"message": "예시입니다."}