# F1 Telemetry iOS

> ⚠️ **Work in Progress** - This project is currently under active development.

An iOS application that displays real-time telemetry data from F1 25 game using UDP communication.

## Overview

This project allows you to view live telemetry information from F1 25 game on your iOS device. The app connects to the game via UDP and displays real-time data including speed, gear, RPM, throttle, brake, and DRS status.

## Features

- Real-time telemetry data display
- Speed, gear, and RPM monitoring
- Throttle and brake indicators
- DRS status
- Connection status monitoring

## Architecture

Built with:

- **SwiftUI** for the user interface
- **The Composable Architecture (TCA)** for state management
- **Network Framework** for UDP communication

## Project Structure

```
f1-telemetry/
├── App/
│   └── f1_telemetryApp.swift
├── Features/
│   └── Telemetry/
│       ├── TelemetryFeature.swift
│       └── TelemetryView.swift
├── Models/
│   └── TelemetryPackets.swift
├── Services/
│   ├── F1Client.swift
│   └── UDPReceiver.swift
└── Shared/
```

## Setup

### Prerequisites

- iOS 17.0+
- macOS 14.0+ (for development)
- Xcode 15.0+
- F1 25 game

### Installation

1. Clone the repository
2. Open `f1-telemetry.xcodeproj` in Xcode
3. Install dependencies (TCA will be resolved via Swift Package Manager)
4. Build and run on your device or simulator

### F1 25 Game Configuration

1. Launch F1 25 game
2. Go to **Settings** → **Telemetry Settings**
3. Enable **UDP Telemetry**
4. Set **UDP Format** to **2025**
5. Set **Port** to **20777** (default)
6. Enable **Broadcast Mode**

### Network Requirements

- Your iOS device and the device running F1 25 must be on the same network (Wi-Fi or Ethernet)
- No IP address configuration needed - the app listens for UDP broadcasts

## Usage

1. Ensure F1 25 game is running with UDP Telemetry enabled
2. Launch the iOS app
3. Tap the **Connect** button
4. Real-time telemetry data will be displayed

## Testing UDP Connection

To verify UDP data is being received, you can test using terminal:

```bash
nc -ul 20777
```

If packets are visible, the network connection is working correctly.

## Dependencies

- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) - State management

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
