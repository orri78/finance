import SafariServices
import SwiftUI

struct NewsReaderView: UIViewControllerRepresentable {
    let item: NewsItem

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: item.url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
