# ChatJJ

[English](#english) | [中文](#chinese)

<a name="english"></a>
# ChatJJ (English)

ChatJJ is an iOS application that provides a chat interface powered by AI, created by didadidaboom. It allows users to interact with an AI assistant for various tasks and conversations, now featuring integration with DeepSeek AI.

## Features Implemented

- AI-powered chat interface using SwiftUI
- Customizable configuration system
- Integration with AI service API, including DeepSeek AI
- User-friendly chat UI with message history

## To-Do List

- Integrate OpenAI's GPT model for more advanced conversational abilities
- Implement user authentication and profile management
- Add support for multiple conversation threads
- Enhance UI with customizable themes
- Implement local storage for offline message caching

## Getting Started

To run this project, you'll need:

1. Xcode 13 or later
2. iOS 15.0+ deployment target
3. An API key for the AI service (not included in the repository)

### Setup

1. Clone the repository:
   ```
   git clone https://github.com/didadidaboom/ChatJJ.git
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

## About the Creator

ChatJJ is developed by didadidaboom, an iOS developer passionate about AI and user-friendly applications.

---

<a name="chinese"></a>
# ChatJJ (中文)

ChatJJ 是由 didadidaboom 开发的一款 AI 驱动的 iOS 聊天应用程序。它允许用户与 AI 助手进行各种任务和对话交互，现已集成 DeepSeek AI 技术。

## 已实现的功能

- 使用 SwiftUI 构建的 AI 驱动聊天界面
- 可自定义的配置系统
- 与 AI 服务 API 的集成，包括 DeepSeek AI
- 用户友好的聊天 UI，包含消息历史记录

## 待办事项

- 集成 OpenAI 的 GPT 模型，以实现更高级的对话能力
- 实现用户认证和个人资料管理
- 添加多个对话线程的支持
- 增强 UI，添加可自定义主题
- 实现本地存储，用于离线消息缓存

## 开始使用

运行此项目需要：

1. Xcode 13 或更高版本
2. iOS 15.0+ 部署目标
3. AI 服务的 API 密钥（不包含在仓库中）

### 设置步骤

1. 克隆仓库：
   ```
   git clone https://github.com/didadidaboom/ChatJJ.git
   ```

2. 在 Xcode 中打开项目：
   ```
   cd ChatJJ
   open ChatJJ.xcodeproj
   ```

3. 复制 `Config.example.plist` 文件并重命名为 `Config.plist`：
   ```
   cp ChatJJ/Config.example.plist ChatJJ/Config.plist
   ```

4. 编辑 `ChatJJ/Config.plist` 并添加您的 API 密钥。

5. 复制 `Config.example.xconfig` 文件并重命名为 `Config.xconfig`：
   ```
   cp Config.example.xconfig ChatJJ/Configuration/Config.xconfig
   ```

6. 编辑 `ChatJJ/Configuration/Config.xconfig` 并添加您的配置设置。

7. 在 Xcode 中构建并运行项目。

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

本项目采用 [MIT 许可证](LICENSE)。

## 关于创作者

ChatJJ 由 didadidaboom 开发，他是一位对 AI 和用户友好应用程序充满热情的 iOS 开发者。