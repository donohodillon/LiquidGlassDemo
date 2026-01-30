import SwiftUI
import AppKit

// MARK: - NSTextField wrapper for guaranteed keyboard input
struct FocusableTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onSubmit: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.isBordered = false
        textField.drawsBackground = false
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = .white
        textField.focusRingType = .none
        textField.cell?.sendsActionOnEndEditing = false
        textField.delegate = context.coordinator
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: FocusableTextField

        init(_ parent: FocusableTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if !parent.text.isEmpty {
                    parent.onSubmit()
                }
                return true
            }
            return false
        }
    }
}

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

    var body: some View {
        VStack(spacing: 12) {
            // Text field using working NSTextField
            HStack(alignment: .center, spacing: 12) {
                DebugNSTextField(
                    text: $messageText,
                    onSubmit: {
                        if !messageText.isEmpty {
                            onSend()
                        }
                    }
                )
                .frame(height: 24)

                // Send button
                Button(action: {
                    if !messageText.isEmpty {
                        onSend()
                    }
                }) {
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.white.opacity(0.2)))
                }
                .buttonStyle(.plain)
                .opacity(messageText.isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )

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
                .background(Capsule().fill(.white.opacity(0.15)))
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Debug View for Testing Input
struct DebugContentView: View {
    @State private var text = ""
    @State private var messages: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("DEBUG: Text Input Test")
                .font(.title)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages, id: \.self) { msg in
                        Text(msg)
                            .padding(10)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            // Debug text field
            DebugNSTextField(text: $text, onSubmit: {
                if !text.isEmpty {
                    messages.append(text)
                    text = ""
                    print("DEBUG: Message added! Count: \(messages.count)")
                }
            })
            .frame(height: 30)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)

            Text("Messages sent: \(messages.count)")
                .font(.caption)

            Button("Add Test Message") {
                messages.append("Test \(Date())")
                print("DEBUG: Button clicked, added test message")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(width: 500, height: 500)
    }
}

struct DebugNSTextField: NSViewRepresentable {
    @Binding var text: String
    var onSubmit: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let tf = NSTextField()
        tf.placeholderString = "Reply..."
        tf.delegate = context.coordinator

        // Remove border and background for glass look
        tf.isBordered = false
        tf.drawsBackground = false
        tf.backgroundColor = .clear
        tf.focusRingType = .none

        // Style text
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = .white
        tf.placeholderAttributedString = NSAttributedString(
            string: "Reply...",
            attributes: [
                .foregroundColor: NSColor.white.withAlphaComponent(0.5),
                .font: NSFont.systemFont(ofSize: 14)
            ]
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            tf.window?.makeFirstResponder(tf)
        }

        return tf
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: DebugNSTextField
        init(_ parent: DebugNSTextField) { self.parent = parent }

        func controlTextDidChange(_ obj: Notification) {
            if let tf = obj.object as? NSTextField {
                parent.text = tf.stringValue
                print("DEBUG: Text = '\(tf.stringValue)'")
            }
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                print("DEBUG: Enter key pressed!")
                parent.onSubmit()
                return true
            }
            return false
        }
    }
}

#Preview {
    ContentView()
}
