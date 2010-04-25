;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Copyright (C) 2003-2007 Troels Henriksen <athas@sigkill.dk>
;;;;
;;;; Some parts are Copyright (C) the Free Software Foundation and other
;;;; people.
;;;;
;;;; This program is free software; you can redistribute it and/or
;;;; modify it under the terms of the GNU General Public License as
;;;; published by the Free Software Foundation; either version 2 of
;;;; the License, or (at your option) any later version.
;;;;  
;;;; This program is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; General Public License for more details.
;;;;  
;;;; You should have received a copy of the GNU General Public License
;;;; along with this program; if not, write to the Free Software
;;;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
;;;; 02111-1307, USA.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; GNU EMACS CONFIGURATION FILE      ;;;;
;;;  Troels Henriksen's .emacs         ;;;
;;   10 September 2004 (yeah right)    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;; IMPORTANT NOTICE: This .emacs is designed for Emacs 22, and is
;;;; likely *NOT* to work in other versions.
;;;;
;;;; The code within is probably not the cleanest around, and it is
;;;; designed for GNU/Linux systems and GNU Emacs, so portability is
;;;; probably non-existant. As usual, "use at own risk," but I guess
;;;; you already knew that.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; Utility Lisp functions:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun trh-value-to-string (value)
  "Convert VALUE to string. 
This function will automatically identify the type of VALUE, and invoke
the appropiate conversion function"
(cond ((symbolp value)
       (symbol-name value))
      ((numberp value)
       (number-to-string value))
      (t
       (error "Cannot convert value to string."))))

(defun trh-read-lines-in-buffer (&optional buffer)
  "Return list of lines in current buffer.
If BUFFER if non-nil, switch to BUFFER before reading lines. The list returned
will be in reverse with regard to the sequence of lines in the buffer read. 
Empty lines will not be ignored."
  (save-excursion
    (when buffer
      (set-buffer buffer))
    (let (stringlist)
      ;; Start from beginning of buffer, remembering to save point.
      (goto-char (point-min))
      (while (not (eobp))
        ;; Because we push the new line to the front of the list, and we start
        ;; from the beginning of the buffer, the list will be backwards.
        ;; Should this be fixed?
        (push (buffer-substring-no-properties 
               (line-beginning-position)
               (line-end-position))
              stringlist)
        (forward-line))
      stringlist)))

(defun make-incr-list (length &optional start)
  "Return list of size LENGTH with increasing values.
The first element in the list is START, the second is START+1, and so forth."
  (or start
      (setq start 0))
  (if (plusp length)
      (cons start (make-incr-list (1- length) (1+ start)))
    nil))

(defun make-symbol-list (elements &optional prefix)
  "Turn list of values into list of symbols.
The list returned will contain symbols, whose names correspond to the values
in ELEMENTS. If PREFIX is non-nil, the name of every symbol will be prefixed
with PREFIX."
  (if elements
      (cons (intern (concat prefix
                            (trh-value-to-string (car elements))))
            (make-symbol-list (cdr elements) prefix))
    nil))

(defun combine-lists (lists &optional number list-prefix)
  "Combine LISTS into calls of list-elements.
The list elements will be numbered from NUMBER. LIST-PREFIX will added to the 
front of the final list. The return value is a list of Lisp-code that should
be evaluated for side-effects."
  (or number
      (setq number 0))
  (if lists
      (progn
        `(dolist (,(intern (concat "element-"
                                   (number-to-string number)))
                  ;; If the list is an explicit list, and not a symbol, it will
                  ;; have to be quoted.
                  ,(if (symbolp (car lists)) 
                       (car lists)
                     `(quote ,(car lists))))
           ,(combine-lists (cdr lists) (1+ number) list-prefix)))
    (if list-prefix
        (cons list-prefix (make-symbol-list (make-incr-list number) "element-"))
      (make-symbol-list (make-incr-list number) "element-"))))

