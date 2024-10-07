# ChatJJ

ChatJJ is an iOS application that provides a chat interface powered by AI. It allows users to interact with an AI assistant for various tasks and conversations.

## Features

- AI-powered chat interface
- Customizable configuration
- Swift and SwiftUI implementation

## Getting Started

To run this project, you'll need:

1. Xcode 13 or later
2. iOS 15.0+ deployment target
3. An API key for the AI service (not included in the repository)

### Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/ChatJJ.git
   ```

2. Open the project in Xcode:
   ```
   cd ChatJJ
   open ChatJJ.xcodeproj
   ```

3. Copy the `Config.example.plist` file and rename it to `Config.plist`:
   ```
   cp ChatJJ/Config.example.plist ChatJJ/Config.plist
   ```

4. Edit `ChatJJ/Config.plist` and add your API key.

5. Copy the `Config.example.xconfig` file and rename it to `Config.xconfig`:
   ```
   cp Config.example.xconfig ChatJJ/Configuration/Config.xconfig
   ```

6. Edit `ChatJJ/Configuration/Config.xconfig` and add your configuration settings.

7. Build and run the project in Xcode.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [MIT License](LICENSE).