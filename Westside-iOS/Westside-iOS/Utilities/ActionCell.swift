import Foundation
import UIKit

open class ActionCell: UITableViewCell {
    /**
     Convenience typealias for subclass action blocks. Used to forward `@IBAction`s to controllers.
     
     - parameter sender: The `UIControl` sending an event.
     - parameter for: The `IndexPath` of the cell that contains the control.
     */
    public typealias ControlAction = (_ sender: UIControl, _ for: IndexPath) -> Void
    
    /**
     Will return the indexPath in the owning table view of the receiver. This property is derived at the time this method is called.
     */
    public var indexPath: IndexPath {
        return owningTableView.indexPath(for: self)!
    }
    
    /**
     The table view the cell is being used in. Automatically set by using the `reusableCell(for:)` method.
     */
    public var owningTableView: UITableView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellDidLoad()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        cellDidLoad()
    }
    
    /**
     This function is used for customization after the cell is loaded. Meant to be overridden by subclasses.
     */
    open func cellDidLoad() {
        
    }
}

public extension UITableView {
    /**
     A convenience method to register a class with a table view. Requires a xib with the same name as the class.
     
     - parameter classType: The class of the cell to be used with the table view.
     */
    public func register<T: ActionCell>(class classType: T.Type) {
        let className = String(describing: classType)
        let nib = UINib(nibName: className, bundle: Bundle(for: T.self))
        register(nib, forCellReuseIdentifier: className)
    }
    
    /**
     A convenience method for dequeuing a reusable cell and setting the cell's owningTableView. Prefer this method to manually dequeing and setting those properties.
     
     - parameter indexPath: An optional `IndexPath` for the cell to be returned.
     
     - returns: An instance (new or recycled) of the receiver's type.
     */
    public func reusableCell<T: ActionCell>(for indexPath: IndexPath? = nil) -> T {
        let className = String(describing: T.self)
        let cell: T
        if let cellIndexPath = indexPath {
            cell = dequeueReusableCell(withIdentifier: className, for: cellIndexPath) as! T
        } else {
            cell = dequeueReusableCell(withIdentifier: className) as! T
        }
        cell.owningTableView = self
        
        return cell
    }
}
