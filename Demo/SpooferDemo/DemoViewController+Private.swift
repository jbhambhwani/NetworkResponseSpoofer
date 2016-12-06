//
//  DemoViewController+Private.swift
//  SpooferDemo
//
//  Created by Deepu Mukundan on 7/13/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import WebKit

enum ButtonTitle: String {
    case startRecording = "Start Recording"
    case stopRecording = "Stop Recording"
    case startReplaying = "Start Replaying"
    case stopReplaying = "Stop Replaying"
}

// MARK: - Webview Delegate

extension DemoViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
    }
    
}

// MARK: - SearchBarDelegate

extension DemoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard var searchText = searchBar.text, searchText.characters.count > 0 else { return }
        if searchText.hasPrefix("http") == false {
            searchText = "http://" + searchText
        }
        guard let url = URL(string: searchText) else { return }
        
        let urlRequest = URLRequest(url: url)
        webview.loadRequest(urlRequest)
        searchBar.resignFirstResponder()
    }

}

// MARK: - Internal methods

extension DemoViewController {
    
    func performSampleNetworkRequests() {
        // Get data from a few sample end points
        sendRequest("http://jsonplaceholder.typicode.com/users")
        sendRequest("http://jsonplaceholder.typicode.com/posts")
    }
    
    fileprivate func sendRequest(_ resource: String) {
        guard let url = URL(string: resource) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            // Spoofer has already intercepted the response if error was non nil. Nothing to do here.
        }).resume()
    }

}
