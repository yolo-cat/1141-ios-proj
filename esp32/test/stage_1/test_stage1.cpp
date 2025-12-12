#include <cmath>
#include <cstdio>
#include <string>
#include "unity.h"

static const std::string kDeviceId = "tea_room_01";

bool isValidReading(float temperature, float humidity) {
    return !std::isnan(temperature) && !std::isnan(humidity);
}

unsigned long intervalMs(bool demoMode) {
    return demoMode ? 10000UL : 300000UL;
}

std::string buildPayload(const std::string &deviceId, float temperature, float humidity) {
    char buffer[128];
    std::snprintf(
        buffer,
        sizeof(buffer),
        "{\"device_id\":\"%s\",\"temperature\":%.2f,\"humidity\":%.2f}",
        deviceId.c_str(),
        static_cast<double>(temperature),
        static_cast<double>(humidity));
    return std::string(buffer);
}

bool canUpload(bool wifiConnected, float temperature, float humidity) {
    return wifiConnected && isValidReading(temperature, humidity);
}

void test_nan_filtered(void) {
    TEST_ASSERT_FALSE(isValidReading(NAN, 45.0f));
    TEST_ASSERT_FALSE(isValidReading(23.0f, NAN));
}

void test_payload_contains_fields(void) {
    const auto payload = buildPayload(kDeviceId, 23.5f, 60.1f);
    TEST_ASSERT_NOT_EQUAL(std::string::npos, payload.find("\"device_id\":\"tea_room_01\""));
    TEST_ASSERT_NOT_EQUAL(std::string::npos, payload.find("\"temperature\":23.50"));
    TEST_ASSERT_NOT_EQUAL(std::string::npos, payload.find("\"humidity\":60.10"));
}

void test_interval_modes(void) {
    TEST_ASSERT_EQUAL(10000UL, intervalMs(true));
    TEST_ASSERT_EQUAL(300000UL, intervalMs(false));
}

void test_upload_requirements(void) {
    TEST_ASSERT_TRUE(canUpload(true, 22.3f, 55.0f));
    TEST_ASSERT_FALSE(canUpload(false, 22.3f, 55.0f));
    TEST_ASSERT_FALSE(canUpload(true, NAN, 55.0f));
}

int main(int argc, char **argv) {
    UNITY_BEGIN();
    RUN_TEST(test_nan_filtered);
    RUN_TEST(test_payload_contains_fields);
    RUN_TEST(test_interval_modes);
    RUN_TEST(test_upload_requirements);
    return UNITY_END();
}
