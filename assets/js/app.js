import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/aya"
import topbar from "../vendor/topbar"
import ECharts from "./hooks/echarts_hook"
import RichEditor from "./hooks/rich_editor_hook"
import MarkdownEditor from "./hooks/markdown_editor_hook"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {
    _csrf_token: csrfToken,
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    locale: navigator.language,
    user_agent: navigator.userAgent,
    viewport_width: window.innerWidth,
    viewport_height: window.innerHeight,
    device_pixel_ratio: window.devicePixelRatio,
    platform: navigator.userAgentData?.platform || navigator.platform,
    touch: "ontouchstart" in window || navigator.maxTouchPoints > 0,
    online: navigator.onLine,
    color_scheme: window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light",
    reduced_motion: window.matchMedia("(prefers-reduced-motion: reduce)").matches,
    connection: navigator.connection?.effectiveType,
  },
  hooks: {...colocatedHooks, ECharts, RichEditor, MarkdownEditor},
})

// ── Topbar (page loading progress) ──────────────────────────
// Uses CSS custom property so it matches the active theme
const primaryColor = getComputedStyle(document.documentElement)
  .getPropertyValue("--color-primary").trim() || "#c2410c"

topbar.config({barColors: {0: primaryColor}, shadowColor: "rgba(0, 0, 0, .15)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// ── LiveSocket connect ──────────────────────────────────────
liveSocket.connect()
window.liveSocket = liveSocket

// ── Global commandfor polyfill (event delegation) ───────────
// Single document listener handles ALL data-commandfor buttons.
// This is the primary mechanism — overlay hooks' bindInvokers is a fallback.
document.addEventListener("click", (e) => {
  const btn = e.target.closest("[data-commandfor]")
  if (!btn) return
  const dialog = document.getElementById(btn.dataset.commandfor)
  if (!dialog || typeof dialog.showModal !== "function") return
  const cmd = btn.dataset.command
  if (cmd === "show-modal" && !dialog.open) dialog.showModal()
  else if (cmd === "close" && dialog.open) dialog.close()
}, true) // capture phase — runs BEFORE per-element handlers

// ── System theme listener ───────────────────────────────────
// When user has "system" theme and OS preference changes, update immediately
const darkMediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
darkMediaQuery.addEventListener("change", () => {
  // Only react if user has "system" selected (no data-theme and no localStorage)
  if (!localStorage.getItem("phx:theme")) {
    document.documentElement.removeAttribute("data-theme")
  }
})

// ── Toast Manager (Sonner-style) ────────────────────────────
// Faithful port of sonner (github.com/emilkowalski/sonner) for vanilla JS
window.AyaToast = (() => {
  const GAP = 14
  const VISIBLE = 3
  const DEFAULT_DURATION = 4000
  const DISMISS_MS = 200

  let toasts = []   // { id, el, height, duration, remaining, timer, startTime, removed }
  let expanded = false
  let interacting = false
  let idCounter = 0

  const container = () => document.querySelector("[data-aya-toaster]")
  const isBottom = () => container()?.dataset.y === "bottom"
  const lift = () => isBottom() ? -1 : 1

  function addToast({ kind = "default", title, description, action_label, action_event, duration, position } = {}) {
    const c = container()
    if (!c) return

    // Allow per-toast position override (e.g. "bottom-center" → y="bottom", x="center")
    if (position) {
      const parts = position.split("-")
      if (parts.length === 2) { c.dataset.y = parts[0]; c.dataset.x = parts[1] }
    }

    const id = ++idCounter
    const containerDuration = parseInt(c.dataset.duration) || DEFAULT_DURATION
    const dur = duration ?? (kind === "error" || kind === "loading" ? 0 : containerDuration)

    const li = document.createElement("li")
    li.setAttribute("data-aya-toast", "")
    li.setAttribute("data-type", kind)
    li.setAttribute("data-y", isBottom() ? "bottom" : "top")
    li.setAttribute("data-mounted", "false")
    li.setAttribute("data-expanded", String(expanded))
    li.setAttribute("data-front", "true")
    li.setAttribute("role", "alert")
    li.tabIndex = 0

    // Close button (Sonner-style: circle at top-left edge)
    let closeHtml = `<button data-close-button aria-label="Close toast">
      <svg width="12" height="12" viewBox="0 0 16 16" fill="currentColor"><path d="M2.96967 2.96967C3.26256 2.67678 3.73744 2.67678 4.03033 2.96967L8 6.93934L11.9697 2.96967C12.2626 2.67678 12.7374 2.67678 13.0303 2.96967C13.3232 3.26256 13.3232 3.73744 13.0303 4.03033L9.06066 8L13.0303 11.9697C13.3232 12.2626 13.3232 12.7374 13.0303 13.0303C12.7374 13.3232 12.2626 13.3232 11.9697 13.0303L8 9.06066L4.03033 13.0303C3.73744 13.3232 3.26256 13.3232 2.96967 13.0303C2.67678 12.7374 2.67678 12.2626 2.96967 11.9697L6.93934 8L2.96967 4.03033C2.67678 3.73744 2.67678 3.26256 2.96967 2.96967Z"/></svg>
    </button>`

    li.innerHTML = `${closeHtml}
      <div data-content>
        ${title ? `<div data-title>${esc(title)}</div>` : ""}
        ${description ? `<div data-description>${esc(description)}</div>` : ""}
      </div>
      ${action_label ? `<button data-button data-action="${action_event || ""}">${esc(action_label)}</button>` : ""}`

    c.prepend(li)

    const toast = { id, el: li, height: 0, duration: dur, remaining: dur, timer: null, startTime: null, removed: false }
    toasts.unshift(toast)

    // Measure height after render
    requestAnimationFrame(() => {
      toast.height = li.offsetHeight
      li.style.setProperty("--initial-height", toast.height + "px")
      li.setAttribute("data-mounted", "true")
      layout()
      if (dur > 0) startTimer(toast)
    })

    // Close button
    li.querySelector("[data-close-button]").addEventListener("click", () => dismiss(toast))

    // Action button
    const actionBtn = li.querySelector("[data-button]")
    if (actionBtn) actionBtn.addEventListener("click", () => dismiss(toast))

    // Swipe
    initSwipe(toast)
  }

  function dismiss(toast) {
    if (toast.removed) return
    toast.removed = true
    if (toast.timer) clearTimeout(toast.timer)
    toast.el.setAttribute("data-removed", "true")

    setTimeout(() => {
      toast.el.remove()
      toasts = toasts.filter(t => t !== toast)
      layout()
    }, DISMISS_MS)
  }

  function layout() {
    const active = toasts.filter(t => !t.removed)
    const frontHeight = active[0]?.height || 0
    let heightBefore = 0

    active.forEach((t, i) => {
      const isFront = i === 0
      t.el.setAttribute("data-front", String(isFront))
      t.el.setAttribute("data-expanded", String(expanded))
      t.el.setAttribute("data-visible", String(i < VISIBLE))
      t.el.style.setProperty("--index", i)
      t.el.style.setProperty("--front-height", frontHeight + "px")
      t.el.style.setProperty("--offset", heightBefore + "px")
      t.el.style.setProperty("--stack-offset", (i * GAP) + "px")
      t.el.style.setProperty("--lift", lift())
      t.el.style.setProperty("--gap", GAP + "px")
      t.el.style.zIndex = active.length - i
      heightBefore += t.height + GAP
    })

    // Set container height for hover area
    const c = container()
    if (c) {
      const total = expanded ? heightBefore - GAP : frontHeight
      c.style.height = Math.max(total, 0) + "px"
    }
  }

  function startTimer(toast) {
    toast.startTime = Date.now()
    toast.timer = setTimeout(() => dismiss(toast), toast.remaining)
  }

  function pauseTimers() {
    for (const t of toasts) {
      if (t.timer) {
        clearTimeout(t.timer)
        t.remaining -= (Date.now() - t.startTime)
        t.timer = null
      }
    }
  }

  function resumeTimers() {
    for (const t of toasts) {
      if (t.remaining > 0 && !t.timer && !t.removed) startTimer(t)
    }
  }

  function setExpanded(val) {
    expanded = val
    layout()
  }

  function initSwipe(toast) {
    let startX = 0, startY = 0, swipeX = 0, swiping = false
    const el = toast.el
    el.addEventListener("pointerdown", (e) => {
      if (e.target.closest("button")) return
      interacting = true
      swiping = true
      startX = e.clientX; startY = e.clientY
      el.setAttribute("data-swiping", "true")
      el.setPointerCapture(e.pointerId)
    })
    el.addEventListener("pointermove", (e) => {
      if (!swiping) return
      swipeX = e.clientX - startX
      el.style.setProperty("--swipe-x", swipeX + "px")
      el.style.transform = `var(--y) translateX(${swipeX}px)`
      el.style.opacity = String(Math.max(0, 1 - Math.abs(swipeX) / el.offsetWidth))
    })
    const end = () => {
      if (!swiping) return
      swiping = false; interacting = false
      el.removeAttribute("data-swiping")
      if (Math.abs(swipeX) > 45) {
        el.style.setProperty("--swipe-exit", swipeX > 0 ? "100%" : "-100%")
        el.setAttribute("data-swipe-out", "true")
        el.addEventListener("animationend", () => dismiss(toast), { once: true })
      } else {
        el.style.transform = ""
        el.style.opacity = ""
      }
      swipeX = 0
    }
    el.addEventListener("pointerup", end)
    el.addEventListener("pointercancel", end)
  }

  // Hover: expand & pause
  document.addEventListener("mouseenter", (e) => {
    const c = e.target.closest?.("[data-aya-toaster]")
    if (c) { setExpanded(true); pauseTimers() }
  }, true)
  document.addEventListener("mouseleave", (e) => {
    const c = e.target.closest?.("[data-aya-toaster]")
    if (!c) return
    // Check if we're still inside
    const related = e.relatedTarget
    if (related && c.contains(related)) return
    if (!interacting) { setExpanded(false); resumeTimers() }
  }, true)

  // Flash bridge via MutationObserver
  const seen = new Set()
  function consumeFlash() {
    document.querySelectorAll("[data-toast-flash]").forEach(el => {
      const kind = el.dataset.toastFlash, msg = el.dataset.toastMessage
      const key = kind + ":" + msg
      if (kind && msg && !seen.has(key)) {
        seen.add(key); setTimeout(() => seen.delete(key), 1000)
        addToast({ kind, title: msg })
      }
      el.remove()
    })
  }
  new MutationObserver((muts) => {
    for (const m of muts) for (const n of m.addedNodes)
      if (n.nodeType === 1 && (n.dataset?.toastFlash || n.querySelector?.("[data-toast-flash]")))
        return requestAnimationFrame(consumeFlash)
  }).observe(document.body, { childList: true, subtree: true })
  consumeFlash()

  function esc(s) { const d = document.createElement("div"); d.textContent = s; return d.innerHTML }

  return { addToast }
})()

// ── Dev tools ───────────────────────────────────────────────
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    reloader.enableServerLogs()

    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}
