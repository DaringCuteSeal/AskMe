# AskMe Web (Multiple Choices)
Answer multiple choices questions.

## Features
- Nicely embeddable to other webpages
- Light... although my code is still messy but it's overall light because it doesn't have a lot of visual effects.

## Query Strings
### file=url
Use `file=<path to file>` to load a JSON file. Only supports files from the internet. Example: https://daringcuteseal.xyz/software/askme/web/multchoices?file=try.json

### theme=dark|light
`dark` forces a dark theme, any other values beside dark will force a light theme. If not set, a light theme is used by default.

## Writing Files
Generally, AskMe Web memorize file should look like this:

```json
{
	"title": "Multiple Choice Question Test",
	"description": "Test questions.",

	"list":
	[
		{
			"label": "First question",
			"choice":
			[
				"Not the correct answer",
				"The correct answer",
				"Not the correct answer too"
			],
			"correct": 2
		},

		{
			"label": "Second question",
			"choice":
			[
				"The correct answer",
				"Not the correct answer too",
				"Not the correct answer"
			],
			"correct": 1
		},

		{
			"label": "Third question",
			"choice":
			[
				"True",
				"False"
			],
			"correct": 1
		}
	]
}
```

### Variables
Variables available are:
- title: your question title (string)
- list: an array of questions containing the question label, choices, and the correct answer (index of correct answer, with elements starting from 1).

And some optional variables are:
- description: a subtitle to show below the title
