#!/bin/sh
valac --pkg posix --pkg gee-0.8 --pkg gio-2.0 printer.vala regex.vala commands.vala main.vala -o main && ./main test.print
