//
//  TaskTestApp.swift
//  TaskTest
//
//  Created by Markus Müller on 22.02.24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TaskTestApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(store: .init(initialState: AppFeature.State()) {
                AppFeature()
            })
        }
    }
}
