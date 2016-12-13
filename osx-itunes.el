;;; osx-itunes.el --- An interface fon OSX itunes
;; Copyright 2016 emuio
;;
;; Author: emuio <emuiolr@gmail.com>
;;
;; Created: 2016-12-09
;; Version: 0.0.1

;;; Commentary:
;;
;; An interface for iTunes.
;;
;; You can do :
;; 1. play or stop music.
;; 2. love or unlove current music.
;;

;;; Code:


(defun osx-itunes-run-osascript (script)
  "Tell itunes to run the osascript SCRIPT."
  (let (all-script)
    (setq all-script (format "osascript -e 'tell application \"iTunes\"
%s
end tell'" script))
    (replace-regexp-in-string "\n$" "" (shell-command-to-string all-script))))
;; (osx-itunes-run-osascript "activate")

(defun osx-itunes-get-info ()
  "Get current music info."
  (let ((list-name '("name" "artist" "loved"))
        (script nil)
        str
        ret-info)
    (dolist (elt list-name script)
      (setq str (format "%s of the current track," elt))
      (setq script (concat script str)))
    (setq script (substring script 0 -1))
    (setq ret-info (split-string (osx-itunes-run-osascript
                                  (concat "set retval to {" script "}"))
                                 ", " t "\n"))
    (cl-mapcar 'cons list-name ret-info)))
;; (osx-itunes-get-info)

(defun osx-itunes-get-value (key info)
  "Get value from 'osx-itunes-get-info' by KEY INFO."
  (cdr (assoc key info)))
;; (osx-itunes-get-value "name" (osx-itunes-get-info))
;; (osx-itunes-get-value "artist" (osx-itunes-get-info))
;; (osx-itunes-get-value "loved" (osx-itunes-get-info))

(defun osx-itunes-get-name-artist-group (info)
  "Get string with \"music name\" - \"music artist\" from INFO."
  (format " music: %s - %s"
          (osx-itunes-get-value "name" info)
          (osx-itunes-get-value "artist" info)))

(defun osx-itunes-get-player-status ()
  "Get player status, which is \"stopped, paused, or playing\"."
  (osx-itunes-run-osascript "player state"))
;; (osx-itunes-get-player-status)

(defun osx-itunes-play-or-pause ()
  "Tell itunes to play or pause."
  (interactive)
  (osx-itunes-run-osascript "playpause")
  (let ((info (osx-itunes-get-info)))
    (message (concat (osx-itunes-get-player-status)
                     (osx-itunes-get-name-artist-group info)))))
;; (osx-itunes-play-or-pause)

(defun osx-itunes-set-loved-or-not (love)
  "Tell itunes to love or not for current track, LOVE is t or nil."
  (osx-itunes-run-osascript
   (format "set loved of current track to %s" (if love "true" "false")))
  (let ((info (osx-itunes-get-info)))
    (concat (if love "loved" "unloved")
            (osx-itunes-get-name-artist-group info))))
;; (osx-itunes-set-loved-or-not nil)

(defun osx-itunes-love-current ()
  "Tell itunes to love current music."
  (interactive)
  (osx-itunes-set-loved-or-not t))
;; (osx-itunes-love-current)

(defun osx-itunes-unlove-current ()
  "Tell itunes to unlove current music."
  (interactive)
  (osx-itunes-set-loved-or-not nil))
;; (osx-itunes-unlove-current)

;;; osx-itunes.el ends here
