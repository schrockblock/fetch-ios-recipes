//
//  MealsView.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import SwiftUI
import ComposableArchitecture
import FunNetTCA
import FunNetCore

struct MealsView: View {
    @Bindable var store: StoreOf<MealsReducer>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                GeometryReader { geometry in
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count:  Int(geometry.size.width / (singleColumnWidth / 2))), alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/) {
                            ForEachStore(self.store.scope(state: \.meals, action: MealsReducer.Action.model(_:_:))) { modelStore in
                                MealCardView(store: modelStore)
                            }
                        }
                    }
                    .refreshable {
                        store.send(.models(.refresh))
                    }
                    .padding(EdgeInsets(top: 0, leading: margin, bottom: 0, trailing: margin))
                }
                .navigationTitle("Meals".localized())
                .onAppear(perform: {
                    store.send(.didAppear)
                })
                .navigationDestination(item: $store.scope(state: \.details, action: \.details)) { store in
                    MealDetailView(store: store)
                }
                .alert($store.scope(state: \.netModelsState.alert, action: \.models.alert))
            }
            .searchable(text: $store.localFilter)
        }
    }
}

#Preview {
    MealsView(store: Store(initialState: MealsReducer.State(netModelsState: NetModelsReducer<ApiMeal, MealsWrapper>.State(modelsCallState: Current.mockNetState(from: mealsEndpoint(), with: mealsJson.data(using: .utf8)!), unwrap: { $0.meals })), reducer: { MealsReducer() }))
}
