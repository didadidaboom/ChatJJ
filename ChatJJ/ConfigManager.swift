import Foundation

class ConfigManager {
    static let shared = ConfigManager()
    
    private init() {}
    
    func getDeepSeekAPIKey() -> String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
              let apiKey = dict["deepSeekAPIKey"] as? String else {
            print("Error: Couldn't find DeepSeek API key in Config.plist")
            return ""
        }
        return apiKey
    }
}