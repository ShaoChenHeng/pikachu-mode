# Pikachu Mode for Emacs

![demo2](https://github.com/ShaoChenHeng/pikachu-mode/blob/main/screenshot/demo2.png)

![demo1](https://github.com/ShaoChenHeng/pikachu-mode/blob/main/screenshot/demo1.png)

A modified Emacs plugin based on the [Parrot](https://github.com/dp12/parrot) that displays a cute Pikachu animation in the mode line.
![License](https://img.shields.io/badge/license-GPL3.0-blue)
![Emacs Version](https://img.shields.io/badge/Emacs-26.1%2B-brightgreen)
![GitHub Stars](https://img.shields.io/github/stars/shaochenheng/pikachu-mode?style=social)

## 🚀 Usage

### 1. Manual Installation
```elisp
(add-to-list 'load-path "~/.emacs.d/site-lisp/pikachu-mode")
(require 'pikachu)
(pikachu-mode 1)
```

### 2. Add hook

Add a hook to make Pikachu run when the cursor moves and sit when the cursor is stationary.

```elisp
(add-hook 'post-command-hook (lambda () (pikachu-start-animation)))
(add-hook 'emacs-idle-hook (lambda () (pikachu-stop-animation)))
```
Add click event:

```elisp
(add-hook 'pikachu-click-hook
          (lambda ()
            (message "Pika pika!")))
```

## ✨ Acknowledgments

This project is developed based on modifications to the [dp12/parrot](https://github.com/dp12/parrot) project. Special thanks to the original author for their creativity and foundational implementation.


