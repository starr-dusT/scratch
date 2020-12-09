;; -*- lexical-binding: t -*-

(setq this-system "main")
(setq system-category-1 '("main" "work" "termux"))
(setq system-category-2 '("main"))

; Use package and add archives to list
(require 'package)

(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

; Uncomment for fresh install
(package-refresh-contents)
(package-install 'use-package)

(require 'use-package)
(require 'use-package-ensure)

; Uncomment for fresh install
(setq use-package-always-ensure t)

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(setq package-quickstart t)

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))

(use-package benchmark-init
  :ensure t
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

;; Keep transient cruft out of ~/.emacs.d/
(setq user-emacs-directory "~/.cache/emacs/"
      backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      url-history-file (expand-file-name "url/history" user-emacs-directory)
      auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" user-emacs-directory)
      projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" user-emacs-directory))

;; Keep customization settings in a temporary file (thanks Ambrevar!)
(setq custom-file
      (if (boundp 'server-socket-dir)
          (expand-file-name "custom.el" server-socket-dir)
        (expand-file-name (format "emacs-custom-%s.el" (user-uid)) temporary-file-directory)))
(load custom-file t)

(global-auto-revert-mode t) ; Allow buffers to update from disk contents

(server-start)

(ido-mode 1)
(ido-everywhere 1)

(use-package ido-completing-read+
  :init
  (ido-ubiquitous-mode 1))

(use-package ivy
  :diminish
  :init
  (use-package amx :defer t)
  (use-package counsel :diminish :config (counsel-mode 1))
  (use-package swiper :defer t)
  (ivy-mode 1)
  :bind
  (("C-s" . swiper-isearch)
   ("C-c s" . counsel-rg)
   ("C-c b" . counsel-buffer-or-recentf)
   ("C-c C-b" . counsel-ibuffer)
   (:map ivy-minibuffer-map
         ("C-r" . ivy-previous-line-or-history)
         ("M-RET" . ivy-immediate-done))
   (:map counsel-find-file-map
         ("C-~" . counsel-goto-local-home)))
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-height 10)
  (ivy-on-del-error-function nil)
  (ivy-magic-slash-non-match-action 'ivy-magic-slash-non-match-create)
  (ivy-count-format "【%d/%d】")
  (ivy-wrap t)
  :config
  (defun counsel-goto-local-home ()
      "Go to the $HOME of the local machine."
      (interactive)
    (ivy--cd "~/")))

(setq inhibit-startup-message t)
(scroll-bar-mode -1)             ; Disable visible scrollbar
(tool-bar-mode -1)               ; Disable the toolbar
(tooltip-mode -1)                ; Disable tooltips
(set-fringe-mode 10)             ; Give some breathing room
(menu-bar-mode -1)               ; Disable the menu bar

(setq mouse-wheel-scroll-amount '(5 ((shift) . 5))) ; start out scrolling 1 line at a time
(setq mouse-wheel-progressive-speed nil)              ; accelerate scrolling
(setq mouse-wheel-follow-mouse 't)                  ; scroll window under mouse
(setq scroll-step 5)                                ; keyboard scroll one line at a timesetq use-dialog-box nil

(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq large-file-warning-threshold nil) ; Don't warn for large files
(setq vc-follow-symlinks t)             ; Don't warn for following symlinked files
(setq ad-redefinition-action 'accept)   ; Don't warn when advice is added for functions

(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (show-paren-mode 1))

(use-package popwin
  :config
  (popwin-mode 1))

(use-package doom-themes :defer t)
(load-theme 'doom-gruvbox t)

;; Set the font face based on platform
(set-face-attribute 'default nil :font "JetBrains Mono Nerd Font" :height 80)
;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "JetBrains Mono Nerd Font" :height 80)
;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "JetBrains Mono Nerd Font" :height 80 :weight 'regular)

(setq display-time-format "%l:%M %p %b %y"
      display-time-default-load-average nil)

(use-package diminish)

;; You must run (all-the-icons-install-fonts) one time after
;; installing this package!

(use-package minions
  :hook (doom-modeline-mode . minions-mode)
  :custom
  (minions-mode-line-lighter ""))

(use-package doom-modeline
  ;:after eshell     ;; Make sure it gets hooked after eshell
  :hook (after-init . doom-modeline-init)
  :custom-face
  (mode-line ((t (:height 0.85))))
  (mode-line-inactive ((t (:height 0.85))))
  :custom
  (doom-modeline-height 20)
  (doom-modeline-bar-width 6)
  (doom-modeline-lsp t)
  (doom-modeline-github nil)
  (doom-modeline-mu4e nil)
  (doom-modeline-irc nil)
  (doom-modeline-minor-modes t)
  (doom-modeline-persp-name nil)
  (doom-modeline-buffer-file-name-style 'truncate-except-project)
  (doom-modeline-major-mode-icon nil))

; Auto-save changed files
(use-package super-save
  :ensure t
  :defer 1
  :diminish super-save-mode
  :config
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t))

; Auto revert changed files
(global-auto-revert-mode 1)

(defun dw/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  erc-mode
                  circe-server-mode
                  circe-chat-mode
                  circe-query-mode
                  sauron-mode
                  term-mode))
  (add-to-list 'evil-emacs-state-modes mode)))

(defun dw/dont-arrow-me-bro ()
  (interactive)
  (message "Arrow keys are bad, you know?"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  :config
  (add-hook 'evil-mode-hook 'dw/evil-hook)
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; Disable arrow keys in normal and visual modes
  (define-key evil-normal-state-map (kbd "<left>") 'dw/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<right>") 'dw/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<down>") 'dw/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<up>") 'dw/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<left>") 'dw/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<right>") 'dw/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<down>") 'dw/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<up>") 'dw/dont-arrow-me-bro)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :custom
  (evil-collection-outline-bind-tab-p nil)
  :config
  (evil-collection-init))

(use-package general
  :ensure t
  :config
  (general-evil-setup t))

  (general-create-definer dw/leader-key-def
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-min-display-lines 6))

(use-package use-package-chords
  :disabled
  :config (key-chord-mode 1))

(use-package hydra
  :defer 1)

; Set Default indentation to 2 characters
(setq-default tab-width 2)
(setq-default evil-shift-width tab-width)

; Use spaces instead of tabs for indents
(setq-default indent-tabs-mode nil)

; Automatic comment/uncomment lines
(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

; Use Parinfer for Lispy languages
(use-package parinfer
  :hook ((clojure-mode . parinfer-mode)
         (emacs-lisp-mode . parinfer-mode)
         (common-lisp-mode . parinfer-mode)
         (scheme-mode . parinfer-mode)
         (lisp-mode . parinfer-mode))
  :config
  (setq parinfer-extensions
      '(defaults       ; should be included.
        pretty-parens  ; different paren styles for different modes.
        evil           ; If you use Evil.
        smart-tab      ; C-b & C-f jump positions and smart shift with tab & S-tab.
        smart-yank)))  ; Yank behavior depend on mode.

;(dw/leader-key-def
;  "tp" 'parinfer-toggle-mode)

;; TODO: Mode this to another section
(setq-default fill-column 80)

;; Turn on indentation and auto-fill mode for Org files
(defun dw/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil)
  (diminish org-indent-mode))

(use-package org
  :defer t
  :hook (org-mode . dw/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 0
        org-hide-block-startup nil
        org-src-preserve-indentation nil
        org-startup-folded 'content
        org-cycle-separator-lines 2)

  (setq org-modules
    '(org-crypt
        org-habit))

  (setq org-refile-targets '((nil :maxlevel . 3)
                            (org-agenda-files :maxlevel . 3)))
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-use-outline-path t)

  (evil-define-key '(normal insert visual) org-mode-map (kbd "C-j") 'org-next-visible-heading)
  (evil-define-key '(normal insert visual) org-mode-map (kbd "C-k") 'org-previous-visible-heading)

  (evil-define-key '(normal insert visual) org-mode-map (kbd "M-j") 'org-metadown)
  (evil-define-key '(normal insert visual) org-mode-map (kbd "M-k") 'org-metaup)

  (org-babel-do-load-languages
    'org-babel-load-languages
    '((emacs-lisp . t)
      (ledger . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes)

  ;; NOTE: Subsequent sections are still part of this use-package block!

;; Since we don't want to disable org-confirm-babel-evaluate all
  ;; of the time, do it around the after-save-hook
  (defun dw/org-babel-tangle-dont-ask ()
  ;; Dynamic scoping to the rescue
  (let ((org-confirm-babel-evaluate nil))
(org-babel-tangle)))

  (add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'dw/org-babel-tangle-dont-ask
					'run-at-end 'only-in-org-mode)))

(use-package org-make-toc
  :hook (org-mode . org-make-toc-mode))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Replace list hyphen with dot
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                          (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(dolist (face '((org-level-1 . 1.2)
                (org-level-2 . 1.1)
                (org-level-3 . 1.05)
                (org-level-4 . 1.0)
                (org-level-5 . 1.1)
                (org-level-6 . 1.1)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "JetBrains Mono Nerd Font" :weight 'regular :height (cdr face)))

;; Make sure org-indent face is available
(require 'org-indent)

;; Ensure that anything that should be fixed-pitch in Org files appears that way
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;;; Directory Options
;; Set default working directory for org files
(setq org-directory "~/documents/org")
;; Set default locations to store notes
(setq org-default-notes-file "~/documents/org/capture/refile.org")
;; Set agenda files
(setq org-agenda-files (quote ("~/documents/org/capture"
                               "~/documents/org/capture/agendas"
                               "~/documents/org/capture/bookmarks"
                               "~/documents/org/capture/notes")))

;;; Set Todo Options
;; Set keywords for todo items
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" ))))
;; Set colors for todo items
(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold))))
;; Set tags based on todo changes
(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("HOLD" ("WAITING") ("HOLD" . t))
              (done ("WAITING") ("HOLD"))
              ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
              ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
              ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

;; open org-capture
(global-set-key (kbd "C-c c") 'org-capture)

;;; Set Org-Capture Options
;; Capture templates for: TODO tasks, Notes, appointments, and meetings
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/documents/org/capture/refile.org")
               "* TODO %?\n%U\n%a\n")
              ("r" "respond" entry (file "~/documents/org/capture/refile.org")
               "* TODO Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n")
              ("n" "note" entry (file "~/documents/org/capture/refile.org")
               "* %? :NOTE:\n%U\n%a\n")
              ("m" "Meeting" entry (file "~/documents/org/capture/refile.org")
               "* MEETING with %? :MEETING:\n%U")
              ("h" "Habit" entry (file "~/documents/org/capture/refile.org")
               "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))

;;; Set Task Refiling Options
;; Targets include this file and any file contributing to the agenda - up to 9 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))
;; Use full outline paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path t)
;; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)
;; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))
;; Use IDO for both buffer and file completion and ido-everywhere to t
(setq org-completion-use-ido t)
(setq ido-everywhere t)
(setq ido-max-directory-size 100000)
(ido-mode (quote both))
;; Use the current window when visiting files and buffers with ido
(setq ido-default-file-method 'selected-window)
(setq ido-default-buffer-method 'selected-window)
;; Use the current window for indirect buffer display
(setq org-indirect-buffer-display 'current-window)
;; Exclude DONE state tasks from refile targets
(defun bh/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))
(setq org-refile-target-verify-function 'bh/verify-refile-target)

;;; Custom Agenda Views
;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)
;; Compact the block agenda view
(setq org-agenda-compact-blocks t)
;; Custom agenda command definitions
(setq org-agenda-custom-commands
      (quote (("N" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              ("h" "Habits" tags-todo "STYLE=\"habit\""
               ((org-agenda-overriding-header "Habits")
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              ("c" "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               nil))))

;; Configure common tags
(setq org-tag-alist
  '((:startgroup)
     ; Put mutually exclusive tags here
     (:endgroup)
     ("@errand" . ?E)
     ("@home" . ?H)
     ("@work" . ?W)
     ("agenda" . ?a)
     ("planning" . ?p)
     ("publish" . ?P)
     ("batch" . ?b)
     ("note" . ?n)
     ("idea" . ?i)
     ("thinking" . ?t)
     ("recurring" . ?r)))

(defun dw/search-org-files ()
  (interactive)
  (counsel-rg "" "~/documents/org/capture/notes" nil "Search Notes: "))

;;; Various Small Settings
;; Always hilight the current agenda line
(add-hook 'org-agenda-mode-hook
          '(lambda () (hl-line-mode 1))
          'append)
;; Keep tasks with dates on the global todo lists
(setq org-agenda-todo-ignore-with-date nil)
;; Keep tasks with deadlines on the global todo lists
(setq org-agenda-todo-ignore-deadlines nil)
;; Keep tasks with scheduled dates on the global todo lists
(setq org-agenda-todo-ignore-scheduled nil)
;; Keep tasks with timestamps on the global todo lists
(setq org-agenda-todo-ignore-timestamp nil)
;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)
;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)
;; Remove completed items from search results
(setq org-agenda-skip-timestamp-if-done t)
;; Enforce todo dependencies
(setq org-enforce-todo-dependencies t)
;; Start in org-indent mode
(setq org-startup-indented t)
;; Remove blank lines
(setq org-cycle-separator-lines 0)
;; Deadline warning
(setq org-deadline-warning-days 14)
;; Enable logging
(setq org-log-done (quote time))
(setq org-log-into-drawer t)
(setq org-log-state-notes-insert-after-drawers nil)
;; Remove hilights after changes
(setq org-remove-highlights-with-change nil)
;; Prefer current year for date
(setq org-read-date-prefer-future nil)
;; Automatically change bullets
(setq org-list-demote-modify-bullet (quote (("+" . "-")
                                            ("*" . "-")
                                            ("1." . "-")
                                            ("1)" . "-")
                                            ("A)" . "-")
                                            ("B)" . "-")
                                            ("a)" . "-")
                                            ("b)" . "-")
                                            ("A." . "-")
                                            ("B." . "-")
                                            ("a." . "-")
                                            ("b." . "-"))))
;; Remove tags indents
(setq org-tags-match-list-sublevels t)
;; Overwrite the current window with the agenda
(setq org-agenda-window-setup 'current-window)
;; Let org-mode fold lists
(setq org-cycle-include-plain-lists t)
;; Start in folded mode
(setq org-startup-folded t)
;; Allow alphabetical lists
(setq org-alphabetical-lists t)
;; Keep times in hours, no days
(setq org-duration-format
      '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))
;; use utf-8 encoding
(setq org-export-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(set-charset-priority 'unicode)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))
;; Disable the default org-mode stuck projects agenda
(setq org-stuck-projects (quote ("" nil nil "")))
;; Only show agenda for current day
(setq org-agenda-span 'month)
;; Start the weekly agenda on Monday
(setq org-agenda-start-on-weekday 1)

;;; Helper Functions
(defun bh/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
 
               (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                next-headline
              nil)) ; a stuck project, has subtasks but no next task
        next-headline))))
(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (if (save-excursion (bh/skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (cond
           ((bh/is-project-p)
            nil)
           ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
            nil)
           (t
            subtree-end))))
    (save-excursion (org-end-of-subtree t))))
(defvar bh/hide-scheduled-and-waiting-next-tasks t)
(defun bh/skip-projects-and-habits-and-single-tasks ()
  "Skip trees that are projects, tasks that are habits, single non-project tasks"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((org-is-habit-p)
        next-headline)
       ((and bh/hide-scheduled-and-waiting-next-tasks
             (member "WAITING" (org-get-tags-at)))
        next-headline)
       ((bh/is-project-p)
        next-headline)
       ((and (bh/is-task-p) (not (bh/is-project-subtree-p)))
        next-headline)
       (t
        nil)))))
(defun bh/skip-project-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       ((bh/is-project-subtree-p)
        subtree-end)
       (t
        nil)))))
(defun bh/skip-non-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-task-p)
        nil)
       (t
        next-headline)))))
