;;; -*- lexical-binding: t; -*-

(require 'markdown-mode)
(add-hook 'markdown-mode-hook #'kuro/eglot-ensure)

(setopt treesit-enabled-modes '(json-ts-mode))
(setq-default eglot-workspace-configuration '(:json (:validate (:enable t))))
(add-hook 'json-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'yaml-ts-mode-hook #'kuro/eglot-ensure)
