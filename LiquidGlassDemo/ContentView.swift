import SwiftUI
import AppKit

struct ContentView: View {
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            SidebarView()

            // Main chat area
            ChatAreaView()
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                .padding(.vertical, 12)
                .padding(.trailing, 12)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

// MARK: - Sidebar
struct SidebarView: View {
    @State private var selectedChat: String? = "New conversation"

    let recentChats = [
        "New conversation",
        "SwiftUI animations",
        "Metal shader help",
        "API integration",
        "Debug CoreData issue"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App title
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title2)
                Text("Glass Chat")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // New chat button
            Button(action: {}) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New chat")
                }
                .font(.body)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .glassEffect(.clear.interactive(), in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 12)
            .padding(.bottom, 16)

            // Recents label
            Text("Recents")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            // Chat list
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(recentChats, id: \.self) { chat in
                        ChatRowView(
                            title: chat,
                            isSelected: selectedChat == chat
                        )
                        .onTapGesture {
                            selectedChat = chat
                        }
                    }
                }
                .padding(.horizontal, 12)
            }

            Spacer()

            // User profile area
            HStack(spacing: 10) {
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("DT")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Dillon Thomas")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    Text("Pro plan")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.up")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(12)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 12))
            .padding(12)
        }
        .frame(width: 240)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
        .padding(12)
    }
}

// MARK: - Chat Row
struct ChatRowView: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: "message")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            Text(title)
                .font(.callout)
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? .white.opacity(0.15) : .clear)
        )
    }
}

// MARK: - Message Model
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}

// MARK: - Chat Area
struct ChatAreaView: View {
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = []

    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack {
                Text(messages.isEmpty ? "New conversation" : "Conversation")
                    .font(.headline)
                    .foregroundStyle(.white)

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                Button(action: {}) {
                    Text("Share")
                        .font(.callout)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
                .glassEffect(.clear.interactive(), in: Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            // Messages area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        if messages.isEmpty {
                            // Welcome message
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.white.opacity(0.8))

                                Text("How can I help you today?")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            // Message bubbles
                            ForEach(messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .onChange(of: messages) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Spacer()

            // Input area
            InputBarView(messageText: $messageText, onSend: sendMessage)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let newMessage = ChatMessage(content: messageText, isUser: true)
        messages.append(newMessage)
        messageText = ""
    }
}

// MARK: - Message Bubble
struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
            }

            Text(message.content)
                .font(.body)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glassEffect(
                    message.isUser
                        ? .clear.tint(.blue.opacity(0.4))
                        : .clear,
                    in: RoundedRectangle(cornerRadius: 18)
                )

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Input Bar
struct InputBarView: View {
    @Binding var messageText: String
    var onSend: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Text field
            HStack(alignment: .bottom, spacing: 12) {
                TextField("Reply...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .foregroundStyle(.white)
                    .focused($isFocused)
                    .lineLimit(1...5)
                    .onSubmit {
                        if !messageText.isEmpty {
                            onSend()
                        }
                    }

                // Send button
                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .glassEffect(.clear.interactive(), in: Circle())
                .opacity(messageText.isEmpty ? 0.5 : 1.0)
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 20))

            // Bottom toolbar
            HStack {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Image(systemName: "face.smiling")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(.plain)

                Spacer()

                // Model selector
                HStack(spacing: 4) {
                    Text("Sonnet 4.5")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .glassEffect(.clear.interactive(), in: Capsule())
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    ContentView()
}
