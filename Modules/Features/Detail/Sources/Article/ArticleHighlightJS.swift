//
//  ArticleHighlightJS.swift
//  Detail
//
//  Created by 권민재 on 2/14/26.
//

// swiftlint:disable file_length
import Foundation

/// JavaScript 코드를 관리하는 구조체
enum ArticleHighlightJS {
    // MARK: - Combined Script

    static var coreScript: String {
        highlightScript + "\n" + selectionScript
    }
}

// MARK: - Core Highlight Functions
extension ArticleHighlightJS {
    static let highlightScript = """
    let originalFontSizes = new Map();
    let savedRange = null;
    let _highlightIdCounter = 0;

    function generateHighlightId() {
        _highlightIdCounter++;
        return 'hl-' + Date.now() + '-' + _highlightIdCounter;
    }

    function saveOriginalFontSizes() {
        document.querySelectorAll('.content *').forEach(function(el, index) {
            const style = window.getComputedStyle(el);
            const currentSize = parseFloat(style.fontSize);
            if (currentSize > 0) {
                el.dataset.fontIndex = index;
                originalFontSizes.set(index, currentSize);
            }
        });
    }

    function adjustFontSize(newSize) {
        const baseSize = 16;
        const ratio = newSize / baseSize;
        document.querySelectorAll('[data-font-index]').forEach(function(el) {
            const index = parseInt(el.dataset.fontIndex);
            const originalSize = originalFontSizes.get(index);
            if (originalSize) {
                el.style.fontSize = (originalSize * ratio) + 'px';
            }
        });
    }

    function applySavedHighlights() {
        console.log('[Highlight] applySavedHighlights called, count:', savedHighlights.length);
        savedHighlights.forEach(function(h, index) {
            console.log('[Highlight] Applying highlight', index + 1, ':', h.text.substring(0, 30), '... type:', h.type);
            const success = highlightTextInDocument(h.text, h.type);
            console.log('[Highlight] Result:', success ? 'success' : 'failed');
        });
    }

    function highlightTextInDocument(searchText, highlightType) {
        const content = document.querySelector('.content');
        if (!content) {
            console.log('[Highlight] Content element not found');
            return false;
        }

        const groupId = generateHighlightId();

        // 줄바꿈, 탭, 여러 공백을 모두 단일 스페이스로 정규화
        const normalizedSearch = searchText.replace(/[\\s\\n\\r\\t]+/g, ' ').trim();
        console.log('[Highlight] Searching for:', normalizedSearch.substring(0, 50));

        // 1차: 단일 텍스트 노드에서 찾기
        const walker = document.createTreeWalker(content, NodeFilter.SHOW_TEXT, null, false);
        let node;
        while (node = walker.nextNode()) {
            const normalizedNode = node.textContent.replace(/[\\s\\n\\r\\t]+/g, ' ');
            const idx = normalizedNode.indexOf(normalizedSearch);
            if (idx >= 0) {
                let realIdx = findRealIndex(node.textContent, normalizedSearch);
                if (realIdx >= 0) {
                    const range = document.createRange();
                    range.setStart(node, realIdx);
                    range.setEnd(node, realIdx + findRealLength(node.textContent, realIdx, normalizedSearch));
                    const span = document.createElement('span');
                    span.className = 'highlight-' + highlightType;
                    span.setAttribute('data-highlight-group', groupId);
                    try {
                        range.surroundContents(span);
                        console.log('[Highlight] Single node match success');
                        return true;
                    } catch(e) {
                        console.log('[Highlight] Single node surroundContents failed:', e.message);
                    }
                }
            }
        }

        // 2차: 여러 노드에 걸친 텍스트 찾기
        return highlightAcrossNodes(content, normalizedSearch, highlightType, groupId);
    }

    function findRealIndex(text, searchText) {
        const normalized = text.replace(/[\\s\\n\\r\\t]+/g, ' ');
        const normalizedSearchText = searchText.replace(/[\\s\\n\\r\\t]+/g, ' ');
        const idx = normalized.indexOf(normalizedSearchText);
        if (idx < 0) return -1;

        let normalizedPos = 0;
        for (let i = 0; i < text.length; i++) {
            if (normalizedPos === idx) return i;
            if (/[\\s\\n\\r\\t]/.test(text[i])) {
                while (i + 1 < text.length && /[\\s\\n\\r\\t]/.test(text[i + 1])) i++;
            }
            normalizedPos++;
        }
        return idx;
    }

    function findRealLength(text, startIdx, searchText) {
        const normalizedSearchText = searchText.replace(/[\\s\\n\\r\\t]+/g, ' ');
        let searchPos = 0;
        let realLen = 0;
        for (let i = startIdx; i < text.length && searchPos < normalizedSearchText.length; i++) {
            realLen++;
            if (/[\\s\\n\\r\\t]/.test(text[i])) {
                while (i + 1 < text.length && /[\\s\\n\\r\\t]/.test(text[i + 1])) {
                    i++;
                    realLen++;
                }
            }
            searchPos++;
        }
        return realLen;
    }

    function highlightAcrossNodes(container, searchText, highlightType, groupId) {
        if (!groupId) groupId = generateHighlightId();
        const normalizedSearchText = searchText.replace(/[\\s\\n\\r\\t]+/g, ' ').trim();

        // 텍스트 노드 수집
        const textNodes = [];
        const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT, null, false);
        let n;
        while (n = walker.nextNode()) {
            textNodes.push(n);
        }

        if (textNodes.length === 0) return false;
        console.log('[Highlight] Found', textNodes.length, 'text nodes');

        // 원본 텍스트를 그대로 이어붙이고 노드별 위치를 정확히 기록
        
        let rawFullText = '';
        const nodeRanges = [];

        for (let i = 0; i < textNodes.length; i++) {
            const startPos = rawFullText.length;
            rawFullText += textNodes[i].textContent;
            nodeRanges.push({ node: textNodes[i], start: startPos, end: rawFullText.length });
        }

        // 검색어의 각 단어를 정규식으로 변환: 단어 사이에 임의의 공백 매칭
        const words = normalizedSearchText.split(' ').filter(function(w) { return w.length > 0; });
        if (words.length === 0) return false;

        const regexStr = words.map(function(w) {
            return w.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&');
        }).join('[\\\\s\\\\n\\\\r\\\\t]*');

        console.log('[Highlight] Regex search:', regexStr.substring(0, 60));

        let match = null;
        try {
            const regex = new RegExp(regexStr);
            match = regex.exec(rawFullText);
        } catch(e) {
            console.log('[Highlight] Regex error:', e.message);
        }

        if (!match) {
            console.log('[Highlight] Cross-node match failed');
            return false;
        }

        const matchStart = match.index;
        const matchEnd = matchStart + match[0].length;
        console.log('[Highlight] Match found at', matchStart, '-', matchEnd);

        // 매칭 범위에 걸치는 노드들 찾기
        const nodesToHighlight = [];
        for (let i = 0; i < nodeRanges.length; i++) {
            const nr = nodeRanges[i];
            if (nr.end <= matchStart) continue;
            if (nr.start >= matchEnd) break;

            const startInNode = Math.max(0, matchStart - nr.start);
            const endInNode = Math.min(nr.end - nr.start, matchEnd - nr.start);

            if (startInNode < endInNode) {
                nodesToHighlight.push({ node: nr.node, start: startInNode, end: endInNode });
            }
        }

        console.log('[Highlight] Nodes to highlight:', nodesToHighlight.length);
        if (nodesToHighlight.length === 0) return false;

        for (let i = nodesToHighlight.length - 1; i >= 0; i--) {
            const info = nodesToHighlight[i];
            highlightPartOfTextNode(info.node, info.start, info.end, highlightType, groupId);
        }

        return true;
    }

    function highlightPartOfTextNode(textNode, start, end, highlightType, groupId) {
        const text = textNode.textContent;
        if (start >= end || start >= text.length) return;

        const before = text.substring(0, start);
        const highlight = text.substring(start, end);
        const after = text.substring(end);

        const parent = textNode.parentNode;
        if (!parent) return;

        const span = document.createElement('span');
        span.className = 'highlight-' + highlightType;
        if (groupId) span.setAttribute('data-highlight-group', groupId);
        span.textContent = highlight;

        const fragment = document.createDocumentFragment();
        if (before) fragment.appendChild(document.createTextNode(before));
        fragment.appendChild(span);
        if (after) fragment.appendChild(document.createTextNode(after));

        parent.replaceChild(fragment, textNode);
    }

    """
}

