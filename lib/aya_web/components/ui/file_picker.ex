defmodule AyaWeb.UI.FilePicker do
  @moduledoc """
  Polished file picker with drag & drop, image previews, progress bars,
  and configurable constraints.

  Wraps Phoenix LiveView's built-in upload system. For S3 direct upload,
  configure `external` on `allow_upload/3`.

  ## Examples

      <%-- In mount: --%>
      socket = allow_upload(socket, :files,
        accept: ~w(.jpg .png .pdf),
        max_entries: 10,
        max_file_size: 10_000_000
      )

      <%-- In template: --%>
      <.file_picker upload={@uploads.files} />

      <%-- With custom constraints display: --%>
      <.file_picker
        upload={@uploads.files}
        max_file_size_mb={10}
        max_total_size_mb={50}
        subtitle="JPG, PNG, PDF up to 10MB each"
      />
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :upload, :any, required: true
  attr :title, :string, default: "Upload files"
  attr :subtitle, :string, default: nil
  attr :max_file_size_mb, :integer, default: 10
  attr :max_total_size_mb, :integer, default: 50
  attr :uploaded_files, :list, default: [], doc: "list of completed file maps for display"
  attr :compact, :boolean, default: false, doc: "compact mode for embedding in sheets"
  attr :class, :any, default: nil

  def file_picker(assigns) do
    total_size =
      Enum.reduce(assigns.upload.entries, 0, &(&1.client_size + &2)) +
        Enum.reduce(assigns.uploaded_files, 0, &(&1.size + &2))

    total_size_mb = Float.round(total_size / 1_000_000, 1)
    max_total = assigns.max_total_size_mb
    has_entries = assigns.upload.entries != [] || assigns.uploaded_files != []
    all_done = assigns.upload.entries == [] && assigns.uploaded_files != []

    assigns =
      assign(assigns,
        total_size_mb: total_size_mb,
        max_total: max_total,
        has_entries: has_entries,
        all_done: all_done,
        global_errors: upload_errors(assigns.upload)
      )

    ~H"""
    <div class={["fp", @compact && "fp--compact", @class]} phx-drop-target={@upload.ref}>
      <.live_file_input upload={@upload} class="sr-only" />

      <%!-- Drop zone --%>
      <label for={@upload.ref} class={["fp__zone", @has_entries && "fp__zone--small"]}>
        <div class="fp__zone-icon">
          <.icon name="hero-cloud-arrow-up" class={if @has_entries, do: "size-6", else: "size-10"} />
        </div>
        <div :if={!@has_entries}>
          <p class="fp__zone-title">{@title}</p>
          <p class="fp__zone-subtitle">{@subtitle || default_subtitle(@upload, @max_file_size_mb)}</p>
        </div>
        <span :if={@has_entries} class="fp__zone-add">Add more files</span>
      </label>

      <%!-- Global errors --%>
      <p :for={err <- @global_errors} class="fp__error mt-2">
        <.icon name="hero-exclamation-circle-mini" class="size-4 shrink-0" />
        {humanize_error(err)}
      </p>

      <%!-- File list --%>
      <div :if={@has_entries} class="fp__list">
        <div :for={entry <- @upload.entries} class="fp__entry">
          <%!-- Preview / icon --%>
          <div class="fp__preview">
            <.live_img_preview :if={image?(entry)} entry={entry} class="fp__thumb" />
            <div :if={!image?(entry)} class="fp__file-icon">
              <span class="fp__ext">{file_ext(entry)}</span>
            </div>
          </div>

          <%!-- Info --%>
          <div class="fp__info">
            <span class="fp__name">{entry.client_name}</span>
            <div class="fp__meta">
              <span class="fp__size">{format_size(entry.client_size)}</span>
              <span :if={entry.progress > 0 && entry.progress < 100} class="fp__pct">
                {entry.progress}%
              </span>
              <span :if={entry.done?} class="fp__done">
                <.icon name="hero-check-circle-mini" class="size-3.5" /> Done
              </span>
            </div>
            <%!-- Progress bar --%>
            <div :if={entry.progress > 0 && !entry.done?} class="fp__progress">
              <div class="fp__progress-fill" style={"width: #{entry.progress}%"} />
            </div>
            <%!-- Per-file errors --%>
            <p :for={err <- upload_errors(@upload, entry)} class="fp__entry-error">
              {humanize_error(err)}
            </p>
          </div>

          <%!-- Remove --%>
          <button
            type="button"
            phx-click="cancel_upload"
            phx-value-ref={entry.ref}
            class="fp__remove"
            aria-label={"Remove #{entry.client_name}"}
          >
            <.icon name="hero-x-mark-mini" class="size-4" />
          </button>
        </div>
      </div>

      <%!-- Completed files --%>
      <div :if={@uploaded_files != []} class={["fp__list", @upload.entries != [] && "mt-0"]}>
        <div :for={file <- @uploaded_files} class="fp__entry fp__entry--done">
          <div class="fp__preview">
            <div class="fp__file-icon fp__file-icon--done">
              <.icon name="hero-check" class="size-4 text-success" />
            </div>
          </div>
          <div class="fp__info">
            <span class="fp__name">{file.name}</span>
            <div class="fp__meta">
              <span class="fp__size">{format_size(file.size)}</span>
              <span class="fp__done">
                <.icon name="hero-check-circle-mini" class="size-3.5" /> Uploaded
              </span>
            </div>
          </div>
          <button
            type="button"
            phx-click="remove_uploaded_file"
            phx-value-ref={file.ref}
            class="fp__remove"
            aria-label={"Remove #{file.name}"}
          >
            <.icon name="hero-x-mark-mini" class="size-4" />
          </button>
        </div>
      </div>

      <%!-- Footer: total size --%>
      <div :if={@has_entries} class="fp__footer">
        <span class="fp__total">
          {length(@upload.entries) + length(@uploaded_files)} file{if length(@upload.entries) +
                                                                        length(@uploaded_files) != 1,
                                                                      do: "s"} · {@total_size_mb} MB
          <span :if={@max_total}> /  {@max_total} MB</span>
        </span>
      </div>
    </div>
    """
  end

  defp image?(entry), do: String.starts_with?(entry.client_type, "image/")

  defp file_ext(entry) do
    entry.client_name
    |> Path.extname()
    |> String.trim_leading(".")
    |> String.upcase()
    |> case do
      "" -> "FILE"
      ext -> ext
    end
  end

  defp format_size(bytes) when bytes < 1_000, do: "#{bytes} B"
  defp format_size(bytes) when bytes < 1_000_000, do: "#{Float.round(bytes / 1_000, 1)} KB"
  defp format_size(bytes), do: "#{Float.round(bytes / 1_000_000, 1)} MB"

  defp default_subtitle(upload, max_mb) do
    accept = upload.accept

    types =
      cond do
        is_list(accept) ->
          accept
          |> Enum.map(&(&1 |> String.trim_leading(".") |> String.upcase()))
          |> Enum.join(", ")

        is_binary(accept) ->
          accept
          |> String.split(",")
          |> Enum.map(&(&1 |> String.trim() |> String.trim_leading(".") |> String.upcase()))
          |> Enum.join(", ")

        true ->
          "All files"
      end

    "#{types} up to #{max_mb}MB each · Max #{upload.max_entries} files"
  end

  defp humanize_error(:too_large), do: "File is too large"
  defp humanize_error(:too_many_files), do: "Too many files"
  defp humanize_error(:not_accepted), do: "File type not accepted"
  defp humanize_error(err) when is_binary(err), do: err
  defp humanize_error(err), do: inspect(err)
end
