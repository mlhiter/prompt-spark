# PromptSpark 技术架构文档

**版本**: v1.0
**日期**: 2025-10-23
**平台**: macOS 13 Ventura+

---

## 一、核心技术选型

### 1.1 系统要求
- **操作系统**: macOS 13 Ventura+
- **开发语言**: Swift 5.9+
- **开发工具**: Xcode 15+
- **UI 框架**: SwiftUI 4.0+ (设置界面) + AppKit (菜单栏)
- **并发模型**: Swift Concurrency (async/await)

### 1.2 关键决策
| 决策点 | 选择 | 理由 |
|--------|------|------|
| 应用形态 | 纯菜单栏应用 | 符合工具类应用定位，不占用 Dock 空间 |
| UI 框架 | SwiftUI + AppKit 混合 | 菜单栏必须用 AppKit，设置面板用 SwiftUI 提高开发效率 |
| 快捷键方案 | KeyboardShortcuts 库 | 成熟稳定，避免重复造轮子 |
| 文本捕获 | 剪贴板方案 | 兼容性最好，支持所有应用 |
| API Key 存储 | macOS Keychain | 系统级加密，安全可靠 |
| 错误通知 | macOS 原生通知 | 优雅、非侵入、符合系统设计规范 |

### 1.3 推荐依赖库
- **KeyboardShortcuts** (必需): 全局快捷键管理
- **KeychainAccess** (可选): 简化 Keychain 操作，也可手写

---

## 二、架构分层设计

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────┐
│                      User Input                         │
│            (任意应用的文本输入框)                         │
└────────────────────┬────────────────────────────────────┘
                     │ 全局快捷键触发
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  System Interaction Layer                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ HotkeyManager│  │TextCapture   │  │ Pasteboard   │  │
│  │              │  │Service       │  │ Manager      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  Business Logic Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │PromptEngine  │  │  APIClient   │  │ConfigManager │  │
│  │              │  │              │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                       UI Layer                           │
│  ┌──────────────┐  ┌─────────────────────────────────┐ │
│  │MenuBar       │  │    Settings Window (SwiftUI)    │ │
│  │Controller    │  │  ┌───────────┐  ┌────────────┐  │ │
│  │(AppKit)      │  │  │API Config │  │Prompt Edit │  │ │
│  │              │  │  └───────────┘  └────────────┘  │ │
│  │              │  │  ┌────────────────────────────┐  │ │
│  │              │  │  │  Profile Manager           │  │ │
│  │              │  │  └────────────────────────────┘  │ │
│  └──────────────┘  └─────────────────────────────────┘ │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Keychain   │  │UserDefaults  │  │App Support   │  │
│  │  (API Key)   │  │  (Configs)   │  │(JSON Files)  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2.2 各层职责

#### Layer 1: System Interaction Layer (系统交互层)
- **HotkeyManager**: 全局快捷键监听与管理
- **TextCaptureService**: 文本捕获（模拟 Cmd+C）和替换（模拟 Cmd+V）
- **Pasteboard Manager**: 剪贴板保存与恢复

#### Layer 2: Business Logic Layer (业务逻辑层)
- **PromptEngine**:
  - 元提示词模板管理
  - 情景模式 (Profile) 管理
  - Prompt 构建逻辑
- **APIClient**:
  - OpenAI 兼容接口调用
  - 请求/响应处理
  - 错误处理与重试
  - 超时控制
- **ConfigManager**:
  - 统一配置管理
  - 配置持久化

#### Layer 3: UI Layer (界面层)
- **MenuBarController** (AppKit):
  - 菜单栏图标
  - 下拉菜单
  - 状态显示
- **Settings Window** (SwiftUI):
  - API 配置面板
  - 元提示词编辑器
  - Profile 管理界面
  - 通用设置

#### Layer 4: Data Layer (数据层)
- **Keychain**: API Key 安全存储
- **UserDefaults**: 普通配置存储
- **Application Support**: 自定义元提示词和 Profile JSON 文件

---

## 三、项目目录结构

