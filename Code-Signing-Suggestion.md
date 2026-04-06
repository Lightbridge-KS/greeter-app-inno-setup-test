# Code Signing Suggestion

## Purpose

Code signing is a mechanism for digitally signing software artifacts such as executables and installers. For a Windows application, code signing helps establish two important properties:

1. **Authenticity** — the signed file can be associated with the publisher identity that signed it.
2. **Integrity** — if the file is modified after signing, the signature becomes invalid.

For this repository, code signing is primarily relevant for the published `GreeterApp.exe` and the generated Inno Setup installer (`Setup.exe`).

---

## What Code Signing Does

A valid code-signing signature helps Windows and end users understand:

- who published the software
- whether the file has been altered after signing
- whether the installer should be treated with more trust than an unsigned executable

In practice, code signing improves the distribution experience by reducing the likelihood that Windows will present the software as coming from an unknown publisher.

---

## What Code Signing Does Not Do

Code signing does **not** guarantee that software is safe, bug-free, or trustworthy in a broader security sense.

It does **not**:
- certify that the application is free of vulnerabilities
- guarantee that the publisher has good intentions
- replace malware scanning, secure development, or release review

It proves publisher identity and file integrity; it is not a substitute for software quality or security assurance.

---

## Standard (Normal) Code Signing vs EV Code Signing

### Standard Code Signing

Standard code signing provides the core capabilities needed for software distribution:

- publisher identification
- tamper detection
- improved trust compared with unsigned files

This is the most practical baseline for many applications and internal distribution scenarios.

However, Windows SmartScreen may still show warnings for a newly released application, especially if the publisher has not yet established reputation.

### EV Code Signing

EV (Extended Validation) code signing applies a stricter identity verification process for the publisher.

Compared with standard code signing, EV generally offers:

- stronger initial trust signals
- a better reputation posture for public Windows distribution
- a smoother experience for end users when downloading and running installers

The tradeoff is that EV signing is typically more expensive and operationally more complex.

---

## Personal Testing Use vs Production Use

### Personal or Internal Testing

For experimentation or internal testing, a **self-signed certificate** can be used at no cost.

This is useful for:
- validating the signing workflow
- testing CI/CD automation
- confirming that the installer and application can be signed successfully

However, self-signed certificates are **not suitable for public distribution**, because external users and Windows itself will not inherently trust them.

### Organization or Production Use

For production use cases such as a RAMAAI company installer, a **publicly trusted organization code-signing solution** is recommended.

Suitable production-grade options include:
- standard organization-validated code-signing certificates
- EV code-signing certificates
- managed cloud signing services

For a company-distributed Windows installer, self-signed certificates should be treated only as a testing tool, not a release strategy.

---

## Certificate Handling and CI/CD Integration

A common GitHub Actions integration pattern is:

1. publish the Windows application
2. sign the published application binary
3. build the Inno Setup installer
4. sign the final installer output
5. verify both signatures before release

Historically, this is often implemented using:
- a `.pfx` certificate file
- a certificate password
- a timestamp server URL

Typical GitHub secrets for that approach are:
- `WINDOWS_CERT_PFX_BASE64`
- `WINDOWS_CERT_PASSWORD`
- `WINDOWS_TIMESTAMP_URL`

The certificate material should **never** be committed to the repository.

---

## Why Timestamping Matters

Timestamping allows a signed file to remain valid even after the signing certificate expires, provided the signature was created while the certificate was valid.

Without timestamping, the long-term value of the signature is significantly reduced.

For release pipelines, timestamping should be considered mandatory.

---

## Recommendation for This Repository

For this repository, the practical recommendation is:

### Short-term / testing
Use a self-signed certificate if the immediate goal is only to validate the build-and-sign workflow.

### Medium-term / public distribution baseline
Use a standard organization code-signing certificate to sign:
- `GreeterApp.exe`
- the generated Inno Setup installer
- the uninstaller, if included in the signing flow

### Higher-trust production posture
If the software will be distributed broadly to external users, consider EV signing or a managed cloud-signing service for a more reliable trust experience.

---

## Current Status in This Repository

At the time of writing, the repository does **not** yet contain a code-signing configuration in the Inno Setup script or GitHub Actions workflow.

That means the current packaging pipeline builds an installer successfully, but does not yet produce signed release artifacts.

---

## Final Summary

Code signing is best understood as a digital proof of publisher identity and file integrity.

For testing, a free self-signed certificate may be sufficient.
For real organizational release scenarios, a trusted code-signing solution should be used.
For this repository, the most reasonable next step is to integrate signing into GitHub Actions so that published binaries and installer outputs are signed automatically during release builds.
