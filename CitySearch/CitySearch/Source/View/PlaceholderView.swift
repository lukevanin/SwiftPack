import UIKit

final class PlaceholderView: UIView {
    
    var iconImageName: String? {
        didSet {
            invalidateImage()
        }
    }
    
    var caption: String? {
        didSet {
            invalidateText()
        }
    }
    
    var foregroundColor: UIColor = .secondaryLabel {
        didSet {
            invalidateForegroundColor()
        }
    }
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.8
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "placeholder"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeLayout()
    }
    
    private func initializeLayout() {
        let contentLayout: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .vertical
            view.alignment = .center
            view.spacing = 16
            view.addArrangedSubview(imageView)
            view.addArrangedSubview(label)
            return view
        }()
        addSubview(contentLayout)
        NSLayoutConstraint.activate([
            contentLayout.leftAnchor.constraint(
                equalTo: layoutMarginsGuide.leftAnchor
            ),
            contentLayout.rightAnchor.constraint(
                equalTo: layoutMarginsGuide.rightAnchor
            ),
            contentLayout.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor
            ),
            contentLayout.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor
            ),
        ])
        invalidateForegroundColor()
        invalidateImage()
        invalidateText()
    }
    
    private func invalidateForegroundColor() {
        label.textColor = foregroundColor
        imageView.tintColor = foregroundColor
    }
    
    private func invalidateImage() {
        let configuration = UIImage.SymbolConfiguration(
            font: label.font.withSize(56)
        )
        imageView.image = iconImageName.flatMap { systemName in
            UIImage(systemName: systemName, withConfiguration: configuration)
        }
    }
    
    private func invalidateText() {
        label.text = caption
    }
}
