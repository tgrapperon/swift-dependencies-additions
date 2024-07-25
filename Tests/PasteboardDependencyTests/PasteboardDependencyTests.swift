#if os(iOS)
import Dependencies
import PasteboardDependency
import XCTest
import UIKit

final class PasteboardTests: XCTestCase {
    @Dependency(\.pasteboard) var pasteboard

    func testSetString() {
        withDependencies {
            $0.pasteboard.$setString = { @Sendable string in
                XCTAssertEqual(string, "Test String")
            }
        } operation: {
            pasteboard.setString("Test String")
        }
    }

    func testGetString() {
        withDependencies {
            $0.pasteboard.$getString = { @Sendable in
                "Test String"
            }
        } operation: {
            XCTAssertEqual(pasteboard.string, "Test String")
        }
    }

    func testSetStrings() {
        withDependencies {
            $0.pasteboard.$setStrings = { @Sendable strings in
                XCTAssertEqual(strings, ["String 1", "String 2"])
            }
        } operation: {
            pasteboard.setStrings(["String 1", "String 2"])
        }
    }

    func testGetStrings() {
        withDependencies {
            $0.pasteboard.$getStrings = { @Sendable in
                ["String 1", "String 2"]
            }
        } operation: {
            XCTAssertEqual(pasteboard.strings, ["String 1", "String 2"])
        }
    }

    func testSetURL() {
        let url = URL(string: "https://example.com")!
        withDependencies {
            $0.pasteboard.$setURL = { @Sendable receivedURL in
                XCTAssertEqual(receivedURL, url)
            }
        } operation: {
            pasteboard.setURL(url)
        }
    }

    func testGetURL() {
        let url = URL(string: "https://example.com")!
        withDependencies {
            $0.pasteboard.$getURL = { @Sendable in
                url
            }
        } operation: {
            XCTAssertEqual(pasteboard.url, url)
        }
    }

    func testSetURLs() {
        let urls = [URL(string: "https://example.com")!, URL(string: "https://example2.com")!]
        withDependencies {
            $0.pasteboard.$setURLs = { @Sendable receivedURLs in
                XCTAssertEqual(receivedURLs, urls)
            }
        } operation: {
            pasteboard.setURLs(urls)
        }
    }

    func testGetURLs() {
        let urls = [URL(string: "https://example.com")!, URL(string: "https://example2.com")!]
        withDependencies {
            $0.pasteboard.$getURLs = { @Sendable in
                urls
            }
        } operation: {
            XCTAssertEqual(pasteboard.urls, urls)
        }
    }

    func testSetImage() {
        let image = UIImage()
        withDependencies {
            $0.pasteboard.$setImage = { @Sendable receivedImage in
                XCTAssertEqual(receivedImage, image)
            }
        } operation: {
            pasteboard.setImage(image)
        }
    }

    func testGetImage() {
        let image = UIImage()
        withDependencies {
            $0.pasteboard.$getImage = { @Sendable in
                image
            }
        } operation: {
            XCTAssertEqual(pasteboard.image, image)
        }
    }

    func testSetImages() {
        let images = [UIImage(), UIImage()]
        withDependencies {
            $0.pasteboard.$setImages = { @Sendable receivedImages in
                XCTAssertEqual(receivedImages, images)
            }
        } operation: {
            pasteboard.setImages(images)
        }
    }

    func testGetImages() {
        let images = [UIImage(), UIImage()]
        withDependencies {
            $0.pasteboard.$getImages = { @Sendable in
                images
            }
        } operation: {
            XCTAssertEqual(pasteboard.images, images)
        }
    }

    func testSetColor() {
        let color = UIColor.red
        withDependencies {
            $0.pasteboard.$setColor = { @Sendable receivedColor in
                XCTAssertEqual(receivedColor, color)
            }
        } operation: {
            pasteboard.setColor(color)
        }
    }

    func testGetColor() {
        let color = UIColor.red
        withDependencies {
            $0.pasteboard.$getColor = { @Sendable in
                color
            }
        } operation: {
            XCTAssertEqual(pasteboard.color, color)
        }
    }

    func testSetColors() {
        let colors = [UIColor.red, UIColor.blue]
        withDependencies {
            $0.pasteboard.$setColors = { @Sendable receivedColors in
                XCTAssertEqual(receivedColors, colors)
            }
        } operation: {
            pasteboard.setColors(colors)
        }
    }

