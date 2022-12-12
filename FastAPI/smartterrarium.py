from fastapi import FastAPI
from fastapi_utils.tasks import repeat_every
from pydantic import BaseModel
import datetime
import pytz
from utility import ControlPlug, ReadWriteDB

# FastAPI
app = FastAPI()

# CORSの許可
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# DBの読み書き
read_write_db = ReadWriteDB()
# parameter_set（制御用のしきい値）取得
threshold_day_temperature, threshold_night_temperature, diff_temperature = read_write_db.read_parameter_set()

# センサーとヒーターのコントロール
control_plug = ControlPlug(threshold_day_temperature,
                           threshold_night_temperature,
                           diff_temperature)


# 定期実行用の関数
@app.get("/rest/")
@app.on_event("startup")
@repeat_every(seconds=60*15)
def heater_control():
    # 温度、湿度取得
    temperature, humidity = control_plug.read_dht()

    # 計測時刻取得
    dt_now = datetime.datetime.now(pytz.timezone('Asia/Tokyo'))
    measurement_time = dt_now.strftime('%Y-%m-%d %H:%M:%S')

    print(temperature, humidity, measurement_time)

    # プラグのスイッチング
    heat_flag = control_plug.switch_plug(
        temperature, dt_now)
    control_plug.write_temperature_humidity(
        temperature, humidity, measurement_time)

    # DBへの環境データの書き込み
    read_write_db.update_temperature_humidity(
        measurement_time, temperature, humidity, heat_flag)


@app.get("/")
async def root():
    return {"message": "This is the smart terrarium"}


# 複数レコード取得（温度、湿度記録）
@app.get("/get_records/")
async def get_record():
    records = read_write_db.read_records()
    return records

# レコード取得（温度、湿度記録）


@app.get("/get_record/")
async def get_record():
    records = read_write_db.read_one_records()
    return records


# parameter_setのリクエストボディー
class ParameterSet(BaseModel):
    day_temperature: int
    night_temperature: int
    diff_temperature: int


# 設定値テーブル更新
@app.post("/update_parameter_set/")
async def update_parameter_set(parameter_set: ParameterSet):
    dt_now = datetime.datetime.now(pytz.timezone('Asia/Tokyo'))
    measurement_time = dt_now.strftime('%Y-%m-%d %H:%M:%S.%f')
    read_write_db.update_parameter_set(
        measurement_time,
        int(parameter_set.day_temperature),
        int(parameter_set.night_temperature),
        int(parameter_set.diff_temperature))
    return {"message": "ok", "day_temperature": parameter_set.day_temperature, "night_temperature": parameter_set.night_temperature, " diff_temperature": parameter_set.diff_temperature}


# 設定値取得
@app.get("/get_parameter_set/")
async def get_parameter_set():
    day_temperature, night_temperature, diff_temperature = read_write_db.read_parameter_set()
    return {"message": "ok", "day_temperature":  int(day_temperature), "night_temperature": int(night_temperature), "diff_temperature": int(diff_temperature)}
