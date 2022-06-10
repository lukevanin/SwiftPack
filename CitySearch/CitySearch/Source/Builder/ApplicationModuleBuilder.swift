import UIKit

struct ApplicationModuleBuilder: BuilderProtocol {
    
    func build() -> UIViewController {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("test") {
            // We are running under developmenu or automated or testing
            // conditions. Use the testing module.
            let builder = TestSearchModuleBuilder()
            return builder.build()
        }
        else {
            // Use the production module.
            let builder = SearchModuleBuilder()
            return builder.build()
        }
    }
}
