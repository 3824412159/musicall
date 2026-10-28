import SwiftUI
import WebKit

/// 播放页：用 WKWebView 打开网易云歌曲 H5 页面在线播放
/// 说明：在线试听方式，不抓取/下载音频文件，规避版权风险
struct PlayerView: View {
    let song: Song

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            WebPlayer(url: URL(string: "https://music.163.com/#/song?id=\(song.id)")!)
                .ignoresSafeArea()
                .navigationTitle(song.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                    }
                }
        }
    }
}

/// WKWebView 包装，支持内联播放、自动播放
struct WebPlayer: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = true
        config.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        // 加载失败时给出提示
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("加载失败: \(error.localizedDescription)")
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("加载失败(首跳): \(error.localizedDescription)")
        }
    }
}
