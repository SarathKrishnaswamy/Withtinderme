//
//  NewsCardViewModel.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 02/08/22.
//

import Foundation

class NewsCardViewModel {
    
    var ListData:HomeFeeds?
    var feedList:[HomeFeeds]?
    
    init(withModel:HomeFeeds?,withHomeModel:[HomeFeeds]?)
      {
          ListData = withModel
          feedList = withHomeModel ?? [HomeFeeds]()
      }

    
    public var monetize: Int {
        return self.ListData?.monetize ?? 0
    }
    
}
