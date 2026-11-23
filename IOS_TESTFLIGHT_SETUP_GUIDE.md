# WINCO Connect — iOS App Store & TestFlight CI/CD Guide

> **Important:** This guide explains how to build an iOS App Store release package (`.ipa`) and deploy directly to Apple TestFlight **without owning a MacBook**, using GitHub Actions Apple Silicon (`macos-14`) cloud runners.

---

## 🚀 How it Works (No MacBook Needed)

1. When you push code to GitHub (or trigger the workflow manually under **Actions** > **iOS App Store & TestFlight CI/CD** > **Run workflow**):
2. GitHub starts a dedicated **Apple macOS cloud runner** (`macos-14`).
3. The runner checks out your code, sets up Flutter & Xcode, executes all 101 tests, and compiles the iOS application (`Runner.app` / `.ipa`).
4. Using your **App Store Connect API Key**, GitHub automatically uploads the built `.ipa` directly to **Apple TestFlight**!
5. In addition, GitHub saves the `.ipa` file as a downloadable artifact under the **Actions** tab for 30 days.

---

## 🔑 Required GitHub Secrets Setup

To enable automated signing and direct upload to Apple TestFlight, add the following secrets to your GitHub repository:

👉 Go to: **GitHub** > **wincoapp** > **Settings** > **Secrets and variables** > **Actions** > **New repository secret**

### 1. App Store Connect API Key (For TestFlight Upload)
| Secret Name | Description | Where to get it in Apple Developer |
|---|---|---|
| `APP_STORE_CONNECT_KEY_ID` | 10-character Key ID | App Store Connect > Users and Access > Integrations > App Store Connect API |
| `APP_STORE_CONNECT_ISSUER_ID` | UUID string (Issuer ID) | App Store Connect > Users and Access > Integrations (Displayed at top) |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Contents of `.p8` file (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`) | Downloaded when you create the API key |

### 2. Apple Distribution Certificate & Profile (For Production Signing)
| Secret Name | Description |
|---|---|
| `BUILD_CERTIFICATE_BASE64` | Base64 encoded string of your Apple Distribution `.p12` certificate |
| `P12_PASSWORD` | Password protecting the `.p12` certificate file |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 encoded string of your App Store `.mobileprovision` profile |
| `KEYCHAIN_PASSWORD` | Any strong temporary password (e.g. `WincoSecurePass123!`) |

> **Note on Base64 encoding:**
> To encode your certificate or profile into base64 on Windows PowerShell:
> ```powershell
> [Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Set-Clipboard
> ```
> Then paste directly into the GitHub Secret!

---

## 📲 How to Trigger a TestFlight Build

1. Go to your GitHub repository: `https://github.com/Utsavthesiya146/wincoapp`
2. Click on the **Actions** tab at the top.
3. In the left sidebar, click **iOS App Store & TestFlight CI/CD**.
4. Click **Run workflow** > select branch `main` > click **Run workflow**.
5. Once complete (typically ~10–15 minutes):
   - The build will appear in your **Apple TestFlight** dashboard under App Store Connect.
   - You can also download the `.ipa` file directly from the GitHub Actions run summary page!

---

## 🤖 Android Play Store Automation (Bonus)

We have also included `.github/workflows/android_release.yml`:
- Automatically builds the **Release APK** and **Play Store App Bundle (.aab)** on every push to `main`.
- Saves both binaries as downloadable artifacts under the Actions run.
