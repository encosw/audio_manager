import Flutter
import UIKit
import MediaPlayer

public class SwiftAudioManagerPlugin: NSObject, FlutterPlugin {
    var audioManager = AudioManager()

    var player: AVPlayer?
    open var hasNext: Bool = false
    open var hasPrev: Bool = false
    open var onEvents: ((String)->Void)?

    fileprivate var registrar: FlutterPluginRegistrar!
    fileprivate static let instance: SwiftAudioManagerPlugin = {
        return SwiftAudioManagerPlugin()
    }()
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_manager", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        
        AudioManager.default.onEvents = { event in
            switch event {
            case "play":
                channel.invokeMethod("play", arguments: nil)
            case "pause":
                channel.invokeMethod("pause", arguments: nil)
            case "next":
                channel.invokeMethod("next", arguments: nil)
            case "prev":
                channel.invokeMethod("prev", arguments: nil)
            default:
                break
            }
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? Dictionary<String,Any> ?? [:]
        //let url = arguments["url"] as? String
        switch call.method {
            case "show":
                AudioManager.default.hasNext = arguments["hasNext"] as? Bool ?? false
                AudioManager.default.hasPrev = arguments["hasPrev"] as? Bool ?? false
                AudioManager.default.setupRemoteCommandHandler(enabled: true)
            case "hide":
                AudioManager.default.setupRemoteCommandHandler(enabled: false)
            case "updateInfo":
                let title = arguments["title"] as? String ?? ""
                let artist = arguments["artist"] as? String ?? ""
                let duration = arguments["duration"] as? Int ?? 0
                let currentPosition = arguments["currentPosition"] as? Int ?? 0
                AudioManager.default.setRemoteInfo(title: title, artist: artist, duration: duration, currentPosition: currentPosition)
            default:
                break
        }
    }
    
    func getLocal(_ registrar: FlutterPluginRegistrar, path: String) -> String? {
        let key = registrar.lookupKey(forAsset: path)
        return Bundle.main.path(forResource: key, ofType: nil)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        //AudioManager.default.registerBackground()
        return true
    }
}