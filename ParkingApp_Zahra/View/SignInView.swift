//
//  SignInView.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authHelper : FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController

    @State private var email : String = ""
    @State private var password : String = ""
   // @State private var linkSelection : Int? = nil

    @Binding var rootScreen : RootView
    
    private let gridItems : [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        //        NavigationView{
        
        VStack{
            
//            NavigationLink(destination: SignUpView().environmentObject(self.authHelper).environmentObject(self.dbHelper), tag: 1, selection: self.$linkSelection) {
//
//            }
            
            
            Form{
                TextField("Enter Email", text: self.$email)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Enter Password", text: self.$password)
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)
            }
            .autocorrectionDisabled(true)
            
            LazyVGrid(columns: self.gridItems){
                Button(action: {
                    //validate the data
                    
                    //sign in using Firebase Auth
                    self.authHelper.signIn(email: self.email, password: self.password, withCompletion: { isSuccessful in
                        if (isSuccessful){
                            //show to home screen
                            self.rootScreen = .Home
                        }else{
                            //show the alert with invalid username/password prompt
                            print(#function, "invalid username/password")
                        }
                    })
                    
                }){
                    Text("Sign In")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .background(Color.blue)
                }
                
                Button(action: {
                    //take user to SignUp screen
                    self.rootScreen = .SignUp


                }){
                    
                    Text("Sign Up")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .background(Color.blue)
                }
            }//LazyVGrid
        }//VStack
        //        }//Navigation View
        
    }
}

