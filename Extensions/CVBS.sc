
// CVBS SynthDefs

+ Object {
    namesCVBS { ^['vBar', 'hBar', 'hLine', 'Box', 'linePAL']; }
    // Envelope mask to zero a signal (multiply) before mixing (adding) to the PAL frame and line sync signal (linePAL)
    maskpicture {
	^LFPulse.ar(freq: 15.625, width: 1-(120/640), iphase: 1-(120/640) + 0.04,
	      mul: LFPulse.kr(freq: 1/20,
	      width: 0.976 - 0.004 - 0.008, iphase: -0.003 - 0.006,
	      mul: 0.32));
    }

    defineCVBS {
	var h = 0.2,
	center = -0.250,
	v = -0.00135;

	// Vertical bar
	SynthDef("vBar", {arg brightness = 1, width = 0.1, x = 0.0;
	    var scale = 0.8;
	    Out.ar(0, LFPulse.ar(freq: 125/8, width: width * scale, iphase: -1 * scale * x - 0.161, mul: brightness) * Object.maskpicture.value)
	}).add;

	// Horizontal bar
	SynthDef("hBar", {arg brightness = 1, height = 0.1, y = 0.0;
		var scale = 0.9145;
		Out.ar(0, LFPulse.ar(freq: 1/20, width: height * scale, iphase: -1 * scale * y - 0.055, mul: brightness) * Object.maskpicture.value)
	}).add;

	// Horizontal line (1 pixel high)
	//  x : 0 to 720, y : 0 to 576 (PAL)
	SynthDef("hLine", {arg brightness = 1, length = 1, x = 0, y = 0;
		var scale = 0.74, w = 576, yscale = 0.9216;
		Out.ar(0, LFPulse.ar(freq: 1/40, width: length / (w * 720) * scale, iphase: -1 * (x / w / 720 * scale) - ((y / w / 2) * yscale) - 0.02906,
			mul: brightness) * Object.maskpicture.value)
	}).add;

	// Box drawing
	SynthDef("Box", {arg brightness = 1, width = 0.1, x = 0.0, height = 0.1, y = 0.0;
		var xscale = 0.8, yscale = 0.9145;
		Out.ar(0, LFPulse.ar(freq: 125/8, width: width * xscale, iphase: -1 * xscale * x - 0.161, mul: brightness) *
			LFPulse.ar(freq: 1/20, width: height * yscale, iphase: -1 * yscale * y - 0.055) * Object.maskpicture.value)
	}).add;

	// PAL line and frame sync for black / empty video signal
	// optional color burst signal via color arg
	SynthDef("linePAL", {arg color = 0;
		var burst = LFPulse.ar(freq: 15.625, width: 15625 / (283.75 * 15625 + 25) * 10, iphase: -0.09,
			mul: SinOsc.ar(freq: (283.75 * 15625 + 25) / 1000, phase: 0.0,
				mul: LFPulse.kr(freq: 1/20, width: 0.976, iphase: -0.001, mul: -0.1)  // no color bursts between frames
			)) * color + center;
		Out.ar(0, LFPulse.ar(freq: 15.625, width: 47/640,
			mul: LFPulse.kr(freq: 1/20, width: 0.976, iphase: -0.001, mul: -1 * h),
			add: Mix([
				LFPulse.ar(freq: 125/4, width: 1-0.140625, iphase: 0.15,
					mul: LFPulse.ar(freq: 1/20, width: 0.992, mul: h, add: -1 * h, iphase: 0.008 + v)),
				LFPulse.ar(freq: 125/4, width: 0.078125, iphase: 0.151,
					mul: Mix(LFPulse.ar(freq: 1/20, width: 0.992, mul: h, add: -1 * h, iphase:[0.0 + v, 0.016 + v])),
					add: burst)
				])
		))
	}).add;
    }
}
