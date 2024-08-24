#if os(iOS)
import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import Foundation
import UIKit
import XCTestDynamicOverlay

#warning("The Pasteboard dependency implementation does not support iOS 15 UIPasteboard API")

extension Pasteboard: DependencyKey {
    public static var liveValue: Pasteboard { .system }
    public static var testValue: Pasteboard { .unimplemented }
    public static var previewValue: Pasteboard { .system }
}

public extension DependencyValues {
    var pasteboard: Pasteboard {
        get { self[Pasteboard.self] }
        set { self[Pasteboard.self] = newValue }
    }
}

public struct Pasteboard: Sendable, ConfigurableProxy {
    @_spi(Internals) public var _implementation: Implementation
    
    public struct Implementation: Sendable {
        @FunctionProxy public var setString: @Sendable (String) -> Void
        @FunctionProxy public var getString: @Sendable () -> String?
        @FunctionProxy public var setStrings: @Sendable ([String]) -> Void
        @FunctionProxy public var getStrings: @Sendable () -> [String]?
        @FunctionProxy public var setURL: @Sendable (URL) -> Void
        @FunctionProxy public var getURL: @Sendable () -> URL?
        @FunctionProxy public var setURLs: @Sendable ([URL]) -> Void
        @FunctionProxy public var getURLs: @Sendable () -> [URL]?
        @FunctionProxy public var setImage: @Sendable (UIImage) -> Void
        @FunctionProxy public var getImage: @Sendable () -> UIImage?
        @FunctionProxy public var setImages: @Sendable ([UIImage]) -> Void
        @FunctionProxy public var getImages: @Sendable () -> [UIImage]?
        @FunctionProxy public var setColor: @Sendable (UIColor) -> Void
        @FunctionProxy public var getColor: @Sendable () -> UIColor?
        @FunctionProxy public var setColors: @Sendable ([UIColor]) -> Void
        @FunctionProxy public var getColors: @Sendable () -> [UIColor]?
        @FunctionProxy public var contains: @Sendable (_ withPasteboardTypes: [String]) -> Bool
        @FunctionProxy public var itemSet: @Sendable (_ withPasteboardTypes: [String]) -> IndexSet?
        @FunctionProxy public var setItems: @Sendable ([[String: Any]]) -> Void
        @FunctionProxy public var items: @Sendable () -> [[String: Any]]
        @FunctionProxy public var numberOfItems: @Sendable () -> Int
        
        @FunctionProxy public var addItems: @Sendable ([[String: Any]]) -> Void
        @FunctionProxy public var setItemsWithOptions: @Sendable ([[String: Any]], [UIPasteboard.OptionsKey : Any]) -> Void
        @FunctionProxy public var dataForPasteboardType: @Sendable (String) -> Data?
        @FunctionProxy public var dataForPasteboardTypeInItemSet: @Sendable (String, IndexSet?) -> [Data]?
        @FunctionProxy public var setData: @Sendable (Data, String) -> Void
        @FunctionProxy public var valueForPasteboardType: @Sendable (String) -> Any?
        @FunctionProxy public var valuesForPasteboardTypeInItemSet: @Sendable (String, IndexSet?) -> [Any]?
        @FunctionProxy public var setValueForPasteboardType: @Sendable (Any, String) -> Void
        @FunctionProxy public var types: @Sendable () -> [String]
        @FunctionProxy public var typesForItemSet: @Sendable (IndexSet?) -> [[String]]?
        
        @FunctionProxy public var hasColors: @Sendable () -> Bool
        @FunctionProxy public var hasImages: @Sendable () -> Bool
        @FunctionProxy public var hasStrings: @Sendable () -> Bool
        @FunctionProxy public var hasURLs: @Sendable () -> Bool
        
        @FunctionProxy public var itemProviders: @Sendable () -> [NSItemProvider]
        @FunctionProxy public var setItemProviders: @Sendable ([NSItemProvider], Bool, Date?) -> Void
        @FunctionProxy public var setObjects: @Sendable ([any NSItemProviderWriting]) -> Void
        @FunctionProxy public var setObjectsWithOptions: @Sendable ([any NSItemProviderWriting], Bool, Date?) -> Void

        @FunctionProxy public var name: @Sendable () -> UIPasteboard.Name
        @FunctionProxy public var changeCount: @Sendable () -> Int
    }
}

public extension Pasteboard {
    /// Gets the string value from the pasteboard.
    var string: String? { _implementation.getString() }
    
    /// Gets the array of string values from the pasteboard.
    var strings: [String]? { _implementation.getStrings() }
    
    /// Gets the URL value from the pasteboard.
    var url: URL? { _implementation.getURL() }
    
    /// Gets the array of URL values from the pasteboard.
    var urls: [URL]? { _implementation.getURLs() }
    
