;;; -*- lexical-binding: t; -*-

(dolist (part '("core" "ui" "keys" "windows" "completion" "git" "lsp" "data" "go" "rego" "start"))
  (load (locate-user-emacs-file (concat "config/" part ".el"))))

(dolist (file (file-expand-wildcards (locate-user-emacs-file "optional/*.el")))
  (load file))
