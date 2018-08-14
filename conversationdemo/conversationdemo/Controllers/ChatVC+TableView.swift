//
//  ChatVC+TableView.swift
//  conversationdemo
//
//  Created by Eric Giannini on 8/6/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit

extension ChatVC: UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return number of elements in collection
        return textMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // initialize an instance of UITableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        
        // check for runtime errors beyond array's index
        if indexPath.row < textMessages.count {
            let messageInfo = textMessages[indexPath.row]
            
            // configure `markAsSeen()`
            let message = (messageInfo.message ?? "") + (messageInfo.isSeen ? "(seen)" : "")
            
            // remove message
            cell.textLabel?.text = message
        }
        
        // return the cell
        return cell 
    }
    
}
