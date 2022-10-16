//
//  File.swift
//
//
//  Created by yuki on 2022/10/16.
//

public var standardError = FileHandle.standardError

extension FileHandle: TextOutputStream {
    public func write(_ string: String) { self.write(Data(string.utf8)) }
}


