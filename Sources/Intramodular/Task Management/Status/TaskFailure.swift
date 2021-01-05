//
// Copyright (c) Vatsal Manot
//

import Swift

/// The failure of a task.
public enum TaskFailure<Error: Swift.Error>: Swift.Error {
    case canceled
    case error(Error)
}

// MARK: - Protocol Conformances -

extension TaskFailure: Equatable where Error: Equatable {
    
}

extension TaskFailure: Hashable where Error: Hashable {
    
}

// MARK: - Helpers -

extension Subscribers.Completion {
    public static func failure<Error>(
        _ error: Error
    ) -> Self where Failure == TaskFailure<Error> {
        .failure(.error(error))
    }
}
