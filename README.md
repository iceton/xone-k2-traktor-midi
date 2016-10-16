# xone-k2-traktor-midi

Store state for the Xone K2's LEDs to enable better lighting behavior

## Why?

Many desired behaviors are not possible using Traktor's MIDI output configuration.

For example, indicating a feature being on/off with green/red takes 2 rules:

- Green on = feature on *(also means green off = feature off)*
- Red on = feature off *(also means red off = feature on)*

One rule will always be executed after the other. If it's the second:

- Feature on = send green on, red off signals
- Feature off = send green off, red on signals

When the feature is on, the green LED will not illuminate, because red LED off is sent after green LED on, and turning off any LED in a light *(definiton below)* results in the entire light location being off.

## So what does this actually do?

This listens to MIDI out from Traktor and stores the state of the LEDs individually. When an LED is turned off, this checks whether other LEDs in this light should be on (and turns them on if so). This addresses the main shortcoming (IMO) in Traktor's MIDI out behavior.

## Definitions (for our purposes)

- light - one physical location on the controller that contains 3 LEDs (green, yellow & red)

## What's next?

- Rules that define light behavior based on controller signals (not just Traktor signals)
