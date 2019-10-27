//
//  CameraViewController.swift
//  MapApp
//
//  Created by William Wilson on 10/25/19.
//  Copyright © 2019 William Wilson. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var gasStationsForTable = [GasStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Info"
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    func viewWillAppear(){
        

       
    }
    override func viewDidAppear(_ animated: Bool) {
       
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return gasStationsForTable.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! //1.
        let text = gasStationsForTable[indexPath.row].prices.map({"\($0)"}).joined(separator:", ")
            
         cell.textLabel?.text = text //3.
            
         return cell //4.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