    func testGetColors() {
        let colors = [UIColor.red, UIColor.blue]
        withDependencies {
            $0.pasteboard.$getColors = { @Sendable in
                colors
            }
        } operation: {
            XCTAssertEqual(pasteboard.colors, colors)
        }
    }

    func testContains() {
        let types = ["public.text"]
        withDependencies {
            $0.pasteboard.$contains = { @Sendable receivedTypes in
                XCTAssertEqual(receivedTypes, types)
                return true
            }
        } operation: {
            XCTAssertTrue(pasteboard.contains(pasteboardTypes: types))
        }
    }

    func testItemSet() {
        let types = ["public.text"]
        let indexSet = IndexSet(arrayLiteral: 0, 1)
        withDependencies {
            $0.pasteboard.$itemSet = { @Sendable receivedTypes in
                XCTAssertEqual(receivedTypes, types)
                return indexSet
            }
        } operation: {
            XCTAssertEqual(pasteboard.itemSet(withPasteboardTypes: types), indexSet)
        }
    }

    func testSetItems() {
        let items: [[String: Any]] = [["public.text": "Test"]]
        withDependencies {
            $0.pasteboard.$setItems = { @Sendable receivedItems in
                XCTAssertEqual(receivedItems.first?["public.text"] as? String, "Test")
            }
        } operation: {
            pasteboard.setItems(items)
        }
    }

    func testGetItems() {
        let items: [[String: Any]] = [["public.text": "Test"]]
        withDependencies {
            $0.pasteboard.$items = { @Sendable in
                items
            }
        } operation: {
            XCTAssertEqual(pasteboard.items.first?["public.text"] as? String, "Test")
        }
    }

    func testNumberOfItems() {
        withDependencies {
            $0.pasteboard.$numberOfItems = { @Sendable in
                3
            }
        } operation: {
            XCTAssertEqual(pasteboard.numberOfItems, 3)
        }
    }

    func testAddItems() {
        let items: [[String: Any]] = [["public.text": "Test"]]
        withDependencies {
            $0.pasteboard.$addItems = { @Sendable receivedItems in
                XCTAssertEqual(receivedItems.first?["public.text"] as? String, "Test")
            }
        } operation: {
            pasteboard.addItems(items)
        }
    }

    func testSetItemsWithOptions() {
        let items: [[String: Any]] = [["public.text": "Test"]]
        let options: [UIPasteboard.OptionsKey: Any] = [.expirationDate: Date()]
        withDependencies {
            $0.pasteboard.$setItemsWithOptions = { @Sendable receivedItems, receivedOptions in
                XCTAssertEqual(receivedItems.first?["public.text"] as? String, "Test")
                XCTAssertEqual(receivedOptions as NSDictionary, options as NSDictionary)
            }
        } operation: {
            pasteboard.setItems(items, options: options)
        }
    }

    func testDataForPasteboardType() {
        let data = "Test".data(using: .utf8)!
        withDependencies {
            $0.pasteboard.$dataForPasteboardType = { @Sendable type in
                XCTAssertEqual(type, "public.text")
                return data
            }
        } operation: {
            XCTAssertEqual(pasteboard.data(forPasteboardType: "public.text"), data)
        }
    }

    func testDataForPasteboardTypeInItemSet() {
        let data = ["Test".data(using: .utf8)!]
        let indexSet = IndexSet(arrayLiteral: 0, 1)
        withDependencies {
            $0.pasteboard.$dataForPasteboardTypeInItemSet = { @Sendable type, receivedIndexSet in
                XCTAssertEqual(type, "public.text")
                XCTAssertEqual(receivedIndexSet, indexSet)
                return data
            }
        } operation: {
            XCTAssertEqual(pasteboard.data(forPasteboardType: "public.text", inItemSet: indexSet), data)
        }
    }

    func testSetData() {
        let data = "Test".data(using: .utf8)!
        withDependencies {
            $0.pasteboard.$setData = { @Sendable receivedData, type in
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(type, "public.text")
            }
        } operation: {
            pasteboard.setData(data, forPasteboardType: "public.text")
        }
    }

    func testValueForPasteboardType() {
        withDependencies {
            $0.pasteboard.$valueForPasteboardType = { @Sendable type in
                XCTAssertEqual(type, "public.text")
                return "Test"
            }
        } operation: {
            XCTAssertEqual(pasteboard.value(forPasteboardType: "public.text") as? String, "Test")
        }
    }

