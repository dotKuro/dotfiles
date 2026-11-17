;;; -*- lexical-binding: t; -*-

(add-hook 'rust-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'rust-ts-mode-hook #'kuro/format-on-save)
