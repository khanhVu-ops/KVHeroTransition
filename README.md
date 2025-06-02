# KVHeroTransition

[![Version](https://img.shields.io/cocoapods/v/KVHeroTransition.svg?style=flat)](https://cocoapods.org/pods/KVHeroTransition)
[![License](https://img.shields.io/cocoapods/l/KVHeroTransition.svg?style=flat)](https://cocoapods.org/pods/KVHeroTransition)
[![Platform](https://img.shields.io/cocoapods/p/KVHeroTransition.svg?style=flat)](https://cocoapods.org/pods/KVHeroTransition)
[![Swift Version](https://img.shields.io/badge/Swift-5.3+-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)

**KVHeroTransition** is a lightweight, customizable, and elegant **Hero-style zoom transition animation** library for iOS applications. Create stunning Material Design-inspired transitions between view controllers with smooth animations, interactive gestures, and zero dependencies.

> 🎯 **Perfect for**: Photo galleries, detail views, card-based UIs, and any app requiring smooth visual transitions

---

## 🌟 Key Features

- ✨ **Hero-style zoom transitions** between UIViewControllers
- 👆 **Interactive drag-to-dismiss** gesture support
- 🎨 **Customizable corner radius** and curve animations
- 🪶 **Ultra-lightweight** - zero third-party dependencies
- 🚀 **Easy integration** - just 3 lines of code to get started
- 📱 **iOS 13+** compatible with Swift 5.3+
- 🔧 **Fully customizable** animation parameters
- 💯 **100% Swift** implementation

---

## 📸 Demo

![KVHeroTransition Demo](demo.gif)

*Smooth hero transitions with interactive dismiss gestures*

---

## 🚀 Quick Start

### Installation

#### CocoaPods
Add to your `Podfile`:
```ruby
pod 'KVHeroTransition'
```

Then run:
```bash
pod install
```

#### Swift Package Manager
```swift
.package(url: "https://github.com/khanhVu-ops/KVHeroTransition.git", from: "1.0.0")
```

### Basic Usage

**Step 1**: Make your view controllers conform to `KVTransitionAnimatable`

```swift
import KVHeroTransition

class PhotoDetailViewController: UIViewController, KVTransitionAnimatable {
    @IBOutlet weak var imageView: UIImageView!
    
    var photo: UIImage?
    
    // MARK: - KVTransitionAnimatable
    func heroImage() -> UIImage? {
        return photo
    }
    
    var imageViewFrame: CGRect? {
        return imageView?.frame
    }
    
    var enableInteractionDismiss: Bool {
        return true
    }
    
    func interactionViewForDismiss() -> UIView? {
        return view
    }
}
```

**Step 2**: Present with hero transition

```swift
let detailVC = PhotoDetailViewController()
detailVC.photo = selectedImage
detailVC.modalPresentationStyle = .custom
detailVC.transitioningDelegate = KVTransitionDelegate(fromVC: self, toVC: detailVC)
present(detailVC, animated: true)
```

That's it! 🎉

---

## 📋 Requirements

| Component | Version |
|-----------|---------|
| **iOS** | 13.0+ |
| **Swift** | 5.3+ |
| **Xcode** | 12.0+ |
| **Dependencies** | None |

---

## 🎨 Customization

### Animation Properties

```swift
// Customize corner radius
var cornerRadius: CGFloat { return 12.0 }

// Choose corner curve style
var cornerCurve: CALayerCornerCurve { return .continuous }

// Enable/disable interactive dismiss
var enableInteractionDismiss: Bool { return true }
```

### Lifecycle Callbacks

```swift
func animationWillStart(transitionType: KVTransitionType) {
    // Prepare for animation start
    print("Transition starting: \(transitionType)")
}

func animationDidEnd(transitionType: KVTransitionType) {
    // Handle animation completion
    print("Transition completed: \(transitionType)")
}
```

### Advanced Configuration

| Property | Type | Description |
|----------|------|-------------|
| `heroImage()` | `UIImage?` | Image to animate during transition |
| `imageViewFrame` | `CGRect?` | Frame of the animated image view |
| `cornerRadius` | `CGFloat` | Corner radius during animation |
| `cornerCurve` | `CALayerCornerCurve` | Corner curve style (.continuous/.circular) |
| `enableInteractionDismiss` | `Bool` | Enable drag-to-dismiss gesture |
| `interactionViewForDismiss()` | `UIView?` | View to track for dismiss gesture |

---

## 📖 Documentation

### KVTransitionAnimatable Protocol

The core protocol that enables hero transitions:

```swift
protocol KVTransitionAnimatable {
    func heroImage() -> UIImage?
    var imageViewFrame: CGRect? { get }
    var cornerRadius: CGFloat { get }
    var cornerCurve: CALayerCornerCurve { get }
    var enableInteractionDismiss: Bool { get }
    func interactionViewForDismiss() -> UIView?
    func animationWillStart(transitionType: KVTransitionType)
    func animationDidEnd(transitionType: KVTransitionType)
}
```

### KVTransitionDelegate

Handles the transition logic between view controllers:

```swift
let transitionDelegate = KVTransitionDelegate(fromVC: sourceViewController, 
                                            toVC: destinationViewController)
destinationViewController.transitioningDelegate = transitionDelegate
```

---

## 💡 Use Cases

- 📷 **Photo Gallery Apps** - Smooth zoom transitions between thumbnail and full-size images
- 🛍️ **E-commerce Apps** - Product card to detail page transitions
- 📰 **News Apps** - Article preview to full article transitions
- 🎵 **Music Apps** - Album art transitions and player views
- 📱 **Social Media** - Profile picture and post detail transitions
- 🏪 **Marketplace Apps** - Item grid to detail view transitions

---

## 🔧 Example Project

Clone and run the example:

```bash
git clone https://github.com/khanhVu-ops/KVHeroTransition.git
cd KVHeroTransition/Example
pod install
open Example.xcworkspace
```

The example demonstrates:
- Basic hero transitions
- Interactive dismiss gestures
- Custom corner radius animations
- Multiple transition scenarios

---

## 🐛 Troubleshooting

### Common Issues

**Q: CocoaPods shows "Unable to find a specification"**
```bash
pod repo update
pod install --repo-update
```

**Q: Animation doesn't work with custom UIImageView**
- Ensure `imageViewFrame` returns the correct frame
- Check that `heroImage()` returns a valid UIImage
- Verify the image view is properly configured before transition

**Q: Interactive dismiss not working**
- Set `enableInteractionDismiss` to `true`
- Implement `interactionViewForDismiss()` to return the correct view
- Ensure the view has proper gesture recognizer setup

---


## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. 🍴 **Fork** the repository
2. 🌟 **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. 📝 **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. 🚀 **Push** to the branch (`git push origin feature/amazing-feature`)
5. 🔃 **Open** a Pull Request

### Development Setup

```bash
git clone https://github.com/khanhVu-ops/KVHeroTransition.git
cd KVHeroTransition
open KVHeroTransition.xcodeproj
```

---

## 🧑‍💻 Author

**Khanh Vu**
- 📧 Email: [vuvankhanh022002@gmail.com](mailto:vuvankhanh022002@gmail.com)
- 🐙 GitHub: [@khanhVu-ops](https://github.com/khanhVu-ops)
- 💼 LinkedIn: [Connect with me](https://linkedin.com/in/khanhvu-ops)

---

## 📄 License

KVHeroTransition is released under the **MIT License**. See [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Khanh Vu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...
```

---

## 🌟 Show Your Support

If you find KVHeroTransition helpful, please:

- ⭐ **Star** this repository on GitHub
- 🐦 **Share** it on social media
- 💬 **Tell** your friends and colleagues
- 🔗 **Link** to it in your projects

[![GitHub stars](https://img.shields.io/github/stars/khanhVu-ops/KVHeroTransition.svg?style=social&label=Star)](https://github.com/khanhVu-ops/KVHeroTransition)
[![GitHub forks](https://img.shields.io/github/forks/khanhVu-ops/KVHeroTransition.svg?style=social&label=Fork)](https://github.com/khanhVu-ops/KVHeroTransition/fork)

---

## 🔍 Keywords

`iOS animation` `hero transition` `zoom animation` `UIViewController transition` `Swift animation library` `iOS UI` `Material Design` `interactive transition` `drag to dismiss` `photo gallery transition` `custom transition` `iOS development` `Swift package` `CocoaPods` `open source iOS`

---

## 📚 Related Projects

- [Hero](https://github.com/HeroTransitions/Hero) - Supercharged transition engine
- [Lottie](https://github.com/airbnb/lottie-ios) - Animation library
- [Spring](https://github.com/MengTo/Spring) - Swift animation framework

---

<p align="center">
  <strong>Made with ❤️ by Khanh Vu</strong><br>
  <em>Building beautiful iOS transitions, one animation at a time</em>
</p>
