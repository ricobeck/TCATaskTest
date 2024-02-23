//
//  RowFeature.swift
//  TaskTest
//
//  Created by Markus Müller on 22.02.24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RowFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        var item: Item
        var isLoading: Bool
        var id: Item.ID { item.id }
    }

    enum Action {
        case task
        case fetchResult(Image)
    }

    @Dependency(\.listClient.loadImage) var loadImage
    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .run { [id = state.id] send in
                    await withTaskCancellation(id: id) {
                        await withThrowingTaskGroup(of: Void.self) { group in
                            group.addTask {
                                await send(.fetchResult(try await loadImage()))
                            }
                        }
                    }
                }

            case .fetchResult(let image):
                state.isLoading = false
                state.item.image = image
                return .none
            }
        }
    }
}

import SwiftUI

struct RowView: View {
    let store: StoreOf<RowFeature>

    var body: some View {
        VStack {
            Text("Chart \(store.item.id)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .task {
                    await store.send(.task).finish()
                }

            if store.isLoading {
                ProgressView()
            } else {
                store.item.image
            }
        }.padding()
    }
}

struct RowDetailView: View {
    let store: StoreOf<RowFeature>

    var body: some View {
        Form {
            Text("Chart \(store.item.id)")
        }
        .task {
            await store.send(.task).finish()
        }
    }
}
