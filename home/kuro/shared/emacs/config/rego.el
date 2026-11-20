;;; -*- lexical-binding: t; -*-

(require 'treesit)

(defvar rego-ts-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?` "\"" table)
    table))

(defvar kuro/rego-font-lock
  (treesit-font-lock-rules
   :language 'rego
   :feature 'comment
   '((comment) @font-lock-comment-face)
   :language 'rego
   :feature 'string
   '((string) @font-lock-string-face)
   :language 'rego
   :feature 'keyword
   '([(package) (import) (default) (if) (else) (contains) (not) (some) (every) (in) (with) (as)]
     @font-lock-keyword-face)
   :language 'rego
   :feature 'definition
   '((rule_head (var) @font-lock-function-name-face))
   :language 'rego
   :feature 'constant
   '((boolean) @font-lock-constant-face
     (scalar "null" @font-lock-constant-face))
   :language 'rego
   :feature 'number
   '((number) @font-lock-number-face)
   :language 'rego
   :feature 'function
   '((fn_name) @font-lock-function-call-face)
   :language 'rego
   :feature 'operator
   '([(assignment_operator) (bool_operator) (arith_operator) (bin_operator)]
     @font-lock-operator-face)
   :language 'rego
   :feature 'bracket
   '([(open_paren) (close_paren) (open_bracket) (close_bracket) (open_curly) (close_curly)]
     @font-lock-bracket-face)))

(defun kuro/rego-indent-line ()
  (let ((column (save-excursion
                  (back-to-indentation)
                  (* 2
                     (max 0 (- (car (syntax-ppss))
                               (if (looking-at-p "[]})]") 1 0)))))))
    (if (<= (current-column) (current-indentation))
        (indent-line-to column)
      (save-excursion (indent-line-to column)))))

(define-derived-mode rego-ts-mode prog-mode "Rego"
  (setq-local comment-start "# "
              comment-end ""
              indent-tabs-mode nil
              indent-line-function #'kuro/rego-indent-line
              eglot-ignored-server-capabilities '(:diagnosticProvider))
  (when (treesit-ready-p 'rego)
    (treesit-parser-create 'rego)
    (setq-local treesit-font-lock-settings kuro/rego-font-lock
                treesit-font-lock-feature-list '((comment definition)
                                                 (keyword string)
                                                 (constant number function)
                                                 (operator bracket)))
    (treesit-major-mode-setup)))

(add-to-list 'auto-mode-alist '("\\.rego\\'" . rego-ts-mode))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(rego-ts-mode . ("regal" "language-server"))))

(add-hook 'rego-ts-mode-hook #'kuro/eglot-ensure)
