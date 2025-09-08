# macOS YubiKey SmartCards

macOS provides support for SmartCards, including YubiKey devices.

## Prerequisites

You must have the following already configured in your YubiKey:

- a 9a **Authentication** certificate (ECCP256)
- a 9d **Key Management** certificate (ECCP256)

## Enabling / Pairing SmartCards

To enable SmartCard support on macOS, you can run the following commands:

```shell
# check current smartcards in the system
$> sudo security list-smartcards
    com.apple.pivtoken:DEADBEEF00000000000000000000000000000000

$> pluginkit -m -p com.apple.ctk-tokens
    com.apple.CryptoTokenKit.pivtoken(1.0)
    com.apple.CryptoTokenKit.ctkcard.ctkcardtoken(1)
    com.apple.PlatformSSOToken(1.0)

# Check the current status of macOS's SmartCard automatic pairing UI prompt
$> sc_auth pairing_ui -s status
SmartCard Pairing dialog is enabled.

# Explicitly enable the SmartCard automatic pairing UI prompt
$> sc_auth pairing_ui -s enable

# In case the prompt does not appear when connecting a new SmartCard, you can also open the UI with
$> sc_auth pairing
```

## References

[Yubikey for macOS](https://support.yubico.com/hc/en-us/articles/19506639966236-YubiKey-for-macOS-login-Advanced-topics)
