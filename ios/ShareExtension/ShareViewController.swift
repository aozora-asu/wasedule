import UIKit
import Social
import MobileCoreServices
import Foundation

class ShareViewController: UIViewController {
    
    let appGroupID = "group.com.example.wasedule"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Extract the URL from the shared content
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
           let itemProvider = item.attachments?.first,
           itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            
            itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (urlItem, error) in
                if let url = urlItem as? URL {
                    // Fetch HTML from the URL
                    self.fetchHTML(from: url) { html in
                        // Save HTML to UserDefaults and launch app
                        self.saveHTMLToAppGroupAndLaunchApp(html: html)
                    }
                } else {
                    // Fallback if no URL is shared or failed to load
                    self.saveHTMLToAppGroupAndLaunchApp(html: nil)
                }
            }
        } else {
            // Fallback if no URL is shared
            self.saveHTMLToAppGroupAndLaunchApp(html: nil)
        }
    }
    
    func fetchHTML(from url: URL, completion: @escaping (String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let html = String(data: data, encoding: .utf8)
            completion(html)
        }
        task.resume()
    }
    
    func saveHTMLToAppGroupAndLaunchApp(html: String?) {
        // Save HTML to App Group
        if let userDefaults = UserDefaults(suiteName: appGroupID) {
            userDefaults.set(html, forKey: "sharedHTMLContent")
            userDefaults.synchronize()
        }
        
        // Create JSON object
        let jsonObject: [String: Any?] = [
            "type": "shared_content",
            "data": [
                "html": html,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        ]
        
        // Convert JSON object to data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) else {
            print("Failed to serialize JSON")
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
            print("Failed to create URL")
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
