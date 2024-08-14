import Foundation

print("Please don't trigger from a folder with emojis in its name !!!")

//let url = URL(string: "file://" + FileManager.default.currentDirectoryPath)!.appendingPathComponent("response.html")
//let doc = try XMLDocument(contentsOf: url, options: .documentTidyHTML)
//dump(doc.documentContentKind.rawValue == 1)

import Foundation

extension Encodable {
    var prettyPrintedJSONString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}


//public enum Node {
//  case comment(String)
//  case doctype(String)
//  indirect case element(String, [(key: String, value: String?)], Node)
//  indirect case fragment([Node])
//  case raw(String)
//  case text(String)
//}

struct Attribute: Codable {
    let key: String
    let value: String
}

final class Node: Codable {
    var tagName: String
    var attributes: [Attribute]
    var children = [Node]()
    var parent: Node?
    var foundCharacters: String?
    
    init(tagName: String, attributes: [Attribute], children: [Node], foundCharacters: String?, parent: Node?) {
        self.tagName = tagName
        self.attributes = attributes
        self.children = children
        self.parent = parent
    }
}

class MyHTMLParser: NSObject, XMLParserDelegate {
    var tree: Node?
    var currentNode: Node?
    
    func parseHTML(htmlString: String) {
        let data = htmlString.data(using: .utf8)!
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let attributes = attributeDict.map { Attribute(key: $0.key, value: $0.value) }
        
        let node = Node(tagName: elementName, attributes: attributes, children: [], foundCharacters: nil, parent: nil)
        
        // Si el nodo actual existe, añade el nuevo nodo a sus hijos y establece el nodo actual como el padre del nuevo nodo
        if let currentNode = currentNode {
            self.currentNode!.children.append(node)
            node.parent = currentNode
        } else {
            // Si no hay un nodo actual, este es el nodo raíz
            tree = node
        }
        
        // Establece el nuevo nodo como el nodo actual
        currentNode = node
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let currentTag = currentNode?.tagName, currentTag == elementName {
            // En lugar de añadir el nodo actual al árbol, establece el nodo actual al nodo padre
            currentNode = currentNode?.parent
        }
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Asegúrate de que el nodo actual no sea nil y que la cadena no esté vacía o solo contenga espacios en blanco
        if let currentNode = currentNode, !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Si el nodo actual ya tiene caracteres, concatena la nueva cadena
            if let existingCharacters = currentNode.foundCharacters {
                currentNode.foundCharacters = existingCharacters + string
            } else {
                // Si no hay caracteres existentes, asigna la nueva cadena
                currentNode.foundCharacters = string
            }
        }
    }
    
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error: \(parseError.localizedDescription)")
    }
}


let parser = MyHTMLParser()
let htmlString = """
<html>
<head>
    <title>My title</title>
</head>
<body>
    <h1 class="title" data-text="main-title">Hello world</h1>
    <vstack>some items</vstack>
</body>
</html>
"""
let htmlString2 = """
<html>
    <head>
        <title>Test</title>
    </head>
    <body>
        <ul type="object" name="recipes" class="someclass">
            <li type="object"><p type="property" name="title">Hamburger</p><p type="property" name="description">Crispy chicken burger</p></li>
            <li type="object"><p type="property" name="title">Sushi</p><p type="property" name="description">Maki sushir</p></li>
        </ul>
    </body>
</html>
"""

let data: Data? = try? FileHandler.read("response.html")
let string = String(decoding: data ?? Data(), as: UTF8.self)
parser.parseHTML(htmlString: string)
dump(parser.tree)
