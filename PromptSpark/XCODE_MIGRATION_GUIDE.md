# Xcode 项目迁移指南

## 第一步：创建 Xcode 项目

1. 打开 Xcode
2. File → New → Project
3. 选择 **macOS** → **App**
4. 项目配置：
   - Product Name: `PromptSpark`
   - Team: None (或你的开发者账号)
   - Organization Identifier: `com.mlhiter`
   - Bundle Identifier: `com.mlhiter.promptspark`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ✅ Use Core Data: NO
   - ✅ Include Tests: NO
5. 保存到当前目录：选择 `prompt-spark` 文件夹
6. ⚠️ 选择 "Don't create Git repository"（我们已经有了）

## 第二步：删除 Xcode 自动生成的文件

删除这些 Xcode 自动创建的文件（我们会用现有的）：
- `PromptSpark/PromptSparkApp.swift` (Xcode 生成的)
- `PromptSpark/ContentView.swift` (Xcode 生成的)
- `PromptSpark/Assets.xcassets` (Xcode 生成的，保留但稍后配置)

## 第三步：配置项目文件引用

在 Xcode 左侧项目导航器中：

1. 右键点击 `PromptSpark` 组 → **Add Files to "PromptSpark"**
2. 选择以下文件夹（确保勾选 "Create folder references"）：
   - `App/`
   - `Core/`
   - `Models/`
   - `Views/`
   - `Services/`
   - `Utils/`
   - `Resources/`

3. 单独添加 `Info.plist`：
   - 右键 → Add Files → 选择 `Info.plist`

## 第四步：配置 Swift Package 依赖

1. 选择项目文件（最上层的蓝色图标）
2. 在编辑器中选择 **PromptSpark** target
3. 选择 **Package Dependencies** 标签
4. 点击 **+** 按钮
5. 输入：`https://github.com/sindresorhus/KeyboardShortcuts`
6. Version: **Up to Next Major Version** `2.0.0`
7. 点击 **Add Package**
8. 确保 **KeyboardShortcuts** 被添加到 target

## 第五步：配置 Build Settings

1. 选择 **PromptSpark** target
2. **General** 标签：
   - Minimum Deployments: **macOS 13.0**
   - Bundle Identifier: `com.mlhiter.promptspark`

3. **Signing & Capabilities** 标签：
   - Signing: **Automatically manage signing**
   - Team: **None** (或选择你的)
   - ⚠️ 如果没有开发者账号，会显示警告，但仍可本地构建

4. **Build Settings** 标签：
   - 搜索 "Info.plist"
   - 设置 **Info.plist File**: `Info.plist`

5. **Info** 标签：
   - Custom macOS Application Target Properties
   - 确认 `LSUIElement` = `YES`

## 第六步：配置资源

1. 删除 Xcode 自动生成的 `Assets.xcassets`
2. 在项目导航器中右键 → **Add Files**
3. 选择 `Resources/Assets.xcassets`（确保 "Copy items if needed" 未勾选）

## 第七步：测试构建

1. 选择 target: **My Mac**
2. Product → Build (⌘B)
3. 如果成功，尝试 Product → Run (⌘R)

## 第八步：Archive 和导出

1. Product → Archive
2. 等待构建完成
3. Window → Organizer
4. 选择最新的 archive
5. **Distribute App**
6. 选择 **Copy App**
7. 导出到 `.build/xcode-export/`

---

## ⚠️ 常见问题

### Q: "No signing certificate" 错误
A: 在 Signing & Capabilities → 取消 "Automatically manage signing" → Signing Certificate 选择 "Sign to Run Locally"

### Q: Bundle 资源找不到
A: Build Phases → Copy Bundle Resources → 确保所有 .bundle 文件都在列表中

### Q: Info.plist 找不到
A: Build Settings → INFOPLIST_FILE → 设置为 "$(SRCROOT)/Info.plist"
