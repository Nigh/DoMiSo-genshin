#NoEnv
#Include lib/music.ahk
/*
Copyright 2011-2012 Anthony Zhang <azhang9@gmail.com>, Henry Lu <redacted@redacted.com>

This file is part of ProgressPlatformer. Source code is available at <https://github.com/Uberi/ProgressPlatformer>.

ProgressPlatformer is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
Song: Sunshower
Location: Title screen
Composer: Henry Lu
*/

Notes := new NotePlayer
Notes.Instrument(9)
Notes.Repeat := 1

Notes.Note(48,500,50).Note(36,500,50).Note(48,125,50).Note(45,125,50).Note(36,125,50).Note(33,125,50).Delay(500)
Notes.Note(47,500,50).Note(35,500,50).Delay(500)
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(45,500,50).Note(41,500,50).Delay(500)

 ; the key melody
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(47,500,50).Note(35,500,50).Delay(500)
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(45,500,50).Note(41,500,50).Delay(500)

Notes.Note(48,500,50).Note(36,500,50).Note(33,2000,48).Note(36,2000,48).Note(40,2000,48).Delay(500)
Notes.Note(47,500,50).Note(35,500,50).Delay(500)
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(45,500,50).Note(41,500,50).Delay(500)

Notes.Note(48,500,50).Note(36,500,50).Note(33,2000,48).Note(36,2000,48).Note(40,2000,48).Delay(500)
Notes.Note(47,500,50).Note(35,500,50).Delay(500)
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(45,500,50).Note(36,500,50).Delay(500)

Notes.Note(48,750,25).Delay(500)
Notes.Note(36,250,32).Note(48,250,32).Delay(250)
Notes.Note(45,750,30).Note(33,750,30).Delay(250)
Notes.Note(48,750,25).Delay(1000)

Notes.Note(48,250,32).Note(36,250,32).Note(48,750,25).Delay(250)
Notes.Note(45,750,28).Note(33,750,28).Delay(1000)

Notes.Note(41,166,30).Delay(166) ;Triple upper
Notes.Note(45,166,38).Delay(166)
Notes.Note(47,167,46).Delay(167)

;7
Notes.Note(48,500,50).Note(36,500,50).Note(36,2000,48).Note(40,2000,48).Note(47,2000,48).Delay(500)
Notes.Note(47,500,50).Note(35,500,50).Delay(500)
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(45,500,50).Note(41,500,50).Delay(500)

Notes.Note(48,500,50).Note(36,500,50).Note(36,3250,48).Note(40,3250,48).Note(45,3250,48).Note(48,3250,48).Delay(500)
Notes.Note(47,500,50).Note(35,500,50).Delay(500)
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(45,500,50).Note(41,500,50).Delay(500)

Notes.Note(33,1000,48).Note(36,1000,48).Note(40,1000,48).Delay(250)
Notes.Note(43,1000,48).Note(48,1000,48).Delay(250)
Notes.Note(45,750,50).Note(41,750,50).Delay(750)
Notes.Note(43,150,48).Note(48,750,48).Note(36,750,48).Note(40,750,48).Delay(250)
Notes.Note(45,125,50).Delay(125)
Notes.Note(41,125,50).Delay(125)
Notes.Note(45,125,50).Delay(125)
Notes.Note(47,125,50).Delay(125)

;10
Notes.Note(48,500,50).Note(36,500,50).Note(33,1500,48).Note(36,1500,48).Note(40,1500,48).Delay(500)
Notes.Note(47,500,50).Note(35,500,50).Delay(500)
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(45,500,50).Note(41,500,50).Delay(500)
Notes.Note(41,166,40).Delay(166)
Notes.Note(45,166,45).Delay(166)

Notes.Note(47,500,48).Delay(250)
Notes.Note(48,500,50).Note(36,500,50).Delay(250)
Notes.Note(38,250,48).Note(43,250,48).Delay(250)
Notes.Note(47,500,50).Note(35,750,48).Note(40,750,48).Delay(500)
Notes.Note(48,500,50).Note(36,500,50).Delay(250)
Notes.Note(35,250,48).Note(40,250,48).Delay(250)
Notes.Note(45,500,50).Note(41,500,50).Delay(125)
Notes.Note(36,125,48).Delay(125)
Notes.Note(38,125,48).Delay(125)

;12
Notes.Note(40,125,48).Delay(125)
Notes.Note(42,125,48).Delay(125)

Notes.Note(48,500,50).Note(36,750,50).Delay(500)
Notes.Note(47,500,50).Note(35,500,50).Delay(250)
Notes.Note(36,750,50).Delay(250)
Notes.Note(48,500,50).Note(36,500,50).Delay(500)
Notes.Note(45,500,50).Note(41,500,50).Note(35,500,50).Delay(625)

