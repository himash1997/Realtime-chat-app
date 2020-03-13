//
//  Home.swift
//  Realtime chat app
//
//  Created by Himash Nadeeshan on 3/12/20.
//  Copyright © 2020 Himash Nadeeshan. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct Home : View {
    
    @State var myuid = UserDefaults.standard.value(forKey: "UserName") as! String
    @EnvironmentObject var data : MainObservable
    
    @State var show = false
    @State var chat = false
    @State var uid = ""
    @State var name = ""
    @State var pic = ""
    
    var body: some View{
        
        VStack{

            if self.data.recents.count == 0{

                    Indicator()

            }
            else{

                ScrollView(.vertical, showsIndicators: false) {

                    VStack(spacing: 12){

                        ForEach(data.recents){i in

                            RecentCellView(url: i.pic, name: i.name, time: i.time, date: i.date, lastmsg: i.lastmsg)

                        }

                    }.padding()
                }
            }
        }.navigationBarTitle("Home",displayMode: .inline)
          .navigationBarItems(leading:

              Button(action: {

                UserDefaults.standard.set("", forKey: "UserName")
                UserDefaults.standard.set("", forKey: "UID")
                UserDefaults.standard.set("", forKey: "pic")

                try! Auth.auth().signOut()

                UserDefaults.standard.set(false, forKey: "status")

                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)

              }, label: {

                  Text("Sign Out")
              })

              , trailing:

              Button(action: {
                
                self.show.toggle()

              }, label: {

                  Image(systemName: "square.and.pencil").resizable().frame(width: 25, height: 25)
              }
          )

        ).sheet(isPresented: self.$show) {
            NewChatView()
        }
    }
}

struct RecentCellView: View{
    
    var url : String
    var name : String
    var time : String
    var date : String
    var lastmsg : String
    
    var body : some View{
        HStack{
            AnimatedImage(url: URL(string: url)!)
            .resizable()
            .renderingMode(.original)
            .frame(width: 55, height: 55)
            .clipShape(Circle())
            
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        Text(name)
                        Text(lastmsg)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 6){
                        Text(date).foregroundColor(.gray)
                        Text(time).foregroundColor(.gray)
                    }
                }
                Divider()
            }
            
        }
    }
}


struct NewChatView : View {
    
    @ObservedObject var data = GetAllUsers()
    
    var body : some View{
        VStack(alignment: .leading){
            
            VStack{
                
                Text("Select To Chat")
                .font(.title)
                .foregroundColor(Color.black.opacity(0.5))
                .padding()

                if self.data.users.count == 0{

                        Indicator()

                }
                else{

                    ScrollView(.vertical, showsIndicators: false) {

                        VStack(spacing: 12){

                            ForEach(data.users){i in
                                
                                Button(action: {
                                    
                                }, label: {
                                    UserCellView(url: i.pic, name: i.name, about: i.about)
                                } )

                            }

                        }
                    }
                }
            }.padding(.horizontal)
            
        }
    }
}

class GetAllUsers : ObservableObject{
    
    @Published var users = [User]()
    
    init() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snap, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            for i in snap!.documents{
                let id = i.documentID
                let name = i.get("name") as! String
                let pic = i.get("pic") as! String
                let about = i.get("about") as! String
                
                self.users.append(User(id: id, name: name, pic: pic, about: about))
                
            }
        }
    }
    
}

struct User: Identifiable {
    var id: String
    var name: String
    var pic: String
    var about: String
}

struct UserCellView: View{
    
    var url : String
    var name : String
    var about : String

    
    var body : some View{
        HStack{
            AnimatedImage(url: URL(string: url)!)
                .resizable()
                .renderingMode(.original)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        Text(name)
                            .foregroundColor(.black)
                        Text(about)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                Divider()
            }
            
        }
    }
}
