//
//  WebServerManager.swift
//
//  Created by soQ on 2023/8/22.
//

import Foundation
import GCDWebServers

class WebServerManager : NSObject {
    static var manager : WebServerManager = WebServerManager()
    
    private var webServer: GCDWebUploader?
    private var webDavServer : GCDWebDAVServer!
    
    func startServer() {
        if let server = webServer {
            server.start()
        }else{
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let s = GCDWebUploader(uploadDirectory: documentsPath)
            s.delegate = self
            s.allowHiddenItems = true
            s.enableDirectoryDownload = true
            webServer = s
            s.start()
        }
    }
    
    func stopServer() {
        if let server = webServer {
            server.stop()
        }
    }
    
    func isRunning() -> Bool {
        if let server = webServer {
            return server.isRunning
        }
        return false
    }
    
    func runningAddress() -> String? {
        if let server = webServer {
            return server.serverURL?.absoluteString
        }
        return nil
    }
}

extension WebServerManager : GCDWebUploaderDelegate {
    func webServerDidStart(_ server: GCDWebServer) {
        
    }
    
    func webServerDidStop(_ server: GCDWebServer) {
        
    }
    
    func zipDir(path : String) -> String {
        
        let fileManager = FileManager()
        let currentWorkingPath = fileManager.temporaryDirectory.versionCompactPercentEncodePath()
        
        print("Zip Dir \(path) in working path : \(currentWorkingPath)")
        
        var sourceURL = URL(fileURLWithPath: path)
        var destinationURL = URL(fileURLWithPath: currentWorkingPath)
        destinationURL.appendPathComponent("pack.zip")
        if fileManager.fileExists(atPath: destinationURL.versionCompactPercentEncodePath()) {
            try? fileManager.removeItem(at: destinationURL)
        }
        do {
            try fileManager.zipItem(at: sourceURL, to: destinationURL)
            
            return destinationURL.versionCompactPercentEncodePath()
        } catch {
            print("Creation of ZIP archive failed with error:\(error)")
        }
        return ""
    }
    
    
    func webUploader(_ uploader: GCDWebUploader, dealWithDirectoryDownload path: String) -> String {
        return zipDir(path: path)
    }
    func webUploader(_: GCDWebUploader, didUploadFileAtPath path: String) {
        print("[UPLOAD] \(path)")
    }
    
    func webUploader(_: GCDWebUploader, didDownloadFileAtPath path: String) {
        print("[DOWNLOAD] \(path)")
    }
    
    func webUploader(_: GCDWebUploader, didMoveItemFromPath fromPath: String, toPath: String) {
        print("[MOVE] \(fromPath) -> \(toPath)")
    }
    
    func webUploader(_: GCDWebUploader, didCreateDirectoryAtPath path: String) {
        print("[CREATE] \(path)")
    }
    
    func webUploader(_: GCDWebUploader, didDeleteItemAtPath path: String) {
        print("[DELETE] \(path)")
    }
}


extension URL {
    func versionCompactPercentEncodePath() -> String {
        if #available(iOS 16.0, *) {
            return self.path()
        } else {
            // Fallback on earlier versions
            return self.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self.absoluteString
        }
    }
}
