//
//  ChecklistViewController.swift
//  Checklists
//
//  Created by Piercing on 17/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
  
  // MARK: - Global variables.
  
  var items: [ChecklistItem]
  var checklist: Checklist!
  
  // MARK: - Contructors
  
  /// Esto sigue el patrón de los métodos init:
  /// 1. Primero asegúrese de que los elementos de la variable de instancia tengan un valor adecuado (un nuevo array).
  /// 2. A continuación, llamar a la versión super de init (). Esta vez se llama a super.init (codificador) para asegurarse de que el resto del controlador de vista se desbloquea correctamente desde el guión gráfico.
  /// 3. Por último, puede llamar a otros métodos. Aquí se llama un nuevo método para hacer el trabajo real de cargar el archivo plist.
  required init?(coder aDecoder: NSCoder) {
    items = [ChecklistItem]()
    super.init(coder: aDecoder)
    loadChecklistItems()
  }
  
  // MARK:- LifeCycle.
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Cambia el título que se muestra en la navigation bar.
    title = checklist.name
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Data Source Table
  
  override func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Obtengo la celda que hay en la tabla con el identificador, para que pueda ser reutilizada.
    let cell = tableView.dequeueReusableCell( withIdentifier: "ChecklistItem", for: indexPath)
    
    // Obtengo el objeto del array según la fila seleccionada.
    let item = items[indexPath.row]
    
    configureText(for: cell, with: item)
    
    // Llamo al método para comprobar el marcado de las
    // celdas al iniciarse están desmarcadas ya que las
    // variables booleanas están a false al arrancar.
    // En caso de que se toque alguna el valor cambiará
    // y la celda contendrá su correspondiente checkmark.
    configureCheckmark(for: cell, with: item)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // Obtengo la celda seleccionada, con if let, me aseguro de que hay una celda seleccionada.
    if let cell = tableView.cellForRow(at: indexPath) {
      // Obtengo el objeto del array según la fila selecionada.
      let item = items[indexPath.row]
      // Llamo al método para cambiar su checked a true o false
      // dependiendo del estado en el que se encontraba al tocarlo.
      item.toggleChecked()
      // Una vez pongo a true o false el objeto configuro su checkmark a show o hide.
      configureCheckmark(for: cell, with: item)
    }
    // Para que al tocar la fila no se quede marcada una vez pierda el foco.
    tableView.deselectRow(at: indexPath, animated: true)
    // Guardo los cambios en local
    saveChecklistItems()
  }
  
  // Borrar un item detail.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,forRowAt indexPath: IndexPath) {
    // 1.-
    items.remove(at: indexPath.row)
    // 2.-
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
    
    // Guardo los cambios en local
    saveChecklistItems()
  }
  
  // MARK: - Functions
  
  func configureCheckmark(for cell: UITableViewCell, with item: ChecklistItem) {
    
    // Obtengo el objeto según el tag.
    let label = cell.viewWithTag(1001) as! UILabel
    
    // Compruebo si está o no seleccionado, para marcarlo o no.
    if item.checked {
      label.text = "✔︎"
    } else {
      label.text = ""
    }
  }
  
  func configureText(for cell: UITableViewCell, with item: ChecklistItem) {
    let label = cell.viewWithTag(1000) as! UILabel
    label.text = item.text
  }
  
  /// CODIFICAR EL ARRAY ChecklistItems para guardarlo en 'Checklist.plist'.
  // Siempre que modifiquemos la lista de elementos debemos de llamar a éste método.
  func saveChecklistItems() {
    
    // Es una forma de NSCoder de crear archivos 'plist'.
    // Codifica el array y todos los archivos 'ChecklistItems'
    // en él, en algún tipo de formato de datos binarios que
    // se pueden escribir en un archivo.
    let data = NSMutableData()
    let archiver = NSKeyedArchiver(forWritingWith: data)
    archiver.encode(items, forKey: "ChecklistItems")
    archiver.finishEncoding()
    // Los datos se colocan en un objeto' NSMutableData', que
    // se escribirá en el archivo especificado por 'dataFilePath'.
    data.write(to: dataFilePath(), atomically: true)
  }
  
  /// DECODIFICAR EL ARRAY ChecklistItems para leerlo de 'Checklist.plist'
  func loadChecklistItems() {
    // 1.- Obtengo la ruta.
    let path = dataFilePath()
    // 2.- Intento cargar el contenido de 'Checklist.plist' en un objeto Data.
    if let data = try? Data(contentsOf: path) {
      // 3.- Cuando la aplicación encuentre un archivo 'Checklist.plist'
      // cargará todo el array con las copias exactas de ChecklistItems.
      let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
      items = unarchiver.decodeObject(forKey: "ChecklistItems") as! [ChecklistItem]
      unarchiver.finishDecoding()
    }
  }
  
  // MARK: - Protocols ItemDetail methods - Delegate
  
  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) { /// AL PULSAR CANCEL.
    dismiss(animated: true, completion: nil)
  }
  
  func itemDetailViewController(_ controller: ItemDetailViewController,
                                didFinishAdding item: ChecklistItem) { /// AL PULSAR DONE AÑADIENDO UN ITEM.
    
    // Número de filas que hay en la tabla, es necesario
    // para actualizar correctamente la vista de la tabla.
    let newRowIndex = items.count
    // Añado el item que recibo al array de items.
    items.append(item)
    
    // Le indico que la voy a insertar en la sección 0, en la fila con el
    // valor que tiene 'newRowIndex', (que será la última fila), una nueva celda.
    let indexPath = IndexPath(row: newRowIndex, section: 0)
    // Creo un array temporal que sólo contien el elemento de un index-path,
    // en este caso el índice que apunta a la fila 5 en la sección 0.
    let indexPaths = [indexPath]
    // Utilizo el método de insertar fila en la tabla, pero debo
    // darle un array de index-paths aunque sólo contenga un elemento.
    // '.automatic' hace que la vista utilice animación agradable al insertar.
    tableView.insertRows(at: indexPaths, with: .automatic)
    
    // Una vez pulso Done y se ha completado lo anterior vuelvo a la vista anterior.
    dismiss(animated: true, completion: nil)
    // Guardo los datos en local.
    saveChecklistItems()
  }
  
  func itemDetailViewController(_ controller: ItemDetailViewController,
                                didFinishEditing item: ChecklistItem) { /// AL PULSAR DONE EDITANDO UN ITEM.
    if let index = items.index(of: item) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        configureText(for: cell, with: item)
      }
    }
    dismiss(animated: true, completion: nil)
    // Guardo los datos en local

    saveChecklistItems()
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    // 1.- obtemos el segue correspondiente por su identificador
    if segue.identifier == "AddItem" {
      
      // 2.- Ahora pasamos por el navigation controller que va primero que la table View en este caso.
      let navigationController = segue.destination as! UINavigationController
      
      // 3.- Para encontrar al controlador al que queremos dirigirnos, accedemos a la
      // propiedad 'topViewController' del controlador de navegación. Esta propiedad
      // se refiere a la pantalla que está actualmente activa dentro del controlador
      // de navegación.
      let controller = navigationController.topViewController as! ItemDetailViewController
      
      // 4.- Una vez tengo la referencia al objeto 'ItemDetailViewController'
      // le digo quien es su delegado, en este caso este mismo controlador,
      // con lo que se completa la conexión entre ambas vistas o controllers.
      controller.delegate = self
      
    } else if segue.identifier == "EditItem" {
      
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! ItemDetailViewController
      controller.delegate = self
      
      // Sender contiene una referencia al botón info de la celda que ha sido pulsada y ha activado el segue.
      // Utilizo éste objeto UITableViewCell para buscar el número de la fila que ha sido pulsada, el indexPath.
      if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
        // Una vez que tengo el número de la fila, puedo obtener el objeto ChecklistItem para editarlo y asignarlo
        // a la propiedad itemToEdit de ItemDetailViewController, sacándolo del array que contiene dichos items.
        controller.itemToEdit = items[indexPath.row]
      }
    }
  }
  
  // MARK: - Data Persistence.
  
  func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  func dataFilePath() -> URL {
    // Utilizo el método anterior para construir la ruta completa al
    // archivo que almacenará los elementos de la lista 'Checklists'.
    return documentsDirectory().appendingPathComponent("Checklists.plist")
  }
}