```
PromptSpark/
├── PromptSpark.xcodeproj
├── PromptSpark/
│   ├── App/
│   │   ├── PromptSparkApp.swift          # 应用入口
│   │   └── AppDelegate.swift             # AppKit 生命周期管理
│   │
│   ├── Core/
│   │   ├── HotkeyManager.swift           # 全局快捷键管理
│   │   ├── TextCaptureService.swift      # 文本捕获与替换
│   │   ├── PromptEngine.swift            # 提示词引擎
│   │   └── APIClient.swift               # OpenAI API 客户端
│   │
│   ├── Models/
│   │   ├── Profile.swift                 # 情���模式数据模型
│   │   ├── APIConfig.swift               # API 配置模型
│   │   ├── PromptTemplate.swift          # 提示词模板模型
│   │   └── AppState.swift                # 全局状态管理
│   │
│   ├── Views/
│   │   ├── MenuBar/
│   │   │   └── MenuBarController.swift   # 菜单栏控制器
│   │   │
│   │   └── Settings/
│   │       ├── SettingsView.swift        # 设置主窗口
│   │       ├── APISettingsView.swift     # API 配置页面
│   │       ├── PromptEditorView.swift    # 提示词编辑器
│   │       └── ProfileManagerView.swift  # 情景模式管理
│   │
│   ├── Services/
│   │   ├── ConfigService.swift           # 配置管理服务
│   │   ├── KeychainService.swift         # Keychain 封装
│   │   ├── NotificationService.swift     # 通知服务
│   │   └── PasteboardService.swift       # 剪贴板服务
│   │
│   ├── Resources/
│   │   ├── DefaultMetaPrompt.txt         # 默认元提示词模板
│   │   ├── Assets.xcassets               # 图标资源
│   │   └── Info.plist
│   │
│   └── Utils/
│       ├── Extensions/
│       │   ├── String+Extensions.swift
│       │   └── UserDefaults+Extensions.swift
│       ├── Constants.swift               # 常量定义
│       └── Logger.swift                  # 日志工具
│
└── Tests/
    ├── PromptEngineTests.swift
    ├── APIClientTests.swift
    └── ...
```

---

## 四、核心工作流详解

### 4.1 文本优化完整流程

```
┌─────────────────────────────────────────────────────┐
│ 1. 用户选中文本，按下快捷键 (Cmd+Shift+P)           │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 2. HotkeyManager 捕获快捷键事件                     │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 3. PasteboardService 保存当前剪贴板内容             │
│    (避免覆盖用户原有的剪贴板数据)                   │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 4. TextCaptureService 模拟 Cmd+C                    │
│    → 获取用户选中的文本                             │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 5. PromptEngine 构建完整 Prompt                     │
│    - 获取当前活动的 Profile                         │
│    - 将用户文本嵌入元提示词模板                     │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 6. APIClient 异步调用 OpenAI API                    │
│    - 设置 10 秒超时                                 │
│    - 流式或非流式响应                               │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ 7. 响应处理                                         │
│    ┌───────────────────┐      ┌──────────────────┐ │
│    │   成功            │      │   失败           │ │
│    │   ↓               │      │   ↓              │ │
│    │ 写入优化后的文本  │      │ 不修改剪贴板     │ │
│    │ 到剪贴板          │      │                  │ │
│    │   ↓               │      │ 发送系统通知     │ │
│    │ 模拟 Cmd+V        │      │ 显示错误信息     │ │
│    │   ↓               │      │   ↓              │ │
│    │ 替换原文本        │      │ 恢复原剪贴板     │ │
│    │   ↓               │      │                  │ │
│    │ 恢复原剪贴板      │      │                  │ │
│    └───────────────────┘      └──────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### 4.2 关键技术细节

#### 4.2.1 文本捕获方案
```swift
// 伪代码示例
func captureSelectedText() async -> String? {
    // 1. 保存当前剪贴板
    let originalContent = NSPasteboard.general.string(forType: .string)

    // 2. 清空剪贴板
    NSPasteboard.general.clearContents()

    // 3. 模拟 Cmd+C
    let source = CGEventSource(stateID: .hidSystemState)
    let cmdC = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
    cmdC?.flags = .maskCommand
    cmdC?.post(tap: .cghidEventTap)

    // 4. 短暂延迟，等待系统复制
    try? await Task.sleep(nanoseconds: 50_000_000) // 50ms

    // 5. 读取剪贴板
    let selectedText = NSPasteboard.general.string(forType: .string)

    // 6. 恢复原剪贴板
    if let originalContent {
        NSPasteboard.general.setString(originalContent, forType: .string)
    }

    return selectedText
}
```

#### 4.2.2 权限管理
- **Accessibility 权限**: 必需，用于监听全局快捷键和模拟键盘事件
- **网络权限**: 自动获取（调用 API 时）
- 首次启动引导用户授权

---

## 五、数据模型设计

### 5.1 Profile (情景模式)
```swift
struct Profile: Codable, Identifiable {
    let id: UUID
    var name: String                    // 如 "代码优化"
    var metaPrompt: String              // 元提示词模板
    var hotkeyName: String?             // 绑定的快捷键标识
    var isActive: Bool                  // 是否为当前活动模式
    var createdAt: Date
    var updatedAt: Date
}
```

### 5.2 APIConfig (API 配置)
```swift
struct APIConfig: Codable {
    var baseURL: String                 // 如 "https://api.openai.com/v1"
    var model: String                   // 如 "gpt-4o-mini"
    var maxTokens: Int                  // 如 500
    var temperature: Double             // 如 0.7
    var timeout: TimeInterval           // 如 10.0
}
```

### 5.3 AppState (全局状态)
```swift
@MainActor
class AppState: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var activeProfile: Profile?
    @Published var apiConfig: APIConfig
    @Published var isProcessing: Bool = false

    // Singleton
    static let shared = AppState()
}
```

---

## 六、API 接口设计

### 6.1 OpenAI 兼容接口

```swift
protocol APIClientProtocol {
    func optimizePrompt(_ userInput: String,
                       config: APIConfig,
                       metaPrompt: String) async throws -> String
}

