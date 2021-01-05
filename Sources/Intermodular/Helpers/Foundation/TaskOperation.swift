//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow

open class TaskOperation<Base: TaskProtocol>: Operation {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
    
    private var _isCancelled = false {
        willSet {
            willChangeValue(forKey: "isCancelled")
        } didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    open override var isCancelled: Bool {
        _isCancelled
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        } didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    open override var isExecuting: Bool {
        _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        } didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    open override var isFinished: Bool {
        _finished
    }
    
    open override var isAsynchronous: Bool {
        true
    }
    
    open override func start() {
        guard isReady && !isCancelled else {
            return
        }
        
        _executing = true
        
        base.onStatusChange { status in
            switch status {
                case .idle:
                    self._executing = false
                    self._finished = false
                case .started:
                    self._executing = true
                    self._finished = false
                case .canceled:
                    self._executing = false
                    self._finished = false
                case .success:
                    self._executing = false
                    self._finished = true
                case .error:
                    self._executing = false
                    self._finished = true
            }
        }
        
        base.start()
    }
    
    open override func cancel() {
        if base.status == .active {
            base.cancel()
        }
        
        if !_isCancelled {
            _isCancelled = true
        }
    }
    
    private func finish() {
        _executing = false
        _finished = true
    }
}

// MARK: - API -

extension TaskProtocol {
    public func convertToOperation() -> TaskOperation<Self> {
        .init(self)
    }
}

extension Publisher {
    public func convertToOperation() -> TaskOperation<AnyTask<Output, Failure>> {
        convertToTask().convertToOperation()
    }
}

extension AnyProtocol where Self == Operation {
    public init<T: TaskProtocol>(task: T) {
        self = task.convertToOperation()
    }
}

extension AnyProtocol where Self == Operation {
    public init<P: Publisher>(publisher: P) {
        self = publisher.convertToOperation()
    }
}
