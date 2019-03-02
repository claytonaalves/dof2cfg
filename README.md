# dof2cfg

This tool generates a .cfg file from a .dof file in a Delphi 5.0 to 7.0 project.

It's useful when you have a build pipeline where the .cfg file is not
tracked in a version control system. This allows you to update .cfg
file reflecting what was changed in .dof file.

## Background

Delphi IDE works with .dof files to store project metadata, while
delphi compiler uses .cfg files to read this metadata.

Delphi IDE updates .cfg file every time it writes the .dof file so
this is useful if you do not want to start the IDE for this purpose.

There is also Bdsproj2cfg which does the same for .bdsproj files used by Delphi
2005 and 2006, search for it on CodeCentral.

Originally writen by **Thomas Mueller**.

Original source: http://cc.embarcadero.com/Item/28351
