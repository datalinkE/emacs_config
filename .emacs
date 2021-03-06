;; common lisp standart functions: loop etc.
(require 'cl)

(setq-default tramp-default-method "ssh")

;;presere opened buffers on emacs restarts
(setq-default desktop-dirname "~/.emacs.d/desktop/"
              desktop-base-file-name      "emacs.desktop"
              desktop-base-lock-name      "lock"
              desktop-path                (list desktop-dirname)
              desktop-save                t
              desktop-files-not-to-save   "^$" ;reload tramp paths
              desktop-load-locked-desktop nil
              desktop-restore-eager       5)

;;(desktop-save-mode 1)

;; own keymap for use in this file
(defvar my-keys-minor-mode-map (make-keymap) "my-keys-minor-mode keymap.")

;; start with single window
(add-hook 'emacs-startup-hook 'delete-other-windows)

;;things that need additional packages

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") )
;;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/" ))
(setq-default package-enable-at-startup nil)
(package-initialize)

(require 'auto-complete-config)
(ac-config-default)

;;
(add-hook 'js-mode-hook 'js2-minor-mode)
(add-hook 'js2-mode-hook 'ac-js2-mode)
(add-hook 'js2-mode-hook 'js2-refactor-mode)


;;navigation
(require 'neotree)
(setq truncate-partial-width-windows nil)
(add-hook 'neotree-mode-hook
          (lambda ()
              (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-change-root)
              (define-key evil-normal-state-local-map (kbd "SPC") 'push-button)
              (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
              (define-key evil-normal-state-local-map (kbd "RET") 'push-button)
              ))

(require 'dired+)
(define-key my-keys-minor-mode-map (kbd "C-x C-d") 'dired-jump)
(define-key my-keys-minor-mode-map (kbd "C-x d") 'dired-jump-other-window)
(toggle-diredp-find-file-reuse-dir 1)

(defun my-dired-hook ()
  (define-key dired-mode-map (kbd "<mouse-2>") 'diredp-mouse-find-file-reuse-dir-buffer)
  (define-key dired-mode-map (kbd "<M-mouse-1>") 'diredp-mouse-find-file))
(add-hook 'dired-mode-hook 'my-dired-hook)

;; vim-like navigation + emacs bindings in insert mode
(require 'evil)
;; remove all keybindings from insert-state keymap
(setcdr evil-insert-state-map nil)
;; but [escape] should switch back to normal state
(define-key evil-insert-state-map (kbd "<escape>") 'evil-normal-state)

(evil-mode 1)

;;colors, fonts and themes
(load-theme 'wombat 't)

(global-linum-mode 1)
;;font size
(if (eq system-type 'darwin)
    (progn
      (set-face-attribute 'default nil :height 130)
      (set-face-attribute 'linum nil :height 100))
  (progn
    (set-face-attribute 'default nil :height 110)
    (set-face-attribute 'linum nil :height 90))
  )

;;show line numbers with fixed size
(setq-default left-fringe-width  10)
(setq-default right-fringe-width  0)


;;replace selected text
(delete-selection-mode 1)


;;no useless start buffer
(setq-default inhibit-splash-screen t)


;;thin cursor istead of rectangle
(setq-default cursor-type 'bar)


;;more compact appearing
(tool-bar-mode -1)
(scroll-bar-mode -1)


;; indentation in c/cpp/java etc.
(setq-default c-default-style "bsd"
      c-basic-offset 4)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default tab-stop-list (number-sequence 4 120 4))

;; Set default tab space for various  python modes
(setq-default py-indent-offset 4)
(setq-default python-indent 4)
(setq-default python-indent-guess-indent-offset nil)

(require 'auto-indent-mode)
(auto-indent-global-mode)
(setq auto-indent-indent-style 'conservative)
(setq-default auto-indent-assign-indent-level 4)


;;paranteses aroud cursor position, if any
(require 'highlight-parentheses)
(global-highlight-parentheses-mode 1)


(require 'xcscope)
(cscope-setup)
(define-key cscope-list-entry-keymap [mouse-1] 'cscope-select-entry-other-window)


;; highlight incorrect blank symbols
(require 'whitespace)
(setq-default whitespace-style '(face tabs trailing lines space-before-tab newline indentation empty space-after-tab tab-mark))
(setq-default whitespace-line-column 160)
(global-whitespace-mode t)


;;start with fullscreen window
(defun toggle-fullscreen-linux()
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
  )

(defun toggle-fullscreen-windows()
  (w32-send-sys-command 61488)
  )

(defun toggle-fullscreen-mac()
  (set-frame-parameter
   nil 'fullscreen
   (when (not (frame-parameter nil 'fullscreen)) 'maximized))
  )

(defun toggle-fullscreen ()
  (interactive)
  (cond
   ((eq system-type 'gnu/linux) (toggle-fullscreen-linux))
   ((eq system-type 'windows-nt) (toggle-fullscreen-windows))
   ((eq system-type 'darwin) (toggle-fullscreen-mac))
   )
)

(toggle-fullscreen)


;; cofig file easy access
(defun open-config()
  (interactive)
  (find-file "~/.emacs")
  (end-of-buffer))

(setq-default vc-follow-symlinks t)


;;compile with Makefile from any place
(defun save-all-and-compile()
  (interactive)
  (save-some-buffers 1)
  (compile "runcompile.sh")) ;custom script


;; smart filenames autocompletions
(require 'ido)
(ido-mode 1)
(ido-everywhere 1)

;;recent files reopening
(require 'recentf)
(recentf-mode 1)
(setq ido-use-virtual-buffers t)
(setq recentf-max-saved-items 150)

(setq-default
  ido-ignore-buffers ;; ignore these guys
  '("\\` " "^\\*"))


;;trick to use C- and M- with russian
(loop
 for from across "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖ\ЭЯЧСМИТЬБЮ№"
 for to   across "qwertyuiop[]asdfghjkl;'zxcvbnm,.QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>#"
 do
 (eval `(define-key key-translation-map (kbd ,(concat "C-" (string from))) (kbd ,(concat     "C-" (string to)))))
 (eval `(define-key key-translation-map (kbd ,(concat "M-" (string from))) (kbd ,(concat     "M-" (string to))))))


;;goto visible bufer buferwith <S-arrow>
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings))


;; Shift the selected region right if distance is postive, left if
;; negative

(defun shift-text (distance)
  (if (use-region-p)
      (let ((mark (mark)))
        (save-excursion
          (indent-rigidly (region-beginning)
                          (region-end)
                          distance)
          (push-mark mark t t)
          (setq deactivate-mark nil)))
    (indent-rigidly (line-beginning-position)
                    (line-end-position)
                    distance)))

(defun shift-right ()
  (interactive)
  (shift-text 4))

(defun shift-left ()
  (interactive)
  (shift-text -4))

;; keybindings

(define-key my-keys-minor-mode-map (kbd "C-d") 'backward-kill-word)
(define-key my-keys-minor-mode-map (kbd "C-9") 'previous-buffer)
(define-key my-keys-minor-mode-map (kbd "C-0") 'next-buffer)
(define-key my-keys-minor-mode-map (kbd "C-7") 'hs-hide-block)
(define-key my-keys-minor-mode-map (kbd "C-8") 'hs-show-block)
(define-key my-keys-minor-mode-map (kbd "<escape>") 'keyboard-escape-quit)
(define-key my-keys-minor-mode-map (kbd "C-=") 'text-scale-increase)
(define-key my-keys-minor-mode-map (kbd "C--") 'text-scale-decrease)
(define-key my-keys-minor-mode-map (kbd "C-\\") 'bookmark-bmenu-list)

(define-key my-keys-minor-mode-map (kbd "M-o") 'ido-find-file)
(define-key my-keys-minor-mode-map (kbd "M-R") 'replace-string)
(define-key my-keys-minor-mode-map (kbd "M-i") 'occur)
(define-key my-keys-minor-mode-map (kbd "C-<backspace>") 'pop-global-mark)

(define-key my-keys-minor-mode-map (kbd "<f5>") 'save-buffer)
(define-key my-keys-minor-mode-map (kbd "C-<f5>") 'revert-buffer-no-confirm)
(define-key my-keys-minor-mode-map (kbd "<f9>") 'save-all-and-compile)
(define-key my-keys-minor-mode-map (kbd "<f11>") 'bookmark-set)
(define-key my-keys-minor-mode-map (kbd "<f12>") 'open-config)

(define-key my-keys-minor-mode-map (kbd "<delete>") 'delete-char)

;;my keybindings
(define-key my-keys-minor-mode-map (kbd "M-k") 'kill-this-buffer)
(define-key my-keys-minor-mode-map (kbd "C-~") 'toggle-fullscreen)
(define-key my-keys-minor-mode-map (kbd "<f4>") 'neotree-toggle)
(define-key my-keys-minor-mode-map (kbd "C-x <f4>") 'neotree-find)

;;manual indentations
(define-key my-keys-minor-mode-map (kbd "<C-tab>")     'shift-right)
(define-key my-keys-minor-mode-map (kbd "<backtab>")   'shift-left)
(define-key my-keys-minor-mode-map (kbd "<C-S-iso-lefttab>")   'shift-left)


(define-key my-keys-minor-mode-map (kbd "M-[") 'windmove-left)
(define-key my-keys-minor-mode-map (kbd "M-]") 'windmove-right)

;;traditional controls

(define-key my-keys-minor-mode-map (kbd "M-q") 'save-buffers-kill-terminal)

(if (eq system-type 'darwin)
    (progn (define-key my-keys-minor-mode-map (kbd "M-s") 'save-buffer)
           (define-key my-keys-minor-mode-map (kbd "M-x") 'kill-region)
           (define-key my-keys-minor-mode-map (kbd "M-c") 'kill-ring-save)
           (define-key my-keys-minor-mode-map (kbd "M-v") 'yank)
           (define-key my-keys-minor-mode-map (kbd "M-z") 'undo))

    (progn (define-key my-keys-minor-mode-map (kbd "C-s") 'save-buffer)
           (define-key my-keys-minor-mode-map (kbd "M-s") 'isearch-forward)
           (define-key my-keys-minor-mode-map (kbd "M-x") 'kill-region)
           (define-key my-keys-minor-mode-map (kbd "C-c") 'kill-ring-save)
           (define-key my-keys-minor-mode-map (kbd "C-v") 'yank)
           (define-key my-keys-minor-mode-map (kbd "C-z") 'undo)))

(if (eq system-type 'windows-nt)
    (progn
      (setq shell-file-name "bash")
      (setq explicit-shell-file-name shell-file-name)
      (setq tramp-default-method "sshx"))
    )

(define-key my-keys-minor-mode-map (kbd "<f3>") 'execute-extended-command)
(define-key my-keys-minor-mode-map (kbd "C-/") 'rgrep)


(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  t " my-keys" 'my-keys-minor-mode-map)

(defun my-minibuffer-setup-hook ()  (my-keys-minor-mode 0))
(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)
(my-keys-minor-mode 1)

;; SHOW FILE PATH IN FRAME TITLE
(setq-default frame-title-format "%b (%f)")

(global-set-key (kbd "C-x C-b") 'ibuffer-other-window)

(defun my-ibuffer-hook ()
  (define-key ibuffer-mode-map (kbd "M-<down-mouse-1>") 'ibuffer-visit-buffer-other-window))

(add-hook 'ibuffer-mode-hooks 'my-ibuffer-hook)
