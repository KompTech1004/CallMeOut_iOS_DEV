//
//  PlayerCache.swift
//  Call Me Out
//
//  Created by B S on 6/13/18.
//  Copyright © 2018 B S. All rights reserved.
//

import Foundation
import AVKit
import Cache

class PlayerCache {
    private var player: AVPlayer!
    
    let diskConfig = DiskConfig(name: "DiskCache",maxSize:1024*1024*100)
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    lazy var storage: Cache.Storage? = {
        return try? Cache.Storage(syncStorage: diskConfig, asyncStorage: memoryConfig)
    }()
    
    // MARK: - Logic
    
    /// Plays a track either from the network if it's not cached or from the cache.
    func play(with url: URL,playerVC:AVPlayerViewController) {
        // Trying to retrieve a track from cache asynchronously.
        storage?.async.entry(ofType: Data.self, forKey: url.absoluteString, completion: { result in
            let playerItem: CachingPlayerItem
            switch result {
            case .error:
                // The track is not cached.
                playerItem = CachingPlayerItem(url: url)
                playerItem.download()
            case .value(let entry):
                // The track is cached.
                playerItem = CachingPlayerItem(data: entry.object, mimeType: "video/mov", fileExtension: "mp4")
            }
            playerItem.delegate = self
            self.player = AVPlayer(playerItem: playerItem)
            playerVC.player = self.player
            self.player.automaticallyWaitsToMinimizeStalling = false
            self.player.play()
        })
    }
    
}

// MARK: - CachingPlayerItemDelegate
extension PlayerCache: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // A track is downloaded. Saving it to the cache asynchronously.
        storage?.async.setObject(data, forKey: playerItem.getUrl().absoluteString, completion: { _ in })
    }
}