    /// Gets the image value from the pasteboard.
    var image: UIImage? { _implementation.getImage() }
    
    /// Gets the array of image values from the pasteboard.
    var images: [UIImage]? { _implementation.getImages() }
    
    /// Gets the color value from the pasteboard.
    var color: UIColor? { _implementation.getColor() }
    
    /// Gets the array of color values from the pasteboard.
    var colors: [UIColor]? { _implementation.getColors() }
    
    /// Gets the items from the pasteboard.
    var items: [[String: Any]] { _implementation.items() }
    
    /// Gets the number of items in the pasteboard.
    var numberOfItems: Int { _implementation.numberOfItems() }
    
    /// Gets the types of the first item in the pasteboard.
    var types: [String] { _implementation.types() }
    
    /// Gets the item providers from the pasteboard.
    var itemProviders: [NSItemProvider] { _implementation.itemProviders() }
    
    /// Indicates whether the pasteboard contains a non-empty array of colors.
    var hasColors: Bool { _implementation.hasColors() }
    
    /// Indicates whether the pasteboard contains a non-empty array of images.
    var hasImages: Bool { _implementation.hasImages() }
    
    /// Indicates whether the pasteboard contains a non-empty array of strings.
    var hasStrings: Bool { _implementation.hasStrings() }
    
    /// Indicates whether the pasteboard contains a non-empty array of URLs.
    var hasURLs: Bool { _implementation.hasURLs() }
    
    /// Gets the name of the pasteboard.
    var name: UIPasteboard.Name { _implementation.name() }
    
    /// Gets the number of times the pasteboard’s contents have changed.
    var changeCount: Int { _implementation.changeCount() }

    /// Sets the string value in the pasteboard.
    func setString(_ string: String) { _implementation.setString(string) }
    
    /// Sets the array of string values in the pasteboard.
    func setStrings(_ strings: [String]) { _implementation.setStrings(strings) }
    
    /// Sets the URL value in the pasteboard.
    func setURL(_ url: URL) { _implementation.setURL(url) }
    
    /// Sets the array of URL values in the pasteboard.
    func setURLs(_ urls: [URL]) { _implementation.setURLs(urls) }
    
    /// Sets the image value in the pasteboard.
    func setImage(_ image: UIImage) { _implementation.setImage(image) }
    
    /// Sets the array of image values in the pasteboard.
    func setImages(_ images: [UIImage]) { _implementation.setImages(images) }
    
    /// Sets the color value in the pasteboard.
    func setColor(_ color: UIColor) { _implementation.setColor(color) }
    
    /// Sets the array of color values in the pasteboard.
    func setColors(_ colors: [UIColor]) { _implementation.setColors(colors) }
    
    /// Checks if the pasteboard contains any data for the specified data types.
    func contains(pasteboardTypes: [String]) -> Bool { _implementation.contains(pasteboardTypes) }
    
    /// Returns the index set of items that contain the specified pasteboard types.
    func itemSet(withPasteboardTypes pasteboardTypes: [String]) -> IndexSet? { _implementation.itemSet(pasteboardTypes) }
    
    /// Sets the items in the pasteboard.
    func setItems(_ items: [[String: Any]]) { _implementation.setItems(items) }
    
    /// Adds the items to the current contents of the pasteboard.
    func addItems(_ items: [[String: Any]]) { _implementation.addItems(items) }
    
    /// Sets the items in the pasteboard with options.
    func setItems(_ items: [[String: Any]], options: [UIPasteboard.OptionsKey : Any]) { _implementation.setItemsWithOptions(items, options) }
    
    /// Gets the data from the pasteboard for the specified representation type.
    func data(forPasteboardType pasteboardType: String) -> Data? { _implementation.dataForPasteboardType(pasteboardType) }
    
    /// Gets the data objects in the indicated pasteboard items that have the given representation type.
    func data(forPasteboardType pasteboardType: String, inItemSet itemSet: IndexSet?) -> [Data]? { _implementation.dataForPasteboardTypeInItemSet(pasteboardType, itemSet) }
    
    /// Sets the data in the pasteboard for the specified representation type.
    func setData(_ data: Data, forPasteboardType pasteboardType: String) { _implementation.setData(data, pasteboardType) }
    
    /// Gets an object from the pasteboard for the specified representation type.
    func value(forPasteboardType pasteboardType: String) -> Any? { _implementation.valueForPasteboardType(pasteboardType) }
    
    /// Gets the objects in the indicated pasteboard items that have the given representation type.
    func values(forPasteboardType pasteboardType: String, inItemSet itemSet: IndexSet?) -> [Any]? { _implementation.valuesForPasteboardTypeInItemSet(pasteboardType, itemSet) }
    
