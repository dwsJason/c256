;
; VDMA Tables, used for scaling the audio
;
	dsk magic
	org $200
	mx %00

dma_table ent
	da	:scale0001,:scale0002,:scale0003,:scale0004,:scale0005,:scale0006,:scale0007,:scale0008
	da	:scale0009,:scale000a,:scale000b,:scale000c,:scale000d,:scale000e,:scale000f,:scale0010
	da	:scale0011,:scale0012,:scale0013,:scale0014,:scale0015,:scale0016,:scale0017,:scale0018
	da	:scale0019,:scale001a,:scale001b,:scale001c,:scale001d,:scale001e,:scale001f,:scale0020
	da	:scale0021,:scale0022,:scale0023,:scale0024,:scale0025,:scale0026,:scale0027,:scale0028
	da	:scale0029,:scale002a,:scale002b,:scale002c,:scale002d,:scale002e,:scale002f,:scale0030
	da	:scale0031,:scale0032,:scale0033,:scale0034,:scale0035,:scale0036,:scale0037,:scale0038
	da	:scale0039,:scale003a,:scale003b,:scale003c,:scale003d,:scale003e,:scale003f,:scale0040
	da	:scale0041,:scale0042,:scale0043,:scale0044,:scale0045,:scale0046,:scale0047,:scale0048
	da	:scale0049,:scale004a,:scale004b,:scale004c,:scale004d,:scale004e,:scale004f,:scale0050
	da	:scale0051,:scale0052,:scale0053,:scale0054,:scale0055,:scale0056,:scale0057,:scale0058
	da	:scale0059,:scale005a,:scale005b,:scale005c,:scale005d,:scale005e,:scale005f,:scale0060
	da	:scale0061,:scale0062,:scale0063,:scale0064,:scale0065,:scale0066,:scale0067,:scale0068
	da	:scale0069,:scale006a,:scale006b,:scale006c,:scale006d,:scale006e,:scale006f,:scale0070
	da	:scale0071,:scale0072,:scale0073,:scale0074,:scale0075,:scale0076,:scale0077,:scale0078
	da	:scale0079,:scale007a,:scale007b,:scale007c,:scale007d,:scale007e,:scale007f,:scale0080
	da	:scale0081,:scale0082,:scale0083,:scale0084,:scale0085,:scale0086,:scale0087,:scale0088
	da	:scale0089,:scale008a,:scale008b,:scale008c,:scale008d,:scale008e,:scale008f,:scale0090
	da	:scale0091,:scale0092,:scale0093,:scale0094,:scale0095,:scale0096,:scale0097,:scale0098
	da	:scale0099,:scale009a,:scale009b,:scale009c,:scale009d,:scale009e,:scale009f,:scale00a0
	da	:scale00a1,:scale00a2,:scale00a3,:scale00a4,:scale00a5,:scale00a6,:scale00a7,:scale00a8
	da	:scale00a9,:scale00aa,:scale00ab,:scale00ac,:scale00ad,:scale00ae,:scale00af,:scale00b0
	da	:scale00b1,:scale00b2,:scale00b3,:scale00b4,:scale00b5,:scale00b6,:scale00b7,:scale00b8
	da	:scale00b9,:scale00ba,:scale00bb,:scale00bc,:scale00bd,:scale00be,:scale00bf,:scale00c0
	da	:scale00c1,:scale00c2,:scale00c3,:scale00c4,:scale00c5,:scale00c6,:scale00c7,:scale00c8
	da	:scale00c9,:scale00ca,:scale00cb,:scale00cc,:scale00cd,:scale00ce,:scale00cf,:scale00d0
	da	:scale00d1,:scale00d2,:scale00d3,:scale00d4,:scale00d5,:scale00d6,:scale00d7,:scale00d8
	da	:scale00d9,:scale00da,:scale00db,:scale00dc,:scale00dd,:scale00de,:scale00df,:scale00e0
	da	:scale00e1,:scale00e2,:scale00e3,:scale00e4,:scale00e5,:scale00e6,:scale00e7,:scale00e8
	da	:scale00e9,:scale00ea,:scale00eb,:scale00ec,:scale00ed,:scale00ee,:scale00ef,:scale00f0
	da	:scale00f1,:scale00f2,:scale00f3,:scale00f4,:scale00f5,:scale00f6,:scale00f7,:scale00f8
	da	:scale00f9,:scale00fa,:scale00fb,:scale00fc,:scale00fd,:scale00fe,:scale00ff,:scale0100
	da	:scale0101,:scale0102,:scale0103,:scale0104,:scale0105,:scale0106,:scale0107,:scale0108
	da	:scale0109,:scale010a,:scale010b,:scale010c,:scale010d,:scale010e,:scale010f,:scale0110
	da	:scale0111,:scale0112,:scale0113,:scale0114,:scale0115,:scale0116,:scale0117,:scale0118
	da	:scale0119,:scale011a,:scale011b,:scale011c,:scale011d,:scale011e,:scale011f,:scale0120
	da	:scale0121,:scale0122,:scale0123,:scale0124,:scale0125,:scale0126,:scale0127,:scale0128
	da	:scale0129,:scale012a,:scale012b,:scale012c,:scale012d,:scale012e,:scale012f,:scale0130
	da	:scale0131,:scale0132,:scale0133,:scale0134,:scale0135,:scale0136,:scale0137,:scale0138
	da	:scale0139,:scale013a,:scale013b,:scale013c,:scale013d,:scale013e,:scale013f,:scale0140
	da	:scale0141,:scale0142,:scale0143,:scale0144,:scale0145,:scale0146,:scale0147,:scale0148
	da	:scale0149,:scale014a,:scale014b,:scale014c,:scale014d,:scale014e,:scale014f,:scale0150
	da	:scale0151,:scale0152,:scale0153,:scale0154,:scale0155,:scale0156,:scale0157,:scale0158
	da	:scale0159,:scale015a,:scale015b,:scale015c,:scale015d,:scale015e,:scale015f,:scale0160
	da	:scale0161,:scale0162,:scale0163,:scale0164,:scale0165,:scale0166,:scale0167,:scale0168
	da	:scale0169,:scale016a,:scale016b,:scale016c,:scale016d,:scale016e,:scale016f,:scale0170
	da	:scale0171,:scale0172,:scale0173,:scale0174,:scale0175,:scale0176,:scale0177,:scale0178
	da	:scale0179,:scale017a,:scale017b,:scale017c,:scale017d,:scale017e,:scale017f,:scale0180
	da	:scale0181,:scale0182,:scale0183,:scale0184,:scale0185,:scale0186,:scale0187,:scale0188
	da	:scale0189,:scale018a,:scale018b,:scale018c,:scale018d,:scale018e,:scale018f,:scale0190
	da	:scale0191,:scale0192,:scale0193,:scale0194,:scale0195,:scale0196,:scale0197,:scale0198
	da	:scale0199,:scale019a,:scale019b,:scale019c,:scale019d,:scale019e,:scale019f,:scale01a0
	da	:scale01a1,:scale01a2,:scale01a3,:scale01a4,:scale01a5,:scale01a6,:scale01a7,:scale01a8
	da	:scale01a9,:scale01aa,:scale01ab,:scale01ac,:scale01ad,:scale01ae,:scale01af,:scale01b0
	da	:scale01b1,:scale01b2,:scale01b3,:scale01b4,:scale01b5,:scale01b6,:scale01b7,:scale01b8
	da	:scale01b9,:scale01ba,:scale01bb,:scale01bc,:scale01bd,:scale01be,:scale01bf,:scale01c0
	da	:scale01c1,:scale01c2,:scale01c3,:scale01c4,:scale01c5,:scale01c6,:scale01c7,:scale01c8
	da	:scale01c9,:scale01ca,:scale01cb,:scale01cc,:scale01cd,:scale01ce,:scale01cf,:scale01d0
	da	:scale01d1,:scale01d2,:scale01d3,:scale01d4,:scale01d5,:scale01d6,:scale01d7,:scale01d8
	da	:scale01d9,:scale01da,:scale01db,:scale01dc,:scale01dd,:scale01de,:scale01df,:scale01e0
	da	:scale01e1,:scale01e2,:scale01e3,:scale01e4,:scale01e5,:scale01e6,:scale01e7,:scale01e8
	da	:scale01e9,:scale01ea,:scale01eb,:scale01ec,:scale01ed,:scale01ee,:scale01ef,:scale01f0
	da	:scale01f1,:scale01f2,:scale01f3,:scale01f4,:scale01f5,:scale01f6,:scale01f7,:scale01f8
	da	:scale01f9,:scale01fa,:scale01fb,:scale01fc,:scale01fd,:scale01fe,:scale01ff,:scale0200
	da	:scale0201,:scale0202,:scale0203,:scale0204,:scale0205,:scale0206,:scale0207,:scale0208
	da	:scale0209,:scale020a,:scale020b,:scale020c,:scale020d,:scale020e,:scale020f,:scale0210
	da	:scale0211,:scale0212,:scale0213,:scale0214,:scale0215,:scale0216,:scale0217,:scale0218
	da	:scale0219,:scale021a,:scale021b,:scale021c,:scale021d,:scale021e,:scale021f,:scale0220
	da	:scale0221,:scale0222,:scale0223,:scale0224,:scale0225,:scale0226,:scale0227,:scale0228
	da	:scale0229,:scale022a,:scale022b,:scale022c,:scale022d,:scale022e,:scale022f,:scale0230
	da	:scale0231,:scale0232,:scale0233,:scale0234,:scale0235,:scale0236,:scale0237,:scale0238
	da	:scale0239,:scale023a,:scale023b,:scale023c,:scale023d,:scale023e,:scale023f,:scale0240
	da	:scale0241,:scale0242,:scale0243,:scale0244,:scale0245,:scale0246,:scale0247,:scale0248
	da	:scale0249,:scale024a,:scale024b,:scale024c,:scale024d,:scale024e,:scale024f,:scale0250
	da	:scale0251,:scale0252,:scale0253,:scale0254,:scale0255,:scale0256,:scale0257,:scale0258
	da	:scale0259,:scale025a,:scale025b,:scale025c,:scale025d,:scale025e,:scale025f,:scale0260
	da	:scale0261,:scale0262,:scale0263,:scale0264,:scale0265,:scale0266,:scale0267,:scale0268
	da	:scale0269,:scale026a,:scale026b,:scale026c,:scale026d,:scale026e,:scale026f,:scale0270
	da	:scale0271,:scale0272,:scale0273,:scale0274,:scale0275,:scale0276,:scale0277,:scale0278
	da	:scale0279,:scale027a,:scale027b,:scale027c,:scale027d,:scale027e,:scale027f,:scale0280
	da	:scale0281,:scale0282,:scale0283,:scale0284,:scale0285,:scale0286,:scale0287,:scale0288
	da	:scale0289,:scale028a,:scale028b,:scale028c,:scale028d,:scale028e,:scale028f,:scale0290
	da	:scale0291,:scale0292,:scale0293,:scale0294,:scale0295,:scale0296,:scale0297,:scale0298
	da	:scale0299,:scale029a,:scale029b,:scale029c,:scale029d,:scale029e,:scale029f,:scale02a0
	da	:scale02a1,:scale02a2,:scale02a3,:scale02a4,:scale02a5,:scale02a6,:scale02a7,:scale02a8
	da	:scale02a9,:scale02aa,:scale02ab,:scale02ac,:scale02ad,:scale02ae,:scale02af,:scale02b0
	da	:scale02b1,:scale02b2,:scale02b3,:scale02b4,:scale02b5,:scale02b6,:scale02b7,:scale02b8
	da	:scale02b9,:scale02ba,:scale02bb,:scale02bc,:scale02bd,:scale02be,:scale02bf,:scale02c0
	da	:scale02c1,:scale02c2,:scale02c3,:scale02c4,:scale02c5,:scale02c6,:scale02c7,:scale02c8
	da	:scale02c9,:scale02ca,:scale02cb,:scale02cc,:scale02cd,:scale02ce,:scale02cf,:scale02d0
	da	:scale02d1,:scale02d2,:scale02d3,:scale02d4,:scale02d5,:scale02d6,:scale02d7,:scale02d8
	da	:scale02d9,:scale02da,:scale02db,:scale02dc,:scale02dd,:scale02de,:scale02df,:scale02e0
	da	:scale02e1,:scale02e2,:scale02e3,:scale02e4,:scale02e5,:scale02e6,:scale02e7,:scale02e8
	da	:scale02e9,:scale02ea,:scale02eb,:scale02ec,:scale02ed,:scale02ee,:scale02ef,:scale02f0
	da	:scale02f1,:scale02f2,:scale02f3,:scale02f4,:scale02f5,:scale02f6,:scale02f7,:scale02f8
	da	:scale02f9,:scale02fa,:scale02fb,:scale02fc,:scale02fd,:scale02fe,:scale02ff,:scale0300
	da	:scale0301,:scale0302,:scale0303,:scale0304,:scale0305,:scale0306,:scale0307,:scale0308
	da	:scale0309,:scale030a,:scale030b,:scale030c,:scale030d,:scale030e,:scale030f,:scale0310
	da	:scale0311,:scale0312,:scale0313,:scale0314,:scale0315,:scale0316,:scale0317,:scale0318
	da	:scale0319,:scale031a,:scale031b,:scale031c,:scale031d,:scale031e,:scale031f,:scale0320
	da	:scale0321,:scale0322,:scale0323,:scale0324,:scale0325,:scale0326,:scale0327,:scale0328
	da	:scale0329,:scale032a,:scale032b,:scale032c,:scale032d,:scale032e,:scale032f,:scale0330
	da	:scale0331,:scale0332,:scale0333,:scale0334,:scale0335,:scale0336,:scale0337,:scale0338
	da	:scale0339,:scale033a,:scale033b,:scale033c,:scale033d,:scale033e,:scale033f,:scale0340
	da	:scale0341,:scale0342,:scale0343,:scale0344,:scale0345,:scale0346,:scale0347,:scale0348
	da	:scale0349,:scale034a,:scale034b,:scale034c,:scale034d,:scale034e,:scale034f,:scale0350
	da	:scale0351,:scale0352,:scale0353,:scale0354,:scale0355,:scale0356,:scale0357,:scale0358
	da	:scale0359,:scale035a,:scale035b,:scale035c,:scale035d,:scale035e,:scale035f,:scale0360
	da	:scale0361,:scale0362,:scale0363,:scale0364,:scale0365,:scale0366,:scale0367,:scale0368
	da	:scale0369,:scale036a,:scale036b,:scale036c,:scale036d,:scale036e,:scale036f,:scale0370
	da	:scale0371,:scale0372,:scale0373,:scale0374,:scale0375,:scale0376,:scale0377,:scale0378
	da	:scale0379,:scale037a,:scale037b,:scale037c,:scale037d,:scale037e,:scale037f,:scale0380
	da	:scale0381,:scale0382,:scale0383,:scale0384,:scale0385,:scale0386,:scale0387,:scale0388
	da	:scale0389,:scale038a,:scale038b,:scale038c,:scale038d,:scale038e,:scale038f,:scale0390
	da	:scale0391,:scale0392,:scale0393,:scale0394,:scale0395,:scale0396,:scale0397,:scale0398
	da	:scale0399,:scale039a,:scale039b,:scale039c,:scale039d,:scale039e,:scale039f,:scale03a0
	da	:scale03a1,:scale03a2,:scale03a3,:scale03a4,:scale03a5,:scale03a6,:scale03a7,:scale03a8
	da	:scale03a9,:scale03aa,:scale03ab,:scale03ac,:scale03ad,:scale03ae,:scale03af,:scale03b0
	da	:scale03b1,:scale03b2,:scale03b3,:scale03b4,:scale03b5,:scale03b6,:scale03b7,:scale03b8
	da	:scale03b9,:scale03ba,:scale03bb,:scale03bc,:scale03bd,:scale03be,:scale03bf,:scale03c0
	da	:scale03c1,:scale03c2,:scale03c3,:scale03c4,:scale03c5,:scale03c6,:scale03c7,:scale03c8
	da	:scale03c9,:scale03ca,:scale03cb,:scale03cc,:scale03cd,:scale03ce,:scale03cf,:scale03d0
	da	:scale03d1,:scale03d2,:scale03d3,:scale03d4,:scale03d5,:scale03d6,:scale03d7,:scale03d8
	da	:scale03d9,:scale03da,:scale03db,:scale03dc,:scale03dd,:scale03de,:scale03df,:scale03e0
	da	:scale03e1,:scale03e2,:scale03e3,:scale03e4,:scale03e5,:scale03e6,:scale03e7,:scale03e8
	da	:scale03e9,:scale03ea,:scale03eb,:scale03ec,:scale03ed,:scale03ee,:scale03ef,:scale03f0
	da	:scale03f1,:scale03f2,:scale03f3,:scale03f4,:scale03f5,:scale03f6,:scale03f7,:scale03f8
	da	:scale03f9,:scale03fa,:scale03fb,:scale03fc,:scale03fd,:scale03fe,:scale03ff,:scale0400
	da	:scale0401,:scale0402,:scale0403,:scale0404,:scale0405,:scale0406,:scale0407,:scale0408
	da	:scale0409,:scale040a,:scale040b,:scale040c,:scale040d,:scale040e,:scale040f,:scale0410
	da	:scale0411,:scale0412,:scale0413,:scale0414,:scale0415,:scale0416,:scale0417,:scale0418
	da	:scale0419,:scale041a,:scale041b,:scale041c,:scale041d,:scale041e,:scale041f,:scale0420
	da	:scale0421,:scale0422,:scale0423,:scale0424,:scale0425,:scale0426,:scale0427,:scale0428
	da	:scale0429,:scale042a,:scale042b,:scale042c,:scale042d,:scale042e,:scale042f,:scale0430
	da	:scale0431,:scale0432,:scale0433,:scale0434,:scale0435,:scale0436,:scale0437,:scale0438
	da	:scale0439,:scale043a,:scale043b,:scale043c,:scale043d,:scale043e,:scale043f,:scale0440
	da	:scale0441,:scale0442,:scale0443,:scale0444,:scale0445,:scale0446,:scale0447,:scale0448
	da	:scale0449,:scale044a,:scale044b,:scale044c,:scale044d,:scale044e,:scale044f,:scale0450
	da	:scale0451,:scale0452,:scale0453,:scale0454,:scale0455,:scale0456,:scale0457,:scale0458
	da	:scale0459,:scale045a,:scale045b,:scale045c,:scale045d,:scale045e,:scale045f,:scale0460
	da	:scale0461,:scale0462,:scale0463,:scale0464,:scale0465,:scale0466,:scale0467,:scale0468
	da	:scale0469,:scale046a,:scale046b,:scale046c,:scale046d,:scale046e,:scale046f,:scale0470
	da	:scale0471,:scale0472,:scale0473,:scale0474,:scale0475,:scale0476,:scale0477,:scale0478
	da	:scale0479,:scale047a,:scale047b,:scale047c,:scale047d,:scale047e,:scale047f,:scale0480
	da	:scale0481,:scale0482,:scale0483,:scale0484,:scale0485,:scale0486,:scale0487,:scale0488
	da	:scale0489,:scale048a,:scale048b,:scale048c,:scale048d,:scale048e,:scale048f,:scale0490
	da	:scale0491,:scale0492,:scale0493,:scale0494,:scale0495,:scale0496,:scale0497,:scale0498
	da	:scale0499,:scale049a,:scale049b,:scale049c,:scale049d,:scale049e,:scale049f,:scale04a0
	da	:scale04a1,:scale04a2,:scale04a3,:scale04a4,:scale04a5,:scale04a6,:scale04a7,:scale04a8
	da	:scale04a9,:scale04aa,:scale04ab,:scale04ac,:scale04ad,:scale04ae,:scale04af,:scale04b0
	da	:scale04b1,:scale04b2,:scale04b3,:scale04b4,:scale04b5,:scale04b6,:scale04b7,:scale04b8
	da	:scale04b9,:scale04ba,:scale04bb,:scale04bc,:scale04bd,:scale04be,:scale04bf,:scale04c0
	da	:scale04c1,:scale04c2,:scale04c3,:scale04c4,:scale04c5,:scale04c6,:scale04c7,:scale04c8
	da	:scale04c9,:scale04ca,:scale04cb,:scale04cc,:scale04cd,:scale04ce,:scale04cf,:scale04d0
	da	:scale04d1,:scale04d2,:scale04d3,:scale04d4,:scale04d5,:scale04d6,:scale04d7,:scale04d8
	da	:scale04d9,:scale04da,:scale04db,:scale04dc,:scale04dd,:scale04de,:scale04df,:scale04e0
	da	:scale04e1,:scale04e2,:scale04e3,:scale04e4,:scale04e5,:scale04e6,:scale04e7,:scale04e8
	da	:scale04e9,:scale04ea,:scale04eb,:scale04ec,:scale04ed,:scale04ee,:scale04ef,:scale04f0
	da	:scale04f1,:scale04f2,:scale04f3,:scale04f4,:scale04f5,:scale04f6,:scale04f7,:scale04f8
	da	:scale04f9,:scale04fa,:scale04fb,:scale04fc,:scale04fd,:scale04fe,:scale04ff,:scale0500
	da	:scale0501,:scale0502,:scale0503,:scale0504,:scale0505,:scale0506,:scale0507,:scale0508
	da	:scale0509,:scale050a,:scale050b,:scale050c,:scale050d,:scale050e,:scale050f,:scale0510
	da	:scale0511,:scale0512,:scale0513,:scale0514,:scale0515,:scale0516,:scale0517,:scale0518
	da	:scale0519,:scale051a,:scale051b,:scale051c,:scale051d,:scale051e,:scale051f,:scale0520
	da	:scale0521,:scale0522,:scale0523,:scale0524,:scale0525,:scale0526,:scale0527,:scale0528
	da	:scale0529,:scale052a,:scale052b,:scale052c,:scale052d,:scale052e,:scale052f,:scale0530
	da	:scale0531,:scale0532,:scale0533,:scale0534,:scale0535,:scale0536,:scale0537,:scale0538
	da	:scale0539,:scale053a,:scale053b,:scale053c,:scale053d,:scale053e,:scale053f,:scale0540
	da	:scale0541,:scale0542,:scale0543,:scale0544,:scale0545,:scale0546,:scale0547,:scale0548
	da	:scale0549,:scale054a,:scale054b,:scale054c,:scale054d,:scale054e,:scale054f,:scale0550
	da	:scale0551,:scale0552,:scale0553,:scale0554,:scale0555,:scale0556,:scale0557,:scale0558
	da	:scale0559,:scale055a,:scale055b,:scale055c,:scale055d,:scale055e,:scale055f,:scale0560
	da	:scale0561,:scale0562,:scale0563,:scale0564,:scale0565,:scale0566,:scale0567,:scale0568
	da	:scale0569,:scale056a,:scale056b,:scale056c,:scale056d,:scale056e,:scale056f,:scale0570
	da	:scale0571,:scale0572,:scale0573,:scale0574,:scale0575,:scale0576,:scale0577,:scale0578
	da	:scale0579,:scale057a,:scale057b,:scale057c,:scale057d,:scale057e,:scale057f,:scale0580
	da	:scale0581,:scale0582,:scale0583,:scale0584,:scale0585,:scale0586,:scale0587,:scale0588
	da	:scale0589,:scale058a,:scale058b,:scale058c,:scale058d,:scale058e,:scale058f,:scale0590
	da	:scale0591,:scale0592,:scale0593,:scale0594,:scale0595,:scale0596,:scale0597,:scale0598
	da	:scale0599,:scale059a,:scale059b,:scale059c,:scale059d,:scale059e,:scale059f,:scale05a0
	da	:scale05a1,:scale05a2,:scale05a3,:scale05a4,:scale05a5,:scale05a6,:scale05a7,:scale05a8
	da	:scale05a9,:scale05aa,:scale05ab,:scale05ac,:scale05ad,:scale05ae,:scale05af,:scale05b0
	da	:scale05b1,:scale05b2,:scale05b3,:scale05b4,:scale05b5,:scale05b6,:scale05b7,:scale05b8
	da	:scale05b9,:scale05ba,:scale05bb,:scale05bc,:scale05bd,:scale05be,:scale05bf,:scale05c0
	da	:scale05c1,:scale05c2,:scale05c3,:scale05c4,:scale05c5,:scale05c6,:scale05c7,:scale05c8
	da	:scale05c9,:scale05ca,:scale05cb,:scale05cc,:scale05cd,:scale05ce,:scale05cf,:scale05d0
	da	:scale05d1,:scale05d2,:scale05d3,:scale05d4,:scale05d5,:scale05d6,:scale05d7,:scale05d8
	da	:scale05d9,:scale05da,:scale05db,:scale05dc,:scale05dd,:scale05de,:scale05df,:scale05e0
	da	:scale05e1,:scale05e2,:scale05e3,:scale05e4,:scale05e5,:scale05e6,:scale05e7,:scale05e8
	da	:scale05e9,:scale05ea,:scale05eb,:scale05ec,:scale05ed,:scale05ee,:scale05ef,:scale05f0
	da	:scale05f1,:scale05f2,:scale05f3,:scale05f4,:scale05f5,:scale05f6,:scale05f7,:scale05f8
	da	:scale05f9,:scale05fa,:scale05fb,:scale05fc,:scale05fd,:scale05fe,:scale05ff,:scale0600
	da	:scale0601,:scale0602,:scale0603,:scale0604,:scale0605,:scale0606,:scale0607,:scale0608
	da	:scale0609,:scale060a,:scale060b,:scale060c,:scale060d,:scale060e,:scale060f,:scale0610
	da	:scale0611,:scale0612,:scale0613,:scale0614,:scale0615,:scale0616,:scale0617,:scale0618
	da	:scale0619,:scale061a,:scale061b,:scale061c,:scale061d,:scale061e,:scale061f,:scale0620
	da	:scale0621,:scale0622,:scale0623,:scale0624,:scale0625,:scale0626,:scale0627,:scale0628
	da	:scale0629,:scale062a,:scale062b,:scale062c,:scale062d,:scale062e,:scale062f,:scale0630
	da	:scale0631,:scale0632,:scale0633,:scale0634,:scale0635,:scale0636,:scale0637,:scale0638
	da	:scale0639,:scale063a,:scale063b,:scale063c,:scale063d,:scale063e,:scale063f,:scale0640
	da	:scale0641,:scale0642,:scale0643,:scale0644,:scale0645,:scale0646,:scale0647,:scale0648
	da	:scale0649,:scale064a,:scale064b,:scale064c,:scale064d,:scale064e,:scale064f,:scale0650
	da	:scale0651,:scale0652,:scale0653,:scale0654,:scale0655,:scale0656,:scale0657,:scale0658
	da	:scale0659,:scale065a,:scale065b,:scale065c,:scale065d,:scale065e,:scale065f,:scale0660
	da	:scale0661,:scale0662,:scale0663,:scale0664,:scale0665,:scale0666,:scale0667,:scale0668
	da	:scale0669,:scale066a,:scale066b,:scale066c,:scale066d,:scale066e,:scale066f,:scale0670
	da	:scale0671,:scale0672,:scale0673,:scale0674,:scale0675,:scale0676,:scale0677,:scale0678
	da	:scale0679,:scale067a,:scale067b,:scale067c,:scale067d,:scale067e,:scale067f,:scale0680
	da	:scale0681,:scale0682,:scale0683,:scale0684,:scale0685,:scale0686,:scale0687,:scale0688
	da	:scale0689,:scale068a,:scale068b,:scale068c,:scale068d,:scale068e,:scale068f,:scale0690
	da	:scale0691,:scale0692,:scale0693,:scale0694,:scale0695,:scale0696,:scale0697,:scale0698
	da	:scale0699,:scale069a,:scale069b,:scale069c,:scale069d,:scale069e,:scale069f,:scale06a0
	da	:scale06a1,:scale06a2,:scale06a3,:scale06a4,:scale06a5,:scale06a6,:scale06a7,:scale06a8
	da	:scale06a9,:scale06aa,:scale06ab,:scale06ac,:scale06ad,:scale06ae,:scale06af,:scale06b0
	da	:scale06b1,:scale06b2,:scale06b3,:scale06b4,:scale06b5,:scale06b6,:scale06b7,:scale06b8
	da	:scale06b9,:scale06ba,:scale06bb,:scale06bc,:scale06bd,:scale06be,:scale06bf,:scale06c0
	da	:scale06c1,:scale06c2,:scale06c3,:scale06c4,:scale06c5,:scale06c6,:scale06c7,:scale06c8
	da	:scale06c9,:scale06ca,:scale06cb,:scale06cc,:scale06cd,:scale06ce,:scale06cf,:scale06d0
	da	:scale06d1,:scale06d2,:scale06d3,:scale06d4,:scale06d5,:scale06d6,:scale06d7,:scale06d8
	da	:scale06d9,:scale06da,:scale06db,:scale06dc,:scale06dd,:scale06de,:scale06df,:scale06e0
	da	:scale06e1,:scale06e2,:scale06e3,:scale06e4,:scale06e5,:scale06e6,:scale06e7,:scale06e8
	da	:scale06e9,:scale06ea,:scale06eb,:scale06ec,:scale06ed,:scale06ee,:scale06ef,:scale06f0
	da	:scale06f1,:scale06f2,:scale06f3,:scale06f4,:scale06f5,:scale06f6,:scale06f7,:scale06f8
	da	:scale06f9,:scale06fa,:scale06fb,:scale06fc,:scale06fd,:scale06fe,:scale06ff,:scale0700
	da	:scale0701,:scale0702,:scale0703,:scale0704,:scale0705,:scale0706,:scale0707,:scale0708
	da	:scale0709,:scale070a,:scale070b,:scale070c,:scale070d,:scale070e,:scale070f,:scale0710
	da	:scale0711,:scale0712,:scale0713,:scale0714,:scale0715,:scale0716,:scale0717,:scale0718
	da	:scale0719,:scale071a,:scale071b,:scale071c,:scale071d,:scale071e,:scale071f,:scale0720
	da	:scale0721,:scale0722,:scale0723,:scale0724,:scale0725,:scale0726,:scale0727,:scale0728
	da	:scale0729,:scale072a,:scale072b,:scale072c,:scale072d,:scale072e,:scale072f,:scale0730
	da	:scale0731,:scale0732,:scale0733,:scale0734,:scale0735,:scale0736,:scale0737,:scale0738
	da	:scale0739,:scale073a,:scale073b,:scale073c,:scale073d,:scale073e,:scale073f,:scale0740
	da	:scale0741,:scale0742,:scale0743,:scale0744,:scale0745,:scale0746,:scale0747,:scale0748
	da	:scale0749,:scale074a,:scale074b,:scale074c,:scale074d,:scale074e,:scale074f,:scale0750
	da	:scale0751,:scale0752,:scale0753,:scale0754,:scale0755,:scale0756,:scale0757,:scale0758
	da	:scale0759,:scale075a,:scale075b,:scale075c,:scale075d,:scale075e,:scale075f,:scale0760
	da	:scale0761,:scale0762,:scale0763,:scale0764,:scale0765,:scale0766,:scale0767,:scale0768
	da	:scale0769,:scale076a,:scale076b,:scale076c,:scale076d,:scale076e,:scale076f,:scale0770
	da	:scale0771,:scale0772,:scale0773,:scale0774,:scale0775,:scale0776,:scale0777,:scale0778
	da	:scale0779,:scale077a,:scale077b,:scale077c,:scale077d,:scale077e,:scale077f,:scale0780
	da	:scale0781,:scale0782,:scale0783,:scale0784,:scale0785,:scale0786,:scale0787,:scale0788
	da	:scale0789,:scale078a,:scale078b,:scale078c,:scale078d,:scale078e,:scale078f,:scale0790
	da	:scale0791,:scale0792,:scale0793,:scale0794,:scale0795,:scale0796,:scale0797,:scale0798
	da	:scale0799,:scale079a,:scale079b,:scale079c,:scale079d,:scale079e,:scale079f,:scale07a0
	da	:scale07a1,:scale07a2,:scale07a3,:scale07a4,:scale07a5,:scale07a6,:scale07a7,:scale07a8
	da	:scale07a9,:scale07aa,:scale07ab,:scale07ac,:scale07ad,:scale07ae,:scale07af,:scale07b0
	da	:scale07b1,:scale07b2,:scale07b3,:scale07b4,:scale07b5,:scale07b6,:scale07b7,:scale07b8
	da	:scale07b9,:scale07ba,:scale07bb,:scale07bc,:scale07bd,:scale07be,:scale07bf,:scale07c0
	da	:scale07c1,:scale07c2,:scale07c3,:scale07c4,:scale07c5,:scale07c6,:scale07c7,:scale07c8
	da	:scale07c9,:scale07ca,:scale07cb,:scale07cc,:scale07cd,:scale07ce,:scale07cf,:scale07d0
	da	:scale07d1,:scale07d2,:scale07d3,:scale07d4,:scale07d5,:scale07d6,:scale07d7,:scale07d8
	da	:scale07d9,:scale07da,:scale07db,:scale07dc,:scale07dd,:scale07de,:scale07df,:scale07e0
	da	:scale07e1,:scale07e2,:scale07e3,:scale07e4,:scale07e5,:scale07e6,:scale07e7,:scale07e8
	da	:scale07e9,:scale07ea,:scale07eb,:scale07ec,:scale07ed,:scale07ee,:scale07ef,:scale07f0
	da	:scale07f1,:scale07f2,:scale07f3,:scale07f4,:scale07f5,:scale07f6,:scale07f7,:scale07f8
	da	:scale07f9,:scale07fa,:scale07fb,:scale07fc,:scale07fd,:scale07fe,:scale07ff,:scale0800
	da	:scale0801,:scale0802,:scale0803,:scale0804,:scale0805,:scale0806,:scale0807,:scale0808
	da	:scale0809,:scale080a,:scale080b,:scale080c,:scale080d,:scale080e,:scale080f,:scale0810
	da	:scale0811,:scale0812,:scale0813,:scale0814,:scale0815,:scale0816,:scale0817,:scale0818
	da	:scale0819,:scale081a,:scale081b,:scale081c,:scale081d,:scale081e,:scale081f,:scale0820
	da	:scale0821,:scale0822,:scale0823,:scale0824,:scale0825,:scale0826,:scale0827,:scale0828
	da	:scale0829,:scale082a,:scale082b,:scale082c,:scale082d,:scale082e,:scale082f,:scale0830
	da	:scale0831,:scale0832,:scale0833,:scale0834,:scale0835,:scale0836,:scale0837,:scale0838
	da	:scale0839,:scale083a,:scale083b,:scale083c,:scale083d,:scale083e,:scale083f,:scale0840
	da	:scale0841,:scale0842,:scale0843,:scale0844,:scale0845,:scale0846,:scale0847,:scale0848
	da	:scale0849,:scale084a,:scale084b,:scale084c,:scale084d,:scale084e,:scale084f,:scale0850
	da	:scale0851,:scale0852,:scale0853,:scale0854,:scale0855,:scale0856,:scale0857,:scale0858
	da	:scale0859,:scale085a,:scale085b,:scale085c,:scale085d,:scale085e,:scale085f,:scale0860
	da	:scale0861,:scale0862,:scale0863,:scale0864,:scale0865,:scale0866,:scale0867,:scale0868
	da	:scale0869,:scale086a,:scale086b,:scale086c,:scale086d,:scale086e,:scale086f,:scale0870
	da	:scale0871,:scale0872,:scale0873,:scale0874,:scale0875,:scale0876,:scale0877,:scale0878
	da	:scale0879,:scale087a,:scale087b,:scale087c,:scale087d,:scale087e,:scale087f,:scale0880
	da	:scale0881,:scale0882,:scale0883,:scale0884,:scale0885,:scale0886,:scale0887,:scale0888
	da	:scale0889,:scale088a,:scale088b,:scale088c,:scale088d,:scale088e,:scale088f,:scale0890
	da	:scale0891,:scale0892,:scale0893,:scale0894,:scale0895,:scale0896,:scale0897,:scale0898
	da	:scale0899,:scale089a,:scale089b,:scale089c,:scale089d,:scale089e,:scale089f,:scale08a0
	da	:scale08a1,:scale08a2,:scale08a3,:scale08a4,:scale08a5,:scale08a6,:scale08a7,:scale08a8
	da	:scale08a9,:scale08aa,:scale08ab,:scale08ac,:scale08ad,:scale08ae,:scale08af,:scale08b0
	da	:scale08b1,:scale08b2,:scale08b3,:scale08b4,:scale08b5,:scale08b6,:scale08b7,:scale08b8
	da	:scale08b9,:scale08ba,:scale08bb,:scale08bc,:scale08bd,:scale08be,:scale08bf,:scale08c0
	da	:scale08c1,:scale08c2,:scale08c3,:scale08c4,:scale08c5,:scale08c6,:scale08c7,:scale08c8
	da	:scale08c9,:scale08ca,:scale08cb,:scale08cc,:scale08cd,:scale08ce,:scale08cf,:scale08d0
	da	:scale08d1,:scale08d2,:scale08d3,:scale08d4,:scale08d5,:scale08d6,:scale08d7,:scale08d8
	da	:scale08d9,:scale08da,:scale08db,:scale08dc,:scale08dd,:scale08de,:scale08df,:scale08e0
	da	:scale08e1,:scale08e2,:scale08e3,:scale08e4,:scale08e5,:scale08e6,:scale08e7,:scale08e8
	da	:scale08e9,:scale08ea,:scale08eb,:scale08ec,:scale08ed,:scale08ee,:scale08ef,:scale08f0
	da	:scale08f1,:scale08f2,:scale08f3,:scale08f4,:scale08f5,:scale08f6,:scale08f7,:scale08f8
	da	:scale08f9,:scale08fa,:scale08fb,:scale08fc,:scale08fd,:scale08fe,:scale08ff,:scale0900
	da	:scale0901,:scale0902,:scale0903,:scale0904,:scale0905,:scale0906,:scale0907,:scale0908
	da	:scale0909,:scale090a,:scale090b,:scale090c,:scale090d,:scale090e,:scale090f,:scale0910
	da	:scale0911,:scale0912,:scale0913,:scale0914,:scale0915,:scale0916,:scale0917,:scale0918
	da	:scale0919,:scale091a,:scale091b,:scale091c,:scale091d,:scale091e,:scale091f,:scale0920
	da	:scale0921,:scale0922,:scale0923,:scale0924,:scale0925,:scale0926,:scale0927,:scale0928
	da	:scale0929,:scale092a,:scale092b,:scale092c,:scale092d,:scale092e,:scale092f,:scale0930
	da	:scale0931,:scale0932,:scale0933,:scale0934,:scale0935,:scale0936,:scale0937,:scale0938
	da	:scale0939,:scale093a,:scale093b,:scale093c,:scale093d,:scale093e,:scale093f,:scale0940
	da	:scale0941,:scale0942,:scale0943,:scale0944,:scale0945,:scale0946,:scale0947,:scale0948
	da	:scale0949,:scale094a,:scale094b,:scale094c,:scale094d,:scale094e,:scale094f,:scale0950
	da	:scale0951,:scale0952,:scale0953,:scale0954,:scale0955,:scale0956,:scale0957,:scale0958
	da	:scale0959,:scale095a,:scale095b,:scale095c,:scale095d,:scale095e,:scale095f,:scale0960
	da	:scale0961,:scale0962,:scale0963,:scale0964,:scale0965,:scale0966,:scale0967,:scale0968
	da	:scale0969,:scale096a,:scale096b,:scale096c,:scale096d,:scale096e,:scale096f,:scale0970
	da	:scale0971,:scale0972,:scale0973,:scale0974,:scale0975,:scale0976,:scale0977,:scale0978
	da	:scale0979,:scale097a,:scale097b,:scale097c,:scale097d,:scale097e,:scale097f,:scale0980
	da	:scale0981,:scale0982,:scale0983,:scale0984,:scale0985,:scale0986,:scale0987,:scale0988
	da	:scale0989,:scale098a,:scale098b,:scale098c,:scale098d,:scale098e,:scale098f,:scale0990
	da	:scale0991,:scale0992,:scale0993,:scale0994,:scale0995,:scale0996,:scale0997,:scale0998
	da	:scale0999,:scale099a,:scale099b,:scale099c,:scale099d,:scale099e,:scale099f,:scale09a0
	da	:scale09a1,:scale09a2,:scale09a3,:scale09a4,:scale09a5,:scale09a6,:scale09a7,:scale09a8
	da	:scale09a9,:scale09aa,:scale09ab,:scale09ac,:scale09ad,:scale09ae,:scale09af,:scale09b0
	da	:scale09b1,:scale09b2,:scale09b3,:scale09b4,:scale09b5,:scale09b6,:scale09b7,:scale09b8
	da	:scale09b9,:scale09ba,:scale09bb,:scale09bc,:scale09bd,:scale09be,:scale09bf,:scale09c0
	da	:scale09c1,:scale09c2,:scale09c3,:scale09c4,:scale09c5,:scale09c6,:scale09c7,:scale09c8
	da	:scale09c9,:scale09ca,:scale09cb,:scale09cc,:scale09cd,:scale09ce,:scale09cf,:scale09d0
	da	:scale09d1,:scale09d2,:scale09d3,:scale09d4,:scale09d5,:scale09d6,:scale09d7,:scale09d8
	da	:scale09d9,:scale09da,:scale09db,:scale09dc,:scale09dd,:scale09de,:scale09df,:scale09e0
	da	:scale09e1,:scale09e2,:scale09e3,:scale09e4,:scale09e5,:scale09e6,:scale09e7,:scale09e8
	da	:scale09e9,:scale09ea,:scale09eb,:scale09ec,:scale09ed,:scale09ee,:scale09ef,:scale09f0
	da	:scale09f1,:scale09f2,:scale09f3,:scale09f4,:scale09f5,:scale09f6,:scale09f7,:scale09f8
	da	:scale09f9,:scale09fa,:scale09fb,:scale09fc,:scale09fd,:scale09fe,:scale09ff,:scale0a00
	da	:scale0a01,:scale0a02,:scale0a03,:scale0a04,:scale0a05,:scale0a06,:scale0a07,:scale0a08
	da	:scale0a09,:scale0a0a,:scale0a0b,:scale0a0c,:scale0a0d,:scale0a0e,:scale0a0f,:scale0a10
	da	:scale0a11,:scale0a12,:scale0a13,:scale0a14,:scale0a15,:scale0a16,:scale0a17,:scale0a18
	da	:scale0a19,:scale0a1a,:scale0a1b,:scale0a1c,:scale0a1d,:scale0a1e,:scale0a1f,:scale0a20
	da	:scale0a21,:scale0a22,:scale0a23,:scale0a24,:scale0a25,:scale0a26,:scale0a27,:scale0a28
	da	:scale0a29,:scale0a2a,:scale0a2b,:scale0a2c,:scale0a2d,:scale0a2e,:scale0a2f,:scale0a30
	da	:scale0a31,:scale0a32,:scale0a33,:scale0a34,:scale0a35,:scale0a36,:scale0a37,:scale0a38
	da	:scale0a39,:scale0a3a,:scale0a3b,:scale0a3c,:scale0a3d,:scale0a3e,:scale0a3f,:scale0a40
	da	:scale0a41,:scale0a42,:scale0a43,:scale0a44,:scale0a45,:scale0a46,:scale0a47,:scale0a48
	da	:scale0a49,:scale0a4a,:scale0a4b,:scale0a4c,:scale0a4d,:scale0a4e,:scale0a4f,:scale0a50
	da	:scale0a51,:scale0a52,:scale0a53,:scale0a54,:scale0a55,:scale0a56,:scale0a57,:scale0a58
	da	:scale0a59,:scale0a5a,:scale0a5b,:scale0a5c,:scale0a5d,:scale0a5e,:scale0a5f,:scale0a60
	da	:scale0a61,:scale0a62,:scale0a63,:scale0a64,:scale0a65,:scale0a66,:scale0a67,:scale0a68
	da	:scale0a69,:scale0a6a,:scale0a6b,:scale0a6c,:scale0a6d,:scale0a6e,:scale0a6f,:scale0a70
	da	:scale0a71,:scale0a72,:scale0a73,:scale0a74,:scale0a75,:scale0a76,:scale0a77,:scale0a78
	da	:scale0a79,:scale0a7a,:scale0a7b,:scale0a7c,:scale0a7d,:scale0a7e,:scale0a7f,:scale0a80
	da	:scale0a81,:scale0a82,:scale0a83,:scale0a84,:scale0a85,:scale0a86,:scale0a87,:scale0a88
	da	:scale0a89,:scale0a8a,:scale0a8b,:scale0a8c,:scale0a8d,:scale0a8e,:scale0a8f,:scale0a90
	da	:scale0a91,:scale0a92,:scale0a93,:scale0a94,:scale0a95,:scale0a96,:scale0a97,:scale0a98
	da	:scale0a99,:scale0a9a,:scale0a9b,:scale0a9c,:scale0a9d,:scale0a9e,:scale0a9f,:scale0aa0
	da	:scale0aa1,:scale0aa2,:scale0aa3,:scale0aa4,:scale0aa5,:scale0aa6,:scale0aa7,:scale0aa8
	da	:scale0aa9,:scale0aaa,:scale0aab,:scale0aac,:scale0aad,:scale0aae,:scale0aaf,:scale0ab0
	da	:scale0ab1,:scale0ab2,:scale0ab3,:scale0ab4,:scale0ab5,:scale0ab6,:scale0ab7,:scale0ab8
	da	:scale0ab9,:scale0aba,:scale0abb,:scale0abc,:scale0abd,:scale0abe,:scale0abf,:scale0ac0
	da	:scale0ac1,:scale0ac2,:scale0ac3,:scale0ac4,:scale0ac5,:scale0ac6,:scale0ac7,:scale0ac8
	da	:scale0ac9,:scale0aca,:scale0acb,:scale0acc,:scale0acd,:scale0ace,:scale0acf,:scale0ad0
	da	:scale0ad1,:scale0ad2,:scale0ad3,:scale0ad4,:scale0ad5,:scale0ad6,:scale0ad7,:scale0ad8
	da	:scale0ad9,:scale0ada,:scale0adb,:scale0adc,:scale0add,:scale0ade,:scale0adf,:scale0ae0
	da	:scale0ae1,:scale0ae2,:scale0ae3,:scale0ae4,:scale0ae5,:scale0ae6,:scale0ae7,:scale0ae8
	da	:scale0ae9,:scale0aea,:scale0aeb,:scale0aec,:scale0aed,:scale0aee,:scale0aef,:scale0af0
	da	:scale0af1,:scale0af2,:scale0af3,:scale0af4,:scale0af5,:scale0af6,:scale0af7,:scale0af8
	da	:scale0af9,:scale0afa,:scale0afb,:scale0afc,:scale0afd,:scale0afe,:scale0aff,:scale0b00
	da	:scale0b01,:scale0b02,:scale0b03,:scale0b04,:scale0b05,:scale0b06,:scale0b07,:scale0b08
	da	:scale0b09,:scale0b0a,:scale0b0b,:scale0b0c,:scale0b0d,:scale0b0e,:scale0b0f,:scale0b10
	da	:scale0b11,:scale0b12,:scale0b13,:scale0b14,:scale0b15,:scale0b16,:scale0b17,:scale0b18
	da	:scale0b19,:scale0b1a,:scale0b1b,:scale0b1c,:scale0b1d,:scale0b1e,:scale0b1f,:scale0b20
	da	:scale0b21,:scale0b22,:scale0b23,:scale0b24,:scale0b25,:scale0b26,:scale0b27,:scale0b28
	da	:scale0b29,:scale0b2a,:scale0b2b,:scale0b2c,:scale0b2d,:scale0b2e,:scale0b2f,:scale0b30
	da	:scale0b31,:scale0b32,:scale0b33,:scale0b34,:scale0b35,:scale0b36,:scale0b37,:scale0b38
	da	:scale0b39,:scale0b3a,:scale0b3b,:scale0b3c,:scale0b3d,:scale0b3e,:scale0b3f,:scale0b40
	da	:scale0b41,:scale0b42,:scale0b43,:scale0b44,:scale0b45,:scale0b46,:scale0b47,:scale0b48
	da	:scale0b49,:scale0b4a,:scale0b4b,:scale0b4c,:scale0b4d,:scale0b4e,:scale0b4f,:scale0b50
	da	:scale0b51,:scale0b52,:scale0b53,:scale0b54,:scale0b55,:scale0b56,:scale0b57,:scale0b58
	da	:scale0b59,:scale0b5a,:scale0b5b,:scale0b5c,:scale0b5d,:scale0b5e,:scale0b5f,:scale0b60
	da	:scale0b61,:scale0b62,:scale0b63,:scale0b64,:scale0b65,:scale0b66,:scale0b67,:scale0b68
	da	:scale0b69,:scale0b6a,:scale0b6b,:scale0b6c,:scale0b6d,:scale0b6e,:scale0b6f,:scale0b70
	da	:scale0b71,:scale0b72,:scale0b73,:scale0b74,:scale0b75,:scale0b76,:scale0b77,:scale0b78
	da	:scale0b79,:scale0b7a,:scale0b7b,:scale0b7c,:scale0b7d,:scale0b7e,:scale0b7f,:scale0b80
	da	:scale0b81,:scale0b82,:scale0b83,:scale0b84,:scale0b85,:scale0b86,:scale0b87,:scale0b88
	da	:scale0b89,:scale0b8a,:scale0b8b,:scale0b8c,:scale0b8d,:scale0b8e,:scale0b8f,:scale0b90
	da	:scale0b91,:scale0b92,:scale0b93,:scale0b94,:scale0b95,:scale0b96,:scale0b97,:scale0b98
	da	:scale0b99,:scale0b9a,:scale0b9b,:scale0b9c,:scale0b9d,:scale0b9e,:scale0b9f,:scale0ba0
	da	:scale0ba1,:scale0ba2,:scale0ba3,:scale0ba4,:scale0ba5,:scale0ba6,:scale0ba7,:scale0ba8
	da	:scale0ba9,:scale0baa,:scale0bab,:scale0bac,:scale0bad,:scale0bae,:scale0baf,:scale0bb0
	da	:scale0bb1,:scale0bb2,:scale0bb3,:scale0bb4,:scale0bb5,:scale0bb6,:scale0bb7,:scale0bb8
	da	:scale0bb9,:scale0bba,:scale0bbb,:scale0bbc,:scale0bbd,:scale0bbe,:scale0bbf,:scale0bc0
	da	:scale0bc1,:scale0bc2,:scale0bc3,:scale0bc4,:scale0bc5,:scale0bc6,:scale0bc7,:scale0bc8
	da	:scale0bc9,:scale0bca,:scale0bcb,:scale0bcc,:scale0bcd,:scale0bce,:scale0bcf,:scale0bd0
	da	:scale0bd1,:scale0bd2,:scale0bd3,:scale0bd4,:scale0bd5,:scale0bd6,:scale0bd7,:scale0bd8
	da	:scale0bd9,:scale0bda,:scale0bdb,:scale0bdc,:scale0bdd,:scale0bde,:scale0bdf,:scale0be0
	da	:scale0be1,:scale0be2,:scale0be3,:scale0be4,:scale0be5,:scale0be6,:scale0be7,:scale0be8
	da	:scale0be9,:scale0bea,:scale0beb,:scale0bec,:scale0bed,:scale0bee,:scale0bef,:scale0bf0
	da	:scale0bf1,:scale0bf2,:scale0bf3,:scale0bf4,:scale0bf5,:scale0bf6,:scale0bf7,:scale0bf8
	da	:scale0bf9,:scale0bfa,:scale0bfb,:scale0bfc,:scale0bfd,:scale0bfe,:scale0bff,:scale0c00
	da	:scale0c01,:scale0c02,:scale0c03,:scale0c04,:scale0c05,:scale0c06,:scale0c07,:scale0c08
	da	:scale0c09,:scale0c0a,:scale0c0b,:scale0c0c,:scale0c0d,:scale0c0e,:scale0c0f,:scale0c10
	da	:scale0c11,:scale0c12,:scale0c13,:scale0c14,:scale0c15,:scale0c16,:scale0c17,:scale0c18
	da	:scale0c19,:scale0c1a,:scale0c1b,:scale0c1c,:scale0c1d,:scale0c1e,:scale0c1f,:scale0c20
	da	:scale0c21,:scale0c22,:scale0c23,:scale0c24,:scale0c25,:scale0c26,:scale0c27,:scale0c28
	da	:scale0c29,:scale0c2a,:scale0c2b,:scale0c2c,:scale0c2d,:scale0c2e,:scale0c2f,:scale0c30
	da	:scale0c31,:scale0c32,:scale0c33,:scale0c34,:scale0c35,:scale0c36,:scale0c37,:scale0c38
	da	:scale0c39,:scale0c3a,:scale0c3b,:scale0c3c,:scale0c3d,:scale0c3e,:scale0c3f,:scale0c40
	da	:scale0c41,:scale0c42,:scale0c43,:scale0c44,:scale0c45,:scale0c46,:scale0c47,:scale0c48
	da	:scale0c49,:scale0c4a,:scale0c4b,:scale0c4c,:scale0c4d,:scale0c4e,:scale0c4f,:scale0c50
	da	:scale0c51,:scale0c52,:scale0c53,:scale0c54,:scale0c55,:scale0c56,:scale0c57,:scale0c58
	da	:scale0c59,:scale0c5a,:scale0c5b,:scale0c5c,:scale0c5d,:scale0c5e,:scale0c5f,:scale0c60
	da	:scale0c61,:scale0c62,:scale0c63,:scale0c64,:scale0c65,:scale0c66,:scale0c67,:scale0c68
	da	:scale0c69,:scale0c6a,:scale0c6b,:scale0c6c,:scale0c6d,:scale0c6e,:scale0c6f,:scale0c70
	da	:scale0c71,:scale0c72,:scale0c73,:scale0c74,:scale0c75,:scale0c76,:scale0c77,:scale0c78
	da	:scale0c79,:scale0c7a,:scale0c7b,:scale0c7c,:scale0c7d,:scale0c7e,:scale0c7f,:scale0c80
	da	:scale0c81,:scale0c82,:scale0c83,:scale0c84,:scale0c85,:scale0c86,:scale0c87,:scale0c88
	da	:scale0c89,:scale0c8a,:scale0c8b,:scale0c8c,:scale0c8d,:scale0c8e,:scale0c8f,:scale0c90
	da	:scale0c91,:scale0c92,:scale0c93,:scale0c94,:scale0c95,:scale0c96,:scale0c97,:scale0c98
	da	:scale0c99,:scale0c9a,:scale0c9b,:scale0c9c,:scale0c9d,:scale0c9e,:scale0c9f,:scale0ca0
	da	:scale0ca1,:scale0ca2,:scale0ca3,:scale0ca4,:scale0ca5,:scale0ca6,:scale0ca7,:scale0ca8
	da	:scale0ca9,:scale0caa,:scale0cab,:scale0cac,:scale0cad,:scale0cae,:scale0caf,:scale0cb0
	da	:scale0cb1,:scale0cb2,:scale0cb3,:scale0cb4,:scale0cb5,:scale0cb6,:scale0cb7,:scale0cb8
	da	:scale0cb9,:scale0cba,:scale0cbb,:scale0cbc,:scale0cbd,:scale0cbe,:scale0cbf,:scale0cc0
	da	:scale0cc1,:scale0cc2,:scale0cc3,:scale0cc4,:scale0cc5,:scale0cc6,:scale0cc7,:scale0cc8
	da	:scale0cc9,:scale0cca,:scale0ccb,:scale0ccc,:scale0ccd,:scale0cce,:scale0ccf,:scale0cd0
	da	:scale0cd1,:scale0cd2,:scale0cd3,:scale0cd4,:scale0cd5,:scale0cd6,:scale0cd7,:scale0cd8
	da	:scale0cd9,:scale0cda,:scale0cdb,:scale0cdc,:scale0cdd,:scale0cde,:scale0cdf,:scale0ce0
	da	:scale0ce1,:scale0ce2,:scale0ce3,:scale0ce4,:scale0ce5,:scale0ce6,:scale0ce7,:scale0ce8
	da	:scale0ce9,:scale0cea,:scale0ceb,:scale0cec,:scale0ced,:scale0cee,:scale0cef,:scale0cf0
	da	:scale0cf1,:scale0cf2,:scale0cf3,:scale0cf4,:scale0cf5,:scale0cf6,:scale0cf7,:scale0cf8
	da	:scale0cf9,:scale0cfa,:scale0cfb,:scale0cfc,:scale0cfd,:scale0cfe,:scale0cff,:scale0d00
	da	:scale0d01,:scale0d02,:scale0d03,:scale0d04,:scale0d05,:scale0d06,:scale0d07,:scale0d08
	da	:scale0d09,:scale0d0a,:scale0d0b,:scale0d0c,:scale0d0d,:scale0d0e,:scale0d0f,:scale0d10
	da	:scale0d11,:scale0d12,:scale0d13,:scale0d14,:scale0d15,:scale0d16,:scale0d17,:scale0d18
	da	:scale0d19,:scale0d1a,:scale0d1b,:scale0d1c,:scale0d1d,:scale0d1e,:scale0d1f,:scale0d20
	da	:scale0d21,:scale0d22,:scale0d23,:scale0d24,:scale0d25,:scale0d26,:scale0d27,:scale0d28
	da	:scale0d29,:scale0d2a,:scale0d2b,:scale0d2c,:scale0d2d,:scale0d2e,:scale0d2f,:scale0d30
	da	:scale0d31,:scale0d32,:scale0d33,:scale0d34,:scale0d35,:scale0d36,:scale0d37,:scale0d38
	da	:scale0d39,:scale0d3a,:scale0d3b,:scale0d3c,:scale0d3d,:scale0d3e,:scale0d3f,:scale0d40
	da	:scale0d41,:scale0d42,:scale0d43,:scale0d44,:scale0d45,:scale0d46,:scale0d47,:scale0d48
	da	:scale0d49,:scale0d4a,:scale0d4b,:scale0d4c,:scale0d4d,:scale0d4e,:scale0d4f,:scale0d50
	da	:scale0d51,:scale0d52,:scale0d53,:scale0d54,:scale0d55,:scale0d56,:scale0d57,:scale0d58
	da	:scale0d59,:scale0d5a,:scale0d5b,:scale0d5c,:scale0d5d,:scale0d5e,:scale0d5f,:scale0d60
	da	:scale0d61,:scale0d62,:scale0d63,:scale0d64,:scale0d65,:scale0d66,:scale0d67,:scale0d68
	da	:scale0d69,:scale0d6a,:scale0d6b,:scale0d6c,:scale0d6d,:scale0d6e,:scale0d6f,:scale0d70
	da	:scale0d71,:scale0d72,:scale0d73,:scale0d74,:scale0d75,:scale0d76,:scale0d77,:scale0d78
	da	:scale0d79,:scale0d7a,:scale0d7b,:scale0d7c,:scale0d7d,:scale0d7e,:scale0d7f,:scale0d80
	da	:scale0d81,:scale0d82,:scale0d83,:scale0d84,:scale0d85,:scale0d86,:scale0d87,:scale0d88
	da	:scale0d89,:scale0d8a,:scale0d8b,:scale0d8c,:scale0d8d,:scale0d8e,:scale0d8f,:scale0d90
	da	:scale0d91,:scale0d92,:scale0d93,:scale0d94,:scale0d95,:scale0d96,:scale0d97,:scale0d98
	da	:scale0d99,:scale0d9a,:scale0d9b,:scale0d9c,:scale0d9d,:scale0d9e,:scale0d9f,:scale0da0
	da	:scale0da1,:scale0da2,:scale0da3,:scale0da4,:scale0da5,:scale0da6,:scale0da7,:scale0da8
	da	:scale0da9,:scale0daa,:scale0dab,:scale0dac,:scale0dad,:scale0dae,:scale0daf,:scale0db0
	da	:scale0db1,:scale0db2,:scale0db3,:scale0db4,:scale0db5,:scale0db6,:scale0db7,:scale0db8
	da	:scale0db9,:scale0dba,:scale0dbb,:scale0dbc,:scale0dbd,:scale0dbe,:scale0dbf,:scale0dc0
	da	:scale0dc1,:scale0dc2,:scale0dc3,:scale0dc4,:scale0dc5,:scale0dc6,:scale0dc7,:scale0dc8
	da	:scale0dc9,:scale0dca,:scale0dcb,:scale0dcc,:scale0dcd,:scale0dce,:scale0dcf,:scale0dd0
	da	:scale0dd1,:scale0dd2,:scale0dd3,:scale0dd4,:scale0dd5,:scale0dd6,:scale0dd7,:scale0dd8
	da	:scale0dd9,:scale0dda,:scale0ddb,:scale0ddc,:scale0ddd,:scale0dde,:scale0ddf,:scale0de0
	da	:scale0de1,:scale0de2,:scale0de3,:scale0de4,:scale0de5,:scale0de6,:scale0de7,:scale0de8
	da	:scale0de9,:scale0dea,:scale0deb,:scale0dec,:scale0ded,:scale0dee,:scale0def,:scale0df0
	da	:scale0df1,:scale0df2,:scale0df3,:scale0df4,:scale0df5,:scale0df6,:scale0df7,:scale0df8
	da	:scale0df9,:scale0dfa,:scale0dfb,:scale0dfc,:scale0dfd,:scale0dfe,:scale0dff,:scale0e00
	da	:scale0e01,:scale0e02,:scale0e03,:scale0e04,:scale0e05,:scale0e06,:scale0e07,:scale0e08
	da	:scale0e09,:scale0e0a,:scale0e0b,:scale0e0c,:scale0e0d,:scale0e0e,:scale0e0f,:scale0e10
	da	:scale0e11,:scale0e12,:scale0e13,:scale0e14,:scale0e15,:scale0e16,:scale0e17,:scale0e18
	da	:scale0e19,:scale0e1a,:scale0e1b,:scale0e1c,:scale0e1d,:scale0e1e,:scale0e1f,:scale0e20
	da	:scale0e21,:scale0e22,:scale0e23,:scale0e24,:scale0e25,:scale0e26,:scale0e27,:scale0e28
	da	:scale0e29,:scale0e2a,:scale0e2b,:scale0e2c,:scale0e2d,:scale0e2e,:scale0e2f,:scale0e30
	da	:scale0e31,:scale0e32,:scale0e33,:scale0e34,:scale0e35,:scale0e36,:scale0e37,:scale0e38
	da	:scale0e39,:scale0e3a,:scale0e3b,:scale0e3c,:scale0e3d,:scale0e3e,:scale0e3f,:scale0e40
	da	:scale0e41,:scale0e42,:scale0e43,:scale0e44,:scale0e45,:scale0e46,:scale0e47,:scale0e48
	da	:scale0e49,:scale0e4a,:scale0e4b,:scale0e4c,:scale0e4d,:scale0e4e,:scale0e4f,:scale0e50
	da	:scale0e51,:scale0e52,:scale0e53,:scale0e54,:scale0e55,:scale0e56,:scale0e57,:scale0e58
	da	:scale0e59,:scale0e5a,:scale0e5b,:scale0e5c,:scale0e5d,:scale0e5e,:scale0e5f,:scale0e60
	da	:scale0e61,:scale0e62,:scale0e63,:scale0e64,:scale0e65,:scale0e66,:scale0e67,:scale0e68
	da	:scale0e69,:scale0e6a,:scale0e6b,:scale0e6c,:scale0e6d,:scale0e6e,:scale0e6f,:scale0e70
	da	:scale0e71,:scale0e72,:scale0e73,:scale0e74,:scale0e75,:scale0e76,:scale0e77,:scale0e78
	da	:scale0e79,:scale0e7a,:scale0e7b,:scale0e7c,:scale0e7d,:scale0e7e,:scale0e7f,:scale0e80
	da	:scale0e81,:scale0e82,:scale0e83,:scale0e84,:scale0e85,:scale0e86,:scale0e87,:scale0e88
	da	:scale0e89,:scale0e8a,:scale0e8b,:scale0e8c,:scale0e8d,:scale0e8e,:scale0e8f,:scale0e90
	da	:scale0e91,:scale0e92,:scale0e93,:scale0e94,:scale0e95,:scale0e96,:scale0e97,:scale0e98
	da	:scale0e99,:scale0e9a,:scale0e9b,:scale0e9c,:scale0e9d,:scale0e9e,:scale0e9f,:scale0ea0
	da	:scale0ea1,:scale0ea2,:scale0ea3,:scale0ea4,:scale0ea5,:scale0ea6,:scale0ea7,:scale0ea8
	da	:scale0ea9,:scale0eaa,:scale0eab,:scale0eac,:scale0ead,:scale0eae,:scale0eaf,:scale0eb0
	da	:scale0eb1,:scale0eb2,:scale0eb3,:scale0eb4,:scale0eb5,:scale0eb6,:scale0eb7,:scale0eb8
	da	:scale0eb9,:scale0eba,:scale0ebb,:scale0ebc,:scale0ebd,:scale0ebe,:scale0ebf,:scale0ec0
	da	:scale0ec1,:scale0ec2,:scale0ec3,:scale0ec4,:scale0ec5,:scale0ec6,:scale0ec7,:scale0ec8
	da	:scale0ec9,:scale0eca,:scale0ecb,:scale0ecc,:scale0ecd,:scale0ece,:scale0ecf,:scale0ed0
	da	:scale0ed1,:scale0ed2,:scale0ed3,:scale0ed4,:scale0ed5,:scale0ed6,:scale0ed7,:scale0ed8
	da	:scale0ed9,:scale0eda,:scale0edb,:scale0edc,:scale0edd,:scale0ede,:scale0edf,:scale0ee0
	da	:scale0ee1,:scale0ee2,:scale0ee3,:scale0ee4,:scale0ee5,:scale0ee6,:scale0ee7,:scale0ee8
	da	:scale0ee9,:scale0eea,:scale0eeb,:scale0eec,:scale0eed,:scale0eee,:scale0eef,:scale0ef0
	da	:scale0ef1,:scale0ef2,:scale0ef3,:scale0ef4,:scale0ef5,:scale0ef6,:scale0ef7,:scale0ef8
	da	:scale0ef9,:scale0efa,:scale0efb,:scale0efc,:scale0efd,:scale0efe,:scale0eff,:scale0f00
	da	:scale0f01,:scale0f02,:scale0f03,:scale0f04,:scale0f05,:scale0f06,:scale0f07,:scale0f08
	da	:scale0f09,:scale0f0a,:scale0f0b,:scale0f0c,:scale0f0d,:scale0f0e,:scale0f0f,:scale0f10
	da	:scale0f11,:scale0f12,:scale0f13,:scale0f14,:scale0f15,:scale0f16,:scale0f17,:scale0f18
	da	:scale0f19,:scale0f1a,:scale0f1b,:scale0f1c,:scale0f1d,:scale0f1e,:scale0f1f,:scale0f20
	da	:scale0f21,:scale0f22,:scale0f23,:scale0f24,:scale0f25,:scale0f26,:scale0f27,:scale0f28
	da	:scale0f29,:scale0f2a,:scale0f2b,:scale0f2c,:scale0f2d,:scale0f2e,:scale0f2f,:scale0f30
	da	:scale0f31,:scale0f32,:scale0f33,:scale0f34,:scale0f35,:scale0f36,:scale0f37,:scale0f38
	da	:scale0f39,:scale0f3a,:scale0f3b,:scale0f3c,:scale0f3d,:scale0f3e,:scale0f3f,:scale0f40
	da	:scale0f41,:scale0f42,:scale0f43,:scale0f44,:scale0f45,:scale0f46,:scale0f47,:scale0f48
	da	:scale0f49,:scale0f4a,:scale0f4b,:scale0f4c,:scale0f4d,:scale0f4e,:scale0f4f,:scale0f50
	da	:scale0f51,:scale0f52,:scale0f53,:scale0f54,:scale0f55,:scale0f56,:scale0f57,:scale0f58
	da	:scale0f59,:scale0f5a,:scale0f5b,:scale0f5c,:scale0f5d,:scale0f5e,:scale0f5f,:scale0f60
	da	:scale0f61,:scale0f62,:scale0f63,:scale0f64,:scale0f65,:scale0f66,:scale0f67,:scale0f68
	da	:scale0f69,:scale0f6a,:scale0f6b,:scale0f6c,:scale0f6d,:scale0f6e,:scale0f6f,:scale0f70
	da	:scale0f71,:scale0f72,:scale0f73,:scale0f74,:scale0f75,:scale0f76,:scale0f77,:scale0f78
	da	:scale0f79,:scale0f7a,:scale0f7b,:scale0f7c,:scale0f7d,:scale0f7e,:scale0f7f,:scale0f80
	da	:scale0f81,:scale0f82,:scale0f83,:scale0f84,:scale0f85,:scale0f86,:scale0f87,:scale0f88
	da	:scale0f89,:scale0f8a,:scale0f8b,:scale0f8c,:scale0f8d,:scale0f8e,:scale0f8f,:scale0f90
	da	:scale0f91,:scale0f92,:scale0f93,:scale0f94,:scale0f95,:scale0f96,:scale0f97,:scale0f98
	da	:scale0f99,:scale0f9a,:scale0f9b,:scale0f9c,:scale0f9d,:scale0f9e,:scale0f9f,:scale0fa0
	da	:scale0fa1,:scale0fa2,:scale0fa3,:scale0fa4,:scale0fa5,:scale0fa6,:scale0fa7,:scale0fa8
	da	:scale0fa9,:scale0faa,:scale0fab,:scale0fac,:scale0fad,:scale0fae,:scale0faf,:scale0fb0
	da	:scale0fb1,:scale0fb2,:scale0fb3,:scale0fb4,:scale0fb5,:scale0fb6,:scale0fb7,:scale0fb8
	da	:scale0fb9,:scale0fba,:scale0fbb,:scale0fbc,:scale0fbd,:scale0fbe,:scale0fbf,:scale0fc0
	da	:scale0fc1,:scale0fc2,:scale0fc3,:scale0fc4,:scale0fc5,:scale0fc6,:scale0fc7,:scale0fc8
	da	:scale0fc9,:scale0fca,:scale0fcb,:scale0fcc,:scale0fcd,:scale0fce,:scale0fcf,:scale0fd0
	da	:scale0fd1,:scale0fd2,:scale0fd3,:scale0fd4,:scale0fd5,:scale0fd6,:scale0fd7,:scale0fd8
	da	:scale0fd9,:scale0fda,:scale0fdb,:scale0fdc,:scale0fdd,:scale0fde,:scale0fdf,:scale0fe0
	da	:scale0fe1,:scale0fe2,:scale0fe3,:scale0fe4,:scale0fe5,:scale0fe6,:scale0fe7,:scale0fe8
	da	:scale0fe9,:scale0fea,:scale0feb,:scale0fec,:scale0fed,:scale0fee,:scale0fef,:scale0ff0
	da	:scale0ff1,:scale0ff2,:scale0ff3,:scale0ff4,:scale0ff5,:scale0ff6,:scale0ff7,:scale0ff8
	da	:scale0ff9,:scale0ffa,:scale0ffb,:scale0ffc,:scale0ffd,:scale0ffe,:scale0fff,:scale1000