// MARK: - NOTES

/// NOTA: ############ 😍😍Delegados en cinco sencillos pasos:😎😎 ############
// Estos son los pasos para configurar el patrón de delegado entre dos objetos, donde
// el objeto A es el delegado para el objeto B y el objeto B devolverá los mensajes a A.
// Los pasos son:

/// 1 - Definir un protocolo delegado para Objeto B.

/// 2 - Dar al objeto B una variable opcional de delegado. Esta variable debe ser débil.

/// 3 - Haga que el objeto B envíe mensajes a su delegado cuando ocurre algo interesante,
/// como el usuario presionando los botones Cancelar o Done, o cuando necesita una
/// información. Escribir: 😎'delegate?.methodName (self, ...)😎'.

/// 4 - Hacer el objeto A conforme al protocolo del delegado. Debe poner el nombre
/// del protocolo en su línea de clase e implementar los métodos del protocolo.

/// 5 - Diga al objeto B que el objeto A es ahora su delegado.


// NOTA: RECORDAR QUE LAS FILAS SIEMPRE DEBEN AGREGARSE TANTO AL MODELO DE DATOS COMO A LA VISTA DE LA TABLA.
// NOTA:  loose coupling and is considered good software design practice. ACOPLAMIENTO SUELTO, cuando A es delegado
// de B, pero B no sabe nada sobre A, lo único que puede mandarle mensajes a A por medio del delegado.

// VOY POR LA PÁGINA 168














