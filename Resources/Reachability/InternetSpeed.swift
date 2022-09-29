//
//  InternetSpeed.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 17/06/22.
//

import Foundation
import UIKit

/**
 Check the internet speed test using image url 
 */
class InternetSpeed: NSObject,URLSessionDataDelegate, URLSessionDelegate {
    
    
    var startTime = CFAbsoluteTime()
    var stopTime = CFAbsoluteTime()
    var bytesReceived: CGFloat = 0
    var testURL:String?
    var speedTestCompletionHandler: ((_ megabytesPerSecond: Double, _ error: Error?) -> Void)? = nil
    var timerForSpeedTest:Timer?
    
    func testDownloadSpeed(withTimout timeout: TimeInterval, completionHandler: @escaping (_ megabytesPerSecond: Double, _ error: Error?) -> Void) {
        
        // you set any relevant string with any file
        let urlForSpeedTest = URL(string: "https://images.apple.com/v/imac-with-retina/a/images/overview/5k_image.jpg")
        
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
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        bytesReceived += CGFloat(data.count)
        stopTime = CFAbsoluteTimeGetCurrent()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let elapsed = (stopTime - startTime)/1000 //as? CFAbsoluteTime
        print("Stop_time - start_time:\(elapsed)")
        let speed = bytesReceived / (1024 * 1024 * CGFloat(elapsed))
        print("bytesreceived:\(bytesReceived)")
        print("speed after calculation with elapsed:\(speed)")
        //print(bytesReceived)
        let final_speed = Double(speed/125).rounded()
        print("final_speed:\(final_speed)")
        var my_speed = (final_speed * 3) / 4
        print("my_speed:\(my_speed)")
        // treat timeout as no error (as we're testing speed, not worried about whether we got entire resource or not
        if my_speed.isNaN == true{
            my_speed = Double(0.1)
            if error == nil || ((((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == NSURLErrorTimedOut) {
                print("No error")
                speedTestCompletionHandler?(Double(CGFloat(my_speed)), nil)
            }
            else {
                print("error")
                speedTestCompletionHandler?(0.0, error)
            }
        }
        else{
            if error == nil || ((((error as NSError?)?.domain) == NSURLErrorDomain) && (error as NSError?)?.code == NSURLErrorTimedOut) {
                print("No error")
                speedTestCompletionHandler?(Double(CGFloat(my_speed)), nil)
            }
            else {
                print("error")
                speedTestCompletionHandler?(0.0, error)
            }
        }
    }
    
}