:scale0001
	db	0,0		; Scale, Y
	db	1		; Stages
	db	0,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0002
	db	0,0		; Scale, Y
	db	1		; Stages
	db	128,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0003
	db	0,0		; Scale, Y
	db	2		; Stages
	db	64,1		; Source Stride, Dest Stride
	dw	342		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0004
:scale0005
	db	0,0		; Scale, Y
	db	1		; Stages
	db	64,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0006
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,1		; Source Stride, Dest Stride
	dw	342		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0007
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,1		; Source Stride, Dest Stride
	dw	293		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0008
:scale0009
	db	0,0		; Scale, Y
	db	1		; Stages
	db	32,1		; Source Stride, Dest Stride
	dw	256		; y

:scale000a
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,1		; Source Stride, Dest Stride
	dw	410		; y
	db	8,7		; Source Stride, Dest Stride
	dw	52		; y
	db	4,3		; Source Stride, Dest Stride
	dw	91		; y

:scale000b
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,1		; Source Stride, Dest Stride
	dw	373		; y
	db	4,3		; Source Stride, Dest Stride
	dw	94		; y

:scale000c
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,1		; Source Stride, Dest Stride
	dw	342		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale000d
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,1		; Source Stride, Dest Stride
	dw	341		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale000e
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,1		; Source Stride, Dest Stride
	dw	293		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale000f
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	274		; y
	db	16,1		; Source Stride, Dest Stride
	dw	257		; y

