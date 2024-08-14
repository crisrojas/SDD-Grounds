import Foundation

class HTMLToJSONParser: NSObject, XMLParserDelegate {
    var currentElement: String = ""
    var currentAttributes: [String: String] = [:]
    var json: [String: Any] = [:]
    var stack: [[String: Any]] = []
    
    func parse(_ data: Data) -> [String: Any]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return json
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentAttributes = attributeDict
        var element: [String: Any] = ["#text": ""]
        for (key, value) in attributeDict {
            element["@\(key)"] = value
        }
        stack.append(element)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if var lastElement = stack.last {
            if let text = lastElement["#text"] as? String {
                lastElement["#text"] = text + string
            } else {
                lastElement["#text"] = string
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let element = stack.popLast() {
            if var lastElement = stack.last {
                if var children = lastElement["children"] as? [[String: Any]] {
                    children.append(element)
                    lastElement["children"] = children
                } else {
                    lastElement["children"] = [element]
                }
            } else {
                json = element
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        // Manejar CDATA si es necesario
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Error de análisis: \(parseError.localizedDescription)")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // No es necesario hacer nada aquí si ya hemos construido la estructura JSON en didEndElement
    }
}

let htmlString = """
<html>
    <head>
        <title>My title</title>
    </head>
    <body>
        <div class="recipe-list">
            <div class="recipe-card" item-id="1"></div>
            <div class="recipe-card" item-id="2"></div>
        </div>
    </body>
</html>
"""

let delegate = HTMLToJSONParser()
if let json = delegate.parse(htmlString.data(using: .utf8)!) {
    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    let stringData = String(data: jsonData, encoding: .utf8)
    print(stringData!)
}
