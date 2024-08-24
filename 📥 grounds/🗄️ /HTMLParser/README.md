# HTLML Parser

### ¿Es esto útil realmente?

Argumentos en contra:

- Si quiero parsear una página web en una estructura tipo json, y esa página se presta a la conversión y es relativamente fácil, es porque probablemente ese html ya se esté generando a partir de un json. Por tanto, es muy probable que exita ya una api json que consumir
- ¿Qué tipo de webs los clientes suelen querer convertir en webapps?
- ¿Qué tipo de información se suele mostrar en una webapp / app? Listas con elementos y detalles de un elemento.


### Goal
The goal of this playground is to experiment with a way of consuming html as we usually would consume JSON.
So idea is to be able to turn websites or webapps (hypermedia-apis) into high quality apps without minimal changes
on the server side.
 
So we can turn this:

```
 <html>
 <body>
   <div>
   <div id="div1" name="recipes">
     <div item>
        <div name="id" style="display:none">1</id>
        <div name="title">Hamburger</div>
        <div name="description">Fresh hamburger with chicken, salad, tomatoes</div>
    </div>
     <div item>
        <div name="id" style="display:none">1</id>
        <div name="title">Sushi rolls</div>
        <div name="description">Delicious salmon avocado sushi rolls</div>
    </div>
   </div>
   </div>
   <div id="div2">This will be ignored</div>
   <div id="div3" name="content">This will be parsed</div>
 </body>
 </html>
 ```
 
 Into a consommable data structure (being a json string or a swift dict [String: Any]) :
 
 ```
 [
    "recipes": [
        { "id": 1, "title": "Hamburger", "description": "Fresh hamburger with chicken, salad, tomatoes" },
        { "id": 2, "title": "Sushi", "description": "Delicious salmon avocado sushi rolls" }
    ],
    "content": "This will be parserd"
 ]
 ```
 
 Then you could deserialize to a JSON structure:
 
 ```swift
 struct ContentView: View {
     @State var data = JSON()
     var body: some View {
         VStack {
             ForEach(data.recipes.arrayValue, id: \.title) { item in
                 Text(item.title)
             }
         }
         .padding()
         .onAppear(perform: parseb)
    }
 }
```
