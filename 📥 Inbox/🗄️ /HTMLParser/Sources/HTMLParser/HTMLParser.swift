// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftSoup

struct HTMLDocument: Equatable {
    var elements: [HTMLElement] = []
}

extension HTMLDocument {
    
    init(elements: HTMLElement...) {
        self.elements = elements
    }
}

struct HTMLElement: Equatable {
    
    enum Content: Equatable {
        case children([HTMLElement])
        case text(String)
    }
    
    let name: String
    let content: Content
}

extension HTMLElement {
    init(name: String, content: String) {
        self.name = name
        self.content = .text(content)
    }
    
    init(name: String, content: [HTMLElement]) {
        self.name = name
        self.content = .children(content)
    }
    
    init(name: String, content: HTMLElement...) {
        self.name = name
        self.content = .children(content)
    }
}

final class HTMLParser {
    let filterKey: String
    
    var nameAttribute: String {
        filterKey + "-name"
    }
    
    var idAttribute: String {
        filterKey + "-id"
    }
    
    init(filterKey: String) {
        self.filterKey = filterKey
    }
    
    func parse(htmlString: String) throws -> HTMLDocument {
        HTMLDocument()
    }
}

extension Element {
    func hasChildren() -> Bool { !children().isEmpty() }
}

extension Document {
    func parse(filterBy nameAttribute: String) throws -> [String: Any] {
        let elements = try self.select("*[\(nameAttribute)]")
        var dict = [String: Any]()
        
        for element in elements.array().reversed() {
            let name  = try element.attr(nameAttribute)
            let value = try element.text()

            if element.hasChildren() {
                var childDicts = [[String: Any]]()
                for child in element.children().filter({ $0.hasAttr(nameAttribute) }) {
                    let childName  = try child.attr(nameAttribute)
                    let childValue = try child.text()
                    let childDict  = [childName: childValue]
                    childDicts.append(childDict)
                }
                dict[name] = childDicts
            } else {
                if element.parent() == nil || element.parent() == body() {
                    dict[name] = value
                }
            }
        }
        
        return dict
    }
}

