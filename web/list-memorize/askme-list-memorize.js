/* AskMe List Memorizer (originally called CIVZ)
 *
 * Made with <3 for 8D on December 2022.
 * Thank you for an opportunity to learn more about JavaScript.
 * You guys are awesome.
*/

/* Things I learned:
   * query strings
   * fetch
   * async, await
   * alerts
   * element additions and deletions
   * ...probably more
*/

// Get query strings
const params = new Proxy(new URLSearchParams(window.location.search),{
	  get: (searchParams, prop) => searchParams.get(prop),
});

// Append text
function appendText(string, style = null)
{
	newEl = document.createElement("p");
	newEl.style = style;
	content_text = document.createTextNode(string)

	newEl.appendChild(content_text);
	document.body.appendChild(newEl);
	return newEl;
}

// Set theme
if(params.theme == "dark")
{
	document.body.style = "background-color: #181A1B; color: white";
}
else
{
	document.body.style = "background-color: white;";
}

// Disable all buttons
function interfaceOff()
{
	addBtn.disabled = true;
	checkBtn.disabled = true;
	clearBtn.disabled = true;
	textContent.disabled = true;
}

// Handle file loading
async function loadFile(url)
{
	try {
		const response = await fetch(url);

		if(!response.ok)
		{
			alert("ERROR: Failed to load file, make sure you typed the correct file address.");
			interfaceOff();

		}
		else
		{
			const data = await response.text();
			return data;
		}
	} catch(err) {
		console.log(err);
	}
}

async function parseFile()
{

	fileContent = await loadFile(filepath);

	if(!addBtn.disabled)
	{
		try {
			file = JSON.parse(fileContent);
		}
		catch(err)
		{
			alert("ERROR: Failed to parse JSON data, make sure your file is a valid JSON file!");
			interfaceOff();
		}
	}
	

	// Set title
	if(!file.title)
	{
		document.title = "AskMe List Memorize";
		headerEl.textContent = "AskMe List Memorize";
	}
	else
	{
		document.title = file.title;
		headerEl.textContent = file.title;
	}

	// Set description
	if(!file.description)
	{
		descEl.textContent = "An AskMe list memorize question.";
	}
	else
	{
		descEl.textContent = file.description;
	}
}

// File handling
if(!params.file)
{

	alert("ERROR: No file specified! Specify a file by inputting a file as the query string.");
	interfaceOff();
}
else
{
	filepath = params.file;
}

parseFile();

// Ask
function appendList(string)
{
	newEl = document.createElement("li");
	newEl.className = "list-item";

	content_text = document.createTextNode(string);

	newEl.appendChild(content_text);
	listEl.appendChild(newEl);

}

function addBtnAction() 
{
	appendList(textContent.value);
	textContent.value = '';
	checkBtn.disabled = false;

}

// clear list
function clear()
{
	els = document.getElementsByClassName("list-item");
	len = els.length;
	for(i = 0; i < len; i++)
	{
		// sorta like this:
		// {a, b, c}
		// ⬆️ delete
		//
		// {b, c}
		// ⬆️ delete
		//
		// and so on

		els[0].remove();
	}

	addBtn.disabled = false;
	textContent.disabled = false;
	msgInfo.remove();
}

// check answer
function check()
{
	correct = true;
	strikeEl = document.createElement("s");
	els = document.getElementsByClassName("list-item");
	len = els.length;
	for(i = 0; i < len; i++)
	{
		// mark red strings that didn't match
		if(els[i].textContent.toLowerCase() != file.list[i].toLowerCase())
		{
			els[i].style.color = "red";
			correct = false;
		}
	}
	addBtn.disabled = true;
	checkBtn.disabled = true;
	textContent.disabled = true;
	textContent.value = '';

	if(!correct || len < file.list.length)
	{
		msgInfo = appendText("Not quite correct, try again...", "color: #D70000");
	}
	else
	{
		msgInfo = appendText("That's correct! Great job.", "color: #48AF5F");
	}


}


listEl = document.getElementById("list-contents");
headerEl = document.getElementById("header");
descEl = document.getElementById("desc");

textContent = document.getElementById("inputArea");

document.getElementById("addBtn").addEventListener('click', addBtnAction);
document.getElementById("clearBtn").addEventListener('click', clear);
document.getElementById("checkBtn").addEventListener('click', check);

// ctrl + enter keybinding
document.addEventListener('keydown', (event) => {
	const keyName = event.key;

	if (event.ctrlKey && keyName == 'Enter' && document.activeElement == textContent && !addBtn.disabled && textContent.value) {
		addBtnAction()
	}
}, false);


