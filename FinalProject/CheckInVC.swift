//
//  CheckInVC.swift
//  FinalProject
//
//  Created by AJ Fite on 5/20/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit

class CheckInVC: UIViewController {
    
    var destPlace: Place?

    @IBOutlet weak var bottomHalfView: UIView!
    
    private let topStackView = UIStackView()
    fileprivate lazy var goodCheckInVC: GoodCheckInVC = buildFromStoryboard("Main")
    fileprivate lazy var badCheckInVC: BadCheckInVC = buildFromStoryboard("Main")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup child views for bottom
        addChildViewController(goodCheckInVC)
        addChildViewController(badCheckInVC)
        
        bottomHalfView.addSubview(goodCheckInVC.view)
        bottomHalfView.addSubview(badCheckInVC.view)
        
        goodCheckInVC.didMove(toParentViewController: self)
        badCheckInVC.didMove(toParentViewController: self)

        bottomHalfView.bringSubview(toFront: goodCheckInVC.view)
        //TODO: User distance
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func buildFromStoryboard<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: T.self)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Missing \(identifier) in Storyboard")
        }
        return viewController
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
