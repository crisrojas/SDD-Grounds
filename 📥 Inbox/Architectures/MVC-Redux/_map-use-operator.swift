// Map then use operator
func ~> <A, B>(map: @escaping (A) -> B, use: @escaping (B) -> Void) -> (A) -> Void {
    return { a in 
        let b = map(a)
        use(b)
    }
}