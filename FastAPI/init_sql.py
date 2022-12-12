import sqlite3
import datetime
import pytz

dbname = 'smart-terrarium.db'

# コネクタ作成。dbnameの名前を持つDBへ接続する。
conn = sqlite3.connect(dbname)
cur = conn.cursor()

# 温度、湿度記録用テーブルをリセットする
# cur.execute('DROP TABLE IF EXISTS environmental_record')

# テーブルの作成
cur.execute('CREATE TABLE environmental_record(measurement_time TEXT PRIMARY KEY,temperature float NOT NULL,humidity float NOT NULL,heat_flag int NOT NULL);')
cur.execute('CREATE TABLE parameter_set(update_at TEXT PRIMARY KEY,threshold_day_temperature float NOT NULL,threshold_night_temperature float NOT NULL,diff_temperature float NOT NULL)')

dt_now = datetime.datetime.now(pytz.timezone('Asia/Tokyo'))
measurement_time = dt_now.strftime('%Y-%m-%d %H:%M:%S')
parameter_data = [(measurement_time, 25.0, 22.0, 3.0)]
cur.executemany("insert into parameter_set values (?, ?, ?, ?)",
                parameter_data)


# 処理をコミット
conn.commit()
conn.close()
