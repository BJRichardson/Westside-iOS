import Foundation
import UIKit

protocol RegisterViewControllerDelegate: class {
    func registrationDidSucceed()
    func registrationDidCancel()
}

class RegisterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: FloatingTextField!
    @IBOutlet weak var passwordTextField: FloatingTextField!
    @IBOutlet weak var confirmPasswordTextField: FloatingTextField!
    @IBOutlet weak var firstNameTextField: FloatingTextField!
    @IBOutlet weak var lastNameTextField: FloatingTextField!
    @IBOutlet weak var phoneTextField: FloatingTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    weak var delegate: RegisterViewControllerDelegate?
    
    var textFields: Array<FloatingTextField> {
        return [phoneTextField, emailTextField, passwordTextField, confirmPasswordTextField, firstNameTextField, lastNameTextField]
    }
    
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
        
        signInButton.layer.cornerRadius = 8
        
        textFields.forEach { textField in
            textField.floatingLabelPadding.top = 4
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.isNavigationBarHidden = false
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
        
        loadingIndicator.isHidden = true
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: IBActions
    
    @IBAction func dismissView(_ sender: AnyObject) {
        delegate?.registrationDidCancel()
    }
    
    @IBAction func phoneTextChanged(_ sender: UITextField) {
        guard var text = sender.text?.numericText else {
            sender.text = nil
            return
        }
        
        if text.count > 10 {
            text = text.substring(to: 10)
        }
        
        if text.count > 3 {
            text.insert("-", at: 3)
        }
        if text.count > 7 {
            text.insert("-", at: 7)
        }
        
        sender.text = text
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        do {
            let values = try inputValues()
            loadingIndicator.startAnimating()
            signInButton.isEnabled = false
            
            Store.sharedStore.registerWith(username: values.email, password: values.password, phone: values.phoneNumber, firstName: values.firstName, lastName: values.lastName) { (error) in
                if let error = error {
                    self.loadingIndicator.stopAnimating()
                    self.signInButton.isEnabled = true
                    self.show(error: error as! TransportError)
                } else {
                    self.delegate?.registrationDidSucceed()
                }
            }
        } catch {
            self.displayAlert(for: error)
        }
    }
    
    private func inputValues() throws -> (phoneNumber: String, email: String, password: String, firstName: String, lastName: String) {
        let email = try validateEmailText()
        let password = try validPasswordText()
        let firstName = try validateFirstNameText()
        let lastName = try validateLastNameText()
        let phoneNumber = try validatePhoneText()
        return (phoneNumber, email, password, firstName, lastName)
    }
    
    private func validatePhoneText() throws -> String {
        guard let numericText = phoneTextField.text?.numericText, numericText.count == 10 else {
            throw InputError.invalidPhoneNumber
        }
        
        return numericText
    }
    
    private func validateEmailText() throws -> String {
        guard let email = emailTextField.text, email.count > 0 else {
            throw InputError.invalidEmail
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        
        guard
            let emailRange = email.range(of: emailRegex, options: .regularExpression),
            email.distance(from: emailRange.lowerBound, to: emailRange.upperBound) == email.count
            else {
                throw InputError.invalidEmail
        }
        
        return email
    }
    
    private func validPasswordText() throws -> String {
        guard let password = passwordTextField.text, password.count > 5 else {
            throw InputError.invalidPassword
        }
        
        guard password == confirmPasswordTextField.text else {
            throw InputError.passwordsDontMatch
        }
        
        return password
    }
    
    private func validateFirstNameText() throws -> String {
        guard let nameText = firstNameTextField.text, nameText.count > 0 else {
            throw InputError.invalidFirstName
        }
        
        return nameText
    }
    
    private func validateLastNameText() throws -> String {
        guard let nameText = lastNameTextField.text, nameText.count > 0 else {
            throw InputError.invalidLastName
        }
        
        return nameText
    }
    
    // MARK: - InputError
    enum InputError: LocalizedError {
        case invalidFirstName
        case invalidLastName
        case invalidPhoneNumber
        case invalidEmail
        case invalidPassword
        case passwordsDontMatch
        
        var errorDescription: String? {
            switch self {
            case .invalidFirstName:
                return NSLocalizedString("First Name is Empty", comment: "")
            case .invalidLastName:
                return NSLocalizedString("Last Name is Empty", comment: "")
            case .invalidPhoneNumber:
                return NSLocalizedString("Invalid Phone Number", comment: "")
            case .invalidEmail:
                return NSLocalizedString("Invalid Email Address", comment: "")
            case .invalidPassword:
                return NSLocalizedString("Password must be at least 6 characters long", comment: "")
            case .passwordsDontMatch:
                return NSLocalizedString("Passwords do not match", comment: "")
            }
        }
    }
    
    private func show(error: TransportError) {
            let alert = UIAlertController(title: NSLocalizedString("Login Failed", comment: ""), message: error.errorDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(alert, animated: true)
    }
}
