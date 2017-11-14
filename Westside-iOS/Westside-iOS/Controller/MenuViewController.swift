import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var menusTableView: UITableView!
    
    var menuItems: Array<Menu> = []
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menusTableView.register(class: MenuCell.self)
        navigationController?.navigationBar.isHidden = true
        
        menuItems.append(Menu(title: "Login", destination: nil, content: .action(.login)))
        menuItems.append(Menu(title: "Create Account", destination: nil, content: .action(.register)))
        
//        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: reachabilityChangedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (Store.sharedStore.isUserLoggedIn) {
            menuItems = Store.sharedStore.authedMenus
        } else {
            menuItems = Store.sharedStore.unauthedMenus
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell() as MenuCell
        let menu = menuItems[indexPath.row]

        cell.menuLabel.text = menu.title
        
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = menuItems[indexPath.row]
        
        containerViewController?.displayContent(content: menu.content, title: menu.title, destination: menu.destination)
    }
}
