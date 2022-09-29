//
//  LiveData.swift
//  NTrust
//
//  Created by Waseem Akram on 03/12/20.
//

import Foundation
/// Set the live data value with calling the observe value and observe the error
final class LiveData<V: Any, E: Error> {
    
    var error: E? {
        didSet {
            if let error = error {
                observeError?(error)
            }
        }
    }
    
    var value: V?  {
        didSet {
            if let value = value {
                observeValue?(value)
            }
        }
    }
    
    init(value: V?){
        self.value = value
    }
    
    init(){
        self.value = nil
    }
    
    var observeValue: ((V)->Void)?
    var observeError: ((E)->Void)?
    
}
