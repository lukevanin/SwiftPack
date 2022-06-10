import UIKit

///
/// Creates and presents a view controller constructed with a builder.
///
class BuilderPresentingCoordinator: PresentingCoordinator {
    
    private let builder: AnyBuilder<UIViewController>
    
    init(builder: AnyBuilder<UIViewController>) {
        self.builder = builder
    }
    
    override func makeViewController() throws -> UIViewController {
        try builder.build()
    }
}
