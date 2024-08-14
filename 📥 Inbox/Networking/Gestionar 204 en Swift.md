# Gestionar 204 en Swift
#review/dev/swift

```swift
// MARK: - OrdersResponse
struct OrdersResponse {
    let orders: [Order]
}

extension OrdersResponse: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case orders
    }

    init(from decoder: Decoder) throws {

        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            orders = []
            return
        }
        
        orders = (try container.decodeIfPresent([Order].self, forKey: .orders)) ?? []
    }
}
```

#review