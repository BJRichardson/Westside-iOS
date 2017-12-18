import UIKit
import Forge

class EventDetailsController: NavigatableViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var eventImageView: ResolvingImageView!
    @IBOutlet weak var rsvpTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var eventButton: UIButton!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    let event: Event
    var currentUser: User? {
        return Store.sharedStore.user
    }
    var isAttending: Bool = false
    
    init(event: Event) {
        self.event = event
        super.init()
        //super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (event.imageUrl != nil) {
            eventImageView.urlString = event.imageUrl
        }
        //eventImageView.loadingImageView.image = #imageLiteral(resourceName: "image_placeholder")
        titleLabel.text = event.title
        descriptionTextView.text = event.eventDescription
        
        if (hasJoined()) {
            eventButton.setTitle(NSLocalizedString("Leave Event", comment: ""), for: .normal)
        } else {
            eventButton.setTitle(NSLocalizedString("Join Event", comment: ""), for: .normal)
        }
        
        rsvpTextView.text = getAttendees()
        loadingIndicator?.stopAnimating()
    }
    
    // MARK: - Actions
    @IBAction func eventButtonTapped(_ sender: UIButton) {
        if (currentUser == nil) {
            view.makeToast(NSLocalizedString("Please sign in", comment: ""), duration: 3)
            return
        }
        
        eventButton.isHidden = true
        loadingIndicator?.startAnimating()
        
        if (isAttending) {
            Store.sharedStore.leaveEvent(event: event)
            self.isAttending = false
            self.eventButton.setTitle(NSLocalizedString("Join Event", comment: ""), for: .normal)
            self.rsvpTextView.text = getAttendees()
            self.eventButton.isHidden = false
            loadingIndicator?.stopAnimating()
        } else {
            Store.sharedStore.joinEvent(event: event, completion: {(result) in
                switch result {
                case .value:
                    self.isAttending = true
                    self.eventButton.setTitle(NSLocalizedString("Leave Event", comment: ""), for: .normal)
                    self.eventButton.isHidden = false
                    self.loadingIndicator?.stopAnimating()
                    self.rsvpTextView.text = self.getAttendees()
                case .error(let e):
                    self.eventButton.isHidden = false
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
        guard let eventUsers = event.users else {
            return false
        }
        
        guard let me = currentUser else {
            return false;
        }
        
        for user in eventUsers {
            if user.id == me.id {
                return true
            }
        }
        
        return false
    }
    
    func getAttendees() -> String {
        var attendees = "Attendees: "
        
        if (event.users != nil) {
            for user in event.users! {
                attendees = attendees + user.firstName + " " + user.lastName + ", "
            }
        }
        
        guard let me = currentUser else {
            attendees.removeLast(2)
            return attendees;
        }
        
        if (isAttending) {
            attendees = attendees + me.firstName + " " + me.lastName + ", "
        } else if (!hasJoined() && isAttending) {
            attendees = attendees + me.firstName + " " + me.lastName + ", "
        }
        
        attendees.removeLast(2)
        return attendees
    }
}
