/*
 Copyright (c) 2012-2019, Pierre-Olivier Latour
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * The name of Pierre-Olivier Latour may not be used to endorse
 or promote products derived from this software without specific
 prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import GCDWebServers
import UIKit



class ViewController: UIViewController {
  @IBOutlet var label: UILabel?
  var toggleButton : UIButton = {
    let b = UIButton()
    b.setTitle("Open Server", for: .normal)
    b.setTitle("Stop Server", for: .selected)
    b.setTitleColor(.blue, for: .normal)
    return b
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(toggleButton)
    self.toggleButton.sizeToFit()
    self.toggleButton.bounds = self.toggleButton.bounds.insetBy(dx: -10, dy: -6)
    toggleButton.addTarget(self, action: #selector(toggleServer), for: .touchUpInside)
    
    self.label?.text = "Click Button below to Start."
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if let label = label {
      self.toggleButton.center = CGPoint.init(x: label.center.x, y: label.center.y + 30)
    }else {
      self.toggleButton.center = self.view.center
    }
  }
  
  @objc func toggleServer() {
      let serverManager = WebServerManager.manager
      if serverManager.isRunning() {
          serverManager.stopServer()
      }else{
          serverManager.startServer()
      }
    if #available(iOS 13.0, *) {
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .seconds(1)), execute: DispatchWorkItem(block: { [weak self] in
        self?.updateServerBtnState()
      }))
    } else {
      // Fallback on earlier versions
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: DispatchWorkItem(block: { [weak self] in
        self?.updateServerBtnState()
      }))
    }
  }

  func updateServerBtnState() {
      let serverManager = WebServerManager.manager
      if serverManager.isRunning() {
          self.toggleButton.isSelected = true
          if let addr = serverManager.runningAddress() {
              self.label?.text = "Now you can access \(addr) to operate files."
          }
      }else {
          self.toggleButton.isSelected = false
      }
  }
}


class ViewController_Origin: UIViewController {
  @IBOutlet var label: UILabel?
  var webServer: GCDWebUploader!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    webServer = GCDWebUploader(uploadDirectory: documentsPath)
    webServer.delegate = self
    webServer.allowHiddenItems = true
    webServer.enableDirectoryDownload = true
    if webServer.start() {
      label?.text = "GCDWebServer running locally on port \(webServer.port)"
    } else {
      label?.text = "GCDWebServer not running!"
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    webServer.stop()
    webServer = nil
  }
}

extension ViewController_Origin: GCDWebUploaderDelegate {
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
