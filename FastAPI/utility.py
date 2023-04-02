# coding: utf-8
import Adafruit_DHT as DHT
import RPi.GPIO as GPIO
from tp_plug import *
import datetime
import pytz
import sqlite3


class ControlPlug():
    def __init__(self, threshold_day_temperature, threshold_night_temperature, diff_temperature):
        self.SENSOR_TYPE = DHT.DHT22
        self.DHT_GPIO = 26
        self.heat_flag = 0
        self.threshold_day_temperature = threshold_day_temperature
        self.threshold_night_temperature = threshold_night_temperature
        self.diff_temperature = diff_temperature
        self.day_start_hour = 7
        self.day_end_hour = 20
        print("***parameter_set:", self.threshold_day_temperature,
              self.threshold_night_temperature, self.diff_temperature)

        # 起動時に一度IOTプラグの電源を落とす
        print(TPLink_Plug("192.168.11.23").off())

    # 昼間、夜間加温温度とオフまでの超過温度の設定
    def update_threshold(self, threshold_day_temperature, threshold_night_temperature, diff_temperature):
        self.threshold_day_temperature = threshold_day_temperature
        self.threshold_night_temperature = threshold_night_temperature
        self.diff_temperature = diff_temperature

    # 温度、湿度センサーの読み取り
    def read_dht(self):
        try:
            humidity, temperature = DHT.read_retry(
                self.SENSOR_TYPE, self.DHT_GPIO)
            message_temp = "Temp= {0:0.1f} deg C".format(temperature)
            message_humidity = "Humidity= {0:0.1f} %".format(humidity)
            message = message_temp + ". " + message_humidity
            print(message)
        except:
            humidity = 99.9
            temperature = 99.9
        return temperature, humidity
        
    # プラグ(HS105)のスイッチング
    def switch_plug(self, temperature, dt_now):
        # データベースから閾値を読み込む
        read_write_db = ReadWriteDB()
        self.threshold_day_temperature, self.threshold_night_temperature, self.diff_temperature = read_write_db.read_parameter_set()
        # 夜間、ヒーターオフ時、温度低下でヒーターオン
        if (dt_now.hour < 7 or 19 < dt_now.hour) and (temperature < self.threshold_night_temperature) and self.heat_flag == 0:
            self.heat_flag = 1
            print("night_on")
            print(TPLink_Plug("192.168.11.23").on())
        # 昼間、ヒーターオフ時、温度低下でヒーターオン
        if (7 < dt_now.hour < 19) and (temperature < self.threshold_day_temperature) and self.heat_flag == 0:
            self.heat_flag = 1
            print("day_on")
            print(TPLink_Plug("192.168.11.23").on())
        # 夜間、ヒーターオン時、温度上昇でヒーターオフ
        if (dt_now.hour < 7 or 19 < dt_now.hour) and (temperature > (self.threshold_night_temperature + self.diff_temperature)) and self.heat_flag == 1:
            self.heat_flag = 0
            print("night_off")
            print(TPLink_Plug("192.168.11.23").off())
        # 昼間、ヒーターオン時、温度上昇でヒーターオフ
        if (7 < dt_now.hour < 19) and (temperature > (self.threshold_day_temperature + self.diff_temperature)) and self.heat_flag == 1:
            self.heat_flag = 0
            print("day_off")
            print(TPLink_Plug("192.168.11.23").off())

        if self.heat_flag == 1:
            print("ON")
        else:
            print("OFF")

        return self.heat_flag

# データベース操作用
class ReadWriteDB():
    def __init__(self):
        self.dbname = 'smart-terrarium.db'

    # parameter_set読み出し
    def read_parameter_set(self):
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        data = cur.execute(
            'select * from parameter_set order by update_at desc limit 1')
        latest_record = data.fetchall()
        threshold_day_temperature = latest_record[0][1]
        threshold_night_temperature = latest_record[0][2]
        diff_temperature = latest_record[0][3]
        conn.commit()
        conn.close()

        return threshold_day_temperature, threshold_night_temperature, diff_temperature

    # parameter_set更新
    def update_parameter_set(self, measurement_time, threshold_day_temperature, threshold_night_temperature, diff_temperature):
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        parameter_set = [
            (measurement_time, threshold_day_temperature, threshold_night_temperature, diff_temperature)]
        cur.executemany(
            "insert into parameter_set values (?, ?, ?, ?)", parameter_set)
        conn.commit()
        conn.close()

        return threshold_day_temperature, threshold_night_temperature, diff_temperature

    # SQLite版　温度記録
    def update_temperature_humidity(self, measurement_time, temperature, humidity, heat_flag):
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        environmental_data = [
            (measurement_time, temperature, humidity, heat_flag)]
        cur.executemany(
            "insert into environmental_record values (?, ?, ?, ?)", environmental_data).fetchall()
        conn.commit()
        conn.close()

    #   400 レコード取得
    def read_records(self):
        # コネクタ作成
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        # 値の取得
        data = cur.execute(
            'select * from environmental_record order by measurement_time desc limit  400')
        records = data.fetchall()
        return_values = []
        for record in records:
            return_value = {
				'timestamp': record[0],
				'temperature': record[1],
				'humidity': record[2],
				'heat_flag': record[3]
            }
            return_values.append(return_value)
        return return_values

    #  1 レコード取得
    def read_one_records(self):
        # コネクタ作成
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        # 値の取得
        data = cur.execute(
            'select * from environmental_record order by measurement_time desc limit  1')
        records = data.fetchall()
        return_value = {
			'timestamp': records[0][0], 
            'temperature': records[0][1],
            'humidity': records[0][2],
            'heat_flag': records[0][3]
        }
        return return_value
        
    def read_heat_flag(self):
        # コネクタ作成
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        # 値の取得
        data = cur.execute(
            'select * from environmental_record order by measurement_time desc limit 1')
        latest_record = data.fetchall()
        heat_flag = int(latest_record[0][3])

        return heat_flag
