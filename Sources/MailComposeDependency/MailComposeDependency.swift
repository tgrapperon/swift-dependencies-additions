#if canImport(MessageUI)
  import MessageUI
  @_spi(Internals) import DependenciesAdditionsBasics

  public struct MailCompose: Sendable, ConfigurableProxy {
    @_spi(Internals) public var _implementation: Implementation

    public struct Implementation: Sendable {
      @MainActorReadWriteProxy public var delegate: (any MFMailComposeViewControllerDelegate & Sendable)?
      @FunctionProxy public var canSendMail: @MainActor @Sendable () -> Bool
      @FunctionProxy public var setSubject: @MainActor @Sendable (String) -> Void
      @FunctionProxy public var setToRecipients: @MainActor @Sendable ([String]?) -> Void
      @FunctionProxy public var setCcRecipients: @MainActor @Sendable ([String]?) -> Void
      @FunctionProxy public var setBccRecipients: @MainActor @Sendable ([String]?) -> Void
      @FunctionProxy public var setMessageBody:
        @MainActor @Sendable (String, _ isHTML: Bool) -> Void
      @FunctionProxy public var addAttachmentData:
        @MainActor @Sendable (Data, _ mimeType: String, _ fileName: String) -> Void
      @FunctionProxy public var setPreferredSendingEmailAddress:
        @Sendable @MainActor (String) -> Void
    }

    /// The mail composition view controller’s delegate.
    @MainActor
    public var delegate: (any MFMailComposeViewControllerDelegate & Sendable)? {
      get { self._implementation.delegate }
      nonmutating set { self._implementation.delegate = newValue }
    }

    /// Returns a Boolean that indicates whether the current device is able to send email.
    @MainActor
    func canSendMail() -> Bool {
      self._implementation.canSendMail()
    }
    /// Sets the initial text for the subject line of the email.
    @MainActor
    func setSubject(_ subject: String) {
      self._implementation.setSubject(subject)
    }
    /// Sets the initial recipients to include in the email’s To field.
    @MainActor
    func setToRecipients(_ toRecipients: [String]?) {
      self._implementation.setToRecipients(toRecipients)
    }
    /// Sets the initial recipients to include in the email’s Cc field.
    @MainActor
    func setCcRecipients(_ ccRecipients: [String]?) {
      self._implementation.setCcRecipients(ccRecipients)
    }
    /// Sets the initial recipients to include in the email’s Bcc field.
    @MainActor
    func setBccRecipients(_ bccRecipients: [String]?) {
      self._implementation.setBccRecipients(bccRecipients)
    }
    /// Sets the initial body text to include in the email.
    @MainActor
    func setMessageBody(_ body: String, isHTML: Bool) {
      self._implementation.setMessageBody(body, isHTML)
    }
    /// Adds the specified data as an attachment to the message.
    @MainActor
    func addAttachmentData(_ attachment: Data, mimeType: String, fileName: String) {
      self._implementation.addAttachmentData(attachment, mimeType, fileName)
    }

    /// Sets the preferred email address to use in the From field, if such an address is available.
    @MainActor
    func setPreferredSendingEmailAddress(_ emailAddress: String) {
      self._implementation.setPreferredSendingEmailAddress(emailAddress)
    }
  }

extension MailCompose: DependencyKey {
  public static var liveValue: MailCompose {
    let mailComposeController = MainActorIsolated {
      MFMailComposeViewController()
    }
    let delegate = LockIsolated((any MFMailComposeViewControllerDelegate & Sendable)?.none)

    return .init(
      _implementation: .init(
        delegate: .init(.init(get: {
          return delegate.value
        }, set: { newValue in
          delegate.withValue {
            $0 = newValue
            mailComposeController.withValue {
              $0.mailComposeDelegate = newValue
            }
          }
        })),
        canSendMail: .init {
          MFMailComposeViewController.canSendMail()
        },
        setSubject: .init {
          mailComposeController.value.setSubject($0)
        },
        setToRecipients: .init {
          mailComposeController.value.setToRecipients($0)
        },
        setCcRecipients: .init {
          mailComposeController.value.setCcRecipients($0)
        },
        setBccRecipients: .init {
          mailComposeController.value.setBccRecipients($0)
        },
        setMessageBody: .init {
          mailComposeController.value.setMessageBody($0, isHTML: $1)
        },
        addAttachmentData: .init {
          mailComposeController.value.addAttachmentData($0, mimeType: $1, fileName: $2)
        },
        setPreferredSendingEmailAddress: .init {
          mailComposeController.value.setPreferredSendingEmailAddress($0)
        }
      )
    )
  }
}

#endif
