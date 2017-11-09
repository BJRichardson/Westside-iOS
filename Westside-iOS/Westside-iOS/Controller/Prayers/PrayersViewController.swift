import UIKit

class PrayersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var prayers = Array<Prayer>()
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString(title, comment: "")
        self.tabBarItem.image = UIImage(named: "icon_prayer")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alwaysBounceVertical = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(class: PrayerCell.self)
        tableView.isHidden = true
    }
    
    // MARK: - Actions
    func loadPrayers(completion: ((URLResult<Array<Prayer>>) -> Void)? = nil) {
        Store.sharedStore.fetchPrayers { [weak self] result in
            switch result {
            case .value(let prayers, _):
                self?.prayers = prayers
                self?.tableView?.reloadData()
                completion?(result)
            case .error(let error):
                print("Hi Bryan!\(error.localizedDescription)")
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell() as PrayerCell
        let prayer = prayers[indexPath.row]
        
        cell.prayer.text = prayer.prayer
        cell.poster.text = prayer.posterString
        cell.postedDate.text = prayer.dateString
        
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prayers.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == prayers.count - 1) {
            loadingIndicator?.stopAnimating()
            tableView.isHidden = false
        }
    }
}
