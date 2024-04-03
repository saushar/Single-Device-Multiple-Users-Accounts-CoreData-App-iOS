//
//  EditViewController.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 03/04/24.
//

import UIKit
import CoreData

class EditViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var rollNumberTxtf: UITextField!
    @IBOutlet weak var fullnameTxtf: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    
    @IBAction func add(_ sender: UIButton) {
        let roll = self.rollNumberTxtf.text ?? ""
        let fullname = fullnameTxtf.text ?? ""
        guard !roll.isEmpty || !fullname.isEmpty else { return }
        let app = UIApplication.shared.delegate as? AppDelegate
        guard let ctx = app?.context else { return }
        let student = Student(context: ctx)
        student.roll_number = Int16(roll) ?? Int16(results().count)
        student.fullname = fullname
        try? ctx.save()
        self.tableView.reloadData()
        self.rollNumberTxtf.text = nil
        self.fullnameTxtf.text = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.results().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let data = results()[indexPath.row]
        cell.textLabel?.text = "\(data.roll_number), \(data.fullname ?? "")"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Records data"
    }
    
    var fetchRequest: NSFetchRequest<Student> {
        NSFetchRequest(entityName: "Student")
    }
    
    var ctx: NSManagedObjectContext {
        let app = UIApplication.shared.delegate as! AppDelegate
        return app.context
    }
    
    func results() -> [Student] {
        let results = try? ctx.fetch(self.fetchRequest)
        return results ?? []
    }
}
