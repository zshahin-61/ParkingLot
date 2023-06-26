//
//  NewParkingView.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//

import SwiftUI

struct NewParkingView: View {
    
    @EnvironmentObject var dbHelper : FirestoreController
    @EnvironmentObject var authHelper : FireAuthController
    @Environment(\.dismiss) var dismiss
    @State private var buildingCodeUI:String = ""
    @State private var parkingDuration:Int = 0
    @State private var licensePlateNumberUI:String = ""
    @State private var suitNumberUI:String = ""
    @State private var parkingLocationUI:String = ""
    @State private var selectedCarPlateNumber:String = ""
    @State private var CarList : [String] = [String]()
    @State private var addnewPlateNumber:String = ""
    let availableDurations = ["1-hour or less", "4-hour", "12-hour", "24-hour"]
    @State private var errMsg : String? = nil
    
    var body: some View {
        VStack {
            List {
                
                TextField("5 characters building Code", text: $buildingCodeUI)
                 
                Picker("Select parking duration", selection: $parkingDuration) {
                    Text("1-hour or less").tag(1)
                    Text("4-hour").tag(4)
                    Text("12-hour").tag(12)
                    Text("24-hour").tag(24)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                
                Picker("Select Car Plate", selection: $selectedCarPlateNumber) {
                    
                    Text(" select").tag("NOTHING")
                    ForEach(self.CarList, id: \.self) { plateNumber in
                        Text(plateNumber).tag(plateNumber)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                TextField("plate number 2-8 alphanumeric", text: self.$addnewPlateNumber)
                
                TextField("Suit Number (2-5 characters)", text: $suitNumberUI)
                
                
                TextField("Parking Location", text: $parkingLocationUI)
                
            
            }
            
            
            Button(action:{
                errMsg = nil
                
                var plateNumberToSave = ""
                if(!self.addnewPlateNumber.isEmpty){
                    plateNumberToSave = self.addnewPlateNumber
                    
                    dbHelper.userProfile!.carPlateNumber.append(plateNumberToSave)
                    dbHelper.updateUserProfile(userUpdate: dbHelper.userProfile!)
                    
                }else{
                    plateNumberToSave = self.selectedCarPlateNumber
                }
                
                let parkingEntry = Parking(
                    buildingCode: buildingCodeUI,
                    parkingDuration: parkingDuration,
                    licensePlateNumber: licensePlateNumberUI,
                    suitNumber: suitNumberUI,
                    parkingLocation: parkingLocationUI,
                    dateTime: Date()
                )
                self.dbHelper.insertParkingRecord(newParking: parkingEntry)
                //return to privious screen
                dismiss()
                
            }){
                Text("Add  Parking")
            }.buttonStyle(.borderedProminent).disabled((self.addnewPlateNumber.isEmpty && self.selectedCarPlateNumber == "") || self.buildingCodeUI.isEmpty)
            if let err = errMsg{
                Text(err).foregroundColor(Color.red).bold()
            }
            Spacer()
        }.onAppear(){
            dbHelper.getUserProfile(withCompletion: { isSuccessful in
                if (isSuccessful){
                    self.CarList = dbHelper.userProfile!.carPlateNumber
                    
                }
            })
        }
    }
    
    func validateBuildingCode(_ input: String) -> Bool {
        let pattern = "^[a-zA-Z0-9]{5}$"
        let regex = NSPredicate(format: "SELF MATCHES %@", pattern)
        return regex.evaluate(with: input)
    }
    
    func validateCarPlateNumber(_ input: String) -> Bool {
        let pattern = "^[a-zA-Z0-9]{2,8}$"
        let regex = NSPredicate(format: "SELF MATCHES %@", pattern)
        return regex.evaluate(with: input)
    }
    
    func validateSuitNo(_ input: String) -> Bool {
        let pattern = "^[a-zA-Z0-9]{2,5}$"
        let regex = NSPredicate(format: "SELF MATCHES %@", pattern)
        return regex.evaluate(with: input)
    }
    
}
