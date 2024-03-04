//
//  MealsTests.swift
//  RecipesTests
//
//  Created by Elliot Schrock on 3/2/24.
//

import XCTest
import ComposableArchitecture
import FunNetTCA
import FunNetCore
import ErrorHandling
@testable import Recipes

@MainActor
final class MealsTests: XCTestCase {
    func testLoading() async throws {
        /// Test meals, which are mocked here, are out of order and have null/empty values; if it equals `successArray`, which is in alphabetical order,
        /// and is without null/empty values, then we know our json parsing was correct and that our sorting code (in the reducer) is correct.
        let netState = Current.mockNetState(from: mealsEndpoint(), with: testMealsJson.data(using: .utf8)!, delay: 0)
        let modelsState = NetModelsReducer<ApiMeal, MealsWrapper>.State(modelsCallState: netState, unwrap: { $0.meals })
        let state = MealsReducer.State(netModelsState: modelsState)
        let store = TestStore(initialState: state) { MealsReducer() } withDependencies: { $0.mainQueue = .immediate }
        
        await store.send(.didAppear)
        await store.receive(.models(.refresh))
        await store.receive(.models(.modelsCall(.refresh))) {
            $0.netModelsState.modelsCallState.isInProgress = true
        }
        await store.receive(.models(.modelsCall(.delegate(.responseData(testMealsJson.data(using: .utf8)!))))) {
            $0.netModelsState.modelsCallState.isInProgress = false
        }
        await store.receive(.models(.delegate(.didUpdateModels(successApiArray)))) {
            $0.mealArray = successArray
            $0.meals = successArray
        }
    }
    
    func testErrorLoading() async throws {
        let netState = Current.mockNetState(from: mealsEndpoint(), with: testMealsJson.data(using: .utf8)!, delay: 0)
        let modelsState = NetModelsReducer<ApiMeal, MealsWrapper>.State(modelsCallState: netState, unwrap: { $0.meals })
        let state = MealsReducer.State(netModelsState: modelsState)
        let store = TestStore(initialState: state) { MealsReducer() } withDependencies: { $0.mainQueue = .immediate }
        
        let errorCode = 403
        await store.send(.models(.modelsCall(.delegate(.error(NSError(domain: "Server", code: errorCode, userInfo: [:])))))) {
            $0.netModelsState.modelsCallState.isInProgress = false
            $0.netModelsState.alert = AlertState { TextState("Error: \(errorCode)") } actions: {} message: {
                TextState(urlResponseErrorMessages[errorCode]!)
            }
        }
    }
    
    func testMealTapped() async throws {
        let netState = Current.mockNetState(from: mealsEndpoint(), with: testMealsJson.data(using: .utf8)!, delay: 0)
        let modelsState = NetModelsReducer<ApiMeal, MealsWrapper>.State(modelsCallState: netState, unwrap: { $0.meals })
        let state = MealsReducer.State(meals: IdentifiedArray(uniqueElements: successArray), netModelsState: modelsState)
        let store = TestStore(initialState: state) { MealsReducer() } withDependencies: { $0.mainQueue = .immediate }
        let meal = successArray[0]
        
        await store.send(.model(meal.id, .delegate(.didTapMeal(meal)))) {
            $0.details = MealDetailReducer.State(meal: meal)
        }
    }
    
    func testFilterMeals() async throws {
        let netState = Current.mockNetState(from: mealsEndpoint(), with: testMealsJson.data(using: .utf8)!, delay: 0)
        let modelsState = NetModelsReducer<ApiMeal, MealsWrapper>.State(modelsCallState: netState, unwrap: { $0.meals })
        let state = MealsReducer.State(mealArray: IdentifiedArray(uniqueElements: successArray), meals: IdentifiedArray(uniqueElements: successArray), netModelsState: modelsState)
        let store = TestStore(initialState: state) { MealsReducer() } withDependencies: { $0.mainQueue = .immediate }
        let meal = successArray[0]
        let searchTerm = "blac" // from "Apple & Blackberry Crumble"
        
        await store.send(.binding(.set(\.localFilter, searchTerm))) {
            $0.localFilter = searchTerm
            $0.meals = IdentifiedArray(uniqueElements: [meal])
        }
        await store.send(.binding(.set(\.localFilter, ""))) {
            $0.localFilter = ""
            $0.meals = successArray
        }
    }
}

/// This json is: out of alphabetical order, has elements with null properties,
/// and has elements with empty properties. A correct parsing of it, according
/// to the assignment guidelines, would result in an array with only the
/// crumble and the brulee, in that order.
let testMealsJson = """
{"meals":[
{
"strMeal":"White chocolate creme brulee",
"strMealThumb":"https://www.themealdb.com/images/media/meals/uryqru1511798039.jpg",
"idMeal":"52917"
}, {
"strMealThumb":"https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg",
"idMeal":"52768"
}, {
"strMeal":"Bakewell tart",
"idMeal":"52767"
}, {
"strMeal":"Banana Pancakes",
"strMealThumb":"https://www.themealdb.com/images/media/meals/sywswr1511383814.jpg"
}, {
"strMeal":"",
"strMealThumb":"https://www.themealdb.com/images/media/meals/xqwwpy1483908697.jpg",
"idMeal":"52792"
},{
"strMeal":"Budino Di Ricotta",
"strMealThumb":"",
"idMeal":"52961"
},{
"strMeal":"Canadian Butter Tarts",
"strMealThumb":"https://www.themealdb.com/images/media/meals/wpputp1511812960.jpg",
"idMeal":""
},{
"strMeal":"Apple & Blackberry Crumble",
"strMealThumb":"https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg",
"idMeal":"52893"
}]}
"""
let successApiArray = [
    ApiMeal(id: "52917", name: "White chocolate creme brulee", imgUrl: "https://www.themealdb.com/images/media/meals/uryqru1511798039.jpg"),
    ApiMeal(id: "52768", name: nil, imgUrl: "https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg"),
    ApiMeal(id: "52767", name: "Bakewell tart", imgUrl: nil),
    ApiMeal(id: nil, name: "Banana Pancakes", imgUrl: "https://www.themealdb.com/images/media/meals/sywswr1511383814.jpg"),
    ApiMeal(id: "52792", name: "", imgUrl: "https://www.themealdb.com/images/media/meals/xqwwpy1483908697.jpg"),
    ApiMeal(id: "52961", name: "Budino Di Ricotta", imgUrl: ""),
    ApiMeal(id: "", name: "Canadian Butter Tarts", imgUrl: "https://www.themealdb.com/images/media/meals/wpputp1511812960.jpg"),
    ApiMeal(id: "52893", name: "Apple & Blackberry Crumble", imgUrl: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg")
]
let successArray = IdentifiedArray(uniqueElements: [
    Meal(id: "52893", name: "Apple & Blackberry Crumble", imgUrl: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg"),
    Meal(id: "52917", name: "White chocolate creme brulee", imgUrl: "https://www.themealdb.com/images/media/meals/uryqru1511798039.jpg")
])
