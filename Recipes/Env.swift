//
//  Env.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import Foundation
import FunNetTCA
import FunNetCore
import ComposableArchitecture

/// This is an older pattern from Brandon and Stephen (creators of TCA). I still find it useful, since
/// it allows you to control dependencies outside of TCA as well.
struct Env {
    @Dependency(\.uuid) var uuid
    
    var session: URLSession
    var baseUrl: URLComponents
    var apiJsonEncoder: JSONEncoder
    var apiJsonDecoder: JSONDecoder
    
    init(session: URLSession = URLSession.shared,
         baseUrl: URLComponents = URLComponents(string: "https://www.themealdb.com/api/json/v1/1/")!,
         apiJsonEncoder: JSONEncoder = JSONEncoder(),
         apiJsonDecoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.baseUrl = baseUrl
        self.apiJsonEncoder = apiJsonEncoder
        self.apiJsonDecoder = apiJsonDecoder
        
        URLCache.shared.memoryCapacity = 1024 * 1024 * 512
        URLCache.shared.diskCapacity = 1_000_000_000
    }
    
    func netState(from endpoint: Endpoint) -> NetCallReducer.State {
        return NetCallReducer.State(session: session, baseUrl: baseUrl, endpoint: endpoint)
    }
    
    func mockNetState(from endpoint: Endpoint, with data: Data, delay: Int = 100) -> NetCallReducer.State {
        return NetCallReducer.State(session: session, baseUrl: baseUrl, endpoint: endpoint, firingFunc: NetCallReducer.mockFire(with: data, delayMillis: delay))
    }
}

var Current = Env()
