//
//  AppErrorAction.swift
//  dogether
//
//  Created by yujaehong on 7/6/26.
//

import Foundation

enum AppErrorAction {
    case retry
    case logout
    case alert(AlertTypes)
    case passThrough
    
    static func resolve(for error: Error) -> AppErrorAction {
        if error is URLError || error is DecodingError { return .retry }
        
        guard let error = error as? NetworkError else { return .passThrough }
        
        switch error {
        case .dogetherError(let code, _):
            return resolve(for: code)
        default:
            return .retry
        }
    }
    
    private static func resolve(for code: DogetherCodes) -> AppErrorAction {
        switch code {
        case .ATF0003:
            return .logout
        case .ATF0002:
            return .alert(.needRevoke)
        case .CGF0002:
            return .alert(.alreadyParticipated)
        case .CGF0003:
            return .alert(.fullGroup)
        case .CGF0004, .CGF0005:
            return .alert(.unableToParticipate)
        default:
            return .retry
        }
    }
}
