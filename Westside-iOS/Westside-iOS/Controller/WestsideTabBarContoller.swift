import Foundation
import UIKit

class WestsideTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let servicesVC = TestViewController(title: "Services")
        let eventsVC = TestViewController(title: "Events")
        let announcementsVC = TestViewController(title: "Announcements")
        let prayersVC = TestViewController(title: "Prayers")
        
        viewControllers = [servicesVC, eventsVC, announcementsVC, prayersVC]
        delegate = self
        
        tabBar.barTintColor = UIColor.primaryColor()
        tabBar.tintColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let index = viewControllers?.index(of: viewController) {
            print("Selected Tab at index: \(index)")
        }
    }
}