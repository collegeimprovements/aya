defmodule Aya.Fixtures do
  @moduledoc """
  Shared test fixtures and factory functions.

  Provides simple functions to create test data. Each function returns
  the minimum viable data for a valid record. Override individual fields
  by passing a map.

  ## Usage

      import Aya.Fixtures

      test "creates article" do
        attrs = article_attrs(%{title: "Custom Title"})
        assert attrs.title == "Custom Title"
      end
  """

  @doc """
  Returns default attributes for a news article.
  """
  def article_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        title: "Test Article #{System.unique_integer([:positive])}",
        url: "https://example.com/article/#{System.unique_integer([:positive])}",
        summary: "A test article about food science.",
        published_at: DateTime.utc_now()
      },
      overrides
    )
  end

  @doc """
  Returns default attributes for a recipe.
  """
  def recipe_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        title: "Test Recipe #{System.unique_integer([:positive])}",
        description: "A delicious test recipe.",
        prep_time_minutes: 15,
        cook_time_minutes: 30,
        servings: 4
      },
      overrides
    )
  end

  @doc """
  Returns a sample RSS XML string for feed testing.
  """
  def rss_xml_fixture do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>Test Food Feed</title>
        <link>https://example.com</link>
        <description>Test feed for food news</description>
        <item>
          <title>New Food Discovery</title>
          <link>https://example.com/article/1</link>
          <description>Scientists discover new superfood.</description>
          <pubDate>Sat, 22 Mar 2026 10:00:00 GMT</pubDate>
        </item>
        <item>
          <title>Recipe of the Week</title>
          <link>https://example.com/article/2</link>
          <description>This week's featured recipe.</description>
          <pubDate>Fri, 21 Mar 2026 08:00:00 GMT</pubDate>
        </item>
      </channel>
    </rss>
    """
  end
end
