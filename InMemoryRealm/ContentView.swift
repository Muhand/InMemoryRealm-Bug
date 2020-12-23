//
//  ContentView.swift
//  InMemoryRealm
//
//  Created by Muhand Jumah on 12/22/20.
//

import SwiftUI
import RealmSwift
struct ContentView: View {
    private let cache: InMemoryCache = RealmInMemoryCache(Realm.Configuration(inMemoryIdentifier: "messagesRealm"))
    
    @State private var message: String = ""
    @State private var messages: [String] = []
    @State private var doingWork: Bool = false
    var body: some View {
        VStack {
            
            if(doingWork) {
                ProgressView()
            }
            
            VStack {
                TextField("Message", text: self.$message)
                    .padding()
                Button(action: {
                    self.doingWork = true
                    let messageEntity: MessageRealmEntity = MessageRealmEntity(message: self.message)
                    cache.save(object: messageEntity) { (result) in
                        switch result {
                            case .success(_):
                                print("Success")
                            case .failure(_):
                                print("Got error")
                        }
                        
                        self.doingWork = false
                    }
                    
                }, label: {
                    Text("Save")
                }).padding(.vertical, 10)
            }
            .border(Color.black)
            .padding()
            
            VStack {
                Button(action: {
                    self.doingWork = true
                    self.cache.fetch(model: MessageRealmEntity.self, predicate: nil, sorted: nil) { (result) in
                        switch result {
                            case .success(let messages):
                                self.messages = messages.map {
                                    $0.message
                                }
                            case .failure(_):
                                print("got error")
                        }
                        
                        self.doingWork = false
                    }
                }) {
                    Text("Refresh")
                }
                
                Divider()
                
                if(messages.count > 0 ) {
                    List (self.messages, id: \.self) { message in
                        Text(message)
                    }
                } else {
                    Text("Empty")
                }
            }
            .padding()
            .border(Color.black)
            .padding()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
