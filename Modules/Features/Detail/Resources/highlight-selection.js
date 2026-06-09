function postHighlightEvent(type, payload) {
    window.webkit.messageHandlers.highlightEvent.postMessage({ type: type, payload: payload });
}

function setupTextSelection() {
    document.addEventListener('selectionchange', function() {
        const selection = window.getSelection();
        const selectedText = selection.toString().trim();
        if (selectedText.length > 0 && selection.rangeCount > 0) {
            savedRange = selection.getRangeAt(0).cloneRange();
            postHighlightEvent('selected', { text: selectedText });
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
                postHighlightEvent('selected', { text: selectedText });
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

    postHighlightEvent('applied', { text: textToHighlight, style: color });

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

    postHighlightEvent('styleChanged', { text: fullText, style: newType });

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

    postHighlightEvent('deleted', { text: fullText });

    hideHighlightEditMenu();
}
