//
//  Result.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 11/1/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

public extension Result {
    func flatMap<U>(_ transform: (Value) -> Result<U>) -> Result<U> {
        switch self {
        case let .success(val): return transform(val)
        case let .failure(e): return .failure(e)
        }
    }
}
