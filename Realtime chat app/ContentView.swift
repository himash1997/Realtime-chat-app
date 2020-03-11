//
//  ContentView.swift
//  Realtime chat app
//
//  Created by Himash Nadeeshan on 3/11/20.
//  Copyright © 2020 Himash Nadeeshan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Verify()
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
            
            Button(action: {
                
            }){
                Text("Send")
                .frame(width: 380, height: 50)
            }.foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}


struct Verify : View {
    
//    @Binding var show : Bool
//    @Binding var ID : String
    
    @State var msg = ""
    @State var alert = false
    @State var verificationcode = ""
    
    var body : some View{
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
                
            }){
                Text("Verify")
                .frame(width: 380, height: 50)
            }.foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}
