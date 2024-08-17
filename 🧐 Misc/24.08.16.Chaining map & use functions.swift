
struct A { let value: String }
struct B { let value: String }

func map(_ a: A) -> B {B(value: a.value)} // (A) -> B
func use(_ b: B) -> Void {print(b.value)} // (B) -> Void

func fetch(id: String, completion: @escaping (A) -> Void) { 
    completion(A(value: "Item fetched, id: \(id) "))
}

func ~> (map: @escaping (A) -> B, use: @escaping (B) -> Void) -> (A) -> Void {
    return { a in 
        let b = map(a)
        use(b)
    }
}

fetch(id: "Some id", completion: map ~> use)