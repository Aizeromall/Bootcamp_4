from fastapi import APIRouter, Form
import pymysql

router = APIRouter()


def connect():
    return pymysql.connect(
        host='192.168.20.55',
        user='root',
        passwd='qwer1234',
        database='todo_team',
        charset='utf8'
    )


@router.post("")
async def search(
    todolist: str = Form(...)):

    try:
        conn = connect()
        curs = conn.cursor()
        curs.execute(
            "SELECT * FROM todo WHERE todolist LIKE %s",
            ('%' + todolist + '%',)
        )
        rows = curs.fetchall()
        conn.close()
        return {'results': rows}

    except Exception as e:
        print("Error:", e)
        return {'result': 'Error'}
