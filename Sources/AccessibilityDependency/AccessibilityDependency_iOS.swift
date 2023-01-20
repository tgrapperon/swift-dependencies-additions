import Dependencies
@_spi(Internals) import DependenciesAdditionsBasics
import Foundation
import XCTestDynamicOverlay

import UIKit

extension Accessibility: DependencyKey {
  public static var liveValue: Accessibility { .shared }
  public static var testValue: Accessibility { .unimplemented }
  public static var previewValue: Accessibility { .shared }
}

extension DependencyValues {
  /// The centralized accessibility state for apps running in iOS.
  public var accessibility: Accessibility {
    get { self[Accessibility.self] }
    set { self[Accessibility.self] = newValue }
  }
}

/// The centralized accessibility state for apps running in iOS.
public struct Accessibility: Sendable, ConfigurableProxy {
  @_spi(Internals) public var _implementation: Implementation

  // MARK: Modes & Notification Names

  /// A Boolean value that indicates whether VoiceOver is in an enabled state.
  ///
  /// You can use this function to customize your app’s UI specifically for VoiceOver users.
  /// For example, you might want UI elements that usually disappear quickly to persist
  /// onscreen for VoiceOver users. Note that you can also listen for the
  /// ``voiceOverStatusDidChangeNotification`` notification to determine
  /// when VoiceOver starts and stops.
  @MainActor
  @available(iOS 4.0, *)
  public var isVoiceOverRunning: Bool {
    _implementation.isVoiceOverRunning
  }

