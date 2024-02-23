//
//  AnimationFeature.swift
//  TaskTest
//
//  Created by Rico Becker on 23.02.24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct AnimationFeature {
    @ObservableState
    struct State {
        var isActive: Bool = false
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start:
                state.isActive = true
                return .none
            }
        }
    }

    enum Action {
        case start
    }
}

struct AnimationView: View {
    let store: StoreOf<AnimationFeature>
        
    var body: some View {
        ZStack {
            ForEach(0 ... 375, id: \.self) { index in
                let offset = CGFloat.random(in: 40 ... 600)
                Circle()
                    .frame(width: CGFloat.random(in: 40 ... 60))
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.red.opacity(1.0 / 375.0 * CGFloat(index)))
                    .offset(x: (Bool.random() ? 1 : -1) * CGFloat(index) / 2, y: store.isActive ? -offset : offset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            store.send(.start, animation: .easeInOut(duration: 5).repeatForever(autoreverses: true))
        }
    }
}
