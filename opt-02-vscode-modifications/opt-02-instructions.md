# Opt 02 - VSCode Modifications
Here are a couple of VSCode modifications that you might like.

## Maximize/Restore Terminal Toggle
As of the writing of this document, VSCode does not have a built-in keyboard shortcut to maximize the terminal. This is a super-nice feature already exists, we just have to assign a keyboard shortcut to it:

- Go to File > Preferences > Keyboard Shortcuts
  - or <kbd>Ctrl+K</kbd> and <kbd>Ctrl+S</kbd>
- Then, in the search field, type
  
     `workbench.action.toggleMaximizedPanel`
		
- Once you find the Command, double-click it and enter the keyboard shortcut of your choice. For example:
  - <kbd>Ctrl+Shift+Q</kbd>
  
That's it. Now, you can maximize the terminal by pressing the keyboard shortcut. Restore it to its original size/place by pressing the keyboard shortcut again. Awesome.

## Install the Peacock Extension
The Peacock extension makes subtle changes to the color of a VSCode workspace. If you plan on running more than one VSCode workspace at a time, it can help to differentiate between them. 

Install it from Quick Open (<kbd>Ctrl+P,/kbd>)

`ext install johnpapa.vscode-peacock`

I also recommend the Hashicorp HCL extension for HCL syntax highlighting and the Github Markdown Styling extension for reading markdown files (which this repository is full of!)