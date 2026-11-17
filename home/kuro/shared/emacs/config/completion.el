;;; -*- lexical-binding: t; -*-

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

(evil-define-key '(normal visual motion) 'global (kbd "<leader> s s") #'consult-ripgrep)
(evil-define-key '(normal visual motion) 'global (kbd "<leader> s r") #'kuro/replace-in-project)