(defmacro combine-calls (combinators)
  (combine-lists combinators 0 'funcall))

(require 'cl)

(defun noerr-require (feature)
  "`require' FEATURE, but don't invoke any Lisp errors.
If FEATURE cannot be loaded, this function will print an error
message through `message' and return nil. It otherwise behaves
exactly as `require'."
  (ignore-errors
    (require feature (symbol-name feature) t)))

(defmacro with-feature (feature &rest body)
  "Require FEATURE and execute BODY.
If FEATURE can't be loaded, don't execute BODY."
  (when (noerr-require (car feature))
    (push 'progn body)))

(defmacro with-features (features &rest body)
  "Require FEATURES and execute BODY.
If any of FEATURES cannot be loaded, don't execute BODY."
  (if features
      `(with-feature (,(first features))
         (with-features ,(cdr features)
           ,@body))
    `(progn ,@body)))

;;;; Generic Emacs options:
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Variable for portability:
(defvar this-os nil
  "A string describing the current OS.
This variable holds the name of the currently running
operating system. The idea is that Emacs functions are
able to know what they run under.")

(when (file-exists-p "/etc/gentoo-release")
  (setq this-os 'gentoo))
(when (file-exists-p "/etc/apt/sources.list")
  (setq this-os 'debian))
(when (file-exists-p "c:\windows")
  (setq this-os 'win32))

(defun windows-p ()
  "Return NIL if not running on Win32."
  (eq this-os 'win32))

(defun gentoo-p ()
  "Return NIL if not running on Gentoo."
  (eq this-os 'gentoo))

(defun debian-p ()
  "Return NIL if not running on Debian."
  (eq this-os 'debian))

;;; Loadpaths:
(add-to-list 'load-path "~/emacs")
(add-to-list 'load-path "~/emacs/emms")
(add-to-list 'load-path "/usr/share/maxima/5.9.1/emacs")
(add-to-list 'load-path "~/emacs/imaxima-imath-0.97a/")
(add-to-list 'load-path "/usr/share/doc/git-core/contrib/emacs")

(when (windows-p)
  (add-to-list 'load-path "D:\\Dokumenter\\emacs"))

(noerr-require 'gpl)
(noerr-require 'gpl-copying)
(noerr-require 'help-mode)
(noerr-require 'grep)
(noerr-require 'htmlfontify)
(noerr-require 'ucs-tables)
(noerr-require 'ispell)
(noerr-require 'latex)
(noerr-require 'w3m)
(noerr-require 'margin)
(noerr-require 'ubbc-mode)
(noerr-require 'gnus)

(with-feature
 (imaxima)
 (autoload 'imaxima "imaxima" "Image support for Maxima." t)
 (autoload 'imath-mode "imath" "Interactive Math minor mode." t))

(when (not (windows-p))
  (server-start))                       ; Convenient, at times.

(display-time)                          ; Display time in modeline.
(column-number-mode 1)          ; Show column number on the mode-line.
(line-number-mode 1)              ; Show line number on the mode-line.
(show-paren-mode 1)                     ; Paren-matching.
(auto-fill-mode -1)                     ; Don't auto-fill by default.
(global-font-lock-mode t)               ; Font-lock by default.

(setf pop-up-windows nil        ; Don't change my windowconfiguration.
      european-calendar-style t         ; Use european date format.
      delete-auto-save-files t   ; Delete unnecessary auto-save files.
      default-major-mode 'fundamental-mode ; At least this mode won't do anything stupid.
      scroll-step 1                   ; Only move in small increments.
      frame-title-format "%b GNU Emacs" ; Make the frame a bit more useful.
      ;; Personal information.
      user-mail-address "athas@sigkill.dk"
      user-full-name "Troels Henriksen"
      user-company-name "Church of Emacs"
      mail-user-agent 'gnus-user-agent
      visible-bell t
      fill-column 70
      dired-recursive-copies t
      enable-local-variables :safe
      undo-strong-limit 3000000)

(setq-default case-fold-search t)

(transient-mark-mode 0)

;; Backup-files in the working directory sucks.
(add-to-list 'backup-directory-alist
             (cons ".*" "~/backup"))

;; ido is actually better and more general than iswitchb...
(with-feature
 (ido)
 (ido-mode 1)
 (setq ido-enable-flex-matching t)
 (defvar ido-enable-replace-completing-read nil
   "If t, use ido-completing-read instead of completing-read if possible.
    
    Set it to nil using let in around-advice for functions where the
    original completing-read is required.  For example, if a function
    foo absolutely must use the original completing-read, define some
    advice like this:
    
    (defadvice foo (around original-completing-read-only activate)
      (let (ido-enable-replace-completing-read) ad-do-it))")
    
 ;; Replace completing-read wherever possible, unless directed otherwise
 (defadvice completing-read
   (around use-ido-when-possible activate)
   (if (or (not ido-enable-replace-completing-read) ; Manual override disable ido
           (boundp 'ido-cur-list)) ; Avoid infinite loop from ido calling this
       ad-do-it
     (let ((allcomp (all-completions "" collection predicate)))
       (if allcomp
           (setq ad-return-value
                 (ido-completing-read prompt
                                      allcomp
                                      nil require-match initial-input hist def))
         ad-do-it))))
 (add-hook 'ido-define-mode-map-hook 'ido-my-keys)
 (defun ido-my-keys ()
   "Add my keybindings for ido."
   (define-key ido-mode-map "\C-w" 'backward-kill-word)))

;; Do not use The Evil Tab, use Holy Spaces instead.
(setq-default indent-tabs-mode nil) 

;; Go Danish. UTF-8 input breaks under Windows, so... disable.
;(when (not (windows-p))
;  (set-keyboard-coding-system 'utf-8-unix)
;  (set-terminal-coding-system 'utf-8-unix))

;; Set up Twelf...
(setq twelf-root "/home/athas/twelf/")
(when (file-exists-p (concat twelf-root "emacs/twelf-init.el"))
  (load (concat twelf-root "emacs/twelf-init.el")))

(with-feature
 (ispell)
 (ispell-change-dictionary "british" t)

 (add-hook 'find-file-hook
           (lambda ()
             (when (or (ignore-errors
                         (save-excursion
                           (beginning-of-buffer)
                           (re-search-forward "[æøåÆØÅ]" (buffer-size) t))
                         (eql (trh-language-of-buffer) "da")))
               (ispell-change-dictionary "dansk"))))
 (mapcar (lambda (hook)
           (add-hook hook
                     (lambda ()
                       (flyspell-mode 1)
                       (auto-fill-mode 1))))
         '(text-mode-hook latex-mode-hook)))

;;; Make Emacs a bitch to close (C-x C-c is sooo easy to hit):
(add-to-list 'kill-emacs-query-functions 
             (lambda () (y-or-n-p "Last chance, your work would be lost. ")))
(add-to-list 'kill-emacs-query-functions 
             (lambda () (y-or-n-p "Are you ABSOLUTELY certain that Emacs should close? ")))
(add-to-list 'kill-emacs-query-functions 
             (lambda () (y-or-n-p "Should Emacs really close? ")))

(defun textlove ()
  (interactive)
  (auto-fill-mode 1)
  (flyspell-mode 1)
  (ispell-change-dictionary "british"))

(defun tekstkærlighed ()
  (interactive)
  (auto-fill-mode 1)
  (flyspell-mode 1)
  (ispell-change-dictionary "dansk"))

;;; Tease the vi-users:
(defconst wq "This is not vi!  Use C-x C-c instead.")
(defconst w "This is not vi!  Use C-x C-s instead.")
(defconst q! "This is EMACS not vi!  Use C-x C-c instead.")
(defconst wq! "This is EMACS not vi!  Use C-x C-c instead.")

;;;; Generic Keybindings:
;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro global-set-keys (&rest keycommands)
  "Register keys to commands.
Analyze KEYCOMMANDS in pairs, and maps the corresponding keys
to the corresponding functions."
  (let ((setkey-list nil))
    (while keycommands
      (let ((key (car keycommands))
            (command (cadr keycommands)))
        (push `(global-set-key (kbd ,key)
                               ,command)
              setkey-list))
      (setq keycommands (cddr keycommands)))
    (push 'progn setkey-list)
    setkey-list))

(defmacro set-keybinding-for-maps (key command &rest keymaps)
  "Register keys to commands in a nuber of keymaps.
Maps KEY to COMMAND in the keymaps listed in KEYMAPS."
  (let ((defkey-list nil))
    (while keymaps
      (let ((current-map (first keymaps)))
        (push `(define-key 
                 ,current-map 
                 (kbd ,key)
                 ,command)
              defkey-list))
      (setq keymaps (rest keymaps)))
    (push 'progn defkey-list)
    defkey-list))

(defmacro define-keys (keymap &rest args)
  `(progn
     ,@(let (defs)
         (while args
           (let ((key (first args))
                 (def (second args)))
             (push `(define-key ,keymap ,key ,def) defs))
           (setf args (cddr args)))
         defs)))

;;; Keybindings:
(global-set-keys

 ;; M-x strains my fingers.
 "\C-x\C-m" 'execute-extended-command
 "\C-c\C-m" 'execute-extended-command

 ;; Backspace is far away, making backward-kill-word hard to perform.
 "\C-w"     'backward-kill-word
 "\C-x\C-k" 'kill-region
 "\C-c\C-k" 'kill-region

 "\C-xw"     'goto-line
 "\C-x\C-b"  'buffer-menu
 "\C-cn"     'bs-cycle-next
 "\C-cp"     'bs-cycle-previous
 "\C-ce"     'eshell
 "\C-c\C-e"  'eshell
 "\C-ck"     'compile
 "\C-x!"     'shell-command
 "\C- "      'set-mark-command
 "\C-hg"     'apropos
 "\C-cs"     'trh-insert-slander
 "\C-c\C-s"  'trh-insert-slander
 "<f5>"      (lambda ()
               (interactive)
               (find-file "~/.notes"))
 "<f6>"      (lambda ()
               (interactive)
               (find-file "~/.todo"))

 "<f1>"      'slime-scratch
 "C-x c s"     'slime-selector)

(global-set-key  (kbd "C-c TAB") 'lisp-complete-symbol)

(when window-system
  (global-set-key " " 'other-window))

;;; A lot of major modes do not allow quick exit, but they should.
(defvar maps-for-quick-exit nil
  "List of keymaps that should have a key for quick exit defined.")

(with-feature (help-mode)
              (push help-mode-map maps-for-quick-exit))

(with-feature (grep)
              (push grep-mode-map maps-for-quick-exit))

(push completion-list-mode-map maps-for-quick-exit)

(dolist (map maps-for-quick-exit)
  (set-keybinding-for-maps  "q" 'kill-this-buffer map))


(global-set-key (kbd "<C-tab>") 'other-window)
(global-set-key "\C-\M-z" 'undo)

;;;; Visual Appearance:
;;;;;;;;;;;;;;;;;;;;;;;

;;; Disable X-fluff and remove stuff:
(when (> (string-to-number emacs-version) 20) ; Why do I care?
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (blink-cursor-mode -1))

;;; Turn on mouse wheel scrolling
(defun sd-mousewheel-scroll-up (event)
  "Scroll window under mouse up by five lines."
  (interactive "e")
  (let ((current-window (selected-window)))
    (unwind-protect
        (progn
          (select-window (posn-window (event-start event)))
          (scroll-up 5))
      (select-window current-window))))

(defun sd-mousewheel-scroll-down (event)
  "Scroll window under mouse down by five lines."
  (interactive "e")
  (let ((current-window (selected-window)))
    (unwind-protect
        (progn
          (select-window (posn-window (event-start event)))
          (scroll-down 5))
      (select-window current-window))))

(global-set-key (kbd "<mouse-5>") 'sd-mousewheel-scroll-up)
(global-set-key (kbd "<mouse-4>") 'sd-mousewheel-scroll-down) 

;; Define the way Emacs looks:
(set-foreground-color "gray")
(set-background-color "black")
(set-cursor-color "red")
(set-mouse-color "green")
(set-border-color "light green")

;; Fonts: ;; Specified in .Xdefaults for now.
;;(if (eq this-os 'gentoo)
;;    (progn
;;      (add-to-list
;;       'default-frame-alist)))
;;       '(font
;;       . "9x15"))))
         
;;(if (eq this-os 'debian)
;;    (progn
;;      (add-to-list
;;       'default-frame-alist
;;       '(font
;;       . "9x16"))))

;; Color theme overrides some of the above stuff.

(with-feature
 (color-theme)

 (setq color-theme-is-cumulative nil)

 (defvar trh-color-theme nil
   "This variable contains the current color theme.")

 (setq trh-color-theme 'color-theme-charcoal-black)

 ;; Only change color theme when running in X.
 (when (> (display-color-cells) 256)
   ;(funcall trh-color-theme)
   )

 (set-cursor-color "white")             ; I NEED this!
 )

;;;; Slander subsystem:
;;;;;;;;;;;;;;;;;;;;;;;

(defvar trh-slander-list-da nil
  "List of slanders in danish.
Updated via the function `trh-update-slander-list', and used by `trh-get-slander'.")

(defvar trh-slander-list-C nil
  "List of slanders in english.
Updated via the function `trh-update-slander-list', and used by `trh-get-slander'.")

(defun get-slander-list (language)
  "Return the symbol of the slander-list for LANGUAGE."
  (read (concat "trh-slander-list-"
                language)))

(defun get-slander-file (language)
  "Return the containing slanders for LANGUAGE."
  (concat
   "~/.slanders-"
   language))

(defun trh-slander-check (language)
  "Will check if a slander of LANGUAGE can be retrieved.
Signals an error if not, returns T otherwise."
  (let ((slander-list (get-slander-list language)))
    ;; If the slander-list does not exist, exit with error.
    (or (boundp (symbol-value 'slander-list))
        (error (concat "Slander list for language "
                       language
                       " does not exist.")))
    ;; Otherwise, return T.
    t))
  
(defun trh-update-slander-list (language &optional force-update)
  "Update the slander list of LANGUAGE.
This function will read from the relevant ~/slanders-LANGUAGE file.
Returns the slander list for LANGUAGE."
  ;; Construct the correct symbol for the slander-list from LANGUAGE.
  ;; All slander-lists are prefixed with trh-slander-list, followed by a
  ;; two-letter language code.
  (let* ((slander-list (get-slander-list language))
         (slander-file (get-slander-file language))
         (slander-file-attributes (file-attributes slander-file))
         ;; Convert two 16bit integers to 32bit (or something close to it).
         (slander-file-access-time (+ (* (expt 2 16) 
                                         (first (fifth slander-file-attributes))
                                         (second (fifth slander-file-attributes))))))
    ;; Does this list exist?
    (trh-slander-check language)
    ;; Now, we don't want to reload the contents of `slander-file' unless
    ;; the file has been changed since the list was last updated. Therefore,
    ;; the plist for the slander-list has a `trh-timestamp' property, which
    ;; contains a UNIX timestamp. We compare this with the files timestamp,
    ;; and only update it if they are not equal.
    (when (or
           force-update
           (> slander-file-access-time 
              (or (get (symbol-value 'slander-list) 'trh-timestamp)
                  0)))
      (message "Reloaded slander file.")
      ;; Read from correct ~/.slanders-file.
      (let ((slander-buffer (find-file-noselect slander-file)))
        ;; This is a relatively complicated indirection process. It should be 
        ;; greatly simplified somehow.
        (setf (symbol-value (symbol-value 'slander-list))
              (trh-read-lines-in-buffer slander-buffer))
        ;; Set plist of slander-list to timestamp of file.
        (put slander-list
             'trh-timestamp
             slander-file-access-time)
        ;; Clean up.
        (kill-buffer slander-buffer)))
    (symbol-value (symbol-value 'slander-list))))

(defun trh-get-slander (language)
  "Return random slander.
The slander returned will be in LANGUAGE."
  ;; Ensure that list is up to date.
  ;; Find a random number in the interval [0,length-of-list).
  ;; Find the relevant element in the list.
  (trh-update-slander-list language)
  (let* ((slander-list (symbol-value (get-slander-list language)))
         (random-number (random (length slander-list)))
         (random-element (nth random-number slander-list)))
    random-element))

;;;; Git:
;;;;;;;;;

(with-feature
 (vc-git)
 (when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
 (require 'git)
 (autoload 'git-blame-mode "git-blame"
   "Minor mode for incremental blame for Git." t))

;;;; EMMS:
;;;;;;;;;;

(with-feature
 (emms)
 (noerr-require 'emms-default)

 (emms-setup 'cvs "/home/athas/docs/Musik")

 ;; Show the current track each time EMMS
 ;; starts to play a track with "EMMS Playing: "
 (add-hook 'emms-player-started-hook 'emms-show)
 (setq emms-show-format "EMMS Playing: %s")
 )

;;;; Programming:
;;;;;;;;;;;;;;;;;

(with-feature
 (css-mode)
 (setq cssm-indent-level 2)
 (setq cssm-newline-before-closing-bracket t)
 (setq cssm-indent-function #'cssm-c-style-indenter)
 (setq cssm-mirror-mode nil))

(noerr-require 'ld-script)

(with-feature
 (moo-code)
 (add-to-list
  'auto-mode-alist
  (cons "\\.moo" 'moo-code-mode))
 )

(with-feature
 (nxml-mode)
 (add-to-list 
  'auto-mode-alist
  (cons (concat "\\."(regexp-opt '("xml" "xsd" "sch" "rng" "xslt" "svg" "rss") t) "\\'")
        'nxml-mode))
 )

(with-feature
 (maxima-mode)
 (add-to-list 
  'auto-mode-alist '("\.max" . maxima-mode))
 )

(with-feature
 (octave-mode)
 (setq auto-mode-alist
       (cons '("\\.m$" . octave-mode) auto-mode-alist)))

(add-to-list
 'auto-mode-alist '("\.stumpwmrc" . lisp-mode))

(setq compilation-read-command nil)

(global-set-key [f8] 'add-change-log-entry-other-window)
(global-set-key "\C-c\C-c" 'eval-last-sexp)

(add-hook 'change-log-mode-hook (lambda ()
                                  (auto-fill-mode)))

;;; Darcs - a revision control system.

;; I might accidentaly open a darcs-file, in that case, warn.
(add-hook 'find-file-hook 'warn-if-darcs-file)

(defun warn-if-darcs-file()
  (let ((f (buffer-file-name (current-buffer))))
    (and f (string-match "_darcs" f)
         (if (y-or-n-p "This is a _darcs file, open the real file? ")
             (jump-to-real-file-from-darcs)
           (push '(:propertize "_DARCS-FILE:" face font-lock-warning-face)
                 mode-line-buffer-identification)))))

(defun jump-to-real-file-from-darcs()
  (interactive)
  (let* ((f (buffer-file-name (current-buffer)))
         (match (string-match "_darcs/current" f)))
    (and f match
         (find-alternate-file
          (concat (substring f 0 (match-beginning 0))
                  (substring f (match-end 0)))))))

;;; SLIME and generic Common Lisp.

(push "/home/athas/code/cvsrepos/slime/" load-path)
(push "/home/athas/code/cvsrepos/slime/contrib/" load-path)
(with-features
 (slime paredit)
 ;;(setq inferior-lisp-program "/usr/bin/lisp")
 (setq inferior-lisp-program "~/bin/cvsbcl"
       slime-multiprocessing t
       slime-startup-animation nil
       slime-backend "/home/athas/code/cvsrepos/slime/swank-loader.lisp")
 (slime-setup '(slime-fancy slime-asdf))
 (define-key paredit-mode-map (kbd "RET") nil)
 (define-key lisp-mode-shared-map (kbd "RET") 'paredit-newline)
 (define-key slime-repl-mode-map (kbd "C-M-d") 'down-list)
 (add-hook 'lisp-mode-hook (lambda () (slime-mode t)))
 (add-hook 'lisp-mode-hook (lambda () (paredit-mode +1)))
 (add-hook 'slime-repl-mode-hook (lambda () (paredit-mode +1)))
 (add-hook 'inferior-lisp-mode-hook (lambda () (inferior-slime-mode t)))
 (add-to-list 'auto-mode-alist '("\\.cl$" . lisp-mode))
 (add-to-list 'auto-mode-alist '("\\.cmucl-init$" . lisp-mode))
 (add-to-list 'auto-mode-alist '("\\.asd$" . lisp-mode))

 (setq slime-complete-symbol-function 'slime-complete-symbol*)

 ;; I have a local copy of the Common Lisp HyperSpec
 (setq common-lisp-hyperspec-root "file:/home/athas/docs/HyperSpec/")

 (defvar hyperspec-browser-function 'w3m-browse-url
   "Function to display the relevant entry of the HyperSpec in a WWW browser.
This is used by the command `trh-hyperspec-lookup'.")

 (define-key slime-mode-map "\C-c\C-dh"
   (lambda ()
     (interactive)
     (let ((browse-url-browser-function hyperspec-browser-function))
       (call-interactively 'slime-hyperspec-lookup))))

 (global-set-key "\C-c\C-dh"
                 '(lambda ()
                    (interactive)
                    (let ((browse-url-browser-function hyperspec-browser-function))
                      (call-interactively 'slime-hyperspec-lookup))))

 (setq lisp-simple-loop-indentation 1
       lisp-loop-keyword-indentation 6
       lisp-loop-forms-indentation 6)

 )

;;; Scheme setup.

(setq scheme-program-name "mzscheme")
(with-feature 
 (quack)
 
 
 (set-face-foreground quack-pltish-defn-face "green")

 (define-key scheme-mode-map "\C-c\C-c" 'scheme-send-last-sexp)
 (define-key scheme-mode-map "\C-c\C-e" 'scheme-compile-definition-and-go)
 )

;;; Haskell setup.

(with-feature
 (haskell-mode)
 (noerr-require 'haskell-ghci)
 (noerr-require 'inf-haskell)
 (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
 (add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
 (remove-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
 (add-hook 'haskell-mode-hook
           '(lambda ()
              (setq process-connection-type nil)
              (turn-on-haskell-ghci)))
 (setq haskell-program-name "ghci")

 (with-feature
  (mmm-haskell)

  (setq mmm-global-mode 'maybe)
  (add-to-list 'mmm-mode-ext-classes-alist
               '(latex-mode "\\.lhs$" haskell))

  (add-to-list 'auto-mode-alist '("\\.lhs\\'" . latex-mode))
  (eval-after-load "tex"
    '(progn
       (add-to-list 'LaTeX-command-style '("lhs" "lhslatex"))
       (add-to-list 'TeX-file-extensions "lhs"))))

 (with-feature
  (haskell-indentation)

  (add-hook 'haskell-mode-hook 'haskell-indentation-mode)))

;;; SML setup.
(with-feature
 (sml-mode)

 ;; Use MOSML for DIKU.
 (setf sml-program-name "~/bin/mosml")
 (setf sml-default-arg "-P full")
 
 (add-to-list 'auto-mode-alist
              '("\\.sml$" . sml-mode))
 (add-to-list 'auto-mode-alist
              '("\\.ML$"  . sml-mode))
 (add-to-list 'auto-mode-alist
              '("\\.sig$" . sml-mode)))

;;;; Enable disabled options:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(put 'narrow-to-region 'disabled nil)

;;;; ERC-options:
;;;;;;;;;;;;;;;;;

(with-feature 
 (erc)

 (noerr-require 'erc-auto)
 (noerr-require 'erc-autojoin)
 (noerr-require 'erc-match)

 ;; Fix a potentially broken charset:
 (setq erc-default-coding-system '(utf-8 . undecided)
       erc-join-buffer 'bury)

 ;; Some stupid channels require obsolete charsets.
 (push '("#udvikleren.dk" . (iso-latin-1 . undecided))
       erc-encoding-coding-alist)

 (push '("#linuxin.dk" . (iso-latin-1 . undecided))
       erc-encoding-coding-alist)

 ;;(push '("#linuxin.dk" . (iso-latin-1 . undecided))
 ;;      erc-encoding-coding-alist)

 (push '("#piratgruppen.org" . (iso-latin-1 . undecided))
       erc-encoding-coding-alist)

 ;; Display private messages in new buffers.
 (setq erc-auto-query 'buffer)

 (setq erc-paranoid t)                  ; Show CTCP-messages.
 (setq erc-email-userid "athas@@sigkill.dk"
       erc-user-full-name "Troels Henriksen"
       erc-prompt (lambda () (concat (buffer-name) ">")))

 ;; Read-only:
 (add-hook 'erc-insert-post-hook 'erc-make-read-only)
 (add-hook 'erc-send-post-hook 'erc-make-read-only)

 (defun erc-toggle-away ()
   "Toggles away-status in ERC."
   (interactive)
   (if (erc-away-p)
       (erc-cmd-AWAY "")
     (erc-cmd-AWAY "I'm away for some reason")))

 (define-key erc-mode-map "\C-ca" 'erc-toggle-away)

 ;; Hooks, put stuff here:
 (add-hook 'erc-mode-hook
           (lambda ()        
             ;; Use emacs-mule as coding system for all erc-buffers (for easy logging).
             (set (make-variable-buffer-local 'coding-system-for-write) 'emacs-mule)))

 ;; /hop command ala mIRC.

 (defun erc-cmd-HOP (&rest rest)
   "Part channel and immediately rejoin."
   (let ((channel (erc-default-target)))
     (erc-part-from-channel "hop")
     (erc-join-channel channel)))

 (defun erc-cmd-OS ()
   "Brag about which operating system is running."
   (erc-send-message

    (concat "I'm running: "
            (replace-regexp-in-string "\n" "" (emacs-version)))))

 ;; Generic slap.
 (defun erc-cmd-SLAPWITH (&rest rest)
   (erc-send-action
    (erc-default-target)
    (concat "slaps "
            (car rest)
            " around a bit with"
            (let (thing)
              (setq rest (cdr rest))
              (while (not (equal (car rest) nil))
                (setq thing (concat thing " " (car rest)))
                (setq rest (cdr rest)))
              thing)
            ".")))

 ;; So, I don't use Winamp, but I can at least print my Emacs-state.
 (defun erc-cmd-EMACS ()
   (erc-send-action
    (erc-default-target)
    (apply 'concat "is editing "
           (nconc
            (mapcar (lambda (buffer)
                      (concat "\"" (buffer-name buffer) "\" ["
                              (save-excursion (set-buffer buffer)
                                              (symbol-name major-mode))
                              "], "))
                    (remove-if-not 'buffer-file-name (buffer-list)))
            (list "and that's it.")))))

 ;; Badass slap!
 (defun erc-cmd-SLAP (&rest nick)
   (erc-cmd-SLAPWITH (car nick) "a small 50lb Unix-manual"))

  ;; Yucky slap. :-(
 (defun erc-cmd-SLAPPENIS (&rest nick)
   (erc-cmd-SLAPWITH (car nick) (concat 
                                 "his "
                                 (find-epenis)
                                 "cm long ePenis")))

 (defun erc-cmd-EPENIS ()
   "Calculates the size of your ePenis and writes it in `erc-default-target'"
   (erc-send-message 
    (get-epenis)))

  (defun penisdyst (process response)
    (let ((user (car (erc-parse-user (erc-response.sender response)))))
      (when (and (string= "!penisdyst" (erc-response.contents response))
                 (or (string-equal "KasperTSW" user)
                     (string-equal "Athas" user)
                     (string-equal "WinAthas" user)))
        (save-excursion
          (set-buffer (first (erc-response.command-args response)))
          (erc-send-message (get-epenis)))))
    nil)

 ;; WHY doesn't this work?
 (add-hook 'erc-server-PRIVMSG-functions 'penisdyst)

 (defun get-epenis ()
   "Returns a string describing your ePenis."
   (let ((penis (find-epenis)))
     (concat
      "ePenis: "
      (graph-epenis (string-to-number penis) 4)
      " ("
      penis
      "cm).")))

 (defun graph-epenis (length fraction)
   "Return ASCII image of epenis of length LENGTH, with one \"piece\" for
each FRACTION in LENGTH."
   (concat
    "o"
    (make-string (floor (/ length fraction)) ?=)
    "8"))

 (defun find-epenis ()
   "Return a string containing size of electronic penis.
Returns the value in centimeters."
   (shell-command "cat /proc/uptime") ; Puts output in *Shell Command Output*
   (save-excursion
     (set-buffer "*Shell Command Output*")
     (goto-char (point-min))
     (format "%.3f"
             (* 2.427
                (log
                 (string-to-int 
                  (buffer-substring 
                   (point-min) 
                   (search-forward "." (point-max)))))))))

 (defvar irc-nickname "Athas"
   "Standard nickname for use on IRC")

 (when (windows-p)
   (setq irc-nickname "WinAthas"))

 (defvar irc-port 6667
   "Standard port to connect to IRC servers with.")

 (defvar irc-realname "Troels Henriksen"
   "Standard real name on IRC.")

;;; ERC really doesn't like connecting to the same IRC-server
;;; twice. Therefore, I set up a guard, to error out early, before any
;;; network connections are made, if ERC is already connected to the
;;; specified server.

 (defvar irc-connected-hosts nil
   "List of servers ERC is connected to.")

 (defun irc-connect (server &optional port)
   "Connect to SERVER via ERC, using default values for nickname, realname and 
port. Port can be specified as optional parameter PORT. The default values are 
specified in the variables `irc-nickname', `irc-port' and `irc-realname'."
   (when (find server irc-connected-hosts)
     (error "Already connected to server."))
   (erc :server server :port (or port irc-port) :nick irc-nickname :full-name irc-realname)
   (push server irc-connected-hosts))

 (defun irc-quakenet ()
   "Connect to the QuakeNet IRC-network using ERC."
   (interactive)
   (irc-connect "irc.quakenet.org"))

 (defun irc-freenode ()
   "Connect to the Freenode IRC-network using ERC."
   (interactive)
   (irc-connect "irc.freenode.net" 8001))

 (defun irc-efnet ()
   "Connect to the EFNet IRC-network using ERC."
   (interactive)
   (irc-connect "irc.inet.tele.dk" 6661))

 (defun irc-chatsociety ()
   "Connect to the ChatSociety IRC-network using ERC."
   (interactive)
   (irc-connect "irc.chatsociety.net"))

 (defun irc-synirc ()
   "Connect to the SynIRC IRC-network using ERC."
   (interactive)
   (irc-connect "irc.synirc.net"))

 (defun irc-zybourne ()
   "Connect to the Zybourne IRC-network using ERC."
   (interactive)
   (irc-connect "irc.zybourne.net"))

 (defun irc-oftc ()
   (interactive)
   (irc-connect "irc.oftc.net"))

 (defun irc-cleanup ()
   "Kills all IRC buffers.
For now, it kills all buffers in ERC-mode."
   (interactive)
   (save-window-excursion
     (let ((print-list)
           (obuffer (current-buffer)))
       (dolist (buffer (buffer-list))
         (set-buffer buffer)
         (when (eq major-mode 'erc-mode) 
           (set-buffer buffer)
           (progn
              (kill-buffer buffer))))
       (setq irc-connected-hosts nil))))

 (add-to-list 'kill-emacs-query-functions
              (lambda () (progn
                           'irc-cleanup
                           t)))         ; Just to clean up properly.

 ;; Wrapper function to connect.
 (defun irc ()
   "Automatically connects to the IRC-servers irc.quakenet.org
and irc.freenode.net using ERC."
   (interactive)
   (irc-quakenet)
   (irc-freenode)
   (irc-zybourne)
   (irc-oftc))

 ;; Set up highlight-options:
 (setq erc-keywords '("Athas" "YuleAthas" "Climacs" "climacs"))

 (erc-match-mode 1)

 ;; Make my prompt reflect the current channel:
 (setq erc-prompt (lambda ()
                    (if (and (boundp 'erc-default-recipients) (erc-default-target))
                        (erc-propertize (concat (erc-default-target) ">") 'read-only t 'rear-nonsticky t 'front-nonsticky t)
                      (erc-propertize (concat "ERC>") 'read-only t 'rear-nonsticky t 'front-nonsticky t))))

 ;; Auto-join of channels is a nice thing to have.
 (erc-autojoin-mode 1)
 (setq erc-autojoin-channels-alist
       '(("irc.inet.tele.dk" "#sslug")
         ("freenode.net" "#emacs" "#lisp" "#diku" "#haskell" "#spiltirsdag" "#ghc" "#xmonad" "#cat-v")
         ("chatsociety.net" "#piratgruppen.org")
         ("quakenet.org" "#udvikleren.dk")
         ("zybourne.net" "#cobol")
         ("oftc.net" "#suckless")
         ))

 ;; Emacs doesn't like when it's buffers grow too big, so we'll
 ;; truncate them at 100'000 characters.
 (setq erc-max-buffer-size 100000)
 (defvar erc-insert-post-hook)
 (add-hook 'erc-insert-post-hook 'erc-truncate-buffer)
 (setq erc-truncate-buffer-on-save nil)

 ;; Timestamps:
 (erc-timestamp-mode t)

 (setq erc-hide-timestamps nil
       erc-timestamp-only-if-changed-flag nil
       erc-timestamp-format "%R:%S  "
       erc-fill-prefix "          "
       erc-insert-timestamp-function 'erc-insert-timestamp-left)


;;; Logging

 ;; Set up logging:
 (setq erc-log-insert-log-on-open nil)
 (setq erc-log-channels t)
 (setq erc-enable-logging t)
 (setq erc-log-channels-directory "~/.irclogs/")

 (setq erc-save-buffer-on-part t
       erc-save-queries-on-quit t
       erc-log-write-after-send t
       erc-log-write-after-insert t)

 (add-hook 'erc-insert-post-hook 'erc-save-buffer-in-logs)

 ;; When exiting emacs, save all logs without confirmation
 (defadvice save-buffers-kill-emacs
   (before save-logs (&rest args) activate)
   (save-some-buffers
    t
    (lambda ()
      (when (and (eq major-mode 'erc-mode)
                 (not (null buffer-file-name))) t))))

;;; You know what's cool? 
;;; Integrating doctor-mode with ERC, that's what's cool!

 (autoload 'doctor-doc "doctor")
 (autoload 'make-doctor-variables "doctor")

 (defvar erc-doctor-id "{Emacs doctor} ")

 (defun erc-cmd-DOCTOR (&optional last-sender &rest ignore)
   "Get the last message in the channel and doctor it."
   (let ((limit (- (point) 1000))
         (pos (point))
         doctor-buffer
         last-message
         text)
     ;; Make sure limit is not negative
     (when (< limit 0) (setq limit 0))
     ;; Search backwards for text from someone
     (while (and pos (not (let ((data (get-text-property pos 'erc-parsed)))
                            (and data
                                 (string= (aref data 3) "PRIVMSG")
                                 (or (not last-sender)
                                     (string= (car (split-string (aref data 2) "!"))
                                              last-sender))))))
       (setq pos (previous-single-property-change
                  pos 'erc-parsed nil limit))
       (when (= pos limit)
         (error "No appropriate previous message to doctor")))
     (when pos
       (setq last-sender (car (split-string
                               (aref (get-text-property
                                      pos 'erc-parsed) 2) "!"))
             doctor-buffer (concat "*ERC Doctor: " last-sender "*")
             last-message (split-string
                           ;; Remove punctuation from end of sentence
                           (replace-regexp-in-string
                            "[ .?!;,/]+$" ""
                            (aref (get-text-property pos
                                                     'erc-parsed) 5)))
             text (mapcar (lambda (s)
                            (intern (downcase s)))
                          ;; Remove salutation if it exists
                          (if (string-match
                               (concat "^" erc-valid-nick-regexp
                                       "[:,]*$\\|[:,]+$")
                               (car last-message))
                              (cdr last-message)
                            last-message))))
     (erc-send-message
      (concat erc-doctor-id
              ;; Only display sender if not in a query buffer
              (if (not (erc-query-buffer-p))
                  (concat last-sender ": "))
              (save-excursion
                (if (get-buffer doctor-buffer)
                    (set-buffer doctor-buffer)
                  (set-buffer (get-buffer-create doctor-buffer))
                  (make-doctor-variables))
                (erase-buffer)
                (doctor-doc text)
                (buffer-string))))))

;;; A little wisdom for the other IRC-users:
 (defun erc-cmd-WISDOM (lawno)
   "Writes one of Athas' Laws of Computing to `erc-default-target'
The specific law is defined by LAWNO."
   (erc-send-message 
    (concat
     "Athas' "
     lawno
     ". Law of Computing: "
     (trh-get-law lawno))))
 )

;;;; Eshell:
;;;;;;;;;;;;

(with-feature
 (eshell)
 (noerr-require 'esh-mode)
 (noerr-require 'em-cmpl)

  (setq eshell-history-size 16000)
  (add-to-list 'eshell-output-filter-functions 'eshell-handle-control-codes)
  )

;;;; Auxilliary Functions:
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; My own auxilliary functions are prefixed with trh-.

;;; I always end up with spurious whitespaces, this will remove them.
(defun trh-remove-whitespace-around-point () 
  "Removes whitespace from point up to, anc back to, the next non-whitespace.
Will affect linebreaks, tabs and spaces"
  (interactive)
  (save-excursion
    (let ((orig-pos (point)))
      (delete-region
       (progn
         (skip-chars-forward " \t\n")
         (constrain-to-field nil orig-pos t))
       (progn
         (skip-chars-backward " \t\n")
         (constrain-to-field nil orig-pos))))))

(global-set-key "\C-cr" 'trh-remove-whitespace-around-point)

(defun trh-indent-whole-buffer ()
  "Indents the whole buffer.
Uses ``indent-region'' to indent the whole buffer."
  (interactive)
  (when (y-or-n-p "Are you sure you want to indent the entire buffer? ")
    (indent-region (point-min) (point-max) nil)))

(global-set-key "\C-ci" 'trh-indent-whole-buffer)

(defun trh-visit-all-buffers ()
  "Will switch to, and close, all currently active buffers.
This is designed to be used in conjuction with ERC."
  (interactive)
  (save-window-excursion
    (let ((print-list)
          (obuffer (current-buffer)))
      (dolist (buffer (buffer-list)) 
        (switch-to-buffer buffer)))))

(global-set-key "\C-cg" 'trh-visit-all-buffers)

(defun trh-switch-to-gnus (&optional arg)
  "Switch to a Gnus related buffer.
    Candidates are buffers starting with
     *mail or *reply or *wide reply
     *Summary or
     *Group*
    Use a prefix argument to start Gnus if no candidate exists."
  (interactive "P")
  (let (candidate
        (alist '(("^\\*\\(mail\\|\\(wide \\)?reply\\)" t)
                 ("^\\*Group")
                 ("^\\*Summary")
                 ("^\\*Article" nil (lambda ()
                                      (buffer-live-p gnus-article-current-summary))))))
    (catch 'none-found
      (dolist (item alist)
        (let (last
              (regexp (nth 0 item))
              (optional (nth 1 item))
              (test (nth 2 item)))
          (dolist (buf (buffer-list))
            (when (and (string-match regexp (buffer-name buf))
                       (> (buffer-size buf) 0))
              (setq last buf)))
          (cond ((and last (or (not test) (funcall test)))
                 (setq candidate last))
                (optional
                 nil)
                (t
                 (throw 'none-found t))))))
    (cond (candidate
           (switch-to-buffer candidate))
          (arg
           (gnus))
          (t
           (error "Gnus does not appear to be running,")))))
(global-set-key (kbd "\C-cf") 'trh-switch-to-gnus)

(defun trh-insert-shell-command-output (command)
  "Inserts the output of COMMAND at point.
This function will garble the contents of *Shell Command Output*
if the buffer already exists."
  (interactive "MCommand: ")
  (shell-command command)      ; Puts output in *Shell Command Output*
  (insert-string
   (save-excursion
     (save-window-excursion
       (set-buffer "*Shell Command Output*")
       (buffer-substring 
        (point-min) 
        (point-max))))))

(global-set-key "\C-c!" 'trh-insert-shell-command-output)

;; TODO: Fix this function, it is broken.
(defun trh-clean-indentation ()
  "Remove all whitespace at the beginning of every line of the
current buffer This function will iterate through the current
buffer and remove every whitespace character at the beginning of
each line."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (not (equal (point) (point-max)))
      (delete-region
       (point)
       (search-forward-regexp "[^ ]*" ))
      (next-line))))

;;; Start Galeon
(defun trh-browse-url-galeon (url &optional new-window)
  "Ask the Galeon WWW browser to load URL.
Default to the URL around or before point. "
  (interactive (browse-url-interactive-arg "URL: "))
  ;; URL encode any `confusing' characters in the URL.  This needs to
  ;; include at least commas; presumably also close parens.
  (while (string-match "[,)]" url)
    (setq url (replace-match
               (format "%%%x" (string-to-char (match-string 0 url))) t t url)))
  (let* ((process-environment (browse-url-process-environment))
         (process (apply 'start-process
                         (concat "galeon " url) nil
                         "galeon"
                         (list url))))
    (set-process-sentinel process
                          `(lambda (process change)
                             (browse-url-netscape-sentinel process ,url)))))

;; This function is very simple, but it does what I need.
(defun trh-language-of-buffer (&optional buffer)
  "Get language of current buffer.
The algorithm used for finding the language is extremely simple, and not very
useful outside a small subset of problems. If the name of the buffer ends with
a \"-\" or a \".\" followed by a language- or country-code, that two-letter 
language code will be returned. Only very few language codes are supported.
If BUFFER is non-nil, the language of BUFFER will be returned instead of the
that of the current buffer."
  (let ((buffer-name (buffer-name (or buffer
                                      (current-buffer)))))
    (cond 
     ((string-match "[-.]\\(da\\|dk\\)$" buffer-name)
      "da")
     (t
      "C"))))

(defun trh-insert-slander (&optional language)
  "Insert random slander in buffer.
If LANGUAGE is non-nil the slander will be of the specified language, otherwise
it will be calculated from the name of the current buffer, using 
`trh-language-of-buffer'. If point is next to a word, delete the word and 
replace it with the slander, otherwise, just insert it."
  (interactive)
  ;; Set the language.
  (or language
      (setq language (trh-language-of-buffer)))
  ;; Does slander-list of language even exist?
  (trh-slander-check language)
  ;; Go back a character - if we are still looking at a SPACE-character, we
  ;; must be at least two spaces from the nearest word, so insert the
  ;; slander. If not, delete the word and insert the slander in its stead.
  (save-excursion
    (backward-char)
    (if (not (looking-at " "))
        (progn
          (forward-char)
          (backward-kill-word 1))
      (forward-char)))
  (insert (trh-get-slander language)))

;;; Athas' Laws of Computing. Arranged in a list and stuff.

(defvar trh-athas-laws nil
  "Athas' Laws of Computing.
Infinite and eternal truths of everything related to computers and the Internet.")

(setq trh-athas-laws '((1 . "The amount of zombies one can successfully apply in a DDoS-attack, is inversely proportional to the size of ones reproductive organs.")
                       (2 . "Any language employing a \"mixed type system\" (as seen in PHP) is to be recognized as dumb, and is to be considered unusable.")))

(defun trh-get-law (lawno)
  "Return one of Athas' Laws of Computing.
The exact law is controlled by LAWNO."
  (or (cdr (find 
            (string-to-int lawno) 
            trh-athas-laws 
            :test (lambda (x y)
                    (eql x (car y)))))
      (error "No such law.")))

;;; Firefox is my preferred browser.
;(setq browse-url-browser-function 'browse-url-firefox)
(setq browse-url-browser-function 'w3m-browse-url)

(defun untabify-buffer ()
  "Call `untabify' with the entire buffer as region."
  (interactive)
  (untabify (point-min) (point-max)))

;;;; Ugly Hacks and Workarounds:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; This section contains dubious code that provides short-term solutions to
;;; problems that annoy me.

(defun mmm-parse-buffer ()
  "Re-apply all applicable submode classes to current buffer.
Clears all current submode regions, reapplies all past interactive
mmm-ification, and applies `mmm-classes' and mode-extension classes."
  (interactive)
  (message "MMM-ifying buffer...")
  (save-excursion
    (mmm-apply-all))
  (message "MMM-ifying buffer...done"))

;;;; Custom-set-variables:
;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(load-home-init-file t t))
(put 'downcase-region 'disabled nil)
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(mmm-code-submode-face ((t nil)))
 '(mmm-default-submode-face ((t nil))))

(defun toggle-linecomment ()
  (interactive)
  (save-excursion
    (comment-or-uncomment-region (progn (beginning-of-line) (point))
                                 (progn (end-of-line) (point)))))
