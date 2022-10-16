//
//  RestorableData.swift
//  CoreUtil
//
//  Created by yuki on 2022/02/03.
//

import Cocoa
import Combine

private enum RestorableDataStatic {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    static let restorableDataURL = try! FileManager.default.allocTemporaryDirectory("RestorableData")
}

// Save Codable value as state
@propertyWrapper
public struct RestorableData<Value: Codable> {
    public struct Publisher: Combine.Publisher {
        public typealias Output = Value
        public typealias Failure = Never
        
        let subject: CurrentValueSubject<Value, Never>
        
        init(_ value: Value) { self.subject = CurrentValueSubject(value) }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Self.Failure, S.Input == Self.Output {
            self.subject.receive(subscriber: subscriber)
        }
    }
    
    public let projectedValue: Publisher
    public let key: String
    public let fileURL: URL
    
    public var wrappedValue: Value {
        get { self.projectedValue.subject.value }
        set {
            self.projectedValue.subject.send(newValue)
            do { try RestorableDataStatic.encoder.encode(newValue).write(to: fileURL) } catch {
                // TODO: Handle Error
            }
        }
    }
    
    public init(wrappedValue initialValue: Value, _ key: String, file: String = #fileID, line: UInt = #line) {
        #if DEBUG
        GlobalOneLineChecker.register(label: key, file: file, line: line)
        #endif
        
        self.key = key
        self.fileURL = RestorableDataStatic.restorableDataURL.appendingPathComponent(key + ".json")
                
        let wrappedValue: Value
        do {
            wrappedValue = try RestorableDataStatic.decoder.decode(Value.self, from: Data(contentsOf: fileURL))
        } catch {
            wrappedValue = initialValue
        }
        
        self.projectedValue = Publisher(wrappedValue)
    }
}
