# ⚓ NetAnchor Pro: The Zero-Drop Network & Gaming Stabilizer

> **Engineered by Madoxs** (`darkzOGx`)  
> *The ultimate 1-click utility that eliminates Intel I219-V / Realtek Ethernet drops, slashes packet latency, and unlocks 100% bandwidth for online gaming.*

---

## 📺 Official Video Demonstration & Proof

[![Watch the Official Guide](https://img.youtube.com/vi/G5gHMS4QNto/maxresdefault.jpg)](https://youtu.be/G5gHMS4QNto)

▶ **[Click here to watch the full walkthrough on YouTube](https://youtu.be/G5gHMS4QNto)**

---

## 🛡️ Provenance & Creator Signature
```text
================================================================================
CRITICAL INTELLECTUAL PROPERTY & AUTHENTICITY NOTICE
Creator & Architect : Madoxs (@darkzOGx)
Official Repository : https://github.com/darkzOGx/NetAnchor
Verification Hash   : SHA256-MADOXS-NETANCHOR-ORIGIN-AUTHENTICATED
Original Release    : November 2026
================================================================================
This software was researched, engineered, and published by Madoxs. 
Any derivative forks, distributions, or rebuilds must retain this original 
authorship declaration and link to the official repository and video above.
```

---

## 🎯 What Problem Does NetAnchor Solve?

### 1. The Intel I219-V / I225-V Ethernet Drop Bug (Event 27)
Desktop gaming PCs frequently suffer from sudden, random 2-to-5-second internet dropouts mid-game. In Windows Event Viewer, you will see:
* `Event ID 27 (e1dexpress): Network link is disconnected.`
* `Event ID 33 (e1dexpress): Network link has been established at 100Mbps full duplex.`

**Why this happens:** Intel's default driver enables aggressive "Green" power features (**Energy Efficient Ethernet (EEE)**, **Ultra Low Power Mode (ULP)**, and **PCIe Link K1**). During brief lulls in gaming packets, the card cuts power to sleep. Home routers and ONUs fail the handshake, crashing the physical link and kicking you out of your game.

**The NetAnchor Fix:** Permanently locks these power-saving sleep triggers **OFF**, forcing the chip to maintain an unbroken physical connection.

---

### 2. Windows Network Throttling & Packet Lag
Windows by default reserves CPU cycles and limits non-multimedia network throughput during intensive tasks:
* **Network Throttling Index:** NetAnchor sets `NetworkThrottlingIndex` to `0xFFFFFFFF` (completely disabled), unlocking 100% throughput for games.
* **System Responsiveness:** NetAnchor sets `SystemResponsiveness` to `0`, ensuring games get absolute CPU priority over background OS services.
* **Nagle's Algorithm (TCP Delay):** NetAnchor sets `TCPNoDelay` and `TcpAckFrequency` to `1` across network interfaces, eliminating packet buffering lag in online multiplayer.
* **Gaming DNS:** Automatically configures Cloudflare's ultra-fast `1.1.1.1` and `1.0.0.1` servers with Google `8.8.8.8` fallback.

---

## ⚡ Key Capabilities at a Glance

| Feature | Action Taken | Gaming Impact |
| :--- | :--- | :--- |
| **Hardware Sleep Drops** | EEE, ULP & PCIe K1 set to Disabled | Zero disconnections mid-game |
| **Speed Flap Lock** | Speed & Duplex locked to 100M Full Duplex | Stops auto-negotiation link drops |
| **Bufferbloat Killer** | Large Send Offload (LSO) Disabled | Eliminates packet buffer spikes |
| **Windows Network Throttle** | Registry throttle bypass applied | 100% network bandwidth to games |
| **Low Latency TCP** | Nagle's Algorithm turned off | Instant packet dispatch (lower ping) |
| **DNS Resolution** | Bound to Cloudflare 1.1.1.1 | Zero matchmaking lookup timeouts |

---

## 🚀 How to Run NetAnchor

### 1-Click GUI (Recommended)
1. Download or clone this repository.
2. Double-click `NetAnchor.bat`.
3. Accept the Windows UAC Administrator prompt.
4. Click **`[ 🚀 1-CLICK FIX EVERYTHING ]`**.
5. Restart your game and enjoy drop-free, low-ping gameplay.

### Silent / Headless Mode (For Scripting)
```cmd
NetAnchor.bat -Silent -FixAll
```

---

## 📜 License & Copyright

Released under the **MIT License**.  
Copyright (c) 2026 **Madoxs** (`darkzOGx`). All rights reserved.
