vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- Disable the space key's default behavior in normal mode
keymap.set("n", "<Space>", "<Nop>")

-- general keymaps

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlight" })
keymap.set("n", "x", '"_x', { desc = "Remove character without copying it" })

keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment a number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement a number" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make split windows equal width & height" })
keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close current split window" })

keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", ":tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", ":tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>td", ":tabnew %<CR>", { desc = "Open current buffer in new tab" })
