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
import BSText
import YYImage
import SDWebImage
import SDWebImageYYPlugin
import Kingfisher
//import netfox
import Gifu

struct emoteStruct{
    var numInList: Int = -1
    var id = ""
    var lowerNum: Int = -1
    var upperNum : Int = -1
    var type = emoteType.normal
    var ending = pictureType.png
    var name = ""
}

struct passingGifs{
    var url: URL
    var size: CGSize
}

struct emoteGifLocation{
    var url : URL
    var size : CGSize
    var location : CGPoint
}

struct customEmote{
    var name = ""
    var id = ""
    var ending = pictureType.png
}

struct msgStruct{
    var msg : [NSMutableAttributedString] = []
    var rawTextMsg : String
    var id = -1
    
    ///starting msg id, after the colon
    var startingMsgId = -1
    
    
    var uniqueId = ""
    
    var numEmotes = 0
    var numEmotesUploaded = 0
    var hasRan = false
    var hasGif = false
    var channelName = ""
    
    var gifDict : [Int : passingGifs] = [:]
}

enum lightModeDarkMode{
    case light, dark
}

enum emoteType{
    case bttv, ffz, normal, badge
}

enum pictureType{
    case png, gif
}

struct currentMsgStruct{
    var msg : NSMutableAttributedString
    var globalId: Int
    
    var uniqueId : String
}

struct syncGif{
    var date: Date
    var frameCount : Int
    var frameDuration : Double
}

class ChatViewController: UIViewController, WKNavigationDelegate {
    
    ///WebSocket to connect
    var socket: WebSocket!
    var readingSocket: WebSocket!
    
    var isConnected = false
    
    @IBOutlet var yepChatLabel: UILabel!
    
    ///channels
    var channelName = ""
    var channelNameWithout = "twitch"
    
    ///auth token
    var accesstoken = ""
    
    //light or dark mode
    var themeMode : lightModeDarkMode = .light
    
    ///max messages
    var maxNumMessages = 50
    
    var rangesToDelete: [NSRange] = []
    
    var currentShownMessages: [currentMsgStruct] = []
    
    @IBOutlet var tutorialView: UIView!
    
    ///Dictionary of all badges and custom badges, in the form Name:Link
    var badgeDict: [String:String] = [:]
    
    var emoteList: [String] = []
    var gifEmotes: [String] = []
    
    var bttvEmotes: [String] = []
    var ffzEmotes: [String] = []
    var emojisList: [String] = []
    
    var globalEmoteList: [String] = []
    var msgGlobalArray: [msgStruct] = []
    var bttvPreProcessedEmotes : [customEmote] = []
    var ffzPreProcessedEmotes: [customEmote] = []
    
    ///scales
    var ffzScale: String = ""
    var bttvScale: String = ""
    
    var twitchID: Int = 0
    
    var msgidNum: Int = 0
    
    ///login
    @IBOutlet weak var loginWebView: WKWebView!
    @IBOutlet weak var hideLoginWebView: UIView!
    
    ///send chat button
    @IBOutlet weak var sendChatButton: UIButton!
    var chatMessageToSend = ""
    
    ///type in chat
    @IBOutlet weak var typeInChatMasterView: UIView!
    @IBOutlet var typeInChatOverView: UIView!
    @IBOutlet var typeInChatMasterViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var typeInChatMasterViewTopConstraint: NSLayoutConstraint!
    var typeInChatView = BSTextView()
    @IBOutlet weak var typeChatPlaceholder: UIView!
    var typeInChatMasterViewNewBottomConstraint : NSLayoutConstraint?
    var typeInChatMasterViewHeight : NSLayoutConstraint?
    @IBOutlet var chatTableViewHeight: NSLayoutConstraint!
    var chatTableNewHeight : NSLayoutConstraint?
    
    @IBOutlet var mainStackView: UIStackView!
    
    @IBOutlet var noKeyboardConstraint: NSLayoutConstraint!
    var keyboardConstraint : NSLayoutConstraint!
    
    var chatTableOldHeight : CGFloat = 0
    
    ///clientid
    ///
    ///
    /// ---------OMITTED FOR DATA SENSITIVE PURPOSES, IF USING REPLACE WITH YOUR OWN CLIENT ID
    /// OBTAINED FROM YOUR TWITCH DEVELOPER PAGE!!!-------------------------
    ///
    var clientid = ""
    
    ///username
    var username = ""
    
    ///actual chat ui
    var Chat = BSTextView()
    
    @IBOutlet weak var chatTableView: UITableView!
    
    var setOfFinishedIndexPaths: Set<IndexPath> = []
    
    var heightDict : [Int : CGFloat] = [:]
    
    var gifDict : [IndexPath : [emoteGifLocation]] = [:]
    
    ///font + line spacing for setting up the images
    var lineSpace : CGFloat = 8

    var emoteFont = UIFont.systemFont(ofSize: 20)
    var textFont = UIFont.systemFont(ofSize: 20)
    var italicsFont = UIFont.italicSystemFont(ofSize: 20)
    
    ///url of gif to its corresponding info
    var syncGifDict : [URL : syncGif] = [:]
    
    var autoScroll = true
    
    var cellWidth : CGFloat = 0
    
    var gifSyncEnabled = false
    
    var autoScrollLimit = 25
    
    var nonAutoScrollLimit = 500
    
    ///tutorial view controller
    var tutorialVC : TutorialVC?
    
    ///chat msg spacing
    var chatMsgSpacing : CGFloat = 8
    var chatVerticalSpacing : CGFloat = 4
    
    ///the actual video
    @IBOutlet weak var videoTapView: UIView!
    @IBOutlet weak var videoWebView: WKWebView!
    
    ///playback control
    var isPause = true
    
    var isControlsEnabled  = false
    @IBOutlet weak var playpauseButton: UIButton!
    
    ///main view controllers
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var typeChatView: UIView!
    
    ///labels for the channel and changing the channel
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet var changeChannelMasterView: UIView!
    @IBOutlet var channelLabelOverView: RoundedCornersLeftSideOnly!
    @IBOutlet weak var changeChannelTextField: UITextField!
    @IBOutlet var changeChannelOverView: RoundedCornersRightSideOnly!
    
    ///buttons
    @IBOutlet var changeChannelButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    
    @IBOutlet var border1: UIView!
    @IBOutlet var border2: UIView!
    @IBOutlet var border3: UIView!
    
    var keyboardDuration : Double = 0
    var keyboardCurve : UInt = 0
    
    @IBOutlet var autoScrollButton: UIButton!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        NFX.sharedInstance().start()
        
        print("View is appearing!")
        
        ChatViewController.initWebServer()
        
        ///add this script as a userContentController to enable it to receive js messages from server
        self.loginWebView.configuration.userContentController.add(self, name: "getID")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        typeInChatMasterViewHeight = typeInChatMasterView.heightAnchor.constraint(equalToConstant:typeInChatMasterView.frame.size.height)
        
        chatTableOldHeight = chatTableView.frame.height
        
        changeChannelTextField.font = channelLabel.font
        
        changeChannelOverView.roundCorners()
        channelLabelOverView.roundCorners()
        
