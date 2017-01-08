;;; amazon-this-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "amazon-this" "amazon-this.el" (0 0 0 0))
;;; Generated autoloads from amazon-this.el

(autoload 'amazon-this-search "amazon-this" "\
Write and do a amazon search.
Interactively PREFIX determines quoting.
Non-interactively SEARCH-STRING is the string to search.

\(fn PREFIX &optional SEARCH-STRING)" t nil)

(autoload 'amazon-this-lucky-and-insert-url "amazon-this" "\
Fetch the url that would be visited by `amazon-this-lucky'.

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
* Only insert if INSERT is non-nil, otherwise return.

\(fn TERM &optional INSERT)" t nil)

(autoload 'amazon-this-lucky-search "amazon-this" "\
Exactly like `amazon-this-search', but use the \"I'm feeling lucky\" option.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'amazon-this-string "amazon-this" "\
Amazon given TEXT, but ask the user first if NOCONFIRM is nil.
PREFIX determines quoting.

\(fn PREFIX &optional TEXT NOCONFIRM)" nil nil)

(autoload 'amazon-this-line "amazon-this" "\
Amazon the current line.
PREFIX determines quoting.
NOCONFIRM goes without asking for confirmation.

\(fn PREFIX &optional NOCONFIRM)" t nil)

(autoload 'amazon-this-ray "amazon-this" "\
Amazon text between the point and end of the line.
If there is a selected region, amazons the region.
PREFIX determines quoting. Negative arguments invert the line segment.
NOCONFIRM goes without asking for confirmation.
NOREGION ignores the region.

\(fn PREFIX &optional NOCONFIRM NOREGION)" t nil)

(autoload 'amazon-this-word "amazon-this" "\
Amazon the current word.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'amazon-this-symbol "amazon-this" "\
Amazon the current symbol.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'amazon-this-region "amazon-this" "\
Amazon the current region.
PREFIX determines quoting.
NOCONFIRM goes without asking for confirmation.

\(fn PREFIX &optional NOCONFIRM)" t nil)

(autoload 'amazon-this "amazon-this" "\
Decide what the user wants to amazon (always something under point).
Unlike `amazon-this-search' (which presents an empty prompt with
\"this\" as the default value), this function inserts the query
in the minibuffer to be edited.
PREFIX argument determines quoting.
NOCONFIRM goes without asking for confirmation.

\(fn PREFIX &optional NOCONFIRM)" t nil)

(autoload 'amazon-this-noconfirm "amazon-this" "\
Decide what the user wants to amazon and go without confirmation.
Exactly like `amazon-this' or `amazon-this-search', but don't ask
for confirmation.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'amazon-this-error "amazon-this" "\
Amazon the current error in the compilation buffer.
PREFIX determines quoting.

\(fn PREFIX)" t nil)

(autoload 'amazon-this-clean-error-string "amazon-this" "\
Parse error string S and turn it into amazonable strings.

Removes unhelpful details like file names and line numbers from
simple error strings (such as c-like erros).

Uses replacements in `amazon-this-error-regexp' and stops at the first match.

\(fn S)" t nil)

(autoload 'amazon-this-cpp-reference "amazon-this" "\
Visit the most probable cppreference.com page for this word.

\(fn)" t nil)

(autoload 'amazon-this-forecast "amazon-this" "\
Search amazon for \"weather\".
With PREFIX, ask for location.

\(fn PREFIX)" t nil)

(defvar amazon-this-mode nil "\
Non-nil if Amazon-This mode is enabled.
See the `amazon-this-mode' command
for a description of this minor mode.")

(custom-autoload 'amazon-this-mode "amazon-this" nil)

(autoload 'amazon-this-mode "amazon-this" "\
Toggle Amazon-This mode on or off.
With a prefix argument ARG, enable Amazon-This mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil, and toggle it if ARG is `toggle'.
\\{amazon-this-mode-map}

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "amazon-this" '("amazon-this-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; amazon-this-autoloads.el ends here
