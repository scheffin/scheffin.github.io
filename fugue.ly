\version "2.26.0"
\language "english"
\include "articulate.ly"

% MIDI-only articulation: sixteenth notes sound for 60 percent of their
% written value, while longer ordinary notes sound for 75 percent.
#(set! ac:normalFactor '(3 . 4))
#(set! ac:staccatoFactor '(3 . 5))

shortenSixteenths =
#(define-music-function (music) (ly:music?)
   (map-some-music
    (lambda (mus)
      (and (eq? (ly:music-property mus 'name) 'NoteEvent)
           (let ((duration (ly:music-property mus 'duration)))
             (and (ly:duration? duration)
                  (= (ly:duration-log duration) 4)
                  (begin
                    (set! (ly:music-property mus 'articulations)
                          (append (ly:music-property mus 'articulations)
                                  (list
                                   (make-music
                                    'ArticulationEvent
                                    'articulation-type 'staccato))))
                    mus)))))
    music))

global = {
  \tempo 8 = 170
  \key a \major
  \time 3/8
}

% Use these commands in voiceTwoMusic to move voice 2 between staves.
% The voice direction is changed as well, so that it does not collide with
% the other voice on the destination staff.
voiceTwoDown = {
  \change Staff = "down"
  \voiceOne
}

voiceTwoUp = {
  \change Staff = "up"
  \voiceTwo
}

voiceThreeDown = {
  \change Staff = "down"
  \voiceTwo
}

subject_major = \relative c'' {
  e16 d fs,8 gs
  cs16 b d,8 e
  b'16 a cs,8 e
}

subject_minor = \relative c'' {
  e16 d fs,8 gs
  c16 b d,8 e
  b'16 a c,8 e
}
subject_final = \relative c'' {
  e16 d fs,8 gs
  cs16 b d,8 fs
  b16 a cs,8 e
}

voiceOneMusic = \relative c'' {
  \global
  \voiceOne

  \subject_major

  a16 gs a b cs e
  ds8 e ds16 cs
  b8 cs b16 a
  gs b e8 ds
  e16 ds cs b a gs
  fs e fs gs a b
  e,8 e'
  d16[ cs d b]
  cs e a8
  gs a gs16 fs
  e8 fs8.[ e16]
  d8 e8.[ d16]
  cs8[ e] b[ d] cs r8
  gs' a r8
  es fs r8
  cs d! cs
  b r4
  r4.
  cs,16 d! b'8 a
  es16 fs d'!8 cs
  gs16 a fs'8 ds 
  bs cs16 [ds cs8]
  ds16 [e!] ds8 [e16 fs]
  e4 ds8 cs4 r8
  gs [a] bs [cs] ds [es]
  fs8. [gs16] e8
  ~ e16 [ds8 cs16] ds8
  ~ ds16 [gs,] cs8. b!16
  ~b16 [a8 b16] gs8
  ~ gs16 fs e8. [fs16] ds8
  \transpose c g, \subject_final
  e8 d! cs
  ~ cs b cs16 [d]
  cs4.
}

voiceTwoMusic = \relative c' {
  \global
  \voiceTwo

  s4.
  s4.
  s4.
  s4.

  \transpose c g, \subject_major

  e4.
  d!
  cs4 b8[ e]
  a16[ b cs8] ~ cs16 b
  a8 b ~ b8.
  a16 gs8 ~
  gs16 fs e fs gs8
  e4.
  r4.

  \transpose c a, \subject_minor

  fs8 cs'16 [d] cs [b
  a gs] a8 [b16 a]
  gs4 fs8
  \voiceTwoDown
  gs,16 a b8 a
  b16 cs ds8 e!
  fs bs, [cs]
  r4.
  \voiceTwoUp
  gs'16 fs 
  \voiceTwoDown
  as,8 bs
  \voiceTwoUp
  e16 ds
  \voiceTwoDown
  fs,8 a!
  \voiceTwoUp
  ds16 [cs
  \voiceTwoDown
  e,8]
  \voiceTwoUp
  fs'16 [e
  \voiceTwoDown
  gs,8]
  \voiceTwoUp
  a'16 [gs
  \voiceTwoDown
  b,!8]
  \voiceTwoUp
  r8
  gs'4
  a!8 gs8. fs16
  e8. e16 ds8
  e fs8. [b,!16]
  ds8. gs,16
  cs8. b!16
  e4  
  \voiceTwoDown
  b16 a gs8
  r4
  r4.
  r4.
  a8 gs4
  a4.
  % From here voice 2 is printed on the lower staff.

  % If voice 2 later has to return to the upper staff:
  %
  % \voiceTwoUp
  % ...
}

voiceThreeMusic = \relative c {
  \global
  \voiceThree

  s4.
  s4.
  s4.
  s4.
  s4.
  s4.
  s4.
  s4.
  s4.
  s4.
  s4.

  % Start a new system when the third voice enters.  Since the lower staff is
  % hidden while empty, it becomes visible here for the first time.
  \break
  \voiceThreeDown

  \transpose c c, \subject_major

  a'8[ cs] e,[ gs]
  a gs16 fs
  es8 fs es16 ds
  cs8 ds cs16 b
  a8 fs'8.[ e!16]
  ds4 es8
  [cs] fs4
  ~ fs4.
  ~ fs4.
  ~ fs4.
  ~ fs8 fs [e!]
  ds16 cs bs8 [as16 gs]
  cs8 fs4
  e8 ds cs
  bs [cs] ds [e] fs [gs] 
  a16 gs bs,8 cs
  fs16 e as,8 bs
  ds16 cs e,8 gs
  cs  ds [e]
  \time 4/8
  bs [cs] as [b]
  \time 3/8
  cs4 b8
  e16 d! cs b a e' 
  ds cs b a gs fs
  gs e fs gs a b 
  cs ds e8 [e,] 
  a4.
  \bar "|."
}

fugueMusic = \new PianoStaff \with {
    % Normally PianoStaff keeps both staves visible together.  Removing this
    % engraver lets the empty lower staff disappear independently.
    \remove Keep_alive_together_engraver
  } <<

    \new Staff = "up" \with {
      midiInstrument = "recorder"
    } {
      % Force all sibling contexts to be instantiated.
      <>

      <<
        \clef treble

        \new Voice = "voiceOne" {
          \voiceOne
          \voiceOneMusic
        }

        \new Voice = "voiceTwo" {
          \voiceTwo
          \voiceTwoMusic
        }

        % Voice 3 starts here so its rests are visible on the upper staff.  It
        % moves to the lower staff when its musical entry begins.
        \new Voice = "voiceThree" {
          \voiceThree
          \voiceThreeMusic
        }
      >>
    }

    \new Staff = "down" \with {
      \RemoveAllEmptyStaves
      midiInstrument = "recorder"
    } {
      \clef bass

      <<
        % Keep the lower Staff available for cross-staff changes until the
        % end of voice 2.  NullVoice engraves no notes of its own.
        \new NullVoice = "downStaffLifetime" {
          \global
          #(skip-of-length voiceTwoMusic)
        }

      >>
    }

  >>

\score {
  \fugueMusic
  \layout { }
}

\score {
  % Sound the MIDI one octave above the engraved score, like a 4' flute stop.
  \transpose c c' { \articulate \shortenSixteenths \fugueMusic }
  \midi { }
}
