//
//  MealsReducer.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import Foundation
import ComposableArchitecture
import FunNetCore
import FunNetTCA

@Reducer
struct MealsReducer {
    
    @ObservableState
    public struct State: Equatable {
        /// We hold two arrays of meals, one of which always holds the full list from the server,
        /// and one that holds what we're currently displaying (ie, the meals that have been
        /// filtered by the `filter` property).
        var mealArray: IdentifiedArrayOf<Meal> = .init()
        var meals: IdentifiedArrayOf<Meal> = .init()
        var localFilter = ""
        var netModelsState: NetModelsReducer<ApiMeal, MealsWrapper>.State
        
        @Presents public var details: MealDetailReducer.State?
    }
    
    enum Action: Equatable, BindableAction {
        case didAppear
        
        case binding(BindingAction<State>)
        case details(PresentationAction<MealDetailReducer.Action>)
        case model(Meal.ID, MealItemReducer.Action)
        case models(NetModelsReducer<ApiMeal, MealsWrapper>.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer().onChange(of: \.localFilter) { oldValue, newValue in
            Reduce { state, action in
                if !newValue.isEmpty {
                    state.meals = state.meals.filter({ meal in
                        return matchesWordsPrefixes(newValue, meal.name)
                    })
                } else {
                    state.meals = state.mealArray
                }
                return .none
            }
        }
        Scope(state: \.netModelsState, action: /MealsReducer.Action.models, child: NetModelsReducer<ApiMeal, MealsWrapper>.init)
        Reduce { state, action in
            switch action {
            case .didAppear:
                if state.meals.isEmpty {
                    return .send(.models(.refresh))
                }
            case .models(.delegate(.didUpdateModels(let modelArray))):
                //Here we remove nil and empty meals
                let nonNilArray = modelArray.compactMap { Meal.mealFromApi($0) }
                let nonEmptyArray = nonNilArray.filter { !$0.id.rawValue.isEmpty && !$0.name.isEmpty && !$0.imgUrl.isEmpty }
                //Here we sort alphabetically
                let sortedArray = nonEmptyArray.sorted(by: { lhs, rhs in
                    return lhs.name < rhs.name
                })
                //Two arrays, so we can filter one
                state.mealArray = IdentifiedArray(uniqueElements: sortedArray)
                state.meals = IdentifiedArray(uniqueElements: sortedArray)
            case .binding(_): break
            case .model(let id, .didLoadImage(let data)):
                state.mealArray[id: id]?.imgData = data
                state.meals[id: id]?.imgData = data
            case .model(_, .delegate(.didTapMeal(let meal))):
                state.details = MealDetailReducer.State(meal: meal)
            case .model(_, _): break
            case .models(_): break
            case .details(_): break
            }
            return .none
        }.ifLet(\.$details, action: \.details) {
            MealDetailReducer()
        }.forEach(\.meals, action: /Action.model(_:_:)) {
            MealItemReducer()
        }
    }
}

func matchesWordsPrefixes(_ search: String, _ text: String) -> Bool {
    let textWords = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
    let searchWords = search.components(separatedBy: CharacterSet.alphanumerics.inverted)
    for word in searchWords {
        var foundMatch = false
        for textWord in textWords {
            if textWord.prefix(word.count).caseInsensitiveCompare(word) == .orderedSame {
                foundMatch = true
                break
            }
        }
        if !foundMatch {
            return false
        }
    }
    return true
}
