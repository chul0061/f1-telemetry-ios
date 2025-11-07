import Foundation
import ComposableArchitecture

struct F1Client {
    var connect: @Sendable (UInt16) async -> Void
    var disconnect: @Sendable () async -> Void
    var telemetryStream: @Sendable () async -> AsyncStream<CarTelemetryData>
}

extension F1Client: DependencyKey {
    static let liveValue = F1Client(
        connect: { port in
            await F1ClientLive.shared.connect(port: port)
        },
        disconnect: {
            await F1ClientLive.shared.disconnect()
        },
        telemetryStream: {
            await F1ClientLive.shared.telemetryStream()
        }
    )
    
    static let testValue = F1Client(
        connect: { _ in },
        disconnect: { },
        telemetryStream: {
            AsyncStream { continuation in
                Task {
                    while !Task.isCancelled {
                        let mockData = CarTelemetryData(
                            speed: UInt16.random(in: 0...350),
                            throttle: Float.random(in: 0...1),
                            steer: 0,
                            brake: Float.random(in: 0...1),
                            clutch: 0,
                            gear: Int8.random(in: 1...8),
                            engineRPM: UInt16.random(in: 0...15000),
                            drs: false,
                            revLightsPercent: 0,
                            brakesTemperature: [0, 0, 0, 0],
                            tyresSurfaceTemperature: [0, 0, 0, 0],
                            tyresInnerTemperature: [0, 0, 0, 0],
                            engineTemperature: 90,
                            tyresPressure: [23.5, 23.5, 23.5, 23.5],
                            surfaceType: [0, 0, 0, 0]
                        )
                        continuation.yield(mockData)
                        try? await Task.sleep(for: .milliseconds(50))
                    }
                }
            }
        }
    )
}

extension DependencyValues {
    var f1Client: F1Client {
        get { self[F1Client.self] }
        set { self[F1Client.self] = newValue }
    }
}

// MARK: - Live Implementation
actor F1ClientLive {
    static let shared = F1ClientLive()
    
    private var receiver: UDPReceiver?
    private var isConnected = false
    
    func connect(port: UInt16) {
        guard !isConnected else { return }
        receiver = UDPReceiver()
        isConnected = true
    }
    
    func disconnect() {
        Task {
            await receiver?.stop()
            receiver = nil
            isConnected = false
        }
    }
    
    func telemetryStream() -> AsyncStream<CarTelemetryData> {
        guard let receiver = receiver else {
            return AsyncStream { _ in }
        }
        
        return AsyncStream { continuation in
            Task {
                for await data in await receiver.startListening() {
                    if let telemetryData = parseTelemetryPacket(data) {
                        continuation.yield(telemetryData)
                    }
                }
            }
        }
    }
    
    private func parseTelemetryPacket(_ data: Data) -> CarTelemetryData? {
        // 패킷이 충분한 크기인지 확인
        guard data.count >= 24 else { return nil }
        
        // PacketID 확인 (6번째 바이트)
        let packetId = data[5]
        guard packetId == PacketId.carTelemetry.rawValue else { return nil }
        
        // 플레이어 인덱스 가져오기
        let playerCarIndex = data[22]
        
        // 헤더 크기 + 차량 데이터 시작 위치 계산
        let headerSize = 29
        let carDataSize = 60 // CarTelemetryData 구조체 크기
        let playerDataOffset = headerSize + (Int(playerCarIndex) * carDataSize)
        
        // 데이터가 충분한지 확인
        guard data.count >= playerDataOffset + carDataSize else { return nil }
        
        // 플레이어 차량 데이터만 파싱
        let carData = data[playerDataOffset..<(playerDataOffset + carDataSize)]
        
        return carData.withUnsafeBytes { bytes in
            let speed = bytes.load(fromByteOffset: 0, as: UInt16.self)
            let throttle = bytes.load(fromByteOffset: 2, as: Float.self)
            let steer = bytes.load(fromByteOffset: 6, as: Float.self)
            let brake = bytes.load(fromByteOffset: 10, as: Float.self)
            let clutch = bytes.load(fromByteOffset: 14, as: UInt8.self)
            let gear = bytes.load(fromByteOffset: 15, as: Int8.self)
            let engineRPM = bytes.load(fromByteOffset: 16, as: UInt16.self)
            let drs = bytes.load(fromByteOffset: 18, as: UInt8.self) == 1
            let revLightsPercent = bytes.load(fromByteOffset: 19, as: UInt8.self)
            
            // 온도 데이터는 간단히 0으로 처리 (필요시 파싱)
            return CarTelemetryData(
                speed: speed,
                throttle: throttle,
                steer: steer,
                brake: brake,
                clutch: clutch,
                gear: gear,
                engineRPM: engineRPM,
                drs: drs,
                revLightsPercent: revLightsPercent,
                brakesTemperature: [0, 0, 0, 0],
                tyresSurfaceTemperature: [0, 0, 0, 0],
                tyresInnerTemperature: [0, 0, 0, 0],
                engineTemperature: 0,
                tyresPressure: [0, 0, 0, 0],
                surfaceType: [0, 0, 0, 0]
            )
        }
    }
}
