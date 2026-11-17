;;; -*- lexical-binding: t; -*-

(require 'cl-lib)
(load (locate-user-emacs-file "start-art.el"))

(defface kuro/start-heading '((t)) "Heading on the start page.")

(modus-themes-with-colors
  (custom-set-faces
   `(kuro/start-heading ((,c :weight bold :foreground ,blue)))))

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
  (let* ((cells (delq nil (mapcar (lambda (entry)
                                    (when-let* ((key (kuro/start-key (car entry))))
                                      (kuro/start-cell key (cdr entry))))
                                  kuro/start-keys)))
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