(defun bh/skip-non-archivable-tasks ()
  "Skip trees that are not available for archiving"
  (save-restriction
    (widen)
    ;; Consider only tasks with done todo headings as archivable candidates
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
          (subtree-end (save-excursion (org-end-of-subtree t))))
      (if (member (org-get-todo-state) org-todo-keywords-1)
          (if (member (org-get-todo-state) org-done-keywords)
              (let* ((daynr (string-to-int (format-time-string "%d" (current-time))))
                     (a-month-ago (* 60 60 24 (+ daynr 1)))
                     (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
                     (this-month (format-time-string "%Y-%m-" (current-time)))
                     (subtree-is-current (save-excursion
                                           (forward-line 1)
                                           (and (< (point) subtree-end)
                                                (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
                (if subtree-is-current
                    subtree-end ; Has a date in this month or last month, skip it
                  nil))  ; available to archive
            (or subtree-end (point-max)))
        next-headline))))
(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task has-subtask))))

(defun bh/is-project-subtree-p ()
  "Any task with a todo keyword that is in a project subtree.
Callers of this function already widen the buffer view."
  (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                              (point))))
    (save-excursion
      (bh/find-project-task)
      (if (equal (point) task)
          nil
        t))))

(defun bh/is-task-p ()
  "Any task with a todo keyword and no subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task (not has-subtask)))))

(defun bh/is-subproject-p ()
  "Any task which is a subtask of another project"
  (let ((is-subproject)
        (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
    (save-excursion
      (while (and (not is-subproject) (org-up-heading-safe))
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq is-subproject t))))
    (and is-a-task is-subproject)))
(defun bh/list-sublevels-for-projects-indented ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels 'indented)
    (setq org-tags-match-list-sublevels nil))
  nil)
(defun bh/list-sublevels-for-projects ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels t)
    (setq org-tags-match-list-sublevels nil))
  nil)
(defvar bh/hide-scheduled-and-waiting-next-tasks t)
(defun bh/toggle-next-task-display ()
  (interactive)
  (setq bh/hide-scheduled-and-waiting-next-tasks (not bh/hide-scheduled-and-waiting-next-tasks))
  (when  (equal major-mode 'org-agenda-mode)
    (org-agenda-redo))
  (message "%s WAITING and SCHEDULED NEXT Tasks" (if bh/hide-scheduled-and-waiting-next-tasks "Hide" "Show")))
(defun bh/skip-stuck-projects ()
  "Skip trees that are not stuck projects"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                nil
              next-headline)) ; a stuck project, has subtasks but no next task
        nil))))
(defun bh/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                next-headline
              nil)) ; a stuck project, has subtasks but no next task
        next-headline))))
(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (if (save-excursion (bh/skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (cond
           ((bh/is-project-p)
            nil)
           ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
            nil)
           (t
            subtree-end))))
    (save-excursion (org-end-of-subtree t))))
(defun bh/skip-non-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-task-p)
        nil)
       (t
        next-headline)))))
(defun bh/skip-project-trees-and-habits ()
  "Skip trees that are projects"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))
(defun bh/skip-projects-and-habits-and-single-tasks ()
  "Skip trees that are projects, tasks that are habits, single non-project tasks"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((org-is-habit-p)
        next-headline)
       ((and bh/hide-scheduled-and-waiting-next-tasks
             (member "WAITING" (org-get-tags-at)))
        next-headline)
       ((bh/is-project-p)
        next-headline)
       ((and (bh/is-task-p) (not (bh/is-project-subtree-p)))
        next-headline)
       (t
        nil)))))
(defun bh/skip-project-tasks-maybe ()
  "Show tasks related to the current restriction.
When restricted to a project, skip project and sub project tasks, habits, NEXT tasks, and loose tasks.
When not restricted, skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max))))
           (limit-to-project (marker-buffer org-agenda-restrict-begin)))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (not limit-to-project)
             (bh/is-project-subtree-p))
        subtree-end)
       ((and limit-to-project
             (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       (t
        nil)))))
(defun bh/skip-project-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       ((bh/is-project-subtree-p)
        subtree-end)
       (t
        nil)))))
(defun bh/skip-non-project-tasks ()
  "Show project tasks.
Skip project and sub-project tasks, habits, and loose non-project tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       ((not (bh/is-project-subtree-p))
        subtree-end)
       (t
        nil)))))
(defun bh/skip-projects-and-habits ()
  "Skip trees that are projects and tasks that are habits"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))
(defun bh/skip-non-subprojects ()
  "Skip trees that are not projects"
  (let ((next-headline (save-excursion (outline-next-heading))))
    (if (bh/is-subproject-p)
        nil
      next-headline)))
