//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by Piercing on 17/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import Foundation

class DataModel {
  
  var lists = [Checklist]()
  
  // Propiedad calculada. No hay ningún almacenamiento asignado
  // para esta propiedad (por lo que no es realmente una variable).
  
  // Cuando la aplicación intenta leer el valor de indexOfSelectedChecklist, se realiza el código del bloque 'get'.
  // Y cuando la aplicación intenta poner un nuevo valor en 'indexOfSelectedChecklist', se realiza el bloque 'set'.
  // A partir de ahora, al utilizar 'indexOfSelectedChecklist' actualizará automáticamente 'UserDefaults'.
  // Hacemos esto para que el resto del código no tenga que preocuparse más por 'UserDefaults'. Los otros objetos
  // sólo tienen que usar la propiedad 'indexOfSelectedChecklist' de 'DataModel'. Ocultar detalles de la implementación
  // es un importante principio de programación orientado a objetos, y esta es una forma de hacerlo. Si decide más tarde
  // que desea almacenar estas configuraciones en otro lugar, por ejemplo en una base de datos o en iCloud, sólo tendrá
  // que cambiarlo en un lugar, en DataModel. El resto del código será ajeno a estos cambios y eso es algo bueno.
  var indexOfSelectedChecklist: Int {
    get { return UserDefaults.standard.integer(forKey: "ChecklistIndex") }
    set { UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
      UserDefaults.standard.synchronize()
    }
  }
  
  // Esto asegura que tan pronto como se crea el objeto 'DataModel', intentará
  // cargar 'Checklist.plist'. NO tenemos que llamar a 'super.init()',  porque
  // 'DataModel' no tiene una superclase,(no se basa en 'NSObject).
  init() {
    loadChecklists()
    registerDefaults()
    handleFirstTime()
  }
  
  // MARK: - Data Persistence.
  
  func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("Checklists.plist")
  }
  
  /// CODIFICAR EL ARRAY ChecklistItems para guardarlo en 'Checklist.plist'.
  //// Siempre que modifiquemos la lista de elementos debemos de llamar a éste método.
  // This method is now called saveChecklists()
  func saveChecklists() {
    
    // Es una forma de NSCoder de crear archivos 'plist'.
    // Codifica el array y todos los archivos 'ChecklistItems'
    // en él, en algún tipo de formato de datos binarios que
    // se pueden escribir en un archivo.
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: data)
    
    // Codifico los objetos de 'lists' con clave 'Checklists'
    archiver.encode(lists, forKey: "Checklists")
    archiver.finishEncoding()
    // Los datos se colocan en un objeto' NSMutableData', que se escribirá
    // en el archivo especificado por el método de más arriba 'dataFilePath'.
    data.write(to: dataFilePath(), atomically: true)
  }
  
  /// DECODIFICAR EL ARRAY ChecklistItems para leerlo de 'Checklist.plist'
  // This method is now called loadChecklists()
  func loadChecklists() {
    
    // 1.- Obtengo la ruta.
    let path = dataFilePath()
    // 2.- Intento cargar el contenido de 'Checklist.plist' en un objeto Data.
    if let data = try? Data(contentsOf: path) {
      // 3.- Cuando la aplicación encuentre un archivo 'Checklist.plist'
      // cargará todo el array con las copias exactas de 'Checklist'.
      let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
      
      lists = unarchiver.decodeObject(forKey: "Checklists") as! [Checklist]
      unarchiver.finishDecoding()
    }
  }
  
  // MARK: - Functions
  
  // Esto crea una nueva instancia de diccionario y
  // añade el valor -1 para la clave "ChecklistIndex" y no se bloquee la aplicación al hacer una nueva instalación ya que
  // toma como índice el valor cero, y este es un valor válido para cualquier array, de ahí que arranquemos con -1.
  func registerDefaults() {
    let dictionary: [String: Any] = [ "ChecklistIndex": -1, "FirstTime": true ]
    UserDefaults.standard.register(defaults: dictionary)
  }
  
  func handleFirstTime() {
    
    let userDefaults = UserDefaults.standard
    let firstTime = userDefaults.bool(forKey: "FirstTime")
    
    // Aquí verifica UserDefaults para el valor de la clave "FirstTime".
    // Si el valor de "FirstTime" es verdadero, esta es la primera vez
    // que se ejecuta la aplicación. En ese caso, se crea un nuevo objeto
    // de lista de verificación y se agrega a la matriz.
    if firstTime {
      let checklist = Checklist(name: "List")
      lists.append(checklist)
      
      // También establece 'indexOfSelectedChecklist' en 0, que es el índice
      // de este objeto de lista de comprobación recién agregado, para asegurarse
      // de que la aplicación se traslade automáticamente a la nueva lista en
      // 'ViewDidAppear ()' de 'AllListsViewController'.
      indexOfSelectedChecklist = 0
      userDefaults.set(false, forKey: "FirstTime")
      userDefaults.synchronize()
    }
  }
  
}











