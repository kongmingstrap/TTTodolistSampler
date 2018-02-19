//
//  TodoEditViewController.swift
//  TTTodolistSample
//

import UIKit

class TodoEditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputTextField: UITextField!
    var doneTextClosure: ((String) -> Void)?
    
    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        self.navigationItem.leftBarButtonItem = cancelButton
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
        doneButton.enabled = false
        self.navigationItem.rightBarButtonItem = doneButton
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "textFieldTextChanged:", name:UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldTextChanged(notification: NSNotification) {
        if let text = self.inputTextField.text {
            if text.utf16.count > 0 {
                self.navigationItem.rightBarButtonItem?.enabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
        }
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
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return false
    }
}