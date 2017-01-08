;;; amazon-this.el --- A set of functions and bindings to amazon under point.

;; Author: Ryan McCarl (ryan.mccarl@wordbrewery.com), based on code by Artur Malabarba <bruce.connor.am@gmail.com>
;; Inspired by: http://github.com/Malabarba/emacs-google-this
;; Package-Version: 20160107.001
;; Version: 0.01
;; Package-Requires: ((emacs "24.1"))
;; Keywords: convenience hypermedia
;; Prefix: amazon-this
;; Separator: -

;;; Commentary:

;; amazon-this is a package that provides a set of functions and
;; keybindings for launching amazon searches from within Emacs.

;; The main function is `amazon-this' (bound to C-c / w). It does a
;; amazon search using the currently selected region, or the
;; expression under point. All functions are bound under "C-c /"
;; prefix, in order to comply with Emacs' standards. If that's a
;; problem see `amazon-this-keybind'. To view all keybindings type "C-c
;; / C-h".
;;
;; If you don't like this keybind, just reassign the
;; `amazon-this-mode-submap' variable.
;; My personal preference is "C-x g":
;;
;;        (global-set-key (kbd "C-x g") 'amazon-this-mode-submap)
;;
;; Or, if you don't want amazon-this to overwrite the default ("C-c /")
;; key insert the following line BEFORE everything else (even before
;; the `require' command):
;;
;;        (setq amazon-this-keybind (kbd "C-x g"))
;;

;; To start a blank search, do `amazon-search' (C-c / RET). If you
;; want more control of what "under point" means for the `amazon-this'
;; command, there are the `amazon-word', `amazon-symbol',
;; `amazon-line' and `amazon-region' functions, bound as w, s, l and space,
;; respectively. They all do a search for what's under point.

;; If the `amazon-wrap-in-quotes' variable is t, than searches are
;; enclosed by double quotes (default is NOT). If a prefix argument is
;; given to any of the functions, invert the effect of
;; `amazon-wrap-in-quotes'.

;; There is also a `amazon-error' (C-c / e) function. It checks the
;; current error in the compilation buffer, tries to do some parsing
;; (to remove file name, line number, etc), and amazons it. It's still
;; experimental, and has only really been tested with gcc error
;; reports.

;; Finally there's also a amazon-cpp-reference function (C-c / r).

;;; Instructions:

;; INSTALLATION

;;  Make sure "amazon-this.el" is in your load path, then place
;;      this code in your .emacs file:
;;		(require 'amazon-this)
;;              (amazon-this-mode 1)

;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;

;;; Change Log:
;; 1.9   - 2014/09/25 - New Command: amazon-this-noconfirm bound to l. Like amazon-this but no confirmation.
;; 1.9   - 2014/09/02 - Renamed A LOT of functions to be namespaced correctly.
;; 1.10  - 2014/09/02 - Fix 24.3 compatibility.
;; 1.9   - 2014/06/19 - Customizable URL.
;; 1.8   - 2013/10/31 - Customizable mode-line indicator (credit https://github.com/mgalgs)
;; 1.7.1 - 2013/09/17 - amazon-this-parse-and-search-string returns what browse-url returns.
;; 1.7   - 2013/09/08 - Removed some obsolete aliases.
;; 1.7   - 2013/09/08 - Implemented amazon-lucky-and-insert-url, with keybinding.
;; 1.7   - 2013/09/08 - Implemented amazon-lucky, with keybinding.
;; 1.6   - 2013/08/22 - Activated amazon-instant, so you can navigate straight for the keyboard
;; 1.5   - 2013/07/18 - added keybinding for amazon region.
;; 1.5   - 2013/07/18 - Fixed cpp-reference.
;; 1.4   - 2013/06/03 - Added parent groups.
;; 1.4   - 2013/06/03 - Renamed some functions and variables. Is backwards incompatible if you were using functions you shouldn't be.
;; 1.4   - 2013/06/03 - Fixed quoting.
;; 1.3   - 2013/05/31 - Merged fix for amazon-forecast. Thanks to ptrv.
;; 1.3   - 2013/05/31 - More robust amazon-translate command.
;; 1.2.1 - 2013/04/26 - Created an error parser for the amazon-error function.
;; pre   - 2013/02/27 - It works with c-like errors and is extendable to other types of errors using the varible `amazon-error-regexp'.
;; 1.2.1 - 2013/04/26 - autoloaded any functions that the user might want to call directly.
;; 1.2   - 2013/04/21 - Fixed docs.
;; pre   - 2013/05/04 - Changed the keybinding to be standards compliant.
;; pre   - 2013/03/03 - Fixed problem with backslash.
;; pre   - 2013/02/27 - Added support for amazon-translate and amazon-maps packages.
;; pre   - 2013/02/27 - And added `amazon-forecast' function.
;; pre   - 2013/02/27 - And added `amazon-location-suffix' so we're not constrained to amazon.com anymore.
;;; Code:

