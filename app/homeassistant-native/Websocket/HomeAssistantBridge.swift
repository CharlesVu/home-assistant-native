import Combine
import Foundation
import OSLog

protocol HomeAssistantBridging {
    func turnLight(on: Bool, entityID: String) async throws
    var subject: PassthroughSubject<EntityState, Never> { get }
}

class HomeAssistantBridge: NSObject {
    var socket: URLSessionWebSocketTask!
    var decoder = JSONDecoder()

    let messageLogger = Logger(subsystem: "Network", category: "Message")
    let websocketLogger = Logger(subsystem: "Network", category: "Websocket")

    let subject = PassthroughSubject<EntityState, Never>()

    override init() {
        super.init()

        socket = URLSession.shared.webSocketTask(with: Config.websocketEndpoint)
        socket.resume()

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

        decoder.dateDecodingStrategy = .formatted(formatter)

        receive()
    }
}

extension HomeAssistantBridge: URLSessionTaskDelegate {
    // MARK: Receive
    private func receive() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.socket.receive(completionHandler: { result in
                switch result {
                    case .success(let message):
                        switch message {
                            case .data(let data):
                                print("Data received \(data)")
                            case .string(let str):
                                do {
                                    let message = try self.decoder.decode(HAMessage.self, from: str.data(using: .utf8)!)
                                    Task {
                                        await self.handleMessage(message: message)
                                    }
                                } catch {
                                    self.messageLogger.error("----->\n\n\(error)\n\n\(str)\n\n<-----")
                                }
                            default:
                                break
                        }
                    case .failure(let error):
                        ()
                        print("[SOCKET] Error Receiving \(error)")
                }
                self.receive()
            })
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: workItem)
    }

    @MainActor
    private func handleMessage(message: HAMessage) async {
        if message.type == .authRequired {
            try? await sendAuthData()
        } else if message.type == .authOk {
            try? await sendGetStates()
            try? await sendSubscribe()
        } else if message.type == .event {
            if let newState = message.event?.data.newState {
                subject.send(newState)
            }
        } else if message.type == .result, case .entities(let results) = message.result {
            results.forEach { subject.send($0) }
        }
    }
}

// MARK: Websocket Commands
extension HomeAssistantBridge: HomeAssistantBridging {
    func send(message: HAMessage) async throws {
        let json = try! JSONEncoder().encode(message)
        try await socket.send(.string(String(data: json, encoding: .utf8)!))
    }

    func sendSubscribe() async throws {
        let message = HAMessageBuilder.subscribeMessage()
        try await send(message: message)
    }

    func sendAuthData() async throws {
        let message = HAMessageBuilder.authMessage(accessToken: Config.authToken)
        try await send(message: message)
    }

    func sendGetStates() async throws {
        let message = HAMessageBuilder.getStateMessage()
        try await send(message: message)
    }

    func turnLight(on: Bool, entityID: String) async throws {
        let message = HAMessageBuilder.turnLight(on: on, entityID: entityID)
        try await send(message: message)
    }
}
