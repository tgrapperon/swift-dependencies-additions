#if os(iOS) || os(tvOS)
import Dependencies
import AccessibilityDependency
import XCTest

final class AccessibilityDependencyTests: XCTestCase {
  @Dependency(\.accessibility) var accessibility

  func testIsVoiceOverRunning() {
    withDependencies {
      $0.accessibility.$isVoiceOverRunning = true
    } operation: {
      XCTAssertEqual(accessibility.isVoiceOverRunning, true)
    }
  }
  
  func testIsMonoAudioEnabled() {
    withDependencies {
      $0.accessibility.$isMonoAudioEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isMonoAudioEnabled, true)
    }
  }
  
  func testIsClosedCaptioningEnabled() {
    withDependencies {
      $0.accessibility.$isClosedCaptioningEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isClosedCaptioningEnabled, true)
    }
  }
  
  func testIsInvertColorsEnabled() {
    withDependencies {
      $0.accessibility.$isInvertColorsEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isInvertColorsEnabled, true)
    }
  }
  
  func testIsGuidedAccessEnabled() {
    withDependencies {
      $0.accessibility.$isGuidedAccessEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isGuidedAccessEnabled, true)
    }
  }
  
  func testIsBoldTextEnabled() {
    withDependencies {
      $0.accessibility.$isBoldTextEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isBoldTextEnabled, true)
    }
  }
  
  @available(iOS 14.0, tvOS 14, *)
  func testButtonShapesEnabled() {
    withDependencies {
      $0.accessibility.$buttonShapesEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.buttonShapesEnabled, true)
    }
  }
  
  func testIsGrayscaleEnabled() {
    withDependencies {
      $0.accessibility.$isGrayscaleEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isGrayscaleEnabled, true)
    }
  }
  
  func testIsReduceTransparencyEnabled() {
    withDependencies {
      $0.accessibility.$isReduceTransparencyEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isReduceTransparencyEnabled, true)
    }
  }
  
  func testIsReduceMotionEnabled() {
    withDependencies {
      $0.accessibility.$isReduceMotionEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isReduceMotionEnabled, true)
    }
  }
  
  @available(iOS 14.0, tvOS 14, *)
  func testPrefersCrossFadeTransitions() {
    withDependencies {
      $0.accessibility.$prefersCrossFadeTransitions = true
    } operation: {
      XCTAssertEqual(accessibility.prefersCrossFadeTransitions, true)
    }
  }
  
  func testIsVideoAutoplayEnabled() {
    withDependencies {
      $0.accessibility.$isVideoAutoplayEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isVideoAutoplayEnabled, true)
    }
  }
  
  func testIsDarkerSystemColorsEnabled() {
    withDependencies {
      $0.accessibility.$isDarkerSystemColorsEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isDarkerSystemColorsEnabled, true)
    }
  }
  
  func testIsSwitchControlRunning() {
    withDependencies {
      $0.accessibility.$isSwitchControlRunning = true
    } operation: {
      XCTAssertEqual(accessibility.isSwitchControlRunning, true)
    }
  }
  
  func testIsSpeakSelectionEnabled() {
    withDependencies {
      $0.accessibility.$isSpeakSelectionEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isSpeakSelectionEnabled, true)
    }
  }
  
  func testIsSpeakScreenEnabled() {
    withDependencies {
      $0.accessibility.$isSpeakScreenEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isSpeakScreenEnabled, true)
    }
  }
  
  func testIsShakeToUndoEnabled() {
    withDependencies {
      $0.accessibility.$isShakeToUndoEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isShakeToUndoEnabled, true)
    }
  }
  
  func testIsAssistiveTouchRunning() {
    withDependencies {
      $0.accessibility.$isAssistiveTouchRunning = true
    } operation: {
      XCTAssertEqual(accessibility.isAssistiveTouchRunning, true)
    }
  }
  
  func testShouldDifferentiateWithoutColor() {
    withDependencies {
      $0.accessibility.$shouldDifferentiateWithoutColor = true
    } operation: {
      XCTAssertEqual(accessibility.shouldDifferentiateWithoutColor, true)
    }
  }
  
  func testIsOnOffSwitchLabelsEnabled() {
    withDependencies {
      $0.accessibility.$isOnOffSwitchLabelsEnabled = true
    } operation: {
      XCTAssertEqual(accessibility.isOnOffSwitchLabelsEnabled, true)
    }
  }
  
  #if os(iOS)
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
  #endif
  
  func testConvertToScreenCoordinatesUsingCGRect() {
    XCTExpectFailure {
      let _ = accessibility.convertToScreenCoordinates(CGRect.zero, in: .init())
    }
  }

  func testConvertToScreenCoordinatesUsingUIBezierPath() {
    XCTExpectFailure {
      let _ = accessibility.convertToScreenCoordinates(UIBezierPath.init(), in: .init())
    }
  }

  func testFocusedElement() {
    XCTExpectFailure {
      let _ = accessibility.focusedElement(using: nil)
    }
  }

  func testPost() {
    XCTExpectFailure {
      let _ = accessibility.post(
        notification: UIAccessibility.Notification.announcement,
        argument: nil
      )
    }
  }
}
#endif
