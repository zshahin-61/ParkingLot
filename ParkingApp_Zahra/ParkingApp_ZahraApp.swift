//
//  ParkingApp_ZahraApp.swift
//  ParkingApp_Zahra
//
//  Created by zahra SHAHIN on 2023-06-23.
//
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


@main
struct ParkingApp_ZahraApp: App {
    let authHelper = FireAuthController()

    init(){
        //configure Firebase in the project
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authHelper)
        }
    }
}
