#!/bin/bash

### AskMe Header ###

# Speed up stuff
export LANG=C

# AskMe version .. ↓
version='1.0.6'

# Escape codes for styling
style_bold='\e[0;1m'
style_italic='\e[0;3m'
style_reset='\e[0;0m'

die(){
	[[ "$2" == 1 ]] && string="\e[31;31m[!!] err: ${style_reset}$1" || string="$1"
	echo -e "$string"
	exit $2
}

warn(){
	echo -e "${style_bold}[!] warn:${style_reset} $1"
}

info(){
	echo -e "${style_bold}[i] info:${style_reset} $1"
}

try(){
	type "$1" &>/dev/null
}

print_help(){
	cat << EOF
AskMe (Memorize) v.$version
Usage: ${0##*/} [options] <AskMe file>

Options:
	-h   --help          Show this help
	-V   --version       Print version
	-n   --no-unicode    Only use ASCII (useful in TTYs)

Special options (overrides variables set on AskMe file):
	-l   --loop          Only exit when terminated
	-s   --shuffle       Shuffle questions
	-c   --show-correct  Show correct answer
EOF
}

print_ver(){
	cat << EOF
AskMe - Memorize - version $version
EOF
}

while [[ $# -gt 0 ]]
do
	case "$1" in
		-h|--help)
			print_help
			exit 0
			;;
		-V|--version)
			print_ver
			exit 0
			;;

		-n|--no-unicode)
			unicode=no
			shift
			;;
		-l|--loop)
			var_override+=(loop)
			shift
			;;
		-s|--shuffle)
			var_override+=(shuffle)
			shift
			;;
		-c|--show-correct)
			var_override+=(show_correct)
			shift
			;;

		--)
			shift
			break
			;;
		-*)
			die "Unknown option: $1" 1
			;;
		*)
			break
			;;
	esac
done

[[ $# == 0 ]] && die "No file specified" 1
file="$1"

if [[ $# -gt 1 ]]
then
	shift
	case "$1" in
		-*)
			warn "Options after file are ignored"
			;;
		*)
			die "Too many files" 1
			;;
	esac
fi


INT_handle(){
	info "Interrupt signal received, quitting.."
	print_correct 2>/dev/null
	exit 0
}

trap INT_handle SIGINT

# Quit if input is not a terminal
if ! stty &>/dev/null 
then
	echo "Input not a terminal!"
	exit 1
fi

# Source file to get all functions
source "$file" || die "Failed to source file" 1

override(){
	if [[ -n "${var_override}" ]]
	then
		for i in "${var_override[@]}"
		do
			eval "$i=yes"
		done
	fi
}

override

### End of AskMe header ###


### Default properties and properties checking ###

required_props=("title")

default_props()
{
	for j in "$@"
	do
		case "$j" in
			title)
				title="AskMe Memorize Question"
				;;
		esac
	done
}

for i in "${required_props[@]}"
do
	eval "[[ -z \$$i ]] && {
		warn 'At props: variable \"$i\" not found, using default value\n'
		default_props $i
	}"
done

### End of default properties and properties checking ###


### AskMe Body ###


# Figlet is cool.
fancytext="$( { try figlet && echo "figlet -t"; } || { try toilet && echo "toilet"; } || echo "cat")"

fancytext="$(eval $fancytext <<< "$title")"

# Title
echo -e "\e[36;1m\r
${fancytext}${reset}
      ${style_italic}AskMe v.${version}${style_reset}
"

unset fancytext

# Try to automatically detect if we're on a VT
{ [[ "$TERM" == "linux" ]] || [[ "$TERM" =~ "vt" ]]; } && unicode=no

### Specific AskMe Loop ###

[[ -z "$wait_duration" ]] && wait_duration=1

ask(){
	echo -e " ${style_bold}${assoc}${style_reset}"
}

get_answer(){
	read -e -p "> " input_answer
}

print_correct(){
	if [[ "$loop" == "yes" ]]
	then
		i='$nQ_loop'
	else
		i='$nQ'

	fi

	eval "echo -e \"\e[31;35mCorrect answers: $correct/$i\""
}

if_unicode(){
	[[ ! "$unicode" == "no" ]] && echo "$1" || { [[ -n "$2" ]] && echo "$2"; }
}

Qs=("${!questions[@]}")
nQ="${#questions[@]}"
correct=0

[[ "$loop" == "yes" ]] && nQ_loop=0
[[ -n "$subtitle" ]] && echo -e " \e[34;1m$subtitle${style_reset}\n"

main(){

	# Unset variables from previous questions
	unset input_answer yep correct_answer

	# Ask
	ask

	# Get answer
	until [[ -n "$input_answer" ]]
	do
		get_answer
	done

	# Increment the amount of questions we've answered
	# if we're looping forever
	[[ "$loop" == "yes" ]] && nQ_loop=$(($nQ_loop+1))

	# Check answer
	ans_index=$(($answer-1))

	correct_answer="${questions[$assoc]@L}"

	if [[ -n "$(echo $correct_answer | grep -E '\((.)*\)')" ]]
	then
		eval "correct_answer=$correct_answer"
	else
		correct_answer="$correct_answer"
	fi


	for i in "${correct_answer[@]}"
	do
		until [[ "$yep" == "true" ]]
		do
			if [[ "${input_answer@L}" == "$i" ]]
			then
				correct=$(($correct+1))
				echo -e "\e[31;32m $(if_unicode "✔") That's correct!\n${style_reset}"
				sleep ${wait_duration}s
				yep="true"
			fi
			break
		done
	done

	if [[ "$yep" != "true" ]]
	then
		echo -e "\e[31;31m $(if_unicode "✗") Not quite correct..\n${style_reset}"

		if [[ "$show_correct" == "yes" ]]
		then
			if [[ "${#correct_answer[@]}" -gt 1 ]]
			then
				echo -e " ${style_bold}The correct answers are:"
				for i in "${correct_answer[@]}"
				do
					echo -e " $(if_unicode "•" "-") ${i}"
				done
				echo
			else
				echo -e " ${style_bold}The correct answer is: $correct_answer${style_reset}\n"
			fi
		fi

		sleep ${wait_duration}s

	fi


}

shuffle(){
	Qs_old=("${Qs[@]}")
	unset Qs

	# TODO: This loop is inefficient; try to fix it
	shuf_index=$(seq 0 $nQ | head -n -1 | shuf) # Head is used to remove the trailing newline; edit when there's a proper fix.

	for i in $shuf_index
	do
		Qs+=("${Qs_old[$i]}")
	done
	unset Qs_old

}

[[ "$shuffle" == "yes" ]] && shuffle

if [[ "$loop" == "yes" ]]
then
	index=0
	while :
	do
		assoc="${Qs[$index]}"
		main
		[[ $(($index+1)) == $nQ ]] && index=0 || index=$(($index+1))
		[[ "$shuffle" == "yes" ]] && shuffle
	done
else
	for (( index=0; index < $nQ; index=$(($index+1)) ))
		do
			assoc="${Qs[$index]}"
			main
		done

fi

print_correct

### End of Specific AskMe Loop ###

### End of AskMe Body ###
