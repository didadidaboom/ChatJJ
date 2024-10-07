import SwiftUI
import Foundation

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var chatHistory: [ChatMessage] = [
        ChatMessage(content: "You are a helpful assistant", role: "system")
    ]
    @State private var newMessage: String = ""
    @State private var isLoading = false
    @FocusState private var isInputFocused: Bool
    @State private var useMockResponse: Bool
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var shouldAutoScroll = true
    @State private var animatedMessageIds: Set<UUID> = []
    @State private var scrollTarget: UUID?
    @State private var isAutoScrolling = false
    @State private var loadingId = UUID()
    @AppStorage("selectedAPI") private var selectedAPI = APIService.deepSeek
    @State private var currentTask: Task<Void, Never>?
    @State private var deepSeekAPIKey: String = ""

    init(useMockResponse: Bool = false) {
        _useMockResponse = State(initialValue: useMockResponse)
        _deepSeekAPIKey = State(initialValue: ConfigManager.shared.getDeepSeekAPIKey())
    }

    @State private var keyboardHeight: CGFloat = 0
    @State private var scrollProxy: ScrollViewProxy?
    @State private var lastMessageId: UUID?
    @State private var isScrolledToBottom = true

    var body: some View {
        NavigationView {
            ZStack {
                Color(isDarkMode ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        Spacer()
                        settingsMenu
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    
                    // Message area
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(messages) { message in
                                    MessageView(message: message, shouldAnimate: !animatedMessageIds.contains(message.id))
                                        .id(message.id)
                                        .onAppear {
                                            if !animatedMessageIds.contains(message.id) {
                                                animatedMessageIds.insert(message.id)
                                            }
                                        }
                                }
                                
                                if isLoading {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .padding()
                                        Spacer()
                                    }
                                    .id(loadingId)
                                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                                }
                            }
                            .padding(.vertical)
                        }
                        .onChange(of: scrollTarget) { _, target in
                            if let target = target {
                                isAutoScrolling = true
                                withAnimation {
                                    proxy.scrollTo(target, anchor: .bottom)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isAutoScrolling = false
                                }
                            }
                        }
                        .onChange(of: isLoading) { _, newValue in
                            if newValue {
                                withAnimation {
                                    proxy.scrollTo(loadingId, anchor: .bottom)
                                }
                            }
                        }
                        .simultaneousGesture(
                            DragGesture().onChanged { _ in
                                if !isAutoScrolling {
                                    scrollTarget = nil
                                }
                            }
                        )
                        .onAppear {
                            scrollProxy = proxy
                        }
                    }
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                dismissKeyboard()
                            }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Input area
                    VStack(spacing: 0) {
                        HStack(spacing: 8) {
                            ZStack(alignment: .trailing) {
                                TextField("Message", text: $newMessage)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .padding(.trailing, 40)
                                    .background(isInputFocused ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isInputFocused ? Color.blue.opacity(0.5) : Color(UIColor.systemGray4), lineWidth: 1)
                                    )
                                    .focused($isInputFocused)

                                Button(action: {
                                    // Handle voice input
                                }) {
                                    Image(systemName: "waveform")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 12)
                                }
                            }

                            Button(action: {
                                sendMessage()
                                dismissKeyboard()
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .background(Color(UIColor.systemBackground))
                }
            }
            .navigationBarHidden(true)
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            setupKeyboardObservers()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }

    var settingsMenu: some View {
        Menu {
            Button(action: createNewChat) {
                Label("New Chat", systemImage: "plus")
            }
            
            Toggle(isOn: $isDarkMode) {
                Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
            }
            
            Menu {
                ForEach(APIService.allCases, id: \.self) { api in
                    Button(action: {
                        selectedAPI = api
                    }) {
                        Label(api.rawValue, systemImage: selectedAPI == api ? "checkmark" : "")
                    }
                }
            } label: {
                Label("Select API", systemImage: "network")
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(.gray)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
    
    private func dismissKeyboard() {
        isInputFocused = false
    }

    func sendMessage() {
        if !newMessage.isEmpty {
            let userMessage = Message(content: newMessage, isUser: true, apiService: selectedAPI)
            withAnimation {
                messages.append(userMessage)
            }
            chatHistory.append(ChatMessage(content: newMessage, role: "user"))
            isLoading = true
            loadingId = UUID()
            
            scrollTarget = userMessage.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollTarget = loadingId
            }
            
            sendMessageToAPI(userMessage: newMessage)
            
            newMessage = ""
            dismissKeyboard()
        }
    }
    
    func sendMessageToAPI(userMessage: String) {
        // Cancel any previous task
        currentTask?.cancel()

        // Create a new task
        currentTask = Task {
            switch selectedAPI {
            case .deepSeek:
                await sendMessageToDeepSeek(userMessage: userMessage)
            case .openAI:
                await sendMessageToOpenAI(userMessage: userMessage)
            }
        }
    }
    
    func sendMessageToDeepSeek(userMessage: String) async {
        print("Sending message to DeepSeek: \(userMessage)")
        
        let url = URL(string: "https://api.deepseek.com/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(deepSeekAPIKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "messages": chatHistory.map { ["content": $0.content, "role": $0.role] },
            "model": "deepseek-chat",
            "frequency_penalty": 0,
            "max_tokens": 2048,
            "presence_penalty": 0,
            "response_format": ["type": "text"],
            "stop": NSNull(),
            "stream": false,
            "stream_options": NSNull(),
            "temperature": 1,
            "top_p": 1,
            "tools": NSNull(),
            "tool_choice": "none",
            "logprobs": false,
            "top_logprobs": NSNull()
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
                self.messages.append(Message(content: "Error: Unable to send message", isUser: false, apiService: .deepSeek))
            }
            return
        }
        
        print("Sending request to DeepSeek API...")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check if the task was cancelled
            if Task.isCancelled {
                print("DeepSeek request was cancelled")
                return
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    DispatchQueue.main.async {
                        self.messages.append(Message(content: "Error: Invalid response from server", isUser: false, apiService: .deepSeek))
                    }
                    return
                }
                
                print("Received response with status code: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(responseString)")
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(DeepSeekResponse.self, from: data)
                    if let content = decodedResponse.choices.first?.message.content {
                        print("Received AI response: \(content)")
                        let newMessage = Message(content: content, isUser: false, apiService: .deepSeek)
                        withAnimation {
                            self.messages.append(newMessage)
                        }
                        self.chatHistory.append(ChatMessage(content: content, role: "assistant"))
                        
                        // Scroll to the new message
                        self.scrollTarget = newMessage.id
                    } else {
                        print("No content in AI response")
                        withAnimation {
                            self.messages.append(Message(content: "Error: No content in AI response", isUser: false, apiService: .deepSeek))
                        }
                    }
                } catch {
                    print("Failed to decode response: \(error)")
                    DispatchQueue.main.async {
                        withAnimation {
                            self.messages.append(Message(content: "Error: Unable to process server response", isUser: false, apiService: .deepSeek))
                        }
                    }
                }
            }
        } catch {
            if error is CancellationError {
                print("DeepSeek request was cancelled")
            } else {
                print("Error sending request to DeepSeek: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.messages.append(Message(content: "Error: \(error.localizedDescription)", isUser: false, apiService: .deepSeek))
                }
            }
        }
    }
    
    func sendMessageToOpenAI(userMessage: String) async {
        print("Sending message to OpenAI: \(userMessage)")
        // Simulate a delay
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // Check if the task was cancelled
            if Task.isCancelled {
                print("OpenAI request was cancelled")
                return
            }

            let response = "This is a placeholder response from OpenAI."
            DispatchQueue.main.async {
                let newMessage = Message(content: response, isUser: false, apiService: .openAI)
                withAnimation {
                    self.messages.append(newMessage)
                }
                self.chatHistory.append(ChatMessage(content: response, role: "assistant"))
                self.scrollTarget = newMessage.id
                self.isLoading = false
            }
        } catch {
            if error is CancellationError {
                print("OpenAI request was cancelled")
            } else {
                print("Error in OpenAI request: \(error.localizedDescription)")
            }
        }
    }
    
    func createNewChat() {
        // Cancel any ongoing request
        currentTask?.cancel()
        
        messages.removeAll()
        chatHistory = [ChatMessage(content: "You are a helpful assistant", role: "system")]
        newMessage = ""
        isLoading = false  // Ensure loading is stopped when creating a new chat
        animatedMessageIds.removeAll()  // Reset animated message IDs
        scrollTarget = nil  // Reset scroll target
    }
    
    func scrollToBottom() {
        withAnimation {
            if isLoading {
                scrollProxy?.scrollTo("loadingIndicator", anchor: .bottom)
            } else if let lastId = lastMessageId {
                scrollProxy?.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    var createNewSession: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                Button("Create a new session") {
                    createNewSession()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let apiService: APIService
    
    var label: String {
        isUser ? "You" : apiService.rawValue
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser && lhs.apiService == rhs.apiService
    }
}

struct MessageView: View {
    let message: Message
    let shouldAnimate: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: message.isUser ? "person.circle.fill" : "brain.head.profile")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(message.isUser ? .blue : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if shouldAnimate {
                    TypewriterText(text: message.content)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 16)
                            .fill(message.isUser ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground)))
                        .foregroundColor(Color(UIColor.label))
                } else {
                    Text(message.content)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 16)
                            .fill(message.isUser ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground)))
                        .foregroundColor(Color(UIColor.label))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct DeepSeekResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [DeepSeekChoice]
    let usage: DeepSeekUsage
    let systemFingerprint: String

    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

struct DeepSeekChoice: Codable {
    let index: Int
    let message: AIMessage
    let logprobs: String?
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index, message, logprobs
        case finishReason = "finish_reason"
    }
}

struct AIMessage: Codable {
    let role: String
    let content: String
}

struct DeepSeekUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let promptCacheHitTokens: Int
    let promptCacheMissTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptCacheHitTokens = "prompt_cache_hit_tokens"
        case promptCacheMissTokens = "prompt_cache_miss_tokens"
    }
}

struct ChatMessage: Codable {
    let content: String
    let role: String
}

struct TypewriterText: View {
    let text: String
    @State private var displayedText = ""
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                animateText()
            }
    }
    
    private func animateText() {
        let duration = Double(text.count) * 0.05 // Adjust this value to change typing speed
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * Double(index) / Double(text.count)) {
                displayedText += String(character)
            }
        }
    }
}

enum APIService: String, CaseIterable {
    case deepSeek = "DeepSeek"
    case openAI = "ChatGPT"  // Changed from "OpenAI" to "ChatGPT"
}

#Preview {
    ContentView()
}