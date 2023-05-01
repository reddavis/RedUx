@testable import Numan
import SnapshotTesting
import XCTest

class ___VARIABLE_productName___ScreenSnapshotTests: XCTestCase {
    func test_loaded() {
        assertSnapshot(
            matching: ___VARIABLE_productName___Screen(
                store: .mock(state: .init()),
                viewModel: .init(.mock())
            ),
            as: .fixedSizedImage(precision: 1, size: UIScreen.main.bounds.size)
        )
    }
}
