import UIKit
import Social
import MobileCoreServices
import Foundation
import os.log

class ShareViewController: UIViewController {
    
    let appGroupID = "group.com.example.wasedule"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
           let attachments = item.attachments {
            
            for (_, attachment) in attachments.enumerated() {
                
                if attachment.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                  
                    
                    attachment.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil) { (data, error) in
                        if error != nil {
                
                            self.saveHTMLToAppGroupAndLaunchApp(html: nil)
                            return
                        }
                        
                       
                        if let dict = data as? NSDictionary {
                           
                            
                            if let results = dict[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary {
                    
                                
                                if let html = results["html"] as? String {
                                    
                                    self.saveHTMLToAppGroupAndLaunchApp(html: html)
                                } else {
                                   
                                    self.saveHTMLToAppGroupAndLaunchApp(html: nil)
                                }
                            } else {
                               
                                self.saveHTMLToAppGroupAndLaunchApp(html: nil)
                            }
                        } else {
                           
                            self.saveHTMLToAppGroupAndLaunchApp(html: nil)
                        }
                    }
                    return
                }
            }
        }
        
        self.saveHTMLToAppGroupAndLaunchApp(html: nil)
    }
    
    func saveHTMLToAppGroupAndLaunchApp(html: String?) {

        
        // Save HTML to App Group
        if let userDefaults = UserDefaults(suiteName: appGroupID) {
            userDefaults.set(html, forKey: "sharedHTMLContent")
            userDefaults.synchronize()
        }
        // Create JSON object
        let jsonObject: [String: Any] = [
            "type": "shared_content",
            "data": [
                "html": html ,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        // Convert JSON object to data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) else {
            launchAppWithoutData()
            return
        }
        // Convert JSON data to base64 string
        let base64String = jsonData.base64EncodedString()
        // Create app URL with base64 encoded JSON
        let appURL = "com.example.wasedule://shared?data=\(base64String)"
        
        if let url = URL(string: appURL) {
    
            openUrl(url: url)
        } else {
         
            launchAppWithoutData()
        }
        
        // Close the share extension after launching the app
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func launchAppWithoutData() {
        if let url = URL(string: "com.example.wasedule://shared") {
            openUrl(url: url)
        }
    }

    func openUrl(url: URL?) {
        let selector = #selector(openURL(_:))
        var responder = (self as UIResponder).next
        while let r = responder, !r.responds(to: selector) {
            responder = r.next
        }
        _ = responder?.perform(selector, with: url)
    }

    @objc func openURL(_ url: URL) {
        DispatchQueue.main.async {
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
}



