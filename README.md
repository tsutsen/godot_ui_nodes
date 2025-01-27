Some extra functionality for Godot's Control nodes. Now, this addon includes modifiers to make Control nodes resizable or draggable in-game. More modifiers are planned for the future.

![Screenshot 2025-01-27 124706](https://github.com/user-attachments/assets/06210a82-ee98-42d4-bc6e-5a58fd19da59)

# How to use it
You just need to add a modifer (Draggable or Resizable) as a child to a Control node. A Control node can have multiple modifiers at once. To change modifier activation key (the one you have to hold to interact), you can change the value of `activation_event` variable. By default, drag/resize activation event is `ui_select` (Space bar). But you can set it as any event from `Project` `>` `Project Settings` `>` `Input Map`, including your custom events.

# What's planned
More modifiers, including:
- `Croppable`
- `Rotatable`
- `Skewable`
- `FreeTransform`
- `Editable` (for labels)

# Contribute!
I want to make this addon a go-to for making in-game editors. If you have any suggestions for new nodes or ideas on how to improve exisiting ones, open an issue. If you want to add the nodes you've created/fix bugs/improve something, open a pull-request. Any help and constructive feedback are greatly appreciated!
