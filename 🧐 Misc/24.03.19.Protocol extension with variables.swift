import Foundation
import ObjectiveC.runtime

protocol Identifiable: AnyObject {
    var name: String { get set }
}

var IdentifiableIdKey   = "kIdentifiableIdKey"
var IdentifiableNameKey = "kIdentifiableNameKey"

// https://stackoverflow.com/questions/38885622/swift-protocol-extensions-property-default-values

fileprivate var identifiableProtocolLock = NSLock()
extension Identifiable {
        
    var name: String {
        get {
            identifiableProtocolLock.lock()
            defer { identifiableProtocolLock.unlock() }
            return (objc_getAssociatedObject(self, &IdentifiableNameKey) as? String) ?? "default"
        }
        set {
            identifiableProtocolLock.lock()
            defer { identifiableProtocolLock.unlock() }
            objc_setAssociatedObject(self, &IdentifiableNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }   
    }
}

class A: Identifiable {}

var a = A()
print(a.name)  // default

let queue = DispatchQueue(
    label: "com.example.counterQueue", 
    attributes: .concurrent
)

// Incrementar el contador 1000 veces en múltiples hilos simultáneamente
for int in 0..<1000 {
    queue.async {
        a.name += int.description
    }
}

sleep(1)
print(a.name)