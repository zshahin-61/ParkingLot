//
//  DetailView.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//

import SwiftUI

struct DetailView: View {
    
    let selectedCar : Int

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dbHelper : FirestoreController
    @EnvironmentObject var authHelper : FireAuthController
    
    @State private var carList : [String] = [String]()
    @State private var selecteditem : String = ""
      @State private var buildingCode = ""
      @State private var parkingDuration = 0
      @State private var licensePlateNumber = ""
      @State private var suitNumber = ""
      @State private var parkingLocation = ""
    @State private var addCarPlateNumber : String = ""
    @State private var errMsg : String? = nil

    
      var body: some View {
          VStack {
              List {
                  Section(header: Text("Building Code")) {
                      TextField("Enter building code (5 characters)", text: $buildingCode)
                  }
                  
                  Picker("Hours to Stay:", selection: self.$parkingDuration){
                      Text("1-hour or less").tag(1)
                      Text("4-hour").tag(4)
                      Text("12-hour").tag(12)
                      Text("24-hour").tag(24)
                  }
                  
                  Picker("Car Plate Numbers", selection:$selecteditem) {
                      Text("----SELECT----").tag("NOT_SELECTED")
                      ForEach(self.carList, id: \.self) { cpNum in
                          Text(cpNum).tag(cpNum)
                      }
                  }
                  
                  TextField("New car plate number (2-8 alphanumeric)", text: self.$addCarPlateNumber)
                  
                  TextField("Suit no. of host (2-5 alphanumeric)", text: self.$suitNumber)
                  
                  TextField("Location", text: self.$parkingLocation)
              }
              
                  Button(action:{
                      errMsg = nil
                      if(!validateBuildingCode(self.buildingCode) && !self.buildingCode.isEmpty){
                          errMsg = "Invalid building code"
                          return
                      }
                      
                      if(self.addCarPlateNumber.isEmpty && self.selecteditem == "NOT_SELECTED"){
                          errMsg = "Enter / Select a valid car plate number"
                          return
                      }
                      
                      if(!self.addCarPlateNumber.isEmpty && !validateCarPlateNumber(self.addCarPlateNumber)){
                          errMsg = "Invalid car plate number"
                          return
                      }
                      
                      if(!validateSuitNo(self.suitNumber) && !self.suitNumber.isEmpty){
                          errMsg = "Invalid suit number"
                          return
                      }
                      
                      var plateNumberToSave = ""
                      if(!self.addCarPlateNumber.isEmpty){
                          plateNumberToSave = self.addCarPlateNumber
                          
                          dbHelper.userProfile!.carPlateNumber.append(plateNumberToSave)
                          dbHelper.updateUserProfile(userUpdate: dbHelper.userProfile!)
                          
                      }else{
                          plateNumberToSave = self.selecteditem
                      }
                      
                      self.dbHelper.prkList[selectedCar].buildingCode = self.buildingCode
                      self.dbHelper.prkList[selectedCar].licensePlateNumber = plateNumberToSave
                      self.dbHelper.prkList[selectedCar].parkingDuration = self.parkingDuration
                      self.dbHelper.prkList[selectedCar].parkingLocation = self.parkingLocation
                      self.dbHelper.prkList[selectedCar].suitNumber = self.suitNumber
                      
                      //update existing parking lot
                      self.dbHelper.updateParkingRecord(UpdateParking:  self.dbHelper.prkList[selectedCar])
                  
                      dismiss()
                      
                  }){
                      Text("add Parking")
                  }.buttonStyle(.borderedProminent).disabled((self.addCarPlateNumber.isEmpty && self.selecteditem == "NOT_SELECTED") || self.buildingCode.isEmpty)
                  
                  if let err = errMsg{
                      Text(err).foregroundColor(Color.red).bold()
                  }
              }.onAppear(){
                  //show existing information about employee on the form
                  let selectedParking : Parking = self.dbHelper.prkList[selectedCar]
                  
                  self.buildingCode = selectedParking.buildingCode
                  self.parkingDuration = selectedParking.parkingDuration
                  self.parkingLocation = selectedParking.parkingLocation
                  self.selecteditem = selectedParking.licensePlateNumber
                  self.addCarPlateNumber = ""
                  self.suitNumber = selectedParking.suitNumber
                  
                  dbHelper.getUserProfile(withCompletion: { isSuccessful in
                      if (isSuccessful){
                          self.carList = dbHelper.userProfile!.carPlateNumber
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
