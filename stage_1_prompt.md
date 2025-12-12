這份 PRD（產品需求文件）是專為 **AI Coding Agent (如 Cursor, Windsurf, GitHub Copilot)** 閱讀而優化的版本。它去除了模糊的敘述，強調資料結構、API 格式與邏輯規則，你可以直接將此文件貼給 AI，讓它精準產出程式碼。

-----

### 給 AI Coding Agent 的啟動指令 (Prompt)

若你要開始寫程式，可以直接複製以下指令給 Cursor 或 Copilot：

**針對 Supabase Setup:**

> "I am building an IoT project with Supabase. Please generate the SQL to create a table named `readings` with columns: id (int8, PK), created\_at (timestamptz), device\_id (text), temperature (float), humidity (float). Also, provide the SQL to enable RLS and allow public inserts but only authenticated selects."

**針對 ESP32 (Arduino):**

> "Write an Arduino sketch for ESP32 with DHT11 connected to GPIO 15. It needs to connect to WiFi, read sensor data every 10 seconds, and POST a JSON payload `{'device_id': 'demo_1', 'temperature': ..., 'humidity': ...}` to a Supabase REST API endpoint. Use `HTTPClient` and `ArduinoJson`. Handle WiFi reconnection."

**針對 iOS (SwiftUI):**

> "Create a SwiftUI ViewModel named `SensorViewModel` using the `supabase-swift` SDK. It should have a published property `currentReading`. It needs a function to subscribe to Realtime INSERT events on the `readings` table and update `currentReading` automatically. Also, include a function to fetch the last 100 rows for a history chart."