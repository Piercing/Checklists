//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Piercing on 17/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject, NSCoding {
  var text = ""
  var checked = false
  
  // Ahora, los métodos init son especiales en Swift.
  // Debido a que acabamos de agregar 'init? (coder)'
  // también es necesario agregar un método init () que
  // no tiene parámetros. Sin esto, la aplicación no compilará.
  override init() {
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    text = aDecoder.decodeObject(forKey: "Text") as! String
    checked = aDecoder.decodeBool(forKey: "Checked")
    super.init()
  }
  
  func toggleChecked() {
    checked = !checked
  }
  
  // Cuando 'NSKeyArchiver' intenta codificar el objeto
  //'ChecklistItem', enviará al elemento checklistItem
  // un mensaje con 'encode(with)'.
  func encode(with aCoder: NSCoder) {
    // Aquí simplemente dices: ChecklistItem debe guardar un objeto llamado
    // "Text" que contiene el valor del texto de la variable de instancia, y
    // un objeto llamado "Checked" que contiene el valor de la variable marcada.
    // Sólo estas dos líneas son suficientes para que funcione el sistema de
    // codificación, al menos para guardar los elementos de tareas pendientes.
    aCoder.encode(text, forKey: "Text")
    aCoder.encode(checked, forKey: "Checked")
  }
}
