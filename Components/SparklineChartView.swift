import SwiftUI
import Charts

struct SparklineChartView: View {
    let data: [Double]
    let isPositive: Bool

    private var color: Color { isPositive ? .priceUp : .priceDown }

    private var indexedData: [(index: Int, value: Double)] {
        data.enumerated().map { (index: $0.offset, value: $0.element) }
    }

    var body: some View {
        Chart(indexedData, id: \.index) { point in
            LineMark(
                x: .value("Tími", point.index),
                y: .value("Verð", point.value)
            )
            .foregroundStyle(color)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Tími", point.index),
                yStart: .value("Lágmark", data.min() ?? 0),
                yEnd: .value("Verð", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.3), color.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: (data.min() ?? 0)...(data.max() ?? 1))
        .frame(width: 60, height: 30)
    }
}

#Preview {
    HStack(spacing: 16) {
        SparklineChartView(
            data: [100, 102, 101, 103, 105, 104, 106, 108, 107, 109],
            isPositive: true
        )
        SparklineChartView(
            data: [109, 107, 108, 106, 104, 105, 103, 101, 102, 100],
            isPositive: false
        )
    }
    .padding()
    .background(Color.black)
}
