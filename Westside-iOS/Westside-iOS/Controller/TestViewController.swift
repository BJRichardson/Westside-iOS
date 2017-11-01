import Foundation
import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    private var text: String
    
    init(title: String) {
        self.text = title
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString(title, comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = NSLocalizedString(text, comment: "")
    }
}
