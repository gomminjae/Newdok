import Foundation

enum ArticleHighlightJS {
    static var coreScript: String {
        load("highlight-core") + "\n" + load("highlight-selection")
    }

    private static func load(_ name: String) -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: "js") else {
            assertionFailure("Missing JS resource: \(name).js")
            return ""
        }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            assertionFailure("Failed to load \(name).js: \(error)")
            return ""
        }
    }

    static func scrollToHighlightScript(text: String) -> String {
        let escapedText = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")

        return """
        (function() {
            const searchText = '\(escapedText)';
            const normalizedSearch = searchText.replace(/\\s+/g, ' ').trim();

            const highlights = document.querySelectorAll('[class^="highlight-"]');
            for (const el of highlights) {
                const normalizedEl = el.textContent.replace(/\\s+/g, ' ').trim();
                if (normalizedEl.includes(normalizedSearch) || normalizedSearch.includes(normalizedEl)) {
                    el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    const groupId = el.getAttribute('data-highlight-group');
                    const groupEls = groupId
                        ? document.querySelectorAll('[data-highlight-group="' + groupId + '"]')
                        : [el];
                    showGroupFocusOverlay(groupEls);
                    setTimeout(function() { removeGroupFocusOverlay(); }, 1500);
                    return true;
                }
            }

            const content = document.querySelector('.content');
            if (!content) return false;

            const fullText = content.textContent.replace(/\\s+/g, ' ');
            const idx = fullText.indexOf(normalizedSearch);
            if (idx < 0) return false;

            const walker = document.createTreeWalker(content, NodeFilter.SHOW_TEXT, null, false);
            let node;
            let pos = 0;
            while (node = walker.nextNode()) {
                const nodeText = node.textContent.replace(/\\s+/g, ' ');
                if (pos + nodeText.length > idx) {
                    const range = document.createRange();
                    range.selectNodeContents(node);
                    const rect = range.getBoundingClientRect();
                    window.scrollTo({
                        top: rect.top + window.scrollY - 100,
                        behavior: 'smooth'
                    });
                    return true;
                }
                pos += nodeText.length;
            }
            return false;
        })();
        """
    }

    static func removeHighlightScript(text: String) -> String {
        let escapedText = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")

        return """
        (function() {
            const searchText = '\(escapedText)';
            const normalizedSearch = searchText.replace(/\\s+/g, ' ').trim();
            const highlights = document.querySelectorAll('[class^="highlight-"]');
            for (const el of highlights) {
                const normalizedEl = el.textContent.replace(/\\s+/g, ' ').trim();
                if (normalizedEl.includes(normalizedSearch) || normalizedSearch.includes(normalizedEl)) {
                    const groupId = el.getAttribute('data-highlight-group');
                    const groupEls = groupId
                        ? Array.from(document.querySelectorAll('[data-highlight-group="' + groupId + '"]'))
                        : [el];
                    groupEls.forEach(function(g) {
                        const parent = g.parentNode;
                        while (g.firstChild) {
                            parent.insertBefore(g.firstChild, g);
                        }
                        parent.removeChild(g);
                        parent.normalize();
                    });
                    return true;
                }
            }
            return false;
        })();
        """
    }
}
