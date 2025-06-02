import UIKit
import KVHeroTransition

class PhotoGalleryViewController: UIViewController {
    
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
    
    private var heroTransitionManager: KVHeroTransitionManager?
    private var pinterestTransitionManager: KVPinterestTransitionManager?

    private var cellSelected: PhotoCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Photo Gallery"
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
}

// MARK: - UICollectionViewDataSource
extension PhotoGalleryViewController: UICollectionViewDataSource {
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
extension PhotoGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else { return }
        cellSelected = cell
        
        pỉnterestTransition(indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 10) / 2
        return CGSize(width: width, height: width)
    }
} 

extension PhotoGalleryViewController: KVTransitionAnimatable {
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
