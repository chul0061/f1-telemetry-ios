import SwiftUI
import ComposableArchitecture

struct TelemetryView: View {
    let store: StoreOf<TelemetryFeature>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Connection Status
                HStack {
                    Circle()
                        .fill(store.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(store.isConnected ? "연결됨" : "연결 안됨")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button(store.isConnected ? "연결 끊기" : "연결") {
                        if store.isConnected {
                            store.send(.disconnect)
                        } else {
                            store.send(.connect)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                if store.isConnected {
                    // Speed
                    VStack {
                        Text("속도")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("\(store.speed)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                        Text("km/h")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.1))
                    )
                    
                    // Gear & RPM
                    HStack(spacing: 20) {
                        // Gear
                        VStack {
                            Text("기어")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(gearDisplay)
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(gearColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.1))
                        )
                        
                        // RPM
                        VStack {
                            Text("RPM")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(store.engineRPM)")
                                .font(.system(size: 36, weight: .medium, design: .rounded))
                            
                            // RPM Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.3))
                                    
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(rpmBarColor)
                                        .frame(width: geometry.size.width * CGFloat(store.engineRPM) / 15000)
                                }
                            }
                            .frame(height: 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    
                    // Throttle & Brake
                    HStack(spacing: 20) {
                        // Throttle
                        VStack {
                            Text("스로틀")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(Int(store.throttle * 100))%")
                                .font(.title2.bold())
                            
                            ProgressView(value: Double(store.throttle))
                                .progressViewStyle(.linear)
                                .tint(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green.opacity(0.1))
                        )
                        
                        // Brake
                        VStack {
                            Text("브레이크")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(Int(store.brake * 100))%")
                                .font(.title2.bold())
                            
                            ProgressView(value: Double(store.brake))
                                .progressViewStyle(.linear)
                                .tint(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                    
                    // DRS Status
                    if store.drs {
                        HStack {
                            Image(systemName: "wind")
                            Text("DRS 활성화")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    
                } else {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("F1 게임을 시작하고\nTelemetry Settings에서\nUDP Telemetry를 켜주세요")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        if let error = store.connectionError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("F1 텔레메트리")
        }
    }
    
    private var gearDisplay: String {
        switch store.gear {
        case -1: return "R"
        case 0: return "N"
        default: return "\(store.gear)"
        }
    }
    
    private var gearColor: Color {
        switch store.gear {
        case -1: return .red
        case 0: return .gray
        case 7, 8: return .purple
        default: return .primary
        }
    }
    
    private var rpmBarColor: Color {
        let rpmPercentage = Float(store.engineRPM) / 15000
        if rpmPercentage > 0.95 {
            return .red
        } else if rpmPercentage > 0.85 {
            return .orange
        } else {
            return .green
        }
    }
}
