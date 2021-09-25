//
//  ViewController.swift
//  ParkingBuddy
//
//  Created by Norbert Nagy on 2021. 09. 11..
//

import UIKit

let TITLE_NAME = "My parking spots"
let CELL_IDENTIFIER: String = "cell"
let MAP_CONTROLLER_IDENTIFIER = "map"
let NAVIGATE_CONTROLLER_IDENTIFIER = "navigate"

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.rowHeight = 100
        table.register(UITableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        
        return table
    }()
    
    private var spots = [ParkingSpot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = TITLE_NAME
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        getAllParkingSpots()
    }
    
    @objc private func didTapAdd() {
        let mapViewController = storyboard?.instantiateViewController(identifier: MAP_CONTROLLER_IDENTIFIER) as! MapViewController
        mapViewController.delegate = self
        mapViewController.modalPresentationStyle = .fullScreen
        self.present(mapViewController, animated: true)
    }

    func getAllParkingSpots() {
        do {
            spots = try context?.fetch(ParkingSpot.fetchRequest()) as! [ParkingSpot]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            
        }
    }
    
    func createParkingSpot(parkingSpot: ParkingSpotData) {
        let newParkingSpot = ParkingSpot(context: context!)
        newParkingSpot.address = parkingSpot.address
        newParkingSpot.details = parkingSpot.details
        newParkingSpot.date = parkingSpot.date
        newParkingSpot.rawLocation = parkingSpot.rawLocation
        do {
            try context?.save()
            getAllParkingSpots()
        } catch {
            
        }
    }
    
    func deleteParkingSpot(parkingSpot: ParkingSpot) {
        context?.delete(parkingSpot)
        do {
            try context?.save()
            getAllParkingSpots()
        } catch {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spot = spots[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath)
        cell.textLabel?.text = spot.address
        cell.textLabel?.font = UIFont(name:"Avenir", size:22)
        cell.detailTextLabel?.text = spot.details
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navigateViewController = storyboard?.instantiateViewController(identifier: NAVIGATE_CONTROLLER_IDENTIFIER) as! NavigateViewController
        navigateViewController.delegate = self
        navigateViewController.indexPath = indexPath
        navigateViewController.setLocation(rawLocation: spots[indexPath.row].rawLocation!)
        navigateViewController.modalPresentationStyle = .fullScreen
        present(navigateViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteParkingSpot(parkingSpot: spots[indexPath.row])
        }
    }
    
}

extension ViewController : AddLocationDelegate {
    func addLocation(parkingSpotData: ParkingSpotData) {
        self.dismiss(animated: true) {
            self.createParkingSpot(parkingSpot: parkingSpotData)
        }
    }
}

extension ViewController : RemoveLocationDelegate {
    func removeLocation(_ indexPath: IndexPath) {
        deleteParkingSpot(parkingSpot: spots[indexPath.row])
    }
}
