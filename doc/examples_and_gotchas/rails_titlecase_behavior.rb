# Rails adds the 'titlecase' function to String, which often does what you want:
"Alameda high school".titlecase # => "Alameda High School"

# However, titlecase has two other behaviors that aren't intuitive. First,
# it will downcase all letters in a word except the first:
"ABC school".titlecase # => "Abc School"

# Another side effect is that it will replace :: with /
"My own :: string".titleize # => "My Own / String"
