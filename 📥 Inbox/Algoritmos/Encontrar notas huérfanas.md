# Encontrar notas huérfanas
#review/dev/algoritmos 

```swift
var orphans = [String]()
for page in pages {
    let filename = page.filename
    var count = 0
    for page in pages {
        if page.conent.contains(filename!) {
            count += 1
        }
    }
    if count == 0 {
            orphans.append(filename!)
     }
}
```

#review