//
//  Game.swift
//  DehSwiftUI
//
//  Created by 阮盟雄 on 2021/4/27.
//  Copyright © 2021 mmlab. All rights reserved.
//

import SwiftUI
import Combine
import Alamofire
struct GameView: View {
    @EnvironmentObject var settingStorage:SettingStorage
    @State private var cancellable: AnyCancellable?
    @State var gameList : [gameListtuple] = []
    var body: some View {
        List{
            ForEach(gameList,id: \.self){
                list in
                Section(header: Text(list.sectionName)){
                    ForEach(list.groupList ,id: \.id){
                        group in
                        NavigationLink(
                            destination: SessionView(group: group),
                            label: {
                                Text(group.name)
                                    .foregroundColor(Color.white)
                                    .allowsTightening(true)
                                    .lineLimit(1)
                                    .background(Color.init(UIColor(rgba:lightGreen)))
                            })
                    }
                }
                .listRowBackground(Color.init(UIColor(rgba: lightGreen)))
            }
        }
            .onAppear(perform: {
                if(gameList.isEmpty){
                    getGameList()
                }
            })
    }
}

extension GameView{
    func getGameList(){
        let url = privateGetGroupList
        let parameters:[String:String] = [
            "user_id": "\(settingStorage.userID)",
            "coi_name": coi,
            "language": "中文",
        ]
        var tempList : [gameListtuple] = []
        let publisher:DataResponsePublisher<GroupLists> = NetworkConnector().getDataPublisherDecodable(url: url, para: parameters)
        self.cancellable = publisher
            .sink(receiveValue: {(values) in
                print(values.debugDescription)
                if let eventList = values.value?.eventList {
                    tempList.append(gameListtuple("public".localized,eventList))
                }
                if let groupList = values.value?.groupList{
                    if(!groupList.isEmpty){
                        tempList.append(gameListtuple("private".localized,groupList))
                    }}
                self.gameList = tempList
            })
    }
    class gameListtuple : Identifiable, Hashable{
        var id = UUID()
        var sectionName:String = ""
        var groupList:[Group] = []
        init(_ sectionName:String, _ groupList:[Group]) {
            self.sectionName = sectionName
            self.groupList = groupList
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        static func == (lhs: gameListtuple, rhs: gameListtuple) -> Bool {
            return lhs.id == rhs.id
        }
    }
}
struct Game_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(SettingStorage())
    }
}
