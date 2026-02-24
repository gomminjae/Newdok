//
//  ArticleHighlightJS.swift
//  Detail
//
//  Created by 권민재 on 2/14/26.
//

import Foundation

/// JavaScript 코드를 관리하는 구조체
enum ArticleHighlightJS {
    // MARK: - Core Highlight Functions

    static let coreScript = """
    let originalFontSizes = new Map();
    let savedRange = null;

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
        return highlightAcrossNodes(content, normalizedSearch, highlightType);
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

    function highlightAcrossNodes(container, searchText, highlightType) {
        const normalizedSearchText = searchText.replace(/[\\s\\n\\r\\t]+/g, ' ').trim();

        // 텍스트 노드 수집
        const textNodes = [];
        const walker = document.createTreeWalker(container, NodeFilter.SHOW_TEXT, null, false);
        let n;

        while (n = walker.nextNode()) {
            textNodes.push(n);
        }

        console.log('[Highlight] Found', textNodes.length, 'text nodes');

        // 전체 텍스트 구성 (노드 사이에 공백 추가)
        let fullText = '';
        let nodePositions = []; // { node, startInFull, endInFull }

        for (let i = 0; i < textNodes.length; i++) {
            const node = textNodes[i];
            const nodeText = node.textContent.replace(/[\\s\\n\\r\\t]+/g, ' ');
            const startPos = fullText.length;
            fullText += nodeText;
            nodePositions.push({
                node: node,
                startInFull: startPos,
                endInFull: fullText.length,
                originalText: node.textContent
            });
            // 노드 사이에 공백 추가 (<br> 등을 보완)
            if (i < textNodes.length - 1) {
                fullText += ' ';
            }
        }

        fullText = fullText.replace(/[\\s]+/g, ' ');
        const idx = fullText.indexOf(normalizedSearchText);
        console.log('[Highlight] fullText:', fullText.substring(0, 80), '...');
        console.log('[Highlight] searching:', normalizedSearchText.substring(0, 50), '...');
        console.log('[Highlight] idx:', idx);

        if (idx < 0) {
            // 부분 매칭 시도: 첫 30자로 찾기
            const partialSearch = normalizedSearchText.substring(0, 30);
            const partialIdx = fullText.indexOf(partialSearch);
            console.log('[Highlight] Partial search idx:', partialIdx);
            if (partialIdx >= 0) {
                // 첫 번째 부분이 포함된 노드 찾기
                for (const np of nodePositions) {
                    const normalizedNode = np.originalText.replace(/[\\s\\n\\r\\t]+/g, ' ');
                    if (normalizedNode.includes(partialSearch)) {
                        // 이 노드에서 하이라이트
                        highlightPartOfTextNode(np.node, 0, np.node.textContent.length, highlightType);
                        return true;
                    }
                }
            }
            return false;
        }

        const endIdx = idx + normalizedSearchText.length;
        const nodesToHighlight = [];

        // 재계산된 위치로 노드 찾기
        let currentPos = 0;
        for (let i = 0; i < textNodes.length; i++) {
            const node = textNodes[i];
            const nodeText = node.textContent.replace(/[\\s\\n\\r\\t]+/g, ' ');
            const nodeStart = currentPos;
            const nodeEnd = currentPos + nodeText.length;

            if (nodeEnd <= idx) {
                currentPos = nodeEnd + 1; // +1 for space between nodes
                continue;
            }
            if (nodeStart >= endIdx) break;

            const nodeStartInRange = Math.max(0, idx - nodeStart);
            const nodeEndInRange = Math.min(nodeText.length, endIdx - nodeStart);

            nodesToHighlight.push({
                node: node,
                start: nodeStartInRange,
                end: nodeEndInRange
            });

            currentPos = nodeEnd + 1;
        }

        console.log('[Highlight] Nodes to highlight:', nodesToHighlight.length);

        if (nodesToHighlight.length === 0) return false;

        for (let i = nodesToHighlight.length - 1; i >= 0; i--) {
            const info = nodesToHighlight[i];
            highlightPartOfTextNode(info.node, info.start, info.end, highlightType);
        }

        return true;
    }

    function highlightPartOfTextNode(textNode, start, end, highlightType) {
        const text = textNode.textContent;
        if (start >= end || start >= text.length) return;

        const before = text.substring(0, start);
        const highlight = text.substring(start, end);
        const after = text.substring(end);

        const parent = textNode.parentNode;
        if (!parent) return;

        const span = document.createElement('span');
        span.className = 'highlight-' + highlightType;
        span.textContent = highlight;

        const fragment = document.createDocumentFragment();
        if (before) fragment.appendChild(document.createTextNode(before));
        fragment.appendChild(span);
        if (after) fragment.appendChild(document.createTextNode(after));

        parent.replaceChild(fragment, textNode);
    }

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
    }

    // MARK: - 텍스트 선택 시 커스텀 팔레트 (기획서 D 에디트 메뉴)

    const TRASH_SVG = '<svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>';

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
        palette.style.top = (menuTop < 10 ? rect.bottom + 8 : menuTop) + 'px';
        palette.style.left = Math.min(Math.max(rect.left + rect.width / 2, 120), window.innerWidth - 120) + 'px';

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

        if (range.startContainer === range.endContainer && range.startContainer.nodeType === Node.TEXT_NODE) {
            const span = document.createElement('span');
            span.className = 'highlight-' + color;
            try {
                range.surroundContents(span);
            } catch (e) {
                highlightPartOfTextNode(range.startContainer, range.startOffset, range.endOffset, color);
            }
        } else {
            highlightRangeAcrossNodes(range, color);
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

    function highlightRangeAcrossNodes(range, highlightType) {
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
                highlightPartOfTextNode(textNode, start, end, highlightType);
            }
        }
    }

    function applyUnderline() {
        applyHighlight('underline');
    }

    // MARK: - 기존 하이라이트 클릭 편집 메뉴 (D, E)

    let _focusedHighlight = null;

    function setupHighlightClickHandlers() {
        document.addEventListener('click', function(e) {
            if (e.target.closest('.hl-palette')) return;

            const highlight = e.target.closest('span[class*="highlight-"]');
            if (highlight) {
                const hlTypes = ['highlight-yellow','highlight-orange','highlight-pink','highlight-green','highlight-blue','highlight-underline'];
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

    function showHighlightEditMenu(element) {
        hideHighlightEditMenu();
        hideSelectionPalette();

        element.classList.add('highlight-focused');
        window._focusedHighlight = element;

        const currentType = getHighlightType(element);
        const rect = element.getBoundingClientRect();

        const menu = document.createElement('div');
        menu.className = 'hl-palette';
        menu.setAttribute('data-role', 'edit');

        const menuTop = rect.top - 46;
        menu.style.top = (menuTop < 10 ? rect.bottom + 8 : menuTop) + 'px';
        menu.style.left = Math.min(Math.max(rect.left + rect.width / 2, 120), window.innerWidth - 120) + 'px';

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

        const focused = document.querySelector('.highlight-focused');
        if (focused) focused.classList.remove('highlight-focused');

        window._focusedHighlight = null;
    }

    function changeHighlightTypeFromMenu(newType) {
        const element = window._focusedHighlight;
        if (!element) return;

        const currentType = getHighlightType(element);
        if (currentType === newType) {
            hideHighlightEditMenu();
            return;
        }

        element.classList.remove('highlight-' + currentType);
        element.classList.add('highlight-' + newType);

        window.webkit.messageHandlers.highlightTypeChanged.postMessage({
            text: element.textContent,
            oldType: currentType,
            newType: newType
        });

        hideHighlightEditMenu();
    }

    function deleteHighlightFromMenu() {
        const element = window._focusedHighlight;
        if (!element) return;

        const text = element.textContent;

        const parent = element.parentNode;
        while (element.firstChild) {
            parent.insertBefore(element.firstChild, element);
        }
        parent.removeChild(element);
        parent.normalize();

        window.webkit.messageHandlers.highlightDeleted.postMessage({
            text: text
        });

        hideHighlightEditMenu();
    }
    """

    // MARK: - Scroll & Remove Scripts

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
                    el.style.transition = 'outline 0.3s';
                    el.style.outline = '2px solid #007AFF';
                    setTimeout(() => { el.style.outline = 'none'; }, 1500);
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
                    const parent = el.parentNode;
                    while (el.firstChild) {
                        parent.insertBefore(el.firstChild, el);
                    }
                    parent.removeChild(el);
                    return true;
                }
            }
            return false;
        })();
        """
    }
}