:scale0010
:scale0011
	db	0,0		; Scale, Y
	db	1		; Stages
	db	16,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0012
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,1		; Source Stride, Dest Stride
	dw	455		; y
	db	4,3		; Source Stride, Dest Stride
	dw	114		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0013
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,1		; Source Stride, Dest Stride
	dw	453		; y
	db	4,3		; Source Stride, Dest Stride
	dw	114		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0014
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	410		; y
	db	8,1		; Source Stride, Dest Stride
	dw	359		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0015
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	390		; y
	db	8,1		; Source Stride, Dest Stride
	dw	342		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0016
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	187		; y
	db	8,1		; Source Stride, Dest Stride
	dw	351		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0017
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,1		; Source Stride, Dest Stride
	dw	357		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0018
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,1		; Source Stride, Dest Stride
	dw	342		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0019
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,1		; Source Stride, Dest Stride
	dw	341		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale001a
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	158		; y
	db	8,7		; Source Stride, Dest Stride
	dw	297		; y
	db	8,1		; Source Stride, Dest Stride
	dw	260		; y

:scale001b
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	304		; y
	db	8,1		; Source Stride, Dest Stride
	dw	266		; y

:scale001c
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	293		; y
	db	8,1		; Source Stride, Dest Stride
	dw	257		; y

