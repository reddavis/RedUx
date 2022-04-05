@testable import Numan
import XCTest

final class ___VARIABLE_productName___ProviderTests: XCTestCase {
    private var session: MockHTTPSession!
    private var apiClient: NumanAPIClient!
    private var provider: ___VARIABLE_productName___Provider!

    override func setUpWithError() throws {
        session = MockHTTPSession()
        apiClient = NumanAPIClient.mock(
            authStore: MockAuthStore(),
            session: session
        )
        provider = .main(apiClient: apiClient)
    }

    func test_getNotificationSettings_succeeds() async {
        session.register(
            stub: MockHTTPSession.Stub(
                path: "/api/v1/settings/push_notifications", // Adapt this
                method: .get,
                statusCode: 200,
                data: PushNotificationSettingsRequest.mock() // Adapt this
            )
        )

        await XCTAsyncAssertNoThrow {
            do {
                let settings = try await provider.settings() // Adapt this
                XCTAssertEqual(settings, expectedResult)
            } catch {
                XCTFail("The notification settings request should be succeeding in this test case.") // Adapt this
            }
        }
    }
}
