//
//  TabBarController.swift
//  Levy
//
//  Created by Praveenraj T on 08/03/22.
//

import UIKit

class MyTabBarController: UITabBarController {

    let friendsVC:FriendsWiseExpViewController = {
        let vc = FriendsWiseExpViewController()
        vc.title = "Friends"
        vc.tabBarItem = UITabBarItem(title: "Friends", image: UIImage(systemName: "person.fill"), tag: 1)
        
        return vc
    }()
    
    lazy var friendsNC:UINavigationController = {
        
        let navController = UINavigationController(rootViewController: friendsVC)
        navController.navigationBar.alpha = 1
        navController.navigationBar.isOpaque = true
        navController.navigationBar.tintColor = .white
        navController.navigationBar.barTintColor = .white
        return navController
    }()
    
    let groupVC:GroupListViewController = {
        let vc = GroupListViewController()
        vc.title = "Groups"
        vc.tabBarItem = UITabBarItem(title: "Groups", image: UIImage(systemName: "person.3.fill"), tag: 1)
        
        return vc
    }()
    
    lazy var groupNC:UINavigationController={
        let navController = UINavigationController(rootViewController: self.groupVC)
        navController.navigationBar.alpha = 1
        navController.navigationBar.tintColor = .white
        navController.navigationBar.barTintColor = .white
        return navController
    }()
    
    lazy var tripListVC : TripListViewController = {
        let vc = TripListViewController(presenter: TripListPresenter())
        if #available(iOS 15, *){
            vc.tabBarItem = UITabBarItem(title: "Trips", image: UIImage(systemName: "airplane.departure"), tag: 1)
        }else{
            vc.tabBarItem = UITabBarItem(title: "Trips", image: UIImage(systemName: "paperplane"), tag: 1)
        }
        return vc

    }()
    
    private lazy var tripListNC:UINavigationController = {
        let navController = UINavigationController(rootViewController: self.tripListVC)
        navController.navigationBar.alpha = 1
        navController.navigationBar.tintColor = .white
        navController.navigationBar.barTintColor = .white
        
        return navController
    }()
    
    
    let tabbarAppearance = UITabBarAppearance()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setViewControllers([tripListNC,friendsNC,groupNC], animated: true)
        tabbarAppearance.backgroundColor = .systemBackground

        tabBar.isTranslucent = false
        tabBar.standardAppearance = tabbarAppearance
        tabBar.backgroundColor = .systemBackground
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabbarAppearance
        } 
        configureTabbarBackgroud()
    }
    
    func configureTabbarBackgroud(){
    
        let navAppearence = UINavigationBarAppearance()
        navAppearence.configureWithOpaqueBackground()
        navAppearence.backgroundColor = myThemeColor
        navAppearence.titleTextAttributes = [.foregroundColor:UIColor.white]
        

        tripListNC.navigationBar.compactAppearance = navAppearence
        tripListNC.navigationBar.scrollEdgeAppearance = navAppearence
        tripListNC.navigationBar.standardAppearance = navAppearence
        
        groupNC.navigationBar.compactAppearance = navAppearence
        groupNC.navigationBar.scrollEdgeAppearance = navAppearence
        groupNC.navigationBar.standardAppearance = navAppearence
        
        friendsNC.navigationBar.compactAppearance = navAppearence
        friendsNC.navigationBar.scrollEdgeAppearance = navAppearence
        friendsNC.navigationBar.standardAppearance = navAppearence
        
        
    }
   

}
extension MyTabBarController{
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.title == "Friends"{
            friendsVC.bringDataForUI()
            friendsNC.bringDataForUI()
            for vc in friendsNC.viewControllers{
                vc.bringDataForUI()
            }
        }
        
        if item.title == "Trips"{
            tripListNC.viewDidLoad()
            for vc in tripListNC.viewControllers{
                vc.bringDataForUI()
            }
        }
        if item.title == "Groups"{
            groupNC.bringDataForUI()
            for vc in groupNC.viewControllers{
                vc.bringDataForUI()
            }
        }
    }
}

