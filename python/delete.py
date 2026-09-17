from fastapi import APIRouter
import pymysql

router = APIRouter()

def connect():
    return pymysql.connect(
        host = '192.168.20.55',
        user = 'root',
        passwd = 'qwer1234',
        database = 'todo_team',
        charset = 'utf8'
    )

@router.delete("/{seq}")
async def delete(seq: int):
    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute("DELETE FROM selection WHERE todo_seq = %s", (seq,))
        curs.execute("DELETE FROM todo WHERE seq = %s", (seq,))
        conn.commit()
        conn.close()
        return {'result': 'OK'}
    except Exception as e:
        print("Error", e)
        return {'result': 'Error'}
