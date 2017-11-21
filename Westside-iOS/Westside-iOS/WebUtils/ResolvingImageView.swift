import UIKit

/**
 Instances of this class can be used to display images that are fetched lazily from a web server. It will work with
 `ImageStore` to download and cache images.
 */
public class ResolvingImageView: UIImageView {
    /**
     Setting this property will attempt to fetch the image at the location `urlString` from the `ImageStore`.
     Setting this property to `nil` will remove any image from the receiver.
     */
    public var urlString: String? {
        didSet {
            guard let actualUrlString = urlString else {
                image = nil
                loadingImageView.isHidden = true
                return
            }
            
            loadingImageView.isHidden = false
            
            ImageStore.store.fetchImage(for: actualUrlString) { [weak self] (img) -> Void in
                if let actualSelf = self, actualUrlString == actualSelf.urlString {
                    actualSelf.image = img
                    actualSelf.loadingImageView.isHidden = true
                    
                    actualSelf.imageResolvedCompletion?(actualSelf, img != nil)
                }
            }
        }
    }
    
    /**
     ImageView that appears while the receiver is loading.
     */
    public lazy var loadingImageView: UIImageView = {
        let loadingImageView = UIImageView()
        loadingImageView.translatesAutoresizingMaskIntoConstraints = false
        loadingImageView.contentMode = self.contentMode
        loadingImageView.isHidden = true
        return loadingImageView
    }()
    
    /**
     If you'd like to take an extra action after the image succeeds or fails downloading, you may set this block.
     Defaults to nil.
     */
    public var imageResolvedCompletion: ((_ imageView: ResolvingImageView, _ success: Bool) -> Void)?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        addSubview(loadingImageView)
        
        NSLayoutConstraint(item: loadingImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    // MARK: - Deprecations
    
    /**
     Setting this property will set the image that appears while the receiver is loading. This property must be set
     before setting `urlString` if you wish to see a loading image.
     */
    @available(*, deprecated: 2.0, renamed: "loadingImageView.image")
    public var loadingImage: UIImage?
    
    /**
     Setting this property will impact how the receiver positions and scales an image located at `urlString`. Defaults to
     the contentMode of the receiver when it is first instantiated.
     */
    @available(*, deprecated: 2.0, renamed: "contentMode")
    public var normalContentMode: UIViewContentMode {
        get {
            return contentMode
        }
        set {
            contentMode = newValue
        }
    }
    
    /**
     Setting this property will impact how the receiver positions and scales its loading image. Defaults to the
     contentMode of the receiver when it is first instantiated.
     */
    @available(*, deprecated: 2.0, renamed: "loadingImageView.contentMode")
    public var loadingContentMode: UIViewContentMode {
        get {
            return loadingImageView.contentMode
        }
        set {
            loadingImageView.contentMode = newValue
        }
    }
}

