import UIKit

///
/// Presenting coordinator
///
/// Creates and presents a view controller when activated
///
class PresentingCoordinator: AnyCoordinator, ActivatingCoordinatorProtocol {
    
    var errorHandler: ((Error) -> Void)?
    
    final func activate()  {
        let viewController: UIViewController
        do {
            viewController = try makeViewController()
        }
        catch {
            errorHandler?(error)
            return
        }
        Task {
            await parent?.present(viewController: viewController)
        }
    }
    
    func makeViewController() throws -> UIViewController {
        throw CancellationError()
    }
}
