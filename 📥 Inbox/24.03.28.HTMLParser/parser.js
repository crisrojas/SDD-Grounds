function parseHTMLToJSON(htmlString) {
    // Crear un nuevo DOMParser
    const parser = new DOMParser();
    // Parsear la cadena HTML a un documento DOM
    const doc = parser.parseFromString(htmlString, 'text/html');
    // Llamar a la función recursiva para convertir el documento DOM a JSON
    return elementToJSON(doc.body);
}

function elementToJSON(element) {
    // Crear el objeto JSON base para el elemento
    const json = {
        type: element.tagName.toLowerCase(),
        attributes: {},
        content: []
    };

    // Agregar atributos al objeto JSON
    for (let i = 0; i < element.attributes.length; i++) {
        const attr = element.attributes[i];
        json.attributes[attr.name] = attr.value;
    }

    // Procesar el contenido del elemento
    for (let i = 0; i < element.childNodes.length; i++) {
        const child = element.childNodes[i];
        if (child.nodeType === Node.TEXT_NODE) {
            // Si el nodo es un texto, agregarlo directamente al contenido
            json.content.push(child.textContent);
        } else if (child.nodeType === Node.ELEMENT_NODE) {
            // Si el nodo es un elemento, convertirlo a JSON y agregarlo al contenido
            json.content.push(elementToJSON(child));
        }
    }

    return json;
}

// Ejemplo de uso
const htmlString = `
<div class="container">
    <ul>
        <li>Hello <strong>World</strong></li>
    </ul>
</div>
`;

const json = parseHTMLToJSON(htmlString);
console.log(json);
