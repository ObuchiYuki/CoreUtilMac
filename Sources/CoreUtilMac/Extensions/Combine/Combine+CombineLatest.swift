//
//  CombineLatest++.swift
//  CoreUtil
//
//  Created by yuki on 2020/09/24.
//  Copyright © 2020 yuki. All rights reserved.
//

import Combine

extension Publisher {
    public func combineLatest<P, Q, R, S>(
        _ publisher1: P, _ publisher2: Q, _ publisher3: R, _ publisher4: S
    ) -> Publishers.Map<Publishers.CombineLatest<
                            Publishers.CombineLatest4<Self, P, Q, R>, S>, (Self.Output, P.Output, Q.Output, R.Output, S.Output)> // swiftlint:disable:this large_tuple
    where
        Self.Failure == P.Failure,
        P: Publisher, Q: Publisher, R: Publisher, S: Publisher {
        self.combineLatest(publisher1, publisher2, publisher3)
            .combineLatest(publisher4)
            .map { com0, com1 in
                (com0.0, com0.1, com0.2, com0.3, com1)
            }
    }

    public func combineLatest<P, Q, R, S, T>(
        _ publisher1: P, _ publisher2: Q, _ publisher3: R, _ publisher4: S, _ publisher5: T
    ) -> Publishers.Map<Publishers.CombineLatest3<
                            Publishers.CombineLatest4<Self, P, Q, R>, S, T>, (Self.Output, P.Output, Q.Output, R.Output, S.Output, T.Output)> // swiftlint:disable:this large_tuple
    where
        Self.Failure == P.Failure,
        P: Publisher, Q: Publisher, R: Publisher, S: Publisher, T: Publisher {
        self.combineLatest(publisher1, publisher2, publisher3)
            .combineLatest(publisher4, publisher5)
            .map { com0, com1, com2 in
                (com0.0, com0.1, com0.2, com0.3, com1, com2)
            }
    }

    public func combineLatest<P, Q, R, S, T, U>(
        _ publisher1: P, _ publisher2: Q, _ publisher3: R, _ publisher4: S, _ publisher5: T, _ publisher6: U
    ) -> Publishers.Map<Publishers.CombineLatest4<
                            Publishers.CombineLatest4<Self, P, Q, R>, S, T, U>, (Self.Output, P.Output, Q.Output, R.Output, S.Output, T.Output, U.Output)> // swiftlint:disable:this large_tuple
    where
        Self.Failure == P.Failure,
        P: Publisher, Q: Publisher, R: Publisher, S: Publisher, T: Publisher, U: Publisher {
        self.combineLatest(publisher1, publisher2, publisher3)
            .combineLatest(publisher4, publisher5, publisher6)
            .map { com0, com1, com2, com3 in
                (com0.0, com0.1, com0.2, com0.3, com1, com2, com3)
            }
    }
}
