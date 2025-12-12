#include <cmath>
#include <cstdio>
#include <string>
#include <vector>
#include "unity.h"

static const std::string kDeviceId = "test_device_01";

bool isValidReading(float temperature, float humidity) {
    return !std::isnan(temperature) && !std::isnan(humidity);
}

unsigned long intervalMs(bool demoMode) {
    return demoMode ? 10000UL : 300000UL;
}

std::string buildPayload(const std::string &deviceId, float temperature, float humidity) {
    const int required = std::snprintf(
        nullptr,
        0,
        "{\"device_id\":\"%s\",\"temperature\":%.2f,\"humidity\":%.2f}",
        deviceId.c_str(),
        static_cast<double>(temperature),
        static_cast<double>(humidity));
    if (required < 0) {
        return {};
    }
    std::vector<char> buffer(static_cast<std::size_t>(required) + 1);
    std::snprintf(
        buffer.data(),
        buffer.size(),
        "{\"device_id\":\"%s\",\"temperature\":%.2f,\"humidity\":%.2f}",
        deviceId.c_str(),
        static_cast<double>(temperature),
        static_cast<double>(humidity));
    return std::string(buffer.data());
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
    const auto deviceField = std::string("\"device_id\":\"") + kDeviceId + "\"";
    TEST_ASSERT_TRUE(payload.find(deviceField) != std::string::npos);
    TEST_ASSERT_TRUE(payload.find("\"temperature\":23.50") != std::string::npos);
    TEST_ASSERT_TRUE(payload.find("\"humidity\":60.10") != std::string::npos);
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

int main() {
    UNITY_BEGIN();
    RUN_TEST(test_nan_filtered);
    RUN_TEST(test_payload_contains_fields);
    RUN_TEST(test_interval_modes);
    RUN_TEST(test_upload_requirements);
    return UNITY_END();
}
