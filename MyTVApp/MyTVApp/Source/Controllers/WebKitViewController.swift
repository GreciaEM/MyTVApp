//
//  WebKitViewController.swift
//  MyTVApp
//
//  Created by Grecia Escárcega on 13/09/20.
//  Copyright © 2020 GEM. All rights reserved.
//

import UIKit
import WebKit

class WebKitViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    var timer: Timer!
    var complete: Bool! = false
    var url: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        webView.delegate = self
        loadURL()
    }
    
    @IBAction func closeButtopTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadURL() {
        let fullUrl = "https://www.imdb.com/title/" + url
        self.titleLabel.text = fullUrl
        guard let url = URL(string: fullUrl) else { return }
        let request = URLRequest(url: url)
        progressView.progress = 0
        webView.loadRequest(request)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector: #selector(self.timerCallback), userInfo: nil, repeats: true)
        }
    }
        
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if !webView.isLoading {
            complete = true
        }
    }
    
    @objc func timerCallback() {
        if complete {
            if progressView.progress >= 1 {
                progressView.isHidden = true
                timer.invalidate()
            } else {
                progressView.progress += 0.1
            }
        } else {
            progressView.progress += 0.05
            if progressView.progress >= 0.95 {
                progressView.progress = 0.95
            }
        }
    }
}
