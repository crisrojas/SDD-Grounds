# Crear una cola con combine

#review/dev/swift #review/dev/algoritmos #vlabs

Recientemente tuve que implementar un mecanismo en el que las peticiones de red se acumulaban.

El objetivo es que cuando el usuario presiona un elemento para marcarlo/desmarcarlo como terminado, hacemos la petición al servidor, y ponemos en espera todas las demás.

Cuando la petición en curso ha terminado, continuamos con la última de la cola.

Para ello necesitamos 2 variables: una para la petición en curso (`currentTask`) y otra para la cola  (`queue`):

```swift
@Published var currentTask: UUID?
@Published var queue = [UUID]()
```

Por simplificar la explicación, el tipo de este ejemplo va a ser `UUID`.

El siguiente paso es detectar los cambios hechos a esas dos variables:


```swift
private var cancellables = Set<AnyCancellable>()
...
func sink() {
    $currentTask.sink { task in
        print("Task did change")
    }
    .store(in: &cancellables)
    
    $queue.sink { queue in
        print("Queue did change")
    }
}
```

También necesitamos de un método disparador que será llamado cada vez que el usuario marque/desmarque un ítem de la lista:

```swift
func trigger() {
}
```

El algoritmo en pseudocódigo es el siguiente:

1. Cada vez que el usuario marque/desmarque llamamos al método `trigger()`
2. Añadimos la petición a la cola
3. Si la cola tiene un solo elemento, lo asignamos a la variable currentTask
4. Cuando la variable currentTask es definida, lanzamos la petición de red
5. Cuando la petición de red ha terminado, reescribimos la cola dejando únicamente el único elemento
6. Volvemos al paso 2


Y la implementación:

```swift

@Published var currentTask: UUID?
@Published var queue = [UUID]()
private var cancellables = Set<AnyCancellable>()

func sink() {
    $queue.sink { newQueue in
        if newQueue.count == 1 {
            currentTask = newQueue[0]
        }
    }
    .store(in: &cancellables)
    $currentTask.sink { [weak self] task in
      self?.dispatch(task)
    }
    .store(in: &cancellables)
}

func trigger() {
   queue.append(UUID())
}

func dispatch(_ task: UUID) {
    
    // Get index for deleting task from the queue
    // once is done
    if let index = queue.firstIndex(of: item) {
        Task {
            await apiCall(task)
            queue.remove(at: index)
            currentTask = nil
            
            if let last = queue.last {
                queue = [last]
            }
        }
    }
}
```


### Actualización: 

Esta es una implementación más eficiente y ligera:


```swift
@Published var queue = [UUID]()
...
$queue.dropFirst().sink { newQueue in 
    if newQueue.count == 1 {
        dispatch(newQueue)
    }
}

func dispatch(_ newQueue: [UUID]) {
    Task {
        let currentItem = newQueue.first
        await apiCall(currentItem)
        queue.removeFirst()
        resetQueue()
    }
}

func resetQueue() {
    if let lastItem = queue.last {
        queue = [lastItem]
    }
}
```

#review