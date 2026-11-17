;;; -*- lexical-binding: t; -*-

(add-hook 'go-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'go-ts-mode-hook #'kuro/format-on-save)
(add-hook 'go-ts-mode-hook #'kuro/organize-imports-on-save)
