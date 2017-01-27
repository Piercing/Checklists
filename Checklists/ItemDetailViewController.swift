//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Piercing on 18/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

protocol ItemDetailViewControllerDelegate: class {
  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate {
  
  // MARK: - Global variables.
  
  weak var delegate: ItemDetailViewControllerDelegate?
  var itemToEdit: ChecklistItem?
  
  /// Nota: Tal vez se esté preguntando por qué está utilizando una variable de instancia para el dueDate pero no para shouldRemind.
  /// Usted no necesita uno para shouldRemind porque es fácil obtener el estado del control del interruptor: simplemente mira su
  /// propiedad isOn, que es verdadera o falsa. Sin embargo, es difícil leer la fecha elegida de nuevo de la etiqueta dueDateLabel
  /// porque la etiqueta almacena el texto (una cadena), no una fecha. Por lo tanto, es más fácil realizar un seguimiento de la fecha
  /// elegida por separado en una variable de instancia de fecha.
  var dueDate = Date()
  var datePickerVisible = false // Controla si el selector de fechas está visible.
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  @IBOutlet weak var shouldRemindSwitch: UISwitch!
  @IBOutlet weak var dueDateLabel: UILabel!
  @IBOutlet weak var datePickerCell: UITableViewCell!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  // MARK: - Lifecycle
  
  // Se llama antes de que se muestre la pantalla.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let item = itemToEdit {
      // Cuando 'itemToEdit' contenga algo, cambia el título de
      // la barra de navegación por 'Edit Item' en vez de'Add Item'
      // ya que estamos reaprovechando el mismo controlador para las dos cosas.
      title = "Edit Item"// Es una propiedad integrada del propio controlador, por eso no está definida 'title'
      // Establece también el texto en el textView.
      textField.text = item.text
      doneBarButton.isEnabled = true
      
      // Si ya existe un objeto ChecklistItem existente, establezca el control de conmutador en activado o desactivado,
      // dependiendo del valor de la propiedad shouldRemind del objeto. Si el usuario está agregando un nuevo elemento,
      // el interruptor está inicialmente desactivado (en el storyboard). También obtiene la fecha de vencimiento del ChecklistItem.
      shouldRemindSwitch.isOn = item.shouldRemind
      dueDate = item.dueDate
    }
    
