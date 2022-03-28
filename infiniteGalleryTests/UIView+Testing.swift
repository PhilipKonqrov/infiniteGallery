//
//  UIView+Testing.swift
//  infiniteGalleryTests
//
//  Created by Philip Plamenov on 28.03.22.
//

import UIKit

extension UIView {
    /// Finds the subviews of a particular type.
    /// - Parameter type: The type of the subviews we wish to find.
    /// - Returns: The subviews of the given type, if any.
    func subviews<ViewType: UIView>(ofType type: ViewType.Type) -> [ViewType] {
        return subviews(passing: { $0 is ViewType }) as! [ViewType]
    }
    
    /// Finds the subviews that pass a particular test.
    /// - Parameter test: The closure used to determine whether a subview is a
    /// match or not.
    /// - Returns: The subviews passing the test.
    private func subviews(passing test: (UIView) -> Bool) -> [UIView] {
        var subviewsPassingTest = [UIView]()
        subviews.forEach { subview in
            if test(subview) {
                subviewsPassingTest.append(subview)
            }
            subviewsPassingTest.append(contentsOf: subview.subviews(passing: test))
        }
        return subviewsPassingTest
    }
}
