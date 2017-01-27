//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Piercing on 18/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import Foundation
import UserNotifications

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
  
//  convenience init(text: String, checked: Bool){
//    self.init (text: text, checked: false)
//  }
  
  // Se invocará cuando elimine un ChecklistItem individual, pero también cuando elimine una Checklist completa,
  // ya que todos sus 'ChecklistItems' se destruirán también, ya que el array en la que están se desasigna.
  deinit {
    removeNotification()
  }
  
  // MARK: - Functions
  
  func toggleChecked() {
    checked = !checked
  }
  
  func scheduleNotification() {
    
    removeNotification()
    
    // Esto compara Due Date con la fecha actual. Siempre puede obtener la hora actual creando un nuevo objeto Date con new Date().
    // La declaración dueDate > Date() compara las dos fechas y devuelve true si dueDate es en el futuro y false si es en el pasado.
    // Si 'Due Date' es anterior, no se realizará print().
    if shouldRemind && dueDate > Date() {
      // 1.-  Coloque el texto del elemento en el mensaje de notificación.
      let content = UNMutableNotificationContent()
      content.title = "Reminder:"
      content.body = text
      content.sound = UNNotificationSound.default()
      // 2.- Extraiga el mes, día, hora y minuto de la fecha de vencimiento. No nos importa el año o el número de segundos
      // - la notificación no necesita ser programada con precisión milisegundo, en el minuto es lo suficientemente preciso.
      let calendar = Calendar(identifier: .gregorian)
      let components = calendar.dateComponents(
        [.month, .day, .hour, .minute], from: dueDate)
      // 3. Para probar las notificaciones locales que utilizó un UNTimeIntervalNotificationTrigger,
      // que programó la notificación para que aparezca después de un número de segundos. Aquí, está
      // utilizando un UNCalendarNotificationTrigger, que muestra la notificación en la fecha especificada.
      let trigger = UNCalendarNotificationTrigger(
        dateMatching: components, repeats: false)
      // 4.- Cree el objeto UNNotificationRequest. Importante aquí es que convertimos el ID numérico del
      // artículo en una cadena y lo usamos para identificar la notificación. Así es como podrá encontrar
      // esta notificación más tarde si necesita cancelarla.
      let request = UNNotificationRequest(
        identifier: "\(itemID)", content: content, trigger: trigger)
      // 5.- Agregue la nueva notificación al UNUserNotificationCenter. Xcode no está tan impresionado con
      // este nuevo código y le da un montón de mensajes de error.
      let center = UNUserNotificationCenter.current()
      center.add(request)
      
      print("Scheduled notification \(request) for itemID \(itemID)")
    }
  }
  
  // Cuando el usuario edita un elemento, pueden ocurrir las siguientes situaciones:
  // • Me recuerda que estaba apagado y ahora está encendido. Tienes que programar una nueva notificación.
  // • Me recuerda que estaba encendido y ahora está apagado. Debe cancelar la notificación existente.
  // • Me recuerda que permanece encendido pero cambia la fecha de vencimiento. Debe cancelar la notificación
  //   existente y programar una nueva.
  // • Recordarme permanece encendido, pero la fecha de vencimiento no cambia. No es necesario hacer nada.
  // • Me recuerda permanece apagado. Aquí también no tienes que hacer nada.
  
  // Siempre es una buena idea hacer un balance de todos los posibles escenarios antes de empezar a programar porque esto le da una
  // imagen clara de todo lo que necesita abordar. Puede parecer que usted necesita para escribir una gran cantidad de lógica aquí
  // para hacer frente a todas estas situaciones, pero en realidad resulta ser bastante simple. En primer lugar, buscará si hay una
  // notificación existente para este elemento de tarea pendiente. Si lo hay, simplemente lo cancela. A continuación, determina si el
  // elemento debe tener una notificación y, si es así, programar una nueva. Que debe hacerse cargo de todas las situaciones anteriores,
  // incluso si a veces simplemente podría haber dejado la notificación existente por sí solo.
  func removeNotification() {
    
    // Esto elimina la notificación local para este ChecklistItem, si existe. Tenga en cuenta que removePendingNotificationRequests ()
    // requiere una matriz de identificadores, por lo que primero poner nuestro itemID en una cadena con \ (...) y luego en una matriz
    // utilizando [].
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests( withIdentifiers: ["\(itemID)"])
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






