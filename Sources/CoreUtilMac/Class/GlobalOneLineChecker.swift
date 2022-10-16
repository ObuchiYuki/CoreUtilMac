//
//  GlobalOneLineChecker.swift
//  
//
//  Created by yuki on 2022/10/16.
//


public enum GlobalOneLineChecker {
    static var table = [String: String]()
    static var isEnabled = true
    
    public static func disableChecker() { isEnabled = false }
    public static func enableChecker() { isEnabled = true }
    
    static func register(label: String, file: String, line: UInt) {
#if DEBUG
        guard isEnabled else { return }
        
        let key = "\(file):\(line)"
        assert(table[label] == key, "Should not use same label '\(label)' in other place.")
        table[label] = key
#endif
    }
}
