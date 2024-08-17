
func isUnitTesting() -> Bool {
    let env = ProcessInfo.processInfo.environment
    let hasEnvTestConfigFile = env["XCTestConfigurationFilePath"] != nil
    let isXCTestCaseAvailable = NSClassFromString("XCTestCase") != nil
    // Not usre if double checking both variables is really needed, but anyways:
    return isXCTestCaseAvailable || hasEnvTestConfigFile
}



print(isUnitTesting())

// MARK: - UIKit
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        #if DEBUG 
        guard !isUnitTesting() else { return true }
        #endif
        
        makeWindow()
        return true
    }
    
    func makeWindow() {}
}


// MARK: - SwiftUI
import SwiftUI

struct AppLauncher {
    static func main() throws {
        if isUnitTesting() {
            MyApp.main()
        } else {
            TestApp.main()
        }
    }
}

struct MyApp: App {
    var body: some Scene {
        WindowGroup { Text("App") }
    }
}

struct TestApp: App {
    var body: some Scene {
        WindowGroup { Text("Tests") }
    }
}


