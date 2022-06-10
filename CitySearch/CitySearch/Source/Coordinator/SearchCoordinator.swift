import UIKit

final class CitySearchCoordinator: AnyCoordinator, SearchViewControllerDelegate {
    
    func selectItem(item: City) {
        let builder = MapModuleBuilder(city: item)
        let viewController = builder.build()
        Task { [weak self] in
            await self?.present(viewController: viewController)
        }
    }
}
