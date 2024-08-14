func assert(_ condition: Bool, _ desc: String, line: UInt = #line) {
    let result = condition ? "✅" : "❌"
    print(line.description + " " + result + " " + desc)
}