import base64

from fastapi import FastAPI
import pymysql

from delete import router as delete_router
from insert import router as insert_router
from search import router as search_router
from update import router as update_router

app = FastAPI()
app.include_router(delete_router, prefix='/delete', tags=['delete'])
app.include_router(insert_router, prefix='/insert', tags=['insert'])
app.include_router(search_router, prefix='/search', tags=['search'])
app.include_router(update_router, prefix='/update', tags=['update'])


def connect():
    return pymysql.connect(
        host='192.168.20.55',
        user='root',
        passwd='qwer1234',
        database='todo_team',
        charset='utf8'
    )


@app.get("/image", tags=['image'])
async def get_images():
    conn = None
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("SELECT seq, image FROM todo_team.image ORDER BY seq")
        rows = curs.fetchall()
        return {
            'result': 'OK',
            'images': [
                {'seq': seq, 'image': base64.b64encode(image).decode('utf-8')}
                for seq, image in rows
            ],
        }
    except Exception as e:
        print("Error:", e)
        return {'result': 'Error'}
    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="192.168.20.55", port=8000)
