import Foundation
import Network

actor UDPReceiver {
    private var listener: NWListener?
    
func startListening(port: UInt16 = 20777) -> AsyncStream<Data> {
    AsyncStream { continuation in
        let parameters = NWParameters.udp
        parameters.allowLocalEndpointReuse = true
        
        guard let listener = try? NWListener(using: parameters, on: NWEndpoint.Port(rawValue: port)!) else {
            print("Failed to create listener")
            continuation.finish()
            return
        }
        
        // 로컬 함수로 정의 (nonisolated)
        func receiveData(from connection: NWConnection) {
            connection.receiveMessage { data, context, isComplete, error in
                if let data = data, !data.isEmpty {
                    continuation.yield(data)
                }
                
                if error == nil && !isComplete {
                    receiveData(from: connection)
                } else if let error = error {
                    print("Receive error: \(error)")
                }
            }
        }
        
        // UDP 브로드캐스트는 newConnectionHandler 사용
        listener.newConnectionHandler = { connection in
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    receiveData(from: connection)  // self 없이 호출 가능
                case .failed(let error):
                    print("Connection failed: \(error)")
                default:
                    break
                }
            }
            connection.start(queue: .global())
        }
        
        listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("UDP listener ready on port \(port)")
            case .failed(let error):
                print("UDP listener failed: \(error)")
                continuation.finish()
            case .cancelled:
                print("UDP listener cancelled")
            default:
                break
            }
        }
        
        listener.start(queue: .global())
        
        continuation.onTermination = { _ in
            listener.cancel()
        }
        
        Task {
            await self.setListener(listener)
        }
        
        print("UDP listener started on port \(port)")
    }
}
    
    // nonisolated로 변경 - continuation만 사용하므로 actor isolation 불필요
    nonisolated private func receiveData(from connection: NWConnection, continuation: AsyncStream<Data>.Continuation) {
        connection.receiveMessage { [self] data, context, isComplete, error in
            if let data = data, !data.isEmpty {
                continuation.yield(data)
            }
            
            if error == nil && !isComplete {
                self.receiveData(from: connection, continuation: continuation)
            } else if let error = error {
                print("Receive error: \(error)")
            }
        }
    }
    
    private func setListener(_ listener: NWListener) {
        self.listener = listener
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
    }
}
