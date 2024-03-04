//
//  MealItemReducer.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import Foundation
import ComposableArchitecture

/// This reducer doesn't do much of anything, other than load the meal's image if we haven't already.

@Reducer
struct MealItemReducer {
    typealias State = Meal
    enum Action: Equatable {
        case didAppear
        case didTap
        case didLoadImage(Data)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case didTapMeal(Meal)
        }
    }
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didAppear:
                if let url = URL(string: state.imgUrl), state.imgData == nil {
                    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                    return .run { send in
                        if let (data, _) = try? await URLSession.shared.data(for: request) {
                            await send(.didLoadImage(data))
                        } else {
                            await send(.didAppear)
                        }
                    }
                }
                return .none
            case .didLoadImage(let data):
                state.imgData = data
                return .none
            case .didTap:
                return .send(.delegate(.didTapMeal(state)))
            case .delegate(_):
                return .none
            
            }
        }
    }
}
