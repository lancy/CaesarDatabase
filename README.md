# CaesarDatabase

CaesarDatabase is a multi-keys-value store for you to persist data easily without SQL.

## Features

* Key value database, easy to use.
* Support multiple keys for complicated query.
* Access data with predicates.
* Batch reading and writting for performance.

As CaesarDatabase use sqlite as its engine, you can always access data via raw SQL.

## Requirements

Requires iOS 8 or later.

## Installation

###[Carthage](https://github.com/Carthage/Carthage#installing-carthage)

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "lancy/CaesarDatabase"
```

Then do `carthage update`. After that, add the framework to your project.

###[Cocoapods](https://github.com/CocoaPods/CocoaPods)

TODO

## Usages

TODO

## Acknowledgements
* [GRDB.swift](https://github.com/groue/GRDB.swift) CaesarDatabase is build on top of GRDB.swift, thanks for their great work.

## License
CaesarStore is available under the MIT license.