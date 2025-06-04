# KVHeroTransition

[![Version](https://img.shields.io/cocoapods/v/KVHeroTransition.svg?style=flat)](https://cocoapods.org/pods/KVHeroTransition)
[![License](https://img.shields.io/cocoapods/l/KVHeroTransition.svg?style=flat)](https://cocoapods.org/pods/KVHeroTransition)
[![Platform](https://img.shields.io/cocoapods/p/KVHeroTransition.svg?style=flat)](https://cocoapods.org/pods/KVHeroTransition)
[![Swift Version](https://img.shields.io/badge/Swift-5.3+-orange.svg)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)

**KVHeroTransition** is a lightweight, customizable, and elegant transition animation library for iOS applications. It provides two main transition styles: Hero-style zoom transitions and Pinterest-style transitions.

> 🎯 **Perfect for**: Photo galleries, detail views, card-based UIs, and any app requiring smooth visual transitions

---

## 🌟 Key Features

- ✨ **Two transition styles**:
  - Hero-style zoom transitions
  - Pinterest-style transitions
- 👆 **Interactive drag-to-dismiss** gesture support
- 🎨 **Customizable corner radius** and curve animations
- 🪶 **Ultra-lightweight** - zero third-party dependencies
- 🚀 **Easy integration** - just a few lines of code to get started
- 📱 **iOS 13+** compatible with Swift 5.3+
- 🔧 **Fully customizable** animation parameters
- 💯 **100% Swift** implementation

---

## 📸 Demo

![KVHeroTransition Demo](https://raw.githubusercontent.com/khanhVu-ops/KVHeroTransition/main/demo_example.gif)

*Smooth transitions with interactive dismiss gestures*

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
    var photo: UIImage!
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.image = photo
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        dismiss(animated: true)
    }
    
    // MARK: - KVTransitionAnimatable
    var imageViewFrame: CGRect? {
        return imageView.frame
    }
    
    var cornerRadius: CGFloat {
        return 12
    }
    
    func heroImage() -> UIImage? {
        return imageView.image
    }
    
    func heroImageContentMode() -> UIView.ContentMode {
        return .scaleAspectFill
    }
    
    func animationWillStart(transitionType: KVTransitionType) {
        // Handle animation start
    }
    
    func animationDidEnd(transitionType: KVTransitionType) {
        // Handle animation end
    }
}
```

**Step 2**: Create a source view controller with collection view

```swift
class HeroTransitionDemoViewController: UIViewController {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        return cv
    }()
    
    // Important: Store transition manager as a strong reference
    private var transitionManager: Any?
    private var cellSelected: PhotoCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Setup collection view
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        // ... setup constraints
    }
}

// MARK: - UICollectionViewDelegate
extension HeroTransitionDemoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else { return }
        cellSelected = cell
        
        let detailVC = PhotoDetailViewController()
        detailVC.photo = photos[indexPath.item]
        
        // Create and store transition manager
        let heroManager = KVHeroTransitionManager(
            presentingViewController: self,
            presentedViewController: detailVC
        )
        // Important: Keep a strong reference to the transition manager
        transitionManager = heroManager
        
        detailVC.modalPresentationStyle = .custom
        detailVC.transitioningDelegate = heroManager
        
        present(detailVC, animated: true)
    }
}

// MARK: - KVTransitionAnimatable
extension HeroTransitionDemoViewController: KVTransitionAnimatable {
    var imageViewFrame: CGRect? {
        guard let imv = cellSelected?.getImageView() else { return .zero }
        return imv.convert(imv.bounds, to: self.view)
    }
    
    var cornerRadius: CGFloat {
        return 12
    }
    
    func heroImage() -> UIImage? {
        return nil
    }
    
    func heroImageContentMode() -> UIView.ContentMode {
        return .scaleAspectFill
    }
    
    func animationWillStart(transitionType: KVTransitionType) {
        switch transitionType {
        case .present:
            cellSelected?.isHidden = true
        case .dismiss:
            break
        }
    }
    
    func animationDidEnd(transitionType: KVTransitionType) {
        switch transitionType {
        case .present:
            break
        case .dismiss:
            cellSelected?.isHidden = false
        }
    }
}
```

**Step 3**: Use convenience methods for different transition types

```swift
// Hero transition
presentWithHeroTransition(detailVC)

// Pinterest transition
presentWithPinterestTransition(detailVC)
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

### Transition Types

1. **Hero Transition**
   - Smooth zoom transition between views
   - Perfect for photo galleries and detail views
   - Can be used to create banner-like transitions

2. **Pinterest Transition**
   - Pinterest-style masonry layout transitions
   - Great for grid-based UIs
   - Supports interactive dismiss gestures

### Animation Properties

```swift
// Customize corner radius
var cornerRadius: CGFloat { return 12.0 }

// Choose content mode
func heroImageContentMode() -> UIView.ContentMode {
    return .scaleAspectFill
}

// Handle animation lifecycle
func animationWillStart(transitionType: KVTransitionType) {
    // Prepare for animation
}

func animationDidEnd(transitionType: KVTransitionType) {
    // Handle completion
}
```

---

## 📖 Documentation

### KVTransitionAnimatable Protocol

The core protocol that enables transitions:

```swift
protocol KVTransitionAnimatable {
    var imageViewFrame: CGRect? { get }
    var cornerRadius: CGFloat { get }
    func heroImage() -> UIImage?
    func heroImageContentMode() -> UIView.ContentMode
    func animationWillStart(transitionType: KVTransitionType)
    func animationDidEnd(transitionType: KVTransitionType)
}
```

#### Protocol Methods Explained

1. **heroImage()**
   - Returns the image to be used during the transition animation
   - If returns `nil`, the system will automatically capture the screen content for transition
   - This is useful when you want to:
     - Use a different image for transition than what's displayed
     - Handle cases where the image might not be immediately available
     - Fall back to screen capture when no specific image is provided

2. **heroImageContentMode()**
   - Defines how the hero image should be displayed during transition
   - Common values:
     - `.scaleAspectFill`: Image fills the frame while maintaining aspect ratio (may crop)
     - `.scaleAspectFit`: Image fits within the frame while maintaining aspect ratio
     - `.scaleToFill`: Image stretches to fill the frame (may distort)
   - This affects how the image appears during the transition animation

Example implementation:
```swift
class PhotoDetailViewController: UIViewController, KVTransitionAnimatable {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // MARK: - KVTransitionAnimatable
    
    var imageViewFrame: CGRect? {
        return imageView.frame
    }
    
    var cornerRadius: CGFloat {
        return 12
    }
    
    func heroImage() -> UIImage? {
        return imageView.image
    }
    
    func heroImageContentMode() -> UIView.ContentMode {
        return .scaleAspectFill
    }
    
    func animationWillStart(transitionType: KVTransitionType) {
        // Handle animation start
    }
    
    func animationDidEnd(transitionType: KVTransitionType) {
        // Handle animation end
    }
}
```

### Important Notes

1. **Transition Manager Retention**
   - Always store the transition manager as a strong reference in your view controller
   - The `transitioningDelegate` is a weak reference, so the manager will be deallocated if not retained
   - Example:
   ```swift
   private var transitionManager: Any? // or specific type
   
   // When presenting
   let manager = KVHeroTransitionManager(...)
   transitionManager = manager // Store strong reference
   detailVC.transitioningDelegate = manager
   ```

2. **Memory Management**
   - The transition manager should be stored for the duration of the transition
   - It can be released after the transition is complete
   - Consider using a weak reference to the view controller in the manager to avoid retain cycles

3. **Hero Image Handling**
   - Always provide a valid `imageViewFrame` for accurate transition positioning
   - Use `heroImage()` to control which image is used during transition
   - Choose appropriate `heroImageContentMode()` based on your UI requirements
   - Consider using screen capture (returning nil from `heroImage()`) when:
     - The image is not immediately available
     - You want to transition the entire view content
     - You need to handle complex view hierarchies

---

## 💡 Use Cases

- 📷 **Photo Gallery Apps** - Hero transitions between thumbnail and full-size images
- 🛍️ **E-commerce Apps** - Product grid to detail transitions
- 📰 **News Apps** - Article preview to full article transitions
- 🎵 **Music Apps** - Album art transitions
- 📱 **Social Media** - Profile picture and post transitions
- 🏪 **Marketplace Apps** - Item grid to detail view transitions

---

## 🔧 Example Project

Clone and run the example:

```bash
git clone https://github.com/khanhVu-ops/KVHeroTransition.git
cd KVHeroTransition/Example
pod install
open KVHeroTransition.xcworkspace
```

The example demonstrates:
- Hero transitions
- Pinterest transitions
- Interactive dismiss gestures
- Custom corner radius animations

---

## 🐛 Troubleshooting

### Common Issues

**Q: Transition manager is nil after animation**
- Store the transition manager as a strong reference in your view controller
- Use the convenience methods for transitions
- Make sure the manager is not deallocated during the transition

**Q: Animation doesn't work with custom UIImageView**
- Ensure `imageViewFrame` returns the correct frame
- Check that the image view is properly configured
- Verify the view hierarchy is set up correctly

**Q: Interactive dismiss not working**
- Implement proper gesture handling
- Check view controller lifecycle methods
- Ensure the transition manager is properly retained

---

## 🧑‍💻 Author

**Khanh Vu**
- 📧 Email: [vuvankhanh022002@gmail.com](mailto:vuvankhanh022002@gmail.com)
- 🐙 GitHub: [@khanhVu-ops](https://github.com/khanhVu-ops)
- 💼 LinkedIn: [Connect with me](https://linkedin.com/in/khanhvu-ops)

---

## 📄 License

KVHeroTransition is released under the **MIT License**. See [LICENSE](LICENSE) file for details.

---

## 🔍 Keywords

`iOS animation` `hero transition` `zoom animation` `UIViewController transition` `Swift animation library` `iOS UI` `Material Design` `interactive transition` `drag to dismiss` `photo gallery transition` `custom transition` `iOS development` `Swift package` `CocoaPods` `open source iOS`

---


<p align="center">
  <strong>Made with ❤️ by Khanh Vu</strong><br>
  <em>Building beautiful iOS transitions, one animation at a time</em>
</p>
