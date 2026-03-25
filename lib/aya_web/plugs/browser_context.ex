defmodule AyaWeb.Plugs.BrowserContext do
  @moduledoc """
  Extracts browser context from the HTTP request and client-side JS.

  Two-phase data collection:

  1. **HTTP phase** (Plug) — parses the User-Agent header on every request.
     Available immediately on first render, before WebSocket connects.
  2. **JS phase** (LiveSocket params) — sends rich client-side data (timezone,
     viewport, touch, locale, etc.) when the LiveView WebSocket connects.

  `from_socket/1` merges both phases into a single map.

  ## Available Data

  | Key                  | Source    | Type      | Example                |
  |----------------------|-----------|-----------|------------------------|
  | `user_agent`         | HTTP + JS | string    | full UA string         |
  | `mobile`             | HTTP UA   | boolean   | `true`                 |
  | `bot`                | HTTP UA   | boolean   | `false`                |
  | `bot_type`           | HTTP UA   | string/nil| `"search"`, `"ai"`, `nil` |
  | `browser`            | HTTP UA   | string    | `"Chrome"`, `"Safari"` |
  | `os`                 | HTTP UA   | string    | `"macOS"`, `"iOS"`     |
  | `timezone`           | JS Intl   | string    | `"Asia/Hong_Kong"`     |
  | `locale`             | JS nav    | string    | `"en-US"`              |
  | `viewport_width`     | JS window | integer   | `390`                  |
  | `viewport_height`    | JS window | integer   | `844`                  |
  | `device_pixel_ratio` | JS window | float     | `3.0`                  |
  | `platform`           | JS nav    | string    | `"macOS"`, `"Win32"`   |
  | `touch`              | JS detect | boolean   | `true`                 |
  | `online`             | JS nav    | boolean   | `true`                 |
  | `color_scheme`       | JS media  | string    | `"dark"`, `"light"`    |
  | `reduced_motion`     | JS media  | boolean   | `false`                |
  | `connection`         | JS net    | string    | `"4g"`, `"3g"`, `nil`  |

  ## Usage in LiveView

      def mount(_params, _session, socket) do
        browser = AyaWeb.Plugs.BrowserContext.from_socket(socket)

        socket =
          socket
          |> assign(:browser, browser)
          |> assign(:timezone, browser.timezone)

        {:ok, socket}
      end

  On the **static render** (before WebSocket), only HTTP-level fields are
  available (`user_agent`, `mobile`, `bot`, `browser`, `os`). JS fields
  are `nil`. Once the WebSocket connects and `mount/3` runs again with
  `connected?(socket) == true`, all fields are populated.

  ## Usage in regular controllers

      def show(conn, _params) do
        browser = conn.assigns[:browser_context]
        # browser.mobile => true
        # browser.browser => "Chrome"
      end

  ## Common patterns

      # Show timezone-aware timestamps (Elixir built-in, NOT Timex)
      DateTime.shift_zone!(datetime, browser.timezone)

      # Responsive server-side rendering
      if browser.mobile, do: render_compact(assigns), else: render_full(assigns)

      # Skip animations for users who prefer reduced motion
      if browser.reduced_motion, do: "duration-0", else: "duration-300"

      # Detect slow connections
      if browser.connection in ["slow-2g", "2g"], do: load_lite_version()

      # Bot detection for SEO
      if browser.bot, do: render_static_seo(assigns)

  ## Bot Detection

  `bot` is a boolean. `bot_type` categorizes the bot:

  | `bot_type`   | Detects                          | Examples                                   |
  |--------------|----------------------------------|--------------------------------------------|
  | `"search"`   | Search engine crawlers            | Googlebot, Bingbot, DuckDuckBot, Yandex    |
  | `"social"`   | Social media preview crawlers     | Facebook, Twitter, LinkedIn, Slack, Discord |
  | `"ai"`       | AI/LLM scrapers & training bots   | GPTBot, ClaudeBot, CCBot, PerplexityBot    |
  | `"monitor"`  | Uptime/health checks              | UptimeRobot, Pingdom, Datadog, NewRelic    |
  | `"headless"` | Headless browsers & automation    | HeadlessChrome, Puppeteer, Playwright      |
  | `"feed"`     | RSS/Atom feed readers             | Feedly, Feedbin, NewsBlur, Inoreader       |
  | `"other"`    | Generic bots (catch-all)          | Anything with "bot", "crawl", "spider"     |
  | `nil`        | Real browser — not a bot          |                                            |

      # Block AI scrapers
      if browser.bot_type == "ai", do: send_resp(conn, 403, "")

      # Serve static HTML to search engines
      if browser.bot_type == "search", do: render_seo_page(assigns)

      # Skip analytics for monitors
      if browser.bot_type == "monitor", do: skip_analytics()

      # Rate-limit headless browsers
      if browser.bot_type == "headless", do: apply_strict_rate_limit()

      # Allow social crawlers (for link previews) but log them
      if browser.bot_type == "social", do: log_social_preview(conn)
  """

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    ua = get_req_header(conn, "user-agent") |> List.first() || ""

    bot_info = detect_bot(ua)

    context = %{
      user_agent: ua,
      mobile: mobile?(ua),
      bot: bot_info != nil,
      bot_type: bot_info,
      browser: parse_browser(ua),
      os: parse_os(ua)
    }

    conn
    |> assign(:browser_context, context)
    |> put_session(:browser_context, context)
  end

  @doc """
  Builds a comprehensive browser context map from a LiveView socket.

  Merges HTTP-level data (from the session) with client-side JS data
  (from `get_connect_params/1`). Call this in `mount/3`.
  """
  def from_socket(socket) do
    # Only available during WebSocket connect, not static render
    session_ctx =
      if Phoenix.LiveView.connected?(socket),
        do: Phoenix.LiveView.get_connect_info(socket, :session),
        else: nil

    js_params =
      if Phoenix.LiveView.connected?(socket),
        do: Phoenix.LiveView.get_connect_params(socket) || %{},
        else: %{}

    # HTTP-level context from the plug (via session)
    http_ctx =
      case session_ctx do
        %{"browser_context" => ctx} when is_map(ctx) -> ctx
        _ -> %{}
      end

    # Client-side context from JS params
    js_ctx = %{
      timezone: js_params["timezone"],
      locale: js_params["locale"],
      viewport_width: js_params["viewport_width"],
      viewport_height: js_params["viewport_height"],
      device_pixel_ratio: js_params["device_pixel_ratio"],
      platform: js_params["platform"],
      touch: js_params["touch"] == true,
      online: js_params["online"] != false,
      color_scheme: js_params["color_scheme"],
      reduced_motion: js_params["reduced_motion"] == true,
      connection: js_params["connection"]
    }

    # Merge: JS params override HTTP-level where both exist
    Map.merge(http_ctx, js_ctx)
  end

  # ── User-Agent Parsing (lightweight, no deps) ──────────────

  defp mobile?(ua) do
    Regex.match?(~r/Mobile|Android|iPhone|iPad|iPod|webOS|BlackBerry|Opera Mini|IEMobile/i, ua)
  end

  @doc """
  Detects if the User-Agent is a bot and returns its category.

  Returns `nil` for real browsers, or one of:
  - `"search"` — search engine crawlers (Googlebot, Bingbot, Yandex, etc.)
  - `"social"` — social media preview crawlers (Facebook, Twitter, LinkedIn, etc.)
  - `"ai"` — AI scrapers and LLM training bots (GPTBot, ClaudeBot, CCBot, etc.)
  - `"monitor"` — uptime monitors, health checks (UptimeRobot, Pingdom, etc.)
  - `"headless"` — headless browsers, automation tools (Puppeteer, Playwright, etc.)
  - `"feed"` — RSS/Atom feed readers (Feedly, Feedbin, etc.)
  - `"other"` — generic bots matching common bot patterns
  """
  def detect_bot(ua) do
    cond do
      # Search engine crawlers
      Regex.match?(
        ~r/Googlebot|Google-Extended|Bingbot|Slurp|DuckDuckBot|Baiduspider|YandexBot|Sogou|Applebot/i,
        ua
      ) ->
        "search"

      # Social media preview crawlers
      Regex.match?(
        ~r/facebookexternalhit|Facebot|Twitterbot|LinkedInBot|Pinterest|WhatsApp|Slackbot|TelegramBot|Discordbot/i,
        ua
      ) ->
        "social"

      # AI scrapers and LLM training bots
      Regex.match?(
        ~r/GPTBot|ChatGPT|ClaudeBot|Claude-Web|anthropic-ai|Amazonbot|Bytespider|CCBot|cohere-ai|Diffbot|Google-Extended|Meta-ExternalAgent|PerplexityBot|YouBot/i,
        ua
      ) ->
        "ai"

      # Uptime monitors and health checks
      Regex.match?(
        ~r/UptimeRobot|Pingdom|StatusCake|Site24x7|Datadog|NewRelicPinger|Checkly|BetterUptime/i,
        ua
      ) ->
        "monitor"

      # Headless browsers and automation
      Regex.match?(~r/HeadlessChrome|PhantomJS|Puppeteer|Playwright|Selenium|webdriver|PTST/i, ua) ->
        "headless"

      # RSS/Atom feed readers
      Regex.match?(~r/Feedly|Feedbin|NewsBlur|Inoreader|FreshRSS|Tiny Tiny RSS|feedparser/i, ua) ->
        "feed"

      # Generic bot patterns (catch-all)
      Regex.match?(~r/bot|crawl|spider|scrape|fetch|scan|check|monitor|preview/i, ua) ->
        "other"

      # Not a bot
      true ->
        nil
    end
  end

  defp parse_browser(ua) do
    cond do
      String.contains?(ua, "Firefox") -> "Firefox"
      String.contains?(ua, "Edg/") -> "Edge"
      String.contains?(ua, "OPR/") or String.contains?(ua, "Opera") -> "Opera"
      String.contains?(ua, "Chrome") -> "Chrome"
      String.contains?(ua, "Safari") -> "Safari"
      true -> "Unknown"
    end
  end

  defp parse_os(ua) do
    cond do
      String.contains?(ua, "Windows") -> "Windows"
      String.contains?(ua, "Mac OS") -> "macOS"
      String.contains?(ua, "Android") -> "Android"
      String.contains?(ua, "iPhone") or String.contains?(ua, "iPad") -> "iOS"
      String.contains?(ua, "Linux") -> "Linux"
      true -> "Unknown"
    end
  end
end
