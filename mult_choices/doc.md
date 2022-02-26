# AskMe (Multiple Choices) v.1.0.4
Want to prepare for your exam? Great! Now you can do that from your command line.

## Features
- Colors!
- Usage of simple scripts for questions
- Questions & choices shuffling
- Might help you to get 100 on your exam :)

## CLI Usage
Usage: [options] \<AskMe file\>

Options:
	-h   --help          Show this help
	-V   --version       Print version
	-n   --no-unicode    Only use ASCII (useful in TTYs)
	-a   --auto-enter    Enter choice automatically after user input

## Writing .askme Files
An .askme file contains **global variables** (`global`) *(not required)*, **properties** (`props`), and **questions** (`q_n`). It is written in Bash as functions that assign variables.

Generally, (multiple choices) AskMe file should look like this:

```bash
#!/hint/bash

global()
{

	shuffle_questions=yes
	shuffle=yes

props()
{
	title="Your title"
	wait_duration=1
	shuffle_questions=0
	...
}

q_1()
{
	shuffle=no
	question="Your question"
	showcorrect=yes
	choices=("Incorrect answer" "Also incorrect answer" "Correct answer")
	answer=3
}

q_2()
{
	question="Your second question"
	showcorrect=no
	choices=("True" "False")
	answer=1
}
```


### Global Variables
The `global()` function contains variables for questions. It is *not required*. Available global variables are:
- shuffle\_questions: shuffle questions order (yes|no)
- shuffle: shuffle choices (yes|no)
- showcorrect: show correct answer after user answers (yes|no)

### Properties
The `props()` function contains properties for the question. Available properties are:
- title: your question title (string)

### Questions
**Question functions** should be named **q_1**, **q_2**, and so on. It needs to contain these variables:
- question: your question (string)
- choices: array of choices (strings)
- answer: answer for your question (integer: index of choices array (starts from 1))

There are some optional variables overriding values set on the `global` function too. For the list, please see **global variables** section.

### Extras
The first line containing `#!/hint/bash` can be used when you need syntax highlighting and/or auto-indentations. It hints that your .askme file is a bash script.