Notes.Note(48,125,50).Note(45,125,50).Note(36,125,50).Note(33,125,50).Delay(125)
Notes.Note(48,125,50).Note(45,125,50).Note(36,125,50).Note(33,125,50).Delay(250)
Notes.Note(41,166,30).Delay(166)
Notes.Note(45,166,38).Delay(166)
Notes.Note(47,167,46).Delay(167)

Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(47,500,50).Note(35,500,50).Delay(500)
Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(45,500,50).Note(41,500,50).Note(36,1000,50).Delay(625)
Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(47,500,50).Note(35,500,50).Delay(125)
Notes.Note(35,1000,50).Delay(500)

;15
Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(45,500,50).Note(36,500,50).Delay(750)
Notes.Note(36,1000,50).Delay(500)
Notes.Note(41,166,30).Delay(166)
Notes.Note(45,166,38).Delay(166)
Notes.Note(47,167,46).Delay(167)

Notes.Note(48,250,50).Note(41,250,45).Delay(250)
Notes.Note(47,250,50).Note(45,250,45).Delay(250)
Notes.Note(48,250,50).Note(47,250,45).Delay(250)
Notes.Note(45,250,50).Note(40,500,45).Delay(250)

Notes.Note(48,250,50).Delay(250)
Notes.Note(47,250,50).Delay(250)
Notes.Note(48,250,50).Delay(250)
Notes.Note(45,250,50).Delay(250)

Notes.Note(48,250,50).Note(41,250,45).Delay(250)
Notes.Note(47,250,50).Note(45,250,45).Delay(250)
Notes.Note(48,250,50).Note(47,250,45).Delay(250)
Notes.Note(45,250,50).Note(40,500,45).Delay(250)

Notes.Note(48,250,50).Delay(250)
Notes.Note(47,250,50).Note(41,500,45).Delay(250)
Notes.Note(48,250,50).Delay(250)
Notes.Note(45,250,50).Delay(250)

;18
Notes.Note(41,166,30).Delay(166)
Notes.Note(45,166,38).Delay(166)
Notes.Note(47,167,46).Delay(167)

Notes.Note(48,250,50).Note(33,2000,48).Note(36,2000,48).Note(40,2000,48).Delay(250)
Notes.Note(47,500,50).Delay(500)
Notes.Note(48,250,50).Delay(250)
Notes.Note(45,250,50).Delay(250) ;three part chord
Notes.Note(48,250,50).Delay(250)
Notes.Note(47,500,50).Delay(500)

Notes.Note(48,250,50).Delay(250)
Notes.Note(47,500,50).Delay(500)
Notes.Note(48,250,50).Delay(250)
Notes.Note(45,500,50).Delay(500)

Notes.Note(48,250,50).Note(41,250,45).Delay(250)
Notes.Note(47,250,50).Note(45,250,45).Delay(250)
Notes.Note(48,250,50).Note(47,250,45).Delay(250)
Notes.Note(45,250,50).Note(40,500,45).Delay(250)

Notes.Note(48,250,50).Delay(250)
Notes.Note(47,250,50).Delay(250)
Notes.Note(48,250,50).Delay(250)
Notes.Note(45,250,50).Delay(250)

Notes.Note(48,250,50).Note(41,250,45).Delay(250)
Notes.Note(47,250,50).Note(45,250,45).Delay(250)
Notes.Note(48,250,50).Note(47,250,45).Delay(250)
Notes.Note(45,250,50).Note(40,500,45).Delay(250)

Notes.Note(48,250,50).Delay(250)
Notes.Note(47,250,50).Note(41,500,45).Delay(250)
Notes.Note(48,250,50).Delay(250)
Notes.Note(45,250,50).Delay(250)

;22
Notes.Note(41,166,30).Delay(166)
Notes.Note(45,166,38).Delay(166)
Notes.Note(47,167,46).Delay(167)

Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(47,250,50).Note(35,250,50).Delay(250)
Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(45,250,50).Note(41,250,50).Delay(250)

Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(47,250,50).Note(35,250,50).Delay(250)
Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(45,250,50).Note(41,250,50).Delay(250)

Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(47,250,50).Note(35,250,50).Delay(250)
Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(45,250,50).Note(41,250,50).Delay(250)

Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(47,250,50).Note(35,250,50).Delay(250)
Notes.Note(48,250,50).Note(36,250,50).Delay(250)
Notes.Note(45,250,50).Note(36,250,50).Delay(250)

;
Notes.Note(41,166,30).Delay(166)
Notes.Note(45,166,38).Delay(166)
Notes.Note(47,167,46).Delay(167)
Notes.Note(36,250,50).(48,250,50).Delay(250)
Notes.Note(36,250,50).Delay(250)
Notes.Note(35,250,50).Note(47,500,50).Delay(250)
Notes.Note(36,250,50).Delay(250)


