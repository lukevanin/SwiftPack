import UIKit

///
/// Presenting coordinator
///
/// Creates and presents a view controller when activated
///
class PresentingCoordinator: ActivatingCoordinatorProtocol {
    
    unowned var parent: PresentingCoordinatorProtocol?
    
    final func activate() async throws  {
        let viewController = try makeViewController()
        await parent?.present(viewController: viewController)
    }
    
    func makeViewController() throws -> UIViewController {
        throw CancellationError()
    }
}