        print(channelLabel.font, changeChannelTextField.font)
    }
    
    ///connecting to chat
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            
            ///get username
            getUserName(clientID: clientid, authToken: accesstoken)
            
            ///get bttv emotes
            getUserID(channel: channelNameWithout, accesstoken: accesstoken)
            
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            
            if autoScroll || currentShownMessages.count < nonAutoScrollLimit {
                ///pong back to ensure not disconnected
                if string.contains("PING :tmi.twitch.tv"){
                    print("pinged!!!")
                    socket.write(string: "PONG :tmi.twitch.tv")
                }
                
                handleText(text: string)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            print("Pinged!!! POGGIES!")
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
        
        ///scroll to bottom
        let point = CGPoint(x: 0.0, y: (Chat.contentSize.height - Chat.bounds.height))
        Chat.setContentOffset(point, animated: false)
        
        Chat.attributedText = textToBeDisplayed
    }
    
    func addRowChat(msgGlobalID: Int, id : Int){
        var msgGlobalID = msgGlobalID
        
        ///Protection if msgGlobalId greater than msgGlobalArray for whatever reason
        if msgGlobalID >= msgGlobalArray.count || msgGlobalID == -1{
            print("ID More than msgGlobalArray count")
            return
        }
        
        ///if the chat message hasn't been added yet - add it
        if !msgGlobalArray[msgGlobalID].hasRan{
            let message = NSMutableAttributedString()
            
            for part in msgGlobalArray[msgGlobalID].msg{
                message.append(part)
            }
            
            currentShownMessages.append(currentMsgStruct(msg: message, globalId: id, uniqueId: msgGlobalArray[msgGlobalID].uniqueId))
            
            UIView.setAnimationsEnabled(false)
            print("a")
            chatTableView.beginUpdates()
            chatTableView.insertRows(at: [IndexPath(row: currentShownMessages.count - 1,section: 0)], with: .none)
            
            chatTableView.endUpdates()
            
            
            
            if autoScroll && currentShownMessages.count > autoScrollLimit{
                let currentmsg = msgGlobalArray[msgGlobalID]
                
                chatTableView.beginUpdates()
                print(msgGlobalID, "msgglobalID")
                
                var indexPaths : [IndexPath] = []
                for n in 0..<(currentShownMessages.count - autoScrollLimit){
                    print("does it get here?")
                    currentShownMessages.remove(at: 0)
                    msgGlobalArray.remove(at: 0)
                    indexPaths.append(IndexPath(row: n, section: 0))
                }
                
                chatTableView.deleteRows(at:indexPaths, with: .none)
                
                chatTableView.endUpdates()
                
                msgGlobalID = getMsgId(msg: currentmsg)
            }
            
            UIView.setAnimationsEnabled(true)
            msgGlobalArray[msgGlobalID].hasRan = true
        }
        
        ///if it has - just update the picture
        else if msgGlobalArray[msgGlobalID].numEmotesUploaded >= msgGlobalArray[msgGlobalID].numEmotes{
            let cellPath = IndexPath(row: msgGlobalID, section: 0)
            
            let message = NSMutableAttributedString()
            
            for (count, part) in msgGlobalArray[msgGlobalID].msg.enumerated(){
                message.append(part)
                
                if let gifURL = msgGlobalArray[msgGlobalID].gifDict[count]{
                    let msgWidth = ceil(message.size().width)
                    
                    let numRows = ceil(msgWidth/chatTableView.frame.size.width)
                    
                    let calculatedHeight =  numRows * emoteFont.pointSize + (numRows + 1) * lineSpace
                    
                    gifDict[cellPath, default: []].append(emoteGifLocation(url: gifURL.url, size: CGSize(width: gifURL.size.width, height: gifURL.size.height), location: CGPoint(x: (message.size().width - gifURL.size.width/2).truncatingRemainder(dividingBy: (cellWidth - 10)), y: calculatedHeight - gifURL.size.height/2)))
                }
            }
            
            let rangeOfString = NSMakeRange(0, message.string.count)
            
            message.bs_set(maximumLineHeight: emoteFont.pointSize, range: rangeOfString)
            message.bs_set(lineSpacing: lineSpace, range: rangeOfString)
            
            currentShownMessages[msgGlobalID] = currentMsgStruct(msg: message, globalId: currentShownMessages[msgGlobalID].globalId, uniqueId: msgGlobalArray[msgGlobalID].uniqueId)
            
            setOfFinishedIndexPaths.insert(cellPath)
            
            
            if let paths = chatTableView.indexPathsForVisibleRows{
                if paths.contains(cellPath){
                    if let cell = chatTableView.cellForRow(at: cellPath) as? ChatMessage{
                        
                        if gifSyncEnabled{
                            syncGifs(attributedText: message)
                        }
                        
                        cell.chatmsg.attributedText = message
                        
                        UIView.performWithoutAnimation {
                            chatTableView.beginUpdates()
                            setHeight(cell: cell, indexPath: cellPath, id: id)
                            chatTableView.endUpdates()
                        }
                        
                    }
                }
            }
        }
        
        if autoScroll{
            let cell = chatTableView.cellForRow(at: IndexPath(row: currentShownMessages.count - 1, section: 0))
            cell?.layoutIfNeeded()
            chatTableView.scrollToRow(at: IndexPath(row: currentShownMessages.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    @IBAction func autoScrollButtonPressed(_ sender: Any) {
        autoScroll = true
        
        if currentShownMessages.count > 0{
            let cell = chatTableView.cellForRow(at: IndexPath(row: currentShownMessages.count - 1, section: 0))
            cell?.layoutIfNeeded()
            chatTableView.scrollToRow(at: IndexPath(row: currentShownMessages.count - 1, section: 0), at: .bottom, animated: false)
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.autoScrollButton.alpha = 0
        }, completion: {_ in
            self.autoScrollButton.isHidden = true
        })
    }
    
    func syncGifs(attributedText : NSAttributedString){
        
        attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: [], using: {
            (value,range,stop) in
            for (k, v) in value{
                if k == NSAttributedString.Key.init("TextAttachment"),let bsattachments = v as? BSText.TextAttachment, let image = bsattachments.content as? YYAnimatedImageView, let url = image.sd_imageURL, let gifInfo = syncGifDict[url]{
                    
                    let timeSince = Date().timeIntervalSince(gifInfo.date)/gifInfo.frameDuration
                    
                    image.stopAnimating()
                    image.currentAnimatedImageIndex = UInt(Int(ceil(timeSince)) % gifInfo.frameCount)
                        
                    let timeToDelay = (ceil(timeSince) - timeSince) * gifInfo.frameDuration

                    DispatchQueue.main.asyncAfter(deadline: .now() + timeToDelay){
                        image.startAnimating()
                    }
                    print("synced!", gifInfo.frameCount, gifInfo.frameDuration, url)
                }
            }
        })
        
    }
    
    
    ///creatae gifs in the cell
//    func makeGifs(cellPath: IndexPath, cell: ChatMessage){
//        guard let emoteGifDict = gifDict[cellPath] else {return}
//
//        for gif in emoteGifDict{
//            let gifAnimation = YYAnimatedImageView()
//
//            gifAnimation.sd_setImage(with: gif.url){[self] (image,_,_,_)  in
//
//                cell.chatmsg.addSubview(gifAnimation)
//
//                if let gifInfo = syncGifDict[gif.url]{
//                    let timeSince = Date().timeIntervalSince(gifInfo.date)/gifInfo.frameDuration
//
//                    gifAnimation.currentAnimatedImageIndex = UInt(Int(ceil(timeSince)) % gifInfo.frameCount)
//                }
//                else{
//                    if let image = image as? YYAnimatedImage{
//                       syncGifDict[gif.url] = syncGif(date: Date(), frameCount: Int(image.animatedImageFrameCount()), frameDuration: image.animatedImageDuration(at: 0))
//                    }
//                }
//                gifAnimation.frame.size = gif.size
//                gifAnimation.center = gif.location
//            }
//
//        }
//    }
    
    func setHeight(cell: ChatMessage, indexPath: IndexPath, id: Int){
        ///calculations to get actual height
        let width = cell.frame.size.width
        
        let numRows = ceil(cell.chatmsg.intrinsicContentSize.width/width)
        
        let calculatedHeight =  numRows * cell.chatmsg.intrinsicContentSize.height + (numRows + 1) * lineSpace
        
        ///manually resize height since BSText doesn't seem to support autolayout
        heightDict[id] = calculatedHeight
        
        cell.chatmsg.frame = CGRect(x: chatMsgSpacing, y: chatVerticalSpacing, width: cell.frame.size.width - chatMsgSpacing * 2, height: calculatedHeight)
        
    }
    
    func displayText(msgArray: msgStruct, emoteArray: [emoteStruct]){
        
        var msgArray = msgArray
        
        ///add to global array
        msgGlobalArray.append(msgArray)
        
        for emote in emoteArray{
            switch emote.type{
            case .normal:
                guard let emoteURLProcessed = URL(string:  "https://static-cdn.jtvnw.net/emoticons/v2/\(emote.id)/default/\(themeMode)/\(bttvScale).0") else {return }
                
                addImageToAttributedText(emoteURLProcessed: emoteURLProcessed, emote: emote, msg: msgArray)
            
            case .bttv:
                
                guard let emoteURLProcessed = URL(string:  "https://cdn.betterttv.net/emote/\(emote.id)/\(bttvScale)x") else { return }
                
                switch emote.ending{
                case .png:
                    addImageToAttributedText(emoteURLProcessed: emoteURLProcessed, emote: emote, msg: msgArray)
                    
                case .gif:
                    
                    ///whether or not has gif, for optimization purposes
                    if !msgArray.hasGif{
                        msgArray.hasGif = true
                    }
                    
                    let tempimage = YYAnimatedImageView()
                    
                    
                    tempimage.sd_setImage(with: emoteURLProcessed){[self] (image,_,_,_)  in
                        if let image = image{
                            let ratio = image.size.width/image.size.height
                            
                            let newHeight = emoteFont.pointSize + lineSpace
                            
                            let resizedSize = CGSize(width: ratio * newHeight, height: newHeight)
                            
                            tempimage.frame.size = resizedSize
                            
                            
                        }
                        
                        if let gifInfo = syncGifDict[emoteURLProcessed]{
                            let timeSince = Date().timeIntervalSince(gifInfo.date)/gifInfo.frameDuration
                            
                            tempimage.currentAnimatedImageIndex = UInt(Int(ceil(timeSince)) % gifInfo.frameCount)
                        }
                        else{
                            if let image = image as? YYAnimatedImage{
                               syncGifDict[emoteURLProcessed] = syncGif(date: Date(), frameCount: Int(image.animatedImageFrameCount()), frameDuration: image.animatedImageDuration(at: 0))
                            }
                        }
                        
                        print("This happened!)")
                        
                        let imageString = NSMutableAttributedString.bs_attachmentString(with: tempimage, contentMode: .center, attachmentSize: tempimage.frame.size, alignTo: emoteFont, alignment: TextVerticalAlignment.center)!
                        
                        let msgGlobalID = getMsgId(msg: msgArray)

//                                msgGlobalArray[msgGlobalID].gifDict[emote.numInList] = passingGifs(url: emoteURLProcessed, size: resizedSize)
                        
                        ///Protection if msgGlobalId greater than msgGlobalArray for whatever reason
                        if msgGlobalID >= msgGlobalArray.count || msgGlobalID == -1{
                            print("ID More than msgGlobalArray count")
                            return
                        }
                        
                        
                        msgGlobalArray[msgGlobalID].msg[emote.numInList] = imageString
                        
                        msgGlobalArray[msgGlobalID].numEmotesUploaded += 1
                        
                        addRowChat(msgGlobalID: msgGlobalID, id:  msgGlobalArray[msgGlobalID].id)
                    }
//                    KingfisherManager.shared.retrieveImage(with: emoteURLProcessed){ [self] (result) in
//                        switch result{
//                        case .success (let value):
//                            if let image = value.image as? UIImage{
//                                let ratio = image.size.width/image.size.height
//
//                                let newHeight = font.pointSize + lineSpace
//
//                                let resizedSize = CGSize(width: ratio * newHeight, height: newHeight)
//
//                                let tempImage = YYAnimatedImageView(image: image)
//                                tempImage.frame.size = resizedSize
//
//                                print("This happened!)")
//
//                                let imageString = NSMutableAttributedString.bs_attachmentString(with: tempImage, contentMode: .center, attachmentSize: resizedSize, alignTo: font, alignment: TextVerticalAlignment.center)!
//
//                                let msgGlobalID = getMsgId(msg: msgArray)
//
////                                msgGlobalArray[msgGlobalID].gifDict[emote.numInList] = passingGifs(url: emoteURLProcessed, size: resizedSize)
//
//                                msgGlobalArray[msgGlobalID].msg[emote.numInList] = imageString
//
//                                msgGlobalArray[msgGlobalID].numEmotesUploaded += 1
//
//                                addRowChat(msgGlobalID: msgGlobalID)
//
//                            }
//                        case .failure (let error):
//                            print(error)
//                        }
//                    }
                }

                
            case .ffz:
                guard let url = URL(string: emote.id) else {return}
                
                addImageToAttributedText(emoteURLProcessed: url, emote: emote, msg: msgArray)

            case .badge:
                guard let emoteURLProcessed = URL(string: emote.id) else { return }
                
                addImageToAttributedText(emoteURLProcessed: emoteURLProcessed, emote: emote, msg: msgArray)
            }
        }
        
        addRowChat(msgGlobalID: getMsgId(msg: msgArray), id: msgArray.id)
    }
    
    ///add Images to the attirbutedText
    func addImageToAttributedText(emoteURLProcessed: URL, emote: emoteStruct, msg: msgStruct){
        let imageAttatchment = UIImageView()
        imageAttatchment.kf.setImage(with: emoteURLProcessed, placeholder: UIImage(), completionHandler: {[self] (result) in
            switch result{
            case .success(let image):
                let msgGlobalID = getMsgId(msg: msg)
                
                ///Protection if msgGlobalId greater than msgGlobalArray for whatever reason
                if msgGlobalID >= msgGlobalArray.count || msgGlobalID == -1{
                    print("ID More than msgGlobalArray count")
                    return
                }
                
                
                let ratio = image.image.size.width/image.image.size.height
                
                var newHeight = emoteFont.pointSize + lineSpace
                
                if emote.type == .badge{
                    newHeight = emoteFont.pointSize
                }
                
                
                imageAttatchment.frame.size = CGSize(width: ratio * newHeight, height: newHeight)

                let imageString = NSMutableAttributedString.bs_attachmentString(with: imageAttatchment, contentMode: .center, attachmentSize: imageAttatchment.frame.size, alignTo: emoteFont, alignment: TextVerticalAlignment.center)!
                
                print(msgGlobalID, msgGlobalArray.count, "Debug this")
                
                msgGlobalArray[msgGlobalID].msg[emote.numInList] = imageString
                
                msgGlobalArray[msgGlobalID].numEmotesUploaded += 1
                
                addRowChat(msgGlobalID: msgGlobalID, id:  msgGlobalArray[msgGlobalID].id)
            case .failure (let error):
                print("Error in loading the emotes. \(error)")
            }
        })
            
        
        
    }
    
    func getMsgId(msg: msgStruct) -> Int{
        if let first = msgGlobalArray.first{
            if msg.id >= first.id{
                return msg.id - first.id
            }
        } else{
            return 0
        }
        return -1
        
    }
    
    func processCustomEmote(emoteID: String, emoteName: String, msg: String, type: emoteType, ending: pictureType = .png) -> [emoteStruct]{
        var ranges = nsranges(msg: msg, emote: emoteName)
        
        ranges.reverse()
        
        var emoteArray : [emoteStruct] = []
        
        for range in ranges{
            
            var isLowerSpace = false
            var isUpperSpace = false
            
            ///check if upper and lower spaces are white
            
            ///check if in beginning of sentence
            if range.lowerBound == 0{
                isLowerSpace = true
            }
            
            else{
                if msg[msg.index(msg.startIndex, offsetBy: range.lowerBound - 1)] == " "{
                    isLowerSpace = true
                }
            }
            
            ///check if in end of sentence
            if range.upperBound == msg.count{
                isUpperSpace = true
            }
            else{
                if msg.index(msg.startIndex, offsetBy: range.upperBound) > msg.endIndex{
                    //print(msg, newRange.upperBound)
                }
                print(range.upperBound, msg, msg.count)
                if msg[msg.index(msg.startIndex, offsetBy: range.upperBound)] == " "{
                    isUpperSpace = true
                }
            }
            
            ///if in between two spaces - add attachment and do attributedstring stuff to add the image
            if isLowerSpace && isUpperSpace{
                switch type{
                case .bttv:
                    emoteArray.append(emoteStruct(id: emoteID, lowerNum: range.lowerBound, upperNum: range.upperBound - 1, type: type, ending: ending, name: emoteName))
                case .ffz:
                    emoteArray.append(emoteStruct(id: emoteID, lowerNum: range.lowerBound, upperNum: range.upperBound - 1, type: type, ending: ending, name: emoteName))
                case .normal:
                    print("something went wrong")
                case .badge:
                    print("something went wrong")
                }
            }
        }
        
        return emoteArray

        
    }
    
    ///delete message
    func deleteMsg(text: String){
        ///tag processing
        let firstSpace = text.firstIndex(of: " ") ?? text.startIndex
        let tagSubstring = text[...firstSpace]
        let tagArray = String(tagSubstring).components(separatedBy: ";")
        
        ///processing tags - to get name
        var tagDict: [String:String] = [:]
        
        for i in tagArray{
            if let equalsIndex = i.firstIndex(of: "="){
                tagDict[String(i[..<equalsIndex])] = String(i[i.index(equalsIndex, offsetBy: 1)...])
            }
        }
        
        var indexPathsToRefresh: [IndexPath] = []
        
        print("Should delete a message", tagDict)
        
        ///delete message from chat
        if let uniqueIdToRemove = tagDict["target-msg-id"]{
            guard let channelToClear = tagDict["@login"] else { return}
            print("Delete this id")
            for (i, message) in msgGlobalArray.enumerated(){
                    
                if message.uniqueId == uniqueIdToRemove{
                    
                    let msgToBecome = NSMutableAttributedString()
                    for num in 0..<message.startingMsgId{
                        msgToBecome.append(message.msg[num])
                    }
                    
                    let italicizedFont = [NSAttributedString.Key.font: italicsFont]

                    let messageRemoved = NSMutableAttributedString(string: "[Message removed]", attributes: italicizedFont)
                    
                    msgToBecome.append(messageRemoved)
                    
                    currentShownMessages[i].msg = msgToBecome
                    
                    indexPathsToRefresh.append(IndexPath(row: i, section: 0))
                }
            }
                
        }
        
        chatTableView.beginUpdates()
        chatTableView.reloadRows(at: indexPathsToRefresh, with: .none)
        chatTableView.endUpdates()
        
    }
    
    ///clear chat for purged, timed out, + banned msges
    func clearChat(text: String){
        ///get channel to clear
        
        let firstSpace = text.firstIndex(of: " ") ?? text.startIndex
        
        let restOfString = text[firstSpace...]
        
        var channelToClear = ""
        
        let channelNotice = restOfString.index(restOfString.endIndex(of: channelName)!, offsetBy: 2, limitedBy: restOfString.endIndex)!
        
        channelToClear = String(restOfString[channelNotice...]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Clearing channel", channelToClear)
        
        var indexPathsToRefresh : [IndexPath] = []
        ///clear from chat visually
        for (i, message) in msgGlobalArray.enumerated(){
            if message.channelName == channelToClear{
                
                let msgToBecome = NSMutableAttributedString()
                for num in 0..<message.startingMsgId{
                    msgToBecome.append(message.msg[num])
                }
                let italicizedFont = [NSAttributedString.Key.font: italicsFont]

                let messageRemoved = NSMutableAttributedString(string: "[Message removed]", attributes: italicizedFont)
                
                msgToBecome.append(messageRemoved)
                
                currentShownMessages[i].msg = msgToBecome
                
                indexPathsToRefresh.append(IndexPath(row: i, section: 0))
             }
        }
        
        chatTableView.beginUpdates()
        chatTableView.reloadRows(at: indexPathsToRefresh, with: .none)
        chatTableView.endUpdates()
    }
    
    let whiteBackgroundColor = UIColor(hexString: "#F0F0F0")
    let darkGray = UIColor(hexString: "6F6F6F")
    
    ///convert to dark/light mode
    func convertToLightMode(){
        deleteChat()
        
        autoScrollButton.setImage(UIImage(named: "arrowdownlightmode"), for: .normal)
        
        yepChatLabel.textColor = .black
        
        channelLabel.textColor = .white
        channelLabelOverView.backgroundColor = darkGray
        
        changeChannelMasterView.backgroundColor = whiteBackgroundColor
        typeInChatMasterView.backgroundColor = whiteBackgroundColor
        
        border1.backgroundColor = darkGray
        border2.backgroundColor = darkGray
        border3.backgroundColor = darkGray
        
        changeChannelTextField.textColor = darkGray
        changeChannelOverView.backgroundColor = .white
        changeChannelTextField.backgroundColor = .white
        
        settingsButton.tintColor = .black
        changeChannelButton.tintColor = .black
        sendChatButton.tintColor = .black
        
        chatTableView.backgroundColor = whiteBackgroundColor
        
        typeInChatOverView.backgroundColor = UIColor(hexString: "DBDBDB")
        
        typeInChatView.textColor = .black
        
        view.backgroundColor = whiteBackgroundColor
    }
    
    
    let blackBackgroundColor = UIColor(hexString: "#101010")
    let lightGrayDarkMode = UIColor(hexString: "#BFBFBF")
    let darkGrayDarkMode = UIColor(hexString: "#404040")
    
    func convertToDarkMode(){
        deleteChat()
        
        autoScrollButton.setImage(UIImage(named: "arrowdowndarkmode"), for: .normal)
        
        yepChatLabel.textColor = .white
        
        channelLabel.textColor = .black
        channelLabelOverView.backgroundColor = lightGrayDarkMode
        
        changeChannelMasterView.backgroundColor = blackBackgroundColor
        typeInChatMasterView.backgroundColor = blackBackgroundColor
        
        border1.backgroundColor = lightGrayDarkMode
        border2.backgroundColor = lightGrayDarkMode
        border3.backgroundColor = lightGrayDarkMode
        
        changeChannelTextField.textColor = .white
        changeChannelOverView.backgroundColor = darkGrayDarkMode
        changeChannelTextField.backgroundColor = darkGrayDarkMode
        
        settingsButton.tintColor = .white
        changeChannelButton.tintColor = .white
        sendChatButton.tintColor = .white
        
        chatTableView.backgroundColor = blackBackgroundColor
        
        typeInChatOverView.backgroundColor = darkGrayDarkMode
        
        typeInChatView.textColor = .white
        
        view.backgroundColor = blackBackgroundColor
    }
    
    
    ///detecting each chat message as it comes in
    func handleText(text: String){
        
        ///get msg processing - PRIVMSG makes sure it's a message to the channel
        if text.contains("PRIVMSG"){
            
            ///sometimes received two messages at once
            let duplicationHandler = text.components(separatedBy: "\r\n")
            
            for i in duplicationHandler{
                if i != ""{
                    print("this is the message", i)
                    addMessage(text: i)
                }
            }
        }
        else if text.contains("CLEARCHAT"){
            clearChat(text: text)
            
            return
        }
        else if text.contains("CLEARMSG"){
            deleteMsg(text: text)
            
            return
        }
        else if text.contains("USERSTATE"){
            deleteMsg(text: text)
            
            return
        }
        else if text.contains("CLEARMSG"){
            deleteMsg(text: text)
            
            return
        }
        else{
            return
        }
    }
    
    ///if adding a message
    func addMessage(text: String){
        
        print("Should add", text, typeInChatMasterView.frame.origin)
        ///tag processing
        guard let firstSpace = text.firstIndex(of: " ") else{return}
        let tagSubstring = text[...firstSpace]
        let tagArray = String(tagSubstring).components(separatedBy: ";")
        
        let restOfString = text[firstSpace...]
        
        guard var fourthIndex = text.fourthIndex(of: " ") else {return}
        
        fourthIndex = text.index(fourthIndex, offsetBy: 2)
        
        var msg = String(restOfString[fourthIndex...])
        
        ///processing tags - to get name
        var tagDict: [String:String] = [:]
        
        for i in tagArray{
            if let equalsIndex = i.firstIndex(of: "="){
                tagDict[String(i[..<equalsIndex])] = String(i[i.index(equalsIndex, offsetBy: 1)...])
            }
        }
        print(tagDict, msg)
        
        ///process emotes by making a huge array and splitting the array of the msg up into different parts including the emotes
        var msgArray = msgStruct(msg: [], rawTextMsg: msg, id: msgidNum)
        var emoteArray : [emoteStruct] = []
            
        var numBadges = 0
        
        ///add unique message id
        if let uniqueId = tagDict["id"]{
            msgArray.uniqueId = uniqueId
        }
        
        ///process badges
        if let badges = tagDict["badges"]{
            if badges != ""{
                let badgesList = badges.components(separatedBy: ",")
                
                var lowerNum = 0
                
                for i in 0..<badgesList.count * 2 + 1{
                    let displayed = NSMutableAttributedString(string: " ")
                    print("sadfsdf", i)
                    msgArray.msg.append(displayed)
                }
                
                print(msgArray.msg.count, "This is msgArray Count", badgesList.count)
                
                for badge in badgesList{
                    let tempBadge = badge.components(separatedBy: "/")[0]
                    
                    
                    if let badgeurl = badgeDict[tempBadge] {
                        ///add emote and ranges emote occupies to array
                        emoteArray.append(emoteStruct(numInList: numBadges * 2, id: badgeurl, lowerNum: numBadges - 1, upperNum: numBadges, type: .badge))
                        
                        lowerNum = lowerNum + tempBadge.length + 1
                        
                        numBadges += 1
                    }
                }
            }
        }
        
        
        ///append displayName
        guard let displayName = tagDict["display-name"] else {
            print("No display name!")
            return
        }
        
        msgArray.channelName = displayName
        
        ///color name
        var attributes : [NSAttributedString.Key : Any] = [:]
        
        var colorHex = themeMode == .light ? tagDict["color"] ?? "#000000": tagDict["color"] ?? "#FFFFFF"
        
        if colorHex == ""{
            colorHex = themeMode == .light ? "#000000":"#FFFFFF"
        }
        
        attributes = [NSAttributedString.Key.foregroundColor : UIColor(hexString: colorHex), NSAttributedString.Key.strokeWidth : -1, NSAttributedString.Key.font : textFont]

        
        let displayed = NSMutableAttributedString(string: displayName + ": ", attributes: attributes)
        
        msgArray.msg.append(displayed)
        msgArray.startingMsgId = msgArray.msg.count
        
        
        
//        print("emoteBuffer", emoteBuffer)
        
        ///process emotes
        if tagDict["emotes"] != ""{
            for emoteSection in (tagDict["emotes"] ?? "").components(separatedBy: "/"){
                let emoteandrange = emoteSection.components(separatedBy: ":")
                
                ///get the id and the ranges emote occupies
                let id = emoteandrange[0]
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
        
        ///dealing with emojis, whose unicode parsing is different from swift's'
        var emoteBuffer = 0
        
        var emotePointer = numBadges
        
        ///if any emotes as opposed to just badges
        if emoteArray.count > numBadges{
            for charPointer in 0..<msg.count{
                if msg[msg.index(msg.startIndex, offsetBy: charPointer)].unicodeScalars.count > 1{
                    emoteBuffer += 1
                }
                
                if emotePointer < emoteArray.count{
                    if emoteArray[emotePointer].lowerNum == charPointer{
                        emoteArray[emotePointer].lowerNum -= emoteBuffer
                        emoteArray[emotePointer].upperNum -= emoteBuffer
                        
                        emotePointer += 1
                    }
                }
            }
        }
        
        ///deal with the rest of the emotes
        while emotePointer < emoteArray.count{
            emoteArray[emotePointer].lowerNum -= emoteBuffer
            emoteArray[emotePointer].upperNum -= emoteBuffer
            
            emotePointer += 1
        }
        
        ///process bttv and ffz emotes
        for emote in bttvPreProcessedEmotes{
            switch emote.ending{
            case .gif:
                emoteArray.append(contentsOf:processCustomEmote(emoteID: emote.id, emoteName: emote.name, msg: msg, type: emoteType.bttv, ending:.gif))
            case .png:
                emoteArray.append(contentsOf:processCustomEmote(emoteID: emote.id, emoteName: emote.name, msg: msg, type: emoteType.bttv, ending: .png))
                
            }
        }
        
        for emote in ffzPreProcessedEmotes{
            emoteArray.append(contentsOf:processCustomEmote(emoteID: emote.id, emoteName: emote.name, msg: msg, type: emoteType.ffz))
        }
        
        ///sort range array
        emoteArray = emoteArray.sorted { $0.upperNum < $1.lowerNum}
        
        ///if previousNum is 0 - no previous emotes, we need previousIndex to be -1 from this line: let previousIndex = msg.index(msg.startIndex, offsetBy: previousNum + 1)
        var previousNum = -1
        var upperNum = 0
        var counter = 0
        
        ///text color dependent on darkmode/lightmode
        var themeAttributes : [NSAttributedString.Key : Any] = [NSAttributedString.Key.strokeWidth : -1, NSAttributedString.Key.font : textFont]
        
        switch themeMode{
        case .light:
            themeAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
        case .dark:
            themeAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
        }
        
        ///appending the split up message into the msgarray which is then used to have the emotes being split up and then processed after downloaded asyncly
        
        ///different ifs:h
        if emoteArray.count > numBadges{
            for emote in emoteArray{
                
                ///if badge - separate processing
                if emote.type != .badge{
                    if emote.lowerNum > previousNum{
                        
                        ///if previousNum is 0 - no previous emotes, we need previousIndex to be -1
                        let previousIndex = msg.index(msg.startIndex, offsetBy: previousNum + 1)
                        
                        ///min to protect against where unicode nonsense like 👨‍❤️‍💋‍👨
                        let lowerIndex = msg.index(msg.startIndex, offsetBy:  min(emote.lowerNum, msg.count - 1))
                        let upperIndex = msg.index(msg.startIndex, offsetBy: min(emote.upperNum, msg.count - 1))
                        
                        
                        msgArray.msg.append(NSMutableAttributedString(string: String(msg[previousIndex..<lowerIndex]), attributes: themeAttributes))
                        msgArray.msg.append(NSMutableAttributedString(string: String(msg[lowerIndex...upperIndex]), attributes: themeAttributes))
                        
                        emoteArray[counter].numInList = msgArray.msg.count - 1
                    }
                    else{
                        let lowerIndex = msg.index(msg.startIndex, offsetBy: emote.lowerNum)
                        let upperIndex = msg.index(msg.startIndex, offsetBy: emote.upperNum)
                        msgArray.msg.append(NSMutableAttributedString(string: String(msg[lowerIndex...upperIndex]), attributes: themeAttributes))
                        
                        emoteArray[counter].numInList = msgArray.msg.count - 1
                        
                    }
                    previousNum = emote.upperNum
                    upperNum = emote.upperNum
                }
                counter += 1
                
            }
        
        
        /// minus 2 because of the newline character at the end
            if msg.count - 2 > upperNum{
                let previousIndex = msg.index(msg.startIndex, offsetBy: previousNum + 1)
                let upperIndex = msg.endIndex
                
                
                msgArray.msg.append(NSMutableAttributedString(string: String(msg[previousIndex...]), attributes: themeAttributes))
            }
        }
        else{
            msgArray.msg.append(NSMutableAttributedString(string: msg, attributes: themeAttributes))
            
        }
        
        msgArray.numEmotes = emoteArray.count
        
        print("Gets here!", msgArray.msg)
        
        msgArray.id = msgidNum
        msgidNum += 1
        displayText(msgArray: msgArray, emoteArray: emoteArray)
    }
    
//    func BSTextSetup(){
//        do {
//            Chat.frame = View.frame
//
//
//            view.addSubview(Chat)
//            print("Successful!")
//        } catch {
//            print("Error loading image : \(error)")
//        }
//    }
    
    /// Prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        
        if segue.identifier == "tutorialVC"{
            if let tutorialVC = destination as? TutorialVC{
                tutorialVC.delegate = self
                self.tutorialVC = tutorialVC
            }
        }
        else if segue.identifier == "toSettings"{
            if let settingsVC = destination as? SettingsViewController{
                settingsVC.previousVC = self
            }
            
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
            }
            currentPosition += 1
        }
        
        return result
        
    }
    
    ///get global ffz emotes
    func getGlobalFFZEmotes(){
        let url = URL(string: "https://api.frankerfacez.com/v1/set/global")!
        let request = AF.request(url)
        
        ///processing of JSON from FFZ API
        request.responseDecodable(of: GlobalFFZ.self) { (response) in
            guard let ffz = response.value else { return }
            
            let default_sets = ffz.default_sets

            for setNum in default_sets{

                if let setsList = ffz.sets[String(setNum)]{

                    ///get FFZ emotes
                    for emote in setsList.emotes{
                        ///list of emotes
                        ///self.emoteList.append(emote.name)
                        self.ffzEmotes.append(emote.name)
                        let emoteURLProcessed = "https:" + (emote.urls[self.ffzScale] ?? emote.urls["1"]!)

                        self.ffzPreProcessedEmotes.append(customEmote(name: emote.name, id: emoteURLProcessed, ending: .png))
                    }
                }
            }
        }
    }
    @IBAction func changeChannel(_ sender: Any) {
        
        if let text = changeChannelTextField.text{
            if text != ""{
                changeChannelTextField.resignFirstResponder()
                
                socket.write(string: "PART " + channelName)
                readingSocket.write(string: "PART " + channelName)
                
                deleteChat()
                
    //            channelNameLabel.text = text
                channelNameWithout = text
                
                reprocessEmotes()
                
                ///configure channelname
                channelName = "#" + channelNameWithout
                
                socket.write(string: "JOIN " + channelName)
                socket.write(string: "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership")
                
                
                readingSocket.write(string: "JOIN " + channelName)
                readingSocket.write(string: "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership")
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       hideChatInViewKeyboard()
    }
    
    func hideChatInViewKeyboard(){
        changeChannelTextField.resignFirstResponder()
        typeInChatView.resignFirstResponder()
    }
    
    func resizeFonts(){
        lineSpace = min(8, 0.01 * view.frame.size.height)
        italicsFont = UIFont.italicSystemFont(ofSize: min(20, 0.025 * view.frame.size.height))
        emoteFont = UIFont.systemFont(ofSize: min(20, 0.025 * view.frame.size.height))
        textFont = UIFont.systemFont(ofSize: min(20, 0.025 * view.frame.size.height))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        enableGIfSyncSlidler.isOn = false
//
//        channelNameLabel.text = channelNameWithout
//
////        chatMessageTextView.delegate = self
//        changeChannelTextField.delegate = self
        
        autoScrollButton.alpha = 0
        autoScrollButton.isHidden = true
        
        resizeFonts()
        
        keyboardConstraint =  mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        typeInChatOverView.layer.cornerRadius = 10
        
        typeInChatView.delegate = self
        
        typeInChatMasterView.translatesAutoresizingMaskIntoConstraints = false
        
        ///initialize settings
        initialSettings()
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.allowsSelection = false
        chatTableView.separatorStyle = .none
        
        chatTableView.rowHeight = 150
        
        print(UIScreen.main.scale, "SCALE")
        
        ///disable ability to edit text on Chat
        Chat.isEditable = false
        
        let scale = UIScreen.main.scale
        
        if scale == 1{
            ffzScale = "1"
            bttvScale = "1"
        }
        else if scale == 2{
            ffzScale = "2"
            bttvScale = "2"
        }
        else{
            ffzScale = "4"
            bttvScale = "3"
        }
        
        ///get global emotes
        let test = #":) :( :O :Z B) :\ ;) ;p :p R) O_o :D >( <3"#
        ///:) :( :o :z B) :\ ;) ;p :p R) o_O :D >( <3 <3 R) :> <] :7 :( :P ;P :O :\ :| :s :D o_O >( :) B) ;) #/"#
        
        emojisList = test.components(separatedBy: " ")
        emoteList.append(contentsOf: emojisList)
        
        changeChannelTextField.delegate = self
        
        //BSTextSetup()
        
        getGlobalFFZEmotes()
        getFFZEmotes(channel: channelNameWithout)
        
        getGlobalBTTVEmotes()
        
        //getUserID(channel: channelNameWithout)
        
        ///configure channelname
        channelName = "#" + channelNameWithout
        
        ///Login web view frame size
        loginWebView.frame = view.frame
        
        ///load webview
//        let url = URL(string: "http://localhost:8080/index.html")!
//        webView.load(URLRequest(url: url))
        
        let loginURL = URL(string: "https://id.twitch.tv/oauth2/authorize?response_type=token&client_id=om32h2qnvirwp87ueis6rdfkvvgqoh&redirect_uri=http://localhost:8080/getid.html&scope=chat:edit%20chat:read%20user_read&state=c5drem2kkzvj624eirqrh98cejc2i4svk7p6tj1j")!
        loginWebView.load(URLRequest(url: loginURL))
        
//        webView.scrollView.isScrollEnabled = false
        
        ///get keyboard height
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        chatTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chatTableViewTapped)))
        
        if let isFirstLaunch = UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool{
            if !isFirstLaunch {
                tutorialScreen()
            }
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    ///Initialize to stored settings
    func initialSettings(){
        print("initial settings! in chatviewcontrolelr")
        themeMode = (UserDefaults.standard.object(forKey: "isLightMode") as? Bool ?? (themeMode == .light)) ? .light: .dark
        
        switch themeMode {
        case .light:
            convertToLightMode()
            if let tutorialVC = tutorialVC{
                tutorialVC.convertToLightMode()
            }
        case .dark:
            convertToDarkMode()
            if let tutorialVC = tutorialVC{
                tutorialVC.convertToDarkMode()
            }
        }
        
        autoScrollLimit = UserDefaults.standard.object(forKey: "maxMessages") as? Int ?? autoScrollLimit
        nonAutoScrollLimit = UserDefaults.standard.object(forKey: "maxMessagesNoScroll") as? Int ?? nonAutoScrollLimit
        
        textFont = UIFont.systemFont(ofSize: UserDefaults.standard.object(forKey: "textFont") as? CGFloat ?? textFont.pointSize)
        emoteFont = UIFont.systemFont(ofSize: UserDefaults.standard.object(forKey: "emoteSize") as? CGFloat ?? emoteFont.pointSize)
        lineSpace = UserDefaults.standard.object(forKey: "lineSpacing") as? CGFloat ?? lineSpace
    }

    @objc func appMovedToBackground() {
        print("App moved to background!")
    }
    
    @objc func appMovedToForeground() {
        print("App moved to foreground!")
        deleteChat()
    }
    
    func tutorialScreen(){
        tutorialView.isHidden = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        print("Trait collection changed")
        
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            ///detection of light/dark mode
            if traitCollection.userInterfaceStyle == .light {
                themeMode = .light
                
                UserDefaults.standard.set(themeMode == .light, forKey: "isLightMode")
                
                if let tutorialVC = tutorialVC{
                    tutorialVC.convertToLightMode()
                }
                
                convertToLightMode()
            }
            else{
                themeMode = .dark
                
                UserDefaults.standard.set(themeMode == .light, forKey: "isLightMode")
                
                if let tutorialVC = tutorialVC{
                    tutorialVC.convertToDarkMode()
                }
                
                convertToDarkMode()
            }
        }
    }
    
    ///hide keyboard when chat view tapped
    var keyboardHeight : CGFloat = 0
    
    var keyboardOpen : Bool = false
    
    @objc func keyboardChanged(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboardshould change")
            keyboardHeight = keyboardSize.height
            if keyboardOpen{
//                typeInChatMasterViewNewBottomConstraint?.constant = -keyboardHeight
//                chatTableNewHeight?.constant = max(chatTableOldHeight - keyboardHeight, 0)
                print("KEYBOARD CHANGED ALRIGHT")
                keyboardConstraint.constant = -keyboardHeight
                self.view.layoutIfNeeded()
//
//                print("Should change keyboard size", keyboardSize)
//                view.layoutIfNeeded()
            }
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        keyboardCurve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboardshould show", keyboardDuration, keyboardCurve)
            if !keyboardOpen{
                print("KEYBOARD SHOWED ALRIGHT")
                keyboardHeight = keyboardSize.height
                
                keyboardConstraint.constant = -keyboardHeight
                
//                print(keyboardHeight, "keyboardHeight")
//
//                typeInChatMasterViewNewBottomConstraint = typeInChatMasterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardHeight)
//
//                chatTableNewHeight = chatTableView.heightAnchor.constraint(equalToConstant: max(chatTableOldHeight - keyboardHeight, 0))
            }
        }
    }
    
    @objc func chatTableViewTapped(){
        hideChatInViewKeyboard()
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
    
    
    @IBAction func gifSyncChanged(_ sender: Any) {
        gifSyncEnabled = !gifSyncEnabled
    }
    
    @IBAction func sendChatButtonPressed(_ sender: Any) {
        if let chatMessageToSendAttributedText = typeInChatView.attributedText{
            chatMessageToSend = chatMessageToSendAttributedText.string
            socket.write(string: "PRIVMSG \(channelName) :\(chatMessageToSend)")
            
            typeInChatView.attributedText = NSMutableAttributedString(string: "")
        }
    }
    
    @IBAction func unwindToSettings( _ seg: UIStoryboardSegue) {
    }
}


///typing in chat textview
extension ChatViewController: TextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: BSTextView) {
        keyboardOpen = true

//        guard let newBottom = typeInChatMasterViewNewBottomConstraint else {return}
//        guard let height = typeInChatMasterViewHeight else {return}
//        guard let newHeightChatView = chatTableNewHeight else { return }

//        NSLayoutConstraint.deactivate([
////            typeInChatMasterViewBottomConstraint,
////            typeInChatMasterViewTopConstraint,
////            chatTableViewHeight
//            noKeyboardConstraint
//        ])
//
//        NSLayoutConstraint.activate([
////            newBottom,
////            height,
////            newHeightChatView
//            keyboardConstraint
//        ])
        UIView.animate(
                withDuration: keyboardDuration,
                delay: 0.0,
                options: UIView.AnimationOptions(rawValue: keyboardCurve),
               animations: { [self] in
                   noKeyboardConstraint.isActive = false
                   keyboardConstraint.isActive = true
                   self.view.layoutIfNeeded()
               }
        )
        print("Should begin editing", keyboardHeight, typeInChatMasterView.frame)
    }
    func textViewDidEndEditing(_ textView: BSTextView) {
        keyboardOpen = false
//        guard let newBottom = typeInChatMasterViewNewBottomConstraint else {return}
//        guard let height = typeInChatMasterViewHeight else {return}
//        guard let newHeightChatView = chatTableNewHeight else { return }
        
////
//        NSLayoutConstraint.deactivate([
////            newBottom,
////            height,
////            newHeightChatView
//            keyboardConstraint
//        ])
//
//        NSLayoutConstraint.activate([
////            typeInChatMasterViewBottomConstraint,
////            typeInChatMasterViewTopConstraint,
////            chatTableViewHeight
//            noKeyboardConstraint
//        ])

        UIView.animate(
               withDuration: keyboardDuration,
               delay: 0.0,
               options: UIView.AnimationOptions(rawValue: keyboardCurve),
               animations: { [self] in
                   keyboardConstraint.isActive = false
                   noKeyboardConstraint.isActive = true
                   self.view.layoutIfNeeded()
               }
        )
        print("Should end editing", typeInChatMasterView.frame)
        
    }
    
    
}

