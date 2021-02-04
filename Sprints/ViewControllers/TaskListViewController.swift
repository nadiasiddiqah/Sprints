//
//  TaskListViewController.swift
//  Sprints
//
//  Created by Nadia Siddiqah on 12/30/20.
//

import Foundation
import UIKit
import CoreData

// MARK: - TimerData Class

// Custom class type to set task name/time in UITableView
public class TaskData {
    var name: String
    var time: String
    
    init(name: String, time: String) {
        self.name = name
        self.time = time
    }
}

class TaskListViewController: UIViewController {
    
    // MARK: - Outlet Variables
    @IBOutlet weak var taskList: SelfSizedTableView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var sprintButton: UIButton!
    
    // MARK: - Instance Variables
//    var context: NSManagedObjectContext!
    var savedTotalTime: Int!
    
    var taskData = [TaskData]()
    
    var taskCount: Int = 1
    var rowIndex = Int()
    
    var taskName = [Int:String]()
    var taskTime = [Int:String]()
    
    var switchToSprintButton: Bool = false
    
    var currentTimeLeftInt = Int()
    var recentTaskTimeInt = Int()
    
    // MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Define max height for table view
        taskList.maxHeight = 351
        
        // Set initial taskTime vlaue
        taskTime[0] = "Set time"
        
        // Connect table view's dataSource and delegate to current view controller
        taskList.delegate = self
        taskList.dataSource = self
        
        // Update time labels on screen
        let hour = savedTotalTime / 60 / 60
        let min = (savedTotalTime - (hour * 60 * 60)) / 60
        
        totalTimeLabel.text = String(format: "%01d:%02d", hour, min)
        timeLeftLabel.text = String(format: "%01d:%02d", hour, min)
        
        // Hide keyboard on drag and tap
        taskList.keyboardDismissMode = .onDrag
        setUpGestureRecognizer()
    }
    
    // MARK: - Navigation
    
    // Unwind from SelectTimeVC
    @IBAction func unwindFromSelectTime(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! SelectTimeViewController
        taskTime[rowIndex] = controller.selectedTaskTime
        updateTimeLeft()
        timeLeftIsZero()
        taskList.reloadRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
        print(taskTime)
    }
    
    // MARK: - Helper Methods
    
    // Set up tap gesture recongizer on screen
    func setUpGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Hides keyboard when screen is tapped
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // Checks if timeLeft is 0:00
    func timeLeftIsZero() {
        if timeLeftLabel.text == "0:00" || currentTimeLeftInt <= 900 {
            switchToSprintButton = true
            addTaskButton.setTitle("Ready, Set, Sprint!", for: .normal)
            addTaskButton.backgroundColor = UIColor(red: 0.25, green: 0.45, blue: 0.38, alpha: 1.00)
        }
    }

    func updateTimeLeft() {
        // Recent task time saved for a task
        let recentTaskTime = taskTime[rowIndex]
        
        // Check that recentTaskTime is not a String + currentTimeLeftInt is greater than 15min
        if recentTaskTime != "Set time" {
            // Convert recentTaskTime (Str) into Int
            let recentTimeComponents = recentTaskTime?.split { $0 == ":" }.map({ (x) -> Int in
                Int(String(x))!
            })

            if let components = recentTimeComponents {
               recentTaskTimeInt = (components[0] * 60 * 60) + (components[1] * 60)
            }
            
            // Convert currentTimeLeft into Int
            let currentTimeLeft = timeLeftLabel.text
            
            let currentTimeLeftComponents = currentTimeLeft?.split { $0 == ":" }.map({ (x) -> Int in
                Int(String(x))!
            })
            
            if let components = currentTimeLeftComponents {
                currentTimeLeftInt = (components[0] * 60 * 60) + (components[1] * 60)
            }
            
            // Calculate timeLeft
            let hour = (currentTimeLeftInt - recentTaskTimeInt) / 60 / 60
            let min = ((currentTimeLeftInt - recentTaskTimeInt) - (hour * 60 * 60)) / 60
            
            // Update timeLeftLabel
            timeLeftLabel.text = String(format: "%01d:%02d", hour, min)
        } else {
            timeLeftIsZero()
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func pressedAddTask(_ sender: UIButton) {
        // Adds new cell in Table View
        if switchToSprintButton == false {
            taskCount += 1
            taskTime[taskCount-1] = "Set time"
            taskList.reloadData()
            taskList.scrollToRow(at: IndexPath(row: taskCount-1, section: 0), at: .bottom, animated: true)
        } else if switchToSprintButton {
        // Switch to Sprint Button to segue to TaskRun screen
            if let controller = storyboard?.instantiateViewController(identifier: "taskRunScreen") {
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    
}

extension TaskListViewController: UITableViewDataSource {
    
    // Return the number of rows in table view
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return taskCount
    }
    
    // Return the cell to the insert in table view
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell
        
        cell.delegate = self
        
        // Configure nameField in taskCell
        cell.nameField.text = taskName[indexPath.row]
        cell.nameField.clearButtonMode = .always
        
        // Configure timeButton in taskCell
        
        cell.timeButton.setTitle(taskTime[indexPath.row], for: .normal)
        
        if cell.timeButton.currentTitle != "Set time" {
            cell.timeButton.backgroundColor = UIColor(red: 0.25, green: 0.45, blue: 0.38, alpha: 1.00)
        } else {
            cell.timeButton.setTitle("Set time", for: .normal)
            cell.timeButton.backgroundColor = UIColor.systemIndigo
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView,
//                   commit editingStyle: UITableViewCell.EditingStyle,
//                   forRowAt indexPath: IndexPath) {
//        taskName[indexPath.row] = nil
//        taskTime[indexPath.row] = nil
//
//        taskCount -= 1
//        taskList.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
//        taskList.reloadData()
//    }
    
}

extension TaskListViewController: UITableViewDelegate {
    
    // De-selects a row after its selected
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TaskListViewController: TaskCellDelegate {
    func nameFieldDidStartEditing(onCell cell: TaskCell) {
        cell.nameField.becomeFirstResponder()
    }
    
    func nameFieldDidEndEditing(onCell cell: TaskCell) {
        if let indexPath = taskList.indexPath(for: cell) {
            rowIndex = indexPath.row
            print("Task edited on row \(indexPath.row)")
        }
        taskName[rowIndex] = cell.nameField.text
        print(taskName)
        cell.nameField.resignFirstResponder()
    }
    
    func nameFieldShouldReturn(onCell cell: TaskCell) -> Bool {
        cell.nameField.resignFirstResponder()
        return true
    }
    
    func pressedTimeButton(onCell cell: TaskCell) {
        if let indexPath = taskList.indexPath(for: cell) {
            rowIndex = indexPath.row
            print("Button tapped on row \(indexPath.row)")
        }
    }

}

