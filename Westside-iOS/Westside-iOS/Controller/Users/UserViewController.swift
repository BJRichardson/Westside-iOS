import UIKit
import Forge

class UserViewController: NavigatableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    let user: User
    
    init(user: User) {
        self.user = user
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = user.fullName
        phoneLabel.text = user.phone
        emailLabel.text = user.email
    }

}
