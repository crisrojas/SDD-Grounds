
class ClassA {
    deinit {
        print("deinit A")
    }
}

class ClassB {
    var closure: (() -> Void)?
    
    func setup() {
        closure = {
            self.doSomething()
        }
    }
    
    func doSomething() {print("Did something")}
    deinit {print("deinit B")}
}

var classA: ClassA? = ClassA()
classA = nil

var classB: ClassB? = ClassB()
classB?.setup()
classB = nil