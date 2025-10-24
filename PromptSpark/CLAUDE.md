# PromptSpark Project Context

## Product Overview
A macOS menubar app that optimizes user prompts before sending to AI models using a global hotkey and meta-prompt engine.

**Core Value**: Bridge the gap between casual user input and expert-level AI output.

## Tech Stack
- **Platform**: macOS 13+ only
- **Language**: Swift 5.9+
- **UI**: SwiftUI (settings) + AppKit (menubar)
- **Dependencies**:
  - KeyboardShortcuts (global hotkey)
  - KeychainAccess (optional, for API key storage)

## Key Architecture Decisions
1. **MenuBar-only app**: No Dock icon, LSUIElement = true
2. **Clipboard-based text capture**: Simulate Cmd+C/Cmd+V for max compatibility
3. **OpenAI-compatible API**: Support any OpenAI-format endpoint (OpenAI, Ollama, etc)
4. **Local-first**: All data stored locally, API keys in Keychain
5. **BYOK model**: Users provide their own API keys and endpoints

## Core Workflow

### Replace Mode (Default: Cmd+Shift+P)
1. User selects text → presses replace hotkey
2. Save current clipboard → simulate Cmd+C to capture selected text
3. Wrap user text with meta-prompt → call OpenAI API
4. On success: paste optimized prompt back (simulate Cmd+V)
5. On failure: show notification, keep original text, restore clipboard

### Display Mode (Default: Cmd+Shift+I)
1. User selects text → presses display hotkey
2. Save current clipboard → simulate Cmd+C to capture selected text
3. Wrap user text with meta-prompt → call OpenAI API
4. On success: show floating window with original text and AI summary
5. On failure: show notification, keep original text, restore clipboard

## Performance Targets
- Startup: <100ms
- Memory: <30MB
- Hotkey latency: <50ms
- API timeout: 10s

## Project Structure
```
PromptSpark/
├── App/              # Entry point
├── Core/             # HotkeyManager, TextCaptureService, PromptEngine, APIClient
├── Models/           # Profile, APIConfig, AppState
├── Views/            # MenuBar + Settings (SwiftUI)
├── Services/         # Config, Keychain, Notification, Pasteboard
├── Resources/        # DefaultMetaPrompt.txt, Assets
└── Utils/            # Extensions, Constants, Logger
```

## Key Features (MVP)
- [x] Global hotkey support (dual-mode)
  - Replace Mode: Optimize and replace selected text
  - Display Mode: Summarize and show in floating window
- [x] Text capture & replacement
- [x] OpenAI-compatible API client
- [x] Meta-prompt template engine
- [x] Custom prompt editor (in-app UI)
- [x] Profile (scenario) management
- [x] Result display window for read-only content
- [x] MenuBar icon & menu

## Development Notes
- All code and comments must be in English
- Keep naming concise (avoid overly long names)
- Minimize comments unless necessary
- Never commit to git unless user explicitly asks
- Use existing dependencies when possible
- No hardcoding solutions

## Error Handling
- On API error: keep original text, show macOS notification
- Always restore clipboard after operation
- 10s timeout for API calls
- Accessibility permission required (guide user on first launch)

## Security
- API keys stored in macOS Keychain (encrypted)
- No data collection or telemetry
- All processing happens locally
- HTTPS enforced for API calls

## Default Meta-Prompt Strategy
Design a universal meta-prompt that:
1. Analyzes user intent
2. Expands vague requests into structured instructions
3. Adds necessary context placeholders
4. Maintains user's original goal

Example transformation:
- Before: "帮我写个 python 爬虫"
- After: Structured prompt with role, target, data fields, tech stack, error handling requirements

## Business Model
- One-time purchase (perpetual license)
- Sell the tool + core meta-prompt engine
- No server costs (BYOK model)
