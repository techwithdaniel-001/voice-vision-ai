# Lexi AI Assistant - Voice & Vision Companion

A Flutter-based AI assistant designed specifically for blind and visually impaired individuals, featuring voice interaction and computer vision capabilities.

## 🌟 Features

### Voice Assistant (Lexi)
- **Compassionate AI Companion**: Specialized personality for blind users
- **Female Voice**: Friendly, expressive, young female voice at faster pace
- **Emotional Intelligence**: Recognizes and responds to emotional states
- **Real-time Conversation**: Powered by OpenAI's Realtime API via Stream Video

### Computer Vision Integration
- **Real-time Image Analysis**: Uses OpenAI's GPT-4 Vision model
- **Automatic Scene Description**: Lexi describes what it sees in detail
- **Smart Vision Detection**: Automatically detects vision-related questions
- **Gray Image Filtering**: Skips blank/gray images during camera initialization

### Accessibility Features
- **Navigation Assistance**: Help with indoor/outdoor navigation
- **Object Recognition**: Identifies objects, people, and environments
- **Safety Awareness**: Obstacle detection and safety warnings
- **Daily Living Support**: Meal prep, clothing, personal care assistance

## 🏗️ Architecture

### Backend (Node.js)
- **Server**: `openai-audio-tutorial/server.mjs`
- **APIs**: 
  - `/credentials` - Stream Video call setup
  - `/chat` - Text-based conversation with vision context
  - `/analyze-image` - Image analysis with GPT-4 Vision
  - `/update-visual-context` - Visual context management

### Frontend (Flutter)
- **Main App**: `openai-tutorial-flutter/`
- **Key Components**:
  - `main.dart` - App entry point
  - `home_page.dart` - Main interface with camera toggle
  - `visual_assistance_view.dart` - Camera integration
  - `ai_demo_controller.dart` - AI session management

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK
- Node.js
- OpenAI API key
- Stream Video account

### Backend Setup
```bash
cd openai-audio-tutorial
npm install
# Add your OpenAI API key to environment
node server.mjs
```

### Flutter App Setup
```bash
cd openai-tutorial-flutter
flutter pub get
flutter run
```

## 🔧 Configuration

### Environment Variables
- `OPENAI_API_KEY`: Your OpenAI API key
- `STREAM_API_KEY`: Stream Video API key
- `STREAM_API_SECRET`: Stream Video API secret

### Camera Integration
- **iOS**: Requires camera permissions
- **Android**: Requires camera and storage permissions
- **Wireless Debugging**: Supports ADB wireless connection

## 📱 Usage

### Voice Mode
1. Start a conversation with Lexi
2. Ask questions naturally
3. Lexi responds with compassionate, helpful guidance

### Vision Mode
1. Toggle camera on
2. Point camera at objects/environments
3. Ask vision-related questions:
   - "What do you see?"
   - "Can you help me navigate?"
   - "What's in front of me?"
   - "Is it safe to walk here?"

### Smart Integration
- Lexi automatically detects vision questions
- Seamlessly switches between voice and vision modes
- Maintains conversation context across modes

## 🐛 Known Issues

### Current Limitations
1. **Gradle Build Issues**: Android build sometimes fails due to Worker Daemon
2. **Speech Trigger**: Automatic speech on image analysis needs refinement
3. **Vision Routing**: Vision question detection needs optimization

### Workarounds
- Clean build: `flutter clean && flutter pub get`
- Manual camera toggle for vision questions
- Restart server if speech trigger fails

## 🔮 Future Enhancements

- [ ] Improved vision question routing
- [ ] Enhanced speech triggers
- [ ] Better gray image detection
- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Advanced navigation features

## 🤝 Contributing

This project is designed to improve accessibility for blind and visually impaired individuals. Contributions that enhance accessibility features are especially welcome.

## 📄 License

This project is for educational and accessibility purposes.

## 🙏 Acknowledgments

- OpenAI for GPT-4 Vision and Realtime APIs
- Stream Video for real-time communication infrastructure
- Flutter team for the mobile framework
- The blind and visually impaired community for inspiration and feedback 