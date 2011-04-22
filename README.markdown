Usage
=====

This is plugin for xchat that lets you execute javascript.

Take a look into *example* to get a first impression.


When the plugin is loaded it registers 4 commands

* /XDS_LOAD "C:\myscript.ds" - loads myscript.ds and executes xchat_plugin_init().
* /XDS_UNLOAD "C:\myscript.ds" unloads myscript.ds (if it is already loaded) and executes xchat_plugin_deinit(), also removes all hooks for this scripts.
* /XDS_LIST will list all loaded scripts.
* /XDS_APPEND "C:\myscript.ds" will append myscript.ds to the end of xcdscript.txt. xcdscript.txt lays in */home/user/.xchat2`* for Linux or *C:\Documents and Settings\yourusername\Application Data\X-Chat 2* for Silverex's version. You can edit the file manually. Each line is treated as path to script to be automatically loaded.

What?
=====

xcdscript is a X-Chat plugin that enables it to use DMDScript (aka JavaScript, ECMAScript) as scripting language. It is written in Digital Mars D language and uses DMDScript implementation of ECMA 262 scripting language. This plugin is one more proof how well D can integrate into the C world. 


Why?
====

I've always wanted an IRC client that supports JavaScript-ing. I wanted to script something but I don't want to learn Pearl and I don't even want to imagine Python or TCL. Plus JavaScript is easy, familiar (to C-like and web programmers) and nice. 

How? (licence)
==============

This is free software and as any free software is provided as-is. Author will not be responsible for anything 'negative' this software may cause. If you use, redistribute or modify it you declare that you have read, understood and accepted this licence agreement ("How?" section).

xcdscript is free and open source. There are no restrictions. I.e. it uses "bobef license" which is: use without restrictions at your own risk. 

Platform notes
==========

This is the Win32 version. I don't have linux currently but the source doesn't contain any windoze specific code (except WinMain), so it shouldn't be a problem to compile it for linux. It is tested on X-Chat 2.4.5-2 compiled by Silverex.

Installation
========
Extract the dll into X-Chat's plugin-s directory to load automatically or load it manually.


Development
=========

Functions
---------

* xchat_hook_command("COMMAND",priority,"callback_name","help text")
* xchat_hook_print("TEXT_COMMAND",priority,"callback_name")
* xchat_hook_server("SERVER_EVENT",priority,"callback_name")
* xchat_hook_timer(timeout,"callback_name")
* xchat_unhook(id_returned_by_xchat_hook)
* xchat_command("COMMAND")
* xchat_print("TEXT")
* xchat_emit_print("TEXT EVENT",parameter1,...) - takes up to 32 parameters
* xchat_send_modes(nicks_array,modes_per_line,sign,char)
* xchat_get_info(property)
* xchat_get_prefs(setting)
* xchat_find_context("SERVER","CHANNEL") - both parameters may be null or undefined
* xchat_get_context()
* xchat_set_context(context_id_returned_by_get_find_context)
* xchat_nickcmp("NICK1","NICK2")
* xchat_strip("TEXT",what_to_strip) - what_to_strip 1 - colours, 2 - bold etc, 3 - all
* xchat_list_get("LIST")
- returns array with objects with properties named after the ones at og docs

Predefined symbols
------------------

* SCRIPT_PATH
* XCHAT_IFACE_MAJOR
* XCHAT_IFACE_MINOR
* XCHAT_IFACE_MICRO
* XCHAT_IFACE_VERSION
* XCHAT_PRI_HIGHEST
* XCHAT_PRI_HIGH
* XCHAT_PRI_NORM
* XCHAT_PRI_LOW
* XCHAT_PRI_LOWEST
* XCHAT_EAT_NONE
* XCHAT_EAT_XCHAT
* XCHAT_EAT_PLUGIN
* XCHAT_EAT_ALL
