# Android Export Template Generator

> This addon is made for Linux distributions and tested only on LINUX. Adding support for Windows/Mac should not be a problem, it's just a matter of finding the replacements for some specific commands. Contributions are always welcome. 

This is an addon for Godot Engine which generates android export templates with one click of a button(obviously after setting up config directories).

It is advised to follow the following structure for every projects so that you can manage all of them later easily.

* Project root dir/
 * godot project dir/
 * modules/
   * admob/
   * analytics/
 * export_templates/

***godot project dir*** - This is our godot project directory.
***modules*** - copy all required modules to this directory. We can also copy required AndroidManifest template xml or build.gradle template files with custom settings.
***export_templates*** - This is where our template apks are going to be saved.


Copy the directory to addons/ inside our project directory and activate it in Godot Project Settings. Click the AETC button on the top right corner. Choose android sdk, ndk, godot source directory, our project modules directory(above specified) and export template directory(above specified).

Each module has a ***config.py*** and ***AndroidManifestChunk*** files which helps the module creators to add custom parameters to some extent. These parameters are merged into AndroidManifest or build.gradle files. If we need to customize some other things in these files, we can provide a template file similar to the one inside the godot source directory. Just copy this file to ***modules*** directory and make those changes. We can provide these files so that the addon will overwrite the template just before compling the templates.

After choosing these, click the GENERATE button. When clicking this button a terminal window is to be expected and run all required things which in turn spits out two template apk files into our export template directory.

The paths will be saved so that for the next time onwards we need to only click the GENERATE button.

All the changes done to the Godot source directory will be reverted back after creating the export templates so that we can easily jump between projects and create export templates without any difficulties.
