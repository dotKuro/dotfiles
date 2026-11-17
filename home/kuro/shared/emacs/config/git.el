;;; -*- lexical-binding: t; -*-

(require 'magit)
(require 'evil-collection)
(evil-collection-init 'magit)
(evil-define-key '(normal visual) magit-mode-map (kbd "SPC") (lookup-key evil-normal-state-map (kbd "<leader>")))
(keymap-set transient-map "<escape>" #'transient-quit-one)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> g g") #'magit-status)
