//
//  ChatViewController+TwitchProcessing.swift
//  YEP Chat
//
//  Created by Darren Key on 12/15/21.
//

import Foundation
import Alamofire
import Starscream
import WebKit

extension ChatViewController{
    func connectToTwitchChat(authToken: String){
        ///Protocol for connection  - note: obv change PASS and NICK when releasing app
        socket.write(string: "PASS oauth:\(authToken)")
        socket.write(string: "NICK \(username)")
        socket.write(string: "JOIN " + channelName)
        socket.write(string: "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership")
    }
    
    func connectToTwitchChatReadingOnly(){
        ///Protocol for connection  - note: obv change PASS and NICK when releasing app
        readingSocket.write(string: "PASS AAA")
        readingSocket.write(string: "NICK justinfan123")
        readingSocket.write(string: "JOIN " + channelName)
        readingSocket.write(string: "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership")
    }
    
    
    func getUserID(channel: String, accesstoken: String){
        guard let url = URL(string: "https://api.twitch.tv/helix/users?login=\(channel)") else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accesstoken)",
            "Client-Id": clientid]
        
        
        AF.request(url, headers: headers).responseDecodable(of: DataUserID.self) { [self] (response) in
            guard let response = response.value else { print("ERROROR!")
                return }
            
            if response.data.count >= 1, let tempID = Int(response.data[0].id){
                
                twitchID = tempID
                
                getBTTVEmotes(twitchID: twitchID)
                
                getGlobalChannelBadges(channel: channel, accesstoken: accesstoken)
            }
        }
        
        
    }
    
    func getGlobalChannelBadges(channel: String, accesstoken:String){
        let url = URL(string: "https://api.twitch.tv/helix/chat/badges/global")!
        let headers: HTTPHeaders = [
            
            "Authorization": "Bearer \(accesstoken)",
            "Client-Id": clientid]
        
        AF.request(url, headers: headers).responseDecodable(of: DataGlobalBadges.self) { [self] (response) in
            guard let response = response.value else { return }
            
            for globalBadge in response.data{
                badgeDict[globalBadge.set_id] = globalBadge.versions[0]["image_url_\(ffzScale)x"]
            }
        }
        
    }
    
    func getUserName(clientID: String, authToken: String){
        let url = URL(string: "https://api.twitch.tv/kraken/user")!
        
        let headers: HTTPHeaders = [
            "Accept": "application/vnd.twitchtv.v5+json",
            "Client-Id": clientID,
            "Authorization": "OAuth \(authToken)"]
        
        
        AF.request(url, headers: headers).responseDecodable(of: GetUserName.self) { [self] (response) in
            guard let gottenUsername = response.value?.name else { return }
            
            print("Got the username!", gottenUsername)
            username = gottenUsername
            
            
            connectToTwitchChat(authToken: accesstoken)
            connectToTwitchChatReadingOnly()
        }
        
    }
    
    
    ///download emotes as soon as get a channel
    func getFFZEmotes(channel: String){
        guard let url = URL(string: "https://api.frankerfacez.com/v1/room/\(channelNameWithout)") else {return}
        let request = AF.request(url)
        
        ///processing of JSON from FFZ API
        request.responseDecodable(of: Rooms.self) { (response) in
            guard let rooms = response.value else {
                return }
            let setID = rooms.room.setID
            //let twitchID = rooms.room.twitchID

            guard let setsList = rooms.sets[String(setID)] else {return }

            ///get FFZ emotes
            for emote in setsList.emotes{
                ///list of emotes
                ///self.emoteList.append(emote.name)
                self.ffzEmotes.append(emote.name)
                let emoteURLProcessed = "https:" + (emote.urls[self.ffzScale] ?? emote.urls["1"]!)

                self.ffzPreProcessedEmotes.append(customEmote(name: emote.name, id: emoteURLProcessed, ending: .png))
//                ///download emote
//
//                ///emote location
//                let destination: DownloadRequest.Destination = { _, _ in
//                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                    let fileURL = documentsURL.appendingPathComponent("\(emote.name).png")
//
//                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
//                }
//
//                AF.download(emoteURLProcessed, to: destination).response { response in
//                    debugPrint(response)
//
//                    if response.error == nil, let imagePath = response.fileURL?.path {
//                        let image = UIImage(contentsOfFile: imagePath)
//                    }
//                }
 
            }
            
          }
        
        
    }
    
    ///Get global BTTV Emotes
    func getGlobalBTTVEmotes(){
        ///get BTTV emotes
        let bttvURL = URL(string: "https://api.betterttv.net/3/cached/emotes/global")!
        let bttvRequest = AF.request(bttvURL)
        
        ///processing BTTV Emotes
        bttvRequest.responseDecodable(of: [BTTVEmotes].self) { [self] (response) in
            guard let bttvemotes = response.value else { return }
            
            for emote in bttvemotes{
                self.bttvEmotes.append(emote.name)
                
                if emote.imageType == "gif"{
                    self.bttvPreProcessedEmotes.append(customEmote(name: emote.name, id: emote.id, ending: .gif))
                }
                else{
                    self.bttvPreProcessedEmotes.append(customEmote(name: emote.name, id: emote.id, ending: .png))

                   // let bttvEmoteProcessed = "https://cdn.betterttv.net/emote/\(emote.id)/\(bttvScale)x"
                    
//                    let destination: DownloadRequest.Destination = { _, _ in
//                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                        let fileURL = documentsURL.appendingPathComponent("\(emote.name).\(emote.imageType)")
//
//                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
//                    }
//
//
//                    AF.download(bttvEmoteProcessed, to: destination).response { response in
//                       // debugPrint(response)
//
//                        if response.error == nil, let imagePath = response.fileURL?.path {
//                            let image = UIImage(contentsOfFile: imagePath)
//                        }
                    }
                }
                
            }
        }
    
    func getBTTVEmotes(twitchID: Int){
        ///get BTTV emotes
        guard let bttvURL = URL(string: "https://api.betterttv.net/3/cached/users/twitch/\(String(twitchID))") else {return}
        let bttvRequest = AF.request(bttvURL)
        
        ///processing BTTV Emotes
        bttvRequest.responseDecodable(of: BTTVId.self) { [self] (response) in
            guard let bttvid = response.value else { return }
            
            var bttvemotes = bttvid.BTTVEmotes
                
            bttvemotes.append(contentsOf: bttvid.sharedEmotes)
            
            for emote in bttvemotes{
                self.bttvEmotes.append(emote.name)
                
                if emote.imageType == "gif"{
                    self.bttvPreProcessedEmotes.append(customEmote(name: emote.name, id: emote.id, ending: .gif))
                }
                else{
                    self.bttvPreProcessedEmotes.append(customEmote(name: emote.name, id: emote.id, ending: .png))
                }
                
                //let bttvEmoteProcessed = "https://cdn.betterttv.net/emote/\(emote.id)/\(bttvScale)x"
                
                ///download emote
                ///emote location
//                let destination: DownloadRequest.Destination = { _, _ in
//                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//                    let fileURL = documentsURL.appendingPathComponent("\(emote.name).\(emote.imageType)")
//
//                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
//                }
                
                
//                AF.download(bttvEmoteProcessed, to: destination).response { response in
//                   // debugPrint(response)
//
//                    if response.error == nil, let imagePath = response.fileURL?.path {
//                        let image = UIImage(contentsOfFile: imagePath)
//                    }
//                }
                
                }
            }
        }
}


