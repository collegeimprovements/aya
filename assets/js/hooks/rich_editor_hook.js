/**
 * Tiptap Rich Text Editor hook for Phoenix LiveView.
 *
 * Features:
 * - Full toolbar: headings, bold, italic, underline, strike, code, blockquote, lists
 * - Table support: insert, add/remove rows/columns
 * - Text alignment
 * - AI selection menu: expand, summarize, fix language
 * - Form integration via hidden input
 * - Syncs content as HTML to a hidden textarea
 */

import { Editor } from "@tiptap/core"
import StarterKit from "@tiptap/starter-kit"
// Underline is included in StarterKit v2+
import { Table } from "@tiptap/extension-table"
import { TableRow } from "@tiptap/extension-table-row"
import { TableCell } from "@tiptap/extension-table-cell"
import { TableHeader } from "@tiptap/extension-table-header"
import Placeholder from "@tiptap/extension-placeholder"
import TextAlign from "@tiptap/extension-text-align"
import { TextStyle } from "@tiptap/extension-text-style"
import { Color } from "@tiptap/extension-color"
import { Highlight } from "@tiptap/extension-highlight"
// Link is included in StarterKit v2+

// ── Toolbar button definitions ──────────────────────────────
const TOOLBAR_GROUPS = [
  // Text style
  [
    { cmd: "toggleBold", icon: "bold", label: "Bold" },
    { cmd: "toggleItalic", icon: "italic", label: "Italic" },
    { cmd: "toggleUnderline", icon: "underline", label: "Underline" },
    { cmd: "toggleStrike", icon: "strikethrough", label: "Strikethrough" },
    { cmd: "toggleCode", icon: "code", label: "Inline code" },
  ],
  // Color & highlight
  [
    { cmd: "textColor", icon: "text-color", label: "Text color", custom: true },
    { cmd: "highlightColor", icon: "highlight", label: "Highlight", custom: true },
    { cmd: "clearFormat", icon: "clear-format", label: "Clear formatting", custom: true },
  ],
  // Link
  [
    { cmd: "setLink", icon: "link", label: "Link", custom: true },
    { cmd: "unsetLink", icon: "unlink", label: "Remove link", custom: true },
  ],
  // Block type
  [
    { cmd: "heading1", icon: "h1", label: "Heading 1", custom: true },
    { cmd: "heading2", icon: "h2", label: "Heading 2", custom: true },
    { cmd: "heading3", icon: "h3", label: "Heading 3", custom: true },
    { cmd: "toggleBlockquote", icon: "quote", label: "Blockquote" },
    { cmd: "toggleCodeBlock", icon: "codeblock", label: "Code block" },
  ],
  // Lists
  [
    { cmd: "toggleBulletList", icon: "ul", label: "Bullet list" },
    { cmd: "toggleOrderedList", icon: "ol", label: "Ordered list" },
  ],
  // Separator
  [
    { cmd: "setHorizontalRule", icon: "separator", label: "Horizontal rule" },
  ],
  // Alignment
  [
    { cmd: "alignLeft", icon: "align-left", label: "Align left", custom: true },
    { cmd: "alignCenter", icon: "align-center", label: "Align center", custom: true },
    { cmd: "alignRight", icon: "align-right", label: "Align right", custom: true },
  ],
  // Table
  [
    { cmd: "insertTable", icon: "table", label: "Insert table", custom: true },
  ],
  // Undo/Redo
  [
    { cmd: "undo", icon: "undo", label: "Undo" },
    { cmd: "redo", icon: "redo", label: "Redo" },
  ],
]

