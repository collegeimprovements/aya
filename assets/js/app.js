import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/aya"
import topbar from "../vendor/topbar"
import ECharts from "./hooks/echarts_hook"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, ECharts},
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

// ── System theme listener ───────────────────────────────────
// When user has "system" theme and OS preference changes, update immediately
const darkMediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
darkMediaQuery.addEventListener("change", () => {
  // Only react if user has "system" selected (no data-theme and no localStorage)
  if (!localStorage.getItem("phx:theme")) {
    document.documentElement.removeAttribute("data-theme")
  }
})

// ── Flash auto-dismiss ──────────────────────────────────────
// Auto-dismiss info flashes after 5 seconds, errors stay until clicked
window.addEventListener("phx:page-loading-stop", () => {
  document.querySelectorAll("[data-auto-dismiss]").forEach(el => {
    const delay = parseInt(el.dataset.autoDismiss || "5000", 10)
    setTimeout(() => {
      el.classList.add("flash-exit")
      el.addEventListener("animationend", () => el.remove(), {once: true})
    }, delay)
  })
})

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
