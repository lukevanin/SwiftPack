import UIKit


///
/// Manages view controller navigation.
///
/// Coordinators are responsible for creating and presenting view controllers. They are most commonly used
/// by view controllers to perform navigation actions.
///
protocol ActivatingCoordinatorProtocol: AnyObject {
    
    ///
    /// Activates the route for the coordinator.
    ///
    @MainActor func activate() async throws
}

///
/// Coordinator that presents view controllers as a popup.
///
protocol PresentingCoordinatorProtocol: AnyObject {
    
    ///
    /// Presents the view controller as a popup over the current screen.
    ///
    @MainActor func present(viewController: UIViewController) async
}
