;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!


;; These are used for a number of things, particularly for GPG configuration,
;; some email clients, file templates and snippets.
(setq user-full-name "Arnold Mpiima"
      user-mail-address "mpiima@protonmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:<
(setq doom-font (font-spec :family "Terminus" :size 14))

(global-set-key (kbd "C-c m c") 'mc/edit-lines)
(global-set-key (kbd "C-x g") 'magit-status)
;;(add-hook 'elixir-mode-hook 'eglot-ensure)


;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-one)

;; If you intend to use org, it is recommended you change this!
(setq org-directory "~/org/")

;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type t)



; Elixir configuration
;; Start by configuring Alchemist for some tasks.
(use-package! alchemist
  :hook (elixir-mode . alchemist-mode)
  :config
  (set-lookup-handlers! 'elixir-mode
    :definition #'alchemist-goto-definition-at-point
    :documentation #'alchemist-help-search-at-point)
  (set-eval-handler! 'elixir-mode #'alchemist-eval-region)
  (set-repl-handler! 'elixir-mode #'alchemist-iex-project-run)
  (setq alchemist-mix-env "dev")
  (setq alchemist-hooks-compile-on-save t)
  (map! :map elixir-mode-map :nv "m" alchemist-mode-keymap))

;; ;; Now configure LSP mode and set the client filepath.
 (use-package! lsp-mode
  :commands lsp
  :config
  (setq lsp-enable-file-watchers t)
  :hook
  (elixir-mode . lsp))

(after! lsp-clients
  (lsp-register-client
   (make-lsp-client :new-connection
    (lsp-stdio-connection
     "/usr/lib/elixir-ls/language_server.sh")
        :major-modes '(elixir-mode)
        :priority -1
        :server-id 'elixir-ls
        :initialized-fn (lambda (workspace)
            (with-lsp-workspace workspace
             (let ((config `(:elixirLS
                             (:mixEnv "dev"
                                     :dialyzerEnabled
                                     :json-false
                                     :lsp-enable-file-watchers t
                                     :lsp-file-watch-threshold 10000))))
               (lsp--set-configuration config)))))))



;; ;; Configure LSP-ui to define when and how to display informations.
(after! lsp-ui
  (setq lsp-ui-doc-max-height 20
        lsp-ui-doc-max-width 80
        lsp-ui-sideline-ignore-duplicate t
        lsp-ui-ui-doc-header t
        lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'bottom
        lsp-ui-doc-use-webkit t
        lsp-ui-flycheck-enable t
        lsp-ui-imenu-kind-position 'left
        lsp-sideline-code-actions-prefix "💡"
        ;; fix for completing candidates not showing after “Enum.”:
        company-lsp-match-candidate-predicate #'company-lsp-match-candidate-prefix
        ))
(use-package lsp-ui :commands lsp-ui-mode :hook (lsp-mode . lsp-ui-mode))
(use-package lsp-mode :commands lsp :config (setq lsp-prefer-flymake nil))
(after! lsp-ui
  (add-hook! 'lsp-ui-mode-hooke
    (run-hooks (intern (format "%s-lsp-ui-hook" major-mode)))))

;; (setq +format-on-save-enabled-modes
;;   '(not emacs-lisp-mode  ; elisp's mechanisms are good enough
;;         sql-mode         ; sqlformat is currently broken
;;         tex-mode         ; latexindent is broken
;;         org-mode
;;         latex-mode))
;; ;; Configure exunit
(use-package! exunit)
(setq lsp-enable-file-watchers t)
(setq lsp-file-watch-threshold 10000)

;Enable credo checks on flycheck
;; (use-package! flycheck-credo
;;   :after flycheck
;;   :config
;;     (flycheck-credo-setup)
;;     (after! lsp-ui
;;       (flycheck-add-next-checker 'lsp 'elixir-credo)))

(eval-after-load 'flycheck
  '(flycheck-credo-setup))
(add-hook 'elixir-mode-hook 'flycheck-mode)
;;
(use-package! lsp-ui)
;; ;; Enable format and iex reload on save
(after! lsp
  (add-hook 'elixir-mode-hook
            (lambda ()
              (add-hook 'before-save-hook 'elixir-format t)
              (add-hook 'after-save-hook 'alchemist-iex-reload-module))))

(setq org-default-notes-file "/home/zeus/notes/journal.org")

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(setq org-agenda-files (list "~/org/journal.org"
                             "~/org/todo.org"
                             "~/org/home.org"
                             "~/org/notes.org"))

(setq lsp-clients-elixir-server-executable "/usr/lib/elixir-ls/language_server.sh")

(lsp-treemacs-sync-mode 1)

(use-package php-mode
  ;;
  :hook ((php-mode . (lambda () (set (make-local-variable 'company-backends)
       '(;; list of backends
         company-phpactor
         company-files
         ))))))
;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
(put 'projectile-ripgrep 'disabled nil)

(add-to-list 'org-modules 'org-habit t)
(setq org-log-into-drawer t)
(setq org-treat-insert-todo-heading-as-state-change t)
(setq lsp-enable-folding t)
(use-package! lsp-origami)
(add-hook! 'lsp-after-open-hook #'lsp-origami-try-enable)

(defhydra hydra-origami (:color red)
  "
  _o_pen node    _n_ext fold       toggle _f_orward
  _c_lose node   _p_revious fold   toggle _a_ll
  "
  ("o" origami-open-node)
  ("c" origami-close-node)
  ("n" origami-next-fold)
  ("p" origami-previous-fold)
  ("f" origami-forward-toggle-node)
  ("a" origami-toggle-all-nodes))

(setq org-todo-keywords
      '((sequence "TODO(t)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELLED(c@)")))

(setq tramp-verbose 6)