:scale001d
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	292		; y
	db	8,1		; Source Stride, Dest Stride
	dw	256		; y

:scale001e
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	137		; y
	db	8,1		; Source Stride, Dest Stride
	dw	257		; y

:scale001f
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	67		; y
	db	8,1		; Source Stride, Dest Stride
	dw	260		; y

:scale0020
:scale0021
	db	0,0		; Scale, Y
	db	1		; Stages
	db	8,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0022
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	121		; y
	db	4,3		; Source Stride, Dest Stride
	dw	454		; y
	db	4,3		; Source Stride, Dest Stride
	dw	341		; y
	db	4,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0023
	db	0,0		; Scale, Y
	db	3		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	468		; y
	db	4,3		; Source Stride, Dest Stride
	dw	351		; y
	db	4,1		; Source Stride, Dest Stride
	dw	264		; y

:scale0024
	db	0,0		; Scale, Y
	db	3		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	455		; y
	db	4,3		; Source Stride, Dest Stride
	dw	342		; y
	db	4,1		; Source Stride, Dest Stride
	dw	257		; y

:scale0025
	db	0,0		; Scale, Y
	db	3		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	454		; y
	db	4,3		; Source Stride, Dest Stride
	dw	341		; y
	db	4,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0026
	db	0,0		; Scale, Y
	db	4		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	222		; y
	db	8,7		; Source Stride, Dest Stride
	dw	195		; y
	db	4,3		; Source Stride, Dest Stride
	dw	342		; y
	db	4,1		; Source Stride, Dest Stride
	dw	257		; y

:scale0027
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	105		; y
	db	8,7		; Source Stride, Dest Stride
	dw	197		; y
	db	4,3		; Source Stride, Dest Stride
	dw	345		; y
	db	4,1		; Source Stride, Dest Stride
	dw	259		; y

:scale0028
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	104		; y
	db	8,7		; Source Stride, Dest Stride
	dw	195		; y
	db	4,3		; Source Stride, Dest Stride
	dw	342		; y
	db	4,1		; Source Stride, Dest Stride
	dw	257		; y

:scale0029
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	200		; y
	db	4,3		; Source Stride, Dest Stride
	dw	350		; y
	db	4,1		; Source Stride, Dest Stride
	dw	263		; y

:scale002a
:scale002b
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	195		; y
	db	4,3		; Source Stride, Dest Stride
	dw	342		; y
	db	4,1		; Source Stride, Dest Stride
	dw	257		; y

:scale002c
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	94		; y
	db	4,3		; Source Stride, Dest Stride
	dw	353		; y
	db	4,1		; Source Stride, Dest Stride
	dw	265		; y

:scale002d
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	91		; y
	db	4,3		; Source Stride, Dest Stride
	dw	342		; y
	db	4,1		; Source Stride, Dest Stride
	dw	257		; y

:scale002e
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	45		; y
	db	4,3		; Source Stride, Dest Stride
	dw	349		; y
	db	4,1		; Source Stride, Dest Stride
	dw	262		; y

:scale002f
	db	0,0		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	349		; y
	db	4,1		; Source Stride, Dest Stride
	dw	262		; y

:scale0030
	db	0,0		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	342		; y
	db	4,1		; Source Stride, Dest Stride
	dw	257		; y

:scale0031
	db	0,0		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	341		; y
	db	4,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0032
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	166		; y
	db	8,7		; Source Stride, Dest Stride
	dw	146		; y
	db	4,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0033
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	81		; y
	db	8,7		; Source Stride, Dest Stride
	dw	152		; y
	db	4,1		; Source Stride, Dest Stride
	dw	266		; y

:scale0034
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	79		; y
	db	8,7		; Source Stride, Dest Stride
	dw	149		; y
	db	4,1		; Source Stride, Dest Stride
	dw	261		; y

:scale0035
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	78		; y
	db	8,7		; Source Stride, Dest Stride
	dw	147		; y
	db	4,1		; Source Stride, Dest Stride
	dw	258		; y

:scale0036
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	38		; y
	db	8,7		; Source Stride, Dest Stride
	dw	148		; y
	db	4,1		; Source Stride, Dest Stride
	dw	259		; y

:scale0037
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	149		; y
	db	4,1		; Source Stride, Dest Stride
	dw	261		; y

:scale0038
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	147		; y
	db	4,1		; Source Stride, Dest Stride
	dw	258		; y

:scale0039
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	146		; y
	db	4,1		; Source Stride, Dest Stride
	dw	256		; y

:scale003a
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	36		; y
	db	16,15		; Source Stride, Dest Stride
	dw	70		; y
	db	4,1		; Source Stride, Dest Stride
	dw	263		; y

:scale003b
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	70		; y
	db	4,1		; Source Stride, Dest Stride
	dw	263		; y

:scale003c
:scale003d
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	69		; y
	db	4,1		; Source Stride, Dest Stride
	dw	259		; y

:scale003e
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	34		; y
	db	4,1		; Source Stride, Dest Stride
	dw	264		; y

:scale003f
	db	0,0		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	17		; y
	db	4,1		; Source Stride, Dest Stride
	dw	268		; y

:scale0040
:scale0041
	db	0,0		; Scale, Y
	db	1		; Stages
	db	4,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0042
:scale0043
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	62		; y
	db	4,3		; Source Stride, Dest Stride
	dw	233		; y
	db	4,3		; Source Stride, Dest Stride
	dw	175		; y
	db	2,1		; Source Stride, Dest Stride
	dw	263		; y

:scale0044
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	61		; y
	db	4,3		; Source Stride, Dest Stride
	dw	229		; y
	db	4,3		; Source Stride, Dest Stride
	dw	172		; y
	db	2,1		; Source Stride, Dest Stride
	dw	258		; y

:scale0045
:scale0046
	db	0,0		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	30		; y
	db	4,3		; Source Stride, Dest Stride
	dw	233		; y
	db	4,3		; Source Stride, Dest Stride
	dw	175		; y
	db	2,1		; Source Stride, Dest Stride
	dw	263		; y

:scale0047
	db	0,0		; Scale, Y
	db	3		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	231		; y
	db	4,3		; Source Stride, Dest Stride
	dw	174		; y
	db	2,1		; Source Stride, Dest Stride
	dw	261		; y

:scale0048
	db	0,0		; Scale, Y
	db	3		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	228		; y
	db	4,3		; Source Stride, Dest Stride
	dw	171		; y
	db	2,1		; Source Stride, Dest Stride
	dw	257		; y

:scale0049
	db	0,0		; Scale, Y
	db	3		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	227		; y
	db	4,3		; Source Stride, Dest Stride
	dw	171		; y
	db	2,1		; Source Stride, Dest Stride
	dw	257		; y

:scale004a
:scale004b
:scale004c
	db	0,0		; Scale, Y
	db	4		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	111		; y
	db	8,7		; Source Stride, Dest Stride
	dw	98		; y
	db	4,3		; Source Stride, Dest Stride
	dw	172		; y
	db	2,1		; Source Stride, Dest Stride
	dw	258		; y

:scale004d
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	54		; y
	db	8,7		; Source Stride, Dest Stride
	dw	102		; y
	db	4,3		; Source Stride, Dest Stride
	dw	179		; y
	db	2,1		; Source Stride, Dest Stride
	dw	269		; y

:scale004e
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	53		; y
	db	8,7		; Source Stride, Dest Stride
	dw	100		; y
	db	4,3		; Source Stride, Dest Stride
	dw	175		; y
	db	2,1		; Source Stride, Dest Stride
	dw	263		; y

:scale004f
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	52		; y
	db	8,7		; Source Stride, Dest Stride
	dw	98		; y
	db	4,3		; Source Stride, Dest Stride
	dw	172		; y
	db	2,1		; Source Stride, Dest Stride
	dw	258		; y

:scale0050
	db	0,0		; Scale, Y
	db	4		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	205		; y
	db	4,3		; Source Stride, Dest Stride
	dw	154		; y
	db	4,3		; Source Stride, Dest Stride
	dw	116		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0051
	db	0,0		; Scale, Y
	db	4		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	203		; y
	db	4,3		; Source Stride, Dest Stride
	dw	153		; y
	db	4,3		; Source Stride, Dest Stride
	dw	115		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0052
	db	0,0		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	101		; y
	db	4,3		; Source Stride, Dest Stride
	dw	177		; y
	db	2,1		; Source Stride, Dest Stride
	dw	266		; y

:scale0053
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	99		; y
	db	4,3		; Source Stride, Dest Stride
	dw	174		; y
	db	2,1		; Source Stride, Dest Stride
	dw	261		; y

:scale0054
:scale0055
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	98		; y
	db	4,3		; Source Stride, Dest Stride
	dw	172		; y
	db	2,1		; Source Stride, Dest Stride
	dw	258		; y

:scale0056
	db	0,0		; Scale, Y
	db	4		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	96		; y
	db	8,7		; Source Stride, Dest Stride
	dw	84		; y
	db	8,7		; Source Stride, Dest Stride
	dw	74		; y
	db	2,1		; Source Stride, Dest Stride
	dw	259		; y

:scale0057
	db	0,0		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	24		; y
	db	16,15		; Source Stride, Dest Stride
	dw	47		; y
	db	4,3		; Source Stride, Dest Stride
	dw	177		; y
	db	2,1		; Source Stride, Dest Stride
	dw	266		; y

:scale0058
	db	0,0		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	48		; y
	db	4,3		; Source Stride, Dest Stride
	dw	180		; y
	db	2,1		; Source Stride, Dest Stride
	dw	270		; y

:scale0059
:scale005a
:scale005b
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	46		; y
	db	4,3		; Source Stride, Dest Stride
	dw	173		; y
	db	2,1		; Source Stride, Dest Stride
	dw	260		; y

:scale005c
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	179		; y
	db	2,1		; Source Stride, Dest Stride
	dw	269		; y

:scale005d
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	22		; y
	db	4,3		; Source Stride, Dest Stride
	dw	171		; y
	db	2,1		; Source Stride, Dest Stride
	dw	257		; y

:scale005e
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	11		; y
	db	4,3		; Source Stride, Dest Stride
	dw	174		; y
	db	2,1		; Source Stride, Dest Stride
	dw	261		; y

:scale005f
	db	0,0		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	173		; y
	db	2,1		; Source Stride, Dest Stride
	dw	260		; y

:scale0060
:scale0061
	db	0,0		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	171		; y
	db	2,1		; Source Stride, Dest Stride
	dw	257		; y

:scale0062
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	84		; y
	db	8,7		; Source Stride, Dest Stride
	dw	74		; y
	db	2,1		; Source Stride, Dest Stride
	dw	259		; y

:scale0063
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	83		; y
	db	8,7		; Source Stride, Dest Stride
	dw	73		; y
	db	2,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0064
:scale0065
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	41		; y
	db	4,3		; Source Stride, Dest Stride
	dw	154		; y
	db	4,3		; Source Stride, Dest Stride
	dw	116		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0066
	db	0,0		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	41		; y
	db	8,7		; Source Stride, Dest Stride
	dw	77		; y
	db	2,1		; Source Stride, Dest Stride
	dw	270		; y

:scale0067
	db	0,0		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	40		; y
	db	8,7		; Source Stride, Dest Stride
	dw	75		; y
	db	2,1		; Source Stride, Dest Stride
	dw	263		; y

:scale0068
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	40		; y
	db	8,7		; Source Stride, Dest Stride
	dw	75		; y
	db	2,1		; Source Stride, Dest Stride
	dw	263		; y

:scale0069
:scale006a
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	39		; y
	db	8,7		; Source Stride, Dest Stride
	dw	74		; y
	db	2,1		; Source Stride, Dest Stride
	dw	259		; y

:scale006b
	db	0,0		; Scale, Y
	db	3		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	153		; y
	db	4,3		; Source Stride, Dest Stride
	dw	115		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale006c
	db	0,0		; Scale, Y
	db	3		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	152		; y
	db	4,3		; Source Stride, Dest Stride
	dw	114		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale006d
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	19		; y
	db	8,7		; Source Stride, Dest Stride
	dw	74		; y
	db	2,1		; Source Stride, Dest Stride
	dw	259		; y

:scale006e
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	79		; y
	db	2,1		; Source Stride, Dest Stride
	dw	277		; y

