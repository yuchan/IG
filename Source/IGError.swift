//
//  IGError.swift
//  IG
//
//  Created by Ohashi, Yusuke a | Mike | ECMD on 2018/03/30.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

public enum IGError: Error {
    case unknown
    case invalidToken
}

extension IGError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidToken:
            return NSLocalizedString("Token is empty or invalid. Please autorize account again.", comment: "")
        default:
            return NSLocalizedString("Something is wrong.", comment: "")
        }
    }
    public var failureReason: String? {
        switch self {
        case .invalidToken:
            return NSLocalizedString("Token is empty or invalid.", comment: "")
        default:
            return NSLocalizedString("Something is wrong.", comment: "")
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .invalidToken:
            return NSLocalizedString("Please autorize account again.", comment: "")
        default:
            return NSLocalizedString("Try again", comment: "")
        }
    }
}
