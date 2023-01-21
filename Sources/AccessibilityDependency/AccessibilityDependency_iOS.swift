#if os(iOS) || os(tvOS)
  import Dependencies
  @_spi(Internals) import DependenciesAdditionsBasics
  import Foundation
  import UIKit

  extension Accessibility: DependencyKey {
    public static var liveValue: Accessibility { .system }
    public static var testValue: Accessibility { .unimplemented }
    public static var previewValue: Accessibility { .system }
  }

  extension DependencyValues {
    /// A namespace for accessibility symbols for UIKit apps.
    public var accessibility: Accessibility {
      get { self[Accessibility.self] }
      set { self[Accessibility.self] = newValue }
    }
  }

  /// A namespace for accessibility symbols for UIKit apps.
  public struct Accessibility: Sendable, ConfigurableProxy {
    @_spi(Internals) public var _implementation: Implementation

    public struct Implementation: Sendable {
      @ReadOnlyProxy public var buttonShapesEnabled: Bool
      #if os(iOS)
        @ReadOnlyProxy public var hearingDevicePairedEar: UIAccessibility.HearingDeviceEar
      #endif
      @ReadOnlyProxy public var isAssistiveTouchRunning: Bool
      @ReadOnlyProxy public var isBoldTextEnabled: Bool
      @ReadOnlyProxy public var isClosedCaptioningEnabled: Bool
      @ReadOnlyProxy public var isDarkerSystemColorsEnabled: Bool
      @ReadOnlyProxy public var isGrayscaleEnabled: Bool
      @ReadOnlyProxy public var isGuidedAccessEnabled: Bool
      @ReadOnlyProxy public var isInvertColorsEnabled: Bool
      @ReadOnlyProxy public var isMonoAudioEnabled: Bool
      @ReadOnlyProxy public var isOnOffSwitchLabelsEnabled: Bool
      @ReadOnlyProxy public var isReduceMotionEnabled: Bool
      @ReadOnlyProxy public var isReduceTransparencyEnabled: Bool
      @ReadOnlyProxy public var isShakeToUndoEnabled: Bool
      @ReadOnlyProxy public var isSpeakScreenEnabled: Bool
      @ReadOnlyProxy public var isSpeakSelectionEnabled: Bool
      @ReadOnlyProxy public var isSwitchControlRunning: Bool
      @ReadOnlyProxy public var isVideoAutoplayEnabled: Bool
      @ReadOnlyProxy public var isVoiceOverRunning: Bool
      @ReadOnlyProxy public var prefersCrossFadeTransitions: Bool
      @ReadOnlyProxy public var shouldDifferentiateWithoutColor: Bool
      #if os(iOS)
        @FunctionProxy public var configureForGuidedAccess:
          @Sendable (UIGuidedAccessAccessibilityFeature, Bool) async throws -> Bool
      #endif
      @FunctionProxy public var convertToScreenCoordinatesUsingUIBezierPath:
        @Sendable (UIBezierPath, UIView) -> UIBezierPath
      @FunctionProxy public var convertToScreenCoordinatesUsingUIView:
        @Sendable (CGRect, UIView) -> CGRect
      @FunctionProxy public var focusedElement:
        @Sendable (UIAccessibility.AssistiveTechnologyIdentifier?) -> Any?
      @FunctionProxy public var guidedAccessRestrictionState:
        @Sendable (String) -> UIAccessibility.GuidedAccessRestrictionState
      @FunctionProxy public var post: @Sendable (UIAccessibility.Notification, Any?) -> Void
      @FunctionProxy public var registerGestureConflictWithZoom: @Sendable () -> Void
      @FunctionProxy public var requestGuidedAccessSession: @Sendable (Bool) async -> Bool
      @FunctionProxy public var zoomFocusChanged:
        @Sendable (UIAccessibility.ZoomType, CGRect, UIView) -> Void
    }
  }

  extension Accessibility {
    /// A Boolean value that indicates whether VoiceOver is in an enabled state.
    public var isVoiceOverRunning: Bool {
      _implementation.isVoiceOverRunning
    }

    /// A Boolean value that indicates whether the Mono Audio setting is in an enabled state.
    public var isMonoAudioEnabled: Bool {
      _implementation.isMonoAudioEnabled
    }

    /// A Boolean value that indicates whether the Closed Captions + SDH setting is
    public var isClosedCaptioningEnabled: Bool {
      _implementation.isClosedCaptioningEnabled
    }

    /// A Boolean value that indicates whether the Classic Invert setting is in
    /// an enabled state.
    public var isInvertColorsEnabled: Bool {
      _implementation.isInvertColorsEnabled
    }

    /// A Boolean value that indicates whether the Guided Access setting is in an enabled state.
    public var isGuidedAccessEnabled: Bool {
      _implementation.isGuidedAccessEnabled
    }

    /// A Boolean value that indicates whether the Bold Text setting is in an enabled state.
    public var isBoldTextEnabled: Bool {
      _implementation.isBoldTextEnabled
    }

    /// A Boolean value that indicates whether the Button Shapes setting is in an
    /// enabled state.
    @available(iOS 14.0, tvOS 14.0, *)
    public var buttonShapesEnabled: Bool {
      _implementation.buttonShapesEnabled
    }

    /// A Boolean value that indicates whether the Color Filters and the Grayscale
    /// settings are in an enabled state.
    public var isGrayscaleEnabled: Bool {
      _implementation.isGrayscaleEnabled
    }

    /// A Boolean value that indicates whether the Reduce Transparency setting is in
    /// an enabled state.
    public var isReduceTransparencyEnabled: Bool {
      _implementation.isReduceTransparencyEnabled
    }

    /// A Boolean value that indicates whether the Reduce Motion setting is in an enabled state.
    public var isReduceMotionEnabled: Bool {
      _implementation.isReduceMotionEnabled
    }

    /// A Boolean value that indicates whether the Reduce Motion and the Prefer Cross-Fade
    /// Transitions settings are in an enabled state.
    @available(iOS 14.0, tvOS 14.0, *)
    public var prefersCrossFadeTransitions: Bool {
      _implementation.prefersCrossFadeTransitions
    }

    /// A Boolean value that indicates whether the Auto-Play Video Previews setting
    /// is in an enabled state.
    public var isVideoAutoplayEnabled: Bool {
      _implementation.isVideoAutoplayEnabled
    }

    /// A Boolean value that indicates whether the Increase Contrast setting is in
    /// an enabled state.
    public var isDarkerSystemColorsEnabled: Bool {
      _implementation.isDarkerSystemColorsEnabled
    }

    /// A Boolean value that indicates whether the Switch Control setting is in an
    /// enabled state.
    public var isSwitchControlRunning: Bool {
      _implementation.isSwitchControlRunning
    }

    /// A Boolean value that indicates whether the Speak Selection setting is in an
    /// enabled state.
    public var isSpeakSelectionEnabled: Bool {
      _implementation.isSpeakSelectionEnabled
    }

    /// A Boolean value that indicates whether the Speak Screen setting is in an
    /// enabled state.
    public var isSpeakScreenEnabled: Bool {
      _implementation.isSpeakScreenEnabled
    }

    /// A Boolean value that indicates whether the Shake to Undo setting is in an enabled state.
    public var isShakeToUndoEnabled: Bool {
      _implementation.isShakeToUndoEnabled
    }

    /// A Boolean value that indicates whether AssistiveTouch is in an enabled state.
    public var isAssistiveTouchRunning: Bool {
      _implementation.isAssistiveTouchRunning
    }

    /// A Boolean value that indicates whether the Differentiate Without Color setting
    /// is in an enabled state.
    public var shouldDifferentiateWithoutColor: Bool {
      _implementation.shouldDifferentiateWithoutColor
    }

    /// A Boolean value that indicates whether the On/Off Labels setting is in an
    /// enabled state.
    public var isOnOffSwitchLabelsEnabled: Bool {
      _implementation.isOnOffSwitchLabelsEnabled
    }

    #if os(iOS)
      /// The current pairing status of Made for iPhone hearing devices.
      public var hearingDevicePairedEar: UIAccessibility.HearingDeviceEar {
        _implementation.hearingDevicePairedEar
      }
    #endif

    /// Converts the specified rectangle from view coordinates to screen coordinates.
    public func convertToScreenCoordinates(_ rect: CGRect, in view: UIView) -> CGRect {
      _implementation.convertToScreenCoordinatesUsingUIView(rect, view)
    }

    /// Converts the specified path object to screen coordinates and returns a new path
    /// object with the results.
    public func convertToScreenCoordinates(_ path: UIBezierPath, in view: UIView) -> UIBezierPath {
      _implementation.convertToScreenCoordinatesUsingUIBezierPath(path, view)
    }

    /// Returns the accessibility element that’s currently in focus by the specified
    /// assistive app.
    public func focusedElement(
      using assistiveTechnologyIdentifier: UIAccessibility.AssistiveTechnologyIdentifier?
    ) -> Any? {
      _implementation.focusedElement(assistiveTechnologyIdentifier)
    }

    /// Posts a notification to assistive apps.
    public func post(notification: UIAccessibility.Notification, argument: Any?) {
      _implementation.post(notification, argument)
    }

    /// Transitions the app to or from Single App mode asynchronously.
    public func requestGuidedAccessSession(enabled enable: Bool) async -> Bool {
      await _implementation.requestGuidedAccessSession(enable)
    }
    #if os(iOS)
      /// Enables or disables the specified accessibility features while using Guided Access.
      public func configureForGuidedAccess(
        features: UIGuidedAccessAccessibilityFeature,
        enabled: Bool
      ) async throws -> Bool {
        try await _implementation.configureForGuidedAccess(features, enabled)
      }
    #endif
    /// Returns the restriction state for the specified guided access restriction.
    public func guidedAccessRestrictionState(forIdentifier restrictionIdentifier: String)
      -> UIAccessibility.GuidedAccessRestrictionState
    {
      _implementation.guidedAccessRestrictionState(restrictionIdentifier)
    }

    /// Warns users that app-specific gestures conflict with the system-defined Zoom accessibility
    /// gestures.
    public func registerGestureConflictWithZoom() {
      _implementation.registerGestureConflictWithZoom()
    }

    /// Notifies the system when the app’s focus changes to a new location.
    public func zoomFocusChanged(
      zoomType type: UIAccessibility.ZoomType,
      toFrame frame: CGRect,
      in view: UIView
    ) {
      _implementation.zoomFocusChanged(type, frame, view)
    }
  }

  extension Accessibility {
    static var system: Accessibility {
      #if os(iOS)
        Accessibility(
          _implementation: .init(
            buttonShapesEnabled: .init {
              if #available(iOS 14.0, tvOS 14.0, *) {
                return UIAccessibility.buttonShapesEnabled
              } else {
                return false
              }
            },
            hearingDevicePairedEar: .init { UIAccessibility.hearingDevicePairedEar },
            isAssistiveTouchRunning: .init { UIAccessibility.isAssistiveTouchRunning },
            isBoldTextEnabled: .init { UIAccessibility.isBoldTextEnabled },
            isClosedCaptioningEnabled: .init { UIAccessibility.isClosedCaptioningEnabled },
            isDarkerSystemColorsEnabled: .init { UIAccessibility.isDarkerSystemColorsEnabled },
            isGrayscaleEnabled: .init { UIAccessibility.isGrayscaleEnabled },
            isGuidedAccessEnabled: .init { UIAccessibility.isGuidedAccessEnabled },
            isInvertColorsEnabled: .init { UIAccessibility.isInvertColorsEnabled },
            isMonoAudioEnabled: .init { UIAccessibility.isMonoAudioEnabled },
            isOnOffSwitchLabelsEnabled: .init { UIAccessibility.isOnOffSwitchLabelsEnabled },
            isReduceMotionEnabled: .init { UIAccessibility.isReduceMotionEnabled },
            isReduceTransparencyEnabled: .init { UIAccessibility.isReduceTransparencyEnabled },
            isShakeToUndoEnabled: .init { UIAccessibility.isShakeToUndoEnabled },
            isSpeakScreenEnabled: .init { UIAccessibility.isSpeakScreenEnabled },
            isSpeakSelectionEnabled: .init { UIAccessibility.isSpeakSelectionEnabled },
            isSwitchControlRunning: .init { UIAccessibility.isSwitchControlRunning },
            isVideoAutoplayEnabled: .init { UIAccessibility.isVideoAutoplayEnabled },
            isVoiceOverRunning: .init { UIAccessibility.isVoiceOverRunning },
            prefersCrossFadeTransitions: .init {
              if #available(iOS 14.0, tvOS 14.0, *) {
                return UIAccessibility.prefersCrossFadeTransitions
              } else {
                return false
              }
            },
            shouldDifferentiateWithoutColor: .init {
              UIAccessibility.shouldDifferentiateWithoutColor
            },
            configureForGuidedAccess:
              .init {
                { features, enabled in
                  try await withUnsafeThrowingContinuation { continuation in
                    UIAccessibility.configureForGuidedAccess(features: features, enabled: enabled) {
                      enabled, error in
                      if let error {
                        continuation.resume(with: .failure(error))
                      } else {
                        continuation.resume(with: .success(enabled))
                      }
                    }
                  }
                }
              },
            convertToScreenCoordinatesUsingUIBezierPath:
              .init { { UIAccessibility.convertToScreenCoordinates($0, in: $1) } },
            convertToScreenCoordinatesUsingUIView:
              .init { { UIAccessibility.convertToScreenCoordinates($0, in: $1) } },
            focusedElement:
              .init { { UIAccessibility.focusedElement(using: $0) } },
            guidedAccessRestrictionState:
              .init { { UIAccessibility.guidedAccessRestrictionState(forIdentifier: $0) } },
            post: .init { { UIAccessibility.post(notification: $0, argument: $1) } },
            registerGestureConflictWithZoom: .init {
              { UIAccessibility.registerGestureConflictWithZoom() }
            },
            requestGuidedAccessSession: .init {
              { enabled in
                await withUnsafeContinuation { continuation in
                  UIAccessibility.requestGuidedAccessSession(enabled: enabled) {
                    continuation.resume(returning: $0)
                  }
                }
              }
            },
            zoomFocusChanged: .init {
              {
                UIAccessibility.zoomFocusChanged(zoomType: $0, toFrame: $1, in: $2)
              }
            }
          )
        )
      #elseif os(tvOS)
        Accessibility(
          _implementation: .init(
            buttonShapesEnabled: .init {
              if #available(iOS 14.0, tvOS 14.0, *) {
                return UIAccessibility.buttonShapesEnabled
              } else {
                return false
              }
            },
            isAssistiveTouchRunning: .init { UIAccessibility.isAssistiveTouchRunning },
            isBoldTextEnabled: .init { UIAccessibility.isBoldTextEnabled },
            isClosedCaptioningEnabled: .init { UIAccessibility.isClosedCaptioningEnabled },
            isDarkerSystemColorsEnabled: .init { UIAccessibility.isDarkerSystemColorsEnabled },
            isGrayscaleEnabled: .init { UIAccessibility.isGrayscaleEnabled },
            isGuidedAccessEnabled: .init { UIAccessibility.isGuidedAccessEnabled },
            isInvertColorsEnabled: .init { UIAccessibility.isInvertColorsEnabled },
            isMonoAudioEnabled: .init { UIAccessibility.isMonoAudioEnabled },
            isOnOffSwitchLabelsEnabled: .init { UIAccessibility.isOnOffSwitchLabelsEnabled },
            isReduceMotionEnabled: .init { UIAccessibility.isReduceMotionEnabled },
            isReduceTransparencyEnabled: .init { UIAccessibility.isReduceTransparencyEnabled },
            isShakeToUndoEnabled: .init { UIAccessibility.isShakeToUndoEnabled },
            isSpeakScreenEnabled: .init { UIAccessibility.isSpeakScreenEnabled },
            isSpeakSelectionEnabled: .init { UIAccessibility.isSpeakSelectionEnabled },
            isSwitchControlRunning: .init { UIAccessibility.isSwitchControlRunning },
            isVideoAutoplayEnabled: .init { UIAccessibility.isVideoAutoplayEnabled },
            isVoiceOverRunning: .init { UIAccessibility.isVoiceOverRunning },
            prefersCrossFadeTransitions: .init {
              if #available(iOS 14.0, tvOS 14.0, *) {
                return UIAccessibility.prefersCrossFadeTransitions
              } else {
                return false
              }
            },
            shouldDifferentiateWithoutColor: .init {
              UIAccessibility.shouldDifferentiateWithoutColor
            },
            convertToScreenCoordinatesUsingUIBezierPath:
              .init { { UIAccessibility.convertToScreenCoordinates($0, in: $1) } },
            convertToScreenCoordinatesUsingUIView:
              .init { { UIAccessibility.convertToScreenCoordinates($0, in: $1) } },
            focusedElement:
              .init { { UIAccessibility.focusedElement(using: $0) } },
            guidedAccessRestrictionState:
              .init { { UIAccessibility.guidedAccessRestrictionState(forIdentifier: $0) } },
            post: .init { { UIAccessibility.post(notification: $0, argument: $1) } },
            registerGestureConflictWithZoom: .init {
              { UIAccessibility.registerGestureConflictWithZoom() }
            },
            requestGuidedAccessSession: .init {
              { enabled in
                await withUnsafeContinuation { continuation in
                  UIAccessibility.requestGuidedAccessSession(enabled: enabled) {
                    continuation.resume(returning: $0)
                  }
                }
              }
            },
            zoomFocusChanged: .init {
              {
                UIAccessibility.zoomFocusChanged(zoomType: $0, toFrame: $1, in: $2)
              }
            }
          )
        )
      #endif
    }

    public static var unimplemented: Accessibility {
      #if os(iOS)
        .init(
          _implementation: Implementation(
            buttonShapesEnabled: .unimplemented(
              #"@Dependency(\.accessibility.buttonShapesEnabled)"#),
            hearingDevicePairedEar: .unimplemented(
              #"@Dependency(\.accessibility.hearingDevicePairedEar)"#, placeholder: []),
            isAssistiveTouchRunning: .unimplemented(
              #"@Dependency(\.accessibility.isAssistiveTouchRunning)"#),
            isBoldTextEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isBoldTextEnabled)"#),
            isClosedCaptioningEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isClosedCaptioningEnabled)"#),
            isDarkerSystemColorsEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isDarkerSystemColorsEnabled)"#),
            isGrayscaleEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isGrayscaleEnabled)"#),
            isGuidedAccessEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isGuidedAccessEnabled)"#),
            isInvertColorsEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isInvertColorsEnabled)"#),
            isMonoAudioEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isMonoAudioEnabled)"#),
            isOnOffSwitchLabelsEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isOnOffSwitchLabelsEnabled)"#),
            isReduceMotionEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isReduceMotionEnabled)"#),
            isReduceTransparencyEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isReduceTransparencyEnabled)"#),
            isShakeToUndoEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isShakeToUndoEnabled)"#),
            isSpeakScreenEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isSpeakScreenEnabled)"#),
            isSpeakSelectionEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isSpeakSelectionEnabled)"#),
            isSwitchControlRunning: .unimplemented(
              #"@Dependency(\.accessibility.isSwitchControlRunning)"#),
            isVideoAutoplayEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isVideoAutoplayEnabled)"#),
            isVoiceOverRunning: .unimplemented(
              #"@Dependency(\.accessibility.isVoiceOverRunning)"#),
            prefersCrossFadeTransitions: .unimplemented(
              #"@Dependency(\.accessibility.prefersCrossFadeTransitions)"#),
            shouldDifferentiateWithoutColor: .unimplemented(
              #"@Dependency(\.accessibility.shouldDifferentiateWithoutColor)"#),
            configureForGuidedAccess: .unimplemented(
              #"@Dependency(\.accessibility.configureForGuidedAccess)"#),
            convertToScreenCoordinatesUsingUIBezierPath: .unimplemented(
              #"@Dependency(\.accessibility.convertToScreenCoordinatesUsingUIBezierPath)"#,
              placeholder: { _, _ in UIBezierPath() }),
            convertToScreenCoordinatesUsingUIView: .unimplemented(
              #"@Dependency(\.accessibility.convertToScreenCoordinatesUsingUIView)"#,
              placeholder: { _, _ in .zero }),
            focusedElement: .unimplemented(
              #"@Dependency(\.accessibility.focusedElement)"#,
              placeholder: { _ in nil }),
            guidedAccessRestrictionState: .unimplemented(
              #"@Dependency(\.accessibility.guidedAccessRestrictionState)"#,
              placeholder: { _ in .deny }),
            post: .unimplemented(
              #"@Dependency(\.accessibility.post)"#, placeholder: { _, _ in () }),
            registerGestureConflictWithZoom: .unimplemented(
              #"@Dependency(\.accessibility.registerGestureConflictWithZoom)"#),
            requestGuidedAccessSession: .unimplemented(
              #"@Dependency(\.accessibility.requestGuidedAccessSession)"#),
            zoomFocusChanged: .unimplemented(
              #"@Dependency(\.accessibility.zoomFocusChanged)"#)
          )
        )
      #elseif os(tvOS)
        .init(
          _implementation: Implementation(
            buttonShapesEnabled: .unimplemented(
              #"@Dependency(\.accessibility.buttonShapesEnabled)"#),
            isAssistiveTouchRunning: .unimplemented(
              #"@Dependency(\.accessibility.isAssistiveTouchRunning)"#),
            isBoldTextEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isBoldTextEnabled)"#),
            isClosedCaptioningEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isClosedCaptioningEnabled)"#),
            isDarkerSystemColorsEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isDarkerSystemColorsEnabled)"#),
            isGrayscaleEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isGrayscaleEnabled)"#),
            isGuidedAccessEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isGuidedAccessEnabled)"#),
            isInvertColorsEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isInvertColorsEnabled)"#),
            isMonoAudioEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isMonoAudioEnabled)"#),
            isOnOffSwitchLabelsEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isOnOffSwitchLabelsEnabled)"#),
            isReduceMotionEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isReduceMotionEnabled)"#),
            isReduceTransparencyEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isReduceTransparencyEnabled)"#),
            isShakeToUndoEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isShakeToUndoEnabled)"#),
            isSpeakScreenEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isSpeakScreenEnabled)"#),
            isSpeakSelectionEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isSpeakSelectionEnabled)"#),
            isSwitchControlRunning: .unimplemented(
              #"@Dependency(\.accessibility.isSwitchControlRunning)"#),
            isVideoAutoplayEnabled: .unimplemented(
              #"@Dependency(\.accessibility.isVideoAutoplayEnabled)"#),
            isVoiceOverRunning: .unimplemented(
              #"@Dependency(\.accessibility.isVoiceOverRunning)"#),
            prefersCrossFadeTransitions: .unimplemented(
              #"@Dependency(\.accessibility.prefersCrossFadeTransitions)"#),
            shouldDifferentiateWithoutColor: .unimplemented(
              #"@Dependency(\.accessibility.shouldDifferentiateWithoutColor)"#),
            convertToScreenCoordinatesUsingUIBezierPath: .unimplemented(
              #"@Dependency(\.accessibility.convertToScreenCoordinatesUsingUIBezierPath)"#,
              placeholder: { _, _ in UIBezierPath() }),
            convertToScreenCoordinatesUsingUIView: .unimplemented(
              #"@Dependency(\.accessibility.convertToScreenCoordinatesUsingUIView)"#,
              placeholder: { _, _ in .zero }),
            focusedElement: .unimplemented(
              #"@Dependency(\.accessibility.focusedElement)"#,
              placeholder: { _ in nil }),
            guidedAccessRestrictionState: .unimplemented(
              #"@Dependency(\.accessibility.guidedAccessRestrictionState)"#,
              placeholder: { _ in .deny }),
            post: .unimplemented(
              #"@Dependency(\.accessibility.post)"#, placeholder: { _, _ in () }),
            registerGestureConflictWithZoom: .unimplemented(
              #"@Dependency(\.accessibility.registerGestureConflictWithZoom)"#),
            requestGuidedAccessSession: .unimplemented(
              #"@Dependency(\.accessibility.requestGuidedAccessSession)"#),
            zoomFocusChanged: .unimplemented(
              #"@Dependency(\.accessibility.zoomFocusChanged)"#)
          )
        )
      #endif
    }
  }
#endif