// ── SVG Icons (minimal, inline) ─────────────────────────────
const ICONS = {
  bold: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M6 4h8a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z"/><path d="M6 12h9a4 4 0 0 1 4 4 4 4 0 0 1-4 4H6z"/></svg>',
  italic: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="19" y1="4" x2="10" y2="4"/><line x1="14" y1="20" x2="5" y2="20"/><line x1="15" y1="4" x2="9" y2="20"/></svg>',
  underline: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 4v6a6 6 0 0 0 12 0V4"/><line x1="4" y1="20" x2="20" y2="20"/></svg>',
  strikethrough: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M16 4H9a3 3 0 0 0-3 3v0a3 3 0 0 0 3 3h6"/><path d="M8 20h7a3 3 0 0 0 3-3v0a3 3 0 0 0-3-3h-6"/><line x1="4" y1="12" x2="20" y2="12"/></svg>',
  code: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>',
  highlight: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 11-6 6v3h9l3-3"/><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"/></svg>',
  h1: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 12h8"/><path d="M4 18V6"/><path d="M12 18V6"/><path d="m17 12 3-2v8"/></svg>',
  h2: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 12h8"/><path d="M4 18V6"/><path d="M12 18V6"/><path d="M21 18h-4c0-4 4-3 4-6 0-1.5-2-2.5-4-1"/></svg>',
  h3: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 12h8"/><path d="M4 18V6"/><path d="M12 18V6"/><path d="M17.5 10.5c1.7-1 3.5 0 3.5 1.5a2 2 0 0 1-2 2"/><path d="M17 17.5c2 1.5 4 .3 4-1.5a2 2 0 0 0-2-2"/></svg>',
  quote: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V21z"/><path d="M15 21c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.25.25 4-2.75 4v3z"/></svg>',
  codeblock: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="2"/><polyline points="10 8 6 12 10 16"/><polyline points="14 16 18 12 14 8"/></svg>',
  ul: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><circle cx="3" cy="6" r="1" fill="currentColor"/><circle cx="3" cy="12" r="1" fill="currentColor"/><circle cx="3" cy="18" r="1" fill="currentColor"/></svg>',
  ol: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="10" y1="6" x2="21" y2="6"/><line x1="10" y1="12" x2="21" y2="12"/><line x1="10" y1="18" x2="21" y2="18"/><text x="1" y="8" font-size="7" fill="currentColor" stroke="none" font-family="sans-serif">1</text><text x="1" y="14" font-size="7" fill="currentColor" stroke="none" font-family="sans-serif">2</text><text x="1" y="20" font-size="7" fill="currentColor" stroke="none" font-family="sans-serif">3</text></svg>',
  "align-left": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="15" y2="12"/><line x1="3" y1="18" x2="18" y2="18"/></svg>',
  "align-center": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="6" y1="12" x2="18" y2="12"/><line x1="4" y1="18" x2="20" y2="18"/></svg>',
  "align-right": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="9" y1="12" x2="21" y2="12"/><line x1="6" y1="18" x2="21" y2="18"/></svg>',
  table: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="3" x2="9" y2="21"/><line x1="15" y1="3" x2="15" y2="21"/></svg>',
  "text-color": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 20h16"/><path d="m6 16 6-12 6 12"/><path d="M8 12h8"/><rect x="2" y="20" width="20" height="3" rx="1" fill="currentColor" opacity="0.3"/></svg>',
  "highlight-color": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 11-6 6v3h9l3-3"/><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"/><rect x="2" y="20" width="20" height="3" rx="1" fill="#fef08a" opacity="0.6"/></svg>',
  link: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>',
  unlink: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m18.84 12.25 1.72-1.71a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="m5.16 11.75-1.72 1.71a5 5 0 0 0 7.07 7.07l1.72-1.71"/><line x1="2" y1="2" x2="22" y2="22"/></svg>',
  separator: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><line x1="3" y1="12" x2="21" y2="12"/></svg>',
  "clear-format": '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 7V4h16v3"/><path d="M9 20h6"/><path d="M12 4v16"/><line x1="3" y1="21" x2="21" y2="3"/></svg>',
  undo: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/></svg>',
  redo: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>',
  ai: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/><path d="M5 3v4"/><path d="M19 17v4"/><path d="M3 5h4"/><path d="M17 19h4"/></svg>',
}

// ── AI Selection Menu ───────────────────────────────────────
const AI_ACTIONS = [
  { id: "expand", label: "Expand with AI", icon: "✨" },
  { id: "summarize", label: "Summarize", icon: "📝" },
  { id: "fix_language", label: "Fix language & typos", icon: "🔤" },
  { id: "simplify", label: "Simplify", icon: "💡" },
  { id: "formal", label: "Make formal", icon: "👔" },
  { id: "casual", label: "Make casual", icon: "😊" },
]

