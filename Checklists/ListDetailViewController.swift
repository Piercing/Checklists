//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by Piercing on 18/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//

import UIKit

protocol ListDetailViewControllerDelegate: class {
  func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
  func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding checklist: Checklist)
  func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing checklist: Checklist)
}

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate {
  
  // MARK: - Globals variables
  
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneBarButton: UIBarButtonItem!
  weak var delegate: ListDetailViewControllerDelegate?
  var checklistToEdit: Checklist?
  var iconName = "Folder"
  
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Esto cambia el título de la pantalla si el usuario
    // está editando una 'checklist' existente, poniendo
    // el nombre de la checklist en el textField.
    if let checklist = checklistToEdit {
      title = "Edit Checklist"
      textField.text = checklist.name
      
      //textField.text != "" ? doneBarButton.isEnabled = true : doneBarButton.isEnabled = false
      if(textField.text != ""){
        doneBarButton.isEnabled = true
      } else{
        doneBarButton.isEnabled = false
      }
      iconName = checklist.iconName
      iconImageView.image = UIImage(named: iconName)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    textField.becomeFirstResponder()
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    
    // Esto es necesario de lo contrario no se puede tocar la celda 'Icon' para activar el segue.
    // Esto es necesario de lo contrario no se puede tocar la celda "Icono" para activar el segue.
    // Anteriormente, este método siempre devuelve cero, lo que significa que no se puede hacer
    // tapping en las filas. Ahora, sin embargo, desea permitir que el usuario toque la celda Icono,
    // por lo que este método debe devolver el 'indexPath' para esa celda. Debido a que la celda de
    // 'Icon' es la única fila en la segunda sección, sólo tiene que comprobar 'indexPath.section'.
    if indexPath.section == 1 {
      return indexPath
    } else {
      return nil
    }
  }
  
  // MARK: Actions
  
  @IBAction func cancel() {
    // Mando el mensaje al delegado, el mensaje es el método que implementa del protocolo.
    // Que lo recibirá la clase que implemente dicho protocolo, es decir, le mando mensajes
    // a través del protocolo a la clase que lo implementa y que se hace delegado de ésta.
    delegate?.listDetailViewControllerDidCancel(self)
  }
  
  @IBAction func done() {
    if let checklist = checklistToEdit {
      // Antes de cerrar al pulsar Done, pongo los valores de las propiedades que he editado.
      checklist.name = textField.text!
      checklist.iconName = iconName
      // Mando el mensaje al controlador delegado, el mensaje es el
      // método que implementa del protocolo y le paso la checklist.
      delegate?.listDetailViewController(self, didFinishEditing: checklist)
      
    } else {
      // Como no edito, cojo el nombre que tenía el checklist en el campo
      //  de texto y le asigno también la imagen antes de cerrar la vista, 
      // creando un nuevo objeto Checklist.
      let checklist = Checklist(name: textField.text!, iconName: iconName)
      // Mando el mensaje al controlador delegado, el mensaje es el 
      // método que implementa del protocolo y le paso la checklist.
      delegate?.listDetailViewController(self, didFinishAdding: checklist)
    }
  }
  
  // MARK: - Delegates for UITextField & IconPicker
  
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    
    let oldText = textField.text! as NSString
    let newText = oldText.replacingCharacters(in: range, with: string) as NSString
    
    doneBarButton.isEnabled = (newText.length > 0)
    return true
  }
  
  // Recibo el mensaje que me manda la variable delegado de 'IconPickerViewController', 
  // y que manda quién es el controlador y el iconName que se ha seleccioando en la tabla.
  func iconPicker (_ picker: IconPickerViewController, didPick iconName: String){
    
    // Esto pone el nombre del icono elegido en la variable 'iconName' para
    // recordarlo y también actualiza la vista de la imagen con la nueva imagen.
    self.iconName = iconName // Este icono es el que el delegado me manda y que ha sido seleccionado en la tabla de iconos.
    
    //Busco en assets, la imagen con el nombre que me trae el mensaje del delegado, iconName.
    iconImageView.image = UIImage(named: iconName)
    
    // No llamamos a 'dismiss()' aquí pero si a 'popViewController(animated)' porque el 'IconPicker' está en la pila de navegación.
    // Al crear el segue usamos el estilo de seguimiento "show" en lugar de "present modally", que empuja al nuevo controlador de
    // vista en el stack de navegación. Para regresar es necesario "pop" de nuevo. ('dismiss()' es sólo para pantallas modales, no
    // para pantallas push). Recuerde que navigationController es una propiedad opcional del controlador de vista, por lo que necesita
    // usar? (o !) para acceder al objeto UINavigationController real. Al escribir 'let _' le dice a Xcode que no nos importa el valor
    // devuelto de 'popViewController()'. El símbolo '_' se llama comodín y se puede utilizar en lugar de un nombre de variable.
    let _ = navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickIcon" {
      let controller = segue.destination as! IconPickerViewController
      // Le digo que el delegado del controlador 'IconPickerViewController' voy a ser yo.
      controller.delegate = self
    }
  }
}








