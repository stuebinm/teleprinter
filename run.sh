#!/bin/bash
./valaweb src/teleprinter.web && valac --pkg gee-0.8 src/teleprinter.vala -o teleprinter && ./teleprinter
