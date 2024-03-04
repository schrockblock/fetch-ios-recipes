//
//  MealCardView.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import SwiftUI
import ComposableArchitecture

struct MealCardView: View {
    let store: StoreOf<MealItemReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Button(action: {
                    viewStore.send(.didTap)
                }) {
                    ZStack {
                        if let imgData = viewStore.imgData, let uiImage = UIImage(data: imgData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: maxImageHeight)
                                .clipShape(Rectangle())
                        }
                        VStack {
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(viewStore.name).foregroundStyle(Color.white)
                            }
                            .padding(EdgeInsets(top: margin/2, leading: margin/4, bottom: margin/2, trailing: margin/4))
                            .frame(maxWidth: .infinity)
                            .background(Color(white: 0, opacity: 0.7))
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(margin/2, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    .padding(margin/2)
                    .shadow(color: .gray, radius: 4, x: 4, y: 4)
                }
            }
            .onAppear {
                if viewStore.imgData == nil {
                    viewStore.send(.didAppear)
                }
            }
            /// If the view has already appeared, but is reused for a new meal,
            /// then onAppear won't be called. We have to detect the new meal
            /// in the state and then call `.didAppear`.
            .onChange(of: viewStore.state) {
                if viewStore.imgData == nil {
                    viewStore.send(.didAppear)
                }
                
            }
        }
    }
}

#Preview {
    MealCardView(store: Store(initialState: Meal(
        id: "1",
        name: "Apple & Blackberry Crumble",
        imgUrl: "https://www.themealdb.com/images/media/meals/xvsurr1511719182.jpg"
    ),
                              reducer: { MealItemReducer() }))
}
