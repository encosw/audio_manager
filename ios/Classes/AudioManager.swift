//
//  AudioManager.swift
//
//  Created by Jerome Xiong on 2020/1/13.
//  Copyright © 2020 JeromeXiong. All rights reserved.
//

import UIKit
import MediaPlayer

open class AudioManager: NSObject {

    var player: AVPlayer?

    open var hasNext: Bool = false
    open var hasPrev: Bool = false
    open var buffering: Bool = false

    open var playing: Bool = false

    open var onEvents: ((String)->Void)?

    public static let `default`: AudioManager = {
        return AudioManager()
    }()

    func setupRemoteCommandHandler(enabled: Bool) {
        let command = MPRemoteCommandCenter.shared()

        if enabled {
            command.pauseCommand.addTarget{ (event) -> MPRemoteCommandHandlerStatus in
                //self.stopPlayer();
                self.playing = false
                self.onEvents?("pause")
                return .success
            }
            command.playCommand.addTarget{ (event) -> MPRemoteCommandHandlerStatus in
                //self.player?.play();
                self.playing = true
                self.onEvents?("play")
                return .success
            }
            command.togglePlayPauseCommand.addTarget{ (event) -> MPRemoteCommandHandlerStatus in
                if self.player?.rate != 0 && self.player?.error == nil {
                    //self.stopPlayer()
                    self.onEvents?("pause")
	            } else {
                    //self.player?.play()
                    self.onEvents?("play")
	            }
                return .success
            }
            command.nextTrackCommand.addTarget{ (event) -> MPRemoteCommandHandlerStatus in
                //self.stopPlayer()
                self.onEvents?("next")
                return .success
            }
            command.previousTrackCommand.addTarget{ (event) -> MPRemoteCommandHandlerStatus in
                //self.stopPlayer()
                self.onEvents?("prev")
                return .success
            }
            if self.buffering {
                command.playCommand.isEnabled = false
                command.pauseCommand.isEnabled = false
                command.togglePlayPauseCommand.isEnabled = false
                command.nextTrackCommand.isEnabled = false
                command.previousTrackCommand.isEnabled = false
            } else {
                command.playCommand.isEnabled = true
                command.pauseCommand.isEnabled = true
                command.togglePlayPauseCommand.isEnabled = true
                command.nextTrackCommand.isEnabled = hasNext
                command.previousTrackCommand.isEnabled = hasPrev
            }
        } else {
            command.pauseCommand.removeTarget(self)
            command.playCommand.removeTarget(self)
            command.togglePlayPauseCommand.removeTarget(self)
            if hasNext {
                command.nextTrackCommand.removeTarget(self)
            }
            if hasPrev {
                command.previousTrackCommand.removeTarget(self)
            }
        }
    }

    func setRemoteInfo(title: String, artist: String, duration: Int, currentPosition: Int) {
        let center = MPNowPlayingInfoCenter.default()
        var infos = [String: Any]()
        
        infos[MPMediaItemPropertyTitle] = title
        infos[MPMediaItemPropertyArtist] = artist
        if duration > 0 {
            infos[MPMediaItemPropertyPlaybackDuration] = Double(duration / 1000)
            infos[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(currentPosition / 1000)
        }
        
        /*infos[MPNowPlayingInfoPropertyPlaybackRate] = queue.rate
        queue.rate = rate*/
        
        /*let image = cover?.image ?? UIImage()
        if #available(iOS 11.0, *) {
            infos[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
        } else {
            let cover = image.withText(self.desc ?? "")!
            if #available(iOS 10.0, *) {
                infos[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200,height: 200), requestHandler: { (size) -> UIImage in
                    return cover
                })
                
            } else {
                infos[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
            }
        }*/
        
        center.nowPlayingInfo = infos
    }

    deinit {
        setupRemoteCommandHandler(enabled: false)
    }

    func setupPlayer(url: String? = nil) {
        let streamUrl = URL(string: url!)
        self.player = AVPlayer(url: streamUrl!)
        self.playing = true
        self.player?.play()
    }

    func pause() {
        self.player?.pause()
        self.playing = false
    }

    func resume() {
        self.player?.play()
        self.playing = true
    }

    func stopPlayer() {
        if let play = player {
            play.pause()
            self.playing = false
            self.player = nil
        } else {
            print("player was already deallocated")
        }
        setupRemoteCommandHandler(enabled: false)
    }
}

