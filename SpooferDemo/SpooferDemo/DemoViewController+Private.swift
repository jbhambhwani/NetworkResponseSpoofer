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
    case StartRecording = "Start Recording"
    case StopRecording = "Stop Recording"
    case StartReplaying = "Start Replaying"
    case StopReplaying = "Stop Replaying"
}

// MARK: - Webview Delegate

extension DemoViewController: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}

// MARK: - SearchBarDelegate

extension DemoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        guard var searchText = searchBar.text where searchText.characters.count > 0 else { return }
        if searchText.hasPrefix("http") == false {
            searchText = "http://" + searchText
        }
        guard let url = NSURL(string: searchText) else { return }
        
        let urlRequest = NSURLRequest(URL: url)
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
    
    private func sendRequest(resource: String) {
        guard let url = NSURL(string: resource) else { return }
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { data, response, error in
            // Spoofer has already intercepted the response if error was non nil. Nothing to do here.
        }).resume()
    }

}