/*
 * 版本更新註釋:
 * 2024-11-25 v1: 修復 GPIO 4 輸入輸出衝突,實體按鈕改用 GPIO 17,實現虛擬與實體按鈕雙向控制 LED 並同步狀態到 V5 Label
 * 2024-11-25 v2: 修正按鈕邏輯從切換模式改為按住/放開模式,按住時 LED 亮顯示 Button Down,放開時 LED 滅顯示 Button Up
 * 2024-11-25 v3: 加入計數器強制刷新 Blynk Label 顯示,解決 Label 元件不更新問題
 * 2024-11-25 v4: 加入 DHT11 溫濕度感測器,連接 GPIO 32,按鈕按下時更新溫濕度數據到 V0 和 V1
 */

#define BLYNK_PRINT Serial
#define BLYNK_TEMPLATE_ID "TMPL6IoglQkK7"
#define BLYNK_TEMPLATE_NAME "Quickstart Template"
#define BLYNK_AUTH_TOKEN "X12hSrsYVoGdAsrW03_V8ys5YebyvefK"

#include <WiFi.h>
#include <WiFiClient.h>
#include <BlynkSimpleEsp32.h>
#include <DHTesp.h>

// WiFi authentication details
char ssid[] = "JoXP10vi";
char password[] = "0919091821";

// GPIO pins
const int LED_PIN = 4;
const int BUTTON_PIN = 17;
const int DHT_PIN = 32;

// DHT11 sensor
DHTesp dht;

// LED state
bool ledState = LOW;
bool lastButtonState = HIGH;
int updateCounter = 0;

// Virtual Pin V4 - 虛擬按鈕控制 LED
BLYNK_WRITE(V4) {
    int pinValue = param.asInt();
    ledState = pinValue;
    digitalWrite(LED_PIN, ledState);

    // 同步狀態到 V5 Label (加入計數器強制刷新)
    updateCounter++;
    if(ledState == HIGH) {
        Blynk.virtualWrite(V5, String("Button Down #") + String(updateCounter));

        // 按鈕按下時讀取並更新 DHT11 數據
        readAndUpdateDHT();
    } else {
        Blynk.virtualWrite(V5, String("Button Up #") + String(updateCounter));
    }

    Serial.print("V4 Button value: ");
    Serial.println(pinValue);
}

// 讀取 DHT11 並更新到 Blynk
void readAndUpdateDHT() {
    TempAndHumidity data = dht.getTempAndHumidity();

    if (dht.getStatus() == 0) {
        // 讀取成功
        float temperature = data.temperature;
        float humidity = data.humidity;

        // 更新到 Blynk V0 (溫度) 和 V1 (濕度)
        Blynk.virtualWrite(V0, String("Temperature: ") + String(temperature, 1) + " °C");
        Blynk.virtualWrite(V1, String("Humidity: ") + String(humidity, 1) + " %");

        Serial.print("Temperature: ");
        Serial.print(temperature, 1);
        Serial.print(" °C, Humidity: ");
        Serial.print(humidity, 1);
        Serial.println(" %");
    } else {
        // 讀取失敗
        Serial.println("DHT11 read error: " + String(dht.getStatusString()));
        Blynk.virtualWrite(V0, "Temperature: Error");
        Blynk.virtualWrite(V1, "Humidity: Error");
    }
}

void setup() {
    Serial.begin(115200);
    Blynk.begin(BLYNK_AUTH_TOKEN, ssid, password);

    pinMode(LED_PIN, OUTPUT);
    pinMode(BUTTON_PIN, INPUT_PULLUP);
    digitalWrite(LED_PIN, LOW);

    // 初始化 DHT11
    dht.setup(DHT_PIN, DHTesp::DHT11);
    Serial.println("DHT11 initialized on GPIO " + String(DHT_PIN));

    // 初始化 V5 顯示
    Blynk.virtualWrite(V5, "Button Up #0");

    // 初始化溫濕度顯示
    Blynk.virtualWrite(V0, "Temperature: --");
    Blynk.virtualWrite(V1, "Humidity: --");
}

void loop() {
    Blynk.run();
    int button_status = digitalRead(BUTTON_PIN);

    // 按鈕狀態改變時更新
    if(button_status != lastButtonState) {

        updateCounter++;

        if(button_status == LOW) {
            // 按鈕被按下
            ledState = HIGH;
            digitalWrite(LED_PIN, HIGH);

            // 同步到 Blynk V4 虛擬按鈕
            Blynk.virtualWrite(V4, HIGH);

            // 更新 V5 Label 顯示 (加入計數器強制刷新)
            Blynk.virtualWrite(V5, String("Button Down #") + String(updateCounter));

            // 讀取並更新 DHT11 數據
            readAndUpdateDHT();

            Serial.println("Physical button pressed, LED ON");

        } else {
            // 按鈕被放開
            ledState = LOW;
            digitalWrite(LED_PIN, LOW);

            // 同步到 Blynk V4 虛擬按鈕
            Blynk.virtualWrite(V4, LOW);

            // 更新 V5 Label 顯示 (加入計數器強制刷新)
            Blynk.virtualWrite(V5, String("Button Up #") + String(updateCounter));

            Serial.println("Physical button released, LED OFF");
        }

        lastButtonState = button_status;
        delay(50); // 消除按鈕彈跳
    }

    delay(10);
}
