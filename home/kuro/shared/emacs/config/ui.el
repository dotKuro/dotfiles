;;; -*- lexical-binding: t; -*-

(defun kuro/tab-modified-p (buffer)
  (and (buffer-file-name buffer) (buffer-modified-p buffer)))

(defun kuro/tab-name (buffer &optional _buffers)
  (format " %s%s " (buffer-name buffer) (if (kuro/tab-modified-p buffer) " ●" "")))

(defun kuro/tab-cache-key (tabs)
  (list (tab-line-cache-key-default tabs)
        (mapcar (lambda (tab) (and (bufferp tab) (kuro/tab-modified-p tab))) tabs)))

(setq tab-line-close-button-show nil)
(setq tab-line-new-button-show nil)
(setq tab-line-separator "")
(setq tab-line-tab-name-function #'kuro/tab-name)
(setq tab-line-cache-key-function #'kuro/tab-cache-key)
(global-tab-line-mode 1)

(defface kuro/mode-line-normal '((t)) "Mode line block for normal state.")
(defface kuro/mode-line-insert '((t)) "Mode line block for insert state.")
(defface kuro/mode-line-visual '((t)) "Mode line block for visual state.")

(load-theme 'modus-vivendi-deuteranopia t)
(modus-themes-with-colors
  (custom-set-faces
   `(kuro/mode-line-normal ((,c :background ,blue :foreground ,bg-main)))
   `(kuro/mode-line-insert ((,c :background ,yellow :foreground ,bg-main)))
   `(kuro/mode-line-visual ((,c :background ,fg-main :foreground ,bg-main)))
   `(mode-line ((,c :background ,bg-dim :foreground ,fg-main :underline nil)))
   `(mode-line-active ((,c :background ,bg-dim :foreground ,fg-main :underline nil)))
   `(mode-line-inactive ((,c :background ,bg-dim :foreground ,fg-dim :underline nil)))
   `(tab-line ((,c :background ,bg-dim :foreground ,fg-dim)))
   `(tab-line-tab ((,c :background ,bg-main :foreground ,fg-main)))
   `(tab-line-tab-current ((,c :weight bold :background ,bg-main :foreground ,blue)))
   `(tab-line-tab-inactive ((,c :background ,bg-dim :foreground ,fg-dim)))))
(custom-set-faces
 '(evil-ex-substitute-matches
   ((t :inherit diff-refine-removed :background unspecified :foreground unspecified)))
 '(evil-ex-substitute-replacement
   ((t :inherit diff-refine-added :background unspecified :foreground unspecified))))

(defvar-local kuro/mode-line-file nil)

(defun kuro/mode-line-state ()
  (when (and (mode-line-window-selected-p) (bound-and-true-p evil-state))
    (propertize (format " %s " (upcase (symbol-name evil-state)))
                'face (pcase evil-state
                        ((or 'insert 'replace) 'kuro/mode-line-insert)
                        ('visual 'kuro/mode-line-visual)
                        (_ 'kuro/mode-line-normal)))))

(defun kuro/mode-line-file ()
  (if (not buffer-file-name)
      "%b"
    (or kuro/mode-line-file
        (setq kuro/mode-line-file
              (string-replace
               "%" "%%"
               (if-let* ((project (project-current)))
                   (concat (propertize (concat (project-name project) "/") 'face 'shadow)
                           (file-relative-name buffer-file-name (project-root project)))
                 (abbreviate-file-name buffer-file-name)))))))

(defun kuro/mode-line-count (count noun face)
  (when (> count 0)
    (propertize (format "%d %s%s" count noun (if (= count 1) "" "s")) 'face face)))

(defun kuro/mode-line-diagnostics ()
  (when (bound-and-true-p flymake-mode)
    (let ((errors 0)
          (warnings 0))
      (dolist (diagnostic (flymake-diagnostics))
        (pcase (get (flymake-diagnostic-type diagnostic) 'flymake-category)
          ('flymake-error (setq errors (1+ errors)))
          ('flymake-warning (setq warnings (1+ warnings)))))
      (list (kuro/mode-line-count errors "error" 'error)
            (kuro/mode-line-count warnings "warning" 'warning)))))

(defvar kuro/branches (make-hash-table :test #'equal))
(defvar-local kuro/mode-line-repository nil)

(defun kuro/update-branch ()
  (when-let* ((repository (locate-dominating-file default-directory ".git")))
    (setq kuro/mode-line-repository repository)
    (puthash repository
             (car (ignore-errors (process-lines "git" "branch" "--show-current")))
             kuro/branches)))

(defun kuro/mode-line-branch ()
  (when-let* ((branch (gethash kuro/mode-line-repository kuro/branches)))
    (concat "⎇ " branch)))

(add-hook 'find-file-hook #'kuro/update-branch)
(add-hook 'after-save-hook #'kuro/update-branch)
(add-hook 'after-revert-hook #'kuro/update-branch)
(add-hook 'magit-post-refresh-hook #'kuro/update-branch)

(defun kuro/mode-line-right ()
  (string-join
   (delq nil (append (kuro/mode-line-diagnostics)
                     (list (kuro/mode-line-branch)
                           (format-mode-line mode-name))))
   "   "))

(add-hook 'after-set-visited-file-name-hook
          (lambda () (kill-local-variable 'kuro/mode-line-file)))

(setq-default mode-line-format
              '((:eval (kuro/mode-line-state))
                " "
                (:eval (kuro/mode-line-file))
                (:eval (when (kuro/tab-modified-p (current-buffer))
                         (propertize " ●" 'face 'warning)))
                (:eval (when (and defining-kbd-macro (mode-line-window-selected-p))
                         (propertize "   REC" 'face 'warning)))
                mode-line-format-right-align
                (:eval (kuro/mode-line-right))
                "   %l:%C "))
