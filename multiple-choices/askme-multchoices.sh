#!/bin/bash

### AskMe Header ###

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
AskMe (Multiple Choice) v.$version
Usage: ${0##*/} [options] <AskMe file>

Options:
	-h   --help                  Show this help
	-V   --version               Print version

	-n   --no-unicode            Only use ASCII (useful in TTYs)
	-a   --auto-enter            Enter choice automatically after user input

Special options (overrides variables set on AskMe file):
	-q   --shuffle-questions     Shuffle questions
	-s   --shuffle-choices       Shuffle choices
	-c   --show-correct          Show correct answer
	
EOF
}

print_ver(){
	cat << EOF
AskMe - Multiple Choice - version $version
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
		-a|--auto-enter)
			auto_enter=yes
			shift
			;;

		-q|--shuffle-questions)
			var_override+=(shuffle_questions)
			shift
			;;
		-s|--shuffle-choices)
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
				title="Multiple Choice Question"
				;;
		esac
	done
}

checkprops()
{
	for i in "${required_props[@]}"
	do
		eval "[[ -z \$$i ]] && {
			warn 'At props: variable \"$i\" not found, using default value\n'
			default_props $i
		}"
	done
}

### End of default properties and properties checking ###


### AskMe Body ###

# Assign properties
if ( ! try props ) then
	warn "props function not found, using defaults.."
	for i in "${required_props[@]}"
		do
			default_props $i
		done

	else
		props && checkprops
fi

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

func_vars=('question' 'choices' 'answer' 'input_answer')
required_func_vars=('question' 'choices' 'answer')
[[ -z "$wait_duration" ]] && wait_duration=1

alphabets=({a..z})

ask(){
	echo -e "\e[32;1mQuestion ${qN}${style_reset}"
	echo -e "  ${style_bold}$question${style_reset}"

	nChoices="${#choices[@]}"

	if [[ "$shuffle" == "yes" ]]
	then
		old_choices=("${choices[@]}")
		unset choices

		shuf_index=$(seq 0 $nChoices | head -n -1 | shuf) # Head is used to remove the trailing newline; edit when there's a proper fix.
		ans_index=$(($answer-1))
		j=0
		for i in $shuf_index
		do
			choices+=("${old_choices[$i]}")
			j=$(($j+1))
			[[ $i == $ans_index ]] && answer=$j
		done
		unset j

		unset old_choices
	fi

	for i in ${!choices[@]}
	do
		echo "    ${alphabets[$i]}) ${choices[$i]}"
	done
}

get_answer(){
	i="-e"
	[[ "$auto_enter" == "yes" ]] && i+=" -n 1"
	read $i -p "> " input_answer
}

check_alphabets(){
	for i in ${alphabets[@]:0:$nChoices}
	do
		[[ "${input_answer@L}" == "$i" ]] && return 0
	done
}

print_correct(){
	echo -e "\e[31;35mCorrect answers: $correct/$nQ"
}

if_unicode(){
	[[ ! "$unicode" == "no" ]] && echo "$1" || { [[ -n "$2" ]] && echo "$2"; }
}

Qs=($(grep -Eo "q_[0-9]*" "$file"))
nQ=${#Qs[@]}
correct=0

main(){

	# Reset all variables from the previous question
	unset ${func_vars[@]}

	# Error when question cannot be found
	try "$func" || {
		warn "Function $func could not be executed!\n"
		return
	}

	try props && props
	override

	"$func"

	# Which question is this?
	[[ "$shuffle_questions" == "yes" ]] && qN="$(($index+1))" || qN="${func#*_}"

	# Check for missing required variables
	for i in "${required_func_vars[@]}"
	do
		# I couldn't use "\$${i}" for some reason
		try_string="$(echo "\$$i")"
		[[ -z "$try_string" ]] && {
			warn "At question $qN (function $func): required variable \"$i\" missing, skipping this question..\n"
			return
		}
	done
	unset try_string

	# Ask
	ask

	# Get answer
	until ( check_alphabets ) && [[ -n "$input_answer" ]]
	do
		get_answer
	done

	# Check answer
	ans_index=$(($answer-1))
	correct_answer="${alphabets[$ans_index]}"

	if [[ "${input_answer@L}" == "$correct_answer" ]]
	then
		correct=$(($correct+1))
		echo -e "\e[31;32m $(if_unicode "✔") That's correct!\n${style_reset}"
		sleep ${wait_duration}s
	else
		echo -e "\e[31;31m $(if_unicode "✗") Not quite correct..\n${style_reset}"

		if [[ "$show_correct" == "yes" ]]
		then
			echo -e " ${style_bold}The correct answer is: $correct_answer${style_reset}\n"
		fi

		sleep ${wait_duration}s
	fi
}

try props && props
override

if [[ "$shuffle_questions" == "yes" ]]
then
	Qs=($(shuf -e "${Qs[@]}"))

fi

for (( index=0; index < $nQ; index=$(($index+1)) ))
do
	func="${Qs[$index]}"
	main
done

print_correct

### End of Specific AskMe Loop ###

### End of AskMe Body ###
