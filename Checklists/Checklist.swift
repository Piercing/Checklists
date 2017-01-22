//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Piercing on 18/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import UIKit

// Añado NSCoding para la codificación de los
// objetos y poder guardarlos en el dispositivo
// y luego poder decodificarlos para leerlos.
class Checklist: NSObject, NSCoding {
  
  var name = ""
  var items: [ChecklistItem] = []
  
  init(name: String){
    self.name = name
    super.init()
  }
  
  // MARK: - Protocol methods NSCoding
  
  /// For decoding objects
  required init?(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObject(forKey: "Name") as! String
    items = aDecoder.decodeObject(forKey: "Items") as! [ChecklistItem]
    super.init()
  }
  
  /// For encoding objects
  func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: "Name")
    aCoder.encode(items, forKey: "Items")
  }
}
