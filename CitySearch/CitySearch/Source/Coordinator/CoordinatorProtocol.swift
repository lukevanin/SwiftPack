import UIKit

///
/// A generic coordinator.
///
/// Coordinators are responsible for creating and presenting view controllers. They are most commonly used
/// by view controllers to perform navigation actions.
///
protocol CoordinatorProtocol: AnyObject {
    var parent: ContainingCoordinatorProtocol? { get set }
}

///
/// Activating coordinator
///
/// Performs a navigation action when activated.
///
protocol ActivatingCoordinatorProtocol: CoordinatorProtocol {
    
    ///
    /// Activates the route for the coordinator.
    ///
    @MainActor func activate()
}

///
/// Presenting coordinator
///
/// Coordinator that presents view controllers as a popup.
///
protocol PresentingCoordinatorProtocol: CoordinatorProtocol {
    
    ///
    /// Presents the view controller as a popup over the current screen.
    ///
    @MainActor func present(viewController: UIViewController) async
}

///
/// A coordinator that contains other coordinators.
///
protocol ContainingCoordinatorProtocol: PresentingCoordinatorProtocol {
    func add(child coordinator: CoordinatorProtocol)
}
