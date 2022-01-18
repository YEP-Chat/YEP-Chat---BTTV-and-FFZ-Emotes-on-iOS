//
//  ViewController.swift
//  YEP Chat
//
//  Created by Darren Key on 5/20/21.
//

import UIKit
import Starscream
import WebKit
import GCDWebServer
import Foundation
import Alamofire
import AlamofireImage
import YYImage
import YYWebImage
import BSText
import SDWebImage

struct emoteStruct{
    var numInList: Int = -1
    var id = ""
    var lowerNum: Int = -1
    var upperNum : Int = -1
}

struct msgStruct{
    var msg : [NSMutableAttributedString] = []
    var id = -1
}

class ChatViewController: UIViewController, WebSocketDelegate, WKNavigationDelegate {
    
    ///WebSocket to connect
    var socket: WebSocket!
    var isConnected = false
    
    var channelName = ""
    var channelNameWithout = "teltale"
    
    var accesstoken = ""
    
    var maxNumMessages = 50
    
    var rangesToDelete: [NSRange] = []
    
    var emoteList: [String] = []
    var gifEmotes: [String] = []
    var emojisList: [String] = []
    var globalEmoteList: [String] = []
    var msgGlobalArray: [msgStruct] = []
    
    var twitchID: Int = 0
    
    var msgidNum: Int = 0
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loginWebView: WKWebView!
    
    @IBOutlet weak var chatView: UITextView!
    
    ///
    ///
    /// ---------OMITTED FOR DATA SENSITIVE PURPOSES, IF USING REPLACE WITH YOUR OWN CLIENT ID
    /// OBTAINED FROM YOUR TWITCH DEVELOPER PAGE!!!------------------------- 
    var clientid = ""
    
    var Chat = BSTextView()
    //@IBOutlet weak var chatView: BSTextView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        webView.navigationDelegate = self
        
        getEmotes()
        
        ChatViewController.initWebServer()
        
