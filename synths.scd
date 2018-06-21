(
SynthDef(\reverb, {
	|in, roomsize=10, revtime=3, damping=0.5, inputbw=0.5, spread=15, drylevel=1, earlyreflevel=0.7, taillevel=0.5|
	var reverb, signal;
	signal = In.ar(16, 2);
	reverb = GVerb.ar(signal, roomsize: roomsize, revtime: revtime, damping: damping, inputbw: inputbw, spread: spread, drylevel: drylevel, earlyreflevel: earlyreflevel, taillevel: taillevel);
	Out.ar(18, reverb);
}).add;

SynthDef(\dfm, {
	|in, freq = 1000, res = 0.1, inputgain = 1, type = 0, noiselevel = 0.0003, mul = 1, add = 0|
	var dfm, signal, out;
	out = 0;
	signal = In.ar(18, 2);
	dfm = DFM1.ar(in: signal, freq: freq, res: res, inputgain: inputgain, type: type, noiselevel: noiselevel, mul: mul, add: add);
	Out.ar(0, dfm);
}).add;
)
(
~kickBuf = Buffer.read(s,"/Users/justinbosma/Desktop/samples/BPB_Cassette_909/BPB Cassette 909/cassette 1/bd01.wav"); //store handle to Buffer in global variable b


SynthDef("playbufKick",{ arg out=0,bufnum=0, rate=1, trigger=1, startPos=0, loop=1, time = 1, amp = 0.1;

	var sig = PlayBuf.ar(1,bufnum, BufRateScale.kr(bufnum)*rate, trigger, BufFrames.ir(bufnum)*startPos, loop);
	var env = EnvGen.kr(Env.linen(0.01, time, 0.05, level: amp), doneAction: 2);
	Out.ar(out,
		Pan2.ar(sig*env,0.0)
	)
}).add;


~snareBuf = Buffer.read(s,"/Users/justinbosma/Desktop/samples/BPB_Cassette_909/BPB Cassette 909/cassette 1/sd01.wav"); //store handle to Buffer in global variable b


SynthDef("playbufSnare",{ arg out=0,bufnum=0, rate=1, trigger=1, startPos=0, loop=1, time = 1, amp = 0.1;

	var sig = PlayBuf.ar(1,bufnum, BufRateScale.kr(bufnum)*rate, trigger, BufFrames.ir(bufnum)*startPos, loop);
	var env = EnvGen.kr(Env.linen(0.01, time, 0.05, level: amp), doneAction: 2);
	Out.ar(out,
		Pan2.ar(sig*env,0.0)
	)
}).add;


SynthDef(\drone1, {
	|out = 0, freq = 220, mul = 0.1, cutoff = 110, rez = 1.5 numSideBands = 5, modFreq = 100, gate = 1|
	var snd, env;
	out = 16; //set output bus
	snd = PMOsc.ar([freq, freq + 4], modFreq, LFNoise0.kr(1, add: 2), mul: mul) + PMOsc.ar([freq*1.3, freq*1.3 + 4], modFreq, LFNoise0.kr(4, add: 2), mul: mul);
	snd = LPF.ar(snd ,MouseX.kr(0, 1000), MouseY.kr(0, 1));
	//env = EnvGen.ar(Env.adsr(0.2, 0.2, 0.0025, 0.01, 1, -4), gate, doneAction: 2);
	Out.ar(0, Pan2.ar(snd));
}).add;
//mallet sounding synthdef

    SynthDef(\mallet, {|freq, amp, gate = 1, release = 2, cutoff|
        var env, out, osc, delayTime = 0.9, delayDecay = 0.6;
    env = EnvGen.kr(Env.perc(attackTime: 0.05, releaseTime: release),doneAction: 2);
	osc = LPF.ar(SinOsc.ar(freq: freq, mul: amp*0.7), freq: freq-100);
	//osc = Disintegrator.ar(osc, 0.2, 0.7);
	osc = Decimator.ar(osc, 40000, 16);
	osc = FreeVerb.ar(osc, osc, mix: 0.33, room: 0.5, damp: 0.5, mul: 1, add: 0);
	//	osc = BPF.ar(SinOsc.ar(freq: freq, mul: amp), freq: SinOsc.kr(1, mul: 880, add: 220), rq: SinOsc.kr(1, mul: 0.05, add: 0.1));
	out = osc*env;
	//out = out + CombL.ar(out, delayTime, delayTime, delayDecay);
        Out.ar(0,
                Pan2.ar(out, 0));
        };
    ).add;

//mallet sounding synthdef with delay

    SynthDef(\mallet2, {|freq, amp, gate = 1|
        var env, out, osc, delayTime = 0.9, delayDecay = 0.6;
    env = EnvGen.kr(Env.perc(attackTime: 0.05, releaseTime:0.8),doneAction: 2);
    osc = Resonz.ar(SinOsc.ar(freq: freq, mul: amp), freq: freq);
        out = osc*env;
        out = out + CombL.ar(out, delayTime, delayTime, delayDecay);
        Out.ar(0,
                Pan2.ar(out, 0));
        };
    ).add;

//drone instrument. Uses harmonic series for oscillators

    SynthDef(\drone, {|freq, gate = 1, amp, cut = 350|
        var env, out, osc;
    //env = EnvGen.kr(Env.adsr(0.75, 0.1, 0.5, 0.0), doneAction: 2);
    env = EnvGen.kr(Env.new([0, 0.25, 0.5, 1, 0.35, 0.25, 0.1, 0], [1.3, 1.3, 1.0, 0.4, 3.0, 2.5, 0.5]),doneAction: 2);
    osc = RLPF.ar(Saw.ar(freq: freq, mul: amp) + Saw.ar(freq: freq*(1/2), mul: amp) + Saw.ar(freq: freq*(1/3), mul: amp) + Saw.ar(freq: freq*(1/4), mul: amp) + Saw.ar(freq: freq*(1/5), mul: amp), freq: cut);
        out = osc*env;
        Out.ar(0,
                Pan2.ar(out, 0));
        };
    ).add;

//bass instrument

    SynthDef(\bass, {|freq, gate = 1, amp, atk = 0.6, sus = 0.9, rls = 0.9, lfo = 4|
        var env, out, osc;
	env = EnvGen.kr(Env.linen(attackTime: atk, sustainTime: sus, releaseTime: rls, level: 1, curve: 'lin'), doneAction: 2);
        osc = SinOsc.ar(freq: freq, mul: amp*0.7);
	out = LPF.ar(osc*env, SinOsc.kr(lfo, mul: 100, add: 100));
        Out.ar(0,
                Pan2.ar(out, 0));
        };
    ).add;


SynthDef(\pad1, {
	|out = 0, freq = 1, amp = 0.01, cutoff = 1100, rez = 1.5, release = 8, sus =1, lowDiv = 1|
	var snd, envWhtNs, envSin, whtNs, sin;
	//snd = Disintegrator.ar(WhiteNoise.ar(freq, mul: amp) + SinOsc.ar(freq*220, mul: amp), MouseX.kr(0, 1));
	//whtNs = LPF.ar(WhiteNoise.ar(freq, mul: amp), SinOsc.kr(80, mul: 440, add: 880));
	whtNs = LPF.ar(WhiteNoise.ar(freq, mul: amp), cutoff);
	sin = Mix.new([SinOsc.ar(freq, mul: amp), SinOsc.ar(freq*2, mul: amp), SinOsc.ar(freq*3, mul: amp), SinOsc.ar(freq/lowDiv, mul: amp)]);

	envWhtNs = EnvGen.ar(Env.linen(attackTime: 1.5, sustainTime: sus + 7, releaseTime: release + 4, level: 1, curve: -1), doneAction: 2);
	envSin = EnvGen.ar(Env.linen(attackTime: 1.7, sustainTime: sus, releaseTime: release, level: 1, curve: -1), doneAction: 2);
	snd = whtNs*envWhtNs + sin*envSin;
	//snd = Disintegrator.ar(snd, probability: 0.5, multiplier: -1, mul: amp);
	//snd = GVerb.ar(snd, mul: amp);
	Out.ar(out, Pan2.ar(snd));
}).add;

SynthDef(\piano, {
	|out = 0, freq = 1, amp = 0.01, cutoff = 110, rez = 1.5|
	var snd, env;
	snd = MdaPiano.ar(freq: freq, mul: amp);
	//env = EnvGen.ar(Env.linen(0.5,1 , 1, -8), doneAction: 2);
	Out.ar(out, Pan2.ar(snd));
}).add;

SynthDef(\tink, {
	|out = 0, freq = 440, amp = 0.1, detune = -15, bend = 0|
	var snd, env;
	snd = SinOscFB.ar(freq: freq + bend, feedback: MouseX.kr(0, 2), mul: amp*0.2) + BPF.ar(SinOsc.ar(freq: (freq + detune + bend), mul: amp*0.3), freq: freq);
	env = EnvGen.ar(Env.perc(0.0005, Rand(0.001, 1), 1, -8), doneAction: 2);
	Out.ar(out, Pan2.ar(snd*env));
}).add;

SynthDef(\moogVCF, {
	arg out=0,freq, amp = 0.1, time = 0.95, cutoff = 0, res = 0, feedback = 0;
	var sig = SinOscFB.ar(freq, SinOsc.kr(4, mul:2, add:2));
	var env = EnvGen.kr(Env.linen(0.01, time, 0.05, level: amp), doneAction: 2);
	sig = sig*env;

	//sig = Disintegrator.ar(sig, MouseX.kr(0, 1), MouseY.kr(-1, 1));
	//sig = CrossoverDistortion.ar(sig, smooth: MouseY.kr(0, 1), mul: amp);

	sig = MoogVCF.ar(sig, fco: cutoff, res:  res);
	sig = Decimator.ar(sig, MouseX.kr(0, 44444), MouseY.kr(0, 24), mul: amp);
	Out.ar(out,
		Pan2.ar(sig,0.0)
	)
}).add;
)
