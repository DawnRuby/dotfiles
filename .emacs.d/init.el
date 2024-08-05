;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;+++++++++++++++++++Load Elpaca+++++++++++++++++++++++++++++++++++
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
(setq package-enable-at-startup nil)
(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))


;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;+++++++++++++++++++Install Packages+++++++++++++++++++++++++++++++
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
(elpaca
    (rust-mode :host github :repo "rust-lang/rust-mode")
    (message "Loading Rust mode.."))

(elpaca
  (rustic :host github :repo "emacs-rustic/rustic")
  (message "Loading rustic..."))

(elpaca
  (org-caldav :host github :repo "dengste/org-caldav")
  (message "Loading Caldav"))

(elpaca (emms)
  (message "Loading emms..."))

(elpaca (org)
  (message "Loading org mode..."))


;; Make Window Transparent
(set-frame-parameter nil 'alpha-background 85) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background . 85)) ; For all new frames henceforth

;; Customize our font
;; Main typeface
(set-face-attribute 'default nil :family "FiraCode Nerd Font Mono" :height 140)

;; Blink cursor 30 times before stopping
(blink-cursor-mode 30)

;; Change Cursor type
(setq-default cursor-type 'bar) 

;; Override certain things in our theme
(setq modus-themes-common-palette-overrides
      `(
	(black-dark "#000000")
	(black "#0e0e0e")
	(black-light "#262626")
	(black-light-light "#9f9f9f")
	(gray black-light)
	(gray-light black-light-light)

	(white-dark-dark "#585655")
	(white-dark "#afadaa")
	(white "#dbd8d4")
	(white-light "#e6e4e1")
	(white-light-light "#f4f3f2")

	(blue-dark-dark "#1d4c70")
	(blue-dark "#2e7ab3")
	(blue "#3a98e0")
	(blue-light "#61ADE6")
	(blue-light-light "#9DCCF0")
	(blue-light-light "#D8EAF9")

	(red-dark-dark "642025")
	(red-dark "9f323b")
	(red "#c73f4a")
	(red-light "#d87980")
	(red-light-light "#e9b2b7")

	(pink-dark-dark "#7f1958")
	(pink-dark "#cb288c")
	(pink "#fe32af")
	(pink-light "#fe70c7")
	(pink-light-light "#ffaddf")

	(yellow-dark-dark "#975f14")
	(yellow-dark "#ca7e1a")
	(yellow "#fc9e21")
	(yellow-light "#fdb14d")
	(yellow-light-light "#fecf90")

	(brown-dark-dark "#3b3328")
	(brown-dark "#766651")	
	(brown "#948065")
	(brown-light "#b4a693")
	(brown-light-light "#cac0b2")

	(purple-dark-dark "#462570")
	(purple-dark "#5d3196")
	(purple "#743dbb")
	(purple-light "#9064c9")
	(purple-light-light "#c7b1e4")

	(green-dark-dark "#1d6614")
	(green-dark "#3acb28")
	(green "#49fe32")
	(green-light "#6dfe5b")
	(green-light-light "#b6ffad")

	;; Customize the background and foreground
	(bg-main black)
	(bg-inactive gray)
	(fg-main white)
	
	;; Customize our cursor
	(cursor pink)
	
	;; Customize mode line
	(border-mode-line-active unspecified)
        (border-mode-line-inactive unspecified)      
	(bg-mode-line-active gray)
	(bg-mode-line-inactive white)
	(fg-mode-line-active white)
	(fg-mode-line-inactive white)
	
	;; Make matching parenthesis more or less intense
	(bg-paren-match white)
	(fg-paren-match black)
        (underline-paren-match unspecified)

	;; Customize Fringe (padding around the window)
	(fringe gray)

	;; Customize Links ( https://google.com )
	(underline-link border)
        (underline-link-visited border)
        (underline-link-symbolic border)

	;; Customize Prompts
	(fg-prompt pink-light)
        (bg-prompt gray)

        ;; Customize auto completions
	(fg-completion-match-0 blue)
        (fg-completion-match-1 green)
        (fg-completion-match-2 pink)
        (fg-completion-match-3 red)
        (bg-completion-match-0 black)
        (bg-completion-match-1 black)
        (bg-completion-match-2 black)
        (bg-completion-match-3 black)

	;; Customize data types and comments
	(builtin green-light)
        (comment brown)
        (constant pink)
        (fnname pink-light)
        (keyword blue)
        (preprocessor red-light)
        (docstring pink-light-light)
        (string blue-light)
        (type pink-dark)
        (variable green-dark)

	;; Customize Line Numbers
	(fg-line-number-inactive fg-main)
        (fg-line-number-active black)
        (bg-line-number-inactive gray)
        (bg-line-number-active white)

	;; Customize mouse highlights
	(bg-hover green-light)

	;; Customize language underlines
	(underline-err red)
        (underline-warning yellow)
        (underline-note blue-light)

	;; Customize matching parenthesis
	(bg-paren-match pink)

	;; Customize box buttons
	(bg-button-active bg-main)
        (fg-button-active fg-main)
        (bg-button-inactive bg-inactive)
        (fg-button-inactive gray)

	;; Customize diffs
	(bg-added           unspecified)
        (bg-added-faint     unspecified)
        (bg-added-refine    bg-inactive)
        (fg-added           green)
        (fg-added-intense   green-light)

        (bg-changed         unspecified)
        (bg-changed-faint   unspecified)
        (bg-changed-refine  bg-inactive)
        (fg-changed         yellow)
        (fg-changed-intense yellow-light)

        (bg-removed         unspecified)
        (bg-removed-faint   unspecified)
        (bg-removed-refine  bg-inactive)
        (fg-removed         red)
        (fg-removed-intense red-light)

        (bg-diff-context    unspecified)

	;; Customize Todo and Done
	(prose-done green-light)
        (prose-todo yellow-light)

	;; Customize org blocks
	(bg-prose-block-contents pink-light-light)
        (bg-prose-block-delimiter purple-light)
        (fg-prose-block-delimiter fg-main)

	;; Customize org agendas	
	(date-common blue-light)   ; default value (for timestamps and more)
        (date-deadline red-light)
        (date-event purple-light)
        (date-holiday blue) ; for M-x calendar
        (date-now yellow-light)
        (date-scheduled purple-dark)
        (date-weekday blue-dark)
        (date-weekend blue-light-light)

	;; Make inline code in prose use alt styles
	(bg-prose-code unspecified)
        (fg-prose-code green-light-light)
        (bg-prose-verbatim unspecified)
        (fg-prose-verbatim pink-light-light)
        (bg-prose-macro unspecified)
        (fg-prose-macro purple-light-light)

	(bg-tab-bar gray)
        (bg-tab-current bg-active)
        (bg-tab-other bg-dim)
	))

;; Load Modus-Viventi (Dark Theme) by default
(load-theme 'modus-vivendi t)

;;;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;+++++++++++++++++++Customize Emacs Functions+++++++++++++++++++++
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; Set our folder where deleted files go to ~/.Trash
(setq backup-directory-alist            '((".*" . "~/.Trash")))

;; Disable Scrollbar and tool / menu bar
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; Show line numbers
(global-display-line-numbers-mode 1)

;; Saves a list of recently opened files.
(recentf-mode 1)

;; History of files we opened
(setq history-length 25)

;; Saves our minibuffer history
(savehist-mode 1)

;; Saves our position in the file
(save-place-mode 1)



;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;+++++++++++++++++++Customize Packages++++++++++++++++++++++++++++
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;; Configure emms to make it load a bit faster

;; Configure ERC
(setq
 erc-server "irc.libra.chat"
 erc-nick "sudoredact"
 erc-user-full-name "Sudo"
 erc-track-shorten-start 8
 erc-autojoin-channels-alist '(("irc.libera.chat" "#emacs")))

;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;+++++++++++++++++++Create custom commands++++++++++++++++++++++++
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; Define custom functions to make my life a bit easier :3
(defun shuffle-music ()
  "Shuffle through my music."
  (interactive)
  (emms-stop)
  (when (bufferp emms-playlist-buffer-name)
    (kill-buffer emms-playlist-buffer-name))
  (emms-play-directory-tree "~/Music")
  (emms-shuffle)
  (emms-next))
