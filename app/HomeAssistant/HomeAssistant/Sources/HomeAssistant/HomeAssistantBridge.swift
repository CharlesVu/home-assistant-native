import ApplicationConfiguration
import Combine
import Factory
import Foundation
import OSLog

public protocol HomeAssistantBridging {
    func turnLight(on: Bool, entityID: String) async throws -> Int
    var entityPublisher: PassthroughSubject<EntityState, Never> { get }
    var octopusPublisher: PassthroughSubject<[OctopusRate], Never> { get }
    var responsePublisher: PassthroughSubject<HAMessage, Never> { get }
}

public final class HomeAssistantBridge: NSObject {
    @Injected(\.config) private var configurationPublisher
    var configuration: HomeAssistantConfiguration!

    var socket: URLSessionWebSocketTask!
    var decoder = JSONDecoder()

    let messageLogger = Logger(subsystem: "Network", category: "Message")
    let websocketLogger = Logger(subsystem: "Network", category: "Websocket")

    public let entityPublisher = PassthroughSubject<EntityState, Never>()
    public let responsePublisher = PassthroughSubject<HAMessage, Never>()
    public let octopusPublisher = PassthroughSubject<[OctopusRate], Never>()

    private var subscriptions = Set<AnyCancellable>()

    override public init() {
        super.init()

        decoder.dateDecodingStrategyFormatters = [
            .hassTime,
            .octopusTime,
        ]

        configurationPublisher
            .homeAssistantConfigurationPublisher
            .sink { [weak self] configuration in
                guard let self, let configuration else { return }
                self.configuration = configuration
                self.connectWebsocket()
            }
            .store(in: &subscriptions)
        _ = HomeAssistantConfigurationManager()
    }

    func connectWebsocket() {
        if self.socket != nil {
            socket.cancel()
        }
        self.socket = URLSession.shared.webSocketTask(with: configuration.websocketEndpoint)
        self.socket.resume()
        receive()
    }
}

extension HomeAssistantBridge: URLSessionTaskDelegate {
    // MARK: Receive
    private func receive() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self, let socket = self.socket else { return }
            socket.receive { result in
                switch result {
                    case .success(let message):
                        switch message {
                            case .string(let str):
                                do {
                                    let message = try self.decoder.decode(HAMessage.self, from: str.data(using: .utf8)!)
                                    Task {
                                        await self.handleMessage(message: message)
                                    }
                                } catch {
                                    self.messageLogger.debug("Received unhandled message")
                                }
                            default:
                                break
                        }
                    case .failure(_):
                        self.connectWebsocket()
                }
                self.receive()
            }
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
            publishMessage(message: message)
        } else if message.type == .result,
            case .entities(let results) = message.result
        {
            results.forEach { entityPublisher.send($0) }
        } else if message.type == .result {
            responsePublisher.send(message)
        }
    }

    func publishMessage(message: HAMessage) {
        if message.event?.eventType == .octopusCurrentDayRate,
            let rates = message.event?.data.rates
        {
            octopusPublisher.send(rates)
        } else if let newState = message.event?.data.newState {
            entityPublisher.send(newState)
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
        let message = HAMessageBuilder.authMessage(accessToken: configuration.authToken)
        try await send(message: message)
    }

    func sendGetStates() async throws {
        let message = HAMessageBuilder.getStateMessage()
        try await send(message: message)
    }

    public func turnLight(on: Bool, entityID: String) async throws -> Int {
        let message = HAMessageBuilder.turnLight(on: on, entityID: entityID)
        try await send(message: message)
        return message.id!
    }
}

extension DateFormatter {
    static let hassTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()

    static let octopusTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
}
