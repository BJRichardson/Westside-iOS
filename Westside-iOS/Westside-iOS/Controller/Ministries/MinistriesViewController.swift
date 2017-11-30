import UIKit
import Forge

class MinistriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var ministries = Array<Group>()
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString(title, comment: "")
        self.tabBarItem.image = UIImage(named: "icon_calendar")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alwaysBounceVertical = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(class: MinistryCell.self)
        tableView.isHidden = true
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMinistries()
    }
    
    // MARK: - Actions
    func loadMinistries(completion: ((URLResult<Array<Group>>) -> Void)? = nil) {
        Store.sharedStore.fetchMinistries { [weak self] result in
            switch result {
            case .value(let ministries, _):
                self?.ministries = ministries
                self?.tableView?.reloadData()
                completion?(result)
            case .error(let error):
                print("Hi Bryan!\(error.localizedDescription)")
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell() as MinistryCell
        let ministry = ministries[indexPath.row]
        
        cell.nameLabel.text = ministry.name
        cell.chairPersonLabel.text = ministry.chairPerson
        
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ministries.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == ministries.count - 1) {
            loadingIndicator?.stopAnimating()
            tableView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ministry = ministries[indexPath.row]
        let ministryVC = MinistryViewController(ministry: ministry)
        
        navigationController?.pushViewController(ministryVC, animated: true)
    }
}
