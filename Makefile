CONFIG = debug
PLATFORM_IOS = iOS Simulator,name=iPhone 15 Pro Max
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,name=Apple TV
PLATFORM_WATCHOS = watchOS Simulator,name=Apple Watch Series 7 (45mm)

CONFIG = debug

default: test-all

test-all:
	CONFIG=debug test-library
	CONFIG=release test-library

test-library:
	for platform in "$(PLATFORM_IOS)" "$(PLATFORM_MACOS)" "$(PLATFORM_MAC_CATALYST)" "$(PLATFORM_TVOS)" "$(PLATFORM_WATCHOS)"; do \
		xcodebuild test \
			-configuration $(CONFIG) \
			-workspace DependenciesAdditions.xcworkspace \
			-scheme DependenciesAdditions \
			-destination platform="$$platform" || exit 1; \
	done;


build-all-platforms:
	for platform in \
	  "$(PLATFORM_IOS)" \
	  "$(PLATFORM_MACOS)" \
	  "$(PLATFORM_MAC_CATALYST)" \
	  "$(PLATFORM_TVOS)" \
	  "$(PLATFORM_WATCHOS)"; \
	do \
		xcodebuild build \
			-workspace DependenciesAdditions.xcworkspace \
			-scheme DependenciesAdditions \
			-configuration $(CONFIG) \
			-destination platform="$$platform" || exit 1; \
	done;

test-swift:
	swift test
	swift test -c release

build-for-static-stdlib:
	@swift build -c debug --static-swift-stdlib
	@swift build -c release --static-swift-stdlib

build-for-library-evolution:
	swift build \
		-c release \
		--target DependenciesAdditions \
		-Xswiftc -enable-library-evolution

format:
	swift format \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		./Package.swift ./Sources ./Tests


.PHONY: test test-swift build-for-library-evolution format
