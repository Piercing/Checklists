//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Piercing on 18/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, NSCoding {
  var text = ""
  var checked = false
  var dueDate = Date()
  var shouldRemind = false
  var itemID: Int
  
  // Ahora, los métodos init son especiales en Swift.
  // Debido a que acabamos de agregar 'init? (coder)'
  // también es necesario agregar un método init () que
  // no tiene parámetros. Sin esto, la aplicación no compilará.
  override init() {
    itemID = DataModel.nextChecklistItemID()
    super.init()
  }
  
  convenience init(text: String, checked: Bool){
    self.init (text: text, checked: false)
  }
  
  // MARK: - Functions
  
  func toggleChecked() {
    checked = !checked
  }
  
  
  // MARK: - Protocol methods NSCoding
  
  /// For decoding objects
  required init?(coder aDecoder: NSCoder) {
    text = aDecoder.decodeObject(forKey: "Text") as! String
    checked = aDecoder.decodeBool(forKey: "Checked")
    dueDate = aDecoder.decodeObject(forKey: "DueDate") as! Date
    shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
    itemID = aDecoder.decodeInteger(forKey: "ItemID")
    super.init()
  }
  
  /// For encoding objects
  // Cuando 'NSKeyArchiver' intenta codificar el objeto
  //'ChecklistItem', enviará al elemento checklistItem
  // un mensaje con 'encode(with)'.
  func encode(with aCoder: NSCoder) {
    // Aquí simplemente decimos: ChecklistItem debe guardar un objeto llamado
    // "Text" que contiene el valor del texto de la variable de instancia, y
    // un objeto llamado "Checked" que contiene el valor de la variable marcada.
    // Sólo estas dos líneas son suficientes para que funcione el sistema de
    // codificación, al menos para guardar los elementos de tareas pendientes.
    aCoder.encode(text, forKey: "Text")
    aCoder.encode(checked, forKey: "Checked")
    aCoder.encode(dueDate, forKey: "DueDate")
    aCoder.encode(shouldRemind, forKey: "ShouldRemind")
    aCoder.encode(itemID, forKey: "ItemID")
  }
}