    func testValuesForPasteboardTypeInItemSet() {
        let values = ["Test"]
        let indexSet = IndexSet(arrayLiteral: 0, 1)
        withDependencies {
            $0.pasteboard.$valuesForPasteboardTypeInItemSet = { @Sendable type, receivedIndexSet in
                XCTAssertEqual(type, "public.text")
                XCTAssertEqual(receivedIndexSet, indexSet)
                return values
            }
        } operation: {
            XCTAssertEqual(pasteboard.values(forPasteboardType: "public.text", inItemSet: indexSet) as? [String], values)
        }
    }

    func testSetValueForPasteboardType() {
        withDependencies {
            $0.pasteboard.$setValueForPasteboardType = { @Sendable value, type in
                XCTAssertEqual(value as? String, "Test")
                XCTAssertEqual(type, "public.text")
            }
        } operation: {
            pasteboard.setValue("Test", forPasteboardType: "public.text")
        }
    }

    func testTypes() {
        let types = ["public.text"]
        withDependencies {
            $0.pasteboard.$types = { @Sendable in
                types
            }
        } operation: {
            XCTAssertEqual(pasteboard.types, types)
        }
    }

    func testTypesForItemSet() {
        let types = [["public.text"]]
        let indexSet = IndexSet(arrayLiteral: 0, 1)
        withDependencies {
            $0.pasteboard.$typesForItemSet = { @Sendable receivedIndexSet in
                XCTAssertEqual(receivedIndexSet, indexSet)
                return types
            }
        } operation: {
            XCTAssertEqual(pasteboard.types(forItemSet: indexSet), types)
        }
    }

    func testHasColors() {
        withDependencies {
            $0.pasteboard.$hasColors = { @Sendable in
                true
            }
        } operation: {
            XCTAssertTrue(pasteboard.hasColors)
        }
    }

    func testHasImages() {
        withDependencies {
            $0.pasteboard.$hasImages = { @Sendable in
                true
            }
        } operation: {
            XCTAssertTrue(pasteboard.hasImages)
        }
    }

    func testHasStrings() {
        withDependencies {
            $0.pasteboard.$hasStrings = { @Sendable in
                true
            }
        } operation: {
            XCTAssertTrue(pasteboard.hasStrings)
        }
    }

    func testHasURLs() {
        withDependencies {
            $0.pasteboard.$hasURLs = { @Sendable in
                true
            }
        } operation: {
            XCTAssertTrue(pasteboard.hasURLs)
        }
    }

    func testItemProviders() {
        withDependencies {
            $0.pasteboard.$itemProviders = { @Sendable in
                return [NSItemProvider()]
            }
        } operation: {
            XCTAssertEqual(pasteboard.itemProviders.count, 1)
        }
    }

    func testSetItemProviders() {
        let expirationDate = Date()
        withDependencies {
            $0.pasteboard.$setItemProviders = { @Sendable receivedItemProviders, localOnly, receivedExpirationDate in
                XCTAssertEqual(receivedItemProviders.count, 1)
                XCTAssertFalse(localOnly)
                XCTAssertEqual(receivedExpirationDate, expirationDate)
            }
        } operation: {
            let itemProviders = [NSItemProvider()]
            pasteboard.setItemProviders(itemProviders, localOnly: false, expirationDate: expirationDate)
        }
    }

    func testSetObjects() {
        let objects: [any NSItemProviderWriting] = [UIImage()]
        withDependencies {
            $0.pasteboard.$setObjects = { @Sendable receivedObjects in
                XCTAssertEqual(receivedObjects.count, objects.count)
            }
        } operation: {
            pasteboard.setObjects(objects)
        }
    }

    func testSetObjectsWithOptions() {
        let objects: [any NSItemProviderWriting] = [UIImage()]
        let expirationDate = Date()
        withDependencies {
            $0.pasteboard.$setObjectsWithOptions = { @Sendable receivedObjects, localOnly, receivedExpirationDate in
                XCTAssertEqual(receivedObjects.count, objects.count)
                XCTAssertFalse(localOnly)
                XCTAssertEqual(receivedExpirationDate, expirationDate)
            }
        } operation: {
            pasteboard.setObjects(objects, localOnly: false, expirationDate: expirationDate)
        }
    }

    func testName() {
        let name = UIPasteboard.Name.general
        withDependencies {
            $0.pasteboard.$name = { @Sendable in
                name
            }
        } operation: {
            XCTAssertEqual(pasteboard.name, name)
        }
    }

    func testChangeCount() {
        withDependencies {
            $0.pasteboard.$changeCount = { @Sendable in
                5
            }
        } operation: {
            XCTAssertEqual(pasteboard.changeCount, 5)
        }
    }
}
#endif
