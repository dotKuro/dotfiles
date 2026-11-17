;;; -*- lexical-binding: t; -*-

(setq make-backup-files nil)
(make-directory (locate-user-emacs-file "auto-save/") t)
(setq auto-save-file-name-transforms `((".*" ,(locate-user-emacs-file "auto-save/") t)))
(setq xterm-update-cursor 'type)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(menu-bar-mode -1)
(xterm-mouse-mode 1)

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
(defface kuro/start-heading '((t)) "Heading on the start page.")

(load-theme 'modus-vivendi-deuteranopia t)
(modus-themes-with-colors
  (custom-set-faces
   `(kuro/mode-line-normal ((,c :background ,blue :foreground ,bg-main)))
   `(kuro/mode-line-insert ((,c :background ,yellow :foreground ,bg-main)))
   `(kuro/mode-line-visual ((,c :background ,fg-main :foreground ,bg-main)))
   `(kuro/start-heading ((,c :weight bold :foreground ,blue)))
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
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c d") #'xref-find-definitions)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b b") #'kuro/switch-buffer)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b d") #'kuro/close-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b f") #'kuro/find-buffer)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b t") #'evil-buffer-new)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> h") #'tab-line-switch-to-prev-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> l") #'tab-line-switch-to-next-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> k") #'tab-line-switch-to-prev-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> j") #'tab-line-switch-to-next-tab)

(require 'cl-lib)
(load (locate-user-emacs-file "tiling-keys.el"))

(defun kuro/tile-windows ()
  (seq-remove (lambda (window) (window-parameter window 'window-side))
              (window-list nil 'nomini (frame-first-window))))

(defun kuro/tile-pane (window)
  (cons (window-state-get window) (gethash window evil--jumps-window-jumps)))

(defun kuro/tile-put (window pane)
  (window-state-put (car pane) window 'safe)
  (if (cdr pane)
      (puthash window (cdr pane) evil--jumps-window-jumps)
    (remhash window evil--jumps-window-jumps)))

(defun kuro/tile-panes ()
  (let ((windows (kuro/tile-windows))
        (hidden (frame-parameter nil 'kuro/tile-hidden)))
    (cons (append (car hidden) (mapcar #'kuro/tile-pane windows) (cdr hidden))
          (+ (length (car hidden)) (or (seq-position windows (selected-window)) 0)))))

(defun kuro/tile-show (panes index zoomed)
  (let* ((configuration (current-window-configuration))
         (visible (if zoomed (list (nth index panes)) panes))
         (window (car (kuro/tile-windows)))
         (windows (list window)))
    (condition-case failure
        (progn
          (delete-other-windows window)
          (when (cdr visible)
            (setq window (split-window window (round (* 0.55 (window-total-width window))) 'right))
            (push window windows)
            (dotimes (step (- (length visible) 2))
              (setq window (split-window window
                                         (/ (window-total-height window) (- (length visible) 1 step))
                                         'below))
              (push window windows)))
          (setq windows (nreverse windows))
          (cl-mapc #'kuro/tile-put windows visible))
      (error
       (set-window-configuration configuration)
       (signal (car failure) (cdr failure))))
    (set-frame-parameter nil 'kuro/tile-hidden
                         (and zoomed (cdr panes)
                              (cons (take index panes) (nthcdr (1+ index) panes))))
    (select-window (nth (if zoomed 0 index) windows))))

(defun kuro/tile-target (offset index count)
  (if offset (mod (+ index offset) count) 0))

(defun kuro/tile-focus (offset)
  (pcase-let* ((`(,panes . ,index) (kuro/tile-panes))
               (target (kuro/tile-target offset index (length panes))))
    (if (frame-parameter nil 'kuro/tile-hidden)
        (kuro/tile-show panes target t)
      (select-window (nth target (kuro/tile-windows))))))

