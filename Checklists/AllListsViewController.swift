//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Piercing on 18/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate {
  
  // MARK: - Globals variables
  
  // El '!' es necesario porque 'dataModel' será temporalmente nulo cuando se incicia la aplicación.
  // No tiene porque ser un '?', ya que una vez que 'dataModel' da un valor nunca más volverá a ser nil.
  var dataModel: DataModel!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  
  // 'ViewDidAppear ()' no sólo se llama cuando se inicia la aplicación, sino también cada
  // vez que el controlador de navegación desliza la pantalla principal de nuevo a la vista.
  
  // Comprobar si se debe restaurar la pantalla 'AllListsViewController’s' sólo tiene que ocurrir una vez cuando se inicia la aplicación,
  // ¿por qué puso esta lógica en 'viewDidAppear ()' si se llama más de una vez? Esta es la razón: La primera vez que la pantalla de
  // 'AllListsViewController' se vuelve visible, no quieres que el método delegate navigationController (willShow ...) sea llamado todavía,
  // ya que siempre sobrescribiría el valor antiguo de "ChecklistIndex" con -1, antes de que haya tenido la oportunidad de restaurar la pantalla antigua.
  // Al esperar a registrar 'AllListsViewController' como delegado de controlador de navegación hasta que sea visible, evitará este problema.
  // 'ViewDidAppear ()' es el lugar ideal para eso, por lo que tiene sentido hacerlo desde ese método. Sin embargo, como se mencionó, 'viewDidAppear ()'
  // también se llama después de que el usuario presiona el botón atrás para volver a la pantalla All Lists. Eso no debería tener ningún efecto secundario
  // no deseado, como activar el segue de nuevo.
  
  // Naturalmente, el controlador de navegación llama a 'navigationController (willShow ...)' cuando se pulsa el botón de retroceso, pero esto sucede antes de 'viewDidAppear ()'.
  // El método 'delegate' siempre establece el valor de "ChecklistIndex" en -1, y como resultado 'viewDidAppear ()' no desencadena un segue nuevamente. Y así todo funciona ...
  // La lógica que agregó a 'viewDidAppear ()' sólo hace su trabajo una vez durante el inicio de la aplicación. Hay otras maneras de resolver este problema en particular,
  // pero este enfoque es simple.
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // UIKit llama automáticamente a este método una vez que el controlador de vista se ha vuelto visible.
    // En primer lugar, el controlador de vista se convierte en el delegado del controlador de navegación.
    // Cada controlador de vista tiene una propiedad built-in navigationController. Para acceder a él se
    // utiliza la notación 'navigationController?.delegate' porque es opcional. La diferencia entre los dos
    // es que '!' bloqueará la aplicación si este controlador de vista se mostrara fuera de un 'UINavigationController',
    // mientras que '?' no se bloquea, sino simplemente ignora el resto de esa línea. Para nuestra aplicación, esto no importa).
    // A continuación, verifica 'UserDefaults' para ver si tiene que realizar el segue. Si el valor de la opción "ChecklistIndex" es -1,
    // el usuario se encontraba en la pantalla principal de la aplicación antes de que se terminara la aplicación y no tenemos que hacer nada.
    // Sin embargo, si el valor de la configuración "ChecklistIndex" no es -1, el usuario estaba viendo una lista de verificación y la aplicación
    // debería seguir a esa pantalla,colocando el objeto de 'checklist' relevante en el parámetro 'sender' de performSegue(withIdentifier, sender).
    
    navigationController?.delegate = self
    let index = dataModel.indexOfSelectedChecklist
    
    // PROGRAMACIÓN DEFENSIVA: Realizar una comprobación más precisa para determinar si el índice es válido.
    // Debe estar entre 0 y el número de CHECKLIST el modelo de datos. Si no, entonces simplemente no seguir.
    // Esto evita que 'dataModel.lists [index]' solicite un objeto en un índice que no existe y la aplicación no rompa.
    
    // En 'viewDidAppear()' sólo se realiza el segue cuando el índice es 0 o mayor y también menor que el número 'checklist',
    // lo que significa que sólo es válido si se encuentra entre esos dos valores. Con este control defensivo en su lugar,
    // garantizamos que la aplicación no intentará seguir a una 'checklist' que no existe, incluso si los datosno están sincronizados.
    if index >= 0 && index < dataModel.lists.count {
      let checklist = dataModel.lists[index]
      performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataModel.lists.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = makeCell(for: tableView)
    
    let checklist = dataModel.lists[indexPath.row]
    cell.textLabel!.text = checklist.name
    cell.accessoryType = .detailDisclosureButton // Botón de revelación 'info'
    
    let count = checklist.countUncheckedItems()
    if checklist.items.count == 0 {
      cell.detailTextLabel!.text = "(No Items)"
    } else if count == 0 {
      cell.detailTextLabel!.text = "All Done!"
    } else {
      cell.detailTextLabel!.text = "\(count) Remaining"
    }
    
    //cell.imageView!.image = UIImage(named: checklist.iconName)
    
    return cell
  }
  
  // Se invoca éste método de delegado de tableView cuando se toca en una
  // fila, ya que ahora lo hacemos a mano ya que no utilizamos celdas prototipo.
  // Para ello llamamos 'performSegue' con el identificador del segue y las cosas comenzarán a moverse.
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // Guardando valores en userDefault. Almacena el índice de la
    // fila seleccionada en UserDefaults bajo la clave 'ChecklistIndex.
    
    // Para reconocer si el usuario presiona el botón de retroceso en la barra de navegación,
    // tiene que convertirse en un delegado del controlador de navegación. Ser delegado significa
    // que el controlador de navegación le indica cuándo empuja o  muestra controladores de vista
    // en la pila de navegación. El lugar lógico para este delegado es el 'AllListsViewController'.
    dataModel.indexOfSelectedChecklist = indexPath.row
    
    let checklist = dataModel.lists[indexPath.row]
    // Envío el objeto 'sender: checklist' pulsado en la lista a través del segue,
    // aunque lo enviará realmente el método prepare (for segue:)', de más abajo.
    performSegue(withIdentifier: "ShowChecklist", sender: checklist)
  }
  
  // Borrar un item checklist
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    dataModel.lists.remove(at: indexPath.row)
    
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }
  
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    
    // En este método se crea el objeto view controller para la pantalla Add/Edit Checklist
    // y se muestra con 'present' en la pantalla. Esto es parecido a lo que 'segue' hace detrás
    // de escena. El view controller está embebido en el storyboard y hay que pedirle que lo cargue.
    
    // ¿De dónde sacamos ese objeto del storyboard?. Cada view Controller
    // tiene una propiedad del storyboard que hace referencia al storyboard desde el que se cargó el view controller.
    // La propiedad 'storyboard!' es opcional porque los view controllers no siempre se cargan desde un storyboard.
    // Pero este sí, por lo que podemos utilizar '!' para desempaquetar ya que estamos seguros de que no será nil.
    
    // La llamada a 'instantiateViewController' toma un String identificador 'ListDetailNavigationController';
    // y así es como pedimos al stroyboard que cree un nuevo view controller, en nuestro caso éste será el controlador
    // de navegación que contine 'ListDetailViewController'; aún tenemos que establecer este identificador en el controlador
    // de navegación, de lo contrario el storyboard no podrá encontrarlo.
    
    let navigationController = storyboard!.instantiateViewController(
      withIdentifier: "ListDetailNavigationController") as! UINavigationController
    
    let controller = navigationController.topViewController as! ListDetailViewController
    controller.delegate = self
    
    let checklist = dataModel.lists[indexPath.row]
    controller.checklistToEdit = checklist
    
    present(navigationController, animated: true, completion: nil)
  }
  
  // MARK: - Funtions
  
  // Función propia para crear nueva celda o reutilizar una existente.
  func makeCell(for tableView: UITableView) -> UITableViewCell {
    
    let cellIdentifier = "Cell"
    
    // Se devuelve nil, es que no hay ninguna celda que se
    // pueda reutilizar y se crea una nueva con 'cellIdentifier'.
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
      return cell
    } else {
      return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
    }
  }
  
  // MARK: - Navigation
  
  // Aquí establecemos las propiedades del nuevo controlador de vista antes de que se haga visible.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) { /// MOSTRAMOS UN CHECKLIST YA EXISTENTE PARA EDITARLO.
    if segue.identifier == "ShowChecklist" { // Busco el segue con el identificador dado.
      // Guardo a que controlador se dirige el segue seleccionado.
      let controller = segue.destination as! ChecklistViewController
      // Accedo a la variable 'checklist' a traves de controller que es de tipo 'ChecklistViewController'
      // y le digo que su valor, lo que va a recibir, es el sender, que contiene el objeto pulsado en la lista
      // es decir, la fila que se pulsó, y que recibo del método anterior 'performSegue' -> 'sender: checklist'
      // Por tanto le estoy pasando mediante el segue a esta variable la fila seleccionada, luego en viewDidload
      // del controlador 'ChecklistViewController' que es el controlador destino, establezco el título, 'title = checklist.name'
      // que mostrará la barra de navegación del viewController 'ChecklistViewController', y será el texto de la fila seleccionada.
      controller.checklist = sender as! Checklist
      
    } else if segue.identifier == "AddChecklist" { /// CREAMOS/AÑADIMOS UN NUEVO CHECKLIST.
      let navigationController = segue.destination as! UINavigationController
      let controller = navigationController.topViewController as! ListDetailViewController
      
      controller.delegate = self
      controller.checklistToEdit = nil
    }
  }
  
  // MARK: - Protocols ListDetail methods - Delegate
  
  func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) { /// AL PULSAR CANCEL.
    dismiss(animated: true, completion: nil)
  }
  
  func listDetailViewController(_ controller: ListDetailViewController,
                                didFinishAdding checklist: Checklist) { /// AL PULSAR DONE AÑADIENDO UN ITEM.
    
    let newRowIndex = dataModel.lists.count
    dataModel.lists.append(checklist)
    let indexPath = IndexPath(row: newRowIndex, section: 0)
    let indexPaths = [indexPath]
    tableView.insertRows(at: indexPaths, with: .automatic)
    dismiss(animated: true, completion: nil)
  }
  
  func listDetailViewController(_ controller: ListDetailViewController,
                                didFinishEditing checklist: Checklist) { /// AL PULSAR DONE EDITANDO UN ITEM.
    
    if let index = dataModel.lists.index(of: checklist) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        cell.textLabel!.text = checklist.name
      }
    }
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Protocols Navigation Controller methods - Delegate
  
  // Este método se llama siempre que el controlador de navegación se deslice a una nueva pantalla.
  // Si se presionó el botón de retroceso, el nuevo controlador de vista es AllListsViewController
  // y se establece el valor "ChecklistIndex" en UserDefaults en -1, lo que significa que no se ha
  // seleccionado ninguna lista de comprobación (checklist).
  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    
    // ¿¿Se pulsó el botón de retroceso??. Para ello
    // compruebo si el view controller es en el que estoy.
    if viewController === self {
      // si es así, establezco a -1 ya que no voy a guardar nada, dado que
      // no se pulsó el botón de retroceso ya que sigo en el mismo controlador.
      dataModel.indexOfSelectedChecklist = -1
    }
  }
}








