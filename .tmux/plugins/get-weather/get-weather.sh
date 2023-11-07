#!/bin/bash

weather -a -q -f kbwi | $PAGER
echo 'Press Ctrl-C to close'
