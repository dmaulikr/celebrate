//
//  ReminderViewController.swift
//  Reminders
//
//  Created by Adam Waxman on 3/10/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import UIKit

class ReminderViewController: UIViewController {

    @IBOutlet weak var reminderTitle: UILabel!
    @IBOutlet weak var reminderSubtitle: UILabel!
    
    var reminder : Reminder!
    
    @IBOutlet weak var remainingBaseCircle: UIView!
    @IBOutlet weak var remainingOverlayCircle: UIView!
    @IBOutlet weak var reminderRemainingDays: UILabel!
    @IBOutlet weak var daysAwayText: UILabel!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialReminderValues()
    }
    
    
    
    @IBAction func callContact(sender: UIButton) {
    
        let numberString = reminder.phoneNumber
        if let number = numberString {
            dispatch_async(dispatch_get_main_queue()) {
                self.callNumber(number)
            }
        }
        
    }
    
    let messageComposer = MessageComposer()
    
    @IBAction func textContact(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {

            let numberString = self.reminder.phoneNumber
            
            // Make sure the device can send text messages
            if (self.messageComposer.canSendText()) {
                // Obtain a configured MFMessageComposeViewController
                let messageComposeVC = self.messageComposer.configuredMessageComposeViewController([numberString!])
                
                self.presentViewController(messageComposeVC, animated: true, completion: nil)
            } else {
                // Let the user know if his/her device isn't able to send text messages
                print("There was an error")
            }
        }
    }
    
    func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    func setInitialReminderValues() {
        let fullName = reminder.name!
        var fullNameArr = fullName.characters.split{$0 == " "}.map(String.init)
        let firstName = fullNameArr[0]
        reminderTitle.text =  firstName + "'s " + getEventYear(reminder.reminderDate!) + reminder.reminderType!
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        let reminderDateString = dateFormatter.stringFromDate(ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!))
        reminderSubtitle.text = reminderDateString
    
        
        let remainingDays = reminder.remainingDays
        if remainingDays == 0 {
            daysAwayText.text = "TODAY"
            reminderRemainingDays.text = "😀"
        } else if remainingDays == 1 {
            daysAwayText.text = "DAY AWAY"
            reminderRemainingDays.text = reminder.remainingDays?.stringValue
        } else {
            reminderRemainingDays.text = reminder.remainingDays?.stringValue
        }

        createReminderCircle()
        createOverlayCircle()
        styleButtons()
    }
    
    func getEventYear(reminderDate: NSDate) -> String {
        let yearOfEvent = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: reminderDate, toDate: ReminderHelper.getNextOccurenceOfReminderDate(reminderDate), options:  NSCalendarOptions(rawValue: 0)).year
        return addOrdinal(yearOfEvent)
    }
    
    func addOrdinal(yearOfEvent: Int) -> String {
        if yearOfEvent < 5 && reminder?.reminderType == "Birthday" {
            return ""
        }
        if (11...13).contains(yearOfEvent % 100) {
            return "\(yearOfEvent)th "
        }
        switch yearOfEvent % 10 {
        case 1: return "\(yearOfEvent)st "
        case 2: return "\(yearOfEvent)nd "
        case 3: return "\(yearOfEvent)rd "
        default: return "\(yearOfEvent)th "
        }
    }
    
    func styleButtons() {
        
        let fullName = reminder.name!
        var fullNameArr = fullName.characters.split{$0 == " "}.map(String.init)
        let firstName = fullNameArr[0].uppercaseString
        
        // Style call button
        callButton.layer.cornerRadius = 3
        callButton.backgroundColor = UIColor(red:0.14, green:0.81, blue:0.37, alpha:1.0)
        callButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        let callButtonTitle = "CALL " + firstName
        callButton.setTitle(callButtonTitle, forState: .Normal)
        
        // Style text button
        textButton.layer.borderColor = UIColor(red:0.14, green:0.81, blue:0.37, alpha:1.0).CGColor
        textButton.layer.borderWidth = 1
        textButton.layer.cornerRadius = 3
        let textButtonTitle = "TEXT " + firstName
        textButton.setTitle(textButtonTitle, forState: .Normal)
    }
    
    func createReminderCircle() {
        let circle = remainingBaseCircle
        circle.backgroundColor = UIColor.whiteColor()
        circle.layer.cornerRadius = circle.frame.size.width/2
        
        circle.layer.borderWidth = 4
        
        // Set color based on days remaining
        let remainingDays = reminder?.remainingDays as! Int
        switch remainingDays {
        case 0...7:
            circle.layer.borderColor = UIColor(red:0.137, green:0.812, blue:0.373, alpha:1).CGColor
        case 8...30:
            circle.layer.borderColor = UIColor(red:0.98, green:0.7, blue:0.19, alpha: 0.5).CGColor
        // case 31...90:
            // circle.layer.borderColor = UIColor(red:0.91, green:0.23, blue:0.19, alpha:0.6).CGColor
        default:
            circle.layer.borderColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:0.6).CGColor
        }
        
        if CFloat(reminder!.remainingDays!) > 99 {
            let currentFont = reminderRemainingDays.font
            let fontName = currentFont.fontName.componentsSeparatedByString("-").first
            let newFont = UIFont(name: "\(fontName!)-Thin", size: 80)
            reminderRemainingDays.font = newFont
        }
    }
    
    func createOverlayCircle() {
        let circle = remainingOverlayCircle
        circle.backgroundColor = UIColor.whiteColor()
        circle.layer.cornerRadius = circle.frame.size.width/2
    }

}