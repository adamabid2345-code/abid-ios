import UIKit
import WebKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { ok, _ in
            if ok { Reminder.refresh() }
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) { Reminder.refresh() }

    func userNotificationCenter(_ c: UNUserNotificationCenter, willPresent n: UNNotification,
                                withCompletionHandler h: @escaping (UNNotificationPresentationOptions) -> Void) {
        h([.banner, .sound])
    }
}

enum Reminder {
    static let key = "rem_on"
    static var enabled: Bool { UserDefaults.standard.object(forKey: key) as? Bool ?? true }
    static let texts = [
        "طفي VPN وعاود شعلو باش يتبدل IP من جديد.",
        "تم اكتشاف نظامك. طفي VPN وشعلو دابا.",
        "تنبيه: طفي VPN وعاود شعلو.",
        "ذكير: بدل IP ديالك. طفي VPN وشعلو."
    ]
    static func set(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: key)
        refresh()
    }
    // iOS allows 64 pending notifications: schedule 60 at random gaps of 1-4 minutes
    static func refresh() {
        let c = UNUserNotificationCenter.current()
        c.removeAllPendingNotificationRequests()
        guard enabled else { return }
        var t = 0
        for i in 0..<60 {
            t += Int.random(in: 60...240)
            let m = UNMutableNotificationContent()
            m.title = "Abid"
            m.body = texts.randomElement()!
            m.sound = .default
            let trig = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(t), repeats: false)
            c.add(UNNotificationRequest(identifier: "abid.\(i)", content: m, trigger: trig))
        }
    }
}

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var web: WKWebView!
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.02, green: 0.008, blue: 0.012, alpha: 1)
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        cfg.userContentController.add(self, name: "reminder")
        web = WKWebView(frame: view.bounds, configuration: cfg)
        web.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        web.navigationDelegate = self
        web.uiDelegate = self
        web.isOpaque = false
        web.backgroundColor = view.backgroundColor
        web.scrollView.bounces = false
        web.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(web)
        if let url = Bundle.main.url(forResource: "abid", withExtension: "html") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    func userContentController(_ u: WKUserContentController, didReceive m: WKScriptMessage) {
        if m.name == "reminder", let v = m.body as? String { Reminder.set(v == "on") }
    }

    // Open every non-local link (app schemes, https, tel:, mailto:) outside the app
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme != "file", url.scheme != "about", url.scheme != "blob", url.scheme != "data" {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