        ///add this script as a userContentController to enable it to receive js messages from server
        self.loginWebView.configuration.userContentController.add(self, name: "getID")
    }
    
    ///connecting to chat
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            
            
            ///Protocol for connection  - note: obv change PASS and NICK when releasing app
            socket.write(string: "PASS oauth:t48snjjxm5yfweq22gf1poi24qyo3z")
            socket.write(string: "NICK teltale")
            socket.write(string: "JOIN " + channelName)
            socket.write(string: "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership")
            
            
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            //print("Received text: \(string)")
            handleText(text: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    
    func getUserID(channel: String, accesstoken: String){
        //print("SDFJKSDJF")
        let url = URL(string: "https://api.twitch.tv/helix/users?login=\(channel)")!
        let request = AF.request(url)
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accesstoken)",
            "Client-Id": clientid]
        
        //print("SDFSDJF")
        AF.request(url, headers: headers).responseDecodable(of: DataUserID.self) { (response) in
            guard let response = response.value else { print("ERROROR!")
                return }
            
            self.twitchID = Int(response.data[0].id) ?? 0
            
            self.getBTTVEmotes(twitchID: self.twitchID)
        }
        
        
    }
    
    func getGlobalEmotes(){
        let headers: HTTPHeaders = [
            "Accept": "application/vnd.twitchtv.v5+json",
            "Client-ID": clientid]
        
        //print("SDFSDJF")
        AF.request("https://api.twitch.tv/kraken/chat/emoticon_images?emotesets=0", headers: headers).responseDecodable(of: GlobalEmotes.self) { (response) in
            
            guard let response = response.value else { return }
            for emote in response.emoticon_sets.id{
                //print(emote, emote.id, "EmoteGlobal")
                
                self.globalEmoteList.append(emote.code)
                self.emoteList.append(emote.code)
                
                
                let destination: DownloadRequest.Destination = { _, _ in
                    //print(Bundle.main.resourceURL, "URL!!!")
                    let pathOfFile = Bundle.main.resourceURL!.appendingPathComponent("twitch global emotes/\(emote.code).png")
                    print("pathoffile", pathOfFile)
                    return (pathOfFile, [.removePreviousFile, .createIntermediateDirectories])
                }
                
                //print("SDJFKSDJFKSDFJ")
                
                //print(emote.urls)
                
                let emoteURLProcessed = "https://static-cdn.jtvnw.net/emoticons/v1/\(emote.id)/3.0"
                
//                let emoteURLProcessed = URLRequest(url: URL(string: String(emoteURLNotProcessed[emoteURLNotProcessed.index(emoteURLNotProcessed.startIndex, offsetBy: 2)...]))!)
                
                
                AF.download(emoteURLProcessed, to: destination).response { response in
                    debugPrint(response)

                    if response.error == nil, let imagePath = response.fileURL?.path {
                        let image = UIImage(contentsOfFile: imagePath)
                    }
                }
                
            }
        }
            
        
    }
    @IBOutlet weak var testimageview: UIImageView!
    
    ///update chat
    func updateChat(){
        
        ///if over a certain number
        if msgGlobalArray.count > maxNumMessages{
            msgGlobalArray.remove(at: 0)
        }
        
        ///append all messages in msgGlobalArray
        let textToBeDisplayed = NSMutableAttributedString()
        for msg in msgGlobalArray{
            for text in msg.msg{
                textToBeDisplayed.append(text)
            }
        }
        print(textToBeDisplayed, "texttobedisplayed")
        Chat.attributedText = textToBeDisplayed
    }
    
    func displayText(msgArray: msgStruct, emoteArray: [emoteStruct]){
        
        ///add to global array
        msgGlobalArray.append(msgArray)
        
        
        for emote in emoteArray{
            guard let emoteURLProcessed = URL(string:  "https://static-cdn.jtvnw.net/emoticons/v1/\(emote.id)/3.0") else { return }
            AF.request(emoteURLProcessed).responseImage { [self] response in
                if case .success(let image) = response.result {
                    //print("image downloaded: \(image)")
                    
                    guard let data = image.pngData() else {return}
                    let imageAttatchment = YYImage(data: data)
                    
                    let imageString = NSAttributedString.bs_attachmentString(with: imageAttatchment, fontSize: 20)!
                    
                    let tempMsg = NSMutableAttributedString()
                    tempMsg.append(imageString)
                    
                    let msgGlobalID = getMsgId(msg: msgArray)
                    
                    ///if end character - add newline
                    if emote.numInList == msgGlobalArray[msgGlobalID].msg.count - 1{
                        tempMsg.append(NSMutableAttributedString(string: "\n"))
                    }
                    //print(msgGlobalArray, emote.numInList)
                    msgGlobalArray[msgGlobalID].msg[emote.numInList] = tempMsg
                    
                    
                    updateChat()
                    
                }
            }

        }
    }
    
    func getMsgId(msg: msgStruct) -> Int{
        //print(msg, "MSGSG")
        if let first = msgGlobalArray.first{
            //print(first, "FIRST")
            if msg.id >= first.id{
                return msg.id - first.id
            }
        } else{
            return 0
        }
        return -1
        
    }
    
    ///detecting each chat message as it comes in
    func handleText(text: String){
        
        ///tag processing
        let firstSpace = text.firstIndex(of: " ") ?? text.startIndex
        let tagSubstring = text[...firstSpace]
        let tagArray = String(tagSubstring).components(separatedBy: ";")
        
        let restOfString = text[firstSpace...]
        
        var msg = ""
        
        ///get msg processing - PRIVMSG makes sure it's a message to the channel
        if restOfString.contains("PRIVMSG"){
            
            ///get raw message
            let channelNotice = restOfString.index(restOfString.endIndex(of: channelName)!, offsetBy: 2, limitedBy: restOfString.endIndex)!
            
            //print(channelNotice,restOfString, channelName)
            
            msg = String(restOfString[channelNotice...])
            //print(msg)
        }
        else{
            return
        }
        
        print("RAN!!")
        ///detecting emotes in string
        let msgAttributedString = NSMutableAttributedString(string: msg)
        
        ///processing tags - to get name
        var tagDict: [String:String] = [:]
        
        for i in tagArray{
            if let equalsIndex = i.firstIndex(of: "="){
                tagDict[String(i[..<equalsIndex])] = String(i[i.index(equalsIndex, offsetBy: 1)...])
            }
        }
        
        //print(tagDict["emotes"])
        
        ///process emotes by making a huge array and splitting the array of the msg up into different parts including the emotes
        
        var msgArray = msgStruct(msg: [], id: msgidNum)
        msgidNum += 1
        var emoteArray : [emoteStruct] = []
        
        ///format: [[Beginning, End]]
        var rangeArray : [[Int]] = []
        
        ///append displayName
        guard let displayName = tagDict["display-name"] else {return}
        let displayed = NSMutableAttributedString(string: displayName + ": ")
        
        msgArray.msg.append(displayed)
        
        ///process emotes
        if tagDict["emotes"] != ""{
            for emoteSection in (tagDict["emotes"] ?? "").components(separatedBy: "/"){
                let emoteandrange = emoteSection.components(separatedBy: ":")
               // guard let emoteURLProcessed = URL(string:  "https://static-cdn.jtvnw.net/emoticons/v1/\(emoteandrange[0])/3.0") else { return }
                
                ///get the id and the ranges emote occupies
                let id = emoteandrange[0]
                //print(emoteandrange, "emoteandrange")
                let ranges = emoteandrange[1].components(separatedBy: ",")
                for range in ranges{
                    let rangeList = range.components(separatedBy: "-").map {
                        Int($0)!
                    }
                    
                    ///addd emote and ranges emote occupies to array
                    emoteArray.append(emoteStruct(id: id, lowerNum: rangeList[0], upperNum: rangeList[1]))
                }
                    
            }
                
        }
        
        ///sort range array
        emoteArray = emoteArray.sorted { $0.upperNum < $1.lowerNum}
        
        //print(rangeArray, emoteArray, "SDF")
        
        var previousNum = 0
        var upperNum = 0
        var counter = 0
        if emoteArray.count >= 1{
            for emote in emoteArray{
                if emote.lowerNum > previousNum{
                    let previousIndex = msg.index(msg.startIndex, offsetBy: previousNum + 1)
                    let lowerIndex = msg.index(msg.startIndex, offsetBy: emote.lowerNum)
                    let upperIndex = msg.index(msg.startIndex, offsetBy: emote.upperNum)
                    
                    
                    //print("LOWERNUM")
                    msgArray.msg.append(NSMutableAttributedString(string: String(msg[previousIndex..<lowerIndex])))
                    msgArray.msg.append(NSMutableAttributedString(string: String(msg[lowerIndex...upperIndex])))
                    
                    emoteArray[counter].numInList = msgArray.msg.count - 1
                    //print(emote.numInList, "NUMINLIST!!!")
                }
                else{
                    let lowerIndex = msg.index(msg.startIndex, offsetBy: emote.lowerNum)
                    let upperIndex = msg.index(msg.startIndex, offsetBy: emote.upperNum)
                    msgArray.msg.append(NSMutableAttributedString(string: String(msg[lowerIndex...upperIndex])))
                    
                    emoteArray[counter].numInList = msgArray.msg.count - 1
                    //print(emote.numInList, "NUMINLIST!!!")
                    
                }
                previousNum = emote.upperNum
                upperNum = emote.upperNum
                counter += 1
                
            }
        
        ///print(msgArray.msg, "SDFSDMFSD", upperNum, msg.count - 1, msg.count, msg)
        
        /// minus 2 because of the newline character at the end
            if msg.count - 2 > upperNum{
                let previousIndex = msg.index(msg.startIndex, offsetBy: previousNum + 1)
                let upperIndex = msg.endIndex
                
                
                msgArray.msg.append(NSMutableAttributedString(string: String(msg[previousIndex...])))
            }
        }
        else{
            msgArray.msg.append(NSMutableAttributedString(string: msg))
            
        }
        
        //print(msgArray)
        
        displayText(msgArray: msgArray, emoteArray: emoteArray)
        
        updateChat()
        
        //print(tagDict, "tagDict")
        
        for emote in emoteList{
            var ranges = nsranges(msg: msg, emote: emote)
            
            ranges.reverse()
           //print(ranges, msg)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            //print(emote, "Emote name", documentsURL)
            var fileURL = documentsURL.appendingPathComponent("\(emote).png")
            if gifEmotes.contains(emote){
                print("A GIF!!!")
                fileURL = documentsURL.appendingPathComponent("\(emote).gif")
            }
            
            
            for range in ranges{
                
                var newRange = range
                //print(newRange)
                
                var isLowerSpace = false
                var isUpperSpace = false
                
                ///check if upper and lower spaces are white
                
                //print(newRange.upperBound, newRange.lowerBound)
                ///check if in beginning of sentence
                if newRange.lowerBound == 0{
                    isLowerSpace = true
                }
                
                else{
                    //print(newRange.lowerBound)
                    if msg[msg.index(msg.startIndex, offsetBy: newRange.lowerBound - 1)] == " "{
                        isLowerSpace = true
                    }
                }
                
                ///check if in end of sentence
                if newRange.upperBound == msg.count - 1{
                    isUpperSpace = true
                    //print("UPPERBOUND")
                }
                else{
                    //print(newRange.upperBound)
                    if msg.index(msg.startIndex, offsetBy: newRange.upperBound) > msg.endIndex{
                        //print(msg, newRange.upperBound)
                    }
                    if msg[msg.index(msg.startIndex, offsetBy: newRange.upperBound)] == " "{
                        isUpperSpace = true
                    }
                }
                
                ///if in between two spaces - add attatchment and do attributedstring stuff to add the image
                if isLowerSpace && isUpperSpace{
                    
                    ///get image
                    do {
                        
                        ///if gif:
                        if gifEmotes.contains(emote){
                           // print("Contains GIF")
                            let imageData = try Data(contentsOf: fileURL)
                            let imageView = YYAnimatedImageView(image: YYImage(data: imageData))
                            
                            let font = UIFont.systemFont(ofSize: 20)
                            
                            let imageString = NSMutableAttributedString.bs_attachmentString(with: imageView, contentMode: .center, attachmentSize: imageView.frame.size, alignTo: font, alignment: TextVerticalAlignment.center)!
                            
                            //print(newRange, msgAttributedString)
                            msgAttributedString.replaceCharacters(in: newRange, with: imageString)
                            
                            msg = msgAttributedString.string
                        }
                        else if emojisList.contains(emote){
                            
                            if let pathOfFile = Bundle.main.url(forResource: "\(String(emojisList.firstIndex(of: emote)!))", withExtension: "png", subdirectory: "twitch emojis"){
                                
                                print("PATH!!")
                                let imageData = try Data(contentsOf: pathOfFile)
                                let imageAttatchment = YYImage(data: imageData)
                                
                                let imageString = NSAttributedString.bs_attachmentString(with: imageAttatchment, fontSize: 20)!
                                //print(newRange, msgAttributedString)
                                msgAttributedString.replaceCharacters(in: newRange, with: imageString)
                                
                                msg = msgAttributedString.string
                                
                            }
                        }
                        else if globalEmoteList.contains(emote){
                            if let pathfile = Bundle.main.resourceURL{
                                let pathOfFile = pathfile.appendingPathComponent("twitch global emotes/\(emote).png")
                                
                                print("globalemotePATH!!")
                                let imageData = try Data(contentsOf: pathOfFile)
                                let imageAttatchment = YYImage(data: imageData)
                                
                                let imageString = NSAttributedString.bs_attachmentString(with: imageAttatchment, fontSize: 20)!
                                //print(newRange, msgAttributedString)
                                msgAttributedString.replaceCharacters(in: newRange, with: imageString)
                                
                                msg = msgAttributedString.string
                                
                            }
                            
                        }
                        else{
                            let imageData = try Data(contentsOf: fileURL)
                            let imageAttatchment = YYImage(data: imageData)
                            
                            let imageString = NSAttributedString.bs_attachmentString(with: imageAttatchment, fontSize: 20)!
                            //print(newRange, msgAttributedString)
                            msgAttributedString.replaceCharacters(in: newRange, with: imageString)
                            
                            msg = msgAttributedString.string
                        }
                    } catch {
                        print("Error loading image : \(error)")
                    }
                }
            }
            
        }
        
    }
    
    func BSTextSetup(){
        do {
            Chat.frame = chatView.frame
            
            view.addSubview(Chat)
            print("Successful!")
        } catch {
            print("Error loading image : \(error)")
        }
    }
    
    ///websocket error
    func handleError(_ error: Error?) {
            if let e = error as? WSError {
                print("websocket encountered an error: \(e.message)")
            } else if let e = error {
                print("websocket encountered an error: \(e.localizedDescription)")
            } else {
                print("websocket encountered an error")
            }
        }
    
    func nsranges(msg: String, emote: String) -> [NSRange]{
        var currentEmotePos = 0
        var firstPos = 0
        var currentPosition = 0
        var result : [NSRange] = []
        for char in msg{
            if char == emote[emote.index(emote.startIndex, offsetBy: currentEmotePos)]{
                if currentEmotePos == 0{
                    firstPos = currentPosition
                }
                currentEmotePos += 1
            }
            else if currentEmotePos > 0{
                currentEmotePos = 0
            }
            if currentEmotePos == emote.count{
                result.append(NSRange(location: firstPos, length: emote.count))
                currentEmotePos = 0
                //print(firstPos, emote.count + firstPos, "SDF", msg, emote)
            }
            currentPosition += 1
            //print(currentEmotePos, char, currentPosition)
        }
        
        return result
        
    }
    
    
    ///download emotes as soon as get a channel
    func getEmotes(){
        let url = URL(string: "https://api.frankerfacez.com/v1/room/\(channelNameWithout)")!
        let request = AF.request(url)
        
        
        ///processing of JSON from FFZ API
        request.responseDecodable(of: Rooms.self) { (response) in
            guard let rooms = response.value else { return }
            let setID = rooms.room.setID
            
            //let twitchID = rooms.room.twitchID
            
            guard let setsList = rooms.sets[String(setID)] else {return }
            
            ///get FFZ emotes
            for emote in setsList.emotes{
                ///list of emotes
                self.emoteList.append(emote.name)
                
                ///download emote
                
                ///emote location
                let destination: DownloadRequest.Destination = { _, _ in
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsURL.appendingPathComponent("\(emote.name).png")

                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                
                //print(emote.urls)
                
                let emoteURLProcessed = "https:" + (emote.urls["1"]!)
                
//                let emoteURLProcessed = URLRequest(url: URL(string: String(emoteURLNotProcessed[emoteURLNotProcessed.index(emoteURLNotProcessed.startIndex, offsetBy: 2)...]))!)
                
                
                AF.download(emoteURLProcessed, to: destination).response { response in
                    debugPrint(response)

                    if response.error == nil, let imagePath = response.fileURL?.path {
                        let image = UIImage(contentsOfFile: imagePath)
                    }
                }
            }
            
            //print(twitchID, "USERID")
            //self.getBTTVEmotes(twitchID: twitchID)
            
          }
        
        
    }
    
    func getBTTVEmotes(twitchID: Int){
        ///get BTTV emotes
        let bttvURL = URL(string: "https://api.betterttv.net/3/cached/users/twitch/\(String(twitchID))")!
        let bttvRequest = AF.request(bttvURL)
        
        //print("BTTV!")
        ///processing BTTV Emotes
        bttvRequest.responseDecodable(of: BTTVId.self) { (response) in
            guard let bttvid = response.value else { return }
            
            var bttvemotes = bttvid.BTTVEmotes
                
            bttvemotes.append(contentsOf: bttvid.sharedEmotes)
            //print(bttvemotes)
            
            var tempeemotes : [String] = []
            for emote in bttvemotes{
                
                ///if not in FFZ emotes already
                if !self.emoteList.contains(emote.name){
                    ///get url
                    //print(emote.id, "bttvid")
                    var bttvEmoteProcessed = "https://cdn.betterttv.net/emote/\(emote.id)/1x"
                    
                    ///add to gifs list if a gif
                    if emote.imageType == "gif"{
                        self.gifEmotes.append(emote.name)
                        bttvEmoteProcessed = "https://cdn.betterttv.net/emote/\(emote.id)/1x"
                    }
                    
                    self.emoteList.append(emote.name)
                    
                    ///download emote
                    ///emote location
                    let destination: DownloadRequest.Destination = { _, _ in
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let fileURL = documentsURL.appendingPathComponent("\(emote.name).\(emote.imageType)")

                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    
                    
                    AF.download(bttvEmoteProcessed, to: destination).response { response in
                       // debugPrint(response)

                        if response.error == nil, let imagePath = response.fileURL?.path {
                            let image = UIImage(contentsOfFile: imagePath)
                        }
                    }
                   // print("successful bttv")
                }
               // print(self.gifEmotes, "gif emotes")
            }
            
           // print(self.emoteList, "EMOTE LIST")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///get global emotes
        let test = #":) :( :O :Z B) :\ ;) ;p :p R) O_o :D >( <3"#
        ///:) :( :o :z B) :\ ;) ;p :p R) o_O :D >( <3 <3 R) :> <] :7 :( :P ;P :O :\ :| :s :D o_O >( :) B) ;) #/"#
        
        emojisList = test.components(separatedBy: " ")
        emoteList.append(contentsOf: emojisList)
        
        BSTextSetup()
        
        getGlobalEmotes()
        
        //getUserID(channel: channelNameWithout)
        
        ///configure channelname
        channelName = "#" + channelNameWithout
        
        ///connect to IRC chat
        var request = URLRequest(url: URL(string: "wss://irc-ws.chat.twitch.tv:443")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        ///load webview
        let url = URL(string: "http://localhost:8080/index.html")!
        webView.load(URLRequest(url: url))
        
        let loginURL = URL(string: "https://id.twitch.tv/oauth2/authorize?response_type=token&client_id=om32h2qnvirwp87ueis6rdfkvvgqoh&redirect_uri=http://localhost:8080/getid.html&scope=viewing_activity_read&state=d57b85c0-421e-47d8-92b8-083510ac4d2e")!
        loginWebView.load(URLRequest(url: loginURL))
        
        webView.scrollView.isScrollEnabled = false
    }
    
    
    ///starting the server to allow twitch embed
    static let webServer = GCDWebServer()
    static func initWebServer() {
        
        guard let websitePath = Bundle.main.path(forResource: "server", ofType: nil) else { return }
        webServer.addGETHandler(forBasePath: "/", directoryPath: websitePath, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
        webServer.addHandler(forMethod: "GET", pathRegex: "/.*\\.html", request: GCDWebServerRequest.self) { (request) in
            return GCDWebServerDataResponse(htmlTemplate: websitePath + request.path, variables: ["variable": "value"])
        }
        webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
        
        
        print("Visit \(webServer.serverURL) in your web browser")
    }
    
    @IBAction func StartWebSocketPressed(_ sender: Any) {
        webView.evaluateJavaScript("player.play();", completionHandler: nil)
    }
    
    @IBAction func StopWebSocketPressed(_ sender: UIBarButtonItem) {
        if isConnected{
            sender.title = "Connect"
            socket.disconnect()
        }
        else{
            sender.title = "Disconnect"
            socket.connect()
        }
    }
    

}


///find substring in string extension
extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
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
        
        guard let tempaccess = getiddict["#access_token"] else {return}
        
        accesstoken = tempaccess
        
        ///get bttv emotes
        getUserID(channel: channelNameWithout, accesstoken: accesstoken)
        print(getiddict, accesstoken, "message bdy")
    }
}
