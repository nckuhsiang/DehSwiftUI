//
//  GameViewModel.swift
//  DehSwiftUI
//
//  Created by 陳家庠 on 2022/11/6.
//  Copyright © 2022 mmlab. All rights reserved.
//

import Foundation
import Alamofire
import Combine

class GameViewModel:ObservableObject {
    @Published var gameList:[gameListtuple] = []
    @Published var sessionList : [SessionModel] = []
    @Published var chestList:[ChestModel] = []
    @Published var gameData:GameData = GameData()
    
    @Published var min:Int = 0
    @Published var sec:Int = 0
    @Published private var cancellable: AnyCancellable?
    @Published private var cancellable2: AnyCancellable?
    
    func getGameList(userID:String) {
        let url = privateGetGroupList
        let parameters:[String:String] = [
            "user_id": "\(userID)",
            "coi_name": coi,
            "language": "中文",
        ]
        var tempList : [gameListtuple] = []
        let publisher:DataResponsePublisher<GroupLists> = NetworkConnector().getDataPublisherDecodable(url: url, para: parameters)
        self.cancellable = publisher
            .sink(receiveValue: {(values) in
//                print(values.debugDescription)
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
    func getSessions(userID:String,groupID:Int){
        let url = getRoomList
        let parameters:[String:String] = [
            "user_id": "\(userID)",
            "coi_name": coi,
            "coi":coi,
            "language": "中文",
            "group_id":"\(groupID)",
            
            
        ]
        let publisher:DataResponsePublisher<[SessionModel]> = NetworkConnector().getDataPublisherDecodable(url: url, para: parameters)
        self.cancellable = publisher
            .sink(receiveValue: {(values) in
//                print(values.data?.JsonPrint())
//                print(values.debugDescription)
                if let value = values.value{
                    self.sessionList = value
                }
                
            })
    }
    func getChests(session:SessionModel){
        let url = getChestList
        let parameters:[String:String] = [
            "user_id": "\(session.id)",
            "game_id":"\(session.gameID)",
        ]
        let publisher:DataResponsePublisher<[ChestModel]> = NetworkConnector().getDataPublisherDecodable(url: url, para: parameters)
        self.cancellable = publisher
            .sink(receiveValue: {(values) in
                //                print(values.data?.JsonPrint())
//                print(values.debugDescription)
                if let value = values.value{
                    self.chestList = value
                    print(self.chestList.count)
                }
                
            })
    }
    func getGameData(gameID:Int){
        let url = getGameDataUrl
        let parameters = ["game_id": gameID]
        let publisher:DataResponsePublisher<[GameData]> = NetworkConnector().getDataPublisherDecodable(url: url, para: parameters)
        self.cancellable2 = publisher
            .sink(receiveValue: {(values) in
                print(values.debugDescription)
                self.gameData = values.value?[0] ?? GameData()
                self.min = self.gameData.end_time/60
                self.sec = self.gameData.end_time % 60
            })
    }
}
