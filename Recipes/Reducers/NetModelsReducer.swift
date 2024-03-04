//
//  NetModelsReducer.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import Foundation
import ComposableArchitecture
import FunNetCore
import FunNetTCA
import ErrorHandling

/// This reducer allows us to easily load lists of models. This is adapted from a standard implementation
/// I have of it that also handles pagination, searching, and filtering by additional properties – but to cut
/// down on the LOC you have to review, I have simplified it to its current form.

public typealias ModelType = Decodable & Equatable

@Reducer
public struct NetModelsReducer<Model: ModelType, Wrapper: Decodable> {
    @ObservableState
    public struct State: Equatable {
        /// manual equatable conformance because of the function type `unwrap`
        public static func == (lhs: NetModelsReducer<Model, Wrapper>.State, rhs: NetModelsReducer<Model, Wrapper>.State) -> Bool {
            return lhs.modelsCallState == rhs.modelsCallState
            && lhs.alert == rhs.alert
        }
        
        var modelsCallState: NetCallReducer.State
        
        var unwrap: ((Wrapper) -> [Model]?)?
        
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    public enum Action: Equatable {
        case refresh
        
        case modelsCall(NetCallReducer.Action)
        
        case alert(PresentationAction<Alert>)
        public enum Alert: Equatable, Sendable {}
        
        case delegate(Delegate)
        public enum Delegate: Equatable {
            case didUpdateModels([Model])
        }
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.modelsCallState, action: /NetModelsReducer.Action.modelsCall, child: NetCallReducer.init)
        Reduce { state, action in
            switch action {
            case .refresh:
                return .send(.modelsCall(.refresh))
            case .modelsCall(.delegate(.responseData(let data))):
                if let unwrap = state.unwrap {
                    if let wrapper = try? Current.apiJsonDecoder.decode(Wrapper.self, from: data), let models = unwrap(wrapper) {
                        return .send(.delegate(.didUpdateModels(models)))
                    }
                } else if let models = try? Current.apiJsonDecoder.decode([Model].self, from: data) {
                    return .send(.delegate(.didUpdateModels(models)))
                }
            case .modelsCall(.delegate(.error(let error as NSError))):
                var allErrors = urlLoadingErrorCodesDict
                allErrors.merge(urlResponseErrorMessages, uniquingKeysWith: { _, second in second })
                if let message = allErrors[error.code] {
                    state.alert = AlertState { TextState("Error: \(error.code)") } actions: {} message: {
                        TextState(message)
                    }
                }
            case .modelsCall(_): break
            case .alert(_): break
            case .delegate(_): break
            }
            return .none
        }
    }
}
