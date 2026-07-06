//
//  AppInfoProtocol.swift
//  dogether
//
//  Created by seungyooooong on 7/1/25.
//

import Foundation

protocol AppInfoProtocol: Sendable {
    func checkUpdate(appVersion: String) async throws -> Bool
}
