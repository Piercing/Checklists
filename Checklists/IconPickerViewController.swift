//
//  IconPickerViewController.swift
//  Checklists
//
//  Created by Piercing on 23/1/17.
//  Copyright © 2017 DevSapin. All rights reserved.
//

import UIKit

protocol IconPickerViewControllerDelegate: class {
  func iconPicker(_ picker: IconPickerViewController, didPick iconName: String)
}


class IconPickerViewController: UITableViewController {
  
  weak var delegate: IconPickerViewControllerDelegate?
  
  let icons =
    [
      "No Icon",
      "Appointments",
      "Birthdays",
      "Chores",
      "Drinks",
      "Folder",
      "Groceries",
      "Inbox",
      "Photos",
      "Trips"
  ]
  
  
  // MARK: - Data source Table view
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return icons.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "IconCell", for: indexPath)
    
    let iconName = icons[indexPath.row]
    cell.textLabel!.text = iconName
    cell.imageView!.image = UIImage(named: iconName)
    
    return cell
  }
  
  // Añadimos este método para poder llamar al método delegado cuando se pulsa una fila.
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let delegate = delegate {
      let iconName = icons[indexPath.row]
      delegate.iconPicker(self, didPick: iconName)
    }
  }
  
}


/// NOTAS: Para recapitular, hemos:

/// • agregado un nuevo objeto view controller,
/// • diseñamos nuestra interfaz de usuario en el storyboard, y 
/// • lo conectamos a la pantalla Añadir/Editar de Checklist usando un segue y un delegado. 
/// Ésos son los pasos básicos que necesitamos hacer con cualquier nueva pantalla que añadamos.


