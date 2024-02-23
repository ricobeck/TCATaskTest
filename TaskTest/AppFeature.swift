//
//  AppFeature.swift
//  TaskTest
//
//  Created by Rico Becker on 23.02.24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    @Reducer
    enum Destination {
        case list(ListFeature)
    }

    @Reducer
    enum Path {
        case animation(AnimationFeature)
    }

    @ObservableState
    struct State {
        var path: StackState<Path.State> = .init()
        @Presents var destination: Destination.State? = nil
    }

    enum Action {
        case showListButtonTapped
        case showAnimationButtonTapped
        case path(StackAction<Path.State, Path.Action>)
        case destination(PresentationAction<Destination.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showAnimationButtonTapped:
                state.path.append(.animation(.init()))
                return .none

            case .showListButtonTapped:
                state.destination = .list(.init())
                return .none

            case .destination:
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }
}

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                Button("Show List") {
                    store.send(.showListButtonTapped)
                }

                Button("Show Animation") {
                    store.send(.showAnimationButtonTapped)
                }
            }
            .sheet(item: $store.scope(state: \.destination?.list, action: \.destination.list)) { store in
                ListFeatureView(store: store)
            }
        } destination: { store in
            switch store.case {
            case let .animation(store):
                AnimationView(store: store)
            }
        }
    }
}
