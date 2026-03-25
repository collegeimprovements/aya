/**
 * CodeMirror 6 Markdown Editor hook for Phoenix LiveView.
 *
 * Features:
 * - Syntax-highlighted markdown editing
 * - Live preview toggle (rendered via marked.js or server)
 * - Toolbar: headings, bold, italic, code, links, lists, blockquote
 * - Dark mode support via theme detection
 * - Form integration via hidden textarea
 */

import { EditorView, keymap, placeholder as cmPlaceholder } from "@codemirror/view"
import { EditorState } from "@codemirror/state"
import { markdown } from "@codemirror/lang-markdown"
import { languages } from "@codemirror/language-data"
import { defaultKeymap, indentWithTab, history, historyKeymap, undo, redo } from "@codemirror/commands"
import { oneDark } from "@codemirror/theme-one-dark"
import {
  syntaxHighlighting,
  defaultHighlightStyle,
  bracketMatching,
} from "@codemirror/language"

// ── Toolbar actions ─────────────────────────────────────────
const TOOLBAR = [
  [
    { cmd: "bold", icon: "B", label: "Bold (⌘B)", wrap: ["**", "**"] },
    { cmd: "italic", icon: "I", label: "Italic (⌘I)", wrap: ["_", "_"] },
    { cmd: "strike", icon: "S", label: "Strikethrough", wrap: ["~~", "~~"] },
    { cmd: "code", icon: "<>", label: "Inline code", wrap: ["`", "`"] },
  ],
  [
    { cmd: "h1", icon: "H1", label: "Heading 1", prefix: "# " },
    { cmd: "h2", icon: "H2", label: "Heading 2", prefix: "## " },
    { cmd: "h3", icon: "H3", label: "Heading 3", prefix: "### " },
  ],
  [
    { cmd: "ul", icon: "•", label: "Bullet list", prefix: "- " },
    { cmd: "ol", icon: "1.", label: "Ordered list", prefix: "1. " },
    { cmd: "quote", icon: ">", label: "Blockquote", prefix: "> " },
  ],
  [
    { cmd: "link", icon: "🔗", label: "Link", template: "[text](url)" },
    { cmd: "image", icon: "🖼", label: "Image", template: "![alt](url)" },
    { cmd: "hr", icon: "—", label: "Horizontal rule", insert: "\n---\n" },
    { cmd: "codeblock", icon: "```", label: "Code block", insert: "\n```\n\n```\n", cursorOffset: -5 },
  ],
  [
    { cmd: "undo", icon: "↩", label: "Undo", action: "undo" },
    { cmd: "redo", icon: "↪", label: "Redo", action: "redo" },
    { cmd: "preview", icon: "👁", label: "Toggle preview", action: "preview" },
  ],
]

