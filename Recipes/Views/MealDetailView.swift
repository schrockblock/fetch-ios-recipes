//
//  MealDetailView.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import SwiftUI
import ComposableArchitecture
import FunNetTCA

struct MealDetailView: View {
    @Bindable var store: StoreOf<MealDetailReducer>
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: store.meal.imgUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: maxImageHeight)
                            .clipShape(Rectangle())
                    } else if let error = phase.error {
                        Image(systemName: "photo")
                            .frame(minWidth: maxImageHeight / 2, maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray)
                    } else {
                        ProgressView()
                    }
                }
                
                if let ingredients = store.meal.ingredients {
                    ForEach(ingredients) { ingredient in
                            HStack {
                                Text("\(ingredient.name): \(ingredient.measurement ?? "uh oh")")
                                Spacer()
                            }
                    }
                    .padding(EdgeInsets(top: 0, leading: margin, bottom: 0, trailing: margin))
                }
                
                Text(store.meal.instructions ?? "").padding()
            }
        }.navigationTitle(store.meal.name)
        .onAppear {
            store.send(.didAppear)
        }
    }
}

let meal = Meal(
    id: "52893",
    name: "Apple & Blackberry Crumble",
    imgUrl: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg",
    instructions: "Heat oven to 190C/170C fan/gas 5. Tip the flour and sugar into a large bowl. Add the butter, then rub into the flour using your fingertips to make a light breadcrumb texture. Do not overwork it or the crumble will become heavy. Sprinkle the mixture evenly over a baking sheet and bake for 15 mins or until lightly coloured.\r\nMeanwhile, for the compote, peel, core and cut the apples into 2cm dice. Put the butter and sugar in a medium saucepan and melt together over a medium heat. Cook for 3 mins until the mixture turns to a light caramel. Stir in the apples and cook for 3 mins. Add the blackberries and cinnamon, and cook for 3 mins more. Cover, remove from the heat, then leave for 2-3 mins to continue cooking in the warmth of the pan.\r\nTo serve, spoon the warm fruit into an ovenproof gratin dish, top with the crumble mix, then reheat in the oven for 5-10 mins. Serve with vanilla ice cream.",
    ingredients: [Ingredient(name: "Plain Flour", measurement: "120g")]
)
#Preview {
    MealDetailView(store: Store(initialState: MealDetailReducer.State(meal: meal), reducer: { MealDetailReducer() }))
}
