# DeenGuard Content Blocking Implementation

## The Problem
Flutter cannot natively intercept or block network traffic (like DNS requests) device-wide. It operates in user-space within the app sandbox.

## The Solution: Android Local VPN Service (Split-Tunnel DNS)
To implement device-wide content blocking (specifically for harmful sites and ads), we use an Android **Local VPN Service** in Kotlin. 

Instead of writing a complex packet forwarder that intercepts and parses all IP packets, we use a highly performant **Split-Tunnel** approach that modifies the system DNS without routing real traffic through the VPN.

### How it works:
1. **The VPN Tunnel**: We use Android's `VpnService` API to create a virtual network interface (TUN device).
2. **Split-Tunnel Bypass**: Instead of adding a `0.0.0.0/0` route (which blackholes all traffic), we add a route for a single dummy IP (`10.0.0.3`). This means **all real traffic bypasses the VPN** and goes straight through the user's active Wi-Fi or Mobile Data network.
3. **DNS Enforcement**: We apply custom DNS servers (`94.140.14.15`, AdGuard Family Protection) to the VPN builder. Android routes DNS queries explicitly to this server.
4. **Blocking Action**: Since the DNS requests are handled by AdGuard Family, any request to an adult site, malicious tracker, or known ad network is dropped at the DNS level. The user gets full internet speed with no VPN overhead, while being fully protected.

### Architecture Overview
- **`DeenGuardVpnService.kt`**: The native Android service extending `VpnService`. It handles creating the split-tunnel dummy interface to apply the custom DNS.
- **`MainActivity.kt`**: Bridges the Flutter UI with the native Android service using a `MethodChannel` (`com.example.deenguard/vpn`).
- **`vpn_service.dart`**: A Dart wrapper around the `MethodChannel` used to send start/stop commands to Android.
- **`BlockingBloc`**: The Flutter state management component that triggers the `vpn_service.dart` based on user input from the Dashboard toggle switch.
