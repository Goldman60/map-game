//
//  GoodCheckInVC.swift
//  FinalProject
//
//  Created by AJ Fite on 5/21/18.
//  Copyright © 2018 AJ Fite. All rights reserved.
//

import UIKit

class GoodCheckInVC: UIViewController {
    
    var destPlace: Place?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFromSave(segue:UIStoryboardSegue) {
    }
    
    @IBAction func unwindFromCancel(segue:UIStoryboardSegue) {
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doCheckInSegue" {
            let destVC = segue.destination as? DoCheckInVC
            destVC?.checkInPlaceID = destPlace?.key
        }
    }

}
