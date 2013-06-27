MIDI Note Editor
================
A simpler way to edit and compose music with the ProgressEngine NotePlayer API.

The program accepts either a note sequence or NotePlayer code. If a note sequence is entered, it will be converted into working code that can then be copied into a game file to play music. If NotePlayer code is entered, it will be converted into a note sequence that can be edited more easily.

Syntax
------

Note sequences are a collection of lines, each line defining either a comment or a single chord. Chords follow the following syntax:

    [duration] [notes]

Where [duration] is the duration the chord is active for, in milliseconds, and [notes] is a whitespace delimited list of zero or more notes in standard format. A note uses the following syntax:

    [letter][octave][suffix]

Where [letter] is a letter between A to G representing the note, [octave] is the octave in which the note may be found (it is assumed to be 5 if left blank), and [suffix] is either "#", representing a sharp, "-", representing a flat, or blank, representing the unmodified note.

Instruments
-----------

Selecting an instrument from the dropdown menu during note sequence creation causes the resulting code to use that instrument when playing.

Likewise, code converted into a note sequence will have the instrument automatically detected, and the correct instrument will be selected in the dropdown menu.

License
-------

ProgressPlatformer is licensed under the GNU Affero General Public License, version 3 or later. See LICENSE.txt included in the package for more information.