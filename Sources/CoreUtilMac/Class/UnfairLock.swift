//
//  UnfairLock.swift
//  
//
//  Created by yuki on 2022/10/16.
//

final public class UnfairLock {
    private typealias LockType = UnsafeMutablePointer<os_unfair_lock>
    
    private let unfairLock: LockType
    
    public init() {
        let lock = LockType.allocate(capacity: 1)
        lock.initialize(to: .init())
        self.unfairLock = lock
    }
    
    public func lock() {
        os_unfair_lock_lock(self.unfairLock)
    }
    public func unlock() {
        os_unfair_lock_unlock(self.unfairLock)
    }
    public func assertOwner() {
        os_unfair_lock_assert_owner(self.unfairLock)
    }
    public func assertNotOwner() {
        os_unfair_lock_assert_not_owner(self.unfairLock)
    }

    deinit {
        self.unfairLock.deinitialize(count: 1)
        self.unfairLock.deallocate()
    }
}

