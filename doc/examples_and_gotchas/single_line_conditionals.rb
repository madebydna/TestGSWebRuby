# Foo isn't yet defined, so you might expect this to set foo to 123
# But actually, foo will be nil
foo = 123 unless defined? foo # => nil

# And likewise, you might expect bar to not be set to 123 here, since bar isn't defined yet.
# But actually, bar will be set to 123
bar = 123 if defined? bar # => 123

# Another example:

# Baz is currently undefined:
!!defined?(baz) # => false

# Therefore, you might expect baz to still be undefined after the following statement:
baz = 123 if false

# But alas, baz is nil:
baz # => nil

# The left-hand portion of the statement is evaluated and the variable is defined but not assigned
# More info: https://www.evernote.com/shard/s4/sh/ffe4a7d8-70fa-4f6f-9688-422ce192935d/709304031658c60d98e31c167cd6e48e


