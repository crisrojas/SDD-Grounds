import XCTest
@testable import HTMLParser
import CustomDump

final class HTMLParserTests: XCTestCase {
    var sut = HTMLParser(filterKey: "jkey")
    
    let featuredSection = """
     [
        recipes: [
            { id: 1, title: "Hamburger", desc: "Fresh hamburger" },
            { id: 2, title: "Sushi"    , desc: "Delicious rolls" }
        ],
        categories: [
           {
            id: 1,
            title: "Italian", 
            recipes: [{ id: 1, title: "Carbonara" }]
           },
        ]
     ]
    """

    func test_ParsingHTMLWithNamedElement_OutputsNamedJSON() throws {
        
        let hamburger = HTMLElement(name: "title", content: "Hamburger")
        let sushi     = HTMLElement(name: "title", content: "Sushi")
        let recipes   = HTMLElement(name: "recipes", content: hamburger, sushi)
        let content   = HTMLElement(name: "content", content: .text("Content 3"))
        let expected  = HTMLDocument(elements: recipes, content)
        
        let sample = """
        <html>
        <body>
          <div>
          <div id="div1" jkey-name="recipes">
            <div jkey-name="title" jkey-id="1">Hamburger</div>
            <div jkey-name="title" jkey-id="2">Sushi</div>
          </div>
          </div>
          <div id="div2">Content 2</div>
          <div id="div3" object jkey-name="content">Content 3</div>
        </body>
        </html>
        """
        
        let parsed = try sut.parse(htmlString: sample)
        expectNoDifference(parsed, expected)
    }
}
