<div align="center">

# ⚡ NetAnchor Pro
### 🛡️ The Zero-Drop Network & Gaming Stabilizer for Windows
**The Official Open-Source "Quick Setup Machine" by MadOxs**

[![GitHub release](https://img.shields.io/badge/Release-v1.0.0-00FFA3?style=for-the-badge&logo=github&logoColor=white)](https://github.com/MadOXs12/NetAnchor/releases)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011%20(64--bit)-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/License-MIT-F7DF1E?style=for-the-badge&logoColor=black)](LICENSE)
[![YouTube Video](https://img.shields.io/badge/YouTube-Video%20Guide-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/G5gHMS4QNto)

<p align="center">
  <strong>Eliminates Intel I219-V / Realtek Ethernet 3-second disconnects, crushes packet latency, and unlocks 100% bandwidth for online gaming.</strong>
</p>

---

</div>

## 📺 Official Video Walkthrough & Proof

[![Watch the Official Guide](https://img.youtube.com/vi/G5gHMS4QNto/maxresdefault.jpg)](https://youtu.be/G5gHMS4QNto)

<div align="center">

▶️ **[Click here to watch the complete video guide on YouTube](https://youtu.be/G5gHMS4QNto)**

</div>

### ⏱️ Video Chapters:
- `0:00` — What Happens If You Don't Fix This (The 999ms Ping Disaster)
- `0:04` — The Mid-Match Disconnect Rage
- `0:07` — The Result: Rock-Solid 12ms Ping & 0% Packet Loss
- `0:13` — The Root Cause: The Intel I219-V Micro-Sleep Bug (Event ID 27)
- `0:21` — Hidden Windows Choke: Large Send Offload & Network Throttling
- `0:28` — **1-Click Fix with Quick Setup Machine**
- `0:41` — Verification & GitHub Open Source Release

---

## 🛡️ Provenance & Creator Signature

```text
================================================================================
CRITICAL INTELLECTUAL PROPERTY & AUTHENTICITY NOTICE
Creator & Architect : MadOxs (@MadOXs12)
Official Repository : https://github.com/MadOXs12/NetAnchor
Official Video      : https://youtu.be/G5gHMS4QNto
Verification Hash   : SHA256-MADOXS-NETANCHOR-ORIGIN-AUTHENTICATED
Original Release    : November 2026
================================================================================
This software was researched, engineered, and published by MadOxs.
Any derivative forks, distributions, or rebuilds must retain this original 
authorship declaration and link to the official repository and video above.
```

---

## 🎯 What Problem Does NetAnchor Solve?

### 1. The Intel I219-V / I225-V Ethernet Drop Bug (Event ID 27)
Desktop gaming PCs frequently suffer from sudden, random **2-to-5-second internet dropouts** mid-match. In the Windows Event Viewer, you will see:
* `Event ID 27 (e1dexpress): Network link is disconnected.`
* `Event ID 33 (e1dexpress): Network link has been established at 100Mbps full duplex.`

**Why this happens:** Intel's default driver enables aggressive "Green" power-saving modes:
- **Energy Efficient Ethernet (EEE)**
- **Ultra Low Power Mode (ULP)**
- **PCIe Link State Power Management (ASPM / K1)**

During brief millisecond lulls in gaming packets, the Ethernet chip aggressively cuts power to enter sleep mode. Home routers and ONUs fail the wake-up handshake, crashing the physical link and kicking you out of your game.

> **The NetAnchor Fix:** Permanently locks these power-saving sleep triggers **OFF**, forcing the Ethernet controller to maintain an unbroken, persistent physical link.

---

### 2. Windows Network Throttling & Packet Latency
By default, Windows restricts non-multimedia network throughput during intensive CPU loads and introduces packet buffering delays:
* **Network Throttling Bypass:** NetAnchor sets `NetworkThrottlingIndex` to `0xFFFFFFFF` (completely disabled), unlocking 100% network throughput for games.
* **System Responsiveness:** NetAnchor sets `SystemResponsiveness` to `0`, ensuring online games get absolute CPU scheduling priority over background OS tasks.
* **Nagle's Algorithm (TCP NoDelay):** NetAnchor sets `TCPNoDelay` and `TcpAckFrequency` to `1` across network interfaces, eliminating packet batching delays and instantly sending game packets.
* **Cloudflare Ultra-Fast Gaming DNS:** Automatically configures Cloudflare's ultra-low-latency `1.1.1.1` and `1.0.0.1` servers with Google `8.8.8.8` fallback to prevent matchmaking resolution timeouts.

---

## ⚡ Comparison: Before vs. After NetAnchor

| Feature / Metric | Stock Windows 10/11 | With NetAnchor Applied |
| :--- | :--- | :--- |
| **Intel I219-V Link Sleep** | ❌ Micro-sleeps drop connection (Event 27) | ✔️ **Permanently Anchored (0 disconnects)** |
| **Packet Buffer Choke (LSO)** | ❌ Enabled (Spikes ping in firefights) | ✔️ **Disabled (Ultra-consistent buffer)** |
| **Windows Network Throttle** | ❌ 10 packets/ms limit active | ✔️ **Bypassed (100% throughput to games)** |
| **Packet Dispatch (Nagle)** | ❌ Delays packets in buffer queues | ✔️ **Instant TCP dispatch (Zero queuing lag)** |
| **Speed & Duplex** | ⚠️ Auto-negotiation flaps link | ✔️ **Locked to 100M Full Duplex** |
| **DNS Resolution** | ⚠️ ISP default (Slow & throttled) | ✔️ **Cloudflare 1.1.1.1 Ultra-Fast Gaming DNS** |

---

## 🚀 How to Run NetAnchor (Quick Setup Machine)

### Method 1: 1-Click GUI (Recommended)
1. **[Download the Latest ZIP](https://github.com/MadOXs12/NetAnchor/archive/refs/heads/main.zip)** or clone this repository:
   ```cmd
   git clone https://github.com/MadOXs12/NetAnchor.git
   ```
2. Right-click **`Quick Setup Machine.bat`** (or `NetAnchor.bat`) and select **Run as Administrator**.
3. In the dark gaming GUI, click **`[ 🚀 1-CLICK FIX EVERYTHING ]`**.
4. Restart your game and enjoy smooth, low-ping, drop-free gaming!

---

### Method 2: Create Desktop Shortcut (Installer)
Run `install.ps1` in PowerShell to automatically place a **Quick Setup Machine** shortcut directly onto your Windows Desktop:
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

---

### Method 3: Headless / Silent Mode (For Scripts & Auto-Deploy)
To run the complete optimization silently without showing the GUI:
```cmd
"Quick Setup Machine.bat" -Silent -FixAll
```
*(Or via PowerShell directly: `powershell -ExecutionPolicy Bypass -File src/NetAnchor.ps1 -Silent -FixAll`)*

---

## 💻 System Requirements & Compatibility

- **Operating System:** Windows 10 & Windows 11 (64-bit)
- **Supported Adapters:** Intel I219-V, Intel I219-LM, Intel I225-V, Realtek GbE Family, Killer Ethernet, and all standard PCIe LAN adapters.
- **Privileges:** Administrator access required to modify hardware power states and network registry values.

---

## 📜 License & Copyright

Distributed under the **MIT License**.  
Copyright (c) 2026 **MadOxs** (`@MadOXs12`). All rights reserved.

<div align="center">
  <sub>⚡ Engineered with passion by <b>MadOxs</b>. If this saved your matches, leave a ⭐ on this repo! ⚡</sub>
</div>
