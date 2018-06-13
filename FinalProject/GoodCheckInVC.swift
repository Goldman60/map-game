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
    var metaPlaceUser: MetaPlaceUser?

    @IBOutlet weak var lastCheckInLabel: UILabel!
    @IBOutlet weak var totalCheckInCount: UILabel!
    
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
    
    @IBAction func doCheckIn(_ sender: UIButton) {
        let oneHour = Calendar.current.date(
            byAdding: .hour,
            value: -1,
            to: Date())
        
        if metaPlaceUser!.lastCheckIn!.timeIntervalSince(oneHour!) > 0 {
            let dialog = UIAlertController(title: "Too Soon", message: "You checked in here recently! Wait \(String(format: "%.0f", metaPlaceUser!.lastCheckIn!.timeIntervalSinceNow + 3600)) seconds", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Try Again Later", style: .cancel, handler: nil)
            dialog.addAction(action)
            
            present(dialog, animated: true, completion: nil)
        }
        else {
            performSegue(withIdentifier: "doCheckInSegue", sender: self)
        }
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
