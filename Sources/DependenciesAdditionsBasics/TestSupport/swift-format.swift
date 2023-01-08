/// swift-format removes trailings semicolons to local @Dependency declarations, creating
/// compilations issues. We use this dummy function as a separator. We should ideally disable this
/// in some configuration file, but I can't find how to do it yet.
@_spi(Internals) public let __dummySeparator__: UInt8 = 0
