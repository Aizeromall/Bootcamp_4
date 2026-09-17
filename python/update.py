import os

from fastapi import APIRouter, UploadFile, File, Form
import pymysql

router = APIRouter()


def connect():
    return pymysql.connect(
        host=os.getenv("MYSQL_HOST", "192.168.20.55"),
        user=os.getenv("MYSQL_USER", "root"),
        password=os.getenv("MYSQL_PASSWORD", "qwer1234"),
        database=os.getenv("MYSQL_DATABASE", "todo_team"),
        charset="utf8",
    )


@router.post("")
async def update(
    seq: int = Form(...),
    todo: str = Form(...),
    date: str = Form(...),
    image_seq: int | None = Form(None),
    file: UploadFile | None = File(None),
):
    conn = None

    try:
        conn = connect()
        curs = conn.cursor()

        curs.execute(
            """
            UPDATE todo_team
            SET todo = %s, date = %s
            WHERE seq = %s
            """,
            (todo, date, seq),
        )

        if file is not None:
            image_data = await file.read()
            curs.execute(
                """
                UPDATE imagetable
                SET image = %s
                WHERE seq = %s
                """,
                (image_data, image_seq if image_seq is not None else seq),
            )

        conn.commit()
        return {'result': 'OK'}
    except Exception as e:
        if conn is not None:
            conn.rollback()
        print("Error:", e)
        return {'result': 'Error'}
    finally:
        if conn is not None:
            conn.close()