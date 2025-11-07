import Foundation
import ComposableArchitecture

@Reducer
struct TelemetryFeature {
    @ObservableState
    struct State: Equatable {
        var isConnected = false
        var speed: UInt16 = 0
        var gear: Int8 = 0
        var engineRPM: UInt16 = 0
        var throttle: Float = 0
        var brake: Float = 0
        var drs: Bool = false
        var connectionError: String?
    }
    
    enum Action {
        case connect
        case disconnect
        case telemetryReceived(CarTelemetryData)
        case connectionFailed(String)
    }
    
    @Dependency(\.f1Client) var f1Client
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .connect:
                state.isConnected = true
                state.connectionError = nil
                
                return .run { send in
                    await f1Client.connect(20777)
                    
                    for await telemetryData in await f1Client.telemetryStream() {
                        await send(.telemetryReceived(telemetryData))
                    }
                }
                .cancellable(id: "telemetry-stream")
                
            case .disconnect:
                state.isConnected = false
                
                return .run { _ in
                    await f1Client.disconnect()
                }
                .cancellable(id: "telemetry-stream", cancelInFlight: true)
                
            case let .telemetryReceived(data):
                state.speed = data.speed
                state.gear = data.gear
                state.engineRPM = data.engineRPM
                state.throttle = data.throttle
                state.brake = data.brake
                state.drs = data.drs
                return .none
                
            case let .connectionFailed(error):
                state.isConnected = false
                state.connectionError = error
                return .none
            }
        }
    }
}