///get access token for user auth
extension ChatViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String : AnyObject] else { return }
        
        var getiddict : [String: String] = [:]
        
        guard let unprocessed = dict["message"] else { return }
        for tags in unprocessed.components(separatedBy: "&"){
            let temp = tags.components(separatedBy: "=")
            
            getiddict[temp[0]] = temp[1]
        }
        print(dict, "DICT")
        
        guard let tempaccess = getiddict["#access_token"] else {return}
        
        loginWebView.isHidden = true
        hideLoginWebView.isHidden = true
        
        
        ///add type in chat view
        typeInChatView.attributedText = NSMutableAttributedString(string: " ")
        typeInChatView.attributedText = NSMutableAttributedString(string: "")
        typeInChatOverView.addSubview(typeInChatView)
        
        typeInChatView.frame = typeChatPlaceholder.frame
        typeInChatView.placeholderFont = channelLabel.font
        typeInChatView.placeholderText = "Start chatting"
        typeInChatView.font = channelLabel.font

        switch themeMode{
        case .dark:
            typeInChatView.textColor = .white
        case .light:
            typeInChatView.textColor = .black
        }
        
        
        ///connect to IRC chat
        var request = URLRequest(url: URL(string: "wss://irc-ws.chat.twitch.tv:443")!)
        request.timeoutInterval = 30
        socket = WebSocket(request: request)
//        socket.delegate = self
        socket.connect()
        
        
        ///for reading
        readingSocket = WebSocket(request: request)
        readingSocket.delegate = self
        readingSocket.connect()
        
        accesstoken = tempaccess
        
    }
}
