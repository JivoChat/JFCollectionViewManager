![CI](https://github.com/DenTelezhkin/DTCollectionViewManager/workflows/CI/badge.svg)
[![codecov.io](http://codecov.io/github/DenTelezhkin/DTCollectionViewManager/coverage.svg?branch=master)](http://codecov.io/github/DenTelezhkin/DTCollectionViewManager?branch=master)
![CocoaPod platform](https://cocoapod-badges.herokuapp.com/p/DTCollectionViewManager/badge.svg)
![CocoaPod version](https://cocoapod-badges.herokuapp.com/v/DTCollectionViewManager/badge.svg)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

DTCollectionViewManager
================
> This is a sister-project for [DTTableViewManager](https://github.com/DenTelezhkin/DTTableViewManager) - great tool for UITableView management, built on the same principles.

Powerful generic-based UICollectionView management framework, written in Swift.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Usage](#usage)
    - **Intro -** [Mapping and Registration](#mapping-and-registration), [Data Models](#data-models)
    - **Storage classes -** [Memory Storage](#memorystorage), [CoreDataStorage](#coredatastorage), [RealmStorage](#realmstorage), [Diffable Datasources in iOS13](#diffable-datasources-in-ios-13)
    - **Reacting to events -** [Event types](#event-types), [Events configuration](#events-configuration)
- [Advanced Usage](#advanced-usage)
  - [Drag and Drop in iOS 11](#drag-and-drop-in-ios-11)
	- [Reacting to content updates](#reacting-to-content-updates)
	- [Customizing UICollectionView updates](#customizing-uicollectionview-updates)
  - [Conditional mappings](#conditional-mappings)
  - [Anomaly handler](#anomaly-handler)
  - [Unregistering mappings](#unregistering-mappings)
- [Thanks](#thanks)

## Features

- [x] Powerful mapping system between data models and cells, headers and footers
- [x] Support for all Swift types as data models
- [x] Support for diffable datasources in iOS 13
- [x] Powerful events system, that covers all of UICollectionView delegate and datasource methods
- [x] Views created from code, XIB, or storyboard
- [x] Flexible Memory/CoreData/Realm.io storage options
- [x] Automatic datasource and interface synchronization.
- [x] Automatic XIB registration and dequeue
- [x] Support for Drag&Drop for iOS 11 and higher
- [x] Can be used with UICollectionViewController, or UIViewController with UICollectionView, or any other class, that contains UICollectionView
- [x] [Complete documentation](https://dentelezhkin.github.io/DTCollectionViewManager/)

## Requirements

* Xcode 9 and higher
* iOS 8.0 and higher / tvOS 9.0 and higher
* Swift 4.2 and higher

## Installation

### Swift Package Manager(requires Xcode 11)

Add package into Project settings -> Swift Packages

### [CocoaPods](http://www.cocoapods.org):

    pod 'DTCollectionViewManager'

## Quick start

Let's say you have an array of Posts you want to display in UICollectionView. To quickly show them using DTCollectionViewManager, here's what you need to do:

* Create UICollectionViewCell subclass, let's say PostCell. Adopt ModelTransfer protocol

```swift
class PostCell : UICollectionViewCell, ModelTransfer {
	func update(with model: Post) {
		// Fill your cell with actual data
	}
}
```

* Declare your class as `DTCollectionViewManageable`, and it will be automatically injected with `manager` property, that will hold an instance of `DTCollectionViewManager`.

* Make sure your UICollectionView outlet is wired to your class and call registration methods (typically in viewDidLoad method):

```swift
class PostsViewController: UIViewController, DTCollectionViewManageable {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.register(PostCell.self)
    }
}    
```

ModelType will be automatically gathered from your `PostCell`. If you have a PostCell.xib file, it will be automatically registered for PostCell. If you have a storyboard with PostCell, set it's reuseIdentifier to be identical to class - "PostCell".

* Add your posts!

```swift
	manager.memoryStorage.addItems(posts)
```

That's it! It's that easy!

## Usage

### Mapping and registration

Cells:
* `register(_:)`
* `registerNibNamed(_:for:)`
* `registerNibless(_:)`

Headers and footers:
* `registerHeader(_:)`
* `registerNibNamed(_:forHeader:)`
* `registerNiblessHeader(_:)`
* `registerFooter(_:)`
* `registerNibNamed(_:forFooter:)`
* `registerNiblessFooter(_:)`

Supplementaries:
* `registerSupplementary(_:forKind:)`
* `registerNibNamed(_:forSupplementary:ofKind:)`
* `registerNiblessSupplementary(_:forKind:)`

### Data models

`DTCollectionViewManager` supports all Swift and Objective-C types as data models. This also includes protocols and subclasses.

```swift
protocol Food {}
class Apple : Food {}
class Carrot: Food {}

class FoodCollectionViewCell : UICollectionViewCell, ModelTransfer {
    func update(with model: Food) {
        // Display food in a cell
    }
}
manager.register(FoodCollectionViewCell.self)
manager.memoryStorage.addItems([Apple(),Carrot()])
```

## Storage classes

[DTModelStorage](https://github.com/DenTelezhkin/DTModelStorage/) is a framework, that provides storage classes for `DTCollectionViewManager`. By default, storage property on `DTCollectionViewManager` holds a `MemoryStorage` instance.

### MemoryStorage

`MemoryStorage` is a class, that manages UICollectionView models in memory. It has methods for adding, removing, replacing, reordering models etc. You can read all about them in [DTModelStorage repo](https://github.com/DenTelezhkin/DTModelStorage#memorystorage). Basically, every section in `MemoryStorage` is an array of `SectionModel` objects, which itself is an object, that contains an array of items.

### CoreDataStorage

`CoreDataStorage` is meant to be used with `NSFetchedResultsController`. It automatically monitors all NSFetchedResultsControllerDelegate methods and updates UI accordingly to it's changes. All you need to do to display CoreData models in your UICollectionView, is create CoreDataStorage object and set it on your `storage` property of `DTCollectionViewManager`.

It also recommended to use built-in CoreData updater to properly update UICollectionView:

```swift
manager.collectionViewUpdater = manager.coreDataUpdater()
```

Standard flow for creating `CoreDataStorage` can be something like this:

```swift
let request = NSFetchRequest<Post>()
request.entity = NSEntityDescription.entity(forEntityName: String(Post.self), in: context)
request.fetchBatchSize = 20
request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
let fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
_ = try? fetchResultsController.performFetch()

manager.storage = CoreDataStorage(fetchedResultsController: fetchResultsController)
```

Keep in mind, that MemoryStorage is not limited to objects in memory. For example, if you have CoreData database, and you now for sure, that number of items is not big, you can choose not to use CoreDataStorage and NSFetchedResultsController. You can fetch all required models, and store them in MemoryStorage.

### RealmStorage

`RealmStorage` is a class, that is meant to be used with [realm.io](https://realm.io) databases. To use `RealmStorage` with `DTCollectionViewManager`, add following line to your Podfile:

```ruby
    pod 'DTModelStorage/Realm'
```

If you are using Carthage, `RealmStorage` will be automatically built along with `DTModelStorage`.

### Diffable datasources in iOS 13

Diffable datasources is a cool new feature, that is introduced in UIKit in iOS / tvOS 13. `DTCollectionViewManager` provides a powerful integration layer with it, but in order to understand how this layer works, it's highly recommended to check out great [Advances in UI Data Sources WWDC session](https://developer.apple.com/videos/play/wwdc2019/220/).

If you don't use `DTCollectionViewManager`, you would typically create diffable datasource like so (taken from Apple's sample code on diffable datasources):

```swift
dataSource = UICollectionViewDiffableDataSource
    <Section, MountainsController.Mountain>(collectionView: mountainsCollectionView) {
        (collectionView: UICollectionView, indexPath: IndexPath,
        mountain: MountainsController.Mountain) -> UICollectionViewCell? in
    guard let mountainCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
            fatalError("Cannot create new cell") }
    mountainCell.label.text = mountain.name
    return mountainCell
}
```

One of `DTCollectionViewManager`s main goals is to get rid of String identifiers, and to handle cell creation, as well as updating cell with it's model, for you. Which is why with DTCollectionViewManager code, equivalent to one above, is the following:

```swift
dataSource = manager.configureDiffableDataSource { indexPath, model in
    return model
}
```

You should persist strong reference to `dataSource` object, and use it for constructing sections and items exactly as described in Apple documentation and WWDC session.

Diffable datasources and `DTCollectionViewManager 7` are tightly integrated, so all events, even datasource ones like `manager.configure(_:)`, continue to work in the same way as they were working before.

Events integration is possible, because `DTCollectionViewManager` injects a special `ProxyDiffableDataSourceStorage` object between `UICollectionViewDiffableDataSource` and `UICollectionView`. This storage does not store data models and just queries diffable data source to receive them. It does, however, implement section supplementary model providers.

`DTCollectionViewManager` supports both generic `UICollectionViewDiffableDataSource<SectionType,ItemType>` and non-generic  `UICollectionViewDiffableDataSourceReference` with the same method name(`configureDiffableDataSource`). Resulting diffable datasource type is inferred from your declaration of the datasource.

**Note** Due to underlying implementation details, using `UICollectionViewDiffableDataSource.supplementaryViewProvider` property is not supported. Please use `ProxyDiffableDataSourceStorage.supplementaryModelProvider` property instead:

```swift
manager.supplementaryStorage?.setSectionHeaderModels(["Foo"])
```

Keep in mind, that for diffable datasources, `collectionViewUpdater` property will contain nil, since UI updates are handled by diffable datasource itself.

## Reacting to events

Event system in DTCollectionViewManager 5 allows you to react to `UICollectionViewDelegate`, `UICollectionViewDataSource` and `UICollectionViewDelegateFlowLayout` events based on view and model types, completely bypassing any switches or ifs when working with UICollectionView API. For example:

```swift
manager.didSelect(PostCell.self) { cell,model,indexPath in
  print("Selected PostCell with \(model) at \(indexPath)")
}
```

**Important!**

While it's possible to register multiple closures for a single event, only first closure will be called once event is fired. This means that if the same event has two closures for the same view/model type, last one will be ignored. You can still register multiple event handlers for a single event and different view/model types. You can see how reactions are being searched for in [DTModelStorage EventReaction extension](https://github.com/DenTelezhkin/DTModelStorage/blob/master/Sources/DTModelStorage/EventReactions.swift#L155-L166).

### Event types

There are two types of events:

1. Event where we have underlying view at runtime
1. Event where we have only data model, because view has not been created yet.

In the first case, we are able to check view and model types, and pass them into closure. In the second case, however, if there's no view, we can't make any guarantees of which type it will be, therefore it loses view generic type and is not passed to closure. These two types of events have different signature, for example:

```swift
// Signature for didSelect event
// We do have a cell, when UICollectionView calls "collectionView(_:didSelectItemAt:)" method
open func didSelect<T:ModelTransfer>(_ cellClass:  T.Type, _ closure: @escaping (T,T.ModelType, IndexPath) -> Void) where T:UICollectionViewCell


// Signature for sizeForCell(withItem:) event
// When UICollectionView calls "collectionView(_:layout:sizeForItemAt:)" method, cell is not created yet, so closure contains two arguments instead of three, and there are no guarantees made about cell type, only model type
open func sizeForCell<T>(withItem itemType: T.Type, _ closure: @escaping (T, IndexPath) -> CGFloat)
```

It's also important to understand, that event system is implemented using `responds(to:)` method override and is working on the following rules:

* If `DTCollectionViewManageable` is implementing delegate method, `responds(to:)` returns true
* If `DTCollectionViewManager` has events tied to selector being called, `responds(to:)` also returns true

What this approach allows us to do, is configuring UICollectionView knowledge about what delegate method is implemented and what is not. For example, `DTCollectionViewManager` is implementing `collectionView(_:layout:sizeForItemAt:)` method, however if you don't call `sizeForCell(withItem:_:)` method, you are safe to use self-sizing cells in UICollectionView. While a lot of delegate methods are implemented, only those that have events or are implemented by delegate will be called by `UICollectionView`.

`DTCollectionViewManager` has the same approach for handling each delegate and datasource method:

* Try to execute event, if cell and model type satisfy requirements
* Try to call delegate or datasource method on `DTCollectionViewManageable` instance
* If two previous scenarios fail, fallback to whatever default `UICollectionView` has for this delegate or datasource method

### Events configuration

To have compile safety when registering events, you can use `configureEvents` method:

```swift
manager.configureEvents(for: IntCell.self) { cellType, modelType in
  manager.register(cellType)
  manager.estimatedHeight(for: modelType) { _,_ in
    return 44
  }
}
```

## Advanced usage

### Drag and Drop in iOS 11

There is a [dedicated repo](https://github.com/DenTelezhkin/DTDragAndDropExample), containing Apple's sample on Drag&Drop, enhanced with `DTTableViewManager` and `DTCollectionViewManager`. Most of the stuff is just usual drop and drag delegate events, but there is also special support for UITableView and UICollectionView placeholders, that makes sure calls are dispatched to main thread, and if you use `MemoryStorage`, performs datasource updates automatically.

### Reacting to content updates

Sometimes it's convenient to know, when data is updated, for example to hide UICollectionView, if there's no data. `CollectionViewUpdater` has `willUpdateContent` and `didUpdateContent` properties, that can help:

```swift
updater.willUpdateContent = { update in
  print("UI update is about to begin")
}

updater.didUpdateContent = { update in
  print("UI update finished")
}
```

### Customizing UICollectionView updates

`DTCollectionViewManager` uses `CollectionViewUpdater` class by default. However for `CoreData` you might want to tweak UI updating code. For example, when reloading cell, you might want animation to occur, or you might want to silently update your cell. This is actually how [Apple's guide](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html) for `NSFetchedResultsController` suggests you should do. Another interesting thing it suggests that .Move event reported by NSFetchedResultsController should be animated not as a move, but as deletion of old index path and insertion of new one.

If you want to work with CoreData and NSFetchedResultsController, just call:

```swift
manager.collectionViewUpdater = manager.coreDataUpdater()
```

`CollectionViewUpdater` constructor allows customizing it's basic behaviour:

```swift
let updater = CollectionViewUpdater(collectionView: collectionView, reloadRow: { indexPath in
  // Reload row
}, animateMoveAsDeleteAndInsert: false)
```

These are all default options, however you might implement your own implementation of `CollectionViewUpdater`, the only requirement is that object needs to conform to `StorageUpdating` protocol. This gives you full control on how and when `DTCollectionViewManager` will update `UICollectionView`.

### Conditional mappings

There can be cases, where you might want to customize mappings based on some criteria. For example, you might want to display model in several kinds of cells for different sections:

```swift
class FoodTextCell: UICollectionViewCell, ModelTransfer {
    func update(with model: Food) {
        // Text representation
    }
}

class FoodImageCell: UICollectionViewCell, ModelTransfer {
    func update(with model: Food) {
        // Photo representation
    }
}

manager.register(FoodTextCell.self) { mapping in mapping.condition = .section(0) }
manager.register(FoodImageCell.self) { mapping in mapping.condition = .section(1) }
```

Or you may implement completely custom conditions:

```swift
manager.register(FooCell.self) { mapping in
  mapping.condition = .custom({ indexPath, model in
    guard let model = model as? Int else { return false }
    return model > 2
  })
}
```

You can also change reuseIdentifier to be used:

```swift
manager.register(NibCell.self) { mapping in
    mapping.condition = .section(0)
    mapping.reuseIdentifier = "NibCell One"
}
controller.manager.registerNibNamed("CustomNibCell", for: NibCell.self) { mapping in
    mapping.condition = .section(1)
    mapping.reuseIdentifier = "NibCell Two"
}
```

### Anomaly handler

`DTCollectionViewManager` is built on some conventions. For example, your cell needs to have reuseIdentifier that matches the name of your class, XIB files need to be named also identical to the name of your class(to work with default mapping without customization). However when those conventions are not followed, or something unexpected happens, your app may crash or behave inconsistently. Most of the errors are reported by `UICollectionView` API, but there's space to improve.

 `DTTableViewManager` as well as `DTCollectionViewManager` and `DTModelStorage` now have dedicated anomaly analyzers, that try to find inconsistencies and programmer errors when using those frameworks. They detect stuff like missing mappings, inconsistencies in xib files, and even unused events. By default, detected anomalies will be printed in console while you are debugging your app. For example, if you try to register an empty xib to use for your cell, here's what you'll see in console:

```
??????[DTCollectionViewManager] Attempted to register xib EmptyXib for PostCell, but this xib does not contain any views.
```

Messages are prefixed, so for `DTTableViewManager` messages will have `[DTTableViewManager]` prefix.

By default, anomaly handler only prints information into console and does not do anything beyond that, but you can change it's behavior by assigning a custom handler for anomalies:

```swift
manager.anomalyHandler.anomalyAction = { anomaly in
  // invoke custom action
}
```

For example, you may want to send all detected anomalies to analytics you have in your app. For this case anomalies implement shorter description, that is more suitable for analytics, that often have limits for amount of data you can put in. To do that globally for all instances of `DTCollectionViewManager` that will be created during runtime of your app, set default action:

```swift
DTCollectionViewManagerAnomalyHandler.defaultAction = { anomaly in
  print(anomaly.debugDescription)

  analytics.postEvent("DTCollectionViewManager", anomaly.description)
}
```

If you use `DTTableViewManager` and `DTCollectionViewManager`, you can override 3 default actions for both manager frameworks and `DTModelStorage`, presumably during app initialization, before any views are loaded:

```swift
DTTableViewManagerAnomalyHandler.defaultAction = { anomaly in }
DTCollectionViewManagerAnomalyHandler.defaultAction = { anomaly in }
MemoryStorageAnomalyHandler.defaultAction = { anomaly in }
```

### Unregistering mappings

You can unregister cells, headers and footers from `DTCollectionViewManager` and `UICollectionView` by calling:

```swift
manager.unregister(FooCell.self)
manager.unregisterHeader(HeaderView.self)
manager.unregisterFooter(FooterView.self)
manager.unregisterSupplementary(SupplementaryView.self, forKind: "foo")
```

This is equivalent to calling collection view register methods with nil class or nil nib.

## Thanks

* [Alexey Belkevich](https://github.com/belkevich) for providing initial implementation of CellFactory.
* [Michael Fey](https://github.com/MrRooni) for providing insight into NSFetchedResultsController updates done right.
* [Nickolay Sheika](https://github.com/hawk-ukr) for great feedback, that helped shaping 3.0 release.
* [Artem Antihevich](https://github.com/sinarionn) for great discussions about Swift generics and type capturing.
