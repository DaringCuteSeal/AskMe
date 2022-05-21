# AskMe (Multiple Choices) v.1.0.6
Want to prepare for your exam? Great! Now you can do that from your command line.

## Features
- Colors!
- Usage of simple scripts for questions
- Questions & choices shuffling
- Might help you to get 100 on your exam :)

## CLI Usage
Usage: [options] \<AskMe file\>

Options:

- -h|--help: Show this help

- -V|--version: Print version
	
- -n|--no-unicode: Only use ASCII (useful in TTYs)
	
- -a|--auto-enter: Enter choice automatically after user input

## Writing Files
An (multiple choices) AskMe file contains **global variables** (`global`) *(not required)*, **properties** (`props`), and **questions** (`q_n`). It is written in Bash as functions that assign variables.

Generally, (multiple choices) AskMe file should look like this:

```bash
#!/hint/bash

props()
{
	title="Your title"
	shuffle_questions=yes
	shuffle=yes
	wait_duration=1

	...
}

q_1()
{
	shuffle=no
	question="Your question"
	show_correct=yes
	choices=("Incorrect answer" "Also incorrect answer" "Correct answer")
	answer=3
}

q_2()
{
	question="Your second question"
	show_correct=no
	choices=("True" "False")
	answer=1
}
...
```


### Global Variables
The `global()` function contains properties (variables) for the questions. The *title* variable is the only one needed, although it'll fall back to the default value when unset . Available global variables are:
- title: your question title (string)
- shuffle\_questions: shuffle questions order (yes|no)
- shuffle: shuffle choices (yes|no)
- show\_correct: show correct answer after user answers (yes|no)
- wait\_duration: *n* second delay after answering a question (int) 

### Questions
**Question functions** should be named `q_1`, `q_2`, and so on. It needs to contain these variables:
- question: your question (string)
- choices: array of choices (strings)
- answer: answer for your question (integer: index of choices array (starts from 1))

There are some optional variables overriding values set on the `global` function too. For the list, please see **global variables** section.

### Extras
The first line containing `#!/hint/bash` can be used when you need syntax highlighting and/or auto-indentations. It hints that your .askme file is a bash script.
