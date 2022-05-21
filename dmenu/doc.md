# AskMe (dmenu) v.1.0.6
Memorize stuff like words from other languages, terms, etc. quickly.
This script uses [dmenu](https://tools.suckless.org/dmenu/) to display available choices for answering. It is backwards-compatible with [AskMe Memorize](../memorize).

# Extra Dependencies
This script depends on [dmenu](https://tools.suckless.org/dmenu/).

## Features
- Colors!
- Usage of simple scripts for questions
- Question shuffling and looping

## CLI Usage
Usage: askme-memorize.sh [options] \<AskMe file\>

Options:
- -h|--help: Show this help
- -V|--version: Print version
- -n|--no-unicode: Only use ASCII (useful in TTYs)
- -d|--dmenu: Specify another dmenu

Special options (overrides variables set on AskMe file):
- -l|--loop: Only exit when terminated
- -s|--shuffle: Shuffle questions
- -c|--show-correct: Show correct answer

## Writing Files
Please read [AskMe Me Memorize #Writing Files](../memorize/doc.md). The only option (variable) unavailable is `wait_duration` but it is fine to set it otherwise.
