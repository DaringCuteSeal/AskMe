# AskMe (Memorize) v.1.0.6
Memorize stuff like words from other languages, terms, etc. quickly.

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

Special options (overrides variables set on AskMe file):
- -l|--loop: Only exit when terminated
- -s|--shuffle: Shuffle questions
- -c|--show-correct: Show correct answer

## Writing Files
A (memorize) AskMe file contains **variable assignments** and an **associative array** with the terms and the definition/meaning/whatever.

Generally, (memorize) AskMe file should look like this:

```bash
#!/hint/bash

title="Animals sound"
subtitle="Answer the animal name with their corresponding sound."
show_correct=yes
shuffle=yes
wait_duration=1
loop=yes
...

declare -A questions=(
["Cow"]="Moo"
[Chicken]=Cluck
['Dog']="Woof"
[Cat]='("Meow", "Purr")' # ← Multiple correct answers
...
)

```

### Variables
Variables available are:
- title: your question title (string)

And some optional variables are:
- subtitle: a subtitle to show below the title
- show\_correct: show the correct answer after a mistake (yes|no)
- shuffle: shuffle terms (yes|no)
- loop: loop terms; exit only when terminated (yes|no)
- wait\_duration: wait *n* seconds after answering (int)

### Questions
The `questions` associative array should have terms as the subscript with the answers (definition/meaning/whatever) as the value. More than one answers are allowed (pretend that bash supports 2-dimensional array).

### Extras
The first line containing `#!/hint/bash` can be used when you need syntax highlighting and/or auto-indentations. It hints that your .askme file is a bash script.
