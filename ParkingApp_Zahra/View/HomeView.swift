//
//  HomeView.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//


import SwiftUI


struct HomeView: View {
    @EnvironmentObject var authHelper: FireAuthController
    @EnvironmentObject var dbHelper: FirestoreController
    
    @Binding var rootScreen: RootView
    
    @State private var selectedLink : Int? = nil

    var body: some View {
        
            ZStack(alignment: .bottom){
                List{
                    if (self.dbHelper.prkList.isEmpty){
                        Text("The List Is Empty!")
                    }else{
                        
                        ForEach(self.dbHelper.prkList.enumerated().map({$0}), id: \.element.self){index, prk in
                            
                            NavigationLink{
                                DetailView(selectedCar: index).environmentObject(self.dbHelper)
                            }label:{
                                HStack{
                                    Text("\(prk.licensePlateNumber)")
                                        .bold()
                                    Spacer()
                                    Text("\(formatDate(prk.dateTime))")
                                    
                                }//HStack
                            }//Navigation Link
                            
                        }//ForEach
                        .onDelete(perform: { indexSet in
                            for index in indexSet{
                                //get the employee object to delete
                                let prk = self.dbHelper.prkList[index]
                                
                                //delete the document from database
                                self.dbHelper.deleteParkingRecord(parkingToDelete: prk)
                            }
                            
                        })//onDelete
                        
                    }//else
                }//List
                NavigationLink{
                    NewParkingView().environmentObject(self.dbHelper)
                }label:{
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 60, height:60, alignment: .bottom)
                        .foregroundColor(Color.blue)
                }
            // Spacer()
            }//ZStack
            .onAppear(){
                //remove old data from list
                self.dbHelper.prkList.removeAll()
                
                //fetch all documents from database
                self.dbHelper.getAllParkingRecords()
            }
            
            //.navigationTitle("Parking Lots Info")
        
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    NavigationLink(destination: UserProfileView(rootScreen: self.$rootScreen).environmentObject(authHelper).environmentObject(dbHelper), tag: 1, selection: self.$selectedLink){}
                        
                    Button(action: {
                        self.selectedLink = 1
                    }, label: {
                        Image(systemName: "person.badge.shield.checkmark.fill").foregroundColor(Color.blue)
                        Text("Profile")
                    })
                    Button(action: {
                        //sign out using Auth
                        self.authHelper.signOut()
                        
                        //dismiss current screen and show login screen
                        self.rootScreen = .Login
                        
                    }, label: {
                        Image(systemName: "person.badge.key.fill").foregroundColor(Color.blue)
                        Text("Sign out")
                    })
                }
            }//toolbar
        
    }
    
    func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: date)
    }
    
}




    
   