class OpenAIClient: APIClientProtocol {
    func optimizePrompt(_ userInput: String,
                       config: APIConfig,
                       metaPrompt: String) async throws -> String {
        // 构建请求
        let messages = [
            ["role": "system", "content": metaPrompt],
            ["role": "user", "content": userInput]
        ]

        let body = [
            "model": config.model,
            "messages": messages,
            "max_tokens": config.maxTokens,
            "temperature": config.temperature
        ]

        // 发送请求（带超时）
        let (data, response) = try await URLSession.shared
            .data(for: buildRequest(config: config, body: body))
            .timeout(config.timeout)

        // 解析响应
        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return result.choices.first?.message.content ?? ""
    }
}
```

### 6.2 错误处理

```swift
enum PromptSparkError: LocalizedError {
    case noTextSelected
    case apiKeyMissing
    case networkError(Error)
    case timeout
    case invalidResponse
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .noTextSelected:
            return "未选中任何文本"
        case .apiKeyMissing:
            return "请先配置 API Key"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .timeout:
            return "请求超时，请检查网络或尝试更换模型"
        case .invalidResponse:
            return "API 返回无效响应"
        case .rateLimitExceeded:
            return "API 调用频率超限，请稍后重试"
        }
    }
}
```

---

## 七、性能优化策略

### 7.1 启动性能 (目标: <100ms)
- **延迟加载**: 仅初始化菜单栏和核心服务
- **设置窗口**: 首次打开时才创建
- **资源预加载**: 异步加载默认元提示词
- **避免阻塞**: 所有 I/O 操作异步执行

### 7.2 内存优化 (目标: <30MB)
- **无主窗口**: 纯菜单栏应用，没有常驻窗口
- **及时释放**: API 响应处理后立即释放内存
- **懒加载**: Profile 列表按需加载
- **缓存策略**: 仅缓存当前活动 Profile

### 7.3 响应速度 (目标: <50ms)
- **快捷键优先级**: 使用高优先级事件监听
- **非阻塞 UI**: 所有耗时操作异步执行
- **剪贴板优化**: 最小化剪贴板操作延迟
- **API 推荐**: 使用 `gpt-4o-mini` (延迟 <1s)

### 7.4 网络优化
- **超时控制**: 10 秒强制超时
- **错误重试**: 网络错误自动重试 1 次
- **流式响应**: 可选启用流式 API（更快的首字节时间）

---

## 八、安全与隐私

### 8.1 数据安全
- **API Key 存储**: 使用 macOS Keychain，系统级加密
- **本地处理**: 所有数据处理在本地完成
- **无服务器**: 不经过任何第三方服务器
- **HTTPS 强制**: API 调用强制使用 HTTPS

### 8.2 隐私保护
- **零数据收集**: 不收集任何用户数据
- **剪贴板保护**: 操作完成后立即恢复原内容
- **日志脱敏**: 本地日志不记录敏感信息（API Key、用户输入）

---

## 九、开发路线图

### Phase 1: 基础框架 (Week 1)
- [ ] 创建 Xcode 项目
- [ ] 搭建目录结构
- [ ] 实现数据模型 (Profile, APIConfig, AppState)
- [ ] 实现 ConfigService 和 KeychainService
- [ ] 编写单元测试

### Phase 2: 核心功能 (Week 2)
- [ ] 实现 HotkeyManager (使用 KeyboardShortcuts)
- [ ] 实现 TextCaptureService (剪贴板方案)
- [ ] 实现 OpenAI APIClient
- [ ] 实现错误处理和通知
- [ ] 编写核心功能测试

### Phase 3: 提示词引擎 (Week 3)
- [ ] 设计默认元提示词模板
- [ ] 实现 PromptEngine
- [ ] 实现 Profile 管理逻辑
- [ ] 实现 Prompt 构建逻辑
- [ ] 测试提示词效果

### Phase 4: UI 开发 (Week 4-5)
- [ ] 实现 MenuBarController (AppKit)
- [ ] 创建 Settings 窗口框架 (SwiftUI)
- [ ] 实现 API 配置界面
- [ ] 实现元提示词编辑器
- [ ] 实现 Profile 管理界面
- [ ] 实现权限申请引导

### Phase 5: 集成与优化 (Week 6)
- [ ] 集成所有模块
- [ ] 端到端测试
- [ ] 性能优化（启动时间、内存、响应速度）
- [ ] 用户体验打磨
- [ ] 错误场景覆盖测试

### Phase 6: 发布准备 (Week 7)
- [ ] 编写用户文档
- [ ] 创建 README
- [ ] 应用签名和公证
- [ ] Beta 测试
- [ ] 修复 Bug
- [ ] 准备发布

---

## 十、技术风险与应对

### 10.1 风险点
1. **Accessibility 权限被拒**: 应用核心功能无法使用
2. **不同应用的剪贴板兼容性**: 某些应用可能不响应模拟键盘事件
3. **API 调用速度**: 网络延迟可能影响用户体验
4. **快捷键冲突**: 与系统或其他应用的快捷键冲突

### 10.2 应对方案
1. **权限引导**: 清晰的引导界面，说明必要性
2. **兼容性测试**: 在主流应用中测试（VS Code, Chrome, Notion 等）
3. **速度优化**: 推荐快速模型 + 流式响应 + 超时保护
4. **快捷键自定义**: 允许用户自定义快捷键

---

## 十一、测试策略

### 11.1 单元测试
- PromptEngine 逻辑测试
- APIClient 请求构建测试
- ConfigService 持久化测试
- KeychainService 加密测试

### 11.2 集成测试
- 快捷键 → 文本捕获 → API 调用 → 文本替换 全流程测试
- 多 Profile 切换测试
- 错误场景测试（网络错误、超时、无效响应）

### 11.3 性能测试
- 启动时间测试
- 内存占用监控
- 快捷键响应延迟测试
- API 调用性能测试

### 11.4 用户验收测试
- 在真实应用场景中测试（VS Code, Chrome, Cursor 等）
- 极端情况测试（超长文本、特殊字符、无网络）

---

## 十二、总结

PromptSpark 的技术架构遵循以下核心原则：

1. **性能至上**: 原生 Swift + macOS SDK，启动快、内存小、响应快
2. **安全第一**: Keychain 加密存储，本地处理，零数据收集
3. **简洁优雅**: 清晰的分层架构，易于维护和扩展
4. **用户体验**: 无缝集成，快捷键触发，自动替换，优雅的错误提示

本架构已充分考虑性能、安全性、可维护性和用户体验的平衡，为后续开发提供坚实的技术基础。
