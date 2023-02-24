#if canImport(SwiftUI) && canImport(UIKit)
  import SwiftUI
  import Dependencies

  enum InstalledViewControllerKey: EnvironmentKey {
    static var defaultValue: UIViewController? { nil }
  }

  extension EnvironmentValues {
    public var installedViewController: UIViewController? {
      get { self[InstalledViewControllerKey.self] }
      set { self[InstalledViewControllerKey.self] = newValue }
    }
  }

  extension View {
    public func extractViewControllerAsDependency(id: AnyHashable? = nil) -> some View {
      self.modifier(InstallViewController(id: id))
    }

    public func extractViewControllerAsDependency(id: Any.Type) -> some View {
      self.modifier(InstallViewController(id: ObjectIdentifier(id)))
    }
  }

  struct InstallViewController<ID: Hashable>: ViewModifier {
    let id: ID?

    func body(content: Content) -> some View {
      content
        .background(InstalledViewController(id: id))
    }

    struct InstalledViewController: UIViewControllerRepresentable {
      let id: ID?

      @MainActor
      final class Coordinator {
        lazy var viewController = UIViewController(nibName: nil, bundle: nil)
        let representable: InstalledViewController
        var didCallbackOnce: Bool = false
        var swiftUIEnvironment: SwiftUIEnvironment?
        init(representable: InstalledViewController) {
          self.representable = representable
        }

        func updateDependency(context: Context) {
          self.swiftUIEnvironment = context.environment._swiftuiEnvironment
          self.swiftUIEnvironment?.update(
            self.viewController,
            keyPath: \.installedViewController,
            id: self.representable.id
          )
        }
        
        func onDismantle() {
          self.swiftUIEnvironment?.update(
            nil,
            keyPath: \.installedViewController,
            id: self.representable.id
          )
        }
      }

      func makeCoordinator() -> Coordinator {
        Coordinator(representable: self)
      }

      func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.viewController
      }
      static func dismantleUIViewController(
        _ uiViewController: UIViewController, coordinator: Coordinator
      ) {
        coordinator.onDismantle()
      }

      func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.updateDependency(context: context)
      }
    }
  }
#endif