    updateDueDateLabel()
  }
  
  // El controlador recibe este mensaje justo antes de que se haga visible.
  // Momento perfecto para activar el campo de texto enviando el mensaje
  // 'becomeFirstResponder' y active teclado automática/ al abrirse el controlador.
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }
  
  // MARK: - Functions
  
  // Para convertir el valor de fecha en texto, utilice el objeto  DateFormatter.
  // La forma en que funciona es muy sencillo: le da un estilo para el componente
  // de fecha y un estilo independiente para el componente de tiempo y, a continuación,
  // pídale que formatee el objeto Date.
  func updateDueDateLabel() {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    dueDateLabel.text = formatter.string(from: dueDate)
  }
  
  
  // Esto establece la nueva variable de instancia en true y le indica a la vista de tabla que inserte una nueva fila debajo de la
  // celda Due Date. Esta nueva fila contendrá el UIDatePicker. La pregunta es: ¿de dónde viene la celda para esta nueva fila de
  // selector de fechas? No se puede poner en la vista de tabla como una célula estática ya porque entonces siempre sería visible.
  // Sólo desea mostrarlo después de que el usuario toque la fila Fecha de vencimiento. Xcode tiene una nueva característica que le
  // permite agregar vistas adicionales a una escena que no son inmediatamente visibles.
  func showDatePicker() {
    datePickerVisible = true
    
    let indexPathDateRow = IndexPath(row: 1, section: 1)
    let indexPathDatePicker = IndexPath(row: 2, section: 1)
    
    // Esto establece el textColor del detailTextLabel en el color del tinte.
    if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
      dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
    }
    
    
    // También indica a la vista de tabla que vuelva a cargar la fila Due Date.
    // Sin eso, las líneas separadoras entre las celdas no se actualizan correctamente.
    tableView.beginUpdates()
    tableView.insertRows(at: [indexPathDatePicker], with: .fade)
    tableView.reloadRows(at: [indexPathDateRow], with: .none)
    tableView.endUpdates()
    
    // Esto da la fecha adecuada al componente UIDatePicker.
    datePicker.setDate(dueDate, animated: false)
  }
  
  func hideDatePicker() {
    
    // Esto hace lo contrario de showDatePicker (). Elimina la celda del selector de
    // fechas de la vista de tabla y restaura el color de la etiqueta de fecha a gris medio.
    if datePickerVisible {
      datePickerVisible = false
      let indexPathDateRow = IndexPath(row: 1, section: 1)
      let indexPathDatePicker = IndexPath(row: 2, section: 1)
      if let cell = tableView.cellForRow(at: indexPathDateRow) {
        cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
      }
      tableView.beginUpdates()
      tableView.reloadRows(at: [indexPathDateRow], with: .none)
      tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
      tableView.endUpdates()
    }
  }
  
  // MARK: - Actions
  
  // Cuando se cambia el interruptor a ON, esto le solicita permiso al usuario para enviar notificaciones locales. 
  // Una vez que el usuario haya dado permiso, la aplicación no presentará una solicitud de nuevo pidiendo permiso.
  @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
    textField.resignFirstResponder()
    if switchControl.isOn {
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .sound]) {
        granted, error in /* do nothing */
      }
    }
  }
  
  // Actualiza la variable de instancia dueDate con la nueva fecha
  // y luego actualiza el texto en la etiqueta Fecha de vencimiento.
  @IBAction func dateChanged(_ datePicker: UIDatePicker) {
    dueDate = datePicker.date
    updateDueDateLabel()
  }
  
  @IBAction func cancel() {
    // Cuando el usuario hace clic en el botón cancel, envía
    // el mensaje 'itemDetailViewControllerDidCancel' al delegado.
    delegate?.itemDetailViewControllerDidCancel(self)
  }
  
  @IBAction func done() {
    if let item = itemToEdit {
      // Pongo lo que hay en el campo textView en item.text que es el objeto ChecklistItem existente.
      item.text = textField.text!
      
      // Aquí se vuelve a colocar el valor del control de conmutación y la variable de
      // instancia dueDate en el objeto ChecklistItem cuando el usuario presiona el botón Done.
      item.shouldRemind = shouldRemindSwitch.isOn
      item.dueDate = dueDate
      item.scheduleNotification()
      
      // A continuación llamo al nuevo método delegado, 'didFinishEditing'
      delegate?.itemDetailViewController(self, didFinishEditing: item)
      
    } else { // Si itemToEdit es nil, hago lo de siempre, añadir un nuevo item en vez de editar uno existente.
      
      let item = ChecklistItem()
      item.text = textField.text!
      item.checked = false
      
      item.shouldRemind = shouldRemindSwitch.isOn
      item.dueDate = dueDate
      item.scheduleNotification()
      
      // Al pulsar en done, se envía el mensajes 'itemDetailViewController'
      // al delegado, pero pasándole un nuevo objeto 'ChecklistItem' que
      // contiene la cadena de texto del campo del textView y su check.
      
      delegate?.itemDetailViewController(self, didFinishAdding: item)
    }
  }
  
  // MARK: - TableView - Data source & delegate.
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Si el selector de fechas está visible, la sección 1 tiene tres filas. Si el
    // selector de fechas no está visible, puede pasar al origen de datos original.
    if section == 1 && datePickerVisible {
      return 3
    } else {
      return super.tableView(tableView, numberOfRowsInSection: section)
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    // Proporcionando el método de "heightForRowAt" usted puede dar a cada célula su propia altura.
    // El componente UIDatePicker tiene 216 puntos de altura, más 1 punto para la línea de separación,
    // lo que hace que la altura total de la fila sea de 217 puntos.
    if indexPath.section == 1 && indexPath.row == 2 {
      return 217
    } else {
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }
  
  // El selector de fecha solo se hace visible después de que el usuario
  // toque  la celda Due Date, que ocurre en  tableView (didSelectRowAt).
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // Esto llama a showDatePicker() cuando indexPath indica que se usó la fila 'Due Date'.
    // También oculta el teclado en pantalla si es visible. En este punto tiene la mayoría
    // de las piezas en su lugar, pero la fila de 'Due Date' no es  capaz todavía de hacer tap.
    // Esto se debe a que ItemDetailViewController.swift ya tiene un método "willSelectRowAt"
    // que siempre devuelve nil, haciendo que los toques en todas las filas sean ignorados.
    tableView.deselectRow(at: indexPath, animated: true)
    textField.resignFirstResponder()
    
    if indexPath.section == 1 && indexPath.row == 1 {
      if !datePickerVisible {
        showDatePicker()
      } else {
        hideDatePicker()
      }
    }
  }
  
  
  // Cuando el usuario teclea en una celda, la table view envía al delegado
  // un mensaje ('willSelectRowAt') que dice: "Hola delegado, estoy a punto
  // de seleccionar esta fila en particular". Al devolver 'nil' el delegado
  // responde:"Lo siento, pero no se le permite seleccionar esa celda: nil"
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    // Ahora la fila de 'Due Date' responde a los taps, pero las otras filas no.
    if indexPath.section == 1 && indexPath.row == 1 {
      return indexPath
    } else {
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // La sentencia if comprueba si "cellForRowAt" se está llamando con el indexpath para la fila selectora de fecha.
    // Si es así, devuelve la nueva datePickerCell que acaba de diseñar. Esto es seguro porque la vista de tabla del
    // storyboard  no sabe nada acerca de la fila 2 en la  sección 1, por lo que no está interfiriendo con una celda
    // estática existente. Para cualquier ruta de índice que no sea la celda selectora de fecha, este método llamará
    // a super (que es UITableViewController). Este es el truco que se asegura de que las otras células estáticas todavía funcionan.
    if indexPath.section == 1 && indexPath.row == 2 {
      return datePickerCell
    } else {
      return super.tableView(tableView, cellForRowAt: indexPath)
    }
  }
  
  override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
    // La razón de la aplicación se estrelló en este método anterior que la fuente de datos estándar no sabe
    // nada acerca de la celda en la fila 2 en la sección 1 (el que tiene el selector de fecha), porque esa
    // celda no forma parte del diseño de la vista de tabla en El storyboard. Así que después de insertar la
    // nueva celda selectora de fecha, la fuente de datos se confunde y se bloquea la aplicación. Para arreglar
    // esto, usted tiene que engañar a la fuente de datos para creer que realmente hay tres filas en esa sección
    // cuando el selector de fecha es visible.
    var newIndexPath = indexPath
    if indexPath.section == 1 && indexPath.row == 2 {
      newIndexPath = IndexPath(row: 0, section: indexPath.section)
    }
    return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
  }
  
  // MARK: - Delegates for UITextField
  
  // Este es uno de los métodos de delegado UITextField, que se invoca
  // cada vez que el usuario cambia el texto, ya sea tocando el teclado
  // o cortando / pegando texto.
  func textField(_ textField: UITextField,shouldChangeCharactersIn range: NSRange,replacementString string: String) -> Bool {
    
    let oldText = textField.text! as NSString
    let newText = oldText.replacingCharacters(in: range, with: string) as NSString
    
    doneBarButton.isEnabled = (newText.length > 0)
    return true
  }
  
  // Hay otra situación en la que es una buena idea ocultar el selector de fecha: cuando el usuario teclea dentro del campo de texto.
  // No se verá muy bien si el teclado parcialmente se superpone al selector de fecha, por lo que también podría ocultarlo.
  // El controlador de vista ya es el delegado para el campo de texto, lo que facilita esto.
  func textFieldDidBeginEditing(_ textField: UITextField) {
    hideDatePicker()
  }
}