  /// A notification that UIKit posts when VoiceOver starts or stops.
  ///
  /// Use this notification to customize your app's UI for VoiceOver users. For example,
  /// if you display a UI element that briefly overlays other parts of your UI, you can make
  /// the display persistent for VoiceOver users, but allow it to not appear for users who
  /// aren't using VoiceOver. You can also use the isVoiceOverRunning function to determine
  /// whether VoiceOver is currently running.
  ///
  /// Use the ``isVoiceOverRunning`` function to determine whether the
  /// settings for VoiceOver are in an enabled state.
  @MainActor
  @available(iOS 11.0, *)
  public var voiceOverStatusDidChangeNotification: NSNotification.Name {
    _implementation.voiceOverStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Mono Audio setting is in an enabled state.
  ///
  /// Note that you can also listen for the ``monoAudioStatusDidChangeNotification``
  /// notification to determine when Mono Audio setting is enabled and disabled.
  @MainActor
  @available(iOS 5.0, *)
  public var isMonoAudioEnabled: Bool {
    _implementation.isMonoAudioEnabled
  }

  /// A notification that UIKit posts when system audio changes from stereo to mono.
  ///
  /// Use the ``isMonoAudioEnabled`` function to determine whether the
  /// settings for mono audio are in an enabled state.
  @MainActor
  @available(iOS 5.0, *)
  public var monoAudioStatusDidChangeNotification: NSNotification.Name {
    _implementation.monoAudioStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Closed Captions + SDH setting is
  /// in an enabled state.
  ///
  /// Note that you can also listen for the ``closedCaptioningStatusDidChangeNotification``
  /// notification to determine when Closed Captions is enabled and disabled.
  @MainActor
  @available(iOS 5.0, *)
  public var isClosedCaptioningEnabled: Bool {
    _implementation.isClosedCaptioningEnabled
  }

  /// A notification that UIKit posts when the setting for Closed Captions + SDH
  /// changes.
  ///
  /// Use the ``isClosedCaptioningEnabled`` function to determine whether the
  /// settings for closed captioning are in an enabled state.
  @MainActor
  @available(iOS 5.0, *)
  public var closedCaptioningStatusDidChangeNotification: NSNotification.Name {
    _implementation.closedCaptioningStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Classic Invert setting is in
  /// an enabled state.
  ///
  /// Note that you can also listen for the ``invertColorsStatusDidChangeNotification``
  /// notification to determine when Classic Invert setting is enabled and disabled.
  @MainActor
  @available(iOS 6.0, *)
  public var isInvertColorsEnabled: Bool {
    _implementation.isInvertColorsEnabled
  }

  /// A notification that UIKit posts when the settings for inverted colors change.
  ///
  /// Use the ``isInvertColorsEnabled`` function to determine whether the settings for
  /// inverted colors are in an enabled state.
  @MainActor
  @available(iOS 6.0, *)
  public var invertColorsStatusDidChangeNotification: NSNotification.Name {
    _implementation.invertColorsStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Guided Access setting is in an enabled state.
  ///
  /// Note that you can also listen for the ``guidedAccessStatusDidChangeNotification``
  /// notification to determine when the Guided Access setting is enabled and disabled.
  @MainActor
  @available(iOS 6.0, *)
  public var isGuidedAccessEnabled: Bool {
    _implementation.isGuidedAccessEnabled
  }

  /// A notification that indicates when a Guided Access session starts or ends.
  ///
  /// Use the ``isGuidedAccessEnabled`` function to determine whether a Guided
  /// Access session is currently active.
  @MainActor
  @available(iOS 6.0, *)
  public var guidedAccessStatusDidChangeNotification: NSNotification.Name {
    _implementation.guidedAccessStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Bold Text setting is in an enabled state.
  ///
  /// Note that you can also listen for the ``boldTextStatusDidChangeNotification``
  /// notification to determine when Bold Text has been enabled and disabled.
  @MainActor
  @available(iOS 8.0, *)
  public var isBoldTextEnabled: Bool {
    _implementation.isBoldTextEnabled
  }

  /// A notification that UIKit posts when the system’s Bold Text setting changes.
  ///
  /// Use the ``isBoldTextEnabled`` function to determine whether a Guided
  /// Access session is currently active.
  @MainActor
  @available(iOS 8.0, *)
  public var boldTextStatusDidChangeNotification: NSNotification.Name {
    _implementation.boldTextStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Button Shapes setting is in an
  /// enabled state.
  ///
  /// Note that you can also listen for the ``buttonShapesEnabledStatusDidChangeNotification``
  /// notification to determine when Button Shapes mode has been enabled and disabled.
  @MainActor
  @available(iOS 14.0, *)
  public var buttonShapesEnabled: Bool {
    _implementation.buttonShapesEnabled
  }

  /// A notification that UIKit posts when the system’s Button Shapes setting changes.
  ///
  /// Use the ``buttonShapesEnabled`` function to determine whether the Button
  /// Shapes settings is currently enabled.
  @MainActor
  @available(iOS 14.0, *)
  public var buttonShapesEnabledStatusDidChangeNotification: NSNotification.Name {
    _implementation.buttonShapesEnabledStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Color Filters and the Grayscale
  /// settings are in an enabled state.
  ///
  /// Note that you can also listen for the ``grayscaleStatusDidChangeNotification``
  /// notification to determine when the Grayscale settings has been enabled and disabled.
  @MainActor
  @available(iOS 8.0, *)
  public var isGrayscaleEnabled: Bool {
    _implementation.isGrayscaleEnabled
  }

  /// A notification that UIKit posts when the system’s Grayscale setting changes.
  ///
  /// Use the ``isGrayscaleEnabled`` function to determine whether the Grayscale
  /// settings is currently enabled.
  @MainActor
  @available(iOS 8.0, *)
  public var grayscaleStatusDidChangeNotification: NSNotification.Name {
    _implementation.grayscaleStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Reduce Transparency setting is in
  /// an enabled state.
  ///
  /// Note that you can also listen for the ``reduceTransparencyStatusDidChangeNotification``
  /// notification to determine when the Reduce Transparency settings has been enabled
  /// and disabled.
  @MainActor
  @available(iOS 8.0, *)
  public var isReduceTransparencyEnabled: Bool {
    _implementation.isReduceTransparencyEnabled
  }

  /// A notification that UIKit posts when the system’s Reduce Transparency setting changes.
  ///
  /// Use the ``isReduceTransparencyEnabled`` function to determine whether the
  /// Reduce Transparency settings is currently enabled.
  @MainActor
  @available(iOS 8.0, *)
  public var reduceTransparencyStatusDidChangeNotification: NSNotification.Name {
    _implementation.reduceTransparencyStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Reduce Motion setting is in an enabled state.
  ///
  /// Note that you can also listen for the ``reduceMotionStatusDidChangeNotification``
  /// notification to determine when the Reduce Motion settings has been enabled and disabled.
  @MainActor
  @available(iOS 8.0, *)
  public var isReduceMotionEnabled: Bool {
    _implementation.isReduceMotionEnabled
  }

  /// A notification that UIKit posts when the system’s Reduce Motion setting changes.
  ///
  /// Use the ``isReduceMotionEnabled`` function to determine whether the Reduce
  /// Motion settings is currently enabled.
  @MainActor
  @available(iOS 8.0, *)
  public var reduceMotionStatusDidChangeNotification: NSNotification.Name {
    _implementation.reduceMotionStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Reduce Motion and the Prefer Cross-Fade
  /// Transitions settings are in an enabled state.
  ///
  /// Note that you can also listen for the ``prefersCrossFadeTransitionsStatusDidChange``
  /// notification to determine when the Reduce Motion settings has been enabled and
  /// disabled.
  @MainActor
  @available(iOS 14.0, *)
  public var prefersCrossFadeTransitions: Bool {
    _implementation.prefersCrossFadeTransitions
  }

  /// A notification that UIKit posts when the system’s Prefer Cross-Fade Transitions
  /// setting changes.
  ///
  /// Use the ``prefersCrossFadeTransitions`` function to determine whether
  /// the Prefer Cross-Fade Transitions settings is currently enabled.
  @MainActor
  @available(iOS 14.0, *)
  public var prefersCrossFadeTransitionsStatusDidChange: NSNotification.Name {
    _implementation.prefersCrossFadeTransitionsStatusDidChange
  }

  /// A Boolean value that indicates whether the Auto-Play Video Previews setting
  /// is in an enabled state.
  ///
  /// Note that you can also listen for the ``videoAutoplayStatusDidChangeNotification``
  /// notification to determine when the Auto-Play Video Previews settings has been
  /// enabled and disabled.
  @MainActor
  @available(iOS 13.0, *)
  public var isVideoAutoplayEnabled: Bool {
    _implementation.isVideoAutoplayEnabled
  }

  /// A notification that UIKit posts when the system’s Auto-Play Video Previews setting
  /// changes.
  ///
  /// Use the ``isVideoAutoplayEnabled`` function to determine whether
  /// the Auto-Play Video Previews settings is currently enabled.
  @MainActor
  @available(iOS 13.0, *)
  public var videoAutoplayStatusDidChangeNotification: NSNotification.Name {
    _implementation.videoAutoplayStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Increase Contrast setting is in
  /// an enabled state.
  ///
  /// Note that you can also listen for the ``darkerSystemColorsStatusDidChangeNotification``
  /// notification to determine when the Increase Contrast settings has been
  /// enabled and disabled.
  @MainActor
  @available(iOS 8.0, *)
  public var isDarkerSystemColorsEnabled: Bool {
    _implementation.isDarkerSystemColorsEnabled
  }

  /// A notification that UIKit posts when the system’s Increase Contrast setting changes.
  ///
  /// Use the ``isDarkerSystemColorsEnabled`` function to determine whether
  /// the Increase Contrast settings is currently enabled.
  @MainActor
  @available(iOS 8.0, *)
  public var darkerSystemColorsStatusDidChangeNotification: NSNotification.Name {
    _implementation.darkerSystemColorsStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Switch Control setting is in an
  /// enabled state.
  ///
  /// Note that you can also listen for the ``switchControlStatusDidChangeNotification``
  /// notification to determine when Switch Control starts and stops.
  @MainActor
  @available(iOS 8.0, *)
  public var isSwitchControlRunning: Bool {
    _implementation.isSwitchControlRunning
  }

  /// A notification that UIKit posts when the system’s Switch Control setting changes.
  ///
  /// Use the ``isSwitchControlRunning`` function to determine whether
  /// the Switch Control session is currently active.
  @MainActor
  @available(iOS 8.0, *)
  public var switchControlStatusDidChangeNotification: NSNotification.Name {
    _implementation.switchControlStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Speak Selection setting is in an
  /// enabled state.
  ///
  /// Note that you can also listen for the ``speakSelectionStatusDidChangeNotification``
  /// notification to determine when the Speak Selection settings has been
  /// enabled and disabled.
  @MainActor
  @available(iOS 8.0, *)
  public var isSpeakSelectionEnabled: Bool {
    _implementation.isSpeakSelectionEnabled
  }

  /// A notification that UIKit posts when the system’s Speak Selection setting changes.
  ///
  /// Use the ``isSpeakSelectionEnabled`` function to determine whether
  /// the Speak Selection settings is currently enabled.
  @MainActor
  @available(iOS 8.0, *)
  public var speakSelectionStatusDidChangeNotification: NSNotification.Name {
    _implementation.speakSelectionStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Speak Screen setting is in an
  /// enabled state.
  ///
  /// Note that you can also listen for the ``speakScreenStatusDidChangeNotification``
  /// notification to determine when the Speak Screen settings has been enabled
  /// and disabled.
  @MainActor
  @available(iOS 8.0, *)
  public var isSpeakScreenEnabled: Bool {
    _implementation.isSpeakScreenEnabled
  }

  /// A notification that UIKit posts when the system’s Speak Screen setting changes.
  ///
  /// Use the ``isSpeakScreenEnabled`` function to determine whether the
  /// Speak Screen settings is currently enabled.
  @MainActor
  @available(iOS 8.0, *)
  public var speakScreenStatusDidChangeNotification: NSNotification.Name {
    _implementation.speakScreenStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Shake to Undo setting is in an enabled state.
  ///
  /// Note that you can also listen for the ``shakeToUndoDidChangeNotification``
  /// notification to determine when the Shake to Undo settings has been enabled
  /// and disabled.
  @MainActor
  @available(iOS 9.0, *)
  public var isShakeToUndoEnabled: Bool {
    _implementation.isShakeToUndoEnabled
  }

  /// A notification that UIKit posts when the system's Shake to Undo setting changes.
  ///
  /// Use the ``isShakeToUndoEnabled`` function to determine whether the
  /// Shake to Undo settings is currently enabled.
  @MainActor
  @available(iOS 9.0, *)
  public var shakeToUndoDidChangeNotification: NSNotification.Name {
    _implementation.shakeToUndoDidChangeNotification
  }

  /// A Boolean value that indicates whether AssistiveTouch is in an enabled state.
  ///
  /// Note that you can also listen for the ``assistiveTouchStatusDidChangeNotification``
  /// notification to determine when the AssistiveTouch session starts and stops
  @MainActor
  @available(iOS 10.0, *)
  public var isAssistiveTouchRunning: Bool {
    _implementation.isAssistiveTouchRunning
  }

  /// A notification that indicates a change in the status of AssistiveTouch.
  ///
  /// The user must enable Guided Access for this notification to post.
  ///
  /// Use the ``isAssistiveTouchRunning`` function to determine whether
  /// the AssistiveTouch session is currently active.
  @MainActor
    @available(iOS 10.0, *)
  public var assistiveTouchStatusDidChangeNotification: NSNotification.Name {
    _implementation.assistiveTouchStatusDidChangeNotification
  }

  /// A Boolean value that indicates whether the Differentiate Without Color setting
  /// is in an enabled state.
  ///
  /// Note that you can also listen for the ``differentiateWithoutColorDidChangeNotification``
  /// notification to determine when the Differentiate Without Color settings has been
  /// enabled and disabled.
  @MainActor
  @available(iOS 13.0, *)
  public var shouldDifferentiateWithoutColor: Bool {
    _implementation.shouldDifferentiateWithoutColor
  }

  /// A notification that UIKit posts when the system’s Differentiate Without Color
  /// setting changes.
  ///
  /// Use the ``shouldDifferentiateWithoutColor`` function to determine
  /// whether the Differentiate Without Color settings is currently enabled.
  @MainActor
  @available(iOS 13.0, *)
  public var differentiateWithoutColorDidChangeNotification: NSNotification.Name {
    _implementation.differentiateWithoutColorDidChangeNotification
  }

  /// A Boolean value that indicates whether the On/Off Labels setting is in an
  /// enabled state.
  ///
  /// Note that you can also listen for the ``onOffSwitchLabelsDidChangeNotification``
  /// notification to determine when the On/Off Labels settings has been enabled
  /// and disabled.
  @MainActor
  @available(iOS 13.0, *)
  public var isOnOffSwitchLabelsEnabled: Bool {
    _implementation.isOnOffSwitchLabelsEnabled
  }

  /// A notification that UIKit posts when the system’s On/Off Labels setting changes.
  ///
  /// Use the ``isOnOffSwitchLabelsEnabled`` function to determine
  /// whether the On/Off Labels settings is currently enabled.
  @MainActor
  @available(iOS 13.0, *)
  public var onOffSwitchLabelsDidChangeNotification: NSNotification.Name {
    _implementation.onOffSwitchLabelsDidChangeNotification
  }

  /// The current pairing status of Made for iPhone hearing devices.
  ///
  /// Note that you can also listen for the ``hearingDevicePairedEarDidChangeNotification``
  /// notification to determine when the hearing devices currently paired have
  /// been updated.
  @MainActor
  @available(iOS 10.0, *)
  public var hearingDevicePairedEar: UIAccessibility.HearingDeviceEar {
    _implementation.hearingDevicePairedEar
  }

  /// A notification that UIKit posts when there is a change to the currently paired
  /// hearing devices.
  ///
  /// Use the ``hearingDevicePairedEar`` function to determine which hearing
  /// devices are currently paired.
  @MainActor
  @available(iOS 10.0, *)
  public var hearingDevicePairedEarDidChangeNotification: NSNotification.Name {
    _implementation.hearingDevicePairedEarDidChangeNotification
  }

  // MARK: Functions

  /// Converts the specified rectangle from view coordinates to screen coordinates.
  /// - Parameters:
  ///   - rect: A rectangle specified in the coordinate system of the specified view.
  ///   - view: The view that contains the specified rectangle. This parameter must not be nil.
  /// - Returns: The rectangle in screen coordinates.
  ///
  /// Use this function to convert accessibility frame rectangles to screen coordinates.
  @MainActor
  @available(iOS 7.0, *)
  public func convertToScreenCoordinates(_ rect: CGRect, in view: UIView) -> CGRect {
    _implementation.convertToScreenCoordinatesUsingCGRect(rect, view)
  }

  /// Converts the specified path object to screen coordinates and returns a new path
  /// object with the results.
  /// - Parameters:
  ///   - path: The path object that you want to convert. The coordinate values used to
  ///    create this path object should be relative to the coordinate system of the specified
  ///    view. This parameter must not be nil.
  ///   - view: The view whose coordinate system was used to define the path. This
  ///   parameter must not be nil.
  /// - Returns: A new path object that has the same shape as path but whose points
  /// are specified in screen coordinates.
  ///
  /// This function adjusts the points of the path you provide to values that the accessibility
  /// system can use. You can use it to convert path objects in use by your app’s user
  /// interface before handing them to the accessibility system.
  @MainActor
  @available(iOS 7.0, *)
  public func convertToScreenCoordinates(_ path: UIBezierPath, in view: UIView) -> UIBezierPath {
    _implementation.convertToScreenCoordinatesUsingUIBezierPath(path, view)
  }

  /// Returns the accessibility element that’s currently in focus by the specified
  /// assistive app.
  /// - Returns: The element that is currently focused by the specified assistive
  ///  technology or the element that was most recently focused, if no technology is specified.
  @MainActor
  @available(iOS 9.0, *)
  public func focusedElement(
    using assistiveTechnologyIdentifier: UIAccessibility.AssistiveTechnologyIdentifier?
  ) -> Any? {
    _implementation.focusedElement(assistiveTechnologyIdentifier)
  }

  /// Posts a notification to assistive apps.
  /// - Parameters:
  ///   - notification: The notification to post (see “Notifications” in
  ///   `UIAccessibility` for a list of notifications).
  ///   - argument: The argument specified by the notification. Pass nil unless
  ///   a notification specifies otherwise.
  ///
  /// Your application might need to post accessibility notifications if you have user
  /// interface components that change very frequently or that appear and disappear.
  @MainActor
  public func post(notification: UIAccessibility.Notification, argument: Any?) {
    _implementation.post(notification, argument)
  }

  /// Transitions the app to or from Single App mode asynchronously.
  /// - Parameters:
  ///   - enable: Specify true to put the device into Single App mode for this
  ///   app or false to exit Single App mode.
  ///   - completionHandler: The block that notifies your app of the success
  ///   or failure of the operation. This block takes the following parameter: didSucceed.
  /// If true, the app transitioned to or from Single App mode successfully. If false, the
  /// app or device is not eligible for Single App mode or there was some other error.
  ///
  /// You can use this method to lock your app into Single App mode and to release
  /// it from that mode later. For example, a test-taking app might enter this mode at
  /// the beginning of a test and exit it when the user completes the test. Entering
  /// Single App mode is supported only for devices that are supervised using Mobile
  /// Device Management (MDM), and the app itself must be enabled for this mode by
  /// MDM. You must balance each call to enter Single App mode with a call to exit
  /// that mode.
  ///
  /// Because entering or exiting Single App mode might take some time, this method
  /// executes asynchronously and notifies you of the results using the completionHandler
  /// block.
  @MainActor
  @available(iOS 7.0, *)
  public func requestGuidedAccessSession(
    enabled enable: Bool,
    completionHandler: @escaping (Bool) -> Void
  ) {
    _implementation.requestGuidedAccessSession(enable, completionHandler)
  }
}

extension Accessibility {
  public struct Implementation: Sendable {
    @MainActorReadOnlyProxy public var isVoiceOverRunning: Bool
    @MainActorReadOnlyProxy public var voiceOverStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isMonoAudioEnabled: Bool
    @MainActorReadOnlyProxy public var monoAudioStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isClosedCaptioningEnabled: Bool
    @MainActorReadOnlyProxy public var closedCaptioningStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isInvertColorsEnabled: Bool
    @MainActorReadOnlyProxy public var invertColorsStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isGuidedAccessEnabled: Bool
    @MainActorReadOnlyProxy public var guidedAccessStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isBoldTextEnabled: Bool
    @MainActorReadOnlyProxy public var boldTextStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var buttonShapesEnabled: Bool
    @MainActorReadOnlyProxy public var buttonShapesEnabledStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isGrayscaleEnabled: Bool
    @MainActorReadOnlyProxy public var grayscaleStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isReduceTransparencyEnabled: Bool
    @MainActorReadOnlyProxy public var reduceTransparencyStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isReduceMotionEnabled: Bool
    @MainActorReadOnlyProxy public var reduceMotionStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var prefersCrossFadeTransitions: Bool
    @MainActorReadOnlyProxy public var prefersCrossFadeTransitionsStatusDidChange: NSNotification.Name
    @MainActorReadOnlyProxy public var isVideoAutoplayEnabled: Bool
    @MainActorReadOnlyProxy public var videoAutoplayStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isDarkerSystemColorsEnabled: Bool
    @MainActorReadOnlyProxy public var darkerSystemColorsStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isSwitchControlRunning: Bool
    @MainActorReadOnlyProxy public var switchControlStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isSpeakSelectionEnabled: Bool
    @MainActorReadOnlyProxy public var speakSelectionStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isSpeakScreenEnabled: Bool
    @MainActorReadOnlyProxy public var speakScreenStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isShakeToUndoEnabled: Bool
    @MainActorReadOnlyProxy public var shakeToUndoDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isAssistiveTouchRunning: Bool
    @MainActorReadOnlyProxy public var assistiveTouchStatusDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var shouldDifferentiateWithoutColor: Bool
    @MainActorReadOnlyProxy public var differentiateWithoutColorDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var isOnOffSwitchLabelsEnabled: Bool
    @MainActorReadOnlyProxy public var onOffSwitchLabelsDidChangeNotification: NSNotification.Name
    @MainActorReadOnlyProxy public var hearingDevicePairedEar: UIAccessibility.HearingDeviceEar
    @MainActorReadOnlyProxy public var hearingDevicePairedEarDidChangeNotification: NSNotification.Name
    @FunctionProxy public var convertToScreenCoordinatesUsingCGRect:
      @MainActor @Sendable (CGRect, UIView) -> CGRect
    @FunctionProxy public var convertToScreenCoordinatesUsingUIBezierPath:
      @MainActor @Sendable (UIBezierPath, UIView) -> UIBezierPath
    @FunctionProxy public var focusedElement:
      @MainActor @Sendable (UIAccessibility.AssistiveTechnologyIdentifier?) -> Any?
    @FunctionProxy public var post:
      @MainActor @Sendable (UIAccessibility.Notification, Any?) -> Void
    @FunctionProxy public var requestGuidedAccessSession:
      @MainActor @Sendable (Bool, @escaping (Bool) -> Void) -> Void
    init(
      isVoiceOverRunning: MainActorReadOnlyProxy<Bool>,
      voiceOverStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isMonoAudioEnabled: MainActorReadOnlyProxy<Bool>,
      monoAudioStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isClosedCaptioningEnabled: MainActorReadOnlyProxy<Bool>,
      closedCaptioningStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isInvertColorsEnabled: MainActorReadOnlyProxy<Bool>,
      invertColorsStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isGuidedAccessEnabled: MainActorReadOnlyProxy<Bool>,
      guidedAccessStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isBoldTextEnabled: MainActorReadOnlyProxy<Bool>,
      boldTextStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      buttonShapesEnabled: MainActorReadOnlyProxy<Bool>,
      buttonShapesEnabledStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isGrayscaleEnabled: MainActorReadOnlyProxy<Bool>,
      grayscaleStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isReduceTransparencyEnabled: MainActorReadOnlyProxy<Bool>,
      reduceTransparencyStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isReduceMotionEnabled: MainActorReadOnlyProxy<Bool>,
      reduceMotionStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      prefersCrossFadeTransitions: MainActorReadOnlyProxy<Bool>,
      prefersCrossFadeTransitionsStatusDidChange: MainActorReadOnlyProxy<NSNotification.Name>,
      isVideoAutoplayEnabled: MainActorReadOnlyProxy<Bool>,
      videoAutoplayStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isDarkerSystemColorsEnabled: MainActorReadOnlyProxy<Bool>,
      darkerSystemColorsStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isSwitchControlRunning: MainActorReadOnlyProxy<Bool>,
      switchControlStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isSpeakSelectionEnabled: MainActorReadOnlyProxy<Bool>,
      speakSelectionStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isSpeakScreenEnabled: MainActorReadOnlyProxy<Bool>,
      speakScreenStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isShakeToUndoEnabled: MainActorReadOnlyProxy<Bool>,
      shakeToUndoDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isAssistiveTouchRunning: MainActorReadOnlyProxy<Bool>,
      assistiveTouchStatusDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      shouldDifferentiateWithoutColor: MainActorReadOnlyProxy<Bool>,
      differentiateWithoutColorDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      isOnOffSwitchLabelsEnabled: MainActorReadOnlyProxy<Bool>,
      onOffSwitchLabelsDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      hearingDevicePairedEar: MainActorReadOnlyProxy<UIAccessibility.HearingDeviceEar>,
      hearingDevicePairedEarDidChangeNotification: MainActorReadOnlyProxy<NSNotification.Name>,
      convertToScreenCoordinatesUsingCGRect: FunctionProxy<
        @MainActor @Sendable (CGRect, UIView) -> CGRect
      >,
      convertToScreenCoordinatesUsingUIBezierPath: FunctionProxy<
        @MainActor @Sendable (UIBezierPath, UIView) -> UIBezierPath
      >,
      focusedElement: FunctionProxy<
        @MainActor @Sendable (UIAccessibility.AssistiveTechnologyIdentifier?) -> Any?
      >,
      post: FunctionProxy<
        @MainActor @Sendable (UIAccessibility.Notification, Any?) -> Void
      >,
      requestGuidedAccessSession: FunctionProxy<
        @MainActor @Sendable (Bool, @escaping (Bool) -> Void) -> Void
      >
    ) {
      self._isVoiceOverRunning = isVoiceOverRunning
      self._voiceOverStatusDidChangeNotification = voiceOverStatusDidChangeNotification
      self._isMonoAudioEnabled = isMonoAudioEnabled
      self._monoAudioStatusDidChangeNotification = monoAudioStatusDidChangeNotification
      self._isClosedCaptioningEnabled = isClosedCaptioningEnabled
      self._closedCaptioningStatusDidChangeNotification = closedCaptioningStatusDidChangeNotification
      self._isInvertColorsEnabled = isInvertColorsEnabled
      self._invertColorsStatusDidChangeNotification = invertColorsStatusDidChangeNotification
      self._isGuidedAccessEnabled = isGuidedAccessEnabled
      self._guidedAccessStatusDidChangeNotification = guidedAccessStatusDidChangeNotification
      self._isBoldTextEnabled = isBoldTextEnabled
      self._boldTextStatusDidChangeNotification = boldTextStatusDidChangeNotification
      self._buttonShapesEnabled = buttonShapesEnabled
      self._buttonShapesEnabledStatusDidChangeNotification = buttonShapesEnabledStatusDidChangeNotification
      self._isGrayscaleEnabled = isGrayscaleEnabled
      self._grayscaleStatusDidChangeNotification = grayscaleStatusDidChangeNotification
      self._isReduceTransparencyEnabled = isReduceTransparencyEnabled
      self._reduceTransparencyStatusDidChangeNotification = reduceTransparencyStatusDidChangeNotification
      self._isReduceMotionEnabled = isReduceMotionEnabled
      self._reduceMotionStatusDidChangeNotification = reduceMotionStatusDidChangeNotification
      self._prefersCrossFadeTransitions = prefersCrossFadeTransitions
      self._prefersCrossFadeTransitionsStatusDidChange = prefersCrossFadeTransitionsStatusDidChange
      self._isVideoAutoplayEnabled = isVideoAutoplayEnabled
      self._videoAutoplayStatusDidChangeNotification = videoAutoplayStatusDidChangeNotification
      self._isDarkerSystemColorsEnabled = isDarkerSystemColorsEnabled
      self._darkerSystemColorsStatusDidChangeNotification = darkerSystemColorsStatusDidChangeNotification
      self._isSwitchControlRunning = isSwitchControlRunning
      self._switchControlStatusDidChangeNotification = switchControlStatusDidChangeNotification
      self._isSpeakSelectionEnabled = isSpeakSelectionEnabled
      self._speakSelectionStatusDidChangeNotification = speakSelectionStatusDidChangeNotification
      self._isSpeakScreenEnabled = isSpeakScreenEnabled
      self._speakScreenStatusDidChangeNotification = speakScreenStatusDidChangeNotification
      self._isShakeToUndoEnabled = isShakeToUndoEnabled
      self._shakeToUndoDidChangeNotification = shakeToUndoDidChangeNotification
      self._isAssistiveTouchRunning = isAssistiveTouchRunning
      self._assistiveTouchStatusDidChangeNotification = assistiveTouchStatusDidChangeNotification
      self._shouldDifferentiateWithoutColor = shouldDifferentiateWithoutColor
      self._differentiateWithoutColorDidChangeNotification = differentiateWithoutColorDidChangeNotification
      self._isOnOffSwitchLabelsEnabled = isOnOffSwitchLabelsEnabled
      self._onOffSwitchLabelsDidChangeNotification = onOffSwitchLabelsDidChangeNotification
      self._hearingDevicePairedEar = hearingDevicePairedEar
      self._hearingDevicePairedEarDidChangeNotification = hearingDevicePairedEarDidChangeNotification
      self._convertToScreenCoordinatesUsingCGRect = convertToScreenCoordinatesUsingCGRect
      self._convertToScreenCoordinatesUsingUIBezierPath = convertToScreenCoordinatesUsingUIBezierPath
      self._focusedElement = focusedElement
      self._post = post
      self._requestGuidedAccessSession = requestGuidedAccessSession
    }
  }
}

extension Accessibility {
  /// The singleton app instance.
  public static var shared: Accessibility {
    let _implementation = Implementation(
      isVoiceOverRunning: .init {
        UIAccessibility.isVoiceOverRunning
      },
      voiceOverStatusDidChangeNotification: .init {
        UIAccessibility.voiceOverStatusDidChangeNotification
      },
      isMonoAudioEnabled: .init {
        UIAccessibility.isMonoAudioEnabled
      },
      monoAudioStatusDidChangeNotification: .init {
        UIAccessibility.monoAudioStatusDidChangeNotification
      },
      isClosedCaptioningEnabled: .init {
        UIAccessibility.isClosedCaptioningEnabled
      },
      closedCaptioningStatusDidChangeNotification: .init {
        UIAccessibility.closedCaptioningStatusDidChangeNotification
      },
      isInvertColorsEnabled: .init {
        UIAccessibility.isInvertColorsEnabled
      },
      invertColorsStatusDidChangeNotification: .init {
        UIAccessibility.invertColorsStatusDidChangeNotification
      },
      isGuidedAccessEnabled: .init {
        UIAccessibility.isGuidedAccessEnabled
      },
      guidedAccessStatusDidChangeNotification: .init {
        UIAccessibility.guidedAccessStatusDidChangeNotification
      },
      isBoldTextEnabled: .init {
        UIAccessibility.isBoldTextEnabled
      },
      boldTextStatusDidChangeNotification: .init {
        UIAccessibility.boldTextStatusDidChangeNotification
      },
      buttonShapesEnabled: .init {
        UIAccessibility.buttonShapesEnabled
      },
      buttonShapesEnabledStatusDidChangeNotification: .init {
        UIAccessibility.buttonShapesEnabledStatusDidChangeNotification
      },
      isGrayscaleEnabled: .init {
        UIAccessibility.isGrayscaleEnabled
      },
      grayscaleStatusDidChangeNotification: .init {
        UIAccessibility.grayscaleStatusDidChangeNotification
      },
      isReduceTransparencyEnabled: .init {
        UIAccessibility.isReduceTransparencyEnabled
      },
      reduceTransparencyStatusDidChangeNotification: .init {
        UIAccessibility.reduceTransparencyStatusDidChangeNotification
      },
      isReduceMotionEnabled: .init {
        UIAccessibility.isReduceMotionEnabled
      },
      reduceMotionStatusDidChangeNotification: .init {
        UIAccessibility.reduceMotionStatusDidChangeNotification
      },
      prefersCrossFadeTransitions: .init {
        UIAccessibility.prefersCrossFadeTransitions
      },
      prefersCrossFadeTransitionsStatusDidChange: .init {
        UIAccessibility.prefersCrossFadeTransitionsStatusDidChange
      },
      isVideoAutoplayEnabled: .init {
        UIAccessibility.isVideoAutoplayEnabled
      },
      videoAutoplayStatusDidChangeNotification: .init {
        UIAccessibility.videoAutoplayStatusDidChangeNotification
      },
      isDarkerSystemColorsEnabled: .init {
        UIAccessibility.isDarkerSystemColorsEnabled
      },
      darkerSystemColorsStatusDidChangeNotification: .init {
        UIAccessibility.darkerSystemColorsStatusDidChangeNotification
      },
      isSwitchControlRunning: .init {
        UIAccessibility.isSwitchControlRunning
      },
      switchControlStatusDidChangeNotification: .init {
        UIAccessibility.switchControlStatusDidChangeNotification
      },
      isSpeakSelectionEnabled: .init {
        UIAccessibility.isSpeakSelectionEnabled
      },
      speakSelectionStatusDidChangeNotification: .init {
        UIAccessibility.speakSelectionStatusDidChangeNotification
      },
      isSpeakScreenEnabled: .init {
        UIAccessibility.isSpeakScreenEnabled
      },
      speakScreenStatusDidChangeNotification: .init {
        UIAccessibility.speakScreenStatusDidChangeNotification
      },
      isShakeToUndoEnabled: .init {
        UIAccessibility.isShakeToUndoEnabled
      },
      shakeToUndoDidChangeNotification: .init {
        UIAccessibility.shakeToUndoDidChangeNotification
      },
      isAssistiveTouchRunning: .init {
        UIAccessibility.isAssistiveTouchRunning
      },
      assistiveTouchStatusDidChangeNotification: .init {
        UIAccessibility.assistiveTouchStatusDidChangeNotification
      },
      shouldDifferentiateWithoutColor: .init {
        UIAccessibility.shouldDifferentiateWithoutColor
      },
      differentiateWithoutColorDidChangeNotification: .init {
        UIAccessibility.differentiateWithoutColorDidChangeNotification
      },
      isOnOffSwitchLabelsEnabled: .init {
        UIAccessibility.isOnOffSwitchLabelsEnabled
      },
      onOffSwitchLabelsDidChangeNotification: .init {
        UIAccessibility.onOffSwitchLabelsDidChangeNotification
      },
      hearingDevicePairedEar: .init {
        UIAccessibility.hearingDevicePairedEar
      },
      hearingDevicePairedEarDidChangeNotification: .init {
        UIAccessibility.hearingDevicePairedEarDidChangeNotification
      },
      convertToScreenCoordinatesUsingCGRect: .init {
        { UIAccessibility.convertToScreenCoordinates($0, in: $1) }
      },
      convertToScreenCoordinatesUsingUIBezierPath: .init {
        { UIAccessibility.convertToScreenCoordinates($0, in: $1) }
      },
      focusedElement: .init {
        { UIAccessibility.focusedElement(using: $0) }
      },
      post: .init {
        { UIAccessibility.post(notification: $0, argument: $1) }
      },
      requestGuidedAccessSession: .init {
        { UIAccessibility.requestGuidedAccessSession(enabled: $0, completionHandler: $1) }
      }
    )
    return Accessibility(_implementation: _implementation)
  }
}

extension Accessibility {
  public static var unimplemented: Accessibility {
    let _implementation = Implementation(
      isVoiceOverRunning: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isVoiceOverRunning)"#
        )
      },
      voiceOverStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.voiceOverStatusDidChangeNotification)"#
        )
      },
      isMonoAudioEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isMonoAudioEnabled)"#
        )
      },
      monoAudioStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.monoAudioStatusDidChangeNotification)"#
        )
      },
      isClosedCaptioningEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isClosedCaptioningEnabled)"#
        )
      },
      closedCaptioningStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.closedCaptioningStatusDidChangeNotification)"#
        )
      },
      isInvertColorsEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isInvertColorsEnabled)"#
        )
      },
      invertColorsStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.invertColorsStatusDidChangeNotification)"#
        )
      },
      isGuidedAccessEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isGuidedAccessEnabled)"#
        )
      },
      guidedAccessStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.guidedAccessStatusDidChangeNotification)"#
        )
      },
      isBoldTextEnabled: .init {
        XCTestDynamicOverlay.unimplemented(#"@Dependency(\.accessibility.isBoldTextEnabled)"#)
      },
      boldTextStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.boldTextStatusDidChangeNotification)"#
        )
      },
      buttonShapesEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.buttonShapesEnabled)"#
        )
      },
      buttonShapesEnabledStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.buttonShapesEnabledStatusDidChangeNotification)"#
        )
      },
      isGrayscaleEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isGrayscaleEnabled)"#
        )
      },
      grayscaleStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.grayscaleStatusDidChangeNotification)"#
        )
      },
      isReduceTransparencyEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isReduceTransparencyEnabled)"#
        )
      },
      reduceTransparencyStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.reduceTransparencyStatusDidChangeNotification)"#
        )
      },
      isReduceMotionEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isReduceMotionEnabled)"#
        )
      },
      reduceMotionStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.reduceMotionStatusDidChangeNotification)"#
        )
      },
      prefersCrossFadeTransitions: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.prefersCrossFadeTransitions)"#
        )
      },
      prefersCrossFadeTransitionsStatusDidChange: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.prefersCrossFadeTransitionsStatusDidChange)"#
        )
      },
      isVideoAutoplayEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isVideoAutoplayEnabled)"#
        )
      },
      videoAutoplayStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.videoAutoplayStatusDidChangeNotification)"#
        )
      },
      isDarkerSystemColorsEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isDarkerSystemColorsEnabled)"#
        )
      },
      darkerSystemColorsStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.darkerSystemColorsStatusDidChangeNotification)"#
        )
      },
      isSwitchControlRunning: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isSwitchControlRunning)"#
        )
      },
      switchControlStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.switchControlStatusDidChangeNotification)"#
        )
      },
      isSpeakSelectionEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isSpeakSelectionEnabled)"#
        )
      },
      speakSelectionStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.speakSelectionStatusDidChangeNotification)"#
        )
      },
      isSpeakScreenEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isSpeakScreenEnabled)"#
        )
      },
      speakScreenStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.speakScreenStatusDidChangeNotification)"#
        )
      },
      isShakeToUndoEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isShakeToUndoEnabled)"#
        )
      },
      shakeToUndoDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.shakeToUndoDidChangeNotification)"#
        )
      },
      isAssistiveTouchRunning: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isAssistiveTouchRunning)"#
        )
      },
      assistiveTouchStatusDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.assistiveTouchStatusDidChangeNotification)"#
        )
      },
      shouldDifferentiateWithoutColor: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.shouldDifferentiateWithoutColor)"#
        )
      },
      differentiateWithoutColorDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.differentiateWithoutColorDidChangeNotification)"#
        )
      },
      isOnOffSwitchLabelsEnabled: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.isOnOffSwitchLabelsEnabled)"#
        )
      },
      onOffSwitchLabelsDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.onOffSwitchLabelsDidChangeNotification)"#
        )
      },
      hearingDevicePairedEar: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.hearingDevicePairedEar)"#
        )
      },
      hearingDevicePairedEarDidChangeNotification: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.hearingDevicePairedEarDidChangeNotification)"#
        )
      },
      convertToScreenCoordinatesUsingCGRect: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.convertToScreenCoordinatesUsingCGRect)"#,
          placeholder: .zero
        )
      },
      convertToScreenCoordinatesUsingUIBezierPath: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.convertToScreenCoordinatesUsingUIBezierPath)"#,
          placeholder: .init()
        )
      },
      focusedElement: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.focusedElement)"#,
          placeholder: NSObject()
        )
      },
      post: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.post)"#
        )
      },
      requestGuidedAccessSession: .init {
        XCTestDynamicOverlay.unimplemented(
          #"@Dependency(\.accessibility.requestGuidedAccessSession)"#
        )
      }
    )
    return Accessibility(_implementation: _implementation)
  }
}

