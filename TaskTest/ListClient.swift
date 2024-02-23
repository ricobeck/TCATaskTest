//
//  ListClient.swift
//  TaskTest
//
//  Created by Markus Müller on 22.02.24.
//

import Algorithms
import Dependencies
import DependenciesMacros
import Foundation
import SwiftUI
import Charts

struct Item: Equatable, Identifiable, Sendable {
    var id: Int
    var image: Image?
}

@DependencyClient
struct ListClient {
    var fetchItems: @Sendable () async throws -> [Item]
    var loadImage: @Sendable () async throws -> Image
}

extension ListClient: DependencyKey {
    static var liveValue: Self = .init(fetchItems: {
        try await withThrowingTaskGroup(of: [Item].self) { group in
            for chunk in (1 ... 3000).chunks(ofCount: 5) {
                group.addTask {
                    chunk.map { Item(id: $0) }
                }
            }
            return try await group.reduce([Item]()) { acc, items in
                try Task.checkCancellation()
                return acc + items
            }
        }
    }, loadImage: {
        let values = (1...200).map { ChartView.ChartValue(value: Double($0), date: Calendar.current.date(byAdding: .day, value: -$0, to: .now)!) }
        let image = try await renderChartImage(values: values)
        return Image(uiImage: image)
    })
}

extension DependencyValues {
    var listClient: ListClient {
        get { self[ListClient.self] }
        set { self[ListClient.self] = newValue }
    }
}

@MainActor
func renderChartImage(values: [ChartView.ChartValue]) async throws -> UIImage {
    let renderer = ImageRenderer(content: ChartView(values: values))
    renderer.scale = 3
    return renderer.uiImage!
}

struct ChartView: View {
    struct ChartValue: Identifiable {
        var value: Double
        var date: Date

        var id: Date { date }
    }
    let values: [ChartValue]
    var body: some View {
        Chart(values) { value in
            BarMark(x: .value("Date", value.date), y: .value("Value", value.value))

        }
        .frame(width: 300)
    }
}
