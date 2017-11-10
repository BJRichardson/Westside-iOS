import Foundation
import UIKit

protocol LoginViewControllerDelegate: class {
    func loginDidSucceed()
    func loginDidCancel()
}

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private static let viewName = "NativeLogin"
    
    weak var delegate: LoginViewControllerDelegate?
    
    var backButton: UIBarButtonItem!
    let errorMessage = NSLocalizedString("There was an error authenticating your credentials.", comment: "")
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let backButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""),
                                         style: UIBarButtonItemStyle.plain,
                                         target: self,
                                         action: #selector(dismissView(_:)))
        backButton.tintColor = UIColor.white
        navigationItem.setLeftBarButton(backButton, animated: true)
        title = "Westside CME"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 8
        signUpButton.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.isNavigationBarHidden = false
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
        
        activityIndicator.isHidden = true
        //UIApplication.shared.statusBarStyle = .default
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return .all
        }
        
        return .allButUpsideDown
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    // MARK: IBActions
    
    @IBAction func dismissView(_ sender: AnyObject) {
        delegate?.loginDidCancel()
    }
    
    @IBAction func returnPressed(_ sender: Any) {
        if let username = usernameField.text, username.isEmpty {
            usernameField.becomeFirstResponder()
        } else if let password = passwordField.text, password.isEmpty {
            passwordField.becomeFirstResponder()
        } else {
            resignFirstResponder()
            loginPressed(sender)
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let username = usernameField.text,
            let password = passwordField.text,
            username != "",
            password != "" else { return }
        
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        
        Store.sharedStore.loginWith(username: username, password: password) { (error) in
            if let error = error {
                self.show(error: error as! TransportError)
            } else {
                self.delegate?.loginDidSucceed()
            }
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        //UIApplication.shared.openURL(forgotPasswordURL)
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        //UIApplication.shared.openURL(signUpURL)
    }
    
    private func show(error: TransportError) {
//        let alert = UIAlertController(title: NSLocalizedString("Login Failed", comment: ""), message: error.serverErrorDescription, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//        present(alert, animated: true)
    }
    
}
