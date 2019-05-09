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
    func webViewDidStartLoad(_: UIWebView) {
        activityIndicatorView.startAnimating()
    }

    func webViewDidFinishLoad(_: UIWebView) {
        activityIndicatorView.stopAnimating()
    }

    func webView(_: UIWebView, didFailLoadWithError _: Error) {
        activityIndicatorView.stopAnimating()
    }

    func webView(_: UIWebView, shouldStartLoadWith request: URLRequest, navigationType _: UIWebView.NavigationType) -> Bool {
        if let url = request.url?.absoluteString, !url.isEmpty {
            searchBar.text = url
        }
        return true
    }
}

// MARK: - SearchBarDelegate

extension DemoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard var searchText = searchBar.text, !searchText.isEmpty else { return }
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
    private func sendRequest(_ resource: String) {
        guard let url = URL(string: resource) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { _, _, _ in
            // Spoofer has already intercepted the response if error was non nil. Nothing to do here.
        }).resume()
    }
}
