//
//  webserver.swift
//  YEP Chat
//
//  Created by Darren Key on 5/22/21.
//

import Foundation
import GCDWebServer

func initWebServer() {

    let webServer = GCDWebServer()

    webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse(html:"<html><body><p>Hello World</p></body></html>")
            
        })
        
    webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
    
    print("Visit \(webServer.serverURL) in your web browser")
}
