import UIKit

class FloatingTextField: UITextField {
    // MARK: - Customizable Properties
    var underlineColor: UIColor? {
        get {
            return underline.backgroundColor
        }
        set {
            underline.backgroundColor = newValue
            if newValue == nil {
                underline.isHidden = true
            } else {
                underline.isHidden = false
            }
        }
    }
    
    var floatingLabelPadding = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var alwaysShowFloatingLabel = false {
        didSet {
            setNeedsLayout()
        }
    }
    var animationType: AnimationType = .fade
    
    override var placeholder: String? {
        didSet {
            if floatingLabel.text == nil || floatingLabel.text == "" || floatingLabel.text == oldValue {
                floatingLabel.text = placeholder
            }
        }
    }
    
    // MARK: - Convenience Properties
    private var shouldHideLabel: Bool {
        return (text?.count ?? 0) == 0 && !alwaysShowFloatingLabel
    }
    
    private var labelHeight: CGFloat {
        floatingLabel.sizeToFit()
        return floatingLabel.bounds.height + floatingLabelPadding.top + floatingLabelPadding.bottom
    }
    
    private var floatingLabelHidden = false
    
    // MARK: - Views
    lazy var floatingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    private lazy var underline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(floatingLabel)
        floatingLabel.frame.origin = CGPoint(x: floatingLabelPadding.left, y: floatingLabelPadding.top)
        floatingLabel.alpha = shouldHideLabel ? 0 : 1
        floatingLabelHidden = shouldHideLabel
        
        addSubview(underline)
        underline.heightAnchor.constraint(equalToConstant: 1).isActive = true
        underline.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        underline.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        underline.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    // MARK: - UITextField Overrides
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, UIEdgeInsets(top: labelHeight, left: 0, bottom: 0, right: 0))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        floatingLabel.frame.origin = CGPoint(x: floatingLabelPadding.left, y: floatingLabelPadding.top)
        
        if floatingLabelHidden != shouldHideLabel {
            if shouldHideLabel {
                hideLabel()
            } else {
                showLabel()
            }
            
            floatingLabelHidden = shouldHideLabel
        }
    }
    
    // MARK: - Animations
    private func showLabel() {
        performAnimation(animationType.showAnimation)
    }
    
    private func hideLabel() {
        performAnimation(animationType.hideAnimation)
    }
    
    private func performAnimation(_ animation: @escaping (FloatingTextField) -> Void) {
        if animationType.duration > 0 {
            let animationClosure: () -> Void = { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                animation(strongSelf)
            }
            
            UIView.animate(
                withDuration: animationType.duration,
                delay: animationType.delay,
                options: animationType.options,
                animations: animationClosure,
                completion: nil
            )
        } else {
            animation(self)
        }
    }
    
    // MARK: - AnimationType
    enum AnimationType {
        case none
        case fade
        
        var duration: TimeInterval {
            switch self {
            case .none:
                return 0
            case .fade:
                return 0.3
            }
        }
        
        var delay: TimeInterval {
            switch self {
            case .none, .fade:
                return 0
            }
        }
        
        var options: UIViewAnimationOptions {
            switch self {
            case .none:
                return []
            case .fade:
                return [.beginFromCurrentState, .curveEaseOut]
            }
        }
        
        var showAnimation: (FloatingTextField) -> Void {
            switch self {
            case .none, .fade:
                return { $0.floatingLabel.alpha = 1 }
            }
        }
        
        var hideAnimation: (FloatingTextField) -> Void {
            switch self {
            case .none, .fade:
                return { $0.floatingLabel.alpha = 0 }
            }
        }
    }
}
