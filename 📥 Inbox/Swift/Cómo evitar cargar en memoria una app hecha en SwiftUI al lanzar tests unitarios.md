# Cómo evitar cargar en memoria una app hecha en SwiftUI al lanzar tests unitarios
#review/dev/swift

### AppDelegate

```swift
#if DEBUG
        // Short-circuit starting app if running unit tests
        let isUnitTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        guard !isUnitTesting else {
            return true
        }
#endif
```

### SwiftUI

```swift
@main
struct AppLauncher {
    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            <#MyApp#>.main()
        } else {
            TestApp.main()
        }
    }
}

struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Tests")
        }
    }
}

```

#review