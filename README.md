# Single-Device-Multiple-Users-Accounts-CoreData-App (iOS)

This demo project enables an iOS app with Core Data and Cloud Kit capabilities and multiple user accounts on an iphone/ipad.

## Requirements

  - Xcode 15 or later
  - iOS 16 or later

## Steps and Configuration
    
  - Comment out the following properties/methods default code setup in App Delegate for Core Data:
    - persistentContainer computed property
    - saveContext method
      
  - For persistentContainer property, we use an instance of LazyContainer class, type annotated with NSPersistentCloudKitContainer. Refer AppDelegate.
     - ```var persistentContainer = LazyContainer<NSPersistentCloudKitContainer> { (email: String) -> NSPersistentCloudKitContainer in }```
   
  - To initialize this property and set it up, logged in user email string is required. So, the container property is setup only once user successfully logs in.
    
  - In ViewController class, once user taps on login button, invoke AppDelegate method: `setupContainer()`. Refer AppDelegate.
    - The setupContainer() calls the persistentContainer computed property and loads persistent store.
    - Add method to get NSPersistentStoreDescription utilizing email and sandbox's .sqlite db file url, as well.
   
  - At this point, persistentContainer is fully initialized.
    
  - Declare a Managed Object Context propoerty using the `container.viewContext` property. Refer AppDelegate.
    
  - To reset the persistent container, for example on logout, use resetContainer() method in App Delegate. Refer AppDelegate.
  
    Note: The `NSPersistentCloudKitContainer` class is a subclass of `NSPersistentContainer` and is capable of handling both cloud and noncloud stores.

  - LocalDatabaseManager class does three core data operations:
    
    - Backup persistent store using backup method.
   
    - Restore persistent store to replace in-use database with a backed up one.
   
    - Reset persistent store to clear all contents of the in-use database.
   
      Note: All these operations are performed while user is still inside the app.

## Usage

  ### Login
  
  - On user signin success, email is stored in User Defaults. This helps to auto-login user next time.
    
  - On signout, persistent container is cleared, the database associated files are stored in sandbox inside a folder named after each user's emailid, and there is no need to close or relaunch the app.
    
  - On signing with new email, new containner property is initialized with that email. Folder is created in Application Support directory and each user has separate database file.

 ### How to use this Demo

   - On signing in, the view controller that opens up has 3 buttons and a table view:
     - Backup button
     - Reset button
     - Edit button
    
   - `Backup` button - backs up current state of database files, for the logged in user, inside the sandbox `Documents` directory.

   - `Reset` Button - reset the current database in use inside the Application Support directory and clears all its contents.

   - `Edit` Button - takes you to another view where you can add data to the database. For demo purpose, we have a Student entity with 1. roll number and 2. Full name fields only.

   - A `table view` below the above buttons shows the list of backed up databases from the sandbox Documents directory.
     
     - Each table View row supports 2 `swipe operations`: 1. Delete and 2. Restore
    
       1. `Delete` action deletes the backup database corresponding to that row.
      
       2. `Restore` action replaces the current in-use database file with that backed up db.
      
     - To check restore worked property, we can go to the Edit screen and check the list of records.
    
     - Screenshots:
        ![Login](https://github.com/saushar/Single-Device-Multiple-Users-Accounts-CoreData-App-iOS/assets/49163871/eef94c6d-8e54-4897-a690-51fa84c724bd)
        ![Backup](https://github.com/saushar/Single-Device-Multiple-Users-Accounts-CoreData-App-iOS/assets/49163871/2c475534-5372-4c6c-a53e-8cf4009e52ad)
        ![Edit](https://github.com/saushar/Single-Device-Multiple-Users-Accounts-CoreData-App-iOS/assets/49163871/e05b71ae-d3ac-489b-96d3-b5d4c31f4d8b)
       

### Adapting the code to your own requirements

  - For replicating the core fucntionality, all that you will need:
    
    1. AppDelegate class code

    2. LazyContainer class

    3. LocalDatabaseManager class
    
### Summary
  
  - Backup / Restore / Reset persistent stores withoug signing out and instantly.
  
  - Use CloudKit along side CoreData to sync data to the Cloud.

  - Enable multiple user accounts for your app on a single iOS device or simulator.

