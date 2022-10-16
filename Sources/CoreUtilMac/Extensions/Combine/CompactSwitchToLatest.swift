//
//  CompactSwitchToLatest.swift
//  CoreUtil
//
//  Created by yuki on 2021/11/19.
//  Copyright © 2021 yuki. All rights reserved.
//

import Combine

extension Publisher where Failure == Never {
    public func involveSwitchToLatest<T: Publisher>() -> AnyPublisher<T.Output?, Never>
        where Self.Output == Optional<T>, T.Failure == Never
    {
        self
            .map{
                $0?.map{ Optional.some($0) }.eraseToAnyPublisher() ?? Just(nil).eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

