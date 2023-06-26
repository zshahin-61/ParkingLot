//
//  Parking.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//

import Foundation
import FirebaseFirestoreSwift

struct Parking: Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    
    var buildingCode: String
    var parkingDuration: Int
    var licensePlateNumber: String
    var suitNumber: String
    var parkingLocation: String
    var dateTime: Date
    
    init?(dictionary : [String : Any])
    {
        guard let buildingCode = dictionary["buildingCode"] as? String else{
            print(#function, "Unable to get buildingCode from JSON")
            return nil
        }
        
        
        guard let parkingDuration = dictionary["parkingDuration"] as? Int else{
            print(#function, "Unable to get parkingDuration  from JSON")
            return nil
        }
        
        guard let licensePlateNumber = dictionary["licensePlateNumber"] as? String else{
            print(#function, "Unable to get licensePlateNumber from JSON")
            return nil
        }
        
        guard let suitNumber = dictionary["suitNumber"] as? String else{
            print(#function, "Unable to get suitNumber  from JSON")
            return nil
        }
        
        guard let parkingLocation = dictionary["parkingLocation"] as? String else{
            print(#function, "Unable to get parkingLocation from JSON")
            return nil
        }
        
        guard let dateTime = dictionary["dateTime"] as? Date else{
            print(#function, "Unable to get dateTime  from JSON")
            return nil
        }
        self.init(buildingCode: buildingCode, parkingDuration: parkingDuration, licensePlateNumber: licensePlateNumber, suitNumber: suitNumber, parkingLocation: parkingLocation, dateTime: dateTime)
        
    }
   
        
    init(buildingCode: String, parkingDuration: Int, licensePlateNumber: String, suitNumber: String, parkingLocation: String, dateTime: Date){
        self.buildingCode = buildingCode
        self.parkingDuration = parkingDuration
        self.licensePlateNumber = licensePlateNumber
        self.suitNumber = suitNumber
        self.parkingLocation = parkingLocation
        self.dateTime = dateTime
    }
    
    
    func showInfo() {
        print("Parking Info --------- \n " +
              "Building Code: \(self.buildingCode) \n " +
              "Parking Duration: \(self.parkingDuration) \n " +
              "License Plate Number: \(self.licensePlateNumber) \n " +
              "Suit Number: \(self.suitNumber) \n " +
              "Parking Location: \(self.parkingLocation) \n " +
              "Date and Time: \(self.dateTime) \n")
    }
}






