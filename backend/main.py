import uvicorn

LOG = 'debug'

if __name__ == '__main__':
    try:
        if LOG == 'debug':
            uvicorn.run(
                "src.app:app", 
                host="0.0.0.0", 
                port=8000, 
                workers=1,
                log_level="info",
                reload=True,
            )
        else:
            uvicorn.run(
                "src.app:app", 
                host="0.0.0.0", 
                port=8000,
                workers=5,
                log_level="warning",
                reload=False,
            )
    except KeyboardInterrupt:
        print('\nExiting\n')
    except Exception as errormain:
        print('Failed to Start API')
        print('='*100)
        print(str(errormain))
        print('='*100)
        print('Exiting\n')