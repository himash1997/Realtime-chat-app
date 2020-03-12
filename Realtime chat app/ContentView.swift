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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountCreation()
//    }
//}

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
    
    @State var name = ""
    @State var about = ""
    @State var picker = false
    @State var loading = false
    @State var imagedata : Data = .init(count: 0)
    @State var alert = false
    
    var body: some View{
        
        VStack(){
            Text("Creation An Account")
                .font(.title)
            
            HStack{
                Spacer()
                Button(action: {
                    
                    self.picker.toggle()
                    
                }){
                    
                    if self.imagedata.count == 0{
                        Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .frame(width: 90, height: 70)
                        .foregroundColor(Color.gray)
                    }else{
                        Image(uiImage: UIImage(data: self.imagedata)!)
                        .resizable()
                        .renderingMode(.original)
                        .frame(width:90 ,height: 90)
                        .clipShape(Circle())
                        
                    }
                
                }
                Spacer()
            }
            //.padding(.vertical, 30)
            
            VStack(alignment: .leading, spacing: 20){
                Text("Enter User Name")
                    .font(.body)
                    .foregroundColor(Color.gray)
                
                TextField("Name",text: self.$name)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text("About You")
                    .font(.body)
                    .foregroundColor(Color.gray)
                
                TextField("About",text: self.$about)
                    .padding()
                    .background(Color("Color"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            }.padding()
            
            if self.loading{
                HStack{
                    Spacer()
                    Indicator()
                    Spacer()
                }
            }else{
                
                Button(action:{
                    
                    if self.name != "" && self.about != "" && self.imagedata.count != 0{
                        
                        self.loading.toggle()
                        createUser(name: self.name, about: self.about, imagedata: self.imagedata) { (status) in
                            if status{
                                self.show.toggle()
                            }
                        }
                        
                    }else{
                        self.alert.toggle()
                    }
                    
               }){
               Text("Create Account")
                   .frame(width: 350, height: 50)
                   
               }.foregroundColor(.white)
               .background(Color.blue)
               .cornerRadius(10)
    
            }
            
        }.padding()
            .sheet(isPresented: self.$picker, content: {
                ImagePicker(picker: self.$picker, imagedata: self.$imagedata)
            })
            .alert(isPresented: self.$alert) {
                Alert(title: Text("Message"), message: Text("Please Fill The Contents"), dismissButton: .default(Text("Ok")))
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var picker : Bool
    @Binding var imagedata : Data
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        return ImagePicker.Coordinator(parent1: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    class Coordinator : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
        
        var parent : ImagePicker
        
        init(parent1 : ImagePicker) {
            parent = parent1
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.picker.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let image = info[.originalImage] as! UIImage
            let data = image.jpegData(compressionQuality: 0.45)
            self.parent.imagedata = data!
            self.parent.picker.toggle()
            
        }
        
    }
    
}

func createUser(name : String, about: String, imagedata: Data, completion: @escaping(Bool)->Void){
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    let uid = Auth.auth().currentUser?.uid
    
    storage.child("profilepics").child(uid!).putData(imagedata, metadata: nil) { (_, err) in
        
        if err != nil{
            print((err?.localizedDescription)!)
            return
        }
        
        storage.child("profilepics").child(uid!).downloadURL { (url, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            db.collection("users").document(uid!).setData(["name":name,"about":about,"pic":"\(url!)","uid":uid!]) { (err) in
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }
                
                completion(true)
                
                UserDefaults.standard.set(true, forKey: "status")
                UserDefaults.standard.set(name, forKey: "UserName")
                NotificationCenter.default.post(name: NSNotification.Name("statusChange"), object: nil)
                
            }
            
        }
        
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
