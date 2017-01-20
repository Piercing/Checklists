//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Piercing on 20/1/17.
//  Copyright © 2017 Razeware. All rights reserved.
//

import UIKit

class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate {
  
  // MARK: - Globals variables
  
  var lists: [Checklist]
  
  // MARK: - Constructor.
  
  required init?(coder aDecoder: NSCoder) {
    lists = [Checklist]()
    super.init(coder: aDecoder)
    var list = Checklist(name: "Birthdays")
    lists.append(list)
    list = Checklist(name: "Groceries")
    lists.append(list)
    list = Checklist(name: "Cool Apps")
    lists.append(list)
    list = Checklist(name: "To Do")
    lists.append(list)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return lists.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = makeCell(for: tableView)
    
    //let checklist = lists[indexPath.row]
    cell.textLabel!.text = "List \(indexPath.row)"
    cell.accessoryType = .detailDisclosureButton // Botón de revelación 'info'
    
    return cell
  }
  
  // Se invoca éste método de delegado de tableView cuando se toca en una
  // fila, ya que ahora lo hacemos a mano ya que no utilizamos celdas prototipo.
  // Para ello llamamos 'performSegue' con el identificador del segue y las cosas comenzarán a moverse.
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let checklist = lists[indexPath.row]
    // Envío el objeto 'sender: checklist' pulsado en la lista a través del segue,
    // aunque lo enviará realmente el método prepare (for segue:)', de más abajo.
    performSegue(withIdentifier: "ShowChecklist", sender: checklist)
  }
  
  // Borrar un item checklist
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    lists.remove(at: indexPath.row)
    
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }
  
  // MARK: - Funtions
  
  func makeCell(for tableView: UITableView) -> UITableViewCell {
    
    let cellIdentifier = "Cell"
    
    // Se devuelve nil, es que no hay ninguna celda que se
    // pueda reutilizar y se crea una nueva con 'cellIdentifier'.
    if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
      return cell
    } else {
      return UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
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
    
    let newRowIndex = lists.count
    lists.append(checklist)
    let indexPath = IndexPath(row: newRowIndex, section: 0)
    let indexPaths = [indexPath]
    tableView.insertRows(at: indexPaths, with: .automatic)
    dismiss(animated: true, completion: nil)
  }
  
  func listDetailViewController(_ controller: ListDetailViewController,
                                didFinishEditing checklist: Checklist) { /// AL PULSAR DONE EDITANDO UN ITEM.
    
    if let index = lists.index(of: checklist) {
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) {
        cell.textLabel!.text = checklist.name
      }
    }
    dismiss(animated: true, completion: nil)
  }
}








