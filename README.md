# NAME

names - Name generator

# SYNOPSIS

**package require names** ?0.1?

**names gen** ?*seq*?

**names gen\_unique** ?*seq*?

**names name** *thing* ?*seq*?

**names thing** *name*

# DESCRIPTION

This module provides automatic naming facilities designed to be
compatible with human perception and memory. Often in software we have
opaque handles for things or addresses in memory: thread ids, process
ids, file handles, object instances, etc. These are often similar to
each other and hard to remember, visually match and contrast. This
module provides a way to map such things to memorable and easy to match
names by assigning a CamelCased combination of an adjective and a noun,
picked at random from a list of the most common adjectives and nouns
(minimally modified to be SFW), and optionally maintains a map from the
generated names to the original things and back.

# COMMANDS

  - **names gen** ?*seq*?  
    Generate and return a name, using *seq* for the random numbers (a
    sequence as implemented by the **prng** module). If *seq* isn’t
    supplied, a default sequence is used which is seeded with a random
    number.
  - **names gen\_unique** ?*seq*?  
    Generate and return a unique name. The name will not have been used
    by any thread in the current process. The optional *seq* arg as per
    the description of **names gen**.
  - **names name** *thing* ?*seq*?  
    Return the name allocated for *thing*, generating it if it didn’t
    exist yet. The returned name uniquely refers to *thing* and won’t
    have been previously used by any thread in the current process to
    refer to a different *thing*. *seq* as for **names gen**.
  - **names thing** *name*  
    Return the *thing* which was allocated the name *name* (possibly by
    another thread)

# SEQUENCES

The commands that require random number input take an optional *seq*
argument, which allows control over the random numbers supplied,
allowing programs to always assign the same names to things, provided
the names are generated in a deterministic sequence. This can be helpful
when debugging, to maintain name consistency across runs.

# EXAMPLES

Generate 3 random names:

``` tcl
package require names

puts [names gen]
puts [names gen]
puts [names gen]
```

produces output like:

    BrightFamily
    SuccessfulJump
    AutomaticCake

Generate the same sequence of names for each run:

``` tcl
package require names
package require prng::mt

prng::mt::Sequence create nameseq "hello, names"
puts [names gen nameseq]
puts [names gen nameseq]
puts [names gen nameseq]
```

produces the output:

    MuchDeath
    HumanEquivalent
    PrizeBell

Automatically assign friendly names for thread ids in log messages:

``` tcl
package require names
package require Thread

proc threadlog {tid msg} {
    global threads
    set name   [names name $tid] 
    puts "$name: $msg"
    set idx     [lsearch -exact $threads [names thing $name]]
    set threads [lreplace $threads $idx $idx]
}

set initscript [string map [list %tid% [thread::id]] {
    proc log msg {
        thread::send -async %tid% [list threadlog [thread::id] $msg]
    }
    thread::wait
}]

set threads {}
lappend threads [thread::create $initscript]
lappend threads [thread::create $initscript]
lappend threads [thread::create $initscript]

foreach tid $threads msg {foo bar baz} {
    thread::send -async $tid [list log $msg]
}

while {[llength $threads]} {
    vwait threads
}
```

produces output like:

    SoftHouse: foo
    NearbySystem: bar
    AfterVariation: baz

# LICENCE

This package Copyright 2013-2022 Cyan Ogilvie, and is made available
under the same license terms as the Tcl Core.