(defun kuro/tile-swap (offset)
  (pcase-let* ((`(,panes . ,index) (kuro/tile-panes))
               (target (kuro/tile-target offset index (length panes))))
    (cl-rotatef (nth index panes) (nth target panes))
    (kuro/tile-show panes target nil)))

(defun kuro/tile-spawn ()
  (interactive)
  (pcase-let ((`(,panes . ,index) (kuro/tile-panes)))
    (kuro/tile-show (append (take (1+ index) panes)
                            (list (list (car (nth index panes))))
                            (nthcdr (1+ index) panes))
                    (1+ index)
                    nil)
    (set-window-prev-buffers nil nil)
    (set-window-next-buffers nil nil)))

(defun kuro/tile-close ()
  (interactive)
  (pcase-let ((`(,panes . ,index) (kuro/tile-panes)))
    (unless (cdr panes)
      (user-error "Only one window"))
    (kuro/tile-show (append (take index panes) (nthcdr (1+ index) panes))
                    (min index (- (length panes) 2))
                    (frame-parameter nil 'kuro/tile-hidden))))

(defun kuro/tile-toggle-layout ()
  (interactive)
  (pcase-let ((`(,panes . ,index) (kuro/tile-panes)))
    (kuro/tile-show panes index (not (frame-parameter nil 'kuro/tile-hidden)))))

(defun kuro/tile-focus-next () (interactive) (kuro/tile-focus 1))
(defun kuro/tile-focus-previous () (interactive) (kuro/tile-focus -1))
(defun kuro/tile-focus-main () (interactive) (kuro/tile-focus nil))
(defun kuro/tile-swap-next () (interactive) (kuro/tile-swap 1))
(defun kuro/tile-swap-previous () (interactive) (kuro/tile-swap -1))
(defun kuro/tile-swap-main () (interactive) (kuro/tile-swap nil))

(defun kuro/tile-key (name &optional shift)
  (let ((key (alist-get name kuro/tiling-keys)))
    (kbd (concat "<leader> w "
                 (cond ((equal key "Return") (if shift "S-<return>" "RET"))
                       (shift (upcase key))
                       (t key))))))

(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'spawn) #'kuro/tile-spawn)
(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'close) #'kuro/tile-close)
(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'toggleLayout) #'kuro/tile-toggle-layout)
(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'focusNext) #'kuro/tile-focus-next)
(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'focusPrev) #'kuro/tile-focus-previous)
(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'master) #'kuro/tile-focus-main)
(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'focusNext t) #'kuro/tile-swap-next)
(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'focusPrev t) #'kuro/tile-swap-previous)
(evil-define-key '(normal visual motion) 'global (kuro/tile-key 'master t) #'kuro/tile-swap-main)

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

(defun kuro/organize-imports ()
  (when (eglot-managed-p)
    (with-demoted-errors "Organize imports: %S"
      (dolist (action (eglot-code-actions (point-min) (point-max) "source.organizeImports"))
        (eglot-execute (eglot-current-server) action)))))

(defun kuro/organize-imports-on-save ()
  (add-hook 'before-save-hook #'kuro/organize-imports -10 t))

(add-hook 'go-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'go-ts-mode-hook #'kuro/format-on-save)
(add-hook 'go-ts-mode-hook #'kuro/organize-imports-on-save)

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

(defun kuro/tab-window (buffer &optional windows)
  (seq-find (lambda (window)
              (or (eq buffer (window-buffer window))
                  (assq buffer (window-prev-buffers window))
                  (memq buffer (window-next-buffers window))))
            (or windows (window-list nil 'nomini))))

(defun kuro/close-tab ()
  (interactive)
  (if (kuro/tab-window (current-buffer) (cdr (window-list nil 'nomini)))
      (bury-buffer)
    (kill-current-buffer)))

(defun kuro/find-buffer ()
  (interactive)
  (let* ((buffer (get-buffer (read-buffer "Find buffer: " nil t #'kuro/user-buffer-p)))
         (window (kuro/tab-window buffer)))
    (if window
        (progn
          (select-window window)
          (tab-line-select-tab-buffer buffer window))
      (switch-to-buffer buffer))))

(load (locate-user-emacs-file "start-art.el"))

(defconst kuro/start-keys
  '((project-find-file . "find file in project")
    (find-file . "find file")
    (consult-ripgrep . "search in project")
    (kuro/replace-in-project . "replace in project")
    (kuro/switch-buffer . "switch buffer")
    (kuro/find-buffer . "jump to tab")
    (tab-line-switch-to-next-tab . "next tab")
    (tab-line-switch-to-prev-tab . "previous tab")
    (kuro/close-tab . "close tab")
    (magit-status . "git status")
    (kuro/tile-spawn . "new window")
    (kuro/tile-close . "close window")
    (kuro/tile-focus-next . "next window")
    (kuro/tile-focus-previous . "previous window")
    (kuro/tile-toggle-layout . "maximize window")
    (kuro/tile-focus-main . "main window")
    (xref-find-definitions . "go to definition")
    (eglot-code-actions . "code actions")
    (eglot-rename . "rename symbol")
    (execute-extended-command . "run command")))

(defconst kuro/start-width 72)

(defun kuro/start-indent (width)
  (propertize " " 'display `(space :align-to (- center ,(/ width 2)))))

(defun kuro/start-insert-art ()
  (cl-loop for (top bottom) on kuro/start-art by #'cddr do
           (insert (kuro/start-indent (length top)))
           (dotimes (column (length top))
             (let ((upper (nth column top))
                   (lower (nth column bottom)))
               (insert (cond
                        ((and upper lower)
                         (propertize "▀" 'face (list :foreground upper :background lower)))
                        (upper (propertize "▀" 'face (list :foreground upper)))
                        (lower (propertize "▄" 'face (list :foreground lower)))
                        (t " ")))))
           (insert "\n")))

(defun kuro/start-insert-heading (title)
  (insert "\n"
          (kuro/start-indent kuro/start-width)
          (propertize title 'face 'kuro/start-heading)
          "\n"))

(defun kuro/start-cell (key text)
  (concat (propertize key 'face 'help-key-binding)
          (make-string (max 1 (- 11 (length key))) ?\s)
          (format "%-25s" text)))

(defun kuro/start-insert-projects ()
  (kuro/start-insert-heading "Recent projects")
  (seq-do-indexed
   (lambda (root index)
     (insert (kuro/start-indent kuro/start-width)
             (propertize (number-to-string (1+ index)) 'face 'help-key-binding)
             "  "
             (abbreviate-file-name root)
             "\n"))
   (take 5 (project-known-project-roots))))

(defun kuro/start-key (command)
  (when-let* ((key (where-is-internal command (list evil-normal-state-map) t)))
    (string-replace "<leader>" "SPC" (key-description key))))

(defun kuro/start-insert-keys ()
  (kuro/start-insert-heading "Keys")
  (let* ((cells (mapcar (lambda (entry)
                          (kuro/start-cell (or (kuro/start-key (car entry)) "") (cdr entry)))
                        kuro/start-keys))
         (rows (/ (1+ (length cells)) 2)))
    (dotimes (row rows)
      (insert (kuro/start-indent kuro/start-width)
              (nth row cells)
              (or (nth (+ row rows) cells) "")
              "\n"))))

(defun kuro/start-open-project (index)
  (lambda ()
    (interactive)
    (when-let* ((root (nth index (project-known-project-roots))))
      (let ((default-directory root))
        (project-find-file)))))

(define-derived-mode kuro/start-mode special-mode "Start"
  (setq truncate-lines t))

(evil-set-initial-state 'kuro/start-mode 'motion)
(dotimes (index 5)
  (evil-define-key 'motion kuro/start-mode-map
    (kbd (number-to-string (1+ index))) (kuro/start-open-project index)))

(defun kuro/start-buffer ()
  (with-current-buffer (get-buffer-create "*start*")
    (kuro/start-mode)
    (display-line-numbers-mode -1)
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert "\n")
      (kuro/start-insert-art)
      (kuro/start-insert-projects)
      (kuro/start-insert-keys)
      (goto-char (point-min)))
    (current-buffer)))

(setq initial-buffer-choice #'kuro/start-buffer)
