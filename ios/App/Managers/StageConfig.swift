/*
 * File: StageConfig.swift
 * Purpose: Centralized configuration for sensor thresholds and application constants.
 * Architecture: Static configuration enum.
 * AI Context: Source of truth for alert logic. Do not modify values without PRD alignment.
 */
#if canImport(Foundation)
  import Foundation

  @MainActor
  enum StageConfig {
    static let temperatureThreshold: Float = 30
    static let humidityThreshold: Float = 70
    static let historyLimit: Int = 288
    static let alertCooldown: TimeInterval = 30
  }
#endif
