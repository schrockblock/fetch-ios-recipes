//
//  Api.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import Foundation
import FunNetCore

/// I like to keep all my endpoints together so that I can move them to new projects easily.
/// Because the endpoints in FunNet are independent from the base url they're called on,
/// transporting them in this way is easy and convenient. In this case, I don't exactly
/// envision doing so, but for things like login endpoints, or profiles, or searches, it can
/// make more sense.

func mealsEndpoint(for category: String = "Dessert") -> Endpoint {
    var endpoint = Endpoint()
    endpoint.path = "filter.php"
    endpoint.getParams = [URLQueryItem(name: "c", value: category)]
    return endpoint
}

func mealDetailsEndpoint(with id: MealId) -> Endpoint {
    var endpoint = Endpoint()
    endpoint.path = "lookup.php"
    endpoint.getParams = [URLQueryItem(name: "i", value: id.rawValue)]
    return endpoint
}
