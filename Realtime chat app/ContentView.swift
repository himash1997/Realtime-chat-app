//
//  ContentView.swift
//  Realtime chat app
//
//  Created by Himash Nadeeshan on 3/11/20.
//  Copyright © 2020 Himash Nadeeshan. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ??  false
    
    var body: some View {
        VStack{
            if status{
                Home()
            }else{
                NavigationView{
                    Getnumber()
                }
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
        
        VStack(spacing: 20){
            
            Image("images")
            
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
    
    var body : some View{
        
        ZStack(alignment: .topLeading){
            
            VStack(spacing: 20){
                
                Image("images")
                
                Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.heavy)
                
                Text("Please enter your verification number")
                    .font(.body)
                    .foregroundColor(Color.gray)
                    .padding(.bottom,40)
                    
                TextField("Code",text: $verificationcode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color("Color"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                    
                Button(action: {
                 
                 let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.verificationcode)
                 
                 Auth.auth().signIn(with: credential) { (res, err) in
                     if err != nil{
                         self.msg = (err?.localizedDescription)!
                         self.alert.toggle()
                         return
                     }
                     
                     UserDefaults.standard.set(true, forKey: "status")
                     NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                     
                 }
                 
                 
                }){
                    Text("Verify")
                        .frame(width: 380, height: 50)
                    
                }.foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(10)
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
            
            Button(action: {
                self.show.toggle()
            }){
                Image(systemName: "chevron.left")
                
            }.foregroundColor(Color.blue)
            
        }.padding()
        
    }
    
}

struct Home : View {
    var body: some View{
        Button(action:{
            
            try! Auth.auth().signOut()
            
            UserDefaults.standard.set(false, forKey: "status")
            NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
        }){
            Text("Logout")
        }
    }
}

