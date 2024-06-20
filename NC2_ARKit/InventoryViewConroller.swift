import UIKit

protocol InventoryViewControllerDelegate: AnyObject {
    func didSelectModel(named modelName: String)
}

class InventoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var delegate: InventoryViewControllerDelegate?

    let models = ["Animated_fire", "Seaside", "Campfire_rock","Candle_Animated","Galaxy","Star_orb"]
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let selectButton = UIButton(type: .system)
    var selectedModel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 87, height: 87)
            layout.sectionInset = UIEdgeInsets(top: 17, left: 4, bottom: 17, right: 4)
        }
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 65),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        selectButton.setTitle("Select", for: .normal)
        selectButton.setTitleColor(.green, for: .normal)
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        view.addSubview(selectButton)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 48),
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .gray
        let modelName = models[indexPath.item]
        let imageView = UIImageView(image: UIImage(named: modelName))
        imageView.contentMode = .scaleAspectFit
        cell.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedModel = models[indexPath.item]
    }
    
    @objc func selectButtonTapped() {
        guard let selectedModel = selectedModel else { return }
        delegate?.didSelectModel(named: selectedModel)
        dismiss(animated: true, completion: nil)
    }
}
