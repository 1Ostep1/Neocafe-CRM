//
//  BaseViewController.swift
//  ClientApp
//
//  Created by Рамазан Юсупов on 7/11/21.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
 
    private func setUp() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backgroundColor = Asset.clientBackround.color
        navigationController?.navigationBar.barTintColor =  Asset.clientBackround.color
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = Asset.clientBackround.color
    }
}
