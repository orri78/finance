import Foundation
import Observation

@MainActor
@Observable
final class NewsViewModel {

    var items: [NewsItem] = []
    var selectedSource: NewsItem.NewsSource? = nil  // nil = all sources
    var isLoading = false
    var isRefreshing = false
    var hasLoaded = false
    var errorMessage: String? = nil

    var filteredItems: [NewsItem] {
        guard let source = selectedSource else { return items }
        return items.filter { $0.source == source }
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
        await fetchNews()
        isRefreshing = false
    }

    private func fetchNews() async {
        let fetched = await service.fetchAll()
        if fetched.isEmpty && hasLoaded {
            errorMessage = "Engar fréttir fundust. Athugaðu nettengingu."
        } else {
            items = fetched
        }
    }
}
