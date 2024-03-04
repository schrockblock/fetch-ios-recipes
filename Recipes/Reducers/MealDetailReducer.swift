//
//  MealDetailReducer.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import Foundation
import ComposableArchitecture
import FunNetTCA
import FunNetCore
import ErrorHandling

/// This reducer calls the `lookup` endpoint, handles success and failure, and that's about it.

@Reducer
struct MealDetailReducer {
    
    @ObservableState
    struct State: Equatable {
        var meal: Meal
        var netCallState: NetCallReducer.State
        @Presents var alert: AlertState<Action.Alert>?
        
        init(meal: Meal) {
            self.meal = meal
            
            self.netCallState = Current.netState(from: mealDetailsEndpoint(with: meal.id))
        }
    }
    
    public enum Action: Equatable {
        case didAppear
        
        case detailsCall(NetCallReducer.Action)
        
        case alert(PresentationAction<Alert>)
        public enum Alert: Equatable, Sendable {}
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.netCallState, action: /MealDetailReducer.Action.detailsCall, child: NetCallReducer.init)
        Reduce { state, action in
            switch action {
            case .didAppear:
                return .send(.detailsCall(.fire))
            case .detailsCall(.delegate(.responseData(let data))):
                if let meals = try? Current.apiJsonDecoder.decode(MealsWrapper.self, from: data), 
                    let apiMeal = meals.meals?.first,
                    var meal = Meal.mealFromApi(apiMeal) {
                    meal.imgData = state.meal.imgData
                    state.meal = meal
                }
            case .detailsCall(.delegate(.error(let error as NSError))):
                var allErrors = urlLoadingErrorCodesDict
                allErrors.merge(urlResponseErrorMessages, uniquingKeysWith: { _, second in second })
                if let message = allErrors[error.code] {
                    state.alert = AlertState { TextState("Error: \(error.code)") } actions: {} message: {
                        TextState(message)
                    }
                }
                break
            case .detailsCall(_): break
            case .alert(_): break
            }
            return .none
        }
    }
}
