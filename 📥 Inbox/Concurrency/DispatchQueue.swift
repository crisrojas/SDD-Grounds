final class SimpleDispatchQueue {
	private var tasks = [() -> Void]()
	private var isBusy = false
	let label: String
	
	init(label: String) {
		self.label = label
	}
	
	func async(_ task: @escaping () -> Void) {
		tasks.append(task)
		processTask()
	}
	
	func sync(_ task: @escaping () -> Void) {
		if isBusy {
			print("🛑 Queue is busy. Waiting...")
			async {
				self.sync(task)
			}
		} else {
			print("✅ Queue is free. Running...")
			run(task)
		}
	}
}

extension SimpleDispatchQueue {
	
	private func run(_ task: () -> Void) {
		isBusy = true
		print("📥 Executing task")
		task()
		isBusy = false
	}
	
	 private func processTask() {
		while !tasks.isEmpty {
			let task = tasks.removeFirst()
			run(task)
		}
	}
}

let queue = SimpleDispatchQueue(label: "My queue")

// When we call sync inside async, wel'll call again sync multiple times because queue will be flagged as busy.
/*
2.	El Problema con sync Dentro de async:
	•	Cuando sync es llamado dentro de async, se está llamando de nuevo a sync mientras la cola ya está ocupada. Esta llamada se agrega a la cola, pero porque sync está esperando que run complete, y run no puede completarse porque está esperando que sync se complete, se forma un ciclo de espera.
	•	isBusy en la llamada a sync dentro de async asegura que sync no se ejecuta hasta que la cola esté libre, pero la cola está esperando que sync se complete para liberar el hilo, creando un deadlock.
	3.	Ejemplo de Deadlock:
	•	Primera Tarea: queue.async añade “Task 1” a la cola y llama a processTask, que ejecuta “Task 1”.
	•	Dentro de “Task 1”: Se llama a queue.sync para ejecutar una nueva tarea.
	•	queue.sync: Verifica si isBusy es true (porque Task 1 está ejecutándose) y añade la tarea sync a la cola a través de async.
	•	Espera Cíclica: La tarea sync en la cola espera que la cola esté libre, pero no puede continuar porque la cola está esperando que la tarea sync se complete. Esto crea una espera cíclica y el deadlock.
*/
queue.async {
	print("Task 1")
	print("🤡 Lets trigger a deadlock")
	queue.sync {
		print("You'll never read this on the console buddy")
	}
}