; 25
Notes.Note(48,250,50).Delay(250)
Notes.Note(47,500,50).Delay(500)
Notes.Note(48,250,50).Delay(250)
Notes.Note(45,250,50).Delay(250)
Notes.Delay(-1250)
Notes.Note(41,166,30).Delay(166)
Notes.Note(45,166,38).Delay(166)
Notes.Note(47,167,46).Delay(167)

;26
;Loop, 4
Loop, 1
{
    Notes.Note(48,250,50).Note(36,250,50).Delay(250)
    Notes.Note(47,250,50).Note(35,250,50).Delay(250)
    Notes.Note(48,250,50).Note(36,250,50).Delay(250)
    Notes.Note(45,250,50).Note(41,250,50).Delay(250)

    Notes.Note(48,250,50).Note(36,250,50).Delay(250)
    Notes.Note(47,250,50).Note(35,250,50).Delay(250)
    Notes.Note(48,250,50).Note(36,250,50).Delay(250)
    Notes.Note(45,250,50).Note(41,250,50).Delay(250)

    Notes.Note(48,250,50).Note(36,250,50).Delay(250)
    Notes.Note(47,250,50).Note(35,250,50).Delay(250)
    Notes.Note(48,250,50).Note(36,250,50).Delay(250)
    Notes.Note(45,250,50).Note(41,250,50).Delay(250)

    Notes.Note(48,250,50).Note(36,250,50).Delay(250)
    Notes.Note(47,250,50).Note(35,250,50).Delay(250)
    Notes.Note(48,250,50).Note(36,250,50).Delay(250)
    Notes.Note(45,250,50).Note(36,250,50).Delay(250)
}

Notes.Delay(-16000)
Loop, 3
{
    Notes.Note(36,250,80).Note(48,250,80).Delay(250)
    Notes.Note(45,750,80).Note(33,750,80).Delay(1000)
}

Notes.Note(36,250,80).Note(48,250,80).Delay(250)
Notes.Note(45,750,80).Note(33,750,80).Delay(750)
Notes.Note(36,250,80).Note(48,250,80).Delay(250)

;34
Notes.Note(45,500 * 10 / 9,60).Note(33,500 * 10 / 9,60).Delay(500 * 10 / 9)
Notes.Note(45,250 * 10 / 9,80).Delay(250 * 10 / 9)
Notes.Note(41,166 * 10 / 9,40).Delay(500 * 10 / 9)
Notes.Note(45,166 * 10 / 9,40).Delay(166 * 10 / 9)
Notes.Note(47,167 * 10 / 9,40).Delay(167 * 10 / 9)
Notes.Note(45,250 * 10 / 9,80).Delay(125 * 10 / 9)
Notes.Note(41,166 * 10 / 9,40).Delay(166 * 10 / 9)
Notes.Note(45,166 * 10 / 9,40).Delay(166 * 10 / 9)
Notes.Note(47,167 * 10 / 9,40).Delay(167 * 10 / 9)
Notes.Note(45,125 * 10 / 9,60).Note(48,125 * 10 / 9,60).Note(52,125 * 10 / 9,60).Delay(125 * 10 / 9)

Loop, 4
{
    Notes.Note(48,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(47,250 * 10 / 9,80).Note(35,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(48,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(45,250 * 10 / 9,80).Note(41,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(48,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(47,250 * 10 / 9,80).Note(35,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(48,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(45,250 * 10 / 9,80).Note(41,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(48,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(47,250 * 10 / 9,80).Note(35,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(48,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(45,250 * 10 / 9,80).Note(41,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(48,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(47,250 * 10 / 9,80).Note(35,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(48,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
    Notes.Note(45,250 * 10 / 9,80).Note(36,250 * 10 / 9,80).Delay(250 * 10 / 9)
}

Notes.Delay(-16000 * 10 / 9)
Loop, 3
{
    Notes.Note(36,250 * 10 / 9,60).Note(48,250 * 10 / 9,60).Delay(250 * 10 / 9)
    Notes.Note(45,750 * 10 / 9,60).Note(33,750 * 10 / 9,60).Delay(1000 * 10 / 9)
}

Notes.Note(41,166 * 10 / 9,40).Delay(500 * 10 / 9)
Notes.Note(45,166 * 10 / 9,40).Delay(166 * 10 / 9)
Notes.Note(47,167 * 10 / 9,40).Delay(167 * 10 / 9)

Notes.Note(36,250,80).Note(40,250,80).Note(45,250,80).Note(48,250,80).Delay(250)
Notes.Note(36,250,80).Note(40,250,80).Note(45,250,80).Note(48,250,80).Delay(250)

;Start song
Notes.Start()
MsgBox