
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a2010113          	add	sp,sp,-1504 # 80008a20 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	add	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	89070713          	add	a4,a4,-1904 # 800088e0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	efe78793          	add	a5,a5,-258 # 80005f60 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdcaaf>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2678793          	add	a5,a5,-474 # 80000ed2 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	474080e7          	jalr	1140(ra) # 8000259e <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7e4080e7          	jalr	2020(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	add	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	add	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	add	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	89450513          	add	a0,a0,-1900 # 80010a20 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	88448493          	add	s1,s1,-1916 # 80010a20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00011917          	auipc	s2,0x11
    800001a8:	91490913          	add	s2,s2,-1772 # 80010ab8 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	88e080e7          	jalr	-1906(ra) # 80001a4a <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	224080e7          	jalr	548(ra) # 800023e8 <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	f6e080e7          	jalr	-146(ra) # 80002140 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00011717          	auipc	a4,0x11
    800001ec:	83870713          	add	a4,a4,-1992 # 80010a20 <cons>
    800001f0:	0017869b          	addw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	and	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	add	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	32e080e7          	jalr	814(ra) # 80002548 <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
      break;

    dst++;
    80000228:	0a05                	add	s4,s4,1
    --n;
    8000022a:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000236:	00010517          	auipc	a0,0x10
    8000023a:	7ea50513          	add	a0,a0,2026 # 80010a20 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	aae080e7          	jalr	-1362(ra) # 80000cec <release>
        return -1;
    80000246:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	add	sp,sp,96
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
        cons.r--;
    80000264:	00011717          	auipc	a4,0x11
    80000268:	84f72a23          	sw	a5,-1964(a4) # 80010ab8 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00010517          	auipc	a0,0x10
    8000027e:	7a650513          	add	a0,a0,1958 # 80010a20 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
  return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	add	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
    uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	59c080e7          	jalr	1436(ra) # 80000840 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	add	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	58a080e7          	jalr	1418(ra) # 80000840 <uartputc_sync>
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	574080e7          	jalr	1396(ra) # 80000840 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d6:	1101                	add	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	add	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00010517          	auipc	a0,0x10
    800002e6:	73e50513          	add	a0,a0,1854 # 80010a20 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	94e080e7          	jalr	-1714(ra) # 80000c38 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	2ec080e7          	jalr	748(ra) # 800025f4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00010517          	auipc	a0,0x10
    80000314:	71050513          	add	a0,a0,1808 # 80010a20 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9d4080e7          	jalr	-1580(ra) # 80000cec <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	add	sp,sp,32
    80000328:	8082                	ret
  switch(c){
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000332:	00010717          	auipc	a4,0x10
    80000336:	6ee70713          	add	a4,a4,1774 # 80010a20 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
      consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00010797          	auipc	a5,0x10
    80000360:	6c478793          	add	a5,a5,1732 # 80010a20 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	and	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00010797          	auipc	a5,0x10
    8000038e:	72e7a783          	lw	a5,1838(a5) # 80010ab8 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00010717          	auipc	a4,0x10
    800003a4:	68070713          	add	a4,a4,1664 # 80010a20 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00010497          	auipc	s1,0x10
    800003b4:	67048493          	add	s1,s1,1648 # 80010a20 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003be:	37fd                	addw	a5,a5,-1
    800003c0:	07f7f713          	and	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
      cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
    while(cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f6:	00010717          	auipc	a4,0x10
    800003fa:	62a70713          	add	a4,a4,1578 # 80010a20 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addw	a5,a5,-1
    8000040c:	00010717          	auipc	a4,0x10
    80000410:	6af72a23          	sw	a5,1716(a4) # 80010ac0 <cons+0xa0>
      consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
      consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	5ee78793          	add	a5,a5,1518 # 80010a20 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	and	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000456:	00010797          	auipc	a5,0x10
    8000045a:	66c7a323          	sw	a2,1638(a5) # 80010abc <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00010517          	auipc	a0,0x10
    80000462:	65a50513          	add	a0,a0,1626 # 80010ab8 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	d3e080e7          	jalr	-706(ra) # 800021a4 <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void
consoleinit(void)
{
    80000470:	1141                	add	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b8858593          	add	a1,a1,-1144 # 80008000 <etext>
    80000480:	00010517          	auipc	a0,0x10
    80000484:	5a050513          	add	a0,a0,1440 # 80010a20 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00020797          	auipc	a5,0x20
    8000049c:	72078793          	add	a5,a5,1824 # 80020bb8 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	add	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	add	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	add	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	add	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	add	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	25260613          	add	a2,a2,594 # 80008728 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	sll	a5,a5,0x20
    800004e8:	9381                	srl	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	add	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

  if(sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
    buf[i++] = '-';
    80000506:	fe070793          	add	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	add	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	add	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addw	a4,a4,-1
    80000532:	1702                	sll	a4,a4,0x20
    80000534:	9301                	srl	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
  while(--i >= 0)
    80000546:	14fd                	add	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	add	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
    x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	add	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	add	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00010797          	auipc	a5,0x10
    80000570:	5607aa23          	sw	zero,1396(a5) # 80010ae0 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	add	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	add	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	00008717          	auipc	a4,0x8
    800005a4:	30f72023          	sw	a5,768(a4) # 800088a0 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	add	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	0100                	add	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00010d17          	auipc	s10,0x10
    800005ce:	516d2d03          	lw	s10,1302(s10) # 80010ae0 <pr+0x18>
  if(locking)
    800005d2:	040d1463          	bnez	s10,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	add	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050b63          	beqz	a0,8000077c <printf+0x1d2>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	ec6e                	sd	s11,24(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000608:	00008a97          	auipc	s5,0x8
    8000060c:	120a8a93          	add	s5,s5,288 # 80008728 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00010517          	auipc	a0,0x10
    8000061e:	4ae50513          	add	a0,a0,1198 # 80010ac8 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	616080e7          	jalr	1558(ra) # 80000c38 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	add	a0,a0,-1566 # 80008020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c46080e7          	jalr	-954(ra) # 80000294 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2985                	addw	s3,s3,1
    80000658:	013a07b3          	add	a5,s4,s3
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c0>
    if(c != '%'){
    80000664:	ff6515e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	2985                	addw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000676:	10078b63          	beqz	a5,8000078c <printf+0x1e2>
    switch(c){
    8000067a:	05778a63          	beq	a5,s7,800006ce <printf+0x124>
    8000067e:	02fbf663          	bgeu	s7,a5,800006aa <printf+0x100>
    80000682:	09878863          	beq	a5,s8,80000712 <printf+0x168>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79563          	bne	a5,a4,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	add	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85e6                	mv	a1,s9
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e1c080e7          	jalr	-484(ra) # 800004bc <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	09678f63          	beq	a5,s6,80000748 <printf+0x19e>
    800006ae:	0bb79363          	bne	a5,s11,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	add	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	df8080e7          	jalr	-520(ra) # 800004bc <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	add	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	bb2080e7          	jalr	-1102(ra) # 80000294 <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	ba6080e7          	jalr	-1114(ra) # 80000294 <consputc>
    800006f6:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srl	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b92080e7          	jalr	-1134(ra) # 80000294 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	sll	s2,s2,0x4
    8000070c:	34fd                	addw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x14e>
    80000710:	b799                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	add	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x190>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d905                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b6c080e7          	jalr	-1172(ra) # 80000294 <consputc>
      for(; *s; s++)
    80000730:	0485                	add	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x17e>
    80000738:	bf39                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	add	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x17e>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b4a080e7          	jalr	-1206(ra) # 80000294 <consputc>
      break;
    80000752:	b711                	j	80000656 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b3e080e7          	jalr	-1218(ra) # 80000294 <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b34080e7          	jalr	-1228(ra) # 80000294 <consputc>
      break;
    80000768:	b5fd                	j	80000656 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077c:	020d1263          	bnez	s10,800007a0 <printf+0x1f6>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	7d02                	ld	s10,32(sp)
    80000788:	6129                	add	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	6de2                	ld	s11,24(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d2>
    release(&pr.lock);
    800007a0:	00010517          	auipc	a0,0x10
    800007a4:	32850513          	add	a0,a0,808 # 80010ac8 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	544080e7          	jalr	1348(ra) # 80000cec <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d6>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1101                	add	sp,sp,-32
    800007b4:	ec06                	sd	ra,24(sp)
    800007b6:	e822                	sd	s0,16(sp)
    800007b8:	e426                	sd	s1,8(sp)
    800007ba:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    800007bc:	00010497          	auipc	s1,0x10
    800007c0:	30c48493          	add	s1,s1,780 # 80010ac8 <pr>
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	86c58593          	add	a1,a1,-1940 # 80008030 <etext+0x30>
    800007cc:	8526                	mv	a0,s1
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	3da080e7          	jalr	986(ra) # 80000ba8 <initlock>
  pr.locking = 1;
    800007d6:	4785                	li	a5,1
    800007d8:	cc9c                	sw	a5,24(s1)
}
    800007da:	60e2                	ld	ra,24(sp)
    800007dc:	6442                	ld	s0,16(sp)
    800007de:	64a2                	ld	s1,8(sp)
    800007e0:	6105                	add	sp,sp,32
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	add	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	10000737          	lui	a4,0x10000
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	add	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00010517          	auipc	a0,0x10
    8000082c:	2c050513          	add	a0,a0,704 # 80010ae8 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	378080e7          	jalr	888(ra) # 80000ba8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	add	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	add	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	add	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a0080e7          	jalr	928(ra) # 80000bec <push_off>

  if(panicked){
    80000854:	00008797          	auipc	a5,0x8
    80000858:	04c7a783          	lw	a5,76(a5) # 800088a0 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	add	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	and	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	412080e7          	jalr	1042(ra) # 80000c8c <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	add	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	00008797          	auipc	a5,0x8
    80000892:	01a7b783          	ld	a5,26(a5) # 800088a8 <uart_tx_r>
    80000896:	00008717          	auipc	a4,0x8
    8000089a:	01a73703          	ld	a4,26(a4) # 800088b0 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	add	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	add	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00010a97          	auipc	s5,0x10
    800008c0:	22ca8a93          	add	s5,s5,556 # 80010ae8 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	00008497          	auipc	s1,0x8
    800008c8:	fe448493          	add	s1,s1,-28 # 800088a8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	00008997          	auipc	s3,0x8
    800008d4:	fe098993          	add	s3,s3,-32 # 800088b0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	and	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	and	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	add	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	8b2080e7          	jalr	-1870(ra) # 800021a4 <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	add	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	add	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	add	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00010517          	auipc	a0,0x10
    80000934:	1b850513          	add	a0,a0,440 # 80010ae8 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	00008797          	auipc	a5,0x8
    80000944:	f607a783          	lw	a5,-160(a5) # 800088a0 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	00008717          	auipc	a4,0x8
    8000094e:	f6673703          	ld	a4,-154(a4) # 800088b0 <uart_tx_w>
    80000952:	00008797          	auipc	a5,0x8
    80000956:	f567b783          	ld	a5,-170(a5) # 800088a8 <uart_tx_r>
    8000095a:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00010997          	auipc	s3,0x10
    80000962:	18a98993          	add	s3,s3,394 # 80010ae8 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	f4248493          	add	s1,s1,-190 # 800088a8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	f4290913          	add	s2,s2,-190 # 800088b0 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00001097          	auipc	ra,0x1
    80000982:	7c2080e7          	jalr	1986(ra) # 80002140 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	add	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00010497          	auipc	s1,0x10
    80000998:	15448493          	add	s1,s1,340 # 80010ae8 <uart_tx_lock>
    8000099c:	01f77793          	and	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	add	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	f0e7b423          	sd	a4,-248(a5) # 800088b0 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	332080e7          	jalr	818(ra) # 80000cec <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	add	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	add	sp,sp,-16
    800009d6:	e422                	sd	s0,8(sp)
    800009d8:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0795                	add	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009e0:	0007c783          	lbu	a5,0(a5)
    800009e4:	8b85                	and	a5,a5,1
    800009e6:	cb81                	beqz	a5,800009f6 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	add	sp,sp,16
    800009f4:	8082                	ret
    return -1;
    800009f6:	557d                	li	a0,-1
    800009f8:	bfe5                	j	800009f0 <uartgetc+0x1c>

00000000800009fa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fa:	1101                	add	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a04:	54fd                	li	s1,-1
    80000a06:	a029                	j	80000a10 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	8ce080e7          	jalr	-1842(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	fc4080e7          	jalr	-60(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a18:	fe9518e3          	bne	a0,s1,80000a08 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1c:	00010497          	auipc	s1,0x10
    80000a20:	0cc48493          	add	s1,s1,204 # 80010ae8 <uart_tx_lock>
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	212080e7          	jalr	530(ra) # 80000c38 <acquire>
  uartstart();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	e60080e7          	jalr	-416(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2b4080e7          	jalr	692(ra) # 80000cec <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret

0000000080000a4a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4a:	1101                	add	sp,sp,-32
    80000a4c:	ec06                	sd	ra,24(sp)
    80000a4e:	e822                	sd	s0,16(sp)
    80000a50:	e426                	sd	s1,8(sp)
    80000a52:	e04a                	sd	s2,0(sp)
    80000a54:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a56:	03451793          	sll	a5,a0,0x34
    80000a5a:	ebb9                	bnez	a5,80000ab0 <kfree+0x66>
    80000a5c:	84aa                	mv	s1,a0
    80000a5e:	00021797          	auipc	a5,0x21
    80000a62:	2f278793          	add	a5,a5,754 # 80021d50 <end>
    80000a66:	04f56563          	bltu	a0,a5,80000ab0 <kfree+0x66>
    80000a6a:	47c5                	li	a5,17
    80000a6c:	07ee                	sll	a5,a5,0x1b
    80000a6e:	04f57163          	bgeu	a0,a5,80000ab0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a72:	6605                	lui	a2,0x1
    80000a74:	4585                	li	a1,1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2be080e7          	jalr	702(ra) # 80000d34 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00010917          	auipc	s2,0x10
    80000a82:	0a290913          	add	s2,s2,162 # 80010b20 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	1b0080e7          	jalr	432(ra) # 80000c38 <acquire>
  r->next = kmem.freelist;
    80000a90:	01893783          	ld	a5,24(s2)
    80000a94:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a96:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	250080e7          	jalr	592(ra) # 80000cec <release>
}
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6902                	ld	s2,0(sp)
    80000aac:	6105                	add	sp,sp,32
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	59050513          	add	a0,a0,1424 # 80008040 <etext+0x40>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	aa8080e7          	jalr	-1368(ra) # 80000560 <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	add	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aca:	6785                	lui	a5,0x1
    80000acc:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad0:	00e504b3          	add	s1,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad8:	94be                	add	s1,s1,a5
    80000ada:	0295e463          	bltu	a1,s1,80000b02 <freerange+0x42>
    80000ade:	e84a                	sd	s2,16(sp)
    80000ae0:	e44e                	sd	s3,8(sp)
    80000ae2:	e052                	sd	s4,0(sp)
    80000ae4:	892e                	mv	s2,a1
    kfree(p);
    80000ae6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	6985                	lui	s3,0x1
    kfree(p);
    80000aea:	01448533          	add	a0,s1,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	f5c080e7          	jalr	-164(ra) # 80000a4a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af6:	94ce                	add	s1,s1,s3
    80000af8:	fe9979e3          	bgeu	s2,s1,80000aea <freerange+0x2a>
    80000afc:	6942                	ld	s2,16(sp)
    80000afe:	69a2                	ld	s3,8(sp)
    80000b00:	6a02                	ld	s4,0(sp)
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6145                	add	sp,sp,48
    80000b0a:	8082                	ret

0000000080000b0c <kinit>:
{
    80000b0c:	1141                	add	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b14:	00007597          	auipc	a1,0x7
    80000b18:	53458593          	add	a1,a1,1332 # 80008048 <etext+0x48>
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	00450513          	add	a0,a0,4 # 80010b20 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	sll	a1,a1,0x1b
    80000b30:	00021517          	auipc	a0,0x21
    80000b34:	22050513          	add	a0,a0,544 # 80021d50 <end>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f88080e7          	jalr	-120(ra) # 80000ac0 <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	add	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	add	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00010497          	auipc	s1,0x10
    80000b56:	fce48493          	add	s1,s1,-50 # 80010b20 <kmem>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	0dc080e7          	jalr	220(ra) # 80000c38 <acquire>
  r = kmem.freelist;
    80000b64:	6c84                	ld	s1,24(s1)
  if(r)
    80000b66:	c885                	beqz	s1,80000b96 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00010517          	auipc	a0,0x10
    80000b6e:	fb650513          	add	a0,a0,-74 # 80010b20 <kmem>
    80000b72:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	178080e7          	jalr	376(ra) # 80000cec <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4595                	li	a1,5
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	1b2080e7          	jalr	434(ra) # 80000d34 <memset>
  return (void*)r;
}
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	add	sp,sp,32
    80000b94:	8082                	ret
  release(&kmem.lock);
    80000b96:	00010517          	auipc	a0,0x10
    80000b9a:	f8a50513          	add	a0,a0,-118 # 80010b20 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	14e080e7          	jalr	334(ra) # 80000cec <release>
  if(r)
    80000ba6:	b7d5                	j	80000b8a <kalloc+0x42>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	add	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	add	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	add	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	add	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	e5c080e7          	jalr	-420(ra) # 80001a2e <mycpu>
    80000bda:	40a48533          	sub	a0,s1,a0
    80000bde:	00153513          	seqz	a0,a0
}
    80000be2:	60e2                	ld	ra,24(sp)
    80000be4:	6442                	ld	s0,16(sp)
    80000be6:	64a2                	ld	s1,8(sp)
    80000be8:	6105                	add	sp,sp,32
    80000bea:	8082                	ret

0000000080000bec <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bec:	1101                	add	sp,sp,-32
    80000bee:	ec06                	sd	ra,24(sp)
    80000bf0:	e822                	sd	s0,16(sp)
    80000bf2:	e426                	sd	s1,8(sp)
    80000bf4:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf6:	100024f3          	csrr	s1,sstatus
    80000bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfe:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c00:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	e2a080e7          	jalr	-470(ra) # 80001a2e <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e1e080e7          	jalr	-482(ra) # 80001a2e <mycpu>
    80000c18:	5d3c                	lw	a5,120(a0)
    80000c1a:	2785                	addw	a5,a5,1
    80000c1c:	dd3c                	sw	a5,120(a0)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	add	sp,sp,32
    80000c26:	8082                	ret
    mycpu()->intena = old;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	e06080e7          	jalr	-506(ra) # 80001a2e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c30:	8085                	srl	s1,s1,0x1
    80000c32:	8885                	and	s1,s1,1
    80000c34:	dd64                	sw	s1,124(a0)
    80000c36:	bfe9                	j	80000c10 <push_off+0x24>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	add	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	add	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	fa8080e7          	jalr	-88(ra) # 80000bec <push_off>
  if(holding(lk))
    80000c4c:	8526                	mv	a0,s1
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	f70080e7          	jalr	-144(ra) # 80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c56:	4705                	li	a4,1
  if(holding(lk))
    80000c58:	e115                	bnez	a0,80000c7c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5a:	87ba                	mv	a5,a4
    80000c5c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c60:	2781                	sext.w	a5,a5
    80000c62:	ffe5                	bnez	a5,80000c5a <acquire+0x22>
  __sync_synchronize();
    80000c64:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	dc6080e7          	jalr	-570(ra) # 80001a2e <mycpu>
    80000c70:	e888                	sd	a0,16(s1)
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	add	sp,sp,32
    80000c7a:	8082                	ret
    panic("acquire");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	3d450513          	add	a0,a0,980 # 80008050 <etext+0x50>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	add	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	00001097          	auipc	ra,0x1
    80000c98:	d9a080e7          	jalr	-614(ra) # 80001a2e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca0:	8b89                	and	a5,a5,2
  if(intr_get())
    80000ca2:	e78d                	bnez	a5,80000ccc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca4:	5d3c                	lw	a5,120(a0)
    80000ca6:	02f05b63          	blez	a5,80000cdc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000caa:	37fd                	addw	a5,a5,-1
    80000cac:	0007871b          	sext.w	a4,a5
    80000cb0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb2:	eb09                	bnez	a4,80000cc4 <pop_off+0x38>
    80000cb4:	5d7c                	lw	a5,124(a0)
    80000cb6:	c799                	beqz	a5,80000cc4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbc:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc4:	60a2                	ld	ra,8(sp)
    80000cc6:	6402                	ld	s0,0(sp)
    80000cc8:	0141                	add	sp,sp,16
    80000cca:	8082                	ret
    panic("pop_off - interruptible");
    80000ccc:	00007517          	auipc	a0,0x7
    80000cd0:	38c50513          	add	a0,a0,908 # 80008058 <etext+0x58>
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    panic("pop_off");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39450513          	add	a0,a0,916 # 80008070 <etext+0x70>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	87c080e7          	jalr	-1924(ra) # 80000560 <panic>

0000000080000cec <release>:
{
    80000cec:	1101                	add	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	add	s0,sp,32
    80000cf6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	ec6080e7          	jalr	-314(ra) # 80000bbe <holding>
    80000d00:	c115                	beqz	a0,80000d24 <release+0x38>
  lk->cpu = 0;
    80000d02:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d06:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d0a:	0f50000f          	fence	iorw,ow
    80000d0e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f7a080e7          	jalr	-134(ra) # 80000c8c <pop_off>
}
    80000d1a:	60e2                	ld	ra,24(sp)
    80000d1c:	6442                	ld	s0,16(sp)
    80000d1e:	64a2                	ld	s1,8(sp)
    80000d20:	6105                	add	sp,sp,32
    80000d22:	8082                	ret
    panic("release");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	35450513          	add	a0,a0,852 # 80008078 <etext+0x78>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080000d34 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d34:	1141                	add	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3a:	ca19                	beqz	a2,80000d50 <memset+0x1c>
    80000d3c:	87aa                	mv	a5,a0
    80000d3e:	1602                	sll	a2,a2,0x20
    80000d40:	9201                	srl	a2,a2,0x20
    80000d42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4a:	0785                	add	a5,a5,1
    80000d4c:	fee79de3          	bne	a5,a4,80000d46 <memset+0x12>
  }
  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d56:	1141                	add	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5c:	ca05                	beqz	a2,80000d8c <memcmp+0x36>
    80000d5e:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d62:	1682                	sll	a3,a3,0x20
    80000d64:	9281                	srl	a3,a3,0x20
    80000d66:	0685                	add	a3,a3,1
    80000d68:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	0005c703          	lbu	a4,0(a1)
    80000d72:	00e79863          	bne	a5,a4,80000d82 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d76:	0505                	add	a0,a0,1
    80000d78:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d7a:	fed518e3          	bne	a0,a3,80000d6a <memcmp+0x14>
  }

  return 0;
    80000d7e:	4501                	li	a0,0
    80000d80:	a019                	j	80000d86 <memcmp+0x30>
      return *s1 - *s2;
    80000d82:	40e7853b          	subw	a0,a5,a4
}
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	add	sp,sp,16
    80000d8a:	8082                	ret
  return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	bfe5                	j	80000d86 <memcmp+0x30>

0000000080000d90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d90:	1141                	add	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d96:	c205                	beqz	a2,80000db6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d98:	02a5e263          	bltu	a1,a0,80000dbc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9c:	1602                	sll	a2,a2,0x20
    80000d9e:	9201                	srl	a2,a2,0x20
    80000da0:	00c587b3          	add	a5,a1,a2
{
    80000da4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da6:	0585                	add	a1,a1,1
    80000da8:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd2b1>
    80000daa:	fff5c683          	lbu	a3,-1(a1)
    80000dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db2:	feb79ae3          	bne	a5,a1,80000da6 <memmove+0x16>

  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	add	sp,sp,16
    80000dba:	8082                	ret
  if(s < d && s + n > d){
    80000dbc:	02061693          	sll	a3,a2,0x20
    80000dc0:	9281                	srl	a3,a3,0x20
    80000dc2:	00d58733          	add	a4,a1,a3
    80000dc6:	fce57be3          	bgeu	a0,a4,80000d9c <memmove+0xc>
    d += n;
    80000dca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dcc:	fff6079b          	addw	a5,a2,-1
    80000dd0:	1782                	sll	a5,a5,0x20
    80000dd2:	9381                	srl	a5,a5,0x20
    80000dd4:	fff7c793          	not	a5,a5
    80000dd8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dda:	177d                	add	a4,a4,-1
    80000ddc:	16fd                	add	a3,a3,-1
    80000dde:	00074603          	lbu	a2,0(a4)
    80000de2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de6:	fef71ae3          	bne	a4,a5,80000dda <memmove+0x4a>
    80000dea:	b7f1                	j	80000db6 <memmove+0x26>

0000000080000dec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dec:	1141                	add	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000df4:	00000097          	auipc	ra,0x0
    80000df8:	f9c080e7          	jalr	-100(ra) # 80000d90 <memmove>
}
    80000dfc:	60a2                	ld	ra,8(sp)
    80000dfe:	6402                	ld	s0,0(sp)
    80000e00:	0141                	add	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e04:	1141                	add	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0a:	ce11                	beqz	a2,80000e26 <strncmp+0x22>
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf89                	beqz	a5,80000e2a <strncmp+0x26>
    80000e12:	0005c703          	lbu	a4,0(a1)
    80000e16:	00f71a63          	bne	a4,a5,80000e2a <strncmp+0x26>
    n--, p++, q++;
    80000e1a:	367d                	addw	a2,a2,-1
    80000e1c:	0505                	add	a0,a0,1
    80000e1e:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e20:	f675                	bnez	a2,80000e0c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	a801                	j	80000e34 <strncmp+0x30>
    80000e26:	4501                	li	a0,0
    80000e28:	a031                	j	80000e34 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	add	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	add	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	86b2                	mv	a3,a2
    80000e44:	367d                	addw	a2,a2,-1
    80000e46:	02d05563          	blez	a3,80000e70 <strncpy+0x36>
    80000e4a:	0785                	add	a5,a5,1
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	0585                	add	a1,a1,1
    80000e56:	f775                	bnez	a4,80000e42 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e58:	873e                	mv	a4,a5
    80000e5a:	9fb5                	addw	a5,a5,a3
    80000e5c:	37fd                	addw	a5,a5,-1
    80000e5e:	00c05963          	blez	a2,80000e70 <strncpy+0x36>
    *s++ = 0;
    80000e62:	0705                	add	a4,a4,1
    80000e64:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e68:	40e786bb          	subw	a3,a5,a4
    80000e6c:	fed04be3          	bgtz	a3,80000e62 <strncpy+0x28>
  return os;
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	add	sp,sp,16
    80000e74:	8082                	ret

0000000080000e76 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e76:	1141                	add	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7c:	02c05363          	blez	a2,80000ea2 <safestrcpy+0x2c>
    80000e80:	fff6069b          	addw	a3,a2,-1
    80000e84:	1682                	sll	a3,a3,0x20
    80000e86:	9281                	srl	a3,a3,0x20
    80000e88:	96ae                	add	a3,a3,a1
    80000e8a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8c:	00d58963          	beq	a1,a3,80000e9e <safestrcpy+0x28>
    80000e90:	0585                	add	a1,a1,1
    80000e92:	0785                	add	a5,a5,1
    80000e94:	fff5c703          	lbu	a4,-1(a1)
    80000e98:	fee78fa3          	sb	a4,-1(a5)
    80000e9c:	fb65                	bnez	a4,80000e8c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea2:	6422                	ld	s0,8(sp)
    80000ea4:	0141                	add	sp,sp,16
    80000ea6:	8082                	ret

0000000080000ea8 <strlen>:

int
strlen(const char *s)
{
    80000ea8:	1141                	add	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eae:	00054783          	lbu	a5,0(a0)
    80000eb2:	cf91                	beqz	a5,80000ece <strlen+0x26>
    80000eb4:	0505                	add	a0,a0,1
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	86be                	mv	a3,a5
    80000eba:	0785                	add	a5,a5,1
    80000ebc:	fff7c703          	lbu	a4,-1(a5)
    80000ec0:	ff65                	bnez	a4,80000eb8 <strlen+0x10>
    80000ec2:	40a6853b          	subw	a0,a3,a0
    80000ec6:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	add	sp,sp,16
    80000ecc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <strlen+0x20>

0000000080000ed2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed2:	1141                	add	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	b44080e7          	jalr	-1212(ra) # 80001a1e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	00008717          	auipc	a4,0x8
    80000ee6:	9d670713          	add	a4,a4,-1578 # 800088b8 <started>
  if(cpuid() == 0){
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while(started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	b28080e7          	jalr	-1240(ra) # 80001a1e <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	19850513          	add	a0,a0,408 # 80008098 <etext+0x98>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0d8080e7          	jalr	216(ra) # 80000fe8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f18:	00002097          	auipc	ra,0x2
    80000f1c:	936080e7          	jalr	-1738(ra) # 8000284e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	084080e7          	jalr	132(ra) # 80005fa4 <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	01e080e7          	jalr	30(ra) # 80001f46 <scheduler>
    consoleinit();
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	540080e7          	jalr	1344(ra) # 80000470 <consoleinit>
    printfinit();
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	87a080e7          	jalr	-1926(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f40:	00007517          	auipc	a0,0x7
    80000f44:	0d050513          	add	a0,a0,208 # 80008010 <etext+0x10>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	662080e7          	jalr	1634(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	13050513          	add	a0,a0,304 # 80008080 <etext+0x80>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	652080e7          	jalr	1618(ra) # 800005aa <printf>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	0b050513          	add	a0,a0,176 # 80008010 <etext+0x10>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	642080e7          	jalr	1602(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();       // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	326080e7          	jalr	806(ra) # 8000129e <kvminit>
    kvminithart();   // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	068080e7          	jalr	104(ra) # 80000fe8 <kvminithart>
    procinit();      // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	9d4080e7          	jalr	-1580(ra) # 8000195c <procinit>
    trapinit();      // trap vectors
    80000f90:	00002097          	auipc	ra,0x2
    80000f94:	896080e7          	jalr	-1898(ra) # 80002826 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00002097          	auipc	ra,0x2
    80000f9c:	8b6080e7          	jalr	-1866(ra) # 8000284e <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	fea080e7          	jalr	-22(ra) # 80005f8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	ffc080e7          	jalr	-4(ra) # 80005fa4 <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	0c4080e7          	jalr	196(ra) # 80003074 <binit>
    iinit();         // inode table
    80000fb8:	00002097          	auipc	ra,0x2
    80000fbc:	77a080e7          	jalr	1914(ra) # 80003732 <iinit>
    fileinit();      // file table
    80000fc0:	00003097          	auipc	ra,0x3
    80000fc4:	72a080e7          	jalr	1834(ra) # 800046ea <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	0e4080e7          	jalr	228(ra) # 800060ac <virtio_disk_init>
    userinit();      // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	d56080e7          	jalr	-682(ra) # 80001d26 <userinit>
    __sync_synchronize();
    80000fd8:	0ff0000f          	fence
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	00008717          	auipc	a4,0x8
    80000fe2:	8cf72d23          	sw	a5,-1830(a4) # 800088b8 <started>
    80000fe6:	b789                	j	80000f28 <main+0x56>

0000000080000fe8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe8:	1141                	add	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff2:	00008797          	auipc	a5,0x8
    80000ff6:	8ce7b783          	ld	a5,-1842(a5) # 800088c0 <kernel_pagetable>
    80000ffa:	83b1                	srl	a5,a5,0xc
    80000ffc:	577d                	li	a4,-1
    80000ffe:	177e                	sll	a4,a4,0x3f
    80001000:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001002:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001006:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100a:	6422                	ld	s0,8(sp)
    8000100c:	0141                	add	sp,sp,16
    8000100e:	8082                	ret

0000000080001010 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001010:	7139                	add	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	add	s0,sp,64
    80001024:	84aa                	mv	s1,a0
    80001026:	89ae                	mv	s3,a1
    80001028:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srl	a5,a5,0x1a
    8000102e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001030:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001032:	04b7f263          	bgeu	a5,a1,80001076 <walk+0x66>
    panic("walk");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	07a50513          	add	a0,a0,122 # 800080b0 <etext+0xb0>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	522080e7          	jalr	1314(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001046:	060a8663          	beqz	s5,800010b2 <walk+0xa2>
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	afe080e7          	jalr	-1282(ra) # 80000b48 <kalloc>
    80001052:	84aa                	mv	s1,a0
    80001054:	c529                	beqz	a0,8000109e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001056:	6605                	lui	a2,0x1
    80001058:	4581                	li	a1,0
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	cda080e7          	jalr	-806(ra) # 80000d34 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001062:	00c4d793          	srl	a5,s1,0xc
    80001066:	07aa                	sll	a5,a5,0xa
    80001068:	0017e793          	or	a5,a5,1
    8000106c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001070:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd2a7>
    80001072:	036a0063          	beq	s4,s6,80001092 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	and	s2,s2,511
    8000107e:	090e                	sll	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	and	a5,s1,1
    8000108a:	dfd5                	beqz	a5,80001046 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srl	s1,s1,0xa
    8000108e:	04b2                	sll	s1,s1,0xc
    80001090:	b7c5                	j	80001070 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001092:	00c9d513          	srl	a0,s3,0xc
    80001096:	1ff57513          	and	a0,a0,511
    8000109a:	050e                	sll	a0,a0,0x3
    8000109c:	9526                	add	a0,a0,s1
}
    8000109e:	70e2                	ld	ra,56(sp)
    800010a0:	7442                	ld	s0,48(sp)
    800010a2:	74a2                	ld	s1,40(sp)
    800010a4:	7902                	ld	s2,32(sp)
    800010a6:	69e2                	ld	s3,24(sp)
    800010a8:	6a42                	ld	s4,16(sp)
    800010aa:	6aa2                	ld	s5,8(sp)
    800010ac:	6b02                	ld	s6,0(sp)
    800010ae:	6121                	add	sp,sp,64
    800010b0:	8082                	ret
        return 0;
    800010b2:	4501                	li	a0,0
    800010b4:	b7ed                	j	8000109e <walk+0x8e>

00000000800010b6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b6:	57fd                	li	a5,-1
    800010b8:	83e9                	srl	a5,a5,0x1a
    800010ba:	00b7f463          	bgeu	a5,a1,800010c2 <walkaddr+0xc>
    return 0;
    800010be:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c0:	8082                	ret
{
    800010c2:	1141                	add	sp,sp,-16
    800010c4:	e406                	sd	ra,8(sp)
    800010c6:	e022                	sd	s0,0(sp)
    800010c8:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ca:	4601                	li	a2,0
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	f44080e7          	jalr	-188(ra) # 80001010 <walk>
  if(pte == 0)
    800010d4:	c105                	beqz	a0,800010f4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010d6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d8:	0117f693          	and	a3,a5,17
    800010dc:	4745                	li	a4,17
    return 0;
    800010de:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e0:	00e68663          	beq	a3,a4,800010ec <walkaddr+0x36>
}
    800010e4:	60a2                	ld	ra,8(sp)
    800010e6:	6402                	ld	s0,0(sp)
    800010e8:	0141                	add	sp,sp,16
    800010ea:	8082                	ret
  pa = PTE2PA(*pte);
    800010ec:	83a9                	srl	a5,a5,0xa
    800010ee:	00c79513          	sll	a0,a5,0xc
  return pa;
    800010f2:	bfcd                	j	800010e4 <walkaddr+0x2e>
    return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7fd                	j	800010e4 <walkaddr+0x2e>

00000000800010f8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f8:	715d                	add	sp,sp,-80
    800010fa:	e486                	sd	ra,72(sp)
    800010fc:	e0a2                	sd	s0,64(sp)
    800010fe:	fc26                	sd	s1,56(sp)
    80001100:	f84a                	sd	s2,48(sp)
    80001102:	f44e                	sd	s3,40(sp)
    80001104:	f052                	sd	s4,32(sp)
    80001106:	ec56                	sd	s5,24(sp)
    80001108:	e85a                	sd	s6,16(sp)
    8000110a:	e45e                	sd	s7,8(sp)
    8000110c:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000110e:	c639                	beqz	a2,8000115c <mappages+0x64>
    80001110:	8aaa                	mv	s5,a0
    80001112:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001114:	777d                	lui	a4,0xfffff
    80001116:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111a:	fff58993          	add	s3,a1,-1
    8000111e:	99b2                	add	s3,s3,a2
    80001120:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001124:	893e                	mv	s2,a5
    80001126:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112a:	6b85                	lui	s7,0x1
    8000112c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001130:	4605                	li	a2,1
    80001132:	85ca                	mv	a1,s2
    80001134:	8556                	mv	a0,s5
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	eda080e7          	jalr	-294(ra) # 80001010 <walk>
    8000113e:	cd1d                	beqz	a0,8000117c <mappages+0x84>
    if(*pte & PTE_V)
    80001140:	611c                	ld	a5,0(a0)
    80001142:	8b85                	and	a5,a5,1
    80001144:	e785                	bnez	a5,8000116c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001146:	80b1                	srl	s1,s1,0xc
    80001148:	04aa                	sll	s1,s1,0xa
    8000114a:	0164e4b3          	or	s1,s1,s6
    8000114e:	0014e493          	or	s1,s1,1
    80001152:	e104                	sd	s1,0(a0)
    if(a == last)
    80001154:	05390063          	beq	s2,s3,80001194 <mappages+0x9c>
    a += PGSIZE;
    80001158:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115a:	bfc9                	j	8000112c <mappages+0x34>
    panic("mappages: size");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f5c50513          	add	a0,a0,-164 # 800080b8 <etext+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3fc080e7          	jalr	1020(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	f5c50513          	add	a0,a0,-164 # 800080c8 <etext+0xc8>
    80001174:	fffff097          	auipc	ra,0xfffff
    80001178:	3ec080e7          	jalr	1004(ra) # 80000560 <panic>
      return -1;
    8000117c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117e:	60a6                	ld	ra,72(sp)
    80001180:	6406                	ld	s0,64(sp)
    80001182:	74e2                	ld	s1,56(sp)
    80001184:	7942                	ld	s2,48(sp)
    80001186:	79a2                	ld	s3,40(sp)
    80001188:	7a02                	ld	s4,32(sp)
    8000118a:	6ae2                	ld	s5,24(sp)
    8000118c:	6b42                	ld	s6,16(sp)
    8000118e:	6ba2                	ld	s7,8(sp)
    80001190:	6161                	add	sp,sp,80
    80001192:	8082                	ret
  return 0;
    80001194:	4501                	li	a0,0
    80001196:	b7e5                	j	8000117e <mappages+0x86>

0000000080001198 <kvmmap>:
{
    80001198:	1141                	add	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	add	s0,sp,16
    800011a0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a2:	86b2                	mv	a3,a2
    800011a4:	863e                	mv	a2,a5
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f52080e7          	jalr	-174(ra) # 800010f8 <mappages>
    800011ae:	e509                	bnez	a0,800011b8 <kvmmap+0x20>
}
    800011b0:	60a2                	ld	ra,8(sp)
    800011b2:	6402                	ld	s0,0(sp)
    800011b4:	0141                	add	sp,sp,16
    800011b6:	8082                	ret
    panic("kvmmap");
    800011b8:	00007517          	auipc	a0,0x7
    800011bc:	f2050513          	add	a0,a0,-224 # 800080d8 <etext+0xd8>
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	3a0080e7          	jalr	928(ra) # 80000560 <panic>

00000000800011c8 <kvmmake>:
{
    800011c8:	1101                	add	sp,sp,-32
    800011ca:	ec06                	sd	ra,24(sp)
    800011cc:	e822                	sd	s0,16(sp)
    800011ce:	e426                	sd	s1,8(sp)
    800011d0:	e04a                	sd	s2,0(sp)
    800011d2:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	974080e7          	jalr	-1676(ra) # 80000b48 <kalloc>
    800011dc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011de:	6605                	lui	a2,0x1
    800011e0:	4581                	li	a1,0
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	b52080e7          	jalr	-1198(ra) # 80000d34 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	6685                	lui	a3,0x1
    800011ee:	10000637          	lui	a2,0x10000
    800011f2:	100005b7          	lui	a1,0x10000
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	fa0080e7          	jalr	-96(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	6685                	lui	a3,0x1
    80001204:	10001637          	lui	a2,0x10001
    80001208:	100015b7          	lui	a1,0x10001
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f8a080e7          	jalr	-118(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	004006b7          	lui	a3,0x400
    8000121c:	0c000637          	lui	a2,0xc000
    80001220:	0c0005b7          	lui	a1,0xc000
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f72080e7          	jalr	-142(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000122e:	00007917          	auipc	s2,0x7
    80001232:	dd290913          	add	s2,s2,-558 # 80008000 <etext>
    80001236:	4729                	li	a4,10
    80001238:	80007697          	auipc	a3,0x80007
    8000123c:	dc868693          	add	a3,a3,-568 # 8000 <_entry-0x7fff8000>
    80001240:	4605                	li	a2,1
    80001242:	067e                	sll	a2,a2,0x1f
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f50080e7          	jalr	-176(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001250:	46c5                	li	a3,17
    80001252:	06ee                	sll	a3,a3,0x1b
    80001254:	4719                	li	a4,6
    80001256:	412686b3          	sub	a3,a3,s2
    8000125a:	864a                	mv	a2,s2
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8526                	mv	a0,s1
    80001260:	00000097          	auipc	ra,0x0
    80001264:	f38080e7          	jalr	-200(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001268:	4729                	li	a4,10
    8000126a:	6685                	lui	a3,0x1
    8000126c:	00006617          	auipc	a2,0x6
    80001270:	d9460613          	add	a2,a2,-620 # 80007000 <_trampoline>
    80001274:	040005b7          	lui	a1,0x4000
    80001278:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000127a:	05b2                	sll	a1,a1,0xc
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f1a080e7          	jalr	-230(ra) # 80001198 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001286:	8526                	mv	a0,s1
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	630080e7          	jalr	1584(ra) # 800018b8 <proc_mapstacks>
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6902                	ld	s2,0(sp)
    8000129a:	6105                	add	sp,sp,32
    8000129c:	8082                	ret

000000008000129e <kvminit>:
{
    8000129e:	1141                	add	sp,sp,-16
    800012a0:	e406                	sd	ra,8(sp)
    800012a2:	e022                	sd	s0,0(sp)
    800012a4:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f22080e7          	jalr	-222(ra) # 800011c8 <kvmmake>
    800012ae:	00007797          	auipc	a5,0x7
    800012b2:	60a7b923          	sd	a0,1554(a5) # 800088c0 <kernel_pagetable>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	add	sp,sp,16
    800012bc:	8082                	ret

00000000800012be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012be:	715d                	add	sp,sp,-80
    800012c0:	e486                	sd	ra,72(sp)
    800012c2:	e0a2                	sd	s0,64(sp)
    800012c4:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c6:	03459793          	sll	a5,a1,0x34
    800012ca:	e39d                	bnez	a5,800012f0 <uvmunmap+0x32>
    800012cc:	f84a                	sd	s2,48(sp)
    800012ce:	f44e                	sd	s3,40(sp)
    800012d0:	f052                	sd	s4,32(sp)
    800012d2:	ec56                	sd	s5,24(sp)
    800012d4:	e85a                	sd	s6,16(sp)
    800012d6:	e45e                	sd	s7,8(sp)
    800012d8:	8a2a                	mv	s4,a0
    800012da:	892e                	mv	s2,a1
    800012dc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	0632                	sll	a2,a2,0xc
    800012e0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	6b05                	lui	s6,0x1
    800012e8:	0935fb63          	bgeu	a1,s3,8000137e <uvmunmap+0xc0>
    800012ec:	fc26                	sd	s1,56(sp)
    800012ee:	a8a9                	j	80001348 <uvmunmap+0x8a>
    800012f0:	fc26                	sd	s1,56(sp)
    800012f2:	f84a                	sd	s2,48(sp)
    800012f4:	f44e                	sd	s3,40(sp)
    800012f6:	f052                	sd	s4,32(sp)
    800012f8:	ec56                	sd	s5,24(sp)
    800012fa:	e85a                	sd	s6,16(sp)
    800012fc:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	de250513          	add	a0,a0,-542 # 800080e0 <etext+0xe0>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	25a080e7          	jalr	602(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000130e:	00007517          	auipc	a0,0x7
    80001312:	dea50513          	add	a0,a0,-534 # 800080f8 <etext+0xf8>
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	24a080e7          	jalr	586(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000131e:	00007517          	auipc	a0,0x7
    80001322:	dea50513          	add	a0,a0,-534 # 80008108 <etext+0x108>
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	23a080e7          	jalr	570(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	df250513          	add	a0,a0,-526 # 80008120 <etext+0x120>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	22a080e7          	jalr	554(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000133e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001342:	995a                	add	s2,s2,s6
    80001344:	03397c63          	bgeu	s2,s3,8000137c <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001348:	4601                	li	a2,0
    8000134a:	85ca                	mv	a1,s2
    8000134c:	8552                	mv	a0,s4
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	cc2080e7          	jalr	-830(ra) # 80001010 <walk>
    80001356:	84aa                	mv	s1,a0
    80001358:	d95d                	beqz	a0,8000130e <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000135a:	6108                	ld	a0,0(a0)
    8000135c:	00157793          	and	a5,a0,1
    80001360:	dfdd                	beqz	a5,8000131e <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	3ff57793          	and	a5,a0,1023
    80001366:	fd7784e3          	beq	a5,s7,8000132e <uvmunmap+0x70>
    if(do_free){
    8000136a:	fc0a8ae3          	beqz	s5,8000133e <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000136e:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001370:	0532                	sll	a0,a0,0xc
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	6d8080e7          	jalr	1752(ra) # 80000a4a <kfree>
    8000137a:	b7d1                	j	8000133e <uvmunmap+0x80>
    8000137c:	74e2                	ld	s1,56(sp)
    8000137e:	7942                	ld	s2,48(sp)
    80001380:	79a2                	ld	s3,40(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6b42                	ld	s6,16(sp)
    80001388:	6ba2                	ld	s7,8(sp)
  }
}
    8000138a:	60a6                	ld	ra,72(sp)
    8000138c:	6406                	ld	s0,64(sp)
    8000138e:	6161                	add	sp,sp,80
    80001390:	8082                	ret

0000000080001392 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001392:	1101                	add	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	7ac080e7          	jalr	1964(ra) # 80000b48 <kalloc>
    800013a4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a6:	c519                	beqz	a0,800013b4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	988080e7          	jalr	-1656(ra) # 80000d34 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	add	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c0:	7179                	add	sp,sp,-48
    800013c2:	f406                	sd	ra,40(sp)
    800013c4:	f022                	sd	s0,32(sp)
    800013c6:	ec26                	sd	s1,24(sp)
    800013c8:	e84a                	sd	s2,16(sp)
    800013ca:	e44e                	sd	s3,8(sp)
    800013cc:	e052                	sd	s4,0(sp)
    800013ce:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d0:	6785                	lui	a5,0x1
    800013d2:	04f67863          	bgeu	a2,a5,80001422 <uvmfirst+0x62>
    800013d6:	8a2a                	mv	s4,a0
    800013d8:	89ae                	mv	s3,a1
    800013da:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	76c080e7          	jalr	1900(ra) # 80000b48 <kalloc>
    800013e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	94a080e7          	jalr	-1718(ra) # 80000d34 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f2:	4779                	li	a4,30
    800013f4:	86ca                	mv	a3,s2
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	8552                	mv	a0,s4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	cfc080e7          	jalr	-772(ra) # 800010f8 <mappages>
  memmove(mem, src, sz);
    80001404:	8626                	mv	a2,s1
    80001406:	85ce                	mv	a1,s3
    80001408:	854a                	mv	a0,s2
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	986080e7          	jalr	-1658(ra) # 80000d90 <memmove>
}
    80001412:	70a2                	ld	ra,40(sp)
    80001414:	7402                	ld	s0,32(sp)
    80001416:	64e2                	ld	s1,24(sp)
    80001418:	6942                	ld	s2,16(sp)
    8000141a:	69a2                	ld	s3,8(sp)
    8000141c:	6a02                	ld	s4,0(sp)
    8000141e:	6145                	add	sp,sp,48
    80001420:	8082                	ret
    panic("uvmfirst: more than a page");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d1650513          	add	a0,a0,-746 # 80008138 <etext+0x138>
    8000142a:	fffff097          	auipc	ra,0xfffff
    8000142e:	136080e7          	jalr	310(ra) # 80000560 <panic>

0000000080001432 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001432:	1101                	add	sp,sp,-32
    80001434:	ec06                	sd	ra,24(sp)
    80001436:	e822                	sd	s0,16(sp)
    80001438:	e426                	sd	s1,8(sp)
    8000143a:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143e:	00b67d63          	bgeu	a2,a1,80001458 <uvmdealloc+0x26>
    80001442:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001448:	00f60733          	add	a4,a2,a5
    8000144c:	76fd                	lui	a3,0xfffff
    8000144e:	8f75                	and	a4,a4,a3
    80001450:	97ae                	add	a5,a5,a1
    80001452:	8ff5                	and	a5,a5,a3
    80001454:	00f76863          	bltu	a4,a5,80001464 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001458:	8526                	mv	a0,s1
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	add	sp,sp,32
    80001462:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001464:	8f99                	sub	a5,a5,a4
    80001466:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001468:	4685                	li	a3,1
    8000146a:	0007861b          	sext.w	a2,a5
    8000146e:	85ba                	mv	a1,a4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	e4e080e7          	jalr	-434(ra) # 800012be <uvmunmap>
    80001478:	b7c5                	j	80001458 <uvmdealloc+0x26>

000000008000147a <uvmalloc>:
  if(newsz < oldsz)
    8000147a:	0ab66b63          	bltu	a2,a1,80001530 <uvmalloc+0xb6>
{
    8000147e:	7139                	add	sp,sp,-64
    80001480:	fc06                	sd	ra,56(sp)
    80001482:	f822                	sd	s0,48(sp)
    80001484:	ec4e                	sd	s3,24(sp)
    80001486:	e852                	sd	s4,16(sp)
    80001488:	e456                	sd	s5,8(sp)
    8000148a:	0080                	add	s0,sp,64
    8000148c:	8aaa                	mv	s5,a0
    8000148e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	77fd                	lui	a5,0xfffff
    80001498:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149c:	08c9fc63          	bgeu	s3,a2,80001534 <uvmalloc+0xba>
    800014a0:	f426                	sd	s1,40(sp)
    800014a2:	f04a                	sd	s2,32(sp)
    800014a4:	e05a                	sd	s6,0(sp)
    800014a6:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014a8:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	69c080e7          	jalr	1692(ra) # 80000b48 <kalloc>
    800014b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b6:	c915                	beqz	a0,800014ea <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014b8:	6605                	lui	a2,0x1
    800014ba:	4581                	li	a1,0
    800014bc:	00000097          	auipc	ra,0x0
    800014c0:	878080e7          	jalr	-1928(ra) # 80000d34 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c4:	875a                	mv	a4,s6
    800014c6:	86a6                	mv	a3,s1
    800014c8:	6605                	lui	a2,0x1
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	c2a080e7          	jalr	-982(ra) # 800010f8 <mappages>
    800014d6:	ed05                	bnez	a0,8000150e <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d8:	6785                	lui	a5,0x1
    800014da:	993e                	add	s2,s2,a5
    800014dc:	fd4968e3          	bltu	s2,s4,800014ac <uvmalloc+0x32>
  return newsz;
    800014e0:	8552                	mv	a0,s4
    800014e2:	74a2                	ld	s1,40(sp)
    800014e4:	7902                	ld	s2,32(sp)
    800014e6:	6b02                	ld	s6,0(sp)
    800014e8:	a821                	j	80001500 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014ea:	864e                	mv	a2,s3
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8556                	mv	a0,s5
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	f42080e7          	jalr	-190(ra) # 80001432 <uvmdealloc>
      return 0;
    800014f8:	4501                	li	a0,0
    800014fa:	74a2                	ld	s1,40(sp)
    800014fc:	7902                	ld	s2,32(sp)
    800014fe:	6b02                	ld	s6,0(sp)
}
    80001500:	70e2                	ld	ra,56(sp)
    80001502:	7442                	ld	s0,48(sp)
    80001504:	69e2                	ld	s3,24(sp)
    80001506:	6a42                	ld	s4,16(sp)
    80001508:	6aa2                	ld	s5,8(sp)
    8000150a:	6121                	add	sp,sp,64
    8000150c:	8082                	ret
      kfree(mem);
    8000150e:	8526                	mv	a0,s1
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	53a080e7          	jalr	1338(ra) # 80000a4a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	864e                	mv	a2,s3
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f14080e7          	jalr	-236(ra) # 80001432 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74a2                	ld	s1,40(sp)
    8000152a:	7902                	ld	s2,32(sp)
    8000152c:	6b02                	ld	s6,0(sp)
    8000152e:	bfc9                	j	80001500 <uvmalloc+0x86>
    return oldsz;
    80001530:	852e                	mv	a0,a1
}
    80001532:	8082                	ret
  return newsz;
    80001534:	8532                	mv	a0,a2
    80001536:	b7e9                	j	80001500 <uvmalloc+0x86>

0000000080001538 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001538:	7179                	add	sp,sp,-48
    8000153a:	f406                	sd	ra,40(sp)
    8000153c:	f022                	sd	s0,32(sp)
    8000153e:	ec26                	sd	s1,24(sp)
    80001540:	e84a                	sd	s2,16(sp)
    80001542:	e44e                	sd	s3,8(sp)
    80001544:	e052                	sd	s4,0(sp)
    80001546:	1800                	add	s0,sp,48
    80001548:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154a:	84aa                	mv	s1,a0
    8000154c:	6905                	lui	s2,0x1
    8000154e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001550:	4985                	li	s3,1
    80001552:	a829                	j	8000156c <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001554:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001556:	00c79513          	sll	a0,a5,0xc
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	fde080e7          	jalr	-34(ra) # 80001538 <freewalk>
      pagetable[i] = 0;
    80001562:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001566:	04a1                	add	s1,s1,8
    80001568:	03248163          	beq	s1,s2,8000158a <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156e:	00f7f713          	and	a4,a5,15
    80001572:	ff3701e3          	beq	a4,s3,80001554 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001576:	8b85                	and	a5,a5,1
    80001578:	d7fd                	beqz	a5,80001566 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000157a:	00007517          	auipc	a0,0x7
    8000157e:	bde50513          	add	a0,a0,-1058 # 80008158 <etext+0x158>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fde080e7          	jalr	-34(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    8000158a:	8552                	mv	a0,s4
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	4be080e7          	jalr	1214(ra) # 80000a4a <kfree>
}
    80001594:	70a2                	ld	ra,40(sp)
    80001596:	7402                	ld	s0,32(sp)
    80001598:	64e2                	ld	s1,24(sp)
    8000159a:	6942                	ld	s2,16(sp)
    8000159c:	69a2                	ld	s3,8(sp)
    8000159e:	6a02                	ld	s4,0(sp)
    800015a0:	6145                	add	sp,sp,48
    800015a2:	8082                	ret

00000000800015a4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a4:	1101                	add	sp,sp,-32
    800015a6:	ec06                	sd	ra,24(sp)
    800015a8:	e822                	sd	s0,16(sp)
    800015aa:	e426                	sd	s1,8(sp)
    800015ac:	1000                	add	s0,sp,32
    800015ae:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b0:	e999                	bnez	a1,800015c6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b2:	8526                	mv	a0,s1
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	f84080e7          	jalr	-124(ra) # 80001538 <freewalk>
}
    800015bc:	60e2                	ld	ra,24(sp)
    800015be:	6442                	ld	s0,16(sp)
    800015c0:	64a2                	ld	s1,8(sp)
    800015c2:	6105                	add	sp,sp,32
    800015c4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c6:	6785                	lui	a5,0x1
    800015c8:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015ca:	95be                	add	a1,a1,a5
    800015cc:	4685                	li	a3,1
    800015ce:	00c5d613          	srl	a2,a1,0xc
    800015d2:	4581                	li	a1,0
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	cea080e7          	jalr	-790(ra) # 800012be <uvmunmap>
    800015dc:	bfd9                	j	800015b2 <uvmfree+0xe>

00000000800015de <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015de:	c679                	beqz	a2,800016ac <uvmcopy+0xce>
{
    800015e0:	715d                	add	sp,sp,-80
    800015e2:	e486                	sd	ra,72(sp)
    800015e4:	e0a2                	sd	s0,64(sp)
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    800015f4:	0880                	add	s0,sp,80
    800015f6:	8b2a                	mv	s6,a0
    800015f8:	8aae                	mv	s5,a1
    800015fa:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fc:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015fe:	4601                	li	a2,0
    80001600:	85ce                	mv	a1,s3
    80001602:	855a                	mv	a0,s6
    80001604:	00000097          	auipc	ra,0x0
    80001608:	a0c080e7          	jalr	-1524(ra) # 80001010 <walk>
    8000160c:	c531                	beqz	a0,80001658 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160e:	6118                	ld	a4,0(a0)
    80001610:	00177793          	and	a5,a4,1
    80001614:	cbb1                	beqz	a5,80001668 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001616:	00a75593          	srl	a1,a4,0xa
    8000161a:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000161e:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	526080e7          	jalr	1318(ra) # 80000b48 <kalloc>
    8000162a:	892a                	mv	s2,a0
    8000162c:	c939                	beqz	a0,80001682 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162e:	6605                	lui	a2,0x1
    80001630:	85de                	mv	a1,s7
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	75e080e7          	jalr	1886(ra) # 80000d90 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163a:	8726                	mv	a4,s1
    8000163c:	86ca                	mv	a3,s2
    8000163e:	6605                	lui	a2,0x1
    80001640:	85ce                	mv	a1,s3
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	ab4080e7          	jalr	-1356(ra) # 800010f8 <mappages>
    8000164c:	e515                	bnez	a0,80001678 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	6785                	lui	a5,0x1
    80001650:	99be                	add	s3,s3,a5
    80001652:	fb49e6e3          	bltu	s3,s4,800015fe <uvmcopy+0x20>
    80001656:	a081                	j	80001696 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b1050513          	add	a0,a0,-1264 # 80008168 <etext+0x168>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	f00080e7          	jalr	-256(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b2050513          	add	a0,a0,-1248 # 80008188 <etext+0x188>
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	ef0080e7          	jalr	-272(ra) # 80000560 <panic>
      kfree(mem);
    80001678:	854a                	mv	a0,s2
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	3d0080e7          	jalr	976(ra) # 80000a4a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001682:	4685                	li	a3,1
    80001684:	00c9d613          	srl	a2,s3,0xc
    80001688:	4581                	li	a1,0
    8000168a:	8556                	mv	a0,s5
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	c32080e7          	jalr	-974(ra) # 800012be <uvmunmap>
  return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6161                	add	sp,sp,80
    800016aa:	8082                	ret
  return 0;
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret

00000000800016b0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b0:	1141                	add	sp,sp,-16
    800016b2:	e406                	sd	ra,8(sp)
    800016b4:	e022                	sd	s0,0(sp)
    800016b6:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b8:	4601                	li	a2,0
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	956080e7          	jalr	-1706(ra) # 80001010 <walk>
  if(pte == 0)
    800016c2:	c901                	beqz	a0,800016d2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c4:	611c                	ld	a5,0(a0)
    800016c6:	9bbd                	and	a5,a5,-17
    800016c8:	e11c                	sd	a5,0(a0)
}
    800016ca:	60a2                	ld	ra,8(sp)
    800016cc:	6402                	ld	s0,0(sp)
    800016ce:	0141                	add	sp,sp,16
    800016d0:	8082                	ret
    panic("uvmclear");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	ad650513          	add	a0,a0,-1322 # 800081a8 <etext+0x1a8>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e86080e7          	jalr	-378(ra) # 80000560 <panic>

00000000800016e2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	c6bd                	beqz	a3,80001750 <copyout+0x6e>
{
    800016e4:	715d                	add	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	add	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8c2e                	mv	s8,a1
    80001700:	8a32                	mv	s4,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a015                	j	8000172c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170a:	9562                	add	a0,a0,s8
    8000170c:	0004861b          	sext.w	a2,s1
    80001710:	85d2                	mv	a1,s4
    80001712:	41250533          	sub	a0,a0,s2
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	67a080e7          	jalr	1658(ra) # 80000d90 <memmove>

    len -= n;
    8000171e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001722:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001724:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001728:	02098263          	beqz	s3,8000174c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001730:	85ca                	mv	a1,s2
    80001732:	855a                	mv	a0,s6
    80001734:	00000097          	auipc	ra,0x0
    80001738:	982080e7          	jalr	-1662(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    8000173c:	cd01                	beqz	a0,80001754 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000173e:	418904b3          	sub	s1,s2,s8
    80001742:	94d6                	add	s1,s1,s5
    if(n > len)
    80001744:	fc99f3e3          	bgeu	s3,s1,8000170a <copyout+0x28>
    80001748:	84ce                	mv	s1,s3
    8000174a:	b7c1                	j	8000170a <copyout+0x28>
  }
  return 0;
    8000174c:	4501                	li	a0,0
    8000174e:	a021                	j	80001756 <copyout+0x74>
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret
      return -1;
    80001754:	557d                	li	a0,-1
}
    80001756:	60a6                	ld	ra,72(sp)
    80001758:	6406                	ld	s0,64(sp)
    8000175a:	74e2                	ld	s1,56(sp)
    8000175c:	7942                	ld	s2,48(sp)
    8000175e:	79a2                	ld	s3,40(sp)
    80001760:	7a02                	ld	s4,32(sp)
    80001762:	6ae2                	ld	s5,24(sp)
    80001764:	6b42                	ld	s6,16(sp)
    80001766:	6ba2                	ld	s7,8(sp)
    80001768:	6c02                	ld	s8,0(sp)
    8000176a:	6161                	add	sp,sp,80
    8000176c:	8082                	ret

000000008000176e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000176e:	caa5                	beqz	a3,800017de <copyin+0x70>
{
    80001770:	715d                	add	sp,sp,-80
    80001772:	e486                	sd	ra,72(sp)
    80001774:	e0a2                	sd	s0,64(sp)
    80001776:	fc26                	sd	s1,56(sp)
    80001778:	f84a                	sd	s2,48(sp)
    8000177a:	f44e                	sd	s3,40(sp)
    8000177c:	f052                	sd	s4,32(sp)
    8000177e:	ec56                	sd	s5,24(sp)
    80001780:	e85a                	sd	s6,16(sp)
    80001782:	e45e                	sd	s7,8(sp)
    80001784:	e062                	sd	s8,0(sp)
    80001786:	0880                	add	s0,sp,80
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8a2e                	mv	s4,a1
    8000178c:	8c32                	mv	s8,a2
    8000178e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6a85                	lui	s5,0x1
    80001794:	a01d                	j	800017ba <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001796:	018505b3          	add	a1,a0,s8
    8000179a:	0004861b          	sext.w	a2,s1
    8000179e:	412585b3          	sub	a1,a1,s2
    800017a2:	8552                	mv	a0,s4
    800017a4:	fffff097          	auipc	ra,0xfffff
    800017a8:	5ec080e7          	jalr	1516(ra) # 80000d90 <memmove>

    len -= n;
    800017ac:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b6:	02098263          	beqz	s3,800017da <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017be:	85ca                	mv	a1,s2
    800017c0:	855a                	mv	a0,s6
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	8f4080e7          	jalr	-1804(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    800017ca:	cd01                	beqz	a0,800017e2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017cc:	418904b3          	sub	s1,s2,s8
    800017d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d2:	fc99f2e3          	bgeu	s3,s1,80001796 <copyin+0x28>
    800017d6:	84ce                	mv	s1,s3
    800017d8:	bf7d                	j	80001796 <copyin+0x28>
  }
  return 0;
    800017da:	4501                	li	a0,0
    800017dc:	a021                	j	800017e4 <copyin+0x76>
    800017de:	4501                	li	a0,0
}
    800017e0:	8082                	ret
      return -1;
    800017e2:	557d                	li	a0,-1
}
    800017e4:	60a6                	ld	ra,72(sp)
    800017e6:	6406                	ld	s0,64(sp)
    800017e8:	74e2                	ld	s1,56(sp)
    800017ea:	7942                	ld	s2,48(sp)
    800017ec:	79a2                	ld	s3,40(sp)
    800017ee:	7a02                	ld	s4,32(sp)
    800017f0:	6ae2                	ld	s5,24(sp)
    800017f2:	6b42                	ld	s6,16(sp)
    800017f4:	6ba2                	ld	s7,8(sp)
    800017f6:	6c02                	ld	s8,0(sp)
    800017f8:	6161                	add	sp,sp,80
    800017fa:	8082                	ret

00000000800017fc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fc:	cacd                	beqz	a3,800018ae <copyinstr+0xb2>
{
    800017fe:	715d                	add	sp,sp,-80
    80001800:	e486                	sd	ra,72(sp)
    80001802:	e0a2                	sd	s0,64(sp)
    80001804:	fc26                	sd	s1,56(sp)
    80001806:	f84a                	sd	s2,48(sp)
    80001808:	f44e                	sd	s3,40(sp)
    8000180a:	f052                	sd	s4,32(sp)
    8000180c:	ec56                	sd	s5,24(sp)
    8000180e:	e85a                	sd	s6,16(sp)
    80001810:	e45e                	sd	s7,8(sp)
    80001812:	0880                	add	s0,sp,80
    80001814:	8a2a                	mv	s4,a0
    80001816:	8b2e                	mv	s6,a1
    80001818:	8bb2                	mv	s7,a2
    8000181a:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000181c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000181e:	6985                	lui	s3,0x1
    80001820:	a825                	j	80001858 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001822:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001826:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001828:	37fd                	addw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000182e:	60a6                	ld	ra,72(sp)
    80001830:	6406                	ld	s0,64(sp)
    80001832:	74e2                	ld	s1,56(sp)
    80001834:	7942                	ld	s2,48(sp)
    80001836:	79a2                	ld	s3,40(sp)
    80001838:	7a02                	ld	s4,32(sp)
    8000183a:	6ae2                	ld	s5,24(sp)
    8000183c:	6b42                	ld	s6,16(sp)
    8000183e:	6ba2                	ld	s7,8(sp)
    80001840:	6161                	add	sp,sp,80
    80001842:	8082                	ret
    80001844:	fff90713          	add	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001848:	9742                	add	a4,a4,a6
      --max;
    8000184a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000184e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001852:	04e58663          	beq	a1,a4,8000189e <copyinstr+0xa2>
{
    80001856:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001858:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185c:	85a6                	mv	a1,s1
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	856080e7          	jalr	-1962(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    80001868:	cd0d                	beqz	a0,800018a2 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000186a:	417486b3          	sub	a3,s1,s7
    8000186e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001870:	00d97363          	bgeu	s2,a3,80001876 <copyinstr+0x7a>
    80001874:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001876:	955e                	add	a0,a0,s7
    80001878:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000187a:	c695                	beqz	a3,800018a6 <copyinstr+0xaa>
    8000187c:	87da                	mv	a5,s6
    8000187e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001880:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001884:	96da                	add	a3,a3,s6
    80001886:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001888:	00f60733          	add	a4,a2,a5
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd2b0>
    80001890:	db49                	beqz	a4,80001822 <copyinstr+0x26>
        *dst = *p;
    80001892:	00e78023          	sb	a4,0(a5)
      dst++;
    80001896:	0785                	add	a5,a5,1
    while(n > 0){
    80001898:	fed797e3          	bne	a5,a3,80001886 <copyinstr+0x8a>
    8000189c:	b765                	j	80001844 <copyinstr+0x48>
    8000189e:	4781                	li	a5,0
    800018a0:	b761                	j	80001828 <copyinstr+0x2c>
      return -1;
    800018a2:	557d                	li	a0,-1
    800018a4:	b769                	j	8000182e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018a6:	6b85                	lui	s7,0x1
    800018a8:	9ba6                	add	s7,s7,s1
    800018aa:	87da                	mv	a5,s6
    800018ac:	b76d                	j	80001856 <copyinstr+0x5a>
  int got_null = 0;
    800018ae:	4781                	li	a5,0
  if(got_null){
    800018b0:	37fd                	addw	a5,a5,-1
    800018b2:	0007851b          	sext.w	a0,a5
}
    800018b6:	8082                	ret

00000000800018b8 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018b8:	7139                	add	sp,sp,-64
    800018ba:	fc06                	sd	ra,56(sp)
    800018bc:	f822                	sd	s0,48(sp)
    800018be:	f426                	sd	s1,40(sp)
    800018c0:	f04a                	sd	s2,32(sp)
    800018c2:	ec4e                	sd	s3,24(sp)
    800018c4:	e852                	sd	s4,16(sp)
    800018c6:	e456                	sd	s5,8(sp)
    800018c8:	e05a                	sd	s6,0(sp)
    800018ca:	0080                	add	s0,sp,64
    800018cc:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ce:	0000f497          	auipc	s1,0xf
    800018d2:	6a248493          	add	s1,s1,1698 # 80010f70 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018d6:	8b26                	mv	s6,s1
    800018d8:	04fa5937          	lui	s2,0x4fa5
    800018dc:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800018e0:	0932                	sll	s2,s2,0xc
    800018e2:	fa590913          	add	s2,s2,-91
    800018e6:	0932                	sll	s2,s2,0xc
    800018e8:	fa590913          	add	s2,s2,-91
    800018ec:	0932                	sll	s2,s2,0xc
    800018ee:	fa590913          	add	s2,s2,-91
    800018f2:	040009b7          	lui	s3,0x4000
    800018f6:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018f8:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fa:	00015a97          	auipc	s5,0x15
    800018fe:	076a8a93          	add	s5,s5,118 # 80016970 <tickslock>
    char *pa = kalloc();
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	246080e7          	jalr	582(ra) # 80000b48 <kalloc>
    8000190a:	862a                	mv	a2,a0
    if(pa == 0)
    8000190c:	c121                	beqz	a0,8000194c <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    8000190e:	416485b3          	sub	a1,s1,s6
    80001912:	858d                	sra	a1,a1,0x3
    80001914:	032585b3          	mul	a1,a1,s2
    80001918:	2585                	addw	a1,a1,1
    8000191a:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000191e:	4719                	li	a4,6
    80001920:	6685                	lui	a3,0x1
    80001922:	40b985b3          	sub	a1,s3,a1
    80001926:	8552                	mv	a0,s4
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	870080e7          	jalr	-1936(ra) # 80001198 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001930:	16848493          	add	s1,s1,360
    80001934:	fd5497e3          	bne	s1,s5,80001902 <proc_mapstacks+0x4a>
  }
}
    80001938:	70e2                	ld	ra,56(sp)
    8000193a:	7442                	ld	s0,48(sp)
    8000193c:	74a2                	ld	s1,40(sp)
    8000193e:	7902                	ld	s2,32(sp)
    80001940:	69e2                	ld	s3,24(sp)
    80001942:	6a42                	ld	s4,16(sp)
    80001944:	6aa2                	ld	s5,8(sp)
    80001946:	6b02                	ld	s6,0(sp)
    80001948:	6121                	add	sp,sp,64
    8000194a:	8082                	ret
      panic("kalloc");
    8000194c:	00007517          	auipc	a0,0x7
    80001950:	86c50513          	add	a0,a0,-1940 # 800081b8 <etext+0x1b8>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	c0c080e7          	jalr	-1012(ra) # 80000560 <panic>

000000008000195c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000195c:	7139                	add	sp,sp,-64
    8000195e:	fc06                	sd	ra,56(sp)
    80001960:	f822                	sd	s0,48(sp)
    80001962:	f426                	sd	s1,40(sp)
    80001964:	f04a                	sd	s2,32(sp)
    80001966:	ec4e                	sd	s3,24(sp)
    80001968:	e852                	sd	s4,16(sp)
    8000196a:	e456                	sd	s5,8(sp)
    8000196c:	e05a                	sd	s6,0(sp)
    8000196e:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001970:	00007597          	auipc	a1,0x7
    80001974:	85058593          	add	a1,a1,-1968 # 800081c0 <etext+0x1c0>
    80001978:	0000f517          	auipc	a0,0xf
    8000197c:	1c850513          	add	a0,a0,456 # 80010b40 <pid_lock>
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	228080e7          	jalr	552(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001988:	00007597          	auipc	a1,0x7
    8000198c:	84058593          	add	a1,a1,-1984 # 800081c8 <etext+0x1c8>
    80001990:	0000f517          	auipc	a0,0xf
    80001994:	1c850513          	add	a0,a0,456 # 80010b58 <wait_lock>
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	210080e7          	jalr	528(ra) # 80000ba8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	0000f497          	auipc	s1,0xf
    800019a4:	5d048493          	add	s1,s1,1488 # 80010f70 <proc>
      initlock(&p->lock, "proc");
    800019a8:	00007b17          	auipc	s6,0x7
    800019ac:	830b0b13          	add	s6,s6,-2000 # 800081d8 <etext+0x1d8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));    
    800019b0:	8aa6                	mv	s5,s1
    800019b2:	04fa5937          	lui	s2,0x4fa5
    800019b6:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800019ba:	0932                	sll	s2,s2,0xc
    800019bc:	fa590913          	add	s2,s2,-91
    800019c0:	0932                	sll	s2,s2,0xc
    800019c2:	fa590913          	add	s2,s2,-91
    800019c6:	0932                	sll	s2,s2,0xc
    800019c8:	fa590913          	add	s2,s2,-91
    800019cc:	040009b7          	lui	s3,0x4000
    800019d0:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019d2:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	00015a17          	auipc	s4,0x15
    800019d8:	f9ca0a13          	add	s4,s4,-100 # 80016970 <tickslock>
      initlock(&p->lock, "proc");
    800019dc:	85da                	mv	a1,s6
    800019de:	8526                	mv	a0,s1
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	1c8080e7          	jalr	456(ra) # 80000ba8 <initlock>
      p->state = UNUSED;
    800019e8:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));    
    800019ec:	415487b3          	sub	a5,s1,s5
    800019f0:	878d                	sra	a5,a5,0x3
    800019f2:	032787b3          	mul	a5,a5,s2
    800019f6:	2785                	addw	a5,a5,1
    800019f8:	00d7979b          	sllw	a5,a5,0xd
    800019fc:	40f987b3          	sub	a5,s3,a5
    80001a00:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a02:	16848493          	add	s1,s1,360
    80001a06:	fd449be3          	bne	s1,s4,800019dc <procinit+0x80>
  }
}
    80001a0a:	70e2                	ld	ra,56(sp)
    80001a0c:	7442                	ld	s0,48(sp)
    80001a0e:	74a2                	ld	s1,40(sp)
    80001a10:	7902                	ld	s2,32(sp)
    80001a12:	69e2                	ld	s3,24(sp)
    80001a14:	6a42                	ld	s4,16(sp)
    80001a16:	6aa2                	ld	s5,8(sp)
    80001a18:	6b02                	ld	s6,0(sp)
    80001a1a:	6121                	add	sp,sp,64
    80001a1c:	8082                	ret

0000000080001a1e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a1e:	1141                	add	sp,sp,-16
    80001a20:	e422                	sd	s0,8(sp)
    80001a22:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a24:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a26:	2501                	sext.w	a0,a0
    80001a28:	6422                	ld	s0,8(sp)
    80001a2a:	0141                	add	sp,sp,16
    80001a2c:	8082                	ret

0000000080001a2e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a2e:	1141                	add	sp,sp,-16
    80001a30:	e422                	sd	s0,8(sp)
    80001a32:	0800                	add	s0,sp,16
    80001a34:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a36:	2781                	sext.w	a5,a5
    80001a38:	079e                	sll	a5,a5,0x7
  return c;
}
    80001a3a:	0000f517          	auipc	a0,0xf
    80001a3e:	13650513          	add	a0,a0,310 # 80010b70 <cpus>
    80001a42:	953e                	add	a0,a0,a5
    80001a44:	6422                	ld	s0,8(sp)
    80001a46:	0141                	add	sp,sp,16
    80001a48:	8082                	ret

0000000080001a4a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a4a:	1101                	add	sp,sp,-32
    80001a4c:	ec06                	sd	ra,24(sp)
    80001a4e:	e822                	sd	s0,16(sp)
    80001a50:	e426                	sd	s1,8(sp)
    80001a52:	1000                	add	s0,sp,32
  push_off();
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	198080e7          	jalr	408(ra) # 80000bec <push_off>
    80001a5c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a5e:	2781                	sext.w	a5,a5
    80001a60:	079e                	sll	a5,a5,0x7
    80001a62:	0000f717          	auipc	a4,0xf
    80001a66:	0de70713          	add	a4,a4,222 # 80010b40 <pid_lock>
    80001a6a:	97ba                	add	a5,a5,a4
    80001a6c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	21e080e7          	jalr	542(ra) # 80000c8c <pop_off>
  return p;
}
    80001a76:	8526                	mv	a0,s1
    80001a78:	60e2                	ld	ra,24(sp)
    80001a7a:	6442                	ld	s0,16(sp)
    80001a7c:	64a2                	ld	s1,8(sp)
    80001a7e:	6105                	add	sp,sp,32
    80001a80:	8082                	ret

0000000080001a82 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a82:	1141                	add	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a8a:	00000097          	auipc	ra,0x0
    80001a8e:	fc0080e7          	jalr	-64(ra) # 80001a4a <myproc>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	25a080e7          	jalr	602(ra) # 80000cec <release>

  if (first) {
    80001a9a:	00007797          	auipc	a5,0x7
    80001a9e:	db67a783          	lw	a5,-586(a5) # 80008850 <first.1>
    80001aa2:	eb89                	bnez	a5,80001ab4 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aa4:	00001097          	auipc	ra,0x1
    80001aa8:	dc2080e7          	jalr	-574(ra) # 80002866 <usertrapret>
}
    80001aac:	60a2                	ld	ra,8(sp)
    80001aae:	6402                	ld	s0,0(sp)
    80001ab0:	0141                	add	sp,sp,16
    80001ab2:	8082                	ret
    first = 0;
    80001ab4:	00007797          	auipc	a5,0x7
    80001ab8:	d807ae23          	sw	zero,-612(a5) # 80008850 <first.1>
    fsinit(ROOTDEV);
    80001abc:	4505                	li	a0,1
    80001abe:	00002097          	auipc	ra,0x2
    80001ac2:	bf4080e7          	jalr	-1036(ra) # 800036b2 <fsinit>
    80001ac6:	bff9                	j	80001aa4 <forkret+0x22>

0000000080001ac8 <allocpid>:
{
    80001ac8:	1101                	add	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	e04a                	sd	s2,0(sp)
    80001ad2:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001ad4:	0000f917          	auipc	s2,0xf
    80001ad8:	06c90913          	add	s2,s2,108 # 80010b40 <pid_lock>
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	15a080e7          	jalr	346(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001ae6:	00007797          	auipc	a5,0x7
    80001aea:	d6e78793          	add	a5,a5,-658 # 80008854 <nextpid>
    80001aee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af0:	0014871b          	addw	a4,s1,1
    80001af4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001af6:	854a                	mv	a0,s2
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	1f4080e7          	jalr	500(ra) # 80000cec <release>
}
    80001b00:	8526                	mv	a0,s1
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6902                	ld	s2,0(sp)
    80001b0a:	6105                	add	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <proc_pagetable>:
{
    80001b0e:	1101                	add	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	add	s0,sp,32
    80001b1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	876080e7          	jalr	-1930(ra) # 80001392 <uvmcreate>
    80001b24:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b26:	c121                	beqz	a0,80001b66 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b28:	4729                	li	a4,10
    80001b2a:	00005697          	auipc	a3,0x5
    80001b2e:	4d668693          	add	a3,a3,1238 # 80007000 <_trampoline>
    80001b32:	6605                	lui	a2,0x1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b3a:	05b2                	sll	a1,a1,0xc
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	5bc080e7          	jalr	1468(ra) # 800010f8 <mappages>
    80001b44:	02054863          	bltz	a0,80001b74 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b48:	4719                	li	a4,6
    80001b4a:	05893683          	ld	a3,88(s2)
    80001b4e:	6605                	lui	a2,0x1
    80001b50:	020005b7          	lui	a1,0x2000
    80001b54:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b56:	05b6                	sll	a1,a1,0xd
    80001b58:	8526                	mv	a0,s1
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	59e080e7          	jalr	1438(ra) # 800010f8 <mappages>
    80001b62:	02054163          	bltz	a0,80001b84 <proc_pagetable+0x76>
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	add	sp,sp,32
    80001b72:	8082                	ret
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	a2c080e7          	jalr	-1492(ra) # 800015a4 <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	b7d5                	j	80001b66 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8e:	05b2                	sll	a1,a1,0xc
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	72c080e7          	jalr	1836(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001b9a:	4581                	li	a1,0
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	a06080e7          	jalr	-1530(ra) # 800015a4 <uvmfree>
    return 0;
    80001ba6:	4481                	li	s1,0
    80001ba8:	bf7d                	j	80001b66 <proc_pagetable+0x58>

0000000080001baa <proc_freepagetable>:
{
    80001baa:	1101                	add	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	add	s0,sp,32
    80001bb6:	84aa                	mv	s1,a0
    80001bb8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	040005b7          	lui	a1,0x4000
    80001bc2:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bc4:	05b2                	sll	a1,a1,0xc
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	6f8080e7          	jalr	1784(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	020005b7          	lui	a1,0x2000
    80001bd6:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bd8:	05b6                	sll	a1,a1,0xd
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	6e2080e7          	jalr	1762(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001be4:	85ca                	mv	a1,s2
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	9bc080e7          	jalr	-1604(ra) # 800015a4 <uvmfree>
}
    80001bf0:	60e2                	ld	ra,24(sp)
    80001bf2:	6442                	ld	s0,16(sp)
    80001bf4:	64a2                	ld	s1,8(sp)
    80001bf6:	6902                	ld	s2,0(sp)
    80001bf8:	6105                	add	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <freeproc>:
{
    80001bfc:	1101                	add	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	add	s0,sp,32
    80001c06:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c08:	6d28                	ld	a0,88(a0)
    80001c0a:	c509                	beqz	a0,80001c14 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	e3e080e7          	jalr	-450(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c14:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c18:	68a8                	ld	a0,80(s1)
    80001c1a:	c511                	beqz	a0,80001c26 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c1c:	64ac                	ld	a1,72(s1)
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	f8c080e7          	jalr	-116(ra) # 80001baa <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c32:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c36:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c42:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	add	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	add	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	0000f497          	auipc	s1,0xf
    80001c64:	31048493          	add	s1,s1,784 # 80010f70 <proc>
    80001c68:	00015917          	auipc	s2,0x15
    80001c6c:	d0890913          	add	s2,s2,-760 # 80016970 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	fc6080e7          	jalr	-58(ra) # 80000c38 <acquire>
    if(p->state == UNUSED) {
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	cf81                	beqz	a5,80001c94 <allocproc+0x40>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	06c080e7          	jalr	108(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c88:	16848493          	add	s1,s1,360
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
    80001c92:	a899                	j	80001ce8 <allocproc+0x94>
      p->priority = DEFAULT_PRIORITY; //Set p->priority to default priority given.
    80001c94:	47a9                	li	a5,10
    80001c96:	d8dc                	sw	a5,52(s1)
  p->pid = allocpid();
    80001c98:	00000097          	auipc	ra,0x0
    80001c9c:	e30080e7          	jalr	-464(ra) # 80001ac8 <allocpid>
    80001ca0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ca2:	4785                	li	a5,1
    80001ca4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	ea2080e7          	jalr	-350(ra) # 80000b48 <kalloc>
    80001cae:	892a                	mv	s2,a0
    80001cb0:	eca8                	sd	a0,88(s1)
    80001cb2:	c131                	beqz	a0,80001cf6 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	00000097          	auipc	ra,0x0
    80001cba:	e58080e7          	jalr	-424(ra) # 80001b0e <proc_pagetable>
    80001cbe:	892a                	mv	s2,a0
    80001cc0:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cc2:	c531                	beqz	a0,80001d0e <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001cc4:	07000613          	li	a2,112
    80001cc8:	4581                	li	a1,0
    80001cca:	06048513          	add	a0,s1,96
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	066080e7          	jalr	102(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001cd6:	00000797          	auipc	a5,0x0
    80001cda:	dac78793          	add	a5,a5,-596 # 80001a82 <forkret>
    80001cde:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ce0:	60bc                	ld	a5,64(s1)
    80001ce2:	6705                	lui	a4,0x1
    80001ce4:	97ba                	add	a5,a5,a4
    80001ce6:	f4bc                	sd	a5,104(s1)
}
    80001ce8:	8526                	mv	a0,s1
    80001cea:	60e2                	ld	ra,24(sp)
    80001cec:	6442                	ld	s0,16(sp)
    80001cee:	64a2                	ld	s1,8(sp)
    80001cf0:	6902                	ld	s2,0(sp)
    80001cf2:	6105                	add	sp,sp,32
    80001cf4:	8082                	ret
    freeproc(p);
    80001cf6:	8526                	mv	a0,s1
    80001cf8:	00000097          	auipc	ra,0x0
    80001cfc:	f04080e7          	jalr	-252(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d00:	8526                	mv	a0,s1
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	fea080e7          	jalr	-22(ra) # 80000cec <release>
    return 0;
    80001d0a:	84ca                	mv	s1,s2
    80001d0c:	bff1                	j	80001ce8 <allocproc+0x94>
    freeproc(p);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	00000097          	auipc	ra,0x0
    80001d14:	eec080e7          	jalr	-276(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d18:	8526                	mv	a0,s1
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	fd2080e7          	jalr	-46(ra) # 80000cec <release>
    return 0;
    80001d22:	84ca                	mv	s1,s2
    80001d24:	b7d1                	j	80001ce8 <allocproc+0x94>

0000000080001d26 <userinit>:
{
    80001d26:	1101                	add	sp,sp,-32
    80001d28:	ec06                	sd	ra,24(sp)
    80001d2a:	e822                	sd	s0,16(sp)
    80001d2c:	e426                	sd	s1,8(sp)
    80001d2e:	1000                	add	s0,sp,32
  p = allocproc();
    80001d30:	00000097          	auipc	ra,0x0
    80001d34:	f24080e7          	jalr	-220(ra) # 80001c54 <allocproc>
    80001d38:	84aa                	mv	s1,a0
  initproc = p;
    80001d3a:	00007797          	auipc	a5,0x7
    80001d3e:	b8a7b723          	sd	a0,-1138(a5) # 800088c8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d42:	03400613          	li	a2,52
    80001d46:	00007597          	auipc	a1,0x7
    80001d4a:	b1a58593          	add	a1,a1,-1254 # 80008860 <initcode>
    80001d4e:	6928                	ld	a0,80(a0)
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	670080e7          	jalr	1648(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001d58:	6785                	lui	a5,0x1
    80001d5a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d5c:	6cb8                	ld	a4,88(s1)
    80001d5e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d62:	6cb8                	ld	a4,88(s1)
    80001d64:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d66:	4641                	li	a2,16
    80001d68:	00006597          	auipc	a1,0x6
    80001d6c:	47858593          	add	a1,a1,1144 # 800081e0 <etext+0x1e0>
    80001d70:	15848513          	add	a0,s1,344
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	102080e7          	jalr	258(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001d7c:	00006517          	auipc	a0,0x6
    80001d80:	47450513          	add	a0,a0,1140 # 800081f0 <etext+0x1f0>
    80001d84:	00002097          	auipc	ra,0x2
    80001d88:	380080e7          	jalr	896(ra) # 80004104 <namei>
    80001d8c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d90:	478d                	li	a5,3
    80001d92:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d94:	8526                	mv	a0,s1
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	f56080e7          	jalr	-170(ra) # 80000cec <release>
}
    80001d9e:	60e2                	ld	ra,24(sp)
    80001da0:	6442                	ld	s0,16(sp)
    80001da2:	64a2                	ld	s1,8(sp)
    80001da4:	6105                	add	sp,sp,32
    80001da6:	8082                	ret

0000000080001da8 <growproc>:
{
    80001da8:	1101                	add	sp,sp,-32
    80001daa:	ec06                	sd	ra,24(sp)
    80001dac:	e822                	sd	s0,16(sp)
    80001dae:	e426                	sd	s1,8(sp)
    80001db0:	e04a                	sd	s2,0(sp)
    80001db2:	1000                	add	s0,sp,32
    80001db4:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001db6:	00000097          	auipc	ra,0x0
    80001dba:	c94080e7          	jalr	-876(ra) # 80001a4a <myproc>
    80001dbe:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dc0:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dc2:	01204c63          	bgtz	s2,80001dda <growproc+0x32>
  } else if(n < 0){
    80001dc6:	02094663          	bltz	s2,80001df2 <growproc+0x4a>
  p->sz = sz;
    80001dca:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dcc:	4501                	li	a0,0
}
    80001dce:	60e2                	ld	ra,24(sp)
    80001dd0:	6442                	ld	s0,16(sp)
    80001dd2:	64a2                	ld	s1,8(sp)
    80001dd4:	6902                	ld	s2,0(sp)
    80001dd6:	6105                	add	sp,sp,32
    80001dd8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dda:	4691                	li	a3,4
    80001ddc:	00b90633          	add	a2,s2,a1
    80001de0:	6928                	ld	a0,80(a0)
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	698080e7          	jalr	1688(ra) # 8000147a <uvmalloc>
    80001dea:	85aa                	mv	a1,a0
    80001dec:	fd79                	bnez	a0,80001dca <growproc+0x22>
      return -1;
    80001dee:	557d                	li	a0,-1
    80001df0:	bff9                	j	80001dce <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df2:	00b90633          	add	a2,s2,a1
    80001df6:	6928                	ld	a0,80(a0)
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	63a080e7          	jalr	1594(ra) # 80001432 <uvmdealloc>
    80001e00:	85aa                	mv	a1,a0
    80001e02:	b7e1                	j	80001dca <growproc+0x22>

0000000080001e04 <fork>:
{
    80001e04:	7139                	add	sp,sp,-64
    80001e06:	fc06                	sd	ra,56(sp)
    80001e08:	f822                	sd	s0,48(sp)
    80001e0a:	f04a                	sd	s2,32(sp)
    80001e0c:	e456                	sd	s5,8(sp)
    80001e0e:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e10:	00000097          	auipc	ra,0x0
    80001e14:	c3a080e7          	jalr	-966(ra) # 80001a4a <myproc>
    80001e18:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e1a:	00000097          	auipc	ra,0x0
    80001e1e:	e3a080e7          	jalr	-454(ra) # 80001c54 <allocproc>
    80001e22:	12050063          	beqz	a0,80001f42 <fork+0x13e>
    80001e26:	e852                	sd	s4,16(sp)
    80001e28:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e2a:	048ab603          	ld	a2,72(s5)
    80001e2e:	692c                	ld	a1,80(a0)
    80001e30:	050ab503          	ld	a0,80(s5)
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	7aa080e7          	jalr	1962(ra) # 800015de <uvmcopy>
    80001e3c:	04054a63          	bltz	a0,80001e90 <fork+0x8c>
    80001e40:	f426                	sd	s1,40(sp)
    80001e42:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e44:	048ab783          	ld	a5,72(s5)
    80001e48:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e4c:	058ab683          	ld	a3,88(s5)
    80001e50:	87b6                	mv	a5,a3
    80001e52:	058a3703          	ld	a4,88(s4)
    80001e56:	12068693          	add	a3,a3,288
    80001e5a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5e:	6788                	ld	a0,8(a5)
    80001e60:	6b8c                	ld	a1,16(a5)
    80001e62:	6f90                	ld	a2,24(a5)
    80001e64:	01073023          	sd	a6,0(a4)
    80001e68:	e708                	sd	a0,8(a4)
    80001e6a:	eb0c                	sd	a1,16(a4)
    80001e6c:	ef10                	sd	a2,24(a4)
    80001e6e:	02078793          	add	a5,a5,32
    80001e72:	02070713          	add	a4,a4,32
    80001e76:	fed792e3          	bne	a5,a3,80001e5a <fork+0x56>
  np->trapframe->a0 = 0;
    80001e7a:	058a3783          	ld	a5,88(s4)
    80001e7e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e82:	0d0a8493          	add	s1,s5,208
    80001e86:	0d0a0913          	add	s2,s4,208
    80001e8a:	150a8993          	add	s3,s5,336
    80001e8e:	a015                	j	80001eb2 <fork+0xae>
    freeproc(np);
    80001e90:	8552                	mv	a0,s4
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	d6a080e7          	jalr	-662(ra) # 80001bfc <freeproc>
    release(&np->lock);
    80001e9a:	8552                	mv	a0,s4
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	e50080e7          	jalr	-432(ra) # 80000cec <release>
    return -1;
    80001ea4:	597d                	li	s2,-1
    80001ea6:	6a42                	ld	s4,16(sp)
    80001ea8:	a071                	j	80001f34 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001eaa:	04a1                	add	s1,s1,8
    80001eac:	0921                	add	s2,s2,8
    80001eae:	01348b63          	beq	s1,s3,80001ec4 <fork+0xc0>
    if(p->ofile[i])
    80001eb2:	6088                	ld	a0,0(s1)
    80001eb4:	d97d                	beqz	a0,80001eaa <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb6:	00003097          	auipc	ra,0x3
    80001eba:	8c6080e7          	jalr	-1850(ra) # 8000477c <filedup>
    80001ebe:	00a93023          	sd	a0,0(s2)
    80001ec2:	b7e5                	j	80001eaa <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ec4:	150ab503          	ld	a0,336(s5)
    80001ec8:	00002097          	auipc	ra,0x2
    80001ecc:	a30080e7          	jalr	-1488(ra) # 800038f8 <idup>
    80001ed0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed4:	4641                	li	a2,16
    80001ed6:	158a8593          	add	a1,s5,344
    80001eda:	158a0513          	add	a0,s4,344
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	f98080e7          	jalr	-104(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001ee6:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001eea:	8552                	mv	a0,s4
    80001eec:	fffff097          	auipc	ra,0xfffff
    80001ef0:	e00080e7          	jalr	-512(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001ef4:	0000f497          	auipc	s1,0xf
    80001ef8:	c6448493          	add	s1,s1,-924 # 80010b58 <wait_lock>
    80001efc:	8526                	mv	a0,s1
    80001efe:	fffff097          	auipc	ra,0xfffff
    80001f02:	d3a080e7          	jalr	-710(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f06:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	de0080e7          	jalr	-544(ra) # 80000cec <release>
  acquire(&np->lock);
    80001f14:	8552                	mv	a0,s4
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	d22080e7          	jalr	-734(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001f1e:	478d                	li	a5,3
    80001f20:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f24:	8552                	mv	a0,s4
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	dc6080e7          	jalr	-570(ra) # 80000cec <release>
  return pid;
    80001f2e:	74a2                	ld	s1,40(sp)
    80001f30:	69e2                	ld	s3,24(sp)
    80001f32:	6a42                	ld	s4,16(sp)
}
    80001f34:	854a                	mv	a0,s2
    80001f36:	70e2                	ld	ra,56(sp)
    80001f38:	7442                	ld	s0,48(sp)
    80001f3a:	7902                	ld	s2,32(sp)
    80001f3c:	6aa2                	ld	s5,8(sp)
    80001f3e:	6121                	add	sp,sp,64
    80001f40:	8082                	ret
    return -1;
    80001f42:	597d                	li	s2,-1
    80001f44:	bfc5                	j	80001f34 <fork+0x130>

0000000080001f46 <scheduler>:
{
    80001f46:	715d                	add	sp,sp,-80
    80001f48:	e486                	sd	ra,72(sp)
    80001f4a:	e0a2                	sd	s0,64(sp)
    80001f4c:	fc26                	sd	s1,56(sp)
    80001f4e:	f84a                	sd	s2,48(sp)
    80001f50:	f44e                	sd	s3,40(sp)
    80001f52:	f052                	sd	s4,32(sp)
    80001f54:	ec56                	sd	s5,24(sp)
    80001f56:	e85a                	sd	s6,16(sp)
    80001f58:	e45e                	sd	s7,8(sp)
    80001f5a:	0880                	add	s0,sp,80
    80001f5c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f5e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f60:	00779b13          	sll	s6,a5,0x7
    80001f64:	0000f717          	auipc	a4,0xf
    80001f68:	bdc70713          	add	a4,a4,-1060 # 80010b40 <pid_lock>
    80001f6c:	975a                	add	a4,a4,s6
    80001f6e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f72:	0000f717          	auipc	a4,0xf
    80001f76:	c0670713          	add	a4,a4,-1018 # 80010b78 <cpus+0x8>
    80001f7a:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE && p->priority < highest_prio){
    80001f7c:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++){
    80001f7e:	00015917          	auipc	s2,0x15
    80001f82:	9f290913          	add	s2,s2,-1550 # 80016970 <tickslock>
        p->state = RUNNING;
    80001f86:	4b91                	li	s7,4
        c->proc = p;
    80001f88:	079e                	sll	a5,a5,0x7
    80001f8a:	0000fa97          	auipc	s5,0xf
    80001f8e:	bb6a8a93          	add	s5,s5,-1098 # 80010b40 <pid_lock>
    80001f92:	9abe                	add	s5,s5,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f98:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f9c:	10079073          	csrw	sstatus,a5
    80001fa0:	4a55                	li	s4,21
    for(p = proc; p < &proc[NPROC]; p++){
    80001fa2:	0000f497          	auipc	s1,0xf
    80001fa6:	fce48493          	add	s1,s1,-50 # 80010f70 <proc>
    80001faa:	a821                	j	80001fc2 <scheduler+0x7c>
      if(p->state == RUNNABLE && p->priority < highest_prio){
    80001fac:	00070a1b          	sext.w	s4,a4
      release(&p->lock);
    80001fb0:	8526                	mv	a0,s1
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	d3a080e7          	jalr	-710(ra) # 80000cec <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001fba:	16848493          	add	s1,s1,360
    80001fbe:	03248163          	beq	s1,s2,80001fe0 <scheduler+0x9a>
      acquire(&p->lock);
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	c74080e7          	jalr	-908(ra) # 80000c38 <acquire>
      if(p->state == RUNNABLE && p->priority < highest_prio){
    80001fcc:	4c9c                	lw	a5,24(s1)
    80001fce:	ff3791e3          	bne	a5,s3,80001fb0 <scheduler+0x6a>
    80001fd2:	58dc                	lw	a5,52(s1)
    80001fd4:	873e                	mv	a4,a5
    80001fd6:	2781                	sext.w	a5,a5
    80001fd8:	fcfa5ae3          	bge	s4,a5,80001fac <scheduler+0x66>
    80001fdc:	8752                	mv	a4,s4
    80001fde:	b7f9                	j	80001fac <scheduler+0x66>
    for(p = proc; p < &proc[NPROC]; p++){
    80001fe0:	0000f497          	auipc	s1,0xf
    80001fe4:	f9048493          	add	s1,s1,-112 # 80010f70 <proc>
    80001fe8:	a811                	j	80001ffc <scheduler+0xb6>
      release(&p->lock);
    80001fea:	8526                	mv	a0,s1
    80001fec:	fffff097          	auipc	ra,0xfffff
    80001ff0:	d00080e7          	jalr	-768(ra) # 80000cec <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001ff4:	16848493          	add	s1,s1,360
    80001ff8:	f9248ee3          	beq	s1,s2,80001f94 <scheduler+0x4e>
      acquire(&p->lock);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	c3a080e7          	jalr	-966(ra) # 80000c38 <acquire>
      if(p->state == RUNNABLE && p->priority == highest_prio){
    80002006:	4c9c                	lw	a5,24(s1)
    80002008:	ff3791e3          	bne	a5,s3,80001fea <scheduler+0xa4>
    8000200c:	58dc                	lw	a5,52(s1)
    8000200e:	fd479ee3          	bne	a5,s4,80001fea <scheduler+0xa4>
        p->state = RUNNING;
    80002012:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002016:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    8000201a:	06048593          	add	a1,s1,96
    8000201e:	855a                	mv	a0,s6
    80002020:	00000097          	auipc	ra,0x0
    80002024:	79c080e7          	jalr	1948(ra) # 800027bc <swtch>
        c->proc = 0;
    80002028:	020ab823          	sd	zero,48(s5)
    8000202c:	bf7d                	j	80001fea <scheduler+0xa4>

000000008000202e <sched>:
{
    8000202e:	7179                	add	sp,sp,-48
    80002030:	f406                	sd	ra,40(sp)
    80002032:	f022                	sd	s0,32(sp)
    80002034:	ec26                	sd	s1,24(sp)
    80002036:	e84a                	sd	s2,16(sp)
    80002038:	e44e                	sd	s3,8(sp)
    8000203a:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    8000203c:	00000097          	auipc	ra,0x0
    80002040:	a0e080e7          	jalr	-1522(ra) # 80001a4a <myproc>
    80002044:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002046:	fffff097          	auipc	ra,0xfffff
    8000204a:	b78080e7          	jalr	-1160(ra) # 80000bbe <holding>
    8000204e:	c93d                	beqz	a0,800020c4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002050:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002052:	2781                	sext.w	a5,a5
    80002054:	079e                	sll	a5,a5,0x7
    80002056:	0000f717          	auipc	a4,0xf
    8000205a:	aea70713          	add	a4,a4,-1302 # 80010b40 <pid_lock>
    8000205e:	97ba                	add	a5,a5,a4
    80002060:	0a87a703          	lw	a4,168(a5)
    80002064:	4785                	li	a5,1
    80002066:	06f71763          	bne	a4,a5,800020d4 <sched+0xa6>
  if(p->state == RUNNING)
    8000206a:	4c98                	lw	a4,24(s1)
    8000206c:	4791                	li	a5,4
    8000206e:	06f70b63          	beq	a4,a5,800020e4 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002072:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002076:	8b89                	and	a5,a5,2
  if(intr_get())
    80002078:	efb5                	bnez	a5,800020f4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000207a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000207c:	0000f917          	auipc	s2,0xf
    80002080:	ac490913          	add	s2,s2,-1340 # 80010b40 <pid_lock>
    80002084:	2781                	sext.w	a5,a5
    80002086:	079e                	sll	a5,a5,0x7
    80002088:	97ca                	add	a5,a5,s2
    8000208a:	0ac7a983          	lw	s3,172(a5)
    8000208e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002090:	2781                	sext.w	a5,a5
    80002092:	079e                	sll	a5,a5,0x7
    80002094:	0000f597          	auipc	a1,0xf
    80002098:	ae458593          	add	a1,a1,-1308 # 80010b78 <cpus+0x8>
    8000209c:	95be                	add	a1,a1,a5
    8000209e:	06048513          	add	a0,s1,96
    800020a2:	00000097          	auipc	ra,0x0
    800020a6:	71a080e7          	jalr	1818(ra) # 800027bc <swtch>
    800020aa:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020ac:	2781                	sext.w	a5,a5
    800020ae:	079e                	sll	a5,a5,0x7
    800020b0:	993e                	add	s2,s2,a5
    800020b2:	0b392623          	sw	s3,172(s2)
}
    800020b6:	70a2                	ld	ra,40(sp)
    800020b8:	7402                	ld	s0,32(sp)
    800020ba:	64e2                	ld	s1,24(sp)
    800020bc:	6942                	ld	s2,16(sp)
    800020be:	69a2                	ld	s3,8(sp)
    800020c0:	6145                	add	sp,sp,48
    800020c2:	8082                	ret
    panic("sched p->lock");
    800020c4:	00006517          	auipc	a0,0x6
    800020c8:	13450513          	add	a0,a0,308 # 800081f8 <etext+0x1f8>
    800020cc:	ffffe097          	auipc	ra,0xffffe
    800020d0:	494080e7          	jalr	1172(ra) # 80000560 <panic>
    panic("sched locks");
    800020d4:	00006517          	auipc	a0,0x6
    800020d8:	13450513          	add	a0,a0,308 # 80008208 <etext+0x208>
    800020dc:	ffffe097          	auipc	ra,0xffffe
    800020e0:	484080e7          	jalr	1156(ra) # 80000560 <panic>
    panic("sched running");
    800020e4:	00006517          	auipc	a0,0x6
    800020e8:	13450513          	add	a0,a0,308 # 80008218 <etext+0x218>
    800020ec:	ffffe097          	auipc	ra,0xffffe
    800020f0:	474080e7          	jalr	1140(ra) # 80000560 <panic>
    panic("sched interruptible");
    800020f4:	00006517          	auipc	a0,0x6
    800020f8:	13450513          	add	a0,a0,308 # 80008228 <etext+0x228>
    800020fc:	ffffe097          	auipc	ra,0xffffe
    80002100:	464080e7          	jalr	1124(ra) # 80000560 <panic>

0000000080002104 <yield>:
{
    80002104:	1101                	add	sp,sp,-32
    80002106:	ec06                	sd	ra,24(sp)
    80002108:	e822                	sd	s0,16(sp)
    8000210a:	e426                	sd	s1,8(sp)
    8000210c:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    8000210e:	00000097          	auipc	ra,0x0
    80002112:	93c080e7          	jalr	-1732(ra) # 80001a4a <myproc>
    80002116:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	b20080e7          	jalr	-1248(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    80002120:	478d                	li	a5,3
    80002122:	cc9c                	sw	a5,24(s1)
  sched();
    80002124:	00000097          	auipc	ra,0x0
    80002128:	f0a080e7          	jalr	-246(ra) # 8000202e <sched>
  release(&p->lock);
    8000212c:	8526                	mv	a0,s1
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	bbe080e7          	jalr	-1090(ra) # 80000cec <release>
}
    80002136:	60e2                	ld	ra,24(sp)
    80002138:	6442                	ld	s0,16(sp)
    8000213a:	64a2                	ld	s1,8(sp)
    8000213c:	6105                	add	sp,sp,32
    8000213e:	8082                	ret

0000000080002140 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002140:	7179                	add	sp,sp,-48
    80002142:	f406                	sd	ra,40(sp)
    80002144:	f022                	sd	s0,32(sp)
    80002146:	ec26                	sd	s1,24(sp)
    80002148:	e84a                	sd	s2,16(sp)
    8000214a:	e44e                	sd	s3,8(sp)
    8000214c:	1800                	add	s0,sp,48
    8000214e:	89aa                	mv	s3,a0
    80002150:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002152:	00000097          	auipc	ra,0x0
    80002156:	8f8080e7          	jalr	-1800(ra) # 80001a4a <myproc>
    8000215a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	adc080e7          	jalr	-1316(ra) # 80000c38 <acquire>
  release(lk);
    80002164:	854a                	mv	a0,s2
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	b86080e7          	jalr	-1146(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    8000216e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002172:	4789                	li	a5,2
    80002174:	cc9c                	sw	a5,24(s1)

  sched();
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	eb8080e7          	jalr	-328(ra) # 8000202e <sched>

  // Tidy up.
  p->chan = 0;
    8000217e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	b68080e7          	jalr	-1176(ra) # 80000cec <release>
  acquire(lk);
    8000218c:	854a                	mv	a0,s2
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	aaa080e7          	jalr	-1366(ra) # 80000c38 <acquire>
}
    80002196:	70a2                	ld	ra,40(sp)
    80002198:	7402                	ld	s0,32(sp)
    8000219a:	64e2                	ld	s1,24(sp)
    8000219c:	6942                	ld	s2,16(sp)
    8000219e:	69a2                	ld	s3,8(sp)
    800021a0:	6145                	add	sp,sp,48
    800021a2:	8082                	ret

00000000800021a4 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021a4:	7139                	add	sp,sp,-64
    800021a6:	fc06                	sd	ra,56(sp)
    800021a8:	f822                	sd	s0,48(sp)
    800021aa:	f426                	sd	s1,40(sp)
    800021ac:	f04a                	sd	s2,32(sp)
    800021ae:	ec4e                	sd	s3,24(sp)
    800021b0:	e852                	sd	s4,16(sp)
    800021b2:	e456                	sd	s5,8(sp)
    800021b4:	0080                	add	s0,sp,64
    800021b6:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021b8:	0000f497          	auipc	s1,0xf
    800021bc:	db848493          	add	s1,s1,-584 # 80010f70 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021c0:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021c2:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021c4:	00014917          	auipc	s2,0x14
    800021c8:	7ac90913          	add	s2,s2,1964 # 80016970 <tickslock>
    800021cc:	a811                	j	800021e0 <wakeup+0x3c>
      }
      release(&p->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	b1c080e7          	jalr	-1252(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021d8:	16848493          	add	s1,s1,360
    800021dc:	03248663          	beq	s1,s2,80002208 <wakeup+0x64>
    if(p != myproc()){
    800021e0:	00000097          	auipc	ra,0x0
    800021e4:	86a080e7          	jalr	-1942(ra) # 80001a4a <myproc>
    800021e8:	fea488e3          	beq	s1,a0,800021d8 <wakeup+0x34>
      acquire(&p->lock);
    800021ec:	8526                	mv	a0,s1
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	a4a080e7          	jalr	-1462(ra) # 80000c38 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021f6:	4c9c                	lw	a5,24(s1)
    800021f8:	fd379be3          	bne	a5,s3,800021ce <wakeup+0x2a>
    800021fc:	709c                	ld	a5,32(s1)
    800021fe:	fd4798e3          	bne	a5,s4,800021ce <wakeup+0x2a>
        p->state = RUNNABLE;
    80002202:	0154ac23          	sw	s5,24(s1)
    80002206:	b7e1                	j	800021ce <wakeup+0x2a>
    }
  }
}
    80002208:	70e2                	ld	ra,56(sp)
    8000220a:	7442                	ld	s0,48(sp)
    8000220c:	74a2                	ld	s1,40(sp)
    8000220e:	7902                	ld	s2,32(sp)
    80002210:	69e2                	ld	s3,24(sp)
    80002212:	6a42                	ld	s4,16(sp)
    80002214:	6aa2                	ld	s5,8(sp)
    80002216:	6121                	add	sp,sp,64
    80002218:	8082                	ret

000000008000221a <reparent>:
{
    8000221a:	7179                	add	sp,sp,-48
    8000221c:	f406                	sd	ra,40(sp)
    8000221e:	f022                	sd	s0,32(sp)
    80002220:	ec26                	sd	s1,24(sp)
    80002222:	e84a                	sd	s2,16(sp)
    80002224:	e44e                	sd	s3,8(sp)
    80002226:	e052                	sd	s4,0(sp)
    80002228:	1800                	add	s0,sp,48
    8000222a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000222c:	0000f497          	auipc	s1,0xf
    80002230:	d4448493          	add	s1,s1,-700 # 80010f70 <proc>
      pp->parent = initproc;
    80002234:	00006a17          	auipc	s4,0x6
    80002238:	694a0a13          	add	s4,s4,1684 # 800088c8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000223c:	00014997          	auipc	s3,0x14
    80002240:	73498993          	add	s3,s3,1844 # 80016970 <tickslock>
    80002244:	a029                	j	8000224e <reparent+0x34>
    80002246:	16848493          	add	s1,s1,360
    8000224a:	01348d63          	beq	s1,s3,80002264 <reparent+0x4a>
    if(pp->parent == p){
    8000224e:	7c9c                	ld	a5,56(s1)
    80002250:	ff279be3          	bne	a5,s2,80002246 <reparent+0x2c>
      pp->parent = initproc;
    80002254:	000a3503          	ld	a0,0(s4)
    80002258:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000225a:	00000097          	auipc	ra,0x0
    8000225e:	f4a080e7          	jalr	-182(ra) # 800021a4 <wakeup>
    80002262:	b7d5                	j	80002246 <reparent+0x2c>
}
    80002264:	70a2                	ld	ra,40(sp)
    80002266:	7402                	ld	s0,32(sp)
    80002268:	64e2                	ld	s1,24(sp)
    8000226a:	6942                	ld	s2,16(sp)
    8000226c:	69a2                	ld	s3,8(sp)
    8000226e:	6a02                	ld	s4,0(sp)
    80002270:	6145                	add	sp,sp,48
    80002272:	8082                	ret

0000000080002274 <exit>:
{
    80002274:	7179                	add	sp,sp,-48
    80002276:	f406                	sd	ra,40(sp)
    80002278:	f022                	sd	s0,32(sp)
    8000227a:	ec26                	sd	s1,24(sp)
    8000227c:	e84a                	sd	s2,16(sp)
    8000227e:	e44e                	sd	s3,8(sp)
    80002280:	e052                	sd	s4,0(sp)
    80002282:	1800                	add	s0,sp,48
    80002284:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002286:	fffff097          	auipc	ra,0xfffff
    8000228a:	7c4080e7          	jalr	1988(ra) # 80001a4a <myproc>
    8000228e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002290:	00006797          	auipc	a5,0x6
    80002294:	6387b783          	ld	a5,1592(a5) # 800088c8 <initproc>
    80002298:	0d050493          	add	s1,a0,208
    8000229c:	15050913          	add	s2,a0,336
    800022a0:	02a79363          	bne	a5,a0,800022c6 <exit+0x52>
    panic("init exiting");
    800022a4:	00006517          	auipc	a0,0x6
    800022a8:	f9c50513          	add	a0,a0,-100 # 80008240 <etext+0x240>
    800022ac:	ffffe097          	auipc	ra,0xffffe
    800022b0:	2b4080e7          	jalr	692(ra) # 80000560 <panic>
      fileclose(f);
    800022b4:	00002097          	auipc	ra,0x2
    800022b8:	51a080e7          	jalr	1306(ra) # 800047ce <fileclose>
      p->ofile[fd] = 0;
    800022bc:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800022c0:	04a1                	add	s1,s1,8
    800022c2:	01248563          	beq	s1,s2,800022cc <exit+0x58>
    if(p->ofile[fd]){
    800022c6:	6088                	ld	a0,0(s1)
    800022c8:	f575                	bnez	a0,800022b4 <exit+0x40>
    800022ca:	bfdd                	j	800022c0 <exit+0x4c>
  begin_op();
    800022cc:	00002097          	auipc	ra,0x2
    800022d0:	038080e7          	jalr	56(ra) # 80004304 <begin_op>
  iput(p->cwd);
    800022d4:	1509b503          	ld	a0,336(s3)
    800022d8:	00002097          	auipc	ra,0x2
    800022dc:	81c080e7          	jalr	-2020(ra) # 80003af4 <iput>
  end_op();
    800022e0:	00002097          	auipc	ra,0x2
    800022e4:	09e080e7          	jalr	158(ra) # 8000437e <end_op>
  p->cwd = 0;
    800022e8:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022ec:	0000f497          	auipc	s1,0xf
    800022f0:	86c48493          	add	s1,s1,-1940 # 80010b58 <wait_lock>
    800022f4:	8526                	mv	a0,s1
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	942080e7          	jalr	-1726(ra) # 80000c38 <acquire>
  reparent(p);
    800022fe:	854e                	mv	a0,s3
    80002300:	00000097          	auipc	ra,0x0
    80002304:	f1a080e7          	jalr	-230(ra) # 8000221a <reparent>
  wakeup(p->parent);
    80002308:	0389b503          	ld	a0,56(s3)
    8000230c:	00000097          	auipc	ra,0x0
    80002310:	e98080e7          	jalr	-360(ra) # 800021a4 <wakeup>
  acquire(&p->lock);
    80002314:	854e                	mv	a0,s3
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	922080e7          	jalr	-1758(ra) # 80000c38 <acquire>
  p->xstate = status;
    8000231e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002322:	4795                	li	a5,5
    80002324:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002328:	8526                	mv	a0,s1
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	9c2080e7          	jalr	-1598(ra) # 80000cec <release>
  sched();
    80002332:	00000097          	auipc	ra,0x0
    80002336:	cfc080e7          	jalr	-772(ra) # 8000202e <sched>
  panic("zombie exit");
    8000233a:	00006517          	auipc	a0,0x6
    8000233e:	f1650513          	add	a0,a0,-234 # 80008250 <etext+0x250>
    80002342:	ffffe097          	auipc	ra,0xffffe
    80002346:	21e080e7          	jalr	542(ra) # 80000560 <panic>

000000008000234a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000234a:	7179                	add	sp,sp,-48
    8000234c:	f406                	sd	ra,40(sp)
    8000234e:	f022                	sd	s0,32(sp)
    80002350:	ec26                	sd	s1,24(sp)
    80002352:	e84a                	sd	s2,16(sp)
    80002354:	e44e                	sd	s3,8(sp)
    80002356:	1800                	add	s0,sp,48
    80002358:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000235a:	0000f497          	auipc	s1,0xf
    8000235e:	c1648493          	add	s1,s1,-1002 # 80010f70 <proc>
    80002362:	00014997          	auipc	s3,0x14
    80002366:	60e98993          	add	s3,s3,1550 # 80016970 <tickslock>
    acquire(&p->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	8cc080e7          	jalr	-1844(ra) # 80000c38 <acquire>
    if(p->pid == pid){
    80002374:	589c                	lw	a5,48(s1)
    80002376:	01278d63          	beq	a5,s2,80002390 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	970080e7          	jalr	-1680(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002384:	16848493          	add	s1,s1,360
    80002388:	ff3491e3          	bne	s1,s3,8000236a <kill+0x20>
  }
  return -1;
    8000238c:	557d                	li	a0,-1
    8000238e:	a829                	j	800023a8 <kill+0x5e>
      p->killed = 1;
    80002390:	4785                	li	a5,1
    80002392:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002394:	4c98                	lw	a4,24(s1)
    80002396:	4789                	li	a5,2
    80002398:	00f70f63          	beq	a4,a5,800023b6 <kill+0x6c>
      release(&p->lock);
    8000239c:	8526                	mv	a0,s1
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	94e080e7          	jalr	-1714(ra) # 80000cec <release>
      return 0;
    800023a6:	4501                	li	a0,0
}
    800023a8:	70a2                	ld	ra,40(sp)
    800023aa:	7402                	ld	s0,32(sp)
    800023ac:	64e2                	ld	s1,24(sp)
    800023ae:	6942                	ld	s2,16(sp)
    800023b0:	69a2                	ld	s3,8(sp)
    800023b2:	6145                	add	sp,sp,48
    800023b4:	8082                	ret
        p->state = RUNNABLE;
    800023b6:	478d                	li	a5,3
    800023b8:	cc9c                	sw	a5,24(s1)
    800023ba:	b7cd                	j	8000239c <kill+0x52>

00000000800023bc <setkilled>:

void
setkilled(struct proc *p)
{
    800023bc:	1101                	add	sp,sp,-32
    800023be:	ec06                	sd	ra,24(sp)
    800023c0:	e822                	sd	s0,16(sp)
    800023c2:	e426                	sd	s1,8(sp)
    800023c4:	1000                	add	s0,sp,32
    800023c6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	870080e7          	jalr	-1936(ra) # 80000c38 <acquire>
  p->killed = 1;
    800023d0:	4785                	li	a5,1
    800023d2:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023d4:	8526                	mv	a0,s1
    800023d6:	fffff097          	auipc	ra,0xfffff
    800023da:	916080e7          	jalr	-1770(ra) # 80000cec <release>
}
    800023de:	60e2                	ld	ra,24(sp)
    800023e0:	6442                	ld	s0,16(sp)
    800023e2:	64a2                	ld	s1,8(sp)
    800023e4:	6105                	add	sp,sp,32
    800023e6:	8082                	ret

00000000800023e8 <killed>:

int
killed(struct proc *p)
{
    800023e8:	1101                	add	sp,sp,-32
    800023ea:	ec06                	sd	ra,24(sp)
    800023ec:	e822                	sd	s0,16(sp)
    800023ee:	e426                	sd	s1,8(sp)
    800023f0:	e04a                	sd	s2,0(sp)
    800023f2:	1000                	add	s0,sp,32
    800023f4:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	842080e7          	jalr	-1982(ra) # 80000c38 <acquire>
  k = p->killed;
    800023fe:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002402:	8526                	mv	a0,s1
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	8e8080e7          	jalr	-1816(ra) # 80000cec <release>
  return k;
}
    8000240c:	854a                	mv	a0,s2
    8000240e:	60e2                	ld	ra,24(sp)
    80002410:	6442                	ld	s0,16(sp)
    80002412:	64a2                	ld	s1,8(sp)
    80002414:	6902                	ld	s2,0(sp)
    80002416:	6105                	add	sp,sp,32
    80002418:	8082                	ret

000000008000241a <wait>:
{
    8000241a:	715d                	add	sp,sp,-80
    8000241c:	e486                	sd	ra,72(sp)
    8000241e:	e0a2                	sd	s0,64(sp)
    80002420:	fc26                	sd	s1,56(sp)
    80002422:	f84a                	sd	s2,48(sp)
    80002424:	f44e                	sd	s3,40(sp)
    80002426:	f052                	sd	s4,32(sp)
    80002428:	ec56                	sd	s5,24(sp)
    8000242a:	e85a                	sd	s6,16(sp)
    8000242c:	e45e                	sd	s7,8(sp)
    8000242e:	e062                	sd	s8,0(sp)
    80002430:	0880                	add	s0,sp,80
    80002432:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002434:	fffff097          	auipc	ra,0xfffff
    80002438:	616080e7          	jalr	1558(ra) # 80001a4a <myproc>
    8000243c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000243e:	0000e517          	auipc	a0,0xe
    80002442:	71a50513          	add	a0,a0,1818 # 80010b58 <wait_lock>
    80002446:	ffffe097          	auipc	ra,0xffffe
    8000244a:	7f2080e7          	jalr	2034(ra) # 80000c38 <acquire>
    havekids = 0;
    8000244e:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002450:	4a15                	li	s4,5
        havekids = 1;
    80002452:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002454:	00014997          	auipc	s3,0x14
    80002458:	51c98993          	add	s3,s3,1308 # 80016970 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000245c:	0000ec17          	auipc	s8,0xe
    80002460:	6fcc0c13          	add	s8,s8,1788 # 80010b58 <wait_lock>
    80002464:	a0d1                	j	80002528 <wait+0x10e>
          pid = pp->pid;
    80002466:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000246a:	000b0e63          	beqz	s6,80002486 <wait+0x6c>
    8000246e:	4691                	li	a3,4
    80002470:	02c48613          	add	a2,s1,44
    80002474:	85da                	mv	a1,s6
    80002476:	05093503          	ld	a0,80(s2)
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	268080e7          	jalr	616(ra) # 800016e2 <copyout>
    80002482:	04054163          	bltz	a0,800024c4 <wait+0xaa>
          freeproc(pp);
    80002486:	8526                	mv	a0,s1
    80002488:	fffff097          	auipc	ra,0xfffff
    8000248c:	774080e7          	jalr	1908(ra) # 80001bfc <freeproc>
          release(&pp->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	fffff097          	auipc	ra,0xfffff
    80002496:	85a080e7          	jalr	-1958(ra) # 80000cec <release>
          release(&wait_lock);
    8000249a:	0000e517          	auipc	a0,0xe
    8000249e:	6be50513          	add	a0,a0,1726 # 80010b58 <wait_lock>
    800024a2:	fffff097          	auipc	ra,0xfffff
    800024a6:	84a080e7          	jalr	-1974(ra) # 80000cec <release>
}
    800024aa:	854e                	mv	a0,s3
    800024ac:	60a6                	ld	ra,72(sp)
    800024ae:	6406                	ld	s0,64(sp)
    800024b0:	74e2                	ld	s1,56(sp)
    800024b2:	7942                	ld	s2,48(sp)
    800024b4:	79a2                	ld	s3,40(sp)
    800024b6:	7a02                	ld	s4,32(sp)
    800024b8:	6ae2                	ld	s5,24(sp)
    800024ba:	6b42                	ld	s6,16(sp)
    800024bc:	6ba2                	ld	s7,8(sp)
    800024be:	6c02                	ld	s8,0(sp)
    800024c0:	6161                	add	sp,sp,80
    800024c2:	8082                	ret
            release(&pp->lock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	826080e7          	jalr	-2010(ra) # 80000cec <release>
            release(&wait_lock);
    800024ce:	0000e517          	auipc	a0,0xe
    800024d2:	68a50513          	add	a0,a0,1674 # 80010b58 <wait_lock>
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	816080e7          	jalr	-2026(ra) # 80000cec <release>
            return -1;
    800024de:	59fd                	li	s3,-1
    800024e0:	b7e9                	j	800024aa <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024e2:	16848493          	add	s1,s1,360
    800024e6:	03348463          	beq	s1,s3,8000250e <wait+0xf4>
      if(pp->parent == p){
    800024ea:	7c9c                	ld	a5,56(s1)
    800024ec:	ff279be3          	bne	a5,s2,800024e2 <wait+0xc8>
        acquire(&pp->lock);
    800024f0:	8526                	mv	a0,s1
    800024f2:	ffffe097          	auipc	ra,0xffffe
    800024f6:	746080e7          	jalr	1862(ra) # 80000c38 <acquire>
        if(pp->state == ZOMBIE){
    800024fa:	4c9c                	lw	a5,24(s1)
    800024fc:	f74785e3          	beq	a5,s4,80002466 <wait+0x4c>
        release(&pp->lock);
    80002500:	8526                	mv	a0,s1
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	7ea080e7          	jalr	2026(ra) # 80000cec <release>
        havekids = 1;
    8000250a:	8756                	mv	a4,s5
    8000250c:	bfd9                	j	800024e2 <wait+0xc8>
    if(!havekids || killed(p)){
    8000250e:	c31d                	beqz	a4,80002534 <wait+0x11a>
    80002510:	854a                	mv	a0,s2
    80002512:	00000097          	auipc	ra,0x0
    80002516:	ed6080e7          	jalr	-298(ra) # 800023e8 <killed>
    8000251a:	ed09                	bnez	a0,80002534 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000251c:	85e2                	mv	a1,s8
    8000251e:	854a                	mv	a0,s2
    80002520:	00000097          	auipc	ra,0x0
    80002524:	c20080e7          	jalr	-992(ra) # 80002140 <sleep>
    havekids = 0;
    80002528:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000252a:	0000f497          	auipc	s1,0xf
    8000252e:	a4648493          	add	s1,s1,-1466 # 80010f70 <proc>
    80002532:	bf65                	j	800024ea <wait+0xd0>
      release(&wait_lock);
    80002534:	0000e517          	auipc	a0,0xe
    80002538:	62450513          	add	a0,a0,1572 # 80010b58 <wait_lock>
    8000253c:	ffffe097          	auipc	ra,0xffffe
    80002540:	7b0080e7          	jalr	1968(ra) # 80000cec <release>
      return -1;
    80002544:	59fd                	li	s3,-1
    80002546:	b795                	j	800024aa <wait+0x90>

0000000080002548 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002548:	7179                	add	sp,sp,-48
    8000254a:	f406                	sd	ra,40(sp)
    8000254c:	f022                	sd	s0,32(sp)
    8000254e:	ec26                	sd	s1,24(sp)
    80002550:	e84a                	sd	s2,16(sp)
    80002552:	e44e                	sd	s3,8(sp)
    80002554:	e052                	sd	s4,0(sp)
    80002556:	1800                	add	s0,sp,48
    80002558:	84aa                	mv	s1,a0
    8000255a:	892e                	mv	s2,a1
    8000255c:	89b2                	mv	s3,a2
    8000255e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002560:	fffff097          	auipc	ra,0xfffff
    80002564:	4ea080e7          	jalr	1258(ra) # 80001a4a <myproc>
  if(user_dst){
    80002568:	c08d                	beqz	s1,8000258a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000256a:	86d2                	mv	a3,s4
    8000256c:	864e                	mv	a2,s3
    8000256e:	85ca                	mv	a1,s2
    80002570:	6928                	ld	a0,80(a0)
    80002572:	fffff097          	auipc	ra,0xfffff
    80002576:	170080e7          	jalr	368(ra) # 800016e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000257a:	70a2                	ld	ra,40(sp)
    8000257c:	7402                	ld	s0,32(sp)
    8000257e:	64e2                	ld	s1,24(sp)
    80002580:	6942                	ld	s2,16(sp)
    80002582:	69a2                	ld	s3,8(sp)
    80002584:	6a02                	ld	s4,0(sp)
    80002586:	6145                	add	sp,sp,48
    80002588:	8082                	ret
    memmove((char *)dst, src, len);
    8000258a:	000a061b          	sext.w	a2,s4
    8000258e:	85ce                	mv	a1,s3
    80002590:	854a                	mv	a0,s2
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	7fe080e7          	jalr	2046(ra) # 80000d90 <memmove>
    return 0;
    8000259a:	8526                	mv	a0,s1
    8000259c:	bff9                	j	8000257a <either_copyout+0x32>

000000008000259e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000259e:	7179                	add	sp,sp,-48
    800025a0:	f406                	sd	ra,40(sp)
    800025a2:	f022                	sd	s0,32(sp)
    800025a4:	ec26                	sd	s1,24(sp)
    800025a6:	e84a                	sd	s2,16(sp)
    800025a8:	e44e                	sd	s3,8(sp)
    800025aa:	e052                	sd	s4,0(sp)
    800025ac:	1800                	add	s0,sp,48
    800025ae:	892a                	mv	s2,a0
    800025b0:	84ae                	mv	s1,a1
    800025b2:	89b2                	mv	s3,a2
    800025b4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025b6:	fffff097          	auipc	ra,0xfffff
    800025ba:	494080e7          	jalr	1172(ra) # 80001a4a <myproc>
  if(user_src){
    800025be:	c08d                	beqz	s1,800025e0 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800025c0:	86d2                	mv	a3,s4
    800025c2:	864e                	mv	a2,s3
    800025c4:	85ca                	mv	a1,s2
    800025c6:	6928                	ld	a0,80(a0)
    800025c8:	fffff097          	auipc	ra,0xfffff
    800025cc:	1a6080e7          	jalr	422(ra) # 8000176e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025d0:	70a2                	ld	ra,40(sp)
    800025d2:	7402                	ld	s0,32(sp)
    800025d4:	64e2                	ld	s1,24(sp)
    800025d6:	6942                	ld	s2,16(sp)
    800025d8:	69a2                	ld	s3,8(sp)
    800025da:	6a02                	ld	s4,0(sp)
    800025dc:	6145                	add	sp,sp,48
    800025de:	8082                	ret
    memmove(dst, (char*)src, len);
    800025e0:	000a061b          	sext.w	a2,s4
    800025e4:	85ce                	mv	a1,s3
    800025e6:	854a                	mv	a0,s2
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	7a8080e7          	jalr	1960(ra) # 80000d90 <memmove>
    return 0;
    800025f0:	8526                	mv	a0,s1
    800025f2:	bff9                	j	800025d0 <either_copyin+0x32>

00000000800025f4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025f4:	715d                	add	sp,sp,-80
    800025f6:	e486                	sd	ra,72(sp)
    800025f8:	e0a2                	sd	s0,64(sp)
    800025fa:	fc26                	sd	s1,56(sp)
    800025fc:	f84a                	sd	s2,48(sp)
    800025fe:	f44e                	sd	s3,40(sp)
    80002600:	f052                	sd	s4,32(sp)
    80002602:	ec56                	sd	s5,24(sp)
    80002604:	e85a                	sd	s6,16(sp)
    80002606:	e45e                	sd	s7,8(sp)
    80002608:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000260a:	00006517          	auipc	a0,0x6
    8000260e:	a0650513          	add	a0,a0,-1530 # 80008010 <etext+0x10>
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	f98080e7          	jalr	-104(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000261a:	0000f497          	auipc	s1,0xf
    8000261e:	aae48493          	add	s1,s1,-1362 # 800110c8 <proc+0x158>
    80002622:	00014917          	auipc	s2,0x14
    80002626:	4a690913          	add	s2,s2,1190 # 80016ac8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000262a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000262c:	00006997          	auipc	s3,0x6
    80002630:	c3498993          	add	s3,s3,-972 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    80002634:	00006a97          	auipc	s5,0x6
    80002638:	c34a8a93          	add	s5,s5,-972 # 80008268 <etext+0x268>
    printf("\n");
    8000263c:	00006a17          	auipc	s4,0x6
    80002640:	9d4a0a13          	add	s4,s4,-1580 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002644:	00006b97          	auipc	s7,0x6
    80002648:	0fcb8b93          	add	s7,s7,252 # 80008740 <states.0>
    8000264c:	a00d                	j	8000266e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000264e:	ed86a583          	lw	a1,-296(a3)
    80002652:	8556                	mv	a0,s5
    80002654:	ffffe097          	auipc	ra,0xffffe
    80002658:	f56080e7          	jalr	-170(ra) # 800005aa <printf>
    printf("\n");
    8000265c:	8552                	mv	a0,s4
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	f4c080e7          	jalr	-180(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002666:	16848493          	add	s1,s1,360
    8000266a:	03248263          	beq	s1,s2,8000268e <procdump+0x9a>
    if(p->state == UNUSED)
    8000266e:	86a6                	mv	a3,s1
    80002670:	ec04a783          	lw	a5,-320(s1)
    80002674:	dbed                	beqz	a5,80002666 <procdump+0x72>
      state = "???";
    80002676:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002678:	fcfb6be3          	bltu	s6,a5,8000264e <procdump+0x5a>
    8000267c:	02079713          	sll	a4,a5,0x20
    80002680:	01d75793          	srl	a5,a4,0x1d
    80002684:	97de                	add	a5,a5,s7
    80002686:	6390                	ld	a2,0(a5)
    80002688:	f279                	bnez	a2,8000264e <procdump+0x5a>
      state = "???";
    8000268a:	864e                	mv	a2,s3
    8000268c:	b7c9                	j	8000264e <procdump+0x5a>
  }
}
    8000268e:	60a6                	ld	ra,72(sp)
    80002690:	6406                	ld	s0,64(sp)
    80002692:	74e2                	ld	s1,56(sp)
    80002694:	7942                	ld	s2,48(sp)
    80002696:	79a2                	ld	s3,40(sp)
    80002698:	7a02                	ld	s4,32(sp)
    8000269a:	6ae2                	ld	s5,24(sp)
    8000269c:	6b42                	ld	s6,16(sp)
    8000269e:	6ba2                	ld	s7,8(sp)
    800026a0:	6161                	add	sp,sp,80
    800026a2:	8082                	ret

00000000800026a4 <setpriority>:
*/


//Function that sets the priority of current process, equal to priority.
int setpriority(int priority)
{
    800026a4:	1101                	add	sp,sp,-32
    800026a6:	ec06                	sd	ra,24(sp)
    800026a8:	e822                	sd	s0,16(sp)
    800026aa:	e426                	sd	s1,8(sp)
    800026ac:	e04a                	sd	s2,0(sp)
    800026ae:	1000                	add	s0,sp,32
    800026b0:	892a                	mv	s2,a0
  struct proc* current_proc = myproc();
    800026b2:	fffff097          	auipc	ra,0xfffff
    800026b6:	398080e7          	jalr	920(ra) # 80001a4a <myproc>
    800026ba:	84aa                	mv	s1,a0

  acquire(&current_proc->lock);
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	57c080e7          	jalr	1404(ra) # 80000c38 <acquire>

  //Priority given is not in the available bounds, or current process is null.
  if(priority < H_PRIO || priority > L_PRIO || !current_proc)
    800026c4:	fff9071b          	addw	a4,s2,-1
    800026c8:	47cd                	li	a5,19
    800026ca:	02e7e163          	bltu	a5,a4,800026ec <setpriority+0x48>
    800026ce:	c08d                	beqz	s1,800026f0 <setpriority+0x4c>
    return  -1;

  //Set priority = priority.
  current_proc->priority = priority;  
    800026d0:	0324aa23          	sw	s2,52(s1)

  release(&current_proc->lock);
    800026d4:	8526                	mv	a0,s1
    800026d6:	ffffe097          	auipc	ra,0xffffe
    800026da:	616080e7          	jalr	1558(ra) # 80000cec <release>

  return 0;
    800026de:	4501                	li	a0,0
}
    800026e0:	60e2                	ld	ra,24(sp)
    800026e2:	6442                	ld	s0,16(sp)
    800026e4:	64a2                	ld	s1,8(sp)
    800026e6:	6902                	ld	s2,0(sp)
    800026e8:	6105                	add	sp,sp,32
    800026ea:	8082                	ret
    return  -1;
    800026ec:	557d                	li	a0,-1
    800026ee:	bfcd                	j	800026e0 <setpriority+0x3c>
    800026f0:	557d                	li	a0,-1
    800026f2:	b7fd                	j	800026e0 <setpriority+0x3c>

00000000800026f4 <getpinfo>:

//Retrieves useful information needed for ps
//and stores them into struct pstat. 
int getpinfo(struct pstat* pstats){
    800026f4:	715d                	add	sp,sp,-80
    800026f6:	e486                	sd	ra,72(sp)
    800026f8:	e0a2                	sd	s0,64(sp)
    800026fa:	fc26                	sd	s1,56(sp)
    800026fc:	f84a                	sd	s2,48(sp)
    800026fe:	f44e                	sd	s3,40(sp)
    80002700:	f052                	sd	s4,32(sp)
    80002702:	ec56                	sd	s5,24(sp)
    80002704:	e85a                	sd	s6,16(sp)
    80002706:	0880                	add	s0,sp,80
    80002708:	8b2a                	mv	s6,a0
  struct proc* p;

  uint64 addr; 
  argaddr(0, &addr); //User pointer to struct pstat stored in addr variable.
    8000270a:	fb840593          	add	a1,s0,-72
    8000270e:	4501                	li	a0,0
    80002710:	00000097          	auipc	ra,0x0
    80002714:	5de080e7          	jalr	1502(ra) # 80002cee <argaddr>

  int index = 0;
  for(p = proc; p < &proc[NPROC]; p++) {
    80002718:	895a                	mv	s2,s6
    8000271a:	300b0993          	add	s3,s6,768
    8000271e:	0000f497          	auipc	s1,0xf
    80002722:	85248493          	add	s1,s1,-1966 # 80010f70 <proc>
    if(p->state != UNUSED){
      //Edge case where parent does not exist.
      if(p->parent != 0)
        pstats->ppid[index] = p->parent->pid;
      else  
        pstats->ppid[index] = 0; //Default value of parent id if it does not exist.
    80002726:	4a81                	li	s5,0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002728:	00014a17          	auipc	s4,0x14
    8000272c:	248a0a13          	add	s4,s4,584 # 80016970 <tickslock>
    80002730:	a83d                	j	8000276e <getpinfo+0x7a>
    80002732:	10f92023          	sw	a5,256(s2)

      pstats->pid[index] = p->pid;
    80002736:	589c                	lw	a5,48(s1)
    80002738:	00f92023          	sw	a5,0(s2)
      pstats->priority[index] = p->priority;
    8000273c:	58dc                	lw	a5,52(s1)
    8000273e:	20f92023          	sw	a5,512(s2)
      strncpy(pstats->name[index], p->name, 16);
    80002742:	4641                	li	a2,16
    80002744:	15848593          	add	a1,s1,344
    80002748:	854e                	mv	a0,s3
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	6f0080e7          	jalr	1776(ra) # 80000e3a <strncpy>
    }
    pstats->state[index] = p->state;
    80002752:	4c9c                	lw	a5,24(s1)
    80002754:	70f92023          	sw	a5,1792(s2)
    index++;

    release(&p->lock);
    80002758:	8526                	mv	a0,s1
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	592080e7          	jalr	1426(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002762:	16848493          	add	s1,s1,360
    80002766:	0911                	add	s2,s2,4
    80002768:	09c1                	add	s3,s3,16
    8000276a:	01448e63          	beq	s1,s4,80002786 <getpinfo+0x92>
    acquire(&p->lock);
    8000276e:	8526                	mv	a0,s1
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	4c8080e7          	jalr	1224(ra) # 80000c38 <acquire>
    if(p->state != UNUSED){
    80002778:	4c9c                	lw	a5,24(s1)
    8000277a:	dfe1                	beqz	a5,80002752 <getpinfo+0x5e>
      if(p->parent != 0)
    8000277c:	7c98                	ld	a4,56(s1)
        pstats->ppid[index] = 0; //Default value of parent id if it does not exist.
    8000277e:	87d6                	mv	a5,s5
      if(p->parent != 0)
    80002780:	db4d                	beqz	a4,80002732 <getpinfo+0x3e>
        pstats->ppid[index] = p->parent->pid;
    80002782:	5b1c                	lw	a5,48(a4)
    80002784:	b77d                	j	80002732 <getpinfo+0x3e>
  }
  
  //Copy struct pstat from kernel level to user level.
  if(copyout(myproc()->pagetable, addr, (char *)pstats, sizeof(struct pstat)) < 0)
    80002786:	fffff097          	auipc	ra,0xfffff
    8000278a:	2c4080e7          	jalr	708(ra) # 80001a4a <myproc>
    8000278e:	6685                	lui	a3,0x1
    80002790:	80068693          	add	a3,a3,-2048 # 800 <_entry-0x7ffff800>
    80002794:	865a                	mv	a2,s6
    80002796:	fb843583          	ld	a1,-72(s0)
    8000279a:	6928                	ld	a0,80(a0)
    8000279c:	fffff097          	auipc	ra,0xfffff
    800027a0:	f46080e7          	jalr	-186(ra) # 800016e2 <copyout>
    return -1;

  return 0;
    800027a4:	41f5551b          	sraw	a0,a0,0x1f
    800027a8:	60a6                	ld	ra,72(sp)
    800027aa:	6406                	ld	s0,64(sp)
    800027ac:	74e2                	ld	s1,56(sp)
    800027ae:	7942                	ld	s2,48(sp)
    800027b0:	79a2                	ld	s3,40(sp)
    800027b2:	7a02                	ld	s4,32(sp)
    800027b4:	6ae2                	ld	s5,24(sp)
    800027b6:	6b42                	ld	s6,16(sp)
    800027b8:	6161                	add	sp,sp,80
    800027ba:	8082                	ret

00000000800027bc <swtch>:
    800027bc:	00153023          	sd	ra,0(a0)
    800027c0:	00253423          	sd	sp,8(a0)
    800027c4:	e900                	sd	s0,16(a0)
    800027c6:	ed04                	sd	s1,24(a0)
    800027c8:	03253023          	sd	s2,32(a0)
    800027cc:	03353423          	sd	s3,40(a0)
    800027d0:	03453823          	sd	s4,48(a0)
    800027d4:	03553c23          	sd	s5,56(a0)
    800027d8:	05653023          	sd	s6,64(a0)
    800027dc:	05753423          	sd	s7,72(a0)
    800027e0:	05853823          	sd	s8,80(a0)
    800027e4:	05953c23          	sd	s9,88(a0)
    800027e8:	07a53023          	sd	s10,96(a0)
    800027ec:	07b53423          	sd	s11,104(a0)
    800027f0:	0005b083          	ld	ra,0(a1)
    800027f4:	0085b103          	ld	sp,8(a1)
    800027f8:	6980                	ld	s0,16(a1)
    800027fa:	6d84                	ld	s1,24(a1)
    800027fc:	0205b903          	ld	s2,32(a1)
    80002800:	0285b983          	ld	s3,40(a1)
    80002804:	0305ba03          	ld	s4,48(a1)
    80002808:	0385ba83          	ld	s5,56(a1)
    8000280c:	0405bb03          	ld	s6,64(a1)
    80002810:	0485bb83          	ld	s7,72(a1)
    80002814:	0505bc03          	ld	s8,80(a1)
    80002818:	0585bc83          	ld	s9,88(a1)
    8000281c:	0605bd03          	ld	s10,96(a1)
    80002820:	0685bd83          	ld	s11,104(a1)
    80002824:	8082                	ret

0000000080002826 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002826:	1141                	add	sp,sp,-16
    80002828:	e406                	sd	ra,8(sp)
    8000282a:	e022                	sd	s0,0(sp)
    8000282c:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    8000282e:	00006597          	auipc	a1,0x6
    80002832:	a7a58593          	add	a1,a1,-1414 # 800082a8 <etext+0x2a8>
    80002836:	00014517          	auipc	a0,0x14
    8000283a:	13a50513          	add	a0,a0,314 # 80016970 <tickslock>
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	36a080e7          	jalr	874(ra) # 80000ba8 <initlock>
}
    80002846:	60a2                	ld	ra,8(sp)
    80002848:	6402                	ld	s0,0(sp)
    8000284a:	0141                	add	sp,sp,16
    8000284c:	8082                	ret

000000008000284e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000284e:	1141                	add	sp,sp,-16
    80002850:	e422                	sd	s0,8(sp)
    80002852:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002854:	00003797          	auipc	a5,0x3
    80002858:	67c78793          	add	a5,a5,1660 # 80005ed0 <kernelvec>
    8000285c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002860:	6422                	ld	s0,8(sp)
    80002862:	0141                	add	sp,sp,16
    80002864:	8082                	ret

0000000080002866 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002866:	1141                	add	sp,sp,-16
    80002868:	e406                	sd	ra,8(sp)
    8000286a:	e022                	sd	s0,0(sp)
    8000286c:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    8000286e:	fffff097          	auipc	ra,0xfffff
    80002872:	1dc080e7          	jalr	476(ra) # 80001a4a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002876:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000287a:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000287c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002880:	00004697          	auipc	a3,0x4
    80002884:	78068693          	add	a3,a3,1920 # 80007000 <_trampoline>
    80002888:	00004717          	auipc	a4,0x4
    8000288c:	77870713          	add	a4,a4,1912 # 80007000 <_trampoline>
    80002890:	8f15                	sub	a4,a4,a3
    80002892:	040007b7          	lui	a5,0x4000
    80002896:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002898:	07b2                	sll	a5,a5,0xc
    8000289a:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000289c:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028a0:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028a2:	18002673          	csrr	a2,satp
    800028a6:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028a8:	6d30                	ld	a2,88(a0)
    800028aa:	6138                	ld	a4,64(a0)
    800028ac:	6585                	lui	a1,0x1
    800028ae:	972e                	add	a4,a4,a1
    800028b0:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028b2:	6d38                	ld	a4,88(a0)
    800028b4:	00000617          	auipc	a2,0x0
    800028b8:	13860613          	add	a2,a2,312 # 800029ec <usertrap>
    800028bc:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028be:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028c0:	8612                	mv	a2,tp
    800028c2:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c4:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028c8:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028cc:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d0:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028d4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028d6:	6f18                	ld	a4,24(a4)
    800028d8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800028dc:	6928                	ld	a0,80(a0)
    800028de:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028e0:	00004717          	auipc	a4,0x4
    800028e4:	7bc70713          	add	a4,a4,1980 # 8000709c <userret>
    800028e8:	8f15                	sub	a4,a4,a3
    800028ea:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800028ec:	577d                	li	a4,-1
    800028ee:	177e                	sll	a4,a4,0x3f
    800028f0:	8d59                	or	a0,a0,a4
    800028f2:	9782                	jalr	a5
}
    800028f4:	60a2                	ld	ra,8(sp)
    800028f6:	6402                	ld	s0,0(sp)
    800028f8:	0141                	add	sp,sp,16
    800028fa:	8082                	ret

00000000800028fc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028fc:	1101                	add	sp,sp,-32
    800028fe:	ec06                	sd	ra,24(sp)
    80002900:	e822                	sd	s0,16(sp)
    80002902:	e426                	sd	s1,8(sp)
    80002904:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002906:	00014497          	auipc	s1,0x14
    8000290a:	06a48493          	add	s1,s1,106 # 80016970 <tickslock>
    8000290e:	8526                	mv	a0,s1
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	328080e7          	jalr	808(ra) # 80000c38 <acquire>
  ticks++;
    80002918:	00006517          	auipc	a0,0x6
    8000291c:	fb850513          	add	a0,a0,-72 # 800088d0 <ticks>
    80002920:	411c                	lw	a5,0(a0)
    80002922:	2785                	addw	a5,a5,1
    80002924:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	87e080e7          	jalr	-1922(ra) # 800021a4 <wakeup>
  release(&tickslock);
    8000292e:	8526                	mv	a0,s1
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	3bc080e7          	jalr	956(ra) # 80000cec <release>
}
    80002938:	60e2                	ld	ra,24(sp)
    8000293a:	6442                	ld	s0,16(sp)
    8000293c:	64a2                	ld	s1,8(sp)
    8000293e:	6105                	add	sp,sp,32
    80002940:	8082                	ret

0000000080002942 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002942:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002946:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002948:	0a07d163          	bgez	a5,800029ea <devintr+0xa8>
{
    8000294c:	1101                	add	sp,sp,-32
    8000294e:	ec06                	sd	ra,24(sp)
    80002950:	e822                	sd	s0,16(sp)
    80002952:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002954:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002958:	46a5                	li	a3,9
    8000295a:	00d70c63          	beq	a4,a3,80002972 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    8000295e:	577d                	li	a4,-1
    80002960:	177e                	sll	a4,a4,0x3f
    80002962:	0705                	add	a4,a4,1
    return 0;
    80002964:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002966:	06e78163          	beq	a5,a4,800029c8 <devintr+0x86>
  }
}
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	6105                	add	sp,sp,32
    80002970:	8082                	ret
    80002972:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002974:	00003097          	auipc	ra,0x3
    80002978:	668080e7          	jalr	1640(ra) # 80005fdc <plic_claim>
    8000297c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000297e:	47a9                	li	a5,10
    80002980:	00f50963          	beq	a0,a5,80002992 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002984:	4785                	li	a5,1
    80002986:	00f50b63          	beq	a0,a5,8000299c <devintr+0x5a>
    return 1;
    8000298a:	4505                	li	a0,1
    } else if(irq){
    8000298c:	ec89                	bnez	s1,800029a6 <devintr+0x64>
    8000298e:	64a2                	ld	s1,8(sp)
    80002990:	bfe9                	j	8000296a <devintr+0x28>
      uartintr();
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	068080e7          	jalr	104(ra) # 800009fa <uartintr>
    if(irq)
    8000299a:	a839                	j	800029b8 <devintr+0x76>
      virtio_disk_intr();
    8000299c:	00004097          	auipc	ra,0x4
    800029a0:	b6a080e7          	jalr	-1174(ra) # 80006506 <virtio_disk_intr>
    if(irq)
    800029a4:	a811                	j	800029b8 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    800029a6:	85a6                	mv	a1,s1
    800029a8:	00006517          	auipc	a0,0x6
    800029ac:	90850513          	add	a0,a0,-1784 # 800082b0 <etext+0x2b0>
    800029b0:	ffffe097          	auipc	ra,0xffffe
    800029b4:	bfa080e7          	jalr	-1030(ra) # 800005aa <printf>
      plic_complete(irq);
    800029b8:	8526                	mv	a0,s1
    800029ba:	00003097          	auipc	ra,0x3
    800029be:	646080e7          	jalr	1606(ra) # 80006000 <plic_complete>
    return 1;
    800029c2:	4505                	li	a0,1
    800029c4:	64a2                	ld	s1,8(sp)
    800029c6:	b755                	j	8000296a <devintr+0x28>
    if(cpuid() == 0){
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	056080e7          	jalr	86(ra) # 80001a1e <cpuid>
    800029d0:	c901                	beqz	a0,800029e0 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029d2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029d6:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029d8:	14479073          	csrw	sip,a5
    return 2;
    800029dc:	4509                	li	a0,2
    800029de:	b771                	j	8000296a <devintr+0x28>
      clockintr();
    800029e0:	00000097          	auipc	ra,0x0
    800029e4:	f1c080e7          	jalr	-228(ra) # 800028fc <clockintr>
    800029e8:	b7ed                	j	800029d2 <devintr+0x90>
}
    800029ea:	8082                	ret

00000000800029ec <usertrap>:
{
    800029ec:	1101                	add	sp,sp,-32
    800029ee:	ec06                	sd	ra,24(sp)
    800029f0:	e822                	sd	s0,16(sp)
    800029f2:	e426                	sd	s1,8(sp)
    800029f4:	e04a                	sd	s2,0(sp)
    800029f6:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029fc:	1007f793          	and	a5,a5,256
    80002a00:	e3b1                	bnez	a5,80002a44 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a02:	00003797          	auipc	a5,0x3
    80002a06:	4ce78793          	add	a5,a5,1230 # 80005ed0 <kernelvec>
    80002a0a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a0e:	fffff097          	auipc	ra,0xfffff
    80002a12:	03c080e7          	jalr	60(ra) # 80001a4a <myproc>
    80002a16:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a18:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a1a:	14102773          	csrr	a4,sepc
    80002a1e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a20:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a24:	47a1                	li	a5,8
    80002a26:	02f70763          	beq	a4,a5,80002a54 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a2a:	00000097          	auipc	ra,0x0
    80002a2e:	f18080e7          	jalr	-232(ra) # 80002942 <devintr>
    80002a32:	892a                	mv	s2,a0
    80002a34:	c151                	beqz	a0,80002ab8 <usertrap+0xcc>
  if(killed(p))
    80002a36:	8526                	mv	a0,s1
    80002a38:	00000097          	auipc	ra,0x0
    80002a3c:	9b0080e7          	jalr	-1616(ra) # 800023e8 <killed>
    80002a40:	c929                	beqz	a0,80002a92 <usertrap+0xa6>
    80002a42:	a099                	j	80002a88 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002a44:	00006517          	auipc	a0,0x6
    80002a48:	88c50513          	add	a0,a0,-1908 # 800082d0 <etext+0x2d0>
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	b14080e7          	jalr	-1260(ra) # 80000560 <panic>
    if(killed(p))
    80002a54:	00000097          	auipc	ra,0x0
    80002a58:	994080e7          	jalr	-1644(ra) # 800023e8 <killed>
    80002a5c:	e921                	bnez	a0,80002aac <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002a5e:	6cb8                	ld	a4,88(s1)
    80002a60:	6f1c                	ld	a5,24(a4)
    80002a62:	0791                	add	a5,a5,4
    80002a64:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a6a:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a6e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a72:	00000097          	auipc	ra,0x0
    80002a76:	33a080e7          	jalr	826(ra) # 80002dac <syscall>
  if(killed(p))
    80002a7a:	8526                	mv	a0,s1
    80002a7c:	00000097          	auipc	ra,0x0
    80002a80:	96c080e7          	jalr	-1684(ra) # 800023e8 <killed>
    80002a84:	c911                	beqz	a0,80002a98 <usertrap+0xac>
    80002a86:	4901                	li	s2,0
    exit(-1);
    80002a88:	557d                	li	a0,-1
    80002a8a:	fffff097          	auipc	ra,0xfffff
    80002a8e:	7ea080e7          	jalr	2026(ra) # 80002274 <exit>
  if(which_dev == 2)
    80002a92:	4789                	li	a5,2
    80002a94:	04f90f63          	beq	s2,a5,80002af2 <usertrap+0x106>
  usertrapret();
    80002a98:	00000097          	auipc	ra,0x0
    80002a9c:	dce080e7          	jalr	-562(ra) # 80002866 <usertrapret>
}
    80002aa0:	60e2                	ld	ra,24(sp)
    80002aa2:	6442                	ld	s0,16(sp)
    80002aa4:	64a2                	ld	s1,8(sp)
    80002aa6:	6902                	ld	s2,0(sp)
    80002aa8:	6105                	add	sp,sp,32
    80002aaa:	8082                	ret
      exit(-1);
    80002aac:	557d                	li	a0,-1
    80002aae:	fffff097          	auipc	ra,0xfffff
    80002ab2:	7c6080e7          	jalr	1990(ra) # 80002274 <exit>
    80002ab6:	b765                	j	80002a5e <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ab8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002abc:	5890                	lw	a2,48(s1)
    80002abe:	00006517          	auipc	a0,0x6
    80002ac2:	83250513          	add	a0,a0,-1998 # 800082f0 <etext+0x2f0>
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	ae4080e7          	jalr	-1308(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ace:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ad2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	84a50513          	add	a0,a0,-1974 # 80008320 <etext+0x320>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	acc080e7          	jalr	-1332(ra) # 800005aa <printf>
    setkilled(p);
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	00000097          	auipc	ra,0x0
    80002aec:	8d4080e7          	jalr	-1836(ra) # 800023bc <setkilled>
    80002af0:	b769                	j	80002a7a <usertrap+0x8e>
    yield();
    80002af2:	fffff097          	auipc	ra,0xfffff
    80002af6:	612080e7          	jalr	1554(ra) # 80002104 <yield>
    80002afa:	bf79                	j	80002a98 <usertrap+0xac>

0000000080002afc <kerneltrap>:
{
    80002afc:	7179                	add	sp,sp,-48
    80002afe:	f406                	sd	ra,40(sp)
    80002b00:	f022                	sd	s0,32(sp)
    80002b02:	ec26                	sd	s1,24(sp)
    80002b04:	e84a                	sd	s2,16(sp)
    80002b06:	e44e                	sd	s3,8(sp)
    80002b08:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b0a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b0e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b12:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b16:	1004f793          	and	a5,s1,256
    80002b1a:	cb85                	beqz	a5,80002b4a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b1c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b20:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002b22:	ef85                	bnez	a5,80002b5a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	e1e080e7          	jalr	-482(ra) # 80002942 <devintr>
    80002b2c:	cd1d                	beqz	a0,80002b6a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b2e:	4789                	li	a5,2
    80002b30:	06f50a63          	beq	a0,a5,80002ba4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b34:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b38:	10049073          	csrw	sstatus,s1
}
    80002b3c:	70a2                	ld	ra,40(sp)
    80002b3e:	7402                	ld	s0,32(sp)
    80002b40:	64e2                	ld	s1,24(sp)
    80002b42:	6942                	ld	s2,16(sp)
    80002b44:	69a2                	ld	s3,8(sp)
    80002b46:	6145                	add	sp,sp,48
    80002b48:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b4a:	00005517          	auipc	a0,0x5
    80002b4e:	7f650513          	add	a0,a0,2038 # 80008340 <etext+0x340>
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	a0e080e7          	jalr	-1522(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002b5a:	00006517          	auipc	a0,0x6
    80002b5e:	80e50513          	add	a0,a0,-2034 # 80008368 <etext+0x368>
    80002b62:	ffffe097          	auipc	ra,0xffffe
    80002b66:	9fe080e7          	jalr	-1538(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002b6a:	85ce                	mv	a1,s3
    80002b6c:	00006517          	auipc	a0,0x6
    80002b70:	81c50513          	add	a0,a0,-2020 # 80008388 <etext+0x388>
    80002b74:	ffffe097          	auipc	ra,0xffffe
    80002b78:	a36080e7          	jalr	-1482(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b7c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b80:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b84:	00006517          	auipc	a0,0x6
    80002b88:	81450513          	add	a0,a0,-2028 # 80008398 <etext+0x398>
    80002b8c:	ffffe097          	auipc	ra,0xffffe
    80002b90:	a1e080e7          	jalr	-1506(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002b94:	00006517          	auipc	a0,0x6
    80002b98:	81c50513          	add	a0,a0,-2020 # 800083b0 <etext+0x3b0>
    80002b9c:	ffffe097          	auipc	ra,0xffffe
    80002ba0:	9c4080e7          	jalr	-1596(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ba4:	fffff097          	auipc	ra,0xfffff
    80002ba8:	ea6080e7          	jalr	-346(ra) # 80001a4a <myproc>
    80002bac:	d541                	beqz	a0,80002b34 <kerneltrap+0x38>
    80002bae:	fffff097          	auipc	ra,0xfffff
    80002bb2:	e9c080e7          	jalr	-356(ra) # 80001a4a <myproc>
    80002bb6:	4d18                	lw	a4,24(a0)
    80002bb8:	4791                	li	a5,4
    80002bba:	f6f71de3          	bne	a4,a5,80002b34 <kerneltrap+0x38>
    yield();
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	546080e7          	jalr	1350(ra) # 80002104 <yield>
    80002bc6:	b7bd                	j	80002b34 <kerneltrap+0x38>

0000000080002bc8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002bc8:	1101                	add	sp,sp,-32
    80002bca:	ec06                	sd	ra,24(sp)
    80002bcc:	e822                	sd	s0,16(sp)
    80002bce:	e426                	sd	s1,8(sp)
    80002bd0:	1000                	add	s0,sp,32
    80002bd2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002bd4:	fffff097          	auipc	ra,0xfffff
    80002bd8:	e76080e7          	jalr	-394(ra) # 80001a4a <myproc>
  switch (n) {
    80002bdc:	4795                	li	a5,5
    80002bde:	0497e163          	bltu	a5,s1,80002c20 <argraw+0x58>
    80002be2:	048a                	sll	s1,s1,0x2
    80002be4:	00006717          	auipc	a4,0x6
    80002be8:	b8c70713          	add	a4,a4,-1140 # 80008770 <states.0+0x30>
    80002bec:	94ba                	add	s1,s1,a4
    80002bee:	409c                	lw	a5,0(s1)
    80002bf0:	97ba                	add	a5,a5,a4
    80002bf2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002bf4:	6d3c                	ld	a5,88(a0)
    80002bf6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bf8:	60e2                	ld	ra,24(sp)
    80002bfa:	6442                	ld	s0,16(sp)
    80002bfc:	64a2                	ld	s1,8(sp)
    80002bfe:	6105                	add	sp,sp,32
    80002c00:	8082                	ret
    return p->trapframe->a1;
    80002c02:	6d3c                	ld	a5,88(a0)
    80002c04:	7fa8                	ld	a0,120(a5)
    80002c06:	bfcd                	j	80002bf8 <argraw+0x30>
    return p->trapframe->a2;
    80002c08:	6d3c                	ld	a5,88(a0)
    80002c0a:	63c8                	ld	a0,128(a5)
    80002c0c:	b7f5                	j	80002bf8 <argraw+0x30>
    return p->trapframe->a3;
    80002c0e:	6d3c                	ld	a5,88(a0)
    80002c10:	67c8                	ld	a0,136(a5)
    80002c12:	b7dd                	j	80002bf8 <argraw+0x30>
    return p->trapframe->a4;
    80002c14:	6d3c                	ld	a5,88(a0)
    80002c16:	6bc8                	ld	a0,144(a5)
    80002c18:	b7c5                	j	80002bf8 <argraw+0x30>
    return p->trapframe->a5;
    80002c1a:	6d3c                	ld	a5,88(a0)
    80002c1c:	6fc8                	ld	a0,152(a5)
    80002c1e:	bfe9                	j	80002bf8 <argraw+0x30>
  panic("argraw");
    80002c20:	00005517          	auipc	a0,0x5
    80002c24:	7a050513          	add	a0,a0,1952 # 800083c0 <etext+0x3c0>
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	938080e7          	jalr	-1736(ra) # 80000560 <panic>

0000000080002c30 <fetchaddr>:
{
    80002c30:	1101                	add	sp,sp,-32
    80002c32:	ec06                	sd	ra,24(sp)
    80002c34:	e822                	sd	s0,16(sp)
    80002c36:	e426                	sd	s1,8(sp)
    80002c38:	e04a                	sd	s2,0(sp)
    80002c3a:	1000                	add	s0,sp,32
    80002c3c:	84aa                	mv	s1,a0
    80002c3e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	e0a080e7          	jalr	-502(ra) # 80001a4a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c48:	653c                	ld	a5,72(a0)
    80002c4a:	02f4f863          	bgeu	s1,a5,80002c7a <fetchaddr+0x4a>
    80002c4e:	00848713          	add	a4,s1,8
    80002c52:	02e7e663          	bltu	a5,a4,80002c7e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c56:	46a1                	li	a3,8
    80002c58:	8626                	mv	a2,s1
    80002c5a:	85ca                	mv	a1,s2
    80002c5c:	6928                	ld	a0,80(a0)
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	b10080e7          	jalr	-1264(ra) # 8000176e <copyin>
    80002c66:	00a03533          	snez	a0,a0
    80002c6a:	40a00533          	neg	a0,a0
}
    80002c6e:	60e2                	ld	ra,24(sp)
    80002c70:	6442                	ld	s0,16(sp)
    80002c72:	64a2                	ld	s1,8(sp)
    80002c74:	6902                	ld	s2,0(sp)
    80002c76:	6105                	add	sp,sp,32
    80002c78:	8082                	ret
    return -1;
    80002c7a:	557d                	li	a0,-1
    80002c7c:	bfcd                	j	80002c6e <fetchaddr+0x3e>
    80002c7e:	557d                	li	a0,-1
    80002c80:	b7fd                	j	80002c6e <fetchaddr+0x3e>

0000000080002c82 <fetchstr>:
{
    80002c82:	7179                	add	sp,sp,-48
    80002c84:	f406                	sd	ra,40(sp)
    80002c86:	f022                	sd	s0,32(sp)
    80002c88:	ec26                	sd	s1,24(sp)
    80002c8a:	e84a                	sd	s2,16(sp)
    80002c8c:	e44e                	sd	s3,8(sp)
    80002c8e:	1800                	add	s0,sp,48
    80002c90:	892a                	mv	s2,a0
    80002c92:	84ae                	mv	s1,a1
    80002c94:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c96:	fffff097          	auipc	ra,0xfffff
    80002c9a:	db4080e7          	jalr	-588(ra) # 80001a4a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c9e:	86ce                	mv	a3,s3
    80002ca0:	864a                	mv	a2,s2
    80002ca2:	85a6                	mv	a1,s1
    80002ca4:	6928                	ld	a0,80(a0)
    80002ca6:	fffff097          	auipc	ra,0xfffff
    80002caa:	b56080e7          	jalr	-1194(ra) # 800017fc <copyinstr>
    80002cae:	00054e63          	bltz	a0,80002cca <fetchstr+0x48>
  return strlen(buf);
    80002cb2:	8526                	mv	a0,s1
    80002cb4:	ffffe097          	auipc	ra,0xffffe
    80002cb8:	1f4080e7          	jalr	500(ra) # 80000ea8 <strlen>
}
    80002cbc:	70a2                	ld	ra,40(sp)
    80002cbe:	7402                	ld	s0,32(sp)
    80002cc0:	64e2                	ld	s1,24(sp)
    80002cc2:	6942                	ld	s2,16(sp)
    80002cc4:	69a2                	ld	s3,8(sp)
    80002cc6:	6145                	add	sp,sp,48
    80002cc8:	8082                	ret
    return -1;
    80002cca:	557d                	li	a0,-1
    80002ccc:	bfc5                	j	80002cbc <fetchstr+0x3a>

0000000080002cce <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002cce:	1101                	add	sp,sp,-32
    80002cd0:	ec06                	sd	ra,24(sp)
    80002cd2:	e822                	sd	s0,16(sp)
    80002cd4:	e426                	sd	s1,8(sp)
    80002cd6:	1000                	add	s0,sp,32
    80002cd8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cda:	00000097          	auipc	ra,0x0
    80002cde:	eee080e7          	jalr	-274(ra) # 80002bc8 <argraw>
    80002ce2:	c088                	sw	a0,0(s1)
}
    80002ce4:	60e2                	ld	ra,24(sp)
    80002ce6:	6442                	ld	s0,16(sp)
    80002ce8:	64a2                	ld	s1,8(sp)
    80002cea:	6105                	add	sp,sp,32
    80002cec:	8082                	ret

0000000080002cee <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002cee:	1101                	add	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	1000                	add	s0,sp,32
    80002cf8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cfa:	00000097          	auipc	ra,0x0
    80002cfe:	ece080e7          	jalr	-306(ra) # 80002bc8 <argraw>
    80002d02:	e088                	sd	a0,0(s1)
}
    80002d04:	60e2                	ld	ra,24(sp)
    80002d06:	6442                	ld	s0,16(sp)
    80002d08:	64a2                	ld	s1,8(sp)
    80002d0a:	6105                	add	sp,sp,32
    80002d0c:	8082                	ret

0000000080002d0e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d0e:	7179                	add	sp,sp,-48
    80002d10:	f406                	sd	ra,40(sp)
    80002d12:	f022                	sd	s0,32(sp)
    80002d14:	ec26                	sd	s1,24(sp)
    80002d16:	e84a                	sd	s2,16(sp)
    80002d18:	1800                	add	s0,sp,48
    80002d1a:	84ae                	mv	s1,a1
    80002d1c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d1e:	fd840593          	add	a1,s0,-40
    80002d22:	00000097          	auipc	ra,0x0
    80002d26:	fcc080e7          	jalr	-52(ra) # 80002cee <argaddr>
  return fetchstr(addr, buf, max);
    80002d2a:	864a                	mv	a2,s2
    80002d2c:	85a6                	mv	a1,s1
    80002d2e:	fd843503          	ld	a0,-40(s0)
    80002d32:	00000097          	auipc	ra,0x0
    80002d36:	f50080e7          	jalr	-176(ra) # 80002c82 <fetchstr>
}
    80002d3a:	70a2                	ld	ra,40(sp)
    80002d3c:	7402                	ld	s0,32(sp)
    80002d3e:	64e2                	ld	s1,24(sp)
    80002d40:	6942                	ld	s2,16(sp)
    80002d42:	6145                	add	sp,sp,48
    80002d44:	8082                	ret

0000000080002d46 <argpstat>:

//////////////////////////////////////////////
//Initializes struct pstat, and checks if there is enogh size for it.
int
argpstat(int n, struct pstat *pp, int size)
{
    80002d46:	7139                	add	sp,sp,-64
    80002d48:	fc06                	sd	ra,56(sp)
    80002d4a:	f822                	sd	s0,48(sp)
    80002d4c:	f426                	sd	s1,40(sp)
    80002d4e:	f04a                	sd	s2,32(sp)
    80002d50:	ec4e                	sd	s3,24(sp)
    80002d52:	0080                	add	s0,sp,64
    80002d54:	892a                	mv	s2,a0
    80002d56:	84b2                	mv	s1,a2
  struct proc *curproc = myproc();
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	cf2080e7          	jalr	-782(ra) # 80001a4a <myproc>
    80002d60:	89aa                	mv	s3,a0
 
  int i;
  argint(n, &i);
    80002d62:	fcc40593          	add	a1,s0,-52
    80002d66:	854a                	mv	a0,s2
    80002d68:	00000097          	auipc	ra,0x0
    80002d6c:	f66080e7          	jalr	-154(ra) # 80002cce <argint>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    80002d70:	0204ca63          	bltz	s1,80002da4 <argpstat+0x5e>
    80002d74:	fcc42783          	lw	a5,-52(s0)
    80002d78:	0489b503          	ld	a0,72(s3)
    80002d7c:	02079713          	sll	a4,a5,0x20
    80002d80:	9301                	srl	a4,a4,0x20
    80002d82:	02a77363          	bgeu	a4,a0,80002da8 <argpstat+0x62>
    80002d86:	9cbd                	addw	s1,s1,a5
    80002d88:	1482                	sll	s1,s1,0x20
    80002d8a:	9081                	srl	s1,s1,0x20
    80002d8c:	00953533          	sltu	a0,a0,s1
    80002d90:	40a0053b          	negw	a0,a0
    80002d94:	2501                	sext.w	a0,a0
    return -1;

  struct pstat p;
  pp = (struct pstat*)&p;
  return 0;
}
    80002d96:	70e2                	ld	ra,56(sp)
    80002d98:	7442                	ld	s0,48(sp)
    80002d9a:	74a2                	ld	s1,40(sp)
    80002d9c:	7902                	ld	s2,32(sp)
    80002d9e:	69e2                	ld	s3,24(sp)
    80002da0:	6121                	add	sp,sp,64
    80002da2:	8082                	ret
    return -1;
    80002da4:	557d                	li	a0,-1
    80002da6:	bfc5                	j	80002d96 <argpstat+0x50>
    80002da8:	557d                	li	a0,-1
    80002daa:	b7f5                	j	80002d96 <argpstat+0x50>

0000000080002dac <syscall>:

};

void
syscall(void)
{
    80002dac:	1101                	add	sp,sp,-32
    80002dae:	ec06                	sd	ra,24(sp)
    80002db0:	e822                	sd	s0,16(sp)
    80002db2:	e426                	sd	s1,8(sp)
    80002db4:	e04a                	sd	s2,0(sp)
    80002db6:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	c92080e7          	jalr	-878(ra) # 80001a4a <myproc>
    80002dc0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dc2:	05853903          	ld	s2,88(a0)
    80002dc6:	0a893783          	ld	a5,168(s2)
    80002dca:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dce:	37fd                	addw	a5,a5,-1
    80002dd0:	4759                	li	a4,22
    80002dd2:	00f76f63          	bltu	a4,a5,80002df0 <syscall+0x44>
    80002dd6:	00369713          	sll	a4,a3,0x3
    80002dda:	00006797          	auipc	a5,0x6
    80002dde:	9ae78793          	add	a5,a5,-1618 # 80008788 <syscalls>
    80002de2:	97ba                	add	a5,a5,a4
    80002de4:	639c                	ld	a5,0(a5)
    80002de6:	c789                	beqz	a5,80002df0 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002de8:	9782                	jalr	a5
    80002dea:	06a93823          	sd	a0,112(s2)
    80002dee:	a839                	j	80002e0c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002df0:	15848613          	add	a2,s1,344
    80002df4:	588c                	lw	a1,48(s1)
    80002df6:	00005517          	auipc	a0,0x5
    80002dfa:	5d250513          	add	a0,a0,1490 # 800083c8 <etext+0x3c8>
    80002dfe:	ffffd097          	auipc	ra,0xffffd
    80002e02:	7ac080e7          	jalr	1964(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e06:	6cbc                	ld	a5,88(s1)
    80002e08:	577d                	li	a4,-1
    80002e0a:	fbb8                	sd	a4,112(a5)
  }
}
    80002e0c:	60e2                	ld	ra,24(sp)
    80002e0e:	6442                	ld	s0,16(sp)
    80002e10:	64a2                	ld	s1,8(sp)
    80002e12:	6902                	ld	s2,0(sp)
    80002e14:	6105                	add	sp,sp,32
    80002e16:	8082                	ret

0000000080002e18 <sys_exit>:
#include "proc.h"


uint64
sys_exit(void)
{
    80002e18:	1101                	add	sp,sp,-32
    80002e1a:	ec06                	sd	ra,24(sp)
    80002e1c:	e822                	sd	s0,16(sp)
    80002e1e:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002e20:	fec40593          	add	a1,s0,-20
    80002e24:	4501                	li	a0,0
    80002e26:	00000097          	auipc	ra,0x0
    80002e2a:	ea8080e7          	jalr	-344(ra) # 80002cce <argint>
  exit(n);
    80002e2e:	fec42503          	lw	a0,-20(s0)
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	442080e7          	jalr	1090(ra) # 80002274 <exit>
  return 0;  // not reached
}
    80002e3a:	4501                	li	a0,0
    80002e3c:	60e2                	ld	ra,24(sp)
    80002e3e:	6442                	ld	s0,16(sp)
    80002e40:	6105                	add	sp,sp,32
    80002e42:	8082                	ret

0000000080002e44 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e44:	1141                	add	sp,sp,-16
    80002e46:	e406                	sd	ra,8(sp)
    80002e48:	e022                	sd	s0,0(sp)
    80002e4a:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002e4c:	fffff097          	auipc	ra,0xfffff
    80002e50:	bfe080e7          	jalr	-1026(ra) # 80001a4a <myproc>
}
    80002e54:	5908                	lw	a0,48(a0)
    80002e56:	60a2                	ld	ra,8(sp)
    80002e58:	6402                	ld	s0,0(sp)
    80002e5a:	0141                	add	sp,sp,16
    80002e5c:	8082                	ret

0000000080002e5e <sys_fork>:

uint64
sys_fork(void)
{
    80002e5e:	1141                	add	sp,sp,-16
    80002e60:	e406                	sd	ra,8(sp)
    80002e62:	e022                	sd	s0,0(sp)
    80002e64:	0800                	add	s0,sp,16
  return fork();
    80002e66:	fffff097          	auipc	ra,0xfffff
    80002e6a:	f9e080e7          	jalr	-98(ra) # 80001e04 <fork>
}
    80002e6e:	60a2                	ld	ra,8(sp)
    80002e70:	6402                	ld	s0,0(sp)
    80002e72:	0141                	add	sp,sp,16
    80002e74:	8082                	ret

0000000080002e76 <sys_wait>:

uint64
sys_wait(void)
{
    80002e76:	1101                	add	sp,sp,-32
    80002e78:	ec06                	sd	ra,24(sp)
    80002e7a:	e822                	sd	s0,16(sp)
    80002e7c:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e7e:	fe840593          	add	a1,s0,-24
    80002e82:	4501                	li	a0,0
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	e6a080e7          	jalr	-406(ra) # 80002cee <argaddr>
  return wait(p);
    80002e8c:	fe843503          	ld	a0,-24(s0)
    80002e90:	fffff097          	auipc	ra,0xfffff
    80002e94:	58a080e7          	jalr	1418(ra) # 8000241a <wait>
}
    80002e98:	60e2                	ld	ra,24(sp)
    80002e9a:	6442                	ld	s0,16(sp)
    80002e9c:	6105                	add	sp,sp,32
    80002e9e:	8082                	ret

0000000080002ea0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ea0:	7179                	add	sp,sp,-48
    80002ea2:	f406                	sd	ra,40(sp)
    80002ea4:	f022                	sd	s0,32(sp)
    80002ea6:	ec26                	sd	s1,24(sp)
    80002ea8:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002eaa:	fdc40593          	add	a1,s0,-36
    80002eae:	4501                	li	a0,0
    80002eb0:	00000097          	auipc	ra,0x0
    80002eb4:	e1e080e7          	jalr	-482(ra) # 80002cce <argint>
  addr = myproc()->sz;
    80002eb8:	fffff097          	auipc	ra,0xfffff
    80002ebc:	b92080e7          	jalr	-1134(ra) # 80001a4a <myproc>
    80002ec0:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002ec2:	fdc42503          	lw	a0,-36(s0)
    80002ec6:	fffff097          	auipc	ra,0xfffff
    80002eca:	ee2080e7          	jalr	-286(ra) # 80001da8 <growproc>
    80002ece:	00054863          	bltz	a0,80002ede <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002ed2:	8526                	mv	a0,s1
    80002ed4:	70a2                	ld	ra,40(sp)
    80002ed6:	7402                	ld	s0,32(sp)
    80002ed8:	64e2                	ld	s1,24(sp)
    80002eda:	6145                	add	sp,sp,48
    80002edc:	8082                	ret
    return -1;
    80002ede:	54fd                	li	s1,-1
    80002ee0:	bfcd                	j	80002ed2 <sys_sbrk+0x32>

0000000080002ee2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ee2:	7139                	add	sp,sp,-64
    80002ee4:	fc06                	sd	ra,56(sp)
    80002ee6:	f822                	sd	s0,48(sp)
    80002ee8:	f04a                	sd	s2,32(sp)
    80002eea:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002eec:	fcc40593          	add	a1,s0,-52
    80002ef0:	4501                	li	a0,0
    80002ef2:	00000097          	auipc	ra,0x0
    80002ef6:	ddc080e7          	jalr	-548(ra) # 80002cce <argint>
  acquire(&tickslock);
    80002efa:	00014517          	auipc	a0,0x14
    80002efe:	a7650513          	add	a0,a0,-1418 # 80016970 <tickslock>
    80002f02:	ffffe097          	auipc	ra,0xffffe
    80002f06:	d36080e7          	jalr	-714(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80002f0a:	00006917          	auipc	s2,0x6
    80002f0e:	9c692903          	lw	s2,-1594(s2) # 800088d0 <ticks>
  while(ticks - ticks0 < n){
    80002f12:	fcc42783          	lw	a5,-52(s0)
    80002f16:	c3b9                	beqz	a5,80002f5c <sys_sleep+0x7a>
    80002f18:	f426                	sd	s1,40(sp)
    80002f1a:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f1c:	00014997          	auipc	s3,0x14
    80002f20:	a5498993          	add	s3,s3,-1452 # 80016970 <tickslock>
    80002f24:	00006497          	auipc	s1,0x6
    80002f28:	9ac48493          	add	s1,s1,-1620 # 800088d0 <ticks>
    if(killed(myproc())){
    80002f2c:	fffff097          	auipc	ra,0xfffff
    80002f30:	b1e080e7          	jalr	-1250(ra) # 80001a4a <myproc>
    80002f34:	fffff097          	auipc	ra,0xfffff
    80002f38:	4b4080e7          	jalr	1204(ra) # 800023e8 <killed>
    80002f3c:	ed15                	bnez	a0,80002f78 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f3e:	85ce                	mv	a1,s3
    80002f40:	8526                	mv	a0,s1
    80002f42:	fffff097          	auipc	ra,0xfffff
    80002f46:	1fe080e7          	jalr	510(ra) # 80002140 <sleep>
  while(ticks - ticks0 < n){
    80002f4a:	409c                	lw	a5,0(s1)
    80002f4c:	412787bb          	subw	a5,a5,s2
    80002f50:	fcc42703          	lw	a4,-52(s0)
    80002f54:	fce7ece3          	bltu	a5,a4,80002f2c <sys_sleep+0x4a>
    80002f58:	74a2                	ld	s1,40(sp)
    80002f5a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f5c:	00014517          	auipc	a0,0x14
    80002f60:	a1450513          	add	a0,a0,-1516 # 80016970 <tickslock>
    80002f64:	ffffe097          	auipc	ra,0xffffe
    80002f68:	d88080e7          	jalr	-632(ra) # 80000cec <release>
  return 0;
    80002f6c:	4501                	li	a0,0
}
    80002f6e:	70e2                	ld	ra,56(sp)
    80002f70:	7442                	ld	s0,48(sp)
    80002f72:	7902                	ld	s2,32(sp)
    80002f74:	6121                	add	sp,sp,64
    80002f76:	8082                	ret
      release(&tickslock);
    80002f78:	00014517          	auipc	a0,0x14
    80002f7c:	9f850513          	add	a0,a0,-1544 # 80016970 <tickslock>
    80002f80:	ffffe097          	auipc	ra,0xffffe
    80002f84:	d6c080e7          	jalr	-660(ra) # 80000cec <release>
      return -1;
    80002f88:	557d                	li	a0,-1
    80002f8a:	74a2                	ld	s1,40(sp)
    80002f8c:	69e2                	ld	s3,24(sp)
    80002f8e:	b7c5                	j	80002f6e <sys_sleep+0x8c>

0000000080002f90 <sys_kill>:

uint64
sys_kill(void)
{
    80002f90:	1101                	add	sp,sp,-32
    80002f92:	ec06                	sd	ra,24(sp)
    80002f94:	e822                	sd	s0,16(sp)
    80002f96:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f98:	fec40593          	add	a1,s0,-20
    80002f9c:	4501                	li	a0,0
    80002f9e:	00000097          	auipc	ra,0x0
    80002fa2:	d30080e7          	jalr	-720(ra) # 80002cce <argint>
  return kill(pid);
    80002fa6:	fec42503          	lw	a0,-20(s0)
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	3a0080e7          	jalr	928(ra) # 8000234a <kill>
}
    80002fb2:	60e2                	ld	ra,24(sp)
    80002fb4:	6442                	ld	s0,16(sp)
    80002fb6:	6105                	add	sp,sp,32
    80002fb8:	8082                	ret

0000000080002fba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fba:	1101                	add	sp,sp,-32
    80002fbc:	ec06                	sd	ra,24(sp)
    80002fbe:	e822                	sd	s0,16(sp)
    80002fc0:	e426                	sd	s1,8(sp)
    80002fc2:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fc4:	00014517          	auipc	a0,0x14
    80002fc8:	9ac50513          	add	a0,a0,-1620 # 80016970 <tickslock>
    80002fcc:	ffffe097          	auipc	ra,0xffffe
    80002fd0:	c6c080e7          	jalr	-916(ra) # 80000c38 <acquire>
  xticks = ticks;
    80002fd4:	00006497          	auipc	s1,0x6
    80002fd8:	8fc4a483          	lw	s1,-1796(s1) # 800088d0 <ticks>
  release(&tickslock);
    80002fdc:	00014517          	auipc	a0,0x14
    80002fe0:	99450513          	add	a0,a0,-1644 # 80016970 <tickslock>
    80002fe4:	ffffe097          	auipc	ra,0xffffe
    80002fe8:	d08080e7          	jalr	-760(ra) # 80000cec <release>
  return xticks;
}
    80002fec:	02049513          	sll	a0,s1,0x20
    80002ff0:	9101                	srl	a0,a0,0x20
    80002ff2:	60e2                	ld	ra,24(sp)
    80002ff4:	6442                	ld	s0,16(sp)
    80002ff6:	64a2                	ld	s1,8(sp)
    80002ff8:	6105                	add	sp,sp,32
    80002ffa:	8082                	ret

0000000080002ffc <sys_setpriority>:

/////////////////////////////////////////////////////////////////////////////////////////////////////
uint64
sys_setpriority(void)
{
    80002ffc:	1101                	add	sp,sp,-32
    80002ffe:	ec06                	sd	ra,24(sp)
    80003000:	e822                	sd	s0,16(sp)
    80003002:	1000                	add	s0,sp,32
  int priority;
  argint(0, &priority);
    80003004:	fec40593          	add	a1,s0,-20
    80003008:	4501                	li	a0,0
    8000300a:	00000097          	auipc	ra,0x0
    8000300e:	cc4080e7          	jalr	-828(ra) # 80002cce <argint>
  return setpriority(priority);
    80003012:	fec42503          	lw	a0,-20(s0)
    80003016:	fffff097          	auipc	ra,0xfffff
    8000301a:	68e080e7          	jalr	1678(ra) # 800026a4 <setpriority>
}
    8000301e:	60e2                	ld	ra,24(sp)
    80003020:	6442                	ld	s0,16(sp)
    80003022:	6105                	add	sp,sp,32
    80003024:	8082                	ret

0000000080003026 <sys_getpinfo>:


uint64
sys_getpinfo(void)
{
    80003026:	7179                	add	sp,sp,-48
    80003028:	f406                	sd	ra,40(sp)
    8000302a:	f022                	sd	s0,32(sp)
    8000302c:	ec26                	sd	s1,24(sp)
    8000302e:	1800                	add	s0,sp,48
    80003030:	81010113          	add	sp,sp,-2032
  struct pstat pstats;

  //Checks if the current instantiation of the struct pstat is allowed.
  if(argpstat (0 , &pstats ,sizeof(struct pstat)) < 0)
    80003034:	6605                	lui	a2,0x1
    80003036:	80060613          	add	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000303a:	74fd                	lui	s1,0xfffff
    8000303c:	7e048793          	add	a5,s1,2016 # fffffffffffff7e0 <end+0xffffffff7ffdda90>
    80003040:	008785b3          	add	a1,a5,s0
    80003044:	4501                	li	a0,0
    80003046:	00000097          	auipc	ra,0x0
    8000304a:	d00080e7          	jalr	-768(ra) # 80002d46 <argpstat>
    8000304e:	87aa                	mv	a5,a0
    return -1;
    80003050:	557d                	li	a0,-1
  if(argpstat (0 , &pstats ,sizeof(struct pstat)) < 0)
    80003052:	0007ca63          	bltz	a5,80003066 <sys_getpinfo+0x40>

  return getpinfo(&pstats);
    80003056:	7e048793          	add	a5,s1,2016
    8000305a:	00878533          	add	a0,a5,s0
    8000305e:	fffff097          	auipc	ra,0xfffff
    80003062:	696080e7          	jalr	1686(ra) # 800026f4 <getpinfo>
    80003066:	7f010113          	add	sp,sp,2032
    8000306a:	70a2                	ld	ra,40(sp)
    8000306c:	7402                	ld	s0,32(sp)
    8000306e:	64e2                	ld	s1,24(sp)
    80003070:	6145                	add	sp,sp,48
    80003072:	8082                	ret

0000000080003074 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003074:	7179                	add	sp,sp,-48
    80003076:	f406                	sd	ra,40(sp)
    80003078:	f022                	sd	s0,32(sp)
    8000307a:	ec26                	sd	s1,24(sp)
    8000307c:	e84a                	sd	s2,16(sp)
    8000307e:	e44e                	sd	s3,8(sp)
    80003080:	e052                	sd	s4,0(sp)
    80003082:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003084:	00005597          	auipc	a1,0x5
    80003088:	36458593          	add	a1,a1,868 # 800083e8 <etext+0x3e8>
    8000308c:	00014517          	auipc	a0,0x14
    80003090:	8fc50513          	add	a0,a0,-1796 # 80016988 <bcache>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	b14080e7          	jalr	-1260(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000309c:	0001c797          	auipc	a5,0x1c
    800030a0:	8ec78793          	add	a5,a5,-1812 # 8001e988 <bcache+0x8000>
    800030a4:	0001c717          	auipc	a4,0x1c
    800030a8:	b4c70713          	add	a4,a4,-1204 # 8001ebf0 <bcache+0x8268>
    800030ac:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030b0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030b4:	00014497          	auipc	s1,0x14
    800030b8:	8ec48493          	add	s1,s1,-1812 # 800169a0 <bcache+0x18>
    b->next = bcache.head.next;
    800030bc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030be:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030c0:	00005a17          	auipc	s4,0x5
    800030c4:	330a0a13          	add	s4,s4,816 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    800030c8:	2b893783          	ld	a5,696(s2)
    800030cc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030ce:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030d2:	85d2                	mv	a1,s4
    800030d4:	01048513          	add	a0,s1,16
    800030d8:	00001097          	auipc	ra,0x1
    800030dc:	4e8080e7          	jalr	1256(ra) # 800045c0 <initsleeplock>
    bcache.head.next->prev = b;
    800030e0:	2b893783          	ld	a5,696(s2)
    800030e4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030e6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ea:	45848493          	add	s1,s1,1112
    800030ee:	fd349de3          	bne	s1,s3,800030c8 <binit+0x54>
  }
}
    800030f2:	70a2                	ld	ra,40(sp)
    800030f4:	7402                	ld	s0,32(sp)
    800030f6:	64e2                	ld	s1,24(sp)
    800030f8:	6942                	ld	s2,16(sp)
    800030fa:	69a2                	ld	s3,8(sp)
    800030fc:	6a02                	ld	s4,0(sp)
    800030fe:	6145                	add	sp,sp,48
    80003100:	8082                	ret

0000000080003102 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003102:	7179                	add	sp,sp,-48
    80003104:	f406                	sd	ra,40(sp)
    80003106:	f022                	sd	s0,32(sp)
    80003108:	ec26                	sd	s1,24(sp)
    8000310a:	e84a                	sd	s2,16(sp)
    8000310c:	e44e                	sd	s3,8(sp)
    8000310e:	1800                	add	s0,sp,48
    80003110:	892a                	mv	s2,a0
    80003112:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003114:	00014517          	auipc	a0,0x14
    80003118:	87450513          	add	a0,a0,-1932 # 80016988 <bcache>
    8000311c:	ffffe097          	auipc	ra,0xffffe
    80003120:	b1c080e7          	jalr	-1252(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003124:	0001c497          	auipc	s1,0x1c
    80003128:	b1c4b483          	ld	s1,-1252(s1) # 8001ec40 <bcache+0x82b8>
    8000312c:	0001c797          	auipc	a5,0x1c
    80003130:	ac478793          	add	a5,a5,-1340 # 8001ebf0 <bcache+0x8268>
    80003134:	02f48f63          	beq	s1,a5,80003172 <bread+0x70>
    80003138:	873e                	mv	a4,a5
    8000313a:	a021                	j	80003142 <bread+0x40>
    8000313c:	68a4                	ld	s1,80(s1)
    8000313e:	02e48a63          	beq	s1,a4,80003172 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003142:	449c                	lw	a5,8(s1)
    80003144:	ff279ce3          	bne	a5,s2,8000313c <bread+0x3a>
    80003148:	44dc                	lw	a5,12(s1)
    8000314a:	ff3799e3          	bne	a5,s3,8000313c <bread+0x3a>
      b->refcnt++;
    8000314e:	40bc                	lw	a5,64(s1)
    80003150:	2785                	addw	a5,a5,1
    80003152:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003154:	00014517          	auipc	a0,0x14
    80003158:	83450513          	add	a0,a0,-1996 # 80016988 <bcache>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	b90080e7          	jalr	-1136(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80003164:	01048513          	add	a0,s1,16
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	492080e7          	jalr	1170(ra) # 800045fa <acquiresleep>
      return b;
    80003170:	a8b9                	j	800031ce <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003172:	0001c497          	auipc	s1,0x1c
    80003176:	ac64b483          	ld	s1,-1338(s1) # 8001ec38 <bcache+0x82b0>
    8000317a:	0001c797          	auipc	a5,0x1c
    8000317e:	a7678793          	add	a5,a5,-1418 # 8001ebf0 <bcache+0x8268>
    80003182:	00f48863          	beq	s1,a5,80003192 <bread+0x90>
    80003186:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003188:	40bc                	lw	a5,64(s1)
    8000318a:	cf81                	beqz	a5,800031a2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000318c:	64a4                	ld	s1,72(s1)
    8000318e:	fee49de3          	bne	s1,a4,80003188 <bread+0x86>
  panic("bget: no buffers");
    80003192:	00005517          	auipc	a0,0x5
    80003196:	26650513          	add	a0,a0,614 # 800083f8 <etext+0x3f8>
    8000319a:	ffffd097          	auipc	ra,0xffffd
    8000319e:	3c6080e7          	jalr	966(ra) # 80000560 <panic>
      b->dev = dev;
    800031a2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031a6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031aa:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031ae:	4785                	li	a5,1
    800031b0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031b2:	00013517          	auipc	a0,0x13
    800031b6:	7d650513          	add	a0,a0,2006 # 80016988 <bcache>
    800031ba:	ffffe097          	auipc	ra,0xffffe
    800031be:	b32080e7          	jalr	-1230(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    800031c2:	01048513          	add	a0,s1,16
    800031c6:	00001097          	auipc	ra,0x1
    800031ca:	434080e7          	jalr	1076(ra) # 800045fa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031ce:	409c                	lw	a5,0(s1)
    800031d0:	cb89                	beqz	a5,800031e2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031d2:	8526                	mv	a0,s1
    800031d4:	70a2                	ld	ra,40(sp)
    800031d6:	7402                	ld	s0,32(sp)
    800031d8:	64e2                	ld	s1,24(sp)
    800031da:	6942                	ld	s2,16(sp)
    800031dc:	69a2                	ld	s3,8(sp)
    800031de:	6145                	add	sp,sp,48
    800031e0:	8082                	ret
    virtio_disk_rw(b, 0);
    800031e2:	4581                	li	a1,0
    800031e4:	8526                	mv	a0,s1
    800031e6:	00003097          	auipc	ra,0x3
    800031ea:	0f2080e7          	jalr	242(ra) # 800062d8 <virtio_disk_rw>
    b->valid = 1;
    800031ee:	4785                	li	a5,1
    800031f0:	c09c                	sw	a5,0(s1)
  return b;
    800031f2:	b7c5                	j	800031d2 <bread+0xd0>

00000000800031f4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031f4:	1101                	add	sp,sp,-32
    800031f6:	ec06                	sd	ra,24(sp)
    800031f8:	e822                	sd	s0,16(sp)
    800031fa:	e426                	sd	s1,8(sp)
    800031fc:	1000                	add	s0,sp,32
    800031fe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003200:	0541                	add	a0,a0,16
    80003202:	00001097          	auipc	ra,0x1
    80003206:	492080e7          	jalr	1170(ra) # 80004694 <holdingsleep>
    8000320a:	cd01                	beqz	a0,80003222 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000320c:	4585                	li	a1,1
    8000320e:	8526                	mv	a0,s1
    80003210:	00003097          	auipc	ra,0x3
    80003214:	0c8080e7          	jalr	200(ra) # 800062d8 <virtio_disk_rw>
}
    80003218:	60e2                	ld	ra,24(sp)
    8000321a:	6442                	ld	s0,16(sp)
    8000321c:	64a2                	ld	s1,8(sp)
    8000321e:	6105                	add	sp,sp,32
    80003220:	8082                	ret
    panic("bwrite");
    80003222:	00005517          	auipc	a0,0x5
    80003226:	1ee50513          	add	a0,a0,494 # 80008410 <etext+0x410>
    8000322a:	ffffd097          	auipc	ra,0xffffd
    8000322e:	336080e7          	jalr	822(ra) # 80000560 <panic>

0000000080003232 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003232:	1101                	add	sp,sp,-32
    80003234:	ec06                	sd	ra,24(sp)
    80003236:	e822                	sd	s0,16(sp)
    80003238:	e426                	sd	s1,8(sp)
    8000323a:	e04a                	sd	s2,0(sp)
    8000323c:	1000                	add	s0,sp,32
    8000323e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003240:	01050913          	add	s2,a0,16
    80003244:	854a                	mv	a0,s2
    80003246:	00001097          	auipc	ra,0x1
    8000324a:	44e080e7          	jalr	1102(ra) # 80004694 <holdingsleep>
    8000324e:	c925                	beqz	a0,800032be <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003250:	854a                	mv	a0,s2
    80003252:	00001097          	auipc	ra,0x1
    80003256:	3fe080e7          	jalr	1022(ra) # 80004650 <releasesleep>

  acquire(&bcache.lock);
    8000325a:	00013517          	auipc	a0,0x13
    8000325e:	72e50513          	add	a0,a0,1838 # 80016988 <bcache>
    80003262:	ffffe097          	auipc	ra,0xffffe
    80003266:	9d6080e7          	jalr	-1578(ra) # 80000c38 <acquire>
  b->refcnt--;
    8000326a:	40bc                	lw	a5,64(s1)
    8000326c:	37fd                	addw	a5,a5,-1
    8000326e:	0007871b          	sext.w	a4,a5
    80003272:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003274:	e71d                	bnez	a4,800032a2 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003276:	68b8                	ld	a4,80(s1)
    80003278:	64bc                	ld	a5,72(s1)
    8000327a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000327c:	68b8                	ld	a4,80(s1)
    8000327e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003280:	0001b797          	auipc	a5,0x1b
    80003284:	70878793          	add	a5,a5,1800 # 8001e988 <bcache+0x8000>
    80003288:	2b87b703          	ld	a4,696(a5)
    8000328c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000328e:	0001c717          	auipc	a4,0x1c
    80003292:	96270713          	add	a4,a4,-1694 # 8001ebf0 <bcache+0x8268>
    80003296:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003298:	2b87b703          	ld	a4,696(a5)
    8000329c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000329e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032a2:	00013517          	auipc	a0,0x13
    800032a6:	6e650513          	add	a0,a0,1766 # 80016988 <bcache>
    800032aa:	ffffe097          	auipc	ra,0xffffe
    800032ae:	a42080e7          	jalr	-1470(ra) # 80000cec <release>
}
    800032b2:	60e2                	ld	ra,24(sp)
    800032b4:	6442                	ld	s0,16(sp)
    800032b6:	64a2                	ld	s1,8(sp)
    800032b8:	6902                	ld	s2,0(sp)
    800032ba:	6105                	add	sp,sp,32
    800032bc:	8082                	ret
    panic("brelse");
    800032be:	00005517          	auipc	a0,0x5
    800032c2:	15a50513          	add	a0,a0,346 # 80008418 <etext+0x418>
    800032c6:	ffffd097          	auipc	ra,0xffffd
    800032ca:	29a080e7          	jalr	666(ra) # 80000560 <panic>

00000000800032ce <bpin>:

void
bpin(struct buf *b) {
    800032ce:	1101                	add	sp,sp,-32
    800032d0:	ec06                	sd	ra,24(sp)
    800032d2:	e822                	sd	s0,16(sp)
    800032d4:	e426                	sd	s1,8(sp)
    800032d6:	1000                	add	s0,sp,32
    800032d8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032da:	00013517          	auipc	a0,0x13
    800032de:	6ae50513          	add	a0,a0,1710 # 80016988 <bcache>
    800032e2:	ffffe097          	auipc	ra,0xffffe
    800032e6:	956080e7          	jalr	-1706(ra) # 80000c38 <acquire>
  b->refcnt++;
    800032ea:	40bc                	lw	a5,64(s1)
    800032ec:	2785                	addw	a5,a5,1
    800032ee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032f0:	00013517          	auipc	a0,0x13
    800032f4:	69850513          	add	a0,a0,1688 # 80016988 <bcache>
    800032f8:	ffffe097          	auipc	ra,0xffffe
    800032fc:	9f4080e7          	jalr	-1548(ra) # 80000cec <release>
}
    80003300:	60e2                	ld	ra,24(sp)
    80003302:	6442                	ld	s0,16(sp)
    80003304:	64a2                	ld	s1,8(sp)
    80003306:	6105                	add	sp,sp,32
    80003308:	8082                	ret

000000008000330a <bunpin>:

void
bunpin(struct buf *b) {
    8000330a:	1101                	add	sp,sp,-32
    8000330c:	ec06                	sd	ra,24(sp)
    8000330e:	e822                	sd	s0,16(sp)
    80003310:	e426                	sd	s1,8(sp)
    80003312:	1000                	add	s0,sp,32
    80003314:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003316:	00013517          	auipc	a0,0x13
    8000331a:	67250513          	add	a0,a0,1650 # 80016988 <bcache>
    8000331e:	ffffe097          	auipc	ra,0xffffe
    80003322:	91a080e7          	jalr	-1766(ra) # 80000c38 <acquire>
  b->refcnt--;
    80003326:	40bc                	lw	a5,64(s1)
    80003328:	37fd                	addw	a5,a5,-1
    8000332a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000332c:	00013517          	auipc	a0,0x13
    80003330:	65c50513          	add	a0,a0,1628 # 80016988 <bcache>
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	9b8080e7          	jalr	-1608(ra) # 80000cec <release>
}
    8000333c:	60e2                	ld	ra,24(sp)
    8000333e:	6442                	ld	s0,16(sp)
    80003340:	64a2                	ld	s1,8(sp)
    80003342:	6105                	add	sp,sp,32
    80003344:	8082                	ret

0000000080003346 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003346:	1101                	add	sp,sp,-32
    80003348:	ec06                	sd	ra,24(sp)
    8000334a:	e822                	sd	s0,16(sp)
    8000334c:	e426                	sd	s1,8(sp)
    8000334e:	e04a                	sd	s2,0(sp)
    80003350:	1000                	add	s0,sp,32
    80003352:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003354:	00d5d59b          	srlw	a1,a1,0xd
    80003358:	0001c797          	auipc	a5,0x1c
    8000335c:	d0c7a783          	lw	a5,-756(a5) # 8001f064 <sb+0x1c>
    80003360:	9dbd                	addw	a1,a1,a5
    80003362:	00000097          	auipc	ra,0x0
    80003366:	da0080e7          	jalr	-608(ra) # 80003102 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000336a:	0074f713          	and	a4,s1,7
    8000336e:	4785                	li	a5,1
    80003370:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003374:	14ce                	sll	s1,s1,0x33
    80003376:	90d9                	srl	s1,s1,0x36
    80003378:	00950733          	add	a4,a0,s1
    8000337c:	05874703          	lbu	a4,88(a4)
    80003380:	00e7f6b3          	and	a3,a5,a4
    80003384:	c69d                	beqz	a3,800033b2 <bfree+0x6c>
    80003386:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003388:	94aa                	add	s1,s1,a0
    8000338a:	fff7c793          	not	a5,a5
    8000338e:	8f7d                	and	a4,a4,a5
    80003390:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003394:	00001097          	auipc	ra,0x1
    80003398:	148080e7          	jalr	328(ra) # 800044dc <log_write>
  brelse(bp);
    8000339c:	854a                	mv	a0,s2
    8000339e:	00000097          	auipc	ra,0x0
    800033a2:	e94080e7          	jalr	-364(ra) # 80003232 <brelse>
}
    800033a6:	60e2                	ld	ra,24(sp)
    800033a8:	6442                	ld	s0,16(sp)
    800033aa:	64a2                	ld	s1,8(sp)
    800033ac:	6902                	ld	s2,0(sp)
    800033ae:	6105                	add	sp,sp,32
    800033b0:	8082                	ret
    panic("freeing free block");
    800033b2:	00005517          	auipc	a0,0x5
    800033b6:	06e50513          	add	a0,a0,110 # 80008420 <etext+0x420>
    800033ba:	ffffd097          	auipc	ra,0xffffd
    800033be:	1a6080e7          	jalr	422(ra) # 80000560 <panic>

00000000800033c2 <balloc>:
{
    800033c2:	711d                	add	sp,sp,-96
    800033c4:	ec86                	sd	ra,88(sp)
    800033c6:	e8a2                	sd	s0,80(sp)
    800033c8:	e4a6                	sd	s1,72(sp)
    800033ca:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033cc:	0001c797          	auipc	a5,0x1c
    800033d0:	c807a783          	lw	a5,-896(a5) # 8001f04c <sb+0x4>
    800033d4:	10078f63          	beqz	a5,800034f2 <balloc+0x130>
    800033d8:	e0ca                	sd	s2,64(sp)
    800033da:	fc4e                	sd	s3,56(sp)
    800033dc:	f852                	sd	s4,48(sp)
    800033de:	f456                	sd	s5,40(sp)
    800033e0:	f05a                	sd	s6,32(sp)
    800033e2:	ec5e                	sd	s7,24(sp)
    800033e4:	e862                	sd	s8,16(sp)
    800033e6:	e466                	sd	s9,8(sp)
    800033e8:	8baa                	mv	s7,a0
    800033ea:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033ec:	0001cb17          	auipc	s6,0x1c
    800033f0:	c5cb0b13          	add	s6,s6,-932 # 8001f048 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033f6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033fa:	6c89                	lui	s9,0x2
    800033fc:	a061                	j	80003484 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033fe:	97ca                	add	a5,a5,s2
    80003400:	8e55                	or	a2,a2,a3
    80003402:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003406:	854a                	mv	a0,s2
    80003408:	00001097          	auipc	ra,0x1
    8000340c:	0d4080e7          	jalr	212(ra) # 800044dc <log_write>
        brelse(bp);
    80003410:	854a                	mv	a0,s2
    80003412:	00000097          	auipc	ra,0x0
    80003416:	e20080e7          	jalr	-480(ra) # 80003232 <brelse>
  bp = bread(dev, bno);
    8000341a:	85a6                	mv	a1,s1
    8000341c:	855e                	mv	a0,s7
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	ce4080e7          	jalr	-796(ra) # 80003102 <bread>
    80003426:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003428:	40000613          	li	a2,1024
    8000342c:	4581                	li	a1,0
    8000342e:	05850513          	add	a0,a0,88
    80003432:	ffffe097          	auipc	ra,0xffffe
    80003436:	902080e7          	jalr	-1790(ra) # 80000d34 <memset>
  log_write(bp);
    8000343a:	854a                	mv	a0,s2
    8000343c:	00001097          	auipc	ra,0x1
    80003440:	0a0080e7          	jalr	160(ra) # 800044dc <log_write>
  brelse(bp);
    80003444:	854a                	mv	a0,s2
    80003446:	00000097          	auipc	ra,0x0
    8000344a:	dec080e7          	jalr	-532(ra) # 80003232 <brelse>
}
    8000344e:	6906                	ld	s2,64(sp)
    80003450:	79e2                	ld	s3,56(sp)
    80003452:	7a42                	ld	s4,48(sp)
    80003454:	7aa2                	ld	s5,40(sp)
    80003456:	7b02                	ld	s6,32(sp)
    80003458:	6be2                	ld	s7,24(sp)
    8000345a:	6c42                	ld	s8,16(sp)
    8000345c:	6ca2                	ld	s9,8(sp)
}
    8000345e:	8526                	mv	a0,s1
    80003460:	60e6                	ld	ra,88(sp)
    80003462:	6446                	ld	s0,80(sp)
    80003464:	64a6                	ld	s1,72(sp)
    80003466:	6125                	add	sp,sp,96
    80003468:	8082                	ret
    brelse(bp);
    8000346a:	854a                	mv	a0,s2
    8000346c:	00000097          	auipc	ra,0x0
    80003470:	dc6080e7          	jalr	-570(ra) # 80003232 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003474:	015c87bb          	addw	a5,s9,s5
    80003478:	00078a9b          	sext.w	s5,a5
    8000347c:	004b2703          	lw	a4,4(s6)
    80003480:	06eaf163          	bgeu	s5,a4,800034e2 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003484:	41fad79b          	sraw	a5,s5,0x1f
    80003488:	0137d79b          	srlw	a5,a5,0x13
    8000348c:	015787bb          	addw	a5,a5,s5
    80003490:	40d7d79b          	sraw	a5,a5,0xd
    80003494:	01cb2583          	lw	a1,28(s6)
    80003498:	9dbd                	addw	a1,a1,a5
    8000349a:	855e                	mv	a0,s7
    8000349c:	00000097          	auipc	ra,0x0
    800034a0:	c66080e7          	jalr	-922(ra) # 80003102 <bread>
    800034a4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034a6:	004b2503          	lw	a0,4(s6)
    800034aa:	000a849b          	sext.w	s1,s5
    800034ae:	8762                	mv	a4,s8
    800034b0:	faa4fde3          	bgeu	s1,a0,8000346a <balloc+0xa8>
      m = 1 << (bi % 8);
    800034b4:	00777693          	and	a3,a4,7
    800034b8:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034bc:	41f7579b          	sraw	a5,a4,0x1f
    800034c0:	01d7d79b          	srlw	a5,a5,0x1d
    800034c4:	9fb9                	addw	a5,a5,a4
    800034c6:	4037d79b          	sraw	a5,a5,0x3
    800034ca:	00f90633          	add	a2,s2,a5
    800034ce:	05864603          	lbu	a2,88(a2)
    800034d2:	00c6f5b3          	and	a1,a3,a2
    800034d6:	d585                	beqz	a1,800033fe <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034d8:	2705                	addw	a4,a4,1
    800034da:	2485                	addw	s1,s1,1
    800034dc:	fd471ae3          	bne	a4,s4,800034b0 <balloc+0xee>
    800034e0:	b769                	j	8000346a <balloc+0xa8>
    800034e2:	6906                	ld	s2,64(sp)
    800034e4:	79e2                	ld	s3,56(sp)
    800034e6:	7a42                	ld	s4,48(sp)
    800034e8:	7aa2                	ld	s5,40(sp)
    800034ea:	7b02                	ld	s6,32(sp)
    800034ec:	6be2                	ld	s7,24(sp)
    800034ee:	6c42                	ld	s8,16(sp)
    800034f0:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800034f2:	00005517          	auipc	a0,0x5
    800034f6:	f4650513          	add	a0,a0,-186 # 80008438 <etext+0x438>
    800034fa:	ffffd097          	auipc	ra,0xffffd
    800034fe:	0b0080e7          	jalr	176(ra) # 800005aa <printf>
  return 0;
    80003502:	4481                	li	s1,0
    80003504:	bfa9                	j	8000345e <balloc+0x9c>

0000000080003506 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003506:	7179                	add	sp,sp,-48
    80003508:	f406                	sd	ra,40(sp)
    8000350a:	f022                	sd	s0,32(sp)
    8000350c:	ec26                	sd	s1,24(sp)
    8000350e:	e84a                	sd	s2,16(sp)
    80003510:	e44e                	sd	s3,8(sp)
    80003512:	1800                	add	s0,sp,48
    80003514:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003516:	47ad                	li	a5,11
    80003518:	02b7e863          	bltu	a5,a1,80003548 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000351c:	02059793          	sll	a5,a1,0x20
    80003520:	01e7d593          	srl	a1,a5,0x1e
    80003524:	00b504b3          	add	s1,a0,a1
    80003528:	0504a903          	lw	s2,80(s1)
    8000352c:	08091263          	bnez	s2,800035b0 <bmap+0xaa>
      addr = balloc(ip->dev);
    80003530:	4108                	lw	a0,0(a0)
    80003532:	00000097          	auipc	ra,0x0
    80003536:	e90080e7          	jalr	-368(ra) # 800033c2 <balloc>
    8000353a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000353e:	06090963          	beqz	s2,800035b0 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003542:	0524a823          	sw	s2,80(s1)
    80003546:	a0ad                	j	800035b0 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003548:	ff45849b          	addw	s1,a1,-12
    8000354c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003550:	0ff00793          	li	a5,255
    80003554:	08e7e863          	bltu	a5,a4,800035e4 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003558:	08052903          	lw	s2,128(a0)
    8000355c:	00091f63          	bnez	s2,8000357a <bmap+0x74>
      addr = balloc(ip->dev);
    80003560:	4108                	lw	a0,0(a0)
    80003562:	00000097          	auipc	ra,0x0
    80003566:	e60080e7          	jalr	-416(ra) # 800033c2 <balloc>
    8000356a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000356e:	04090163          	beqz	s2,800035b0 <bmap+0xaa>
    80003572:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003574:	0929a023          	sw	s2,128(s3)
    80003578:	a011                	j	8000357c <bmap+0x76>
    8000357a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000357c:	85ca                	mv	a1,s2
    8000357e:	0009a503          	lw	a0,0(s3)
    80003582:	00000097          	auipc	ra,0x0
    80003586:	b80080e7          	jalr	-1152(ra) # 80003102 <bread>
    8000358a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000358c:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003590:	02049713          	sll	a4,s1,0x20
    80003594:	01e75593          	srl	a1,a4,0x1e
    80003598:	00b784b3          	add	s1,a5,a1
    8000359c:	0004a903          	lw	s2,0(s1)
    800035a0:	02090063          	beqz	s2,800035c0 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035a4:	8552                	mv	a0,s4
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	c8c080e7          	jalr	-884(ra) # 80003232 <brelse>
    return addr;
    800035ae:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800035b0:	854a                	mv	a0,s2
    800035b2:	70a2                	ld	ra,40(sp)
    800035b4:	7402                	ld	s0,32(sp)
    800035b6:	64e2                	ld	s1,24(sp)
    800035b8:	6942                	ld	s2,16(sp)
    800035ba:	69a2                	ld	s3,8(sp)
    800035bc:	6145                	add	sp,sp,48
    800035be:	8082                	ret
      addr = balloc(ip->dev);
    800035c0:	0009a503          	lw	a0,0(s3)
    800035c4:	00000097          	auipc	ra,0x0
    800035c8:	dfe080e7          	jalr	-514(ra) # 800033c2 <balloc>
    800035cc:	0005091b          	sext.w	s2,a0
      if(addr){
    800035d0:	fc090ae3          	beqz	s2,800035a4 <bmap+0x9e>
        a[bn] = addr;
    800035d4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035d8:	8552                	mv	a0,s4
    800035da:	00001097          	auipc	ra,0x1
    800035de:	f02080e7          	jalr	-254(ra) # 800044dc <log_write>
    800035e2:	b7c9                	j	800035a4 <bmap+0x9e>
    800035e4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800035e6:	00005517          	auipc	a0,0x5
    800035ea:	e6a50513          	add	a0,a0,-406 # 80008450 <etext+0x450>
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	f72080e7          	jalr	-142(ra) # 80000560 <panic>

00000000800035f6 <iget>:
{
    800035f6:	7179                	add	sp,sp,-48
    800035f8:	f406                	sd	ra,40(sp)
    800035fa:	f022                	sd	s0,32(sp)
    800035fc:	ec26                	sd	s1,24(sp)
    800035fe:	e84a                	sd	s2,16(sp)
    80003600:	e44e                	sd	s3,8(sp)
    80003602:	e052                	sd	s4,0(sp)
    80003604:	1800                	add	s0,sp,48
    80003606:	89aa                	mv	s3,a0
    80003608:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000360a:	0001c517          	auipc	a0,0x1c
    8000360e:	a5e50513          	add	a0,a0,-1442 # 8001f068 <itable>
    80003612:	ffffd097          	auipc	ra,0xffffd
    80003616:	626080e7          	jalr	1574(ra) # 80000c38 <acquire>
  empty = 0;
    8000361a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000361c:	0001c497          	auipc	s1,0x1c
    80003620:	a6448493          	add	s1,s1,-1436 # 8001f080 <itable+0x18>
    80003624:	0001d697          	auipc	a3,0x1d
    80003628:	4ec68693          	add	a3,a3,1260 # 80020b10 <log>
    8000362c:	a039                	j	8000363a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000362e:	02090b63          	beqz	s2,80003664 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003632:	08848493          	add	s1,s1,136
    80003636:	02d48a63          	beq	s1,a3,8000366a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000363a:	449c                	lw	a5,8(s1)
    8000363c:	fef059e3          	blez	a5,8000362e <iget+0x38>
    80003640:	4098                	lw	a4,0(s1)
    80003642:	ff3716e3          	bne	a4,s3,8000362e <iget+0x38>
    80003646:	40d8                	lw	a4,4(s1)
    80003648:	ff4713e3          	bne	a4,s4,8000362e <iget+0x38>
      ip->ref++;
    8000364c:	2785                	addw	a5,a5,1
    8000364e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003650:	0001c517          	auipc	a0,0x1c
    80003654:	a1850513          	add	a0,a0,-1512 # 8001f068 <itable>
    80003658:	ffffd097          	auipc	ra,0xffffd
    8000365c:	694080e7          	jalr	1684(ra) # 80000cec <release>
      return ip;
    80003660:	8926                	mv	s2,s1
    80003662:	a03d                	j	80003690 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003664:	f7f9                	bnez	a5,80003632 <iget+0x3c>
      empty = ip;
    80003666:	8926                	mv	s2,s1
    80003668:	b7e9                	j	80003632 <iget+0x3c>
  if(empty == 0)
    8000366a:	02090c63          	beqz	s2,800036a2 <iget+0xac>
  ip->dev = dev;
    8000366e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003672:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003676:	4785                	li	a5,1
    80003678:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000367c:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003680:	0001c517          	auipc	a0,0x1c
    80003684:	9e850513          	add	a0,a0,-1560 # 8001f068 <itable>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	664080e7          	jalr	1636(ra) # 80000cec <release>
}
    80003690:	854a                	mv	a0,s2
    80003692:	70a2                	ld	ra,40(sp)
    80003694:	7402                	ld	s0,32(sp)
    80003696:	64e2                	ld	s1,24(sp)
    80003698:	6942                	ld	s2,16(sp)
    8000369a:	69a2                	ld	s3,8(sp)
    8000369c:	6a02                	ld	s4,0(sp)
    8000369e:	6145                	add	sp,sp,48
    800036a0:	8082                	ret
    panic("iget: no inodes");
    800036a2:	00005517          	auipc	a0,0x5
    800036a6:	dc650513          	add	a0,a0,-570 # 80008468 <etext+0x468>
    800036aa:	ffffd097          	auipc	ra,0xffffd
    800036ae:	eb6080e7          	jalr	-330(ra) # 80000560 <panic>

00000000800036b2 <fsinit>:
fsinit(int dev) {
    800036b2:	7179                	add	sp,sp,-48
    800036b4:	f406                	sd	ra,40(sp)
    800036b6:	f022                	sd	s0,32(sp)
    800036b8:	ec26                	sd	s1,24(sp)
    800036ba:	e84a                	sd	s2,16(sp)
    800036bc:	e44e                	sd	s3,8(sp)
    800036be:	1800                	add	s0,sp,48
    800036c0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036c2:	4585                	li	a1,1
    800036c4:	00000097          	auipc	ra,0x0
    800036c8:	a3e080e7          	jalr	-1474(ra) # 80003102 <bread>
    800036cc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036ce:	0001c997          	auipc	s3,0x1c
    800036d2:	97a98993          	add	s3,s3,-1670 # 8001f048 <sb>
    800036d6:	02000613          	li	a2,32
    800036da:	05850593          	add	a1,a0,88
    800036de:	854e                	mv	a0,s3
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	6b0080e7          	jalr	1712(ra) # 80000d90 <memmove>
  brelse(bp);
    800036e8:	8526                	mv	a0,s1
    800036ea:	00000097          	auipc	ra,0x0
    800036ee:	b48080e7          	jalr	-1208(ra) # 80003232 <brelse>
  if(sb.magic != FSMAGIC)
    800036f2:	0009a703          	lw	a4,0(s3)
    800036f6:	102037b7          	lui	a5,0x10203
    800036fa:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036fe:	02f71263          	bne	a4,a5,80003722 <fsinit+0x70>
  initlog(dev, &sb);
    80003702:	0001c597          	auipc	a1,0x1c
    80003706:	94658593          	add	a1,a1,-1722 # 8001f048 <sb>
    8000370a:	854a                	mv	a0,s2
    8000370c:	00001097          	auipc	ra,0x1
    80003710:	b60080e7          	jalr	-1184(ra) # 8000426c <initlog>
}
    80003714:	70a2                	ld	ra,40(sp)
    80003716:	7402                	ld	s0,32(sp)
    80003718:	64e2                	ld	s1,24(sp)
    8000371a:	6942                	ld	s2,16(sp)
    8000371c:	69a2                	ld	s3,8(sp)
    8000371e:	6145                	add	sp,sp,48
    80003720:	8082                	ret
    panic("invalid file system");
    80003722:	00005517          	auipc	a0,0x5
    80003726:	d5650513          	add	a0,a0,-682 # 80008478 <etext+0x478>
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	e36080e7          	jalr	-458(ra) # 80000560 <panic>

0000000080003732 <iinit>:
{
    80003732:	7179                	add	sp,sp,-48
    80003734:	f406                	sd	ra,40(sp)
    80003736:	f022                	sd	s0,32(sp)
    80003738:	ec26                	sd	s1,24(sp)
    8000373a:	e84a                	sd	s2,16(sp)
    8000373c:	e44e                	sd	s3,8(sp)
    8000373e:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    80003740:	00005597          	auipc	a1,0x5
    80003744:	d5058593          	add	a1,a1,-688 # 80008490 <etext+0x490>
    80003748:	0001c517          	auipc	a0,0x1c
    8000374c:	92050513          	add	a0,a0,-1760 # 8001f068 <itable>
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	458080e7          	jalr	1112(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003758:	0001c497          	auipc	s1,0x1c
    8000375c:	93848493          	add	s1,s1,-1736 # 8001f090 <itable+0x28>
    80003760:	0001d997          	auipc	s3,0x1d
    80003764:	3c098993          	add	s3,s3,960 # 80020b20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003768:	00005917          	auipc	s2,0x5
    8000376c:	d3090913          	add	s2,s2,-720 # 80008498 <etext+0x498>
    80003770:	85ca                	mv	a1,s2
    80003772:	8526                	mv	a0,s1
    80003774:	00001097          	auipc	ra,0x1
    80003778:	e4c080e7          	jalr	-436(ra) # 800045c0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000377c:	08848493          	add	s1,s1,136
    80003780:	ff3498e3          	bne	s1,s3,80003770 <iinit+0x3e>
}
    80003784:	70a2                	ld	ra,40(sp)
    80003786:	7402                	ld	s0,32(sp)
    80003788:	64e2                	ld	s1,24(sp)
    8000378a:	6942                	ld	s2,16(sp)
    8000378c:	69a2                	ld	s3,8(sp)
    8000378e:	6145                	add	sp,sp,48
    80003790:	8082                	ret

0000000080003792 <ialloc>:
{
    80003792:	7139                	add	sp,sp,-64
    80003794:	fc06                	sd	ra,56(sp)
    80003796:	f822                	sd	s0,48(sp)
    80003798:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000379a:	0001c717          	auipc	a4,0x1c
    8000379e:	8ba72703          	lw	a4,-1862(a4) # 8001f054 <sb+0xc>
    800037a2:	4785                	li	a5,1
    800037a4:	06e7f463          	bgeu	a5,a4,8000380c <ialloc+0x7a>
    800037a8:	f426                	sd	s1,40(sp)
    800037aa:	f04a                	sd	s2,32(sp)
    800037ac:	ec4e                	sd	s3,24(sp)
    800037ae:	e852                	sd	s4,16(sp)
    800037b0:	e456                	sd	s5,8(sp)
    800037b2:	e05a                	sd	s6,0(sp)
    800037b4:	8aaa                	mv	s5,a0
    800037b6:	8b2e                	mv	s6,a1
    800037b8:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037ba:	0001ca17          	auipc	s4,0x1c
    800037be:	88ea0a13          	add	s4,s4,-1906 # 8001f048 <sb>
    800037c2:	00495593          	srl	a1,s2,0x4
    800037c6:	018a2783          	lw	a5,24(s4)
    800037ca:	9dbd                	addw	a1,a1,a5
    800037cc:	8556                	mv	a0,s5
    800037ce:	00000097          	auipc	ra,0x0
    800037d2:	934080e7          	jalr	-1740(ra) # 80003102 <bread>
    800037d6:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037d8:	05850993          	add	s3,a0,88
    800037dc:	00f97793          	and	a5,s2,15
    800037e0:	079a                	sll	a5,a5,0x6
    800037e2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037e4:	00099783          	lh	a5,0(s3)
    800037e8:	cf9d                	beqz	a5,80003826 <ialloc+0x94>
    brelse(bp);
    800037ea:	00000097          	auipc	ra,0x0
    800037ee:	a48080e7          	jalr	-1464(ra) # 80003232 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037f2:	0905                	add	s2,s2,1
    800037f4:	00ca2703          	lw	a4,12(s4)
    800037f8:	0009079b          	sext.w	a5,s2
    800037fc:	fce7e3e3          	bltu	a5,a4,800037c2 <ialloc+0x30>
    80003800:	74a2                	ld	s1,40(sp)
    80003802:	7902                	ld	s2,32(sp)
    80003804:	69e2                	ld	s3,24(sp)
    80003806:	6a42                	ld	s4,16(sp)
    80003808:	6aa2                	ld	s5,8(sp)
    8000380a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000380c:	00005517          	auipc	a0,0x5
    80003810:	c9450513          	add	a0,a0,-876 # 800084a0 <etext+0x4a0>
    80003814:	ffffd097          	auipc	ra,0xffffd
    80003818:	d96080e7          	jalr	-618(ra) # 800005aa <printf>
  return 0;
    8000381c:	4501                	li	a0,0
}
    8000381e:	70e2                	ld	ra,56(sp)
    80003820:	7442                	ld	s0,48(sp)
    80003822:	6121                	add	sp,sp,64
    80003824:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003826:	04000613          	li	a2,64
    8000382a:	4581                	li	a1,0
    8000382c:	854e                	mv	a0,s3
    8000382e:	ffffd097          	auipc	ra,0xffffd
    80003832:	506080e7          	jalr	1286(ra) # 80000d34 <memset>
      dip->type = type;
    80003836:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000383a:	8526                	mv	a0,s1
    8000383c:	00001097          	auipc	ra,0x1
    80003840:	ca0080e7          	jalr	-864(ra) # 800044dc <log_write>
      brelse(bp);
    80003844:	8526                	mv	a0,s1
    80003846:	00000097          	auipc	ra,0x0
    8000384a:	9ec080e7          	jalr	-1556(ra) # 80003232 <brelse>
      return iget(dev, inum);
    8000384e:	0009059b          	sext.w	a1,s2
    80003852:	8556                	mv	a0,s5
    80003854:	00000097          	auipc	ra,0x0
    80003858:	da2080e7          	jalr	-606(ra) # 800035f6 <iget>
    8000385c:	74a2                	ld	s1,40(sp)
    8000385e:	7902                	ld	s2,32(sp)
    80003860:	69e2                	ld	s3,24(sp)
    80003862:	6a42                	ld	s4,16(sp)
    80003864:	6aa2                	ld	s5,8(sp)
    80003866:	6b02                	ld	s6,0(sp)
    80003868:	bf5d                	j	8000381e <ialloc+0x8c>

000000008000386a <iupdate>:
{
    8000386a:	1101                	add	sp,sp,-32
    8000386c:	ec06                	sd	ra,24(sp)
    8000386e:	e822                	sd	s0,16(sp)
    80003870:	e426                	sd	s1,8(sp)
    80003872:	e04a                	sd	s2,0(sp)
    80003874:	1000                	add	s0,sp,32
    80003876:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003878:	415c                	lw	a5,4(a0)
    8000387a:	0047d79b          	srlw	a5,a5,0x4
    8000387e:	0001b597          	auipc	a1,0x1b
    80003882:	7e25a583          	lw	a1,2018(a1) # 8001f060 <sb+0x18>
    80003886:	9dbd                	addw	a1,a1,a5
    80003888:	4108                	lw	a0,0(a0)
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	878080e7          	jalr	-1928(ra) # 80003102 <bread>
    80003892:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003894:	05850793          	add	a5,a0,88
    80003898:	40d8                	lw	a4,4(s1)
    8000389a:	8b3d                	and	a4,a4,15
    8000389c:	071a                	sll	a4,a4,0x6
    8000389e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800038a0:	04449703          	lh	a4,68(s1)
    800038a4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800038a8:	04649703          	lh	a4,70(s1)
    800038ac:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800038b0:	04849703          	lh	a4,72(s1)
    800038b4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800038b8:	04a49703          	lh	a4,74(s1)
    800038bc:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800038c0:	44f8                	lw	a4,76(s1)
    800038c2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038c4:	03400613          	li	a2,52
    800038c8:	05048593          	add	a1,s1,80
    800038cc:	00c78513          	add	a0,a5,12
    800038d0:	ffffd097          	auipc	ra,0xffffd
    800038d4:	4c0080e7          	jalr	1216(ra) # 80000d90 <memmove>
  log_write(bp);
    800038d8:	854a                	mv	a0,s2
    800038da:	00001097          	auipc	ra,0x1
    800038de:	c02080e7          	jalr	-1022(ra) # 800044dc <log_write>
  brelse(bp);
    800038e2:	854a                	mv	a0,s2
    800038e4:	00000097          	auipc	ra,0x0
    800038e8:	94e080e7          	jalr	-1714(ra) # 80003232 <brelse>
}
    800038ec:	60e2                	ld	ra,24(sp)
    800038ee:	6442                	ld	s0,16(sp)
    800038f0:	64a2                	ld	s1,8(sp)
    800038f2:	6902                	ld	s2,0(sp)
    800038f4:	6105                	add	sp,sp,32
    800038f6:	8082                	ret

00000000800038f8 <idup>:
{
    800038f8:	1101                	add	sp,sp,-32
    800038fa:	ec06                	sd	ra,24(sp)
    800038fc:	e822                	sd	s0,16(sp)
    800038fe:	e426                	sd	s1,8(sp)
    80003900:	1000                	add	s0,sp,32
    80003902:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003904:	0001b517          	auipc	a0,0x1b
    80003908:	76450513          	add	a0,a0,1892 # 8001f068 <itable>
    8000390c:	ffffd097          	auipc	ra,0xffffd
    80003910:	32c080e7          	jalr	812(ra) # 80000c38 <acquire>
  ip->ref++;
    80003914:	449c                	lw	a5,8(s1)
    80003916:	2785                	addw	a5,a5,1
    80003918:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000391a:	0001b517          	auipc	a0,0x1b
    8000391e:	74e50513          	add	a0,a0,1870 # 8001f068 <itable>
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	3ca080e7          	jalr	970(ra) # 80000cec <release>
}
    8000392a:	8526                	mv	a0,s1
    8000392c:	60e2                	ld	ra,24(sp)
    8000392e:	6442                	ld	s0,16(sp)
    80003930:	64a2                	ld	s1,8(sp)
    80003932:	6105                	add	sp,sp,32
    80003934:	8082                	ret

0000000080003936 <ilock>:
{
    80003936:	1101                	add	sp,sp,-32
    80003938:	ec06                	sd	ra,24(sp)
    8000393a:	e822                	sd	s0,16(sp)
    8000393c:	e426                	sd	s1,8(sp)
    8000393e:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003940:	c10d                	beqz	a0,80003962 <ilock+0x2c>
    80003942:	84aa                	mv	s1,a0
    80003944:	451c                	lw	a5,8(a0)
    80003946:	00f05e63          	blez	a5,80003962 <ilock+0x2c>
  acquiresleep(&ip->lock);
    8000394a:	0541                	add	a0,a0,16
    8000394c:	00001097          	auipc	ra,0x1
    80003950:	cae080e7          	jalr	-850(ra) # 800045fa <acquiresleep>
  if(ip->valid == 0){
    80003954:	40bc                	lw	a5,64(s1)
    80003956:	cf99                	beqz	a5,80003974 <ilock+0x3e>
}
    80003958:	60e2                	ld	ra,24(sp)
    8000395a:	6442                	ld	s0,16(sp)
    8000395c:	64a2                	ld	s1,8(sp)
    8000395e:	6105                	add	sp,sp,32
    80003960:	8082                	ret
    80003962:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003964:	00005517          	auipc	a0,0x5
    80003968:	b5450513          	add	a0,a0,-1196 # 800084b8 <etext+0x4b8>
    8000396c:	ffffd097          	auipc	ra,0xffffd
    80003970:	bf4080e7          	jalr	-1036(ra) # 80000560 <panic>
    80003974:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003976:	40dc                	lw	a5,4(s1)
    80003978:	0047d79b          	srlw	a5,a5,0x4
    8000397c:	0001b597          	auipc	a1,0x1b
    80003980:	6e45a583          	lw	a1,1764(a1) # 8001f060 <sb+0x18>
    80003984:	9dbd                	addw	a1,a1,a5
    80003986:	4088                	lw	a0,0(s1)
    80003988:	fffff097          	auipc	ra,0xfffff
    8000398c:	77a080e7          	jalr	1914(ra) # 80003102 <bread>
    80003990:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003992:	05850593          	add	a1,a0,88
    80003996:	40dc                	lw	a5,4(s1)
    80003998:	8bbd                	and	a5,a5,15
    8000399a:	079a                	sll	a5,a5,0x6
    8000399c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000399e:	00059783          	lh	a5,0(a1)
    800039a2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039a6:	00259783          	lh	a5,2(a1)
    800039aa:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039ae:	00459783          	lh	a5,4(a1)
    800039b2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039b6:	00659783          	lh	a5,6(a1)
    800039ba:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039be:	459c                	lw	a5,8(a1)
    800039c0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039c2:	03400613          	li	a2,52
    800039c6:	05b1                	add	a1,a1,12
    800039c8:	05048513          	add	a0,s1,80
    800039cc:	ffffd097          	auipc	ra,0xffffd
    800039d0:	3c4080e7          	jalr	964(ra) # 80000d90 <memmove>
    brelse(bp);
    800039d4:	854a                	mv	a0,s2
    800039d6:	00000097          	auipc	ra,0x0
    800039da:	85c080e7          	jalr	-1956(ra) # 80003232 <brelse>
    ip->valid = 1;
    800039de:	4785                	li	a5,1
    800039e0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039e2:	04449783          	lh	a5,68(s1)
    800039e6:	c399                	beqz	a5,800039ec <ilock+0xb6>
    800039e8:	6902                	ld	s2,0(sp)
    800039ea:	b7bd                	j	80003958 <ilock+0x22>
      panic("ilock: no type");
    800039ec:	00005517          	auipc	a0,0x5
    800039f0:	ad450513          	add	a0,a0,-1324 # 800084c0 <etext+0x4c0>
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	b6c080e7          	jalr	-1172(ra) # 80000560 <panic>

00000000800039fc <iunlock>:
{
    800039fc:	1101                	add	sp,sp,-32
    800039fe:	ec06                	sd	ra,24(sp)
    80003a00:	e822                	sd	s0,16(sp)
    80003a02:	e426                	sd	s1,8(sp)
    80003a04:	e04a                	sd	s2,0(sp)
    80003a06:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a08:	c905                	beqz	a0,80003a38 <iunlock+0x3c>
    80003a0a:	84aa                	mv	s1,a0
    80003a0c:	01050913          	add	s2,a0,16
    80003a10:	854a                	mv	a0,s2
    80003a12:	00001097          	auipc	ra,0x1
    80003a16:	c82080e7          	jalr	-894(ra) # 80004694 <holdingsleep>
    80003a1a:	cd19                	beqz	a0,80003a38 <iunlock+0x3c>
    80003a1c:	449c                	lw	a5,8(s1)
    80003a1e:	00f05d63          	blez	a5,80003a38 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a22:	854a                	mv	a0,s2
    80003a24:	00001097          	auipc	ra,0x1
    80003a28:	c2c080e7          	jalr	-980(ra) # 80004650 <releasesleep>
}
    80003a2c:	60e2                	ld	ra,24(sp)
    80003a2e:	6442                	ld	s0,16(sp)
    80003a30:	64a2                	ld	s1,8(sp)
    80003a32:	6902                	ld	s2,0(sp)
    80003a34:	6105                	add	sp,sp,32
    80003a36:	8082                	ret
    panic("iunlock");
    80003a38:	00005517          	auipc	a0,0x5
    80003a3c:	a9850513          	add	a0,a0,-1384 # 800084d0 <etext+0x4d0>
    80003a40:	ffffd097          	auipc	ra,0xffffd
    80003a44:	b20080e7          	jalr	-1248(ra) # 80000560 <panic>

0000000080003a48 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a48:	7179                	add	sp,sp,-48
    80003a4a:	f406                	sd	ra,40(sp)
    80003a4c:	f022                	sd	s0,32(sp)
    80003a4e:	ec26                	sd	s1,24(sp)
    80003a50:	e84a                	sd	s2,16(sp)
    80003a52:	e44e                	sd	s3,8(sp)
    80003a54:	1800                	add	s0,sp,48
    80003a56:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a58:	05050493          	add	s1,a0,80
    80003a5c:	08050913          	add	s2,a0,128
    80003a60:	a021                	j	80003a68 <itrunc+0x20>
    80003a62:	0491                	add	s1,s1,4
    80003a64:	01248d63          	beq	s1,s2,80003a7e <itrunc+0x36>
    if(ip->addrs[i]){
    80003a68:	408c                	lw	a1,0(s1)
    80003a6a:	dde5                	beqz	a1,80003a62 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003a6c:	0009a503          	lw	a0,0(s3)
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	8d6080e7          	jalr	-1834(ra) # 80003346 <bfree>
      ip->addrs[i] = 0;
    80003a78:	0004a023          	sw	zero,0(s1)
    80003a7c:	b7dd                	j	80003a62 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a7e:	0809a583          	lw	a1,128(s3)
    80003a82:	ed99                	bnez	a1,80003aa0 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a84:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a88:	854e                	mv	a0,s3
    80003a8a:	00000097          	auipc	ra,0x0
    80003a8e:	de0080e7          	jalr	-544(ra) # 8000386a <iupdate>
}
    80003a92:	70a2                	ld	ra,40(sp)
    80003a94:	7402                	ld	s0,32(sp)
    80003a96:	64e2                	ld	s1,24(sp)
    80003a98:	6942                	ld	s2,16(sp)
    80003a9a:	69a2                	ld	s3,8(sp)
    80003a9c:	6145                	add	sp,sp,48
    80003a9e:	8082                	ret
    80003aa0:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003aa2:	0009a503          	lw	a0,0(s3)
    80003aa6:	fffff097          	auipc	ra,0xfffff
    80003aaa:	65c080e7          	jalr	1628(ra) # 80003102 <bread>
    80003aae:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ab0:	05850493          	add	s1,a0,88
    80003ab4:	45850913          	add	s2,a0,1112
    80003ab8:	a021                	j	80003ac0 <itrunc+0x78>
    80003aba:	0491                	add	s1,s1,4
    80003abc:	01248b63          	beq	s1,s2,80003ad2 <itrunc+0x8a>
      if(a[j])
    80003ac0:	408c                	lw	a1,0(s1)
    80003ac2:	dde5                	beqz	a1,80003aba <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003ac4:	0009a503          	lw	a0,0(s3)
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	87e080e7          	jalr	-1922(ra) # 80003346 <bfree>
    80003ad0:	b7ed                	j	80003aba <itrunc+0x72>
    brelse(bp);
    80003ad2:	8552                	mv	a0,s4
    80003ad4:	fffff097          	auipc	ra,0xfffff
    80003ad8:	75e080e7          	jalr	1886(ra) # 80003232 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003adc:	0809a583          	lw	a1,128(s3)
    80003ae0:	0009a503          	lw	a0,0(s3)
    80003ae4:	00000097          	auipc	ra,0x0
    80003ae8:	862080e7          	jalr	-1950(ra) # 80003346 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003aec:	0809a023          	sw	zero,128(s3)
    80003af0:	6a02                	ld	s4,0(sp)
    80003af2:	bf49                	j	80003a84 <itrunc+0x3c>

0000000080003af4 <iput>:
{
    80003af4:	1101                	add	sp,sp,-32
    80003af6:	ec06                	sd	ra,24(sp)
    80003af8:	e822                	sd	s0,16(sp)
    80003afa:	e426                	sd	s1,8(sp)
    80003afc:	1000                	add	s0,sp,32
    80003afe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b00:	0001b517          	auipc	a0,0x1b
    80003b04:	56850513          	add	a0,a0,1384 # 8001f068 <itable>
    80003b08:	ffffd097          	auipc	ra,0xffffd
    80003b0c:	130080e7          	jalr	304(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b10:	4498                	lw	a4,8(s1)
    80003b12:	4785                	li	a5,1
    80003b14:	02f70263          	beq	a4,a5,80003b38 <iput+0x44>
  ip->ref--;
    80003b18:	449c                	lw	a5,8(s1)
    80003b1a:	37fd                	addw	a5,a5,-1
    80003b1c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b1e:	0001b517          	auipc	a0,0x1b
    80003b22:	54a50513          	add	a0,a0,1354 # 8001f068 <itable>
    80003b26:	ffffd097          	auipc	ra,0xffffd
    80003b2a:	1c6080e7          	jalr	454(ra) # 80000cec <release>
}
    80003b2e:	60e2                	ld	ra,24(sp)
    80003b30:	6442                	ld	s0,16(sp)
    80003b32:	64a2                	ld	s1,8(sp)
    80003b34:	6105                	add	sp,sp,32
    80003b36:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b38:	40bc                	lw	a5,64(s1)
    80003b3a:	dff9                	beqz	a5,80003b18 <iput+0x24>
    80003b3c:	04a49783          	lh	a5,74(s1)
    80003b40:	ffe1                	bnez	a5,80003b18 <iput+0x24>
    80003b42:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003b44:	01048913          	add	s2,s1,16
    80003b48:	854a                	mv	a0,s2
    80003b4a:	00001097          	auipc	ra,0x1
    80003b4e:	ab0080e7          	jalr	-1360(ra) # 800045fa <acquiresleep>
    release(&itable.lock);
    80003b52:	0001b517          	auipc	a0,0x1b
    80003b56:	51650513          	add	a0,a0,1302 # 8001f068 <itable>
    80003b5a:	ffffd097          	auipc	ra,0xffffd
    80003b5e:	192080e7          	jalr	402(ra) # 80000cec <release>
    itrunc(ip);
    80003b62:	8526                	mv	a0,s1
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	ee4080e7          	jalr	-284(ra) # 80003a48 <itrunc>
    ip->type = 0;
    80003b6c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b70:	8526                	mv	a0,s1
    80003b72:	00000097          	auipc	ra,0x0
    80003b76:	cf8080e7          	jalr	-776(ra) # 8000386a <iupdate>
    ip->valid = 0;
    80003b7a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b7e:	854a                	mv	a0,s2
    80003b80:	00001097          	auipc	ra,0x1
    80003b84:	ad0080e7          	jalr	-1328(ra) # 80004650 <releasesleep>
    acquire(&itable.lock);
    80003b88:	0001b517          	auipc	a0,0x1b
    80003b8c:	4e050513          	add	a0,a0,1248 # 8001f068 <itable>
    80003b90:	ffffd097          	auipc	ra,0xffffd
    80003b94:	0a8080e7          	jalr	168(ra) # 80000c38 <acquire>
    80003b98:	6902                	ld	s2,0(sp)
    80003b9a:	bfbd                	j	80003b18 <iput+0x24>

0000000080003b9c <iunlockput>:
{
    80003b9c:	1101                	add	sp,sp,-32
    80003b9e:	ec06                	sd	ra,24(sp)
    80003ba0:	e822                	sd	s0,16(sp)
    80003ba2:	e426                	sd	s1,8(sp)
    80003ba4:	1000                	add	s0,sp,32
    80003ba6:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	e54080e7          	jalr	-428(ra) # 800039fc <iunlock>
  iput(ip);
    80003bb0:	8526                	mv	a0,s1
    80003bb2:	00000097          	auipc	ra,0x0
    80003bb6:	f42080e7          	jalr	-190(ra) # 80003af4 <iput>
}
    80003bba:	60e2                	ld	ra,24(sp)
    80003bbc:	6442                	ld	s0,16(sp)
    80003bbe:	64a2                	ld	s1,8(sp)
    80003bc0:	6105                	add	sp,sp,32
    80003bc2:	8082                	ret

0000000080003bc4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bc4:	1141                	add	sp,sp,-16
    80003bc6:	e422                	sd	s0,8(sp)
    80003bc8:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003bca:	411c                	lw	a5,0(a0)
    80003bcc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bce:	415c                	lw	a5,4(a0)
    80003bd0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bd2:	04451783          	lh	a5,68(a0)
    80003bd6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bda:	04a51783          	lh	a5,74(a0)
    80003bde:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003be2:	04c56783          	lwu	a5,76(a0)
    80003be6:	e99c                	sd	a5,16(a1)
}
    80003be8:	6422                	ld	s0,8(sp)
    80003bea:	0141                	add	sp,sp,16
    80003bec:	8082                	ret

0000000080003bee <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bee:	457c                	lw	a5,76(a0)
    80003bf0:	10d7e563          	bltu	a5,a3,80003cfa <readi+0x10c>
{
    80003bf4:	7159                	add	sp,sp,-112
    80003bf6:	f486                	sd	ra,104(sp)
    80003bf8:	f0a2                	sd	s0,96(sp)
    80003bfa:	eca6                	sd	s1,88(sp)
    80003bfc:	e0d2                	sd	s4,64(sp)
    80003bfe:	fc56                	sd	s5,56(sp)
    80003c00:	f85a                	sd	s6,48(sp)
    80003c02:	f45e                	sd	s7,40(sp)
    80003c04:	1880                	add	s0,sp,112
    80003c06:	8b2a                	mv	s6,a0
    80003c08:	8bae                	mv	s7,a1
    80003c0a:	8a32                	mv	s4,a2
    80003c0c:	84b6                	mv	s1,a3
    80003c0e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c10:	9f35                	addw	a4,a4,a3
    return 0;
    80003c12:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c14:	0cd76a63          	bltu	a4,a3,80003ce8 <readi+0xfa>
    80003c18:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003c1a:	00e7f463          	bgeu	a5,a4,80003c22 <readi+0x34>
    n = ip->size - off;
    80003c1e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c22:	0a0a8963          	beqz	s5,80003cd4 <readi+0xe6>
    80003c26:	e8ca                	sd	s2,80(sp)
    80003c28:	f062                	sd	s8,32(sp)
    80003c2a:	ec66                	sd	s9,24(sp)
    80003c2c:	e86a                	sd	s10,16(sp)
    80003c2e:	e46e                	sd	s11,8(sp)
    80003c30:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c32:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c36:	5c7d                	li	s8,-1
    80003c38:	a82d                	j	80003c72 <readi+0x84>
    80003c3a:	020d1d93          	sll	s11,s10,0x20
    80003c3e:	020ddd93          	srl	s11,s11,0x20
    80003c42:	05890613          	add	a2,s2,88
    80003c46:	86ee                	mv	a3,s11
    80003c48:	963a                	add	a2,a2,a4
    80003c4a:	85d2                	mv	a1,s4
    80003c4c:	855e                	mv	a0,s7
    80003c4e:	fffff097          	auipc	ra,0xfffff
    80003c52:	8fa080e7          	jalr	-1798(ra) # 80002548 <either_copyout>
    80003c56:	05850d63          	beq	a0,s8,80003cb0 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c5a:	854a                	mv	a0,s2
    80003c5c:	fffff097          	auipc	ra,0xfffff
    80003c60:	5d6080e7          	jalr	1494(ra) # 80003232 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c64:	013d09bb          	addw	s3,s10,s3
    80003c68:	009d04bb          	addw	s1,s10,s1
    80003c6c:	9a6e                	add	s4,s4,s11
    80003c6e:	0559fd63          	bgeu	s3,s5,80003cc8 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003c72:	00a4d59b          	srlw	a1,s1,0xa
    80003c76:	855a                	mv	a0,s6
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	88e080e7          	jalr	-1906(ra) # 80003506 <bmap>
    80003c80:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c84:	c9b1                	beqz	a1,80003cd8 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003c86:	000b2503          	lw	a0,0(s6)
    80003c8a:	fffff097          	auipc	ra,0xfffff
    80003c8e:	478080e7          	jalr	1144(ra) # 80003102 <bread>
    80003c92:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c94:	3ff4f713          	and	a4,s1,1023
    80003c98:	40ec87bb          	subw	a5,s9,a4
    80003c9c:	413a86bb          	subw	a3,s5,s3
    80003ca0:	8d3e                	mv	s10,a5
    80003ca2:	2781                	sext.w	a5,a5
    80003ca4:	0006861b          	sext.w	a2,a3
    80003ca8:	f8f679e3          	bgeu	a2,a5,80003c3a <readi+0x4c>
    80003cac:	8d36                	mv	s10,a3
    80003cae:	b771                	j	80003c3a <readi+0x4c>
      brelse(bp);
    80003cb0:	854a                	mv	a0,s2
    80003cb2:	fffff097          	auipc	ra,0xfffff
    80003cb6:	580080e7          	jalr	1408(ra) # 80003232 <brelse>
      tot = -1;
    80003cba:	59fd                	li	s3,-1
      break;
    80003cbc:	6946                	ld	s2,80(sp)
    80003cbe:	7c02                	ld	s8,32(sp)
    80003cc0:	6ce2                	ld	s9,24(sp)
    80003cc2:	6d42                	ld	s10,16(sp)
    80003cc4:	6da2                	ld	s11,8(sp)
    80003cc6:	a831                	j	80003ce2 <readi+0xf4>
    80003cc8:	6946                	ld	s2,80(sp)
    80003cca:	7c02                	ld	s8,32(sp)
    80003ccc:	6ce2                	ld	s9,24(sp)
    80003cce:	6d42                	ld	s10,16(sp)
    80003cd0:	6da2                	ld	s11,8(sp)
    80003cd2:	a801                	j	80003ce2 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cd4:	89d6                	mv	s3,s5
    80003cd6:	a031                	j	80003ce2 <readi+0xf4>
    80003cd8:	6946                	ld	s2,80(sp)
    80003cda:	7c02                	ld	s8,32(sp)
    80003cdc:	6ce2                	ld	s9,24(sp)
    80003cde:	6d42                	ld	s10,16(sp)
    80003ce0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003ce2:	0009851b          	sext.w	a0,s3
    80003ce6:	69a6                	ld	s3,72(sp)
}
    80003ce8:	70a6                	ld	ra,104(sp)
    80003cea:	7406                	ld	s0,96(sp)
    80003cec:	64e6                	ld	s1,88(sp)
    80003cee:	6a06                	ld	s4,64(sp)
    80003cf0:	7ae2                	ld	s5,56(sp)
    80003cf2:	7b42                	ld	s6,48(sp)
    80003cf4:	7ba2                	ld	s7,40(sp)
    80003cf6:	6165                	add	sp,sp,112
    80003cf8:	8082                	ret
    return 0;
    80003cfa:	4501                	li	a0,0
}
    80003cfc:	8082                	ret

0000000080003cfe <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cfe:	457c                	lw	a5,76(a0)
    80003d00:	10d7ee63          	bltu	a5,a3,80003e1c <writei+0x11e>
{
    80003d04:	7159                	add	sp,sp,-112
    80003d06:	f486                	sd	ra,104(sp)
    80003d08:	f0a2                	sd	s0,96(sp)
    80003d0a:	e8ca                	sd	s2,80(sp)
    80003d0c:	e0d2                	sd	s4,64(sp)
    80003d0e:	fc56                	sd	s5,56(sp)
    80003d10:	f85a                	sd	s6,48(sp)
    80003d12:	f45e                	sd	s7,40(sp)
    80003d14:	1880                	add	s0,sp,112
    80003d16:	8aaa                	mv	s5,a0
    80003d18:	8bae                	mv	s7,a1
    80003d1a:	8a32                	mv	s4,a2
    80003d1c:	8936                	mv	s2,a3
    80003d1e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d20:	00e687bb          	addw	a5,a3,a4
    80003d24:	0ed7ee63          	bltu	a5,a3,80003e20 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d28:	00043737          	lui	a4,0x43
    80003d2c:	0ef76c63          	bltu	a4,a5,80003e24 <writei+0x126>
    80003d30:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d32:	0c0b0d63          	beqz	s6,80003e0c <writei+0x10e>
    80003d36:	eca6                	sd	s1,88(sp)
    80003d38:	f062                	sd	s8,32(sp)
    80003d3a:	ec66                	sd	s9,24(sp)
    80003d3c:	e86a                	sd	s10,16(sp)
    80003d3e:	e46e                	sd	s11,8(sp)
    80003d40:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d42:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d46:	5c7d                	li	s8,-1
    80003d48:	a091                	j	80003d8c <writei+0x8e>
    80003d4a:	020d1d93          	sll	s11,s10,0x20
    80003d4e:	020ddd93          	srl	s11,s11,0x20
    80003d52:	05848513          	add	a0,s1,88
    80003d56:	86ee                	mv	a3,s11
    80003d58:	8652                	mv	a2,s4
    80003d5a:	85de                	mv	a1,s7
    80003d5c:	953a                	add	a0,a0,a4
    80003d5e:	fffff097          	auipc	ra,0xfffff
    80003d62:	840080e7          	jalr	-1984(ra) # 8000259e <either_copyin>
    80003d66:	07850263          	beq	a0,s8,80003dca <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	770080e7          	jalr	1904(ra) # 800044dc <log_write>
    brelse(bp);
    80003d74:	8526                	mv	a0,s1
    80003d76:	fffff097          	auipc	ra,0xfffff
    80003d7a:	4bc080e7          	jalr	1212(ra) # 80003232 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d7e:	013d09bb          	addw	s3,s10,s3
    80003d82:	012d093b          	addw	s2,s10,s2
    80003d86:	9a6e                	add	s4,s4,s11
    80003d88:	0569f663          	bgeu	s3,s6,80003dd4 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d8c:	00a9559b          	srlw	a1,s2,0xa
    80003d90:	8556                	mv	a0,s5
    80003d92:	fffff097          	auipc	ra,0xfffff
    80003d96:	774080e7          	jalr	1908(ra) # 80003506 <bmap>
    80003d9a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d9e:	c99d                	beqz	a1,80003dd4 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003da0:	000aa503          	lw	a0,0(s5)
    80003da4:	fffff097          	auipc	ra,0xfffff
    80003da8:	35e080e7          	jalr	862(ra) # 80003102 <bread>
    80003dac:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dae:	3ff97713          	and	a4,s2,1023
    80003db2:	40ec87bb          	subw	a5,s9,a4
    80003db6:	413b06bb          	subw	a3,s6,s3
    80003dba:	8d3e                	mv	s10,a5
    80003dbc:	2781                	sext.w	a5,a5
    80003dbe:	0006861b          	sext.w	a2,a3
    80003dc2:	f8f674e3          	bgeu	a2,a5,80003d4a <writei+0x4c>
    80003dc6:	8d36                	mv	s10,a3
    80003dc8:	b749                	j	80003d4a <writei+0x4c>
      brelse(bp);
    80003dca:	8526                	mv	a0,s1
    80003dcc:	fffff097          	auipc	ra,0xfffff
    80003dd0:	466080e7          	jalr	1126(ra) # 80003232 <brelse>
  }

  if(off > ip->size)
    80003dd4:	04caa783          	lw	a5,76(s5)
    80003dd8:	0327fc63          	bgeu	a5,s2,80003e10 <writei+0x112>
    ip->size = off;
    80003ddc:	052aa623          	sw	s2,76(s5)
    80003de0:	64e6                	ld	s1,88(sp)
    80003de2:	7c02                	ld	s8,32(sp)
    80003de4:	6ce2                	ld	s9,24(sp)
    80003de6:	6d42                	ld	s10,16(sp)
    80003de8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003dea:	8556                	mv	a0,s5
    80003dec:	00000097          	auipc	ra,0x0
    80003df0:	a7e080e7          	jalr	-1410(ra) # 8000386a <iupdate>

  return tot;
    80003df4:	0009851b          	sext.w	a0,s3
    80003df8:	69a6                	ld	s3,72(sp)
}
    80003dfa:	70a6                	ld	ra,104(sp)
    80003dfc:	7406                	ld	s0,96(sp)
    80003dfe:	6946                	ld	s2,80(sp)
    80003e00:	6a06                	ld	s4,64(sp)
    80003e02:	7ae2                	ld	s5,56(sp)
    80003e04:	7b42                	ld	s6,48(sp)
    80003e06:	7ba2                	ld	s7,40(sp)
    80003e08:	6165                	add	sp,sp,112
    80003e0a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e0c:	89da                	mv	s3,s6
    80003e0e:	bff1                	j	80003dea <writei+0xec>
    80003e10:	64e6                	ld	s1,88(sp)
    80003e12:	7c02                	ld	s8,32(sp)
    80003e14:	6ce2                	ld	s9,24(sp)
    80003e16:	6d42                	ld	s10,16(sp)
    80003e18:	6da2                	ld	s11,8(sp)
    80003e1a:	bfc1                	j	80003dea <writei+0xec>
    return -1;
    80003e1c:	557d                	li	a0,-1
}
    80003e1e:	8082                	ret
    return -1;
    80003e20:	557d                	li	a0,-1
    80003e22:	bfe1                	j	80003dfa <writei+0xfc>
    return -1;
    80003e24:	557d                	li	a0,-1
    80003e26:	bfd1                	j	80003dfa <writei+0xfc>

0000000080003e28 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e28:	1141                	add	sp,sp,-16
    80003e2a:	e406                	sd	ra,8(sp)
    80003e2c:	e022                	sd	s0,0(sp)
    80003e2e:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e30:	4639                	li	a2,14
    80003e32:	ffffd097          	auipc	ra,0xffffd
    80003e36:	fd2080e7          	jalr	-46(ra) # 80000e04 <strncmp>
}
    80003e3a:	60a2                	ld	ra,8(sp)
    80003e3c:	6402                	ld	s0,0(sp)
    80003e3e:	0141                	add	sp,sp,16
    80003e40:	8082                	ret

0000000080003e42 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e42:	7139                	add	sp,sp,-64
    80003e44:	fc06                	sd	ra,56(sp)
    80003e46:	f822                	sd	s0,48(sp)
    80003e48:	f426                	sd	s1,40(sp)
    80003e4a:	f04a                	sd	s2,32(sp)
    80003e4c:	ec4e                	sd	s3,24(sp)
    80003e4e:	e852                	sd	s4,16(sp)
    80003e50:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e52:	04451703          	lh	a4,68(a0)
    80003e56:	4785                	li	a5,1
    80003e58:	00f71a63          	bne	a4,a5,80003e6c <dirlookup+0x2a>
    80003e5c:	892a                	mv	s2,a0
    80003e5e:	89ae                	mv	s3,a1
    80003e60:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e62:	457c                	lw	a5,76(a0)
    80003e64:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e66:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e68:	e79d                	bnez	a5,80003e96 <dirlookup+0x54>
    80003e6a:	a8a5                	j	80003ee2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e6c:	00004517          	auipc	a0,0x4
    80003e70:	66c50513          	add	a0,a0,1644 # 800084d8 <etext+0x4d8>
    80003e74:	ffffc097          	auipc	ra,0xffffc
    80003e78:	6ec080e7          	jalr	1772(ra) # 80000560 <panic>
      panic("dirlookup read");
    80003e7c:	00004517          	auipc	a0,0x4
    80003e80:	67450513          	add	a0,a0,1652 # 800084f0 <etext+0x4f0>
    80003e84:	ffffc097          	auipc	ra,0xffffc
    80003e88:	6dc080e7          	jalr	1756(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e8c:	24c1                	addw	s1,s1,16
    80003e8e:	04c92783          	lw	a5,76(s2)
    80003e92:	04f4f763          	bgeu	s1,a5,80003ee0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e96:	4741                	li	a4,16
    80003e98:	86a6                	mv	a3,s1
    80003e9a:	fc040613          	add	a2,s0,-64
    80003e9e:	4581                	li	a1,0
    80003ea0:	854a                	mv	a0,s2
    80003ea2:	00000097          	auipc	ra,0x0
    80003ea6:	d4c080e7          	jalr	-692(ra) # 80003bee <readi>
    80003eaa:	47c1                	li	a5,16
    80003eac:	fcf518e3          	bne	a0,a5,80003e7c <dirlookup+0x3a>
    if(de.inum == 0)
    80003eb0:	fc045783          	lhu	a5,-64(s0)
    80003eb4:	dfe1                	beqz	a5,80003e8c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003eb6:	fc240593          	add	a1,s0,-62
    80003eba:	854e                	mv	a0,s3
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	f6c080e7          	jalr	-148(ra) # 80003e28 <namecmp>
    80003ec4:	f561                	bnez	a0,80003e8c <dirlookup+0x4a>
      if(poff)
    80003ec6:	000a0463          	beqz	s4,80003ece <dirlookup+0x8c>
        *poff = off;
    80003eca:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ece:	fc045583          	lhu	a1,-64(s0)
    80003ed2:	00092503          	lw	a0,0(s2)
    80003ed6:	fffff097          	auipc	ra,0xfffff
    80003eda:	720080e7          	jalr	1824(ra) # 800035f6 <iget>
    80003ede:	a011                	j	80003ee2 <dirlookup+0xa0>
  return 0;
    80003ee0:	4501                	li	a0,0
}
    80003ee2:	70e2                	ld	ra,56(sp)
    80003ee4:	7442                	ld	s0,48(sp)
    80003ee6:	74a2                	ld	s1,40(sp)
    80003ee8:	7902                	ld	s2,32(sp)
    80003eea:	69e2                	ld	s3,24(sp)
    80003eec:	6a42                	ld	s4,16(sp)
    80003eee:	6121                	add	sp,sp,64
    80003ef0:	8082                	ret

0000000080003ef2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003ef2:	711d                	add	sp,sp,-96
    80003ef4:	ec86                	sd	ra,88(sp)
    80003ef6:	e8a2                	sd	s0,80(sp)
    80003ef8:	e4a6                	sd	s1,72(sp)
    80003efa:	e0ca                	sd	s2,64(sp)
    80003efc:	fc4e                	sd	s3,56(sp)
    80003efe:	f852                	sd	s4,48(sp)
    80003f00:	f456                	sd	s5,40(sp)
    80003f02:	f05a                	sd	s6,32(sp)
    80003f04:	ec5e                	sd	s7,24(sp)
    80003f06:	e862                	sd	s8,16(sp)
    80003f08:	e466                	sd	s9,8(sp)
    80003f0a:	1080                	add	s0,sp,96
    80003f0c:	84aa                	mv	s1,a0
    80003f0e:	8b2e                	mv	s6,a1
    80003f10:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f12:	00054703          	lbu	a4,0(a0)
    80003f16:	02f00793          	li	a5,47
    80003f1a:	02f70263          	beq	a4,a5,80003f3e <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f1e:	ffffe097          	auipc	ra,0xffffe
    80003f22:	b2c080e7          	jalr	-1236(ra) # 80001a4a <myproc>
    80003f26:	15053503          	ld	a0,336(a0)
    80003f2a:	00000097          	auipc	ra,0x0
    80003f2e:	9ce080e7          	jalr	-1586(ra) # 800038f8 <idup>
    80003f32:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003f34:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003f38:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f3a:	4b85                	li	s7,1
    80003f3c:	a875                	j	80003ff8 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003f3e:	4585                	li	a1,1
    80003f40:	4505                	li	a0,1
    80003f42:	fffff097          	auipc	ra,0xfffff
    80003f46:	6b4080e7          	jalr	1716(ra) # 800035f6 <iget>
    80003f4a:	8a2a                	mv	s4,a0
    80003f4c:	b7e5                	j	80003f34 <namex+0x42>
      iunlockput(ip);
    80003f4e:	8552                	mv	a0,s4
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	c4c080e7          	jalr	-948(ra) # 80003b9c <iunlockput>
      return 0;
    80003f58:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f5a:	8552                	mv	a0,s4
    80003f5c:	60e6                	ld	ra,88(sp)
    80003f5e:	6446                	ld	s0,80(sp)
    80003f60:	64a6                	ld	s1,72(sp)
    80003f62:	6906                	ld	s2,64(sp)
    80003f64:	79e2                	ld	s3,56(sp)
    80003f66:	7a42                	ld	s4,48(sp)
    80003f68:	7aa2                	ld	s5,40(sp)
    80003f6a:	7b02                	ld	s6,32(sp)
    80003f6c:	6be2                	ld	s7,24(sp)
    80003f6e:	6c42                	ld	s8,16(sp)
    80003f70:	6ca2                	ld	s9,8(sp)
    80003f72:	6125                	add	sp,sp,96
    80003f74:	8082                	ret
      iunlock(ip);
    80003f76:	8552                	mv	a0,s4
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	a84080e7          	jalr	-1404(ra) # 800039fc <iunlock>
      return ip;
    80003f80:	bfe9                	j	80003f5a <namex+0x68>
      iunlockput(ip);
    80003f82:	8552                	mv	a0,s4
    80003f84:	00000097          	auipc	ra,0x0
    80003f88:	c18080e7          	jalr	-1000(ra) # 80003b9c <iunlockput>
      return 0;
    80003f8c:	8a4e                	mv	s4,s3
    80003f8e:	b7f1                	j	80003f5a <namex+0x68>
  len = path - s;
    80003f90:	40998633          	sub	a2,s3,s1
    80003f94:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f98:	099c5863          	bge	s8,s9,80004028 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003f9c:	4639                	li	a2,14
    80003f9e:	85a6                	mv	a1,s1
    80003fa0:	8556                	mv	a0,s5
    80003fa2:	ffffd097          	auipc	ra,0xffffd
    80003fa6:	dee080e7          	jalr	-530(ra) # 80000d90 <memmove>
    80003faa:	84ce                	mv	s1,s3
  while(*path == '/')
    80003fac:	0004c783          	lbu	a5,0(s1)
    80003fb0:	01279763          	bne	a5,s2,80003fbe <namex+0xcc>
    path++;
    80003fb4:	0485                	add	s1,s1,1
  while(*path == '/')
    80003fb6:	0004c783          	lbu	a5,0(s1)
    80003fba:	ff278de3          	beq	a5,s2,80003fb4 <namex+0xc2>
    ilock(ip);
    80003fbe:	8552                	mv	a0,s4
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	976080e7          	jalr	-1674(ra) # 80003936 <ilock>
    if(ip->type != T_DIR){
    80003fc8:	044a1783          	lh	a5,68(s4)
    80003fcc:	f97791e3          	bne	a5,s7,80003f4e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003fd0:	000b0563          	beqz	s6,80003fda <namex+0xe8>
    80003fd4:	0004c783          	lbu	a5,0(s1)
    80003fd8:	dfd9                	beqz	a5,80003f76 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fda:	4601                	li	a2,0
    80003fdc:	85d6                	mv	a1,s5
    80003fde:	8552                	mv	a0,s4
    80003fe0:	00000097          	auipc	ra,0x0
    80003fe4:	e62080e7          	jalr	-414(ra) # 80003e42 <dirlookup>
    80003fe8:	89aa                	mv	s3,a0
    80003fea:	dd41                	beqz	a0,80003f82 <namex+0x90>
    iunlockput(ip);
    80003fec:	8552                	mv	a0,s4
    80003fee:	00000097          	auipc	ra,0x0
    80003ff2:	bae080e7          	jalr	-1106(ra) # 80003b9c <iunlockput>
    ip = next;
    80003ff6:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003ff8:	0004c783          	lbu	a5,0(s1)
    80003ffc:	01279763          	bne	a5,s2,8000400a <namex+0x118>
    path++;
    80004000:	0485                	add	s1,s1,1
  while(*path == '/')
    80004002:	0004c783          	lbu	a5,0(s1)
    80004006:	ff278de3          	beq	a5,s2,80004000 <namex+0x10e>
  if(*path == 0)
    8000400a:	cb9d                	beqz	a5,80004040 <namex+0x14e>
  while(*path != '/' && *path != 0)
    8000400c:	0004c783          	lbu	a5,0(s1)
    80004010:	89a6                	mv	s3,s1
  len = path - s;
    80004012:	4c81                	li	s9,0
    80004014:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004016:	01278963          	beq	a5,s2,80004028 <namex+0x136>
    8000401a:	dbbd                	beqz	a5,80003f90 <namex+0x9e>
    path++;
    8000401c:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    8000401e:	0009c783          	lbu	a5,0(s3)
    80004022:	ff279ce3          	bne	a5,s2,8000401a <namex+0x128>
    80004026:	b7ad                	j	80003f90 <namex+0x9e>
    memmove(name, s, len);
    80004028:	2601                	sext.w	a2,a2
    8000402a:	85a6                	mv	a1,s1
    8000402c:	8556                	mv	a0,s5
    8000402e:	ffffd097          	auipc	ra,0xffffd
    80004032:	d62080e7          	jalr	-670(ra) # 80000d90 <memmove>
    name[len] = 0;
    80004036:	9cd6                	add	s9,s9,s5
    80004038:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000403c:	84ce                	mv	s1,s3
    8000403e:	b7bd                	j	80003fac <namex+0xba>
  if(nameiparent){
    80004040:	f00b0de3          	beqz	s6,80003f5a <namex+0x68>
    iput(ip);
    80004044:	8552                	mv	a0,s4
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	aae080e7          	jalr	-1362(ra) # 80003af4 <iput>
    return 0;
    8000404e:	4a01                	li	s4,0
    80004050:	b729                	j	80003f5a <namex+0x68>

0000000080004052 <dirlink>:
{
    80004052:	7139                	add	sp,sp,-64
    80004054:	fc06                	sd	ra,56(sp)
    80004056:	f822                	sd	s0,48(sp)
    80004058:	f04a                	sd	s2,32(sp)
    8000405a:	ec4e                	sd	s3,24(sp)
    8000405c:	e852                	sd	s4,16(sp)
    8000405e:	0080                	add	s0,sp,64
    80004060:	892a                	mv	s2,a0
    80004062:	8a2e                	mv	s4,a1
    80004064:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004066:	4601                	li	a2,0
    80004068:	00000097          	auipc	ra,0x0
    8000406c:	dda080e7          	jalr	-550(ra) # 80003e42 <dirlookup>
    80004070:	ed25                	bnez	a0,800040e8 <dirlink+0x96>
    80004072:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004074:	04c92483          	lw	s1,76(s2)
    80004078:	c49d                	beqz	s1,800040a6 <dirlink+0x54>
    8000407a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000407c:	4741                	li	a4,16
    8000407e:	86a6                	mv	a3,s1
    80004080:	fc040613          	add	a2,s0,-64
    80004084:	4581                	li	a1,0
    80004086:	854a                	mv	a0,s2
    80004088:	00000097          	auipc	ra,0x0
    8000408c:	b66080e7          	jalr	-1178(ra) # 80003bee <readi>
    80004090:	47c1                	li	a5,16
    80004092:	06f51163          	bne	a0,a5,800040f4 <dirlink+0xa2>
    if(de.inum == 0)
    80004096:	fc045783          	lhu	a5,-64(s0)
    8000409a:	c791                	beqz	a5,800040a6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000409c:	24c1                	addw	s1,s1,16
    8000409e:	04c92783          	lw	a5,76(s2)
    800040a2:	fcf4ede3          	bltu	s1,a5,8000407c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040a6:	4639                	li	a2,14
    800040a8:	85d2                	mv	a1,s4
    800040aa:	fc240513          	add	a0,s0,-62
    800040ae:	ffffd097          	auipc	ra,0xffffd
    800040b2:	d8c080e7          	jalr	-628(ra) # 80000e3a <strncpy>
  de.inum = inum;
    800040b6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040ba:	4741                	li	a4,16
    800040bc:	86a6                	mv	a3,s1
    800040be:	fc040613          	add	a2,s0,-64
    800040c2:	4581                	li	a1,0
    800040c4:	854a                	mv	a0,s2
    800040c6:	00000097          	auipc	ra,0x0
    800040ca:	c38080e7          	jalr	-968(ra) # 80003cfe <writei>
    800040ce:	1541                	add	a0,a0,-16
    800040d0:	00a03533          	snez	a0,a0
    800040d4:	40a00533          	neg	a0,a0
    800040d8:	74a2                	ld	s1,40(sp)
}
    800040da:	70e2                	ld	ra,56(sp)
    800040dc:	7442                	ld	s0,48(sp)
    800040de:	7902                	ld	s2,32(sp)
    800040e0:	69e2                	ld	s3,24(sp)
    800040e2:	6a42                	ld	s4,16(sp)
    800040e4:	6121                	add	sp,sp,64
    800040e6:	8082                	ret
    iput(ip);
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	a0c080e7          	jalr	-1524(ra) # 80003af4 <iput>
    return -1;
    800040f0:	557d                	li	a0,-1
    800040f2:	b7e5                	j	800040da <dirlink+0x88>
      panic("dirlink read");
    800040f4:	00004517          	auipc	a0,0x4
    800040f8:	40c50513          	add	a0,a0,1036 # 80008500 <etext+0x500>
    800040fc:	ffffc097          	auipc	ra,0xffffc
    80004100:	464080e7          	jalr	1124(ra) # 80000560 <panic>

0000000080004104 <namei>:

struct inode*
namei(char *path)
{
    80004104:	1101                	add	sp,sp,-32
    80004106:	ec06                	sd	ra,24(sp)
    80004108:	e822                	sd	s0,16(sp)
    8000410a:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000410c:	fe040613          	add	a2,s0,-32
    80004110:	4581                	li	a1,0
    80004112:	00000097          	auipc	ra,0x0
    80004116:	de0080e7          	jalr	-544(ra) # 80003ef2 <namex>
}
    8000411a:	60e2                	ld	ra,24(sp)
    8000411c:	6442                	ld	s0,16(sp)
    8000411e:	6105                	add	sp,sp,32
    80004120:	8082                	ret

0000000080004122 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004122:	1141                	add	sp,sp,-16
    80004124:	e406                	sd	ra,8(sp)
    80004126:	e022                	sd	s0,0(sp)
    80004128:	0800                	add	s0,sp,16
    8000412a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000412c:	4585                	li	a1,1
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	dc4080e7          	jalr	-572(ra) # 80003ef2 <namex>
}
    80004136:	60a2                	ld	ra,8(sp)
    80004138:	6402                	ld	s0,0(sp)
    8000413a:	0141                	add	sp,sp,16
    8000413c:	8082                	ret

000000008000413e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000413e:	1101                	add	sp,sp,-32
    80004140:	ec06                	sd	ra,24(sp)
    80004142:	e822                	sd	s0,16(sp)
    80004144:	e426                	sd	s1,8(sp)
    80004146:	e04a                	sd	s2,0(sp)
    80004148:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000414a:	0001d917          	auipc	s2,0x1d
    8000414e:	9c690913          	add	s2,s2,-1594 # 80020b10 <log>
    80004152:	01892583          	lw	a1,24(s2)
    80004156:	02892503          	lw	a0,40(s2)
    8000415a:	fffff097          	auipc	ra,0xfffff
    8000415e:	fa8080e7          	jalr	-88(ra) # 80003102 <bread>
    80004162:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004164:	02c92603          	lw	a2,44(s2)
    80004168:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000416a:	00c05f63          	blez	a2,80004188 <write_head+0x4a>
    8000416e:	0001d717          	auipc	a4,0x1d
    80004172:	9d270713          	add	a4,a4,-1582 # 80020b40 <log+0x30>
    80004176:	87aa                	mv	a5,a0
    80004178:	060a                	sll	a2,a2,0x2
    8000417a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000417c:	4314                	lw	a3,0(a4)
    8000417e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004180:	0711                	add	a4,a4,4
    80004182:	0791                	add	a5,a5,4
    80004184:	fec79ce3          	bne	a5,a2,8000417c <write_head+0x3e>
  }
  bwrite(buf);
    80004188:	8526                	mv	a0,s1
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	06a080e7          	jalr	106(ra) # 800031f4 <bwrite>
  brelse(buf);
    80004192:	8526                	mv	a0,s1
    80004194:	fffff097          	auipc	ra,0xfffff
    80004198:	09e080e7          	jalr	158(ra) # 80003232 <brelse>
}
    8000419c:	60e2                	ld	ra,24(sp)
    8000419e:	6442                	ld	s0,16(sp)
    800041a0:	64a2                	ld	s1,8(sp)
    800041a2:	6902                	ld	s2,0(sp)
    800041a4:	6105                	add	sp,sp,32
    800041a6:	8082                	ret

00000000800041a8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a8:	0001d797          	auipc	a5,0x1d
    800041ac:	9947a783          	lw	a5,-1644(a5) # 80020b3c <log+0x2c>
    800041b0:	0af05d63          	blez	a5,8000426a <install_trans+0xc2>
{
    800041b4:	7139                	add	sp,sp,-64
    800041b6:	fc06                	sd	ra,56(sp)
    800041b8:	f822                	sd	s0,48(sp)
    800041ba:	f426                	sd	s1,40(sp)
    800041bc:	f04a                	sd	s2,32(sp)
    800041be:	ec4e                	sd	s3,24(sp)
    800041c0:	e852                	sd	s4,16(sp)
    800041c2:	e456                	sd	s5,8(sp)
    800041c4:	e05a                	sd	s6,0(sp)
    800041c6:	0080                	add	s0,sp,64
    800041c8:	8b2a                	mv	s6,a0
    800041ca:	0001da97          	auipc	s5,0x1d
    800041ce:	976a8a93          	add	s5,s5,-1674 # 80020b40 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041d4:	0001d997          	auipc	s3,0x1d
    800041d8:	93c98993          	add	s3,s3,-1732 # 80020b10 <log>
    800041dc:	a00d                	j	800041fe <install_trans+0x56>
    brelse(lbuf);
    800041de:	854a                	mv	a0,s2
    800041e0:	fffff097          	auipc	ra,0xfffff
    800041e4:	052080e7          	jalr	82(ra) # 80003232 <brelse>
    brelse(dbuf);
    800041e8:	8526                	mv	a0,s1
    800041ea:	fffff097          	auipc	ra,0xfffff
    800041ee:	048080e7          	jalr	72(ra) # 80003232 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f2:	2a05                	addw	s4,s4,1
    800041f4:	0a91                	add	s5,s5,4
    800041f6:	02c9a783          	lw	a5,44(s3)
    800041fa:	04fa5e63          	bge	s4,a5,80004256 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041fe:	0189a583          	lw	a1,24(s3)
    80004202:	014585bb          	addw	a1,a1,s4
    80004206:	2585                	addw	a1,a1,1
    80004208:	0289a503          	lw	a0,40(s3)
    8000420c:	fffff097          	auipc	ra,0xfffff
    80004210:	ef6080e7          	jalr	-266(ra) # 80003102 <bread>
    80004214:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004216:	000aa583          	lw	a1,0(s5)
    8000421a:	0289a503          	lw	a0,40(s3)
    8000421e:	fffff097          	auipc	ra,0xfffff
    80004222:	ee4080e7          	jalr	-284(ra) # 80003102 <bread>
    80004226:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004228:	40000613          	li	a2,1024
    8000422c:	05890593          	add	a1,s2,88
    80004230:	05850513          	add	a0,a0,88
    80004234:	ffffd097          	auipc	ra,0xffffd
    80004238:	b5c080e7          	jalr	-1188(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000423c:	8526                	mv	a0,s1
    8000423e:	fffff097          	auipc	ra,0xfffff
    80004242:	fb6080e7          	jalr	-74(ra) # 800031f4 <bwrite>
    if(recovering == 0)
    80004246:	f80b1ce3          	bnez	s6,800041de <install_trans+0x36>
      bunpin(dbuf);
    8000424a:	8526                	mv	a0,s1
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	0be080e7          	jalr	190(ra) # 8000330a <bunpin>
    80004254:	b769                	j	800041de <install_trans+0x36>
}
    80004256:	70e2                	ld	ra,56(sp)
    80004258:	7442                	ld	s0,48(sp)
    8000425a:	74a2                	ld	s1,40(sp)
    8000425c:	7902                	ld	s2,32(sp)
    8000425e:	69e2                	ld	s3,24(sp)
    80004260:	6a42                	ld	s4,16(sp)
    80004262:	6aa2                	ld	s5,8(sp)
    80004264:	6b02                	ld	s6,0(sp)
    80004266:	6121                	add	sp,sp,64
    80004268:	8082                	ret
    8000426a:	8082                	ret

000000008000426c <initlog>:
{
    8000426c:	7179                	add	sp,sp,-48
    8000426e:	f406                	sd	ra,40(sp)
    80004270:	f022                	sd	s0,32(sp)
    80004272:	ec26                	sd	s1,24(sp)
    80004274:	e84a                	sd	s2,16(sp)
    80004276:	e44e                	sd	s3,8(sp)
    80004278:	1800                	add	s0,sp,48
    8000427a:	892a                	mv	s2,a0
    8000427c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000427e:	0001d497          	auipc	s1,0x1d
    80004282:	89248493          	add	s1,s1,-1902 # 80020b10 <log>
    80004286:	00004597          	auipc	a1,0x4
    8000428a:	28a58593          	add	a1,a1,650 # 80008510 <etext+0x510>
    8000428e:	8526                	mv	a0,s1
    80004290:	ffffd097          	auipc	ra,0xffffd
    80004294:	918080e7          	jalr	-1768(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    80004298:	0149a583          	lw	a1,20(s3)
    8000429c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000429e:	0109a783          	lw	a5,16(s3)
    800042a2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042a4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042a8:	854a                	mv	a0,s2
    800042aa:	fffff097          	auipc	ra,0xfffff
    800042ae:	e58080e7          	jalr	-424(ra) # 80003102 <bread>
  log.lh.n = lh->n;
    800042b2:	4d30                	lw	a2,88(a0)
    800042b4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042b6:	00c05f63          	blez	a2,800042d4 <initlog+0x68>
    800042ba:	87aa                	mv	a5,a0
    800042bc:	0001d717          	auipc	a4,0x1d
    800042c0:	88470713          	add	a4,a4,-1916 # 80020b40 <log+0x30>
    800042c4:	060a                	sll	a2,a2,0x2
    800042c6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800042c8:	4ff4                	lw	a3,92(a5)
    800042ca:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042cc:	0791                	add	a5,a5,4
    800042ce:	0711                	add	a4,a4,4
    800042d0:	fec79ce3          	bne	a5,a2,800042c8 <initlog+0x5c>
  brelse(buf);
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	f5e080e7          	jalr	-162(ra) # 80003232 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042dc:	4505                	li	a0,1
    800042de:	00000097          	auipc	ra,0x0
    800042e2:	eca080e7          	jalr	-310(ra) # 800041a8 <install_trans>
  log.lh.n = 0;
    800042e6:	0001d797          	auipc	a5,0x1d
    800042ea:	8407ab23          	sw	zero,-1962(a5) # 80020b3c <log+0x2c>
  write_head(); // clear the log
    800042ee:	00000097          	auipc	ra,0x0
    800042f2:	e50080e7          	jalr	-432(ra) # 8000413e <write_head>
}
    800042f6:	70a2                	ld	ra,40(sp)
    800042f8:	7402                	ld	s0,32(sp)
    800042fa:	64e2                	ld	s1,24(sp)
    800042fc:	6942                	ld	s2,16(sp)
    800042fe:	69a2                	ld	s3,8(sp)
    80004300:	6145                	add	sp,sp,48
    80004302:	8082                	ret

0000000080004304 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004304:	1101                	add	sp,sp,-32
    80004306:	ec06                	sd	ra,24(sp)
    80004308:	e822                	sd	s0,16(sp)
    8000430a:	e426                	sd	s1,8(sp)
    8000430c:	e04a                	sd	s2,0(sp)
    8000430e:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80004310:	0001d517          	auipc	a0,0x1d
    80004314:	80050513          	add	a0,a0,-2048 # 80020b10 <log>
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	920080e7          	jalr	-1760(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    80004320:	0001c497          	auipc	s1,0x1c
    80004324:	7f048493          	add	s1,s1,2032 # 80020b10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004328:	4979                	li	s2,30
    8000432a:	a039                	j	80004338 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000432c:	85a6                	mv	a1,s1
    8000432e:	8526                	mv	a0,s1
    80004330:	ffffe097          	auipc	ra,0xffffe
    80004334:	e10080e7          	jalr	-496(ra) # 80002140 <sleep>
    if(log.committing){
    80004338:	50dc                	lw	a5,36(s1)
    8000433a:	fbed                	bnez	a5,8000432c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000433c:	5098                	lw	a4,32(s1)
    8000433e:	2705                	addw	a4,a4,1
    80004340:	0027179b          	sllw	a5,a4,0x2
    80004344:	9fb9                	addw	a5,a5,a4
    80004346:	0017979b          	sllw	a5,a5,0x1
    8000434a:	54d4                	lw	a3,44(s1)
    8000434c:	9fb5                	addw	a5,a5,a3
    8000434e:	00f95963          	bge	s2,a5,80004360 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004352:	85a6                	mv	a1,s1
    80004354:	8526                	mv	a0,s1
    80004356:	ffffe097          	auipc	ra,0xffffe
    8000435a:	dea080e7          	jalr	-534(ra) # 80002140 <sleep>
    8000435e:	bfe9                	j	80004338 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004360:	0001c517          	auipc	a0,0x1c
    80004364:	7b050513          	add	a0,a0,1968 # 80020b10 <log>
    80004368:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	982080e7          	jalr	-1662(ra) # 80000cec <release>
      break;
    }
  }
}
    80004372:	60e2                	ld	ra,24(sp)
    80004374:	6442                	ld	s0,16(sp)
    80004376:	64a2                	ld	s1,8(sp)
    80004378:	6902                	ld	s2,0(sp)
    8000437a:	6105                	add	sp,sp,32
    8000437c:	8082                	ret

000000008000437e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000437e:	7139                	add	sp,sp,-64
    80004380:	fc06                	sd	ra,56(sp)
    80004382:	f822                	sd	s0,48(sp)
    80004384:	f426                	sd	s1,40(sp)
    80004386:	f04a                	sd	s2,32(sp)
    80004388:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000438a:	0001c497          	auipc	s1,0x1c
    8000438e:	78648493          	add	s1,s1,1926 # 80020b10 <log>
    80004392:	8526                	mv	a0,s1
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	8a4080e7          	jalr	-1884(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    8000439c:	509c                	lw	a5,32(s1)
    8000439e:	37fd                	addw	a5,a5,-1
    800043a0:	0007891b          	sext.w	s2,a5
    800043a4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043a6:	50dc                	lw	a5,36(s1)
    800043a8:	e7b9                	bnez	a5,800043f6 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800043aa:	06091163          	bnez	s2,8000440c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043ae:	0001c497          	auipc	s1,0x1c
    800043b2:	76248493          	add	s1,s1,1890 # 80020b10 <log>
    800043b6:	4785                	li	a5,1
    800043b8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043ba:	8526                	mv	a0,s1
    800043bc:	ffffd097          	auipc	ra,0xffffd
    800043c0:	930080e7          	jalr	-1744(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043c4:	54dc                	lw	a5,44(s1)
    800043c6:	06f04763          	bgtz	a5,80004434 <end_op+0xb6>
    acquire(&log.lock);
    800043ca:	0001c497          	auipc	s1,0x1c
    800043ce:	74648493          	add	s1,s1,1862 # 80020b10 <log>
    800043d2:	8526                	mv	a0,s1
    800043d4:	ffffd097          	auipc	ra,0xffffd
    800043d8:	864080e7          	jalr	-1948(ra) # 80000c38 <acquire>
    log.committing = 0;
    800043dc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043e0:	8526                	mv	a0,s1
    800043e2:	ffffe097          	auipc	ra,0xffffe
    800043e6:	dc2080e7          	jalr	-574(ra) # 800021a4 <wakeup>
    release(&log.lock);
    800043ea:	8526                	mv	a0,s1
    800043ec:	ffffd097          	auipc	ra,0xffffd
    800043f0:	900080e7          	jalr	-1792(ra) # 80000cec <release>
}
    800043f4:	a815                	j	80004428 <end_op+0xaa>
    800043f6:	ec4e                	sd	s3,24(sp)
    800043f8:	e852                	sd	s4,16(sp)
    800043fa:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800043fc:	00004517          	auipc	a0,0x4
    80004400:	11c50513          	add	a0,a0,284 # 80008518 <etext+0x518>
    80004404:	ffffc097          	auipc	ra,0xffffc
    80004408:	15c080e7          	jalr	348(ra) # 80000560 <panic>
    wakeup(&log);
    8000440c:	0001c497          	auipc	s1,0x1c
    80004410:	70448493          	add	s1,s1,1796 # 80020b10 <log>
    80004414:	8526                	mv	a0,s1
    80004416:	ffffe097          	auipc	ra,0xffffe
    8000441a:	d8e080e7          	jalr	-626(ra) # 800021a4 <wakeup>
  release(&log.lock);
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffd097          	auipc	ra,0xffffd
    80004424:	8cc080e7          	jalr	-1844(ra) # 80000cec <release>
}
    80004428:	70e2                	ld	ra,56(sp)
    8000442a:	7442                	ld	s0,48(sp)
    8000442c:	74a2                	ld	s1,40(sp)
    8000442e:	7902                	ld	s2,32(sp)
    80004430:	6121                	add	sp,sp,64
    80004432:	8082                	ret
    80004434:	ec4e                	sd	s3,24(sp)
    80004436:	e852                	sd	s4,16(sp)
    80004438:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000443a:	0001ca97          	auipc	s5,0x1c
    8000443e:	706a8a93          	add	s5,s5,1798 # 80020b40 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004442:	0001ca17          	auipc	s4,0x1c
    80004446:	6cea0a13          	add	s4,s4,1742 # 80020b10 <log>
    8000444a:	018a2583          	lw	a1,24(s4)
    8000444e:	012585bb          	addw	a1,a1,s2
    80004452:	2585                	addw	a1,a1,1
    80004454:	028a2503          	lw	a0,40(s4)
    80004458:	fffff097          	auipc	ra,0xfffff
    8000445c:	caa080e7          	jalr	-854(ra) # 80003102 <bread>
    80004460:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004462:	000aa583          	lw	a1,0(s5)
    80004466:	028a2503          	lw	a0,40(s4)
    8000446a:	fffff097          	auipc	ra,0xfffff
    8000446e:	c98080e7          	jalr	-872(ra) # 80003102 <bread>
    80004472:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004474:	40000613          	li	a2,1024
    80004478:	05850593          	add	a1,a0,88
    8000447c:	05848513          	add	a0,s1,88
    80004480:	ffffd097          	auipc	ra,0xffffd
    80004484:	910080e7          	jalr	-1776(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    80004488:	8526                	mv	a0,s1
    8000448a:	fffff097          	auipc	ra,0xfffff
    8000448e:	d6a080e7          	jalr	-662(ra) # 800031f4 <bwrite>
    brelse(from);
    80004492:	854e                	mv	a0,s3
    80004494:	fffff097          	auipc	ra,0xfffff
    80004498:	d9e080e7          	jalr	-610(ra) # 80003232 <brelse>
    brelse(to);
    8000449c:	8526                	mv	a0,s1
    8000449e:	fffff097          	auipc	ra,0xfffff
    800044a2:	d94080e7          	jalr	-620(ra) # 80003232 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044a6:	2905                	addw	s2,s2,1
    800044a8:	0a91                	add	s5,s5,4
    800044aa:	02ca2783          	lw	a5,44(s4)
    800044ae:	f8f94ee3          	blt	s2,a5,8000444a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044b2:	00000097          	auipc	ra,0x0
    800044b6:	c8c080e7          	jalr	-884(ra) # 8000413e <write_head>
    install_trans(0); // Now install writes to home locations
    800044ba:	4501                	li	a0,0
    800044bc:	00000097          	auipc	ra,0x0
    800044c0:	cec080e7          	jalr	-788(ra) # 800041a8 <install_trans>
    log.lh.n = 0;
    800044c4:	0001c797          	auipc	a5,0x1c
    800044c8:	6607ac23          	sw	zero,1656(a5) # 80020b3c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044cc:	00000097          	auipc	ra,0x0
    800044d0:	c72080e7          	jalr	-910(ra) # 8000413e <write_head>
    800044d4:	69e2                	ld	s3,24(sp)
    800044d6:	6a42                	ld	s4,16(sp)
    800044d8:	6aa2                	ld	s5,8(sp)
    800044da:	bdc5                	j	800043ca <end_op+0x4c>

00000000800044dc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044dc:	1101                	add	sp,sp,-32
    800044de:	ec06                	sd	ra,24(sp)
    800044e0:	e822                	sd	s0,16(sp)
    800044e2:	e426                	sd	s1,8(sp)
    800044e4:	e04a                	sd	s2,0(sp)
    800044e6:	1000                	add	s0,sp,32
    800044e8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044ea:	0001c917          	auipc	s2,0x1c
    800044ee:	62690913          	add	s2,s2,1574 # 80020b10 <log>
    800044f2:	854a                	mv	a0,s2
    800044f4:	ffffc097          	auipc	ra,0xffffc
    800044f8:	744080e7          	jalr	1860(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044fc:	02c92603          	lw	a2,44(s2)
    80004500:	47f5                	li	a5,29
    80004502:	06c7c563          	blt	a5,a2,8000456c <log_write+0x90>
    80004506:	0001c797          	auipc	a5,0x1c
    8000450a:	6267a783          	lw	a5,1574(a5) # 80020b2c <log+0x1c>
    8000450e:	37fd                	addw	a5,a5,-1
    80004510:	04f65e63          	bge	a2,a5,8000456c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004514:	0001c797          	auipc	a5,0x1c
    80004518:	61c7a783          	lw	a5,1564(a5) # 80020b30 <log+0x20>
    8000451c:	06f05063          	blez	a5,8000457c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004520:	4781                	li	a5,0
    80004522:	06c05563          	blez	a2,8000458c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004526:	44cc                	lw	a1,12(s1)
    80004528:	0001c717          	auipc	a4,0x1c
    8000452c:	61870713          	add	a4,a4,1560 # 80020b40 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004530:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004532:	4314                	lw	a3,0(a4)
    80004534:	04b68c63          	beq	a3,a1,8000458c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004538:	2785                	addw	a5,a5,1
    8000453a:	0711                	add	a4,a4,4
    8000453c:	fef61be3          	bne	a2,a5,80004532 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004540:	0621                	add	a2,a2,8
    80004542:	060a                	sll	a2,a2,0x2
    80004544:	0001c797          	auipc	a5,0x1c
    80004548:	5cc78793          	add	a5,a5,1484 # 80020b10 <log>
    8000454c:	97b2                	add	a5,a5,a2
    8000454e:	44d8                	lw	a4,12(s1)
    80004550:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004552:	8526                	mv	a0,s1
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	d7a080e7          	jalr	-646(ra) # 800032ce <bpin>
    log.lh.n++;
    8000455c:	0001c717          	auipc	a4,0x1c
    80004560:	5b470713          	add	a4,a4,1460 # 80020b10 <log>
    80004564:	575c                	lw	a5,44(a4)
    80004566:	2785                	addw	a5,a5,1
    80004568:	d75c                	sw	a5,44(a4)
    8000456a:	a82d                	j	800045a4 <log_write+0xc8>
    panic("too big a transaction");
    8000456c:	00004517          	auipc	a0,0x4
    80004570:	fbc50513          	add	a0,a0,-68 # 80008528 <etext+0x528>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	fec080e7          	jalr	-20(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    8000457c:	00004517          	auipc	a0,0x4
    80004580:	fc450513          	add	a0,a0,-60 # 80008540 <etext+0x540>
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	fdc080e7          	jalr	-36(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    8000458c:	00878693          	add	a3,a5,8
    80004590:	068a                	sll	a3,a3,0x2
    80004592:	0001c717          	auipc	a4,0x1c
    80004596:	57e70713          	add	a4,a4,1406 # 80020b10 <log>
    8000459a:	9736                	add	a4,a4,a3
    8000459c:	44d4                	lw	a3,12(s1)
    8000459e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045a0:	faf609e3          	beq	a2,a5,80004552 <log_write+0x76>
  }
  release(&log.lock);
    800045a4:	0001c517          	auipc	a0,0x1c
    800045a8:	56c50513          	add	a0,a0,1388 # 80020b10 <log>
    800045ac:	ffffc097          	auipc	ra,0xffffc
    800045b0:	740080e7          	jalr	1856(ra) # 80000cec <release>
}
    800045b4:	60e2                	ld	ra,24(sp)
    800045b6:	6442                	ld	s0,16(sp)
    800045b8:	64a2                	ld	s1,8(sp)
    800045ba:	6902                	ld	s2,0(sp)
    800045bc:	6105                	add	sp,sp,32
    800045be:	8082                	ret

00000000800045c0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045c0:	1101                	add	sp,sp,-32
    800045c2:	ec06                	sd	ra,24(sp)
    800045c4:	e822                	sd	s0,16(sp)
    800045c6:	e426                	sd	s1,8(sp)
    800045c8:	e04a                	sd	s2,0(sp)
    800045ca:	1000                	add	s0,sp,32
    800045cc:	84aa                	mv	s1,a0
    800045ce:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045d0:	00004597          	auipc	a1,0x4
    800045d4:	f9058593          	add	a1,a1,-112 # 80008560 <etext+0x560>
    800045d8:	0521                	add	a0,a0,8
    800045da:	ffffc097          	auipc	ra,0xffffc
    800045de:	5ce080e7          	jalr	1486(ra) # 80000ba8 <initlock>
  lk->name = name;
    800045e2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045e6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ea:	0204a423          	sw	zero,40(s1)
}
    800045ee:	60e2                	ld	ra,24(sp)
    800045f0:	6442                	ld	s0,16(sp)
    800045f2:	64a2                	ld	s1,8(sp)
    800045f4:	6902                	ld	s2,0(sp)
    800045f6:	6105                	add	sp,sp,32
    800045f8:	8082                	ret

00000000800045fa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045fa:	1101                	add	sp,sp,-32
    800045fc:	ec06                	sd	ra,24(sp)
    800045fe:	e822                	sd	s0,16(sp)
    80004600:	e426                	sd	s1,8(sp)
    80004602:	e04a                	sd	s2,0(sp)
    80004604:	1000                	add	s0,sp,32
    80004606:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004608:	00850913          	add	s2,a0,8
    8000460c:	854a                	mv	a0,s2
    8000460e:	ffffc097          	auipc	ra,0xffffc
    80004612:	62a080e7          	jalr	1578(ra) # 80000c38 <acquire>
  while (lk->locked) {
    80004616:	409c                	lw	a5,0(s1)
    80004618:	cb89                	beqz	a5,8000462a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000461a:	85ca                	mv	a1,s2
    8000461c:	8526                	mv	a0,s1
    8000461e:	ffffe097          	auipc	ra,0xffffe
    80004622:	b22080e7          	jalr	-1246(ra) # 80002140 <sleep>
  while (lk->locked) {
    80004626:	409c                	lw	a5,0(s1)
    80004628:	fbed                	bnez	a5,8000461a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000462a:	4785                	li	a5,1
    8000462c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000462e:	ffffd097          	auipc	ra,0xffffd
    80004632:	41c080e7          	jalr	1052(ra) # 80001a4a <myproc>
    80004636:	591c                	lw	a5,48(a0)
    80004638:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000463a:	854a                	mv	a0,s2
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	6b0080e7          	jalr	1712(ra) # 80000cec <release>
}
    80004644:	60e2                	ld	ra,24(sp)
    80004646:	6442                	ld	s0,16(sp)
    80004648:	64a2                	ld	s1,8(sp)
    8000464a:	6902                	ld	s2,0(sp)
    8000464c:	6105                	add	sp,sp,32
    8000464e:	8082                	ret

0000000080004650 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004650:	1101                	add	sp,sp,-32
    80004652:	ec06                	sd	ra,24(sp)
    80004654:	e822                	sd	s0,16(sp)
    80004656:	e426                	sd	s1,8(sp)
    80004658:	e04a                	sd	s2,0(sp)
    8000465a:	1000                	add	s0,sp,32
    8000465c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000465e:	00850913          	add	s2,a0,8
    80004662:	854a                	mv	a0,s2
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	5d4080e7          	jalr	1492(ra) # 80000c38 <acquire>
  lk->locked = 0;
    8000466c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004670:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004674:	8526                	mv	a0,s1
    80004676:	ffffe097          	auipc	ra,0xffffe
    8000467a:	b2e080e7          	jalr	-1234(ra) # 800021a4 <wakeup>
  release(&lk->lk);
    8000467e:	854a                	mv	a0,s2
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	66c080e7          	jalr	1644(ra) # 80000cec <release>
}
    80004688:	60e2                	ld	ra,24(sp)
    8000468a:	6442                	ld	s0,16(sp)
    8000468c:	64a2                	ld	s1,8(sp)
    8000468e:	6902                	ld	s2,0(sp)
    80004690:	6105                	add	sp,sp,32
    80004692:	8082                	ret

0000000080004694 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004694:	7179                	add	sp,sp,-48
    80004696:	f406                	sd	ra,40(sp)
    80004698:	f022                	sd	s0,32(sp)
    8000469a:	ec26                	sd	s1,24(sp)
    8000469c:	e84a                	sd	s2,16(sp)
    8000469e:	1800                	add	s0,sp,48
    800046a0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046a2:	00850913          	add	s2,a0,8
    800046a6:	854a                	mv	a0,s2
    800046a8:	ffffc097          	auipc	ra,0xffffc
    800046ac:	590080e7          	jalr	1424(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046b0:	409c                	lw	a5,0(s1)
    800046b2:	ef91                	bnez	a5,800046ce <holdingsleep+0x3a>
    800046b4:	4481                	li	s1,0
  release(&lk->lk);
    800046b6:	854a                	mv	a0,s2
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	634080e7          	jalr	1588(ra) # 80000cec <release>
  return r;
}
    800046c0:	8526                	mv	a0,s1
    800046c2:	70a2                	ld	ra,40(sp)
    800046c4:	7402                	ld	s0,32(sp)
    800046c6:	64e2                	ld	s1,24(sp)
    800046c8:	6942                	ld	s2,16(sp)
    800046ca:	6145                	add	sp,sp,48
    800046cc:	8082                	ret
    800046ce:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800046d0:	0284a983          	lw	s3,40(s1)
    800046d4:	ffffd097          	auipc	ra,0xffffd
    800046d8:	376080e7          	jalr	886(ra) # 80001a4a <myproc>
    800046dc:	5904                	lw	s1,48(a0)
    800046de:	413484b3          	sub	s1,s1,s3
    800046e2:	0014b493          	seqz	s1,s1
    800046e6:	69a2                	ld	s3,8(sp)
    800046e8:	b7f9                	j	800046b6 <holdingsleep+0x22>

00000000800046ea <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046ea:	1141                	add	sp,sp,-16
    800046ec:	e406                	sd	ra,8(sp)
    800046ee:	e022                	sd	s0,0(sp)
    800046f0:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046f2:	00004597          	auipc	a1,0x4
    800046f6:	e7e58593          	add	a1,a1,-386 # 80008570 <etext+0x570>
    800046fa:	0001c517          	auipc	a0,0x1c
    800046fe:	55e50513          	add	a0,a0,1374 # 80020c58 <ftable>
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	4a6080e7          	jalr	1190(ra) # 80000ba8 <initlock>
}
    8000470a:	60a2                	ld	ra,8(sp)
    8000470c:	6402                	ld	s0,0(sp)
    8000470e:	0141                	add	sp,sp,16
    80004710:	8082                	ret

0000000080004712 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004712:	1101                	add	sp,sp,-32
    80004714:	ec06                	sd	ra,24(sp)
    80004716:	e822                	sd	s0,16(sp)
    80004718:	e426                	sd	s1,8(sp)
    8000471a:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000471c:	0001c517          	auipc	a0,0x1c
    80004720:	53c50513          	add	a0,a0,1340 # 80020c58 <ftable>
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	514080e7          	jalr	1300(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000472c:	0001c497          	auipc	s1,0x1c
    80004730:	54448493          	add	s1,s1,1348 # 80020c70 <ftable+0x18>
    80004734:	0001d717          	auipc	a4,0x1d
    80004738:	4dc70713          	add	a4,a4,1244 # 80021c10 <disk>
    if(f->ref == 0){
    8000473c:	40dc                	lw	a5,4(s1)
    8000473e:	cf99                	beqz	a5,8000475c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004740:	02848493          	add	s1,s1,40
    80004744:	fee49ce3          	bne	s1,a4,8000473c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004748:	0001c517          	auipc	a0,0x1c
    8000474c:	51050513          	add	a0,a0,1296 # 80020c58 <ftable>
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	59c080e7          	jalr	1436(ra) # 80000cec <release>
  return 0;
    80004758:	4481                	li	s1,0
    8000475a:	a819                	j	80004770 <filealloc+0x5e>
      f->ref = 1;
    8000475c:	4785                	li	a5,1
    8000475e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004760:	0001c517          	auipc	a0,0x1c
    80004764:	4f850513          	add	a0,a0,1272 # 80020c58 <ftable>
    80004768:	ffffc097          	auipc	ra,0xffffc
    8000476c:	584080e7          	jalr	1412(ra) # 80000cec <release>
}
    80004770:	8526                	mv	a0,s1
    80004772:	60e2                	ld	ra,24(sp)
    80004774:	6442                	ld	s0,16(sp)
    80004776:	64a2                	ld	s1,8(sp)
    80004778:	6105                	add	sp,sp,32
    8000477a:	8082                	ret

000000008000477c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000477c:	1101                	add	sp,sp,-32
    8000477e:	ec06                	sd	ra,24(sp)
    80004780:	e822                	sd	s0,16(sp)
    80004782:	e426                	sd	s1,8(sp)
    80004784:	1000                	add	s0,sp,32
    80004786:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004788:	0001c517          	auipc	a0,0x1c
    8000478c:	4d050513          	add	a0,a0,1232 # 80020c58 <ftable>
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	4a8080e7          	jalr	1192(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004798:	40dc                	lw	a5,4(s1)
    8000479a:	02f05263          	blez	a5,800047be <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000479e:	2785                	addw	a5,a5,1
    800047a0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047a2:	0001c517          	auipc	a0,0x1c
    800047a6:	4b650513          	add	a0,a0,1206 # 80020c58 <ftable>
    800047aa:	ffffc097          	auipc	ra,0xffffc
    800047ae:	542080e7          	jalr	1346(ra) # 80000cec <release>
  return f;
}
    800047b2:	8526                	mv	a0,s1
    800047b4:	60e2                	ld	ra,24(sp)
    800047b6:	6442                	ld	s0,16(sp)
    800047b8:	64a2                	ld	s1,8(sp)
    800047ba:	6105                	add	sp,sp,32
    800047bc:	8082                	ret
    panic("filedup");
    800047be:	00004517          	auipc	a0,0x4
    800047c2:	dba50513          	add	a0,a0,-582 # 80008578 <etext+0x578>
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	d9a080e7          	jalr	-614(ra) # 80000560 <panic>

00000000800047ce <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047ce:	7139                	add	sp,sp,-64
    800047d0:	fc06                	sd	ra,56(sp)
    800047d2:	f822                	sd	s0,48(sp)
    800047d4:	f426                	sd	s1,40(sp)
    800047d6:	0080                	add	s0,sp,64
    800047d8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047da:	0001c517          	auipc	a0,0x1c
    800047de:	47e50513          	add	a0,a0,1150 # 80020c58 <ftable>
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	456080e7          	jalr	1110(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    800047ea:	40dc                	lw	a5,4(s1)
    800047ec:	04f05c63          	blez	a5,80004844 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    800047f0:	37fd                	addw	a5,a5,-1
    800047f2:	0007871b          	sext.w	a4,a5
    800047f6:	c0dc                	sw	a5,4(s1)
    800047f8:	06e04263          	bgtz	a4,8000485c <fileclose+0x8e>
    800047fc:	f04a                	sd	s2,32(sp)
    800047fe:	ec4e                	sd	s3,24(sp)
    80004800:	e852                	sd	s4,16(sp)
    80004802:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004804:	0004a903          	lw	s2,0(s1)
    80004808:	0094ca83          	lbu	s5,9(s1)
    8000480c:	0104ba03          	ld	s4,16(s1)
    80004810:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004814:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004818:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000481c:	0001c517          	auipc	a0,0x1c
    80004820:	43c50513          	add	a0,a0,1084 # 80020c58 <ftable>
    80004824:	ffffc097          	auipc	ra,0xffffc
    80004828:	4c8080e7          	jalr	1224(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    8000482c:	4785                	li	a5,1
    8000482e:	04f90463          	beq	s2,a5,80004876 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004832:	3979                	addw	s2,s2,-2
    80004834:	4785                	li	a5,1
    80004836:	0527fb63          	bgeu	a5,s2,8000488c <fileclose+0xbe>
    8000483a:	7902                	ld	s2,32(sp)
    8000483c:	69e2                	ld	s3,24(sp)
    8000483e:	6a42                	ld	s4,16(sp)
    80004840:	6aa2                	ld	s5,8(sp)
    80004842:	a02d                	j	8000486c <fileclose+0x9e>
    80004844:	f04a                	sd	s2,32(sp)
    80004846:	ec4e                	sd	s3,24(sp)
    80004848:	e852                	sd	s4,16(sp)
    8000484a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000484c:	00004517          	auipc	a0,0x4
    80004850:	d3450513          	add	a0,a0,-716 # 80008580 <etext+0x580>
    80004854:	ffffc097          	auipc	ra,0xffffc
    80004858:	d0c080e7          	jalr	-756(ra) # 80000560 <panic>
    release(&ftable.lock);
    8000485c:	0001c517          	auipc	a0,0x1c
    80004860:	3fc50513          	add	a0,a0,1020 # 80020c58 <ftable>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	488080e7          	jalr	1160(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000486c:	70e2                	ld	ra,56(sp)
    8000486e:	7442                	ld	s0,48(sp)
    80004870:	74a2                	ld	s1,40(sp)
    80004872:	6121                	add	sp,sp,64
    80004874:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004876:	85d6                	mv	a1,s5
    80004878:	8552                	mv	a0,s4
    8000487a:	00000097          	auipc	ra,0x0
    8000487e:	3a2080e7          	jalr	930(ra) # 80004c1c <pipeclose>
    80004882:	7902                	ld	s2,32(sp)
    80004884:	69e2                	ld	s3,24(sp)
    80004886:	6a42                	ld	s4,16(sp)
    80004888:	6aa2                	ld	s5,8(sp)
    8000488a:	b7cd                	j	8000486c <fileclose+0x9e>
    begin_op();
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	a78080e7          	jalr	-1416(ra) # 80004304 <begin_op>
    iput(ff.ip);
    80004894:	854e                	mv	a0,s3
    80004896:	fffff097          	auipc	ra,0xfffff
    8000489a:	25e080e7          	jalr	606(ra) # 80003af4 <iput>
    end_op();
    8000489e:	00000097          	auipc	ra,0x0
    800048a2:	ae0080e7          	jalr	-1312(ra) # 8000437e <end_op>
    800048a6:	7902                	ld	s2,32(sp)
    800048a8:	69e2                	ld	s3,24(sp)
    800048aa:	6a42                	ld	s4,16(sp)
    800048ac:	6aa2                	ld	s5,8(sp)
    800048ae:	bf7d                	j	8000486c <fileclose+0x9e>

00000000800048b0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048b0:	715d                	add	sp,sp,-80
    800048b2:	e486                	sd	ra,72(sp)
    800048b4:	e0a2                	sd	s0,64(sp)
    800048b6:	fc26                	sd	s1,56(sp)
    800048b8:	f44e                	sd	s3,40(sp)
    800048ba:	0880                	add	s0,sp,80
    800048bc:	84aa                	mv	s1,a0
    800048be:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048c0:	ffffd097          	auipc	ra,0xffffd
    800048c4:	18a080e7          	jalr	394(ra) # 80001a4a <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048c8:	409c                	lw	a5,0(s1)
    800048ca:	37f9                	addw	a5,a5,-2
    800048cc:	4705                	li	a4,1
    800048ce:	04f76863          	bltu	a4,a5,8000491e <filestat+0x6e>
    800048d2:	f84a                	sd	s2,48(sp)
    800048d4:	892a                	mv	s2,a0
    ilock(f->ip);
    800048d6:	6c88                	ld	a0,24(s1)
    800048d8:	fffff097          	auipc	ra,0xfffff
    800048dc:	05e080e7          	jalr	94(ra) # 80003936 <ilock>
    stati(f->ip, &st);
    800048e0:	fb840593          	add	a1,s0,-72
    800048e4:	6c88                	ld	a0,24(s1)
    800048e6:	fffff097          	auipc	ra,0xfffff
    800048ea:	2de080e7          	jalr	734(ra) # 80003bc4 <stati>
    iunlock(f->ip);
    800048ee:	6c88                	ld	a0,24(s1)
    800048f0:	fffff097          	auipc	ra,0xfffff
    800048f4:	10c080e7          	jalr	268(ra) # 800039fc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048f8:	46e1                	li	a3,24
    800048fa:	fb840613          	add	a2,s0,-72
    800048fe:	85ce                	mv	a1,s3
    80004900:	05093503          	ld	a0,80(s2)
    80004904:	ffffd097          	auipc	ra,0xffffd
    80004908:	dde080e7          	jalr	-546(ra) # 800016e2 <copyout>
    8000490c:	41f5551b          	sraw	a0,a0,0x1f
    80004910:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004912:	60a6                	ld	ra,72(sp)
    80004914:	6406                	ld	s0,64(sp)
    80004916:	74e2                	ld	s1,56(sp)
    80004918:	79a2                	ld	s3,40(sp)
    8000491a:	6161                	add	sp,sp,80
    8000491c:	8082                	ret
  return -1;
    8000491e:	557d                	li	a0,-1
    80004920:	bfcd                	j	80004912 <filestat+0x62>

0000000080004922 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004922:	7179                	add	sp,sp,-48
    80004924:	f406                	sd	ra,40(sp)
    80004926:	f022                	sd	s0,32(sp)
    80004928:	e84a                	sd	s2,16(sp)
    8000492a:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000492c:	00854783          	lbu	a5,8(a0)
    80004930:	cbc5                	beqz	a5,800049e0 <fileread+0xbe>
    80004932:	ec26                	sd	s1,24(sp)
    80004934:	e44e                	sd	s3,8(sp)
    80004936:	84aa                	mv	s1,a0
    80004938:	89ae                	mv	s3,a1
    8000493a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000493c:	411c                	lw	a5,0(a0)
    8000493e:	4705                	li	a4,1
    80004940:	04e78963          	beq	a5,a4,80004992 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004944:	470d                	li	a4,3
    80004946:	04e78f63          	beq	a5,a4,800049a4 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000494a:	4709                	li	a4,2
    8000494c:	08e79263          	bne	a5,a4,800049d0 <fileread+0xae>
    ilock(f->ip);
    80004950:	6d08                	ld	a0,24(a0)
    80004952:	fffff097          	auipc	ra,0xfffff
    80004956:	fe4080e7          	jalr	-28(ra) # 80003936 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000495a:	874a                	mv	a4,s2
    8000495c:	5094                	lw	a3,32(s1)
    8000495e:	864e                	mv	a2,s3
    80004960:	4585                	li	a1,1
    80004962:	6c88                	ld	a0,24(s1)
    80004964:	fffff097          	auipc	ra,0xfffff
    80004968:	28a080e7          	jalr	650(ra) # 80003bee <readi>
    8000496c:	892a                	mv	s2,a0
    8000496e:	00a05563          	blez	a0,80004978 <fileread+0x56>
      f->off += r;
    80004972:	509c                	lw	a5,32(s1)
    80004974:	9fa9                	addw	a5,a5,a0
    80004976:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004978:	6c88                	ld	a0,24(s1)
    8000497a:	fffff097          	auipc	ra,0xfffff
    8000497e:	082080e7          	jalr	130(ra) # 800039fc <iunlock>
    80004982:	64e2                	ld	s1,24(sp)
    80004984:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004986:	854a                	mv	a0,s2
    80004988:	70a2                	ld	ra,40(sp)
    8000498a:	7402                	ld	s0,32(sp)
    8000498c:	6942                	ld	s2,16(sp)
    8000498e:	6145                	add	sp,sp,48
    80004990:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004992:	6908                	ld	a0,16(a0)
    80004994:	00000097          	auipc	ra,0x0
    80004998:	400080e7          	jalr	1024(ra) # 80004d94 <piperead>
    8000499c:	892a                	mv	s2,a0
    8000499e:	64e2                	ld	s1,24(sp)
    800049a0:	69a2                	ld	s3,8(sp)
    800049a2:	b7d5                	j	80004986 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049a4:	02451783          	lh	a5,36(a0)
    800049a8:	03079693          	sll	a3,a5,0x30
    800049ac:	92c1                	srl	a3,a3,0x30
    800049ae:	4725                	li	a4,9
    800049b0:	02d76a63          	bltu	a4,a3,800049e4 <fileread+0xc2>
    800049b4:	0792                	sll	a5,a5,0x4
    800049b6:	0001c717          	auipc	a4,0x1c
    800049ba:	20270713          	add	a4,a4,514 # 80020bb8 <devsw>
    800049be:	97ba                	add	a5,a5,a4
    800049c0:	639c                	ld	a5,0(a5)
    800049c2:	c78d                	beqz	a5,800049ec <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    800049c4:	4505                	li	a0,1
    800049c6:	9782                	jalr	a5
    800049c8:	892a                	mv	s2,a0
    800049ca:	64e2                	ld	s1,24(sp)
    800049cc:	69a2                	ld	s3,8(sp)
    800049ce:	bf65                	j	80004986 <fileread+0x64>
    panic("fileread");
    800049d0:	00004517          	auipc	a0,0x4
    800049d4:	bc050513          	add	a0,a0,-1088 # 80008590 <etext+0x590>
    800049d8:	ffffc097          	auipc	ra,0xffffc
    800049dc:	b88080e7          	jalr	-1144(ra) # 80000560 <panic>
    return -1;
    800049e0:	597d                	li	s2,-1
    800049e2:	b755                	j	80004986 <fileread+0x64>
      return -1;
    800049e4:	597d                	li	s2,-1
    800049e6:	64e2                	ld	s1,24(sp)
    800049e8:	69a2                	ld	s3,8(sp)
    800049ea:	bf71                	j	80004986 <fileread+0x64>
    800049ec:	597d                	li	s2,-1
    800049ee:	64e2                	ld	s1,24(sp)
    800049f0:	69a2                	ld	s3,8(sp)
    800049f2:	bf51                	j	80004986 <fileread+0x64>

00000000800049f4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800049f4:	00954783          	lbu	a5,9(a0)
    800049f8:	12078963          	beqz	a5,80004b2a <filewrite+0x136>
{
    800049fc:	715d                	add	sp,sp,-80
    800049fe:	e486                	sd	ra,72(sp)
    80004a00:	e0a2                	sd	s0,64(sp)
    80004a02:	f84a                	sd	s2,48(sp)
    80004a04:	f052                	sd	s4,32(sp)
    80004a06:	e85a                	sd	s6,16(sp)
    80004a08:	0880                	add	s0,sp,80
    80004a0a:	892a                	mv	s2,a0
    80004a0c:	8b2e                	mv	s6,a1
    80004a0e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a10:	411c                	lw	a5,0(a0)
    80004a12:	4705                	li	a4,1
    80004a14:	02e78763          	beq	a5,a4,80004a42 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a18:	470d                	li	a4,3
    80004a1a:	02e78a63          	beq	a5,a4,80004a4e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a1e:	4709                	li	a4,2
    80004a20:	0ee79863          	bne	a5,a4,80004b10 <filewrite+0x11c>
    80004a24:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a26:	0cc05463          	blez	a2,80004aee <filewrite+0xfa>
    80004a2a:	fc26                	sd	s1,56(sp)
    80004a2c:	ec56                	sd	s5,24(sp)
    80004a2e:	e45e                	sd	s7,8(sp)
    80004a30:	e062                	sd	s8,0(sp)
    int i = 0;
    80004a32:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004a34:	6b85                	lui	s7,0x1
    80004a36:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a3a:	6c05                	lui	s8,0x1
    80004a3c:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004a40:	a851                	j	80004ad4 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004a42:	6908                	ld	a0,16(a0)
    80004a44:	00000097          	auipc	ra,0x0
    80004a48:	248080e7          	jalr	584(ra) # 80004c8c <pipewrite>
    80004a4c:	a85d                	j	80004b02 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a4e:	02451783          	lh	a5,36(a0)
    80004a52:	03079693          	sll	a3,a5,0x30
    80004a56:	92c1                	srl	a3,a3,0x30
    80004a58:	4725                	li	a4,9
    80004a5a:	0cd76a63          	bltu	a4,a3,80004b2e <filewrite+0x13a>
    80004a5e:	0792                	sll	a5,a5,0x4
    80004a60:	0001c717          	auipc	a4,0x1c
    80004a64:	15870713          	add	a4,a4,344 # 80020bb8 <devsw>
    80004a68:	97ba                	add	a5,a5,a4
    80004a6a:	679c                	ld	a5,8(a5)
    80004a6c:	c3f9                	beqz	a5,80004b32 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004a6e:	4505                	li	a0,1
    80004a70:	9782                	jalr	a5
    80004a72:	a841                	j	80004b02 <filewrite+0x10e>
      if(n1 > max)
    80004a74:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004a78:	00000097          	auipc	ra,0x0
    80004a7c:	88c080e7          	jalr	-1908(ra) # 80004304 <begin_op>
      ilock(f->ip);
    80004a80:	01893503          	ld	a0,24(s2)
    80004a84:	fffff097          	auipc	ra,0xfffff
    80004a88:	eb2080e7          	jalr	-334(ra) # 80003936 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a8c:	8756                	mv	a4,s5
    80004a8e:	02092683          	lw	a3,32(s2)
    80004a92:	01698633          	add	a2,s3,s6
    80004a96:	4585                	li	a1,1
    80004a98:	01893503          	ld	a0,24(s2)
    80004a9c:	fffff097          	auipc	ra,0xfffff
    80004aa0:	262080e7          	jalr	610(ra) # 80003cfe <writei>
    80004aa4:	84aa                	mv	s1,a0
    80004aa6:	00a05763          	blez	a0,80004ab4 <filewrite+0xc0>
        f->off += r;
    80004aaa:	02092783          	lw	a5,32(s2)
    80004aae:	9fa9                	addw	a5,a5,a0
    80004ab0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ab4:	01893503          	ld	a0,24(s2)
    80004ab8:	fffff097          	auipc	ra,0xfffff
    80004abc:	f44080e7          	jalr	-188(ra) # 800039fc <iunlock>
      end_op();
    80004ac0:	00000097          	auipc	ra,0x0
    80004ac4:	8be080e7          	jalr	-1858(ra) # 8000437e <end_op>

      if(r != n1){
    80004ac8:	029a9563          	bne	s5,s1,80004af2 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004acc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ad0:	0149da63          	bge	s3,s4,80004ae4 <filewrite+0xf0>
      int n1 = n - i;
    80004ad4:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004ad8:	0004879b          	sext.w	a5,s1
    80004adc:	f8fbdce3          	bge	s7,a5,80004a74 <filewrite+0x80>
    80004ae0:	84e2                	mv	s1,s8
    80004ae2:	bf49                	j	80004a74 <filewrite+0x80>
    80004ae4:	74e2                	ld	s1,56(sp)
    80004ae6:	6ae2                	ld	s5,24(sp)
    80004ae8:	6ba2                	ld	s7,8(sp)
    80004aea:	6c02                	ld	s8,0(sp)
    80004aec:	a039                	j	80004afa <filewrite+0x106>
    int i = 0;
    80004aee:	4981                	li	s3,0
    80004af0:	a029                	j	80004afa <filewrite+0x106>
    80004af2:	74e2                	ld	s1,56(sp)
    80004af4:	6ae2                	ld	s5,24(sp)
    80004af6:	6ba2                	ld	s7,8(sp)
    80004af8:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004afa:	033a1e63          	bne	s4,s3,80004b36 <filewrite+0x142>
    80004afe:	8552                	mv	a0,s4
    80004b00:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b02:	60a6                	ld	ra,72(sp)
    80004b04:	6406                	ld	s0,64(sp)
    80004b06:	7942                	ld	s2,48(sp)
    80004b08:	7a02                	ld	s4,32(sp)
    80004b0a:	6b42                	ld	s6,16(sp)
    80004b0c:	6161                	add	sp,sp,80
    80004b0e:	8082                	ret
    80004b10:	fc26                	sd	s1,56(sp)
    80004b12:	f44e                	sd	s3,40(sp)
    80004b14:	ec56                	sd	s5,24(sp)
    80004b16:	e45e                	sd	s7,8(sp)
    80004b18:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004b1a:	00004517          	auipc	a0,0x4
    80004b1e:	a8650513          	add	a0,a0,-1402 # 800085a0 <etext+0x5a0>
    80004b22:	ffffc097          	auipc	ra,0xffffc
    80004b26:	a3e080e7          	jalr	-1474(ra) # 80000560 <panic>
    return -1;
    80004b2a:	557d                	li	a0,-1
}
    80004b2c:	8082                	ret
      return -1;
    80004b2e:	557d                	li	a0,-1
    80004b30:	bfc9                	j	80004b02 <filewrite+0x10e>
    80004b32:	557d                	li	a0,-1
    80004b34:	b7f9                	j	80004b02 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004b36:	557d                	li	a0,-1
    80004b38:	79a2                	ld	s3,40(sp)
    80004b3a:	b7e1                	j	80004b02 <filewrite+0x10e>

0000000080004b3c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b3c:	7179                	add	sp,sp,-48
    80004b3e:	f406                	sd	ra,40(sp)
    80004b40:	f022                	sd	s0,32(sp)
    80004b42:	ec26                	sd	s1,24(sp)
    80004b44:	e052                	sd	s4,0(sp)
    80004b46:	1800                	add	s0,sp,48
    80004b48:	84aa                	mv	s1,a0
    80004b4a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b4c:	0005b023          	sd	zero,0(a1)
    80004b50:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b54:	00000097          	auipc	ra,0x0
    80004b58:	bbe080e7          	jalr	-1090(ra) # 80004712 <filealloc>
    80004b5c:	e088                	sd	a0,0(s1)
    80004b5e:	cd49                	beqz	a0,80004bf8 <pipealloc+0xbc>
    80004b60:	00000097          	auipc	ra,0x0
    80004b64:	bb2080e7          	jalr	-1102(ra) # 80004712 <filealloc>
    80004b68:	00aa3023          	sd	a0,0(s4)
    80004b6c:	c141                	beqz	a0,80004bec <pipealloc+0xb0>
    80004b6e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	fd8080e7          	jalr	-40(ra) # 80000b48 <kalloc>
    80004b78:	892a                	mv	s2,a0
    80004b7a:	c13d                	beqz	a0,80004be0 <pipealloc+0xa4>
    80004b7c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004b7e:	4985                	li	s3,1
    80004b80:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b84:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b88:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b8c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b90:	00004597          	auipc	a1,0x4
    80004b94:	a2058593          	add	a1,a1,-1504 # 800085b0 <etext+0x5b0>
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	010080e7          	jalr	16(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004ba0:	609c                	ld	a5,0(s1)
    80004ba2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ba6:	609c                	ld	a5,0(s1)
    80004ba8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bac:	609c                	ld	a5,0(s1)
    80004bae:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bb2:	609c                	ld	a5,0(s1)
    80004bb4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bb8:	000a3783          	ld	a5,0(s4)
    80004bbc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bc0:	000a3783          	ld	a5,0(s4)
    80004bc4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bc8:	000a3783          	ld	a5,0(s4)
    80004bcc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bd0:	000a3783          	ld	a5,0(s4)
    80004bd4:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bd8:	4501                	li	a0,0
    80004bda:	6942                	ld	s2,16(sp)
    80004bdc:	69a2                	ld	s3,8(sp)
    80004bde:	a03d                	j	80004c0c <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004be0:	6088                	ld	a0,0(s1)
    80004be2:	c119                	beqz	a0,80004be8 <pipealloc+0xac>
    80004be4:	6942                	ld	s2,16(sp)
    80004be6:	a029                	j	80004bf0 <pipealloc+0xb4>
    80004be8:	6942                	ld	s2,16(sp)
    80004bea:	a039                	j	80004bf8 <pipealloc+0xbc>
    80004bec:	6088                	ld	a0,0(s1)
    80004bee:	c50d                	beqz	a0,80004c18 <pipealloc+0xdc>
    fileclose(*f0);
    80004bf0:	00000097          	auipc	ra,0x0
    80004bf4:	bde080e7          	jalr	-1058(ra) # 800047ce <fileclose>
  if(*f1)
    80004bf8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bfc:	557d                	li	a0,-1
  if(*f1)
    80004bfe:	c799                	beqz	a5,80004c0c <pipealloc+0xd0>
    fileclose(*f1);
    80004c00:	853e                	mv	a0,a5
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	bcc080e7          	jalr	-1076(ra) # 800047ce <fileclose>
  return -1;
    80004c0a:	557d                	li	a0,-1
}
    80004c0c:	70a2                	ld	ra,40(sp)
    80004c0e:	7402                	ld	s0,32(sp)
    80004c10:	64e2                	ld	s1,24(sp)
    80004c12:	6a02                	ld	s4,0(sp)
    80004c14:	6145                	add	sp,sp,48
    80004c16:	8082                	ret
  return -1;
    80004c18:	557d                	li	a0,-1
    80004c1a:	bfcd                	j	80004c0c <pipealloc+0xd0>

0000000080004c1c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c1c:	1101                	add	sp,sp,-32
    80004c1e:	ec06                	sd	ra,24(sp)
    80004c20:	e822                	sd	s0,16(sp)
    80004c22:	e426                	sd	s1,8(sp)
    80004c24:	e04a                	sd	s2,0(sp)
    80004c26:	1000                	add	s0,sp,32
    80004c28:	84aa                	mv	s1,a0
    80004c2a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	00c080e7          	jalr	12(ra) # 80000c38 <acquire>
  if(writable){
    80004c34:	02090d63          	beqz	s2,80004c6e <pipeclose+0x52>
    pi->writeopen = 0;
    80004c38:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c3c:	21848513          	add	a0,s1,536
    80004c40:	ffffd097          	auipc	ra,0xffffd
    80004c44:	564080e7          	jalr	1380(ra) # 800021a4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c48:	2204b783          	ld	a5,544(s1)
    80004c4c:	eb95                	bnez	a5,80004c80 <pipeclose+0x64>
    release(&pi->lock);
    80004c4e:	8526                	mv	a0,s1
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	09c080e7          	jalr	156(ra) # 80000cec <release>
    kfree((char*)pi);
    80004c58:	8526                	mv	a0,s1
    80004c5a:	ffffc097          	auipc	ra,0xffffc
    80004c5e:	df0080e7          	jalr	-528(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004c62:	60e2                	ld	ra,24(sp)
    80004c64:	6442                	ld	s0,16(sp)
    80004c66:	64a2                	ld	s1,8(sp)
    80004c68:	6902                	ld	s2,0(sp)
    80004c6a:	6105                	add	sp,sp,32
    80004c6c:	8082                	ret
    pi->readopen = 0;
    80004c6e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c72:	21c48513          	add	a0,s1,540
    80004c76:	ffffd097          	auipc	ra,0xffffd
    80004c7a:	52e080e7          	jalr	1326(ra) # 800021a4 <wakeup>
    80004c7e:	b7e9                	j	80004c48 <pipeclose+0x2c>
    release(&pi->lock);
    80004c80:	8526                	mv	a0,s1
    80004c82:	ffffc097          	auipc	ra,0xffffc
    80004c86:	06a080e7          	jalr	106(ra) # 80000cec <release>
}
    80004c8a:	bfe1                	j	80004c62 <pipeclose+0x46>

0000000080004c8c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c8c:	711d                	add	sp,sp,-96
    80004c8e:	ec86                	sd	ra,88(sp)
    80004c90:	e8a2                	sd	s0,80(sp)
    80004c92:	e4a6                	sd	s1,72(sp)
    80004c94:	e0ca                	sd	s2,64(sp)
    80004c96:	fc4e                	sd	s3,56(sp)
    80004c98:	f852                	sd	s4,48(sp)
    80004c9a:	f456                	sd	s5,40(sp)
    80004c9c:	1080                	add	s0,sp,96
    80004c9e:	84aa                	mv	s1,a0
    80004ca0:	8aae                	mv	s5,a1
    80004ca2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ca4:	ffffd097          	auipc	ra,0xffffd
    80004ca8:	da6080e7          	jalr	-602(ra) # 80001a4a <myproc>
    80004cac:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004cae:	8526                	mv	a0,s1
    80004cb0:	ffffc097          	auipc	ra,0xffffc
    80004cb4:	f88080e7          	jalr	-120(ra) # 80000c38 <acquire>
  while(i < n){
    80004cb8:	0d405863          	blez	s4,80004d88 <pipewrite+0xfc>
    80004cbc:	f05a                	sd	s6,32(sp)
    80004cbe:	ec5e                	sd	s7,24(sp)
    80004cc0:	e862                	sd	s8,16(sp)
  int i = 0;
    80004cc2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cc4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cc6:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cca:	21c48b93          	add	s7,s1,540
    80004cce:	a089                	j	80004d10 <pipewrite+0x84>
      release(&pi->lock);
    80004cd0:	8526                	mv	a0,s1
    80004cd2:	ffffc097          	auipc	ra,0xffffc
    80004cd6:	01a080e7          	jalr	26(ra) # 80000cec <release>
      return -1;
    80004cda:	597d                	li	s2,-1
    80004cdc:	7b02                	ld	s6,32(sp)
    80004cde:	6be2                	ld	s7,24(sp)
    80004ce0:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ce2:	854a                	mv	a0,s2
    80004ce4:	60e6                	ld	ra,88(sp)
    80004ce6:	6446                	ld	s0,80(sp)
    80004ce8:	64a6                	ld	s1,72(sp)
    80004cea:	6906                	ld	s2,64(sp)
    80004cec:	79e2                	ld	s3,56(sp)
    80004cee:	7a42                	ld	s4,48(sp)
    80004cf0:	7aa2                	ld	s5,40(sp)
    80004cf2:	6125                	add	sp,sp,96
    80004cf4:	8082                	ret
      wakeup(&pi->nread);
    80004cf6:	8562                	mv	a0,s8
    80004cf8:	ffffd097          	auipc	ra,0xffffd
    80004cfc:	4ac080e7          	jalr	1196(ra) # 800021a4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d00:	85a6                	mv	a1,s1
    80004d02:	855e                	mv	a0,s7
    80004d04:	ffffd097          	auipc	ra,0xffffd
    80004d08:	43c080e7          	jalr	1084(ra) # 80002140 <sleep>
  while(i < n){
    80004d0c:	05495f63          	bge	s2,s4,80004d6a <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004d10:	2204a783          	lw	a5,544(s1)
    80004d14:	dfd5                	beqz	a5,80004cd0 <pipewrite+0x44>
    80004d16:	854e                	mv	a0,s3
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	6d0080e7          	jalr	1744(ra) # 800023e8 <killed>
    80004d20:	f945                	bnez	a0,80004cd0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d22:	2184a783          	lw	a5,536(s1)
    80004d26:	21c4a703          	lw	a4,540(s1)
    80004d2a:	2007879b          	addw	a5,a5,512
    80004d2e:	fcf704e3          	beq	a4,a5,80004cf6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d32:	4685                	li	a3,1
    80004d34:	01590633          	add	a2,s2,s5
    80004d38:	faf40593          	add	a1,s0,-81
    80004d3c:	0509b503          	ld	a0,80(s3)
    80004d40:	ffffd097          	auipc	ra,0xffffd
    80004d44:	a2e080e7          	jalr	-1490(ra) # 8000176e <copyin>
    80004d48:	05650263          	beq	a0,s6,80004d8c <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d4c:	21c4a783          	lw	a5,540(s1)
    80004d50:	0017871b          	addw	a4,a5,1
    80004d54:	20e4ae23          	sw	a4,540(s1)
    80004d58:	1ff7f793          	and	a5,a5,511
    80004d5c:	97a6                	add	a5,a5,s1
    80004d5e:	faf44703          	lbu	a4,-81(s0)
    80004d62:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d66:	2905                	addw	s2,s2,1
    80004d68:	b755                	j	80004d0c <pipewrite+0x80>
    80004d6a:	7b02                	ld	s6,32(sp)
    80004d6c:	6be2                	ld	s7,24(sp)
    80004d6e:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004d70:	21848513          	add	a0,s1,536
    80004d74:	ffffd097          	auipc	ra,0xffffd
    80004d78:	430080e7          	jalr	1072(ra) # 800021a4 <wakeup>
  release(&pi->lock);
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	ffffc097          	auipc	ra,0xffffc
    80004d82:	f6e080e7          	jalr	-146(ra) # 80000cec <release>
  return i;
    80004d86:	bfb1                	j	80004ce2 <pipewrite+0x56>
  int i = 0;
    80004d88:	4901                	li	s2,0
    80004d8a:	b7dd                	j	80004d70 <pipewrite+0xe4>
    80004d8c:	7b02                	ld	s6,32(sp)
    80004d8e:	6be2                	ld	s7,24(sp)
    80004d90:	6c42                	ld	s8,16(sp)
    80004d92:	bff9                	j	80004d70 <pipewrite+0xe4>

0000000080004d94 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d94:	715d                	add	sp,sp,-80
    80004d96:	e486                	sd	ra,72(sp)
    80004d98:	e0a2                	sd	s0,64(sp)
    80004d9a:	fc26                	sd	s1,56(sp)
    80004d9c:	f84a                	sd	s2,48(sp)
    80004d9e:	f44e                	sd	s3,40(sp)
    80004da0:	f052                	sd	s4,32(sp)
    80004da2:	ec56                	sd	s5,24(sp)
    80004da4:	0880                	add	s0,sp,80
    80004da6:	84aa                	mv	s1,a0
    80004da8:	892e                	mv	s2,a1
    80004daa:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dac:	ffffd097          	auipc	ra,0xffffd
    80004db0:	c9e080e7          	jalr	-866(ra) # 80001a4a <myproc>
    80004db4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004db6:	8526                	mv	a0,s1
    80004db8:	ffffc097          	auipc	ra,0xffffc
    80004dbc:	e80080e7          	jalr	-384(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc0:	2184a703          	lw	a4,536(s1)
    80004dc4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dc8:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dcc:	02f71963          	bne	a4,a5,80004dfe <piperead+0x6a>
    80004dd0:	2244a783          	lw	a5,548(s1)
    80004dd4:	cf95                	beqz	a5,80004e10 <piperead+0x7c>
    if(killed(pr)){
    80004dd6:	8552                	mv	a0,s4
    80004dd8:	ffffd097          	auipc	ra,0xffffd
    80004ddc:	610080e7          	jalr	1552(ra) # 800023e8 <killed>
    80004de0:	e10d                	bnez	a0,80004e02 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004de2:	85a6                	mv	a1,s1
    80004de4:	854e                	mv	a0,s3
    80004de6:	ffffd097          	auipc	ra,0xffffd
    80004dea:	35a080e7          	jalr	858(ra) # 80002140 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dee:	2184a703          	lw	a4,536(s1)
    80004df2:	21c4a783          	lw	a5,540(s1)
    80004df6:	fcf70de3          	beq	a4,a5,80004dd0 <piperead+0x3c>
    80004dfa:	e85a                	sd	s6,16(sp)
    80004dfc:	a819                	j	80004e12 <piperead+0x7e>
    80004dfe:	e85a                	sd	s6,16(sp)
    80004e00:	a809                	j	80004e12 <piperead+0x7e>
      release(&pi->lock);
    80004e02:	8526                	mv	a0,s1
    80004e04:	ffffc097          	auipc	ra,0xffffc
    80004e08:	ee8080e7          	jalr	-280(ra) # 80000cec <release>
      return -1;
    80004e0c:	59fd                	li	s3,-1
    80004e0e:	a0a5                	j	80004e76 <piperead+0xe2>
    80004e10:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e12:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e14:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e16:	05505463          	blez	s5,80004e5e <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004e1a:	2184a783          	lw	a5,536(s1)
    80004e1e:	21c4a703          	lw	a4,540(s1)
    80004e22:	02f70e63          	beq	a4,a5,80004e5e <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e26:	0017871b          	addw	a4,a5,1
    80004e2a:	20e4ac23          	sw	a4,536(s1)
    80004e2e:	1ff7f793          	and	a5,a5,511
    80004e32:	97a6                	add	a5,a5,s1
    80004e34:	0187c783          	lbu	a5,24(a5)
    80004e38:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e3c:	4685                	li	a3,1
    80004e3e:	fbf40613          	add	a2,s0,-65
    80004e42:	85ca                	mv	a1,s2
    80004e44:	050a3503          	ld	a0,80(s4)
    80004e48:	ffffd097          	auipc	ra,0xffffd
    80004e4c:	89a080e7          	jalr	-1894(ra) # 800016e2 <copyout>
    80004e50:	01650763          	beq	a0,s6,80004e5e <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e54:	2985                	addw	s3,s3,1
    80004e56:	0905                	add	s2,s2,1
    80004e58:	fd3a91e3          	bne	s5,s3,80004e1a <piperead+0x86>
    80004e5c:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e5e:	21c48513          	add	a0,s1,540
    80004e62:	ffffd097          	auipc	ra,0xffffd
    80004e66:	342080e7          	jalr	834(ra) # 800021a4 <wakeup>
  release(&pi->lock);
    80004e6a:	8526                	mv	a0,s1
    80004e6c:	ffffc097          	auipc	ra,0xffffc
    80004e70:	e80080e7          	jalr	-384(ra) # 80000cec <release>
    80004e74:	6b42                	ld	s6,16(sp)
  return i;
}
    80004e76:	854e                	mv	a0,s3
    80004e78:	60a6                	ld	ra,72(sp)
    80004e7a:	6406                	ld	s0,64(sp)
    80004e7c:	74e2                	ld	s1,56(sp)
    80004e7e:	7942                	ld	s2,48(sp)
    80004e80:	79a2                	ld	s3,40(sp)
    80004e82:	7a02                	ld	s4,32(sp)
    80004e84:	6ae2                	ld	s5,24(sp)
    80004e86:	6161                	add	sp,sp,80
    80004e88:	8082                	ret

0000000080004e8a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e8a:	1141                	add	sp,sp,-16
    80004e8c:	e422                	sd	s0,8(sp)
    80004e8e:	0800                	add	s0,sp,16
    80004e90:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e92:	8905                	and	a0,a0,1
    80004e94:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004e96:	8b89                	and	a5,a5,2
    80004e98:	c399                	beqz	a5,80004e9e <flags2perm+0x14>
      perm |= PTE_W;
    80004e9a:	00456513          	or	a0,a0,4
    return perm;
}
    80004e9e:	6422                	ld	s0,8(sp)
    80004ea0:	0141                	add	sp,sp,16
    80004ea2:	8082                	ret

0000000080004ea4 <exec>:

int
exec(char *path, char **argv)
{
    80004ea4:	df010113          	add	sp,sp,-528
    80004ea8:	20113423          	sd	ra,520(sp)
    80004eac:	20813023          	sd	s0,512(sp)
    80004eb0:	ffa6                	sd	s1,504(sp)
    80004eb2:	fbca                	sd	s2,496(sp)
    80004eb4:	0c00                	add	s0,sp,528
    80004eb6:	892a                	mv	s2,a0
    80004eb8:	dea43c23          	sd	a0,-520(s0)
    80004ebc:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ec0:	ffffd097          	auipc	ra,0xffffd
    80004ec4:	b8a080e7          	jalr	-1142(ra) # 80001a4a <myproc>
    80004ec8:	84aa                	mv	s1,a0

  begin_op();
    80004eca:	fffff097          	auipc	ra,0xfffff
    80004ece:	43a080e7          	jalr	1082(ra) # 80004304 <begin_op>

  if((ip = namei(path)) == 0){
    80004ed2:	854a                	mv	a0,s2
    80004ed4:	fffff097          	auipc	ra,0xfffff
    80004ed8:	230080e7          	jalr	560(ra) # 80004104 <namei>
    80004edc:	c135                	beqz	a0,80004f40 <exec+0x9c>
    80004ede:	f3d2                	sd	s4,480(sp)
    80004ee0:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ee2:	fffff097          	auipc	ra,0xfffff
    80004ee6:	a54080e7          	jalr	-1452(ra) # 80003936 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004eea:	04000713          	li	a4,64
    80004eee:	4681                	li	a3,0
    80004ef0:	e5040613          	add	a2,s0,-432
    80004ef4:	4581                	li	a1,0
    80004ef6:	8552                	mv	a0,s4
    80004ef8:	fffff097          	auipc	ra,0xfffff
    80004efc:	cf6080e7          	jalr	-778(ra) # 80003bee <readi>
    80004f00:	04000793          	li	a5,64
    80004f04:	00f51a63          	bne	a0,a5,80004f18 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f08:	e5042703          	lw	a4,-432(s0)
    80004f0c:	464c47b7          	lui	a5,0x464c4
    80004f10:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f14:	02f70c63          	beq	a4,a5,80004f4c <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f18:	8552                	mv	a0,s4
    80004f1a:	fffff097          	auipc	ra,0xfffff
    80004f1e:	c82080e7          	jalr	-894(ra) # 80003b9c <iunlockput>
    end_op();
    80004f22:	fffff097          	auipc	ra,0xfffff
    80004f26:	45c080e7          	jalr	1116(ra) # 8000437e <end_op>
  }
  return -1;
    80004f2a:	557d                	li	a0,-1
    80004f2c:	7a1e                	ld	s4,480(sp)
}
    80004f2e:	20813083          	ld	ra,520(sp)
    80004f32:	20013403          	ld	s0,512(sp)
    80004f36:	74fe                	ld	s1,504(sp)
    80004f38:	795e                	ld	s2,496(sp)
    80004f3a:	21010113          	add	sp,sp,528
    80004f3e:	8082                	ret
    end_op();
    80004f40:	fffff097          	auipc	ra,0xfffff
    80004f44:	43e080e7          	jalr	1086(ra) # 8000437e <end_op>
    return -1;
    80004f48:	557d                	li	a0,-1
    80004f4a:	b7d5                	j	80004f2e <exec+0x8a>
    80004f4c:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004f4e:	8526                	mv	a0,s1
    80004f50:	ffffd097          	auipc	ra,0xffffd
    80004f54:	bbe080e7          	jalr	-1090(ra) # 80001b0e <proc_pagetable>
    80004f58:	8b2a                	mv	s6,a0
    80004f5a:	30050f63          	beqz	a0,80005278 <exec+0x3d4>
    80004f5e:	f7ce                	sd	s3,488(sp)
    80004f60:	efd6                	sd	s5,472(sp)
    80004f62:	e7de                	sd	s7,456(sp)
    80004f64:	e3e2                	sd	s8,448(sp)
    80004f66:	ff66                	sd	s9,440(sp)
    80004f68:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f6a:	e7042d03          	lw	s10,-400(s0)
    80004f6e:	e8845783          	lhu	a5,-376(s0)
    80004f72:	14078d63          	beqz	a5,800050cc <exec+0x228>
    80004f76:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f78:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f7a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004f7c:	6c85                	lui	s9,0x1
    80004f7e:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f82:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f86:	6a85                	lui	s5,0x1
    80004f88:	a0b5                	j	80004ff4 <exec+0x150>
      panic("loadseg: address should exist");
    80004f8a:	00003517          	auipc	a0,0x3
    80004f8e:	62e50513          	add	a0,a0,1582 # 800085b8 <etext+0x5b8>
    80004f92:	ffffb097          	auipc	ra,0xffffb
    80004f96:	5ce080e7          	jalr	1486(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80004f9a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f9c:	8726                	mv	a4,s1
    80004f9e:	012c06bb          	addw	a3,s8,s2
    80004fa2:	4581                	li	a1,0
    80004fa4:	8552                	mv	a0,s4
    80004fa6:	fffff097          	auipc	ra,0xfffff
    80004faa:	c48080e7          	jalr	-952(ra) # 80003bee <readi>
    80004fae:	2501                	sext.w	a0,a0
    80004fb0:	28a49863          	bne	s1,a0,80005240 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80004fb4:	012a893b          	addw	s2,s5,s2
    80004fb8:	03397563          	bgeu	s2,s3,80004fe2 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004fbc:	02091593          	sll	a1,s2,0x20
    80004fc0:	9181                	srl	a1,a1,0x20
    80004fc2:	95de                	add	a1,a1,s7
    80004fc4:	855a                	mv	a0,s6
    80004fc6:	ffffc097          	auipc	ra,0xffffc
    80004fca:	0f0080e7          	jalr	240(ra) # 800010b6 <walkaddr>
    80004fce:	862a                	mv	a2,a0
    if(pa == 0)
    80004fd0:	dd4d                	beqz	a0,80004f8a <exec+0xe6>
    if(sz - i < PGSIZE)
    80004fd2:	412984bb          	subw	s1,s3,s2
    80004fd6:	0004879b          	sext.w	a5,s1
    80004fda:	fcfcf0e3          	bgeu	s9,a5,80004f9a <exec+0xf6>
    80004fde:	84d6                	mv	s1,s5
    80004fe0:	bf6d                	j	80004f9a <exec+0xf6>
    sz = sz1;
    80004fe2:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fe6:	2d85                	addw	s11,s11,1
    80004fe8:	038d0d1b          	addw	s10,s10,56
    80004fec:	e8845783          	lhu	a5,-376(s0)
    80004ff0:	08fdd663          	bge	s11,a5,8000507c <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ff4:	2d01                	sext.w	s10,s10
    80004ff6:	03800713          	li	a4,56
    80004ffa:	86ea                	mv	a3,s10
    80004ffc:	e1840613          	add	a2,s0,-488
    80005000:	4581                	li	a1,0
    80005002:	8552                	mv	a0,s4
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	bea080e7          	jalr	-1046(ra) # 80003bee <readi>
    8000500c:	03800793          	li	a5,56
    80005010:	20f51063          	bne	a0,a5,80005210 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80005014:	e1842783          	lw	a5,-488(s0)
    80005018:	4705                	li	a4,1
    8000501a:	fce796e3          	bne	a5,a4,80004fe6 <exec+0x142>
    if(ph.memsz < ph.filesz)
    8000501e:	e4043483          	ld	s1,-448(s0)
    80005022:	e3843783          	ld	a5,-456(s0)
    80005026:	1ef4e963          	bltu	s1,a5,80005218 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000502a:	e2843783          	ld	a5,-472(s0)
    8000502e:	94be                	add	s1,s1,a5
    80005030:	1ef4e863          	bltu	s1,a5,80005220 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    80005034:	df043703          	ld	a4,-528(s0)
    80005038:	8ff9                	and	a5,a5,a4
    8000503a:	1e079763          	bnez	a5,80005228 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000503e:	e1c42503          	lw	a0,-484(s0)
    80005042:	00000097          	auipc	ra,0x0
    80005046:	e48080e7          	jalr	-440(ra) # 80004e8a <flags2perm>
    8000504a:	86aa                	mv	a3,a0
    8000504c:	8626                	mv	a2,s1
    8000504e:	85ca                	mv	a1,s2
    80005050:	855a                	mv	a0,s6
    80005052:	ffffc097          	auipc	ra,0xffffc
    80005056:	428080e7          	jalr	1064(ra) # 8000147a <uvmalloc>
    8000505a:	e0a43423          	sd	a0,-504(s0)
    8000505e:	1c050963          	beqz	a0,80005230 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005062:	e2843b83          	ld	s7,-472(s0)
    80005066:	e2042c03          	lw	s8,-480(s0)
    8000506a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000506e:	00098463          	beqz	s3,80005076 <exec+0x1d2>
    80005072:	4901                	li	s2,0
    80005074:	b7a1                	j	80004fbc <exec+0x118>
    sz = sz1;
    80005076:	e0843903          	ld	s2,-504(s0)
    8000507a:	b7b5                	j	80004fe6 <exec+0x142>
    8000507c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    8000507e:	8552                	mv	a0,s4
    80005080:	fffff097          	auipc	ra,0xfffff
    80005084:	b1c080e7          	jalr	-1252(ra) # 80003b9c <iunlockput>
  end_op();
    80005088:	fffff097          	auipc	ra,0xfffff
    8000508c:	2f6080e7          	jalr	758(ra) # 8000437e <end_op>
  p = myproc();
    80005090:	ffffd097          	auipc	ra,0xffffd
    80005094:	9ba080e7          	jalr	-1606(ra) # 80001a4a <myproc>
    80005098:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000509a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    8000509e:	6985                	lui	s3,0x1
    800050a0:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    800050a2:	99ca                	add	s3,s3,s2
    800050a4:	77fd                	lui	a5,0xfffff
    800050a6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050aa:	4691                	li	a3,4
    800050ac:	6609                	lui	a2,0x2
    800050ae:	964e                	add	a2,a2,s3
    800050b0:	85ce                	mv	a1,s3
    800050b2:	855a                	mv	a0,s6
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	3c6080e7          	jalr	966(ra) # 8000147a <uvmalloc>
    800050bc:	892a                	mv	s2,a0
    800050be:	e0a43423          	sd	a0,-504(s0)
    800050c2:	e519                	bnez	a0,800050d0 <exec+0x22c>
  if(pagetable)
    800050c4:	e1343423          	sd	s3,-504(s0)
    800050c8:	4a01                	li	s4,0
    800050ca:	aaa5                	j	80005242 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050cc:	4901                	li	s2,0
    800050ce:	bf45                	j	8000507e <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050d0:	75f9                	lui	a1,0xffffe
    800050d2:	95aa                	add	a1,a1,a0
    800050d4:	855a                	mv	a0,s6
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	5da080e7          	jalr	1498(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    800050de:	7bfd                	lui	s7,0xfffff
    800050e0:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800050e2:	e0043783          	ld	a5,-512(s0)
    800050e6:	6388                	ld	a0,0(a5)
    800050e8:	c52d                	beqz	a0,80005152 <exec+0x2ae>
    800050ea:	e9040993          	add	s3,s0,-368
    800050ee:	f9040c13          	add	s8,s0,-112
    800050f2:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050f4:	ffffc097          	auipc	ra,0xffffc
    800050f8:	db4080e7          	jalr	-588(ra) # 80000ea8 <strlen>
    800050fc:	0015079b          	addw	a5,a0,1
    80005100:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005104:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80005108:	13796863          	bltu	s2,s7,80005238 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000510c:	e0043d03          	ld	s10,-512(s0)
    80005110:	000d3a03          	ld	s4,0(s10)
    80005114:	8552                	mv	a0,s4
    80005116:	ffffc097          	auipc	ra,0xffffc
    8000511a:	d92080e7          	jalr	-622(ra) # 80000ea8 <strlen>
    8000511e:	0015069b          	addw	a3,a0,1
    80005122:	8652                	mv	a2,s4
    80005124:	85ca                	mv	a1,s2
    80005126:	855a                	mv	a0,s6
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	5ba080e7          	jalr	1466(ra) # 800016e2 <copyout>
    80005130:	10054663          	bltz	a0,8000523c <exec+0x398>
    ustack[argc] = sp;
    80005134:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005138:	0485                	add	s1,s1,1
    8000513a:	008d0793          	add	a5,s10,8
    8000513e:	e0f43023          	sd	a5,-512(s0)
    80005142:	008d3503          	ld	a0,8(s10)
    80005146:	c909                	beqz	a0,80005158 <exec+0x2b4>
    if(argc >= MAXARG)
    80005148:	09a1                	add	s3,s3,8
    8000514a:	fb8995e3          	bne	s3,s8,800050f4 <exec+0x250>
  ip = 0;
    8000514e:	4a01                	li	s4,0
    80005150:	a8cd                	j	80005242 <exec+0x39e>
  sp = sz;
    80005152:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005156:	4481                	li	s1,0
  ustack[argc] = 0;
    80005158:	00349793          	sll	a5,s1,0x3
    8000515c:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd240>
    80005160:	97a2                	add	a5,a5,s0
    80005162:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005166:	00148693          	add	a3,s1,1
    8000516a:	068e                	sll	a3,a3,0x3
    8000516c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005170:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80005174:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005178:	f57966e3          	bltu	s2,s7,800050c4 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000517c:	e9040613          	add	a2,s0,-368
    80005180:	85ca                	mv	a1,s2
    80005182:	855a                	mv	a0,s6
    80005184:	ffffc097          	auipc	ra,0xffffc
    80005188:	55e080e7          	jalr	1374(ra) # 800016e2 <copyout>
    8000518c:	0e054863          	bltz	a0,8000527c <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005190:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005194:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005198:	df843783          	ld	a5,-520(s0)
    8000519c:	0007c703          	lbu	a4,0(a5)
    800051a0:	cf11                	beqz	a4,800051bc <exec+0x318>
    800051a2:	0785                	add	a5,a5,1
    if(*s == '/')
    800051a4:	02f00693          	li	a3,47
    800051a8:	a039                	j	800051b6 <exec+0x312>
      last = s+1;
    800051aa:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800051ae:	0785                	add	a5,a5,1
    800051b0:	fff7c703          	lbu	a4,-1(a5)
    800051b4:	c701                	beqz	a4,800051bc <exec+0x318>
    if(*s == '/')
    800051b6:	fed71ce3          	bne	a4,a3,800051ae <exec+0x30a>
    800051ba:	bfc5                	j	800051aa <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    800051bc:	4641                	li	a2,16
    800051be:	df843583          	ld	a1,-520(s0)
    800051c2:	158a8513          	add	a0,s5,344
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	cb0080e7          	jalr	-848(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    800051ce:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800051d2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800051d6:	e0843783          	ld	a5,-504(s0)
    800051da:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051de:	058ab783          	ld	a5,88(s5)
    800051e2:	e6843703          	ld	a4,-408(s0)
    800051e6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051e8:	058ab783          	ld	a5,88(s5)
    800051ec:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051f0:	85e6                	mv	a1,s9
    800051f2:	ffffd097          	auipc	ra,0xffffd
    800051f6:	9b8080e7          	jalr	-1608(ra) # 80001baa <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051fa:	0004851b          	sext.w	a0,s1
    800051fe:	79be                	ld	s3,488(sp)
    80005200:	7a1e                	ld	s4,480(sp)
    80005202:	6afe                	ld	s5,472(sp)
    80005204:	6b5e                	ld	s6,464(sp)
    80005206:	6bbe                	ld	s7,456(sp)
    80005208:	6c1e                	ld	s8,448(sp)
    8000520a:	7cfa                	ld	s9,440(sp)
    8000520c:	7d5a                	ld	s10,432(sp)
    8000520e:	b305                	j	80004f2e <exec+0x8a>
    80005210:	e1243423          	sd	s2,-504(s0)
    80005214:	7dba                	ld	s11,424(sp)
    80005216:	a035                	j	80005242 <exec+0x39e>
    80005218:	e1243423          	sd	s2,-504(s0)
    8000521c:	7dba                	ld	s11,424(sp)
    8000521e:	a015                	j	80005242 <exec+0x39e>
    80005220:	e1243423          	sd	s2,-504(s0)
    80005224:	7dba                	ld	s11,424(sp)
    80005226:	a831                	j	80005242 <exec+0x39e>
    80005228:	e1243423          	sd	s2,-504(s0)
    8000522c:	7dba                	ld	s11,424(sp)
    8000522e:	a811                	j	80005242 <exec+0x39e>
    80005230:	e1243423          	sd	s2,-504(s0)
    80005234:	7dba                	ld	s11,424(sp)
    80005236:	a031                	j	80005242 <exec+0x39e>
  ip = 0;
    80005238:	4a01                	li	s4,0
    8000523a:	a021                	j	80005242 <exec+0x39e>
    8000523c:	4a01                	li	s4,0
  if(pagetable)
    8000523e:	a011                	j	80005242 <exec+0x39e>
    80005240:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005242:	e0843583          	ld	a1,-504(s0)
    80005246:	855a                	mv	a0,s6
    80005248:	ffffd097          	auipc	ra,0xffffd
    8000524c:	962080e7          	jalr	-1694(ra) # 80001baa <proc_freepagetable>
  return -1;
    80005250:	557d                	li	a0,-1
  if(ip){
    80005252:	000a1b63          	bnez	s4,80005268 <exec+0x3c4>
    80005256:	79be                	ld	s3,488(sp)
    80005258:	7a1e                	ld	s4,480(sp)
    8000525a:	6afe                	ld	s5,472(sp)
    8000525c:	6b5e                	ld	s6,464(sp)
    8000525e:	6bbe                	ld	s7,456(sp)
    80005260:	6c1e                	ld	s8,448(sp)
    80005262:	7cfa                	ld	s9,440(sp)
    80005264:	7d5a                	ld	s10,432(sp)
    80005266:	b1e1                	j	80004f2e <exec+0x8a>
    80005268:	79be                	ld	s3,488(sp)
    8000526a:	6afe                	ld	s5,472(sp)
    8000526c:	6b5e                	ld	s6,464(sp)
    8000526e:	6bbe                	ld	s7,456(sp)
    80005270:	6c1e                	ld	s8,448(sp)
    80005272:	7cfa                	ld	s9,440(sp)
    80005274:	7d5a                	ld	s10,432(sp)
    80005276:	b14d                	j	80004f18 <exec+0x74>
    80005278:	6b5e                	ld	s6,464(sp)
    8000527a:	b979                	j	80004f18 <exec+0x74>
  sz = sz1;
    8000527c:	e0843983          	ld	s3,-504(s0)
    80005280:	b591                	j	800050c4 <exec+0x220>

0000000080005282 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005282:	7179                	add	sp,sp,-48
    80005284:	f406                	sd	ra,40(sp)
    80005286:	f022                	sd	s0,32(sp)
    80005288:	ec26                	sd	s1,24(sp)
    8000528a:	e84a                	sd	s2,16(sp)
    8000528c:	1800                	add	s0,sp,48
    8000528e:	892e                	mv	s2,a1
    80005290:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005292:	fdc40593          	add	a1,s0,-36
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	a38080e7          	jalr	-1480(ra) # 80002cce <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000529e:	fdc42703          	lw	a4,-36(s0)
    800052a2:	47bd                	li	a5,15
    800052a4:	02e7eb63          	bltu	a5,a4,800052da <argfd+0x58>
    800052a8:	ffffc097          	auipc	ra,0xffffc
    800052ac:	7a2080e7          	jalr	1954(ra) # 80001a4a <myproc>
    800052b0:	fdc42703          	lw	a4,-36(s0)
    800052b4:	01a70793          	add	a5,a4,26
    800052b8:	078e                	sll	a5,a5,0x3
    800052ba:	953e                	add	a0,a0,a5
    800052bc:	611c                	ld	a5,0(a0)
    800052be:	c385                	beqz	a5,800052de <argfd+0x5c>
    return -1;
  if(pfd)
    800052c0:	00090463          	beqz	s2,800052c8 <argfd+0x46>
    *pfd = fd;
    800052c4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052c8:	4501                	li	a0,0
  if(pf)
    800052ca:	c091                	beqz	s1,800052ce <argfd+0x4c>
    *pf = f;
    800052cc:	e09c                	sd	a5,0(s1)
}
    800052ce:	70a2                	ld	ra,40(sp)
    800052d0:	7402                	ld	s0,32(sp)
    800052d2:	64e2                	ld	s1,24(sp)
    800052d4:	6942                	ld	s2,16(sp)
    800052d6:	6145                	add	sp,sp,48
    800052d8:	8082                	ret
    return -1;
    800052da:	557d                	li	a0,-1
    800052dc:	bfcd                	j	800052ce <argfd+0x4c>
    800052de:	557d                	li	a0,-1
    800052e0:	b7fd                	j	800052ce <argfd+0x4c>

00000000800052e2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052e2:	1101                	add	sp,sp,-32
    800052e4:	ec06                	sd	ra,24(sp)
    800052e6:	e822                	sd	s0,16(sp)
    800052e8:	e426                	sd	s1,8(sp)
    800052ea:	1000                	add	s0,sp,32
    800052ec:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052ee:	ffffc097          	auipc	ra,0xffffc
    800052f2:	75c080e7          	jalr	1884(ra) # 80001a4a <myproc>
    800052f6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052f8:	0d050793          	add	a5,a0,208
    800052fc:	4501                	li	a0,0
    800052fe:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005300:	6398                	ld	a4,0(a5)
    80005302:	cb19                	beqz	a4,80005318 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005304:	2505                	addw	a0,a0,1
    80005306:	07a1                	add	a5,a5,8
    80005308:	fed51ce3          	bne	a0,a3,80005300 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000530c:	557d                	li	a0,-1
}
    8000530e:	60e2                	ld	ra,24(sp)
    80005310:	6442                	ld	s0,16(sp)
    80005312:	64a2                	ld	s1,8(sp)
    80005314:	6105                	add	sp,sp,32
    80005316:	8082                	ret
      p->ofile[fd] = f;
    80005318:	01a50793          	add	a5,a0,26
    8000531c:	078e                	sll	a5,a5,0x3
    8000531e:	963e                	add	a2,a2,a5
    80005320:	e204                	sd	s1,0(a2)
      return fd;
    80005322:	b7f5                	j	8000530e <fdalloc+0x2c>

0000000080005324 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005324:	715d                	add	sp,sp,-80
    80005326:	e486                	sd	ra,72(sp)
    80005328:	e0a2                	sd	s0,64(sp)
    8000532a:	fc26                	sd	s1,56(sp)
    8000532c:	f84a                	sd	s2,48(sp)
    8000532e:	f44e                	sd	s3,40(sp)
    80005330:	ec56                	sd	s5,24(sp)
    80005332:	e85a                	sd	s6,16(sp)
    80005334:	0880                	add	s0,sp,80
    80005336:	8b2e                	mv	s6,a1
    80005338:	89b2                	mv	s3,a2
    8000533a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000533c:	fb040593          	add	a1,s0,-80
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	de2080e7          	jalr	-542(ra) # 80004122 <nameiparent>
    80005348:	84aa                	mv	s1,a0
    8000534a:	14050e63          	beqz	a0,800054a6 <create+0x182>
    return 0;

  ilock(dp);
    8000534e:	ffffe097          	auipc	ra,0xffffe
    80005352:	5e8080e7          	jalr	1512(ra) # 80003936 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005356:	4601                	li	a2,0
    80005358:	fb040593          	add	a1,s0,-80
    8000535c:	8526                	mv	a0,s1
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	ae4080e7          	jalr	-1308(ra) # 80003e42 <dirlookup>
    80005366:	8aaa                	mv	s5,a0
    80005368:	c539                	beqz	a0,800053b6 <create+0x92>
    iunlockput(dp);
    8000536a:	8526                	mv	a0,s1
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	830080e7          	jalr	-2000(ra) # 80003b9c <iunlockput>
    ilock(ip);
    80005374:	8556                	mv	a0,s5
    80005376:	ffffe097          	auipc	ra,0xffffe
    8000537a:	5c0080e7          	jalr	1472(ra) # 80003936 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000537e:	4789                	li	a5,2
    80005380:	02fb1463          	bne	s6,a5,800053a8 <create+0x84>
    80005384:	044ad783          	lhu	a5,68(s5)
    80005388:	37f9                	addw	a5,a5,-2
    8000538a:	17c2                	sll	a5,a5,0x30
    8000538c:	93c1                	srl	a5,a5,0x30
    8000538e:	4705                	li	a4,1
    80005390:	00f76c63          	bltu	a4,a5,800053a8 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005394:	8556                	mv	a0,s5
    80005396:	60a6                	ld	ra,72(sp)
    80005398:	6406                	ld	s0,64(sp)
    8000539a:	74e2                	ld	s1,56(sp)
    8000539c:	7942                	ld	s2,48(sp)
    8000539e:	79a2                	ld	s3,40(sp)
    800053a0:	6ae2                	ld	s5,24(sp)
    800053a2:	6b42                	ld	s6,16(sp)
    800053a4:	6161                	add	sp,sp,80
    800053a6:	8082                	ret
    iunlockput(ip);
    800053a8:	8556                	mv	a0,s5
    800053aa:	ffffe097          	auipc	ra,0xffffe
    800053ae:	7f2080e7          	jalr	2034(ra) # 80003b9c <iunlockput>
    return 0;
    800053b2:	4a81                	li	s5,0
    800053b4:	b7c5                	j	80005394 <create+0x70>
    800053b6:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800053b8:	85da                	mv	a1,s6
    800053ba:	4088                	lw	a0,0(s1)
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	3d6080e7          	jalr	982(ra) # 80003792 <ialloc>
    800053c4:	8a2a                	mv	s4,a0
    800053c6:	c531                	beqz	a0,80005412 <create+0xee>
  ilock(ip);
    800053c8:	ffffe097          	auipc	ra,0xffffe
    800053cc:	56e080e7          	jalr	1390(ra) # 80003936 <ilock>
  ip->major = major;
    800053d0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053d4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053d8:	4905                	li	s2,1
    800053da:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053de:	8552                	mv	a0,s4
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	48a080e7          	jalr	1162(ra) # 8000386a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053e8:	032b0d63          	beq	s6,s2,80005422 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800053ec:	004a2603          	lw	a2,4(s4)
    800053f0:	fb040593          	add	a1,s0,-80
    800053f4:	8526                	mv	a0,s1
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	c5c080e7          	jalr	-932(ra) # 80004052 <dirlink>
    800053fe:	08054163          	bltz	a0,80005480 <create+0x15c>
  iunlockput(dp);
    80005402:	8526                	mv	a0,s1
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	798080e7          	jalr	1944(ra) # 80003b9c <iunlockput>
  return ip;
    8000540c:	8ad2                	mv	s5,s4
    8000540e:	7a02                	ld	s4,32(sp)
    80005410:	b751                	j	80005394 <create+0x70>
    iunlockput(dp);
    80005412:	8526                	mv	a0,s1
    80005414:	ffffe097          	auipc	ra,0xffffe
    80005418:	788080e7          	jalr	1928(ra) # 80003b9c <iunlockput>
    return 0;
    8000541c:	8ad2                	mv	s5,s4
    8000541e:	7a02                	ld	s4,32(sp)
    80005420:	bf95                	j	80005394 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005422:	004a2603          	lw	a2,4(s4)
    80005426:	00003597          	auipc	a1,0x3
    8000542a:	1b258593          	add	a1,a1,434 # 800085d8 <etext+0x5d8>
    8000542e:	8552                	mv	a0,s4
    80005430:	fffff097          	auipc	ra,0xfffff
    80005434:	c22080e7          	jalr	-990(ra) # 80004052 <dirlink>
    80005438:	04054463          	bltz	a0,80005480 <create+0x15c>
    8000543c:	40d0                	lw	a2,4(s1)
    8000543e:	00003597          	auipc	a1,0x3
    80005442:	1a258593          	add	a1,a1,418 # 800085e0 <etext+0x5e0>
    80005446:	8552                	mv	a0,s4
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	c0a080e7          	jalr	-1014(ra) # 80004052 <dirlink>
    80005450:	02054863          	bltz	a0,80005480 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005454:	004a2603          	lw	a2,4(s4)
    80005458:	fb040593          	add	a1,s0,-80
    8000545c:	8526                	mv	a0,s1
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	bf4080e7          	jalr	-1036(ra) # 80004052 <dirlink>
    80005466:	00054d63          	bltz	a0,80005480 <create+0x15c>
    dp->nlink++;  // for ".."
    8000546a:	04a4d783          	lhu	a5,74(s1)
    8000546e:	2785                	addw	a5,a5,1
    80005470:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005474:	8526                	mv	a0,s1
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	3f4080e7          	jalr	1012(ra) # 8000386a <iupdate>
    8000547e:	b751                	j	80005402 <create+0xde>
  ip->nlink = 0;
    80005480:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005484:	8552                	mv	a0,s4
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	3e4080e7          	jalr	996(ra) # 8000386a <iupdate>
  iunlockput(ip);
    8000548e:	8552                	mv	a0,s4
    80005490:	ffffe097          	auipc	ra,0xffffe
    80005494:	70c080e7          	jalr	1804(ra) # 80003b9c <iunlockput>
  iunlockput(dp);
    80005498:	8526                	mv	a0,s1
    8000549a:	ffffe097          	auipc	ra,0xffffe
    8000549e:	702080e7          	jalr	1794(ra) # 80003b9c <iunlockput>
  return 0;
    800054a2:	7a02                	ld	s4,32(sp)
    800054a4:	bdc5                	j	80005394 <create+0x70>
    return 0;
    800054a6:	8aaa                	mv	s5,a0
    800054a8:	b5f5                	j	80005394 <create+0x70>

00000000800054aa <sys_dup>:
{
    800054aa:	7179                	add	sp,sp,-48
    800054ac:	f406                	sd	ra,40(sp)
    800054ae:	f022                	sd	s0,32(sp)
    800054b0:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054b2:	fd840613          	add	a2,s0,-40
    800054b6:	4581                	li	a1,0
    800054b8:	4501                	li	a0,0
    800054ba:	00000097          	auipc	ra,0x0
    800054be:	dc8080e7          	jalr	-568(ra) # 80005282 <argfd>
    return -1;
    800054c2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054c4:	02054763          	bltz	a0,800054f2 <sys_dup+0x48>
    800054c8:	ec26                	sd	s1,24(sp)
    800054ca:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800054cc:	fd843903          	ld	s2,-40(s0)
    800054d0:	854a                	mv	a0,s2
    800054d2:	00000097          	auipc	ra,0x0
    800054d6:	e10080e7          	jalr	-496(ra) # 800052e2 <fdalloc>
    800054da:	84aa                	mv	s1,a0
    return -1;
    800054dc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054de:	00054f63          	bltz	a0,800054fc <sys_dup+0x52>
  filedup(f);
    800054e2:	854a                	mv	a0,s2
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	298080e7          	jalr	664(ra) # 8000477c <filedup>
  return fd;
    800054ec:	87a6                	mv	a5,s1
    800054ee:	64e2                	ld	s1,24(sp)
    800054f0:	6942                	ld	s2,16(sp)
}
    800054f2:	853e                	mv	a0,a5
    800054f4:	70a2                	ld	ra,40(sp)
    800054f6:	7402                	ld	s0,32(sp)
    800054f8:	6145                	add	sp,sp,48
    800054fa:	8082                	ret
    800054fc:	64e2                	ld	s1,24(sp)
    800054fe:	6942                	ld	s2,16(sp)
    80005500:	bfcd                	j	800054f2 <sys_dup+0x48>

0000000080005502 <sys_read>:
{
    80005502:	7179                	add	sp,sp,-48
    80005504:	f406                	sd	ra,40(sp)
    80005506:	f022                	sd	s0,32(sp)
    80005508:	1800                	add	s0,sp,48
  argaddr(1, &p);
    8000550a:	fd840593          	add	a1,s0,-40
    8000550e:	4505                	li	a0,1
    80005510:	ffffd097          	auipc	ra,0xffffd
    80005514:	7de080e7          	jalr	2014(ra) # 80002cee <argaddr>
  argint(2, &n);
    80005518:	fe440593          	add	a1,s0,-28
    8000551c:	4509                	li	a0,2
    8000551e:	ffffd097          	auipc	ra,0xffffd
    80005522:	7b0080e7          	jalr	1968(ra) # 80002cce <argint>
  if(argfd(0, 0, &f) < 0)
    80005526:	fe840613          	add	a2,s0,-24
    8000552a:	4581                	li	a1,0
    8000552c:	4501                	li	a0,0
    8000552e:	00000097          	auipc	ra,0x0
    80005532:	d54080e7          	jalr	-684(ra) # 80005282 <argfd>
    80005536:	87aa                	mv	a5,a0
    return -1;
    80005538:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000553a:	0007cc63          	bltz	a5,80005552 <sys_read+0x50>
  return fileread(f, p, n);
    8000553e:	fe442603          	lw	a2,-28(s0)
    80005542:	fd843583          	ld	a1,-40(s0)
    80005546:	fe843503          	ld	a0,-24(s0)
    8000554a:	fffff097          	auipc	ra,0xfffff
    8000554e:	3d8080e7          	jalr	984(ra) # 80004922 <fileread>
}
    80005552:	70a2                	ld	ra,40(sp)
    80005554:	7402                	ld	s0,32(sp)
    80005556:	6145                	add	sp,sp,48
    80005558:	8082                	ret

000000008000555a <sys_write>:
{
    8000555a:	7179                	add	sp,sp,-48
    8000555c:	f406                	sd	ra,40(sp)
    8000555e:	f022                	sd	s0,32(sp)
    80005560:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005562:	fd840593          	add	a1,s0,-40
    80005566:	4505                	li	a0,1
    80005568:	ffffd097          	auipc	ra,0xffffd
    8000556c:	786080e7          	jalr	1926(ra) # 80002cee <argaddr>
  argint(2, &n);
    80005570:	fe440593          	add	a1,s0,-28
    80005574:	4509                	li	a0,2
    80005576:	ffffd097          	auipc	ra,0xffffd
    8000557a:	758080e7          	jalr	1880(ra) # 80002cce <argint>
  if(argfd(0, 0, &f) < 0)
    8000557e:	fe840613          	add	a2,s0,-24
    80005582:	4581                	li	a1,0
    80005584:	4501                	li	a0,0
    80005586:	00000097          	auipc	ra,0x0
    8000558a:	cfc080e7          	jalr	-772(ra) # 80005282 <argfd>
    8000558e:	87aa                	mv	a5,a0
    return -1;
    80005590:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005592:	0007cc63          	bltz	a5,800055aa <sys_write+0x50>
  return filewrite(f, p, n);
    80005596:	fe442603          	lw	a2,-28(s0)
    8000559a:	fd843583          	ld	a1,-40(s0)
    8000559e:	fe843503          	ld	a0,-24(s0)
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	452080e7          	jalr	1106(ra) # 800049f4 <filewrite>
}
    800055aa:	70a2                	ld	ra,40(sp)
    800055ac:	7402                	ld	s0,32(sp)
    800055ae:	6145                	add	sp,sp,48
    800055b0:	8082                	ret

00000000800055b2 <sys_close>:
{
    800055b2:	1101                	add	sp,sp,-32
    800055b4:	ec06                	sd	ra,24(sp)
    800055b6:	e822                	sd	s0,16(sp)
    800055b8:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055ba:	fe040613          	add	a2,s0,-32
    800055be:	fec40593          	add	a1,s0,-20
    800055c2:	4501                	li	a0,0
    800055c4:	00000097          	auipc	ra,0x0
    800055c8:	cbe080e7          	jalr	-834(ra) # 80005282 <argfd>
    return -1;
    800055cc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055ce:	02054463          	bltz	a0,800055f6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055d2:	ffffc097          	auipc	ra,0xffffc
    800055d6:	478080e7          	jalr	1144(ra) # 80001a4a <myproc>
    800055da:	fec42783          	lw	a5,-20(s0)
    800055de:	07e9                	add	a5,a5,26
    800055e0:	078e                	sll	a5,a5,0x3
    800055e2:	953e                	add	a0,a0,a5
    800055e4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800055e8:	fe043503          	ld	a0,-32(s0)
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	1e2080e7          	jalr	482(ra) # 800047ce <fileclose>
  return 0;
    800055f4:	4781                	li	a5,0
}
    800055f6:	853e                	mv	a0,a5
    800055f8:	60e2                	ld	ra,24(sp)
    800055fa:	6442                	ld	s0,16(sp)
    800055fc:	6105                	add	sp,sp,32
    800055fe:	8082                	ret

0000000080005600 <sys_fstat>:
{
    80005600:	1101                	add	sp,sp,-32
    80005602:	ec06                	sd	ra,24(sp)
    80005604:	e822                	sd	s0,16(sp)
    80005606:	1000                	add	s0,sp,32
  argaddr(1, &st);
    80005608:	fe040593          	add	a1,s0,-32
    8000560c:	4505                	li	a0,1
    8000560e:	ffffd097          	auipc	ra,0xffffd
    80005612:	6e0080e7          	jalr	1760(ra) # 80002cee <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005616:	fe840613          	add	a2,s0,-24
    8000561a:	4581                	li	a1,0
    8000561c:	4501                	li	a0,0
    8000561e:	00000097          	auipc	ra,0x0
    80005622:	c64080e7          	jalr	-924(ra) # 80005282 <argfd>
    80005626:	87aa                	mv	a5,a0
    return -1;
    80005628:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000562a:	0007ca63          	bltz	a5,8000563e <sys_fstat+0x3e>
  return filestat(f, st);
    8000562e:	fe043583          	ld	a1,-32(s0)
    80005632:	fe843503          	ld	a0,-24(s0)
    80005636:	fffff097          	auipc	ra,0xfffff
    8000563a:	27a080e7          	jalr	634(ra) # 800048b0 <filestat>
}
    8000563e:	60e2                	ld	ra,24(sp)
    80005640:	6442                	ld	s0,16(sp)
    80005642:	6105                	add	sp,sp,32
    80005644:	8082                	ret

0000000080005646 <sys_link>:
{
    80005646:	7169                	add	sp,sp,-304
    80005648:	f606                	sd	ra,296(sp)
    8000564a:	f222                	sd	s0,288(sp)
    8000564c:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000564e:	08000613          	li	a2,128
    80005652:	ed040593          	add	a1,s0,-304
    80005656:	4501                	li	a0,0
    80005658:	ffffd097          	auipc	ra,0xffffd
    8000565c:	6b6080e7          	jalr	1718(ra) # 80002d0e <argstr>
    return -1;
    80005660:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005662:	12054663          	bltz	a0,8000578e <sys_link+0x148>
    80005666:	08000613          	li	a2,128
    8000566a:	f5040593          	add	a1,s0,-176
    8000566e:	4505                	li	a0,1
    80005670:	ffffd097          	auipc	ra,0xffffd
    80005674:	69e080e7          	jalr	1694(ra) # 80002d0e <argstr>
    return -1;
    80005678:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000567a:	10054a63          	bltz	a0,8000578e <sys_link+0x148>
    8000567e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	c84080e7          	jalr	-892(ra) # 80004304 <begin_op>
  if((ip = namei(old)) == 0){
    80005688:	ed040513          	add	a0,s0,-304
    8000568c:	fffff097          	auipc	ra,0xfffff
    80005690:	a78080e7          	jalr	-1416(ra) # 80004104 <namei>
    80005694:	84aa                	mv	s1,a0
    80005696:	c949                	beqz	a0,80005728 <sys_link+0xe2>
  ilock(ip);
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	29e080e7          	jalr	670(ra) # 80003936 <ilock>
  if(ip->type == T_DIR){
    800056a0:	04449703          	lh	a4,68(s1)
    800056a4:	4785                	li	a5,1
    800056a6:	08f70863          	beq	a4,a5,80005736 <sys_link+0xf0>
    800056aa:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800056ac:	04a4d783          	lhu	a5,74(s1)
    800056b0:	2785                	addw	a5,a5,1
    800056b2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	1b2080e7          	jalr	434(ra) # 8000386a <iupdate>
  iunlock(ip);
    800056c0:	8526                	mv	a0,s1
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	33a080e7          	jalr	826(ra) # 800039fc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056ca:	fd040593          	add	a1,s0,-48
    800056ce:	f5040513          	add	a0,s0,-176
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	a50080e7          	jalr	-1456(ra) # 80004122 <nameiparent>
    800056da:	892a                	mv	s2,a0
    800056dc:	cd35                	beqz	a0,80005758 <sys_link+0x112>
  ilock(dp);
    800056de:	ffffe097          	auipc	ra,0xffffe
    800056e2:	258080e7          	jalr	600(ra) # 80003936 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056e6:	00092703          	lw	a4,0(s2)
    800056ea:	409c                	lw	a5,0(s1)
    800056ec:	06f71163          	bne	a4,a5,8000574e <sys_link+0x108>
    800056f0:	40d0                	lw	a2,4(s1)
    800056f2:	fd040593          	add	a1,s0,-48
    800056f6:	854a                	mv	a0,s2
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	95a080e7          	jalr	-1702(ra) # 80004052 <dirlink>
    80005700:	04054763          	bltz	a0,8000574e <sys_link+0x108>
  iunlockput(dp);
    80005704:	854a                	mv	a0,s2
    80005706:	ffffe097          	auipc	ra,0xffffe
    8000570a:	496080e7          	jalr	1174(ra) # 80003b9c <iunlockput>
  iput(ip);
    8000570e:	8526                	mv	a0,s1
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	3e4080e7          	jalr	996(ra) # 80003af4 <iput>
  end_op();
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	c66080e7          	jalr	-922(ra) # 8000437e <end_op>
  return 0;
    80005720:	4781                	li	a5,0
    80005722:	64f2                	ld	s1,280(sp)
    80005724:	6952                	ld	s2,272(sp)
    80005726:	a0a5                	j	8000578e <sys_link+0x148>
    end_op();
    80005728:	fffff097          	auipc	ra,0xfffff
    8000572c:	c56080e7          	jalr	-938(ra) # 8000437e <end_op>
    return -1;
    80005730:	57fd                	li	a5,-1
    80005732:	64f2                	ld	s1,280(sp)
    80005734:	a8a9                	j	8000578e <sys_link+0x148>
    iunlockput(ip);
    80005736:	8526                	mv	a0,s1
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	464080e7          	jalr	1124(ra) # 80003b9c <iunlockput>
    end_op();
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	c3e080e7          	jalr	-962(ra) # 8000437e <end_op>
    return -1;
    80005748:	57fd                	li	a5,-1
    8000574a:	64f2                	ld	s1,280(sp)
    8000574c:	a089                	j	8000578e <sys_link+0x148>
    iunlockput(dp);
    8000574e:	854a                	mv	a0,s2
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	44c080e7          	jalr	1100(ra) # 80003b9c <iunlockput>
  ilock(ip);
    80005758:	8526                	mv	a0,s1
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	1dc080e7          	jalr	476(ra) # 80003936 <ilock>
  ip->nlink--;
    80005762:	04a4d783          	lhu	a5,74(s1)
    80005766:	37fd                	addw	a5,a5,-1
    80005768:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000576c:	8526                	mv	a0,s1
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	0fc080e7          	jalr	252(ra) # 8000386a <iupdate>
  iunlockput(ip);
    80005776:	8526                	mv	a0,s1
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	424080e7          	jalr	1060(ra) # 80003b9c <iunlockput>
  end_op();
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	bfe080e7          	jalr	-1026(ra) # 8000437e <end_op>
  return -1;
    80005788:	57fd                	li	a5,-1
    8000578a:	64f2                	ld	s1,280(sp)
    8000578c:	6952                	ld	s2,272(sp)
}
    8000578e:	853e                	mv	a0,a5
    80005790:	70b2                	ld	ra,296(sp)
    80005792:	7412                	ld	s0,288(sp)
    80005794:	6155                	add	sp,sp,304
    80005796:	8082                	ret

0000000080005798 <sys_unlink>:
{
    80005798:	7151                	add	sp,sp,-240
    8000579a:	f586                	sd	ra,232(sp)
    8000579c:	f1a2                	sd	s0,224(sp)
    8000579e:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057a0:	08000613          	li	a2,128
    800057a4:	f3040593          	add	a1,s0,-208
    800057a8:	4501                	li	a0,0
    800057aa:	ffffd097          	auipc	ra,0xffffd
    800057ae:	564080e7          	jalr	1380(ra) # 80002d0e <argstr>
    800057b2:	1a054a63          	bltz	a0,80005966 <sys_unlink+0x1ce>
    800057b6:	eda6                	sd	s1,216(sp)
  begin_op();
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	b4c080e7          	jalr	-1204(ra) # 80004304 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057c0:	fb040593          	add	a1,s0,-80
    800057c4:	f3040513          	add	a0,s0,-208
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	95a080e7          	jalr	-1702(ra) # 80004122 <nameiparent>
    800057d0:	84aa                	mv	s1,a0
    800057d2:	cd71                	beqz	a0,800058ae <sys_unlink+0x116>
  ilock(dp);
    800057d4:	ffffe097          	auipc	ra,0xffffe
    800057d8:	162080e7          	jalr	354(ra) # 80003936 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057dc:	00003597          	auipc	a1,0x3
    800057e0:	dfc58593          	add	a1,a1,-516 # 800085d8 <etext+0x5d8>
    800057e4:	fb040513          	add	a0,s0,-80
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	640080e7          	jalr	1600(ra) # 80003e28 <namecmp>
    800057f0:	14050c63          	beqz	a0,80005948 <sys_unlink+0x1b0>
    800057f4:	00003597          	auipc	a1,0x3
    800057f8:	dec58593          	add	a1,a1,-532 # 800085e0 <etext+0x5e0>
    800057fc:	fb040513          	add	a0,s0,-80
    80005800:	ffffe097          	auipc	ra,0xffffe
    80005804:	628080e7          	jalr	1576(ra) # 80003e28 <namecmp>
    80005808:	14050063          	beqz	a0,80005948 <sys_unlink+0x1b0>
    8000580c:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000580e:	f2c40613          	add	a2,s0,-212
    80005812:	fb040593          	add	a1,s0,-80
    80005816:	8526                	mv	a0,s1
    80005818:	ffffe097          	auipc	ra,0xffffe
    8000581c:	62a080e7          	jalr	1578(ra) # 80003e42 <dirlookup>
    80005820:	892a                	mv	s2,a0
    80005822:	12050263          	beqz	a0,80005946 <sys_unlink+0x1ae>
  ilock(ip);
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	110080e7          	jalr	272(ra) # 80003936 <ilock>
  if(ip->nlink < 1)
    8000582e:	04a91783          	lh	a5,74(s2)
    80005832:	08f05563          	blez	a5,800058bc <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005836:	04491703          	lh	a4,68(s2)
    8000583a:	4785                	li	a5,1
    8000583c:	08f70963          	beq	a4,a5,800058ce <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005840:	4641                	li	a2,16
    80005842:	4581                	li	a1,0
    80005844:	fc040513          	add	a0,s0,-64
    80005848:	ffffb097          	auipc	ra,0xffffb
    8000584c:	4ec080e7          	jalr	1260(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005850:	4741                	li	a4,16
    80005852:	f2c42683          	lw	a3,-212(s0)
    80005856:	fc040613          	add	a2,s0,-64
    8000585a:	4581                	li	a1,0
    8000585c:	8526                	mv	a0,s1
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	4a0080e7          	jalr	1184(ra) # 80003cfe <writei>
    80005866:	47c1                	li	a5,16
    80005868:	0af51b63          	bne	a0,a5,8000591e <sys_unlink+0x186>
  if(ip->type == T_DIR){
    8000586c:	04491703          	lh	a4,68(s2)
    80005870:	4785                	li	a5,1
    80005872:	0af70f63          	beq	a4,a5,80005930 <sys_unlink+0x198>
  iunlockput(dp);
    80005876:	8526                	mv	a0,s1
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	324080e7          	jalr	804(ra) # 80003b9c <iunlockput>
  ip->nlink--;
    80005880:	04a95783          	lhu	a5,74(s2)
    80005884:	37fd                	addw	a5,a5,-1
    80005886:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000588a:	854a                	mv	a0,s2
    8000588c:	ffffe097          	auipc	ra,0xffffe
    80005890:	fde080e7          	jalr	-34(ra) # 8000386a <iupdate>
  iunlockput(ip);
    80005894:	854a                	mv	a0,s2
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	306080e7          	jalr	774(ra) # 80003b9c <iunlockput>
  end_op();
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	ae0080e7          	jalr	-1312(ra) # 8000437e <end_op>
  return 0;
    800058a6:	4501                	li	a0,0
    800058a8:	64ee                	ld	s1,216(sp)
    800058aa:	694e                	ld	s2,208(sp)
    800058ac:	a84d                	j	8000595e <sys_unlink+0x1c6>
    end_op();
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	ad0080e7          	jalr	-1328(ra) # 8000437e <end_op>
    return -1;
    800058b6:	557d                	li	a0,-1
    800058b8:	64ee                	ld	s1,216(sp)
    800058ba:	a055                	j	8000595e <sys_unlink+0x1c6>
    800058bc:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800058be:	00003517          	auipc	a0,0x3
    800058c2:	d2a50513          	add	a0,a0,-726 # 800085e8 <etext+0x5e8>
    800058c6:	ffffb097          	auipc	ra,0xffffb
    800058ca:	c9a080e7          	jalr	-870(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058ce:	04c92703          	lw	a4,76(s2)
    800058d2:	02000793          	li	a5,32
    800058d6:	f6e7f5e3          	bgeu	a5,a4,80005840 <sys_unlink+0xa8>
    800058da:	e5ce                	sd	s3,200(sp)
    800058dc:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058e0:	4741                	li	a4,16
    800058e2:	86ce                	mv	a3,s3
    800058e4:	f1840613          	add	a2,s0,-232
    800058e8:	4581                	li	a1,0
    800058ea:	854a                	mv	a0,s2
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	302080e7          	jalr	770(ra) # 80003bee <readi>
    800058f4:	47c1                	li	a5,16
    800058f6:	00f51c63          	bne	a0,a5,8000590e <sys_unlink+0x176>
    if(de.inum != 0)
    800058fa:	f1845783          	lhu	a5,-232(s0)
    800058fe:	e7b5                	bnez	a5,8000596a <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005900:	29c1                	addw	s3,s3,16
    80005902:	04c92783          	lw	a5,76(s2)
    80005906:	fcf9ede3          	bltu	s3,a5,800058e0 <sys_unlink+0x148>
    8000590a:	69ae                	ld	s3,200(sp)
    8000590c:	bf15                	j	80005840 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    8000590e:	00003517          	auipc	a0,0x3
    80005912:	cf250513          	add	a0,a0,-782 # 80008600 <etext+0x600>
    80005916:	ffffb097          	auipc	ra,0xffffb
    8000591a:	c4a080e7          	jalr	-950(ra) # 80000560 <panic>
    8000591e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005920:	00003517          	auipc	a0,0x3
    80005924:	cf850513          	add	a0,a0,-776 # 80008618 <etext+0x618>
    80005928:	ffffb097          	auipc	ra,0xffffb
    8000592c:	c38080e7          	jalr	-968(ra) # 80000560 <panic>
    dp->nlink--;
    80005930:	04a4d783          	lhu	a5,74(s1)
    80005934:	37fd                	addw	a5,a5,-1
    80005936:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000593a:	8526                	mv	a0,s1
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	f2e080e7          	jalr	-210(ra) # 8000386a <iupdate>
    80005944:	bf0d                	j	80005876 <sys_unlink+0xde>
    80005946:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005948:	8526                	mv	a0,s1
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	252080e7          	jalr	594(ra) # 80003b9c <iunlockput>
  end_op();
    80005952:	fffff097          	auipc	ra,0xfffff
    80005956:	a2c080e7          	jalr	-1492(ra) # 8000437e <end_op>
  return -1;
    8000595a:	557d                	li	a0,-1
    8000595c:	64ee                	ld	s1,216(sp)
}
    8000595e:	70ae                	ld	ra,232(sp)
    80005960:	740e                	ld	s0,224(sp)
    80005962:	616d                	add	sp,sp,240
    80005964:	8082                	ret
    return -1;
    80005966:	557d                	li	a0,-1
    80005968:	bfdd                	j	8000595e <sys_unlink+0x1c6>
    iunlockput(ip);
    8000596a:	854a                	mv	a0,s2
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	230080e7          	jalr	560(ra) # 80003b9c <iunlockput>
    goto bad;
    80005974:	694e                	ld	s2,208(sp)
    80005976:	69ae                	ld	s3,200(sp)
    80005978:	bfc1                	j	80005948 <sys_unlink+0x1b0>

000000008000597a <sys_open>:

uint64
sys_open(void)
{
    8000597a:	7131                	add	sp,sp,-192
    8000597c:	fd06                	sd	ra,184(sp)
    8000597e:	f922                	sd	s0,176(sp)
    80005980:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005982:	f4c40593          	add	a1,s0,-180
    80005986:	4505                	li	a0,1
    80005988:	ffffd097          	auipc	ra,0xffffd
    8000598c:	346080e7          	jalr	838(ra) # 80002cce <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005990:	08000613          	li	a2,128
    80005994:	f5040593          	add	a1,s0,-176
    80005998:	4501                	li	a0,0
    8000599a:	ffffd097          	auipc	ra,0xffffd
    8000599e:	374080e7          	jalr	884(ra) # 80002d0e <argstr>
    800059a2:	87aa                	mv	a5,a0
    return -1;
    800059a4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059a6:	0a07ce63          	bltz	a5,80005a62 <sys_open+0xe8>
    800059aa:	f526                	sd	s1,168(sp)

  begin_op();
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	958080e7          	jalr	-1704(ra) # 80004304 <begin_op>

  if(omode & O_CREATE){
    800059b4:	f4c42783          	lw	a5,-180(s0)
    800059b8:	2007f793          	and	a5,a5,512
    800059bc:	cfd5                	beqz	a5,80005a78 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059be:	4681                	li	a3,0
    800059c0:	4601                	li	a2,0
    800059c2:	4589                	li	a1,2
    800059c4:	f5040513          	add	a0,s0,-176
    800059c8:	00000097          	auipc	ra,0x0
    800059cc:	95c080e7          	jalr	-1700(ra) # 80005324 <create>
    800059d0:	84aa                	mv	s1,a0
    if(ip == 0){
    800059d2:	cd41                	beqz	a0,80005a6a <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059d4:	04449703          	lh	a4,68(s1)
    800059d8:	478d                	li	a5,3
    800059da:	00f71763          	bne	a4,a5,800059e8 <sys_open+0x6e>
    800059de:	0464d703          	lhu	a4,70(s1)
    800059e2:	47a5                	li	a5,9
    800059e4:	0ee7e163          	bltu	a5,a4,80005ac6 <sys_open+0x14c>
    800059e8:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	d28080e7          	jalr	-728(ra) # 80004712 <filealloc>
    800059f2:	892a                	mv	s2,a0
    800059f4:	c97d                	beqz	a0,80005aea <sys_open+0x170>
    800059f6:	ed4e                	sd	s3,152(sp)
    800059f8:	00000097          	auipc	ra,0x0
    800059fc:	8ea080e7          	jalr	-1814(ra) # 800052e2 <fdalloc>
    80005a00:	89aa                	mv	s3,a0
    80005a02:	0c054e63          	bltz	a0,80005ade <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a06:	04449703          	lh	a4,68(s1)
    80005a0a:	478d                	li	a5,3
    80005a0c:	0ef70c63          	beq	a4,a5,80005b04 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a10:	4789                	li	a5,2
    80005a12:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005a16:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005a1a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005a1e:	f4c42783          	lw	a5,-180(s0)
    80005a22:	0017c713          	xor	a4,a5,1
    80005a26:	8b05                	and	a4,a4,1
    80005a28:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a2c:	0037f713          	and	a4,a5,3
    80005a30:	00e03733          	snez	a4,a4
    80005a34:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a38:	4007f793          	and	a5,a5,1024
    80005a3c:	c791                	beqz	a5,80005a48 <sys_open+0xce>
    80005a3e:	04449703          	lh	a4,68(s1)
    80005a42:	4789                	li	a5,2
    80005a44:	0cf70763          	beq	a4,a5,80005b12 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005a48:	8526                	mv	a0,s1
    80005a4a:	ffffe097          	auipc	ra,0xffffe
    80005a4e:	fb2080e7          	jalr	-78(ra) # 800039fc <iunlock>
  end_op();
    80005a52:	fffff097          	auipc	ra,0xfffff
    80005a56:	92c080e7          	jalr	-1748(ra) # 8000437e <end_op>

  return fd;
    80005a5a:	854e                	mv	a0,s3
    80005a5c:	74aa                	ld	s1,168(sp)
    80005a5e:	790a                	ld	s2,160(sp)
    80005a60:	69ea                	ld	s3,152(sp)
}
    80005a62:	70ea                	ld	ra,184(sp)
    80005a64:	744a                	ld	s0,176(sp)
    80005a66:	6129                	add	sp,sp,192
    80005a68:	8082                	ret
      end_op();
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	914080e7          	jalr	-1772(ra) # 8000437e <end_op>
      return -1;
    80005a72:	557d                	li	a0,-1
    80005a74:	74aa                	ld	s1,168(sp)
    80005a76:	b7f5                	j	80005a62 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005a78:	f5040513          	add	a0,s0,-176
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	688080e7          	jalr	1672(ra) # 80004104 <namei>
    80005a84:	84aa                	mv	s1,a0
    80005a86:	c90d                	beqz	a0,80005ab8 <sys_open+0x13e>
    ilock(ip);
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	eae080e7          	jalr	-338(ra) # 80003936 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a90:	04449703          	lh	a4,68(s1)
    80005a94:	4785                	li	a5,1
    80005a96:	f2f71fe3          	bne	a4,a5,800059d4 <sys_open+0x5a>
    80005a9a:	f4c42783          	lw	a5,-180(s0)
    80005a9e:	d7a9                	beqz	a5,800059e8 <sys_open+0x6e>
      iunlockput(ip);
    80005aa0:	8526                	mv	a0,s1
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	0fa080e7          	jalr	250(ra) # 80003b9c <iunlockput>
      end_op();
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	8d4080e7          	jalr	-1836(ra) # 8000437e <end_op>
      return -1;
    80005ab2:	557d                	li	a0,-1
    80005ab4:	74aa                	ld	s1,168(sp)
    80005ab6:	b775                	j	80005a62 <sys_open+0xe8>
      end_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	8c6080e7          	jalr	-1850(ra) # 8000437e <end_op>
      return -1;
    80005ac0:	557d                	li	a0,-1
    80005ac2:	74aa                	ld	s1,168(sp)
    80005ac4:	bf79                	j	80005a62 <sys_open+0xe8>
    iunlockput(ip);
    80005ac6:	8526                	mv	a0,s1
    80005ac8:	ffffe097          	auipc	ra,0xffffe
    80005acc:	0d4080e7          	jalr	212(ra) # 80003b9c <iunlockput>
    end_op();
    80005ad0:	fffff097          	auipc	ra,0xfffff
    80005ad4:	8ae080e7          	jalr	-1874(ra) # 8000437e <end_op>
    return -1;
    80005ad8:	557d                	li	a0,-1
    80005ada:	74aa                	ld	s1,168(sp)
    80005adc:	b759                	j	80005a62 <sys_open+0xe8>
      fileclose(f);
    80005ade:	854a                	mv	a0,s2
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	cee080e7          	jalr	-786(ra) # 800047ce <fileclose>
    80005ae8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005aea:	8526                	mv	a0,s1
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	0b0080e7          	jalr	176(ra) # 80003b9c <iunlockput>
    end_op();
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	88a080e7          	jalr	-1910(ra) # 8000437e <end_op>
    return -1;
    80005afc:	557d                	li	a0,-1
    80005afe:	74aa                	ld	s1,168(sp)
    80005b00:	790a                	ld	s2,160(sp)
    80005b02:	b785                	j	80005a62 <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005b04:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005b08:	04649783          	lh	a5,70(s1)
    80005b0c:	02f91223          	sh	a5,36(s2)
    80005b10:	b729                	j	80005a1a <sys_open+0xa0>
    itrunc(ip);
    80005b12:	8526                	mv	a0,s1
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	f34080e7          	jalr	-204(ra) # 80003a48 <itrunc>
    80005b1c:	b735                	j	80005a48 <sys_open+0xce>

0000000080005b1e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b1e:	7175                	add	sp,sp,-144
    80005b20:	e506                	sd	ra,136(sp)
    80005b22:	e122                	sd	s0,128(sp)
    80005b24:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b26:	ffffe097          	auipc	ra,0xffffe
    80005b2a:	7de080e7          	jalr	2014(ra) # 80004304 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b2e:	08000613          	li	a2,128
    80005b32:	f7040593          	add	a1,s0,-144
    80005b36:	4501                	li	a0,0
    80005b38:	ffffd097          	auipc	ra,0xffffd
    80005b3c:	1d6080e7          	jalr	470(ra) # 80002d0e <argstr>
    80005b40:	02054963          	bltz	a0,80005b72 <sys_mkdir+0x54>
    80005b44:	4681                	li	a3,0
    80005b46:	4601                	li	a2,0
    80005b48:	4585                	li	a1,1
    80005b4a:	f7040513          	add	a0,s0,-144
    80005b4e:	fffff097          	auipc	ra,0xfffff
    80005b52:	7d6080e7          	jalr	2006(ra) # 80005324 <create>
    80005b56:	cd11                	beqz	a0,80005b72 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	044080e7          	jalr	68(ra) # 80003b9c <iunlockput>
  end_op();
    80005b60:	fffff097          	auipc	ra,0xfffff
    80005b64:	81e080e7          	jalr	-2018(ra) # 8000437e <end_op>
  return 0;
    80005b68:	4501                	li	a0,0
}
    80005b6a:	60aa                	ld	ra,136(sp)
    80005b6c:	640a                	ld	s0,128(sp)
    80005b6e:	6149                	add	sp,sp,144
    80005b70:	8082                	ret
    end_op();
    80005b72:	fffff097          	auipc	ra,0xfffff
    80005b76:	80c080e7          	jalr	-2036(ra) # 8000437e <end_op>
    return -1;
    80005b7a:	557d                	li	a0,-1
    80005b7c:	b7fd                	j	80005b6a <sys_mkdir+0x4c>

0000000080005b7e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b7e:	7135                	add	sp,sp,-160
    80005b80:	ed06                	sd	ra,152(sp)
    80005b82:	e922                	sd	s0,144(sp)
    80005b84:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	77e080e7          	jalr	1918(ra) # 80004304 <begin_op>
  argint(1, &major);
    80005b8e:	f6c40593          	add	a1,s0,-148
    80005b92:	4505                	li	a0,1
    80005b94:	ffffd097          	auipc	ra,0xffffd
    80005b98:	13a080e7          	jalr	314(ra) # 80002cce <argint>
  argint(2, &minor);
    80005b9c:	f6840593          	add	a1,s0,-152
    80005ba0:	4509                	li	a0,2
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	12c080e7          	jalr	300(ra) # 80002cce <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005baa:	08000613          	li	a2,128
    80005bae:	f7040593          	add	a1,s0,-144
    80005bb2:	4501                	li	a0,0
    80005bb4:	ffffd097          	auipc	ra,0xffffd
    80005bb8:	15a080e7          	jalr	346(ra) # 80002d0e <argstr>
    80005bbc:	02054b63          	bltz	a0,80005bf2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bc0:	f6841683          	lh	a3,-152(s0)
    80005bc4:	f6c41603          	lh	a2,-148(s0)
    80005bc8:	458d                	li	a1,3
    80005bca:	f7040513          	add	a0,s0,-144
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	756080e7          	jalr	1878(ra) # 80005324 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bd6:	cd11                	beqz	a0,80005bf2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bd8:	ffffe097          	auipc	ra,0xffffe
    80005bdc:	fc4080e7          	jalr	-60(ra) # 80003b9c <iunlockput>
  end_op();
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	79e080e7          	jalr	1950(ra) # 8000437e <end_op>
  return 0;
    80005be8:	4501                	li	a0,0
}
    80005bea:	60ea                	ld	ra,152(sp)
    80005bec:	644a                	ld	s0,144(sp)
    80005bee:	610d                	add	sp,sp,160
    80005bf0:	8082                	ret
    end_op();
    80005bf2:	ffffe097          	auipc	ra,0xffffe
    80005bf6:	78c080e7          	jalr	1932(ra) # 8000437e <end_op>
    return -1;
    80005bfa:	557d                	li	a0,-1
    80005bfc:	b7fd                	j	80005bea <sys_mknod+0x6c>

0000000080005bfe <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bfe:	7135                	add	sp,sp,-160
    80005c00:	ed06                	sd	ra,152(sp)
    80005c02:	e922                	sd	s0,144(sp)
    80005c04:	e14a                	sd	s2,128(sp)
    80005c06:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c08:	ffffc097          	auipc	ra,0xffffc
    80005c0c:	e42080e7          	jalr	-446(ra) # 80001a4a <myproc>
    80005c10:	892a                	mv	s2,a0
  
  begin_op();
    80005c12:	ffffe097          	auipc	ra,0xffffe
    80005c16:	6f2080e7          	jalr	1778(ra) # 80004304 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c1a:	08000613          	li	a2,128
    80005c1e:	f6040593          	add	a1,s0,-160
    80005c22:	4501                	li	a0,0
    80005c24:	ffffd097          	auipc	ra,0xffffd
    80005c28:	0ea080e7          	jalr	234(ra) # 80002d0e <argstr>
    80005c2c:	04054d63          	bltz	a0,80005c86 <sys_chdir+0x88>
    80005c30:	e526                	sd	s1,136(sp)
    80005c32:	f6040513          	add	a0,s0,-160
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	4ce080e7          	jalr	1230(ra) # 80004104 <namei>
    80005c3e:	84aa                	mv	s1,a0
    80005c40:	c131                	beqz	a0,80005c84 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c42:	ffffe097          	auipc	ra,0xffffe
    80005c46:	cf4080e7          	jalr	-780(ra) # 80003936 <ilock>
  if(ip->type != T_DIR){
    80005c4a:	04449703          	lh	a4,68(s1)
    80005c4e:	4785                	li	a5,1
    80005c50:	04f71163          	bne	a4,a5,80005c92 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c54:	8526                	mv	a0,s1
    80005c56:	ffffe097          	auipc	ra,0xffffe
    80005c5a:	da6080e7          	jalr	-602(ra) # 800039fc <iunlock>
  iput(p->cwd);
    80005c5e:	15093503          	ld	a0,336(s2)
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	e92080e7          	jalr	-366(ra) # 80003af4 <iput>
  end_op();
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	714080e7          	jalr	1812(ra) # 8000437e <end_op>
  p->cwd = ip;
    80005c72:	14993823          	sd	s1,336(s2)
  return 0;
    80005c76:	4501                	li	a0,0
    80005c78:	64aa                	ld	s1,136(sp)
}
    80005c7a:	60ea                	ld	ra,152(sp)
    80005c7c:	644a                	ld	s0,144(sp)
    80005c7e:	690a                	ld	s2,128(sp)
    80005c80:	610d                	add	sp,sp,160
    80005c82:	8082                	ret
    80005c84:	64aa                	ld	s1,136(sp)
    end_op();
    80005c86:	ffffe097          	auipc	ra,0xffffe
    80005c8a:	6f8080e7          	jalr	1784(ra) # 8000437e <end_op>
    return -1;
    80005c8e:	557d                	li	a0,-1
    80005c90:	b7ed                	j	80005c7a <sys_chdir+0x7c>
    iunlockput(ip);
    80005c92:	8526                	mv	a0,s1
    80005c94:	ffffe097          	auipc	ra,0xffffe
    80005c98:	f08080e7          	jalr	-248(ra) # 80003b9c <iunlockput>
    end_op();
    80005c9c:	ffffe097          	auipc	ra,0xffffe
    80005ca0:	6e2080e7          	jalr	1762(ra) # 8000437e <end_op>
    return -1;
    80005ca4:	557d                	li	a0,-1
    80005ca6:	64aa                	ld	s1,136(sp)
    80005ca8:	bfc9                	j	80005c7a <sys_chdir+0x7c>

0000000080005caa <sys_exec>:

uint64
sys_exec(void)
{
    80005caa:	7121                	add	sp,sp,-448
    80005cac:	ff06                	sd	ra,440(sp)
    80005cae:	fb22                	sd	s0,432(sp)
    80005cb0:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cb2:	e4840593          	add	a1,s0,-440
    80005cb6:	4505                	li	a0,1
    80005cb8:	ffffd097          	auipc	ra,0xffffd
    80005cbc:	036080e7          	jalr	54(ra) # 80002cee <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cc0:	08000613          	li	a2,128
    80005cc4:	f5040593          	add	a1,s0,-176
    80005cc8:	4501                	li	a0,0
    80005cca:	ffffd097          	auipc	ra,0xffffd
    80005cce:	044080e7          	jalr	68(ra) # 80002d0e <argstr>
    80005cd2:	87aa                	mv	a5,a0
    return -1;
    80005cd4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005cd6:	0e07c263          	bltz	a5,80005dba <sys_exec+0x110>
    80005cda:	f726                	sd	s1,424(sp)
    80005cdc:	f34a                	sd	s2,416(sp)
    80005cde:	ef4e                	sd	s3,408(sp)
    80005ce0:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005ce2:	10000613          	li	a2,256
    80005ce6:	4581                	li	a1,0
    80005ce8:	e5040513          	add	a0,s0,-432
    80005cec:	ffffb097          	auipc	ra,0xffffb
    80005cf0:	048080e7          	jalr	72(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cf4:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005cf8:	89a6                	mv	s3,s1
    80005cfa:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cfc:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d00:	00391513          	sll	a0,s2,0x3
    80005d04:	e4040593          	add	a1,s0,-448
    80005d08:	e4843783          	ld	a5,-440(s0)
    80005d0c:	953e                	add	a0,a0,a5
    80005d0e:	ffffd097          	auipc	ra,0xffffd
    80005d12:	f22080e7          	jalr	-222(ra) # 80002c30 <fetchaddr>
    80005d16:	02054a63          	bltz	a0,80005d4a <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005d1a:	e4043783          	ld	a5,-448(s0)
    80005d1e:	c7b9                	beqz	a5,80005d6c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d20:	ffffb097          	auipc	ra,0xffffb
    80005d24:	e28080e7          	jalr	-472(ra) # 80000b48 <kalloc>
    80005d28:	85aa                	mv	a1,a0
    80005d2a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d2e:	cd11                	beqz	a0,80005d4a <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d30:	6605                	lui	a2,0x1
    80005d32:	e4043503          	ld	a0,-448(s0)
    80005d36:	ffffd097          	auipc	ra,0xffffd
    80005d3a:	f4c080e7          	jalr	-180(ra) # 80002c82 <fetchstr>
    80005d3e:	00054663          	bltz	a0,80005d4a <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005d42:	0905                	add	s2,s2,1
    80005d44:	09a1                	add	s3,s3,8
    80005d46:	fb491de3          	bne	s2,s4,80005d00 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d4a:	f5040913          	add	s2,s0,-176
    80005d4e:	6088                	ld	a0,0(s1)
    80005d50:	c125                	beqz	a0,80005db0 <sys_exec+0x106>
    kfree(argv[i]);
    80005d52:	ffffb097          	auipc	ra,0xffffb
    80005d56:	cf8080e7          	jalr	-776(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d5a:	04a1                	add	s1,s1,8
    80005d5c:	ff2499e3          	bne	s1,s2,80005d4e <sys_exec+0xa4>
  return -1;
    80005d60:	557d                	li	a0,-1
    80005d62:	74ba                	ld	s1,424(sp)
    80005d64:	791a                	ld	s2,416(sp)
    80005d66:	69fa                	ld	s3,408(sp)
    80005d68:	6a5a                	ld	s4,400(sp)
    80005d6a:	a881                	j	80005dba <sys_exec+0x110>
      argv[i] = 0;
    80005d6c:	0009079b          	sext.w	a5,s2
    80005d70:	078e                	sll	a5,a5,0x3
    80005d72:	fd078793          	add	a5,a5,-48
    80005d76:	97a2                	add	a5,a5,s0
    80005d78:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005d7c:	e5040593          	add	a1,s0,-432
    80005d80:	f5040513          	add	a0,s0,-176
    80005d84:	fffff097          	auipc	ra,0xfffff
    80005d88:	120080e7          	jalr	288(ra) # 80004ea4 <exec>
    80005d8c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d8e:	f5040993          	add	s3,s0,-176
    80005d92:	6088                	ld	a0,0(s1)
    80005d94:	c901                	beqz	a0,80005da4 <sys_exec+0xfa>
    kfree(argv[i]);
    80005d96:	ffffb097          	auipc	ra,0xffffb
    80005d9a:	cb4080e7          	jalr	-844(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d9e:	04a1                	add	s1,s1,8
    80005da0:	ff3499e3          	bne	s1,s3,80005d92 <sys_exec+0xe8>
  return ret;
    80005da4:	854a                	mv	a0,s2
    80005da6:	74ba                	ld	s1,424(sp)
    80005da8:	791a                	ld	s2,416(sp)
    80005daa:	69fa                	ld	s3,408(sp)
    80005dac:	6a5a                	ld	s4,400(sp)
    80005dae:	a031                	j	80005dba <sys_exec+0x110>
  return -1;
    80005db0:	557d                	li	a0,-1
    80005db2:	74ba                	ld	s1,424(sp)
    80005db4:	791a                	ld	s2,416(sp)
    80005db6:	69fa                	ld	s3,408(sp)
    80005db8:	6a5a                	ld	s4,400(sp)
}
    80005dba:	70fa                	ld	ra,440(sp)
    80005dbc:	745a                	ld	s0,432(sp)
    80005dbe:	6139                	add	sp,sp,448
    80005dc0:	8082                	ret

0000000080005dc2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dc2:	7139                	add	sp,sp,-64
    80005dc4:	fc06                	sd	ra,56(sp)
    80005dc6:	f822                	sd	s0,48(sp)
    80005dc8:	f426                	sd	s1,40(sp)
    80005dca:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dcc:	ffffc097          	auipc	ra,0xffffc
    80005dd0:	c7e080e7          	jalr	-898(ra) # 80001a4a <myproc>
    80005dd4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005dd6:	fd840593          	add	a1,s0,-40
    80005dda:	4501                	li	a0,0
    80005ddc:	ffffd097          	auipc	ra,0xffffd
    80005de0:	f12080e7          	jalr	-238(ra) # 80002cee <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005de4:	fc840593          	add	a1,s0,-56
    80005de8:	fd040513          	add	a0,s0,-48
    80005dec:	fffff097          	auipc	ra,0xfffff
    80005df0:	d50080e7          	jalr	-688(ra) # 80004b3c <pipealloc>
    return -1;
    80005df4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005df6:	0c054463          	bltz	a0,80005ebe <sys_pipe+0xfc>
  fd0 = -1;
    80005dfa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005dfe:	fd043503          	ld	a0,-48(s0)
    80005e02:	fffff097          	auipc	ra,0xfffff
    80005e06:	4e0080e7          	jalr	1248(ra) # 800052e2 <fdalloc>
    80005e0a:	fca42223          	sw	a0,-60(s0)
    80005e0e:	08054b63          	bltz	a0,80005ea4 <sys_pipe+0xe2>
    80005e12:	fc843503          	ld	a0,-56(s0)
    80005e16:	fffff097          	auipc	ra,0xfffff
    80005e1a:	4cc080e7          	jalr	1228(ra) # 800052e2 <fdalloc>
    80005e1e:	fca42023          	sw	a0,-64(s0)
    80005e22:	06054863          	bltz	a0,80005e92 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e26:	4691                	li	a3,4
    80005e28:	fc440613          	add	a2,s0,-60
    80005e2c:	fd843583          	ld	a1,-40(s0)
    80005e30:	68a8                	ld	a0,80(s1)
    80005e32:	ffffc097          	auipc	ra,0xffffc
    80005e36:	8b0080e7          	jalr	-1872(ra) # 800016e2 <copyout>
    80005e3a:	02054063          	bltz	a0,80005e5a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e3e:	4691                	li	a3,4
    80005e40:	fc040613          	add	a2,s0,-64
    80005e44:	fd843583          	ld	a1,-40(s0)
    80005e48:	0591                	add	a1,a1,4
    80005e4a:	68a8                	ld	a0,80(s1)
    80005e4c:	ffffc097          	auipc	ra,0xffffc
    80005e50:	896080e7          	jalr	-1898(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e54:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e56:	06055463          	bgez	a0,80005ebe <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005e5a:	fc442783          	lw	a5,-60(s0)
    80005e5e:	07e9                	add	a5,a5,26
    80005e60:	078e                	sll	a5,a5,0x3
    80005e62:	97a6                	add	a5,a5,s1
    80005e64:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005e68:	fc042783          	lw	a5,-64(s0)
    80005e6c:	07e9                	add	a5,a5,26
    80005e6e:	078e                	sll	a5,a5,0x3
    80005e70:	94be                	add	s1,s1,a5
    80005e72:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005e76:	fd043503          	ld	a0,-48(s0)
    80005e7a:	fffff097          	auipc	ra,0xfffff
    80005e7e:	954080e7          	jalr	-1708(ra) # 800047ce <fileclose>
    fileclose(wf);
    80005e82:	fc843503          	ld	a0,-56(s0)
    80005e86:	fffff097          	auipc	ra,0xfffff
    80005e8a:	948080e7          	jalr	-1720(ra) # 800047ce <fileclose>
    return -1;
    80005e8e:	57fd                	li	a5,-1
    80005e90:	a03d                	j	80005ebe <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005e92:	fc442783          	lw	a5,-60(s0)
    80005e96:	0007c763          	bltz	a5,80005ea4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e9a:	07e9                	add	a5,a5,26
    80005e9c:	078e                	sll	a5,a5,0x3
    80005e9e:	97a6                	add	a5,a5,s1
    80005ea0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ea4:	fd043503          	ld	a0,-48(s0)
    80005ea8:	fffff097          	auipc	ra,0xfffff
    80005eac:	926080e7          	jalr	-1754(ra) # 800047ce <fileclose>
    fileclose(wf);
    80005eb0:	fc843503          	ld	a0,-56(s0)
    80005eb4:	fffff097          	auipc	ra,0xfffff
    80005eb8:	91a080e7          	jalr	-1766(ra) # 800047ce <fileclose>
    return -1;
    80005ebc:	57fd                	li	a5,-1
}
    80005ebe:	853e                	mv	a0,a5
    80005ec0:	70e2                	ld	ra,56(sp)
    80005ec2:	7442                	ld	s0,48(sp)
    80005ec4:	74a2                	ld	s1,40(sp)
    80005ec6:	6121                	add	sp,sp,64
    80005ec8:	8082                	ret
    80005eca:	0000                	unimp
    80005ecc:	0000                	unimp
	...

0000000080005ed0 <kernelvec>:
    80005ed0:	7111                	add	sp,sp,-256
    80005ed2:	e006                	sd	ra,0(sp)
    80005ed4:	e40a                	sd	sp,8(sp)
    80005ed6:	e80e                	sd	gp,16(sp)
    80005ed8:	ec12                	sd	tp,24(sp)
    80005eda:	f016                	sd	t0,32(sp)
    80005edc:	f41a                	sd	t1,40(sp)
    80005ede:	f81e                	sd	t2,48(sp)
    80005ee0:	fc22                	sd	s0,56(sp)
    80005ee2:	e0a6                	sd	s1,64(sp)
    80005ee4:	e4aa                	sd	a0,72(sp)
    80005ee6:	e8ae                	sd	a1,80(sp)
    80005ee8:	ecb2                	sd	a2,88(sp)
    80005eea:	f0b6                	sd	a3,96(sp)
    80005eec:	f4ba                	sd	a4,104(sp)
    80005eee:	f8be                	sd	a5,112(sp)
    80005ef0:	fcc2                	sd	a6,120(sp)
    80005ef2:	e146                	sd	a7,128(sp)
    80005ef4:	e54a                	sd	s2,136(sp)
    80005ef6:	e94e                	sd	s3,144(sp)
    80005ef8:	ed52                	sd	s4,152(sp)
    80005efa:	f156                	sd	s5,160(sp)
    80005efc:	f55a                	sd	s6,168(sp)
    80005efe:	f95e                	sd	s7,176(sp)
    80005f00:	fd62                	sd	s8,184(sp)
    80005f02:	e1e6                	sd	s9,192(sp)
    80005f04:	e5ea                	sd	s10,200(sp)
    80005f06:	e9ee                	sd	s11,208(sp)
    80005f08:	edf2                	sd	t3,216(sp)
    80005f0a:	f1f6                	sd	t4,224(sp)
    80005f0c:	f5fa                	sd	t5,232(sp)
    80005f0e:	f9fe                	sd	t6,240(sp)
    80005f10:	bedfc0ef          	jal	80002afc <kerneltrap>
    80005f14:	6082                	ld	ra,0(sp)
    80005f16:	6122                	ld	sp,8(sp)
    80005f18:	61c2                	ld	gp,16(sp)
    80005f1a:	7282                	ld	t0,32(sp)
    80005f1c:	7322                	ld	t1,40(sp)
    80005f1e:	73c2                	ld	t2,48(sp)
    80005f20:	7462                	ld	s0,56(sp)
    80005f22:	6486                	ld	s1,64(sp)
    80005f24:	6526                	ld	a0,72(sp)
    80005f26:	65c6                	ld	a1,80(sp)
    80005f28:	6666                	ld	a2,88(sp)
    80005f2a:	7686                	ld	a3,96(sp)
    80005f2c:	7726                	ld	a4,104(sp)
    80005f2e:	77c6                	ld	a5,112(sp)
    80005f30:	7866                	ld	a6,120(sp)
    80005f32:	688a                	ld	a7,128(sp)
    80005f34:	692a                	ld	s2,136(sp)
    80005f36:	69ca                	ld	s3,144(sp)
    80005f38:	6a6a                	ld	s4,152(sp)
    80005f3a:	7a8a                	ld	s5,160(sp)
    80005f3c:	7b2a                	ld	s6,168(sp)
    80005f3e:	7bca                	ld	s7,176(sp)
    80005f40:	7c6a                	ld	s8,184(sp)
    80005f42:	6c8e                	ld	s9,192(sp)
    80005f44:	6d2e                	ld	s10,200(sp)
    80005f46:	6dce                	ld	s11,208(sp)
    80005f48:	6e6e                	ld	t3,216(sp)
    80005f4a:	7e8e                	ld	t4,224(sp)
    80005f4c:	7f2e                	ld	t5,232(sp)
    80005f4e:	7fce                	ld	t6,240(sp)
    80005f50:	6111                	add	sp,sp,256
    80005f52:	10200073          	sret
    80005f56:	00000013          	nop
    80005f5a:	00000013          	nop
    80005f5e:	0001                	nop

0000000080005f60 <timervec>:
    80005f60:	34051573          	csrrw	a0,mscratch,a0
    80005f64:	e10c                	sd	a1,0(a0)
    80005f66:	e510                	sd	a2,8(a0)
    80005f68:	e914                	sd	a3,16(a0)
    80005f6a:	6d0c                	ld	a1,24(a0)
    80005f6c:	7110                	ld	a2,32(a0)
    80005f6e:	6194                	ld	a3,0(a1)
    80005f70:	96b2                	add	a3,a3,a2
    80005f72:	e194                	sd	a3,0(a1)
    80005f74:	4589                	li	a1,2
    80005f76:	14459073          	csrw	sip,a1
    80005f7a:	6914                	ld	a3,16(a0)
    80005f7c:	6510                	ld	a2,8(a0)
    80005f7e:	610c                	ld	a1,0(a0)
    80005f80:	34051573          	csrrw	a0,mscratch,a0
    80005f84:	30200073          	mret
	...

0000000080005f8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f8a:	1141                	add	sp,sp,-16
    80005f8c:	e422                	sd	s0,8(sp)
    80005f8e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f90:	0c0007b7          	lui	a5,0xc000
    80005f94:	4705                	li	a4,1
    80005f96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f98:	0c0007b7          	lui	a5,0xc000
    80005f9c:	c3d8                	sw	a4,4(a5)
}
    80005f9e:	6422                	ld	s0,8(sp)
    80005fa0:	0141                	add	sp,sp,16
    80005fa2:	8082                	ret

0000000080005fa4 <plicinithart>:

void
plicinithart(void)
{
    80005fa4:	1141                	add	sp,sp,-16
    80005fa6:	e406                	sd	ra,8(sp)
    80005fa8:	e022                	sd	s0,0(sp)
    80005faa:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005fac:	ffffc097          	auipc	ra,0xffffc
    80005fb0:	a72080e7          	jalr	-1422(ra) # 80001a1e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fb4:	0085171b          	sllw	a4,a0,0x8
    80005fb8:	0c0027b7          	lui	a5,0xc002
    80005fbc:	97ba                	add	a5,a5,a4
    80005fbe:	40200713          	li	a4,1026
    80005fc2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fc6:	00d5151b          	sllw	a0,a0,0xd
    80005fca:	0c2017b7          	lui	a5,0xc201
    80005fce:	97aa                	add	a5,a5,a0
    80005fd0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005fd4:	60a2                	ld	ra,8(sp)
    80005fd6:	6402                	ld	s0,0(sp)
    80005fd8:	0141                	add	sp,sp,16
    80005fda:	8082                	ret

0000000080005fdc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fdc:	1141                	add	sp,sp,-16
    80005fde:	e406                	sd	ra,8(sp)
    80005fe0:	e022                	sd	s0,0(sp)
    80005fe2:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005fe4:	ffffc097          	auipc	ra,0xffffc
    80005fe8:	a3a080e7          	jalr	-1478(ra) # 80001a1e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fec:	00d5151b          	sllw	a0,a0,0xd
    80005ff0:	0c2017b7          	lui	a5,0xc201
    80005ff4:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ff6:	43c8                	lw	a0,4(a5)
    80005ff8:	60a2                	ld	ra,8(sp)
    80005ffa:	6402                	ld	s0,0(sp)
    80005ffc:	0141                	add	sp,sp,16
    80005ffe:	8082                	ret

0000000080006000 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006000:	1101                	add	sp,sp,-32
    80006002:	ec06                	sd	ra,24(sp)
    80006004:	e822                	sd	s0,16(sp)
    80006006:	e426                	sd	s1,8(sp)
    80006008:	1000                	add	s0,sp,32
    8000600a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000600c:	ffffc097          	auipc	ra,0xffffc
    80006010:	a12080e7          	jalr	-1518(ra) # 80001a1e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006014:	00d5151b          	sllw	a0,a0,0xd
    80006018:	0c2017b7          	lui	a5,0xc201
    8000601c:	97aa                	add	a5,a5,a0
    8000601e:	c3c4                	sw	s1,4(a5)
}
    80006020:	60e2                	ld	ra,24(sp)
    80006022:	6442                	ld	s0,16(sp)
    80006024:	64a2                	ld	s1,8(sp)
    80006026:	6105                	add	sp,sp,32
    80006028:	8082                	ret

000000008000602a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000602a:	1141                	add	sp,sp,-16
    8000602c:	e406                	sd	ra,8(sp)
    8000602e:	e022                	sd	s0,0(sp)
    80006030:	0800                	add	s0,sp,16
  if(i >= NUM)
    80006032:	479d                	li	a5,7
    80006034:	04a7cc63          	blt	a5,a0,8000608c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006038:	0001c797          	auipc	a5,0x1c
    8000603c:	bd878793          	add	a5,a5,-1064 # 80021c10 <disk>
    80006040:	97aa                	add	a5,a5,a0
    80006042:	0187c783          	lbu	a5,24(a5)
    80006046:	ebb9                	bnez	a5,8000609c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006048:	00451693          	sll	a3,a0,0x4
    8000604c:	0001c797          	auipc	a5,0x1c
    80006050:	bc478793          	add	a5,a5,-1084 # 80021c10 <disk>
    80006054:	6398                	ld	a4,0(a5)
    80006056:	9736                	add	a4,a4,a3
    80006058:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000605c:	6398                	ld	a4,0(a5)
    8000605e:	9736                	add	a4,a4,a3
    80006060:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006064:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006068:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000606c:	97aa                	add	a5,a5,a0
    8000606e:	4705                	li	a4,1
    80006070:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006074:	0001c517          	auipc	a0,0x1c
    80006078:	bb450513          	add	a0,a0,-1100 # 80021c28 <disk+0x18>
    8000607c:	ffffc097          	auipc	ra,0xffffc
    80006080:	128080e7          	jalr	296(ra) # 800021a4 <wakeup>
}
    80006084:	60a2                	ld	ra,8(sp)
    80006086:	6402                	ld	s0,0(sp)
    80006088:	0141                	add	sp,sp,16
    8000608a:	8082                	ret
    panic("free_desc 1");
    8000608c:	00002517          	auipc	a0,0x2
    80006090:	59c50513          	add	a0,a0,1436 # 80008628 <etext+0x628>
    80006094:	ffffa097          	auipc	ra,0xffffa
    80006098:	4cc080e7          	jalr	1228(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000609c:	00002517          	auipc	a0,0x2
    800060a0:	59c50513          	add	a0,a0,1436 # 80008638 <etext+0x638>
    800060a4:	ffffa097          	auipc	ra,0xffffa
    800060a8:	4bc080e7          	jalr	1212(ra) # 80000560 <panic>

00000000800060ac <virtio_disk_init>:
{
    800060ac:	1101                	add	sp,sp,-32
    800060ae:	ec06                	sd	ra,24(sp)
    800060b0:	e822                	sd	s0,16(sp)
    800060b2:	e426                	sd	s1,8(sp)
    800060b4:	e04a                	sd	s2,0(sp)
    800060b6:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060b8:	00002597          	auipc	a1,0x2
    800060bc:	59058593          	add	a1,a1,1424 # 80008648 <etext+0x648>
    800060c0:	0001c517          	auipc	a0,0x1c
    800060c4:	c7850513          	add	a0,a0,-904 # 80021d38 <disk+0x128>
    800060c8:	ffffb097          	auipc	ra,0xffffb
    800060cc:	ae0080e7          	jalr	-1312(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060d0:	100017b7          	lui	a5,0x10001
    800060d4:	4398                	lw	a4,0(a5)
    800060d6:	2701                	sext.w	a4,a4
    800060d8:	747277b7          	lui	a5,0x74727
    800060dc:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060e0:	18f71c63          	bne	a4,a5,80006278 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060e4:	100017b7          	lui	a5,0x10001
    800060e8:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800060ea:	439c                	lw	a5,0(a5)
    800060ec:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060ee:	4709                	li	a4,2
    800060f0:	18e79463          	bne	a5,a4,80006278 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060f4:	100017b7          	lui	a5,0x10001
    800060f8:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800060fa:	439c                	lw	a5,0(a5)
    800060fc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060fe:	16e79d63          	bne	a5,a4,80006278 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006102:	100017b7          	lui	a5,0x10001
    80006106:	47d8                	lw	a4,12(a5)
    80006108:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000610a:	554d47b7          	lui	a5,0x554d4
    8000610e:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006112:	16f71363          	bne	a4,a5,80006278 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006116:	100017b7          	lui	a5,0x10001
    8000611a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000611e:	4705                	li	a4,1
    80006120:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006122:	470d                	li	a4,3
    80006124:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006126:	10001737          	lui	a4,0x10001
    8000612a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000612c:	c7ffe737          	lui	a4,0xc7ffe
    80006130:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdca0f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006134:	8ef9                	and	a3,a3,a4
    80006136:	10001737          	lui	a4,0x10001
    8000613a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000613c:	472d                	li	a4,11
    8000613e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006140:	07078793          	add	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006144:	439c                	lw	a5,0(a5)
    80006146:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000614a:	8ba1                	and	a5,a5,8
    8000614c:	12078e63          	beqz	a5,80006288 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006150:	100017b7          	lui	a5,0x10001
    80006154:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006158:	100017b7          	lui	a5,0x10001
    8000615c:	04478793          	add	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006160:	439c                	lw	a5,0(a5)
    80006162:	2781                	sext.w	a5,a5
    80006164:	12079a63          	bnez	a5,80006298 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006168:	100017b7          	lui	a5,0x10001
    8000616c:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006170:	439c                	lw	a5,0(a5)
    80006172:	2781                	sext.w	a5,a5
  if(max == 0)
    80006174:	12078a63          	beqz	a5,800062a8 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006178:	471d                	li	a4,7
    8000617a:	12f77f63          	bgeu	a4,a5,800062b8 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000617e:	ffffb097          	auipc	ra,0xffffb
    80006182:	9ca080e7          	jalr	-1590(ra) # 80000b48 <kalloc>
    80006186:	0001c497          	auipc	s1,0x1c
    8000618a:	a8a48493          	add	s1,s1,-1398 # 80021c10 <disk>
    8000618e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006190:	ffffb097          	auipc	ra,0xffffb
    80006194:	9b8080e7          	jalr	-1608(ra) # 80000b48 <kalloc>
    80006198:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000619a:	ffffb097          	auipc	ra,0xffffb
    8000619e:	9ae080e7          	jalr	-1618(ra) # 80000b48 <kalloc>
    800061a2:	87aa                	mv	a5,a0
    800061a4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800061a6:	6088                	ld	a0,0(s1)
    800061a8:	12050063          	beqz	a0,800062c8 <virtio_disk_init+0x21c>
    800061ac:	0001c717          	auipc	a4,0x1c
    800061b0:	a6c73703          	ld	a4,-1428(a4) # 80021c18 <disk+0x8>
    800061b4:	10070a63          	beqz	a4,800062c8 <virtio_disk_init+0x21c>
    800061b8:	10078863          	beqz	a5,800062c8 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    800061bc:	6605                	lui	a2,0x1
    800061be:	4581                	li	a1,0
    800061c0:	ffffb097          	auipc	ra,0xffffb
    800061c4:	b74080e7          	jalr	-1164(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061c8:	0001c497          	auipc	s1,0x1c
    800061cc:	a4848493          	add	s1,s1,-1464 # 80021c10 <disk>
    800061d0:	6605                	lui	a2,0x1
    800061d2:	4581                	li	a1,0
    800061d4:	6488                	ld	a0,8(s1)
    800061d6:	ffffb097          	auipc	ra,0xffffb
    800061da:	b5e080e7          	jalr	-1186(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    800061de:	6605                	lui	a2,0x1
    800061e0:	4581                	li	a1,0
    800061e2:	6888                	ld	a0,16(s1)
    800061e4:	ffffb097          	auipc	ra,0xffffb
    800061e8:	b50080e7          	jalr	-1200(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061ec:	100017b7          	lui	a5,0x10001
    800061f0:	4721                	li	a4,8
    800061f2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800061f4:	4098                	lw	a4,0(s1)
    800061f6:	100017b7          	lui	a5,0x10001
    800061fa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800061fe:	40d8                	lw	a4,4(s1)
    80006200:	100017b7          	lui	a5,0x10001
    80006204:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006208:	649c                	ld	a5,8(s1)
    8000620a:	0007869b          	sext.w	a3,a5
    8000620e:	10001737          	lui	a4,0x10001
    80006212:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006216:	9781                	sra	a5,a5,0x20
    80006218:	10001737          	lui	a4,0x10001
    8000621c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006220:	689c                	ld	a5,16(s1)
    80006222:	0007869b          	sext.w	a3,a5
    80006226:	10001737          	lui	a4,0x10001
    8000622a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000622e:	9781                	sra	a5,a5,0x20
    80006230:	10001737          	lui	a4,0x10001
    80006234:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006238:	10001737          	lui	a4,0x10001
    8000623c:	4785                	li	a5,1
    8000623e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006240:	00f48c23          	sb	a5,24(s1)
    80006244:	00f48ca3          	sb	a5,25(s1)
    80006248:	00f48d23          	sb	a5,26(s1)
    8000624c:	00f48da3          	sb	a5,27(s1)
    80006250:	00f48e23          	sb	a5,28(s1)
    80006254:	00f48ea3          	sb	a5,29(s1)
    80006258:	00f48f23          	sb	a5,30(s1)
    8000625c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006260:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006264:	100017b7          	lui	a5,0x10001
    80006268:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000626c:	60e2                	ld	ra,24(sp)
    8000626e:	6442                	ld	s0,16(sp)
    80006270:	64a2                	ld	s1,8(sp)
    80006272:	6902                	ld	s2,0(sp)
    80006274:	6105                	add	sp,sp,32
    80006276:	8082                	ret
    panic("could not find virtio disk");
    80006278:	00002517          	auipc	a0,0x2
    8000627c:	3e050513          	add	a0,a0,992 # 80008658 <etext+0x658>
    80006280:	ffffa097          	auipc	ra,0xffffa
    80006284:	2e0080e7          	jalr	736(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006288:	00002517          	auipc	a0,0x2
    8000628c:	3f050513          	add	a0,a0,1008 # 80008678 <etext+0x678>
    80006290:	ffffa097          	auipc	ra,0xffffa
    80006294:	2d0080e7          	jalr	720(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006298:	00002517          	auipc	a0,0x2
    8000629c:	40050513          	add	a0,a0,1024 # 80008698 <etext+0x698>
    800062a0:	ffffa097          	auipc	ra,0xffffa
    800062a4:	2c0080e7          	jalr	704(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    800062a8:	00002517          	auipc	a0,0x2
    800062ac:	41050513          	add	a0,a0,1040 # 800086b8 <etext+0x6b8>
    800062b0:	ffffa097          	auipc	ra,0xffffa
    800062b4:	2b0080e7          	jalr	688(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    800062b8:	00002517          	auipc	a0,0x2
    800062bc:	42050513          	add	a0,a0,1056 # 800086d8 <etext+0x6d8>
    800062c0:	ffffa097          	auipc	ra,0xffffa
    800062c4:	2a0080e7          	jalr	672(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    800062c8:	00002517          	auipc	a0,0x2
    800062cc:	43050513          	add	a0,a0,1072 # 800086f8 <etext+0x6f8>
    800062d0:	ffffa097          	auipc	ra,0xffffa
    800062d4:	290080e7          	jalr	656(ra) # 80000560 <panic>

00000000800062d8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062d8:	7159                	add	sp,sp,-112
    800062da:	f486                	sd	ra,104(sp)
    800062dc:	f0a2                	sd	s0,96(sp)
    800062de:	eca6                	sd	s1,88(sp)
    800062e0:	e8ca                	sd	s2,80(sp)
    800062e2:	e4ce                	sd	s3,72(sp)
    800062e4:	e0d2                	sd	s4,64(sp)
    800062e6:	fc56                	sd	s5,56(sp)
    800062e8:	f85a                	sd	s6,48(sp)
    800062ea:	f45e                	sd	s7,40(sp)
    800062ec:	f062                	sd	s8,32(sp)
    800062ee:	ec66                	sd	s9,24(sp)
    800062f0:	1880                	add	s0,sp,112
    800062f2:	8a2a                	mv	s4,a0
    800062f4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062f6:	00c52c83          	lw	s9,12(a0)
    800062fa:	001c9c9b          	sllw	s9,s9,0x1
    800062fe:	1c82                	sll	s9,s9,0x20
    80006300:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006304:	0001c517          	auipc	a0,0x1c
    80006308:	a3450513          	add	a0,a0,-1484 # 80021d38 <disk+0x128>
    8000630c:	ffffb097          	auipc	ra,0xffffb
    80006310:	92c080e7          	jalr	-1748(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    80006314:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006316:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006318:	0001cb17          	auipc	s6,0x1c
    8000631c:	8f8b0b13          	add	s6,s6,-1800 # 80021c10 <disk>
  for(int i = 0; i < 3; i++){
    80006320:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006322:	0001cc17          	auipc	s8,0x1c
    80006326:	a16c0c13          	add	s8,s8,-1514 # 80021d38 <disk+0x128>
    8000632a:	a0ad                	j	80006394 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    8000632c:	00fb0733          	add	a4,s6,a5
    80006330:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006334:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006336:	0207c563          	bltz	a5,80006360 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000633a:	2905                	addw	s2,s2,1
    8000633c:	0611                	add	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000633e:	05590f63          	beq	s2,s5,8000639c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006342:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006344:	0001c717          	auipc	a4,0x1c
    80006348:	8cc70713          	add	a4,a4,-1844 # 80021c10 <disk>
    8000634c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000634e:	01874683          	lbu	a3,24(a4)
    80006352:	fee9                	bnez	a3,8000632c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006354:	2785                	addw	a5,a5,1
    80006356:	0705                	add	a4,a4,1
    80006358:	fe979be3          	bne	a5,s1,8000634e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000635c:	57fd                	li	a5,-1
    8000635e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006360:	03205163          	blez	s2,80006382 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006364:	f9042503          	lw	a0,-112(s0)
    80006368:	00000097          	auipc	ra,0x0
    8000636c:	cc2080e7          	jalr	-830(ra) # 8000602a <free_desc>
      for(int j = 0; j < i; j++)
    80006370:	4785                	li	a5,1
    80006372:	0127d863          	bge	a5,s2,80006382 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006376:	f9442503          	lw	a0,-108(s0)
    8000637a:	00000097          	auipc	ra,0x0
    8000637e:	cb0080e7          	jalr	-848(ra) # 8000602a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006382:	85e2                	mv	a1,s8
    80006384:	0001c517          	auipc	a0,0x1c
    80006388:	8a450513          	add	a0,a0,-1884 # 80021c28 <disk+0x18>
    8000638c:	ffffc097          	auipc	ra,0xffffc
    80006390:	db4080e7          	jalr	-588(ra) # 80002140 <sleep>
  for(int i = 0; i < 3; i++){
    80006394:	f9040613          	add	a2,s0,-112
    80006398:	894e                	mv	s2,s3
    8000639a:	b765                	j	80006342 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000639c:	f9042503          	lw	a0,-112(s0)
    800063a0:	00451693          	sll	a3,a0,0x4

  if(write)
    800063a4:	0001c797          	auipc	a5,0x1c
    800063a8:	86c78793          	add	a5,a5,-1940 # 80021c10 <disk>
    800063ac:	00a50713          	add	a4,a0,10
    800063b0:	0712                	sll	a4,a4,0x4
    800063b2:	973e                	add	a4,a4,a5
    800063b4:	01703633          	snez	a2,s7
    800063b8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800063ba:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800063be:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063c2:	6398                	ld	a4,0(a5)
    800063c4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063c6:	0a868613          	add	a2,a3,168
    800063ca:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063cc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063ce:	6390                	ld	a2,0(a5)
    800063d0:	00d605b3          	add	a1,a2,a3
    800063d4:	4741                	li	a4,16
    800063d6:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063d8:	4805                	li	a6,1
    800063da:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800063de:	f9442703          	lw	a4,-108(s0)
    800063e2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063e6:	0712                	sll	a4,a4,0x4
    800063e8:	963a                	add	a2,a2,a4
    800063ea:	058a0593          	add	a1,s4,88
    800063ee:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800063f0:	0007b883          	ld	a7,0(a5)
    800063f4:	9746                	add	a4,a4,a7
    800063f6:	40000613          	li	a2,1024
    800063fa:	c710                	sw	a2,8(a4)
  if(write)
    800063fc:	001bb613          	seqz	a2,s7
    80006400:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006404:	00166613          	or	a2,a2,1
    80006408:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000640c:	f9842583          	lw	a1,-104(s0)
    80006410:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006414:	00250613          	add	a2,a0,2
    80006418:	0612                	sll	a2,a2,0x4
    8000641a:	963e                	add	a2,a2,a5
    8000641c:	577d                	li	a4,-1
    8000641e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006422:	0592                	sll	a1,a1,0x4
    80006424:	98ae                	add	a7,a7,a1
    80006426:	03068713          	add	a4,a3,48
    8000642a:	973e                	add	a4,a4,a5
    8000642c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006430:	6398                	ld	a4,0(a5)
    80006432:	972e                	add	a4,a4,a1
    80006434:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006438:	4689                	li	a3,2
    8000643a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    8000643e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006442:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006446:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000644a:	6794                	ld	a3,8(a5)
    8000644c:	0026d703          	lhu	a4,2(a3)
    80006450:	8b1d                	and	a4,a4,7
    80006452:	0706                	sll	a4,a4,0x1
    80006454:	96ba                	add	a3,a3,a4
    80006456:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000645a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000645e:	6798                	ld	a4,8(a5)
    80006460:	00275783          	lhu	a5,2(a4)
    80006464:	2785                	addw	a5,a5,1
    80006466:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000646a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000646e:	100017b7          	lui	a5,0x10001
    80006472:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006476:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000647a:	0001c917          	auipc	s2,0x1c
    8000647e:	8be90913          	add	s2,s2,-1858 # 80021d38 <disk+0x128>
  while(b->disk == 1) {
    80006482:	4485                	li	s1,1
    80006484:	01079c63          	bne	a5,a6,8000649c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006488:	85ca                	mv	a1,s2
    8000648a:	8552                	mv	a0,s4
    8000648c:	ffffc097          	auipc	ra,0xffffc
    80006490:	cb4080e7          	jalr	-844(ra) # 80002140 <sleep>
  while(b->disk == 1) {
    80006494:	004a2783          	lw	a5,4(s4)
    80006498:	fe9788e3          	beq	a5,s1,80006488 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000649c:	f9042903          	lw	s2,-112(s0)
    800064a0:	00290713          	add	a4,s2,2
    800064a4:	0712                	sll	a4,a4,0x4
    800064a6:	0001b797          	auipc	a5,0x1b
    800064aa:	76a78793          	add	a5,a5,1898 # 80021c10 <disk>
    800064ae:	97ba                	add	a5,a5,a4
    800064b0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800064b4:	0001b997          	auipc	s3,0x1b
    800064b8:	75c98993          	add	s3,s3,1884 # 80021c10 <disk>
    800064bc:	00491713          	sll	a4,s2,0x4
    800064c0:	0009b783          	ld	a5,0(s3)
    800064c4:	97ba                	add	a5,a5,a4
    800064c6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064ca:	854a                	mv	a0,s2
    800064cc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064d0:	00000097          	auipc	ra,0x0
    800064d4:	b5a080e7          	jalr	-1190(ra) # 8000602a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064d8:	8885                	and	s1,s1,1
    800064da:	f0ed                	bnez	s1,800064bc <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064dc:	0001c517          	auipc	a0,0x1c
    800064e0:	85c50513          	add	a0,a0,-1956 # 80021d38 <disk+0x128>
    800064e4:	ffffb097          	auipc	ra,0xffffb
    800064e8:	808080e7          	jalr	-2040(ra) # 80000cec <release>
}
    800064ec:	70a6                	ld	ra,104(sp)
    800064ee:	7406                	ld	s0,96(sp)
    800064f0:	64e6                	ld	s1,88(sp)
    800064f2:	6946                	ld	s2,80(sp)
    800064f4:	69a6                	ld	s3,72(sp)
    800064f6:	6a06                	ld	s4,64(sp)
    800064f8:	7ae2                	ld	s5,56(sp)
    800064fa:	7b42                	ld	s6,48(sp)
    800064fc:	7ba2                	ld	s7,40(sp)
    800064fe:	7c02                	ld	s8,32(sp)
    80006500:	6ce2                	ld	s9,24(sp)
    80006502:	6165                	add	sp,sp,112
    80006504:	8082                	ret

0000000080006506 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006506:	1101                	add	sp,sp,-32
    80006508:	ec06                	sd	ra,24(sp)
    8000650a:	e822                	sd	s0,16(sp)
    8000650c:	e426                	sd	s1,8(sp)
    8000650e:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006510:	0001b497          	auipc	s1,0x1b
    80006514:	70048493          	add	s1,s1,1792 # 80021c10 <disk>
    80006518:	0001c517          	auipc	a0,0x1c
    8000651c:	82050513          	add	a0,a0,-2016 # 80021d38 <disk+0x128>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	718080e7          	jalr	1816(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006528:	100017b7          	lui	a5,0x10001
    8000652c:	53b8                	lw	a4,96(a5)
    8000652e:	8b0d                	and	a4,a4,3
    80006530:	100017b7          	lui	a5,0x10001
    80006534:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006536:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000653a:	689c                	ld	a5,16(s1)
    8000653c:	0204d703          	lhu	a4,32(s1)
    80006540:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006544:	04f70863          	beq	a4,a5,80006594 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006548:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000654c:	6898                	ld	a4,16(s1)
    8000654e:	0204d783          	lhu	a5,32(s1)
    80006552:	8b9d                	and	a5,a5,7
    80006554:	078e                	sll	a5,a5,0x3
    80006556:	97ba                	add	a5,a5,a4
    80006558:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000655a:	00278713          	add	a4,a5,2
    8000655e:	0712                	sll	a4,a4,0x4
    80006560:	9726                	add	a4,a4,s1
    80006562:	01074703          	lbu	a4,16(a4)
    80006566:	e721                	bnez	a4,800065ae <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006568:	0789                	add	a5,a5,2
    8000656a:	0792                	sll	a5,a5,0x4
    8000656c:	97a6                	add	a5,a5,s1
    8000656e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006570:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006574:	ffffc097          	auipc	ra,0xffffc
    80006578:	c30080e7          	jalr	-976(ra) # 800021a4 <wakeup>

    disk.used_idx += 1;
    8000657c:	0204d783          	lhu	a5,32(s1)
    80006580:	2785                	addw	a5,a5,1
    80006582:	17c2                	sll	a5,a5,0x30
    80006584:	93c1                	srl	a5,a5,0x30
    80006586:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000658a:	6898                	ld	a4,16(s1)
    8000658c:	00275703          	lhu	a4,2(a4)
    80006590:	faf71ce3          	bne	a4,a5,80006548 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006594:	0001b517          	auipc	a0,0x1b
    80006598:	7a450513          	add	a0,a0,1956 # 80021d38 <disk+0x128>
    8000659c:	ffffa097          	auipc	ra,0xffffa
    800065a0:	750080e7          	jalr	1872(ra) # 80000cec <release>
}
    800065a4:	60e2                	ld	ra,24(sp)
    800065a6:	6442                	ld	s0,16(sp)
    800065a8:	64a2                	ld	s1,8(sp)
    800065aa:	6105                	add	sp,sp,32
    800065ac:	8082                	ret
      panic("virtio_disk_intr status");
    800065ae:	00002517          	auipc	a0,0x2
    800065b2:	16250513          	add	a0,a0,354 # 80008710 <etext+0x710>
    800065b6:	ffffa097          	auipc	ra,0xffffa
    800065ba:	faa080e7          	jalr	-86(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
