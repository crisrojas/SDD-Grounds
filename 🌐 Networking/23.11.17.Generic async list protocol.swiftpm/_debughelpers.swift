//
//  debughelpers.swift
//  Generic async list protocol
//
//  Created by Cristian Felipe Patiño Rojas on 01/04/2024.
//

import Foundation


protocol PrintDebugable {}

func dp(_ msg: Any) {
    #if DEBUG
    print(msg)
    #endif
}

extension PrintDebugable {
    func print() { dp(self) }
}

extension String: PrintDebugable {}
extension Double: PrintDebugable {}
extension Int: PrintDebugable {}
extension Array: PrintDebugable {}
extension Bool: PrintDebugable {}

extension Data {
    func asString() -> String {
        String(decoding: self, as: UTF8.self)
    }
}

extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}
