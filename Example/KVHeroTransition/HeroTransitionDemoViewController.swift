import UIKit
import KVHeroTransition

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
    
    private let photos: [UIImage] = [
        UIImage(named: "photo1") ?? UIImage(),
        UIImage(named: "photo2") ?? UIImage(),
        UIImage(named: "photo3") ?? UIImage(),
        UIImage(named: "photo1") ?? UIImage(),
        UIImage(named: "photo2") ?? UIImage(),
        UIImage(named: "photo3") ?? UIImage(),
        UIImage(named: "photo1") ?? UIImage(),
        UIImage(named: "photo2") ?? UIImage(),
        UIImage(named: "photo3") ?? UIImage(),
        UIImage(named: "photo1") ?? UIImage(),
        UIImage(named: "photo2") ?? UIImage(),
        UIImage(named: "photo3") ?? UIImage()
    ]
    
    private let type: TransitionDemoType
    private var heroTransitionManager: KVHeroTransitionManager?
    private var pinterestTransitionManager: KVPinterestTransitionManager?
    private var cellSelected: PhotoCell?

    init(type: TransitionDemoType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = type.title
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func heroTransition(_ indexPath: IndexPath) {
        let detailVC = PhotoDetailViewController()
        detailVC.photo = photos[indexPath.item]

        heroTransitionManager = KVHeroTransitionManager(
            presentingViewController: self,
            presentedViewController: detailVC
        )
        
        detailVC.modalPresentationStyle = .custom
        detailVC.transitioningDelegate = heroTransitionManager
        self.navigationController?.present(detailVC, animated: true)
    }
    
    private func pỉnterestTransition(_ indexPath: IndexPath) {
        let detailVC = PhotoDetailViewController()
        detailVC.photo = photos[indexPath.item]

        pinterestTransitionManager = KVPinterestTransitionManager(
            presentingViewController: self,
            presentedViewController: detailVC
        )
        
        detailVC.modalPresentationStyle = .custom
        detailVC.transitioningDelegate = pinterestTransitionManager
        self.navigationController?.present(detailVC, animated: true)
    }
    
    private func bannerTransition(_ indexPath: IndexPath) {
        let detailVC = BannerDetailViewController()
        detailVC.photo = photos[indexPath.item]

        heroTransitionManager = KVHeroTransitionManager(
            presentingViewController: self,
            presentedViewController: detailVC
        )
        
        detailVC.modalPresentationStyle = .custom
        detailVC.transitioningDelegate = heroTransitionManager
        self.navigationController?.present(detailVC, animated: true)
    }
    
    func presentDetailViewController(indexPath: IndexPath) {
        switch type {
        case .hero: heroTransition(indexPath)
        case .pinterest: pỉnterestTransition(indexPath)
        case .banner: bannerTransition(indexPath)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HeroTransitionDemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.configure(with: photos[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HeroTransitionDemoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else { return }
        cellSelected = cell
        
        presentDetailViewController(indexPath: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HeroTransitionDemoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 10) / 2
        return CGSize(width: width, height: width)
    }
}

extension HeroTransitionDemoViewController: KVTransitionAnimatable {
    var imageViewFrame: CGRect? {
        guard let imv = cellSelected?.getImageView() else { return .zero }
        return imv.convert(imv.bounds, to: self.view)
    }
    
    var cornerRadius: CGFloat {
        return 12
    }
    
    func heroImage() -> UIImage? {
        return cellSelected?.getImageView().image
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
