//
//  TodoEditViewController.swift
//  TTTodolistSample
//

import UIKit

class TodoEditViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    var doneTextClosure: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        self.navigationItem.leftBarButtonItem = cancelButton
        let addButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {
            if let text = self.inputTextField.text {
                self.doneTextClosure!(text)
            }
        })
    }
}