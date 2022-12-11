//
//  BeginView.swift
//  DehSwiftUI
//
//  Created by 廖偉博 on 2022/11/6.
//  Copyright © 2022 mmlab. All rights reserved.
//
//
import SwiftUI
import Combine
import Alamofire

struct BeginView: View {
    
    @EnvironmentObject var settingStorage:SettingStorage
    @State var groupSelectedOver: Bool = false
    @State var searchText:String = ""
    @State var reqAlertState:Bool = false
    @State var resAlertState:Bool = false
    @State var alertText:String = ""
    @State var selectedGroup:Group = Group(id: 0, name: "-111", leaderId: 0, info: "")
    @State var groupList:[Group] = []
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        NavigationView{
            VStack {
                NavigationLink(destination: ContentView(group:self.selectedGroup), isActive: self.$groupSelectedOver) { EmptyView() }
                SearchBar(text: $searchText)
                List {
                    ForEach(self.groupList) { group in
                        if(group.name.hasPrefix(searchText)) {
                            Button {
                                self.selectedGroup = group
                                self.reqAlertState = true
                            } label: {
                                Text(group.name)
                            }
                            .alert(isPresented: $reqAlertState) { () -> Alert in
                                return Alert(title: Text("Join".localized),
                                             message: Text("Join".localized + "\(selectedGroup)?"),
                                             primaryButton: .default(Text("Yes".localized),
                                                                     action: {               self.resAlertState = true
                                    self.groupSelectedOver = true
                                }),
                                             secondaryButton: .default(Text("No".localized), action: {}))
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
            }
        }
//        VStack {
//            NavigationLink(destination: ContentView(group:self.selectedGroup), isActive: self.$groupSelectedOver) { EmptyView() }
//            SearchBar(text: $searchText)
//            List {
//                ForEach(self.groupList) { group in
//                    if(group.name.hasPrefix(searchText)) {
//                        Button {
//                            self.selectedGroup = group
//                            self.reqAlertState = true
//                        } label: {
//                            Text(group.name)
//                        }
//                        .alert(isPresented: $reqAlertState) { () -> Alert in
//                            return Alert(title: Text("Join".localized),
//                                         message: Text("Join".localized + "\(selectedGroup)?"),
//                                         primaryButton: .default(Text("Yes".localized),
//                                                                 action: {               self.resAlertState = true
//                                self.groupSelectedOver = true
//                            }),
//                                         secondaryButton: .default(Text("No".localized), action: {}))
//                        }
//                    }
//                }
//            }
//            .listStyle(PlainListStyle())
//        }
        .onAppear { getGroupList() }
    }
}

extension BeginView {
    func getGroupList() {
        let url = GroupGetAllListUrl
        print(settingStorage.account)
        let parameters = ["coi_name":coi]
        let publisher:DataResponsePublisher<GroupNameList2> = NetworkConnector().getDataPublisherDecodable(url: url, para: parameters)
        self.cancellable = publisher
            .sink(receiveValue: {(values) in
                print(values.debugDescription)
                self.groupList = values.value?.results ?? []
            })
    }
}

struct GroupNameList2:Decodable{
    let results:[Group]
}

struct BeginView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSearchView()
    }
}
