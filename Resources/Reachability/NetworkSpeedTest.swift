//
//  NetworkSpeedTest.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 10/03/22.
//

import Foundation
import UIKit

protocol NetworkSpeedProviderDelegate: AnyObject {
    func callWhileSpeedChange(networkStatus: NetworkStatus)
   }
public enum NetworkStatus :String
{case poor; case good; case disConnected}

/**
 This class network speed test is used to get the spedd of the internet using the url of image downloading
 */
class NetworkSpeedTest: UIViewController {
    
    weak var delegate: NetworkSpeedProviderDelegate?
    var startTime = CFAbsoluteTime()
    var stopTime = CFAbsoluteTime()
    var bytesReceived: CGFloat = 0
    var testURL:String?
    var speedTestCompletionHandler: ((_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void)? = nil
    var timerForSpeedTest:Timer?
    
    func networkSpeedTestStart(UrlForTestSpeed:String!){
        testURL = UrlForTestSpeed
        timerForSpeedTest = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(testForSpeed), userInfo: nil, repeats: true)
    }
    func networkSpeedTestStop(){
        timerForSpeedTest?.invalidate()
    }
    @objc func testForSpeed()
    {
        testDownloadSpeed(withTimout: 0.0, completionHandler: {(_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void in
           /// print("%0.1f; KbPerSec = \(megabytesPerSecond)")
            if (error as NSError?)?.code == -1009
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .disConnected)
            }
            else if megabytesPerSecond == -1.0
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .poor)
            }
            else
            {
                self.delegate?.callWhileSpeedChange(networkStatus: .good)
            }
        })
    }
}
extension NetworkSpeedTest: URLSessionDataDelegate, URLSessionDelegate {
    
    /// Asks delegate to test of internet with time interval
    /// - Parameters:
    ///   - timeout: Check the timeout option of start time and stop time
    ///   - completionHandler: Check the completion of test with megabytes
func testDownloadSpeed(withTimout timeout: TimeInterval, completionHandler: @escaping (_ megabytesPerSecond: CGFloat, _ error: Error?) -> Void) {

    // you set any relevant string with any file
    let urlForSpeedTest = URL(string: testURL!)

    startTime = CFAbsoluteTimeGetCurrent()
    stopTime = startTime
    bytesReceived = 0
    speedTestCompletionHandler = completionHandler
    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForResource = timeout
    let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

    guard let checkedUrl = urlForSpeedTest else { return }

    session.dataTask(with: checkedUrl).resume()
}
    
    /// Asks the data task session to check the method of did receive
    /// - Parameters:
    ///   - session: Check the url session with bytes received count
    ///   - dataTask: Check the data task with the url session made
    ///   - data: received the data as url task
func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    bytesReceived += CGFloat(data.count)
    stopTime = CFAbsoluteTimeGetCurrent()
}

    /// Check this with speed and error speed test
func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    let elapsed = (stopTime - startTime) //as? CFAbsoluteTime
    let speed: CGFloat = elapsed != 0 ? bytesReceived / (CGFloat(CFAbsoluteTimeGetCurrent() - startTime)) / 1024.0 : -1.0
    // treat timeout as no error (as we're testing speed, not worried about whether we got entire resource or not
    if error == nil || ((((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == NSURLErrorTimedOut) {
        speedTestCompletionHandler?(speed, nil)
    }
    else {
        speedTestCompletionHandler?(speed, error)
    }
  }
}
