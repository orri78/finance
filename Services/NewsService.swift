import Foundation
import UIKit

// MARK: - RSS Feed Sources

struct RSSSource {
    let source: NewsItem.NewsSource
    let url: URL
    let category: NewsItem.NewsCategory
}

private let rssSources: [RSSSource] = [
    RSSSource(
        source: .mbl,
        url: URL(string: "https://www.mbl.is/feeds/vidskipti/")!,
        category: .viðskipti
    ),
    RSSSource(
        source: .vb,
        url: URL(string: "https://www.vb.is/rss/")!,
        category: .viðskipti
    ),
    RSSSource(
        source: .visir,
        url: URL(string: "https://www.visir.is/rss/section/vidskipti")!,
        category: .viðskipti
    ),
]

// MARK: - News Service

final class NewsService {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetch all sources concurrently, merge and sort by date.
    func fetchAll() async -> [NewsItem] {
        await withTaskGroup(of: [NewsItem].self) { group in
            for feed in rssSources {
                let service = self
                group.addTask {
                    do {
                        return try await service.fetch(feed: feed)
                    } catch {
                        print("⚠️ RSS fetch failed for \(feed.source.rawValue): \(error)")
                        return []
                    }
                }
            }
            var all: [NewsItem] = []
            for await items in group {
                all.append(contentsOf: items)
            }
            print("📰 Fetched \(all.count) news items total")
            return all.sorted { $0.publishedAt > $1.publishedAt }
        }
    }

    /// Fetch a single RSS source.
    func fetch(feed: RSSSource) async throws -> [NewsItem] {
        print("🔄 Fetching \(feed.url)")
        let (data, response) = try await session.data(from: feed.url)
        if let http = response as? HTTPURLResponse {
            print("📡 \(feed.source.rawValue): HTTP \(http.statusCode), \(data.count) bytes")
        }
        let items = RSSParser.parse(data: data, source: feed.source, category: feed.category)
        print("✅ Parsed \(items.count) items from \(feed.source.rawValue)")
        return items
    }
}

// MARK: - RSS XML Parser

private final class RSSParser: NSObject, XMLParserDelegate {

    private var items: [NewsItem] = []

    // Current item state
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentImageURL = ""
    private var insideItem = false

    private var source: NewsItem.NewsSource
    private var category: NewsItem.NewsCategory

    private static let dateFormatters: [DateFormatter] = {
        let formats = [
            "EEE, dd MMM yyyy HH:mm:ss Z",
            "EEE, dd MMM yyyy HH:mm:ss z",
            "yyyy-MM-dd'T'HH:mm:ssZ",
        ]
        return formats.map { fmt in
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = fmt
            return f
        }
    }()

    init(source: NewsItem.NewsSource, category: NewsItem.NewsCategory) {
        self.source = source
        self.category = category
    }

    static func parse(
        data: Data,
        source: NewsItem.NewsSource,
        category: NewsItem.NewsCategory
    ) -> [NewsItem] {
        let delegate = RSSParser(source: source, category: category)
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        return delegate.items
    }

    // MARK: XMLParserDelegate

    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName: String?,
                attributes: [String: String]) {
        currentElement = elementName
        if elementName == "item" || elementName == "entry" {
            insideItem = true
            currentTitle = ""
            currentDescription = ""
            currentLink = ""
            currentPubDate = ""
            currentImageURL = ""
        }
        // Grab image from enclosure or media:content
        if insideItem {
            if elementName == "enclosure", let url = attributes["url"] {
                currentImageURL = url
            }
            if elementName == "media:content", let url = attributes["url"] {
                if currentImageURL.isEmpty { currentImageURL = url }
            }
            if elementName == "media:thumbnail", let url = attributes["url"] {
                if currentImageURL.isEmpty { currentImageURL = url }
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard insideItem else { return }
        switch currentElement {
        case "title":       currentTitle += string
        case "description": currentDescription += string
        case "link":        currentLink += string
        case "pubDate", "published", "updated": currentPubDate += string
        case "media:content": break
        default: break
        }
    }

    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName: String?) {
        guard insideItem, elementName == "item" || elementName == "entry" else { return }
        insideItem = false

        let cleanTitle = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSummary = currentDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .strippingHTML()
            .truncated(to: 200)
        let cleanLink = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty, let url = URL(string: cleanLink) else { return }

        let pubDate = parseDate(currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines))
        let imageURL = currentImageURL.isEmpty ? nil : URL(string: currentImageURL)

        items.append(NewsItem(
            id: UUID(),
            title: cleanTitle,
            summary: cleanSummary,
            source: source,
            publishedAt: pubDate,
            url: url,
            imageURL: imageURL,
            category: category
        ))
    }

    private func parseDate(_ string: String) -> Date {
        for formatter in Self.dateFormatters {
            if let date = formatter.date(from: string) { return date }
        }
        return Date()
    }
}

// MARK: - String helpers

private extension String {
    /// Strip HTML tags using regex — safe to call from any thread.
    func strippingHTML() -> String {
        var result = replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        result = result
            .replacingOccurrences(of: "&amp;",  with: "&")
            .replacingOccurrences(of: "&lt;",   with: "<")
            .replacingOccurrences(of: "&gt;",   with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    func truncated(to length: Int) -> String {
        count <= length ? self : String(prefix(length)) + "…"
    }
}
