# AskMe (Multiple Choices) v.1.0.3
Want to prepare for your exam? Great! Now you can do that from your command line.

## Features
- Colors!
- Usage of simple scripts for questions
- Max. 26 choices
- Might help you to get 100 on your exam :)

## CLI Usage
AskMe accepts *one* argument: a valid .askme file.

## Writing .askme Files
An .askme file contains properties and questions. It is written in Bash as functions that assign variables.
Generally, (multiple choices) AskMe file should look like this:

```bash
#!/hint/bash

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
	shuffle=yes
	question="Your second question"
	showcorrect=no
	choices=("True" "False")
	answer=1
}
```


### Properties
The **props()** function contains properties for the question. Available properties are:
- title: your question title (string)

### Questions
**Question functions** should be called **q_1**, **q_2**, and so on. It needs to contain these variables:
- question: your question (string)
- choices: array of choices (strings)
- answer: answer for your question (integer: index of choices array starting from 1)

There are some optional variables you can set too:
- showcorrect: Show correct answer if user answered incorrectly (yes|no)

### Extra
The **first line** containing `#!/hint/bash` is only used when you need syntax highlighting and auto-indentations. It hints that your .askme file is a bash script.

## TODO
- Ability to shuffle questions (shuffle\_questions on *props()*)
- Ability to shuffle choices (shuffle on question functions)
- More error handlings.

## Limitations/Bugs
- When required variable is unset, the program exits directly. Instead, it should go to the next question.
- Weird prompt behaviour (possibly because of color).
- Undesired way of checking for missing questions.