:scale006f
:scale0070
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	74		; y
	db	2,1		; Source Stride, Dest Stride
	dw	259		; y

:scale0071
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	73		; y
	db	2,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0072
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	37		; y
	db	16,15		; Source Stride, Dest Stride
	dw	35		; y
	db	2,1		; Source Stride, Dest Stride
	dw	263		; y

:scale0073
:scale0074
:scale0075
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	18		; y
	db	16,15		; Source Stride, Dest Stride
	dw	35		; y
	db	2,1		; Source Stride, Dest Stride
	dw	263		; y

:scale0076
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	36		; y
	db	2,1		; Source Stride, Dest Stride
	dw	270		; y

:scale0077
:scale0078
:scale0079
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	35		; y
	db	2,1		; Source Stride, Dest Stride
	dw	263		; y

:scale007a
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	18		; y
	db	2,1		; Source Stride, Dest Stride
	dw	279		; y

:scale007b
:scale007c
:scale007d
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	17		; y
	db	2,1		; Source Stride, Dest Stride
	dw	264		; y

:scale007e
	db	0,0		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	9		; y
	db	2,1		; Source Stride, Dest Stride
	dw	284		; y

:scale007f
	db	0,0		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	5		; y
	db	2,1		; Source Stride, Dest Stride
	dw	318		; y

:scale0080
:scale0081
	db	0,0		; Scale, Y
	db	1		; Stages
	db	2,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0082
:scale0083
	db	0,0		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0084
:scale0085
	db	0,0		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y
	db	4,3		; Source Stride, Dest Stride
	dw	120		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0086
:scale0087
:scale0088
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0089
	db	0,0		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y
	db	4,3		; Source Stride, Dest Stride
	dw	124		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale008a
:scale008b
:scale008c
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	15		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale008d
:scale008e
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	4,3		; Source Stride, Dest Stride
	dw	126		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale008f
	db	0,0		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	115		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0090
:scale0091
	db	0,0		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	114		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0092
:scale0093
:scale0094
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0095
:scale0096
:scale0097
	db	0,0		; Scale, Y
	db	4		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	55		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	8,7		; Source Stride, Dest Stride
	dw	43		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0098
:scale0099
	db	0,0		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	14		; y
	db	16,15		; Source Stride, Dest Stride
	dw	28		; y
	db	8,7		; Source Stride, Dest Stride
	dw	53		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale009a
:scale009b
	db	0,0		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	16,15		; Source Stride, Dest Stride
	dw	28		; y
	db	8,7		; Source Stride, Dest Stride
	dw	53		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale009c
:scale009d
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	27		; y
	db	8,7		; Source Stride, Dest Stride
	dw	51		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale009e
:scale009f
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale00a0
	db	0,0		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	32,31		; Source Stride, Dest Stride
	dw	14		; y
	db	8,7		; Source Stride, Dest Stride
	dw	55		; y
	db	4,3		; Source Stride, Dest Stride
	dw	97		; y

:scale00a1
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	8,7		; Source Stride, Dest Stride
	dw	43		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale00a2
:scale00a3
:scale00a4
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	13		; y
	db	8,7		; Source Stride, Dest Stride
	dw	51		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale00a5
:scale00a6
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	4,3		; Source Stride, Dest Stride
	dw	98		; y

:scale00a7
:scale00a8
:scale00a9
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale00aa
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	25		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale00ab
:scale00ac
	db	0,0		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale00ad
:scale00ae
:scale00af
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale00b0
:scale00b1
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale00b2
	db	0,0		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale00b3
:scale00b4
:scale00b5
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale00b6
:scale00b7
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale00b8
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	8,7		; Source Stride, Dest Stride
	dw	44		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale00b9
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale00ba
:scale00bb
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale00bc
:scale00bd
	db	0,0		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale00be
	db	0,0		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	4,3		; Source Stride, Dest Stride
	dw	96		; y

:scale00bf
	db	0,0		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	4,3		; Source Stride, Dest Stride
	dw	128		; y

:scale00c0
:scale00c1
	db	0,0		; Scale, Y
	db	1		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale00c2
	db	0,0		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale00c3
:scale00c4
:scale00c5
	db	0,0		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale00c6
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale00c7
	db	0,0		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale00c8
:scale00c9
	db	0,0		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale00ca
:scale00cb
:scale00cc
	db	0,0		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	16,15		; Source Stride, Dest Stride
	dw	22		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale00cd
	db	0,0		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale00ce
:scale00cf
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale00d0
	db	0,0		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale00d1
:scale00d2
:scale00d3
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale00d4
	db	0,0		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale00d5
:scale00d6
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale00d7
	db	0,0		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	8,7		; Source Stride, Dest Stride
	dw	47		; y

:scale00d8
:scale00d9
:scale00da
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale00db
:scale00dc
:scale00dd
	db	0,0		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale00de
	db	0,0		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y

:scale00df
	db	0,0		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	8,7		; Source Stride, Dest Stride
	dw	64		; y

:scale00e0
	db	0,0		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale00e1
:scale00e2
	db	0,0		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale00e3
	db	0,0		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale00e4
:scale00e5
	db	0,0		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale00e6
	db	0,0		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale00e7
:scale00e8
:scale00e9
:scale00ea
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale00eb
:scale00ec
:scale00ed
	db	0,0		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale00ee
	db	0,0		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale00ef
	db	0,0		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale00f0
	db	0,0		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale00f1
	db	0,0		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale00f2
	db	0,0		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale00f3
:scale00f4
:scale00f5
	db	0,0		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale00f6
	db	0,0		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale00f7
	db	0,0		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale00f8
	db	0,0		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale00f9
	db	0,0		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale00fa
	db	0,0		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale00fb
	db	0,0		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale00fc
	db	0,0		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale00fd
	db	0,0		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale00fe
	db	0,0		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale00ff
	db	0,0		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0100
:scale0101
:scale0102
:scale0103
	db	2,256		; Scale, Y
	db	1		; Stages
	db	2,1		; Source Stride, Dest Stride
	dw	256		; y

:scale0104
	db	2,252		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0105
	db	2,251		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0106
	db	2,250		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0107
	db	2,249		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0108
	db	2,248		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y
	db	4,3		; Source Stride, Dest Stride
	dw	120		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0109
	db	2,247		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y
	db	4,3		; Source Stride, Dest Stride
	dw	120		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale010a
	db	2,246		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y
	db	4,3		; Source Stride, Dest Stride
	dw	120		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale010b
	db	2,245		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y
	db	4,3		; Source Stride, Dest Stride
	dw	120		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale010c
	db	2,244		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale010d
	db	2,243		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale010e
	db	2,242		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale010f
:scale0110
:scale0111
	db	2,241		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	31		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0112
	db	2,239		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y
	db	4,3		; Source Stride, Dest Stride
	dw	124		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0113
	db	2,238		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y
	db	4,3		; Source Stride, Dest Stride
	dw	124		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0114
	db	2,237		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	15		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0115
	db	2,236		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	15		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0116
	db	2,235		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	15		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0117
:scale0118
	db	2,234		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	15		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale0119
	db	2,233		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	15		; y
	db	4,3		; Source Stride, Dest Stride
	dw	117		; y
	db	4,3		; Source Stride, Dest Stride
	dw	88		; y

:scale011a
	db	2,232		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	4,3		; Source Stride, Dest Stride
	dw	126		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale011b
	db	2,231		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	4,3		; Source Stride, Dest Stride
	dw	126		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale011c
	db	2,230		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	4,3		; Source Stride, Dest Stride
	dw	126		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale011d
	db	2,229		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y
	db	4,3		; Source Stride, Dest Stride
	dw	126		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale011e
	db	2,229		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	115		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale011f
	db	2,228		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	114		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0120
:scale0121
:scale0122
:scale0123
	db	2,227		; Scale, Y
	db	2		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	114		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0124
	db	2,224		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0125
	db	2,223		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0126
:scale0127
	db	2,222		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0128
	db	2,221		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0129
	db	2,220		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	55		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale012a
:scale012b
	db	2,219		; Scale, Y
	db	4		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	55		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	8,7		; Source Stride, Dest Stride
	dw	43		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale012c
	db	2,218		; Scale, Y
	db	4		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	55		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	8,7		; Source Stride, Dest Stride
	dw	43		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale012d
:scale012e
	db	2,217		; Scale, Y
	db	4		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	55		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	8,7		; Source Stride, Dest Stride
	dw	43		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale012f
	db	2,216		; Scale, Y
	db	4		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	54		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0130
	db	2,215		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	14		; y
	db	16,15		; Source Stride, Dest Stride
	dw	28		; y
	db	8,7		; Source Stride, Dest Stride
	dw	53		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0131
:scale0132
	db	2,214		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	14		; y
	db	16,15		; Source Stride, Dest Stride
	dw	28		; y
	db	8,7		; Source Stride, Dest Stride
	dw	53		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0133
	db	2,213		; Scale, Y
	db	4		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	14		; y
	db	16,15		; Source Stride, Dest Stride
	dw	28		; y
	db	8,7		; Source Stride, Dest Stride
	dw	53		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0134
:scale0135
	db	2,212		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	16,15		; Source Stride, Dest Stride
	dw	28		; y
	db	8,7		; Source Stride, Dest Stride
	dw	53		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0136
	db	2,211		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	16,15		; Source Stride, Dest Stride
	dw	28		; y
	db	8,7		; Source Stride, Dest Stride
	dw	53		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0137
	db	2,210		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	16,15		; Source Stride, Dest Stride
	dw	28		; y
	db	8,7		; Source Stride, Dest Stride
	dw	53		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0138
	db	2,210		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	27		; y
	db	8,7		; Source Stride, Dest Stride
	dw	51		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0139
	db	2,209		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	27		; y
	db	8,7		; Source Stride, Dest Stride
	dw	51		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale013a
:scale013b
	db	2,208		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale013c
	db	2,207		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale013d
:scale013e
	db	2,206		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale013f
	db	2,205		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0140
:scale0141
	db	2,204		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	32,31		; Source Stride, Dest Stride
	dw	14		; y
	db	8,7		; Source Stride, Dest Stride
	dw	55		; y
	db	4,3		; Source Stride, Dest Stride
	dw	97		; y

:scale0142
	db	2,203		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	8,7		; Source Stride, Dest Stride
	dw	43		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0143
	db	2,202		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	26		; y
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	8,7		; Source Stride, Dest Stride
	dw	43		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0144
	db	2,202		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	13		; y
	db	8,7		; Source Stride, Dest Stride
	dw	51		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0145
:scale0146
	db	2,201		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	13		; y
	db	8,7		; Source Stride, Dest Stride
	dw	51		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0147
	db	2,200		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	13		; y
	db	8,7		; Source Stride, Dest Stride
	dw	51		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0148
:scale0149
	db	2,199		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	13		; y
	db	8,7		; Source Stride, Dest Stride
	dw	51		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale014a
	db	2,198		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	4,3		; Source Stride, Dest Stride
	dw	98		; y

:scale014b
:scale014c
	db	2,197		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	4,3		; Source Stride, Dest Stride
	dw	98		; y

:scale014d
	db	2,196		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	7		; y
	db	8,7		; Source Stride, Dest Stride
	dw	56		; y
	db	4,3		; Source Stride, Dest Stride
	dw	98		; y

:scale014e
	db	2,196		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale014f
:scale0150
	db	2,195		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0151
	db	2,194		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0152
:scale0153
	db	2,193		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	49		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0154
:scale0155
	db	2,192		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0156
:scale0157
	db	2,191		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0158
	db	2,190		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0159
	db	2,189		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale015a
	db	2,189		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale015b
:scale015c
	db	2,188		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale015d
:scale015e
	db	2,187		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale015f
	db	2,186		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0160
	db	2,186		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0161
:scale0162
	db	2,185		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0163
	db	2,184		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0164
	db	2,184		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0165
	db	2,183		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0166
	db	2,183		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0167
:scale0168
	db	2,182		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0169
:scale016a
	db	2,181		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale016b
	db	2,180		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale016c
	db	2,180		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale016d
:scale016e
	db	2,179		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale016f
	db	2,178		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0170
	db	2,178		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	8,7		; Source Stride, Dest Stride
	dw	44		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0171
	db	2,177		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	8,7		; Source Stride, Dest Stride
	dw	44		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0172
	db	2,177		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0173
:scale0174
	db	2,176		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0175
:scale0176
	db	2,175		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0177
	db	2,174		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0178
	db	2,174		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale0179
:scale017a
	db	2,173		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale017b
	db	2,172		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale017c
:scale017d
	db	2,172		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	4,3		; Source Stride, Dest Stride
	dw	96		; y

:scale017e
:scale017f
	db	2,171		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	4,3		; Source Stride, Dest Stride
	dw	128		; y

:scale0180
:scale0181
:scale0182
:scale0183
	db	2,171		; Scale, Y
	db	1		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0184
:scale0185
	db	2,168		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale0186
	db	2,168		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0187
:scale0188
	db	2,167		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0189
:scale018a
	db	2,166		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale018b
	db	2,165		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale018c
:scale018d
	db	2,165		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale018e
:scale018f
	db	2,164		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0190
:scale0191
:scale0192
	db	2,163		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0193
	db	2,162		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0194
	db	2,162		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	16,15		; Source Stride, Dest Stride
	dw	22		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale0195
:scale0196
:scale0197
	db	2,161		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	16,15		; Source Stride, Dest Stride
	dw	22		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale0198
:scale0199
	db	2,160		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale019a
:scale019b
	db	2,159		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale019c
	db	2,159		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale019d
:scale019e
	db	2,158		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale019f
	db	2,157		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale01a0
:scale01a1
	db	2,157		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale01a2
:scale01a3
:scale01a4
	db	2,156		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale01a5
:scale01a6
	db	2,155		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale01a7
	db	2,154		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale01a8
:scale01a9
	db	2,154		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale01aa
:scale01ab
:scale01ac
	db	2,153		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale01ad
	db	2,152		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale01ae
:scale01af
	db	2,152		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	8,7		; Source Stride, Dest Stride
	dw	47		; y

:scale01b0
:scale01b1
:scale01b2
	db	2,151		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale01b3
:scale01b4
	db	2,150		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale01b5
	db	2,149		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale01b6
:scale01b7
	db	2,149		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale01b8
:scale01b9
:scale01ba
	db	2,148		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale01bb
	db	2,147		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale01bc
:scale01bd
	db	2,147		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y

:scale01be
:scale01bf
	db	2,146		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	8,7		; Source Stride, Dest Stride
	dw	64		; y

:scale01c0
	db	2,146		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale01c1
	db	2,145		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale01c2
:scale01c3
:scale01c4
:scale01c5
	db	2,145		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale01c6
:scale01c7
	db	2,144		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale01c8
:scale01c9
:scale01ca
	db	2,143		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale01cb
	db	2,142		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale01cc
:scale01cd
	db	2,142		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale01ce
:scale01cf
:scale01d0
	db	2,141		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale01d1
:scale01d2
:scale01d3
:scale01d4
	db	2,140		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale01d5
	db	2,139		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale01d6
:scale01d7
	db	2,139		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale01d8
:scale01d9
:scale01da
	db	2,138		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale01db
	db	2,137		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale01dc
:scale01dd
	db	2,137		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale01de
	db	2,137		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale01df
	db	2,136		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale01e0
:scale01e1
	db	2,137		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale01e2
:scale01e3
	db	2,135		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale01e4
:scale01e5
	db	2,135		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale01e6
:scale01e7
:scale01e8
:scale01e9
	db	2,134		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale01ea
:scale01eb
	db	2,133		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale01ec
	db	2,133		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale01ed
	db	2,132		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale01ee
:scale01ef
	db	2,132		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale01f0
	db	2,132		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale01f1
	db	2,131		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale01f2
:scale01f3
	db	2,131		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale01f4
	db	2,131		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale01f5
	db	2,130		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale01f6
:scale01f7
	db	2,130		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale01f8
	db	2,130		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale01f9
	db	2,129		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale01fa
:scale01fb
	db	2,129		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale01fc
:scale01fd
	db	2,129		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale01fe
:scale01ff
	db	2,129		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0200
	db	3,128		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0201
:scale0202
:scale0203
:scale0204
	db	3,127		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0205
:scale0206
	db	3,126		; Scale, Y
	db	3		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0207
:scale0208
	db	3,126		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0209
:scale020a
:scale020b
:scale020c
	db	3,125		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale020d
:scale020e
:scale020f
	db	3,124		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0210
	db	3,124		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0211
:scale0212
:scale0213
:scale0214
	db	3,123		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0215
	db	3,122		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0216
:scale0217
:scale0218
	db	3,122		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	4,3		; Source Stride, Dest Stride
	dw	90		; y

:scale0219
	db	3,122		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale021a
:scale021b
:scale021c
:scale021d
	db	3,121		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale021e
:scale021f
:scale0220
:scale0221
	db	3,120		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	4,3		; Source Stride, Dest Stride
	dw	87		; y

:scale0222
	db	3,120		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0223
:scale0224
:scale0225
:scale0226
	db	3,119		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0227
	db	3,118		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale0228
:scale0229
:scale022a
	db	3,118		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	23		; y
	db	8,7		; Source Stride, Dest Stride
	dw	44		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale022b
	db	3,118		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	4,3		; Source Stride, Dest Stride
	dw	93		; y

:scale022c
:scale022d
:scale022e
:scale022f
:scale0230
	db	3,117		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0231
:scale0232
:scale0233
	db	3,116		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0234
	db	3,116		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale0235
:scale0236
:scale0237
:scale0238
:scale0239
	db	3,115		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	4,3		; Source Stride, Dest Stride
	dw	95		; y

:scale023a
:scale023b
:scale023c
	db	3,114		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	4,3		; Source Stride, Dest Stride
	dw	96		; y

:scale023d
:scale023e
	db	3,114		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	4,3		; Source Stride, Dest Stride
	dw	128		; y

:scale023f
	db	3,113		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	4,3		; Source Stride, Dest Stride
	dw	128		; y

:scale0240
:scale0241
:scale0242
:scale0243
:scale0244
:scale0245
	db	3,114		; Scale, Y
	db	1		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0246
:scale0247
:scale0248
	db	3,112		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale0249
	db	3,112		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale024a
:scale024b
:scale024c
:scale024d
:scale024e
	db	3,111		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale024f
:scale0250
:scale0251
	db	3,110		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0252
:scale0253
	db	3,110		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0254
	db	3,109		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0255
:scale0256
:scale0257
	db	3,109		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0258
:scale0259
	db	3,109		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale025a
:scale025b
:scale025c
:scale025d
	db	3,108		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale025e
	db	3,108		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	16,15		; Source Stride, Dest Stride
	dw	22		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale025f
:scale0260
:scale0261
:scale0262
:scale0263
:scale0264
	db	3,107		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	16,15		; Source Stride, Dest Stride
	dw	22		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale0265
:scale0266
	db	3,106		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0267
:scale0268
:scale0269
	db	3,106		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale026a
	db	3,106		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale026b
:scale026c
:scale026d
:scale026e
:scale026f
	db	3,105		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0270
	db	3,105		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0271
:scale0272
	db	3,104		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0273
:scale0274
:scale0275
:scale0276
	db	3,104		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0277
:scale0278
:scale0279
:scale027a
:scale027b
	db	3,103		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale027c
	db	3,103		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale027d
:scale027e
	db	3,102		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale027f
:scale0280
:scale0281
:scale0282
	db	3,102		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0283
:scale0284
	db	3,101		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0285
:scale0286
:scale0287
	db	3,101		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	8,7		; Source Stride, Dest Stride
	dw	47		; y

:scale0288
	db	3,101		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0289
:scale028a
:scale028b
:scale028c
:scale028d
:scale028e
:scale028f
	db	3,100		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0290
	db	3,99		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0291
:scale0292
:scale0293
:scale0294
:scale0295
	db	3,99		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale0296
:scale0297
:scale0298
:scale0299
	db	3,98		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale029a
:scale029b
:scale029c
	db	3,98		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y

:scale029d
:scale029e
:scale029f
	db	3,97		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	8,7		; Source Stride, Dest Stride
	dw	64		; y

:scale02a0
:scale02a1
:scale02a2
	db	3,97		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale02a3
:scale02a4
:scale02a5
:scale02a6
:scale02a7
:scale02a8
	db	3,97		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale02a9
:scale02aa
	db	3,96		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale02ab
	db	3,95		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale02ac
:scale02ad
:scale02ae
:scale02af
:scale02b0
:scale02b1
	db	3,95		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale02b2
:scale02b3
:scale02b4
	db	3,94		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale02b5
:scale02b6
:scale02b7
:scale02b8
:scale02b9
	db	3,94		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale02ba
:scale02bb
:scale02bc
:scale02bd
:scale02be
:scale02bf
:scale02c0
	db	3,93		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale02c1
:scale02c2
:scale02c3
:scale02c4
:scale02c5
:scale02c6
:scale02c7
:scale02c8
	db	3,92		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale02c9
	db	3,91		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale02ca
:scale02cb
:scale02cc
	db	3,91		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale02cd
:scale02ce
:scale02cf
	db	3,91		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale02d0
:scale02d1
:scale02d2
	db	3,91		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale02d3
:scale02d4
:scale02d5
	db	3,90		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale02d6
