//
//  Getnumber.swift
//  Realtime chat app
//
//  Created by Himash Nadeeshan on 3/12/20.
//  Copyright © 2020 Himash Nadeeshan. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore

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
                .background(Color.blue)
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
