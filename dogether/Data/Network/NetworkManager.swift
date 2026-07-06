//
//  NetworkManager.swift
//  dogether
//
//  Created by seungyooooong on 1/27/25.
//

import Foundation

final class NetworkManager: Sendable {
    static let shared = NetworkManager()
    private init() { }

    func request<T: Decodable>(_ endpoint: NetworkEndpoint) async throws -> T {
        let response: ServerResponse<T> = try await NetworkService.shared.request(endpoint)

        if T.self == EmptyData.self { return EmptyData() as! T }

        guard let data = response.data else {
            if let dogetherCode = DogetherCodes(rawValue: response.code) {
                throw NetworkError.dogetherError(code: dogetherCode, message: response.message)
            } else { throw NetworkError.unknown }
        }

        return data
    }
    
    func request(_ endpoint: NetworkEndpoint) async throws -> Void {
        let _: EmptyData = try await request(endpoint)
    }
}