extension ChatViewController: tutorialVC{
    func nextTapped() {
        tutorialView.isHidden = true
        
        let defaults = UserDefaults.standard
        
        if !defaults.bool(forKey: "isFirstLaunch") {
            defaults.set(false, forKey: "isFirstLaunch")
            
            defaults.set(autoScrollLimit, forKey: "maxMessages")
            defaults.set(nonAutoScrollLimit, forKey: "maxMessagesNoScroll")
            
            
            defaults.set(themeMode == .light, forKey: "isLightMode")
            
            defaults.set(textFont.pointSize, forKey: "textFont")
            defaults.set(emoteFont.pointSize, forKey: "emoteSize")
            defaults.set(lineSpace, forKey: "lineSpacing")
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentShownMessages.count
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let visiblePaths = chatTableView.indexPathsForVisibleRows else { return }
        
        ///if empty
        if currentShownMessages.count == 0{
            return
        }
        
        if visiblePaths.contains(IndexPath(row: currentShownMessages.count-1, section: 0)){
            autoScroll = true
            UIView.animate(withDuration: 0.25, animations: {
                self.autoScrollButton.alpha = 0
            }, completion: {_ in
                self.autoScrollButton.isHidden = true
            })
        }
        else{
            autoScroll = false
            if autoScrollButton.isHidden{
                self.autoScrollButton.isHidden = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.autoScrollButton.alpha = 1
                })
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        ///if empty
        if currentShownMessages.count == 0{
            return
        }
        
        if autoScroll == true{
            autoScroll = false
            self.autoScrollButton.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                self.autoScrollButton.alpha = 1
            })
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatMessage = tableView.dequeueReusableCell(withIdentifier: "ChatMessage") as! ChatMessage
        
        ///variable for cell width, used later
        if cellWidth == 0{
            cellWidth = cell.frame.size.width
        }
        
        cell.chatmsg.backgroundColor = .clear
        
        switch themeMode{
        case .dark:
            cell.chatmsg.textColor = .white
            cell.contentView.backgroundColor = blackBackgroundColor
        case .light:
            cell.chatmsg.textColor = .black
            cell.contentView.backgroundColor = whiteBackgroundColor
        }
        
        cell.chatmsg.attributedText = NSAttributedString(string: "")
        
        let currentmsg = currentShownMessages[indexPath.row]
        
        cell.chatmsg.attributedText = currentmsg.msg
        
//        for subview in cell.chatmsg.subviews{
//            if type(of: subview) == type(of: YYAnimatedImageView()){
//                subview.removeFromSuperview()
//            }
//        }
        
        if let attributedText =  cell.chatmsg.attributedText{
//            attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: [], using: {
//                (value,range,stop) in
//                for (k, v) in value{
//                    print(k, v)
//                    if k == NSAttributedString.Key.init("TextAttachment"){
//                        if let bsattachments = v as? BSText.TextAttachment{
//                            if let image = bsattachments.content as? YYAnimatedImageView{
//                            }
//                        }
//                    }
//                }
//            })
            if gifSyncEnabled{
                syncGifs(attributedText: attributedText)
            }
        }
//
        if let cellHeight = heightDict[currentmsg.globalId]{
            cell.chatmsg.frame = CGRect(x: chatMsgSpacing, y: chatVerticalSpacing, width: cell.frame.size.width - chatMsgSpacing * 2, height: cellHeight)
        }
        else{
            setHeight(cell: cell, indexPath: indexPath, id: currentmsg.globalId)
        }
        
//        makeGifs(cellPath: indexPath, cell: cell)
        
        ///display async for faster performance
        cell.chatmsg.displaysAsynchronously = true
        
        ///word wrapping settings
        cell.chatmsg.lineBreakMode = .byWordWrapping
        cell.chatmsg.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let idLocation = currentShownMessages[indexPath.row].globalId
        guard let height = heightDict[idLocation] else {return 30}
        return height + chatVerticalSpacing * 2
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cell: ChatMessage = cell as! ChatMessage
//
//        cell.chatmsg.attributedText = currentShownMessages[indexPath.row]
//    }
    
    /**
        Making cells able to be copy and pasted.
     */
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            let copyAction =
                UIAction(title: NSLocalizedString("Copy", comment: ""),
                         image: UIImage(systemName: "doc.on.clipboard.fill")) { action in
                    
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = self.msgGlobalArray[indexPath.row].rawTextMsg
                }
            return UIMenu(title: "", children: [copyAction])
        })
    }
}

extension ChatViewController: WebSocketDelegate{
}

extension ChatViewController: UITextFieldDelegate{
    func deleteChat(){
        msgGlobalArray = []
        currentShownMessages = []
        chatTableView.reloadData()
        print("chat deleted")
    }
    
    func reprocessEmotes(){
        ffzEmotes = []
        bttvEmotes = []
        bttvPreProcessedEmotes = []
        ffzPreProcessedEmotes = []
        getFFZEmotes(channel: channelNameWithout)
        getUserID(channel: channelNameWithout, accesstoken: accesstoken)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        print("Text Field Should Return")
        textField.resignFirstResponder()
        
        if let text = textField.text{
            
            socket.write(string: "PART " + channelName)
            readingSocket.write(string: "PART " + channelName)
            
            deleteChat()
            
//            channelNameLabel.text = text
            channelNameWithout = text
            
            reprocessEmotes()
            
            ///configure channelname
            channelName = "#" + channelNameWithout
            
            socket.write(string: "JOIN " + channelName)
            socket.write(string: "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership")
            
            
            readingSocket.write(string: "JOIN " + channelName)
            readingSocket.write(string: "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership")
        }
        
        return true
    }
    
}
