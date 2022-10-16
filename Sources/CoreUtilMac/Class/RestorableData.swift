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
        set { self.projectedValue.subject.send(newValue); self.saveValue(value: newValue) }
    }
    
    private func saveValue(value: Value) {
        do { try RestorableDataStatic.encoder.encode(value).write(to: fileURL) } catch {
            // TODO: Handle Error
        }
    }
    
    public init(wrappedValue initialValue: Value, _ key: String, file: String = #fileID, line: UInt = #line) {
        #if DEBUG
        GlobalOneLineChecker.register(label: key, file: file, line: line)
        #endif
        
        self.key = key
        self.fileURL = RestorableDataStatic.restorableDataURL.appendingPathComponent(key + ".json")
        
        let saved = FileManager.default.fileExists(atPath: fileURL.path)
        
        let wrappedValue: Value
        do {
            wrappedValue = try RestorableDataStatic.decoder.decode(Value.self, from: Data(contentsOf: fileURL))
        } catch {
            wrappedValue = initialValue
        }
        
        self.projectedValue = Publisher(wrappedValue)
        
        if !saved {
            saveValue(value: initialValue)
        }
    }
}
