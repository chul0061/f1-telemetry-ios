import Foundation

// MARK: - Packet Header (모든 패킷 공통)
struct PacketHeader {
    let packetFormat: UInt16          // 2023 = 2023 format
    let gameYear: UInt8               // Game year - last two digits e.g. 23
    let gameMajorVersion: UInt8       // Game major version - "X.00"
    let gameMinorVersion: UInt8       // Game minor version - "1.XX"
    let packetVersion: UInt8          // Version of this packet type
    let packetId: UInt8               // Identifier for the packet type
    let sessionUID: UInt64            // Unique identifier for the session
    let sessionTime: Float            // Session timestamp
    let frameIdentifier: UInt32       // Identifier for the frame the data was retrieved on
    let overallFrameIdentifier: UInt32 // Overall identifier for the frame the data was retrieved on
    let playerCarIndex: UInt8         // Index of player's car in the array
    let secondaryPlayerCarIndex: UInt8 // Index of secondary player's car in the array (255 if no second player)
}

// MARK: - Packet IDs
enum PacketId: UInt8 {
    case motion = 0
    case session = 1
    case lapData = 2
    case event = 3
    case participants = 4
    case carSetups = 5
    case carTelemetry = 6
    case carStatus = 7
    case finalClassification = 8
    case lobbyInfo = 9
    case carDamage = 10
    case sessionHistory = 11
    case tyreSets = 12
    case motionEx = 13
}

// MARK: - Car Telemetry Data
struct CarTelemetryData {
    let speed: UInt16                // Speed of car in kilometres per hour
    let throttle: Float              // Amount of throttle applied (0.0 to 1.0)
    let steer: Float                 // Steering (-1.0 (full lock left) to 1.0 (full lock right))
    let brake: Float                 // Amount of brake applied (0.0 to 1.0)
    let clutch: UInt8                // Amount of clutch applied (0 to 100)
    let gear: Int8                   // Gear selected (1-8, N=0, R=-1)
    let engineRPM: UInt16            // Engine RPM
    let drs: Bool                    // 0 = off, 1 = on
    let revLightsPercent: UInt8      // Rev lights indicator (percentage)
    let brakesTemperature: [UInt16]  // Brakes temperature (celsius) [RL, RR, FL, FR]
    let tyresSurfaceTemperature: [UInt8]  // Tyres surface temperature (celsius) [RL, RR, FL, FR]
    let tyresInnerTemperature: [UInt8]    // Tyres inner temperature (celsius) [RL, RR, FL, FR]
    let engineTemperature: UInt16     // Engine temperature (celsius)
    let tyresPressure: [Float]       // Tyres pressure (PSI) [RL, RR, FL, FR]
    let surfaceType: [UInt8]         // Driving surface [RL, RR, FL, FR]
}

// MARK: - Full Telemetry Packet
struct PacketCarTelemetryData {
    let header: PacketHeader
    let carTelemetryData: [CarTelemetryData]  // 22 cars max
    let mfdPanelIndex: UInt8
    let mfdPanelIndexSecondaryPlayer: UInt8
    let suggestedGear: Int8
}
