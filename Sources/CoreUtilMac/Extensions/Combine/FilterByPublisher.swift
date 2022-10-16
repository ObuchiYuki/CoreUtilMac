//
//  FilterByPublisher.swift
//  CoreUtil
//
//  Created by yuki on 2021/11/11.
//  Copyright © 2021 yuki. All rights reserved.
//

import Combine

extension Publisher {
    public func filter<P: Combine.Publisher>(by publisher: P) -> AnyPublisher<Self.Output, Self.Failure>
        where P.Output == Bool, P.Failure == Self.Failure
    {
        self.combineLatest(publisher).filter{ _, flag in flag }.map{ $0.0 }.eraseToAnyPublisher()
    }
}

// TODO: More Fast Implementation

//
//extension Publishers {
//    public struct FilterByPublisher<Upstream: Combine.Publisher, Filter: Combine.Publisher>: Combine.Publisher
//        where Upstream.Failure == Filter.Failure, Filter.Output == Bool
//    {
//        public typealias Output = Upstream.Output
//        public typealias Failure = Upstream.Failure
//
//        public let upstream: Upstream
//        public let filter: Filter
//
//        public enum Inputs {
//            case output(Output)
//            case filter(Bool)
//        }
//
//        public func receive<S: Combine.Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
//            let inner = Inner<S>(downstream: subscriber)
//            upstream.map{ .output($0) }.subscribe(inner)
//            filter.map{ .filter($0) }.subscribe(inner)
//        }
//    }
//}
//
//extension Publishers.FilterByPublisher {
//    public final class Inner<Downstream: Combine.Subscriber>: Combine.Subscriber
//        where Downstream.Input == Output, Downstream.Failure == Upstream.Failure
//    {
//
//        public typealias Input = Inputs
//        public typealias Failure = Upstream.Failure
//
//        let downstream: Downstream
//        let subscription = Subscription()
//        
//        var receivedFilter = false
//        var lastFilterValue = false
//        
//        var receivedOutput = false
//        var lastOutputValue: Output?
//
//        init(downstream: Downstream) { self.downstream = downstream }
//
//        public func receive(subscription: Combine.Subscription) {
//            self.subscription.subscriptions.append(subscription)
//            if self.subscription.subscriptions.count == 4 {
//                self.downstream.receive(subscription: self.subscription)
//            }
//        }
//        public func receive(_ input: Input) -> Subscribers.Demand {
//            
//            func checkReceive() {
//                
//            }
//            
//            switch input {
//            case .filter(let flag):
//                self.receivedFilter = true
//                self.lastFilterValue = flag
//            case .output(let output):
//                self.receivedOutput = true
//                self.lastOutputValue = output
//            }
//        }
//        public func receive(completion: Subscribers.Completion<Upstream.Failure>) {
//
//        }
//    }
//
//    final public class Subscription: Combine.Subscription {
//        var subscriptions = [Combine.Subscription]()
//
//        init() { self.subscriptions.reserveCapacity(4) }
//
//        public func request(_ demand: Subscribers.Demand) {
//            for subscription in subscriptions { subscription.request(demand) }
//        }
//        public func cancel() {
//            for subscription in subscriptions { subscription.cancel() }
//        }
//    }
//}
