# DISCONTINUED

### Check out [Modu](https://github.com/fatboychummy/Modu) for the more updated version!

-----

-----

-----







# InventoryMods
A computercraft modification for your inventory.  Completely modular.

## Requirements
As it is modular, a lot of requirements may change depending on your setup, however the absolute BASE requirements currently are:

1. `ComputerCraft computer (basic/advanced) (1)`
2. `Plethora manipulator(s) for the following items: (any amount, the computer checks which manipulator has what module)`
   * `Introspection module`
   * `Chat Recorder module`
3. `MinimalPeripherals chatbox (1)`*

**This can be changed, depending on the event you want to use.  Note that to change this will require changing some of the base coding at the moment.  I am working on this so that it is not a requirement*

## Setup
The computer, manipulator(s), and chatbox must all be connected on the same network via WIRED modems, wireless modems do not work.

### Steps:

1. Download the 'main' program to your computer, along with the core module, along with whichever other modules you may want.
   * Be sure all the modules are in one folder, and NOT in the root folder. (The default folder used is "/modules/")
   * main.lua is NOT a module, leave it out of there or the program confuses itself a bit.
   
2. Run the program once, a customization file will be produced.  Open it and change "modulesLocation" to whatever folder you are saving them to.

3. Check which manipulators you require, write down their names.  Put their names as strings in the table "manipulators".
   * To get the names, disconnect/connect the manipulator to a modem by right-clicking the modem.  A chat message will appear saying "x is disconnected".

4. If you want your command prefix to be something specific, change it in the customization file as well.  The default prefix is `i`
   * Example: `\i get cobblestone 64`

5. Be sure the Introspection module and Chat recorder module are bound to your player
   * You can bind the two modules to your player by holding them in your hand and shift+right-clicking.

6. You should be ready to go!  Run the main program again and you should see a message saying "Ready" in the chat-bar.  Test the program by simply saying "\<prefix> get cobblestone 1".  You should get 1 cobblestone in your inventory.


## Additional Info
Additional info can be found on this git's Wiki.  This includes module syntax and more.
