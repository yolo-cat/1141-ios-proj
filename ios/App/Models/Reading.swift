/*
 * File: Reading.swift
 * Purpose: Domain model for sensor data (Temperature & Humidity).
 * Architecture: Immutable Struct, DTO corresponding to Supabase 'readings' table.
 * AI Context: Core data model. Used in Charts and Alerts.
 */
#if canImport(Foundation)
  import Foundation

  struct Reading: Identifiable, Equatable {
    let id: Int64
    let createdAt: Date
    let deviceId: String
    let temperature: Float
    let humidity: Float

    static let placeholder = Reading(
      id: 0,
      createdAt: Date(),
      deviceId: "demo",
      temperature: 0,
      humidity: 0
    )
  }
#endif
