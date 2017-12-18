import UIKit
import Forge

class MinistryViewController: NavigatableViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var chairPersonLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var ministryButton: UIButton!
    
    let ministry: Group
    var currentUser: User? {
        return Store.sharedStore.user
    }
    var isMember: Bool = false
    
    init(ministry: Group) {
        self.ministry = ministry
        super.init()
        //super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = ministry.name
        descriptionTextView.text = ministry.groupDescription
        
        chairPersonLabel.text = "Chairperson: " +  ministry.chairPerson!
//        phoneLabel.text = "Phone: " +  ministry.phone!
//        emailLabel.text = "Email: " + ministry.email!
        
        isMember = hasJoined()
        if (hasJoined()) {
            ministryButton.setTitle(NSLocalizedString("Leave Ministry", comment: ""), for: .normal)
        } else {
            ministryButton.setTitle(NSLocalizedString("Join Ministry", comment: ""), for: .normal)
        }

        loadingIndicator?.stopAnimating()
    }
    
    // MARK: - Actions
    @IBAction func ministryButtonTapped(_ sender: UIButton) {
        if (currentUser == nil) {
            view.makeToast(NSLocalizedString("Please sign in", comment: ""), duration: 3)
            return
        }
        
        ministryButton.isHidden = true
        loadingIndicator?.startAnimating()
        
        if (isMember) {
            Store.sharedStore.leaveMinistry(ministry: ministry, completion: {(result) in
                switch result {
                    case .error(let e):
                        self.ministryButton.isHidden = false
                        self.loadingIndicator?.stopAnimating()
                        print("Error: \(e)")
                    default:
                        self.isMember = false
                        self.ministryButton.setTitle(NSLocalizedString("Join Ministry", comment: ""), for: .normal)
                        self.ministryButton.isHidden = false
                        self.loadingIndicator?.stopAnimating()
                }
            })
            
        } else {
            Store.sharedStore.joinMinistry(ministry: ministry, completion: {(result) in
                
                switch result {
                case .value:
                    self.isMember = true
                    self.ministryButton.setTitle(NSLocalizedString("Leave Ministry", comment: ""), for: .normal)
                    self.ministryButton.isHidden = false
                    self.loadingIndicator?.stopAnimating()
                case .error(let e):
                    self.ministryButton.isHidden = false
                    self.loadingIndicator?.stopAnimating()
                    print("Error: \(e)")
                }
            })
            
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Do something
    }
    
    func hasJoined() -> Bool {
        guard let groupMembers = ministry.members else {
            return false
        }
        
        guard let me = currentUser else {
            return false;
        }
        
        for user in groupMembers {
            if user.id == me.id {
                return true
            }
        }
        
        return false
    }
}
