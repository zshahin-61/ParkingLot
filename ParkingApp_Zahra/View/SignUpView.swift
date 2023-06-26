//
//  SignUpView.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper : FirestoreController
    
    
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var confirmPassword : String = ""
    
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var carPlateNumber: String = ""
    @State private var carList : [String] = [String]()
    @State private var errorMsg : String? = nil
    
    @Binding var rootScreen : RootView
    
    var body: some View {
        VStack{
            Form{
                TextField("Enter Email", text: self.$email)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Enter Password", text: self.$password)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Confirm Password", text: self.$confirmPassword)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Enter Name", text: self.$name)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Enter Address", text: self.$address)
                    .textInputAutocapitalization(.words)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Enter Phone Number", text: self.$phoneNumber)
                    .keyboardType(.phonePad)
                    .textFieldStyle(.roundedBorder)
                
                Section(header: Text("Car Plate Number List")){
                    HStack{
                        TextField("Enter a car plate number", text: self.$carPlateNumber)
                        Spacer()
                        Button(action:{
                            if(validateCarPlateNumber(self.carPlateNumber)){
                                carList.append(self.carPlateNumber)
                                self.errorMsg = nil
                                self.carPlateNumber = ""
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
                    }
                    List{
                        ForEach(carList, id: \.self) { cpn in
                            Text(cpn)
                        }.onDelete(perform: { indexSet in
                            for index in indexSet{
                                carList.remove(at: index)

                            }
                            
                        })//onDelete
                    }
                }
            }
            .autocorrectionDisabled(true)
            
            HStack{
                Button(action: {
                    self.authHelper.signUp(email: self.email.lowercased(), password: self.password, withCompletion: { isSuccessful in
                        if (isSuccessful){
                            let user : UserProfile = UserProfile(id: self.email.lowercased(), name: self.name, contactNumber: self.phoneNumber, address: self.address, carPlateNumber: carList)
                            self.dbHelper.createUserProfile(NewUserProfile: user)
                            
                            //show to home screen
                            self.rootScreen = .Home
                        }else{
                            //show the alert with invalid username/password prompt
                            print(#function, "unable to create user")
                        }
                    })
                }){
                    Text("Create Account")
                }.buttonStyle(.borderedProminent)
                    .disabled(self.password != self.confirmPassword || self.email.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty)
                Spacer()
                Button(action:{
                    self.rootScreen = .Login
                }){
                    Text("Back to Login").buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    func validateCarPlateNumber(_ input: String) -> Bool {
        let pattern = "^[a-zA-Z0-9]{2,8}$"
        let regex = NSPredicate(format: "SELF MATCHES %@", pattern)
        return regex.evaluate(with: input)
    }
}
