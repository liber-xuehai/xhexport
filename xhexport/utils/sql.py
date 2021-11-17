from sqlite3 import Connection


def select(conn: Connection, table, where=None):
    cmd = 'SELECT * FROM ' + table
    if where is not None:
        cmd += ' WHERE ' + where
    cur = conn.cursor()
    cur.execute(cmd)
    return cur.fetchall()
