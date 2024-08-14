# Algoritmo de Euclides
#review/dev/algoritmos

Encuentra el minimo común divisor.

```swift
func gcd(a: Int, b: Int) -> Int {
	var a = abs(a)
	var b = abs(b)
  if b > a { swap(&a, &b) }
  while b > 0 {
    (a, b) = (b, a % b)
  }
  return a
}
```

Ejemplo línea a línea:

```swift
gcd(15, 12)

a = abs(15) // a = 15
b = abs(12) // b = 12

// No se ejecuta porque no es el caso
if b > a { haz algo } 

// Mientras b sea mayor que cero
while b > 0 

  a = b // a = 12
  b = a % b // b = 3

  // b sigue siendo mayor que cero
	// Empieza otra vez el bucle
  a = b // a = 3
  b = a % b // b = 0

  // b ya no es mayor que cero
	// Rompe el bucle
  break

	// devuelve el último valor de a = 3
 return a 
```

#review
