defmodule AyaWeb.UI.ImageField do
  @moduledoc """
  Drop-in image upload + processing + preview field.

  Combines file picker, progress, processing state, and final image display
  into a single component. Powered by `OmImage.Result` for image data.

  ## States

  - `idle` — shows upload zone (file picker)
  - `uploading` — shows upload progress bar
  - `processing` — shows processing shimmer/spinner
  - `ready` — shows the final image with full srcset + placeholders
  - `error` — shows error message with retry option

  ## Examples

      <%-- Basic usage with LiveView uploads --%>
      <.image_field
        upload={@uploads.photo}
        result={@image_result}
        status={@image_status}
        alt="Recipe photo"
      />

      <%-- With aspect ratio and custom empty state --%>
      <.image_field
        upload={@uploads.photo}
        result={@image_result}
        status={@image_status}
        alt="Recipe photo"
        aspect="16/9"
        rounded="rounded-xl"
      >
        <:empty>
          <p class="text-sm text-muted">Drag and drop your recipe photo here</p>
        </:empty>
      </.image_field>

      <%-- With OmImage.Result props --%>
      <.image_field
        upload={@uploads.photo}
        result={@image_result}
        status={@image_status}
        alt="Recipe photo"
        url_fn={&cdn_url/1}
      />
  """

  use Phoenix.Component

  import AyaWeb.UI.Image
  import AyaWeb.UI.Loading
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :upload, :any, default: nil, doc: "Phoenix LiveView upload config"
  attr :result, :any, default: nil, doc: "OmImage.Result struct"
  attr :status, :string, default: "idle", values: ~w(idle uploading processing ready error)
  attr :error_message, :string, default: nil, doc: "error message to display"
  attr :alt, :string, default: ""
  attr :aspect, :string, default: nil, doc: "aspect ratio e.g. '16/9', '4/3'"
  attr :rounded, :string, default: "rounded-lg"
  attr :url_fn, :any, default: nil, doc: "function to transform S3 URIs to public URLs"
  attr :variant, :atom, default: :medium, doc: "default src variant"
  attr :format, :atom, default: :jpeg, doc: "preferred image format"
  attr :compact, :boolean, default: false, doc: "compact upload zone"
  attr :removable, :boolean, default: true, doc: "show remove button when ready"
  attr :class, :any, default: nil

  slot :empty, doc: "custom content for empty/idle state"

  def image_field(assigns) do
    props = build_image_props(assigns.result, assigns)
    progress = upload_progress(assigns.upload)

    assigns =
      assign(assigns,
        props: props,
        progress: progress
      )

    ~H"""
    <div class={["image-field relative", @rounded, @class]}>
      <!-- Idle: upload zone -->
      <div :if={@status == "idle" && @upload} class="image-field__idle">
        <%= if @empty != [] do %>
          <label
            class={[
              "image-field__dropzone flex flex-col items-center justify-center cursor-pointer",
              "border-2 border-dashed border-border hover:border-primary/50 transition-colors",
              @rounded
            ]}
            style={@aspect && "aspect-ratio: #{@aspect}"}
            phx-drop-target={@upload.ref}
          >
            {render_slot(@empty)}
            <.live_file_input upload={@upload} class="sr-only" />
          </label>
        <% else %>
          <label
            class={[
              "image-field__dropzone flex flex-col items-center justify-center gap-2 cursor-pointer p-6",
              "border-2 border-dashed border-border hover:border-primary/50 bg-surface-alt/50 transition-colors",
              @rounded
            ]}
            style={@aspect && "aspect-ratio: #{@aspect}"}
            phx-drop-target={@upload.ref}
          >
            <.icon name="hero-photo" class="w-8 h-8 text-muted" />
            <span class="text-sm text-muted">
              Drop an image here or <span class="text-primary font-medium">browse</span>
            </span>
            <.live_file_input upload={@upload} class="sr-only" />
          </label>
        <% end %>
      </div>
      
    <!-- Uploading: progress bar -->
      <div
        :if={@status == "uploading"}
        class={[
          "image-field__uploading flex flex-col items-center justify-center bg-surface-alt",
          @rounded
        ]}
        style={@aspect && "aspect-ratio: #{@aspect}"}
      >
        <div class="w-full max-w-48 px-4">
          <.loading type="bar" text={"Uploading #{@progress}%..."} />
        </div>
      </div>
      
    <!-- Processing: shimmer -->
      <div
        :if={@status == "processing"}
        class={[
          "image-field__processing flex flex-col items-center justify-center bg-surface-alt",
          @rounded
        ]}
        style={@aspect && "aspect-ratio: #{@aspect}"}
      >
        <.loading type="shimmer" text="Processing image..." />
      </div>
      
    <!-- Ready: actual image -->
      <div :if={@status == "ready" && @props} class="image-field__ready relative group">
        <.image
          src={@props.src}
          alt={@alt}
          width={@props[:width]}
          height={@props[:height]}
          srcset={@props[:srcset]}
          placeholder={@props[:placeholder]}
          lqip={@props[:lqip]}
          color={@props[:color]}
          rounded={@rounded}
          aspect={@aspect}
        >
          <:source
            :for={s <- @props[:sources] || []}
            srcset={s.srcset}
            type={s.type}
          />
        </.image>

        <button
          :if={@removable}
          type="button"
          phx-click="remove_image"
          class={[
            "absolute top-2 right-2 p-1.5 rounded-full",
            "bg-black/60 text-white opacity-0 group-hover:opacity-100",
            "transition-opacity duration-150 hover:bg-black/80"
          ]}
          aria-label="Remove image"
        >
          <.icon name="hero-x-mark" class="w-4 h-4" />
        </button>
      </div>
      
    <!-- Error: retry -->
      <div
        :if={@status == "error"}
        class={[
          "image-field__error flex flex-col items-center justify-center gap-2 bg-surface-alt p-6",
          @rounded
        ]}
        style={@aspect && "aspect-ratio: #{@aspect}"}
      >
        <.icon name="hero-exclamation-triangle" class="w-8 h-8 text-danger" />
        <p class="text-sm text-danger">{@error_message || "Failed to process image"}</p>
        <button
          :if={@upload}
          type="button"
          phx-click="retry_upload"
          class="text-sm text-primary hover:underline"
        >
          Try again
        </button>
      </div>
    </div>
    """
  end

  defp build_image_props(nil, _assigns), do: nil

  defp build_image_props(result, assigns) do
    opts = [variant: assigns.variant, format: assigns.format]
    opts = if assigns.url_fn, do: Keyword.put(opts, :url_fn, assigns.url_fn), else: opts

    if Code.ensure_loaded?(OmImage.Result) do
      props = apply(OmImage.Result, :props, [result, opts])
      sources = apply(OmImage.Result, :picture_sources, [result, opts])
      Map.put(props, :sources, sources)
    else
      %{
        src: Map.get(result, :src) || Map.get(result, :original),
        width: Map.get(result, :width),
        height: Map.get(result, :height)
      }
    end
  end

  defp upload_progress(nil), do: 0

  defp upload_progress(upload) do
    case upload.entries do
      [] ->
        0

      entries ->
        total = Enum.reduce(entries, 0, &(&1.progress + &2))
        div(total, length(entries))
    end
  end
end
