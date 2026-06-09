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
    const normalizedSearch = searchText.replace(/[\s\n\r\t]+/g, ' ').trim();
    console.log('[Highlight] Searching for:', normalizedSearch.substring(0, 50));

    // 1차: 단일 텍스트 노드에서 찾기
    const walker = document.createTreeWalker(content, NodeFilter.SHOW_TEXT, null, false);
    let node;
    while (node = walker.nextNode()) {
        const normalizedNode = node.textContent.replace(/[\s\n\r\t]+/g, ' ');
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
    const normalized = text.replace(/[\s\n\r\t]+/g, ' ');
    const normalizedSearchText = searchText.replace(/[\s\n\r\t]+/g, ' ');
    const idx = normalized.indexOf(normalizedSearchText);
    if (idx < 0) return -1;

    let normalizedPos = 0;
    for (let i = 0; i < text.length; i++) {
        if (normalizedPos === idx) return i;
        if (/[\s\n\r\t]/.test(text[i])) {
            while (i + 1 < text.length && /[\s\n\r\t]/.test(text[i + 1])) i++;
        }
        normalizedPos++;
    }
    return idx;
}

function findRealLength(text, startIdx, searchText) {
    const normalizedSearchText = searchText.replace(/[\s\n\r\t]+/g, ' ');
    let searchPos = 0;
    let realLen = 0;
    for (let i = startIdx; i < text.length && searchPos < normalizedSearchText.length; i++) {
        realLen++;
        if (/[\s\n\r\t]/.test(text[i])) {
            while (i + 1 < text.length && /[\s\n\r\t]/.test(text[i + 1])) {
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
    const normalizedSearchText = searchText.replace(/[\s\n\r\t]+/g, ' ').trim();

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
        return w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }).join('[\\s\\n\\r\\t]*');

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

