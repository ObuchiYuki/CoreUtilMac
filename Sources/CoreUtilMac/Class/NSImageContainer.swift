//
//  NSImageContainer.swift
//  
//
//  Created by yuki on 2022/10/16.
//

import AppKit


// Wrap NSImage to be Codable
final public class NSImageContainer: Codable {
    static let dataDirectoryURL = try! FileManager.default.allocTemporaryDirectory("NSImageContainer")
    
    public let image: NSImage
    public let id: String
    
    public init(_ image: NSImage) {
        self.image = image
        self.id = UUID().uuidString
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
        let fileURL = NSImageContainer.dataDirectoryURL.appendingPathComponent(id)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            try image.tiffRepresentation?.write(to: fileURL)
        }
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let id = try container.decode(String.self)
        let fileURL = NSImageContainer.dataDirectoryURL.appendingPathComponent(id)
        guard let image = NSImage(contentsOf: fileURL) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No image"))
        }
        self.image = image
        self.id = id
    }
}
