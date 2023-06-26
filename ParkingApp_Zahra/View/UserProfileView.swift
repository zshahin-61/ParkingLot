//
//  UserProfileView.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    @Environment(\.dismiss) var dismiss

    @State private var selectedCarPlateNumber: String = ""
    @State private var emailFromUI : String = ""
    @State private var nameUI: String = ""
    @State private var AddressUI: String = ""
    @State private var contactNumberUI: String = ""
    @State private var carPlateNumberUI: String = ""
    
    @State private var CarPlateList : [String] = [String]()
    @State private var errorMsg : String? = nil
    @State private var selectedLink : Int? = nil
    @State private var showAlert = false
    @Binding var rootScreen : RootView
    
    var body: some View {
        VStack {
            Form{
            TextField("Name", text: $nameUI)
                .padding()
            
            TextField("Address", text: $AddressUI)
                .padding()
        
            
            TextField("Contact Number", text: $contactNumberUI)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
                Section(header: Text("Car Plate Number List")){
                    TextField("Enter a car plate number", text: self.$carPlateNumberUI)
            
            Button(action: {
                if(validateCarPlateNumber(self.carPlateNumberUI)){
                    CarPlateList.append(self.carPlateNumberUI)
                    self.errorMsg = nil
                    self.carPlateNumberUI = ""
                }
                else{
                    self.errorMsg = "Invalid Car Plate Number"
                }
            }){
                Text("Add")
            }
            
            if let err = errorMsg{
                Text(err).foregroundColor(Color.red).bold()
            }
            
            List{
                ForEach(CarPlateList, id: \.self) { cpn in
                    Text(cpn)
                }.onDelete(perform: { indexSet in
                    for index in indexSet{
                        if(dbHelper.prkList.contains(where: {$0.licensePlateNumber == CarPlateList[index]})){
                            errorMsg = "this car plate number can not be deleted form the list. you have parked somewhere :))"
                            return
                            //
                        }
                        CarPlateList.remove(at: index)
                        
                    }
                    
                })//onDelete
            }
        }
    }
    .autocorrectionDisabled(true)
    
    //HStack{
        Button(action: {
           
            dbHelper.userProfile!.address = AddressUI
            dbHelper.userProfile!.carPlateNumber = CarPlateList
            dbHelper.userProfile!.name = nameUI
            dbHelper.userProfile!.contactNumber = contactNumberUI
            
            self.dbHelper.updateUserProfile(userUpdate: dbHelper.userProfile!)
            
            dismiss()
        }){
            Text("Update Profile")
        }.buttonStyle(.borderedProminent)
        
        NavigationLink(destination: SignInView(rootScreen: $rootScreen).environmentObject(authHelper).environmentObject(dbHelper),tag: 1, selection: self.$selectedLink ){}
        Spacer()
        Button(action:{
            if(dbHelper.prkList.count > 0)
            {
                //errorMsg = "before deleting your account you have to remove all cars in parking lots"
                self.showAlert = true
                return
            }
            
            self.dbHelper.deletedUserProfile(withCompletion: { isSuccessful in
                if (isSuccessful){
                    self.authHelper.deleteAccountFromAuth()
                    //sign out using Auth
                    self.authHelper.signOut()
                    
                    self.selectedLink = 1
                    //dismiss current screen and show login screen
                    //self.rootScreen = .Login
                }
            })
            }){
                Image(systemName: "multiply.circle").foregroundColor(Color.white)
            Text("Delete User Account")
            }.padding(5).font(.title2).foregroundColor(Color.white)//
        .buttonBorderShape(.roundedRectangle(radius: 15)).buttonStyle(.bordered).background(Color.red)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error :"),
                message: Text("before deleting your account you have to remove all cars in parking lots"),
                dismissButton: .default(Text("OK")){
                    //dismiss()
                }
            )
        }
    
}.padding().onAppear(){
    dbHelper.getUserProfile(withCompletion: { isSuccessful in
        if (isSuccessful){
            self.emailFromUI = dbHelper.userProfile!.id!
            self.AddressUI = dbHelper.userProfile!.address
            self.nameUI = dbHelper.userProfile!.name
            self.carPlateNumberUI = ""
            self.CarPlateList = dbHelper.userProfile!.carPlateNumber
            self.contactNumberUI = dbHelper.userProfile!.contactNumber
            self.errorMsg = nil
        }
    })
}
}

func validateCarPlateNumber(_ input: String) -> Bool {
let pattern = "^[a-zA-Z0-9]{2,8}$"
let regex = NSPredicate(format: "SELF MATCHES %@", pattern)
return regex.evaluate(with: input)
}
}
