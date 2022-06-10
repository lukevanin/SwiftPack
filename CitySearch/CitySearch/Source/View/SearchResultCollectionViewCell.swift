import UIKit


struct SearchResultViewContentConfiguration: UIContentConfiguration {
    
    var title: String
    var subtitle: String
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
    
    func makeContentView() -> UIView & UIContentView {
        return SearchResultView(configuration: self)
    }
}


final class SearchResultView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            invalidateConfiguration()
        }
    }
    
    init(configuration: SearchResultViewContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        invalidateConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("This class cannot be used in a storyboard or nib")
    }
    
    private func invalidateConfiguration() {
        guard let configuration = configuration as? SearchResultViewContentConfiguration else {
            return
        }
    }
}
