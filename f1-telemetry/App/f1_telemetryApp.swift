//
//  f1_telemetryApp.swift
//  f1-telemetry
//
//  Created by 진정수 on 11/6/25.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

@main
struct f1_telemetryApp: App {

    var body: some Scene {
        WindowGroup {
            TelemetryView(
                store: Store(initialState: TelemetryFeature.State()) {
                            TelemetryFeature()
                        }
            )
        }
    }
}
