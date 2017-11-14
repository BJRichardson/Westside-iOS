import UIKit

extension UIViewController {
    func displayAlert(withTitle title: String? = nil, for error: Error) {
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
