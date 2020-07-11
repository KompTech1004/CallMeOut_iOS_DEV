//
//  AppDelegate.swift
//  Call Me Out
//
//  Created by B S on 4/2/18.
//  Copyright © 2018 B S. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import UserNotifications
import GoogleSignIn
//import GoogleMobileAds
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        SlideNavigationController.init()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let str2 = UIStoryboard(name: "Signin", bundle: nil)
        let menu = storyboard.instantiateViewController(withIdentifier: "SlideMenuVC")
        let main = str2.instantiateViewController(withIdentifier: "LandingVC")
        let main2 = storyboard.instantiateViewController(withIdentifier: "TabbarVC")
        Global.shared.tabbar = main2 as! TabbarVC
//        let defaults = UserDefaults.standard
//        let notification = defaults.integer(forKey: "notification_count")
//        Global.shared.tabbar?.notification = notification
        SlideNavigationController.sharedInstance().leftMenu = menu
        SlideNavigationController.sharedInstance().setNavigationBarHidden(true, animated: false)
        if let _ = Global.getUserDataFromLocal() {
            SlideNavigationController.sharedInstance().pushViewController(main2, animated: false)
            if let _ = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]
            {
                Global.shared.tabbar?.selectedIndex = 3
            }
        }
        else{
            SlideNavigationController.sharedInstance().pushViewController(main, animated: false)
        }
        self.window?.rootViewController = SlideNavigationController.sharedInstance()
        self.window?.makeKeyAndVisible()
        
        FirebaseApp.configure()

        if #available(iOS 10.0, *) {

            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        
        Messaging.messaging().delegate = self
        
//        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544/2934735716")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)

        
        return true
    }

    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("********** - \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: DEVICE_TOKEN)
        if let user = Global.getUserDataFromLocal(){
            Global.shared.updateFcm(userid: String(user.id), token: fcmToken) { (flag, result) in
                print(result)
            }
        }
        connectToFcm()
    }

    @objc func refreshToken(_ noti:Notification)
    {
        if let token = InstanceID.instanceID().token()
        {
            print(token)
            UserDefaults.standard.set(token, forKey: DEVICE_TOKEN)
            if let user = Global.getUserDataFromLocal(){
                Global.shared.updateFcm(userid: String(user.id), token: token) { (flag, result) in
                    print(result)
                }
            }
        }
        connectToFcm()
    }
 
    func connectToFcm()
    {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
/*
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        print ("****  push received \(userInfo)")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print ("****  push received \(userInfo)")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
    }
*/
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        
        
        // Print full message.
        if let payload = userInfo["aps"] as? [String: Any] {
            if let badge = payload["badge"] as? Int {
                UIApplication.shared.applicationIconBadgeNumber = badge
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
            }
        }
        // Change this to your preferred presentation option
//        completionHandler(UNNotificationPresentationOptions.alert)
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print ("push received ---- ")

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receive_notification"), object: nil)
        
//        completionHandler([.alert, .badge, .sound])
    }
}
