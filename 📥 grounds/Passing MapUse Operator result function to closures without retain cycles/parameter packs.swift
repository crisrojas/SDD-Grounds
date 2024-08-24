
//struct Request<T> {}
//func query<each Payload>(_ items: repeat Request<each Payload>) -> (repeat each Payload) {
//	fatalError("@todo")
//}
//
//_ = query(Request<Int>(), Request<String>())

typealias Function<T> = (T) -> Void
func fetch0(onDone: @escaping Function<String>) {}
func fetch1(id: String, onDone: @escaping Function<String>) {}
func fetch2(id: String, force: Bool, onDone: @escaping Function<String>) {}
func fetch3(category: String, pageLimit: Int?, onDone: @escaping Function<Int>) {}

func handle<each P, R>(_ fetch: (repeat each P, Function<R>) -> Void) {
	print(type(of:fetch))
}

handle(fetch0)
handle(fetch1)
handle(fetch2)
handle(fetch3)
