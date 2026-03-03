import Foundation
import Observation

enum NewsSortMode: String, CaseIterable {
    case newest  = "Nýjast"
    case mostRead = "Mest lesið"
}

@MainActor
@Observable
final class NewsViewModel {

    var items: [NewsItem] = []
    var mostReadItems: [NewsItem] = []
    var selectedSource: NewsItem.NewsSource? = nil
    var sortMode: NewsSortMode = .newest
    var selectedItem: NewsItem? = nil

    var isLoading = false
    var isRefreshing = false
    var hasLoaded = false
    var hasMostReadLoaded = false
    var errorMessage: String? = nil

    var filteredItems: [NewsItem] {
        let base = sortMode == .newest ? items : mostReadItems
        guard let source = selectedSource else { return base }
        return base.filter { $0.source == source }
    }

    private let service = NewsService()

    func load() async {
        guard !hasLoaded else { return }
        isLoading = true
        errorMessage = nil
        await fetchNews()
        isLoading = false
        hasLoaded = true
    }

    func refresh() async {
        isRefreshing = true
        errorMessage = nil
        if sortMode == .newest {
            await fetchNews()
        } else {
            await fetchMostRead()
        }
        isRefreshing = false
    }

    func switchMode(_ mode: NewsSortMode) async {
        sortMode = mode
        if mode == .mostRead && !hasMostReadLoaded {
            isLoading = true
            await fetchMostRead()
            isLoading = false
        }
    }

    private func fetchNews() async {
        let fetched = await service.fetchAll()
        if fetched.isEmpty && hasLoaded {
            errorMessage = "Engar fréttir fundust. Athugaðu nettengingu."
        } else {
            items = fetched
        }
    }

    private func fetchMostRead() async {
        let fetched = await service.fetchMostRead()
        mostReadItems = fetched
        hasMostReadLoaded = true
    }
}
