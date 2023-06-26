//
//  FirestoreController.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//
import Foundation
import FirebaseFirestore


class FirestoreController: ObservableObject {
    @Published var prkList = [Parking]()
    
    private let db: Firestore
    private static var shared: FirestoreController?
    
    private let COLLECTION_PARKING = "Parking"
    private let COLLECTION_USER_PROFILES = "UserProfiles"
    private let FIELD_USERCARLIST = "carPlateNumber"
   
    private let FIELD_BULDINGCODE = "buildingCode"
    private let FIELD_HOURSTOPARK = "hoursToPark"
    private let FIELD_LICENSEPLATE = "licensePlate"
    private let FIELD_SUITNUMBER = "suitNumber"
    private let FIELD_LOCATION = "location"
    private let FIELD_DATETIME = "dateTime"
    
    private let FIELD_NAME = "name"
    private let FIELD_CONTACTNUMBER = "contactNumber"
    private let FIELD_ADDRESS = "address"
    private let FIELD_CARPLATENumbers = "carPlateNumber"
    
    private var loggedInUserEmail: String = ""
    
    @Published var userProfile: UserProfile?
    
    init(db: Firestore) {
        self.db = db
    }
    
    // Singleton instance
    static func getInstance() -> FirestoreController {
        if self.shared == nil {
            self.shared = FirestoreController(db: Firestore.firestore())
        }
        return self.shared!
    }
    //Use this code below to use subcollections
    func insertParkingRecord(newParking: Parking) {
        print(#function, "Inserting parking record \(newParking.buildingCode)")
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't add employee")
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .collection(COLLECTION_PARKING)
                    .addDocument(from: newParking)
                
                print(#function, "Parking record \(newParking.buildingCode) successfully added to the database")
            } catch let error as NSError {
                print(#function, "Unable to add parking record to the database: \(error)")
            }
        }//do..catch
    }
    func updateParkingRecord(UpdateParking: Parking) {
        print(#function, "Inserting parking record \(UpdateParking.licensePlateNumber)")
        // Get the email address of the currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty {
            print(#function, "Logged in user's email address not available. Can't add employee")
        } else {
            self.db
                .collection(COLLECTION_USER_PROFILES)
                .document(self.loggedInUserEmail)
                .collection(COLLECTION_PARKING)
                .document(UpdateParking.id!)
                .updateData([
                    
                    FIELD_BULDINGCODE: UpdateParking.buildingCode,
                    FIELD_LICENSEPLATE: UpdateParking.licensePlateNumber,
                    FIELD_SUITNUMBER: UpdateParking.suitNumber     ,
                    FIELD_LOCATION: UpdateParking.parkingLocation
                ]) { error in
                    if let err = error {
                        print(#function, "Unable to update parking record in the database: \(err)")
                    } else {
                        print(#function, "Parking record \(UpdateParking.licensePlateNumber) successfully updated in the database")
                    }
                }
        }
    }
    func deleteParkingRecord(parkingToDelete: Parking) {
        print(#function, "Deleting parking record \(parkingToDelete.licensePlateNumber)")
        
        // Get the email address of the currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty {
            print(#function, "Logged in user's email address not available. Can't delete parking records")
        }  else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .collection(COLLECTION_PARKING)
                    .document(parkingToDelete.id!)
                    .delete { error in
                        if let err = error {
                            print(#function, "Unable to delete parking record from the database: \(err)")
                        } else {
                            print(#function, "Parking record \(parkingToDelete.licensePlateNumber) successfully deleted from the database")
                        }
                    }
            }catch let err as NSError{
                print(#function, "Unable to delete parking lot from database : \(err)")
            }
        }
    }
    func getAllParkingRecords() {
        print(#function, "Trying to get all parking records")
        
        // Get the email address of the currently logged in user
        //get the email address of currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't show Parking lots list")
        }
        else{
            do{
                self.db.collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .collection(COLLECTION_PARKING)
                    .addSnapshotListener { querySnapshot, error in
                        
                        guard let snapshot = querySnapshot else{
                            print(#function, "Unable to retrieve data from database : \(error)")
                            return
                        }
                        
                        snapshot.documentChanges.forEach { docChange in
                            do {
                                // Convert JSON document to Swift object
                                var prk: Parking = try docChange.document.data(as: Parking.self)
                                
                                let documentID = docChange.document.documentID
                                
                                prk.id = documentID
                                print(#function, "Document ID: \(documentID)")
                                //if new document added, perform required operations
                                if docChange.type == .added{
                                    self.prkList.append(prk)
                                    print(#function, "New document added : \(prk.buildingCode)")
                                }
                                
                                //get the index of any matching object in the local list for the firestore document that has been deleted or updated
                                let matchedIndex = self.prkList.firstIndex(where: { ($0.id?.elementsEqual(documentID))! })
                                
                                //if a document deleted, perform required operations
                                if docChange.type == .removed{
                                    print(#function, " document removed : \(prk.licensePlateNumber)")
                                    
                                    //remove the object for deleted document from local list
                                    if (matchedIndex != nil){
                                        self.prkList.remove(at: matchedIndex!)
                                    }
                                }
                                
                                //if a document updated, perform required operations
                                if docChange.type == .modified{
                                    print(#function, " document updated : \(prk.licensePlateNumber)")
                                    
                                    //update the existing object in local list for updated document
                                    if (matchedIndex != nil){
                                        self.prkList[matchedIndex!] = prk
                                    }
                                }
                                
                            }catch let err as NSError{
                                print(#function, "Unable to convert the JSON doc into Swift Object : \(err)")
                            }
                            
                        }//ForEach
                    }//addSnapshotListener
            } catch let error as NSError {
                print(#function, "Unable to get all employees from the database: \(error)")
            }//do..catch
        }//else
    }
    
    
    // MARK: SECTION ALL FUNCTION USER
    
    func createUserProfile(NewUserProfile: UserProfile) {
        print(#function, "Creating user profile")
        do{
            let docRef = db.collection(COLLECTION_USER_PROFILES).document(NewUserProfile.id!)
            try docRef.setData([
                FIELD_NAME : NewUserProfile.name,
                FIELD_CONTACTNUMBER : NewUserProfile.contactNumber,
                FIELD_ADDRESS : NewUserProfile.address, FIELD_CARPLATENumbers : NewUserProfile.carPlateNumber]){ error in
                }
            
            print(#function, "user \(NewUserProfile.name) successfully added to DB")
        }catch let error as NSError{
            print(#function, "Unable to add user to DB : \(error)")
        }
        
    }
    func updateUserProfile(userUpdate: UserProfile) {
        print(#function, "Updating user profile \(userUpdate.name)")
        
        // Get the email address of the currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty {
            print(#function, "Logged in user's email address not available. Can't update user profile.")
        } else {
            do {
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(userUpdate.id!)
                    .updateData(
                [FIELD_NAME :userUpdate.name,
                 FIELD_CONTACTNUMBER : userUpdate.contactNumber,
                FIELD_ADDRESS : userUpdate.address, FIELD_CARPLATENumbers :userUpdate.carPlateNumber ])
                { error in
                    if let error = error {
                        print(#function, "Unable to update user profile: \(error)")
                    } else {
                        print(#function, "User profile updated successfully")
                    }
                }
            } catch let error as NSError {
                print(#function, "Unable to update user profile: \(error)")
            }
        }
    }
    func deletedUserProfile(withCompletion completion: @escaping (Bool) -> Void) {
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (self.loggedInUserEmail.isEmpty){
            print(#function, "Logged in user's email address not available. Can't delete USER")
            DispatchQueue.main.async {
                completion(false)
            }
        }
        else{
            do{
                try self.db
                    .collection(COLLECTION_USER_PROFILES)
                    .document(self.loggedInUserEmail)
                    .delete{ error in
                        if let err = error {
                            print(#function, "Unable to delete user from database : \(err)")
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        }else{
                            print(#function, "user \(self.loggedInUserEmail) successfully deleted from database")
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                    }
            }catch let err as NSError{
                print(#function, "Unable to delete user from database : \(err)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func getUserProfile(withCompletion completion: @escaping (Bool) -> Void) {
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        let document = db.collection(COLLECTION_USER_PROFILES).document(self.loggedInUserEmail)
        
        document.addSnapshotListener { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                do {
                    if let userProfile = try document.data(as: UserProfile?.self) {
                        self.userProfile = userProfile
                        DispatchQueue.main.async {
                            completion(true)
                        }
                    }
                } catch {
                    
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func fetchUserProfile(completion: @escaping (Bool) -> Void) {
        // Get the email address of the currently logged in user
        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if self.loggedInUserEmail.isEmpty {
            print(#function, "Logged in user's email address not available. Can't fetch user profile.")
            completion(false)
            return
        } else {
            self.db
                .collection(COLLECTION_USER_PROFILES)
                .document(self.loggedInUserEmail)
                .getDocument { document, error in
                    if let document = document, document.exists {
                        do {
                            let userProfile = try document.data(as: UserProfile.self)
                            self.userProfile = userProfile
                            completion(true)
                        } catch let error as NSError {
                            print(#function, "Unable to decode user profile: \(error)")
                            completion(false)
                        }
                    } else {
                        print(#function, "User profile document does not exist")
                        completion(false)
                    }
                }
        }
    }
    
//    func getUserCarplateList(completion: @escaping ([String]) -> Void) {
//        print(#function, "Trying to get all user car plates")
//
//        // Get the email address of the currently logged in user
//        self.loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
//
//        if self.loggedInUserEmail.isEmpty {
//            print(#function, "Logged in user's email address not available. Can't retrieve user car plates.")
//            completion([])
//            return
//        }
//
//        self.db.collection(COLLECTION_USER_PROFILES)
//            .document(self.loggedInUserEmail)
//            .getDocument { document, error in
//
//                if let error = error {
//                    print(#function, "Unable to retrieve user car plates from the database: \(error)")
//                    completion([])
//                    return
//                }
//
//                if let data = document?.data(),
//                   let carPlateList = data[self.] as? [String] {
//                    print(#function, "Retrieved user car plates successfully: \(carPlateList)")
//                    completion(carPlateList)
//                } else {
//                    print(#function, "User car plate data not found")
//                    completion([])
//                }
//            }
//    }

}
    

    




