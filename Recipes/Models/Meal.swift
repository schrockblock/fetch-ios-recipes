//
//  Meal.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import Foundation
import ComposableArchitecture
import Tagged

typealias MealId = Tagged<Meal, String>
struct Meal: Codable, Identifiable, Equatable {
    var id: MealId
    var name: String
    var imgUrl: String
    var imgData: Data?
    var instructions: String?
    var youtubeUrl: String?
    var ingredients: [Ingredient]?
    
    static func mealFromApi(_ apiMeal: ApiMeal) -> Meal? {
        if let apiId = apiMeal.id, let id = MealId(apiId), let name = apiMeal.name, let imgUrl = apiMeal.imgUrl {
            return Meal(id: id, name: name, imgUrl: imgUrl, instructions: apiMeal.instructions, youtubeUrl: apiMeal.youtubeUrl, ingredients: apiMeal.ingredients)
        }
        return nil
    }
}

struct MealsWrapper: Codable {
    var meals: [ApiMeal]?
}

struct Ingredient: Codable, Equatable, Identifiable, Hashable {
    var id = Current.uuid()
    var name: String
    var measurement: String?
}

// Wait, why an `ApiMeal` struct as well as a `Meal` struct?
//
// The `ApiMeal` lets us decode directly from the server data and
// allow for nil properties, while converting from `ApiMeal` to
// `Meal` (in a reducer) allows us to know that, for the `Meal`s
// we have, their properties are non-nil. It looks significantly
// cleaner in the view, which, in my experience, is where it
// counts.
//
// Finally, this two tiered approach allows us to isolate the
// complexity of the server json structure to this file, so that
// if/when the server migrates, we can just refactor here rather
// than throughout the codebase.
//
// All of this is tested indirectly through the reducer tests.
struct ApiMeal: Codable, Equatable {
    var id: String?
    var name: String?
    var imgUrl: String?
    var instructions: String?
    var youtubeUrl: String?
    var ingredients: [Ingredient]?
    
    func encode(to encoder: Encoder) throws {
        // NO OP: this is out of scope for this assignment
    }
    
    init(id: String?, name: String?, imgUrl: String?) {
        self.id = id
        self.name = name
        self.imgUrl = imgUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.imgUrl = try container.decodeIfPresent(String.self, forKey: .imgUrl)
        self.instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        self.youtubeUrl = try container.decodeIfPresent(String.self, forKey: .youtubeUrl)
        
        // Yuck! Why do we need this? Because the API provides up to 20 hard coded
        // ingredient/measurement pairs (see the CodingKeys). We can parse those into
        // our own native Swift struct, which will be much easier to manage in the view
        let keys = [
            (ingredient: CodingKeys.ingredient1, measurement: CodingKeys.measurement1),
            (ingredient: CodingKeys.ingredient2, measurement: CodingKeys.measurement2),
            (ingredient: CodingKeys.ingredient3, measurement: CodingKeys.measurement3),
            (ingredient: CodingKeys.ingredient4, measurement: CodingKeys.measurement4),
            (ingredient: CodingKeys.ingredient5, measurement: CodingKeys.measurement5),
            (ingredient: CodingKeys.ingredient6, measurement: CodingKeys.measurement6),
            (ingredient: CodingKeys.ingredient7, measurement: CodingKeys.measurement7),
            (ingredient: CodingKeys.ingredient8, measurement: CodingKeys.measurement8),
            (ingredient: CodingKeys.ingredient9, measurement: CodingKeys.measurement9),
            (ingredient: CodingKeys.ingredient10, measurement: CodingKeys.measurement10),
            (ingredient: CodingKeys.ingredient11, measurement: CodingKeys.measurement11),
            (ingredient: CodingKeys.ingredient12, measurement: CodingKeys.measurement12),
            (ingredient: CodingKeys.ingredient13, measurement: CodingKeys.measurement13),
            (ingredient: CodingKeys.ingredient14, measurement: CodingKeys.measurement14),
            (ingredient: CodingKeys.ingredient15, measurement: CodingKeys.measurement15),
            (ingredient: CodingKeys.ingredient16, measurement: CodingKeys.measurement16),
            (ingredient: CodingKeys.ingredient17, measurement: CodingKeys.measurement17),
            (ingredient: CodingKeys.ingredient18, measurement: CodingKeys.measurement18),
            (ingredient: CodingKeys.ingredient19, measurement: CodingKeys.measurement19),
            (ingredient: CodingKeys.ingredient20, measurement: CodingKeys.measurement20)
        ]
        
        var ingredients = [Ingredient]()
        for tuple in keys {
            if let ingredientName = try? container.decodeIfPresent(String.self, forKey: tuple.ingredient), !ingredientName.isEmpty {
                let measurement = try? container.decodeIfPresent(String.self, forKey: tuple.measurement)
                ingredients.append(Ingredient(name: ingredientName, measurement: measurement))
            }
        }
        if !ingredients.isEmpty {
            self.ingredients = ingredients
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case imgUrl = "strMealThumb"
        case youtubeUrl = "strYoutube"
        case instructions = "strInstructions"
        case ingredients
        
        case ingredient1 = "strIngredient1"
        case ingredient2 = "strIngredient2"
        case ingredient3 = "strIngredient3"
        case ingredient4 = "strIngredient4"
        case ingredient5 = "strIngredient5"
        case ingredient6 = "strIngredient6"
        case ingredient7 = "strIngredient7"
        case ingredient8 = "strIngredient8"
        case ingredient9 = "strIngredient9"
        case ingredient10 = "strIngredient10"
        case ingredient11 = "strIngredient11"
        case ingredient12 = "strIngredient12"
        case ingredient13 = "strIngredient13"
        case ingredient14 = "strIngredient14"
        case ingredient15 = "strIngredient15"
        case ingredient16 = "strIngredient16"
        case ingredient17 = "strIngredient17"
        case ingredient18 = "strIngredient18"
        case ingredient19 = "strIngredient19"
        case ingredient20 = "strIngredient20"
        
        case measurement1 = "strMeasure1"
        case measurement2 = "strMeasure2"
        case measurement3 = "strMeasure3"
        case measurement4 = "strMeasure4"
        case measurement5 = "strMeasure5"
        case measurement6 = "strMeasure6"
        case measurement7 = "strMeasure7"
        case measurement8 = "strMeasure8"
        case measurement9 = "strMeasure9"
        case measurement10 = "strMeasure10"
        case measurement11 = "strMeasure11"
        case measurement12 = "strMeasure12"
        case measurement13 = "strMeasure13"
        case measurement14 = "strMeasure14"
        case measurement15 = "strMeasure15"
        case measurement16 = "strMeasure16"
        case measurement17 = "strMeasure17"
        case measurement18 = "strMeasure18"
        case measurement19 = "strMeasure19"
        case measurement20 = "strMeasure20"
    }
}
