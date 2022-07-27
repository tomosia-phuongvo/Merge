//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

/// An `os_unfair_lock` wrapper.
public final class OSUnfairLock: Initiable, Sendable, TestableLock {
    @usableFromInline
    let base: os_unfair_lock_t
    
    public init() {
        base = .allocate(capacity: 1)
        base.initialize(to: os_unfair_lock())
    }

    @inlinable
    public func acquireOrBlock() {
        os_unfair_lock_lock(base)
    }

    @usableFromInline
    enum AcquisitionError: Error {
        case failedToAcquireLock
    }
    
    @inlinable
    public func acquireOrFail() throws {
        let didAcquire = os_unfair_lock_trylock(base)
        
        if !didAcquire {
            throw AcquisitionError.failedToAcquireLock
        }
    }

    @inlinable
    public func relinquish() {
        os_unfair_lock_unlock(base)
    }
    
    deinit {
        base.deinitialize(count: 1)
        base.deallocate()
    }
}
