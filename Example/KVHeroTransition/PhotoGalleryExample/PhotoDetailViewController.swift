import UIKit
import KVHeroTransition

class PhotoDetailViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(closeButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        imageView.image = photo
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    
} 
// MARK: - KVTransitionAnimatable

extension PhotoDetailViewController: KVTransitionAnimatable {
    
    func heroImage() -> UIImage? {
        return photo
    }
    
    var imageViewFrame: CGRect? {
        guard let contentFrame = imageView.imageContentFrame else {
            return .zero
        }
        return imageView.convert(contentFrame, to: self.view)
    }
    
    var enableInteractionDismiss: Bool {
        return true
    }
    
    func interactionViewForDismiss() -> UIView? {
        return imageView
    }
    
    func animationWillStart(transitionType: KVTransitionType) {
        // You can add custom preparation logic here
        print("Transition starting: \(transitionType)")
    }
    
    func animationDidEnd(transitionType: KVTransitionType) {
        // You can add custom completion logic here
        print("Transition completed: \(transitionType)")
    }
}
