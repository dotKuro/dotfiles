;;; -*- lexical-binding: t; -*-

(require 'apheleia)
(require 'multisession)
(defvar kuro/project-trust
  (make-multisession :package "kuro" :key "project-trust" :initial-value nil))

(setq trusted-content
      (mapcar #'car (seq-filter #'cdr (multisession-value kuro/project-trust))))

(defun kuro/project-trusted-p ()
  (let* ((root (kuro/project-root))
         (entry (assoc root (multisession-value kuro/project-trust))))
    (unless entry
      (setq entry (cons root (y-or-n-p (format "Trust %s? " root))))
      (push entry (multisession-value kuro/project-trust))
      (when (cdr entry)
        (push root trusted-content)))
    (cdr entry)))

(defun kuro/reset-project-trust ()
  (interactive)
  (let ((root (kuro/project-root)))
    (setf (multisession-value kuro/project-trust)
          (assoc-delete-all root (multisession-value kuro/project-trust)))
    (setq trusted-content (delete root trusted-content))
    (message "Trust for %s reset" root)))

(setq eglot-extend-to-xref t)

(defun kuro/eglot-ensure ()
  (when (or (and (featurep 'eglot) (eglot-current-server))
            (kuro/project-trusted-p))
    (eglot-ensure)))

(defun kuro/code-action-hint (suggest callback &rest arguments)
  (apply suggest
         (lambda (hint &rest properties)
           (apply callback
                  (and hint
                       (replace-regexp-in-string
                        "\\`<leader>" (propertize "SPC" 'face 'help-key-binding) hint t t))
                  properties))
         arguments))

(advice-add 'eglot-code-action-suggestion :around #'kuro/code-action-hint)

(defun kuro/format-on-save ()
  (add-hook 'before-save-hook
            (lambda () (when (eglot-managed-p) (eglot-format-buffer)))
            nil t))

(defun kuro/async-format-on-save ()
  (add-hook 'eglot-managed-mode-hook
            (lambda () (apheleia-mode (if (eglot-managed-p) 1 -1)))
            nil t))

(evil-define-key '(normal visual motion) 'global (kbd "<leader> c r") #'eglot-rename)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c a") #'eglot-code-actions)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c d") #'xref-find-definitions)
