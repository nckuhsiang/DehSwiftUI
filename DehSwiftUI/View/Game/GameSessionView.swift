//
//  Session.swift
//  DehSwiftUI
//
//  Created by 阮盟雄 on 2021/4/28.
//  Copyright © 2021 mmlab. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire
struct SessionView: View {
    var group:Group
    @StateObject var gameVM:GameViewModel
//    @State var sessionList : [SessionModel] = []
    @State private var showingSheet = false
    @State var selection: Int? = nil
    @EnvironmentObject var settingStorage:SettingStorage
    @State private var cancellable: AnyCancellable?
    @State var selectedSession : SessionModel?
    var body: some View {
        ZStack{
            List{
                ForEach(gameVM.sessionList,id: \.self){
                    session in
                    Button(session.name) {
                                showingSheet = true
                            }
                            .actionSheet(isPresented: $showingSheet) {
                                ActionSheet(
                                    title: Text("What do you want to do?".localized),
    //                                message: Text("There's only one choice..."),
                                    buttons: [
                                        .default(Text("History".localized),action: {
                                            selection = 1
                                            selectedSession = session
                                        }),
                                        .default(Text("Game".localized),action: {
                                            selection = 2
                                            selectedSession = session
                                        }),
    //                                    .default(Text("Dismiss Action Sheet3")),
                                        .cancel()]
                                )
                            }
                }
                .foregroundColor(Color.white)
                .allowsTightening(true)
                .lineLimit(1)
                .background(Color.init(UIColor(rgba:lightGreen)))
                .listRowBackground(Color.init(UIColor(rgba: lightGreen)))
            }
            NavigationLink(
                destination: GameHistoryView(roomID:selectedSession?.id ?? -1),
                tag:1, selection: $selection){
                EmptyView()
            }
            NavigationLink(
                destination: GameMap(gameVM: gameVM, group: self.group, session: selectedSession ?? testSession),
                tag:2, selection: $selection){
                EmptyView()
            }
        }

            .onAppear(){
                gameVM.getSessions(userID: settingStorage.userID, groupID: group.id)
                
            }
    }
}

extension SessionView{
//    func getSessions(){
//        let url = getRoomList
//        let parameters:[String:String] = [
//            "user_id": "\(settingStorage.userID)",
//            "coi_name": coi,
//            "coi":coi,
//            "language": "中文",
//            "group_id":"\(self.group.id)",
//
//
//        ]
//        let publisher:DataResponsePublisher<[SessionModel]> = NetworkConnector().getDataPublisherDecodable(url: url, para: parameters)
//        self.cancellable = publisher
//            .sink(receiveValue: {(values) in
////                print(values.data?.JsonPrint())
//                print(values.debugDescription)
//                if let value = values.value{
//                    self.sessionList = value
//                }
//
//            })
//    }
}

struct Session_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(group: Group(id: -1, name: "testGroup", leaderId: -1, info: ""),gameVM: GameViewModel())
            .environmentObject(SettingStorage())
    }
}
