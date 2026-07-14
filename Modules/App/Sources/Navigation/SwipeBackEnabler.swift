import UIKit

// 시스템 백버튼을 숨기면(.navigationBarBackButtonHidden) iOS가 엣지 스와이프 pop 제스처도
// 비활성화하므로, 커스텀 백버튼을 쓰는 화면에서도 스와이프 백이 동작하도록 다시 켠다.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1   // 루트에서는 비활성 (pop할 게 없을 때 프리즈 방지)
    }
}
