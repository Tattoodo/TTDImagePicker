import UIKit

class TTDLoadingView: UIView {
    
    let spinner = UIActivityIndicatorView(style: .whiteLarge)
    let processingLabel = UILabel()
    
    convenience init() {
        self.init(frame: .zero)
    
        // View Hiearachy
        let stack = UIStackView(arrangedSubviews: [spinner, processingLabel])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        // Layout
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        processingLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
        
        // Style
        backgroundColor = UIColor.ypLabel.withAlphaComponent(0.8)
        processingLabel.textColor = .ypSystemBackground
        spinner.hidesWhenStopped = true
        
        // Content
        processingLabel.text = TTDConfig.wordings.processing
        
        spinner.startAnimating()
    }
    
    func toggleLoading() {
        if !spinner.isAnimating {
            spinner.startAnimating()
            alpha = 1
        } else {
            spinner.stopAnimating()
            alpha = 0
        }
    }
}
