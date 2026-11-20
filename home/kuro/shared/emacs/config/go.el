;;; -*- lexical-binding: t; -*-

(setf (alist-get 'goimports apheleia-formatters) '("goimports" "-srcdir" filepath))
(setf (alist-get 'go-ts-mode apheleia-mode-alist) 'goimports)

(add-hook 'go-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'go-ts-mode-hook #'kuro/async-format-on-save)
