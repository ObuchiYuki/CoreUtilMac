//
//  main.swift
//  ShareReply
//
//  Created by yuki on 2020/10/28.
//

import Combine
import Foundation

extension Publisher {
    /// UpStreamの値をキャッシュしてDownStreamに流します。
    public func shareReplay() -> ShareReplay<Self> { ShareReplay(upstream: self) }
}

final public class ShareReplay<Upstream: Publisher>: Publisher {

    public typealias Output = Upstream.Output
    public typealias Failure = Upstream.Failure

    private let upstream: Upstream
    private var buffer: Output?
    private var subscriptions = [Inner]()

    public init(upstream: Upstream) {
        self.upstream = upstream
    }

    public func receive<DownStream: Subscriber>(subscriber: DownStream)
    where Failure == DownStream.Failure, Output == DownStream.Input {
        subscriber.receive(subscription: Inner(subscriber, buffer: buffer) => { subscriptions.append($0) })

        guard subscriptions.count == 1 else { return }

        let sub = AnySubscriber<Output, Failure> { $0.request(.unlimited) }
            receiveValue: {[weak self] value in
                self?.buffer = value
                self?.subscriptions.forEach { $0.receive(value) }
                return .none
            }
            receiveCompletion: {[weak self] completion in
                self?.subscriptions.forEach { $0.receive(completion: completion) }
            }

        upstream.subscribe(sub)
    }
}

extension ShareReplay {
    private final class Inner: Subscription {

        typealias Downstream = AnySubscriber<Output, Failure>

        private var buffer: Output?
        private var demand: Subscribers.Demand = .none
        private var downstream: Downstream?

        init<D: Subscriber>(_ downstream: D, buffer: Output?) where Failure == D.Failure, Output == D.Input {
            self.downstream = Downstream(downstream)
            self.buffer = buffer
        }

        func request(_ demand: Subscribers.Demand) {
            self.demand += demand
            _updateDemand()
        }

        func receive(_ input: Output) {
            buffer = input
            _updateDemand()
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            guard let downstream = downstream else { return }

            self.downstream = nil
            self.buffer = nil

            downstream.receive(completion: completion)
        }

        func cancel() { receive(completion: .finished) }

        private func _updateDemand() {
            guard let downstream = downstream else { return }

            if let buffer = buffer, demand > .none {
                demand -= 1
                demand += downstream.receive(buffer)
            }
        }
    }
}
