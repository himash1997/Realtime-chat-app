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
        
        ZStack{
            NavigationLink(destination: ChatView(name: self.name, pic: self.pic, uid: self.uid, chat: self.$chat), isActive: self.$chat) {
                Text("")
            }
            
            VStack{

                       if self.data.recents.count == 0{
                               
                            if self.data.norecent {
                                Text("No Chat History")
                                
                            }else{
                                Indicator()
                        }
                        
                       }
                       else{
                           ScrollView(.vertical, showsIndicators: false) {
                               VStack(spacing: 12){
                                   
                                ForEach(data.recents.sorted(by: {$0.stamp > $1.stamp })){i in
                                    Button(action: {
                                        
                                        self.uid = i.id
                                        self.name = i.name
                                        self.pic = i.pic
                                        self.chat.toggle()
                                        
                                    }) {
                                        RecentCellView(url: i.pic, name: i.name, time: i.time, date: i.date, lastmsg: i.lastmsg)
                                    }
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

                )
            
        }
       .sheet(isPresented: self.$show) {
        NewChatView(name: self.$name, uid: self.$uid, pic: self.$pic, show: self.$show, chat: self.$chat)
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
            
//            AnimatedImage(url: URL(string: url)!)
//            .resizable()
//            .renderingMode(.original)
//            .frame(width: 55, height: 55)
//            .clipShape(Circle())
//
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 6){
                        Text(name)
                            .foregroundColor(.black)
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
    @Binding var name : String
    @Binding var uid : String
    @Binding var pic : String
    @Binding var show : Bool
    @Binding var chat : Bool
    
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
                                    
                                    self.uid = i.id
                                    self.name = i.name
                                    self.pic = i.pic
                                    self.show.toggle()
                                    self.chat.toggle()
                                    
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
                
                if id != UserDefaults.standard.value(forKey: "UID") as! String{
                    self.users.append(User(id: id, name: name, pic: pic, about: about))
                }
                
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

import SwiftUI

struct KeyboardResponsiveModifier: ViewModifier {
  @State private var offset: CGFloat = 0

  func body(content: Content) -> some View {
    content
      .padding(.bottom, offset)
      .onAppear {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
          let value = notif.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
          let height = value.height
          let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom
          self.offset = height - (bottomInset ?? 0)
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notif in
          self.offset = 0
        }
    }
  }
}

extension View {
  func keyboardResponsive() -> ModifiedContent<Self, KeyboardResponsiveModifier> {
    return modifier(KeyboardResponsiveModifier())
  }
}

struct ChatView: View {
    
    var name : String
    var pic : String
    var uid : String
    @Binding var chat : Bool
    
    @State var msgs = [Msg]()
    @State var txt = ""
    @State var nomsg = false
    
    var body: some View{
        
        VStack{
            if msgs.count == 0{
                
                if nomsg{
                    Text("Start New Conversation")
                        .opacity(0.5)
                        .padding()
                    Spacer()
                }else{
                    
                    Spacer()
                    Indicator()
                    Spacer()
                }
                
            }else{
                ScrollView(.vertical, showsIndicators: false){
                    VStack{
                        ForEach(self.msgs){i in
                            
                            HStack{
                                if i.user == UserDefaults.standard.value(forKey: "UID") as! String{
                                    Spacer()
                                    
                                    Text(i.msg)
                                        .padding()
                                        .background(Color("Color-1"))
                                        .clipShape(ChatBubble(mymsg: true))
                                        .foregroundColor(Color.white)
                                        .padding(4)
                                    
                                }else{
                                    Text(i.msg)
                                    .padding()
                                    .background(Color.blue)
                                    .clipShape(ChatBubble(mymsg: true))
                                    .foregroundColor(Color.white)
                                    .padding(4)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            
            HStack(){
                
                TextField("Enter Message", text: self.$txt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                Button(action: {
                    
                    sendMsg(user: self.name, uid: self.uid, pic: self.pic, date: Date() , msg: self.txt)
                    self.txt = ""
                    
                }){
                    Text("Send")
                }
                
            }.keyboardResponsive()
            
            .navigationBarTitle("\(name)", displayMode: .inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.chat.toggle()
                }, label: {
                    Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 20, height: 15)
                })
            )
        }.padding()
            .onAppear(){
                self.getMsgs()
        }
    }
    
    func getMsgs(){
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("msgs").document(uid!).collection(self.uid).order(by: "date", descending: false).addSnapshotListener { (snap, err) in
            
            if err != nil{
                print((err?.localizedDescription)!)
                self.nomsg = true
                return
            }
            
            if snap!.isEmpty{
                self.nomsg = true
            }
            
            
            for i in snap!.documentChanges{
                
                if i.type == .added{
                    
                    let id = i.document.documentID
                    let msg = i.document.get("msg") as! String
                    let user = i.document.get("user") as! String
                    
                    self.msgs.append(Msg(id: id, msg: msg, user: user))
                }
            }
        }
    }
}


struct Msg : Identifiable {
    var id : String
    var msg : String
    var user : String
}


struct ChatBubble : Shape {
    
    var mymsg: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight, mymsg ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        
        return Path(path.cgPath)
        
    }
    
}

func sendMsg(user: String, uid: String, pic: String, date :Date, msg : String){
    
    let db = Firestore.firestore()
    let myuid = Auth.auth().currentUser?.uid

    db.collection("users").document(uid).collection("recents").document(myuid!).getDocument { (snap, err) in
        
        if err != nil{
            print((err?.localizedDescription)!)
            setRecents(user: user, uid: uid, pic: pic, date: date, msg: msg)
            return
        }
        
        if !snap!.exists{
            print("no recent")
            
            setRecents(user: user, uid: uid, pic: pic, date: date, msg: msg)
            
        }else{
             print("have recent")
             updateRecents(uid: uid, date: date, lastmsg: msg)
            
        }
    }
    
    updateDB(uid: uid, msg: msg, date: date)
    
}

func setRecents(user: String, uid: String, pic: String, date :Date, msg : String){
    
    let db = Firestore.firestore()
    let myuid = Auth.auth().currentUser?.uid
    
    let myname = UserDefaults.standard.value(forKey: "UserName") as! String
    let mypic = UserDefaults.standard.value(forKey: "pic") as! String
    db.collection("users").document(uid).collection("recents").document(myuid!).setData(["name":myname,"pic":mypic,"lastmsg":msg,"date":date]) { (err) in
        
        if err != nil{
            
            print((err?.localizedDescription)!)
            return
        }
    }
    
    db.collection("users").document(myuid!).collection("recents").document(uid).setData(["name":user,"pic":pic,"lastmsg":msg,"date":date]) { (err) in
        
        if err != nil{
            
            print((err?.localizedDescription)!)
            return
        }
    }
    
    
}

func updateRecents(uid: String,date :Date, lastmsg : String){
    
    let db = Firestore.firestore()
    let myuid = Auth.auth().currentUser?.uid
    
    db.collection("users").document(uid).collection("recents").document(myuid!).updateData(["lastmsg":lastmsg,"date":date])
    db.collection("users").document(myuid!).collection("recents").document(uid).updateData(["lastmsg":lastmsg,"date":date])
    
    
}


func updateDB(uid: String,msg: String,date: Date){
    
    let db = Firestore.firestore()
    
    let myuid = Auth.auth().currentUser?.uid
    
    db.collection("msgs").document(uid).collection(myuid!).document().setData(["msg":msg,"user":myuid!,"date":date]) { (err) in
        
        if err != nil{
            
            print((err?.localizedDescription)!)
            return
        }
    }
    
    db.collection("msgs").document(myuid!).collection(uid).document().setData(["msg":msg,"user":myuid!,"date":date]) { (err) in
        
        if err != nil{
            
            print((err?.localizedDescription)!)
            return
        }
    }
}
