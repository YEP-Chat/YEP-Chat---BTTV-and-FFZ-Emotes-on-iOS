//
//  JSSingleton.swift
//  YEP Chat
//
//  Created by Darren Key on 5/21/21.
//

import UIKit
import JavaScriptCore

class JSSingleton: NSObject {
        /// Singleton instance. Much more resource-friendly than creating multiple new instances.
        static let shared = JSSingleton()
    
        private let vm = JSVirtualMachine()
        private let context: JSContext
    
        
        private override init() {
            let jsCode = try? String.init(contentsOf: Bundle.main.url(forResource: "YEP.bundle", withExtension: "js")!)
            print("initialized")
            // The Swift closure needs @convention(block) because JSContext's setObject:forKeyedSubscript: method
            // expects an Objective-C compatible block in this instance.
            // For more information check out https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Attributes.html#//apple_ref/doc/uid/TP40014097-CH35-ID350
            let nativeLog: @convention(block) (String) -> Void = { message in
                NSLog("JS Log: \(message)")
            }
            
            let testLog: @convention(block) (String) -> Void = { message in
                NSLog("Test Log: \(message)")
            }
            // Create a new JavaScript context that will contain the state of our evaluated JS code.
            self.context = JSContext(virtualMachine: self.vm)
            
            // Register our native logging function in the JS context
            self.context.setObject(nativeLog, forKeyedSubscript: "nativeLog" as NSString)
            // Register our native logging function in the JS context
            self.context.setObject(testLog, forKeyedSubscript: "testLog" as NSString)
            
            // Evaluate the JS code that defines the functions to be used later on.
            self.context.evaluateScript(jsCode)
            
            
            let randomCode = """
            if (typeof testLog === 'function') {
                testLog('hey')
            }
            """
            self.context.evaluateScript(randomCode)
            
            print("done")
        }
        
    /*
        /**
             Analyze the sentiment of a given English sentence.
     
             - Parameters:
                 - sentence: The sentence to analyze
                 - completion: The block to be called on the main thread upon completion
                 - score: The sentiment score
         */
        func analyze(_ sentence: String, completion: @escaping (_ score: Int) -> Void) {
            // Run this asynchronously in the background
            DispatchQueue.global(qos: .userInitiated).async {
                var score = 0
                
                // In the JSContext global values can be accessed through `objectForKeyedSubscript`.
                // In Objective-C you can actually write `context[@"analyze"]` but unfortunately that's
                // not possible in Swift yet.
                if let result = self.context.objectForKeyedSubscript("analyze").call(withArguments: [sentence]) {
                    score = Int(result.toInt32())
                }
                
                // Call the completion block on the main thread
                DispatchQueue.main.async {
                    completion(score)
                }
            }
        }*/
}
