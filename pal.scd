(
var server = Server(\nrt,
    options: ServerOptions.new
    .numOutputBusChannels_(2)
    .numInputBusChannels_(2)
),
h = 0.2,
center = -0.250,
v = -0.00135,
def = SynthDef("linePAL", {
	//Out.ar(0, Pulse.ar(freq: 15.625, width: 47/640, mul: 0.2, add: -0.25))
	Out.ar(0, LFPulse.ar(freq: 15.625, width: 47/640, 
	//mul: Env.pairs([[1,0], [0,287.5*8/125], [1, (287.5+25)*8/125], [0, (2*287.5+25)*8/125], [1, (2*287.5+50)*8/125]], \step).ar(),
	//mul: Env.pairs([[0, 0.2], [287.5*8/125, 0], [(287.5+25)*8/125, 0.2], [(2*287.5+25)*8/125, 0]], \lin).kr(),
	//mul: LFPulse.ar(freq: 1/20, width: 0.92, mul: 0.2),
	mul: LFPulse.kr(freq: 1/20, width: 0.976, iphase: -0.001, mul: -1 * h),
	//add: 0.25,
	//add: LFPulse.ar(freq: 125/4, width: [0.09375], mul: Mix(LFPulse.ar(freq: 1/20, width: 0.9904, mul: 0.3, add: -0.3, iphase:[0.0, 0.0192])), add: -0.3),
	add: Mix( [ LFPulse.ar(freq: 125/4, width: 1-0.140625, iphase: 0.15, mul:
LFPulse.ar(freq: 1/20, width: 0.992, mul: h, add: -1 * h, iphase: 0.008 + v) , add:
0.0), LFPulse.ar(freq: 125/4, width: [0.078125], iphase: 0.151, mul: Mix(LFPulse.ar(freq: 1/20,
width: 0.992, mul: h, add: -1 * h, iphase:[0.0 + v, 0.016 + v])), add: center)]),
	))
	//Out.ar(0, Pulse.ar(freq: 1440, width: 0.5, mul: 1.0, add: 0.0))
}),
// placeholder for buffer
buf = Buffer.new(server, 0, 1);
def.add;  // add def to SynthDescLib


x = Pbind(
	\instrument, "linePAL",
	\dur, Pseq([2], 1),
).asScore(625 * 0.064 * 6, timeOffset: 0.001);


x.add([0.0, [\d_recv, def.asBytes]]);
//x.add([0.0, buf.allocReadMsg(ExampleFiles.child)]);
x.sort;

//x.add([0.0, [\d_recv, SynthDescLib.global[\default].def.asBytes]]);


x.recordNRT(
    outputFilePath: "pal01.flac",
    sampleRate: 28636,
    headerFormat: "FLAC",
    sampleFormat: "int8",
    options: ServerOptions.new.numOutputBusChannels_(1),
    duration: x.endTime 
);

server.remove;
"script finished, quitting...".postln;
0.exit;
)
