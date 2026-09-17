from datetime import date

from fastapi import APIRouter, Form
import pymysql

router = APIRouter()

def connect():
    return pymysql.connect(
        host="192.168.20.55",
        user="root",
        password="qwer1234",
        db="todo_team",
        charset="utf8",
    )

@router.post("")
async def insert_todo(
    image_seq: int = Form(...),
    todolist: str = Form(...),
):
    conn = None
    curs = None

    try:
        # 빈 할 일과 존재하지 않는 이미지 번호를 미리 차단
        if not todolist.strip():
            return {"result": "Error", "message": "todolist is required"}

        conn = connect()
        curs = conn.cursor()

        # 이미지가 실제로 등록되어 있는지 확인하여 잘못된 연결 데이터 생성을 방지
        check_image_sql = """
            SELECT seq
            FROM todo_team.image
            WHERE seq = %s
        """
        curs.execute(check_image_sql, (image_seq,))
        if curs.fetchone() is None:
            return {"result": "Error", "message": "image not found"}

        # todo 테이블에 할 일을 먼저 생성 date는 DATE 형식으로 저장
        insert_todo_sql = """
            INSERT INTO todo_team.todo (todolist, date)
            VALUES (%s, %s)
        """
        created_date = date.today()
        curs.execute(insert_todo_sql, (todolist.strip(), created_date))
        todo_seq = curs.lastrowid

        # todo와 image의 다대다 연결 정보를 selection 테이블에 저장
        insert_selection_sql = """
            INSERT INTO todo_team.selection (image_seq, todo_seq)
            VALUES (%s, %s)
        """
        curs.execute(insert_selection_sql, (image_seq, todo_seq))

        # 두 INSERT가 모두 성공한 경우에만 반영하여 부분 저장을 방지
        conn.commit()
        return {
            "result": "OK",
            "todo_seq": todo_seq,
            "image_seq": image_seq,
            "date": created_date.isoformat(),
        }

    except Exception as e:
        # DB 오류가 발생하면 todo와 selection을 함께 Rollback
        if conn is not None:
            conn.rollback()
        print("Error:", e)
        return {"result": "Error"}

    finally:
        if curs is not None:
            curs.close()
        if conn is not None:
            conn.close()

