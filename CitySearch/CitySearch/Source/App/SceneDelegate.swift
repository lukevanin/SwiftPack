import UIKit
import OSLog

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "scene-delegate"
)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var coordinator: ActivatingCoordinatorProtocol?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            logger.error("Cannot initialize application. Missing window scene.")
            return
        }
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        let builder = ApplicationCoordinatorBuilder(windowScene: windowScene)
        do {
            coordinator = try builder.build()
        }
        catch {
            logger.error("Cannot initialize application. \(error.localizedDescription)")
        }
        coordinator?.activate()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