:scale02d7
:scale02d8
	db	3,90		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale02d9
:scale02da
:scale02db
:scale02dc
:scale02dd
:scale02de
:scale02df
:scale02e0
	db	3,89		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale02e1
	db	3,88		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale02e2
:scale02e3
:scale02e4
	db	3,88		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale02e5
:scale02e6
:scale02e7
	db	3,88		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale02e8
	db	3,88		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale02e9
:scale02ea
	db	3,87		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale02eb
:scale02ec
:scale02ed
	db	3,87		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale02ee
:scale02ef
:scale02f0
	db	3,87		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale02f1
	db	3,87		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale02f2
:scale02f3
	db	3,86		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale02f4
:scale02f5
:scale02f6
	db	3,86		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale02f7
:scale02f8
:scale02f9
	db	3,86		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale02fa
:scale02fb
:scale02fc
	db	3,86		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale02fd
:scale02fe
:scale02ff
	db	3,86		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0300
:scale0301
:scale0302
:scale0303
:scale0304
:scale0305
:scale0306
:scale0307
	db	4,86		; Scale, Y
	db	1		; Stages
	db	4,3		; Source Stride, Dest Stride
	dw	86		; y

:scale0308
:scale0309
:scale030a
:scale030b
	db	4,84		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale030c
	db	4,84		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale030d
:scale030e
:scale030f
:scale0310
:scale0311
:scale0312
:scale0313
:scale0314
:scale0315
:scale0316
:scale0317
	db	4,83		; Scale, Y
	db	2		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0318
:scale0319
:scale031a
:scale031b
	db	4,82		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale031c
:scale031d
:scale031e
:scale031f
	db	4,82		; Scale, Y
	db	4		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	21		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0320
:scale0321
:scale0322
:scale0323
:scale0324
:scale0325
:scale0326
:scale0327
	db	4,81		; Scale, Y
	db	4		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0328
:scale0329
	db	4,81		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	11		; y
	db	16,15		; Source Stride, Dest Stride
	dw	22		; y
	db	8,7		; Source Stride, Dest Stride
	dw	42		; y

:scale032a
:scale032b
:scale032c
:scale032d
:scale032e
:scale032f
:scale0330
:scale0331
:scale0332
:scale0333
	db	4,80		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0334
:scale0335
:scale0336
:scale0337
	db	4,79		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0338
:scale0339
:scale033a
:scale033b
:scale033c
:scale033d
	db	4,79		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale033e
:scale033f
	db	4,78		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0340
:scale0341
:scale0342
:scale0343
	db	4,78		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0344
:scale0345
:scale0346
:scale0347
:scale0348
	db	4,78		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0349
:scale034a
:scale034b
:scale034c
:scale034d
:scale034e
:scale034f
	db	4,77		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0350
:scale0351
:scale0352
:scale0353
	db	4,77		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0354
:scale0355
:scale0356
:scale0357
:scale0358
:scale0359
:scale035a
:scale035b
	db	4,76		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale035c
:scale035d
:scale035e
	db	4,76		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	8,7		; Source Stride, Dest Stride
	dw	47		; y

:scale035f
	db	4,75		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	8,7		; Source Stride, Dest Stride
	dw	47		; y

:scale0360
:scale0361
:scale0362
:scale0363
:scale0364
:scale0365
:scale0366
:scale0367
:scale0368
:scale0369
	db	4,75		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale036a
:scale036b
	db	4,74		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale036c
:scale036d
:scale036e
:scale036f
:scale0370
:scale0371
:scale0372
:scale0373
:scale0374
:scale0375
	db	4,74		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale0376
:scale0377
	db	4,73		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale0378
:scale0379
:scale037a
:scale037b
	db	4,73		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y

:scale037c
:scale037d
:scale037e
:scale037f
	db	4,73		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	8,7		; Source Stride, Dest Stride
	dw	64		; y

:scale0380
:scale0381
:scale0382
:scale0383
	db	4,73		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0384
:scale0385
:scale0386
:scale0387
:scale0388
:scale0389
:scale038a
:scale038b
	db	4,73		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale038c
:scale038d
:scale038e
	db	4,72		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale038f
	db	4,71		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0390
:scale0391
:scale0392
:scale0393
:scale0394
:scale0395
:scale0396
:scale0397
	db	4,71		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0398
:scale0399
:scale039a
:scale039b
	db	4,71		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale039c
:scale039d
:scale039e
:scale039f
:scale03a0
:scale03a1
:scale03a2
:scale03a3
:scale03a4
:scale03a5
:scale03a6
:scale03a7
:scale03a8
	db	4,70		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale03a9
:scale03aa
:scale03ab
	db	4,69		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale03ac
:scale03ad
:scale03ae
:scale03af
:scale03b0
:scale03b1
:scale03b2
:scale03b3
:scale03b4
:scale03b5
	db	4,69		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale03b6
:scale03b7
	db	4,68		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale03b8
:scale03b9
:scale03ba
:scale03bb
	db	4,68		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale03bc
:scale03bd
:scale03be
:scale03bf
	db	4,68		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale03c0
:scale03c1
:scale03c2
:scale03c3
	db	4,69		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale03c4
:scale03c5
:scale03c6
:scale03c7
	db	4,67		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale03c8
:scale03c9
:scale03ca
:scale03cb
	db	4,67		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale03cc
:scale03cd
:scale03ce
:scale03cf
:scale03d0
:scale03d1
:scale03d2
	db	4,67		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale03d3
:scale03d4
:scale03d5
:scale03d6
:scale03d7
	db	4,66		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale03d8
:scale03d9
:scale03da
:scale03db
	db	4,66		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale03dc
:scale03dd
:scale03de
:scale03df
	db	4,66		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale03e0
	db	4,66		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale03e1
:scale03e2
:scale03e3
	db	4,65		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale03e4
:scale03e5
:scale03e6
:scale03e7
	db	4,65		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale03e8
:scale03e9
:scale03ea
:scale03eb
	db	4,65		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale03ec
:scale03ed
:scale03ee
:scale03ef
	db	4,65		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale03f0
:scale03f1
:scale03f2
:scale03f3
	db	4,65		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale03f4
:scale03f5
:scale03f6
:scale03f7
	db	4,65		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale03f8
:scale03f9
:scale03fa
:scale03fb
	db	4,65		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale03fc
:scale03fd
:scale03fe
:scale03ff
	db	4,65		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0400
	db	5,64		; Scale, Y
	db	3		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0401
:scale0402
:scale0403
:scale0404
:scale0405
	db	5,63		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0406
:scale0407
:scale0408
:scale0409
:scale040a
:scale040b
:scale040c
:scale040d
:scale040e
:scale040f
	db	5,63		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0410
	db	5,63		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0411
:scale0412
:scale0413
:scale0414
	db	5,62		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y
	db	8,7		; Source Stride, Dest Stride
	dw	45		; y

:scale0415
:scale0416
:scale0417
:scale0418
:scale0419
:scale041a
:scale041b
:scale041c
:scale041d
:scale041e
:scale041f
:scale0420
:scale0421
	db	5,62		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0422
:scale0423
	db	5,61		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	8,7		; Source Stride, Dest Stride
	dw	38		; y

:scale0424
:scale0425
:scale0426
:scale0427
:scale0428
	db	5,61		; Scale, Y
	db	3		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0429
:scale042a
:scale042b
:scale042c
:scale042d
:scale042e
:scale042f
:scale0430
:scale0431
:scale0432
	db	5,61		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0433
:scale0434
:scale0435
:scale0436
:scale0437
	db	5,60		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	8,7		; Source Stride, Dest Stride
	dw	47		; y

:scale0438
:scale0439
:scale043a
:scale043b
:scale043c
:scale043d
:scale043e
:scale043f
:scale0440
:scale0441
:scale0442
:scale0443
:scale0444
	db	5,60		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0445
:scale0446
	db	5,59		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0447
:scale0448
:scale0449
:scale044a
:scale044b
:scale044c
:scale044d
:scale044e
:scale044f
:scale0450
:scale0451
:scale0452
:scale0453
:scale0454
:scale0455
	db	5,59		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale0456
	db	5,59		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y

:scale0457
:scale0458
:scale0459
:scale045a
	db	5,58		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y

:scale045b
:scale045c
:scale045d
:scale045e
:scale045f
	db	5,58		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	8,7		; Source Stride, Dest Stride
	dw	64		; y

:scale0460
:scale0461
:scale0462
:scale0463
:scale0464
	db	5,58		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0465
:scale0466
:scale0467
:scale0468
:scale0469
:scale046a
:scale046b
:scale046c
:scale046d
:scale046e
	db	5,58		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale046f
:scale0470
:scale0471
:scale0472
:scale0473
	db	5,57		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0474
:scale0475
:scale0476
:scale0477
:scale0478
:scale0479
:scale047a
:scale047b
:scale047c
:scale047d
	db	5,57		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale047e
:scale047f
:scale0480
:scale0481
:scale0482
	db	5,56		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0483
:scale0484
:scale0485
:scale0486
:scale0487
:scale0488
:scale0489
:scale048a
:scale048b
:scale048c
:scale048d
:scale048e
:scale048f
:scale0490
:scale0491
:scale0492
	db	5,56		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0493
:scale0494
:scale0495
:scale0496
	db	5,55		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0497
:scale0498
:scale0499
:scale049a
:scale049b
:scale049c
:scale049d
:scale049e
:scale049f
:scale04a0
:scale04a1
:scale04a2
:scale04a3
:scale04a4
:scale04a5
	db	5,55		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale04a6
:scale04a7
	db	5,55		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale04a8
:scale04a9
:scale04aa
	db	5,54		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale04ab
:scale04ac
:scale04ad
:scale04ae
:scale04af
	db	5,54		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale04b0
:scale04b1
:scale04b2
:scale04b3
:scale04b4
	db	5,55		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale04b5
:scale04b6
:scale04b7
:scale04b8
:scale04b9
	db	5,54		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale04ba
:scale04bb
:scale04bc
:scale04bd
	db	5,54		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale04be
	db	5,53		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale04bf
:scale04c0
:scale04c1
:scale04c2
:scale04c3
:scale04c4
:scale04c5
:scale04c6
:scale04c7
:scale04c8
:scale04c9
:scale04ca
:scale04cb
:scale04cc
:scale04cd
	db	5,53		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale04ce
:scale04cf
:scale04d0
:scale04d1
:scale04d2
	db	5,53		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale04d3
:scale04d4
	db	5,53		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale04d5
:scale04d6
:scale04d7
	db	5,52		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale04d8
:scale04d9
:scale04da
:scale04db
:scale04dc
	db	5,52		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale04dd
:scale04de
:scale04df
:scale04e0
:scale04e1
	db	5,52		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale04e2
:scale04e3
:scale04e4
:scale04e5
:scale04e6
	db	5,52		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale04e7
:scale04e8
:scale04e9
:scale04ea
:scale04eb
	db	5,52		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale04ec
:scale04ed
:scale04ee
:scale04ef
:scale04f0
	db	5,52		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale04f1
:scale04f2
:scale04f3
:scale04f4
:scale04f5
	db	5,52		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale04f6
:scale04f7
:scale04f8
:scale04f9
:scale04fa
	db	5,52		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale04fb
:scale04fc
:scale04fd
:scale04fe
:scale04ff
	db	5,52		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0500
:scale0501
:scale0502
:scale0503
:scale0504
:scale0505
	db	6,51		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0506
:scale0507
:scale0508
:scale0509
	db	6,50		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale050a
:scale050b
:scale050c
:scale050d
:scale050e
:scale050f
	db	6,50		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	8,7		; Source Stride, Dest Stride
	dw	47		; y

:scale0510
:scale0511
:scale0512
:scale0513
:scale0514
:scale0515
:scale0516
:scale0517
:scale0518
:scale0519
:scale051a
:scale051b
:scale051c
:scale051d
:scale051e
	db	6,50		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale051f
:scale0520
:scale0521
	db	6,49		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	8,7		; Source Stride, Dest Stride
	dw	39		; y

:scale0522
:scale0523
:scale0524
:scale0525
:scale0526
:scale0527
:scale0528
:scale0529
:scale052a
:scale052b
:scale052c
:scale052d
:scale052e
:scale052f
:scale0530
:scale0531
:scale0532
:scale0533
	db	6,49		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale0534
:scale0535
:scale0536
:scale0537
:scale0538
:scale0539
	db	6,49		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y

:scale053a
:scale053b
:scale053c
:scale053d
:scale053e
:scale053f
	db	6,48		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	8,7		; Source Stride, Dest Stride
	dw	64		; y

:scale0540
:scale0541
:scale0542
:scale0543
:scale0544
:scale0545
	db	6,49		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0546
:scale0547
:scale0548
:scale0549
:scale054a
:scale054b
:scale054c
:scale054d
:scale054e
:scale054f
:scale0550
:scale0551
	db	6,49		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0552
:scale0553
:scale0554
:scale0555
	db	6,48		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0556
:scale0557
	db	6,47		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0558
:scale0559
:scale055a
:scale055b
:scale055c
:scale055d
:scale055e
:scale055f
:scale0560
:scale0561
:scale0562
:scale0563
	db	6,47		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0564
:scale0565
:scale0566
:scale0567
:scale0568
:scale0569
	db	6,47		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale056a
:scale056b
:scale056c
:scale056d
:scale056e
:scale056f
:scale0570
:scale0571
:scale0572
	db	6,47		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0573
:scale0574
:scale0575
:scale0576
:scale0577
:scale0578
:scale0579
:scale057a
:scale057b
:scale057c
:scale057d
:scale057e
:scale057f
:scale0580
:scale0581
	db	6,46		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0582
:scale0583
:scale0584
:scale0585
:scale0586
:scale0587
:scale0588
:scale0589
:scale058a
:scale058b
:scale058c
:scale058d
:scale058e
:scale058f
:scale0590
	db	6,46		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0591
:scale0592
:scale0593
	db	6,45		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0594
:scale0595
:scale0596
:scale0597
:scale0598
:scale0599
	db	6,45		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale059a
:scale059b
:scale059c
:scale059d
:scale059e
:scale059f
	db	6,45		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale05a0
:scale05a1
:scale05a2
:scale05a3
:scale05a4
:scale05a5
	db	6,46		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale05a6
:scale05a7
:scale05a8
:scale05a9
:scale05aa
:scale05ab
	db	6,45		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale05ac
:scale05ad
:scale05ae
:scale05af
:scale05b0
	db	6,45		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale05b1
	db	6,44		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale05b2
:scale05b3
:scale05b4
:scale05b5
:scale05b6
:scale05b7
:scale05b8
:scale05b9
:scale05ba
:scale05bb
:scale05bc
:scale05bd
:scale05be
:scale05bf
:scale05c0
:scale05c1
:scale05c2
:scale05c3
	db	6,44		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale05c4
:scale05c5
:scale05c6
:scale05c7
:scale05c8
:scale05c9
	db	6,44		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale05ca
:scale05cb
:scale05cc
:scale05cd
:scale05ce
:scale05cf
	db	6,44		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale05d0
:scale05d1
	db	6,44		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale05d2
:scale05d3
:scale05d4
:scale05d5
	db	6,43		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale05d6
:scale05d7
:scale05d8
:scale05d9
:scale05da
:scale05db
	db	6,43		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale05dc
:scale05dd
:scale05de
:scale05df
:scale05e0
:scale05e1
	db	6,43		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale05e2
:scale05e3
:scale05e4
:scale05e5
:scale05e6
:scale05e7
	db	6,43		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale05e8
:scale05e9
:scale05ea
:scale05eb
:scale05ec
:scale05ed
	db	6,43		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale05ee
:scale05ef
:scale05f0
:scale05f1
:scale05f2
:scale05f3
	db	6,43		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale05f4
:scale05f5
:scale05f6
:scale05f7
:scale05f8
:scale05f9
	db	6,43		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale05fa
:scale05fb
:scale05fc
:scale05fd
:scale05fe
:scale05ff
	db	6,43		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0600
:scale0601
:scale0602
:scale0603
:scale0604
:scale0605
:scale0606
:scale0607
:scale0608
:scale0609
:scale060a
:scale060b
:scale060c
:scale060d
:scale060e
:scale060f
:scale0610
:scale0611
	db	7,42		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	8,7		; Source Stride, Dest Stride
	dw	40		; y

:scale0612
:scale0613
:scale0614
:scale0615
:scale0616
:scale0617
:scale0618
	db	7,42		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	8,7		; Source Stride, Dest Stride
	dw	48		; y

:scale0619
:scale061a
:scale061b
:scale061c
:scale061d
:scale061e
:scale061f
	db	7,41		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	8,7		; Source Stride, Dest Stride
	dw	64		; y

:scale0620
:scale0621
:scale0622
:scale0623
:scale0624
:scale0625
:scale0626
	db	7,42		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0627
:scale0628
:scale0629
:scale062a
:scale062b
:scale062c
:scale062d
:scale062e
:scale062f
:scale0630
:scale0631
:scale0632
:scale0633
:scale0634
	db	7,42		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0635
:scale0636
:scale0637
:scale0638
:scale0639
:scale063a
:scale063b
	db	7,41		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale063c
:scale063d
:scale063e
	db	7,41		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale063f
:scale0640
:scale0641
:scale0642
:scale0643
:scale0644
:scale0645
:scale0646
:scale0647
:scale0648
:scale0649
	db	7,40		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale064a
:scale064b
:scale064c
:scale064d
:scale064e
:scale064f
:scale0650
	db	7,40		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0651
:scale0652
:scale0653
:scale0654
:scale0655
:scale0656
:scale0657
:scale0658
:scale0659
:scale065a
:scale065b
:scale065c
:scale065d
:scale065e
:scale065f
:scale0660
:scale0661
:scale0662
:scale0663
:scale0664
:scale0665
:scale0666
	db	7,40		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0667
:scale0668
:scale0669
:scale066a
:scale066b
:scale066c
	db	7,39		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale066d
:scale066e
:scale066f
:scale0670
:scale0671
:scale0672
:scale0673
:scale0674
:scale0675
:scale0676
:scale0677
:scale0678
:scale0679
:scale067a
:scale067b
:scale067c
:scale067d
:scale067e
:scale067f
:scale0680
:scale0681
	db	7,39		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0682
:scale0683
:scale0684
:scale0685
:scale0686
:scale0687
:scale0688
	db	7,39		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0689
:scale068a
:scale068b
:scale068c
:scale068d
:scale068e
:scale068f
	db	7,39		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0690
:scale0691
:scale0692
:scale0693
:scale0694
:scale0695
:scale0696
	db	7,39		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0697
:scale0698
:scale0699
:scale069a
:scale069b
:scale069c
:scale069d
	db	7,38		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale069e
:scale069f
:scale06a0
:scale06a1
:scale06a2
:scale06a3
:scale06a4
	db	7,38		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale06a5
:scale06a6
:scale06a7
:scale06a8
:scale06a9
:scale06aa
:scale06ab
:scale06ac
:scale06ad
:scale06ae
:scale06af
:scale06b0
:scale06b1
:scale06b2
:scale06b3
:scale06b4
:scale06b5
:scale06b6
:scale06b7
:scale06b8
:scale06b9
	db	7,38		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale06ba
:scale06bb
:scale06bc
	db	7,38		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale06bd
:scale06be
:scale06bf
:scale06c0
	db	7,37		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale06c1
:scale06c2
:scale06c3
:scale06c4
:scale06c5
:scale06c6
:scale06c7
	db	7,37		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale06c8
:scale06c9
:scale06ca
:scale06cb
:scale06cc
:scale06cd
:scale06ce
	db	7,37		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale06cf
:scale06d0
:scale06d1
:scale06d2
:scale06d3
:scale06d4
:scale06d5
	db	7,37		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale06d6
:scale06d7
:scale06d8
:scale06d9
:scale06da
:scale06db
:scale06dc
	db	7,37		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale06dd
:scale06de
:scale06df
:scale06e0
:scale06e1
:scale06e2
:scale06e3
	db	7,37		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale06e4
:scale06e5
:scale06e6
:scale06e7
:scale06e8
:scale06e9
:scale06ea
	db	7,37		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale06eb
:scale06ec
:scale06ed
:scale06ee
:scale06ef
:scale06f0
:scale06f1
	db	7,37		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale06f2
:scale06f3
:scale06f4
:scale06f5
:scale06f6
:scale06f7
:scale06f8
	db	7,37		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale06f9
:scale06fa
:scale06fb
:scale06fc
:scale06fd
:scale06fe
:scale06ff
	db	7,37		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0700
:scale0701
:scale0702
:scale0703
:scale0704
:scale0705
:scale0706
:scale0707
	db	8,37		; Scale, Y
	db	1		; Stages
	db	8,7		; Source Stride, Dest Stride
	dw	37		; y

:scale0708
:scale0709
:scale070a
:scale070b
:scale070c
:scale070d
:scale070e
:scale070f
:scale0710
:scale0711
:scale0712
:scale0713
:scale0714
:scale0715
:scale0716
:scale0717
	db	8,37		; Scale, Y
	db	2		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0718
:scale0719
:scale071a
:scale071b
:scale071c
	db	8,36		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale071d
:scale071e
:scale071f
	db	8,35		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0720
:scale0721
:scale0722
:scale0723
:scale0724
:scale0725
:scale0726
:scale0727
:scale0728
:scale0729
:scale072a
:scale072b
:scale072c
:scale072d
:scale072e
:scale072f
	db	8,35		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0730