// MARK: - Selection & Edit Menu Functions
extension ArticleHighlightJS {
    static let selectionScript = """
    function setupTextSelection() {
        document.addEventListener('selectionchange', function() {
            const selection = window.getSelection();
            const selectedText = selection.toString().trim();
            if (selectedText.length > 0 && selection.rangeCount > 0) {
                savedRange = selection.getRangeAt(0).cloneRange();
                window.webkit.messageHandlers.textSelected.postMessage({
                    text: selectedText,
                    hasSelection: true
                });
            }
        });

        document.addEventListener('touchend', function(e) {
            if (e.target.closest('.hl-palette')) return;

            setTimeout(function() {
                // 에디트 메뉴가 이미 표시 중이면 선택 팔레트 표시하지 않음
                if (document.querySelector('.hl-palette[data-role="edit"]')) return;

                const selection = window.getSelection();
                const selectedText = selection.toString().trim();
                if (selectedText.length > 0 && selection.rangeCount > 0) {
                    savedRange = selection.getRangeAt(0).cloneRange();
                    window.webkit.messageHandlers.textSelected.postMessage({
                        text: selectedText,
                        hasSelection: true
                    });
                    showSelectionPalette();
                } else {
                    hideSelectionPalette();
                }
            }, 300);
        }, { passive: true });

        // 스크롤 시 편집 메뉴 및 오버레이 닫기
        window.addEventListener('scroll', function() {
            hideHighlightEditMenu();
            hideSelectionPalette();
        }, { passive: true });
    }

    // MARK: - 텍스트 선택 시 커스텀 팔레트 (기획서 D 에디트 메뉴)

    const TRASH_SVG = '<svg xmlns="http://www.w3.org/2000/svg" '
        + 'width="15" height="15" viewBox="0 0 24 24" fill="none" '
        + 'stroke="white" stroke-width="2" stroke-linecap="round" '
        + 'stroke-linejoin="round">'
        + '<polyline points="3 6 5 6 21 6"/>'
        + '<path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6'
        + 'm3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>';

    function buildPaletteHTML(currentType, showDelete) {
        const colors = ['yellow', 'orange', 'pink', 'green', 'blue'];
        let html = '';
        colors.forEach(function(color) {
            const sel = currentType === color ? ' selected' : '';
            html += '<div class="hl-dot ' + color + sel + '" data-type="' + color + '"></div>';
        });
        html += '<div class="hl-sep"></div>';
        const uSel = currentType === 'underline' ? ' selected' : '';
        html += '<div class="hl-underline' + uSel + '" data-type="underline">가</div>';
        if (showDelete) {
            html += '<div class="hl-sep"></div>';
            html += '<div class="hl-trash" data-action="delete">' + TRASH_SVG + '</div>';
        }
        return html;
    }

    function showSelectionPalette() {
        hideSelectionPalette();
        hideHighlightEditMenu();

        const selection = window.getSelection();
        if (!selection.rangeCount || selection.toString().trim().length === 0) return;

        const range = selection.getRangeAt(0);
        const rect = range.getBoundingClientRect();

        const palette = document.createElement('div');
        palette.className = 'hl-palette';
        palette.setAttribute('data-role', 'selection');

        const menuTop = rect.top - 46;
        const isBelow = menuTop < 10;
        palette.style.top = (isBelow ? rect.bottom + 8 : menuTop) + 'px';
        palette.style.left = Math.min(Math.max(rect.left + rect.width / 2, 120), window.innerWidth - 120) + 'px';
        if (isBelow) palette.classList.add('below');

        palette.innerHTML = buildPaletteHTML('', false);
        document.body.appendChild(palette);

        palette.querySelectorAll('.hl-dot, .hl-underline').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                e.preventDefault();
                applyHighlight(btn.getAttribute('data-type'));
                hideSelectionPalette();
            });
        });
    }

    function hideSelectionPalette() {
        const p = document.querySelector('.hl-palette[data-role="selection"]');
        if (p) p.remove();
    }

    function applyHighlight(color) {
        let selection = window.getSelection();
        let range = null;
        let textToHighlight = '';

        if (selection.rangeCount > 0 && selection.toString().trim().length > 0) {
            range = selection.getRangeAt(0);
            textToHighlight = selection.toString().trim();
        } else if (savedRange) {
            range = savedRange;
            textToHighlight = savedRange.toString().trim();
        }

        if (!range || textToHighlight.length === 0) {
            console.log('No text selected for highlight');
            return;
        }

        const groupId = generateHighlightId();

        if (range.startContainer === range.endContainer && range.startContainer.nodeType === Node.TEXT_NODE) {
            const span = document.createElement('span');
            span.className = 'highlight-' + color;
            span.setAttribute('data-highlight-group', groupId);
            try {
                range.surroundContents(span);
            } catch (e) {
                highlightPartOfTextNode(range.startContainer, range.startOffset, range.endOffset, color, groupId);
            }
        } else {
            highlightRangeAcrossNodes(range, color, groupId);
        }

        window.webkit.messageHandlers.textSelected.postMessage({
            text: textToHighlight,
            hasSelection: true,
            highlightApplied: true,
            highlightColor: color
        });

        selection.removeAllRanges();
        savedRange = null;
    }

    function highlightRangeAcrossNodes(range, highlightType, groupId) {
        if (!groupId) groupId = generateHighlightId();
        const textNodes = [];
        const walker = document.createTreeWalker(
            range.commonAncestorContainer,
            NodeFilter.SHOW_TEXT,
            {
                acceptNode: function(node) {
                    const nodeRange = document.createRange();
                    nodeRange.selectNodeContents(node);
                    if (range.compareBoundaryPoints(Range.END_TO_START, nodeRange) < 0 &&
                        range.compareBoundaryPoints(Range.START_TO_END, nodeRange) > 0) {
                        return NodeFilter.FILTER_ACCEPT;
                    }
                    return NodeFilter.FILTER_REJECT;
                }
            }
        );

        let node;
        while (node = walker.nextNode()) {
            textNodes.push(node);
        }

        for (let i = textNodes.length - 1; i >= 0; i--) {
            const textNode = textNodes[i];
            let start = 0;
            let end = textNode.textContent.length;

            if (textNode === range.startContainer) {
                start = range.startOffset;
            }
            if (textNode === range.endContainer) {
                end = range.endOffset;
            }

            if (start < end) {
                highlightPartOfTextNode(textNode, start, end, highlightType, groupId);
            }
        }
    }

    function applyUnderline() {
        applyHighlight('underline');
    }

    // MARK: - 기존 하이라이트 클릭 편집 메뉴 (D, E)

    let _focusedHighlight = null;
    let _focusedGroupId = null;

    function getHighlightGroup(element) {
        const groupId = element.getAttribute('data-highlight-group');
        if (groupId) {
            return document.querySelectorAll('[data-highlight-group="' + groupId + '"]');
        }
        return [element];
    }

    function setupHighlightClickHandlers() {
        document.addEventListener('click', function(e) {
            if (e.target.closest('.hl-palette')) return;

            const highlight = e.target.closest('span[class*="highlight-"]');
            if (highlight) {
                const hlTypes = [
                    'highlight-yellow','highlight-orange',
                    'highlight-pink','highlight-green',
                    'highlight-blue','highlight-underline'
                ];
                const isHighlight = hlTypes.some(function(t) { return highlight.classList.contains(t); });
                if (isHighlight) {
                    e.preventDefault();
                    e.stopPropagation();
                    window.getSelection().removeAllRanges();
                    showHighlightEditMenu(highlight);
                    return;
                }
            }

            hideHighlightEditMenu();
            hideSelectionPalette();
        });
    }

    function getHighlightType(element) {
        const types = ['yellow', 'orange', 'pink', 'green', 'blue', 'underline'];
        for (const t of types) {
            if (element.classList.contains('highlight-' + t)) return t;
        }
        return '';
    }

    // 그룹의 모든 span bounding rect를 줄 단위로 합쳐 하나의 파란 오버레이를 그린다
    function showGroupFocusOverlay(groupElements) {
        removeGroupFocusOverlay();
        if (!groupElements || groupElements.length === 0) return;

        // 모든 ClientRect 수집
        const allRects = [];
        groupElements.forEach(function(el) {
            const rects = el.getClientRects();
            for (let i = 0; i < rects.length; i++) {
                allRects.push(rects[i]);
            }
        });
        if (allRects.length === 0) return;

        // 같은 줄(top 차이 5px 이내)에 있는 rect를 하나로 합침
        const lines = [];
        allRects.forEach(function(r) {
            let merged = false;
            for (let line of lines) {
                if (Math.abs(line.top - r.top) < 5) {
                    line.left = Math.min(line.left, r.left);
                    line.right = Math.max(line.right, r.right);
                    line.top = Math.min(line.top, r.top);
                    line.bottom = Math.max(line.bottom, r.bottom);
                    merged = true;
                    break;
                }
            }
            if (!merged) {
                lines.push({ top: r.top, bottom: r.bottom, left: r.left, right: r.right });
            }
        });

        const container = document.createElement('div');
        container.className = 'highlight-group-overlay';

        lines.forEach(function(ln) {
            const box = document.createElement('div');
            box.style.cssText = 'position:fixed;pointer-events:none;'
                + 'border:2px solid #2866D3;border-radius:3px;'
                + 'left:' + (ln.left - 2) + 'px;'
                + 'top:' + (ln.top - 2) + 'px;'
                + 'width:' + (ln.right - ln.left + 4) + 'px;'
                + 'height:' + (ln.bottom - ln.top + 4) + 'px;';
            container.appendChild(box);
        });

        document.body.appendChild(container);
    }

    function removeGroupFocusOverlay() {
        const el = document.querySelector('.highlight-group-overlay');
        if (el) el.remove();
    }

    function showHighlightEditMenu(element) {
        hideHighlightEditMenu();
        hideSelectionPalette();

        const groupElements = getHighlightGroup(element);
        // 오버레이로 그룹 전체를 파란 박스로 감싸기
        showGroupFocusOverlay(groupElements);

        window._focusedHighlight = element;
        window._focusedGroupId = element.getAttribute('data-highlight-group');

        const currentType = getHighlightType(element);

        // 그룹 전체의 첫 번째 span 기준으로 메뉴 위치 결정
        const firstEl = groupElements[0] || element;
        const rect = firstEl.getBoundingClientRect();

        const menu = document.createElement('div');
        menu.className = 'hl-palette';
        menu.setAttribute('data-role', 'edit');

        const menuTop = rect.top - 46;
        const isBelow = menuTop < 10;
        menu.style.top = (isBelow ? rect.bottom + 8 : menuTop) + 'px';
        menu.style.left = Math.min(Math.max(rect.left + rect.width / 2, 120), window.innerWidth - 120) + 'px';
        if (isBelow) menu.classList.add('below');

        menu.innerHTML = buildPaletteHTML(currentType, true);
        document.body.appendChild(menu);

        menu.querySelectorAll('.hl-dot, .hl-underline').forEach(function(btn) {
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                changeHighlightTypeFromMenu(btn.getAttribute('data-type'));
            });
        });
        const trashBtn = menu.querySelector('.hl-trash');
        if (trashBtn) {
            trashBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                deleteHighlightFromMenu();
            });
        }
    }

    function hideHighlightEditMenu() {
        const menu = document.querySelector('.hl-palette[data-role="edit"]');
        if (menu) menu.remove();

        // 오버레이 제거
        removeGroupFocusOverlay();

        window._focusedHighlight = null;
        window._focusedGroupId = null;
    }

    function changeHighlightTypeFromMenu(newType) {
        const element = window._focusedHighlight;
        if (!element) return;

        const currentType = getHighlightType(element);
        if (currentType === newType) {
            hideHighlightEditMenu();
            return;
        }

        // 같은 그룹의 모든 span 타입 변경
        const groupElements = getHighlightGroup(element);
        let fullText = '';
        groupElements.forEach(function(el) {
            el.classList.remove('highlight-' + currentType);
            el.classList.add('highlight-' + newType);
            fullText += el.textContent;
        });

        window.webkit.messageHandlers.highlightTypeChanged.postMessage({
            text: fullText,
            oldType: currentType,
            newType: newType
        });

        hideHighlightEditMenu();
    }

    function deleteHighlightFromMenu() {
        const element = window._focusedHighlight;
        if (!element) return;

        // 같은 그룹의 모든 span에서 텍스트 수집 후 제거
        const groupElements = Array.from(getHighlightGroup(element));
        let fullText = '';
        groupElements.forEach(function(el) {
            fullText += el.textContent;
        });

        groupElements.forEach(function(el) {
            const parent = el.parentNode;
            while (el.firstChild) {
                parent.insertBefore(el.firstChild, el);
            }
            parent.removeChild(el);
            parent.normalize();
        });

        window.webkit.messageHandlers.highlightDeleted.postMessage({
            text: fullText
        });

        hideHighlightEditMenu();
    }
    """
}

// MARK: - Scroll & Remove Scripts
extension ArticleHighlightJS {
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
                    // 같은 그룹 전체를 파란 오버레이로 감싸기
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
                    // 같은 그룹의 모든 span 제거
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
