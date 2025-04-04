# OPSEC: YubiKey 5 NFC

## 🔐 Required OPSEC Configuration for YubiKey 5 NFC

## Key Reduncancy
- Use **2 or more YubiKeys** for redundancy.
- Name each key after the color selected in the Yubico Authenticator app.
- Suggested naming convention: **Blue**, **Green**, **Red**, **Black**.

## PINs & Reset Codes

> All three values (User PIN, Admin PIN, Reset Code) must be stored in a secure, encrypted system (e.g., Proton Pass Secure Notes with hardware token protection).

- **User PIN**:  
  - May be reused across security keys
  - Must be **8 digits**.
  - Chosen for ease of use during frequent signing or authentication.
  - Should be distinct from Admin PIN and Reset Code.

- **Admin PIN**:  
  - Must be unique. May not be reused across security keys
  - Must be at least **64 characters**.
  - Generated using a password manager (e.g., Proton Pass).
  - Stored securely and never reused across keys or systems.
  - Grants full control over OpenPGP key material and PIN configuration.

- **Reset Code**:  
  - Must be unique. May not be reused across security keys
  - Must be a **10-word diceware-style passphrase**.
  - Used to reset the User PIN if forgotten, without destroying key material.
  - Should be stored securely in a password manager or airgapped backup.