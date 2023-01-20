import Dependencies
import Utilities
import XCTest

final class AccessibilityDependencyTests: XCTestCase {
  @Dependency(\.accessibility) var accessibility
  // MARK: - VoiceOver
  @MainActor
  func testIsVoiceOverRunning() {
    withDependencies {
      $0.accessibility.$isVoiceOverRunning = true
    } operation: {
      XCTAssertEqual(accessibility.isVoiceOverRunning, true)
    }
  }
  @MainActor
  func testVoiceOverStatusDidChangeNotificationName() {
    let notification = UIAccessibility.voiceOverStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$voiceOverStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.voiceOverStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Mono Audio
  @MainActor
  func testIsMonoAudioEnabled() {
    withDependencies {
      $0.accessibility.$isMonoAudioEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isMonoAudioEnabled, true)
    }
  }
  @MainActor
  func testMonoAudioStatusDidChangeNotificationName() {
    let notification = UIAccessibility.monoAudioStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$monoAudioStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.monoAudioStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Closed Captioning
  @MainActor
  func testIsClosedCaptioningEnabled() {
    withDependencies {
      $0.accessibility.$isClosedCaptioningEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isClosedCaptioningEnabled, true)
    }
  }
  @MainActor
  func testClosedCaptioningStatusDidChangeNotificationName() {
    let notification = UIAccessibility.closedCaptioningStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$closedCaptioningStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.closedCaptioningStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Invert Colors
  @MainActor
  func testIsInvertColorsEnabled() {
    withDependencies {
      $0.accessibility.$isInvertColorsEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isInvertColorsEnabled, true)
    }
  }
  @MainActor
  func testInvertColorsStatusDidChangeNotificationName() {
    let notification = UIAccessibility.invertColorsStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$invertColorsStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.invertColorsStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Guided Access
  @MainActor
  func testIsGuidedAccessEnabled() {
    withDependencies {
      $0.accessibility.$isGuidedAccessEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isGuidedAccessEnabled, true)
    }
  }
  @MainActor
  func testGuidedAccessStatusDidChangeNotificationName() {
    let notification = UIAccessibility.guidedAccessStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$guidedAccessStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.guidedAccessStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Bold Text
  @MainActor
  func testIsBoldTextEnabled() {
    withDependencies {
      $0.accessibility.$isBoldTextEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isBoldTextEnabled, true)
    }
  }
  @MainActor
  func testBoldTextStatusDidChangeNotificationName() {
    let notification = UIAccessibility.boldTextStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$boldTextStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.boldTextStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Button Shapes
  @MainActor
  func testButtonShapesEnabled() {
    withDependencies {
      $0.accessibility.$buttonShapesEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.buttonShapesEnabled, true)
    }
  }
  @MainActor
  func testButtonShapesEnabledStatusDidChangeNotificationName() {
    let notification = UIAccessibility.buttonShapesEnabledStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$buttonShapesEnabledStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.buttonShapesEnabledStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Grayscale
  @MainActor
  func testIsGrayscaleEnabled() {
    withDependencies {
      $0.accessibility.$isGrayscaleEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isGrayscaleEnabled, true)
    }
  }
  @MainActor
  func testGrayscaleStatusDidChangeNotificationNotificationName() {
    let notification = UIAccessibility.grayscaleStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$grayscaleStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.grayscaleStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Reduce Transparency
  @MainActor
  func testIsReduceTransparencyEnabled() {
    withDependencies {
      $0.accessibility.$isReduceTransparencyEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isReduceTransparencyEnabled, true)
    }
  }
  @MainActor
  func testReduceTransparencyStatusDidChangeNotificationNotificationName() {
    let notification = UIAccessibility.reduceTransparencyStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$reduceTransparencyStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.reduceTransparencyStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Reduce Motion
  @MainActor
  func testIsReduceMotionEnabled() {
    withDependencies {
      $0.accessibility.$isReduceMotionEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isReduceMotionEnabled, true)
    }
  }
  @MainActor
  func testReduceMotionStatusDidChangeNotificationNotificationName() {
    let notification = UIAccessibility.reduceMotionStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$reduceMotionStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.reduceMotionStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Reduce Motion: Prefer Cross-fade Transitions
  @MainActor
  func testPrefersCrossFadeTransitions() {
    withDependencies {
      $0.accessibility.$prefersCrossFadeTransitions = true
    } operation: {
      XCTAssertEqual(accessibility.prefersCrossFadeTransitions, true)
    }
  }
  @MainActor
  func testPrefersCrossFadeTransitionsStatusDidChangeNotificationName() {
    let notification = UIAccessibility.prefersCrossFadeTransitionsStatusDidChange
    withDependencies {
      $0.accessibility.$prefersCrossFadeTransitionsStatusDidChange = notification
    } operation: {
      XCTAssertEqual(accessibility.prefersCrossFadeTransitionsStatusDidChange, notification)
    }
  }
  // MARK: - Video Autoplay
  @MainActor
  func testIsVideoAutoplayEnabled() {
    withDependencies {
      $0.accessibility.$isVideoAutoplayEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isVideoAutoplayEnabled, true)
    }
  }
  @MainActor
  func testVideoAutoplayStatusDidChangeNotificationName() {
    let notification = UIAccessibility.videoAutoplayStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$videoAutoplayStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.videoAutoplayStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Darker System Colors (Increase Contrast)
  @MainActor
  func testIsDarkerSystemColorsEnabled() {
    withDependencies {
      $0.accessibility.$isDarkerSystemColorsEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isDarkerSystemColorsEnabled, true)
    }
  }
  @MainActor
  func testDarkerSystemColorsStatusDidChangeNotificationName() {
    let notification = UIAccessibility.darkerSystemColorsStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$darkerSystemColorsStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.darkerSystemColorsStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Switch Control
  @MainActor
  func testIsSwitchControlRunning() {
    withDependencies {
      $0.accessibility.$isSwitchControlRunning = true
    } operation: {
      XCTAssertEqual(accessibility.isSwitchControlRunning, true)
    }
  }
  @MainActor
  func testSwitchControlStatusDidChangeNotificationName() {
    let notification = UIAccessibility.switchControlStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$switchControlStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.switchControlStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Speak Selection
  @MainActor
  func testIsSpeakSelectionEnabled() {
    withDependencies {
      $0.accessibility.$isSpeakSelectionEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isSpeakSelectionEnabled, true)
    }
  }
  @MainActor
  func testSpeakSelectionStatusDidChangeNotificationName() {
    let notification = UIAccessibility.speakSelectionStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$speakSelectionStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.speakSelectionStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Speak Screen
  @MainActor
  func testIsSpeakScreenEnabled() {
    withDependencies {
      $0.accessibility.$isSpeakScreenEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isSpeakScreenEnabled, true)
    }
  }
  @MainActor
  func testSpeakScreenStatusDidChangeNotificationName() {
    let notification = UIAccessibility.speakScreenStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$speakScreenStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.speakScreenStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Shake To Undo
  @MainActor
  func testIsShakeToUndoEnabled() {
    withDependencies {
      $0.accessibility.$isShakeToUndoEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isShakeToUndoEnabled, true)
    }
  }
  @MainActor
  func testShakeToUndoDidChangeNotificationName() {
    let notification = UIAccessibility.shakeToUndoDidChangeNotification
    withDependencies {
      $0.accessibility.$shakeToUndoDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.shakeToUndoDidChangeNotification, notification)
    }
  }
  // MARK: - Assistive Touch
  @MainActor
  func testIsAssistiveTouchRunning() {
    withDependencies {
      $0.accessibility.$isAssistiveTouchRunning = true
    } operation: {
      XCTAssertEqual(accessibility.isAssistiveTouchRunning, true)
    }
  }
  @MainActor
  func testAssistiveTouchStatusDidChangeNotificationName() {
    let notification = UIAccessibility.assistiveTouchStatusDidChangeNotification
    withDependencies {
      $0.accessibility.$assistiveTouchStatusDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.assistiveTouchStatusDidChangeNotification, notification)
    }
  }
  // MARK: - Differentiate Without Color
  @MainActor
  func testShouldDifferentiateWithoutColor() {
    withDependencies {
      $0.accessibility.$shouldDifferentiateWithoutColor = true
    } operation: {
      XCTAssertEqual(accessibility.shouldDifferentiateWithoutColor, true)
    }
  }
  @MainActor
  func testDifferentiateWithoutColorDidChangeNotificationName() {
    let notification = UIAccessibility.differentiateWithoutColorDidChangeNotification
    withDependencies {
      $0.accessibility.$differentiateWithoutColorDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.differentiateWithoutColorDidChangeNotification, notification)
    }
  }
  // MARK: - On/Off Switch Label
  @MainActor
  func testIsOnOffSwitchLabelsEnabled() {
    withDependencies {
      $0.accessibility.$isOnOffSwitchLabelsEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isOnOffSwitchLabelsEnabled, true)
    }
  }
  @MainActor
  func testOnOffSwitchLabelsDidChangeNotificationName() {
    let notification = UIAccessibility.onOffSwitchLabelsDidChangeNotification
    withDependencies {
      $0.accessibility.$onOffSwitchLabelsDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.onOffSwitchLabelsDidChangeNotification, notification)
    }
  }
  // MARK: - Hearing Device Paired Ear
  @MainActor
  func testHearingDevicePairedEar() {
    withDependencies {
      $0.accessibility.$hearingDevicePairedEar = .both
    } operation: {
      XCTAssertEqual(accessibility.hearingDevicePairedEar, .both)
    }

    withDependencies {
      $0.accessibility.$hearingDevicePairedEar = .left
    } operation: {
      XCTAssertEqual(accessibility.hearingDevicePairedEar, .left)
    }

    withDependencies {
      $0.accessibility.$hearingDevicePairedEar = .right
    } operation: {
      XCTAssertEqual(accessibility.hearingDevicePairedEar, .right)
    }
  }
  @MainActor
  func testHearingDevicePairedEarDidChangeNotificationName() {
    let notification = UIAccessibility.hearingDevicePairedEarDidChangeNotification
    withDependencies {
      $0.accessibility.$hearingDevicePairedEarDidChangeNotification = notification
    } operation: {
      XCTAssertEqual(accessibility.hearingDevicePairedEarDidChangeNotification, notification)
    }
  }
  // MARK: - UIAccessibility Functions
  @MainActor
  func testConvertToScreenCoordinatesUsingCGRect() {
    XCTExpectFailure {
      let _ = accessibility.convertToScreenCoordinates(CGRect.zero, in: .init())
    }
  }
  @MainActor
  func testConvertToScreenCoordinatesUsingUIBezierPath() {
    XCTExpectFailure {
      let _ = accessibility.convertToScreenCoordinates(UIBezierPath.init(), in: .init())
    }
  }
  @MainActor
  func testFocusedElement() {
    XCTExpectFailure {
      let _ = accessibility.focusedElement(using: nil)
    }
  }
  @MainActor
  func testPost() {
    XCTExpectFailure {
      let _ = accessibility.post(
        notification: UIAccessibility.Notification.announcement,
        argument: nil
      )
    }
  }
  @MainActor
  func testRequestGuidedAccessSession() {
    XCTExpectFailure {
      let _ = accessibility.requestGuidedAccessSession(
        enabled: false,
        completionHandler: { _ in }
      )
    }
  }
}
