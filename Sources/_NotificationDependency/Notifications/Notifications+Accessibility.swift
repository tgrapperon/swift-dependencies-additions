#if os(iOS) || os(tvOS)
  import Dependencies
  import AccessibilityDependency
  import UIKit

  extension Notifications {
    /// A notification that UIKit posts when VoiceOver starts or stops.
    public var voiceOverStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.voiceOverStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isVoiceOverRunning) var isVoiceOverRunning;
        return isVoiceOverRunning
      } placeholder: {
        @Dependency(\.accessibility.isVoiceOverRunning) var isVoiceOverRunning;
        return isVoiceOverRunning
      }
    }

    /// A notification that UIKit posts when system audio changes from stereo to mono.
    public var monoAudioStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.monoAudioStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isMonoAudioEnabled) var isMonoAudioEnabled;
        return isMonoAudioEnabled
      } placeholder: {
        @Dependency(\.accessibility.isMonoAudioEnabled) var isMonoAudioEnabled;
        return isMonoAudioEnabled
      }
    }

    /// A notification that UIKit posts when the setting for Closed Captions + SDH
    /// changes.
    public var closedCaptioningStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.closedCaptioningStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isClosedCaptioningEnabled) var isClosedCaptioningEnabled;
        return isClosedCaptioningEnabled
      } placeholder: {
        @Dependency(\.accessibility.isClosedCaptioningEnabled) var isClosedCaptioningEnabled;
        return isClosedCaptioningEnabled
      }
    }

    /// A notification that UIKit posts when the settings for inverted colors change.
    public var invertColorsStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.invertColorsStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isInvertColorsEnabled) var isInvertColorsEnabled;
        return isInvertColorsEnabled
      } placeholder: {
        @Dependency(\.accessibility.isInvertColorsEnabled) var isInvertColorsEnabled;
        return isInvertColorsEnabled
      }
    }

    /// A notification that indicates when a Guided Access session starts or ends.
    public var guidedAccessStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.guidedAccessStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isGuidedAccessEnabled) var isGuidedAccessEnabled;
        return isGuidedAccessEnabled
      } placeholder: {
        @Dependency(\.accessibility.isGuidedAccessEnabled) var isGuidedAccessEnabled;
        return isGuidedAccessEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Bold Text setting changes.
    public var boldTextStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.boldTextStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isBoldTextEnabled) var isBoldTextEnabled;
        return isBoldTextEnabled
      } placeholder: {
        @Dependency(\.accessibility.isBoldTextEnabled) var isBoldTextEnabled;
        return isBoldTextEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Button Shapes setting changes.
    @available(iOS 14.0, tvOS 14.0, *)
    public var buttonShapesEnabledStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.buttonShapesEnabledStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.buttonShapesEnabled) var buttonShapesEnabled;
        return buttonShapesEnabled
      } placeholder: {
        @Dependency(\.accessibility.buttonShapesEnabled) var buttonShapesEnabled;
        return buttonShapesEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Grayscale setting changes.
    public var grayscaleStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.grayscaleStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isGrayscaleEnabled) var isGrayscaleEnabled;
        return isGrayscaleEnabled
      } placeholder: {
        @Dependency(\.accessibility.isGrayscaleEnabled) var isGrayscaleEnabled;
        return isGrayscaleEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Reduce Transparency setting changes.
    public var reduceTransparencyStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.reduceTransparencyStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isReduceTransparencyEnabled) var isReduceTransparencyEnabled;
        return isReduceTransparencyEnabled
      } placeholder: {
        @Dependency(\.accessibility.isReduceTransparencyEnabled) var isReduceTransparencyEnabled;
        return isReduceTransparencyEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Reduce Motion setting changes.
    public var reduceMotionStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.reduceMotionStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isReduceMotionEnabled) var isReduceMotionEnabled;
        return isReduceMotionEnabled
      } placeholder: {
        @Dependency(\.accessibility.isReduceMotionEnabled) var isReduceMotionEnabled;
        return isReduceMotionEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Prefer Cross-Fade Transitions
    /// setting changes.
    @available(iOS 14.0, tvOS 14.0, *)
    public var prefersCrossFadeTransitionsStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.prefersCrossFadeTransitionsStatusDidChange) { _ in
        @Dependency(\.accessibility.prefersCrossFadeTransitions) var prefersCrossFadeTransitions;
        return prefersCrossFadeTransitions
      } placeholder: {
        @Dependency(\.accessibility.prefersCrossFadeTransitions) var prefersCrossFadeTransitions;
        return prefersCrossFadeTransitions
      }
    }

    /// A notification that UIKit posts when the system’s Auto-Play Video Previews setting
    /// changes.
    public var videoAutoplayStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.videoAutoplayStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isVideoAutoplayEnabled) var isVideoAutoplayEnabled;
        return isVideoAutoplayEnabled
      } placeholder: {
        @Dependency(\.accessibility.isVideoAutoplayEnabled) var isVideoAutoplayEnabled;
        return isVideoAutoplayEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Increase Contrast setting changes.
    public var darkerSystemColorsStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.darkerSystemColorsStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isDarkerSystemColorsEnabled) var isDarkerSystemColorsEnabled;
        return isDarkerSystemColorsEnabled
      } placeholder: {
        @Dependency(\.accessibility.isDarkerSystemColorsEnabled) var isDarkerSystemColorsEnabled;
        return isDarkerSystemColorsEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Switch Control setting changes.
    public var switchControlStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.switchControlStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isSwitchControlRunning) var isSwitchControlRunning;
        return isSwitchControlRunning
      } placeholder: {
        @Dependency(\.accessibility.isSwitchControlRunning) var isSwitchControlRunning;
        return isSwitchControlRunning
      }
    }

    /// A notification that UIKit posts when the system’s Speak Selection setting changes.
    public var speakSelectionStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.speakSelectionStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isSpeakSelectionEnabled) var isSpeakSelectionEnabled;
        return isSpeakSelectionEnabled
      } placeholder: {
        @Dependency(\.accessibility.isSpeakSelectionEnabled) var isSpeakSelectionEnabled;
        return isSpeakSelectionEnabled
      }
    }

    /// A notification that UIKit posts when the system’s Speak Screen setting changes.
    public var speakScreenStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.speakScreenStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isSpeakScreenEnabled) var isSpeakScreenEnabled;
        return isSpeakScreenEnabled
      } placeholder: {
        @Dependency(\.accessibility.isSpeakScreenEnabled) var isSpeakScreenEnabled;
        return isSpeakScreenEnabled
      }
    }

    /// A notification that UIKit posts when the system's Shake to Undo setting changes.
    public var shakeToUndoDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.shakeToUndoDidChangeNotification) { _ in
        @Dependency(\.accessibility.isShakeToUndoEnabled) var isShakeToUndoEnabled;
        return isShakeToUndoEnabled
      } placeholder: {
        @Dependency(\.accessibility.isShakeToUndoEnabled) var isShakeToUndoEnabled;
        return isShakeToUndoEnabled
      }
    }

    /// A notification that indicates a change in the status of AssistiveTouch.
    public var assistiveTouchStatusDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.assistiveTouchStatusDidChangeNotification) { _ in
        @Dependency(\.accessibility.isAssistiveTouchRunning) var isAssistiveTouchRunning;
        return isAssistiveTouchRunning
      } placeholder: {
        @Dependency(\.accessibility.isAssistiveTouchRunning) var isAssistiveTouchRunning;
        return isAssistiveTouchRunning
      }
    }

    /// A notification that UIKit posts when the system’s Differentiate Without Color
    /// setting changes.
    public var differentiateWithoutColorDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.differentiateWithoutColorDidChangeNotification) { _ in
        @Dependency(\.accessibility.shouldDifferentiateWithoutColor)
        var shouldDifferentiateWithoutColor;
        return shouldDifferentiateWithoutColor
      } placeholder: {
        @Dependency(\.accessibility.shouldDifferentiateWithoutColor)
        var shouldDifferentiateWithoutColor;
        return shouldDifferentiateWithoutColor
      }
    }
    /// A notification that UIKit posts when the system’s On/Off Labels setting changes.
    public var onOffSwitchLabelsDidChange: SystemNotificationOf<Bool> {
      .init(UIAccessibility.onOffSwitchLabelsDidChangeNotification) { _ in
        @Dependency(\.accessibility.isOnOffSwitchLabelsEnabled) var isOnOffSwitchLabelsEnabled;
        return isOnOffSwitchLabelsEnabled
      } placeholder: {
        @Dependency(\.accessibility.isOnOffSwitchLabelsEnabled) var isOnOffSwitchLabelsEnabled;
        return isOnOffSwitchLabelsEnabled
      }
    }

    #if os(iOS)
      /// A notification that UIKit posts when there is a change to the currently paired
      /// hearing devices.
      public var hearingDevicePairedEarDidChange:
        SystemNotificationOf<UIAccessibility.HearingDeviceEar>
      {
        .init(UIAccessibility.hearingDevicePairedEarDidChangeNotification) { _ in
          @Dependency(\.accessibility.hearingDevicePairedEar) var hearingDevicePairedEar;
          return hearingDevicePairedEar
        } placeholder: {
          @Dependency(\.accessibility.hearingDevicePairedEar) var hearingDevicePairedEar;
          return hearingDevicePairedEar
        }
      }
    #endif
  }
#endif
