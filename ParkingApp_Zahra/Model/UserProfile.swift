//
//  UserProfile.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//

import Foundation

import FirebaseFirestoreSwift

struct UserProfile : Codable, Hashable{
    
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var contactNumber: String
    var address: String
    var carPlateNumber: [String] = [String]()
    
    init?(dictionary : [String : Any]){
        
        guard let id = dictionary["id"] as? String else{
            print(#function, "Unable to get user ID from JSON")
            return nil
        }
        
        guard let Name = dictionary["Name"] as? String else{
            print(#function, "Unable to get user Name from JSON")
            return nil
        }

        guard let contactNumber = dictionary["contactNumber"] as? String else{
            print(#function, "Unable to get contactNumber from JSON")
            return nil
        }

        guard let address = dictionary["address"] as? String else{
            print(#function, "Unable to get address from JSON")
            return nil
        }
        guard let carPlateNumber = dictionary["carPlateNumber"] as? [String] else{
            print(#function, "Unable to get carPlateNumber from JSON")
            return nil
        }

        self.init( id: id, name: Name, contactNumber: contactNumber, address: address, carPlateNumber: carPlateNumber)
    }
    
    init(id: String, name: String, contactNumber: String, address: String, carPlateNumber: [String]) {
        self.id = id
        self.name = name
        self.contactNumber = contactNumber
        self.address = address
        self.carPlateNumber = carPlateNumber
    }
    
    
}
