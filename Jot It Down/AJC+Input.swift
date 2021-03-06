//
//  AJC+Input.swift
//  Jot It Down
//
//  Created by Andrey Baranov on 30/03/2016.
//  Copyright © 2016 PaPaPanda. All rights reserved.
//

import UIKit


// INPUT CELL CONTROLS
extension AllJotsController:  NewJotControllerDelegate, JotInputCellDelegate {
    // MARK: JotInputCell delegate methods
    
    func jotInputCelldidUpdateTextView(cell: JotInputCell) {
        // fights jittering
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    
    // Update navigation bar and handle placeholder
    func jotInputCellIsActivated(cell: JotInputCell) {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(AllJotsController.dismissKeyboard(_:)))
        
        if cell.textView.text == cell.placeholder {
            cell.textView.textColor = UIColor.blackColor()
            cell.textView.text = ""
        }
        
        cell.tickboxSwitch.enabled = true
    }
    
    //NB: model update is handled from AJC, not JIC
    
    
    func jotAddedFromInputCell(cell: JotInputCell) {
        
        //TODO: Check for whitespace only, not absence of alphanumeric. Not good for Emojis
        // Check if there is anything except whitespace
        let alphanum = NSCharacterSet.alphanumericCharacterSet()
        
        guard let _ = cell.textView.text.rangeOfCharacterFromSet(alphanum) else {
            dismissKeyboard(self)
            return
        }
        
        // See if today's section exist, if yes — reload it, if no — refresh whole table
        if SectionBuilder.checkIfThereIsToday(jots) {
            addJotToModel(cell)
            tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        } else {
            addJotToModel(cell)
            tableView.reloadData()
        }
        
        //Height shrinking after multi-line input would be broken if order is changed
        cell.makePlaceholder()
        dismissKeyboard(self)
        
        
        
        
    }
    
    func addJotToModel(cell: JotInputCell) {
        let jot = Jot(string: cell.textView.text, title: nil)
        jot.tagColor = cell.colorSelector
        
        if cell.tickboxSwitch.on {
            jot.type = .Checkmark
            cell.tickboxSwitch.setOn(false, animated: true)
        }
        
        if sectionedJots.isEmpty {
            jots.append(jot)
            tableView.reloadData()
            return
        }
        sectionedJots[0].insert(jot, atIndex: 0)
        jots = sectionedJots.flatMap { $0 }
        

    }
    
    func dismissKeyboard(sender: AnyObject) {
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? JotInputCell
        {
            drawSearchButton()
            self.navigationItem.rightBarButtonItem = editButtonItem()
            
            cell.endEditing(true)
            
            if sender is UIBarButtonItem {
                cell.makePlaceholder()
            }
            
            cell.tickboxSwitch.setOn(false, animated: true)
            cell.tickboxSwitch.enabled = false
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
    }
    
    // MARK: NewJotController delegate methods
    
    func newJotController(contoller: NewJotController, didFinishAddingJot jot: Jot) {
        jots.insert(jot, atIndex: 0)
        // refresh table
        tableView.reloadData()
    }
}
