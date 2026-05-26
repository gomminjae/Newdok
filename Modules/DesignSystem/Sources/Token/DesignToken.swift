import SwiftUI

public enum DesignToken {
    // MARK: - Spacing
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 20
        public static let xxl: CGFloat = 24
        public static let xxxl: CGFloat = 32
    }

    // MARK: - Radius
    public enum Radius {
        public static let sm: CGFloat = 4
        public static let md: CGFloat = 8
        public static let lg: CGFloat = 12
        public static let xl: CGFloat = 16
        public static let xxl: CGFloat = 24
    }

    // MARK: - Font Size
    public enum FontSize {
        public static let caption: CGFloat = 12
        public static let body: CGFloat = 14
        public static let subhead: CGFloat = 16
        public static let title: CGFloat = 18
        public static let headline: CGFloat = 20
    }

    // MARK: - Icon Size
    public enum IconSize {
        public static let sm: CGFloat = 16
        public static let md: CGFloat = 20
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
    }
}
