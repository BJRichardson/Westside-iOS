import UIKit

class AnnouncementsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var announcements = Array<Announcement>()
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString(title, comment: "")
        self.tabBarItem.image = UIImage(named: "icon_announcements")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alwaysBounceVertical = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(class: AnnouncementCell.self)
        tableView.isHidden = true
    }
    
    // MARK: - Actions
    func loadAnnouncements(completion: ((URLResult<Array<Announcement>>) -> Void)? = nil) {
        Store.sharedStore.fetchAnnouncements { [weak self] result in
            switch result {
            case .value(let announcements, _):
                self?.announcements = announcements
                self?.tableView?.reloadData()
                completion?(result)
            case .error(let error):
                print("Hi Bryan!\(error.localizedDescription)")
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell() as AnnouncementCell
        let announcement = announcements[indexPath.row]
        
        cell.announcement.text = announcement.announcement
        cell.poster.text = announcement.posterString
        cell.postedDate.text = announcement.dateString
        
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == announcements.count - 1) {
            loadingIndicator?.stopAnimating()
            tableView.isHidden = false
        }
    }
}
