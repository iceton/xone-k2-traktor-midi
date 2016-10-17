# https://github.com/iceton/xone-k2-traktor-midi

midi = require 'midi'

LED_ADDRESS_PREFIX = 157
LED_COLOR_DIFFERENCE = 36

MIDI_INPUT = new midi.input()
MIDI_OUTPUT = new midi.output()
MIDI_OUTPUT.openPort(0);

class Led
  constructor: (@addr, @parent) ->
    @onAt = null
  on: (doNotSend) ->
    @sendMidiMessage 127 unless doNotSend
    @onAt = Date.now()
  off: (doNotSend) ->
    @sendMidiMessage 0 unless doNotSend
    @onAt = null
    @updateParent()
  sendMidiMessage: (val) ->
    msg = [LED_ADDRESS_PREFIX, @addr, val]
    # console.log msg
    MIDI_OUTPUT.sendMessage msg
    msg
  updateParent: ->
    @parent.ledChanged @
  interpretMidiMessage: (msg) ->
    console.log "led #{@addr}: #{msg}"
    @on() if msg is 127
    @off() if msg is 0

class Light
  constructor: (greenAddr) ->
    @leds =
      green: new Led(greenAddr, @)
      yellow: new Led(greenAddr - LED_COLOR_DIFFERENCE, @)
      red: new Led(greenAddr - LED_COLOR_DIFFERENCE * 2, @)
  on: (color) ->
    color = 'green' unless color
    @leds[color].on()
    color
  off: ->
    @leds[color].off() for color of @leds
    true
  isOn: ->
    for color, led of @leds
      return true if led.onAt
    false
  ledChanged: (changedLed) ->
    return if changedLed.onAt
    ledsOn = (led for color, led of @leds when led.onAt)
    ledsOn.sort (a, b) ->
      a.onAt - b.onAt
    ledsOn[0].on() if ledsOn[0]
    true

class LightRow
  constructor: (startAddr) ->
    @lights = (new Light(startAddr + i) for i in [0..3])
  on: (color) ->
    light.on(color) for light in @lights
    true
  off: ->
    light.off() for light in @lights
    true

class Lights
  constructor: ->
    @rows = [
      new LightRow(124)
      new LightRow(120)
      new LightRow(116)
      new LightRow(112)
      new LightRow(108)
      new LightRow(104)
      new LightRow(100)
      new LightRow(96)
    ]
  addressableLeds: ->
    result = {}
    for row in @rows
      for light in row.lights
        for color, led of light.leds
          result[led.addr] = led
    result
  lowerOn: (color) ->
    row.on(color) for row in @rows[4..]
    true
  lowerOff: ->
    row.off() for row in @rows[4..]
    true
  on: (color) ->
    row.on(color) for row in @rows
    true
  off: ->
    row.off() for row in @rows
    true

lights = new Lights()
leds = lights.addressableLeds()

MIDI_INPUT.on 'message', (deltaTime, msg) ->
  addr = msg[1]
  val = msg[2]
  leds[addr].interpretMidiMessage(val) if msg[0] is LED_ADDRESS_PREFIX && leds[addr]
  console.log msg

MIDI_INPUT.openPort(1);

module.exports = lights

# lights = require './lights.coffee'
