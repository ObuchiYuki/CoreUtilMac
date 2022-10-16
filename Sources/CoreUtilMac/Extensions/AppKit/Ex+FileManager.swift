//
//  File.swift
//  
//
//  Created by yuki on 2022/10/16.
//

extension FileManager {
    public static let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.noname.app")
    
    public func allocTemporaryDirectory(_ directoryName: String) throws -> URL {
        let url = FileManager.temporaryDirectoryURL.appendingPathComponent(directoryName)
        var isDirectory: ObjCBool = false
        if !self.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            try self.createDirectory(at: url, withIntermediateDirectories: true)
        } else if !isDirectory.boolValue {
            throw NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: ["Reason": "File already exists, but not directory."])
        }
        return url
    }
}
