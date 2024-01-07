import SwiftUI

@main
struct MyVisionKitStarterApp: App {
    @StateObject var mainCoordinator = MainCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $mainCoordinator.path) {
                mainCoordinator.getView(page: .home)
                    .navigationDestination(for: Page.self) { page in
                        mainCoordinator.getView(page: page)
                    }
                    .sheet(item: $mainCoordinator.presentationStyle) { _ in
                        mainCoordinator.getView(page: mainCoordinator.page)
                    }
            }
            .environmentObject(mainCoordinator)
        }
    }
}
