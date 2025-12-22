/*
 * File: TeaWarehouseApp.swift
 * Purpose: Main application entry point and dependency injection root.
 * Architecture: SwiftUI App structure using @Observation for state management.
 * AI Context: Root of the view hierarchy. Injects global view models.
 */
#if canImport(SwiftUI)
  import SwiftUI
  import Observation

  @main
  struct TeaWarehouseApp: App {
    @State private var authViewModel = AuthViewModel()
    @State private var sensorViewModel = DashboardViewModel.makeDefault()

    var body: some Scene {
      WindowGroup {
        Group {
          if authViewModel.sessionToken == nil {
            LoginView()
          } else {
            DashboardView(viewModel: sensorViewModel)
          }
        }
        .environment(authViewModel)
      }
    }
  }
#endif
