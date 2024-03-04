//
//  MealDetailsTests.swift
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
final class MealDetailsTests: XCTestCase {
    func testParsing() async throws {
        let uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        Current = withDependencies {
            $0.uuid = .constant(uuid)
        } operation: {
            Env()
        }
        
        let state = MealDetailReducer.State(meal: successArray[0])
        let store = TestStore(initialState: state) { MealDetailReducer() } withDependencies: { $0.mainQueue = .immediate }
        
        await store.send(.detailsCall(.delegate(.responseData(detailJson.data(using: .utf8)!)))) {
            $0.meal = Meal(id: "52893",
                           name: "Apple & Blackberry Crumble",
                           imgUrl: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg",
                           instructions: "Heat oven to 190C/170C fan/gas 5. Tip the flour and sugar into a large bowl. Add the butter, then rub into the flour using your fingertips to make a light breadcrumb texture. Do not overwork it or the crumble will become heavy. Sprinkle the mixture evenly over a baking sheet and bake for 15 mins or until lightly coloured. Meanwhile, for the compote, peel, core and cut the apples into 2cm dice. Put the butter and sugar in a medium saucepan and melt together over a medium heat. Cook for 3 mins until the mixture turns to a light caramel. Stir in the apples and cook for 3 mins. Add the blackberries and cinnamon, and cook for 3 mins more. Cover, remove from the heat, then leave for 2-3 mins to continue cooking in the warmth of the pan. To serve, spoon the warm fruit into an ovenproof gratin dish, top with the crumble mix, then reheat in the oven for 5-10 mins. Serve with vanilla ice cream.",
                           youtubeUrl: "https://www.youtube.com/watch?v=4vhcOwVBDO4",
                           ingredients: [
                            Ingredient(id: uuid, name: "Plain Flour", measurement: "120g"),
                            Ingredient(id: uuid, name: "Caster Sugar", measurement: "60g"),
                            Ingredient(id: uuid, name: "Butter", measurement: "60g"),
                            Ingredient(id: uuid, name: "Braeburn Apples", measurement: "300g"),
                            Ingredient(id: uuid, name: "Butter", measurement: "30g"),
                            Ingredient(id: uuid, name: "Demerara Sugar", measurement: "30g"),
                            Ingredient(id: uuid, name: "Blackberrys", measurement: "120g"),
                            Ingredient(id: uuid, name: "Ice Cream", measurement: "to serve"),
                           ]
            )
        }
    }
    
    func testLoadingError() async throws {
        let state = MealDetailReducer.State(meal: successArray[0])
        let store = TestStore(initialState: state) { MealDetailReducer() } withDependencies: { $0.mainQueue = .immediate }
        
        let errorCode = 403
        await store.send(.detailsCall(.delegate(.error(NSError(domain: "Server", code: errorCode, userInfo: [:]))))) {
            $0.alert = AlertState { TextState("Error: \(errorCode)") } actions: {} message: {
                TextState(urlResponseErrorMessages[errorCode]!)
            }
        }
    }
}

let detailJson = """
{"meals":[
{
    "idMeal": "52893",
    "strMeal": "Apple & Blackberry Crumble",
    "strDrinkAlternate": null,
    "strCategory": "Dessert",
    "strArea": "British",
    "strInstructions": "Heat oven to 190C/170C fan/gas 5. Tip the flour and sugar into a large bowl. Add the butter, then rub into the flour using your fingertips to make a light breadcrumb texture. Do not overwork it or the crumble will become heavy. Sprinkle the mixture evenly over a baking sheet and bake for 15 mins or until lightly coloured. Meanwhile, for the compote, peel, core and cut the apples into 2cm dice. Put the butter and sugar in a medium saucepan and melt together over a medium heat. Cook for 3 mins until the mixture turns to a light caramel. Stir in the apples and cook for 3 mins. Add the blackberries and cinnamon, and cook for 3 mins more. Cover, remove from the heat, then leave for 2-3 mins to continue cooking in the warmth of the pan. To serve, spoon the warm fruit into an ovenproof gratin dish, top with the crumble mix, then reheat in the oven for 5-10 mins. Serve with vanilla ice cream.",
    "strMealThumb": "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg",
    "strTags": "Pudding",
    "strYoutube": "https://www.youtube.com/watch?v=4vhcOwVBDO4",
    "strIngredient1": "Plain Flour",
    "strIngredient2": "Caster Sugar",
    "strIngredient3": "Butter",
    "strIngredient4": "Braeburn Apples",
    "strIngredient5": "Butter",
    "strIngredient6": "Demerara Sugar",
    "strIngredient7": "Blackberrys",
    "strIngredient9": "Ice Cream",
    "strIngredient10": null,
    "strIngredient11": "",
    "strIngredient12": "",
    "strIngredient13": "",
    "strIngredient14": "",
    "strIngredient15": "",
    "strIngredient16": "",
    "strIngredient17": "",
    "strIngredient18": "",
    "strIngredient19": "",
    "strIngredient20": "",
    "strMeasure1": "120g",
    "strMeasure2": "60g",
    "strMeasure3": "60g",
    "strMeasure4": "300g",
    "strMeasure5": "30g",
    "strMeasure6": "30g",
    "strMeasure7": "120g",
    "strMeasure9": "to serve",
    "strMeasure10": "",
    "strMeasure11": "",
    "strMeasure12": "",
    "strMeasure13": "",
    "strMeasure14": "",
    "strMeasure15": "",
    "strMeasure16": "",
    "strMeasure17": "",
    "strMeasure18": "",
    "strMeasure19": "",
    "strMeasure20": "",
    "strSource": "https://www.bbcgoodfood.com/recipes/778642/apple-and-blackberry-crumble",
    "strImageSource": null,
    "strCreativeCommonsConfirmed": null,
    "dateModified": null
}]}
"""
