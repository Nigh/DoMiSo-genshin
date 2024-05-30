
[简体中文](SYNTAX_cn.md) - [English](SYNTAX.md)

# Syntax
DoMiSo's numbered musical notation format includes `control commands` and `note markers`.  
The control commands include `key control`, `tempo control` and `rollback control`.

## Control commands ##

> [!WARNING]  
> Due to restrictions in the game itself, it is not possible to play chromatic tones, so in this special edition, unplayable tones will be automatically ignored when played.

### key control

`1=F#`

When no scale number is added, the default is the 5th scale. I.e. the above command is equivalent to

`1=F5#`

Default `1=C` when no tonality is specified


### tempo control

`bpm=120`

Valid bpm ranges from `1` to `480`, values outside this range are considered invalid and will reset bpm to the initial value of `80`.

When no tempo is specified, the default is `bpm=80`.

### rollback control

`rollback=12.5`

The function of the Rollback command is to move the writing position of a note forward by `N` full note lengths at the current tempo. `N` can be a decimal number.

When there are multiple parts, this command can be used to write multiple parts separately. Its use will be described later.

All control commands are case-insensitive and can be placed on the same line as the note. The command will be executed before the note is parsed, regardless of its position on the line.

## note ##

### Examples ###

`++3b//` `-1#-/-` `5..` `( 1 3 5 )`

Each note is separated by a space and notes that do not meet the format are simply ignored.

### Pitch ###

The notes are marked from `0 to 7`, with the same meaning as in numbered musical notation.

The notes preceded by `+` and `-` indicate that the note is raised or lowered by N steps, N being the number of `+` or `-`.

The `#` and `b` after the note indicate that the note is raised or lowered by half tone.

### Time ###

The time-related markers are `/` `-` `. `

`/` means that the time of the preceding mark is reduced by half. The meaning is the same as the underscore in numbered musical notation.

`-` indicates the time of a whole note. The meaning is the same as in numbered musical notation. Can be used in combination with `/`.

`.` extends the time of the preceding note by half.

For example, `5..` has a note time of `1+0.5+0.25` beats.

`++3b//` has a note time of `0.25` beats.

`-1#-/-` has a note time of `1+0.5+1` beats.

`( 1 3- 5 )` has a note time of `2` beats. This is a chord. The use of the chord is described below.

### Chord ###
Notes enclosed in brackets will be treated as chords. In this case, the brackets need to be separated from the notes by a space. Otherwise they will be ignored as invalid notes.

Each note in the chord will be played at the same time and the length of the whole chord is determined by the longest note in the chord.

## RollBack
This is a RollBack usage example to demonstrate the basic usage of the RollBack command.

This is written using the chord:

```
    ( 1 -1 ) ( 2 -2 ) ( 3 -3 ) ( 4 -4 ) ( 5 -5 ) ( 6 -6 ) ( 7 -7 )
```

This is written using rollback command：

```
    1 2 3 4 5 6 7
    rollback=7
    -1 -2 -3 -4 -5 -6 -7
```

Rollback command animation demonstration：

![](assets/rollback.gif)

The effect is the same for both ways of writing. More usage can be found in the sample sketches in the `example_sheets` directory.
