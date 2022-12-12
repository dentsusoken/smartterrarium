# coding: utf-8
import Adafruit_DHT as DHT
from tp_plug import *
import sqlite3


class ControlPlug():
    def __init__(self, threshold_day_temperature, threshold_night_temperature, over_temperature):
        # センサータイプの設定
        self.SENSOR_TYPE = DHT.DHT22
        # 使用するGPIOのピン番号
        self.DHT_GPIO = 26
        # パネルヒーターのオンオフを管理するフラグ（0:off、1：on）
        self.heat_flag = 0
        # 日中のパネルヒーターの稼働温度
        self.threshold_day_temperature = threshold_day_temperature
        # 夜間のパネルヒーターの稼働温度
        self.threshold_night_temperature = threshold_night_temperature
        # 超過温度（一度パネルヒーターが稼働すると稼働温度+超過温度を超えるまで稼働し続ける）
        self.over_temperature = over_temperature
        # 日中、夜間の切り替え温度
        self.day_start_hour = 7
        self.day_end_hour = 20
        print("***parameter_set:", self.threshold_day_temperature,
              self.threshold_night_temperature, self.over_temperature)

        # 起動時に一度IOTプラグの電源を落とす
        print(TPLink_Plug("192.168.11.23").off())

    # 昼間、夜間加温温度とオフまでの超過温度の設定
    def update_threshold(self, threshold_day_temperature, threshold_night_temperature, over_temperature):
        self.threshold_day_temperature = threshold_day_temperature
        self.threshold_night_temperature = threshold_night_temperature
        self.over_temperature = over_temperature

    # 温度、湿度センサーの読み取り
    def read_dht(self):
        try:
            # センサーからの信号読み取り
            humidity, temperature = DHT.read_retry(
                self.SENSOR_TYPE, self.DHT_GPIO)
            message_temp = "Temp= {0:0.1f} deg C".format(temperature)
            message_humidity = "Humidity= {0:0.1f} %".format(humidity)
            message = message_temp + ". " + message_humidity
            print(message)
        except:
            # センサから温度が取得できなかった際にNullが返るとエラーが起こるので応急処置
            humidity = 0.0
            temperature = 0.0
        return temperature, humidity

    # プラグ(HS105)のスイッチング
    def switch_plug(self, temperature, dt_now):
        print("dt_now.hour:", dt_now.hour)
        # 夜間、ヒーターオフ時、温度低下でヒーターオン
        if (dt_now.hour < 7 or 19 < dt_now.hour) and temperature < self.threshold_night_temperature and self.heat_flag == 0:
            self.heat_flag = 1
            print("night_on")
            print(TPLink_Plug("192.168.11.23").on())
        # 昼間、ヒーターオフ時、温度低下でヒーターオン
        if (7 < dt_now.hour < 19) and temperature < self.threshold_day_temperature and self.heat_flag == 0:
            self.heat_flag = 1
            print("day_on")
            print(TPLink_Plug("192.168.11.23").on())
        # 夜間、ヒーターオン時、温度上昇でヒーターオフ
        if (dt_now.hour < 7 or 19 < dt_now.hour) and temperature > (self.threshold_night_temperature + self.over_temperature) and self.heat_flag == 1:
            self.heat_flag = 0
            print("night_off")
            print(TPLink_Plug("192.168.11.23").off())
        # 昼間、ヒーターオン時、温度上昇でヒーターオフ
        if (7 < dt_now.hour < 19) and temperature > (self.threshold_day_temperature + self.over_temperature) and self.heat_flag == 1:
            self.heat_flag = 0
            print("day_off")
            print(TPLink_Plug("192.168.11.23").off())
        return self.heat_flag
        return self.heat_flag
    # CSV版　削除予定

    def write_temperature_humidity(self, temperature, humidity, measurement_time):
        print(measurement_time + ", " + str(temperature) +
              ", " + str(humidity) + ", " + str(self.heat_flag) + '\n')
        f = open('tp_temperature_temperature.csv', 'a')
        f.write(measurement_time + ", " + str(temperature) +
                ", " + str(humidity) + ", " + str(self.heat_flag) + '\n')
        f.close()


# データの読み書き用のクラス
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
        over_temperature = latest_record[0][3]
        conn.commit()
        conn.close()

        return threshold_day_temperature, threshold_night_temperature, over_temperature

    # parameter_set更新
    def update_parameter_set(self, measurement_time, threshold_day_temperature, threshold_night_temperature, over_temperature):
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        parameter_set = [
            (measurement_time, threshold_day_temperature, threshold_night_temperature, over_temperature)]
        cur.executemany(
            "insert into parameter_set values (?, ?, ?, ?)", parameter_set)
        conn.commit()
        conn.close()

        return threshold_day_temperature, threshold_night_temperature, over_temperature

    # 温度、湿度記録追加
    def update_temperature_humidity(self, measurement_time, temperature, humidity, heat_flag):
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        environmental_data = [
            (measurement_time, temperature, humidity, heat_flag)]
        cur.executemany(
            "insert into environmental_record values (?, ?, ?, ?)", environmental_data).fetchall()
        conn.commit()
        conn.close()

    #  1 レコード取得
    def read_one_records(self):
        # コネクタ作成
        conn = sqlite3.connect(self.dbname)
        cur = conn.cursor()
        # 値の取得
        data = cur.execute(
            'select * from environmental_record order by measurement_time desc limit  1')
        records = data.fetchall()
        print(records[0][1])
        return_value = {
            'timestamp': records[0][0],
            'temperature': records[0][1],
            'humidity': records[0][2],
            'heat_flag': records[0][3]
        }
        return return_value

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
