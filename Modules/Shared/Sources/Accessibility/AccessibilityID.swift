public enum AccessibilityID {
    public enum Home {
        public static let searchButton = "home_search_button"
        public static let calendarButton = "home_calendar_button"
        public static let refreshButton = "home_refresh_button"

        public static func article(_ id: Int) -> String { "home_article_\(id)" }
    }

    public enum Explore {
        public static let searchButton = "explore_search_button"
        public static let recommendationRefreshButton = "explore_recommendation_refresh_button"
        public static let sortButton = "explore_sort_button"

        public static func tab(_ index: Int) -> String { "explore_tab_\(index)" }
        public static func newsletter(_ id: Int) -> String { "explore_newsletter_\(id)" }
        public static func carousel(_ id: Int) -> String { "explore_carousel_\(id)" }
        public static func allNewsletter(_ id: Int) -> String { "explore_all_newsletter_\(id)" }

        public enum Filter {
            public static let closeButton = "filter_close_button"
            public static let resetButton = "filter_reset_button"
            public static let applyButton = "filter_apply_button"

            public static func chip(_ text: String) -> String { "filter_chip_\(text)" }
        }

        public enum Sort {
            public static let closeButton = "sort_close_button"

            public static func option(_ value: String) -> String { "sort_option_\(value)" }
        }
    }

    public enum Search {
        public static let textField = "search_textfield"
        public static let clearButton = "search_clear_button"
        public static let submitButton = "search_submit_button"

        public static func keyword(_ rank: Int) -> String { "search_keyword_\(rank)" }
        public static func result(_ id: String) -> String { "search_result_\(id)" }

        public enum Result {
            public static let textField = "searchresult_textfield"
            public static let clearButton = "searchresult_clear_button"
            public static let submitButton = "searchresult_submit_button"

            public static func newsletter(_ id: String) -> String { "searchresult_newsletter_\(id)" }
        }
    }

    public enum Bookmark {
        public static let searchButton = "bookmark_search_button"
        public static let sortButton = "bookmark_sort_button"
        public static let sortCloseButton = "bookmark_sort_close_button"
        public static let guestLogin = "bookmark_guest_login"

        public static func sortOption(_ value: String) -> String { "bookmark_sort_option_\(value)" }
        public static func category(_ id: Int) -> String { "bookmark_category_\(id)" }
        public static func article(_ id: Int) -> String { "bookmark_article_\(id)" }
    }

    public enum Subscribe {
        public static let searchButton = "subscribe_search_button"
        public static let emptyLogin = "subscribe_empty_login"

        public static func toggle(_ id: Int) -> String { "subscribe_toggle_\(id)" }
        public static func row(_ id: Int) -> String { "subscribe_row_\(id)" }
        public static func picker(_ index: Int) -> String { "subscribe_picker_\(index)" }
    }

    public enum DesignSystem {
        public static let backButton = "back_button"
        public static let passwordVisibilityToggle = "password_visibility_toggle"
        public static let loadingView = "loading_view"
        public static let loadingDotsView = "loading_dots_view"
        public static let toastNotification = "toast_notification"
        public static let subscribeModalCloseButton = "subscribe_modal_close_button"

        public static func segment(_ index: Int) -> String { "segment_\(index)" }

        public enum Calendar {
            public static let todayButton = "calendar_today_button"
            public static let previousMonth = "calendar_previous_month"
            public static let monthTitle = "calendar_month_title"
            public static let nextMonth = "calendar_next_month"
            public static let closeButton = "calendar_close_button"

            public static func day(_ value: Int) -> String { "calendar_day_\(value)" }
        }

        public enum NoData {
            public static let refreshButton = "nodata_refresh_button"
            public static let ctaButton = "nodata_cta_button"
            public static let loginButton = "nodata_login_button"
        }

        public enum Popup {
            public static let authFailConfirm = "auth_fail_confirm_button"
            public static let checkIsSubscribeConfirm = "check_is_subscribe_confirm_button"
            public static let checkIsSubscribeResubscribe = "check_is_subscribe_resubscribe_button"
            public static let checkIsSubscribeClose = "check_is_subscribe_close_button"
            public static let checkSubscribeClose = "check_subscribe_close_button"
            public static let checkSubscribeConfirm = "check_subscribe_confirm_button"
            public static let emailInfoConfirm = "email_info_confirm_button"
            public static let notRegisteredConfirm = "not_registered_confirm_button"
            public static let signupRequiredSignup = "signup_required_signup_button"
            public static let signupRequiredLater = "signup_required_later_button"
            public static let signupRequiredClose = "signup_required_close_button"
            public static let subscribeCheckConfirm = "subscribe_check_confirm_button"
            public static let subscribeGuestSignup = "subscribe_guest_signup_button"
            public static let subscribeGuestClose = "subscribe_guest_close_button"
            public static let subscribeNoticeConfirm = "subscribe_notice_confirm_button"
            public static let subscribeStateDismiss = "subscribe_state_dismiss_button"
            public static let subscribeStateConfirm = "subscribe_state_confirm_button"
            public static let unsubscribeCancel = "unsubscribe_cancel_button"
            public static let unsubscribeConfirm = "unsubscribe_confirm_button"
            public static let loginErrorConfirm = "login_error_confirm_button"
            public static let networkErrorRetry = "network_error_retry_button"
            public static let serverErrorBack = "server_error_back_button"
            public static let serverErrorRefresh = "server_error_refresh_button"
            public static let systemErrorRetry = "system_error_retry_button"
            public static let updateConfirm = "update_confirm_button"
        }
    }
}
