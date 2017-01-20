//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Piercing on 18/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import Foundation
import UIKit

protocol ItemDetailViewControllerDelegate: class {
  func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: ChecklistItem)
  func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate {

  // MARK: - Global variables.

  weak var delegate: ItemDetailViewControllerDelegate?
  var itemToEdit: ChecklistItem?

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!

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
    }
  }

  // El controlador recibe este mensaje justo antes de que se haga visible.
  // Momento perfecto para activar el campo de texto enviando el mensaje
  // 'becomeFirstResponder' y active teclado automática/ al abrirse el controlador.
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }

  // MARK: - Actions

  @IBAction func cancel() {
    // Cuando el usuario hace clic en el botón cancel, envía
    // el mensaje 'itemDetailViewControllerDidCancel' al delegado.
    delegate?.itemDetailViewControllerDidCancel(self)
  }
  
  @IBAction func done() {
    if let item = itemToEdit {
      // Pongo lo que hay en el campo textView en item.text que es el objeto ChecklistItem existente.
      item.text = textField.text!
      // A continuación llamo al nuevo método delegado, 'didFinishEditing'
      delegate?.itemDetailViewController(self, didFinishEditing: item)
      
    } else { // Si itemToEdit es nil, hago lo de siempre, añadir un nuevo item en vez de editar uno existente.
      
      let item = ChecklistItem()
      item.text = textField.text!
      item.checked = false
      
      // Al pulsar en done, se envía el mensajes 'itemDetailViewController'
      // al delegado, pero pasándole un nuevo objeto 'ChecklistItem' que
      // contiene la cadena de texto del campo del textView y su check.

      delegate?.itemDetailViewController(self, didFinishAdding: item)
    }
  }

  // MARK: - TableView - Data source & delegate.

  // Cuando el usuario teclea en una celda, la table view envía al delegado
  // un mensaje ('willSelectRowAt') que dice: "Hola delegado, estoy a punto
  // de seleccionar esta fila en particular". Al devolver 'nil' el delegado
  // responde:"Lo siento, pero no se le permite seleccionar esa celda: nil"
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return nil
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
}