(require 'url)
(eval-when-compile
  (progn
    (require 'compile)
    (require 'simple)))

(defgroup amazon-this '()
  "Customization group for `amazon-this-mode'."
  :link '(url-link "http://github.com/Malabarba/emacs-amazon-this")
  :group 'convenience
  :group 'comm)

(defconst amazon-this-version "1.10"
  "Version string of the `amazon-this' package.")
(defcustom amazon-this-wrap-in-quotes nil
  "If not nil, searches are wrapped in double quotes.

If a prefix argument is given to any of the functions, the
opposite happens."
  :type 'boolean
  :group 'amazon-this)

(defcustom amazon-this-suspend-after-search nil
  "Whether Emacs should be minimized after a search is launched (calls `suspend-frame')."
  :type 'boolean
  :group 'amazon-this)

(defcustom amazon-this-browse-url-function 'browse-url
  "Function used to browse urls.
Possible values include: `browse-url', `browse-url-generic',
`browse-url-emacs', `eww-browse-url'."
  :type 'function
  :group 'amazon-this)

(defvar amazon-this-mode-submap)
(define-prefix-command 'amazon-this-mode-submap)
(define-key amazon-this-mode-submap [return] #'amazon-this-search)
(define-key amazon-this-mode-submap " " #'amazon-this-region)
(define-key amazon-this-mode-submap "t" #'amazon-this)
(define-key amazon-this-mode-submap "n" #'amazon-this-noconfirm)
(define-key amazon-this-mode-submap "g" #'amazon-this-lucky-search)
(define-key amazon-this-mode-submap "i" #'amazon-this-lucky-and-insert-url)
(define-key amazon-this-mode-submap "w" #'amazon-this-word)
(define-key amazon-this-mode-submap "s" #'amazon-this-symbol)
(define-key amazon-this-mode-submap "l" #'amazon-this-line)
(define-key amazon-this-mode-submap "e" #'amazon-this-error)
(define-key amazon-this-mode-submap "f" #'amazon-this-forecast)
(define-key amazon-this-mode-submap "r" #'amazon-this-cpp-reference)
(define-key amazon-this-mode-submap "m" #'amazon-this-maps)
(define-key amazon-this-mode-submap "a" #'amazon-this-ray)
(define-key amazon-this-mode-submap "m" #'amazon-maps)
;; "c" is for "convert language" :-P
(define-key amazon-this-mode-submap "c" #'amazon-this-translate-query-or-region)

(defun amazon-this-translate-query-or-region ()
  "If region is active `amazon-translate-at-point', otherwise `amazon-translate-query-translate'."
  (interactive)
  (unless (require 'amazon-translate nil t)
    (error "[amazon-this]: This command requires the 'amazon-translate' package"))
  (if (region-active-p)
      (if (functionp 'amazon-translate-at-point)
          (call-interactively 'amazon-translate-at-point)
        (error "[amazon-this]: `amazon-translate-at-point' function not found in `amazon-translate' package"))
    (if (functionp 'amazon-translate-query-translate)
        (call-interactively 'amazon-translate-query-translate)
      (error "[amazon-this]: `amazon-translate-query-translate' function not found in `amazon-translate' package"))))

(defcustom amazon-this-base-url "https://affiliate-program.amazon."
  "The base url to use in amazon searches.

This will be appended with `amazon-this-location-suffix', so you
shouldn't include the final \"com\" here."
  :type 'string
  :group 'amazon-this)

(defcustom amazon-this-location-suffix "com"
  "The url suffix associated with your location (com, co.uk, fr, etc)."
  :type 'string
  :group 'amazon-this)

(defun amazon-this-url ()
  "URL for amazon searches."
  (concat amazon-this-base-url amazon-this-location-suffix "/home/productlinks/search?ac-ms-src=ac-nav&category=all&keywords=%s&sortby"))

(defcustom amazon-this-error-regexp '(("^[^:]*:[0-9 ]*:\\([0-9 ]*:\\)? *" ""))
  "List of (REGEXP REPLACEMENT) pairs to parse error strings."
  :type '(repeat (list regexp string))
  :group 'amazon-this)

(defun amazon-this-pick-term (prefix)
  "Decide what \"this\" and return it.
PREFIX determines quoting."
  (let* ((term (if (region-active-p)
                   (buffer-substring-no-properties (region-beginning) (region-end))
                 (or (thing-at-point 'symbol)
                     (thing-at-point 'word)
                     (buffer-substring-no-properties (line-beginning-position)
                                                     (line-end-position)))))
         (term (read-string (concat "Googling [" term "]: ") nil nil term)))
    term))

;;;###autoload
(defun amazon-this-search (prefix &optional search-string)
  "Write and do a amazon search.
Interactively PREFIX determines quoting.
Non-interactively SEARCH-STRING is the string to search."
  (interactive "P")
  (let* ((term (amazon-this-pick-term prefix)))
    (if (stringp term)
        (amazon-this-parse-and-search-string term prefix search-string)
      (message "[amazon-this-string] Empty query."))))

(defun amazon-this-lucky-search-url ()
  "Return the url for a feeling-lucky amazon search."
  (format "%s%s/search?q=%%s&btnI" amazon-this-base-url amazon-this-location-suffix))

(defalias 'amazon-this--do-lucky-search
  (with-no-warnings
    (if (version< emacs-version "24")
        (lambda (term callback)
          "Build the URL using TERM, perform the `url-retrieve' and call CALLBACK if we get redirected."
          (url-retrieve (format (amazon-this-lucky-search-url) (url-hexify-string term))
                        `(lambda (status)
                           (if status
                               (if (eq :redirect (car status))
                                   (progn (message "Received URL: %s" (cadr status))
                                          (funcall ,callback (cadr status)))
                                 (message "Unkown response: %S" status))
                             (message "Search returned no results.")))
                        nil))
      (lambda (term callback)
        "Build the URL using TERM, perform the `url-retrieve' and call CALLBACK if we get redirected."
        (url-retrieve (format (amazon-this-lucky-search-url) (url-hexify-string term))
                      `(lambda (status)
                         (if status
                             (if (eq :redirect (car status))
                                 (progn (message "Received URL: %s" (cadr status))
                                        (funcall ,callback (cadr status)))
                               (message "Unkown response: %S" status))
                           (message "Search returned no results.")))
                      nil t t)))))

(defvar amazon-this--last-url nil "Last url that was fetched by `amazon-this-lucky-and-insert-url'.")

;;;###autoload
(defun amazon-this-lucky-and-insert-url (term &optional insert)
  "Fetch the url that would be visited by `amazon-this-lucky'.

If you just want to do an \"I'm feeling lucky search\", use
`amazon-this-lucky-search' instead.

Interactively:
* Insert the URL at point,
* Kill the searched term, removing it from the buffer (it is killed, not
  deleted, so it can be easily yanked back if desired).
* Search term defaults to region or line, and always queries for
  confirmation.

Non-Interactively:
* Runs synchronously,
* Search TERM is an argument without confirmation,
* Only insert if INSERT is non-nil, otherwise return."
  (interactive '(needsQuerying t))
  (let ((nint (null (called-interactively-p 'any)))
        (l (if (region-active-p) (region-beginning) (line-beginning-position)))
        (r (if (region-active-p) (region-end) (line-end-position)))
        ;; We get current-buffer and point here, because it's
        ;; conceivable that they could change while waiting for input
        ;; from read-string
        (p (point))
        (b (current-buffer)))
    (when nint (setq amazon-this--last-url nil))
    (when (eq term 'needsQuerying)
      (setq term (read-string "Lucky Term: " (buffer-substring-no-properties l r))))
    (unless (stringp term) (error "TERM must be a string!"))
    (amazon-this--do-lucky-search
     term
     `(lambda (url)
        (unless url (error "Received nil url"))
        (with-current-buffer ,b
          (save-excursion
            (if ,nint (goto-char ,p)
              (kill-region ,l ,r)
              (goto-char ,l))
            (when ,insert (insert url))))
        (setq amazon-this--last-url url)))
    (unless nint (deactivate-mark))
    (when nint
      (while (null amazon-this--last-url) (sleep-for 0 10))
      amazon-this--last-url)))

;;;###autoload
(defun amazon-this-lucky-search (prefix)
  "Exactly like `amazon-this-search', but use the \"I'm feeling lucky\" option.
PREFIX determines quoting."
  (interactive "P")
  (amazon-this-search prefix (amazon-this-lucky-search-url)))

(defun amazon-this--maybe-wrap-in-quotes (text flip)
  "Wrap TEXT in quotes.
Depends on the value of FLIP and `amazon-this-wrap-in-quotes'."
  (if (if flip (not amazon-this-wrap-in-quotes) amazon-this-wrap-in-quotes)
      (format "\"%s\"" text)
    text))

(defun amazon-this-parse-and-search-string (text prefix &optional search-url)
  "Convert illegal characters in TEXT to their %XX versions, and then amazons.
PREFIX determines quoting.
SEARCH-URL is usually either the regular or the lucky amazon
search url.

Don't call this function directly, it could change depending on
version. Use `amazon-this-string' instead (or any of the other
amazon-this-\"something\" functions)."
  (let* (;; Create the url
         (query-string (amazon-this--maybe-wrap-in-quotes text prefix))
         ;; Perform the actual search.
         (browse-result (funcall amazon-this-browse-url-function
                                 (format (or search-url (amazon-this-url))
                                         (url-hexify-string query-string)))))
    ;; Maybe suspend emacs.
    (when amazon-this-suspend-after-search (suspend-frame))
    ;; Return what browse-url returned (very usefull for tests).
    browse-result))

;;;###autoload
(defun amazon-this-string (prefix &optional text noconfirm)
  "Amazon given TEXT, but ask the user first if NOCONFIRM is nil.
PREFIX determines quoting."
  (unless noconfirm
    (setq text (read-string "Look up on Amazon: "
                            (if (stringp text) (replace-regexp-in-string "^[[:blank:]]*" "" text)))))
  (if (stringp text)
      (amazon-this-parse-and-search-string text prefix)
    (message "[amazon-this-string] Empty query.")))

;;;###autoload
(defun amazon-this-line (prefix &optional noconfirm)
  "Amazon the current line.
PREFIX determines quoting.
NOCONFIRM goes without asking for confirmation."
  (interactive "P")
  (let ((line (buffer-substring (line-beginning-position) (line-end-position))))
    (amazon-this-string prefix line noconfirm)))

;;;###autoload
(defun amazon-this-ray (prefix &optional noconfirm noregion)
  "Amazon text between the point and end of the line.
If there is a selected region, amazons the region.
PREFIX determines quoting. Negative arguments invert the line segment.
NOCONFIRM goes without asking for confirmation.
NOREGION ignores the region."
  (interactive "P")
  (if (and (region-active-p) (not noregion))
      (amazon-this-region prefix noconfirm)
    (let (beg end pref (arg (prefix-numeric-value prefix)))
      (if (<= arg -1)
          (progn
            (setq beg (line-beginning-position))
            (setq end (point))
            (setq pref (< arg -1)))
        (setq beg (point))
        (setq end (line-end-position))
        (setq pref prefix))
      (amazon-this-string pref (buffer-substring beg end) noconfirm))))

;;;###autoload
(defun amazon-this-word (prefix)
  "Amazon the current word.
PREFIX determines quoting."
  (interactive "P")
  (amazon-this-string prefix (thing-at-point 'word) t))

;;;###autoload
(defun amazon-this-symbol (prefix)
  "Amazon the current symbol.
PREFIX determines quoting."
  (interactive "P")
  (amazon-this-string prefix (thing-at-point 'symbol) t))


;;;###autoload
(defun amazon-this-region (prefix &optional noconfirm)
  "Amazon the current region.
PREFIX determines quoting.
NOCONFIRM goes without asking for confirmation."
  (interactive "P")
  (amazon-this-string
   prefix (buffer-substring-no-properties (region-beginning) (region-end))
   noconfirm))

;;;###autoload
(defun amazon-this (prefix &optional noconfirm)
  "Decide what the user wants to amazon (always something under point).
Unlike `amazon-this-search' (which presents an empty prompt with
\"this\" as the default value), this function inserts the query
in the minibuffer to be edited.
PREFIX argument determines quoting.
NOCONFIRM goes without asking for confirmation."
  (interactive "P")
  (cond
   ((region-active-p) (amazon-this-region prefix noconfirm))
   ((thing-at-point 'symbol) (amazon-this-string prefix (thing-at-point 'symbol) noconfirm))
   ((thing-at-point 'word) (amazon-this-string prefix (thing-at-point 'word) noconfirm))
   (t (amazon-this-line prefix noconfirm))))

;;;###autoload
(defun amazon-this-noconfirm (prefix)
  "Decide what the user wants to amazon and go without confirmation.
Exactly like `amazon-this' or `amazon-this-search', but don't ask
for confirmation.
PREFIX determines quoting."
  (interactive "P")
  (amazon-this prefix 'noconfirm))

;;;###autoload
(defun amazon-this-error (prefix)
  "Amazon the current error in the compilation buffer.
PREFIX determines quoting."
  (interactive "P")
  (unless (boundp 'compilation-mode-map)
    (error "No compilation active"))
  (require 'compile)
  (require 'simple)
  (save-excursion
    (let ((pt (point))
          (buffer-name (next-error-find-buffer)))
      (unless (compilation-buffer-internal-p)
        (set-buffer buffer-name))
      (amazon-this-string prefix
                          (amazon-this-clean-error-string
                           (buffer-substring (line-beginning-position) (line-end-position)))))))


;;;###autoload
(defun amazon-this-clean-error-string (s)
  "Parse error string S and turn it into amazonable strings.

Removes unhelpful details like file names and line numbers from
simple error strings (such as c-like erros).

Uses replacements in `amazon-this-error-regexp' and stops at the first match."
  (interactive)
  (let (out)
    (catch 'result
      (dolist (cur amazon-this-error-regexp out)
        (when (string-match (car cur) s)
          (setq out (replace-regexp-in-string
                     (car cur) (car (cdr cur)) s))
          (throw 'result out))))))

;;;###autoload
(defun amazon-this-cpp-reference ()
  "Visit the most probable cppreference.com page for this word."
  (interactive)
  (amazon-this-parse-and-search-string
   (concat "site:cppreference.com " (thing-at-point 'symbol))
   nil (amazon-this-lucky-search-url)))

;;;###autoload
(defun amazon-this-forecast (prefix)
  "Search amazon for \"weather\".
With PREFIX, ask for location."
  (interactive "P")
  (if (not prefix) (amazon-this-parse-and-search-string "weather" nil)
    (amazon-this-parse-and-search-string
     (concat "weather " (read-string "Location: " nil nil "")) nil)))

(defcustom amazon-this-keybind (kbd "C-c /")
  "Keybinding under which `amazon-this-mode-submap' is assigned.

To change this do something like:
    (setq amazon-this-keybind (kbd \"C-x g\"))
BEFORE activating the function `amazon-this-mode' and BEFORE `require'ing the
`amazon-this' feature."
  :type 'string
  :group 'amazon-this
  :package-version '(amazon-this . "1.4"))

(defcustom amazon-this-modeline-indicator " Amazon"
  "String to display in the modeline when command `amazon-this-mode' is activated."
  :type 'string
  :group 'amazon-this
  :package-version '(amazon-this . "1.8"))

;;;###autoload
(define-minor-mode amazon-this-mode nil nil amazon-this-modeline-indicator
  `((,amazon-this-keybind . ,amazon-this-mode-submap))
  :global t
  :group 'amazon-this)
;; (setq amazon-this-keybind (kbd \"C-x g\"))

(provide 'amazon-this)

;;; amazon-this.el ends here
