import UIKit


struct SearchResultViewContentConfiguration: UIContentConfiguration {
    
    var title: String
    var subtitle: String
    
    func updated(for state: UIConfigurationState) -> Self {
        self
    }
    
    func makeContentView() -> UIView & UIContentView {
        SearchResultView(configuration: self)
    }
}


final class SearchResultView: UIView, UIContentView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    var configuration: UIContentConfiguration {
        didSet {
            invalidateConfiguration()
        }
    }
    
    init(configuration: SearchResultViewContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        initializeLayout()
        invalidateConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("This class cannot be used in a storyboard or nib")
    }
    
    private func initializeLayout() {
        let layout: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .vertical
            view.spacing = 8
            view.alignment = .leading
            view.distribution = .fillProportionally
            view.addArrangedSubview(titleLabel)
            view.addArrangedSubview(subtitleLabel)
            return view
        }()
        
        titleLabel.backgroundColor = .cyan
        subtitleLabel.backgroundColor = .green
        backgroundColor = .magenta

        addSubview(layout)
        
        NSLayoutConstraint.activate([
            layout.leftAnchor.constraint(
                equalTo: layoutMarginsGuide.leftAnchor
            ),
            layout.rightAnchor.constraint(
                equalTo: layoutMarginsGuide.rightAnchor
            ),
            layout.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor
            ),
            layout.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor
            ),
        ])
    }
    
    private func invalidateConfiguration() {
        guard let configuration = configuration as? SearchResultViewContentConfiguration else {
            return
        }
        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
    }
}