    /// Sets an object in the pasteboard for the specified representation type.
    func setValue(_ value: Any, forPasteboardType pasteboardType: String) { _implementation.setValueForPasteboardType(value, pasteboardType) }
    
    /// Returns an array of representation types for each specified pasteboard item.
    func types(forItemSet itemSet: IndexSet?) -> [[String]]? { _implementation.typesForItemSet(itemSet) }

    /// Sets and configures an explicit array of item providers for the pasteboard.
    func setItemProviders(_ itemProviders: [NSItemProvider], localOnly: Bool, expirationDate: Date?) {
        _implementation.setItemProviders(itemProviders, localOnly, expirationDate)
    }

    /// Sets an array of item providers for the pasteboard.
    func setObjects(_ objects: [any NSItemProviderWriting]) { _implementation.setObjects(objects) }
    
    /// Sets and configures an array of item providers for the pasteboard.
    func setObjects(_ objects: [any NSItemProviderWriting], localOnly: Bool, expirationDate: Date?) {
        _implementation.setObjectsWithOptions(objects, localOnly, expirationDate)
    }
}


extension Pasteboard {
    static var system: Pasteboard {
        Pasteboard(
            _implementation: .init(
                setString: .init { string in
                    UIPasteboard.general.string = string
                },
                getString: .init {
                    UIPasteboard.general.string
                },
                setStrings: .init { strings in
                    UIPasteboard.general.strings = strings
                },
                getStrings: .init {
                    UIPasteboard.general.strings
                },
                setURL: .init { url in
                    UIPasteboard.general.url = url
                },
                getURL: .init {
                    UIPasteboard.general.url
                },
                setURLs: .init { urls in
                    UIPasteboard.general.urls = urls
                },
                getURLs: .init {
                    UIPasteboard.general.urls
                },
                setImage: .init { image in
                    UIPasteboard.general.image = image
                },
                getImage: .init {
                    UIPasteboard.general.image
                },
                setImages: .init { images in
                    UIPasteboard.general.images = images
                },
                getImages: .init {
                    UIPasteboard.general.images
                },
                setColor: .init { color in
                    UIPasteboard.general.color = color
                },
                getColor: .init {
                    UIPasteboard.general.color
                },
                setColors: .init { colors in
                    UIPasteboard.general.colors = colors
                },
                getColors: .init {
                    UIPasteboard.general.colors
                },
                contains: .init { types in
                    UIPasteboard.general.contains(pasteboardTypes: types)
                },
                itemSet: .init { types in
                    UIPasteboard.general.itemSet(withPasteboardTypes: types)
                },
                setItems: .init { items in
                    UIPasteboard.general.items = items
                },
                items: .init {
                    UIPasteboard.general.items
                },
                numberOfItems: .init {
                    UIPasteboard.general.numberOfItems
                },
                addItems: .init { items in
                    UIPasteboard.general.addItems(items)
                },
                setItemsWithOptions: .init { items, options in
                    UIPasteboard.general.setItems(items, options: options)
                },
                dataForPasteboardType: .init { type in
                    UIPasteboard.general.data(forPasteboardType: type)
                },
                dataForPasteboardTypeInItemSet: .init { type, itemSet in
                    UIPasteboard.general.data(forPasteboardType: type, inItemSet: itemSet)
                },
                setData: .init { data, type in
                    UIPasteboard.general.setData(data, forPasteboardType: type)
                },
                valueForPasteboardType: .init { type in
                    UIPasteboard.general.value(forPasteboardType: type)
                },
                valuesForPasteboardTypeInItemSet: .init { type, itemSet in
                    UIPasteboard.general.values(forPasteboardType: type, inItemSet: itemSet)
                },
                setValueForPasteboardType: .init { value, type in
                    UIPasteboard.general.setValue(value, forPasteboardType: type)
                },
                types: .init {
                    UIPasteboard.general.types
                },
                typesForItemSet: .init { itemSet in
                    UIPasteboard.general.types(forItemSet: itemSet)
                },
                hasColors: .init {
                    UIPasteboard.general.hasColors
                },
                hasImages: .init {
                    UIPasteboard.general.hasImages
                },
                hasStrings: .init {
                    UIPasteboard.general.hasStrings
                },
                hasURLs: .init {
                    UIPasteboard.general.hasURLs
                },
                itemProviders: .init {
                    UIPasteboard.general.itemProviders
                },
                setItemProviders: .init { itemProviders, localOnly, expirationDate in
                    UIPasteboard.general.setItemProviders(itemProviders, localOnly: localOnly, expirationDate: expirationDate)
                },
                setObjects: .init { objects in
                    UIPasteboard.general.setObjects(objects)
                },
                setObjectsWithOptions: .init { objects, localOnly, expirationDate in
                    UIPasteboard.general.setObjects(objects, localOnly: localOnly, expirationDate: expirationDate)
                },
                name: .init {
                    UIPasteboard.general.name
                },
                changeCount: .init {
                    UIPasteboard.general.changeCount
                }
            )
        )
    }
    
