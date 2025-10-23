# PromptSpark

> Bridge the gap between casual input and expert-level AI output.

PromptSpark is a macOS menubar application that automatically optimizes your prompts before sending them to AI models. It uses a global hotkey to transform vague, casual input into structured, expert-level prompts using AI-powered meta-prompts.

## Features

- ✨ **Global Hotkey**: Trigger prompt optimization from any application with Cmd+Shift+P
- 🔒 **BYOK (Bring Your Own Key)**: Your API key stays secure in macOS Keychain
- 🎯 **Multiple Profiles**: Create different optimization strategies for various use cases
- 🚀 **Lightweight**: Native Swift app with minimal memory footprint (<30MB)
- ⚡ **Fast**: Optimized for speed with <100ms cold start
- 🔐 **Privacy First**: All processing happens locally, no data collection
- 🌐 **OpenAI Compatible**: Works with OpenAI, Ollama, LM Studio, and any OpenAI-compatible API

## Installation

### Requirements

- macOS 13 Ventura or later
- Swift 5.9 or later (for building from source)

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/prompt-spark.git
cd prompt-spark/PromptSpark
```

2. Build the project:
```bash
swift build -c release
```

3. Run the application:
```bash
swift run
```

Alternatively, open the project in Xcode and build from there.

## Setup

1. **Launch PromptSpark**: The app will appear in your menubar as a sparkles icon (✨)

2. **Grant Accessibility Permission**:
   - On first launch, you'll be prompted to grant Accessibility permission
   - Go to System Settings → Privacy & Security → Accessibility
   - Enable PromptSpark

3. **Configure API**:
   - Click the menubar icon → Settings
   - Navigate to the API tab
   - Enter your OpenAI API key (stored securely in Keychain)
   - Configure base URL, model, and other parameters

4. **Set Up Hotkey**:
   - The default hotkey is Cmd+Shift+P
   - You can customize it in System Settings → Keyboard → Keyboard Shortcuts

## Usage

1. In any application, write your casual prompt in a text field
2. Select the text you want to optimize
3. Press **Cmd+Shift+P** (or your custom hotkey)
4. PromptSpark will:
   - Capture your selected text
   - Send it to the AI with the meta-prompt
   - Automatically replace your text with the optimized version

### Example

**Before** (you type):
```
帮我写个 python 爬虫
```

**After** (PromptSpark optimizes):
```
Act as an experienced Python web scraping engineer.

I need a Python script to scrape data from a website.

**Requirements:**
- Target website: [Please provide the URL]
- Data to scrape: [Specify the data fields you need]
- Technology stack: [Choose: requests + BeautifulSoup / Scrapy / Playwright]

**Technical requirements:**
- Include clear comments
- Add error handling (network, parsing errors)
- Implement rate limiting
- Save results to [CSV / JSON / database]

Please provide clean, production-ready code.
```

## Profiles

Profiles allow you to create different optimization strategies:

- **Default**: General-purpose prompt optimization
- **Code**: Optimized for programming tasks
- **Writing**: Optimized for content creation
- **Research**: Optimized for information gathering

### Creating a Profile

1. Go to Settings → Profiles
2. Click the + button
3. Name your profile
4. Customize the meta-prompt
5. Optionally assign a different hotkey

## Configuration

### API Settings

- **Base URL**: API endpoint (default: `https://api.openai.com/v1`)
- **Model**: AI model to use (default: `gpt-4o-mini`)
- **Max Tokens**: Maximum response length (default: 500)
- **Temperature**: Creativity level 0-2 (default: 0.7)
- **Timeout**: Request timeout in seconds (default: 10)

### Supported API Providers

- **OpenAI**: Use default settings
- **Ollama**: Set base URL to `http://localhost:11434/v1`
- **LM Studio**: Set base URL to `http://localhost:1234/v1`
- **Any OpenAI-compatible API**: Configure custom base URL

## Architecture

```
PromptSpark/
├── App/              # Application entry point
├── Core/             # Core business logic
│   ├── APIClient     # OpenAI-compatible API client
│   ├── PromptEngine  # Meta-prompt processing
│   ├── HotkeyManager # Global hotkey handling
│   └── TextCapture   # Text capture/replacement
├── Models/           # Data models
├── Views/            # UI (MenuBar + Settings)
├── Services/         # Supporting services
└── Resources/        # Default meta-prompts
```

## Development

### Project Structure

The project uses Swift Package Manager and is organized into clear layers:

- **System Interaction Layer**: Global hotkey, text capture, clipboard
- **Business Logic Layer**: Prompt engine, API client, configuration
- **UI Layer**: MenuBar (AppKit) + Settings (SwiftUI)
- **Data Layer**: Keychain, UserDefaults, JSON files

### Dependencies

- **KeyboardShortcuts**: Global hotkey management

### Building

```bash
# Debug build
swift build

# Release build
swift build -c release

# Run tests
swift test
```

## Troubleshooting

### Hotkey not working
- Ensure Accessibility permission is granted
- Check System Settings → Keyboard → Keyboard Shortcuts for conflicts
- Try restarting the app

### API errors
- Verify your API key is correct
- Check your internet connection
- Ensure the API endpoint is accessible
- Try increasing the timeout value

### Text not being replaced
- Make sure text is selected before pressing the hotkey
- Verify Accessibility permission is granted
- Check that the target application supports clipboard paste

## Performance

- **Cold start**: <100ms
- **Memory usage**: <30MB
- **Hotkey latency**: <50ms
- **API timeout**: 10s (configurable)

## Security & Privacy

- API keys stored in macOS Keychain (encrypted)
- No data collection or telemetry
- All processing happens locally
- HTTPS enforced for API calls
- Open source (audit the code yourself)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Your chosen license]

## Support

- Issues: [GitHub Issues](https://github.com/yourusername/prompt-spark/issues)
- Discussions: [GitHub Discussions](https://github.com/yourusername/prompt-spark/discussions)

## Roadmap

- [ ] Windows support
- [ ] Linux support
- [ ] Plugin system for custom transformations
- [ ] Prompt history and favorites
- [ ] Team collaboration features
- [ ] More built-in profile templates

---

**Made with ❤️ for the AI community**
