;;; -*- lexical-binding: t; -*-

(setq make-backup-files nil)
(make-directory (locate-user-emacs-file "auto-save/") t)
(setq auto-save-file-name-transforms `((".*" ,(locate-user-emacs-file "auto-save/") t)))
(setq xterm-update-cursor 'type)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(setq tab-line-close-button-show nil)
(setq tab-line-new-button-show nil)
(global-tab-line-mode 1)

(load-theme 'modus-vivendi-deuteranopia t)
(custom-set-faces
 '(evil-ex-substitute-matches
   ((t :inherit diff-refine-removed :background unspecified :foreground unspecified)))
 '(evil-ex-substitute-replacement
   ((t :inherit diff-refine-added :background unspecified :foreground unspecified))))

(setq evil-want-keybinding nil)
(setq evil-want-C-i-jump nil)
(require 'evil)
(setq evil-default-cursor 'box)
(setq evil-vsplit-window-right t)
(setq evil-split-window-below t)
(evil-mode 1)
(evil-set-leader '(normal visual motion) (kbd "SPC"))
(evil-define-key '(normal visual motion) 'global (kbd "<leader> f f") #'find-file)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> SPC") #'project-find-file)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> g g") #'magit-status)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c c") #'execute-extended-command)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> c r") #'eglot-rename)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b b") #'kuro/switch-buffer)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b d") #'kill-current-buffer)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> b t") #'evil-buffer-new)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> h") #'tab-line-switch-to-prev-tab)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> l") #'tab-line-switch-to-next-tab)
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

(require 'markdown-mode)
(add-hook 'markdown-mode-hook #'kuro/eglot-ensure)

(defun kuro/format-on-save ()
  (add-hook 'before-save-hook
            (lambda () (when (eglot-managed-p) (eglot-format-buffer)))
            nil t))

(add-hook 'go-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'go-ts-mode-hook #'kuro/format-on-save)

(setopt treesit-enabled-modes '(json-ts-mode))
(setq-default eglot-workspace-configuration '(:json (:validate (:enable t))))
(add-hook 'json-ts-mode-hook #'kuro/eglot-ensure)
(add-hook 'yaml-ts-mode-hook #'kuro/eglot-ensure)

(keymap-set minibuffer-local-map "<escape>" #'abort-minibuffers)

(require 'vertico)
(vertico-mode 1)

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
