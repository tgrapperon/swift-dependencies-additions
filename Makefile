CONFIG = debug
PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iPhone)
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,id=$(call udid_for,TV)
PLATFORM_WATCHOS = watchOS Simulator,id=$(call udid_for,Watch)

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

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.7-focal \
		bash -c 'apt-get update && apt-get -y install make && make test-swift'

build-for-static-stdlib:
	@swift build -c debug --static-swift-stdlib
	@swift build -c release --static-swift-stdlib

build-for-library-evolution:
	swift build \
		-c release \
		--target DependenciesAdditions \
		-Xswiftc -emit-module-interface \
		-Xswiftc -enable-library-evolution

build-for-static-stdlib-docker:
	@docker run \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.8-focal \
		bash -c "swift build -c debug --static-swift-stdlib"
	@docker run \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.8-focal \
		bash -c "swift build -c release --static-swift-stdlib"

format:
	swift format \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		./Package.swift ./Sources ./Tests


.PHONY: test test-swift test-linux build-for-library-evolution format
