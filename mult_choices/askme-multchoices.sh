#!/bin/bash

### AskMe Header ###

# AskMe version .. ↓
version='1.0.3'

style_bold='\e[0;1m'
style_italic='\e[0;3m'
style_reset='\e[0;0m'

die(){
	[[ "$2" == 1 ]] && string="\e[31;31m[!!] err: ${style_reset}$1" || string="$1"
	echo -e "$string"
	exit $2
}

warn(){
	echo -e "${style_bold}[!] warn: ${style_reset}$1"
}

info(){
	echo -e "${style_bold}[i] info: ${style_reset}$1"
}

try(){
	type "$1" &>/dev/null
}

print_help(){
	cat << EOF
AskMe (Multiple Choice Improved Version)
Usage: $(basename $0) <AskMe file>
EOF
}

for i in $@; do
	case $i in
		-h|--help)
			print_help
			;;
	esac
done

if [[ -z "$1" ]]; then
	die "No file specified!" 1
else
	file="$1"
fi

INT_handle(){
	info "Interrupt signal received, quitting.."
	exit 0
}

trap INT_handle SIGINT

# Source file to get all functions
source "$file" || die "Failed to source file" 1

### End of AskMe header ###


### Default properties and properties checking ###

default_props()
{
	for j in "$@"
	do
		case "$j" in
			title)
				title="Multiple Choice Question"
				;;
		esac
	done
}

checkprops()
{
	for i in 'title'
	do
		eval "[[ -z \$$i ]] && { warn 'At props: variable \"$i\" not found, using default value\n'
					default_props $i; }"
	done
}

### End of default properties and properties checking ###


### AskMe Body ###

# Assign properties

try props || { warn "props function not found, using defaults.."; default_props "title"; } && { props && checkprops; }

# Figlet is cool.
fancytext="$( { try figlet && echo "figlet -t"; } || { try toilet && echo "toilet"; } || echo "cat")"

fancytext="$(eval $fancytext <<< "$title")"

# Title

echo -e "\e[36;1m\r
${fancytext}${reset}
      ${style_italic}AskMe v.${version}${style_reset}
"

unset fancytext

### End of AskMe Body ###


### Specific AskMe Loop ###

alphabets=({a..z})

ask(){
	echo -e "\e[32;1mQuestion $n${style_reset}"
	echo -e "  ${style_bold}$question${style_reset}"

	nChoices="${#choices[@]}"

	for i in ${!choices[@]}
	do
		echo "    ${alphabets[$i]}) ${choices[$i]}"
	done
}

get_answer(){
	read -e -p "> " input_answer
}

double_try(){
	nextQ=$(($n+1))
	warn "Question $n not found, trying question $nextQ.."
	eval "try q_$nextQ" && { info "Question $nextQ found\n"; eval "q_$nextQ"; n=$nextQ; } || { info "Question $nextQ not found, quitting.."; exit 0; }
}

n=1
while :
do
	# Reset all variables from the previous question
	for i in 'question' 'choices' 'answer' 'input_answer'
	do
		eval "unset $i"
	done

	# Double try if question doesn't exist
	eval "try q_$n" || double_try && eval "q_$n" &>/dev/null

	# Check for missing required variables
	for i in '$question' '$choices' '$answer'
	do
		try_string="$(eval "echo $i")"
		[[ -z "$try_string" ]] && die "At question $n: required variable \"$i\" missing" 1
	done
	unset try_string

	# Ask
	ask

	check_alphabets(){
		for i in "${alphabets[@]}"
		do
			if [[ $input_answer == $i ]]
			then
				echo 1
			fi
		done
	}

	# Get answer
	until [[ -n "$input_answer" && "$(check_alphabets)" == 1 ]]
	do
		get_answer
	done

	# Check answer


	correctAnswer="${alphabets[$(($answer-1))]}"
	if [[ "$input_answer" == "$correctAnswer" ]]
	then
		echo -e "\e[31;32m That's correct!\n${style_reset}"
		sleep 1s
	else
		echo -e "\e[31;31m Not quite correct..\n${style_reset}"
		if [[ "$showcorrect" == "yes" ]]
		then
			echo -e "${style_bold}The correct answer is: $correctAnswer${style_reset}\n"
		fi

		sleep 1s
	fi
	
	# Shift
	n=$(($n+1))

done

### End of Specific AskMe Loop ###
