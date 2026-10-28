import SwiftUI

// MARK: - 数据模型

/// 歌曲信息（对应网易云搜索结果）
struct Song: Identifiable, Decodable {
    let id: Int
    let name: String
    let artists: [Artist]?

    struct Artist: Decodable {
        let name: String
    }

    var artistName: String {
        artists?.first?.name ?? "未知歌手"
    }
}

/// 搜索接口返回结构
struct SearchResponse: Decodable {
    let result: SearchResult?
    struct SearchResult: Decodable {
        let songs: [Song]?
    }
}

// MARK: - 搜索服务

/// 网易云旧版搜索接口（实训演示用，仅供学习）
struct MusicService {
    static let headers = [
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
        "Referer": "https://music.163.com/"
    ]

    /// 按歌名搜索，最多返回 limit 条
    static func search(keyword: String, limit: Int = 10) async throws -> [Song] {
        let keyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
        let url = URL(string: "https://music.163.com/api/search/get?s=\(keyword)&type=1&limit=\(limit)&csrf_token=")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = 10

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw MusicError.network("服务器无响应（\( (response as? HTTPURLResponse)?.statusCode ?? 0)）")
        }
        let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
        return decoded.result?.songs ?? []
    }
}

enum MusicError: LocalizedError {
    case network(String)
    var errorDescription: String? {
        switch self {
        case .network(let msg): return msg
        }
    }
}

// MARK: - 主界面

struct ContentView: View {
    @State private var keyword = ""
    @State private var songs: [Song] = []
    @State private var isLoading = false
    @State private var errorMsg: String?
    @State private var selectedSong: Song?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack(spacing: 8) {
                    TextField("输入歌名，如：晴天", text: $keyword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.search)
                        .onSubmit { search() }
                    Button(action: search) {
                        Text("搜索")
                            .fontWeight(.semibold)
                    }
                    .disabled(keyword.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                // 状态区
                if isLoading {
                    Spacer()
                    ProgressView("搜索中…")
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else if let errorMsg {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("出错了").font(.headline)
                        Text(errorMsg)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Text("可能原因：网易云接口风控限制，可稍后重试")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Spacer()
                } else if songs.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("搜歌听歌，输入歌名开始")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    // 结果列表
                    List(songs) { song in
                        Button {
                            selectedSong = song
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(song.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(song.artistName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("锁子音乐")
            .sheet(item: $selectedSong) { song in
                PlayerView(song: song)
            }
        }
    }

    private func search() {
        let kw = keyword.trimmingCharacters(in: .whitespaces)
        guard !kw.isEmpty else { return }
        Task {
            isLoading = true
            errorMsg = nil
            do {
                songs = try await MusicService.search(keyword: kw)
                if songs.isEmpty { errorMsg = "没有搜到「\(kw)」，换个歌名试试" }
            } catch {
                errorMsg = error.localizedDescription
            }
            isLoading = false
        }
    }
}
