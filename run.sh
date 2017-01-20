#!/bin/bash
./valaweb src/teleprinter.web && valac --pkg gio-2.0 --pkg gee-0.8 src/teleprinter.vala -o teleprinter && ./teleprinter