    public static var unimplemented: Pasteboard {
        .init(
            _implementation: Implementation(
                setString: .unimplemented(
                    #"@Dependency(\.pasteboard.setString)"#),
                getString: .unimplemented(
                    #"@Dependency(\.pasteboard.getString)"#),
                setStrings: .unimplemented(
                    #"@Dependency(\.pasteboard.setStrings)"#),
                getStrings: .unimplemented(
                    #"@Dependency(\.pasteboard.getStrings)"#),
                setURL: .unimplemented(
                    #"@Dependency(\.pasteboard.setURL)"#),
                getURL: .unimplemented(
                    #"@Dependency(\.pasteboard.getURL)"#),
                setURLs: .unimplemented(
                    #"@Dependency(\.pasteboard.setURLs)"#),
                getURLs: .unimplemented(
                    #"@Dependency(\.pasteboard.getURLs)"#),
                setImage: .unimplemented(
                    #"@Dependency(\.pasteboard.setImage)"#),
                getImage: .unimplemented(
                    #"@Dependency(\.pasteboard.getImage)"#),
                setImages: .unimplemented(
                    #"@Dependency(\.pasteboard.setImages)"#),
                getImages: .unimplemented(
                    #"@Dependency(\.pasteboard.getImages)"#),
                setColor: .unimplemented(
                    #"@Dependency(\.pasteboard.setColor)"#),
                getColor: .unimplemented(
                    #"@Dependency(\.pasteboard.getColor)"#),
                setColors: .unimplemented(
                    #"@Dependency(\.pasteboard.setColors)"#),
                getColors: .unimplemented(
                    #"@Dependency(\.pasteboard.getColors)"#),
                contains: .unimplemented(
                    #"@Dependency(\.pasteboard.contains)"#),
                itemSet: .unimplemented(
                    #"@Dependency(\.pasteboard.itemSet)"#),
                setItems: .unimplemented(
                    #"@Dependency(\.pasteboard.setItems)"#),
                items: .unimplemented(
                    #"@Dependency(\.pasteboard.items)"#),
                numberOfItems: .unimplemented(
                    #"@Dependency(\.pasteboard.numberOfItems)"#),
                addItems: .unimplemented(
                    #"@Dependency(\.pasteboard.addItems)"#),
                setItemsWithOptions: .unimplemented(
                    #"@Dependency(\.pasteboard.setItemsWithOptions)"#),
                dataForPasteboardType: .unimplemented(
                    #"@Dependency(\.pasteboard.dataForPasteboardType)"#),
                dataForPasteboardTypeInItemSet: .unimplemented(
                    #"@Dependency(\.pasteboard.dataForPasteboardTypeInItemSet)"#),
                setData: .unimplemented(
                    #"@Dependency(\.pasteboard.setData)"#),
                valueForPasteboardType: .unimplemented(
                    #"@Dependency(\.pasteboard.valueForPasteboardType)"#),
                valuesForPasteboardTypeInItemSet: .unimplemented(
                    #"@Dependency(\.pasteboard.valuesForPasteboardTypeInItemSet)"#),
                setValueForPasteboardType: .unimplemented(
                    #"@Dependency(\.pasteboard.setValueForPasteboardType)"#),
                types: .unimplemented(
                    #"@Dependency(\.pasteboard.types)"#),
                typesForItemSet: .unimplemented(
                    #"@Dependency(\.pasteboard.typesForItemSet)"#),
                hasColors: .unimplemented(
                    #"@Dependency(\.pasteboard.hasColors)"#),
                hasImages: .unimplemented(
                    #"@Dependency(\.pasteboard.hasImages)"#),
                hasStrings: .unimplemented(
                    #"@Dependency(\.pasteboard.hasStrings)"#),
                hasURLs: .unimplemented(
                    #"@Dependency(\.pasteboard.hasURLs)"#),
                itemProviders: .unimplemented(
                    #"@Dependency(\.pasteboard.itemProviders)"#),
                setItemProviders: .unimplemented(
                    #"@Dependency(\.pasteboard.setItemProviders)"#),
                setObjects: .unimplemented(
                    #"@Dependency(\.pasteboard.setObjects)"#),
                setObjectsWithOptions: .unimplemented(
                    #"@Dependency(\.pasteboard.setObjectsWithOptions)"#),
                name: .unimplemented(
                    #"@Dependency(\.pasteboard.name)"#),
                changeCount: .unimplemented(
                    #"@Dependency(\.pasteboard.changeCount)"#)
            )
        )
    }
}
#endif