:scale0731
:scale0732
:scale0733
:scale0734
:scale0735
:scale0736
:scale0737
	db	8,35		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0738
:scale0739
:scale073a
:scale073b
:scale073c
:scale073d
:scale073e
:scale073f
:scale0740
:scale0741
:scale0742
:scale0743
:scale0744
:scale0745
:scale0746
:scale0747
:scale0748
:scale0749
:scale074a
:scale074b
:scale074c
:scale074d
:scale074e
:scale074f
:scale0750
	db	8,35		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0751
:scale0752
:scale0753
:scale0754
:scale0755
:scale0756
:scale0757
	db	8,34		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0758
:scale0759
:scale075a
:scale075b
:scale075c
:scale075d
:scale075e
:scale075f
:scale0760
:scale0761
:scale0762
:scale0763
:scale0764
:scale0765
:scale0766
:scale0767
:scale0768
:scale0769
:scale076a
:scale076b
:scale076c
:scale076d
:scale076e
:scale076f
	db	8,34		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0770
:scale0771
:scale0772
:scale0773
:scale0774
:scale0775
:scale0776
:scale0777
	db	8,34		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0778
:scale0779
:scale077a
:scale077b
:scale077c
:scale077d
:scale077e
:scale077f
	db	8,34		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0780
:scale0781
:scale0782
:scale0783
:scale0784
:scale0785
:scale0786
:scale0787
	db	8,35		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0788
:scale0789
:scale078a
:scale078b
:scale078c
:scale078d
:scale078e
:scale078f
	db	8,33		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0790
:scale0791
:scale0792
:scale0793
:scale0794
:scale0795
:scale0796
:scale0797
	db	8,33		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0798
:scale0799
:scale079a
:scale079b
:scale079c
:scale079d
:scale079e
:scale079f
:scale07a0
:scale07a1
:scale07a2
:scale07a3
:scale07a4
:scale07a5
:scale07a6
:scale07a7
:scale07a8
:scale07a9
:scale07aa
:scale07ab
:scale07ac
:scale07ad
:scale07ae
:scale07af
	db	8,33		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale07b0
:scale07b1
:scale07b2
:scale07b3
:scale07b4
:scale07b5
:scale07b6
:scale07b7
	db	8,33		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale07b8
:scale07b9
:scale07ba
:scale07bb
:scale07bc
:scale07bd
:scale07be
:scale07bf
	db	8,33		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale07c0
:scale07c1
:scale07c2
:scale07c3
:scale07c4
:scale07c5
:scale07c6
:scale07c7
	db	8,33		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale07c8
:scale07c9
:scale07ca
:scale07cb
:scale07cc
:scale07cd
:scale07ce
:scale07cf
	db	8,33		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale07d0
:scale07d1
:scale07d2
:scale07d3
:scale07d4
:scale07d5
:scale07d6
:scale07d7
	db	8,33		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale07d8
:scale07d9
:scale07da
:scale07db
:scale07dc
:scale07dd
:scale07de
:scale07df
	db	8,33		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale07e0
:scale07e1
:scale07e2
:scale07e3
:scale07e4
:scale07e5
:scale07e6
:scale07e7
	db	8,33		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale07e8
:scale07e9
:scale07ea
:scale07eb
:scale07ec
:scale07ed
:scale07ee
:scale07ef
	db	8,33		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale07f0
:scale07f1
:scale07f2
:scale07f3
:scale07f4
:scale07f5
:scale07f6
:scale07f7
	db	8,33		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale07f8
:scale07f9
:scale07fa
:scale07fb
:scale07fc
:scale07fd
:scale07fe
:scale07ff
	db	8,33		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0800
	db	9,32		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0801
:scale0802
:scale0803
	db	9,31		; Scale, Y
	db	4		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0804
:scale0805
:scale0806
:scale0807
:scale0808
:scale0809
:scale080a
:scale080b
:scale080c
:scale080d
:scale080e
:scale080f
:scale0810
:scale0811
:scale0812
:scale0813
:scale0814
:scale0815
	db	9,31		; Scale, Y
	db	3		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0816
:scale0817
:scale0818
:scale0819
:scale081a
:scale081b
:scale081c
:scale081d
:scale081e
	db	9,31		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale081f
:scale0820
:scale0821
:scale0822
:scale0823
:scale0824
:scale0825
:scale0826
:scale0827
:scale0828
:scale0829
:scale082a
:scale082b
:scale082c
:scale082d
:scale082e
:scale082f
:scale0830
:scale0831
:scale0832
:scale0833
:scale0834
:scale0835
:scale0836
:scale0837
:scale0838
:scale0839
:scale083a
:scale083b
:scale083c
:scale083d
:scale083e
:scale083f
:scale0840
:scale0841
:scale0842
	db	9,31		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0843
:scale0844
:scale0845
:scale0846
:scale0847
:scale0848
:scale0849
:scale084a
:scale084b
:scale084c
:scale084d
:scale084e
:scale084f
:scale0850
:scale0851
:scale0852
:scale0853
:scale0854
:scale0855
:scale0856
:scale0857
:scale0858
:scale0859
:scale085a
:scale085b
:scale085c
:scale085d
	db	9,30		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale085e
:scale085f
:scale0860
:scale0861
:scale0862
:scale0863
:scale0864
:scale0865
:scale0866
	db	9,30		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0867
:scale0868
:scale0869
:scale086a
:scale086b
:scale086c
:scale086d
:scale086e
:scale086f
	db	9,30		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0870
:scale0871
:scale0872
:scale0873
:scale0874
:scale0875
:scale0876
:scale0877
:scale0878
	db	9,31		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0879
:scale087a
:scale087b
:scale087c
:scale087d
:scale087e
:scale087f
:scale0880
:scale0881
	db	9,30		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0882
:scale0883
:scale0884
:scale0885
:scale0886
:scale0887
:scale0888
	db	9,30		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0889
:scale088a
	db	9,29		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale088b
:scale088c
:scale088d
:scale088e
:scale088f
:scale0890
:scale0891
:scale0892
:scale0893
:scale0894
:scale0895
:scale0896
:scale0897
:scale0898
:scale0899
:scale089a
:scale089b
:scale089c
:scale089d
:scale089e
:scale089f
:scale08a0
:scale08a1
:scale08a2
:scale08a3
:scale08a4
:scale08a5
	db	9,29		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale08a6
:scale08a7
:scale08a8
:scale08a9
:scale08aa
:scale08ab
:scale08ac
:scale08ad
:scale08ae
	db	9,29		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale08af
:scale08b0
:scale08b1
:scale08b2
:scale08b3
:scale08b4
:scale08b5
:scale08b6
:scale08b7
	db	9,29		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale08b8
:scale08b9
:scale08ba
:scale08bb
:scale08bc
:scale08bd
:scale08be
:scale08bf
:scale08c0
	db	9,29		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale08c1
:scale08c2
:scale08c3
:scale08c4
:scale08c5
:scale08c6
:scale08c7
:scale08c8
:scale08c9
	db	9,29		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale08ca
:scale08cb
:scale08cc
:scale08cd
:scale08ce
:scale08cf
:scale08d0
:scale08d1
:scale08d2
	db	9,29		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale08d3
:scale08d4
:scale08d5
:scale08d6
:scale08d7
:scale08d8
:scale08d9
:scale08da
:scale08db
	db	9,29		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale08dc
:scale08dd
:scale08de
:scale08df
:scale08e0
:scale08e1
:scale08e2
:scale08e3
:scale08e4
	db	9,29		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale08e5
:scale08e6
:scale08e7
:scale08e8
:scale08e9
:scale08ea
:scale08eb
:scale08ec
:scale08ed
	db	9,29		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale08ee
:scale08ef
:scale08f0
:scale08f1
:scale08f2
:scale08f3
:scale08f4
:scale08f5
:scale08f6
	db	9,29		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale08f7
:scale08f8
:scale08f9
:scale08fa
:scale08fb
:scale08fc
:scale08fd
:scale08fe
:scale08ff
	db	9,29		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0900
:scale0901
:scale0902
:scale0903
:scale0904
:scale0905
	db	10,28		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0906
:scale0907
:scale0908
:scale0909
:scale090a
:scale090b
:scale090c
:scale090d
:scale090e
:scale090f
:scale0910
:scale0911
:scale0912
:scale0913
:scale0914
:scale0915
:scale0916
:scale0917
:scale0918
:scale0919
:scale091a
:scale091b
:scale091c
:scale091d
:scale091e
:scale091f
:scale0920
:scale0921
:scale0922
:scale0923
:scale0924
	db	10,28		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0925
:scale0926
:scale0927
:scale0928
:scale0929
:scale092a
:scale092b
:scale092c
:scale092d
	db	10,27		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale092e
:scale092f
:scale0930
:scale0931
:scale0932
:scale0933
:scale0934
:scale0935
:scale0936
:scale0937
:scale0938
:scale0939
:scale093a
:scale093b
:scale093c
:scale093d
:scale093e
:scale093f
:scale0940
:scale0941
:scale0942
:scale0943
:scale0944
:scale0945
:scale0946
:scale0947
:scale0948
:scale0949
:scale094a
:scale094b
	db	10,27		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale094c
:scale094d
:scale094e
:scale094f
:scale0950
:scale0951
:scale0952
:scale0953
:scale0954
:scale0955
	db	10,27		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0956
:scale0957
:scale0958
:scale0959
:scale095a
:scale095b
:scale095c
:scale095d
:scale095e
:scale095f
	db	10,27		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0960
:scale0961
:scale0962
:scale0963
:scale0964
:scale0965
:scale0966
:scale0967
:scale0968
:scale0969
	db	10,28		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale096a
:scale096b
:scale096c
:scale096d
:scale096e
:scale096f
:scale0970
:scale0971
:scale0972
:scale0973
	db	10,27		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0974
:scale0975
:scale0976
:scale0977
:scale0978
:scale0979
:scale097a
:scale097b
	db	10,27		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale097c
:scale097d
	db	10,26		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale097e
:scale097f
:scale0980
:scale0981
:scale0982
:scale0983
:scale0984
:scale0985
:scale0986
:scale0987
:scale0988
:scale0989
:scale098a
:scale098b
:scale098c
:scale098d
:scale098e
:scale098f
:scale0990
:scale0991
:scale0992
:scale0993
:scale0994
:scale0995
:scale0996
:scale0997
:scale0998
:scale0999
:scale099a
:scale099b
	db	10,26		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale099c
:scale099d
:scale099e
:scale099f
:scale09a0
:scale09a1
:scale09a2
:scale09a3
:scale09a4
:scale09a5
	db	10,26		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale09a6
:scale09a7
:scale09a8
:scale09a9
:scale09aa
:scale09ab
:scale09ac
:scale09ad
:scale09ae
:scale09af
	db	10,26		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale09b0
:scale09b1
:scale09b2
:scale09b3
:scale09b4
:scale09b5
:scale09b6
:scale09b7
:scale09b8
:scale09b9
	db	10,26		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale09ba
:scale09bb
:scale09bc
:scale09bd
:scale09be
:scale09bf
:scale09c0
:scale09c1
:scale09c2
:scale09c3
	db	10,26		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale09c4
:scale09c5
:scale09c6
:scale09c7
:scale09c8
:scale09c9
:scale09ca
:scale09cb
:scale09cc
:scale09cd
	db	10,26		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale09ce
:scale09cf
:scale09d0
:scale09d1
:scale09d2
:scale09d3
:scale09d4
:scale09d5
:scale09d6
:scale09d7
	db	10,26		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale09d8
:scale09d9
:scale09da
:scale09db
:scale09dc
:scale09dd
:scale09de
:scale09df
:scale09e0
:scale09e1
	db	10,26		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale09e2
:scale09e3
:scale09e4
:scale09e5
:scale09e6
:scale09e7
:scale09e8
:scale09e9
:scale09ea
:scale09eb
	db	10,26		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale09ec
:scale09ed
:scale09ee
:scale09ef
:scale09f0
:scale09f1
:scale09f2
:scale09f3
:scale09f4
:scale09f5
	db	10,26		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale09f6
:scale09f7
:scale09f8
:scale09f9
:scale09fa
:scale09fb
:scale09fc
:scale09fd
:scale09fe
:scale09ff
	db	10,26		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0a00
:scale0a01
:scale0a02
:scale0a03
:scale0a04
:scale0a05
:scale0a06
:scale0a07
:scale0a08
:scale0a09
:scale0a0a
:scale0a0b
:scale0a0c
:scale0a0d
:scale0a0e
:scale0a0f
:scale0a10
:scale0a11
:scale0a12
:scale0a13
:scale0a14
:scale0a15
:scale0a16
:scale0a17
:scale0a18
	db	11,25		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0a19
:scale0a1a
:scale0a1b
:scale0a1c
:scale0a1d
:scale0a1e
:scale0a1f
:scale0a20
:scale0a21
:scale0a22
:scale0a23
:scale0a24
:scale0a25
:scale0a26
:scale0a27
:scale0a28
:scale0a29
:scale0a2a
:scale0a2b
:scale0a2c
:scale0a2d
:scale0a2e
:scale0a2f
:scale0a30
:scale0a31
:scale0a32
:scale0a33
:scale0a34
:scale0a35
:scale0a36
:scale0a37
:scale0a38
:scale0a39
	db	11,25		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0a3a
:scale0a3b
:scale0a3c
:scale0a3d
	db	11,25		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0a3e
:scale0a3f
:scale0a40
:scale0a41
:scale0a42
:scale0a43
:scale0a44
	db	11,24		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0a45
:scale0a46
:scale0a47
:scale0a48
:scale0a49
:scale0a4a
:scale0a4b
:scale0a4c
:scale0a4d
:scale0a4e
:scale0a4f
	db	11,24		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0a50
:scale0a51
:scale0a52
:scale0a53
:scale0a54
:scale0a55
:scale0a56
:scale0a57
:scale0a58
:scale0a59
:scale0a5a
	db	11,25		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0a5b
:scale0a5c
:scale0a5d
:scale0a5e
:scale0a5f
:scale0a60
:scale0a61
:scale0a62
:scale0a63
:scale0a64
:scale0a65
	db	11,24		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0a66
:scale0a67
:scale0a68
:scale0a69
:scale0a6a
:scale0a6b
:scale0a6c
:scale0a6d
:scale0a6e
:scale0a6f
:scale0a70
	db	11,24		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0a71
:scale0a72
:scale0a73
:scale0a74
:scale0a75
:scale0a76
:scale0a77
:scale0a78
:scale0a79
:scale0a7a
:scale0a7b
:scale0a7c
:scale0a7d
:scale0a7e
:scale0a7f
:scale0a80
:scale0a81
:scale0a82
:scale0a83
:scale0a84
:scale0a85
:scale0a86
:scale0a87
:scale0a88
:scale0a89
:scale0a8a
:scale0a8b
:scale0a8c
:scale0a8d
:scale0a8e
:scale0a8f
:scale0a90
:scale0a91
	db	11,24		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale0a92
:scale0a93
:scale0a94
:scale0a95
:scale0a96
:scale0a97
:scale0a98
:scale0a99
:scale0a9a
:scale0a9b
:scale0a9c
	db	11,24		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0a9d
:scale0a9e
:scale0a9f
:scale0aa0
:scale0aa1
:scale0aa2
:scale0aa3
:scale0aa4
:scale0aa5
:scale0aa6
:scale0aa7
	db	11,24		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale0aa8
:scale0aa9
:scale0aaa
:scale0aab
:scale0aac
:scale0aad
:scale0aae
:scale0aaf
:scale0ab0
:scale0ab1
:scale0ab2
	db	11,24		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0ab3
:scale0ab4
:scale0ab5
:scale0ab6
:scale0ab7
:scale0ab8
:scale0ab9
:scale0aba
:scale0abb
:scale0abc
:scale0abd
	db	11,24		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0abe
:scale0abf
:scale0ac0
:scale0ac1
:scale0ac2
:scale0ac3
:scale0ac4
:scale0ac5
:scale0ac6
:scale0ac7
:scale0ac8
	db	11,24		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale0ac9
:scale0aca
:scale0acb
:scale0acc
:scale0acd
:scale0ace
:scale0acf
:scale0ad0
:scale0ad1
:scale0ad2
:scale0ad3
	db	11,24		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale0ad4
:scale0ad5
:scale0ad6
:scale0ad7
:scale0ad8
:scale0ad9
:scale0ada
:scale0adb
:scale0adc
:scale0add
:scale0ade
	db	11,24		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0adf
:scale0ae0
:scale0ae1
:scale0ae2
:scale0ae3
:scale0ae4
:scale0ae5
:scale0ae6
:scale0ae7
:scale0ae8
:scale0ae9
	db	11,24		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale0aea
:scale0aeb
:scale0aec
:scale0aed
:scale0aee
:scale0aef
:scale0af0
:scale0af1
:scale0af2
:scale0af3
:scale0af4
	db	11,24		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale0af5
:scale0af6
:scale0af7
:scale0af8
:scale0af9
:scale0afa
:scale0afb
:scale0afc
:scale0afd
:scale0afe
:scale0aff
	db	11,24		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0b00
:scale0b01
:scale0b02
:scale0b03
	db	12,23		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0b04
:scale0b05
:scale0b06
:scale0b07
:scale0b08
:scale0b09
:scale0b0a
:scale0b0b
:scale0b0c
:scale0b0d
:scale0b0e
:scale0b0f
:scale0b10
:scale0b11
:scale0b12
:scale0b13
:scale0b14
:scale0b15
:scale0b16
:scale0b17
:scale0b18
:scale0b19
:scale0b1a
:scale0b1b
:scale0b1c
:scale0b1d
:scale0b1e
:scale0b1f
:scale0b20
:scale0b21
	db	12,23		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0b22
:scale0b23
:scale0b24
:scale0b25
:scale0b26
:scale0b27
	db	12,22		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0b28
:scale0b29
:scale0b2a
:scale0b2b
:scale0b2c
:scale0b2d
:scale0b2e
:scale0b2f
:scale0b30
:scale0b31
:scale0b32
:scale0b33
	db	12,22		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0b34
:scale0b35
:scale0b36
:scale0b37
:scale0b38
:scale0b39
:scale0b3a
:scale0b3b
:scale0b3c
:scale0b3d
:scale0b3e
:scale0b3f
	db	12,22		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0b40
:scale0b41
:scale0b42
:scale0b43
:scale0b44
:scale0b45
:scale0b46
:scale0b47
:scale0b48
:scale0b49
:scale0b4a
:scale0b4b
	db	12,23		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0b4c
:scale0b4d
:scale0b4e
:scale0b4f
:scale0b50
:scale0b51
:scale0b52
:scale0b53
:scale0b54
:scale0b55
:scale0b56
:scale0b57
	db	12,22		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0b58
:scale0b59
:scale0b5a
:scale0b5b
:scale0b5c
:scale0b5d
:scale0b5e
:scale0b5f
:scale0b60
:scale0b61
:scale0b62
:scale0b63
	db	12,22		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0b64
:scale0b65
:scale0b66
:scale0b67
:scale0b68
:scale0b69
:scale0b6a
:scale0b6b
:scale0b6c
:scale0b6d
:scale0b6e
:scale0b6f
:scale0b70
:scale0b71
:scale0b72
:scale0b73
:scale0b74
:scale0b75
:scale0b76
:scale0b77
:scale0b78
:scale0b79
:scale0b7a
:scale0b7b
:scale0b7c
:scale0b7d
:scale0b7e
:scale0b7f
:scale0b80
:scale0b81
:scale0b82
:scale0b83
:scale0b84
:scale0b85
:scale0b86
:scale0b87
	db	12,22		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale0b88
:scale0b89
:scale0b8a
:scale0b8b
:scale0b8c
:scale0b8d
:scale0b8e
:scale0b8f
:scale0b90
:scale0b91
:scale0b92
:scale0b93
	db	12,22		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0b94
:scale0b95
:scale0b96
:scale0b97
:scale0b98
:scale0b99
:scale0b9a
:scale0b9b
:scale0b9c
:scale0b9d
:scale0b9e
:scale0b9f
	db	12,22		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale0ba0
:scale0ba1
:scale0ba2
:scale0ba3
:scale0ba4
:scale0ba5
:scale0ba6
:scale0ba7
:scale0ba8
:scale0ba9
:scale0baa
:scale0bab
	db	12,22		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0bac
:scale0bad
:scale0bae
:scale0baf
:scale0bb0
:scale0bb1
:scale0bb2
:scale0bb3
:scale0bb4
:scale0bb5
:scale0bb6
:scale0bb7
	db	12,22		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0bb8
:scale0bb9
:scale0bba
:scale0bbb
:scale0bbc
:scale0bbd
:scale0bbe
:scale0bbf
:scale0bc0
:scale0bc1
:scale0bc2
:scale0bc3
	db	12,22		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale0bc4
:scale0bc5
:scale0bc6
:scale0bc7
:scale0bc8
:scale0bc9
:scale0bca
:scale0bcb
:scale0bcc
:scale0bcd
:scale0bce
:scale0bcf
	db	12,22		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale0bd0
:scale0bd1
:scale0bd2
:scale0bd3
:scale0bd4
:scale0bd5
:scale0bd6
:scale0bd7
:scale0bd8
:scale0bd9
:scale0bda
:scale0bdb
	db	12,22		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0bdc
:scale0bdd
:scale0bde
:scale0bdf
:scale0be0
:scale0be1
:scale0be2
:scale0be3
:scale0be4
:scale0be5
:scale0be6
:scale0be7
	db	12,22		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale0be8
