;;; -*- lexical-binding: t; -*-

(setq evil-want-keybinding nil)
(setq evil-want-C-i-jump nil)
(setq evil-mode-line-format nil)
(require 'evil)
(setq evil-default-cursor 'box)
(setq evil-vsplit-window-right t)
(setq evil-split-window-below t)
(evil-mode 1)
(evil-set-leader '(normal visual motion) (kbd "SPC"))
(evil-define-key '(normal visual motion) 'global (kbd "<leader> f f") #'find-file)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> SPC") #'project-find-file)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c c") #'execute-extended-command)
