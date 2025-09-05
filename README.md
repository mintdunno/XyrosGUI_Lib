# Xyros Modern GUI - Documentation

This document provides a comprehensive guide on how to use the modernized Xyros GUI library.
The new design is built with a frosted glass aesthetic, smooth animations, and a responsive layout system.

## 1. Loading the Library
To use the library, you first need to load it into your script.

`local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/main/XyrosGUI.lua"))()`

## 2. Creating a Window
To create a new GUI window, use the `Library.new()` function.

`local window = Library.new(windowName, options)`

- `windowName` (string): The title of the window.
- `options` (table, optional): A table of options to customize the window.
    - `constrainToScreen` (boolean, default: true): Restricts window dragging to screen bounds.

Example:
`local MyWindow = Library.new("My Modern GUI")`

## 3. Creating Tabs
Tabs are created within a window and are displayed in the sidebar.

`local myTab = Library.CreateTab(window, tabName, iconId)`

- `window` (table): The window object returned by `Library.new()`.
- `tabName` (string): The name of the tab.
- `iconId` (string, optional): The Roblox asset ID for the tab icon.

The function returns a table containing the `Tab` and `Page` objects, and an `AddSection` method.

Example:
`local MainTab = Library.CreateTab(MyWindow, "Main", "rbxassetid://10746039695")`

## 4. Creating Sections
Sections are containers for UI elements within a tab's page. They are automatically arranged in columns.

`local mySection = MainTab.AddSection(sectionName)`

- `sectionName` (string): The title of the section.

The function returns a table containing the `Section` object and methods to add UI components.

Example:
`local PlayerSection = MainTab.AddSection("Player Settings")`

## 5. Adding UI Components
All components are added to a section.

### Toggle
`PlayerSection.AddToggle(name, callback)`
- `name` (string): The label for the toggle.
- `callback` (function): A function that is called when the toggle state changes. It receives the new state (boolean) as an argument.

### Button
`PlayerSection.AddButton(name, callback)`
- `name` (string): The text on the button.
- `callback` (function): A function that is called when the button is clicked.

### Slider
`PlayerSection.AddSlider(name, min, max, default, callback)`
- `name` (string): The label for the slider.
- `min` (number): The minimum value of the slider.
- `max` (number): The maximum value of the slider.
- `default` (number): The initial value of the slider.
- `callback` (function): A function that is called when the slider value changes. It receives the new value as an argument.

### Dropdown
`PlayerSection.AddDropdown(name, options, callback)`
- `name` (string): The label for the dropdown.
- `options` (table): A table of options for the dropdown. Each option can be a string or a table `{text = "Display Text", value = "SomeValue"}`.
- `callback` (function): A function that is called when a new option is selected. It receives the selected value as an argument.
