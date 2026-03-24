defmodule AyaWeb.SEO do
  @moduledoc """
  SEO and social sharing meta tag component.

  Renders Open Graph, Twitter Card, article metadata, canonical URL,
  and structured data (JSON-LD) in the `<head>`.

  ## Usage

  1. Set `:meta` assign in your LiveView or controller:

      def handle_params(%{"slug" => slug}, _uri, socket) do
        recipe = Recipes.get!(slug)
        {:noreply, assign(socket, meta: %{
          title: recipe.title,
          description: truncate(recipe.summary, 160),
          image: recipe.image_url,
          image_width: 1200,
          image_height: 630,
          url: url(~p"/recipes/\#{slug}"),
          type: "article",
          published_time: DateTime.to_iso8601(recipe.published_at),
          author: recipe.author_name
        })}
      end

  2. Render in root layout `<head>`:

      <AyaWeb.SEO.meta_tags meta={assigns[:meta]} canonical_url={assigns[:canonical_url]} />

  All fields are optional — sensible defaults are provided.
  """

  use Phoenix.Component

  @default_meta %{
    title: "Aya — Food & Science",
    description:
      "Latest food news, recipes, research papers, ingredients, reports, and market trends.",
    image: "/images/og-default.jpg",
    url: nil,
    type: "website",
    twitter_card: "summary_large_image",
    site_name: "Aya",
    locale: "en_US"
  }

  @doc """
  Renders all meta tags for SEO and social sharing.

  ## Attrs

  - `meta` — map of meta values (merged with defaults)
  - `canonical_url` — canonical URL for the page
  - `json_ld` — optional JSON-LD structured data map

  ## Supported meta keys

  | Key | Default | Description |
  |---|---|---|
  | `title` | "Aya — Food & Science" | Page title (og:title, twitter:title) |
  | `description` | App description | Page description (max ~160 chars) |
  | `image` | "/images/og-default.jpg" | Preview image URL (1200x630 recommended) |
  | `image_width` | — | Image width in px (helps platforms) |
  | `image_height` | — | Image height in px |
  | `image_alt` | Falls back to title | Alt text for preview image |
  | `url` | — | Canonical page URL (og:url) |
  | `type` | "website" | OG type: "website", "article", "profile" |
  | `twitter_card` | "summary_large_image" | Twitter card type |
  | `site_name` | "Aya" | Site name for og:site_name |
  | `locale` | "en_US" | OG locale |
  | `published_time` | — | ISO 8601 datetime (article type) |
  | `modified_time` | — | ISO 8601 datetime (article type) |
  | `author` | — | Author name (article type) |
  | `section` | — | Article section/category |
  | `tags` | — | List of tag strings (article type) |
  | `twitter_site` | — | Twitter @handle for the site |
  | `twitter_creator` | — | Twitter @handle for the author |
  """
  attr :meta, :map, default: %{}
  attr :canonical_url, :string, default: nil
  attr :json_ld, :map, default: nil

  def meta_tags(assigns) do
    meta = Map.merge(@default_meta, assigns.meta || %{})
    assigns = assign(assigns, :m, meta)

    ~H"""
    <%!-- Primary --%>
    <meta name="description" content={@m.description} />

    <%!-- Canonical --%>
    <link :if={@canonical_url} rel="canonical" href={@canonical_url} />

    <%!-- Open Graph (Facebook, WhatsApp, Telegram, LinkedIn, Discord, iMessage) --%>
    <meta property="og:type" content={@m.type} />
    <meta property="og:title" content={@m.title} />
    <meta property="og:description" content={@m.description} />
    <meta property="og:image" content={@m.image} />
    <meta :if={@m[:url]} property="og:url" content={@m.url} />
    <meta property="og:site_name" content={@m.site_name} />
    <meta property="og:locale" content={@m.locale} />

    <%!-- OG Image dimensions --%>
    <meta :if={@m[:image_width]} property="og:image:width" content={to_string(@m.image_width)} />
    <meta :if={@m[:image_height]} property="og:image:height" content={to_string(@m.image_height)} />
    <meta :if={@m[:image]} property="og:image:alt" content={@m[:image_alt] || @m.title} />

    <%!-- Twitter/X Card --%>
    <meta name="twitter:card" content={@m.twitter_card} />
    <meta name="twitter:title" content={@m.title} />
    <meta name="twitter:description" content={@m.description} />
    <meta name="twitter:image" content={@m.image} />
    <meta :if={@m[:twitter_site]} name="twitter:site" content={@m.twitter_site} />
    <meta :if={@m[:twitter_creator]} name="twitter:creator" content={@m.twitter_creator} />

    <%!-- Article metadata --%>
    <meta :if={@m[:published_time]} property="article:published_time" content={@m.published_time} />
    <meta :if={@m[:modified_time]} property="article:modified_time" content={@m.modified_time} />
    <meta :if={@m[:author]} property="article:author" content={@m.author} />
    <meta :if={@m[:section]} property="article:section" content={@m.section} />
    <meta :for={tag <- List.wrap(@m[:tags] || [])} property="article:tag" content={tag} />

    <%!-- Robots --%>
    <meta :if={@m[:noindex]} name="robots" content="noindex, nofollow" />

    <%!-- JSON-LD structured data --%>
    <script :if={@json_ld} type="application/ld+json">
      {Jason.encode!(@json_ld)}
    </script>
    """
  end

  @doc """
  Builds a JSON-LD Recipe structured data map.

  ## Example

      json_ld = AyaWeb.SEO.recipe_json_ld(%{
        name: "Sourdough Bread",
        description: "A classic artisan bread...",
        image: "/images/sourdough.jpg",
        author: "Alice Baker",
        prep_time: "PT30M",
        cook_time: "PT45M",
        total_time: "PT5H",
        servings: "1 loaf",
        ingredients: ["500g flour", "350ml water", "100g starter", "10g salt"],
        instructions: ["Mix flour and water", "Add starter and salt", "Bulk ferment"]
      })
  """
  def recipe_json_ld(recipe) do
    %{
      "@context" => "https://schema.org/",
      "@type" => "Recipe",
      "name" => recipe[:name],
      "description" => recipe[:description],
      "image" => recipe[:image] && [recipe[:image]],
      "author" => recipe[:author] && %{"@type" => "Person", "name" => recipe[:author]},
      "prepTime" => recipe[:prep_time],
      "cookTime" => recipe[:cook_time],
      "totalTime" => recipe[:total_time],
      "recipeYield" => recipe[:servings],
      "recipeIngredient" => recipe[:ingredients],
      "recipeInstructions" =>
        (recipe[:instructions] || [])
        |> Enum.with_index(1)
        |> Enum.map(fn {step, i} ->
          %{"@type" => "HowToStep", "position" => i, "text" => step}
        end)
    }
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end

  @doc """
  Builds a JSON-LD Article structured data map.
  """
  def article_json_ld(article) do
    %{
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => article[:title],
      "description" => article[:description],
      "image" => article[:image],
      "author" => article[:author] && %{"@type" => "Person", "name" => article[:author]},
      "datePublished" => article[:published_time],
      "dateModified" => article[:modified_time],
      "publisher" => %{
        "@type" => "Organization",
        "name" => "Aya",
        "logo" => %{"@type" => "ImageObject", "url" => "/images/logo.png"}
      }
    }
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end
end
