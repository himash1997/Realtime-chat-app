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
                NavigationView{
                    
                    Home()
                     .environmentObject(MainObservable())
                    
                }.navigationViewStyle(StackNavigationViewStyle())
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View{
//        ContentView()
//    }
//}

class MainObservable: ObservableObject{
    @Published var recents = [Recent]()
    @Published var norecent = false
    
    init() {
        
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("users").document(uid!).collection("recents").order(by: "date", descending: true).addSnapshotListener { (snap, err) in
            
            if err != nil{
                print("error >>>>" + (err?.localizedDescription)!)
                self.norecent = true
                return
            }
            
            if snap!.isEmpty{
                self.norecent = true
            }
            
            for i in snap!.documentChanges{
                
                let id = i.document.documentID
                let name = i.document.get("name") as! String
                let pic = i.document.get("pic") as! String
                let lastmsg = i.document.get("lastmsg") as! String
                let stamp = i.document.get("date") as! Timestamp
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yy"
                let date = formatter.string(from: stamp.dateValue())
                
                formatter.dateFormat = "hh:mm a"
                let time = formatter.string(from: stamp.dateValue())
                
                self.recents.append(Recent(id: id, name: name, pic: pic, lastmsg: lastmsg, time: time, date: date, stamp: stamp.dateValue()))
                
            }
            
        }
        
        
    }
    
}

struct Recent : Identifiable {
    
    var id : String
    var name : String
    var pic : String
    var lastmsg : String
    var time : String
    var date : String
    var stamp : Date
    
}
