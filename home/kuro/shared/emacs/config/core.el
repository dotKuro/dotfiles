;;; -*- lexical-binding: t; -*-

(setq make-backup-files nil)
(make-directory (locate-user-emacs-file "auto-save/") t)
(setq auto-save-file-name-transforms `((".*" ,(locate-user-emacs-file "auto-save/") t)))
(setq xterm-update-cursor 'type)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)
(menu-bar-mode -1)
(xterm-mouse-mode 1)

(defun kuro/project-root ()
  (abbreviate-file-name
   (file-truename
    (file-name-as-directory
     (if-let* ((project (project-current)))
         (project-root project)
       default-directory)))))

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
