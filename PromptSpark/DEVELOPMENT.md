# PromptSpark 开发指南

## 项目结构

```
prompt-spark/
├── Sources/
│   └── PromptSpark/
│       ├── App/                    # 应用入口
│       │   ├── PromptSparkApp.swift
│       │   └── AppDelegate.swift
│       ├── Core/                   # 核心业务逻辑
│       │   ├── APIClient.swift
│       │   ├── PromptEngine.swift
│       │   ├── HotkeyManager.swift
│       │   └── TextCaptureService.swift
│       ├── Models/                 # 数据模型
│       │   ├── Profile.swift
│       │   ├── APIConfig.swift
│       │   ├── AppState.swift
│       │   └── PromptSparkError.swift
│       ├── Views/                  # UI 层
│       │   ├── MenuBar/
│       │   │   └── MenuBarController.swift
│       │   └── Settings/
│       │       ├── SettingsView.swift
│       │       ├── APISettingsView.swift
│       │       └── ProfileManagerView.swift
│       ├── Services/               # 服务层
│       │   ├── ConfigService.swift
│       │   ├── KeychainService.swift
│       │   ├── NotificationService.swift
│       │   └── PasteboardService.swift
│       ├── Resources/              # 资源文件
│       │   └── DefaultMetaPrompt.txt
│       └── Utils/                  # 工具类
│           ├── Constants.swift
│           ├── Logger.swift
│           └── Extensions/
├── Package.swift                   # Swift Package 配置
├── README.md                       # 用户文档
├── DEVELOPMENT.md                  # 开发文档（本文件）
├── CLAUDE.md                       # 项目上下文（供 AI 使用）
├── tech-architecture.md            # 详细技术架构
└── white-paper.md                  # 产品白皮书
```

## 快速开始

### 环境要求

- macOS 13 Ventura 或更高版本
- Swift 5.9+
- Xcode 15+（可选，用于调试）

### 构建项目

```bash
# Debug 构建
swift build

# Release 构建
swift build -c release

# 运行应用
swift run
```

### 运行应用

```bash
# 直接运行（开发模式）
swift run

# 或者运行编译后的二进制文件
.build/debug/PromptSpark
```

## 核心工作流程

### 1. 全局快捷键触发

用户按下 `Cmd+Shift+P` → `HotkeyManager` 捕获事件 → 触发优化流程

### 2. 文本捕获

1. 保存当前剪贴板内容（`PasteboardService`）
2. 模拟 `Cmd+C` 复制选中文本（`TextCaptureService`）
3. 从剪贴板读取捕获的文本
4. 恢复原剪贴板内容

### 3. 提示词优化

1. `PromptEngine` 获取当前活动的 Profile
2. 将用户文本嵌入元提示词模板
3. `APIClient` 调用 OpenAI 兼容 API
4. 等待 AI 返回优化后的提示词

### 4. 文本替换

1. 将优化后的文本写入剪贴板（`PasteboardService`）
2. 模拟 `Cmd+V` 粘贴（`TextCaptureService`）
3. 恢复原剪贴板内容

## 关键技术点

### 并发模型

- 使用 Swift Concurrency (async/await)
- `AppState` 标记为 `@MainActor`，确保 UI 更新在主线程
- 网络请求在后台线程，不阻塞 UI

### 权限管理

应用需要 **Accessibility 权限** 才能：
- 监听全局快捷键
- 模拟键盘事件（Cmd+C, Cmd+V）

首次启动时会自动引导用户授权。

### 数据存储

- **API Key**: macOS Keychain（加密）
- **配置**: UserDefaults
- **Profiles**: JSON 文件存储在 `~/Library/Application Support/PromptSpark/`

### 错误处理

所有错误都通过 `PromptSparkError` 枚举统一处理：
- `noTextSelected`: 未选中文本
- `apiKeyMissing`: API Key 未配置
- `networkError`: 网络错误
- `timeout`: 请求超时
- `invalidResponse`: API 返回无效
- `rateLimitExceeded`: API 频率限制
- `accessibilityPermissionDenied`: 权限被拒绝

