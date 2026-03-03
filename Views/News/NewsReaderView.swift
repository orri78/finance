import SafariServices
import SwiftUI

struct NewsReaderView: UIViewControllerRepresentable {
    let item: NewsItem

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: item.url)
        vc.preferredControlTintColor = UIColor(Color.brandAccent)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