(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))
(defun bh/mark-next-parent-tasks-todo ()
  "Visit each parent task and change NEXT states to TODO"
  (let ((mystate (or (and (fboundp 'org-state)
                          state)
                     (nth 2 (org-heading-components)))))
    (when mystate
      (save-excursion
        (while (org-up-heading-safe)
          (when (member (nth 2 (org-heading-components)) (list "NEXT"))
            (org-todo "TODO")))))))

(add-hook 'org-after-todo-state-change-hook 'bh/mark-next-parent-tasks-todo 'append)
(add-hook 'org-clock-in-hook 'bh/mark-next-parent-tasks-todo 'append)

;; This ends the use-package org-mode block
)

(use-package evil-org
  :after org
  :hook ((org-mode . evil-org-mode)
         (org-agenda-mode . evil-org-mode)
         (evil-org-mode . (lambda () (evil-org-set-key-theme '(navigation todo insert textobjects additional)))))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;(dw/leader-key-def
;  "o"   '(:ignore t :which-key "org mode")
;  "oi"  '(:ignore t :which-key "insert")
;  "oil" '(org-insert-link :which-key "insert link")
;  "on"  '(org-toggle-narrow-to-subtree :which-key "toggle narrow")
;  "os"  '(dw/counsel-rg-org-files :which-key "search notes")
;  "oa"  '(org-agenda :which-key "status")
;  "oc"  '(org-capture t :which-key "capture")
;  "ox"  '(org-export-dispatch t :which-key "export"))

;(use-package Beancount
;  :straight (beancount
;             :type git
;             :host github
;             :repo "cnsunyour/beancount.el")
;  :bind
;  ("C-M-b" . (lambda ()
;               (interactive)
;               (find-file "~/Dropbox/beancount/main.bean")))
;  :mode
;  ("\\.bean\\(?:count\\)?\\'" . beancount-mode)
;  :config
;  (setq beancount-accounts-files
;        (directory-files "~/Dropbox/beancount/accounts/"
;                         'full
;                         (rx ".bean" eos))))

(use-package avy
  :commands (avy-goto-char avy-goto-word-0 avy-goto-line))

(dw/leader-key-def
  "j"   '(:ignore t :which-key "jump")
  "jj"  '(avy-goto-char :which-key "jump to char")
  "jw"  '(avy-goto-word-0 :which-key "jump to word")
  "jl"  '(avy-goto-line :which-key "jump to line"))

(use-package expand-region
  :bind (("M-[" . er/expand-region)
         ("C-(" . er/mark-outside-pairs)))

(setq initial-scratch-message "")
(setq initial-major-mode 'emacs-lisp-mode)

(use-package default-text-scale
  :defer 1
  :config
  (default-text-scale-mode))

(use-package ace-window
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(winner-mode)
(define-key evil-window-map "u" 'winner-undo)

(use-package burly)

(setq dired-listing-switches "-agho --group-directories-first"
      dired-omit-files "^\\.[^.].*"
      dired-omit-verbose nil)

(autoload 'dired-omit-mode "dired-x")

(add-hook 'dired-load-hook
  (lambda ()
  (interactive)
  (dired-collapse)))

(add-hook 'dired-mode-hook
  (lambda ()
  (interactive)
  (dired-omit-mode 1)
  (hl-line-mode 1)))

(use-package dired-rainbow
  :defer 2
  :config
  (dired-rainbow-define-chmod directory "#6cb2eb" "d.*")
  (dired-rainbow-define html "#eb5286" ("css" "less" "sass" "scss" "htm" "html" "jhtm" "mht" "eml" "mustache" "xhtml"))
  (dired-rainbow-define xml "#f2d024" ("xml" "xsd" "xsl" "xslt" "wsdl" "bib" "json" "msg" "pgn" "rss" "yaml" "yml" "rdata"))
  (dired-rainbow-define document "#9561e2" ("docm" "doc" "docx" "odb" "odt" "pdb" "pdf" "ps" "rtf" "djvu" "epub" "odp" "ppt" "pptx"))
  (dired-rainbow-define markdown "#ffed4a" ("org" "etx" "info" "markdown" "md" "mkd" "nfo" "pod" "rst" "tex" "textfile" "txt"))
  (dired-rainbow-define database "#6574cd" ("xlsx" "xls" "csv" "accdb" "db" "mdb" "sqlite" "nc"))
  (dired-rainbow-define media "#de751f" ("mp3" "mp4" "mkv" "MP3" "MP4" "avi" "mpeg" "mpg" "flv" "ogg" "mov" "mid" "midi" "wav" "aiff" "flac"))
  (dired-rainbow-define image "#f66d9b" ("tiff" "tif" "cdr" "gif" "ico" "jpeg" "jpg" "png" "psd" "eps" "svg"))
  (dired-rainbow-define log "#c17d11" ("log"))
  (dired-rainbow-define shell "#f6993f" ("awk" "bash" "bat" "sed" "sh" "zsh" "vim"))
  (dired-rainbow-define interpreted "#38c172" ("py" "ipynb" "rb" "pl" "t" "msql" "mysql" "pgsql" "sql" "r" "clj" "cljs" "scala" "js"))
  (dired-rainbow-define compiled "#4dc0b5" ("asm" "cl" "lisp" "el" "c" "h" "c++" "h++" "hpp" "hxx" "m" "cc" "cs" "cp" "cpp" "go" "f" "for" "ftn" "f90" "f95" "f03" "f08" "s" "rs" "hi" "hs" "pyc" ".java"))
  (dired-rainbow-define executable "#8cc4ff" ("exe" "msi"))
  (dired-rainbow-define compressed "#51d88a" ("7z" "zip" "bz2" "tgz" "txz" "gz" "xz" "z" "Z" "jar" "war" "ear" "rar" "sar" "xpi" "apk" "xz" "tar"))
  (dired-rainbow-define packaged "#faad63" ("deb" "rpm" "apk" "jad" "jar" "cab" "pak" "pk3" "vdf" "vpk" "bsp"))
  (dired-rainbow-define encrypted "#ffed4a" ("gpg" "pgp" "asc" "bfe" "enc" "signature" "sig" "p12" "pem"))
  (dired-rainbow-define fonts "#6cb2eb" ("afm" "fon" "fnt" "pfb" "pfm" "ttf" "otf"))
  (dired-rainbow-define partition "#e3342f" ("dmg" "iso" "bin" "nrg" "qcow" "toast" "vcd" "vmdk" "bak"))
  (dired-rainbow-define vc "#0074d9" ("git" "gitignore" "gitattributes" "gitmodules"))
  (dired-rainbow-define-chmod executable-unix "#38c172" "-.*x.*"))

(use-package dired-single
  :ensure t
  :defer t)

(use-package dired-ranger
  :defer t)

(use-package dired-collapse
  :defer t)

(use-package openwith
  :config
  (setq openwith-associations
    (list
      (list (openwith-make-extension-regexp
             '("mpg" "mpeg" "mp3" "mp4"
               "avi" "wmv" "wav" "mov" "flv"
               "ogm" "ogg" "mkv"))
             "mpv"
             '(file))
      (list (openwith-make-extension-regexp
             '("xbm" "pbm" "pgm" "ppm" "pnm"
               "png" "gif" "bmp" "tif" "jpeg")) ;; Removed jpg because Telega was
                                                ;; causing feh to be opened...
             "feh"
             '(file))
      (list (openwith-make-extension-regexp
             '("pdf"))
             "zathura"
             '(file))))
  (openwith-mode 1))

(defun start-mpv (path &optional playlist-p)

  "Start mpv with specified arguments"
  (let* ((default-cmd "mpv --force-window")
        (cmd (if playlist-p
                  (s-append " --loop-playlist --playlist=" default-cmd)
                (s-append " --loop " default-cmd))))
    (call-process-shell-command (s-concat cmd (shell-quote-argument path)) nil 0)))

(defun mpv ()
  "Play a file in current line"
  (interactive)
  (start-mpv (dired-get-filename)))

(defun mpv-dir ()
  "Play all multimedia files in current directory"
  (interactive)
  (start-mpv (expand-file-name default-directory)))

(defun mpv-playlist ()
  "Play a playlist in current line"
  (interactive)
  (start-mpv (dired-get-filename) t))

(setq which-key-sort-order 'which-key-prefix-then-key-order)

(evil-collection-define-key 'normal 'dired-mode-map
  "h" 'dired-single-up-directory
  "H" 'dired-omit-mode
  "l" 'dired-single-buffer
  "y" 'dired-ranger-copy
  "X" 'dired-ranger-move
  "p" 'dired-ranger-paste)

(require 'cl)

(defun dw/dired-link (path)
  (lexical-let ((target path))
    (lambda () (interactive) (message "Path: %s" target) (dired target))))

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package evil-magit
  :after magit)

(use-package forge
  :disabled)

(use-package magit-todos
  :defer t)

(use-package git-link
  :commands git-link
  :config
  (setq git-link-open-in-browser t))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/devel")
    (setq projectile-project-search-path '("~/devel")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile)

(use-package nvm
  :defer t)

(use-package typescript-mode
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 2))

(defun dw/set-js-indentation ()
  (setq js-indent-level 2)
  (setq evil-shift-width js-indent-level)
  (setq-default tab-width 2))

(use-package js2-mode
  :mode "\\.jsx?\\'"
  :config
  ;; Use js2-mode for Node scripts
  (add-to-list 'magic-mode-alist '("#!/usr/bin/env node" . js2-mode))

  ;; Don't use built-in syntax checking
  (setq js2-mode-show-strict-warnings nil)

  ;; Set up proper indentation in JavaScript and JSON files
  (add-hook 'js2-mode-hook #'dw/set-js-indentation)
  (add-hook 'json-mode-hook #'dw/set-js-indentation))

(use-package prettier-js
  :hook ((js2-mode . prettier-js-mode)
         (typescript-mode . prettier-js-mode))
  :config
  (setq prettier-js-show-errors nil))

(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda () (quire 'ccls) (lsp))))

(use-package haskell-mode)

(use-package rust-mode
  :mode "\\.rs\\'"
  :init (setq rust-format-on-save t))

(use-package cargo
  :ensure t
  :defer t)

(add-hook 'emacs-lisp-mode-hook #'flycheck-mode)

(use-package helpful
  :ensure t
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package web-mode
  :mode "(\\.\\(html?\\|ejs\\|tsx\\|jsx\\)\\'"
  :config
  (setq-default web-mode-code-indent-offset 2)
  (setq-default web-mode-markup-indent-offset 2)
  (setq-default web-mode-attribute-indent-offset 2))

;; 1. Start the server with `httpd-start'
;; 2. Use `impatient-mode' on any buffer
(use-package impatient-mode
  :ensure t)

(use-package skewer-mode
  :ensure t)

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(autoload 'ido-completing-read "ido")
(require 'subr-x)
(require 'outline)

(defgroup beancount ()
  "Editing mode for Beancount files."
  :group 'beancount)

(defcustom beancount-transaction-indent 2
  "Transaction indent."
  :type 'integer)

(defcustom beancount-number-alignment-column 52
  "Column to which align numbers in postinng definitions. Set to
0 to automatically determine the minimum column that will allow
to align all amounts."
  :type 'integer)

(defcustom beancount-highlight-transaction-at-point nil
  "If t highlight transaction under point."
  :type 'boolean)

(defcustom beancount-use-ido t
  "If non-nil, use ido-style completion rather than the standard."
  :type 'boolean)

(defcustom beancount-electric-currency nil
  "If non-nil, make `newline' try to add missing currency to
complete the posting at point. The correct currency is determined
from the open directive for the relevant account."
  :type 'boolean)

(defgroup beancount-faces nil "Beancount mode highlighting" :group 'beancount)

(defface beancount-directive
  `((t :inherit font-lock-keyword-face))
  "Face for Beancount directives.")

(defface beancount-tag
  `((t :inherit font-lock-type-face))
  "Face for Beancount tags.")

(defface beancount-link
  `((t :inherit font-lock-type-face))
  "Face for Beancount links.")

(defface beancount-date
  `((t :inherit font-lock-constant-face))
  "Face for Beancount dates.")

(defface beancount-account
  `((t :inherit font-lock-builtin-face))
  "Face for Beancount account names.")

(defface beancount-amount
  `((t :inherit font-lock-default-face))
  "Face for Beancount amounts.")

(defface beancount-narrative
  `((t :inherit font-lock-builtin-face))
  "Face for Beancount transactions narrative.")

(defface beancount-narrative-cleared
  `((t :inherit font-lock-string-face))
  "Face for Beancount cleared transactions narrative.")

(defface beancount-narrative-pending
  `((t :inherit font-lock-keyword-face))
  "Face for Beancount pending transactions narrative.")

(defface beancount-metadata
  `((t :inherit font-lock-type-face))
  "Face for Beancount metadata.")

(defface beancount-highlight
  `((t :inherit highlight))
  "Face to highlight Beancount transaction at point.")

(defconst beancount-account-directive-names
  '("balance"
    "close"
    "document"
    "note"
    "open"
    "pad")
  "Directive bames that can appear after a date and are followd by an account.")

(defconst beancount-no-account-directive-names
  '("commodity"
    "event"
    "price"
    "query"
    "txn")
  "Directive names that can appear after a date and are _not_ followed by an account.")

(defconst beancount-timestamped-directive-names
  (append beancount-account-directive-names
          beancount-no-account-directive-names)
  "Directive names that can appear after a date.")

(defconst beancount-directive-names
  '("include"
    "option"
    "plugin"
    "poptag"
    "pushtag")
  "Directive names that can appear at the beginning of a line.")

(defconst beancount-account-categories
  '("Assets" "Liabilities" "Equity" "Income" "Expenses"))

(defconst beancount-tag-chars "[:alnum:]-_/.")

(defconst beancount-account-chars "[:alnum:]-_:")

(defconst beancount-option-names
  ;; This list is kept in sync with the options defined in
  ;; beancount/parser/options.py.
  '("account_current_conversions"
    "account_current_earnings"
    "account_previous_balances"
    "account_previous_conversions"
    "account_previous_earnings"
    "account_rounding"
    "allow_deprecated_none_for_tags_and_links"
    "allow_pipe_separator"
    "booking_method"
    "conversion_currency"
    "documents"
    "infer_tolerance_from_cost"
    "inferred_tolerance_default"
    "inferred_tolerance_multiplier"
    "insert_pythonpath"
    "long_string_maxlines"
    "name_assets"
    "name_equity"
    "name_expenses"
    "name_income"
    "name_liabilities"
    "operating_currency"
    "plugin_processing_mode"
    "render_commas"
    "title"))

(defconst beancount-date-regexp "[0-9]\\{4\\}[-/][0-9]\\{2\\}[-/][0-9]\\{2\\}"
  "A regular expression to match dates.")

(defconst beancount-account-regexp
  (concat (regexp-opt beancount-account-categories)
          "\\(?::[[:upper:]][[:alnum:]-_]+\\)+")
  "A regular expression to match account names.")

(defconst beancount-number-regexp "[-+]?[0-9]+\\(?:,[0-9]\\{3\\}\\)*\\(?:\\.[0-9]*\\)?"
  "A regular expression to match decimal numbers.")

(defconst beancount-currency-regexp "[A-Z][A-Z-_'.]*"
  "A regular expression to match currencies.")

(defconst beancount-flag-regexp
  ;; Single char that is neither a space nor a lower-case letter.
  "[^ a-z]")

(defconst beancount-transaction-regexp
  (concat "^\\(" beancount-date-regexp "\\) +"
          "\\(?:txn +\\)?"
          "\\(" beancount-flag-regexp "\\) +"
          "\\(\".*\"\\)"))

(defconst beancount-posting-regexp
  (concat "^\\s-+"
          "\\(" beancount-account-regexp "\\)"
          "\\(?:\\s-+\\(\\(" beancount-number-regexp "\\)"
          "\\s-+\\(" beancount-currency-regexp "\\)\\)\\)?"))

(defconst beancount-directive-regexp
  (concat "^\\(" (regexp-opt beancount-directive-names) "\\) +"))

(defconst beancount-timestamped-directive-regexp
  (concat "^\\(" beancount-date-regexp "\\) +"
          "\\(" (regexp-opt beancount-timestamped-directive-names) "\\) +"))

(defconst beancount-metadata-regexp
  "^\\s-+\\([a-z][A-Za-z0-9_-]+:\\)\\s-+\\(.+\\)")

;; This is a grouping regular expression because the subexpression is
;; used in determining the outline level in `beancount-outline-level'.
(defvar beancount-outline-regexp "\\(;;;+\\|\\*+\\)")

(defun beancount-outline-level ()
  (let ((len (- (match-end 1) (match-beginning 1))))
    (if (equal (substring (match-string 1) 0 1) ";")
        (- len 2)
      len)))

(defun beancount-face-by-state (state)
  (cond ((string-equal state "*") 'beancount-narrative-cleared)
        ((string-equal state "!") 'beancount-narrative-pending)
        (t 'beancount-narrative)))

(defun beancount-outline-face ()
  (if outline-minor-mode
      (cl-case (funcall outline-level)
      (1 'org-level-1)
      (2 'org-level-2)
      (3 'org-level-3)
      (4 'org-level-4)
      (5 'org-level-5)
      (6 'org-level-6)
      (otherwise nil))
    nil))

(defvar beancount-font-lock-keywords
  `((,beancount-transaction-regexp (1 'beancount-date)
                                   (2 (beancount-face-by-state (match-string 2)) t)
                                   (3 (beancount-face-by-state (match-string 2)) t))
    (,beancount-posting-regexp (1 'beancount-account)
                               (2 'beancount-amount nil :lax))
    (,beancount-metadata-regexp (1 'beancount-metadata)
                                (2 'beancount-metadata t))
    (,beancount-directive-regexp (1 'beancount-directive))
    (,beancount-timestamped-directive-regexp (1 'beancount-date)
                                             (2 'beancount-directive))
    ;; Fontify section headers when composed with outline-minor-mode.
    (,(concat "^\\(" beancount-outline-regexp "\\).*") . (0 (beancount-outline-face)))
    ;; Tags and links.
    (,(concat "\\#[" beancount-tag-chars "]*") . 'beancount-tag)
    (,(concat "\\^[" beancount-tag-chars "]*") . 'beancount-link)
    ;; Number followed by currency not covered by previous rules.
    (,(concat beancount-number-regexp "\\s-+" beancount-currency-regexp) . 'beancount-amount)
    ;; Accounts not covered by previous rules.
    (,beancount-account-regexp . 'beancount-account)
    ))

(defun beancount-tab-dwim (&optional arg)
  (interactive "P")
  (if (and outline-minor-mode
           (or arg (outline-on-heading-p)))
      (beancount-outline-cycle arg)
    (indent-for-tab-command)))

(defvar beancount-mode-map-prefix [(control c)]
  "The prefix key used to bind Beancount commands in Emacs")

(defvar beancount-mode-map
  (let ((map (make-sparse-keymap))
        (p beancount-mode-map-prefix))
    (define-key map (kbd "TAB") #'beancount-tab-dwim)
    (define-key map (kbd "M-RET") #'beancount-insert-date)
    (define-key map (vconcat p [(\')]) #'beancount-insert-account)
    (define-key map (vconcat p [(control g)]) #'beancount-transaction-clear)
    (define-key map (vconcat p [(l)]) #'beancount-check)
    (define-key map (vconcat p [(q)]) #'beancount-query)
    (define-key map (vconcat p [(x)]) #'beancount-context)
    (define-key map (vconcat p [(k)]) #'beancount-linked)
    (define-key map (vconcat p [(p)]) #'beancount-insert-prices)
    (define-key map (vconcat p [(\;)]) #'beancount-align-to-previous-number)
    (define-key map (vconcat p [(\:)]) #'beancount-align-numbers)
    map))

(defvar beancount-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?\" "\"\"" st)
    (modify-syntax-entry ?\; "<" st)
    (modify-syntax-entry ?\n ">" st)
    st))

;;;###autoload
(define-derived-mode beancount-mode fundamental-mode "Beancount"
  "A mode for Beancount files.
\\{beancount-mode-map}"
  :group 'beancount
  :syntax-table beancount-mode-syntax-table

  (setq-local paragraph-ignore-fill-prefix t)
  (setq-local fill-paragraph-function #'beancount-indent-transaction)

  (setq-local comment-start ";")
  (setq-local comment-start-skip ";+\\s-*")
  (setq-local comment-add 1)

  (setq-local indent-line-function #'beancount-indent-line)
  (setq-local indent-region-function #'beancount-indent-region)
  (setq-local indent-tabs-mode nil)

  (setq-local tab-always-indent 'complete)
  (setq-local completion-ignore-case t)
  
  (add-hook 'completion-at-point-functions #'beancount-completion-at-point nil t)
  (add-hook 'post-command-hook #'beancount-highlight-transaction-at-point nil t)
  (add-hook 'post-self-insert-hook #'beancount--electric-currency nil t)
  
  (setq-local font-lock-defaults '(beancount-font-lock-keywords))
  (setq-local font-lock-syntax-table t)

  (setq-local outline-regexp beancount-outline-regexp)
  (setq-local outline-level #'beancount-outline-level)

  (setq imenu-generic-expression
	(list (list nil (concat "^" beancount-outline-regexp "\\s-+\\(.*\\)$") 2))))

(defun beancount-collect-pushed-tags (begin end)
  "Return list of all pushed (and not popped) tags in the region."
  (goto-char begin)
  (let ((tags (make-hash-table :test 'equal)))
    (while (re-search-forward
         (concat "^\\(push\\|pop\\)tag\\s-+\\(#[" beancount-tag-chars "]+\\)") end t)
      (if (string-equal (match-string 1) "push")
          (puthash (match-string-no-properties 2) nil tags)
        (remhash (match-string-no-properties 2) tags)))
    (hash-table-keys tags)))

(defun beancount-goto-transaction-begin ()
  "Move the cursor to the first line of the transaction definition."
  (interactive)
  (beginning-of-line)
  ;; everything that is indented with at lest one space or tab is part
  ;; of the transaction definition
  (while (looking-at-p "[ \t]+")
    (forward-line -1))
  (point))

(defun beancount-goto-transaction-end ()
  "Move the cursor to the line after the transaction definition."
  (interactive)
  (beginning-of-line)
  (if (looking-at-p beancount-transaction-regexp)
      (forward-line))
  ;; everything that is indented with at least one space or tab as part
  ;; of the transaction definition
  (while (looking-at-p "[ \t]+")
    (forward-line))
  (point))

(defun beancount-goto-next-transaction (&optional arg)
  "Move to the next transaction.
With an argument move to the next non cleared transaction."
  (interactive "P")
  (beancount-goto-transaction-end)
  (let ((done nil))
    (while (and (not done)
                (re-search-forward beancount-transaction-regexp nil t))
      (if (and arg (string-equal (match-string 2) "*"))
          (goto-char (match-end 0))
        (goto-char (match-beginning 0))
        (setq done t)))
    (if (not done) (goto-char (point-max)))))

(defun beancount-find-transaction-extents (p)
  (save-excursion
    (goto-char p)
    (list (beancount-goto-transaction-begin)
          (beancount-goto-transaction-end))))

(defun beancount-inside-transaction-p ()
  (let ((bounds (beancount-find-transaction-extents (point))))
    (> (- (cadr bounds) (car bounds)) 0)))

(defun beancount-looking-at (regexp n pos)
  (and (looking-at regexp)
       (>= pos (match-beginning n))
       (<= pos (match-end n))))

(defvar beancount-accounts nil
  "A list of the accounts available in this buffer.")
(make-variable-buffer-local 'beancount-accounts)

(defun beancount-completion-at-point ()
  "Return the completion data relevant for the text at point."
  (save-excursion
    (save-match-data
      (let ((pos (point)))
        (beginning-of-line)
        (cond
         ;; non timestamped directive
         ((beancount-looking-at "[a-z]*" 0 pos)
          (list (match-beginning 0) (match-end 0)
                (mapcar (lambda (s) (concat s " ")) beancount-directive-names)))

         ;; poptag
         ((beancount-looking-at
           (concat "poptag\\s-+\\(\\(?:#[" beancount-tag-chars "]*\\)\\)") 1 pos)
          (list (match-beginning 1) (match-end 1)
                (beancount-collect-pushed-tags (point-min) (point))))

         ;; option
         ((beancount-looking-at
           (concat "^option\\s-+\\(\"[a-z_]*\\)") 1 pos)
          (list (match-beginning 1) (match-end 1)
                (mapcar (lambda (s) (concat "\"" s "\" ")) beancount-option-names)))

         ;; timestamped directive
         ((beancount-looking-at
           (concat beancount-date-regexp "\\s-+\\([[:alpha:]]*\\)") 1 pos)
          (list (match-beginning 1) (match-end 1)
                (mapcar (lambda (s) (concat s " ")) beancount-timestamped-directive-names)))

         ;; timestamped directives followed by account
         ((beancount-looking-at
           (concat "^" beancount-date-regexp
                   "\\s-+" (regexp-opt beancount-account-directive-names)
                   "\\s-+\\([" beancount-account-chars "]*\\)") 1 pos)
          (setq beancount-accounts nil)
          (list (match-beginning 1) (match-end 1) #'beancount-account-completion-table))

         ;; posting
         ((and (beancount-looking-at
                (concat "[ \t]+\\([" beancount-account-chars "]*\\)") 1 pos)
               ;; Do not force the account name to start with a
               ;; capital, so that it is possible to use substring
               ;; completion and we can rely on completion to fix
               ;; capitalization thanks to completion-ignore-case.
               (beancount-inside-transaction-p))
          (setq beancount-accounts nil)
          (list (match-beginning 1) (match-end 1) #'beancount-account-completion-table))

         ;; tags
         ((beancount-looking-at
           (concat "[ \t]+#\\([" beancount-tag-chars "]*\\)") 1 pos)
          (let* ((candidates nil)
                 (regexp (concat "\\#\\([" beancount-tag-chars "]+\\)"))
                 (completion-table
                  (lambda (string pred action)
                    (if (null candidates)
                        (setq candidates
                              (sort (beancount-collect regexp 1) #'string<)))
                    (complete-with-action action candidates string pred))))
            (list (match-beginning 1) (match-end 1) completion-table)))

         ;; links
         ((beancount-looking-at
           (concat "[ \t]+\\^\\([" beancount-tag-chars "]*\\)") 1 pos)
          (let* ((candidates nil)
                 (regexp (concat "\\^\\([" beancount-tag-chars "]+\\)"))
                 (completion-table
                  (lambda (string pred action)
                    (if (null candidates)
                        (setq candidates
                              (sort (beancount-collect regexp 1) #'string<)))
                    (complete-with-action action candidates string pred))))
            (list (match-beginning 1) (match-end 1) completion-table))))))))

(defun beancount-collect (regexp n)
  "Return an unique list of REGEXP group N in the current buffer."
  (let ((pos (point)))
    (save-excursion
      (save-match-data
        (let ((hash (make-hash-table :test 'equal)))
          (goto-char (point-min))
          (while (re-search-forward regexp nil t)
            ;; Ignore matches around `pos' (the point position when
            ;; entering this funcyion) since that's presumably what
            ;; we're currently trying to complete.
            (unless (<= (match-beginning 0) pos (match-end 0))
              (puthash (match-string-no-properties n) nil hash)))
          (hash-table-keys hash))))))

(defun beancount-account-completion-table (string pred action)
  (if (eq action 'metadata) '(metadata (category . beancount-account))
    (if (null beancount-accounts)
        (setq beancount-accounts
              (sort (beancount-collect beancount-account-regexp 0) #'string<)))
    (complete-with-action action beancount-accounts string pred)))

;; Default to substring completion for beancount accounts.
(defconst beancount--completion-overrides
  '(beancount-account (styles basic partial-completion substring)))
(add-to-list 'completion-category-defaults beancount--completion-overrides)

(defun beancount-number-alignment-column ()
  "Return the column to which postings amounts should be aligned to.
Returns `beancount-number-alignment-column' unless it is 0. In
that case, scan the buffer to determine the minimum column that
will allow to align all numbers."
  (if (> beancount-number-alignment-column 0)
      beancount-number-alignment-column
    (save-excursion
      (save-match-data
        (let ((account-width 0)
              (number-width 0))
          (goto-char (point-min))
          (while (re-search-forward beancount-posting-regexp nil t)
            (if (match-string 2)
                (let ((accw (- (match-end 1) (line-beginning-position)))
                      (numw (- (match-end 3) (match-beginning 3))))
                  (setq account-width (max account-width accw)
                        number-width (max number-width numw)))))
          (+ account-width 2 number-width))))))

(defun beancount-compute-indentation ()
  "Return the column to which the current line should be indented."
  (save-excursion
    (beginning-of-line)
    (cond
     ;; Only timestamped directives start with a digit.
     ((looking-at-p "[0-9]") 0)
     ;; Otherwise look at the previous line.
     ((and (= (forward-line -1) 0)
           (or (looking-at-p "[ \t].+")
               (looking-at-p beancount-timestamped-directive-regexp)
               (looking-at-p beancount-transaction-regexp)))
      beancount-transaction-indent)
     ;; Default.
     (t 0))))

(defun beancount-align-number (target-column)
  (save-excursion
    (beginning-of-line)
    ;; Check if the current line is a posting with a number to align.
    (when (and (looking-at beancount-posting-regexp)
               (match-string 2))
      (let* ((account-end-column (- (match-end 1) (line-beginning-position)))
             (number-width (- (match-end 3) (match-beginning 3)))
             (account-end (match-end 1))
             (number-beginning (match-beginning 3))
             (spaces (max 2 (- target-column account-end-column number-width))))
        (unless (eq spaces (- number-beginning account-end))
          (goto-char account-end)
          (delete-region account-end number-beginning)
          (insert (make-string spaces ? )))))))

(defun beancount-indent-line ()
  (let ((indent (beancount-compute-indentation))
        (savep (> (current-column) (current-indentation))))
    (unless (eq indent (current-indentation))
      (if savep (save-excursion (indent-line-to indent))
        (indent-line-to indent)))
    (unless (eq this-command 'beancount-tab-dwim)
      (beancount-align-number (beancount-number-alignment-column)))))

(defun beancount-indent-region (start end)
  "Indent a region automagically. START and END specify the region to indent."
  (let ((deactivate-mark nil)
        (beancount-number-alignment-column (beancount-number-alignment-column)))
    (save-excursion
      (setq end (copy-marker end))
      (goto-char start)
      (or (bolp) (forward-line 1))
      (while (< (point) end)
        (unless (looking-at-p "\\s-*$")
          (beancount-indent-line))
        (forward-line 1))
      (move-marker end nil))))

(defun beancount-indent-transaction (&optional _justify _region)
  "Indent Beancount transaction at point."
  (interactive)
  (save-excursion
    (let ((bounds (beancount-find-transaction-extents (point))))
      (beancount-indent-region (car bounds) (cadr bounds)))))

(defun beancount-transaction-clear (&optional arg)
  "Clear transaction at point. With a prefix argument set the
transaction as pending."
  (interactive "P")
  (save-excursion
    (save-match-data
      (let ((flag (if arg "!" "*")))
        (beancount-goto-transaction-begin)
        (if (looking-at beancount-transaction-regexp)
            (replace-match flag t t nil 2))))))

(defun beancount-insert-account (account-name)
  "Insert one of the valid account names in this file.
Uses ido niceness according to `beancount-use-ido'."
  (interactive
   (list
    (if beancount-use-ido
        ;; `ido-completing-read' does not understand functional
        ;; completion tables thus directly build a list of the
        ;; accounts in the buffer
        (let ((beancount-accounts
               (sort (beancount-collect beancount-account-regexp 0) #'string<)))
          (ido-completing-read "Account: " beancount-accounts
                               nil nil (thing-at-point 'word)))
      (completing-read "Account: " #'beancount-account-completion-table
                       nil t (thing-at-point 'word)))))
  (let ((bounds (bounds-of-thing-at-point 'word)))
    (when bounds
      (delete-region (car bounds) (cdr bounds))))
  (insert account-name))

(defmacro beancount-for-line-in-region (begin end &rest exprs)
  "Iterate over each line in region until an empty line is encountered."
  `(save-excursion
     (let ((end-marker (copy-marker ,end)))
       (goto-char ,begin)
       (beginning-of-line)
       (while (and (not (eobp)) (< (point) end-marker))
         (beginning-of-line)
         (progn ,@exprs)
         (forward-line 1)
         ))))

(defun beancount-align-numbers (begin end &optional requested-currency-column)
  "Align all numbers in the given region. CURRENCY-COLUMN is the character
at which to align the beginning of the amount's currency. If not specified, use
the smallest columns that will align all the numbers.  With a prefix argument,
align with the fill-column."
  (interactive "r")

  ;; With a prefix argument, align with the fill-column.
  (when current-prefix-arg
    (setq requested-currency-column fill-column))

  ;; Loop once in the region to find the length of the longest string before the
  ;; number.
  (let (prefix-widths
        number-widths
        (number-padding "  "))
    (beancount-for-line-in-region
     begin end
     (let ((line (thing-at-point 'line)))
       (when (string-match (concat "\\(.*?\\)"
                                   "[ \t]+"
                                   "\\(" beancount-number-regexp "\\)"
                                   "[ \t]+"
                                   beancount-currency-regexp)
                           line)
         (push (length (match-string 1 line)) prefix-widths)
         (push (length (match-string 2 line)) number-widths)
         )))

    (when prefix-widths
      ;; Loop again to make the adjustments to the numbers.
      (let* ((number-width (apply 'max number-widths))
             (number-format (format "%%%ss" number-width))
             ;; Compute rightmost column of prefix.
             (max-prefix-width (apply 'max prefix-widths))
             (max-prefix-width
              (if requested-currency-column
                  (max (- requested-currency-column (length number-padding) number-width 1)
                       max-prefix-width)
                max-prefix-width))
             (prefix-format (format "%%-%ss" max-prefix-width))
             )

        (beancount-for-line-in-region
         begin end
         (let ((line (thing-at-point 'line)))
           (when (string-match (concat "^\\([^\"]*?\\)"
                                       "[ \t]+"
                                       "\\(" beancount-number-regexp "\\)"
                                       "[ \t]+"
                                       "\\(.*\\)$")
                               line)
             (delete-region (line-beginning-position) (line-end-position))
             (let* ((prefix (match-string 1 line))
                    (number (match-string 2 line))
                    (rest (match-string 3 line)) )
               (insert (format prefix-format prefix))
               (insert number-padding)
               (insert (format number-format number))
               (insert " ")
               (insert rest)))))))))

(defun beancount-align-to-previous-number ()
  "Align postings under the point's paragraph.
This function looks for a posting in the previous transaction to
determine the column at which to align the transaction, or otherwise
the fill column, and align all the postings of this transaction to
this column."
  (interactive)
  (let* ((begin (save-excursion
                  (beancount-beginning-of-directive)
                  (point)))
         (end (save-excursion
                (goto-char begin)
                (forward-paragraph 1)
                (point)))
         (currency-column (or (beancount-find-previous-alignment-column)
                              fill-column)))
    (beancount-align-numbers begin end currency-column)))


(defun beancount-beginning-of-directive ()
  "Move point to the beginning of the enclosed or preceding directive."
  (beginning-of-line)
  (while (and (> (point) (point-min))
              (not (looking-at
                      "[0-9][0-9][0-9][0-9][\-/][0-9][0-9][\-/][0-9][0-9]")))
    (forward-line -1)))


(defun beancount-find-previous-alignment-column ()
  "Find the preceding column to align amounts with.
This is used to align transactions at the same column as that of
the previous transaction in the file. This function merely finds
what that column is and returns it (an integer)."
  ;; Go hunting for the last column with a suitable posting.
  (let (column)
    (save-excursion
      ;; Go to the beginning of the enclosing directive.
      (beancount-beginning-of-directive)
      (forward-line -1)

      ;; Find the last posting with an amount and a currency on it.
      (let ((posting-regexp (concat
                             "\\s-+"
                             beancount-account-regexp "\\s-+"
                             beancount-number-regexp "\\s-+"
                             "\\(" beancount-currency-regexp "\\)"))
            (balance-regexp (concat
                             beancount-date-regexp "\\s-+"
                             "balance" "\\s-+"
                             beancount-account-regexp "\\s-+"
                             beancount-number-regexp "\\s-+"
                             "\\(" beancount-currency-regexp "\\)")))
        (while (and (> (point) (point-min))
                    (not (or (looking-at posting-regexp)
                             (looking-at balance-regexp))))
          (forward-line -1))
        (when (or (looking-at posting-regexp)
                  (looking-at balance-regexp))
          (setq column (- (match-beginning 1) (point))))
        ))
    column))

(defun beancount--account-currency (account)
  ;; Build a regexp that matches an open directive that specifies a
  ;; single account currencydaaee. The currency is match group 1.
  (let ((re (concat "^" beancount-date-regexp " +open"
                    "\\s-+" (regexp-quote account)
                    "\\s-+\\(" beancount-currency-regexp "\\)\\s-+")))
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward re nil t)
        ;; The account has declared a single currency, so we can fill it in.
        (match-string-no-properties 1)))))

(defun beancount--electric-currency ()
  (when (and beancount-electric-currency (eq last-command-event ?\n))
    (save-excursion
      (forward-line -1)
      (when (and (beancount-inside-transaction-p)
                 (looking-at (concat "\\s-+\\(" beancount-account-regexp "\\)"
                                     "\\s-+\\(" beancount-number-regexp "\\)\\s-*$")))
        ;; Last line is a posting without currency.
        (let* ((account (match-string 1))
               (pos (match-end 0))
               (currency (beancount--account-currency account)))
          (when currency
            (save-excursion
	      (goto-char pos)
              (insert " " currency))))))))

(defun beancount-insert-date ()
  "Start a new timestamped directive."
  (interactive)
  (unless (bolp) (newline))
  (insert (format-time-string "%Y-%m-%d") " "))

(defvar beancount-install-dir nil
  "Directory in which Beancount's source is located.
Only useful if you have not installed Beancount properly in your PATH.")

(defvar beancount-check-program "bean-check"
  "Program to run to run just the parser and validator on an
  input file.")

(defvar compilation-read-command)

(defun beancount--run (prog &rest args)
  (let ((process-environment
         (if beancount-install-dir
             `(,(concat "PYTHONPATH=" beancount-install-dir)
               ,(concat "PATH="
                        (expand-file-name "bin" beancount-install-dir)
                        ":"
                        (getenv "PATH"))
               ,@process-environment)
           process-environment))
        (compile-command (mapconcat (lambda (arg)
                                      (if (stringp arg)
                                          (shell-quote-argument arg) ""))
                                    (cons prog args)
                                    " ")))
    (call-interactively 'compile)))

(defun beancount-check ()
  "Run `beancount-check-program'."
  (interactive)
  (let ((compilation-read-command nil))
    (beancount--run beancount-check-program
                    (file-relative-name buffer-file-name))))

(defvar beancount-query-program "bean-query"
  "Program to run to run just the parser and validator on an
  input file.")

(defun beancount-query ()
  "Run bean-query."
  (interactive)
  ;; Don't let-bind compilation-read-command this time, since the default
  ;; command is incomplete.
  (beancount--run beancount-query-program
                  (file-relative-name buffer-file-name) t))

(defvar beancount-doctor-program "bean-doctor"
  "Program to run the doctor commands.")

(defun beancount-context ()
  "Get the \"context\" from `beancount-doctor-program'."
  (interactive)
  (let ((compilation-read-command nil))
    (beancount--run beancount-doctor-program "context"
                    (file-relative-name buffer-file-name)
                    (number-to-string (line-number-at-pos)))))


(defun beancount-linked ()
  "Get the \"linked\" info from `beancount-doctor-program'."
  (interactive)
  (let ((compilation-read-command nil))
    (beancount--run beancount-doctor-program "linked"
                    (file-relative-name buffer-file-name)
                    (number-to-string (line-number-at-pos)))))

(defvar beancount-price-program "bean-price"
  "Program to run the price fetching commands.")

(defun beancount-insert-prices ()
  "Run bean-price on the current file and insert the output inline."
  (interactive)
  (call-process beancount-price-program nil t nil
                (file-relative-name buffer-file-name)))

;;; Transaction highligh

(defvar beancount-highlight-overlay (list))
(make-variable-buffer-local 'beancount-highlight-overlay)

(defun beancount-highlight-overlay-make ()
  (let ((overlay (make-overlay 1 1)))
    (overlay-put overlay 'face 'beancount-highlight)
    (overlay-put overlay 'priority '(nil . 99))
    overlay))

(defun beancount-highlight-transaction-at-point ()
  "Move the highlight overlay to the current transaction."
  (when beancount-highlight-transaction-at-point
    (unless beancount-highlight-overlay
      (setq beancount-highlight-overlay (beancount-highlight-overlay-make)))
    (let* ((bounds (beancount-find-transaction-extents (point)))
           (begin (car bounds))
           (end (cadr bounds)))
      (if (> (- end begin) 0)
          (move-overlay beancount-highlight-overlay begin end)
        (move-overlay beancount-highlight-overlay 1 1)))))

;;; Outline minor mode support.

(defun beancount-outline-cycle (&optional arg)
  "Implement visibility cycling a la `org-mode'.
The behavior of this command is determined by the first matching
condition among the following:
 1. When point is at the beginning of the buffer, or when called
    with a `\\[universal-argument]' universal argument, rotate the entire buffer
    through 3 states:
   - OVERVIEW: Show only top-level headlines.
   - CONTENTS: Show all headlines of all levels, but no body text.
   - SHOW ALL: Show everything.
 2. When point is at the beginning of a headline, rotate the
    subtree starting at this line through 3 different states:
   - FOLDED:   Only the main headline is shown.
   - CHILDREN: The main headline and its direct children are shown.
               From this state, you can move to one of the children
               and zoom in further.
   - SUBTREE:  Show the entire subtree, including body text."
  (interactive "P")
  (setq deactivate-mark t)
  (cond
   ;; Beginning of buffer or called with C-u: Global cycling
   ((or (equal arg '(4))
        (and (bobp)
             ;; org-mode style behaviour - only cycle if not on a heading
             (not (outline-on-heading-p))))
    (beancount-cycle-buffer))

   ;; At a heading: rotate between three different views
   ((save-excursion (beginning-of-line 1) (looking-at outline-regexp))
    (outline-back-to-heading)
    (let ((goal-column 0) eoh eol eos)
      ;; First, some boundaries
      (save-excursion
        (save-excursion (beancount-next-line) (setq eol (point)))
        (outline-end-of-heading)              (setq eoh (point))
        (outline-end-of-subtree)              (setq eos (point)))
      ;; Find out what to do next and set `this-command'
      (cond
       ((= eos eoh)
        ;; Nothing is hidden behind this heading
        (beancount-message "EMPTY ENTRY"))
       ((>= eol eos)
        ;; Entire subtree is hidden in one line: open it
        (outline-show-entry)
        (outline-show-children)
        (beancount-message "CHILDREN")
        (setq
         this-command 'beancount-cycle-children))
       ((eq last-command 'beancount-cycle-children)
        ;; We just showed the children, now show everything.
        (outline-show-subtree)
        (beancount-message "SUBTREE"))
       (t
        ;; Default action: hide the subtree.
        (outline-hide-subtree)
        (beancount-message "FOLDED")))))))

(defvar beancount-current-buffer-visibility-state nil
  "Current visibility state of buffer.")
(make-variable-buffer-local 'beancount-current-buffer-visibility-state)

(defvar beancount-current-buffer-visibility-state)

(defun beancount-cycle-buffer (&optional arg)
  "Rotate the visibility state of the buffer through 3 states:
  - OVERVIEW: Show only top-level headlines.
  - CONTENTS: Show all headlines of all levels, but no body text.
  - SHOW ALL: Show everything.
With a numeric prefix ARG, show all headlines up to that level."
  (interactive "P")
  (save-excursion
    (cond
     ((integerp arg)
      (outline-show-all)
      (outline-hide-sublevels arg))
     ((eq last-command 'beancount-cycle-overview)
      ;; We just created the overview - now do table of contents
      ;; This can be slow in very large buffers, so indicate action
      ;; Visit all headings and show their offspring
      (goto-char (point-max))
      (while (not (bobp))
        (condition-case nil
            (progn
              (outline-previous-visible-heading 1)
              (outline-show-branches))
          (error (goto-char (point-min)))))
      (beancount-message "CONTENTS")
      (setq this-command 'beancount-cycle-toc
            beancount-current-buffer-visibility-state 'contents))
     ((eq last-command 'beancount-cycle-toc)
      ;; We just showed the table of contents - now show everything
      (outline-show-all)
      (beancount-message "SHOW ALL")
      (setq this-command 'beancount-cycle-showall
            beancount-current-buffer-visibility-state 'all))
     (t
      ;; Default action: go to overview
      (let ((toplevel
             (cond
              (current-prefix-arg
               (prefix-numeric-value current-prefix-arg))
              ((save-excursion
                 (beginning-of-line)
                 (looking-at outline-regexp))
               (max 1 (funcall outline-level)))
              (t 1))))
        (outline-hide-sublevels toplevel))
      (beancount-message "OVERVIEW")
      (setq this-command 'beancount-cycle-overview
            beancount-current-buffer-visibility-state 'overview)))))

(defun beancount-message (msg)
  "Display MSG, but avoid logging it in the *Messages* buffer."
  (let ((message-log-max nil))
    (message msg)))

(defun beancount-next-line ()
  "Forward line, but mover over invisible line ends.
Essentially a much simplified version of `next-line'."
  (interactive)
  (beginning-of-line 2)
  (while (and (not (eobp))
              (get-char-property (1- (point)) 'invisible))
    (beginning-of-line 2)))

(provide 'beancount)

(defun beancount-fixme-replace ()
  "Search for next FIXME in ledger and insert account."
  (interactive)
  (if (search-forward "FIXME")
      (progn
        (replace-match "" nil nil)
        (call-interactively 'beancount-insert-account))))

; Custom keybinds for the entry view
(evil-define-key 'normal beancount-mode-map
  (kbd "C-c C-n") 'beancount-fixme-replace)

(use-package know-your-http-well
  :defer t)

(use-package elpy
  :ensure t
  :init
  (elpy-enable))

(setq python-shell-interpreter "jupyter"
      python-shell-interpreter-args "console --simple-prompt"
      python-shell-prompt-detect-failure-warning nil)
(add-to-list 'python-shell-completion-native-disabled-interpreters "jupyter")

(use-package cider)

(use-package flycheck
  :defer t
  :hook (lsp-mode . flycheck-mode))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :defer t
  :hook (org-mode
         emacs-lisp-mode
         js2-mode))

;; Example from the_dev_aspect's config

; (defun dw/generate-site ()
;   (interactive)
;   (start-process-shell-command "emacs" nil "emacs --batch -l ~/Projects/Writing/Blog/publish.el --funcall dw/publish"))

;; Add keybinds here to

; Use elfeed
(use-package elfeed
  :commands elfeed)

; Set default filter
(setq-default elfeed-search-filter "@1-week-ago")

; Use elfeed-org 
(use-package elfeed-org)
(elfeed-org)

; Set default org file for feed
(setq rmh-elfeed-org-files (list "~/devel/elisp/scratch/scratch-config/elfeed.org"))

; Update and open elfeed at the same time
(defun elfeed-open-and-update ()
  (interactive)
  (elfeed-update)
  (elfeed))

; Custom keybinds for the entry view
(evil-define-key 'normal elfeed-show-mode-map 
  "v" 'elfeed-download-yt-video 
  "a" 'elfeed-download-yt-audio)

; Custom keybinds for the feed view
(evil-define-key 'normal elfeed-search-mode-map 
  "r" 'elfeed-update)

; Fix keybinds for evil modes in elfeed
(add-to-list 'evil-emacs-state-modes 'elfeed-search-mode)
(add-to-list 'evil-emacs-state-modes 'elfeed-show-mode)

; Set executable path for the most illegal youtube-dl ;)
(setq youtube-dl-path "/usr/bin/youtube-dl")
; Set video/audio storage path
(setq youtube-dl-video-dir "~/media/video/youtube/")
(setq youtube-dl-audio-dir "~/media/audio/youtube/")

; Function to download youtube video while suppressing the pop-up
(defun elfeed-download-yt-video ()
  "Download a video using youtube-dl."
  (interactive)
  (message "Youtube video download started...")
  (call-process-shell-command (format "%s -o \"%s%s\" -f bestvideo+bestaudio --add-metadata %s > /dev/null 2>&1"
                               youtube-dl-path
                               youtube-dl-video-dir
                               "%(title)s.%(ext)s"
                               (elfeed-entry-link elfeed-show-entry)) nil 0))

; Function to download youtube audio while suppressing the pop-up
(defun elfeed-download-yt-audio ()
  "Download a video using youtube-dl."
  (interactive)
  (message "Youtube audio download started...")
  (call-process-shell-command (format "%s -o \"%s%s\" -f bestaudio --add-metadata --extract-audio --audio-format mp3 %s > /dev/null 2>&1"
                               youtube-dl-path
                               youtube-dl-audio-dir
                               "%(title)s.%(ext)s"
                               (elfeed-entry-link elfeed-show-entry)) nil 0))

; Function to download youtube video without suppressing the pop-up for debug purposes
(defun elfeed-download-yt-video-debug ()
  "Download a video using youtube-dl."
  (interactive)
  (async-shell-command (format "%s -o \"%s%s\" -f bestvideo+bestaudio --add-metadata %s"
                               youtube-dl-path
                               youtube-dl-video-dir
                               "%(title)s.%(ext)s"
                               (elfeed-entry-link elfeed-show-entry))))

; Function to download youtube audio without suppressing the pop-up for debug purposes
(defun elfeed-download-yt-audio-debug ()
  "Download a video using youtube-dl."
  (interactive)
  (async-shell-command (format "%s -o \"%s%s\" -f bestaudio --add-metadata --extract-audio --audio-format mp3 %s"
                               youtube-dl-path
                               youtube-dl-audio-dir
                               "%(title)s.%(ext)s"
                               (elfeed-entry-link elfeed-show-entry))))

; Commented this out for now I don't think I need this
; Add `youtube` tag to all videos
;(add-hook 'elfeed-new-entry-hook
;          (elfeed-make-tagger :feed-url "youtube\\.com"
;                              :add '(video youtube)))

(require 'elfeed-db)
(require 'xml-query)

(defgroup elfeed-youtube-parser nil
  "Parse video thumbnails and descriptions from youtube feeds."
  :group 'multimedia)

(defcustom elfeed-youtube-parser-tag 'youtube
  "The tag to use when looking for youtube entry in a feed."
  :type 'symbol
  :group 'elfeed-youtube-parser)

(defun elfeed-youtube-parser--make-html (thumbnail description)
  "Transforms `THUMBNAIL' link and `DESCRIPTION' string into html string."
  (format "<img src=\"%s\"><br><pre>%s</pre>"
          thumbnail description))

;;;###autoload
(defun elfeed-youtube-parser-parse-youtube (_type xml-entry db-entry)
  "Parse elfeed youtube entry.
If `XML-ENTRY' contains `YOUTUBE' tag, read `DB-ENTRY' and search
for thumbnail and video description. Then associate new
information with future `DB-ENTRY'. `TYPE' is ignored."

  (when (member elfeed-youtube-parser-tag (elfeed-entry-tags db-entry))
    (let ((thumbnail   (xml-query* (group thumbnail :url) xml-entry))
          (description (xml-query* (group description *) xml-entry)))
      (setf (elfeed-entry-content-type db-entry) 'html)
      (setf (elfeed-entry-content db-entry)
            (elfeed-youtube-parser--make-html thumbnail description)))))

(provide 'elfeed-youtube-parser)
;;; elfeed-youtube-parser.el ends here

(add-hook 'elfeed-new-entry-parse-hook 'elfeed-youtube-parser-parse-youtube)

(use-package mu4e
  :defer t
  :config
  ;; use mu4e for e-mail in emacs
  (setq mail-user-agent 'mu4e-user-agent)

  ;; default
  (setq mu4e-root-maildir "/home/tstarr/media/email/starrtyler88")

  (setq mu4e-drafts-folder "/[Gmail].Drafts")
  (setq mu4e-sent-folder   "/[Gmail].Sent Mail")
  (setq mu4e-trash-folder  "/[Gmail].Trash")

  ;; don't save message to Sent Messages, Gmail/IMAP takes care of this
  (setq mu4e-sent-messages-behavior 'delete)

  ;; (See the documentation for `mu4e-sent-messages-behavior' if you have
  ;; additional non-Gmail addresses and want assign them different
  ;; behavior.)

  ;; setup some handy shortcuts
  ;; you can quickly switch to your Inbox -- press ``ji''
  ;; then, when you want archive some messages, move them to
  ;; the 'All Mail' folder by pressing ``ma''.

  (setq mu4e-maildir-shortcuts
      '( (:maildir "/INBOX"              :key ?i)
        (:maildir "/[Gmail].Sent Mail"  :key ?s)
        (:maildir "/[Gmail].Trash"      :key ?t)
        (:maildir "/[Gmail].All Mail"   :key ?a)))

  ;; allow for updating mail using 'U' in the main view:
  (setq mu4e-get-mail-command "offlineimap")

  ;; something about ourselves
  (setq
    user-mail-address "starrtyler88@gmail.com"
    user-full-name  "Tyler Starr"
    mu4e-compose-signature
      (concat
        "Tyler Starr\n"
        "http://tstarr.us\n"))

  ;; sending mail -- replace USERNAME with your gmail username
  ;; also, make sure the gnutls command line utils are installed
  ;; package 'gnutls-bin' in Debian/Ubuntu

  (use-package smtpmail)
  (setq message-send-mail-function 'smtpmail-send-it
    starttls-use-gnutls t
    smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
    smtpmail-auth-credentials
      '(("smtp.gmail.com" 587 "starrtyler88@gmail.com" nil))
    smtpmail-default-smtp-server "smtp.gmail.com"
    smtpmail-smtp-server "smtp.gmail.com"
    smtpmail-smtp-service 587)

  ;; alternatively, for emacs-24 you can use:
  ;;(setq message-send-mail-function 'smtpmail-send-it
  ;;     smtpmail-stream-type 'starttls
  ;;     smtpmail-default-smtp-server "smtp.gmail.com"
  ;;     smtpmail-smtp-server "smtp.gmail.com"
  ;;     smtpmail-smtp-service 587)

  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t))

; Make ESC cancel all mini-buffer menus
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

; Make ESC cancel all mini-buffer menus
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

; Commands without sub-menus
(dw/leader-key-def
  "RET"  '(bookmark-jump         :which-key "Jump to Bookmark")
  "SPC"  '(project-find-file     :which-key "Find file in project")
  "'"    '(ivy-resume            :which-key "Resume last search")
  "."    '(find-file             :which-key "Find file")
  ":"    '(counsel-M-x           :which-key "M-x")
  ";"    '(eval-expression       :which-key "Eval expression")
  "<"    '(switch-to-buffer      :which-key "Switch buffer")
  "`"    '(switch-to-prev-buffer :which-key "Switch to last buffer")
  "C"    '(org-capture           :which-key "Org Capture")
  "a"    '(ace-window            :which-key "Select window"))
  ;"TAB"  '(:ignore t             :which-key "workspace")
  ;"b"    '(:ignore t             :which-key "buffer")
  ;"c"    '(:ignore t             :which-key "code")
  ;"f"    '(:ignore t             :which-key "file")
  ;"h"    '(:ignore t             :which-key "help")
  ;"i"    '(:ignore t             :which-key "insert")
  ;"n"    '(:ignore t             :which-key "notes")
  ;"o"    '(:ignore t             :which-key "open")
  ;"q"    '(:ignore t             :which-key "quit/session")
  ;"s"    '(:ignore t             :which-key "search")
  ;"t"    '(:ignore t             :which-key "toggle"))

; Menu for opening applications
(dw/leader-key-def
  "o"    '(:ignore t   :which-key "open")
  "om"    '(mu4e       :which-key "Mu4e")
  "oe"    '(elfeed     :which-key "Elfeed")
  "oa"    '(org-agenda :which-key "Agenda"))

; Open evil-window keybind menus
(dw/leader-key-def
  "w"  '(evil-window-map :which-key "window"))

; Commands for projectile projects
(dw/leader-key-def
  "p"  '(:ignore t :which-key "project")
  "p."  '(projectile-find-file                   :which-key "Find file in project")
  "p>"  '(projectile-find-file-in-known-projects :which-key "Find file in know projects")
  "p!"  '(projectile-run-shell-command-in-root   :which-key "Run cmd in project root")
  "pa"  '(projectile-add-known-project           :which-key "Add new project")
  "pb"  '(projectile-switch-to-buffer            :which-key "Switch to project buffer")
  "pc"  '(projectile-compile-project             :which-key "Compile in project")
  "pC"  '(projectile-repeat-last-command         :which-key "Repeat last command")
  "pd"  '(projectile-remove-known-project        :which-key "Remove known project")
  "pe"  '(projectile-edit-dir-locals             :which-key "Edit project .dir-locals")
  "pg"  '(projectile-configure-project           :which-key "Configure project")
  "pi"  '(projectile-invalidate-cache            :which-key "Invalidate project cache")
  "pk"  '(projectile-kill-buffers                :which-key "Kill project buffers")
  "po"  '(projectile-find-other-file             :which-key "Find other file")
  "pp"  '(projectile-switch-project              :which-key "Switch project")
  "pr"  '(projectile-recentf                     :which-key "Find recent project files")
  "pR"  '(projectile-run-project                 :which-key "Run project")
  "ps"  '(projectile-save-project-buffers        :which-key "Save project files")
  "pt"  '(magit-todos-list                       :which-key "List project todos")
  "pT"  '(projectile-test-project                :which-key "Test project"))

; Commands for magit
(dw/leader-key-def
  "g"   '(:ignore t                :which-key "git")
  "gs"  '(magit-status             :which-key "Status")
  "gd"  '(magit-diff-unstaged      :which-key "Diff Unstaged")
  "gc"  '(magit-branch-or-checkout :which-key "Branch or Checkout")
  "gb"  '(magit-branch             :which-key "Branch")
  "gP"  '(magit-push-current       :which-key "Push Current")
  "gp"  '(magit-pull-branch        :which-key "Pull Branch")
  "gf"  '(magit-fetch              :which-key "Fetch")
  "gF"  '(magit-fetch-all          :which-key "Fetch All")
  "gr"  '(magit-rebase             :which-key "Rebase")
  "gl"   '(:ignore t               :which-key "log")
  "glc" '(magit-log-current        :which-key "Log Current")
  "glf" '(magit-log-buffer-file    :which-key "Log Buffer File"))

; Keybinds
(dw/leader-key-def
  "u"   '(:ignore t :which-key "util"))

; Help 
(dw/leader-key-def
  "h"   '(:ignore t :which-key "help")
  "hw"  '(:ignore t :which-key "which-key")
  "hwm" '(which-key-show-major-mode :which-key "Major binds"))

; Buffer
(dw/leader-key-def
  "b"    '(:ignore t                          :which-key "buffer")
  "b["   '(previous-buffer                    :which-key "Previous buffer")
  "b]"   '(next-buffer                        :which-key "Next buffer")
  "bb"   '(persp-switch-to-buffer             :which-key "Switch workspace buffer")
  "bB"   '(switch-to-buffer                   :which-key "Switch buffer")
  "bb"   '(switch-to-buffer                   :which-key "Switch buffer")
  "bd"   '(kill-current-buffer                :which-key "Kill buffer")
  "bi"   '(ibuffer                            :which-key "ibuffer")
  "bk"   '(kill-current-buffer                :which-key "Kill buffer")
  "bl"   '(evil-switch-to-windows-last-buffer :which-key "Switch to last buffer")
  "bm"   '(bookmark-set                       :which-key "Set bookmark")
  "bM"   '(bookmark-delete                    :which-key "Delete bookmark")
  "bn"   '(next-buffer                        :which-key "Next buffer")
  "bN"   '(evil-buffer-new                    :which-key "New empty buffer")
  "bp"   '(previous-buffer                    :which-key "Previous buffer")
  "br"   '(revert-buffer                      :which-key "Revert buffer")
  "bs"   '(basic-save-buffer                  :which-key "Save buffer")
  "bS"   '(evil-write-all                     :which-key "Save all buffers")
  "bw"   '(burly-bookmark-windows             :which-key "Bookmark windows")
  "bz"   '(bury-buffer                        :which-key "Bury buffer"))

(dw/leader-key-def
  "d"   '(:ignore t :which-key "dired")
  "dd"  '(dired :which-key "here")
  "dh"  `(,(dw/dired-link "~") :which-key "home")
  "dn"  `(,(dw/dired-link "~/documents/org") :which-key "org")
  "do"  `(,(dw/dired-link "~/downloads") :which-key "downloads")
  "df"  `(,(dw/dired-link "~/media/pictures") :which-key "pictures")
  "dv"  `(,(dw/dired-link "~/netdrive/media/video") :which-key "video")
  "da"  `(,(dw/dired-link "~/netdrive/media/audio") :which-key "audio")
  "dx"  `(,(dw/dired-link "~/.xmonad") :which-key "xmonad")
  "dc"  `(,(dw/dired-link "~/.config") :which-key "configs")
  "de"  `(,(dw/dired-link "~/devel/elisp/scratch") :which-key "emacs")
  "dp"   '(:ignore t :which-key "play")
  "dpf"   '(mpv :which-key "file")
  "dpd"   '(mpv-dir :which-key "directory")
  "dpp"   '(mpv-playlist :which-key "playlist"))
