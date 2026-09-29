return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    -- Scope the filesystem source's git status calls to whatever directory
    -- is currently displayed, instead of scanning the entire worktree root
    -- on every refresh (extremely expensive in large monorepos).
    git_status_scope_to_path = true,
    -- Hide the repo-wide "Git" tab from the winbar. It inherently can't
    -- respect git_status_scope_to_path (its purpose is to list every changed
    -- file across the whole repo), so keeping it visible/active means
    -- occasional unscoped, full-repo git status scans. The filesystem tree
    -- already shows per-file git status icons, correctly scoped to whatever
    -- directory is displayed.
    source_selector = {
      sources = {
        { source = "filesystem" },
        { source = "buffers" },
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        opts.autocmds = opts.autocmds or {}
        -- Override AstroNvim's default lazygit-close refresh: only refresh
        -- the (scoped) filesystem source, never the repo-wide git_status
        -- source. Without this, closing lazygit always triggers a full,
        -- unscoped `git status` over the entire worktree.
        opts.autocmds.neotree_refresh = {
          {
            event = "TermClose",
            pattern = "*lazygit*",
            desc = "Refresh Neo-Tree filesystem source (scoped to displayed path) when closing lazygit",
            callback = function()
              local manager_avail, manager = pcall(require, "neo-tree.sources.manager")
              if manager_avail and package.loaded["neo-tree.sources.filesystem"] then
                manager.refresh(require("neo-tree.sources.filesystem").name)
              end
            end,
          },
        }
      end,
    },
  },
}
