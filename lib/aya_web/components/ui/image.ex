defmodule AyaWeb.UI.Image do
  @moduledoc """
  Performant image component with lazy loading, responsive srcset,
  placeholder strategies, and smooth reveal animation.

  ## Features

  - Native lazy loading (`loading="lazy"`)
  - `fetchpriority="high"` for above-the-fold images
  - Responsive `srcset` + `sizes` for serving optimal resolution
  - `<picture>` with WebP/AVIF source sets
  - Aspect ratio container (prevents layout shift)
  - Placeholder strategies: color, gradient, blurhash, thumbhash, splathash, lqip
  - Smooth blur-to-clear reveal on load
  - `decoding="async"` for non-blocking decode
  - Explicit `width`/`height` for CLS prevention

  ## Examples

      <%-- Basic --%>
      <.image src="/images/bread.jpg" alt="Sourdough bread" width={800} height={600} />

      <%-- Responsive --%>
      <.image
        src="/images/bread.jpg"
        srcset="/images/bread-400.jpg 400w, /images/bread-800.jpg 800w"
        sizes="(max-width: 640px) 100vw, 50vw"
        alt="Bread"
        width={800} height={600}
      />

      <%-- With color placeholder --%>
      <.image src="/images/bread.jpg" alt="Bread" placeholder="color" color="#d4a574" width={800} height={600} />

      <%-- With gradient placeholder --%>
      <.image src="/images/bread.jpg" alt="Bread" placeholder="gradient"
        gradient="linear-gradient(135deg, #d4a574 0%, #8b6f47 100%)" width={800} height={600} />

      <%-- With LQIP (low quality image placeholder) --%>
      <.image src="/images/bread.jpg" alt="Bread" placeholder="lqip"
        lqip="data:image/jpeg;base64,/9j/4AAQ..." width={800} height={600} />

      <%-- Above the fold (eager load, high priority) --%>
      <.image src="/images/hero.jpg" alt="Hero" priority width={1200} height={600} />

      <%-- With picture sources (AVIF + WebP + fallback) --%>
      <.image src="/images/bread.jpg" alt="Bread" width={800} height={600}>
        <:source srcset="/images/bread.avif" type="image/avif" />
        <:source srcset="/images/bread.webp" type="image/webp" />
      </.image>
  """

  use Phoenix.Component

  attr :src, :string, required: true
  attr :alt, :string, required: true
  attr :width, :integer, default: nil
  attr :height, :integer, default: nil
  attr :srcset, :string, default: nil
  attr :sizes, :string, default: nil

  attr :priority, :boolean,
    default: false,
    doc: "eager load + fetchpriority high (above-the-fold)"

  attr :placeholder, :string, default: nil, values: [nil, "color", "gradient", "lqip", "shimmer"]
  attr :color, :string, default: nil, doc: "dominant color for placeholder='color'"
  attr :gradient, :string, default: nil, doc: "CSS gradient for placeholder='gradient'"
  attr :lqip, :string, default: nil, doc: "data URI for low-quality image placeholder"
  attr :reveal, :boolean, default: true, doc: "animate blur-to-clear on load"
  attr :rounded, :string, default: nil, doc: "Tailwind border-radius class"
  attr :aspect, :string, default: nil, doc: "aspect ratio e.g. '16/9', '4/3', '1/1'"
  attr :object_fit, :string, default: "cover", values: ~w(cover contain fill none)
  attr :class, :any, default: nil
  attr :rest, :global

  slot :source, doc: "picture source elements for AVIF/WebP" do
    attr :srcset, :string, required: true
    attr :type, :string, required: true
    attr :sizes, :string
    attr :media, :string
  end

  def image(assigns) do
    has_sources = assigns.source != []
    aspect_style = if assigns.aspect, do: "aspect-ratio: #{assigns.aspect}"
    placeholder_style = placeholder_bg(assigns)

    assigns =
      assign(assigns,
        has_sources: has_sources,
        aspect_style: aspect_style,
        placeholder_style: placeholder_style,
        loading: if(assigns.priority, do: "eager", else: "lazy"),
        fetchpriority: if(assigns.priority, do: "high"),
        decoding: if(assigns.priority, do: "sync", else: "async")
      )

    ~H"""
    <div
      class={[
        "img-wrapper",
        @reveal && "img-wrapper--reveal",
        @placeholder && "img-wrapper--placeholder",
        @placeholder == "shimmer" && "img-wrapper--shimmer",
        @rounded,
        @class
      ]}
      style={Enum.join(Enum.filter([@aspect_style, @placeholder_style], & &1), "; ")}
      {@rest}
    >
      <%= if @has_sources do %>
        <picture>
          <source
            :for={s <- @source}
            srcset={s.srcset}
            type={s.type}
            sizes={s[:sizes] || @sizes}
            media={s[:media]}
          />
          <img
            src={@src}
            alt={@alt}
            width={@width}
            height={@height}
            srcset={@srcset}
            sizes={@sizes}
            loading={@loading}
            fetchpriority={@fetchpriority}
            decoding={@decoding}
            class="img-el"
            onload="this.parentElement.parentElement.classList.add('img-loaded')"
          />
        </picture>
      <% else %>
        <img
          src={@src}
          alt={@alt}
          width={@width}
          height={@height}
          srcset={@srcset}
          sizes={@sizes}
          loading={@loading}
          fetchpriority={@fetchpriority}
          decoding={@decoding}
          class="img-el"
          onload="this.parentElement.classList.add('img-loaded')"
        />
      <% end %>
    </div>
    """
  end

  defp placeholder_bg(%{placeholder: "color", color: color}) when is_binary(color) do
    "background-color: #{color}"
  end

  defp placeholder_bg(%{placeholder: "gradient", gradient: gradient}) when is_binary(gradient) do
    "background: #{gradient}"
  end

  defp placeholder_bg(%{placeholder: "lqip", lqip: lqip}) when is_binary(lqip) do
    "background-image: url(#{lqip}); background-size: cover; background-position: center"
  end

  defp placeholder_bg(%{placeholder: "shimmer"}), do: nil
  defp placeholder_bg(_), do: nil
end
