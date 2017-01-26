//
//  AppDelegate.swift
//  Checklists
//
//  Created by Piercing on 17/1/17.
//  Copyright © 2017 DevSpain. All rights reserved.
//


import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  
  var window: UIWindow?
  let dataModel = DataModel()
  
  func saveData() {
    dataModel.saveChecklists()
  }
  
  // Método que se llama tan pronto como se incia la aplicación.
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Esto encuentra 'AllListViewController' mirando en el storyboard y luego establece
    // su propiedad dataModel. Ahora la pantalla AllList puede acceder de nuevo al array
    // de objetos de 'Checklist'.
    let navigationController = window!.rootViewController as! UINavigationController
    let controller = navigationController.viewControllers[0] as! AllListsViewController
    
    controller.dataModel = dataModel
    
    // Pedimos permiso para mostrar notificaciones locales.
    // Este es el mejor sitio, ya que es cuando justo se 
    // acaba de arrancar la aplicación. Le decimos que queremos
    // enviar notificaciones de tipo alerta con efecto sonido.
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    
    return true
  }
  
  // Este método se invocará cuando se publique la notificación local y la aplicación siga funcionando
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("Recived local notification \(notification)")
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    saveData()
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    saveData()
  }
  
  
}

