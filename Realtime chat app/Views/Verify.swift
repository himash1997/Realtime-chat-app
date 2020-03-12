//
//  Verify.swift
//  Realtime chat app
//
//  Created by Himash Nadeeshan on 3/12/20.
//  Copyright © 2020 Himash Nadeeshan. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore

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
                        .background(Color.blue)
                        .cornerRadius(10)
                    }

                }
            }

            Button(action: {
                           self.show.toggle()
                       }){
                           Image(systemName: "chevron.left")

                       }.foregroundColor(Color.blue)

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
