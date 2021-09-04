//
//  AppDelegate.swift
//  SRAA3
//
//  Created by Apple on 18/01/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Fabric
import Crashlytics
import OneSignal
import FBSDKCoreKit
import GoogleSignIn





var productCartArray = NSMutableArray.init()
var questionAnswerCartArray = NSMutableArray.init()
var currentLati:Double = 0.0
var currentLongi:Double = 0.0
var userDataModel: UserDataClass!
var currentLocation: CLLocation!

var selectedTimeForDelivery = ""
var selectedDeliveryDate = ""
var selectedPickupDateForJSON = ""
var selectedPickupDate = ""
var selectedAddressDictionary = NSMutableDictionary.init()
var selectedPickUpAddressDictionary = NSMutableDictionary.init()

//var GOOGLE_KEY = "AIzaSyB5dwNKXBc-Ajukxqyr8wZd_7T_SLaJIR0"
var GOOGLE_KEY = "AIzaSyAKCTwRzTedeLQYgIUKmCOv5-8Lm8r1qzA"
var ONE_SIGNAL_KEY = "35ac46db-56e3-4709-87d7-4a703be54524"
var localTimeZoneName: String { return TimeZone.current.identifier }

var isFromAppdelegate = true
var access_token = ""
var refresh_token = ""
var token_type = ""
var app_type = "", super_app_type = ""
var city_id = ""
var selectedOptionsIdsArray = [String]()
var selectedOptionsTitleArray = [String]()

var hasTopNotch: Bool {
    if #available(iOS 11.0,  *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    return false
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,CLLocationManagerDelegate,OSSubscriptionObserver, OSPermissionObserver {
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        print(stateChanges)
    }
    
   
    
    let locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        GIDSignIn.sharedInstance().clientID = "392130391199-isvv4hikolkrh011t1k9m47v88j3mu7n.apps.googleusercontent.com"
        GMSPlacesClient.provideAPIKey(GOOGLE_KEY)
        GMSServices.provideAPIKey(GOOGLE_KEY)
        locationManager.requestWhenInUseAuthorization()
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
                                     kOSSettingsKeyInAppLaunchURL: true]
        
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("notificationReceivedBlock")
            
        }
        
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(String(describing: payload!.body))")
            print("badge number = \(payload?.badge ?? 0)")
            print("notification sound = \(payload?.sound ?? "None")")
            
        }
        
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: ONE_SIGNAL_KEY, handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            let status:OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let userID = status.subscriptionStatus.userId
            print("userID = \(String(describing: userID))")
            
        })
        OneSignal.inFocusDisplayType = .notification
        OneSignal.add(self as OSPermissionObserver)
        OneSignal.add(self as OSSubscriptionObserver)
        
        

        currentLongi = Double(getLatitudeAndLongitude().longitude)
        currentLati = Double(getLatitudeAndLongitude().latitude)
       
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "locationStatus") == nil {
            userDefaults.set(false, forKey: "locationStatus")
        }
        if userDefaults.value(forKey: "refresh_token") != nil {
            refresh_token = (userDefaults.value(forKey: "refresh_token") as! String)
        }
        if userDefaults.value(forKey: "access_token") != nil {
            access_token = (userDefaults.value(forKey: "access_token") as! String)
        }
        if userDefaults.value(forKey: "token_type") != nil {
            token_type = (userDefaults.value(forKey: "token_type") as! String)
        }
       
        
        if userDefaults.object(forKey: "userData") != nil  {
            let decoded  = userDefaults.object(forKey: "userData") as! Data
            userDataModel = (NSKeyedUnarchiver.unarchiveObject(with: decoded) as! UserDataClass)
            print(userDataModel.user_id)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
            
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.isNavigationBarHidden = true
            self.window!.rootViewController = navigationController
            
            self.window?.makeKeyAndVisible()
        }
        
        getAppSettingsApiCall()
        return true
    }

    
    //MARK: Get One Signal Push Notification Token
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(String(describing: stateChanges))")
        
        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
        if let playerId = stateChanges.to.userId {
            let userDefaults = UserDefaults.standard
            notification_token = playerId
            userDefaults.setValue(notification_token, forKey: "notification_token")
            print("Current playerId \(notification_token)")
        }
    }
    
    
    
    func getLatitudeAndLongitude() -> (latitude: Float, longitude: Float) {
       
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        
        currentLocation = locationManager.location
        if let currentLocation = currentLocation {
            let latitude = Float(currentLocation.coordinate.latitude)
            let longitude = Float(currentLocation.coordinate.longitude)
            return (latitude,longitude)
        }
        
        return (0.0,0.0)
       
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("location updated ")
        let location = locations.last
        print(String(format: "Latitude %+.6f, Longitude %+.6f\n", location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 0))
        currentLocation = location
        currentLati = currentLocation.coordinate.latitude
        currentLongi = currentLocation.coordinate.longitude
        let dict = ["latitude":currentLocation.coordinate.latitude,"longitude":currentLocation.coordinate.longitude] as NSDictionary
        
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance().handle(url as URL?,
//                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
//                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
//    }
    
//    func application(application: UIApplication,
//                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
//        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
//                                            UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation!]
//        return GIDSignIn.sharedInstance().handle(url as URL,
//                                                    sourceApplication: sourceApplication,
//                                                    annotation: annotation)
//    }
    
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Hit Apis
    
    func getAppSettingsApiCall() {
        
        WebService.requestGetUrl(strURL: KAppSettings + "?keys=currency_symbol,admin_phone,admin_email,terms_and_conditions", is_loader_required: false, success: { (response) in
            
            print(response)
            
            if (response.value(forKey: "status_code")as! Int) == 1
            {
                let array = response.value(forKey: "data") as! [NSDictionary]
                
                for dic in array
                {
                    let dictt = dic
                    
                    if dictt.object(forKey: "key_title") as! String == "currency_symbol"
                    {
                        currencySymbol = dictt.object(forKey: "key_value") as! String
                    }
                    if dictt.object(forKey: "key_title") as! String == "admin_phone"
                    {
                        KAdminContact = dictt.value(forKey: "key_value")as! String
                    }
                    if dictt.object(forKey: "key_title")as! String == "terms_and_conditions"
                    {
                        KAppTermsAndConditions = dictt.value(forKey: "key_value")as! String
                    }
                    if dictt.object(forKey: "key_title")as! String == "admin_email"
                    {
                        KAdminEmail = dictt.value(forKey: "key_value")as! String
                    }
                }
            }
            
            /* else
             {
             COMMON_ALERT.showAlert(title: response.value(forKey: "message") as! String, msg: "", onView: self)
             } */
            
        }) { (failure) in
            
        }
    }

}

