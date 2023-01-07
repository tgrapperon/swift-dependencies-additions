import SwiftUI

struct NavigationButtonStyle_Previews: PreviewProvider {
  struct NavigationButtonStyle: View {
    @State var path: [Int] = []
    var body: some View {
      NavigationStack(path: $path) {
        List {
          NavigationLink("Navigation", value: 42)
          Button("Button") {
            path.append(55)
          }
          .buttonStyle(.navigation)
        }
        .navigationDestination(for: Int.self) {
          Text("\($0)")
        }
        .listStyle(.sidebar)
      }
    }
  }
  static var previews: some View {
    NavigationButtonStyle()
  }
}

extension ButtonStyle where Self == NavigationButtonStyle {
  public static var navigation: NavigationButtonStyle { .init() }
}

public struct NavigationButtonStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    NavigationLink {
    } label: {
      configuration.label
    }.background(
      ListRowInteractor(
        isSelected: configuration.isPressed
      )
    )
  }

  #if os(iOS)
    struct ListRowInteractor: UIViewRepresentable {
      let isSelected: Bool

      func makeUIView(context: Context) -> CollectionViewCellFinder {
        CollectionViewCellFinder()
      }

      func updateUIView(_ uiView: CollectionViewCellFinder, context: Context) {
        uiView.setSelected(isSelected)
      }

      final class CollectionViewCellFinder: UIView {
        func setSelected(_ isSelected: Bool) {
          self.collectionViewCell(from: self)?.isSelected = isSelected
        }

        func collectionViewCell(from view: UIView?) -> UICollectionViewCell? {
          guard let view = view else { return nil }
          return (view as? UICollectionViewCell) ?? self.collectionViewCell(from: view.superview)
        }
      }
    }
  #elseif os(macOS)
    struct ListRowInteractor: NSViewRepresentable {
      let isSelected: Bool

      func makeNSView(context: Context) -> TableRowFinder {
        TableRowFinder()
      }

      func updateNSView(_ nsView: TableRowFinder, context: Context) {
        nsView.setSelected(isSelected)
      }

      final class TableRowFinder: NSView {
        func setSelected(_ isSelected: Bool) {
          self.tableRowView(from: self)?.isSelected = isSelected
        }

        func tableRowView(from view: NSView?) -> NSTableRowView? {
          guard let view = view else { return nil }
          return (view as? NSTableRowView) ?? self.tableRowView(from: view.superview)
        }
      }
    }
  #endif
}
