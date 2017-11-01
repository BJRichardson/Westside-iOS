import Foundation
import UIKit

extension UIViewController {
    func setUpChildViewController(viewController: UIViewController, containerView: UIView) {
        addChildViewController(viewController)
        
        containerView.addSubview(viewController.view)
        
        let childView = viewController.view
        childView?.translatesAutoresizingMaskIntoConstraints = false
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", options:NSLayoutFormatOptions(), metrics: nil, views: ["v": childView!])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", options:NSLayoutFormatOptions(), metrics: nil, views: ["v": childView!])
        containerView.addConstraints(hConstraints)
        containerView.addConstraints(vConstraints)
        
        viewController.didMove(toParentViewController: self)
    }
}
