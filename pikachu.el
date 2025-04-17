(defconst pikachu-directory (file-name-directory (or load-file-name buffer-file-name)))
(defconst pikachu-modeline-help-string "mouse-1: Run with pikachu!")

;; ('v') (*'v') ('V'*) ('v'*)
;; ('v') ('V') ('>') ('^') ('<') ('V') ('v')

;; 在文件顶部添加变量定义
(defvar pikachu-idle-frame 0
  "Frame number to show when idle (cursor not moving).")

(defgroup pikachu nil
  "Customization group for `pikachu-mode'."
  :group 'frames)

(defun pikachu-refresh ()
  "Refresh after option change if loaded."
  (when (featurep 'pikachu)
    (when (bound-and-true-p pikachu-mode)
      (force-mode-line-update))))

(defcustom pikachu-animation-frame-interval 0.1
  "Number of seconds between animation frames."
  :type 'float
  :set (lambda (sym val)
         (set-default sym val)
         (pikachu-refresh)))

(defcustom pikachu-click-hook nil
  "Hook run after clicking on the pikachu."
  :type 'hook)

(defvar pikachu-animation-timer nil
  "Internal timer used for switching animation frames.")

(defvar pikachu-runnings 0
  "Counter of how many times the pikachu has rund.")

(defun pikachu-start-animation ()
  "Start the pikachu animation."
  (interactive)
  (setq pikachu-runnings 0)
  (when (not (and pikachu-animate-pikachu
                  pikachu-animation-timer))
    (setq pikachu-animation-timer (run-at-time nil
                                              pikachu-animation-frame-interval
                                              #'pikachu-switch-anim-frame))
    (setq pikachu-animate-pikachu t)))

(defun pikachu-stop-animation ()
  "Stop the pikachu animation."
  (interactive)
  (when (and pikachu-animate-pikachu
             pikachu-animation-timer)
    (cancel-timer pikachu-animation-timer)
    (setq pikachu-animation-timer nil)
    (setq pikachu-animate-pikachu nil)))

(defcustom pikachu-minimum-window-width 45
  "Determines the minimum width of the window, below which party pikachu will not be displayed."
  :type 'integer
  :set (lambda (sym val)
         (set-default sym val)
         (pikachu-refresh)))

(defcustom pikachu-animate-pikachu nil
  "If non-nil, pikachu animation is enabled."
  :type '(choice (const :tag "Enabled" t)
                 (const :tag "Disabled" nil))
  :set (lambda (sym val)
         (set-default sym val)
         (if val
             (pikachu-start-animation)
           (pikachu-stop-animation))
         (pikachu-refresh)))

(defcustom pikachu-spaces-before 0
  "Spaces of padding before pikachu in mode line."
  :type 'integer
  :set (lambda (sym val)
         (set-default sym val)
         (pikachu-refresh)))

(defcustom pikachu-spaces-after 0
  "Spaces of padding after pikachu in the mode line."
  :type 'integer
  :set (lambda (sym val)
         (set-default sym val)
         (pikachu-refresh)))

(defcustom pikachu-num-runnings 3
  "How many times party pikachu will run."
  :type 'integer)

(defvar pikachu-frame-list (number-sequence 1 10)
  "List of indices for the pikachu animation frames.
For example, an animation with a total of ten frames would have a
`pikachu-frame-list` of (1 2 3 4 5 6 7 8 9 10)")

(defvar pikachu-type nil
  "The type of pikachu selected, e.g. default or science.")

(defvar pikachu-static-image nil
  "The image shown when pikachu is at rest, i.e. not running.")

(defvar pikachu-animation-frames nil
  "A list of the animation frames for the current pikachu.")


;; 2. 修改 pikachu-create-frame 支持0帧
(defun pikachu-create-frame (pikachu id)
  "Create image for frame with pikachu type PARROT and frame id ID."
  (let ((frame-file (concat pikachu-directory
                           (format "img/%s/%s-pikachu-frame-%d.xpm" pikachu pikachu id))))
    (when (file-exists-p frame-file)
      (create-image frame-file 'xpm nil :ascent 'center))))

(defun pikachu-load-frames (pikachu)
  "Load the images for the selected PARROT."
  (when (image-type-available-p 'xpm)
    (setq pikachu-static-image (pikachu-create-frame pikachu 0))
    (setq pikachu-animation-frames (mapcar (lambda (id)
                                            (pikachu-create-frame pikachu id))
                                          pikachu-frame-list))))

(defun pikachu-sequence-length (pikachu)
  "Return length of the animation sequence for PARROT."
  (cond ((string= pikachu "default") 8)
        (t (error (format "Invalid pikachu %s" pikachu)))))

(defun pikachu-set-pikachu-type (pikachu &optional silent)
  "Set the desired PARROT type in the mode line."
  (interactive (list (completing-read "Select pikachu: "
                                      '(default) nil t)))
  (setq pikachu-frame-list (number-sequence 1 (pikachu-sequence-length pikachu)))
  (setq pikachu-type pikachu)
  (pikachu-load-frames pikachu)
  (unless silent
      (run-at-time "0.5 seconds" nil #'pikachu-start-animation)
      (message (format "%s pikachu selected" pikachu))))

(defvar pikachu-current-frame 0)

(defun pikachu-switch-anim-frame ()
  "Change to the next frame in the pikachu animation.
If the pikachu has already rund for `pikachu-num-runnings', the animation will
stop."
  (setq pikachu-current-frame (% (+ 1 pikachu-current-frame) (car (last pikachu-frame-list))))
  (when (eq pikachu-current-frame 0)
    (setq pikachu-runnings (+ 1 pikachu-runnings))
    (when (and pikachu-num-runnings (>= pikachu-runnings pikachu-num-runnings))
      (pikachu-stop-animation)))
  (force-mode-line-update))

(defun pikachu-get-anim-frame ()
  "Get the current animation frame."
  (if pikachu-animate-pikachu
      (nth pikachu-current-frame pikachu-animation-frames)
    pikachu-static-image))

(defun pikachu-add-click-handler (string)
  "Add a handler to STRING for animating the pikachu when it is clicked."
  (propertize string 'keymap `(keymap (mode-line keymap (down-mouse-1 . ,(lambda () (interactive)
                                                                           (pikachu-start-animation)
                                                                           (run-hooks 'pikachu-click-hook)))))))

(defun pikachu-create ()
  "Generate the party pikachu string."
  (if (< (window-width) pikachu-minimum-window-width)
      ""                                ; disabled for too small windows
    (let ((pikachu-string (make-string pikachu-spaces-before ?\s)))
      (setq pikachu-string (concat pikachu-string (pikachu-add-click-handler
                                                             (propertize "-" 'display (pikachu-get-anim-frame)))
                                        (make-string pikachu-spaces-after ?\s)))
      (propertize pikachu-string 'help-echo pikachu-modeline-help-string))))

(defvar pikachu-old-cdr-mode-line-position nil)
;;;###autoload
(define-minor-mode pikachu-mode
  "Use Parrot to show when you're running.
You can customize this minor mode, see option `pikachu-mode'."
  :global t
  :require 'pikachu
  (if pikachu-mode
      (progn
        (unless pikachu-type (pikachu-set-pikachu-type 'default))
        (unless pikachu-old-cdr-mode-line-position
          (setq pikachu-old-cdr-mode-line-position (cdr mode-line-position)))
        (setcdr mode-line-position (cons '(:eval (list (pikachu-create)))
                                         (cdr pikachu-old-cdr-mode-line-position))))
    (setcdr mode-line-position pikachu-old-cdr-mode-line-position)))

(provide 'pikachu)

;;; pikachu.el ends here
