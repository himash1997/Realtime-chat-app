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

struct Getnumber : View {
    
    @State var number = ""
    @State var code = ""
    @State var show = false
    @State var msg = ""
    @State var alert = false
    @State var ID = ""
    
    var body: some View{
        
        VStack(){
            
            Image("images")
                .resizable()
                .scaledToFill()
                .frame(width:100, height:100)
                .clipped()
            
            Text("Welcome!")
            .font(.largeTitle)
            .fontWeight(.heavy)
            
            Text("Please enter your number to verify your account")
                .font(.body)
                .foregroundColor(Color.gray)
                .padding(.bottom,40)
            
            HStack{
                TextField("+94",text: $code)
                .keyboardType(.numberPad)
                .frame(width : 40)
                .padding()
                .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                TextField("Number",text: $number)
                .keyboardType(.numberPad)
                .padding()
                .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
            }.padding()
            
            
            NavigationLink(destination: Verify(show: $show, ID: $ID), isActive: $show){
                Button(action: {

                    PhoneAuthProvider.provider().verifyPhoneNumber("+"+self.code + self.number, uiDelegate: nil) { (ID, err) in
                        if err != nil{
                            self.msg = (err?.localizedDescription)!
                            self.alert.toggle()
                            return
                        }
                        self.ID = ID!
                        self.show.toggle()
                    }
                    
                }){
                    Text("Send")
                    .frame(width: 350, height: 50)
                    
                }.foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(10)
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
            }.padding()
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }
    }
}


struct Verify : View {
    
    @Binding var show : Bool
    @Binding var ID : String
    
    @State var msg = ""
    @State var alert = false
    @State var verificationcode = ""
    @State var creation = false
    @State var loading = false
    
    var body : some View{
        
        ZStack(alignment: .topLeading){
            GeometryReader{_ in
                VStack(){
                           
                       Image("images")
                       .resizable()
                       .scaledToFill()
                       .frame(width:100, height:100)
                       .clipped()
                    
                       Text("Verification Code")
                           .font(.largeTitle)
                           .fontWeight(.heavy)
                       
                       Text("please enter your verification code")
                           .font(.body)
                           .foregroundColor(Color.gray)
                           .padding(.bottom,40)
                   
                        TextField("Type code here",text: self.$verificationcode)
                           .keyboardType(.numberPad)
                           .padding()
                           .background(Color("Color"))
                           .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if self.loading{
                        HStack{
                            Spacer()
                            Indicator()
                            Spacer()
                        }
                    }else{
                        Button(action: {
                         
                         self.loading.toggle()
                            
                         let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.verificationcode)
                         
                         Auth.auth().signIn(with: credential) { (res, err) in
                             if err != nil{
                                 self.msg = (err?.localizedDescription)!
                                 self.alert.toggle()
                                 self.loading.toggle()
                                
                                 return
                             }
                             
                             checkUser{ (exists, user) in
                                 if exists{
                                     UserDefaults.standard.set(true, forKey: "status")
                                     UserDefaults.standard.set(user, forKey: "UserName")
                                     
                                     NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                                 }else{
                                     self.loading.toggle()
                                     self.creation.toggle()
                                 }
                             }
                             
                         }
                         
                         
                        }){
                            Text("Verify")
                                .frame(width: 380, height: 50)
                            
                        }.foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                           
                }
            }
            
            Button(action: {
                           self.show.toggle()
                       }){
                           Image(systemName: "chevron.left")
                           
                       }.foregroundColor(Color.orange)
            
        }.padding()
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $alert) {
            Alert(title: Text("Error"), message: Text(self.msg), dismissButton: .default(Text("Ok")))
        }.sheet(isPresented: self.$creation){
            AccountCreation(show: self.$creation)
        }
    }
    
}

struct Home : View {
    
    var body: some View{
        
        VStack{
            Text("Welcome \(UserDefaults.standard.value(forKey: "UserName") as! String)")
            Button(action:{
                
                try! Auth.auth().signOut()
                
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
            }){
                Text("Logout")
            }
        }
        
    }
}

struct AccountCreation: View {
    
    @Binding var show: Bool
    
    var body: some View{
        Text("Account create")
    }
}


func checkUser(completion: @escaping (Bool,String)->Void){
     
    let db = Firestore.firestore()
    
    db.collection("users").getDocuments { (snap, err) in
        if err != nil{
            print((err?.localizedDescription)!)
            return
        }
        for i in snap!.documents{
            
            if i.documentID == Auth.auth().currentUser?.uid{
                
                completion(true,i.get("name") as! String)
                return
            }
        }
        completion(false,"")
    }
    
}

struct Indicator: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        
        return indicator
    }
    
    func updateUIView(_ uiView: Indicator.UIViewType, context: UIViewRepresentableContext<Indicator>) {
        
    }
    
}
