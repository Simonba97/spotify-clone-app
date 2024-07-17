//
//  TabBarViewController.swift
//  SpotifyClone
//
//  Created by Simón Bustamante Alzate on 17/07/24.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Instanciamos los ViewController
        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = LibraryViewController()
        
        // Agregamos para que cada VC tenga un título
        vc1.title = "Browse"
        vc2.title = "Search"
        vc3.title = "Library"
                
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always
        
        // Configuración de las pestañas
        let nav1  = UINavigationController(rootViewController: vc1)
        let nav2  = UINavigationController(rootViewController: vc2)
        let nav3  = UINavigationController(rootViewController: vc3)
        
        // Agregamos iconos a nuestas pestañas
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Libray", image: UIImage(systemName: "music.note.list"), tag: 3)

        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        setViewControllers([nav1, nav2, nav3], animated: false)

        


        
    }

}
