# OPSEC Postmortem: YubiKey CLI (ykman) scripting difficulties

## Hotfix

We removed the non-functional non-interactive flags (`--new`, `--new-pin`, etc.) from the `ykman openpgp access` commands and returned to using interactive prompts or adapted the script for the expected CLI behavior based on the installed version. We also corrected `gpg --batch` key generation syntax, which was silently failing due to unsupported or misordered directives.

## Root cause analysis

This incident stemmed from multiple issues involving `ykman` and `gpg` tooling:

1. **`ykman` CLI version mismatches:**  
   The syntax for setting PINs, admin PINs, and reset codes changed between versions. Flags such as `--new-pin` were accepted in some versions but rejected in others without warning.
   
2. **Undocumented argument order requirements:**  
   Some `ykman` commands failed silently or rejected valid arguments when the positional order was not strictly correct — despite appearing valid in the help output.

3. **Incorrect `gpg` batch file formatting:**  
   GPG key generation in batch mode is extremely picky. We encountered errors with:
   - `duplicate keyword` due to multiple `Subkey-Type` entries
   - `invalid usage list` from trying unsupported `Key-Usage` values
   - Field ordering issues (e.g., putting `%commit` after identity values)

4. **Tool inconsistencies and poor documentation:**  
   The `ykman` CLI does not provide clear or version-specific help output. Similarly, GnuPG’s batch mode syntax is fragile and poorly documented for smartcard/PGP workflows.

## Solution (Long term)

- Build an environment check at the top of the script that verifies:
  - `ykman --version` and adapts command flags accordingly
  - `gpg --version` to detect ECC vs RSA key compatibility

- Refactor the script to:
  - Prompt interactively for PINs where needed instead of relying on unsupported automation
  - Generate the GPG master key with batch, and add subkeys using `--edit-key` only

- Document version-specific CLI behaviors with real examples so future script authors understand what's stable vs what’s fragile.

- Consider replacing `ykman` scripting entirely with a thin wrapper that uses `expect` or delegates PIN configuration to human input with strong defaults.

🧠 Lessons learned: writing OPSEC-hardened scripts is like fighting an invisible bureaucracy made of regex and shame.
