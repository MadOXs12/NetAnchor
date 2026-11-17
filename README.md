<div align="center">

# ⚓ NetAnchor Pro
### The Zero-Drop Network, Latency & Audio Optimizer for Windows

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://github.com/Xiam/NetAnchor)
[![Language](https://img.shields.io/badge/Language-PowerShell%20%7C%20WPF-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/Xiam/NetAnchor)
[![License](https://img.shields.io/badge/License-MIT-brightgreen?style=for-the-badge)](LICENSE)
[![Zero-Dependencies](https://img.shields.io/badge/Dependencies-Zero%20(Native%20WPF)-success?style=for-the-badge)](#)

**NetAnchor** is an open-source, zero-dependency, 1-click utility designed to permanently eliminate random Ethernet dropouts (especially the notorious **Intel I219-V / I225-V Event ID 27** bug), eradicate gaming packet lag, remove Windows network throttling, and fix quiet microphone capture levels.

[Quick Start](#-quick-start) • [The Problem It Solves](#-the-problem-it-solves) • [Features](#-features) • [CLI & Automation](#-cli--automation-mode) • [Architecture](#-how-it-works-internally)

</div>

---

## 🎯 The Problem It Solves

### 1. The Intel I219-V / I225-V Dropout Bug (Event ID 27)
Millions of motherboards (ASRock, ASUS, MSI, Gigabyte) with Intel Ethernet chips suffer from sudden, random 2-to-5-second connection drops while gaming or streaming. In the Windows Event Log, this appears as:
> `Event ID 27: Intel(R) Ethernet Connection (11) I219-V Network link is disconnected.`  
> `Event ID 33: Network link has been established at 100Mbps full duplex.`

**Root Cause:** Intel enabled aggressive power-saving protocols (**Energy Efficient Ethernet (EEE)**, **Ultra Low Power (ULP)**, and **PCIe Link State K1**) by default. During small lulls in gaming packets (e.g. in Valorant, CS2, FiveM, Apex, Dota), the chip drops its physical link into deep sleep. Home routers fail the wakeup handshake, crashing the connection and kicking you out of your match.

### 2. Windows Multimedia Network Throttling
By default, Windows throttles non-multimedia network traffic when media or games run, reserving up to 20% of CPU time and queuing packets. This causes random micro-stutter and ping spikes.

### 3. Bufferbloat & Large Send Offload (LSO)
Network card segmentation offloading causes bursts of oversized packets that queue up in the router buffer, leading to jitter and packet loss.

---

## ⚡ Features

| Module | What It Does | Why It Matters |
| :--- | :--- | :--- |
| **🛡️ Hardware Disconnect Shield** | Disables EEE, ULP, ASPM K1, and ReduceSpeedOnPowerDown | Stops the Ethernet chip from going to sleep mid-game. |
| **🔒 Link Flap Stabilizer** | Locks Speed & Duplex to 100M / 1000M Full Duplex | Eliminates endless auto-negotiation speed flapping loops. |
| **🎯 Gaming Latency Optimizer** | Disables Nagle's Algorithm (`TCPNoDelay` & `TcpAckFrequency=1`) | Sends packets immediately without buffering delay. |
| **🚀 Windows Unthrottler** | Sets `NetworkThrottlingIndex = 0xFFFFFFFF` & `SystemResponsiveness = 0` | Gives 100% bandwidth and CPU priority directly to games. |
| **🌐 Ultra-Low Latency DNS** | Sets Cloudflare `1.1.1.1` / `1.0.0.1` + Google `8.8.8.8` fallback | Eliminates domain resolution timeouts and game match drops. |
| **🛡️ Power Sleeping Block** | Disables Windows PnP device power-down on the NIC | Keeps the network card awake 24/7 even during idle downloads. |
| **🎙️ Audio & Mic Diagnostics** | Detects DC offset ground shorts and recording volume | Identifies quiet mic issues across OBS, Bandicam, and Discord. |

---

## 🚀 Quick Start

### Method 1: 1-Click Run (No Installation Needed)
1. Download or clone this repository:
   ```bash
   git clone https://github.com/Xiam/NetAnchor.git
   ```
2. Double-click **`NetAnchor.bat`**.
3. Click **"Yes"** on the Windows UAC permission prompt.
4. Click the big blue button: **`[ 🚀 1-CLICK FIX EVERYTHING ]`**.

### Method 2: Create Desktop & Start Menu Shortcuts
Run PowerShell as Administrator in the repository folder:
```powershell
.\install.ps1
```
This generates a clean desktop shortcut with a shield icon.

---

## 💻 CLI & Automation Mode

NetAnchor can also be executed headless or silently in sysadmin, unattended, or gaming script setups:

```powershell
# Run all optimizations silently with zero prompts
.\NetAnchor.bat -Silent -FixAll

# Run diagnostics only and output JSON status to console
powershell -ExecutionPolicy Bypass -File .\src\NetAnchor.ps1 -DiagnoseOnly
```

---

## 🔬 How It Works Internally

NetAnchor directly interfaces with the Windows Hardware Registry and NDIS Miniport layers:

```
[NetAnchor Engine]
    ├── NetAdapter Properties (via NDIS)
    │     ├── EEELinkAdvertisement     --> 0 (Off)
    │     ├── ULPMode                  --> 0 (Disabled)
    │     ├── EnableK1                 --> 0 (ASPM Off)
    │     ├── *LsoV2IPv4 / *LsoV2IPv6  --> 0 (Off)
    │     └── *SpeedDuplex             --> 4 (100M Full Duplex Lock)
    │
    ├── Multimedia Registry (SystemProfile)
    │     ├── NetworkThrottlingIndex   --> 0xFFFFFFFF (Disabled)
    │     ├── SystemResponsiveness     --> 0 (100% Gaming Priority)
    │     └── Tasks\Games\GPU Priority --> 8 (High)
    │
    ├── TCP/IP Stack Hardening
    │     ├── TcpAckFrequency          --> 1 (Instant ACK)
    │     ├── TCPNoDelay               --> 1 (Nagle Off)
    │     └── autotuninglevel          --> normal
    │
    └── DNS & Adapter Power Management
          ├── Interface DNS            --> 1.1.1.1 / 1.0.0.1
          └── MSPower_DeviceEnable     --> False (Never sleep)
```

---

## 📦 Project Structure

```
NetAnchor/
├── .gitignore             # Git ignore file
├── LICENSE                # MIT License
├── README.md              # Documentation
├── NetAnchor.bat          # Self-elevating root executable launcher
├── install.ps1            # Shortcut installer for Desktop & Start Menu
└── src/
    └── NetAnchor.ps1      # Core WPF Dark UI + Engine logic
```

---

## 🛡️ License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

---

<div align="center">
  <b>Built by gamers, for gamers. If NetAnchor fixed your connection, leave a ⭐ on GitHub!</b>
</div>
