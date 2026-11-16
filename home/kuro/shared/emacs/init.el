;;; -*- lexical-binding: t; -*-

(setq make-backup-files nil)
(make-directory (locate-user-emacs-file "auto-save/") t)
(setq auto-save-file-name-transforms `((".*" ,(locate-user-emacs-file "auto-save/") t)))
(setq xterm-update-cursor 'type)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(menu-bar-mode -1)

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
(evil-define-key '(normal visual motion) 'global (kbd "<leader> s s") #'consult-ripgrep)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> s r") #'kuro/replace-in-project)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> g g") #'magit-status)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c c") #'execute-extended-command)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c r") #'eglot-rename)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c a") #'eglot-code-actions)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b b") #'kuro/switch-buffer)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b d") #'kill-current-buffer)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b t") #'evil-buffer-new)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> h") #'tab-line-switch-to-prev-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> l") #'tab-line-switch-to-next-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> k") #'tab-line-switch-to-prev-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> j") #'tab-line-switch-to-next-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> w h") #'evil-window-left)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> w j") #'evil-window-down)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> w k") #'evil-window-up)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> w l") #'evil-window-right)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> w L") #'evil-window-vsplit)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> w J") #'evil-window-split)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> w d") #'evil-window-delete)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> w D") #'delete-other-windows)

(require 'magit)
(require 'evil-collection)
(evil-collection-init 'magit)
(evil-define-key '(normal visual) magit-mode-map (kbd "SPC") (lookup-key evil-normal-state-map (kbd "<leader>")))
(keymap-set transient-map "<escape>" #'transient-quit-one)

(require 'multisession)
(defvar kuro/project-trust
  (make-multisession :package "kuro" :key "project-trust" :initial-value nil))

(setq trusted-content
      (mapcar #'car (seq-filter #'cdr (multisession-value kuro/project-trust))))

(defun kuro/project-root ()
  (abbreviate-file-name
   (file-truename
    (file-name-as-directory
     (if-let* ((project (project-current)))
         (project-root project)
       default-directory)))))

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

(defun kuro/eglot-ensure ()
  (when (kuro/project-trusted-p)
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

(require 'markdown-mode)
(add-hook 'markdown-mode-hook #'kuro/eglot-ensure)

(defun kuro/format-on-save ()
  (add-hook 'before-save-hook
            (lambda () (when (eglot-managed-p) (eglot-format-buffer)))
            nil t))

(add-hook 'go-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'go-ts-mode-hook #'kuro/format-on-save)

(add-hook 'rust-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'rust-ts-mode-hook #'kuro/format-on-save)

(setopt treesit-enabled-modes '(json-ts-mode))
(setq-default eglot-workspace-configuration '(:json (:validate (:enable t))))
(add-hook 'json-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'yaml-ts-mode-hook #'kuro/eglot-ensure)

(keymap-set minibuffer-local-map "<escape>" #'abort-minibuffers)

(require 'vertico)
(vertico-mode 1)
(savehist-mode 1)

(require 'consult)
(setq consult-async-split-style nil)

(defun kuro/replace-globs (files)
  (mapcan (lambda (file)
            (list "--glob" (if (file-directory-p file)
                               (concat (file-name-as-directory file) "**")
                             file)))
          (split-string files "," t "[ \t]+")))

(defun kuro/replace-in-project (search replacement files)
  (interactive
   (list (read-string "Search: ")
         (read-string "Replace with: ")
         (read-string "Files (empty for all): ")))
  (when (get-buffer "*replace*")
    (kill-buffer "*replace*"))
  (let* ((default-directory (kuro/project-root))
         (buffer (get-buffer-create "*replace*"))
         (count 0)
         (status (apply #'call-process "rg" nil buffer nil
                        "--fixed-strings" "--case-sensitive" "--sort=path"
                        "--line-number" "--with-filename" "--no-heading" "--color=never"
                        (append (kuro/replace-globs files) (list "--regexp" search)))))
    (cond
     ((eql status 1)
      (kill-buffer buffer)
      (message "No matches for %s" search))
     ((not (eql status 0))
      (pop-to-buffer buffer))
     (t
      (with-current-buffer buffer
        (grep-mode)
        (compilation--ensure-parse (point-max))
        (grep-change-to-grep-edit-mode)
        (goto-char (point-min))
        (let ((case-fold-search nil))
          (while (search-forward search nil t)
            (unless (get-text-property (match-beginning 0) 'occur-prefix)
              (replace-match replacement t t)
              (setq count (1+ count)))))
        (goto-char (point-min)))
      (pop-to-buffer buffer)
      (message "%d replacements, :wa saves, u undoes" count)))))

(require 'marginalia)
(setq marginalia-annotators '((command marginalia-annotate-command builtin none)))
(marginalia-mode 1)

(require 'corfu)
(setq corfu-auto t)
(global-corfu-mode 1)

(require 'orderless)
(setq completion-styles '(orderless basic))

(require 'dired-aux)
(require 'embark)

(defun kuro/file-action (action)
  (lambda ()
    (interactive)
    (if (memq (completion-metadata-get
               (completion-metadata (minibuffer-contents)
                                    minibuffer-completion-table
                                    minibuffer-completion-predicate)
               'category)
              '(file project-file))
        (let ((embark-prompter (lambda (&rest _) action))
              (embark-quit-after-action nil))
          (embark-act))
      (user-error "Not a file list"))))

(defun kuro/refresh-file-list ()
  (with-selected-window (active-minibuffer-window)
    (embark--restart)))

(defun kuro/read-new-name (prompt file initial)
  (let ((candidates (with-current-buffer (window-buffer (active-minibuffer-window))
                      (overlay-get vertico--candidates-ov 'before-string)))
        (enable-recursive-minibuffers t))
    (expand-file-name
     (minibuffer-with-setup-hook
         (lambda ()
           (setq-local truncate-lines t
                       max-mini-window-height 1.0)
           (overlay-put (make-overlay (point-max) (point-max) nil t t)
                        'before-string candidates))
       (read-string (format prompt (file-name-nondirectory file)) initial))
     (file-name-directory file))))

(defun kuro/delete-file (file)
  (set-transient-map
   (define-keymap
     "C-d" (lambda ()
             (interactive)
             (delete-file file)
             (kuro/refresh-file-list))
     "<escape>" #'ignore))
  (let ((minibuffer-message-timeout nil))
    (message "Delete %s? Press C-d again" (abbreviate-file-name file))))

(defun kuro/copy-file (file)
  (let ((file (directory-file-name file)))
    (copy-file file
               (kuro/read-new-name "Copy %s to: " file
                                   (concat (file-name-base file)
                                           "-copy"
                                           (file-name-extension file t))))
    (kuro/refresh-file-list)))

(defun kuro/rename-file (file)
  (let ((file (directory-file-name file)))
    (dired-rename-file file
                       (kuro/read-new-name "Rename %s to: " file
                                           (file-name-nondirectory file))
                       nil)
    (kuro/refresh-file-list)))

(keymap-set vertico-map "C-d" (kuro/file-action #'kuro/delete-file))
(keymap-set vertico-map "C-c" (kuro/file-action #'kuro/copy-file))
(keymap-set vertico-map "C-r" (kuro/file-action #'kuro/rename-file))

(defun kuro/stash-file (file)
  (locate-user-emacs-file (concat "stash/" (sha1 file))))

(defun kuro/stash-unsaved-buffers ()
  (make-directory (locate-user-emacs-file "stash/") t)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (and buffer-file-name (buffer-modified-p))
        (let ((coding-system-for-write 'utf-8-emacs))
          (write-region nil nil (kuro/stash-file buffer-file-name) nil 'silent))))))

(defun kuro/restore-stashed-buffer ()
  (let ((stash (kuro/stash-file buffer-file-name)))
    (when (file-exists-p stash)
      (let ((coding-system-for-read 'utf-8-emacs))
        (erase-buffer)
        (insert-file-contents stash))
      (delete-file stash)
      (message "Restored unsaved changes to %s" (buffer-name)))))

(add-hook 'kill-emacs-hook #'kuro/stash-unsaved-buffers)
(add-hook 'find-file-hook #'kuro/restore-stashed-buffer)

(defun kuro/use-client-directory ()
  (when-let* ((client (frame-parameter nil 'client))
              (directory (process-get client 'server-client-directory)))
    (with-current-buffer (window-buffer)
      (unless buffer-file-name
        (setq default-directory (file-name-as-directory directory))))))

(add-hook 'server-after-make-frame-hook #'kuro/use-client-directory)

(defun kuro/user-buffer-p (candidate)
  (let ((name (if (consp candidate) (car candidate) candidate)))
    (or (not (string-match-p "\\`[ *]" name))
        (string-match-p "\\`\\*\\(scratch\\|new\\)\\*" name))))

(defun kuro/switch-buffer ()
  (interactive)
  (switch-to-buffer (read-buffer "Switch to buffer: " nil t #'kuro/user-buffer-p)))
