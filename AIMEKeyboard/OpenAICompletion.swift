//
//  OpenAICompletion.swift
//  AIMEKeyboard
//
//  Created by Galvin Gao on 3/6/23.
//

import Foundation
import LDSwiftEventSource

public enum ChatRole: String, Codable {
    case system, user, assistant
}

public struct ChatMessage: Codable {
    public let role: ChatRole
    public let content: String
    
    public init(role: ChatRole, content: String) {
        self.role = role
        self.content = content
    }
}

public struct ChatConversation: Encodable {
    let messages: [ChatMessage]
    let model: String
//    let maxTokens: Int?
    let stream: Bool

    enum CodingKeys: String, CodingKey {
        case messages
        case model
        case stream
//        case maxTokens = "max_tokens"
    }
}

public struct ChatConversationDeltaResponse: Codable {
    public let object: String
    public let model: String?
    public let choices: [DeltaMessage]
}

public struct DeltaMessage: Codable {
    public let delta: ChatMessage
}

public struct Message: Codable {
    public let content: String
}


public class OpenAIEventHandler: EventHandler {
    public func onClosed() {
        print("closed")
    }
    
    public func onMessage(eventType: String, messageEvent: LDSwiftEventSource.MessageEvent) {
        print("message")
    }
    
    public func onComment(comment: String) {
        print("onComment")
    }
    
    public func onError(error: Error) {
        print("onError")
    }
    
    public func onOpened() {
        print("opened")
    }
}

public enum OpenAIAPI {
    public static func create(prompt: String, streamCallback: @escaping (String?) -> Void) async {
        return try! await withCheckedThrowingContinuation { continuation in
            let conversation = ChatConversation(messages: [
                .init(role: .user, content: prompt)], model: "gpt-3.5-turbo", stream: true)
            let encodedJson = try! JSONEncoder().encode(conversation)

            let handler = OpenAIEventHandler()
//            handler.message = { type, event in
//                print(type, event)
//                if type == "message" {
//                    let data = event.data
//                    let response = try! JSONDecoder().decode(ChatConversationDeltaResponse.self, from: data.data(using: .utf8)!)
//                    streamCallback(response.choices.first?.delta.content)
//                }
//            }

            var config = EventSource.Config(handler: handler, url: URL(string: "https://api.openai.com/v1/chat/completions")!)
            config.body = encodedJson
            config.headers = [
                "Authorization": "Bearer YOUR_API_KEY",
                "Content-Type": "application/json"
            ]
            let source = EventSource(config: config)
            source.start()

        }
    }
}
