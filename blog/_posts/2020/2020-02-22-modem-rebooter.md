---
layout:     post
title:      'Modem drops internet every now and then? I made a modem rebooter util'
date:       2020-02-22 16:30:00
tags:       ['technology']
---

My issues are rare enough to warrant switching to another modem, so I just hacked around
it by writing a [small piece of software](https://github.com/joonas-fi/modemrebooter) that
reboots the modem to try to get the connection back up.

It pings a few known IPs to see if the internet is up, and if it's done for a defined
duration, it'll reboot the modem.

There are drivers for a few different types of modems (since I'm using this at a few
different locations) - the drivers are called "garbage". 🗑️

I wanted the code to be somewhat safe, so:

- It doesn't drop my internet connection (by rebooting) because of bugs
- Or won't wait long enough after reboot to let the modem reconnect before trying to reboot again.


Code details for nerds
----------------------

I think the
[core code](https://github.com/joonas-fi/modemrebooter/blob/61bd05ca03170016c27bd55dac321befb6844d33/cmd/modemrebooter/main.go#L37)
is somewhat understandable:

	for {
		up := internetupdetector.IsInternetUp(ctx)
		
		previousState := state
		
		if up {
			state = state.Up()
		} else {
			state = state.Down(time.Now())
		}
		
		if state.IsUpDifferentTo(previousState) {
			if up {
				logl.Info.Println("came back UP")
			} else {
				logl.Error.Println("went DOWN")
			}
		}
		
		if up {
			logl.Debug.Println("up")
		} else {
			logl.Info.Printf("down for %s", time.Since(state.wentDownAt))
		}
		
		if state.ShouldReboot(defaultRebootConfig, time.Now()) {
			logl.Info.Println("rebooting modem")
			
			if err := rebooter.Reboot(conf); err != nil {
				logl.Error.Printf("reboot failed: %s", err.Error())
			} else {
				logl.Info.Println("reboot succeeded")
				
				state = state.SuccesfullReboot(time.Now())
			}
		}
		
		select {
		case <-ctx.Done():
			return nil // graceful stop
		case <-time.After(1 * time.Minute):
		}
	}

And the `ShouldReboot()`
[implementation](https://github.com/joonas-fi/modemrebooter/blob/61bd05ca03170016c27bd55dac321befb6844d33/cmd/modemrebooter/state.go):

	func (s State) ShouldReboot(rc mrtypes.RebootConfig, now time.Time) bool {
		return !s.wentDownAt.IsZero() &&
			now.Sub(s.wentDownAt) > rc.RebootAfterDownFor &&
			now.Sub(s.lastSuccesfullRebootAt) > rc.ModemRecoversIn
	}

There's actually
[quite good tests for the logic](https://github.com/joonas-fi/modemrebooter/blob/61bd05ca03170016c27bd55dac321befb6844d33/cmd/modemrebooter/state_test.go#L16)
as well. Example:

	// reboot should be only possible at 5 minute mark
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(1)))
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(2)))
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(3)))
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(4)))
	assert.Assert(t, state.ShouldReboot(defaultRebootConfig, tplus(5)))
	
	// now reboot
	state = state.SuccesfullReboot(tplus(5))
	
	// internet keeps being down, but reboot is not possible until "modemRecoversIn"
	// from last reboot
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(5)))
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(6)))
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(7)))
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(8)))
	assert.Assert(t, !state.ShouldReboot(defaultRebootConfig, tplus(9)))
	
	// another reboot after previous reboot
	assert.Assert(t, state.ShouldReboot(defaultRebootConfig, tplus(10)))

p.s. I actually made this some time ago, but I didn't manage to post about it until now.
