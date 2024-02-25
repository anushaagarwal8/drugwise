//
//  TitleViewController.swift
//  DrugWise
//
//  Created by Anusha Agarwal on 2/24/24.
//

import Foundation
import UIKit

class TitleViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup title page UI
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "DrugWise"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Delay transition to the main page
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.navigateToMainPage()
        }
    }
    
    func navigateToMainPage() {
        if let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            navigationController?.pushViewController(mainViewController, animated: true)
        }
    }
}

