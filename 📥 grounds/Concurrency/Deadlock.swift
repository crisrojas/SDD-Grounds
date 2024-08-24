import Foundation


// Operación sincrónica externa
func runTask() {
    DispatchQueue.main.async {
        print("Inicio de la operación externa")
        
        // Intentamos realizar otra operación sincrónica dentro de la misma cola
        DispatchQueue.main.sync {
            print("Esta línea nunca se ejecutará debido al deadlock")
        }
    }
    print("Fin de la operación externa")
}

runTask()
