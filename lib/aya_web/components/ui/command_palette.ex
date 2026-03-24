defmodule AyaWeb.UI.CommandPalette do
  @moduledoc """
  Cmd+K spotlight search and command palette.

  ## Examples

      <.command_palette id="cmd-palette">
        <:group label="Navigation">
          <:item icon="hero-home" label="Home" navigate={~p"/"} shortcut="⌘H" />
          <:item icon="hero-beaker" label="Recipes" navigate={~p"/recipes"} shortcut="⌘R" />
          <:item icon="hero-newspaper" label="News" navigate={~p"/news"} />
        </:group>
        <:group label="Actions">
          <:item icon="hero-plus" label="New Recipe" event="new_recipe" shortcut="⌘N" />
          <:item icon="hero-cog-6-tooth" label="Settings" navigate={~p"/settings"} />
        </:group>
      </.command_palette>
  """

  use Phoenix.Component
  import AyaWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, default: "command-palette"
  attr :placeholder, :string, default: "Type a command or search..."
  attr :class, :any, default: nil

  slot :group do
    attr :label, :string
  end

  slot :item do
    attr :icon, :string
    attr :label, :string, required: true
    attr :shortcut, :string
    attr :navigate, :string
    attr :patch, :string
    attr :event, :string
  end

  def command_palette(assigns) do
    ~H"""
    <dialog
      id={@id}
      phx-hook=".CommandPalette"
      class={["command-palette", @class]}
      data-placeholder={@placeholder}
    >
      <div class="command-palette__surface">
        <div class="command-palette__search">
          <.icon name="hero-magnifying-glass" class="size-5 text-text-muted shrink-0" />
          <input
            type="text"
            class="command-palette__input"
            placeholder={@placeholder}
            autocomplete="off"
            spellcheck="false"
            aria-label="Search commands"
          />
          <kbd class="hidden sm:inline-flex items-center rounded border border-border bg-surface-alt px-1.5 py-0.5 text-[0.65rem] font-mono text-text-muted">
            esc
          </kbd>
        </div>
        <div class="command-palette__results" role="listbox">
          <div :for={group <- @group} class="command-palette__group" data-group-label={group[:label]}>
            <div :if={group[:label]} class="command-palette__group-label">
              {group[:label]}
            </div>
            {render_slot(group)}
          </div>
          <%= for item <- @item do %>
            <.command_item {extract_item_attrs(item)} />
          <% end %>
          <div class="command-palette__empty hidden">
            <p class="py-6 text-center text-sm text-text-muted">No results found.</p>
          </div>
        </div>
      </div>
    </dialog>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".CommandPalette">
      export default {
        mounted() {
          const dialog = this.el;
          const input = dialog.querySelector(".command-palette__input");
          const results = dialog.querySelector(".command-palette__results");
          const empty = dialog.querySelector(".command-palette__empty");
          let highlighted = -1;

          // Global Cmd+K / Ctrl+K listener
          document.addEventListener("keydown", (e) => {
            if ((e.metaKey || e.ctrlKey) && e.key === "k") {
              e.preventDefault();
              if (dialog.open) {
                dialog.close();
              } else {
                dialog.showModal();
                input.value = "";
                input.focus();
                this.filterItems("");
                highlighted = -1;
              }
            }
          });

          // Filter on input
          input.addEventListener("input", () => {
            this.filterItems(input.value);
            highlighted = -1;
            this.updateHighlight();
          });

          // Keyboard navigation
          input.addEventListener("keydown", (e) => {
            const items = this.getVisibleItems();
            if (e.key === "ArrowDown") {
              e.preventDefault();
              highlighted = Math.min(highlighted + 1, items.length - 1);
              this.updateHighlight();
            } else if (e.key === "ArrowUp") {
              e.preventDefault();
              highlighted = Math.max(highlighted - 1, 0);
              this.updateHighlight();
            } else if (e.key === "Enter" && highlighted >= 0) {
              e.preventDefault();
              items[highlighted]?.click();
            }
          });

          // Close on backdrop click
          dialog.addEventListener("click", (e) => {
            if (e.target === dialog) dialog.close();
          });

          // Scroll lock
          const observer = new MutationObserver(() => {
            document.documentElement.style.overflow = dialog.open ? "hidden" : "";
          });
          observer.observe(dialog, { attributes: true, attributeFilter: ["open"] });
          this._observer = observer;
        },

        filterItems(query) {
          const results = this.el.querySelector(".command-palette__results");
          const empty = this.el.querySelector(".command-palette__empty");
          const q = query.toLowerCase().trim();
          let visibleCount = 0;

          // Filter items
          results.querySelectorAll("[data-command-item]").forEach(item => {
            const label = (item.dataset.commandLabel || "").toLowerCase();
            const match = !q || label.includes(q) || this.fuzzyMatch(q, label);
            item.hidden = !match;
            if (match) visibleCount++;
          });

          // Hide empty groups
          results.querySelectorAll(".command-palette__group").forEach(group => {
            const hasVisible = group.querySelector("[data-command-item]:not([hidden])");
            group.hidden = !hasVisible;
          });

          // Show/hide empty state
          if (empty) {
            empty.classList.toggle("hidden", visibleCount > 0 || !q);
          }
        },

        fuzzyMatch(query, text) {
          let qi = 0;
          for (let ti = 0; ti < text.length && qi < query.length; ti++) {
            if (text[ti] === query[qi]) qi++;
          }
          return qi === query.length;
        },

        getVisibleItems() {
          return Array.from(this.el.querySelectorAll("[data-command-item]:not([hidden])"));
        },

        updateHighlight() {
          const items = this.getVisibleItems();
          items.forEach((item, i) => {
            item.setAttribute("data-highlighted", i === this.highlighted ? "" : null);
            if (i === this.highlighted) {
              item.classList.add("command-palette__item--highlighted");
              item.scrollIntoView({ block: "nearest" });
            } else {
              item.classList.remove("command-palette__item--highlighted");
            }
          });
          // Store highlighted for access in keydown
          this.highlighted = items.length > 0 ? Math.max(0, Math.min(this.highlighted || 0, items.length - 1)) : -1;
        },

        destroyed() {
          if (this._observer) this._observer.disconnect();
          document.documentElement.style.overflow = "";
        }
      }
    </script>
    """
  end

  defp command_item(assigns) do
    ~H"""
    <%= if @navigate do %>
      <.link
        navigate={@navigate}
        class="command-palette__item"
        role="option"
        data-command-item
        data-command-label={@label}
      >
        <.icon :if={@icon} name={@icon} class="size-4 text-text-muted shrink-0" />
        <span class="flex-1 truncate">{@label}</span>
        <kbd :if={@shortcut} class="text-[0.65rem] font-mono text-text-muted">{@shortcut}</kbd>
      </.link>
    <% else %>
      <button
        type="button"
        class="command-palette__item"
        role="option"
        phx-click={@event}
        data-command-item
        data-command-label={@label}
      >
        <.icon :if={@icon} name={@icon} class="size-4 text-text-muted shrink-0" />
        <span class="flex-1 truncate">{@label}</span>
        <kbd :if={@shortcut} class="text-[0.65rem] font-mono text-text-muted">{@shortcut}</kbd>
      </button>
    <% end %>
    """
  end

  defp extract_item_attrs(item) do
    %{
      icon: item[:icon],
      label: item[:label] || item.label,
      shortcut: item[:shortcut],
      navigate: item[:navigate] || item[:patch],
      event: item[:event]
    }
  end
end