// ── Hook ────────────────────────────────────────────────────
const RichEditor = {
  mounted() {
    const el = this.el
    const editorEl = el.querySelector("[data-re-editor]")
    const toolbarEl = el.querySelector("[data-re-toolbar]")
    const hiddenInput = el.querySelector("[data-re-input]")
    const placeholder = el.dataset.placeholder || "Start writing..."
    const aiEnabled = el.dataset.aiEnabled === "true"

    // Build toolbar
    this._buildToolbar(toolbarEl, aiEnabled)

    // Initialize Tiptap
    this.editor = new Editor({
      element: editorEl,
      extensions: [
        StarterKit.configure({
          heading: { levels: [1, 2, 3] },
          link: { openOnClick: false, HTMLAttributes: { class: "re-link" } },
        }),
        Table.configure({ resizable: true }),
        TableRow,
        TableCell,
        TableHeader,
        Placeholder.configure({ placeholder }),
        TextAlign.configure({ types: ["heading", "paragraph"] }),
        TextStyle,
        Color,
        Highlight.configure({ multicolor: true }),
      ],
      content: hiddenInput.value || "",
      editorProps: {
        attributes: {
          class: "re-content prose prose-sm max-w-none focus:outline-none min-h-[200px] px-4 py-3",
        },
      },
      onUpdate: ({ editor }) => {
        const html = editor.getHTML()
        hiddenInput.value = html
        hiddenInput.dispatchEvent(new Event("input", { bubbles: true }))
        this._updateToolbarState()
      },
      onSelectionUpdate: ({ editor }) => {
        this._updateToolbarState()
        if (aiEnabled) {
          const { from, to } = editor.state.selection
          if (from !== to) {
            const coords = editor.view.coordsAtPos(from)
            const wrapperRect = el.querySelector("[data-re-wrapper]").getBoundingClientRect()

            this._aiMenu.hidden = false
            const menuH = this._aiMenu.offsetHeight

            let top = coords.top - wrapperRect.top - menuH - 8
            if (top < 0) top = coords.bottom - wrapperRect.top + 8

            let left = coords.left - wrapperRect.left
            left = Math.max(0, Math.min(left, wrapperRect.width - this._aiMenu.offsetWidth - 8))

            this._aiMenu.style.top = top + "px"
            this._aiMenu.style.left = left + "px"
          } else {
            this._hideAIMenu()
          }
        }
      },
      onFocus: () => {
        el.querySelector("[data-re-wrapper]")?.classList.add("re-focused")
      },
      onBlur: () => {
        el.querySelector("[data-re-wrapper]")?.classList.remove("re-focused")
        // Delay hiding AI menu to allow clicks
        setTimeout(() => this._hideAIMenu(), 200)
      },
    })

    // AI menu events
    if (aiEnabled) {
      this._createAIMenu()
    }
  },

  updated() {
    // Sync content if server pushes new value
    const hiddenInput = this.el.querySelector("[data-re-input]")
    if (hiddenInput && this.editor) {
      const serverHTML = hiddenInput.value
      const editorHTML = this.editor.getHTML()
      if (serverHTML !== editorHTML) {
        this.editor.commands.setContent(serverHTML, false)
      }
    }
  },

  destroyed() {
    this.editor?.destroy()
    this._aiMenu?.remove()
  },

  // ── Private methods ─────────────────────────────────────

  _buildToolbar(container, aiEnabled) {
    container.innerHTML = ""

    TOOLBAR_GROUPS.forEach((group, gi) => {
      if (gi > 0) {
        const sep = document.createElement("div")
        sep.className = "re-toolbar-sep"
        container.appendChild(sep)
      }

      group.forEach(({ cmd, icon, label }) => {
        const btn = document.createElement("button")
        btn.type = "button"
        btn.className = "re-toolbar-btn"
        btn.title = label
        btn.setAttribute("aria-label", label)
        btn.dataset.cmd = cmd
        btn.innerHTML = `<span class="re-icon">${ICONS[icon] || icon}</span>`

        btn.addEventListener("click", (e) => {
          e.preventDefault()
          this._execCommand(cmd)
        })

        container.appendChild(btn)
      })
    })

    // AI dropdown in toolbar
    if (aiEnabled) {
      const sep = document.createElement("div")
      sep.className = "re-toolbar-sep"
      container.appendChild(sep)

      const aiWrap = document.createElement("div")
      aiWrap.className = "re-ai-dropdown"
      aiWrap.style.position = "relative"

      const aiBtn = document.createElement("button")
      aiBtn.type = "button"
      aiBtn.className = "re-toolbar-btn re-toolbar-btn--ai"
      aiBtn.title = "AI Actions (select text first)"
      aiBtn.setAttribute("aria-label", "AI Actions")
      aiBtn.innerHTML = `<span class="re-icon">${ICONS.ai}</span>`

      const aiPanel = document.createElement("div")
      aiPanel.className = "re-ai-menu re-ai-toolbar-menu"
      aiPanel.hidden = true

      AI_ACTIONS.forEach(({ id, label, icon }) => {
        const item = document.createElement("button")
        item.type = "button"
        item.className = "re-ai-menu-item"
        item.innerHTML = `<span class="re-ai-icon">${icon}</span> ${label}`
        item.addEventListener("mousedown", (e) => {
          e.preventDefault()
          const { from, to } = this.editor.state.selection
          const selectedText = this.editor.state.doc.textBetween(from, to, " ")
          if (selectedText) {
            this.pushEvent("ai_action", { action: id, text: selectedText, from, to })
          } else {
            console.warn("Select text first to use AI actions")
          }
          aiPanel.hidden = true
        })
        aiPanel.appendChild(item)
      })

      aiBtn.addEventListener("click", (e) => {
        e.preventDefault()
        aiPanel.hidden = !aiPanel.hidden
      })

      // Close on click outside
      document.addEventListener("click", (e) => {
        if (!aiWrap.contains(e.target)) aiPanel.hidden = true
      })

      aiWrap.appendChild(aiBtn)
      aiWrap.appendChild(aiPanel)
      container.appendChild(aiWrap)
    }
  },

  _execCommand(cmd) {
    const editor = this.editor
    if (!editor) return

    const commands = {
      heading1: () => editor.chain().focus().toggleHeading({ level: 1 }).run(),
      heading2: () => editor.chain().focus().toggleHeading({ level: 2 }).run(),
      heading3: () => editor.chain().focus().toggleHeading({ level: 3 }).run(),
      alignLeft: () => editor.chain().focus().setTextAlign("left").run(),
      alignCenter: () => editor.chain().focus().setTextAlign("center").run(),
      alignRight: () => editor.chain().focus().setTextAlign("right").run(),
      insertTable: () => editor.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run(),
      setLink: () => {
        const prev = editor.getAttributes("link").href
        const url = window.prompt("URL", prev || "https://")
        if (url === null) return // cancelled
        if (url === "") { editor.chain().focus().unsetLink().run(); return }
        editor.chain().focus().extendMarkRange("link").setLink({ href: url }).run()
      },
      unsetLink: () => editor.chain().focus().unsetLink().run(),
      textColor: () => this._togglePalette("text"),
      highlightColor: () => this._togglePalette("highlight"),
      clearFormat: () => editor.chain().focus().unsetAllMarks().clearNodes().run(),
    }

    if (commands[cmd]) {
      commands[cmd]()
    } else if (editor.commands[cmd]) {
      editor.chain().focus()[cmd]().run()
    }

    this._updateToolbarState()
  },

  _updateToolbarState() {
    const editor = this.editor
    if (!editor) return

    const toolbar = this.el.querySelector("[data-re-toolbar]")
    toolbar.querySelectorAll("[data-cmd]").forEach((btn) => {
      const cmd = btn.dataset.cmd
      let active = false

      switch (cmd) {
        case "toggleBold": active = editor.isActive("bold"); break
        case "toggleItalic": active = editor.isActive("italic"); break
        case "toggleUnderline": active = editor.isActive("underline"); break
        case "toggleStrike": active = editor.isActive("strike"); break
        case "toggleCode": active = editor.isActive("code"); break
        case "toggleHighlight": active = editor.isActive("highlight"); break
        case "setLink": active = editor.isActive("link"); break
        case "heading1": active = editor.isActive("heading", { level: 1 }); break
        case "heading2": active = editor.isActive("heading", { level: 2 }); break
        case "heading3": active = editor.isActive("heading", { level: 3 }); break
        case "toggleBlockquote": active = editor.isActive("blockquote"); break
        case "toggleCodeBlock": active = editor.isActive("codeBlock"); break
        case "toggleBulletList": active = editor.isActive("bulletList"); break
        case "toggleOrderedList": active = editor.isActive("orderedList"); break
        case "alignLeft": active = editor.isActive({ textAlign: "left" }); break
        case "alignCenter": active = editor.isActive({ textAlign: "center" }); break
        case "alignRight": active = editor.isActive({ textAlign: "right" }); break
      }

      btn.classList.toggle("re-toolbar-btn--active", active)
    })
  },

  // ── AI Selection Menu ─────────────────────────────────

  _createAIMenu() {
    const menu = document.createElement("div")
    menu.className = "re-ai-menu"
    menu.hidden = true

    AI_ACTIONS.forEach(({ id, label, icon }) => {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "re-ai-menu-item"
      btn.innerHTML = `<span class="re-ai-icon">${icon}</span> ${label}`
      btn.addEventListener("mousedown", (e) => {
        e.preventDefault() // Prevent blur
        const { from, to } = this.editor.state.selection
        const selectedText = this.editor.state.doc.textBetween(from, to, " ")
        if (selectedText) {
          this.pushEvent("ai_action", { action: id, text: selectedText, from, to })
        }
        this._hideAIMenu()
      })
      menu.appendChild(btn)
    })

    const wrapper = this.el.querySelector("[data-re-wrapper]")
    wrapper.style.position = "relative"
    wrapper.appendChild(menu)
    this._aiMenu = menu
  },

  _handleSelectionMenu() {
    if (!this._aiMenu) return
    const { from, to } = this.editor.state.selection
    const hasSelection = from !== to

    if (hasSelection) {
      const coords = this.editor.view.coordsAtPos(from)
      const editorRect = this.el.getBoundingClientRect()

      // Show first so we can measure, then position
      this._aiMenu.hidden = false
      const menuHeight = this._aiMenu.offsetHeight
      const menuWidth = this._aiMenu.offsetWidth

      let top = coords.top - editorRect.top - menuHeight - 8
      let left = coords.left - editorRect.left

      // Keep within editor bounds
      if (top < 0) top = coords.bottom - editorRect.top + 8 // flip below
      if (left + menuWidth > editorRect.width) left = editorRect.width - menuWidth - 8

      this._aiMenu.style.top = top + "px"
      this._aiMenu.style.left = Math.max(0, left) + "px"
    } else {
      this._hideAIMenu()
    }
  },

  _hideAIMenu() {
    if (this._aiMenu) this._aiMenu.hidden = true
  },

  _togglePalette(mode) {
    // Close any existing palette
    const existing = this.el.querySelector(".re-color-palette")
    if (existing) { existing.remove(); return }

    const editor = this.editor
    const colors = mode === "text"
      ? [
          { c: "#b91c1c", l: "Red" }, { c: "#c2410c", l: "Orange" },
          { c: "#a16207", l: "Amber" }, { c: "#15803d", l: "Green" },
          { c: "#0369a1", l: "Blue" }, { c: "#7c3aed", l: "Purple" },
          { c: "#be185d", l: "Pink" }, { c: "#1c1917", l: "Black" },
        ]
      : [
          { c: "#fef08a", l: "Yellow" }, { c: "#fed7aa", l: "Orange" },
          { c: "#fecaca", l: "Red" }, { c: "#bbf7d0", l: "Green" },
          { c: "#bae6fd", l: "Blue" }, { c: "#e9d5ff", l: "Purple" },
          { c: "#fbcfe8", l: "Pink" }, { c: "#e5e5e5", l: "Gray" },
        ]

    const palette = document.createElement("div")
    palette.className = "re-color-palette"

    const grid = document.createElement("div")
    grid.className = "re-color-palette-grid"

    colors.forEach(({ c, l }) => {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "re-color-swatch"
      btn.style.backgroundColor = c
      btn.title = l
      btn.addEventListener("mousedown", (e) => {
        e.preventDefault()
        if (mode === "text") editor.chain().focus().setColor(c).run()
        else editor.chain().focus().toggleHighlight({ color: c }).run()
        palette.remove()
      })
      grid.appendChild(btn)
    })

    // Clear button
    const clear = document.createElement("button")
    clear.type = "button"
    clear.className = "re-color-swatch re-color-swatch--clear"
    clear.title = "Clear"
    clear.innerHTML = "✕"
    clear.addEventListener("mousedown", (e) => {
      e.preventDefault()
      if (mode === "text") editor.chain().focus().unsetColor().run()
      else editor.chain().focus().unsetHighlight().run()
      palette.remove()
    })
    grid.appendChild(clear)

    palette.appendChild(grid)

    // Position below the toolbar button
    const cmd = mode === "text" ? "textColor" : "highlightColor"
    const btn = this.el.querySelector(`[data-cmd="${cmd}"]`)
    const wrapper = this.el.querySelector("[data-re-wrapper]")
    if (btn && wrapper) {
      wrapper.style.position = "relative"
      const bRect = btn.getBoundingClientRect()
      const wRect = wrapper.getBoundingClientRect()
      palette.style.top = (bRect.bottom - wRect.top + 4) + "px"
      palette.style.left = Math.max(0, bRect.left - wRect.left) + "px"
    }

    wrapper.appendChild(palette)

    // Click outside to close
    const close = (e) => {
      if (!palette.contains(e.target) && !btn.contains(e.target)) {
        palette.remove()
        document.removeEventListener("mousedown", close)
      }
    }
    setTimeout(() => document.addEventListener("mousedown", close), 0)
  },
}

export default RichEditor
