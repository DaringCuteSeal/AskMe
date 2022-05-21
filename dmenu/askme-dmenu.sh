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

# Variables
dmenu="dmenu -i"

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
AskMe (dmenu) v.$version
Usage: ${0##*/} [options] <AskMe file>

Options:
	-h   --help          Show this help
	-V   --version       Print version

	-n   --no-unicode    Only use ASCII
	-d   --dmenu <dmenu> Specify a different dmenu

Special options (overrides variables set on AskMe file):
	-l   --loop          Only exit when terminated
	-s   --shuffle       Shuffle questions
	-c   --show-correct  Show correct answer
EOF
}

print_ver(){
	cat << EOF
AskMe - dmenu - version $version
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

		-d|--dmenu)
			dmenu="$2"
			shift 2
			;;
		-n|--no-unicode)
			unicode="no"
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

# Title
if [[ -n "$subtitle" ]]
then
	$dmenu -p "$title - $subtitle (ENTER to continue..)" <&-
else
	$dmenu -p "$title (ENTER to continue..)" <&-
fi

[[ $? -gt 0 ]] && exit $?

### Specific AskMe Loop ###

[[ -z "$wait_duration" ]] && wait_duration=1


print_correct(){
	if [[ "$loop" == "yes" ]]
	then
		i='$nQ_loop'
	else
		i='$nQ'

	fi

	eval "dmenu -p \"Correct answers: $correct/$i (ENTER to continue..)\" <&-"

}

if_unicode(){
	[[ ! "$unicode" == "no" ]] && echo "$1" || { [[ -n "$2" ]] && echo "$2"; }
}

quit(){
	if [[ "$choice" == "Quit" ]]
	then
		print_correct
		exit 0
	fi
}

Qs=("${!questions[@]}")
nQ="${#questions[@]}"

# Generate the choices, separated by newline
j=0
for i in "${questions[@]}"
do
	(( j++ ))

	if grep -E '\((.)*\)' <<< "$i" &>/dev/null
	then
		eval "temp_answers=$i"
		for (( h=0; h < ${#temp_answers[@]}; h++ ))
		do
			questions_nl+="${temp_answers[$h]}"
			[[ $j -lt ${#questions[@]} ]] && questions_nl+="
" # \n doesn't work
		done
	else
		questions_nl+="$i"
		[[ $j -lt ${#questions[@]} ]] && questions_nl+="
"
	fi


done

correct=0

[[ "$loop" == "yes" ]] && nQ_loop=0

main(){

	# Unset variables from previous questions
	unset input_answer yep correct_answer

	# Ask question
	input_answer="$($dmenu -p "${assoc}" -l 8 <<< ${questions_nl})"

	# Increment the amount of questions we've answered
	# if we're looping forever
	[[ "$loop" == "yes" ]] && nQ_loop=$(($nQ_loop+1))

	# Check answer
	ans_index=$(($answer-1))

	correct_answer="${questions[$assoc]@L}"

	if grep -E '\((.)*\)' <<< "$correct_answer" &>/dev/null
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
				choice="$($dmenu -p "`if_unicode "✔"` That's correct!" << EOF
Next
Quit
EOF
)"
				quit

				yep="true"
			fi
			break
		done
	done

	if [[ "$yep" != "true" ]]
	then

		mesg="Not quite correct.."

		if [[ "$show_correct" == "yes" ]]
		then
			if [[ "${#correct_answer[@]}" -gt 1 ]]
			then
				mesg+=" The correct answers are: "
				j=0
				for i in "${correct_answer[@]}"
				do
					(( j++ ))
					mesg+="${i}"
					[[ $j -lt ${#correct_answer[@]} ]] && mesg+=", "
				done
			else
				mesg+=" The correct answer is: $correct_answer"
			fi
		fi


		choice="$($dmenu -p "`if_unicode "✗"` $mesg" << EOF
Next
Quit
EOF
)"

		quit

	fi


}

shuffle(){
	Qs_old=("${Qs[@]}")
	unset Qs

	# TODO: This loop is inefficient; try to fix it
	shuf_index=$(seq 0 $nQ | head -n -1 | shuf) # Head is used to remove the trailing newline; edit when there's a proper fix.
	                                            # edit: are you sure? `seq` doesn't seem to add a newline, but from what I recall
						    # I couldn't make this work without the `head` so sure I guess.
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


### End of Specific AskMe Loop ###

### End of AskMe Body ###
