#NoEnv

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
Song: ???
Location: ???
Composer: Henry Lu
*/

Notes := new NotePlayer
Notes.Instrument(0)

Notes.Repeat := 1

Notes.Delay(1000)
Notes.Note(33,3000,55).Note(41,3000,55).Note(48,3000,55).Note(56,3000,55).Delay(3500)
Notes.Note(36,3000,60).Note(48,3000,60).Note(51,3000,60).Note(60,3000,60).Delay(3000)
Notes.Note(30,3500,70).Note(39,3500,70).Note(56,3500,70).Note(60,3500,70).Delay(3500)
Notes.Note(33,4000,45).Note(41,4000,45).Note(49,4000,45).Note(58,4000,45).Delay(4000)

Notes.Start()
