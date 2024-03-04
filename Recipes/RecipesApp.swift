//
//  RecipesApp.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import SwiftUI
import ComposableArchitecture
import FunNetTCA
import FunNetCore
import LithoOperators

@main
struct RecipesApp: App {
    var body: some Scene {
        WindowGroup {
            MealsView(store: Store(initialState: MealsReducer.State(netModelsState: NetModelsReducer.State(modelsCallState: Current.netState(from: mealsEndpoint()), unwrap: ^\MealsWrapper.meals)), reducer: { MealsReducer() }))
        }
    }
}