:scale0be9
:scale0bea
:scale0beb
:scale0bec
:scale0bed
:scale0bee
:scale0bef
:scale0bf0
:scale0bf1
:scale0bf2
:scale0bf3
	db	12,22		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale0bf4
:scale0bf5
:scale0bf6
:scale0bf7
:scale0bf8
:scale0bf9
:scale0bfa
:scale0bfb
:scale0bfc
:scale0bfd
:scale0bfe
:scale0bff
	db	12,22		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0c00
:scale0c01
:scale0c02
:scale0c03
:scale0c04
:scale0c05
:scale0c06
:scale0c07
:scale0c08
:scale0c09
:scale0c0a
:scale0c0b
:scale0c0c
:scale0c0d
:scale0c0e
:scale0c0f
:scale0c10
:scale0c11
:scale0c12
:scale0c13
:scale0c14
:scale0c15
	db	13,21		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0c16
:scale0c17
:scale0c18
:scale0c19
:scale0c1a
:scale0c1b
:scale0c1c
:scale0c1d
:scale0c1e
:scale0c1f
:scale0c20
:scale0c21
:scale0c22
	db	13,21		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0c23
:scale0c24
:scale0c25
:scale0c26
:scale0c27
:scale0c28
:scale0c29
:scale0c2a
:scale0c2b
:scale0c2c
:scale0c2d
:scale0c2e
:scale0c2f
	db	13,21		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0c30
:scale0c31
:scale0c32
:scale0c33
:scale0c34
:scale0c35
:scale0c36
:scale0c37
:scale0c38
:scale0c39
:scale0c3a
:scale0c3b
:scale0c3c
	db	13,21		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0c3d
:scale0c3e
:scale0c3f
:scale0c40
:scale0c41
:scale0c42
:scale0c43
:scale0c44
:scale0c45
:scale0c46
:scale0c47
:scale0c48
:scale0c49
	db	13,20		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0c4a
:scale0c4b
:scale0c4c
:scale0c4d
:scale0c4e
:scale0c4f
:scale0c50
:scale0c51
:scale0c52
:scale0c53
:scale0c54
:scale0c55
:scale0c56
	db	13,20		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0c57
:scale0c58
:scale0c59
:scale0c5a
:scale0c5b
:scale0c5c
:scale0c5d
:scale0c5e
:scale0c5f
:scale0c60
:scale0c61
:scale0c62
:scale0c63
:scale0c64
:scale0c65
:scale0c66
:scale0c67
:scale0c68
:scale0c69
:scale0c6a
:scale0c6b
:scale0c6c
:scale0c6d
:scale0c6e
:scale0c6f
:scale0c70
:scale0c71
:scale0c72
:scale0c73
:scale0c74
:scale0c75
:scale0c76
:scale0c77
:scale0c78
:scale0c79
:scale0c7a
:scale0c7b
:scale0c7c
:scale0c7d
	db	13,20		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale0c7e
:scale0c7f
:scale0c80
:scale0c81
:scale0c82
:scale0c83
:scale0c84
:scale0c85
:scale0c86
:scale0c87
:scale0c88
:scale0c89
:scale0c8a
	db	13,20		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0c8b
:scale0c8c
:scale0c8d
:scale0c8e
:scale0c8f
:scale0c90
:scale0c91
:scale0c92
:scale0c93
:scale0c94
:scale0c95
:scale0c96
:scale0c97
	db	13,20		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale0c98
:scale0c99
:scale0c9a
:scale0c9b
:scale0c9c
:scale0c9d
:scale0c9e
:scale0c9f
:scale0ca0
:scale0ca1
:scale0ca2
:scale0ca3
:scale0ca4
	db	13,20		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0ca5
:scale0ca6
:scale0ca7
:scale0ca8
:scale0ca9
:scale0caa
:scale0cab
:scale0cac
:scale0cad
:scale0cae
:scale0caf
:scale0cb0
:scale0cb1
	db	13,20		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0cb2
:scale0cb3
:scale0cb4
:scale0cb5
:scale0cb6
:scale0cb7
:scale0cb8
:scale0cb9
:scale0cba
:scale0cbb
:scale0cbc
:scale0cbd
:scale0cbe
	db	13,20		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale0cbf
:scale0cc0
:scale0cc1
:scale0cc2
:scale0cc3
:scale0cc4
:scale0cc5
:scale0cc6
:scale0cc7
:scale0cc8
:scale0cc9
:scale0cca
:scale0ccb
	db	13,20		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale0ccc
:scale0ccd
:scale0cce
:scale0ccf
:scale0cd0
:scale0cd1
:scale0cd2
:scale0cd3
:scale0cd4
:scale0cd5
:scale0cd6
:scale0cd7
:scale0cd8
	db	13,20		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0cd9
:scale0cda
:scale0cdb
:scale0cdc
:scale0cdd
:scale0cde
:scale0cdf
:scale0ce0
:scale0ce1
:scale0ce2
:scale0ce3
:scale0ce4
:scale0ce5
	db	13,20		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale0ce6
:scale0ce7
:scale0ce8
:scale0ce9
:scale0cea
:scale0ceb
:scale0cec
:scale0ced
:scale0cee
:scale0cef
:scale0cf0
:scale0cf1
:scale0cf2
	db	13,20		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale0cf3
:scale0cf4
:scale0cf5
:scale0cf6
:scale0cf7
:scale0cf8
:scale0cf9
:scale0cfa
:scale0cfb
:scale0cfc
:scale0cfd
:scale0cfe
:scale0cff
	db	13,20		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0d00
:scale0d01
:scale0d02
:scale0d03
	db	14,19		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	16,15		; Source Stride, Dest Stride
	dw	20		; y

:scale0d04
:scale0d05
:scale0d06
:scale0d07
:scale0d08
:scale0d09
:scale0d0a
:scale0d0b
:scale0d0c
:scale0d0d
:scale0d0e
:scale0d0f
:scale0d10
:scale0d11
	db	14,19		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0d12
:scale0d13
:scale0d14
:scale0d15
:scale0d16
:scale0d17
:scale0d18
:scale0d19
:scale0d1a
:scale0d1b
:scale0d1c
:scale0d1d
:scale0d1e
:scale0d1f
	db	14,19		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0d20
:scale0d21
:scale0d22
:scale0d23
:scale0d24
:scale0d25
:scale0d26
:scale0d27
:scale0d28
:scale0d29
:scale0d2a
:scale0d2b
:scale0d2c
:scale0d2d
	db	14,20		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0d2e
:scale0d2f
:scale0d30
:scale0d31
:scale0d32
:scale0d33
:scale0d34
:scale0d35
:scale0d36
:scale0d37
:scale0d38
:scale0d39
:scale0d3a
:scale0d3b
	db	14,19		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0d3c
:scale0d3d
:scale0d3e
:scale0d3f
:scale0d40
:scale0d41
:scale0d42
:scale0d43
:scale0d44
:scale0d45
:scale0d46
:scale0d47
:scale0d48
:scale0d49
	db	14,19		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0d4a
:scale0d4b
:scale0d4c
:scale0d4d
:scale0d4e
:scale0d4f
:scale0d50
:scale0d51
:scale0d52
:scale0d53
:scale0d54
:scale0d55
:scale0d56
:scale0d57
:scale0d58
:scale0d59
:scale0d5a
:scale0d5b
:scale0d5c
:scale0d5d
:scale0d5e
:scale0d5f
:scale0d60
:scale0d61
:scale0d62
:scale0d63
:scale0d64
:scale0d65
:scale0d66
:scale0d67
:scale0d68
:scale0d69
:scale0d6a
:scale0d6b
:scale0d6c
:scale0d6d
:scale0d6e
:scale0d6f
:scale0d70
:scale0d71
:scale0d72
:scale0d73
	db	14,19		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale0d74
:scale0d75
:scale0d76
:scale0d77
:scale0d78
:scale0d79
:scale0d7a
:scale0d7b
:scale0d7c
:scale0d7d
:scale0d7e
:scale0d7f
:scale0d80
:scale0d81
	db	14,19		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0d82
:scale0d83
:scale0d84
:scale0d85
:scale0d86
:scale0d87
:scale0d88
:scale0d89
:scale0d8a
:scale0d8b
:scale0d8c
:scale0d8d
:scale0d8e
:scale0d8f
	db	14,19		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale0d90
:scale0d91
:scale0d92
:scale0d93
:scale0d94
:scale0d95
:scale0d96
:scale0d97
:scale0d98
:scale0d99
:scale0d9a
:scale0d9b
:scale0d9c
:scale0d9d
	db	14,19		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0d9e
:scale0d9f
:scale0da0
:scale0da1
:scale0da2
:scale0da3
:scale0da4
:scale0da5
:scale0da6
:scale0da7
:scale0da8
:scale0da9
:scale0daa
:scale0dab
	db	14,19		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0dac
:scale0dad
:scale0dae
:scale0daf
:scale0db0
:scale0db1
:scale0db2
:scale0db3
:scale0db4
:scale0db5
:scale0db6
:scale0db7
:scale0db8
:scale0db9
	db	14,19		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale0dba
:scale0dbb
:scale0dbc
:scale0dbd
:scale0dbe
:scale0dbf
:scale0dc0
:scale0dc1
:scale0dc2
:scale0dc3
:scale0dc4
:scale0dc5
:scale0dc6
:scale0dc7
	db	14,19		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale0dc8
:scale0dc9
:scale0dca
:scale0dcb
:scale0dcc
:scale0dcd
:scale0dce
:scale0dcf
:scale0dd0
:scale0dd1
:scale0dd2
:scale0dd3
:scale0dd4
:scale0dd5
	db	14,19		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0dd6
:scale0dd7
:scale0dd8
:scale0dd9
:scale0dda
:scale0ddb
:scale0ddc
:scale0ddd
:scale0dde
:scale0ddf
:scale0de0
:scale0de1
:scale0de2
:scale0de3
	db	14,19		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale0de4
:scale0de5
:scale0de6
:scale0de7
:scale0de8
:scale0de9
:scale0dea
:scale0deb
:scale0dec
:scale0ded
:scale0dee
:scale0def
:scale0df0
:scale0df1
	db	14,19		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale0df2
:scale0df3
:scale0df4
:scale0df5
:scale0df6
:scale0df7
:scale0df8
:scale0df9
:scale0dfa
:scale0dfb
:scale0dfc
:scale0dfd
:scale0dfe
:scale0dff
	db	14,19		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0e00
	db	15,18		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	16,15		; Source Stride, Dest Stride
	dw	24		; y

:scale0e01
:scale0e02
:scale0e03
:scale0e04
:scale0e05
:scale0e06
:scale0e07
:scale0e08
:scale0e09
:scale0e0a
:scale0e0b
:scale0e0c
:scale0e0d
:scale0e0e
:scale0e0f
	db	15,18		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	16,15		; Source Stride, Dest Stride
	dw	32		; y

:scale0e10
:scale0e11
:scale0e12
:scale0e13
:scale0e14
:scale0e15
:scale0e16
:scale0e17
:scale0e18
:scale0e19
:scale0e1a
:scale0e1b
:scale0e1c
:scale0e1d
:scale0e1e
	db	15,19		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0e1f
:scale0e20
:scale0e21
:scale0e22
:scale0e23
:scale0e24
:scale0e25
:scale0e26
:scale0e27
:scale0e28
:scale0e29
:scale0e2a
:scale0e2b
:scale0e2c
:scale0e2d
	db	15,18		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0e2e
:scale0e2f
:scale0e30
:scale0e31
:scale0e32
:scale0e33
:scale0e34
:scale0e35
:scale0e36
:scale0e37
:scale0e38
:scale0e39
:scale0e3a
:scale0e3b
:scale0e3c
	db	15,18		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0e3d
:scale0e3e
:scale0e3f
:scale0e40
:scale0e41
:scale0e42
:scale0e43
:scale0e44
:scale0e45
:scale0e46
:scale0e47
:scale0e48
:scale0e49
:scale0e4a
:scale0e4b
:scale0e4c
:scale0e4d
:scale0e4e
:scale0e4f
:scale0e50
:scale0e51
:scale0e52
:scale0e53
:scale0e54
:scale0e55
:scale0e56
:scale0e57
:scale0e58
:scale0e59
:scale0e5a
:scale0e5b
:scale0e5c
:scale0e5d
:scale0e5e
:scale0e5f
:scale0e60
:scale0e61
:scale0e62
:scale0e63
:scale0e64
:scale0e65
:scale0e66
:scale0e67
:scale0e68
:scale0e69
	db	15,18		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale0e6a
:scale0e6b
:scale0e6c
:scale0e6d
:scale0e6e
:scale0e6f
:scale0e70
:scale0e71
:scale0e72
:scale0e73
:scale0e74
:scale0e75
:scale0e76
:scale0e77
:scale0e78
	db	15,18		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0e79
:scale0e7a
:scale0e7b
:scale0e7c
:scale0e7d
:scale0e7e
:scale0e7f
:scale0e80
:scale0e81
:scale0e82
:scale0e83
:scale0e84
:scale0e85
:scale0e86
:scale0e87
	db	15,18		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale0e88
:scale0e89
:scale0e8a
:scale0e8b
:scale0e8c
:scale0e8d
:scale0e8e
:scale0e8f
:scale0e90
:scale0e91
:scale0e92
:scale0e93
:scale0e94
:scale0e95
:scale0e96
	db	15,18		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0e97
:scale0e98
:scale0e99
:scale0e9a
:scale0e9b
:scale0e9c
:scale0e9d
:scale0e9e
:scale0e9f
:scale0ea0
:scale0ea1
:scale0ea2
:scale0ea3
:scale0ea4
:scale0ea5
	db	15,18		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0ea6
:scale0ea7
:scale0ea8
:scale0ea9
:scale0eaa
:scale0eab
:scale0eac
:scale0ead
:scale0eae
:scale0eaf
:scale0eb0
:scale0eb1
:scale0eb2
:scale0eb3
:scale0eb4
	db	15,18		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale0eb5
:scale0eb6
:scale0eb7
:scale0eb8
:scale0eb9
:scale0eba
:scale0ebb
:scale0ebc
:scale0ebd
:scale0ebe
:scale0ebf
:scale0ec0
:scale0ec1
:scale0ec2
:scale0ec3
	db	15,18		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale0ec4
:scale0ec5
:scale0ec6
:scale0ec7
:scale0ec8
:scale0ec9
:scale0eca
:scale0ecb
:scale0ecc
:scale0ecd
:scale0ece
:scale0ecf
:scale0ed0
:scale0ed1
:scale0ed2
	db	15,18		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0ed3
:scale0ed4
:scale0ed5
:scale0ed6
:scale0ed7
:scale0ed8
:scale0ed9
:scale0eda
:scale0edb
:scale0edc
:scale0edd
:scale0ede
:scale0edf
:scale0ee0
:scale0ee1
	db	15,18		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale0ee2
:scale0ee3
:scale0ee4
:scale0ee5
:scale0ee6
:scale0ee7
:scale0ee8
:scale0ee9
:scale0eea
:scale0eeb
:scale0eec
:scale0eed
:scale0eee
:scale0eef
:scale0ef0
	db	15,18		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale0ef1
:scale0ef2
:scale0ef3
:scale0ef4
:scale0ef5
:scale0ef6
:scale0ef7
:scale0ef8
:scale0ef9
:scale0efa
:scale0efb
:scale0efc
:scale0efd
:scale0efe
:scale0eff
	db	15,18		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale0f00
:scale0f01
:scale0f02
:scale0f03
:scale0f04
:scale0f05
:scale0f06
:scale0f07
:scale0f08
:scale0f09
:scale0f0a
:scale0f0b
:scale0f0c
:scale0f0d
:scale0f0e
:scale0f0f
	db	16,18		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	18		; y

:scale0f10
:scale0f11
:scale0f12
:scale0f13
:scale0f14
:scale0f15
:scale0f16
:scale0f17
:scale0f18
:scale0f19
:scale0f1a
:scale0f1b
:scale0f1c
:scale0f1d
:scale0f1e
:scale0f1f
	db	16,17		; Scale, Y
	db	2		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0f20
:scale0f21
:scale0f22
:scale0f23
:scale0f24
:scale0f25
:scale0f26
:scale0f27
:scale0f28
:scale0f29
:scale0f2a
:scale0f2b
:scale0f2c
:scale0f2d
:scale0f2e
:scale0f2f
	db	16,17		; Scale, Y
	db	3		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0f30
:scale0f31
:scale0f32
:scale0f33
:scale0f34
:scale0f35
:scale0f36
:scale0f37
:scale0f38
:scale0f39
:scale0f3a
:scale0f3b
:scale0f3c
:scale0f3d
:scale0f3e
:scale0f3f
:scale0f40
:scale0f41
:scale0f42
:scale0f43
:scale0f44
:scale0f45
:scale0f46
:scale0f47
:scale0f48
:scale0f49
:scale0f4a
:scale0f4b
:scale0f4c
:scale0f4d
:scale0f4e
:scale0f4f
:scale0f50
:scale0f51
:scale0f52
:scale0f53
:scale0f54
:scale0f55
:scale0f56
:scale0f57
:scale0f58
:scale0f59
:scale0f5a
:scale0f5b
:scale0f5c
:scale0f5d
:scale0f5e
:scale0f5f
	db	16,17		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	32,31		; Source Stride, Dest Stride
	dw	10		; y

:scale0f60
:scale0f61
:scale0f62
:scale0f63
:scale0f64
:scale0f65
:scale0f66
:scale0f67
:scale0f68
:scale0f69
:scale0f6a
:scale0f6b
:scale0f6c
:scale0f6d
:scale0f6e
:scale0f6f
	db	16,17		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	32,31		; Source Stride, Dest Stride
	dw	12		; y

:scale0f70
:scale0f71
:scale0f72
:scale0f73
:scale0f74
:scale0f75
:scale0f76
:scale0f77
:scale0f78
:scale0f79
:scale0f7a
:scale0f7b
:scale0f7c
:scale0f7d
:scale0f7e
:scale0f7f
	db	16,17		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	32,31		; Source Stride, Dest Stride
	dw	16		; y

:scale0f80
:scale0f81
:scale0f82
:scale0f83
:scale0f84
:scale0f85
:scale0f86
:scale0f87
:scale0f88
:scale0f89
:scale0f8a
:scale0f8b
:scale0f8c
:scale0f8d
:scale0f8e
:scale0f8f
	db	16,17		; Scale, Y
	db	1		; Stages
	db	32,31		; Source Stride, Dest Stride
	dw	9		; y

:scale0f90
:scale0f91
:scale0f92
:scale0f93
:scale0f94
:scale0f95
:scale0f96
:scale0f97
:scale0f98
:scale0f99
:scale0f9a
:scale0f9b
:scale0f9c
:scale0f9d
:scale0f9e
:scale0f9f
	db	16,17		; Scale, Y
	db	2		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0fa0
:scale0fa1
:scale0fa2
:scale0fa3
:scale0fa4
:scale0fa5
:scale0fa6
:scale0fa7
:scale0fa8
:scale0fa9
:scale0faa
:scale0fab
:scale0fac
:scale0fad
:scale0fae
:scale0faf
	db	16,17		; Scale, Y
	db	2		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y
	db	64,63		; Source Stride, Dest Stride
	dw	6		; y

:scale0fb0
:scale0fb1
:scale0fb2
:scale0fb3
:scale0fb4
:scale0fb5
:scale0fb6
:scale0fb7
:scale0fb8
:scale0fb9
:scale0fba
:scale0fbb
:scale0fbc
:scale0fbd
:scale0fbe
:scale0fbf
	db	16,17		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	64,63		; Source Stride, Dest Stride
	dw	8		; y

:scale0fc0
:scale0fc1
:scale0fc2
:scale0fc3
:scale0fc4
:scale0fc5
:scale0fc6
:scale0fc7
:scale0fc8
:scale0fc9
:scale0fca
:scale0fcb
:scale0fcc
:scale0fcd
:scale0fce
:scale0fcf
	db	16,17		; Scale, Y
	db	1		; Stages
	db	64,63		; Source Stride, Dest Stride
	dw	5		; y

:scale0fd0
:scale0fd1
:scale0fd2
:scale0fd3
:scale0fd4
:scale0fd5
:scale0fd6
:scale0fd7
:scale0fd8
:scale0fd9
:scale0fda
:scale0fdb
:scale0fdc
:scale0fdd
:scale0fde
:scale0fdf
	db	16,17		; Scale, Y
	db	2		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y
	db	128,127		; Source Stride, Dest Stride
	dw	4		; y

:scale0fe0
:scale0fe1
:scale0fe2
:scale0fe3
:scale0fe4
:scale0fe5
:scale0fe6
:scale0fe7
:scale0fe8
:scale0fe9
:scale0fea
:scale0feb
:scale0fec
:scale0fed
:scale0fee
:scale0fef
	db	16,17		; Scale, Y
	db	1		; Stages
	db	128,127		; Source Stride, Dest Stride
	dw	3		; y

:scale0ff0
:scale0ff1
:scale0ff2
:scale0ff3
:scale0ff4
:scale0ff5
:scale0ff6
:scale0ff7
:scale0ff8
:scale0ff9
:scale0ffa
:scale0ffb
:scale0ffc
:scale0ffd
:scale0ffe
:scale0fff
	db	16,17		; Scale, Y
	db	1		; Stages
	db	0,255		; Source Stride, Dest Stride
	dw	2		; y

:scale1000
	db	17,17		; Scale, Y
	db	1		; Stages
	db	16,15		; Source Stride, Dest Stride
	dw	19		; y

