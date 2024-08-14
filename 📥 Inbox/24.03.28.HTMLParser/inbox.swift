import Foundation

class XMLParserManager: NSObject, XMLParserDelegate {
    var jsonResult: [String: Any] = [:]
    var currentElement: String = ""
    var currentAttributes: [String: String] = [:]
    var currentText: String = ""
    
    func parseXML(xmlData: Data) -> [String: Any]? {
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        parser.parse()
        return jsonResult
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentAttributes = attributeDict
        currentText = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if !currentText.isEmpty {
            if var existingValue = jsonResult[currentElement] as? [Any] {
                existingValue.append(currentText)
                jsonResult[currentElement] = existingValue
            } else if let existingValue = jsonResult[currentElement] as? String {
                jsonResult[currentElement] = [existingValue, currentText]
            } else {
                jsonResult[currentElement] = currentText
            }
        } else {
            if let existingValue = jsonResult[currentElement] {
                if var existingArray = existingValue as? [Any] {
                    existingArray.append(currentAttributes)
                    jsonResult[currentElement] = existingArray
                } else {
                    jsonResult[currentElement] = [existingValue, currentAttributes]
                }
            } else {
                jsonResult[currentElement] = currentAttributes
            }
        }
    }
}

let xmlString = """
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

func test() {
    
    if let xmlData = xmlString.data(using: .utf8) {
        let parserManager = XMLParserManager()
        if let jsonResult = parserManager.parseXML(xmlData: xmlData) {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonResult, options: .prettyPrinted) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            }
        }
    }
}