错误通过 `NotificationService` 以 macOS 原生通知形式展示给用户。

## 开发注意事项

### 1. 主线程操作

访问 `AppState` 属性时必须在主线程：

```swift
// ❌ 错误
let config = AppState.shared.apiConfig

// ✅ 正确
let config = await AppState.shared.apiConfig
```

### 2. 异步操作

所有 I/O 操作（网络、文件读写）都应该是异步的：

```swift
func processText(_ text: String) async throws -> String {
    let result = try await apiClient.optimizePrompt(...)
    return result
}
```

### 3. 错误处理

始终使用 `do-catch` 捕获异步操作的错误：

```swift
do {
    let optimized = try await promptEngine.processText(text)
    // 处理成功
} catch {
    notificationService.showError(error)
}
```

### 4. 剪贴板操作

必须保存和恢复原剪贴板内容，避免覆盖用户数据：

```swift
let original = pasteboardService.saveContent()
// 执行操作...
pasteboardService.restoreContent(original)
```

## 调试技巧

### 1. 查看日志

使用 macOS Console.app 查看应用日志：
1. 打开 Console.app
2. 搜索 "PromptSpark"
3. 查看实时日志输出

### 2. 断点调试

如果使用 Xcode：
1. 在 Xcode 中打开项目：`open Package.swift`
2. 设置断点
3. Run (Cmd+R)

### 3. 打印调试

使用 `Logger` 工具类：

```swift
Logger.log("Processing text...", category: .general)
Logger.error("API call failed", category: .api)
Logger.debug("Hotkey triggered", category: .hotkey)
```

## 测试

### 手动测试清单

- [ ] 启动应用，菜单栏图标显示
- [ ] 授权 Accessibility 权限
- [ ] 配置 API Key
- [ ] 选中文本，按快捷键，文本被替换
- [ ] 创建新 Profile
- [ ] 切换 Profile
- [ ] 编辑元提示词
- [ ] 测试网络错误处理
- [ ] 测试 API 超时处理
- [ ] 测试未选中文本的情况
- [ ] 测试剪贴板恢复功能

### 性能测试

```bash
# 测试启动时间
time swift run

# 监控内存使用
# 使用 Activity Monitor 查看 PromptSpark 进程的内存占用
```

## 常见问题

### Q: 快捷键不工作？
A: 检查 Accessibility 权限是否已授权。

### Q: API 调用失败？
A:
1. 检查 API Key 是否正确
2. 检查网络连接
3. 检查 Base URL 是否正确
4. 查看 Console.app 中的错误日志

### Q: 文本没有被替换？
A:
1. 确保文本已选中
2. 检查目标应用是否支持粘贴操作
3. 查看是否有错误通知

### Q: 编译错误？
A:
1. 确保 Swift 版本 >= 5.9
2. 清理构建缓存：`swift package clean`
3. 重新构建：`swift build`

## 下一步开发

### 短期目标（MVP+）

- [ ] 添加单元测试
- [ ] 添加 UI 测试
- [ ] 性能优化（启动时间、内存占用）
- [ ] 完善错误提示
- [ ] 添加使用引导

### 中期目标

- [ ] 支持多语言（i18n）
- [ ] 提示词历史记录
- [ ] 提示词收藏功能
- [ ] Profile 导入/导出
- [ ] 更多内置 Profile 模板

### 长期目标

- [ ] Windows 支持
- [ ] Linux 支持
- [ ] 插件系统
- [ ] 团队协作功能
- [ ] 云端同步

## 贡献指南

1. Fork 项目
2. 创建 feature 分支
3. 提交代码
4. 创建 Pull Request

代码规范：
- 遵循 Swift API Design Guidelines
- 使用有意义的变量和函数名
- 添加必要的注释
- 确保代码通过编译

## 资源链接

- [Swift 官方文档](https://swift.org/documentation/)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [KeyboardShortcuts 库](https://github.com/sindresorhus/KeyboardShortcuts)
- [OpenAI API 文档](https://platform.openai.com/docs/api-reference)
