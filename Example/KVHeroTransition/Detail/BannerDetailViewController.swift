import UIKit
import KVHeroTransition

class BannerDetailViewController: UIViewController {
    var photo: UIImage!
    
    private let bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Image Details"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "This is a beautiful image with a smooth banner transition animation. The image smoothly animates from the grid to the banner position."
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        return closeButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add banner image view
        view.addSubview(bannerImageView)
        bannerImageView.image = photo
        
        // Add content view
        view.addSubview(contentView)

        // Add labels to content view
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 300),
            
            contentView.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// MARK: - KVTransitionAnimatable

extension BannerDetailViewController: KVTransitionAnimatable {
    
    func heroImage() -> UIImage? {
        return photo
    }
    
    var imageViewFrame: CGRect? {
        guard let contentFrame = bannerImageView.imageContentFrame else {
            return .zero
        }
        return bannerImageView.convert(contentFrame, to: self.view)
    }
    
    var enableInteractionDismiss: Bool {
        return false
    }
    
    func interactionViewForDismiss() -> UIView? {
        return bannerImageView
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
