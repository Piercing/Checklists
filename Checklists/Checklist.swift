//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Piercing on 18/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import UIKit

class Checklist: NSObject {
  
  var name = ""
  
  init(name: String){
    self.name = name
    super.init()
  }
}
