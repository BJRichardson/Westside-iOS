import UIKit
import Forge

class UsersViewController: NavigatableViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var users = Array<User>()
    
    init(title: String) {
        super.init()
        //super.init(nibName: nil, bundle: nil)
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
        tableView.register(class: UserCell.self)
        tableView.isHidden = true
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers()
    }
    
    // MARK: - Actions
    func loadUsers(completion: ((URLResult<Array<User>>) -> Void)? = nil) {
        Store.sharedStore.fetchUsers { [weak self] result in
            switch result {
            case .value(let users, _):
                self?.users = users
                self?.tableView?.reloadData()
                completion?(result)
            case .error(let error):
                print("Hi Bryan!\(error.localizedDescription)")
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell() as UserCell
        let user = users[indexPath.row]
        
        cell.userNameLabel.text = user.fullName
        
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == users.count - 1) {
            loadingIndicator?.stopAnimating()
            tableView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = users[indexPath.row]
        let userVC = UserViewController(user: user)
        
        navigationController?.pushViewController(userVC, animated: true)
    }
}
