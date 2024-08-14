//
//  Using csv for persisting data.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 23/11/23.
//

/*
    I read an article from Paul Hudson [^1] about using the URL api for reading lines and I though that it would be cool to have a CSV based data api.
    Of course, it won't be practical for nested objecs, but anyways...
*/
protocol EncodableCSV {
    func encode() -> String
}

protocol DecodableCSV {
    static func decode(data: String) -> Self? 
}

typealias CodableCSV = DecodableCSV & EncodableCSV

final class CSVDecoder {
    func decode<T:DecodableCSV>(_ type: T.Type, from data: String) -> T? {
        type.decode(data: data)
    }
}

final class CSVEncoder {
    func encode<T: EncodableCSV>(_ value: T) -> String { 
        value.encode()
    }
}

// MARK: - Default implementations
/*
    I wasn't brave/skilled enough to implement this, but [this guy was](https://github.com/dehesa/CodableCSV)
*/
extension DecodableCSV {
    func decode(data: String) -> Self? {nil}
}

extension EncodableCSV {
    func encode() -> String {
        let mirror = Mirror(reflecting: self)
        let propertyValues = mirror.children.map { (label: String?, value: Any) in
            return "\(value)"
        }
        return propertyValues.joined(separator: ",")
    }
}


/*
[^1]: https://www.hackingwithswift.com/articles/241/how-to-fetch-remote-data-the-easy-way-with-url-lines
*/