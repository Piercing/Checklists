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
  
  // MARK: - Functions
  
//  func countUncheckedItems() -> Int {
//    var count = 0
//    for item in items where !item.checked {
//      count += 1
//    }
//    return count
//  }
  // Igual que la anterior, pero en lo que se llama programación funcional, 
  // con expresiones matemáticas en funciones, de ahí que se llame funcional.
  func countUncheckedItems() -> Int {
    
    // 'Reduce ()' es un método que mira cada elemento y realiza el código en el bloque {}. 
    // Inicialmente, la variable cnt contiene el valor 0, pero después de cada elemento se 
    // incrementa por 0 o 1, dependiendo de si el elemento se ha comprobado. Cuando 'reduce()'
    // se hace, su valor de retorno es el recuento total de elementos que no están marcados.
    return items.reduce(0) { cnt, item in cnt + (item.checked ? 0 : 1) }
  }
  
}