// ── Hook ────────────────────────────────────────────────────
const MarkdownEditor = {
  mounted() {
    const el = this.el
    const toolbarEl = el.querySelector("[data-md-toolbar]")
    const editorEl = el.querySelector("[data-md-editor]")
    const previewEl = el.querySelector("[data-md-preview]")
    const hiddenInput = el.querySelector("[data-md-input]")
    const placeholderText = el.dataset.placeholder || "Write markdown..."
    const isDark = document.documentElement.dataset.theme === "dark"

    this._previewing = false

    // Build toolbar
    this._buildToolbar(toolbarEl)

    // CodeMirror extensions
    const extensions = [
      markdown({ codeLanguages: languages }),
      syntaxHighlighting(defaultHighlightStyle),
      bracketMatching(),
      history(),
      keymap.of([
        ...defaultKeymap,
        ...historyKeymap,
        indentWithTab,
        { key: "Mod-b", run: () => { this._wrapSelection("**", "**"); return true } },
        { key: "Mod-i", run: () => { this._wrapSelection("_", "_"); return true } },
      ]),
      cmPlaceholder(placeholderText),
      EditorView.lineWrapping,
      EditorView.updateListener.of((update) => {
        if (update.docChanged) {
          const val = update.state.doc.toString()
          hiddenInput.value = val
          hiddenInput.dispatchEvent(new Event("input", { bubbles: true }))
        }
      }),
      EditorView.theme({
        "&": { fontSize: "0.9375rem", minHeight: "200px" },
        ".cm-content": { fontFamily: "'JetBrains Mono', ui-monospace, monospace", lineHeight: "1.7", padding: "12px 16px" },
        ".cm-gutters": { display: "none" },
        ".cm-focused": { outline: "none" },
        "&.cm-editor": { background: "transparent" },
      }),
    ]

    if (isDark) extensions.push(oneDark)

    // Create editor
    this.view = new EditorView({
      state: EditorState.create({
        doc: hiddenInput.value || "",
        extensions,
      }),
      parent: editorEl,
    })

    // Watch theme changes
    this._themeObserver = new MutationObserver(() => {
      // Recreate on theme change (CodeMirror doesn't support dynamic theme swap easily)
    })
    this._themeObserver.observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] })
  },

  destroyed() {
    this.view?.destroy()
    this._themeObserver?.disconnect()
  },

  // ── Private ─────────────────────────────────────────────

  _buildToolbar(container) {
    TOOLBAR.forEach((group, gi) => {
      if (gi > 0) {
        const sep = document.createElement("div")
        sep.className = "re-toolbar-sep"
        container.appendChild(sep)
      }

      group.forEach(({ cmd, icon, label, wrap, prefix, template, insert, cursorOffset, action }) => {
        const btn = document.createElement("button")
        btn.type = "button"
        btn.className = "re-toolbar-btn"
        btn.title = label
        btn.setAttribute("aria-label", label)
        btn.dataset.cmd = cmd
        btn.innerHTML = `<span class="re-icon" style="font-size:12px;font-weight:600;font-family:ui-monospace,monospace">${icon}</span>`

        btn.addEventListener("mousedown", (e) => {
          e.preventDefault()
          if (action === "undo") { undo(this.view); return }
          if (action === "redo") { redo(this.view); return }
          if (action === "preview") { this._togglePreview(); return }
          if (wrap) this._wrapSelection(wrap[0], wrap[1])
          else if (prefix) this._prefixLine(prefix)
          else if (template) this._insertTemplate(template)
          else if (insert) this._insertText(insert, cursorOffset)
        })

        container.appendChild(btn)
      })
    })
  },

  _wrapSelection(before, after) {
    const view = this.view
    const { from, to } = view.state.selection.main
    const selected = view.state.doc.sliceString(from, to)
    const replacement = before + (selected || "text") + after
    view.dispatch({
      changes: { from, to, insert: replacement },
      selection: { anchor: from + before.length, head: from + replacement.length - after.length },
    })
    view.focus()
  },

  _prefixLine(prefix) {
    const view = this.view
    const { from } = view.state.selection.main
    const line = view.state.doc.lineAt(from)
    view.dispatch({
      changes: { from: line.from, to: line.from, insert: prefix },
    })
    view.focus()
  },

  _insertTemplate(template) {
    const view = this.view
    const { from, to } = view.state.selection.main
    const selected = view.state.doc.sliceString(from, to)
    const text = selected ? template.replace("text", selected) : template
    view.dispatch({
      changes: { from, to, insert: text },
      selection: { anchor: from + text.length },
    })
    view.focus()
  },

  _insertText(text, cursorOffset) {
    const view = this.view
    const { from } = view.state.selection.main
    view.dispatch({
      changes: { from, insert: text },
      selection: { anchor: from + text.length + (cursorOffset || 0) },
    })
    view.focus()
  },

  _togglePreview() {
    const el = this.el
    const editorEl = el.querySelector("[data-md-editor]")
    const previewEl = el.querySelector("[data-md-preview]")
    const hiddenInput = el.querySelector("[data-md-input]")

    this._previewing = !this._previewing

    if (this._previewing) {
      editorEl.style.display = "none"
      previewEl.style.display = "block"
      // Simple markdown to HTML (basic conversion)
      const md = hiddenInput.value
      previewEl.innerHTML = this._renderMarkdown(md)
    } else {
      editorEl.style.display = "block"
      previewEl.style.display = "none"
      this.view.focus()
    }

    // Toggle preview button style
    const previewBtn = el.querySelector('[data-cmd="preview"]')
    if (previewBtn) previewBtn.classList.toggle("re-toolbar-btn--active", this._previewing)
  },

  _renderMarkdown(md) {
    // Basic markdown rendering — handles common patterns
    let html = md
      .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
      // Headings
      .replace(/^### (.+)$/gm, "<h3>$1</h3>")
      .replace(/^## (.+)$/gm, "<h2>$1</h2>")
      .replace(/^# (.+)$/gm, "<h1>$1</h1>")
      // Bold/Italic
      .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
      .replace(/\*(.+?)\*/g, "<em>$1</em>")
      .replace(/_(.+?)_/g, "<em>$1</em>")
      // Strikethrough
      .replace(/~~(.+?)~~/g, "<del>$1</del>")
      // Code
      .replace(/`([^`]+)`/g, "<code>$1</code>")
      // Links
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
      // Images
      .replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1" style="max-width:100%;border-radius:8px">')
      // Blockquote
      .replace(/^&gt; (.+)$/gm, "<blockquote>$1</blockquote>")
      // HR
      .replace(/^---$/gm, "<hr>")
      // Lists
      .replace(/^- (.+)$/gm, "<li>$1</li>")
      .replace(/^(\d+)\. (.+)$/gm, "<li>$2</li>")
      // Paragraphs
      .replace(/\n\n/g, "</p><p>")

    return `<div class="re-preview-content"><p>${html}</p></div>`
  },
}

export default MarkdownEditor
