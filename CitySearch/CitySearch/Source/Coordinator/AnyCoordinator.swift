import UIKit

///
/// Containing coordinator
///
/// Contains child coordinators
///
class AnyCoordinator: ContainingCoordinatorProtocol {
    
    weak var parent: ContainingCoordinatorProtocol?
    
    private var coordinators = [CoordinatorProtocol]()
    
    func add(child coordinator: CoordinatorProtocol) {
        precondition(coordinator.parent == nil)
        // TODO: Remove from parent
        coordinator.parent = self
        coordinators.append(coordinator)
    }
    
    func present(viewController: UIViewController) async {
        await parent?.present(viewController: viewController)
    }
}
