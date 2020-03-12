//
//  ContentView.swift
//  Realtime chat app
//
//  Created by Himash Nadeeshan on 3/11/20.
//  Copyright © 2020 Himash Nadeeshan. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ContentView: View {
    
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ??  false
    
    var body: some View {
        VStack{
            if status{
                Home()
            }else{
                NavigationView{
                    Getnumber()
                }.navigationViewStyle(StackNavigationViewStyle())
            }
        }.onAppear{
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "statusChange"), object: nil, queue: .main) { (_) in
                let status = UserDefaults.standard.value(forKey: "status") as? Bool ??  false
                self.status = status
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View{
        ContentView()
    }
}
