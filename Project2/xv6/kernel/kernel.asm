
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8a013103          	ld	sp,-1888(sp) # 800088a0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8ae70713          	addi	a4,a4,-1874 # 80008900 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	d8c78793          	addi	a5,a5,-628 # 80005df0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca8f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de678793          	addi	a5,a5,-538 # 80000e94 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	3ea080e7          	jalr	1002(ra) # 80002516 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	794080e7          	jalr	1940(ra) # 800008d0 <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	8b450513          	addi	a0,a0,-1868 # 80010a40 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	8a448493          	addi	s1,s1,-1884 # 80010a40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	93290913          	addi	s2,s2,-1742 # 80010ad8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405b63          	blez	s4,8000022a <consoleread+0xc6>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71763          	bne	a4,a5,800001ee <consoleread+0x8a>
      if(killed(myproc())){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	802080e7          	jalr	-2046(ra) # 800019c6 <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	194080e7          	jalr	404(ra) # 80002360 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	ede080e7          	jalr	-290(ra) # 800020b8 <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fcf70de3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000204:	079c0663          	beq	s8,s9,80000270 <consoleread+0x10c>
    cbuf = c;
    80000208:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f8f40613          	addi	a2,s0,-113
    80000212:	85d6                	mv	a1,s5
    80000214:	855a                	mv	a0,s6
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	2aa080e7          	jalr	682(ra) # 800024c0 <either_copyout>
    8000021e:	01a50663          	beq	a0,s10,8000022a <consoleread+0xc6>
    dst++;
    80000222:	0a85                	addi	s5,s5,1
    --n;
    80000224:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000226:	f9bc17e3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	81650513          	addi	a0,a0,-2026 # 80010a40 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	80050513          	addi	a0,a0,-2048 # 80010a40 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	a56080e7          	jalr	-1450(ra) # 80000c9e <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70e6                	ld	ra,120(sp)
    80000254:	7446                	ld	s0,112(sp)
    80000256:	74a6                	ld	s1,104(sp)
    80000258:	7906                	ld	s2,96(sp)
    8000025a:	69e6                	ld	s3,88(sp)
    8000025c:	6a46                	ld	s4,80(sp)
    8000025e:	6aa6                	ld	s5,72(sp)
    80000260:	6b06                	ld	s6,64(sp)
    80000262:	7be2                	ld	s7,56(sp)
    80000264:	7c42                	ld	s8,48(sp)
    80000266:	7ca2                	ld	s9,40(sp)
    80000268:	7d02                	ld	s10,32(sp)
    8000026a:	6de2                	ld	s11,24(sp)
    8000026c:	6109                	addi	sp,sp,128
    8000026e:	8082                	ret
      if(n < target){
    80000270:	000a071b          	sext.w	a4,s4
    80000274:	fb777be3          	bgeu	a4,s7,8000022a <consoleread+0xc6>
        cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	86f72023          	sw	a5,-1952(a4) # 80010ad8 <cons+0x98>
    80000280:	b76d                	j	8000022a <consoleread+0xc6>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
    uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	564080e7          	jalr	1380(ra) # 800007f6 <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	552080e7          	jalr	1362(ra) # 800007f6 <uartputc_sync>
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	546080e7          	jalr	1350(ra) # 800007f6 <uartputc_sync>
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	53c080e7          	jalr	1340(ra) # 800007f6 <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d2:	00010517          	auipc	a0,0x10
    800002d6:	76e50513          	addi	a0,a0,1902 # 80010a40 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	910080e7          	jalr	-1776(ra) # 80000bea <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	274080e7          	jalr	628(ra) # 8000256c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00010517          	auipc	a0,0x10
    80000304:	74050513          	addi	a0,a0,1856 # 80010a40 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	996080e7          	jalr	-1642(ra) # 80000c9e <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
  switch(c){
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000324:	00010717          	auipc	a4,0x10
    80000328:	71c70713          	addi	a4,a4,1820 # 80010a40 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
      consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000034e:	00010797          	auipc	a5,0x10
    80000352:	6f278793          	addi	a5,a5,1778 # 80010a40 <cons>
    80000356:	0a07a683          	lw	a3,160(a5)
    8000035a:	0016871b          	addiw	a4,a3,1
    8000035e:	0007061b          	sext.w	a2,a4
    80000362:	0ae7a023          	sw	a4,160(a5)
    80000366:	07f6f693          	andi	a3,a3,127
    8000036a:	97b6                	add	a5,a5,a3
    8000036c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00010797          	auipc	a5,0x10
    80000380:	75c7a783          	lw	a5,1884(a5) # 80010ad8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00010717          	auipc	a4,0x10
    80000394:	6b070713          	addi	a4,a4,1712 # 80010a40 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00010497          	auipc	s1,0x10
    800003a4:	6a048493          	addi	s1,s1,1696 # 80010a40 <cons>
    while(cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
      cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
    while(cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003dc:	00010717          	auipc	a4,0x10
    800003e0:	66470713          	addi	a4,a4,1636 # 80010a40 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00010717          	auipc	a4,0x10
    800003f6:	6ef72723          	sw	a5,1774(a4) # 80010ae0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
      consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000418:	00010797          	auipc	a5,0x10
    8000041c:	62878793          	addi	a5,a5,1576 # 80010a40 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00010797          	auipc	a5,0x10
    80000440:	6ac7a023          	sw	a2,1696(a5) # 80010adc <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00010517          	auipc	a0,0x10
    80000448:	69450513          	addi	a0,a0,1684 # 80010ad8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	cd0080e7          	jalr	-816(ra) # 8000211c <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void
consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00010517          	auipc	a0,0x10
    8000046a:	5da50513          	addi	a0,a0,1498 # 80010a40 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00020797          	auipc	a5,0x20
    80000482:	75a78793          	addi	a5,a5,1882 # 80020bd8 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cde70713          	addi	a4,a4,-802 # 80000164 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c7270713          	addi	a4,a4,-910 # 80000102 <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054663          	bltz	a0,8000053c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004bc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004be:	2581                	sext.w	a1,a1
    800004c0:	00008617          	auipc	a2,0x8
    800004c4:	b8060613          	addi	a2,a2,-1152 # 80008040 <digits>
    800004c8:	883a                	mv	a6,a4
    800004ca:	2705                	addiw	a4,a4,1
    800004cc:	02b577bb          	remuw	a5,a0,a1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	97b2                	add	a5,a5,a2
    800004d6:	0007c783          	lbu	a5,0(a5)
    800004da:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>

  if(sign)
    800004ec:	00088b63          	beqz	a7,80000502 <printint+0x60>
    buf[i++] = '-';
    800004f0:	fe040793          	addi	a5,s0,-32
    800004f4:	973e                	add	a4,a4,a5
    800004f6:	02d00793          	li	a5,45
    800004fa:	fef70823          	sb	a5,-16(a4)
    800004fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000502:	02e05763          	blez	a4,80000530 <printint+0x8e>
    80000506:	fd040793          	addi	a5,s0,-48
    8000050a:	00e784b3          	add	s1,a5,a4
    8000050e:	fff78913          	addi	s2,a5,-1
    80000512:	993a                	add	s2,s2,a4
    80000514:	377d                	addiw	a4,a4,-1
    80000516:	1702                	slli	a4,a4,0x20
    80000518:	9301                	srli	a4,a4,0x20
    8000051a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051e:	fff4c503          	lbu	a0,-1(s1)
    80000522:	00000097          	auipc	ra,0x0
    80000526:	d60080e7          	jalr	-672(ra) # 80000282 <consputc>
  while(--i >= 0)
    8000052a:	14fd                	addi	s1,s1,-1
    8000052c:	ff2499e3          	bne	s1,s2,8000051e <printint+0x7c>
}
    80000530:	70a2                	ld	ra,40(sp)
    80000532:	7402                	ld	s0,32(sp)
    80000534:	64e2                	ld	s1,24(sp)
    80000536:	6942                	ld	s2,16(sp)
    80000538:	6145                	addi	sp,sp,48
    8000053a:	8082                	ret
    x = -xx;
    8000053c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000540:	4885                	li	a7,1
    x = -xx;
    80000542:	bf9d                	j	800004b8 <printint+0x16>

0000000080000544 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000544:	1101                	addi	sp,sp,-32
    80000546:	ec06                	sd	ra,24(sp)
    80000548:	e822                	sd	s0,16(sp)
    8000054a:	e426                	sd	s1,8(sp)
    8000054c:	1000                	addi	s0,sp,32
    8000054e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000550:	00010797          	auipc	a5,0x10
    80000554:	5a07a823          	sw	zero,1456(a5) # 80010b00 <pr+0x18>
  printf("panic: ");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <etext+0x18>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	02e080e7          	jalr	46(ra) # 8000058e <printf>
  printf(s);
    80000568:	8526                	mv	a0,s1
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	024080e7          	jalr	36(ra) # 8000058e <printf>
  printf("\n");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	b5650513          	addi	a0,a0,-1194 # 800080c8 <digits+0x88>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	32f72e23          	sw	a5,828(a4) # 800088c0 <panicked>
  for(;;)
    8000058c:	a001                	j	8000058c <panic+0x48>

000000008000058e <printf>:
{
    8000058e:	7131                	addi	sp,sp,-192
    80000590:	fc86                	sd	ra,120(sp)
    80000592:	f8a2                	sd	s0,112(sp)
    80000594:	f4a6                	sd	s1,104(sp)
    80000596:	f0ca                	sd	s2,96(sp)
    80000598:	ecce                	sd	s3,88(sp)
    8000059a:	e8d2                	sd	s4,80(sp)
    8000059c:	e4d6                	sd	s5,72(sp)
    8000059e:	e0da                	sd	s6,64(sp)
    800005a0:	fc5e                	sd	s7,56(sp)
    800005a2:	f862                	sd	s8,48(sp)
    800005a4:	f466                	sd	s9,40(sp)
    800005a6:	f06a                	sd	s10,32(sp)
    800005a8:	ec6e                	sd	s11,24(sp)
    800005aa:	0100                	addi	s0,sp,128
    800005ac:	8a2a                	mv	s4,a0
    800005ae:	e40c                	sd	a1,8(s0)
    800005b0:	e810                	sd	a2,16(s0)
    800005b2:	ec14                	sd	a3,24(s0)
    800005b4:	f018                	sd	a4,32(s0)
    800005b6:	f41c                	sd	a5,40(s0)
    800005b8:	03043823          	sd	a6,48(s0)
    800005bc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c0:	00010d97          	auipc	s11,0x10
    800005c4:	540dad83          	lw	s11,1344(s11) # 80010b00 <pr+0x18>
  if(locking)
    800005c8:	020d9b63          	bnez	s11,800005fe <printf+0x70>
  if (fmt == 0)
    800005cc:	040a0263          	beqz	s4,80000610 <printf+0x82>
  va_start(ap, fmt);
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	16050263          	beqz	a0,80000740 <printf+0x1b2>
    800005e0:	4481                	li	s1,0
    if(c != '%'){
    800005e2:	02500a93          	li	s5,37
    switch(c){
    800005e6:	07000b13          	li	s6,112
  consputc('x');
    800005ea:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ec:	00008b97          	auipc	s7,0x8
    800005f0:	a54b8b93          	addi	s7,s7,-1452 # 80008040 <digits>
    switch(c){
    800005f4:	07300c93          	li	s9,115
    800005f8:	06400c13          	li	s8,100
    800005fc:	a82d                	j	80000636 <printf+0xa8>
    acquire(&pr.lock);
    800005fe:	00010517          	auipc	a0,0x10
    80000602:	4ea50513          	addi	a0,a0,1258 # 80010ae8 <pr>
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	5e4080e7          	jalr	1508(ra) # 80000bea <acquire>
    8000060e:	bf7d                	j	800005cc <printf+0x3e>
    panic("null fmt");
    80000610:	00008517          	auipc	a0,0x8
    80000614:	a1850513          	addi	a0,a0,-1512 # 80008028 <etext+0x28>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	f2c080e7          	jalr	-212(ra) # 80000544 <panic>
      consputc(c);
    80000620:	00000097          	auipc	ra,0x0
    80000624:	c62080e7          	jalr	-926(ra) # 80000282 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000628:	2485                	addiw	s1,s1,1
    8000062a:	009a07b3          	add	a5,s4,s1
    8000062e:	0007c503          	lbu	a0,0(a5)
    80000632:	10050763          	beqz	a0,80000740 <printf+0x1b2>
    if(c != '%'){
    80000636:	ff5515e3          	bne	a0,s5,80000620 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063a:	2485                	addiw	s1,s1,1
    8000063c:	009a07b3          	add	a5,s4,s1
    80000640:	0007c783          	lbu	a5,0(a5)
    80000644:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000648:	cfe5                	beqz	a5,80000740 <printf+0x1b2>
    switch(c){
    8000064a:	05678a63          	beq	a5,s6,8000069e <printf+0x110>
    8000064e:	02fb7663          	bgeu	s6,a5,8000067a <printf+0xec>
    80000652:	09978963          	beq	a5,s9,800006e4 <printf+0x156>
    80000656:	07800713          	li	a4,120
    8000065a:	0ce79863          	bne	a5,a4,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4605                	li	a2,1
    8000066c:	85ea                	mv	a1,s10
    8000066e:	4388                	lw	a0,0(a5)
    80000670:	00000097          	auipc	ra,0x0
    80000674:	e32080e7          	jalr	-462(ra) # 800004a2 <printint>
      break;
    80000678:	bf45                	j	80000628 <printf+0x9a>
    switch(c){
    8000067a:	0b578263          	beq	a5,s5,8000071e <printf+0x190>
    8000067e:	0b879663          	bne	a5,s8,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4605                	li	a2,1
    80000690:	45a9                	li	a1,10
    80000692:	4388                	lw	a0,0(a5)
    80000694:	00000097          	auipc	ra,0x0
    80000698:	e0e080e7          	jalr	-498(ra) # 800004a2 <printint>
      break;
    8000069c:	b771                	j	80000628 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ae:	03000513          	li	a0,48
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bd0080e7          	jalr	-1072(ra) # 80000282 <consputc>
  consputc('x');
    800006ba:	07800513          	li	a0,120
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bc4080e7          	jalr	-1084(ra) # 80000282 <consputc>
    800006c6:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c8:	03c9d793          	srli	a5,s3,0x3c
    800006cc:	97de                	add	a5,a5,s7
    800006ce:	0007c503          	lbu	a0,0(a5)
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	bb0080e7          	jalr	-1104(ra) # 80000282 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006da:	0992                	slli	s3,s3,0x4
    800006dc:	397d                	addiw	s2,s2,-1
    800006de:	fe0915e3          	bnez	s2,800006c8 <printf+0x13a>
    800006e2:	b799                	j	80000628 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	0007b903          	ld	s2,0(a5)
    800006f4:	00090e63          	beqz	s2,80000710 <printf+0x182>
      for(; *s; s++)
    800006f8:	00094503          	lbu	a0,0(s2)
    800006fc:	d515                	beqz	a0,80000628 <printf+0x9a>
        consputc(*s);
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	b84080e7          	jalr	-1148(ra) # 80000282 <consputc>
      for(; *s; s++)
    80000706:	0905                	addi	s2,s2,1
    80000708:	00094503          	lbu	a0,0(s2)
    8000070c:	f96d                	bnez	a0,800006fe <printf+0x170>
    8000070e:	bf29                	j	80000628 <printf+0x9a>
        s = "(null)";
    80000710:	00008917          	auipc	s2,0x8
    80000714:	91090913          	addi	s2,s2,-1776 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000718:	02800513          	li	a0,40
    8000071c:	b7cd                	j	800006fe <printf+0x170>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b62080e7          	jalr	-1182(ra) # 80000282 <consputc>
      break;
    80000728:	b701                	j	80000628 <printf+0x9a>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b56080e7          	jalr	-1194(ra) # 80000282 <consputc>
      consputc(c);
    80000734:	854a                	mv	a0,s2
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	b4c080e7          	jalr	-1204(ra) # 80000282 <consputc>
      break;
    8000073e:	b5ed                	j	80000628 <printf+0x9a>
  if(locking)
    80000740:	020d9163          	bnez	s11,80000762 <printf+0x1d4>
}
    80000744:	70e6                	ld	ra,120(sp)
    80000746:	7446                	ld	s0,112(sp)
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	7906                	ld	s2,96(sp)
    8000074c:	69e6                	ld	s3,88(sp)
    8000074e:	6a46                	ld	s4,80(sp)
    80000750:	6aa6                	ld	s5,72(sp)
    80000752:	6b06                	ld	s6,64(sp)
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	7c42                	ld	s8,48(sp)
    80000758:	7ca2                	ld	s9,40(sp)
    8000075a:	7d02                	ld	s10,32(sp)
    8000075c:	6de2                	ld	s11,24(sp)
    8000075e:	6129                	addi	sp,sp,192
    80000760:	8082                	ret
    release(&pr.lock);
    80000762:	00010517          	auipc	a0,0x10
    80000766:	38650513          	addi	a0,a0,902 # 80010ae8 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	534080e7          	jalr	1332(ra) # 80000c9e <release>
}
    80000772:	bfc9                	j	80000744 <printf+0x1b6>

0000000080000774 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077e:	00010497          	auipc	s1,0x10
    80000782:	36a48493          	addi	s1,s1,874 # 80010ae8 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	3ca080e7          	jalr	970(ra) # 80000b5a <initlock>
  pr.locking = 1;
    80000798:	4785                	li	a5,1
    8000079a:	cc9c                	sw	a5,24(s1)
}
    8000079c:	60e2                	ld	ra,24(sp)
    8000079e:	6442                	ld	s0,16(sp)
    800007a0:	64a2                	ld	s1,8(sp)
    800007a2:	6105                	addi	sp,sp,32
    800007a4:	8082                	ret

00000000800007a6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a6:	1141                	addi	sp,sp,-16
    800007a8:	e406                	sd	ra,8(sp)
    800007aa:	e022                	sd	s0,0(sp)
    800007ac:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ae:	100007b7          	lui	a5,0x10000
    800007b2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b6:	f8000713          	li	a4,-128
    800007ba:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007be:	470d                	li	a4,3
    800007c0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007cc:	469d                	li	a3,7
    800007ce:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	88258593          	addi	a1,a1,-1918 # 80008058 <digits+0x18>
    800007de:	00010517          	auipc	a0,0x10
    800007e2:	32a50513          	addi	a0,a0,810 # 80010b08 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	374080e7          	jalr	884(ra) # 80000b5a <initlock>
}
    800007ee:	60a2                	ld	ra,8(sp)
    800007f0:	6402                	ld	s0,0(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f6:	1101                	addi	sp,sp,-32
    800007f8:	ec06                	sd	ra,24(sp)
    800007fa:	e822                	sd	s0,16(sp)
    800007fc:	e426                	sd	s1,8(sp)
    800007fe:	1000                	addi	s0,sp,32
    80000800:	84aa                	mv	s1,a0
  push_off();
    80000802:	00000097          	auipc	ra,0x0
    80000806:	39c080e7          	jalr	924(ra) # 80000b9e <push_off>

  if(panicked){
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	0b67a783          	lw	a5,182(a5) # 800088c0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	10000737          	lui	a4,0x10000
  if(panicked){
    80000816:	c391                	beqz	a5,8000081a <uartputc_sync+0x24>
    for(;;)
    80000818:	a001                	j	80000818 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081e:	0ff7f793          	andi	a5,a5,255
    80000822:	0207f793          	andi	a5,a5,32
    80000826:	dbf5                	beqz	a5,8000081a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000828:	0ff4f793          	andi	a5,s1,255
    8000082c:	10000737          	lui	a4,0x10000
    80000830:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000834:	00000097          	auipc	ra,0x0
    80000838:	40a080e7          	jalr	1034(ra) # 80000c3e <pop_off>
}
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6105                	addi	sp,sp,32
    80000844:	8082                	ret

0000000080000846 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000846:	00008717          	auipc	a4,0x8
    8000084a:	08273703          	ld	a4,130(a4) # 800088c8 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	0827b783          	ld	a5,130(a5) # 800088d0 <uart_tx_w>
    80000856:	06e78c63          	beq	a5,a4,800008ce <uartstart+0x88>
{
    8000085a:	7139                	addi	sp,sp,-64
    8000085c:	fc06                	sd	ra,56(sp)
    8000085e:	f822                	sd	s0,48(sp)
    80000860:	f426                	sd	s1,40(sp)
    80000862:	f04a                	sd	s2,32(sp)
    80000864:	ec4e                	sd	s3,24(sp)
    80000866:	e852                	sd	s4,16(sp)
    80000868:	e456                	sd	s5,8(sp)
    8000086a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000086c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000870:	00010a17          	auipc	s4,0x10
    80000874:	298a0a13          	addi	s4,s4,664 # 80010b08 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	05048493          	addi	s1,s1,80 # 800088c8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	05098993          	addi	s3,s3,80 # 800088d0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000888:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088c:	0ff7f793          	andi	a5,a5,255
    80000890:	0207f793          	andi	a5,a5,32
    80000894:	c785                	beqz	a5,800008bc <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f77793          	andi	a5,a4,31
    8000089a:	97d2                	add	a5,a5,s4
    8000089c:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800008a0:	0705                	addi	a4,a4,1
    800008a2:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	876080e7          	jalr	-1930(ra) # 8000211c <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	6098                	ld	a4,0(s1)
    800008b4:	0009b783          	ld	a5,0(s3)
    800008b8:	fce798e3          	bne	a5,a4,80000888 <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	22650513          	addi	a0,a0,550 # 80010b08 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	fce7a783          	lw	a5,-50(a5) # 800088c0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	fd47b783          	ld	a5,-44(a5) # 800088d0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	fc473703          	ld	a4,-60(a4) # 800088c8 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	1f8a0a13          	addi	s4,s4,504 # 80010b08 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	fb048493          	addi	s1,s1,-80 # 800088c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	fb090913          	addi	s2,s2,-80 # 800088d0 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00001097          	auipc	ra,0x1
    80000934:	788080e7          	jalr	1928(ra) # 800020b8 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	1c248493          	addi	s1,s1,450 # 80010b08 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	f6f73b23          	sd	a5,-138(a4) # 800088d0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee4080e7          	jalr	-284(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	332080e7          	jalr	818(ra) # 80000c9e <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb91                	beqz	a5,800009aa <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009a0:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009a4:	6422                	ld	s0,8(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    return -1;
    800009aa:	557d                	li	a0,-1
    800009ac:	bfe5                	j	800009a4 <uartgetc+0x1e>

00000000800009ae <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b8:	54fd                	li	s1,-1
    int c = uartgetc();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	fcc080e7          	jalr	-52(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c2:	00950763          	beq	a0,s1,800009d0 <uartintr+0x22>
      break;
    consoleintr(c);
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	8fe080e7          	jalr	-1794(ra) # 800002c4 <consoleintr>
  while(1){
    800009ce:	b7f5                	j	800009ba <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009d0:	00010497          	auipc	s1,0x10
    800009d4:	13848493          	addi	s1,s1,312 # 80010b08 <uart_tx_lock>
    800009d8:	8526                	mv	a0,s1
    800009da:	00000097          	auipc	ra,0x0
    800009de:	210080e7          	jalr	528(ra) # 80000bea <acquire>
  uartstart();
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	e64080e7          	jalr	-412(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    800009ea:	8526                	mv	a0,s1
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	2b2080e7          	jalr	690(ra) # 80000c9e <release>
}
    800009f4:	60e2                	ld	ra,24(sp)
    800009f6:	6442                	ld	s0,16(sp)
    800009f8:	64a2                	ld	s1,8(sp)
    800009fa:	6105                	addi	sp,sp,32
    800009fc:	8082                	ret

00000000800009fe <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009fe:	1101                	addi	sp,sp,-32
    80000a00:	ec06                	sd	ra,24(sp)
    80000a02:	e822                	sd	s0,16(sp)
    80000a04:	e426                	sd	s1,8(sp)
    80000a06:	e04a                	sd	s2,0(sp)
    80000a08:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a0a:	03451793          	slli	a5,a0,0x34
    80000a0e:	ebb9                	bnez	a5,80000a64 <kfree+0x66>
    80000a10:	84aa                	mv	s1,a0
    80000a12:	00021797          	auipc	a5,0x21
    80000a16:	35e78793          	addi	a5,a5,862 # 80021d70 <end>
    80000a1a:	04f56563          	bltu	a0,a5,80000a64 <kfree+0x66>
    80000a1e:	47c5                	li	a5,17
    80000a20:	07ee                	slli	a5,a5,0x1b
    80000a22:	04f57163          	bgeu	a0,a5,80000a64 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a26:	6605                	lui	a2,0x1
    80000a28:	4585                	li	a1,1
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	2bc080e7          	jalr	700(ra) # 80000ce6 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a32:	00010917          	auipc	s2,0x10
    80000a36:	10e90913          	addi	s2,s2,270 # 80010b40 <kmem>
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	1ae080e7          	jalr	430(ra) # 80000bea <acquire>
  r->next = kmem.freelist;
    80000a44:	01893783          	ld	a5,24(s2)
    80000a48:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a4a:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	24e080e7          	jalr	590(ra) # 80000c9e <release>
}
    80000a58:	60e2                	ld	ra,24(sp)
    80000a5a:	6442                	ld	s0,16(sp)
    80000a5c:	64a2                	ld	s1,8(sp)
    80000a5e:	6902                	ld	s2,0(sp)
    80000a60:	6105                	addi	sp,sp,32
    80000a62:	8082                	ret
    panic("kfree");
    80000a64:	00007517          	auipc	a0,0x7
    80000a68:	5fc50513          	addi	a0,a0,1532 # 80008060 <digits+0x20>
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	ad8080e7          	jalr	-1320(ra) # 80000544 <panic>

0000000080000a74 <freerange>:
{
    80000a74:	7179                	addi	sp,sp,-48
    80000a76:	f406                	sd	ra,40(sp)
    80000a78:	f022                	sd	s0,32(sp)
    80000a7a:	ec26                	sd	s1,24(sp)
    80000a7c:	e84a                	sd	s2,16(sp)
    80000a7e:	e44e                	sd	s3,8(sp)
    80000a80:	e052                	sd	s4,0(sp)
    80000a82:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a84:	6785                	lui	a5,0x1
    80000a86:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a8a:	94aa                	add	s1,s1,a0
    80000a8c:	757d                	lui	a0,0xfffff
    80000a8e:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94be                	add	s1,s1,a5
    80000a92:	0095ee63          	bltu	a1,s1,80000aae <freerange+0x3a>
    80000a96:	892e                	mv	s2,a1
    kfree(p);
    80000a98:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	6985                	lui	s3,0x1
    kfree(p);
    80000a9c:	01448533          	add	a0,s1,s4
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	f5e080e7          	jalr	-162(ra) # 800009fe <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa8:	94ce                	add	s1,s1,s3
    80000aaa:	fe9979e3          	bgeu	s2,s1,80000a9c <freerange+0x28>
}
    80000aae:	70a2                	ld	ra,40(sp)
    80000ab0:	7402                	ld	s0,32(sp)
    80000ab2:	64e2                	ld	s1,24(sp)
    80000ab4:	6942                	ld	s2,16(sp)
    80000ab6:	69a2                	ld	s3,8(sp)
    80000ab8:	6a02                	ld	s4,0(sp)
    80000aba:	6145                	addi	sp,sp,48
    80000abc:	8082                	ret

0000000080000abe <kinit>:
{
    80000abe:	1141                	addi	sp,sp,-16
    80000ac0:	e406                	sd	ra,8(sp)
    80000ac2:	e022                	sd	s0,0(sp)
    80000ac4:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac6:	00007597          	auipc	a1,0x7
    80000aca:	5a258593          	addi	a1,a1,1442 # 80008068 <digits+0x28>
    80000ace:	00010517          	auipc	a0,0x10
    80000ad2:	07250513          	addi	a0,a0,114 # 80010b40 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00021517          	auipc	a0,0x21
    80000ae6:	28e50513          	addi	a0,a0,654 # 80021d70 <end>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	f8a080e7          	jalr	-118(ra) # 80000a74 <freerange>
}
    80000af2:	60a2                	ld	ra,8(sp)
    80000af4:	6402                	ld	s0,0(sp)
    80000af6:	0141                	addi	sp,sp,16
    80000af8:	8082                	ret

0000000080000afa <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afa:	1101                	addi	sp,sp,-32
    80000afc:	ec06                	sd	ra,24(sp)
    80000afe:	e822                	sd	s0,16(sp)
    80000b00:	e426                	sd	s1,8(sp)
    80000b02:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b04:	00010497          	auipc	s1,0x10
    80000b08:	03c48493          	addi	s1,s1,60 # 80010b40 <kmem>
    80000b0c:	8526                	mv	a0,s1
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	0dc080e7          	jalr	220(ra) # 80000bea <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c885                	beqz	s1,80000b48 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	02450513          	addi	a0,a0,36 # 80010b40 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	178080e7          	jalr	376(ra) # 80000c9e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2e:	6605                	lui	a2,0x1
    80000b30:	4595                	li	a1,5
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	1b2080e7          	jalr	434(ra) # 80000ce6 <memset>
  return (void*)r;
}
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	60e2                	ld	ra,24(sp)
    80000b40:	6442                	ld	s0,16(sp)
    80000b42:	64a2                	ld	s1,8(sp)
    80000b44:	6105                	addi	sp,sp,32
    80000b46:	8082                	ret
  release(&kmem.lock);
    80000b48:	00010517          	auipc	a0,0x10
    80000b4c:	ff850513          	addi	a0,a0,-8 # 80010b40 <kmem>
    80000b50:	00000097          	auipc	ra,0x0
    80000b54:	14e080e7          	jalr	334(ra) # 80000c9e <release>
  if(r)
    80000b58:	b7d5                	j	80000b3c <kalloc+0x42>

0000000080000b5a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b5a:	1141                	addi	sp,sp,-16
    80000b5c:	e422                	sd	s0,8(sp)
    80000b5e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b60:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b62:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b66:	00053823          	sd	zero,16(a0)
}
    80000b6a:	6422                	ld	s0,8(sp)
    80000b6c:	0141                	addi	sp,sp,16
    80000b6e:	8082                	ret

0000000080000b70 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b70:	411c                	lw	a5,0(a0)
    80000b72:	e399                	bnez	a5,80000b78 <holding+0x8>
    80000b74:	4501                	li	a0,0
  return r;
}
    80000b76:	8082                	ret
{
    80000b78:	1101                	addi	sp,sp,-32
    80000b7a:	ec06                	sd	ra,24(sp)
    80000b7c:	e822                	sd	s0,16(sp)
    80000b7e:	e426                	sd	s1,8(sp)
    80000b80:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b82:	6904                	ld	s1,16(a0)
    80000b84:	00001097          	auipc	ra,0x1
    80000b88:	e26080e7          	jalr	-474(ra) # 800019aa <mycpu>
    80000b8c:	40a48533          	sub	a0,s1,a0
    80000b90:	00153513          	seqz	a0,a0
}
    80000b94:	60e2                	ld	ra,24(sp)
    80000b96:	6442                	ld	s0,16(sp)
    80000b98:	64a2                	ld	s1,8(sp)
    80000b9a:	6105                	addi	sp,sp,32
    80000b9c:	8082                	ret

0000000080000b9e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba8:	100024f3          	csrr	s1,sstatus
    80000bac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bb0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bb2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb6:	00001097          	auipc	ra,0x1
    80000bba:	df4080e7          	jalr	-524(ra) # 800019aa <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	de8080e7          	jalr	-536(ra) # 800019aa <mycpu>
    80000bca:	5d3c                	lw	a5,120(a0)
    80000bcc:	2785                	addiw	a5,a5,1
    80000bce:	dd3c                	sw	a5,120(a0)
}
    80000bd0:	60e2                	ld	ra,24(sp)
    80000bd2:	6442                	ld	s0,16(sp)
    80000bd4:	64a2                	ld	s1,8(sp)
    80000bd6:	6105                	addi	sp,sp,32
    80000bd8:	8082                	ret
    mycpu()->intena = old;
    80000bda:	00001097          	auipc	ra,0x1
    80000bde:	dd0080e7          	jalr	-560(ra) # 800019aa <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000be2:	8085                	srli	s1,s1,0x1
    80000be4:	8885                	andi	s1,s1,1
    80000be6:	dd64                	sw	s1,124(a0)
    80000be8:	bfe9                	j	80000bc2 <push_off+0x24>

0000000080000bea <acquire>:
{
    80000bea:	1101                	addi	sp,sp,-32
    80000bec:	ec06                	sd	ra,24(sp)
    80000bee:	e822                	sd	s0,16(sp)
    80000bf0:	e426                	sd	s1,8(sp)
    80000bf2:	1000                	addi	s0,sp,32
    80000bf4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf6:	00000097          	auipc	ra,0x0
    80000bfa:	fa8080e7          	jalr	-88(ra) # 80000b9e <push_off>
  if(holding(lk))
    80000bfe:	8526                	mv	a0,s1
    80000c00:	00000097          	auipc	ra,0x0
    80000c04:	f70080e7          	jalr	-144(ra) # 80000b70 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c08:	4705                	li	a4,1
  if(holding(lk))
    80000c0a:	e115                	bnez	a0,80000c2e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0c:	87ba                	mv	a5,a4
    80000c0e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c12:	2781                	sext.w	a5,a5
    80000c14:	ffe5                	bnez	a5,80000c0c <acquire+0x22>
  __sync_synchronize();
    80000c16:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1a:	00001097          	auipc	ra,0x1
    80000c1e:	d90080e7          	jalr	-624(ra) # 800019aa <mycpu>
    80000c22:	e888                	sd	a0,16(s1)
}
    80000c24:	60e2                	ld	ra,24(sp)
    80000c26:	6442                	ld	s0,16(sp)
    80000c28:	64a2                	ld	s1,8(sp)
    80000c2a:	6105                	addi	sp,sp,32
    80000c2c:	8082                	ret
    panic("acquire");
    80000c2e:	00007517          	auipc	a0,0x7
    80000c32:	44250513          	addi	a0,a0,1090 # 80008070 <digits+0x30>
    80000c36:	00000097          	auipc	ra,0x0
    80000c3a:	90e080e7          	jalr	-1778(ra) # 80000544 <panic>

0000000080000c3e <pop_off>:

void
pop_off(void)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e406                	sd	ra,8(sp)
    80000c42:	e022                	sd	s0,0(sp)
    80000c44:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	d64080e7          	jalr	-668(ra) # 800019aa <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e78d                	bnez	a5,80000c7e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05b63          	blez	a5,80000c8e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	0007871b          	sext.w	a4,a5
    80000c62:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c64:	eb09                	bnez	a4,80000c76 <pop_off+0x38>
    80000c66:	5d7c                	lw	a5,124(a0)
    80000c68:	c799                	beqz	a5,80000c76 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c72:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c76:	60a2                	ld	ra,8(sp)
    80000c78:	6402                	ld	s0,0(sp)
    80000c7a:	0141                	addi	sp,sp,16
    80000c7c:	8082                	ret
    panic("pop_off - interruptible");
    80000c7e:	00007517          	auipc	a0,0x7
    80000c82:	3fa50513          	addi	a0,a0,1018 # 80008078 <digits+0x38>
    80000c86:	00000097          	auipc	ra,0x0
    80000c8a:	8be080e7          	jalr	-1858(ra) # 80000544 <panic>
    panic("pop_off");
    80000c8e:	00007517          	auipc	a0,0x7
    80000c92:	40250513          	addi	a0,a0,1026 # 80008090 <digits+0x50>
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	8ae080e7          	jalr	-1874(ra) # 80000544 <panic>

0000000080000c9e <release>:
{
    80000c9e:	1101                	addi	sp,sp,-32
    80000ca0:	ec06                	sd	ra,24(sp)
    80000ca2:	e822                	sd	s0,16(sp)
    80000ca4:	e426                	sd	s1,8(sp)
    80000ca6:	1000                	addi	s0,sp,32
    80000ca8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	ec6080e7          	jalr	-314(ra) # 80000b70 <holding>
    80000cb2:	c115                	beqz	a0,80000cd6 <release+0x38>
  lk->cpu = 0;
    80000cb4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cbc:	0f50000f          	fence	iorw,ow
    80000cc0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	f7a080e7          	jalr	-134(ra) # 80000c3e <pop_off>
}
    80000ccc:	60e2                	ld	ra,24(sp)
    80000cce:	6442                	ld	s0,16(sp)
    80000cd0:	64a2                	ld	s1,8(sp)
    80000cd2:	6105                	addi	sp,sp,32
    80000cd4:	8082                	ret
    panic("release");
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	3c250513          	addi	a0,a0,962 # 80008098 <digits+0x58>
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	866080e7          	jalr	-1946(ra) # 80000544 <panic>

0000000080000ce6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce6:	1141                	addi	sp,sp,-16
    80000ce8:	e422                	sd	s0,8(sp)
    80000cea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cec:	ce09                	beqz	a2,80000d06 <memset+0x20>
    80000cee:	87aa                	mv	a5,a0
    80000cf0:	fff6071b          	addiw	a4,a2,-1
    80000cf4:	1702                	slli	a4,a4,0x20
    80000cf6:	9301                	srli	a4,a4,0x20
    80000cf8:	0705                	addi	a4,a4,1
    80000cfa:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cfc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d00:	0785                	addi	a5,a5,1
    80000d02:	fee79de3          	bne	a5,a4,80000cfc <memset+0x16>
  }
  return dst;
}
    80000d06:	6422                	ld	s0,8(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d12:	ca05                	beqz	a2,80000d42 <memcmp+0x36>
    80000d14:	fff6069b          	addiw	a3,a2,-1
    80000d18:	1682                	slli	a3,a3,0x20
    80000d1a:	9281                	srli	a3,a3,0x20
    80000d1c:	0685                	addi	a3,a3,1
    80000d1e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d20:	00054783          	lbu	a5,0(a0)
    80000d24:	0005c703          	lbu	a4,0(a1)
    80000d28:	00e79863          	bne	a5,a4,80000d38 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d2c:	0505                	addi	a0,a0,1
    80000d2e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d30:	fed518e3          	bne	a0,a3,80000d20 <memcmp+0x14>
  }

  return 0;
    80000d34:	4501                	li	a0,0
    80000d36:	a019                	j	80000d3c <memcmp+0x30>
      return *s1 - *s2;
    80000d38:	40e7853b          	subw	a0,a5,a4
}
    80000d3c:	6422                	ld	s0,8(sp)
    80000d3e:	0141                	addi	sp,sp,16
    80000d40:	8082                	ret
  return 0;
    80000d42:	4501                	li	a0,0
    80000d44:	bfe5                	j	80000d3c <memcmp+0x30>

0000000080000d46 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d4c:	ca0d                	beqz	a2,80000d7e <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d4e:	00a5f963          	bgeu	a1,a0,80000d60 <memmove+0x1a>
    80000d52:	02061693          	slli	a3,a2,0x20
    80000d56:	9281                	srli	a3,a3,0x20
    80000d58:	00d58733          	add	a4,a1,a3
    80000d5c:	02e56463          	bltu	a0,a4,80000d84 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	0785                	addi	a5,a5,1
    80000d6a:	97ae                	add	a5,a5,a1
    80000d6c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d6e:	0585                	addi	a1,a1,1
    80000d70:	0705                	addi	a4,a4,1
    80000d72:	fff5c683          	lbu	a3,-1(a1)
    80000d76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7a:	fef59ae3          	bne	a1,a5,80000d6e <memmove+0x28>

  return dst;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret
    d += n;
    80000d84:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d86:	fff6079b          	addiw	a5,a2,-1
    80000d8a:	1782                	slli	a5,a5,0x20
    80000d8c:	9381                	srli	a5,a5,0x20
    80000d8e:	fff7c793          	not	a5,a5
    80000d92:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d94:	177d                	addi	a4,a4,-1
    80000d96:	16fd                	addi	a3,a3,-1
    80000d98:	00074603          	lbu	a2,0(a4)
    80000d9c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000da0:	fef71ae3          	bne	a4,a5,80000d94 <memmove+0x4e>
    80000da4:	bfe9                	j	80000d7e <memmove+0x38>

0000000080000da6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dae:	00000097          	auipc	ra,0x0
    80000db2:	f98080e7          	jalr	-104(ra) # 80000d46 <memmove>
}
    80000db6:	60a2                	ld	ra,8(sp)
    80000db8:	6402                	ld	s0,0(sp)
    80000dba:	0141                	addi	sp,sp,16
    80000dbc:	8082                	ret

0000000080000dbe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dbe:	1141                	addi	sp,sp,-16
    80000dc0:	e422                	sd	s0,8(sp)
    80000dc2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dc4:	ce11                	beqz	a2,80000de0 <strncmp+0x22>
    80000dc6:	00054783          	lbu	a5,0(a0)
    80000dca:	cf89                	beqz	a5,80000de4 <strncmp+0x26>
    80000dcc:	0005c703          	lbu	a4,0(a1)
    80000dd0:	00f71a63          	bne	a4,a5,80000de4 <strncmp+0x26>
    n--, p++, q++;
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	0505                	addi	a0,a0,1
    80000dd8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dda:	f675                	bnez	a2,80000dc6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ddc:	4501                	li	a0,0
    80000dde:	a809                	j	80000df0 <strncmp+0x32>
    80000de0:	4501                	li	a0,0
    80000de2:	a039                	j	80000df0 <strncmp+0x32>
  if(n == 0)
    80000de4:	ca09                	beqz	a2,80000df6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de6:	00054503          	lbu	a0,0(a0)
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	9d1d                	subw	a0,a0,a5
}
    80000df0:	6422                	ld	s0,8(sp)
    80000df2:	0141                	addi	sp,sp,16
    80000df4:	8082                	ret
    return 0;
    80000df6:	4501                	li	a0,0
    80000df8:	bfe5                	j	80000df0 <strncmp+0x32>

0000000080000dfa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e422                	sd	s0,8(sp)
    80000dfe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e00:	872a                	mv	a4,a0
    80000e02:	8832                	mv	a6,a2
    80000e04:	367d                	addiw	a2,a2,-1
    80000e06:	01005963          	blez	a6,80000e18 <strncpy+0x1e>
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	0005c783          	lbu	a5,0(a1)
    80000e10:	fef70fa3          	sb	a5,-1(a4)
    80000e14:	0585                	addi	a1,a1,1
    80000e16:	f7f5                	bnez	a5,80000e02 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e18:	00c05d63          	blez	a2,80000e32 <strncpy+0x38>
    80000e1c:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e1e:	0685                	addi	a3,a3,1
    80000e20:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e24:	fff6c793          	not	a5,a3
    80000e28:	9fb9                	addw	a5,a5,a4
    80000e2a:	010787bb          	addw	a5,a5,a6
    80000e2e:	fef048e3          	bgtz	a5,80000e1e <strncpy+0x24>
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e3e:	02c05363          	blez	a2,80000e64 <safestrcpy+0x2c>
    80000e42:	fff6069b          	addiw	a3,a2,-1
    80000e46:	1682                	slli	a3,a3,0x20
    80000e48:	9281                	srli	a3,a3,0x20
    80000e4a:	96ae                	add	a3,a3,a1
    80000e4c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e4e:	00d58963          	beq	a1,a3,80000e60 <safestrcpy+0x28>
    80000e52:	0585                	addi	a1,a1,1
    80000e54:	0785                	addi	a5,a5,1
    80000e56:	fff5c703          	lbu	a4,-1(a1)
    80000e5a:	fee78fa3          	sb	a4,-1(a5)
    80000e5e:	fb65                	bnez	a4,80000e4e <safestrcpy+0x16>
    ;
  *s = 0;
    80000e60:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strlen>:

int
strlen(const char *s)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e70:	00054783          	lbu	a5,0(a0)
    80000e74:	cf91                	beqz	a5,80000e90 <strlen+0x26>
    80000e76:	0505                	addi	a0,a0,1
    80000e78:	87aa                	mv	a5,a0
    80000e7a:	4685                	li	a3,1
    80000e7c:	9e89                	subw	a3,a3,a0
    80000e7e:	00f6853b          	addw	a0,a3,a5
    80000e82:	0785                	addi	a5,a5,1
    80000e84:	fff7c703          	lbu	a4,-1(a5)
    80000e88:	fb7d                	bnez	a4,80000e7e <strlen+0x14>
    ;
  return n;
}
    80000e8a:	6422                	ld	s0,8(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e90:	4501                	li	a0,0
    80000e92:	bfe5                	j	80000e8a <strlen+0x20>

0000000080000e94 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e406                	sd	ra,8(sp)
    80000e98:	e022                	sd	s0,0(sp)
    80000e9a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	afe080e7          	jalr	-1282(ra) # 8000199a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ea4:	00008717          	auipc	a4,0x8
    80000ea8:	a3470713          	addi	a4,a4,-1484 # 800088d8 <started>
  if(cpuid() == 0){
    80000eac:	c139                	beqz	a0,80000ef2 <main+0x5e>
    while(started == 0)
    80000eae:	431c                	lw	a5,0(a4)
    80000eb0:	2781                	sext.w	a5,a5
    80000eb2:	dff5                	beqz	a5,80000eae <main+0x1a>
      ;
    __sync_synchronize();
    80000eb4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	ae2080e7          	jalr	-1310(ra) # 8000199a <cpuid>
    80000ec0:	85aa                	mv	a1,a0
    80000ec2:	00007517          	auipc	a0,0x7
    80000ec6:	1f650513          	addi	a0,a0,502 # 800080b8 <digits+0x78>
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	6c4080e7          	jalr	1732(ra) # 8000058e <printf>
    kvminithart();    // turn on paging
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	0d8080e7          	jalr	216(ra) # 80000faa <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eda:	00002097          	auipc	ra,0x2
    80000ede:	8f6080e7          	jalr	-1802(ra) # 800027d0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	f4e080e7          	jalr	-178(ra) # 80005e30 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	fd2080e7          	jalr	-46(ra) # 80001ebc <scheduler>
    consoleinit();
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	564080e7          	jalr	1380(ra) # 80000456 <consoleinit>
    printfinit();
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	87a080e7          	jalr	-1926(ra) # 80000774 <printfinit>
    printf("\n");
    80000f02:	00007517          	auipc	a0,0x7
    80000f06:	1c650513          	addi	a0,a0,454 # 800080c8 <digits+0x88>
    80000f0a:	fffff097          	auipc	ra,0xfffff
    80000f0e:	684080e7          	jalr	1668(ra) # 8000058e <printf>
    printf("xv6 kernel is booting\n");
    80000f12:	00007517          	auipc	a0,0x7
    80000f16:	18e50513          	addi	a0,a0,398 # 800080a0 <digits+0x60>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	674080e7          	jalr	1652(ra) # 8000058e <printf>
    printf("\n");
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	1a650513          	addi	a0,a0,422 # 800080c8 <digits+0x88>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	664080e7          	jalr	1636(ra) # 8000058e <printf>
    kinit();         // physical page allocator
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	b8c080e7          	jalr	-1140(ra) # 80000abe <kinit>
    kvminit();       // create kernel page table
    80000f3a:	00000097          	auipc	ra,0x0
    80000f3e:	326080e7          	jalr	806(ra) # 80001260 <kvminit>
    kvminithart();   // turn on paging
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	068080e7          	jalr	104(ra) # 80000faa <kvminithart>
    procinit();      // process table
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	99c080e7          	jalr	-1636(ra) # 800018e6 <procinit>
    trapinit();      // trap vectors
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	856080e7          	jalr	-1962(ra) # 800027a8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	876080e7          	jalr	-1930(ra) # 800027d0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	eb8080e7          	jalr	-328(ra) # 80005e1a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	ec6080e7          	jalr	-314(ra) # 80005e30 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	080080e7          	jalr	128(ra) # 80002ff2 <binit>
    iinit();         // inode table
    80000f7a:	00002097          	auipc	ra,0x2
    80000f7e:	724080e7          	jalr	1828(ra) # 8000369e <iinit>
    fileinit();      // file table
    80000f82:	00003097          	auipc	ra,0x3
    80000f86:	6c2080e7          	jalr	1730(ra) # 80004644 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	fae080e7          	jalr	-82(ra) # 80005f38 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d10080e7          	jalr	-752(ra) # 80001ca2 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	92f72c23          	sw	a5,-1736(a4) # 800088d8 <started>
    80000fa8:	b789                	j	80000eea <main+0x56>

0000000080000faa <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000faa:	1141                	addi	sp,sp,-16
    80000fac:	e422                	sd	s0,8(sp)
    80000fae:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb4:	00008797          	auipc	a5,0x8
    80000fb8:	92c7b783          	ld	a5,-1748(a5) # 800088e0 <kernel_pagetable>
    80000fbc:	83b1                	srli	a5,a5,0xc
    80000fbe:	577d                	li	a4,-1
    80000fc0:	177e                	slli	a4,a4,0x3f
    80000fc2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fc8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fcc:	6422                	ld	s0,8(sp)
    80000fce:	0141                	addi	sp,sp,16
    80000fd0:	8082                	ret

0000000080000fd2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd2:	7139                	addi	sp,sp,-64
    80000fd4:	fc06                	sd	ra,56(sp)
    80000fd6:	f822                	sd	s0,48(sp)
    80000fd8:	f426                	sd	s1,40(sp)
    80000fda:	f04a                	sd	s2,32(sp)
    80000fdc:	ec4e                	sd	s3,24(sp)
    80000fde:	e852                	sd	s4,16(sp)
    80000fe0:	e456                	sd	s5,8(sp)
    80000fe2:	e05a                	sd	s6,0(sp)
    80000fe4:	0080                	addi	s0,sp,64
    80000fe6:	84aa                	mv	s1,a0
    80000fe8:	89ae                	mv	s3,a1
    80000fea:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fec:	57fd                	li	a5,-1
    80000fee:	83e9                	srli	a5,a5,0x1a
    80000ff0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff2:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff4:	04b7f263          	bgeu	a5,a1,80001038 <walk+0x66>
    panic("walk");
    80000ff8:	00007517          	auipc	a0,0x7
    80000ffc:	0d850513          	addi	a0,a0,216 # 800080d0 <digits+0x90>
    80001000:	fffff097          	auipc	ra,0xfffff
    80001004:	544080e7          	jalr	1348(ra) # 80000544 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001008:	060a8663          	beqz	s5,80001074 <walk+0xa2>
    8000100c:	00000097          	auipc	ra,0x0
    80001010:	aee080e7          	jalr	-1298(ra) # 80000afa <kalloc>
    80001014:	84aa                	mv	s1,a0
    80001016:	c529                	beqz	a0,80001060 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001018:	6605                	lui	a2,0x1
    8000101a:	4581                	li	a1,0
    8000101c:	00000097          	auipc	ra,0x0
    80001020:	cca080e7          	jalr	-822(ra) # 80000ce6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001024:	00c4d793          	srli	a5,s1,0xc
    80001028:	07aa                	slli	a5,a5,0xa
    8000102a:	0017e793          	ori	a5,a5,1
    8000102e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001032:	3a5d                	addiw	s4,s4,-9
    80001034:	036a0063          	beq	s4,s6,80001054 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001038:	0149d933          	srl	s2,s3,s4
    8000103c:	1ff97913          	andi	s2,s2,511
    80001040:	090e                	slli	s2,s2,0x3
    80001042:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001044:	00093483          	ld	s1,0(s2)
    80001048:	0014f793          	andi	a5,s1,1
    8000104c:	dfd5                	beqz	a5,80001008 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000104e:	80a9                	srli	s1,s1,0xa
    80001050:	04b2                	slli	s1,s1,0xc
    80001052:	b7c5                	j	80001032 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001054:	00c9d513          	srli	a0,s3,0xc
    80001058:	1ff57513          	andi	a0,a0,511
    8000105c:	050e                	slli	a0,a0,0x3
    8000105e:	9526                	add	a0,a0,s1
}
    80001060:	70e2                	ld	ra,56(sp)
    80001062:	7442                	ld	s0,48(sp)
    80001064:	74a2                	ld	s1,40(sp)
    80001066:	7902                	ld	s2,32(sp)
    80001068:	69e2                	ld	s3,24(sp)
    8000106a:	6a42                	ld	s4,16(sp)
    8000106c:	6aa2                	ld	s5,8(sp)
    8000106e:	6b02                	ld	s6,0(sp)
    80001070:	6121                	addi	sp,sp,64
    80001072:	8082                	ret
        return 0;
    80001074:	4501                	li	a0,0
    80001076:	b7ed                	j	80001060 <walk+0x8e>

0000000080001078 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001078:	57fd                	li	a5,-1
    8000107a:	83e9                	srli	a5,a5,0x1a
    8000107c:	00b7f463          	bgeu	a5,a1,80001084 <walkaddr+0xc>
    return 0;
    80001080:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001082:	8082                	ret
{
    80001084:	1141                	addi	sp,sp,-16
    80001086:	e406                	sd	ra,8(sp)
    80001088:	e022                	sd	s0,0(sp)
    8000108a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000108c:	4601                	li	a2,0
    8000108e:	00000097          	auipc	ra,0x0
    80001092:	f44080e7          	jalr	-188(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001096:	c105                	beqz	a0,800010b6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001098:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109a:	0117f693          	andi	a3,a5,17
    8000109e:	4745                	li	a4,17
    return 0;
    800010a0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a2:	00e68663          	beq	a3,a4,800010ae <walkaddr+0x36>
}
    800010a6:	60a2                	ld	ra,8(sp)
    800010a8:	6402                	ld	s0,0(sp)
    800010aa:	0141                	addi	sp,sp,16
    800010ac:	8082                	ret
  pa = PTE2PA(*pte);
    800010ae:	00a7d513          	srli	a0,a5,0xa
    800010b2:	0532                	slli	a0,a0,0xc
  return pa;
    800010b4:	bfcd                	j	800010a6 <walkaddr+0x2e>
    return 0;
    800010b6:	4501                	li	a0,0
    800010b8:	b7fd                	j	800010a6 <walkaddr+0x2e>

00000000800010ba <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ba:	715d                	addi	sp,sp,-80
    800010bc:	e486                	sd	ra,72(sp)
    800010be:	e0a2                	sd	s0,64(sp)
    800010c0:	fc26                	sd	s1,56(sp)
    800010c2:	f84a                	sd	s2,48(sp)
    800010c4:	f44e                	sd	s3,40(sp)
    800010c6:	f052                	sd	s4,32(sp)
    800010c8:	ec56                	sd	s5,24(sp)
    800010ca:	e85a                	sd	s6,16(sp)
    800010cc:	e45e                	sd	s7,8(sp)
    800010ce:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010d0:	c205                	beqz	a2,800010f0 <mappages+0x36>
    800010d2:	8aaa                	mv	s5,a0
    800010d4:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010d6:	77fd                	lui	a5,0xfffff
    800010d8:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010dc:	15fd                	addi	a1,a1,-1
    800010de:	00c589b3          	add	s3,a1,a2
    800010e2:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010e6:	8952                	mv	s2,s4
    800010e8:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ec:	6b85                	lui	s7,0x1
    800010ee:	a015                	j	80001112 <mappages+0x58>
    panic("mappages: size");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	44c080e7          	jalr	1100(ra) # 80000544 <panic>
      panic("mappages: remap");
    80001100:	00007517          	auipc	a0,0x7
    80001104:	fe850513          	addi	a0,a0,-24 # 800080e8 <digits+0xa8>
    80001108:	fffff097          	auipc	ra,0xfffff
    8000110c:	43c080e7          	jalr	1084(ra) # 80000544 <panic>
    a += PGSIZE;
    80001110:	995e                	add	s2,s2,s7
  for(;;){
    80001112:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001116:	4605                	li	a2,1
    80001118:	85ca                	mv	a1,s2
    8000111a:	8556                	mv	a0,s5
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	eb6080e7          	jalr	-330(ra) # 80000fd2 <walk>
    80001124:	cd19                	beqz	a0,80001142 <mappages+0x88>
    if(*pte & PTE_V)
    80001126:	611c                	ld	a5,0(a0)
    80001128:	8b85                	andi	a5,a5,1
    8000112a:	fbf9                	bnez	a5,80001100 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000112c:	80b1                	srli	s1,s1,0xc
    8000112e:	04aa                	slli	s1,s1,0xa
    80001130:	0164e4b3          	or	s1,s1,s6
    80001134:	0014e493          	ori	s1,s1,1
    80001138:	e104                	sd	s1,0(a0)
    if(a == last)
    8000113a:	fd391be3          	bne	s2,s3,80001110 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    8000113e:	4501                	li	a0,0
    80001140:	a011                	j	80001144 <mappages+0x8a>
      return -1;
    80001142:	557d                	li	a0,-1
}
    80001144:	60a6                	ld	ra,72(sp)
    80001146:	6406                	ld	s0,64(sp)
    80001148:	74e2                	ld	s1,56(sp)
    8000114a:	7942                	ld	s2,48(sp)
    8000114c:	79a2                	ld	s3,40(sp)
    8000114e:	7a02                	ld	s4,32(sp)
    80001150:	6ae2                	ld	s5,24(sp)
    80001152:	6b42                	ld	s6,16(sp)
    80001154:	6ba2                	ld	s7,8(sp)
    80001156:	6161                	addi	sp,sp,80
    80001158:	8082                	ret

000000008000115a <kvmmap>:
{
    8000115a:	1141                	addi	sp,sp,-16
    8000115c:	e406                	sd	ra,8(sp)
    8000115e:	e022                	sd	s0,0(sp)
    80001160:	0800                	addi	s0,sp,16
    80001162:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001164:	86b2                	mv	a3,a2
    80001166:	863e                	mv	a2,a5
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	f52080e7          	jalr	-174(ra) # 800010ba <mappages>
    80001170:	e509                	bnez	a0,8000117a <kvmmap+0x20>
}
    80001172:	60a2                	ld	ra,8(sp)
    80001174:	6402                	ld	s0,0(sp)
    80001176:	0141                	addi	sp,sp,16
    80001178:	8082                	ret
    panic("kvmmap");
    8000117a:	00007517          	auipc	a0,0x7
    8000117e:	f7e50513          	addi	a0,a0,-130 # 800080f8 <digits+0xb8>
    80001182:	fffff097          	auipc	ra,0xfffff
    80001186:	3c2080e7          	jalr	962(ra) # 80000544 <panic>

000000008000118a <kvmmake>:
{
    8000118a:	1101                	addi	sp,sp,-32
    8000118c:	ec06                	sd	ra,24(sp)
    8000118e:	e822                	sd	s0,16(sp)
    80001190:	e426                	sd	s1,8(sp)
    80001192:	e04a                	sd	s2,0(sp)
    80001194:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	964080e7          	jalr	-1692(ra) # 80000afa <kalloc>
    8000119e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a0:	6605                	lui	a2,0x1
    800011a2:	4581                	li	a1,0
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	b42080e7          	jalr	-1214(ra) # 80000ce6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ac:	4719                	li	a4,6
    800011ae:	6685                	lui	a3,0x1
    800011b0:	10000637          	lui	a2,0x10000
    800011b4:	100005b7          	lui	a1,0x10000
    800011b8:	8526                	mv	a0,s1
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	fa0080e7          	jalr	-96(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c2:	4719                	li	a4,6
    800011c4:	6685                	lui	a3,0x1
    800011c6:	10001637          	lui	a2,0x10001
    800011ca:	100015b7          	lui	a1,0x10001
    800011ce:	8526                	mv	a0,s1
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	f8a080e7          	jalr	-118(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011d8:	4719                	li	a4,6
    800011da:	004006b7          	lui	a3,0x400
    800011de:	0c000637          	lui	a2,0xc000
    800011e2:	0c0005b7          	lui	a1,0xc000
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f72080e7          	jalr	-142(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f0:	00007917          	auipc	s2,0x7
    800011f4:	e1090913          	addi	s2,s2,-496 # 80008000 <etext>
    800011f8:	4729                	li	a4,10
    800011fa:	80007697          	auipc	a3,0x80007
    800011fe:	e0668693          	addi	a3,a3,-506 # 8000 <_entry-0x7fff8000>
    80001202:	4605                	li	a2,1
    80001204:	067e                	slli	a2,a2,0x1f
    80001206:	85b2                	mv	a1,a2
    80001208:	8526                	mv	a0,s1
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f50080e7          	jalr	-176(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001212:	4719                	li	a4,6
    80001214:	46c5                	li	a3,17
    80001216:	06ee                	slli	a3,a3,0x1b
    80001218:	412686b3          	sub	a3,a3,s2
    8000121c:	864a                	mv	a2,s2
    8000121e:	85ca                	mv	a1,s2
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f38080e7          	jalr	-200(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000122a:	4729                	li	a4,10
    8000122c:	6685                	lui	a3,0x1
    8000122e:	00006617          	auipc	a2,0x6
    80001232:	dd260613          	addi	a2,a2,-558 # 80007000 <_trampoline>
    80001236:	040005b7          	lui	a1,0x4000
    8000123a:	15fd                	addi	a1,a1,-1
    8000123c:	05b2                	slli	a1,a1,0xc
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	f1a080e7          	jalr	-230(ra) # 8000115a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001248:	8526                	mv	a0,s1
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	606080e7          	jalr	1542(ra) # 80001850 <proc_mapstacks>
}
    80001252:	8526                	mv	a0,s1
    80001254:	60e2                	ld	ra,24(sp)
    80001256:	6442                	ld	s0,16(sp)
    80001258:	64a2                	ld	s1,8(sp)
    8000125a:	6902                	ld	s2,0(sp)
    8000125c:	6105                	addi	sp,sp,32
    8000125e:	8082                	ret

0000000080001260 <kvminit>:
{
    80001260:	1141                	addi	sp,sp,-16
    80001262:	e406                	sd	ra,8(sp)
    80001264:	e022                	sd	s0,0(sp)
    80001266:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	f22080e7          	jalr	-222(ra) # 8000118a <kvmmake>
    80001270:	00007797          	auipc	a5,0x7
    80001274:	66a7b823          	sd	a0,1648(a5) # 800088e0 <kernel_pagetable>
}
    80001278:	60a2                	ld	ra,8(sp)
    8000127a:	6402                	ld	s0,0(sp)
    8000127c:	0141                	addi	sp,sp,16
    8000127e:	8082                	ret

0000000080001280 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001280:	715d                	addi	sp,sp,-80
    80001282:	e486                	sd	ra,72(sp)
    80001284:	e0a2                	sd	s0,64(sp)
    80001286:	fc26                	sd	s1,56(sp)
    80001288:	f84a                	sd	s2,48(sp)
    8000128a:	f44e                	sd	s3,40(sp)
    8000128c:	f052                	sd	s4,32(sp)
    8000128e:	ec56                	sd	s5,24(sp)
    80001290:	e85a                	sd	s6,16(sp)
    80001292:	e45e                	sd	s7,8(sp)
    80001294:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001296:	03459793          	slli	a5,a1,0x34
    8000129a:	e795                	bnez	a5,800012c6 <uvmunmap+0x46>
    8000129c:	8a2a                	mv	s4,a0
    8000129e:	892e                	mv	s2,a1
    800012a0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a2:	0632                	slli	a2,a2,0xc
    800012a4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012a8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012aa:	6b05                	lui	s6,0x1
    800012ac:	0735e863          	bltu	a1,s3,8000131c <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012b0:	60a6                	ld	ra,72(sp)
    800012b2:	6406                	ld	s0,64(sp)
    800012b4:	74e2                	ld	s1,56(sp)
    800012b6:	7942                	ld	s2,48(sp)
    800012b8:	79a2                	ld	s3,40(sp)
    800012ba:	7a02                	ld	s4,32(sp)
    800012bc:	6ae2                	ld	s5,24(sp)
    800012be:	6b42                	ld	s6,16(sp)
    800012c0:	6ba2                	ld	s7,8(sp)
    800012c2:	6161                	addi	sp,sp,80
    800012c4:	8082                	ret
    panic("uvmunmap: not aligned");
    800012c6:	00007517          	auipc	a0,0x7
    800012ca:	e3a50513          	addi	a0,a0,-454 # 80008100 <digits+0xc0>
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	276080e7          	jalr	630(ra) # 80000544 <panic>
      panic("uvmunmap: walk");
    800012d6:	00007517          	auipc	a0,0x7
    800012da:	e4250513          	addi	a0,a0,-446 # 80008118 <digits+0xd8>
    800012de:	fffff097          	auipc	ra,0xfffff
    800012e2:	266080e7          	jalr	614(ra) # 80000544 <panic>
      panic("uvmunmap: not mapped");
    800012e6:	00007517          	auipc	a0,0x7
    800012ea:	e4250513          	addi	a0,a0,-446 # 80008128 <digits+0xe8>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	256080e7          	jalr	598(ra) # 80000544 <panic>
      panic("uvmunmap: not a leaf");
    800012f6:	00007517          	auipc	a0,0x7
    800012fa:	e4a50513          	addi	a0,a0,-438 # 80008140 <digits+0x100>
    800012fe:	fffff097          	auipc	ra,0xfffff
    80001302:	246080e7          	jalr	582(ra) # 80000544 <panic>
      uint64 pa = PTE2PA(*pte);
    80001306:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001308:	0532                	slli	a0,a0,0xc
    8000130a:	fffff097          	auipc	ra,0xfffff
    8000130e:	6f4080e7          	jalr	1780(ra) # 800009fe <kfree>
    *pte = 0;
    80001312:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001316:	995a                	add	s2,s2,s6
    80001318:	f9397ce3          	bgeu	s2,s3,800012b0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000131c:	4601                	li	a2,0
    8000131e:	85ca                	mv	a1,s2
    80001320:	8552                	mv	a0,s4
    80001322:	00000097          	auipc	ra,0x0
    80001326:	cb0080e7          	jalr	-848(ra) # 80000fd2 <walk>
    8000132a:	84aa                	mv	s1,a0
    8000132c:	d54d                	beqz	a0,800012d6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000132e:	6108                	ld	a0,0(a0)
    80001330:	00157793          	andi	a5,a0,1
    80001334:	dbcd                	beqz	a5,800012e6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001336:	3ff57793          	andi	a5,a0,1023
    8000133a:	fb778ee3          	beq	a5,s7,800012f6 <uvmunmap+0x76>
    if(do_free){
    8000133e:	fc0a8ae3          	beqz	s5,80001312 <uvmunmap+0x92>
    80001342:	b7d1                	j	80001306 <uvmunmap+0x86>

0000000080001344 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001344:	1101                	addi	sp,sp,-32
    80001346:	ec06                	sd	ra,24(sp)
    80001348:	e822                	sd	s0,16(sp)
    8000134a:	e426                	sd	s1,8(sp)
    8000134c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000134e:	fffff097          	auipc	ra,0xfffff
    80001352:	7ac080e7          	jalr	1964(ra) # 80000afa <kalloc>
    80001356:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001358:	c519                	beqz	a0,80001366 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	988080e7          	jalr	-1656(ra) # 80000ce6 <memset>
  return pagetable;
}
    80001366:	8526                	mv	a0,s1
    80001368:	60e2                	ld	ra,24(sp)
    8000136a:	6442                	ld	s0,16(sp)
    8000136c:	64a2                	ld	s1,8(sp)
    8000136e:	6105                	addi	sp,sp,32
    80001370:	8082                	ret

0000000080001372 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001372:	7179                	addi	sp,sp,-48
    80001374:	f406                	sd	ra,40(sp)
    80001376:	f022                	sd	s0,32(sp)
    80001378:	ec26                	sd	s1,24(sp)
    8000137a:	e84a                	sd	s2,16(sp)
    8000137c:	e44e                	sd	s3,8(sp)
    8000137e:	e052                	sd	s4,0(sp)
    80001380:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001382:	6785                	lui	a5,0x1
    80001384:	04f67863          	bgeu	a2,a5,800013d4 <uvmfirst+0x62>
    80001388:	8a2a                	mv	s4,a0
    8000138a:	89ae                	mv	s3,a1
    8000138c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	76c080e7          	jalr	1900(ra) # 80000afa <kalloc>
    80001396:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001398:	6605                	lui	a2,0x1
    8000139a:	4581                	li	a1,0
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	94a080e7          	jalr	-1718(ra) # 80000ce6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a4:	4779                	li	a4,30
    800013a6:	86ca                	mv	a3,s2
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	8552                	mv	a0,s4
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	d0c080e7          	jalr	-756(ra) # 800010ba <mappages>
  memmove(mem, src, sz);
    800013b6:	8626                	mv	a2,s1
    800013b8:	85ce                	mv	a1,s3
    800013ba:	854a                	mv	a0,s2
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	98a080e7          	jalr	-1654(ra) # 80000d46 <memmove>
}
    800013c4:	70a2                	ld	ra,40(sp)
    800013c6:	7402                	ld	s0,32(sp)
    800013c8:	64e2                	ld	s1,24(sp)
    800013ca:	6942                	ld	s2,16(sp)
    800013cc:	69a2                	ld	s3,8(sp)
    800013ce:	6a02                	ld	s4,0(sp)
    800013d0:	6145                	addi	sp,sp,48
    800013d2:	8082                	ret
    panic("uvmfirst: more than a page");
    800013d4:	00007517          	auipc	a0,0x7
    800013d8:	d8450513          	addi	a0,a0,-636 # 80008158 <digits+0x118>
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	168080e7          	jalr	360(ra) # 80000544 <panic>

00000000800013e4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013e4:	1101                	addi	sp,sp,-32
    800013e6:	ec06                	sd	ra,24(sp)
    800013e8:	e822                	sd	s0,16(sp)
    800013ea:	e426                	sd	s1,8(sp)
    800013ec:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013ee:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013f0:	00b67d63          	bgeu	a2,a1,8000140a <uvmdealloc+0x26>
    800013f4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013f6:	6785                	lui	a5,0x1
    800013f8:	17fd                	addi	a5,a5,-1
    800013fa:	00f60733          	add	a4,a2,a5
    800013fe:	767d                	lui	a2,0xfffff
    80001400:	8f71                	and	a4,a4,a2
    80001402:	97ae                	add	a5,a5,a1
    80001404:	8ff1                	and	a5,a5,a2
    80001406:	00f76863          	bltu	a4,a5,80001416 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000140a:	8526                	mv	a0,s1
    8000140c:	60e2                	ld	ra,24(sp)
    8000140e:	6442                	ld	s0,16(sp)
    80001410:	64a2                	ld	s1,8(sp)
    80001412:	6105                	addi	sp,sp,32
    80001414:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001416:	8f99                	sub	a5,a5,a4
    80001418:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000141a:	4685                	li	a3,1
    8000141c:	0007861b          	sext.w	a2,a5
    80001420:	85ba                	mv	a1,a4
    80001422:	00000097          	auipc	ra,0x0
    80001426:	e5e080e7          	jalr	-418(ra) # 80001280 <uvmunmap>
    8000142a:	b7c5                	j	8000140a <uvmdealloc+0x26>

000000008000142c <uvmalloc>:
  if(newsz < oldsz)
    8000142c:	0ab66563          	bltu	a2,a1,800014d6 <uvmalloc+0xaa>
{
    80001430:	7139                	addi	sp,sp,-64
    80001432:	fc06                	sd	ra,56(sp)
    80001434:	f822                	sd	s0,48(sp)
    80001436:	f426                	sd	s1,40(sp)
    80001438:	f04a                	sd	s2,32(sp)
    8000143a:	ec4e                	sd	s3,24(sp)
    8000143c:	e852                	sd	s4,16(sp)
    8000143e:	e456                	sd	s5,8(sp)
    80001440:	e05a                	sd	s6,0(sp)
    80001442:	0080                	addi	s0,sp,64
    80001444:	8aaa                	mv	s5,a0
    80001446:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001448:	6985                	lui	s3,0x1
    8000144a:	19fd                	addi	s3,s3,-1
    8000144c:	95ce                	add	a1,a1,s3
    8000144e:	79fd                	lui	s3,0xfffff
    80001450:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001454:	08c9f363          	bgeu	s3,a2,800014da <uvmalloc+0xae>
    80001458:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000145e:	fffff097          	auipc	ra,0xfffff
    80001462:	69c080e7          	jalr	1692(ra) # 80000afa <kalloc>
    80001466:	84aa                	mv	s1,a0
    if(mem == 0){
    80001468:	c51d                	beqz	a0,80001496 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000146a:	6605                	lui	a2,0x1
    8000146c:	4581                	li	a1,0
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	878080e7          	jalr	-1928(ra) # 80000ce6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001476:	875a                	mv	a4,s6
    80001478:	86a6                	mv	a3,s1
    8000147a:	6605                	lui	a2,0x1
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	c3a080e7          	jalr	-966(ra) # 800010ba <mappages>
    80001488:	e90d                	bnez	a0,800014ba <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000148a:	6785                	lui	a5,0x1
    8000148c:	993e                	add	s2,s2,a5
    8000148e:	fd4968e3          	bltu	s2,s4,8000145e <uvmalloc+0x32>
  return newsz;
    80001492:	8552                	mv	a0,s4
    80001494:	a809                	j	800014a6 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f48080e7          	jalr	-184(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
}
    800014a6:	70e2                	ld	ra,56(sp)
    800014a8:	7442                	ld	s0,48(sp)
    800014aa:	74a2                	ld	s1,40(sp)
    800014ac:	7902                	ld	s2,32(sp)
    800014ae:	69e2                	ld	s3,24(sp)
    800014b0:	6a42                	ld	s4,16(sp)
    800014b2:	6aa2                	ld	s5,8(sp)
    800014b4:	6b02                	ld	s6,0(sp)
    800014b6:	6121                	addi	sp,sp,64
    800014b8:	8082                	ret
      kfree(mem);
    800014ba:	8526                	mv	a0,s1
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	542080e7          	jalr	1346(ra) # 800009fe <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014c4:	864e                	mv	a2,s3
    800014c6:	85ca                	mv	a1,s2
    800014c8:	8556                	mv	a0,s5
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	f1a080e7          	jalr	-230(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014d2:	4501                	li	a0,0
    800014d4:	bfc9                	j	800014a6 <uvmalloc+0x7a>
    return oldsz;
    800014d6:	852e                	mv	a0,a1
}
    800014d8:	8082                	ret
  return newsz;
    800014da:	8532                	mv	a0,a2
    800014dc:	b7e9                	j	800014a6 <uvmalloc+0x7a>

00000000800014de <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014de:	7179                	addi	sp,sp,-48
    800014e0:	f406                	sd	ra,40(sp)
    800014e2:	f022                	sd	s0,32(sp)
    800014e4:	ec26                	sd	s1,24(sp)
    800014e6:	e84a                	sd	s2,16(sp)
    800014e8:	e44e                	sd	s3,8(sp)
    800014ea:	e052                	sd	s4,0(sp)
    800014ec:	1800                	addi	s0,sp,48
    800014ee:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f0:	84aa                	mv	s1,a0
    800014f2:	6905                	lui	s2,0x1
    800014f4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	4985                	li	s3,1
    800014f8:	a821                	j	80001510 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014fa:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014fc:	0532                	slli	a0,a0,0xc
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	fe0080e7          	jalr	-32(ra) # 800014de <freewalk>
      pagetable[i] = 0;
    80001506:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000150a:	04a1                	addi	s1,s1,8
    8000150c:	03248163          	beq	s1,s2,8000152e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001510:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001512:	00f57793          	andi	a5,a0,15
    80001516:	ff3782e3          	beq	a5,s3,800014fa <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000151a:	8905                	andi	a0,a0,1
    8000151c:	d57d                	beqz	a0,8000150a <freewalk+0x2c>
      panic("freewalk: leaf");
    8000151e:	00007517          	auipc	a0,0x7
    80001522:	c5a50513          	addi	a0,a0,-934 # 80008178 <digits+0x138>
    80001526:	fffff097          	auipc	ra,0xfffff
    8000152a:	01e080e7          	jalr	30(ra) # 80000544 <panic>
    }
  }
  kfree((void*)pagetable);
    8000152e:	8552                	mv	a0,s4
    80001530:	fffff097          	auipc	ra,0xfffff
    80001534:	4ce080e7          	jalr	1230(ra) # 800009fe <kfree>
}
    80001538:	70a2                	ld	ra,40(sp)
    8000153a:	7402                	ld	s0,32(sp)
    8000153c:	64e2                	ld	s1,24(sp)
    8000153e:	6942                	ld	s2,16(sp)
    80001540:	69a2                	ld	s3,8(sp)
    80001542:	6a02                	ld	s4,0(sp)
    80001544:	6145                	addi	sp,sp,48
    80001546:	8082                	ret

0000000080001548 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001548:	1101                	addi	sp,sp,-32
    8000154a:	ec06                	sd	ra,24(sp)
    8000154c:	e822                	sd	s0,16(sp)
    8000154e:	e426                	sd	s1,8(sp)
    80001550:	1000                	addi	s0,sp,32
    80001552:	84aa                	mv	s1,a0
  if(sz > 0)
    80001554:	e999                	bnez	a1,8000156a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001556:	8526                	mv	a0,s1
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	f86080e7          	jalr	-122(ra) # 800014de <freewalk>
}
    80001560:	60e2                	ld	ra,24(sp)
    80001562:	6442                	ld	s0,16(sp)
    80001564:	64a2                	ld	s1,8(sp)
    80001566:	6105                	addi	sp,sp,32
    80001568:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000156a:	6605                	lui	a2,0x1
    8000156c:	167d                	addi	a2,a2,-1
    8000156e:	962e                	add	a2,a2,a1
    80001570:	4685                	li	a3,1
    80001572:	8231                	srli	a2,a2,0xc
    80001574:	4581                	li	a1,0
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	d0a080e7          	jalr	-758(ra) # 80001280 <uvmunmap>
    8000157e:	bfe1                	j	80001556 <uvmfree+0xe>

0000000080001580 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001580:	c679                	beqz	a2,8000164e <uvmcopy+0xce>
{
    80001582:	715d                	addi	sp,sp,-80
    80001584:	e486                	sd	ra,72(sp)
    80001586:	e0a2                	sd	s0,64(sp)
    80001588:	fc26                	sd	s1,56(sp)
    8000158a:	f84a                	sd	s2,48(sp)
    8000158c:	f44e                	sd	s3,40(sp)
    8000158e:	f052                	sd	s4,32(sp)
    80001590:	ec56                	sd	s5,24(sp)
    80001592:	e85a                	sd	s6,16(sp)
    80001594:	e45e                	sd	s7,8(sp)
    80001596:	0880                	addi	s0,sp,80
    80001598:	8b2a                	mv	s6,a0
    8000159a:	8aae                	mv	s5,a1
    8000159c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000159e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a0:	4601                	li	a2,0
    800015a2:	85ce                	mv	a1,s3
    800015a4:	855a                	mv	a0,s6
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	a2c080e7          	jalr	-1492(ra) # 80000fd2 <walk>
    800015ae:	c531                	beqz	a0,800015fa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b0:	6118                	ld	a4,0(a0)
    800015b2:	00177793          	andi	a5,a4,1
    800015b6:	cbb1                	beqz	a5,8000160a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015b8:	00a75593          	srli	a1,a4,0xa
    800015bc:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	536080e7          	jalr	1334(ra) # 80000afa <kalloc>
    800015cc:	892a                	mv	s2,a0
    800015ce:	c939                	beqz	a0,80001624 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d0:	6605                	lui	a2,0x1
    800015d2:	85de                	mv	a1,s7
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	772080e7          	jalr	1906(ra) # 80000d46 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015dc:	8726                	mv	a4,s1
    800015de:	86ca                	mv	a3,s2
    800015e0:	6605                	lui	a2,0x1
    800015e2:	85ce                	mv	a1,s3
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	ad4080e7          	jalr	-1324(ra) # 800010ba <mappages>
    800015ee:	e515                	bnez	a0,8000161a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f0:	6785                	lui	a5,0x1
    800015f2:	99be                	add	s3,s3,a5
    800015f4:	fb49e6e3          	bltu	s3,s4,800015a0 <uvmcopy+0x20>
    800015f8:	a081                	j	80001638 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015fa:	00007517          	auipc	a0,0x7
    800015fe:	b8e50513          	addi	a0,a0,-1138 # 80008188 <digits+0x148>
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	f42080e7          	jalr	-190(ra) # 80000544 <panic>
      panic("uvmcopy: page not present");
    8000160a:	00007517          	auipc	a0,0x7
    8000160e:	b9e50513          	addi	a0,a0,-1122 # 800081a8 <digits+0x168>
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	f32080e7          	jalr	-206(ra) # 80000544 <panic>
      kfree(mem);
    8000161a:	854a                	mv	a0,s2
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	3e2080e7          	jalr	994(ra) # 800009fe <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001624:	4685                	li	a3,1
    80001626:	00c9d613          	srli	a2,s3,0xc
    8000162a:	4581                	li	a1,0
    8000162c:	8556                	mv	a0,s5
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	c52080e7          	jalr	-942(ra) # 80001280 <uvmunmap>
  return -1;
    80001636:	557d                	li	a0,-1
}
    80001638:	60a6                	ld	ra,72(sp)
    8000163a:	6406                	ld	s0,64(sp)
    8000163c:	74e2                	ld	s1,56(sp)
    8000163e:	7942                	ld	s2,48(sp)
    80001640:	79a2                	ld	s3,40(sp)
    80001642:	7a02                	ld	s4,32(sp)
    80001644:	6ae2                	ld	s5,24(sp)
    80001646:	6b42                	ld	s6,16(sp)
    80001648:	6ba2                	ld	s7,8(sp)
    8000164a:	6161                	addi	sp,sp,80
    8000164c:	8082                	ret
  return 0;
    8000164e:	4501                	li	a0,0
}
    80001650:	8082                	ret

0000000080001652 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001652:	1141                	addi	sp,sp,-16
    80001654:	e406                	sd	ra,8(sp)
    80001656:	e022                	sd	s0,0(sp)
    80001658:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000165a:	4601                	li	a2,0
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	976080e7          	jalr	-1674(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001664:	c901                	beqz	a0,80001674 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001666:	611c                	ld	a5,0(a0)
    80001668:	9bbd                	andi	a5,a5,-17
    8000166a:	e11c                	sd	a5,0(a0)
}
    8000166c:	60a2                	ld	ra,8(sp)
    8000166e:	6402                	ld	s0,0(sp)
    80001670:	0141                	addi	sp,sp,16
    80001672:	8082                	ret
    panic("uvmclear");
    80001674:	00007517          	auipc	a0,0x7
    80001678:	b5450513          	addi	a0,a0,-1196 # 800081c8 <digits+0x188>
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	ec8080e7          	jalr	-312(ra) # 80000544 <panic>

0000000080001684 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001684:	c6bd                	beqz	a3,800016f2 <copyout+0x6e>
{
    80001686:	715d                	addi	sp,sp,-80
    80001688:	e486                	sd	ra,72(sp)
    8000168a:	e0a2                	sd	s0,64(sp)
    8000168c:	fc26                	sd	s1,56(sp)
    8000168e:	f84a                	sd	s2,48(sp)
    80001690:	f44e                	sd	s3,40(sp)
    80001692:	f052                	sd	s4,32(sp)
    80001694:	ec56                	sd	s5,24(sp)
    80001696:	e85a                	sd	s6,16(sp)
    80001698:	e45e                	sd	s7,8(sp)
    8000169a:	e062                	sd	s8,0(sp)
    8000169c:	0880                	addi	s0,sp,80
    8000169e:	8b2a                	mv	s6,a0
    800016a0:	8c2e                	mv	s8,a1
    800016a2:	8a32                	mv	s4,a2
    800016a4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016a6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016a8:	6a85                	lui	s5,0x1
    800016aa:	a015                	j	800016ce <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ac:	9562                	add	a0,a0,s8
    800016ae:	0004861b          	sext.w	a2,s1
    800016b2:	85d2                	mv	a1,s4
    800016b4:	41250533          	sub	a0,a0,s2
    800016b8:	fffff097          	auipc	ra,0xfffff
    800016bc:	68e080e7          	jalr	1678(ra) # 80000d46 <memmove>

    len -= n;
    800016c0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016c4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016c6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ca:	02098263          	beqz	s3,800016ee <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ce:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d2:	85ca                	mv	a1,s2
    800016d4:	855a                	mv	a0,s6
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	9a2080e7          	jalr	-1630(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800016de:	cd01                	beqz	a0,800016f6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e0:	418904b3          	sub	s1,s2,s8
    800016e4:	94d6                	add	s1,s1,s5
    if(n > len)
    800016e6:	fc99f3e3          	bgeu	s3,s1,800016ac <copyout+0x28>
    800016ea:	84ce                	mv	s1,s3
    800016ec:	b7c1                	j	800016ac <copyout+0x28>
  }
  return 0;
    800016ee:	4501                	li	a0,0
    800016f0:	a021                	j	800016f8 <copyout+0x74>
    800016f2:	4501                	li	a0,0
}
    800016f4:	8082                	ret
      return -1;
    800016f6:	557d                	li	a0,-1
}
    800016f8:	60a6                	ld	ra,72(sp)
    800016fa:	6406                	ld	s0,64(sp)
    800016fc:	74e2                	ld	s1,56(sp)
    800016fe:	7942                	ld	s2,48(sp)
    80001700:	79a2                	ld	s3,40(sp)
    80001702:	7a02                	ld	s4,32(sp)
    80001704:	6ae2                	ld	s5,24(sp)
    80001706:	6b42                	ld	s6,16(sp)
    80001708:	6ba2                	ld	s7,8(sp)
    8000170a:	6c02                	ld	s8,0(sp)
    8000170c:	6161                	addi	sp,sp,80
    8000170e:	8082                	ret

0000000080001710 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001710:	c6bd                	beqz	a3,8000177e <copyin+0x6e>
{
    80001712:	715d                	addi	sp,sp,-80
    80001714:	e486                	sd	ra,72(sp)
    80001716:	e0a2                	sd	s0,64(sp)
    80001718:	fc26                	sd	s1,56(sp)
    8000171a:	f84a                	sd	s2,48(sp)
    8000171c:	f44e                	sd	s3,40(sp)
    8000171e:	f052                	sd	s4,32(sp)
    80001720:	ec56                	sd	s5,24(sp)
    80001722:	e85a                	sd	s6,16(sp)
    80001724:	e45e                	sd	s7,8(sp)
    80001726:	e062                	sd	s8,0(sp)
    80001728:	0880                	addi	s0,sp,80
    8000172a:	8b2a                	mv	s6,a0
    8000172c:	8a2e                	mv	s4,a1
    8000172e:	8c32                	mv	s8,a2
    80001730:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001732:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001734:	6a85                	lui	s5,0x1
    80001736:	a015                	j	8000175a <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001738:	9562                	add	a0,a0,s8
    8000173a:	0004861b          	sext.w	a2,s1
    8000173e:	412505b3          	sub	a1,a0,s2
    80001742:	8552                	mv	a0,s4
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	602080e7          	jalr	1538(ra) # 80000d46 <memmove>

    len -= n;
    8000174c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001750:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001752:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001756:	02098263          	beqz	s3,8000177a <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000175a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175e:	85ca                	mv	a1,s2
    80001760:	855a                	mv	a0,s6
    80001762:	00000097          	auipc	ra,0x0
    80001766:	916080e7          	jalr	-1770(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    8000176a:	cd01                	beqz	a0,80001782 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000176c:	418904b3          	sub	s1,s2,s8
    80001770:	94d6                	add	s1,s1,s5
    if(n > len)
    80001772:	fc99f3e3          	bgeu	s3,s1,80001738 <copyin+0x28>
    80001776:	84ce                	mv	s1,s3
    80001778:	b7c1                	j	80001738 <copyin+0x28>
  }
  return 0;
    8000177a:	4501                	li	a0,0
    8000177c:	a021                	j	80001784 <copyin+0x74>
    8000177e:	4501                	li	a0,0
}
    80001780:	8082                	ret
      return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret

000000008000179c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000179c:	c6c5                	beqz	a3,80001844 <copyinstr+0xa8>
{
    8000179e:	715d                	addi	sp,sp,-80
    800017a0:	e486                	sd	ra,72(sp)
    800017a2:	e0a2                	sd	s0,64(sp)
    800017a4:	fc26                	sd	s1,56(sp)
    800017a6:	f84a                	sd	s2,48(sp)
    800017a8:	f44e                	sd	s3,40(sp)
    800017aa:	f052                	sd	s4,32(sp)
    800017ac:	ec56                	sd	s5,24(sp)
    800017ae:	e85a                	sd	s6,16(sp)
    800017b0:	e45e                	sd	s7,8(sp)
    800017b2:	0880                	addi	s0,sp,80
    800017b4:	8a2a                	mv	s4,a0
    800017b6:	8b2e                	mv	s6,a1
    800017b8:	8bb2                	mv	s7,a2
    800017ba:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017bc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017be:	6985                	lui	s3,0x1
    800017c0:	a035                	j	800017ec <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017c6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017c8:	0017b793          	seqz	a5,a5
    800017cc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d0:	60a6                	ld	ra,72(sp)
    800017d2:	6406                	ld	s0,64(sp)
    800017d4:	74e2                	ld	s1,56(sp)
    800017d6:	7942                	ld	s2,48(sp)
    800017d8:	79a2                	ld	s3,40(sp)
    800017da:	7a02                	ld	s4,32(sp)
    800017dc:	6ae2                	ld	s5,24(sp)
    800017de:	6b42                	ld	s6,16(sp)
    800017e0:	6ba2                	ld	s7,8(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret
    srcva = va0 + PGSIZE;
    800017e6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ea:	c8a9                	beqz	s1,8000183c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ec:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f0:	85ca                	mv	a1,s2
    800017f2:	8552                	mv	a0,s4
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	884080e7          	jalr	-1916(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800017fc:	c131                	beqz	a0,80001840 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017fe:	41790833          	sub	a6,s2,s7
    80001802:	984e                	add	a6,a6,s3
    if(n > max)
    80001804:	0104f363          	bgeu	s1,a6,8000180a <copyinstr+0x6e>
    80001808:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000180a:	955e                	add	a0,a0,s7
    8000180c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001810:	fc080be3          	beqz	a6,800017e6 <copyinstr+0x4a>
    80001814:	985a                	add	a6,a6,s6
    80001816:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001818:	41650633          	sub	a2,a0,s6
    8000181c:	14fd                	addi	s1,s1,-1
    8000181e:	9b26                	add	s6,s6,s1
    80001820:	00f60733          	add	a4,a2,a5
    80001824:	00074703          	lbu	a4,0(a4)
    80001828:	df49                	beqz	a4,800017c2 <copyinstr+0x26>
        *dst = *p;
    8000182a:	00e78023          	sb	a4,0(a5)
      --max;
    8000182e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001832:	0785                	addi	a5,a5,1
    while(n > 0){
    80001834:	ff0796e3          	bne	a5,a6,80001820 <copyinstr+0x84>
      dst++;
    80001838:	8b42                	mv	s6,a6
    8000183a:	b775                	j	800017e6 <copyinstr+0x4a>
    8000183c:	4781                	li	a5,0
    8000183e:	b769                	j	800017c8 <copyinstr+0x2c>
      return -1;
    80001840:	557d                	li	a0,-1
    80001842:	b779                	j	800017d0 <copyinstr+0x34>
  int got_null = 0;
    80001844:	4781                	li	a5,0
  if(got_null){
    80001846:	0017b793          	seqz	a5,a5
    8000184a:	40f00533          	neg	a0,a5
}
    8000184e:	8082                	ret

0000000080001850 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001850:	7139                	addi	sp,sp,-64
    80001852:	fc06                	sd	ra,56(sp)
    80001854:	f822                	sd	s0,48(sp)
    80001856:	f426                	sd	s1,40(sp)
    80001858:	f04a                	sd	s2,32(sp)
    8000185a:	ec4e                	sd	s3,24(sp)
    8000185c:	e852                	sd	s4,16(sp)
    8000185e:	e456                	sd	s5,8(sp)
    80001860:	e05a                	sd	s6,0(sp)
    80001862:	0080                	addi	s0,sp,64
    80001864:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	0000f497          	auipc	s1,0xf
    8000186a:	72a48493          	addi	s1,s1,1834 # 80010f90 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000186e:	8b26                	mv	s6,s1
    80001870:	00006a97          	auipc	s5,0x6
    80001874:	790a8a93          	addi	s5,s5,1936 # 80008000 <etext>
    80001878:	04000937          	lui	s2,0x4000
    8000187c:	197d                	addi	s2,s2,-1
    8000187e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001880:	00015a17          	auipc	s4,0x15
    80001884:	110a0a13          	addi	s4,s4,272 # 80016990 <tickslock>
    char *pa = kalloc();
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	272080e7          	jalr	626(ra) # 80000afa <kalloc>
    80001890:	862a                	mv	a2,a0
    if(pa == 0)
    80001892:	c131                	beqz	a0,800018d6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001894:	416485b3          	sub	a1,s1,s6
    80001898:	858d                	srai	a1,a1,0x3
    8000189a:	000ab783          	ld	a5,0(s5)
    8000189e:	02f585b3          	mul	a1,a1,a5
    800018a2:	2585                	addiw	a1,a1,1
    800018a4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018a8:	4719                	li	a4,6
    800018aa:	6685                	lui	a3,0x1
    800018ac:	40b905b3          	sub	a1,s2,a1
    800018b0:	854e                	mv	a0,s3
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	8a8080e7          	jalr	-1880(ra) # 8000115a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ba:	16848493          	addi	s1,s1,360
    800018be:	fd4495e3          	bne	s1,s4,80001888 <proc_mapstacks+0x38>
  }
}
    800018c2:	70e2                	ld	ra,56(sp)
    800018c4:	7442                	ld	s0,48(sp)
    800018c6:	74a2                	ld	s1,40(sp)
    800018c8:	7902                	ld	s2,32(sp)
    800018ca:	69e2                	ld	s3,24(sp)
    800018cc:	6a42                	ld	s4,16(sp)
    800018ce:	6aa2                	ld	s5,8(sp)
    800018d0:	6b02                	ld	s6,0(sp)
    800018d2:	6121                	addi	sp,sp,64
    800018d4:	8082                	ret
      panic("kalloc");
    800018d6:	00007517          	auipc	a0,0x7
    800018da:	90250513          	addi	a0,a0,-1790 # 800081d8 <digits+0x198>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	c66080e7          	jalr	-922(ra) # 80000544 <panic>

00000000800018e6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018e6:	7139                	addi	sp,sp,-64
    800018e8:	fc06                	sd	ra,56(sp)
    800018ea:	f822                	sd	s0,48(sp)
    800018ec:	f426                	sd	s1,40(sp)
    800018ee:	f04a                	sd	s2,32(sp)
    800018f0:	ec4e                	sd	s3,24(sp)
    800018f2:	e852                	sd	s4,16(sp)
    800018f4:	e456                	sd	s5,8(sp)
    800018f6:	e05a                	sd	s6,0(sp)
    800018f8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8e658593          	addi	a1,a1,-1818 # 800081e0 <digits+0x1a0>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	25e50513          	addi	a0,a0,606 # 80010b60 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	25e50513          	addi	a0,a0,606 # 80010b78 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	238080e7          	jalr	568(ra) # 80000b5a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192a:	0000f497          	auipc	s1,0xf
    8000192e:	66648493          	addi	s1,s1,1638 # 80010f90 <proc>
      initlock(&p->lock, "proc");
    80001932:	00007b17          	auipc	s6,0x7
    80001936:	8c6b0b13          	addi	s6,s6,-1850 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));    
    8000193a:	8aa6                	mv	s5,s1
    8000193c:	00006a17          	auipc	s4,0x6
    80001940:	6c4a0a13          	addi	s4,s4,1732 # 80008000 <etext>
    80001944:	04000937          	lui	s2,0x4000
    80001948:	197d                	addi	s2,s2,-1
    8000194a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194c:	00015997          	auipc	s3,0x15
    80001950:	04498993          	addi	s3,s3,68 # 80016990 <tickslock>
      initlock(&p->lock, "proc");
    80001954:	85da                	mv	a1,s6
    80001956:	8526                	mv	a0,s1
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	202080e7          	jalr	514(ra) # 80000b5a <initlock>
      p->state = UNUSED;
    80001960:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));    
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	878d                	srai	a5,a5,0x3
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197e:	16848493          	addi	s1,s1,360
    80001982:	fd3499e3          	bne	s1,s3,80001954 <procinit+0x6e>
  }
}
    80001986:	70e2                	ld	ra,56(sp)
    80001988:	7442                	ld	s0,48(sp)
    8000198a:	74a2                	ld	s1,40(sp)
    8000198c:	7902                	ld	s2,32(sp)
    8000198e:	69e2                	ld	s3,24(sp)
    80001990:	6a42                	ld	s4,16(sp)
    80001992:	6aa2                	ld	s5,8(sp)
    80001994:	6b02                	ld	s6,0(sp)
    80001996:	6121                	addi	sp,sp,64
    80001998:	8082                	ret

000000008000199a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000199a:	1141                	addi	sp,sp,-16
    8000199c:	e422                	sd	s0,8(sp)
    8000199e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a2:	2501                	sext.w	a0,a0
    800019a4:	6422                	ld	s0,8(sp)
    800019a6:	0141                	addi	sp,sp,16
    800019a8:	8082                	ret

00000000800019aa <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019aa:	1141                	addi	sp,sp,-16
    800019ac:	e422                	sd	s0,8(sp)
    800019ae:	0800                	addi	s0,sp,16
    800019b0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b2:	2781                	sext.w	a5,a5
    800019b4:	079e                	slli	a5,a5,0x7
  return c;
}
    800019b6:	0000f517          	auipc	a0,0xf
    800019ba:	1da50513          	addi	a0,a0,474 # 80010b90 <cpus>
    800019be:	953e                	add	a0,a0,a5
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	addi	sp,sp,16
    800019c4:	8082                	ret

00000000800019c6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019c6:	1101                	addi	sp,sp,-32
    800019c8:	ec06                	sd	ra,24(sp)
    800019ca:	e822                	sd	s0,16(sp)
    800019cc:	e426                	sd	s1,8(sp)
    800019ce:	1000                	addi	s0,sp,32
  push_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	1ce080e7          	jalr	462(ra) # 80000b9e <push_off>
    800019d8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019da:	2781                	sext.w	a5,a5
    800019dc:	079e                	slli	a5,a5,0x7
    800019de:	0000f717          	auipc	a4,0xf
    800019e2:	18270713          	addi	a4,a4,386 # 80010b60 <pid_lock>
    800019e6:	97ba                	add	a5,a5,a4
    800019e8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	254080e7          	jalr	596(ra) # 80000c3e <pop_off>
  return p;
}
    800019f2:	8526                	mv	a0,s1
    800019f4:	60e2                	ld	ra,24(sp)
    800019f6:	6442                	ld	s0,16(sp)
    800019f8:	64a2                	ld	s1,8(sp)
    800019fa:	6105                	addi	sp,sp,32
    800019fc:	8082                	ret

00000000800019fe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019fe:	1141                	addi	sp,sp,-16
    80001a00:	e406                	sd	ra,8(sp)
    80001a02:	e022                	sd	s0,0(sp)
    80001a04:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a06:	00000097          	auipc	ra,0x0
    80001a0a:	fc0080e7          	jalr	-64(ra) # 800019c6 <myproc>
    80001a0e:	fffff097          	auipc	ra,0xfffff
    80001a12:	290080e7          	jalr	656(ra) # 80000c9e <release>

  if (first) {
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e3a7a783          	lw	a5,-454(a5) # 80008850 <first.1702>
    80001a1e:	eb89                	bnez	a5,80001a30 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a20:	00001097          	auipc	ra,0x1
    80001a24:	dc8080e7          	jalr	-568(ra) # 800027e8 <usertrapret>
}
    80001a28:	60a2                	ld	ra,8(sp)
    80001a2a:	6402                	ld	s0,0(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret
    first = 0;
    80001a30:	00007797          	auipc	a5,0x7
    80001a34:	e207a023          	sw	zero,-480(a5) # 80008850 <first.1702>
    fsinit(ROOTDEV);
    80001a38:	4505                	li	a0,1
    80001a3a:	00002097          	auipc	ra,0x2
    80001a3e:	be4080e7          	jalr	-1052(ra) # 8000361e <fsinit>
    80001a42:	bff9                	j	80001a20 <forkret+0x22>

0000000080001a44 <allocpid>:
{
    80001a44:	1101                	addi	sp,sp,-32
    80001a46:	ec06                	sd	ra,24(sp)
    80001a48:	e822                	sd	s0,16(sp)
    80001a4a:	e426                	sd	s1,8(sp)
    80001a4c:	e04a                	sd	s2,0(sp)
    80001a4e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a50:	0000f917          	auipc	s2,0xf
    80001a54:	11090913          	addi	s2,s2,272 # 80010b60 <pid_lock>
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	190080e7          	jalr	400(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a62:	00007797          	auipc	a5,0x7
    80001a66:	df278793          	addi	a5,a5,-526 # 80008854 <nextpid>
    80001a6a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a6c:	0014871b          	addiw	a4,s1,1
    80001a70:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a72:	854a                	mv	a0,s2
    80001a74:	fffff097          	auipc	ra,0xfffff
    80001a78:	22a080e7          	jalr	554(ra) # 80000c9e <release>
}
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	60e2                	ld	ra,24(sp)
    80001a80:	6442                	ld	s0,16(sp)
    80001a82:	64a2                	ld	s1,8(sp)
    80001a84:	6902                	ld	s2,0(sp)
    80001a86:	6105                	addi	sp,sp,32
    80001a88:	8082                	ret

0000000080001a8a <proc_pagetable>:
{
    80001a8a:	1101                	addi	sp,sp,-32
    80001a8c:	ec06                	sd	ra,24(sp)
    80001a8e:	e822                	sd	s0,16(sp)
    80001a90:	e426                	sd	s1,8(sp)
    80001a92:	e04a                	sd	s2,0(sp)
    80001a94:	1000                	addi	s0,sp,32
    80001a96:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a98:	00000097          	auipc	ra,0x0
    80001a9c:	8ac080e7          	jalr	-1876(ra) # 80001344 <uvmcreate>
    80001aa0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aa2:	c121                	beqz	a0,80001ae2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa4:	4729                	li	a4,10
    80001aa6:	00005697          	auipc	a3,0x5
    80001aaa:	55a68693          	addi	a3,a3,1370 # 80007000 <_trampoline>
    80001aae:	6605                	lui	a2,0x1
    80001ab0:	040005b7          	lui	a1,0x4000
    80001ab4:	15fd                	addi	a1,a1,-1
    80001ab6:	05b2                	slli	a1,a1,0xc
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	602080e7          	jalr	1538(ra) # 800010ba <mappages>
    80001ac0:	02054863          	bltz	a0,80001af0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac4:	4719                	li	a4,6
    80001ac6:	05893683          	ld	a3,88(s2)
    80001aca:	6605                	lui	a2,0x1
    80001acc:	020005b7          	lui	a1,0x2000
    80001ad0:	15fd                	addi	a1,a1,-1
    80001ad2:	05b6                	slli	a1,a1,0xd
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	5e4080e7          	jalr	1508(ra) # 800010ba <mappages>
    80001ade:	02054163          	bltz	a0,80001b00 <proc_pagetable+0x76>
}
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6902                	ld	s2,0(sp)
    80001aec:	6105                	addi	sp,sp,32
    80001aee:	8082                	ret
    uvmfree(pagetable, 0);
    80001af0:	4581                	li	a1,0
    80001af2:	8526                	mv	a0,s1
    80001af4:	00000097          	auipc	ra,0x0
    80001af8:	a54080e7          	jalr	-1452(ra) # 80001548 <uvmfree>
    return 0;
    80001afc:	4481                	li	s1,0
    80001afe:	b7d5                	j	80001ae2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b00:	4681                	li	a3,0
    80001b02:	4605                	li	a2,1
    80001b04:	040005b7          	lui	a1,0x4000
    80001b08:	15fd                	addi	a1,a1,-1
    80001b0a:	05b2                	slli	a1,a1,0xc
    80001b0c:	8526                	mv	a0,s1
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	772080e7          	jalr	1906(ra) # 80001280 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b16:	4581                	li	a1,0
    80001b18:	8526                	mv	a0,s1
    80001b1a:	00000097          	auipc	ra,0x0
    80001b1e:	a2e080e7          	jalr	-1490(ra) # 80001548 <uvmfree>
    return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	bf7d                	j	80001ae2 <proc_pagetable+0x58>

0000000080001b26 <proc_freepagetable>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	84aa                	mv	s1,a0
    80001b34:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b36:	4681                	li	a3,0
    80001b38:	4605                	li	a2,1
    80001b3a:	040005b7          	lui	a1,0x4000
    80001b3e:	15fd                	addi	a1,a1,-1
    80001b40:	05b2                	slli	a1,a1,0xc
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	73e080e7          	jalr	1854(ra) # 80001280 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4a:	4681                	li	a3,0
    80001b4c:	4605                	li	a2,1
    80001b4e:	020005b7          	lui	a1,0x2000
    80001b52:	15fd                	addi	a1,a1,-1
    80001b54:	05b6                	slli	a1,a1,0xd
    80001b56:	8526                	mv	a0,s1
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	728080e7          	jalr	1832(ra) # 80001280 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b60:	85ca                	mv	a1,s2
    80001b62:	8526                	mv	a0,s1
    80001b64:	00000097          	auipc	ra,0x0
    80001b68:	9e4080e7          	jalr	-1564(ra) # 80001548 <uvmfree>
}
    80001b6c:	60e2                	ld	ra,24(sp)
    80001b6e:	6442                	ld	s0,16(sp)
    80001b70:	64a2                	ld	s1,8(sp)
    80001b72:	6902                	ld	s2,0(sp)
    80001b74:	6105                	addi	sp,sp,32
    80001b76:	8082                	ret

0000000080001b78 <freeproc>:
{
    80001b78:	1101                	addi	sp,sp,-32
    80001b7a:	ec06                	sd	ra,24(sp)
    80001b7c:	e822                	sd	s0,16(sp)
    80001b7e:	e426                	sd	s1,8(sp)
    80001b80:	1000                	addi	s0,sp,32
    80001b82:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b84:	6d28                	ld	a0,88(a0)
    80001b86:	c509                	beqz	a0,80001b90 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	e76080e7          	jalr	-394(ra) # 800009fe <kfree>
  p->trapframe = 0;
    80001b90:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b94:	68a8                	ld	a0,80(s1)
    80001b96:	c511                	beqz	a0,80001ba2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b98:	64ac                	ld	a1,72(s1)
    80001b9a:	00000097          	auipc	ra,0x0
    80001b9e:	f8c080e7          	jalr	-116(ra) # 80001b26 <proc_freepagetable>
  p->pagetable = 0;
    80001ba2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ba6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001baa:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bae:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bb2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bb6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bba:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bbe:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bc2:	0004ac23          	sw	zero,24(s1)
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <allocproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bdc:	0000f497          	auipc	s1,0xf
    80001be0:	3b448493          	addi	s1,s1,948 # 80010f90 <proc>
    80001be4:	00015917          	auipc	s2,0x15
    80001be8:	dac90913          	addi	s2,s2,-596 # 80016990 <tickslock>
    acquire(&p->lock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	ffc080e7          	jalr	-4(ra) # 80000bea <acquire>
    if(p->state == UNUSED) {
    80001bf6:	4c9c                	lw	a5,24(s1)
    80001bf8:	cf81                	beqz	a5,80001c10 <allocproc+0x40>
      release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	0a2080e7          	jalr	162(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c04:	16848493          	addi	s1,s1,360
    80001c08:	ff2492e3          	bne	s1,s2,80001bec <allocproc+0x1c>
  return 0;
    80001c0c:	4481                	li	s1,0
    80001c0e:	a899                	j	80001c64 <allocproc+0x94>
      p->priority = DEFAULT_PRIORITY; //Set p->priority to default priority given.
    80001c10:	47a9                	li	a5,10
    80001c12:	d8dc                	sw	a5,52(s1)
  p->pid = allocpid();
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e30080e7          	jalr	-464(ra) # 80001a44 <allocpid>
    80001c1c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c1e:	4785                	li	a5,1
    80001c20:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	ed8080e7          	jalr	-296(ra) # 80000afa <kalloc>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	eca8                	sd	a0,88(s1)
    80001c2e:	c131                	beqz	a0,80001c72 <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001c30:	8526                	mv	a0,s1
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e58080e7          	jalr	-424(ra) # 80001a8a <proc_pagetable>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c3e:	c531                	beqz	a0,80001c8a <allocproc+0xba>
  memset(&p->context, 0, sizeof(p->context));
    80001c40:	07000613          	li	a2,112
    80001c44:	4581                	li	a1,0
    80001c46:	06048513          	addi	a0,s1,96
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	09c080e7          	jalr	156(ra) # 80000ce6 <memset>
  p->context.ra = (uint64)forkret;
    80001c52:	00000797          	auipc	a5,0x0
    80001c56:	dac78793          	addi	a5,a5,-596 # 800019fe <forkret>
    80001c5a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c5c:	60bc                	ld	a5,64(s1)
    80001c5e:	6705                	lui	a4,0x1
    80001c60:	97ba                	add	a5,a5,a4
    80001c62:	f4bc                	sd	a5,104(s1)
}
    80001c64:	8526                	mv	a0,s1
    80001c66:	60e2                	ld	ra,24(sp)
    80001c68:	6442                	ld	s0,16(sp)
    80001c6a:	64a2                	ld	s1,8(sp)
    80001c6c:	6902                	ld	s2,0(sp)
    80001c6e:	6105                	addi	sp,sp,32
    80001c70:	8082                	ret
    freeproc(p);
    80001c72:	8526                	mv	a0,s1
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	f04080e7          	jalr	-252(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	020080e7          	jalr	32(ra) # 80000c9e <release>
    return 0;
    80001c86:	84ca                	mv	s1,s2
    80001c88:	bff1                	j	80001c64 <allocproc+0x94>
    freeproc(p);
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	00000097          	auipc	ra,0x0
    80001c90:	eec080e7          	jalr	-276(ra) # 80001b78 <freeproc>
    release(&p->lock);
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	008080e7          	jalr	8(ra) # 80000c9e <release>
    return 0;
    80001c9e:	84ca                	mv	s1,s2
    80001ca0:	b7d1                	j	80001c64 <allocproc+0x94>

0000000080001ca2 <userinit>:
{
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	f24080e7          	jalr	-220(ra) # 80001bd0 <allocproc>
    80001cb4:	84aa                	mv	s1,a0
  initproc = p;
    80001cb6:	00007797          	auipc	a5,0x7
    80001cba:	c2a7b923          	sd	a0,-974(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cbe:	03400613          	li	a2,52
    80001cc2:	00007597          	auipc	a1,0x7
    80001cc6:	b9e58593          	addi	a1,a1,-1122 # 80008860 <initcode>
    80001cca:	6928                	ld	a0,80(a0)
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	6a6080e7          	jalr	1702(ra) # 80001372 <uvmfirst>
  p->sz = PGSIZE;
    80001cd4:	6785                	lui	a5,0x1
    80001cd6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd8:	6cb8                	ld	a4,88(s1)
    80001cda:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cde:	6cb8                	ld	a4,88(s1)
    80001ce0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	00006597          	auipc	a1,0x6
    80001ce8:	51c58593          	addi	a1,a1,1308 # 80008200 <digits+0x1c0>
    80001cec:	15848513          	addi	a0,s1,344
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	148080e7          	jalr	328(ra) # 80000e38 <safestrcpy>
  p->cwd = namei("/");
    80001cf8:	00006517          	auipc	a0,0x6
    80001cfc:	51850513          	addi	a0,a0,1304 # 80008210 <digits+0x1d0>
    80001d00:	00002097          	auipc	ra,0x2
    80001d04:	340080e7          	jalr	832(ra) # 80004040 <namei>
    80001d08:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d0c:	478d                	li	a5,3
    80001d0e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d10:	8526                	mv	a0,s1
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	f8c080e7          	jalr	-116(ra) # 80000c9e <release>
}
    80001d1a:	60e2                	ld	ra,24(sp)
    80001d1c:	6442                	ld	s0,16(sp)
    80001d1e:	64a2                	ld	s1,8(sp)
    80001d20:	6105                	addi	sp,sp,32
    80001d22:	8082                	ret

0000000080001d24 <growproc>:
{
    80001d24:	1101                	addi	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	e04a                	sd	s2,0(sp)
    80001d2e:	1000                	addi	s0,sp,32
    80001d30:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	c94080e7          	jalr	-876(ra) # 800019c6 <myproc>
    80001d3a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d3c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d3e:	01204c63          	bgtz	s2,80001d56 <growproc+0x32>
  } else if(n < 0){
    80001d42:	02094663          	bltz	s2,80001d6e <growproc+0x4a>
  p->sz = sz;
    80001d46:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d48:	4501                	li	a0,0
}
    80001d4a:	60e2                	ld	ra,24(sp)
    80001d4c:	6442                	ld	s0,16(sp)
    80001d4e:	64a2                	ld	s1,8(sp)
    80001d50:	6902                	ld	s2,0(sp)
    80001d52:	6105                	addi	sp,sp,32
    80001d54:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d56:	4691                	li	a3,4
    80001d58:	00b90633          	add	a2,s2,a1
    80001d5c:	6928                	ld	a0,80(a0)
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	6ce080e7          	jalr	1742(ra) # 8000142c <uvmalloc>
    80001d66:	85aa                	mv	a1,a0
    80001d68:	fd79                	bnez	a0,80001d46 <growproc+0x22>
      return -1;
    80001d6a:	557d                	li	a0,-1
    80001d6c:	bff9                	j	80001d4a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d6e:	00b90633          	add	a2,s2,a1
    80001d72:	6928                	ld	a0,80(a0)
    80001d74:	fffff097          	auipc	ra,0xfffff
    80001d78:	670080e7          	jalr	1648(ra) # 800013e4 <uvmdealloc>
    80001d7c:	85aa                	mv	a1,a0
    80001d7e:	b7e1                	j	80001d46 <growproc+0x22>

0000000080001d80 <fork>:
{
    80001d80:	7179                	addi	sp,sp,-48
    80001d82:	f406                	sd	ra,40(sp)
    80001d84:	f022                	sd	s0,32(sp)
    80001d86:	ec26                	sd	s1,24(sp)
    80001d88:	e84a                	sd	s2,16(sp)
    80001d8a:	e44e                	sd	s3,8(sp)
    80001d8c:	e052                	sd	s4,0(sp)
    80001d8e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d90:	00000097          	auipc	ra,0x0
    80001d94:	c36080e7          	jalr	-970(ra) # 800019c6 <myproc>
    80001d98:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	e36080e7          	jalr	-458(ra) # 80001bd0 <allocproc>
    80001da2:	10050b63          	beqz	a0,80001eb8 <fork+0x138>
    80001da6:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001da8:	04893603          	ld	a2,72(s2)
    80001dac:	692c                	ld	a1,80(a0)
    80001dae:	05093503          	ld	a0,80(s2)
    80001db2:	fffff097          	auipc	ra,0xfffff
    80001db6:	7ce080e7          	jalr	1998(ra) # 80001580 <uvmcopy>
    80001dba:	04054663          	bltz	a0,80001e06 <fork+0x86>
  np->sz = p->sz;
    80001dbe:	04893783          	ld	a5,72(s2)
    80001dc2:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dc6:	05893683          	ld	a3,88(s2)
    80001dca:	87b6                	mv	a5,a3
    80001dcc:	0589b703          	ld	a4,88(s3)
    80001dd0:	12068693          	addi	a3,a3,288
    80001dd4:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dd8:	6788                	ld	a0,8(a5)
    80001dda:	6b8c                	ld	a1,16(a5)
    80001ddc:	6f90                	ld	a2,24(a5)
    80001dde:	01073023          	sd	a6,0(a4)
    80001de2:	e708                	sd	a0,8(a4)
    80001de4:	eb0c                	sd	a1,16(a4)
    80001de6:	ef10                	sd	a2,24(a4)
    80001de8:	02078793          	addi	a5,a5,32
    80001dec:	02070713          	addi	a4,a4,32
    80001df0:	fed792e3          	bne	a5,a3,80001dd4 <fork+0x54>
  np->trapframe->a0 = 0;
    80001df4:	0589b783          	ld	a5,88(s3)
    80001df8:	0607b823          	sd	zero,112(a5)
    80001dfc:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e00:	15000a13          	li	s4,336
    80001e04:	a03d                	j	80001e32 <fork+0xb2>
    freeproc(np);
    80001e06:	854e                	mv	a0,s3
    80001e08:	00000097          	auipc	ra,0x0
    80001e0c:	d70080e7          	jalr	-656(ra) # 80001b78 <freeproc>
    release(&np->lock);
    80001e10:	854e                	mv	a0,s3
    80001e12:	fffff097          	auipc	ra,0xfffff
    80001e16:	e8c080e7          	jalr	-372(ra) # 80000c9e <release>
    return -1;
    80001e1a:	5a7d                	li	s4,-1
    80001e1c:	a069                	j	80001ea6 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1e:	00003097          	auipc	ra,0x3
    80001e22:	8b8080e7          	jalr	-1864(ra) # 800046d6 <filedup>
    80001e26:	009987b3          	add	a5,s3,s1
    80001e2a:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e2c:	04a1                	addi	s1,s1,8
    80001e2e:	01448763          	beq	s1,s4,80001e3c <fork+0xbc>
    if(p->ofile[i])
    80001e32:	009907b3          	add	a5,s2,s1
    80001e36:	6388                	ld	a0,0(a5)
    80001e38:	f17d                	bnez	a0,80001e1e <fork+0x9e>
    80001e3a:	bfcd                	j	80001e2c <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e3c:	15093503          	ld	a0,336(s2)
    80001e40:	00002097          	auipc	ra,0x2
    80001e44:	a1c080e7          	jalr	-1508(ra) # 8000385c <idup>
    80001e48:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e4c:	4641                	li	a2,16
    80001e4e:	15890593          	addi	a1,s2,344
    80001e52:	15898513          	addi	a0,s3,344
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	fe2080e7          	jalr	-30(ra) # 80000e38 <safestrcpy>
  pid = np->pid;
    80001e5e:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001e62:	854e                	mv	a0,s3
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	e3a080e7          	jalr	-454(ra) # 80000c9e <release>
  acquire(&wait_lock);
    80001e6c:	0000f497          	auipc	s1,0xf
    80001e70:	d0c48493          	addi	s1,s1,-756 # 80010b78 <wait_lock>
    80001e74:	8526                	mv	a0,s1
    80001e76:	fffff097          	auipc	ra,0xfffff
    80001e7a:	d74080e7          	jalr	-652(ra) # 80000bea <acquire>
  np->parent = p;
    80001e7e:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001e82:	8526                	mv	a0,s1
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	e1a080e7          	jalr	-486(ra) # 80000c9e <release>
  acquire(&np->lock);
    80001e8c:	854e                	mv	a0,s3
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	d5c080e7          	jalr	-676(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    80001e96:	478d                	li	a5,3
    80001e98:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e9c:	854e                	mv	a0,s3
    80001e9e:	fffff097          	auipc	ra,0xfffff
    80001ea2:	e00080e7          	jalr	-512(ra) # 80000c9e <release>
}
    80001ea6:	8552                	mv	a0,s4
    80001ea8:	70a2                	ld	ra,40(sp)
    80001eaa:	7402                	ld	s0,32(sp)
    80001eac:	64e2                	ld	s1,24(sp)
    80001eae:	6942                	ld	s2,16(sp)
    80001eb0:	69a2                	ld	s3,8(sp)
    80001eb2:	6a02                	ld	s4,0(sp)
    80001eb4:	6145                	addi	sp,sp,48
    80001eb6:	8082                	ret
    return -1;
    80001eb8:	5a7d                	li	s4,-1
    80001eba:	b7f5                	j	80001ea6 <fork+0x126>

0000000080001ebc <scheduler>:
{
    80001ebc:	715d                	addi	sp,sp,-80
    80001ebe:	e486                	sd	ra,72(sp)
    80001ec0:	e0a2                	sd	s0,64(sp)
    80001ec2:	fc26                	sd	s1,56(sp)
    80001ec4:	f84a                	sd	s2,48(sp)
    80001ec6:	f44e                	sd	s3,40(sp)
    80001ec8:	f052                	sd	s4,32(sp)
    80001eca:	ec56                	sd	s5,24(sp)
    80001ecc:	e85a                	sd	s6,16(sp)
    80001ece:	e45e                	sd	s7,8(sp)
    80001ed0:	e062                	sd	s8,0(sp)
    80001ed2:	0880                	addi	s0,sp,80
    80001ed4:	8792                	mv	a5,tp
  int id = r_tp();
    80001ed6:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ed8:	00779b13          	slli	s6,a5,0x7
    80001edc:	0000f717          	auipc	a4,0xf
    80001ee0:	c8470713          	addi	a4,a4,-892 # 80010b60 <pid_lock>
    80001ee4:	975a                	add	a4,a4,s6
    80001ee6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001eea:	0000f717          	auipc	a4,0xf
    80001eee:	cae70713          	addi	a4,a4,-850 # 80010b98 <cpus+0x8>
    80001ef2:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE && p->priority < highest_prio){
    80001ef4:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++){
    80001ef6:	00015917          	auipc	s2,0x15
    80001efa:	a9a90913          	addi	s2,s2,-1382 # 80016990 <tickslock>
        p->state = RUNNING;
    80001efe:	4b91                	li	s7,4
        c->proc = p;
    80001f00:	079e                	slli	a5,a5,0x7
    80001f02:	0000fa97          	auipc	s5,0xf
    80001f06:	c5ea8a93          	addi	s5,s5,-930 # 80010b60 <pid_lock>
    80001f0a:	9abe                	add	s5,s5,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f10:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f14:	10079073          	csrw	sstatus,a5
    80001f18:	4a55                	li	s4,21
    for(p = proc; p < &proc[NPROC]; p++){
    80001f1a:	0000f497          	auipc	s1,0xf
    80001f1e:	07648493          	addi	s1,s1,118 # 80010f90 <proc>
    80001f22:	a821                	j	80001f3a <scheduler+0x7e>
    80001f24:	00078a1b          	sext.w	s4,a5
      release(&p->lock);
    80001f28:	8526                	mv	a0,s1
    80001f2a:	fffff097          	auipc	ra,0xfffff
    80001f2e:	d74080e7          	jalr	-652(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001f32:	16848493          	addi	s1,s1,360
    80001f36:	03248163          	beq	s1,s2,80001f58 <scheduler+0x9c>
      acquire(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	cae080e7          	jalr	-850(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE && p->priority < highest_prio){
    80001f44:	4c9c                	lw	a5,24(s1)
    80001f46:	ff3791e3          	bne	a5,s3,80001f28 <scheduler+0x6c>
    80001f4a:	58dc                	lw	a5,52(s1)
    80001f4c:	0007871b          	sext.w	a4,a5
    80001f50:	fcea5ae3          	bge	s4,a4,80001f24 <scheduler+0x68>
    80001f54:	87d2                	mv	a5,s4
    80001f56:	b7f9                	j	80001f24 <scheduler+0x68>
    for(p = proc; p < &proc[NPROC]; p++){
    80001f58:	0000f497          	auipc	s1,0xf
    80001f5c:	03848493          	addi	s1,s1,56 # 80010f90 <proc>
    80001f60:	a03d                	j	80001f8e <scheduler+0xd2>
        p->state = RUNNING;
    80001f62:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001f66:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001f6a:	06048593          	addi	a1,s1,96
    80001f6e:	855a                	mv	a0,s6
    80001f70:	00000097          	auipc	ra,0x0
    80001f74:	7ce080e7          	jalr	1998(ra) # 8000273e <swtch>
        c->proc = 0;
    80001f78:	020ab823          	sd	zero,48(s5)
      release(&p->lock);
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	d20080e7          	jalr	-736(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001f86:	16848493          	addi	s1,s1,360
    80001f8a:	f92481e3          	beq	s1,s2,80001f0c <scheduler+0x50>
      acquire(&p->lock);
    80001f8e:	8526                	mv	a0,s1
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	c5a080e7          	jalr	-934(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE && p->priority == highest_prio){
    80001f98:	4c9c                	lw	a5,24(s1)
    80001f9a:	ff3791e3          	bne	a5,s3,80001f7c <scheduler+0xc0>
    80001f9e:	58dc                	lw	a5,52(s1)
    80001fa0:	fd479ee3          	bne	a5,s4,80001f7c <scheduler+0xc0>
    80001fa4:	bf7d                	j	80001f62 <scheduler+0xa6>

0000000080001fa6 <sched>:
{
    80001fa6:	7179                	addi	sp,sp,-48
    80001fa8:	f406                	sd	ra,40(sp)
    80001faa:	f022                	sd	s0,32(sp)
    80001fac:	ec26                	sd	s1,24(sp)
    80001fae:	e84a                	sd	s2,16(sp)
    80001fb0:	e44e                	sd	s3,8(sp)
    80001fb2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fb4:	00000097          	auipc	ra,0x0
    80001fb8:	a12080e7          	jalr	-1518(ra) # 800019c6 <myproc>
    80001fbc:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	bb2080e7          	jalr	-1102(ra) # 80000b70 <holding>
    80001fc6:	c93d                	beqz	a0,8000203c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fc8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fca:	2781                	sext.w	a5,a5
    80001fcc:	079e                	slli	a5,a5,0x7
    80001fce:	0000f717          	auipc	a4,0xf
    80001fd2:	b9270713          	addi	a4,a4,-1134 # 80010b60 <pid_lock>
    80001fd6:	97ba                	add	a5,a5,a4
    80001fd8:	0a87a703          	lw	a4,168(a5)
    80001fdc:	4785                	li	a5,1
    80001fde:	06f71763          	bne	a4,a5,8000204c <sched+0xa6>
  if(p->state == RUNNING)
    80001fe2:	4c98                	lw	a4,24(s1)
    80001fe4:	4791                	li	a5,4
    80001fe6:	06f70b63          	beq	a4,a5,8000205c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fee:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001ff0:	efb5                	bnez	a5,8000206c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ff2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ff4:	0000f917          	auipc	s2,0xf
    80001ff8:	b6c90913          	addi	s2,s2,-1172 # 80010b60 <pid_lock>
    80001ffc:	2781                	sext.w	a5,a5
    80001ffe:	079e                	slli	a5,a5,0x7
    80002000:	97ca                	add	a5,a5,s2
    80002002:	0ac7a983          	lw	s3,172(a5)
    80002006:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002008:	2781                	sext.w	a5,a5
    8000200a:	079e                	slli	a5,a5,0x7
    8000200c:	0000f597          	auipc	a1,0xf
    80002010:	b8c58593          	addi	a1,a1,-1140 # 80010b98 <cpus+0x8>
    80002014:	95be                	add	a1,a1,a5
    80002016:	06048513          	addi	a0,s1,96
    8000201a:	00000097          	auipc	ra,0x0
    8000201e:	724080e7          	jalr	1828(ra) # 8000273e <swtch>
    80002022:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002024:	2781                	sext.w	a5,a5
    80002026:	079e                	slli	a5,a5,0x7
    80002028:	97ca                	add	a5,a5,s2
    8000202a:	0b37a623          	sw	s3,172(a5)
}
    8000202e:	70a2                	ld	ra,40(sp)
    80002030:	7402                	ld	s0,32(sp)
    80002032:	64e2                	ld	s1,24(sp)
    80002034:	6942                	ld	s2,16(sp)
    80002036:	69a2                	ld	s3,8(sp)
    80002038:	6145                	addi	sp,sp,48
    8000203a:	8082                	ret
    panic("sched p->lock");
    8000203c:	00006517          	auipc	a0,0x6
    80002040:	1dc50513          	addi	a0,a0,476 # 80008218 <digits+0x1d8>
    80002044:	ffffe097          	auipc	ra,0xffffe
    80002048:	500080e7          	jalr	1280(ra) # 80000544 <panic>
    panic("sched locks");
    8000204c:	00006517          	auipc	a0,0x6
    80002050:	1dc50513          	addi	a0,a0,476 # 80008228 <digits+0x1e8>
    80002054:	ffffe097          	auipc	ra,0xffffe
    80002058:	4f0080e7          	jalr	1264(ra) # 80000544 <panic>
    panic("sched running");
    8000205c:	00006517          	auipc	a0,0x6
    80002060:	1dc50513          	addi	a0,a0,476 # 80008238 <digits+0x1f8>
    80002064:	ffffe097          	auipc	ra,0xffffe
    80002068:	4e0080e7          	jalr	1248(ra) # 80000544 <panic>
    panic("sched interruptible");
    8000206c:	00006517          	auipc	a0,0x6
    80002070:	1dc50513          	addi	a0,a0,476 # 80008248 <digits+0x208>
    80002074:	ffffe097          	auipc	ra,0xffffe
    80002078:	4d0080e7          	jalr	1232(ra) # 80000544 <panic>

000000008000207c <yield>:
{
    8000207c:	1101                	addi	sp,sp,-32
    8000207e:	ec06                	sd	ra,24(sp)
    80002080:	e822                	sd	s0,16(sp)
    80002082:	e426                	sd	s1,8(sp)
    80002084:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002086:	00000097          	auipc	ra,0x0
    8000208a:	940080e7          	jalr	-1728(ra) # 800019c6 <myproc>
    8000208e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	b5a080e7          	jalr	-1190(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    80002098:	478d                	li	a5,3
    8000209a:	cc9c                	sw	a5,24(s1)
  sched();
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	f0a080e7          	jalr	-246(ra) # 80001fa6 <sched>
  release(&p->lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	bf8080e7          	jalr	-1032(ra) # 80000c9e <release>
}
    800020ae:	60e2                	ld	ra,24(sp)
    800020b0:	6442                	ld	s0,16(sp)
    800020b2:	64a2                	ld	s1,8(sp)
    800020b4:	6105                	addi	sp,sp,32
    800020b6:	8082                	ret

00000000800020b8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020b8:	7179                	addi	sp,sp,-48
    800020ba:	f406                	sd	ra,40(sp)
    800020bc:	f022                	sd	s0,32(sp)
    800020be:	ec26                	sd	s1,24(sp)
    800020c0:	e84a                	sd	s2,16(sp)
    800020c2:	e44e                	sd	s3,8(sp)
    800020c4:	1800                	addi	s0,sp,48
    800020c6:	89aa                	mv	s3,a0
    800020c8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020ca:	00000097          	auipc	ra,0x0
    800020ce:	8fc080e7          	jalr	-1796(ra) # 800019c6 <myproc>
    800020d2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	b16080e7          	jalr	-1258(ra) # 80000bea <acquire>
  release(lk);
    800020dc:	854a                	mv	a0,s2
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	bc0080e7          	jalr	-1088(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    800020e6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020ea:	4789                	li	a5,2
    800020ec:	cc9c                	sw	a5,24(s1)

  sched();
    800020ee:	00000097          	auipc	ra,0x0
    800020f2:	eb8080e7          	jalr	-328(ra) # 80001fa6 <sched>

  // Tidy up.
  p->chan = 0;
    800020f6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	ba2080e7          	jalr	-1118(ra) # 80000c9e <release>
  acquire(lk);
    80002104:	854a                	mv	a0,s2
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	ae4080e7          	jalr	-1308(ra) # 80000bea <acquire>
}
    8000210e:	70a2                	ld	ra,40(sp)
    80002110:	7402                	ld	s0,32(sp)
    80002112:	64e2                	ld	s1,24(sp)
    80002114:	6942                	ld	s2,16(sp)
    80002116:	69a2                	ld	s3,8(sp)
    80002118:	6145                	addi	sp,sp,48
    8000211a:	8082                	ret

000000008000211c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000211c:	7139                	addi	sp,sp,-64
    8000211e:	fc06                	sd	ra,56(sp)
    80002120:	f822                	sd	s0,48(sp)
    80002122:	f426                	sd	s1,40(sp)
    80002124:	f04a                	sd	s2,32(sp)
    80002126:	ec4e                	sd	s3,24(sp)
    80002128:	e852                	sd	s4,16(sp)
    8000212a:	e456                	sd	s5,8(sp)
    8000212c:	0080                	addi	s0,sp,64
    8000212e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002130:	0000f497          	auipc	s1,0xf
    80002134:	e6048493          	addi	s1,s1,-416 # 80010f90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002138:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000213a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000213c:	00015917          	auipc	s2,0x15
    80002140:	85490913          	addi	s2,s2,-1964 # 80016990 <tickslock>
    80002144:	a821                	j	8000215c <wakeup+0x40>
        p->state = RUNNABLE;
    80002146:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    8000214a:	8526                	mv	a0,s1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	b52080e7          	jalr	-1198(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002154:	16848493          	addi	s1,s1,360
    80002158:	03248463          	beq	s1,s2,80002180 <wakeup+0x64>
    if(p != myproc()){
    8000215c:	00000097          	auipc	ra,0x0
    80002160:	86a080e7          	jalr	-1942(ra) # 800019c6 <myproc>
    80002164:	fea488e3          	beq	s1,a0,80002154 <wakeup+0x38>
      acquire(&p->lock);
    80002168:	8526                	mv	a0,s1
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	a80080e7          	jalr	-1408(ra) # 80000bea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002172:	4c9c                	lw	a5,24(s1)
    80002174:	fd379be3          	bne	a5,s3,8000214a <wakeup+0x2e>
    80002178:	709c                	ld	a5,32(s1)
    8000217a:	fd4798e3          	bne	a5,s4,8000214a <wakeup+0x2e>
    8000217e:	b7e1                	j	80002146 <wakeup+0x2a>
    }
  }
}
    80002180:	70e2                	ld	ra,56(sp)
    80002182:	7442                	ld	s0,48(sp)
    80002184:	74a2                	ld	s1,40(sp)
    80002186:	7902                	ld	s2,32(sp)
    80002188:	69e2                	ld	s3,24(sp)
    8000218a:	6a42                	ld	s4,16(sp)
    8000218c:	6aa2                	ld	s5,8(sp)
    8000218e:	6121                	addi	sp,sp,64
    80002190:	8082                	ret

0000000080002192 <reparent>:
{
    80002192:	7179                	addi	sp,sp,-48
    80002194:	f406                	sd	ra,40(sp)
    80002196:	f022                	sd	s0,32(sp)
    80002198:	ec26                	sd	s1,24(sp)
    8000219a:	e84a                	sd	s2,16(sp)
    8000219c:	e44e                	sd	s3,8(sp)
    8000219e:	e052                	sd	s4,0(sp)
    800021a0:	1800                	addi	s0,sp,48
    800021a2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021a4:	0000f497          	auipc	s1,0xf
    800021a8:	dec48493          	addi	s1,s1,-532 # 80010f90 <proc>
      pp->parent = initproc;
    800021ac:	00006a17          	auipc	s4,0x6
    800021b0:	73ca0a13          	addi	s4,s4,1852 # 800088e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b4:	00014997          	auipc	s3,0x14
    800021b8:	7dc98993          	addi	s3,s3,2012 # 80016990 <tickslock>
    800021bc:	a029                	j	800021c6 <reparent+0x34>
    800021be:	16848493          	addi	s1,s1,360
    800021c2:	01348d63          	beq	s1,s3,800021dc <reparent+0x4a>
    if(pp->parent == p){
    800021c6:	7c9c                	ld	a5,56(s1)
    800021c8:	ff279be3          	bne	a5,s2,800021be <reparent+0x2c>
      pp->parent = initproc;
    800021cc:	000a3503          	ld	a0,0(s4)
    800021d0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021d2:	00000097          	auipc	ra,0x0
    800021d6:	f4a080e7          	jalr	-182(ra) # 8000211c <wakeup>
    800021da:	b7d5                	j	800021be <reparent+0x2c>
}
    800021dc:	70a2                	ld	ra,40(sp)
    800021de:	7402                	ld	s0,32(sp)
    800021e0:	64e2                	ld	s1,24(sp)
    800021e2:	6942                	ld	s2,16(sp)
    800021e4:	69a2                	ld	s3,8(sp)
    800021e6:	6a02                	ld	s4,0(sp)
    800021e8:	6145                	addi	sp,sp,48
    800021ea:	8082                	ret

00000000800021ec <exit>:
{
    800021ec:	7179                	addi	sp,sp,-48
    800021ee:	f406                	sd	ra,40(sp)
    800021f0:	f022                	sd	s0,32(sp)
    800021f2:	ec26                	sd	s1,24(sp)
    800021f4:	e84a                	sd	s2,16(sp)
    800021f6:	e44e                	sd	s3,8(sp)
    800021f8:	e052                	sd	s4,0(sp)
    800021fa:	1800                	addi	s0,sp,48
    800021fc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021fe:	fffff097          	auipc	ra,0xfffff
    80002202:	7c8080e7          	jalr	1992(ra) # 800019c6 <myproc>
    80002206:	89aa                	mv	s3,a0
  if(p == initproc)
    80002208:	00006797          	auipc	a5,0x6
    8000220c:	6e07b783          	ld	a5,1760(a5) # 800088e8 <initproc>
    80002210:	0d050493          	addi	s1,a0,208
    80002214:	15050913          	addi	s2,a0,336
    80002218:	02a79363          	bne	a5,a0,8000223e <exit+0x52>
    panic("init exiting");
    8000221c:	00006517          	auipc	a0,0x6
    80002220:	04450513          	addi	a0,a0,68 # 80008260 <digits+0x220>
    80002224:	ffffe097          	auipc	ra,0xffffe
    80002228:	320080e7          	jalr	800(ra) # 80000544 <panic>
      fileclose(f);
    8000222c:	00002097          	auipc	ra,0x2
    80002230:	4fc080e7          	jalr	1276(ra) # 80004728 <fileclose>
      p->ofile[fd] = 0;
    80002234:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002238:	04a1                	addi	s1,s1,8
    8000223a:	01248563          	beq	s1,s2,80002244 <exit+0x58>
    if(p->ofile[fd]){
    8000223e:	6088                	ld	a0,0(s1)
    80002240:	f575                	bnez	a0,8000222c <exit+0x40>
    80002242:	bfdd                	j	80002238 <exit+0x4c>
  begin_op();
    80002244:	00002097          	auipc	ra,0x2
    80002248:	018080e7          	jalr	24(ra) # 8000425c <begin_op>
  iput(p->cwd);
    8000224c:	1509b503          	ld	a0,336(s3)
    80002250:	00002097          	auipc	ra,0x2
    80002254:	804080e7          	jalr	-2044(ra) # 80003a54 <iput>
  end_op();
    80002258:	00002097          	auipc	ra,0x2
    8000225c:	084080e7          	jalr	132(ra) # 800042dc <end_op>
  p->cwd = 0;
    80002260:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002264:	0000f497          	auipc	s1,0xf
    80002268:	91448493          	addi	s1,s1,-1772 # 80010b78 <wait_lock>
    8000226c:	8526                	mv	a0,s1
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	97c080e7          	jalr	-1668(ra) # 80000bea <acquire>
  reparent(p);
    80002276:	854e                	mv	a0,s3
    80002278:	00000097          	auipc	ra,0x0
    8000227c:	f1a080e7          	jalr	-230(ra) # 80002192 <reparent>
  wakeup(p->parent);
    80002280:	0389b503          	ld	a0,56(s3)
    80002284:	00000097          	auipc	ra,0x0
    80002288:	e98080e7          	jalr	-360(ra) # 8000211c <wakeup>
  acquire(&p->lock);
    8000228c:	854e                	mv	a0,s3
    8000228e:	fffff097          	auipc	ra,0xfffff
    80002292:	95c080e7          	jalr	-1700(ra) # 80000bea <acquire>
  p->xstate = status;
    80002296:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000229a:	4795                	li	a5,5
    8000229c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022a0:	8526                	mv	a0,s1
    800022a2:	fffff097          	auipc	ra,0xfffff
    800022a6:	9fc080e7          	jalr	-1540(ra) # 80000c9e <release>
  sched();
    800022aa:	00000097          	auipc	ra,0x0
    800022ae:	cfc080e7          	jalr	-772(ra) # 80001fa6 <sched>
  panic("zombie exit");
    800022b2:	00006517          	auipc	a0,0x6
    800022b6:	fbe50513          	addi	a0,a0,-66 # 80008270 <digits+0x230>
    800022ba:	ffffe097          	auipc	ra,0xffffe
    800022be:	28a080e7          	jalr	650(ra) # 80000544 <panic>

00000000800022c2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022c2:	7179                	addi	sp,sp,-48
    800022c4:	f406                	sd	ra,40(sp)
    800022c6:	f022                	sd	s0,32(sp)
    800022c8:	ec26                	sd	s1,24(sp)
    800022ca:	e84a                	sd	s2,16(sp)
    800022cc:	e44e                	sd	s3,8(sp)
    800022ce:	1800                	addi	s0,sp,48
    800022d0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022d2:	0000f497          	auipc	s1,0xf
    800022d6:	cbe48493          	addi	s1,s1,-834 # 80010f90 <proc>
    800022da:	00014997          	auipc	s3,0x14
    800022de:	6b698993          	addi	s3,s3,1718 # 80016990 <tickslock>
    acquire(&p->lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	906080e7          	jalr	-1786(ra) # 80000bea <acquire>
    if(p->pid == pid){
    800022ec:	589c                	lw	a5,48(s1)
    800022ee:	01278d63          	beq	a5,s2,80002308 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022f2:	8526                	mv	a0,s1
    800022f4:	fffff097          	auipc	ra,0xfffff
    800022f8:	9aa080e7          	jalr	-1622(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022fc:	16848493          	addi	s1,s1,360
    80002300:	ff3491e3          	bne	s1,s3,800022e2 <kill+0x20>
  }
  return -1;
    80002304:	557d                	li	a0,-1
    80002306:	a829                	j	80002320 <kill+0x5e>
      p->killed = 1;
    80002308:	4785                	li	a5,1
    8000230a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000230c:	4c98                	lw	a4,24(s1)
    8000230e:	4789                	li	a5,2
    80002310:	00f70f63          	beq	a4,a5,8000232e <kill+0x6c>
      release(&p->lock);
    80002314:	8526                	mv	a0,s1
    80002316:	fffff097          	auipc	ra,0xfffff
    8000231a:	988080e7          	jalr	-1656(ra) # 80000c9e <release>
      return 0;
    8000231e:	4501                	li	a0,0
}
    80002320:	70a2                	ld	ra,40(sp)
    80002322:	7402                	ld	s0,32(sp)
    80002324:	64e2                	ld	s1,24(sp)
    80002326:	6942                	ld	s2,16(sp)
    80002328:	69a2                	ld	s3,8(sp)
    8000232a:	6145                	addi	sp,sp,48
    8000232c:	8082                	ret
        p->state = RUNNABLE;
    8000232e:	478d                	li	a5,3
    80002330:	cc9c                	sw	a5,24(s1)
    80002332:	b7cd                	j	80002314 <kill+0x52>

0000000080002334 <setkilled>:

void
setkilled(struct proc *p)
{
    80002334:	1101                	addi	sp,sp,-32
    80002336:	ec06                	sd	ra,24(sp)
    80002338:	e822                	sd	s0,16(sp)
    8000233a:	e426                	sd	s1,8(sp)
    8000233c:	1000                	addi	s0,sp,32
    8000233e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	8aa080e7          	jalr	-1878(ra) # 80000bea <acquire>
  p->killed = 1;
    80002348:	4785                	li	a5,1
    8000234a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000234c:	8526                	mv	a0,s1
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	950080e7          	jalr	-1712(ra) # 80000c9e <release>
}
    80002356:	60e2                	ld	ra,24(sp)
    80002358:	6442                	ld	s0,16(sp)
    8000235a:	64a2                	ld	s1,8(sp)
    8000235c:	6105                	addi	sp,sp,32
    8000235e:	8082                	ret

0000000080002360 <killed>:

int
killed(struct proc *p)
{
    80002360:	1101                	addi	sp,sp,-32
    80002362:	ec06                	sd	ra,24(sp)
    80002364:	e822                	sd	s0,16(sp)
    80002366:	e426                	sd	s1,8(sp)
    80002368:	e04a                	sd	s2,0(sp)
    8000236a:	1000                	addi	s0,sp,32
    8000236c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	87c080e7          	jalr	-1924(ra) # 80000bea <acquire>
  k = p->killed;
    80002376:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	922080e7          	jalr	-1758(ra) # 80000c9e <release>
  return k;
}
    80002384:	854a                	mv	a0,s2
    80002386:	60e2                	ld	ra,24(sp)
    80002388:	6442                	ld	s0,16(sp)
    8000238a:	64a2                	ld	s1,8(sp)
    8000238c:	6902                	ld	s2,0(sp)
    8000238e:	6105                	addi	sp,sp,32
    80002390:	8082                	ret

0000000080002392 <wait>:
{
    80002392:	715d                	addi	sp,sp,-80
    80002394:	e486                	sd	ra,72(sp)
    80002396:	e0a2                	sd	s0,64(sp)
    80002398:	fc26                	sd	s1,56(sp)
    8000239a:	f84a                	sd	s2,48(sp)
    8000239c:	f44e                	sd	s3,40(sp)
    8000239e:	f052                	sd	s4,32(sp)
    800023a0:	ec56                	sd	s5,24(sp)
    800023a2:	e85a                	sd	s6,16(sp)
    800023a4:	e45e                	sd	s7,8(sp)
    800023a6:	e062                	sd	s8,0(sp)
    800023a8:	0880                	addi	s0,sp,80
    800023aa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	61a080e7          	jalr	1562(ra) # 800019c6 <myproc>
    800023b4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023b6:	0000e517          	auipc	a0,0xe
    800023ba:	7c250513          	addi	a0,a0,1986 # 80010b78 <wait_lock>
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	82c080e7          	jalr	-2004(ra) # 80000bea <acquire>
    havekids = 0;
    800023c6:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023c8:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ca:	00014997          	auipc	s3,0x14
    800023ce:	5c698993          	addi	s3,s3,1478 # 80016990 <tickslock>
        havekids = 1;
    800023d2:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023d4:	0000ec17          	auipc	s8,0xe
    800023d8:	7a4c0c13          	addi	s8,s8,1956 # 80010b78 <wait_lock>
    havekids = 0;
    800023dc:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023de:	0000f497          	auipc	s1,0xf
    800023e2:	bb248493          	addi	s1,s1,-1102 # 80010f90 <proc>
    800023e6:	a0bd                	j	80002454 <wait+0xc2>
          pid = pp->pid;
    800023e8:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023ec:	000b0e63          	beqz	s6,80002408 <wait+0x76>
    800023f0:	4691                	li	a3,4
    800023f2:	02c48613          	addi	a2,s1,44
    800023f6:	85da                	mv	a1,s6
    800023f8:	05093503          	ld	a0,80(s2)
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	288080e7          	jalr	648(ra) # 80001684 <copyout>
    80002404:	02054563          	bltz	a0,8000242e <wait+0x9c>
          freeproc(pp);
    80002408:	8526                	mv	a0,s1
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	76e080e7          	jalr	1902(ra) # 80001b78 <freeproc>
          release(&pp->lock);
    80002412:	8526                	mv	a0,s1
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	88a080e7          	jalr	-1910(ra) # 80000c9e <release>
          release(&wait_lock);
    8000241c:	0000e517          	auipc	a0,0xe
    80002420:	75c50513          	addi	a0,a0,1884 # 80010b78 <wait_lock>
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	87a080e7          	jalr	-1926(ra) # 80000c9e <release>
          return pid;
    8000242c:	a0b5                	j	80002498 <wait+0x106>
            release(&pp->lock);
    8000242e:	8526                	mv	a0,s1
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	86e080e7          	jalr	-1938(ra) # 80000c9e <release>
            release(&wait_lock);
    80002438:	0000e517          	auipc	a0,0xe
    8000243c:	74050513          	addi	a0,a0,1856 # 80010b78 <wait_lock>
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	85e080e7          	jalr	-1954(ra) # 80000c9e <release>
            return -1;
    80002448:	59fd                	li	s3,-1
    8000244a:	a0b9                	j	80002498 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000244c:	16848493          	addi	s1,s1,360
    80002450:	03348463          	beq	s1,s3,80002478 <wait+0xe6>
      if(pp->parent == p){
    80002454:	7c9c                	ld	a5,56(s1)
    80002456:	ff279be3          	bne	a5,s2,8000244c <wait+0xba>
        acquire(&pp->lock);
    8000245a:	8526                	mv	a0,s1
    8000245c:	ffffe097          	auipc	ra,0xffffe
    80002460:	78e080e7          	jalr	1934(ra) # 80000bea <acquire>
        if(pp->state == ZOMBIE){
    80002464:	4c9c                	lw	a5,24(s1)
    80002466:	f94781e3          	beq	a5,s4,800023e8 <wait+0x56>
        release(&pp->lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	832080e7          	jalr	-1998(ra) # 80000c9e <release>
        havekids = 1;
    80002474:	8756                	mv	a4,s5
    80002476:	bfd9                	j	8000244c <wait+0xba>
    if(!havekids || killed(p)){
    80002478:	c719                	beqz	a4,80002486 <wait+0xf4>
    8000247a:	854a                	mv	a0,s2
    8000247c:	00000097          	auipc	ra,0x0
    80002480:	ee4080e7          	jalr	-284(ra) # 80002360 <killed>
    80002484:	c51d                	beqz	a0,800024b2 <wait+0x120>
      release(&wait_lock);
    80002486:	0000e517          	auipc	a0,0xe
    8000248a:	6f250513          	addi	a0,a0,1778 # 80010b78 <wait_lock>
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	810080e7          	jalr	-2032(ra) # 80000c9e <release>
      return -1;
    80002496:	59fd                	li	s3,-1
}
    80002498:	854e                	mv	a0,s3
    8000249a:	60a6                	ld	ra,72(sp)
    8000249c:	6406                	ld	s0,64(sp)
    8000249e:	74e2                	ld	s1,56(sp)
    800024a0:	7942                	ld	s2,48(sp)
    800024a2:	79a2                	ld	s3,40(sp)
    800024a4:	7a02                	ld	s4,32(sp)
    800024a6:	6ae2                	ld	s5,24(sp)
    800024a8:	6b42                	ld	s6,16(sp)
    800024aa:	6ba2                	ld	s7,8(sp)
    800024ac:	6c02                	ld	s8,0(sp)
    800024ae:	6161                	addi	sp,sp,80
    800024b0:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024b2:	85e2                	mv	a1,s8
    800024b4:	854a                	mv	a0,s2
    800024b6:	00000097          	auipc	ra,0x0
    800024ba:	c02080e7          	jalr	-1022(ra) # 800020b8 <sleep>
    havekids = 0;
    800024be:	bf39                	j	800023dc <wait+0x4a>

00000000800024c0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024c0:	7179                	addi	sp,sp,-48
    800024c2:	f406                	sd	ra,40(sp)
    800024c4:	f022                	sd	s0,32(sp)
    800024c6:	ec26                	sd	s1,24(sp)
    800024c8:	e84a                	sd	s2,16(sp)
    800024ca:	e44e                	sd	s3,8(sp)
    800024cc:	e052                	sd	s4,0(sp)
    800024ce:	1800                	addi	s0,sp,48
    800024d0:	84aa                	mv	s1,a0
    800024d2:	892e                	mv	s2,a1
    800024d4:	89b2                	mv	s3,a2
    800024d6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	4ee080e7          	jalr	1262(ra) # 800019c6 <myproc>
  if(user_dst){
    800024e0:	c08d                	beqz	s1,80002502 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024e2:	86d2                	mv	a3,s4
    800024e4:	864e                	mv	a2,s3
    800024e6:	85ca                	mv	a1,s2
    800024e8:	6928                	ld	a0,80(a0)
    800024ea:	fffff097          	auipc	ra,0xfffff
    800024ee:	19a080e7          	jalr	410(ra) # 80001684 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024f2:	70a2                	ld	ra,40(sp)
    800024f4:	7402                	ld	s0,32(sp)
    800024f6:	64e2                	ld	s1,24(sp)
    800024f8:	6942                	ld	s2,16(sp)
    800024fa:	69a2                	ld	s3,8(sp)
    800024fc:	6a02                	ld	s4,0(sp)
    800024fe:	6145                	addi	sp,sp,48
    80002500:	8082                	ret
    memmove((char *)dst, src, len);
    80002502:	000a061b          	sext.w	a2,s4
    80002506:	85ce                	mv	a1,s3
    80002508:	854a                	mv	a0,s2
    8000250a:	fffff097          	auipc	ra,0xfffff
    8000250e:	83c080e7          	jalr	-1988(ra) # 80000d46 <memmove>
    return 0;
    80002512:	8526                	mv	a0,s1
    80002514:	bff9                	j	800024f2 <either_copyout+0x32>

0000000080002516 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002516:	7179                	addi	sp,sp,-48
    80002518:	f406                	sd	ra,40(sp)
    8000251a:	f022                	sd	s0,32(sp)
    8000251c:	ec26                	sd	s1,24(sp)
    8000251e:	e84a                	sd	s2,16(sp)
    80002520:	e44e                	sd	s3,8(sp)
    80002522:	e052                	sd	s4,0(sp)
    80002524:	1800                	addi	s0,sp,48
    80002526:	892a                	mv	s2,a0
    80002528:	84ae                	mv	s1,a1
    8000252a:	89b2                	mv	s3,a2
    8000252c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000252e:	fffff097          	auipc	ra,0xfffff
    80002532:	498080e7          	jalr	1176(ra) # 800019c6 <myproc>
  if(user_src){
    80002536:	c08d                	beqz	s1,80002558 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002538:	86d2                	mv	a3,s4
    8000253a:	864e                	mv	a2,s3
    8000253c:	85ca                	mv	a1,s2
    8000253e:	6928                	ld	a0,80(a0)
    80002540:	fffff097          	auipc	ra,0xfffff
    80002544:	1d0080e7          	jalr	464(ra) # 80001710 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002548:	70a2                	ld	ra,40(sp)
    8000254a:	7402                	ld	s0,32(sp)
    8000254c:	64e2                	ld	s1,24(sp)
    8000254e:	6942                	ld	s2,16(sp)
    80002550:	69a2                	ld	s3,8(sp)
    80002552:	6a02                	ld	s4,0(sp)
    80002554:	6145                	addi	sp,sp,48
    80002556:	8082                	ret
    memmove(dst, (char*)src, len);
    80002558:	000a061b          	sext.w	a2,s4
    8000255c:	85ce                	mv	a1,s3
    8000255e:	854a                	mv	a0,s2
    80002560:	ffffe097          	auipc	ra,0xffffe
    80002564:	7e6080e7          	jalr	2022(ra) # 80000d46 <memmove>
    return 0;
    80002568:	8526                	mv	a0,s1
    8000256a:	bff9                	j	80002548 <either_copyin+0x32>

000000008000256c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000256c:	715d                	addi	sp,sp,-80
    8000256e:	e486                	sd	ra,72(sp)
    80002570:	e0a2                	sd	s0,64(sp)
    80002572:	fc26                	sd	s1,56(sp)
    80002574:	f84a                	sd	s2,48(sp)
    80002576:	f44e                	sd	s3,40(sp)
    80002578:	f052                	sd	s4,32(sp)
    8000257a:	ec56                	sd	s5,24(sp)
    8000257c:	e85a                	sd	s6,16(sp)
    8000257e:	e45e                	sd	s7,8(sp)
    80002580:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002582:	00006517          	auipc	a0,0x6
    80002586:	b4650513          	addi	a0,a0,-1210 # 800080c8 <digits+0x88>
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	004080e7          	jalr	4(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002592:	0000f497          	auipc	s1,0xf
    80002596:	b5648493          	addi	s1,s1,-1194 # 800110e8 <proc+0x158>
    8000259a:	00014917          	auipc	s2,0x14
    8000259e:	54e90913          	addi	s2,s2,1358 # 80016ae8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025a4:	00006997          	auipc	s3,0x6
    800025a8:	cdc98993          	addi	s3,s3,-804 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025ac:	00006a97          	auipc	s5,0x6
    800025b0:	cdca8a93          	addi	s5,s5,-804 # 80008288 <digits+0x248>
    printf("\n");
    800025b4:	00006a17          	auipc	s4,0x6
    800025b8:	b14a0a13          	addi	s4,s4,-1260 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025bc:	00006b97          	auipc	s7,0x6
    800025c0:	d0cb8b93          	addi	s7,s7,-756 # 800082c8 <states.1746>
    800025c4:	a00d                	j	800025e6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025c6:	ed86a583          	lw	a1,-296(a3)
    800025ca:	8556                	mv	a0,s5
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	fc2080e7          	jalr	-62(ra) # 8000058e <printf>
    printf("\n");
    800025d4:	8552                	mv	a0,s4
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	fb8080e7          	jalr	-72(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025de:	16848493          	addi	s1,s1,360
    800025e2:	03248163          	beq	s1,s2,80002604 <procdump+0x98>
    if(p->state == UNUSED)
    800025e6:	86a6                	mv	a3,s1
    800025e8:	ec04a783          	lw	a5,-320(s1)
    800025ec:	dbed                	beqz	a5,800025de <procdump+0x72>
      state = "???";
    800025ee:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f0:	fcfb6be3          	bltu	s6,a5,800025c6 <procdump+0x5a>
    800025f4:	1782                	slli	a5,a5,0x20
    800025f6:	9381                	srli	a5,a5,0x20
    800025f8:	078e                	slli	a5,a5,0x3
    800025fa:	97de                	add	a5,a5,s7
    800025fc:	6390                	ld	a2,0(a5)
    800025fe:	f661                	bnez	a2,800025c6 <procdump+0x5a>
      state = "???";
    80002600:	864e                	mv	a2,s3
    80002602:	b7d1                	j	800025c6 <procdump+0x5a>
  }
}
    80002604:	60a6                	ld	ra,72(sp)
    80002606:	6406                	ld	s0,64(sp)
    80002608:	74e2                	ld	s1,56(sp)
    8000260a:	7942                	ld	s2,48(sp)
    8000260c:	79a2                	ld	s3,40(sp)
    8000260e:	7a02                	ld	s4,32(sp)
    80002610:	6ae2                	ld	s5,24(sp)
    80002612:	6b42                	ld	s6,16(sp)
    80002614:	6ba2                	ld	s7,8(sp)
    80002616:	6161                	addi	sp,sp,80
    80002618:	8082                	ret

000000008000261a <setpriority>:
*/


//Function that sets the priority of current process, equal to priority.
int setpriority(int priority)
{
    8000261a:	1101                	addi	sp,sp,-32
    8000261c:	ec06                	sd	ra,24(sp)
    8000261e:	e822                	sd	s0,16(sp)
    80002620:	e426                	sd	s1,8(sp)
    80002622:	e04a                	sd	s2,0(sp)
    80002624:	1000                	addi	s0,sp,32
    80002626:	892a                	mv	s2,a0
  struct proc* current_proc = myproc();
    80002628:	fffff097          	auipc	ra,0xfffff
    8000262c:	39e080e7          	jalr	926(ra) # 800019c6 <myproc>
    80002630:	84aa                	mv	s1,a0

  acquire(&current_proc->lock);
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	5b8080e7          	jalr	1464(ra) # 80000bea <acquire>

  //Priority given is not in the available bounds, or current process is null.
  if(priority < H_PRIO || priority > L_PRIO || !current_proc)
    8000263a:	fff9071b          	addiw	a4,s2,-1
    8000263e:	47cd                	li	a5,19
    80002640:	02e7e163          	bltu	a5,a4,80002662 <setpriority+0x48>
    80002644:	c08d                	beqz	s1,80002666 <setpriority+0x4c>
    return  -1;

  //Set priority = priority.
  current_proc->priority = priority;  
    80002646:	0324aa23          	sw	s2,52(s1)

  release(&current_proc->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	652080e7          	jalr	1618(ra) # 80000c9e <release>

  return 0;
    80002654:	4501                	li	a0,0
}
    80002656:	60e2                	ld	ra,24(sp)
    80002658:	6442                	ld	s0,16(sp)
    8000265a:	64a2                	ld	s1,8(sp)
    8000265c:	6902                	ld	s2,0(sp)
    8000265e:	6105                	addi	sp,sp,32
    80002660:	8082                	ret
    return  -1;
    80002662:	557d                	li	a0,-1
    80002664:	bfcd                	j	80002656 <setpriority+0x3c>
    80002666:	557d                	li	a0,-1
    80002668:	b7fd                	j	80002656 <setpriority+0x3c>

000000008000266a <getpinfo>:

//Retrieves useful information needed for ps
//and stores them into struct pstat. 
int getpinfo(struct pstat* pstats){
    8000266a:	715d                	addi	sp,sp,-80
    8000266c:	e486                	sd	ra,72(sp)
    8000266e:	e0a2                	sd	s0,64(sp)
    80002670:	fc26                	sd	s1,56(sp)
    80002672:	f84a                	sd	s2,48(sp)
    80002674:	f44e                	sd	s3,40(sp)
    80002676:	f052                	sd	s4,32(sp)
    80002678:	ec56                	sd	s5,24(sp)
    8000267a:	e85a                	sd	s6,16(sp)
    8000267c:	0880                	addi	s0,sp,80
    8000267e:	8b2a                	mv	s6,a0
  struct proc* p;

  uint64 addr; 
  argaddr(0, &addr); //User pointer to struct pstat stored in addr variable.
    80002680:	fb840593          	addi	a1,s0,-72
    80002684:	4501                	li	a0,0
    80002686:	00000097          	auipc	ra,0x0
    8000268a:	5e2080e7          	jalr	1506(ra) # 80002c68 <argaddr>

  int index = 0;
  for(p = proc; p < &proc[NPROC]; p++) {
    8000268e:	895a                	mv	s2,s6
    80002690:	002b1a93          	slli	s5,s6,0x2
    80002694:	415b0ab3          	sub	s5,s6,s5
    80002698:	0000f497          	auipc	s1,0xf
    8000269c:	8f848493          	addi	s1,s1,-1800 # 80010f90 <proc>
      else  
        pstats->ppid[index] = 0; //Default value of parent id if it does not exist.

      pstats->pid[index] = p->pid;
      pstats->priority[index] = p->priority;
      strncpy(pstats->name[index], p->name, 16);
    800026a0:	300a8a93          	addi	s5,s5,768
  for(p = proc; p < &proc[NPROC]; p++) {
    800026a4:	00014a17          	auipc	s4,0x14
    800026a8:	2eca0a13          	addi	s4,s4,748 # 80016990 <tickslock>
    800026ac:	a081                	j	800026ec <getpinfo+0x82>
        pstats->ppid[index] = 0; //Default value of parent id if it does not exist.
    800026ae:	10092023          	sw	zero,256(s2)
      pstats->pid[index] = p->pid;
    800026b2:	589c                	lw	a5,48(s1)
    800026b4:	00f92023          	sw	a5,0(s2)
      pstats->priority[index] = p->priority;
    800026b8:	58dc                	lw	a5,52(s1)
    800026ba:	20f92023          	sw	a5,512(s2)
      strncpy(pstats->name[index], p->name, 16);
    800026be:	00291513          	slli	a0,s2,0x2
    800026c2:	4641                	li	a2,16
    800026c4:	15898593          	addi	a1,s3,344
    800026c8:	9556                	add	a0,a0,s5
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	730080e7          	jalr	1840(ra) # 80000dfa <strncpy>
    }
    pstats->state[index] = p->state;
    800026d2:	4c9c                	lw	a5,24(s1)
    800026d4:	70f92023          	sw	a5,1792(s2)
    index++;

    release(&p->lock);
    800026d8:	8526                	mv	a0,s1
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	5c4080e7          	jalr	1476(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026e2:	16848493          	addi	s1,s1,360
    800026e6:	0911                	addi	s2,s2,4
    800026e8:	03448063          	beq	s1,s4,80002708 <getpinfo+0x9e>
    acquire(&p->lock);
    800026ec:	89a6                	mv	s3,s1
    800026ee:	8526                	mv	a0,s1
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	4fa080e7          	jalr	1274(ra) # 80000bea <acquire>
    if(p->state != UNUSED){
    800026f8:	4c9c                	lw	a5,24(s1)
    800026fa:	dfe1                	beqz	a5,800026d2 <getpinfo+0x68>
      if(p->parent != 0)
    800026fc:	7c9c                	ld	a5,56(s1)
    800026fe:	dbc5                	beqz	a5,800026ae <getpinfo+0x44>
        pstats->ppid[index] = p->parent->pid;
    80002700:	5b9c                	lw	a5,48(a5)
    80002702:	10f92023          	sw	a5,256(s2)
    80002706:	b775                	j	800026b2 <getpinfo+0x48>
  }
  
  //Copy struct pstat from kernel level to user level.
  if(copyout(myproc()->pagetable, addr, (char *)pstats, sizeof(struct pstat)) < 0)
    80002708:	fffff097          	auipc	ra,0xfffff
    8000270c:	2be080e7          	jalr	702(ra) # 800019c6 <myproc>
    80002710:	6685                	lui	a3,0x1
    80002712:	80068693          	addi	a3,a3,-2048 # 800 <_entry-0x7ffff800>
    80002716:	865a                	mv	a2,s6
    80002718:	fb843583          	ld	a1,-72(s0)
    8000271c:	6928                	ld	a0,80(a0)
    8000271e:	fffff097          	auipc	ra,0xfffff
    80002722:	f66080e7          	jalr	-154(ra) # 80001684 <copyout>
    return -1;

  return 0;
    80002726:	41f5551b          	sraiw	a0,a0,0x1f
    8000272a:	60a6                	ld	ra,72(sp)
    8000272c:	6406                	ld	s0,64(sp)
    8000272e:	74e2                	ld	s1,56(sp)
    80002730:	7942                	ld	s2,48(sp)
    80002732:	79a2                	ld	s3,40(sp)
    80002734:	7a02                	ld	s4,32(sp)
    80002736:	6ae2                	ld	s5,24(sp)
    80002738:	6b42                	ld	s6,16(sp)
    8000273a:	6161                	addi	sp,sp,80
    8000273c:	8082                	ret

000000008000273e <swtch>:
    8000273e:	00153023          	sd	ra,0(a0)
    80002742:	00253423          	sd	sp,8(a0)
    80002746:	e900                	sd	s0,16(a0)
    80002748:	ed04                	sd	s1,24(a0)
    8000274a:	03253023          	sd	s2,32(a0)
    8000274e:	03353423          	sd	s3,40(a0)
    80002752:	03453823          	sd	s4,48(a0)
    80002756:	03553c23          	sd	s5,56(a0)
    8000275a:	05653023          	sd	s6,64(a0)
    8000275e:	05753423          	sd	s7,72(a0)
    80002762:	05853823          	sd	s8,80(a0)
    80002766:	05953c23          	sd	s9,88(a0)
    8000276a:	07a53023          	sd	s10,96(a0)
    8000276e:	07b53423          	sd	s11,104(a0)
    80002772:	0005b083          	ld	ra,0(a1)
    80002776:	0085b103          	ld	sp,8(a1)
    8000277a:	6980                	ld	s0,16(a1)
    8000277c:	6d84                	ld	s1,24(a1)
    8000277e:	0205b903          	ld	s2,32(a1)
    80002782:	0285b983          	ld	s3,40(a1)
    80002786:	0305ba03          	ld	s4,48(a1)
    8000278a:	0385ba83          	ld	s5,56(a1)
    8000278e:	0405bb03          	ld	s6,64(a1)
    80002792:	0485bb83          	ld	s7,72(a1)
    80002796:	0505bc03          	ld	s8,80(a1)
    8000279a:	0585bc83          	ld	s9,88(a1)
    8000279e:	0605bd03          	ld	s10,96(a1)
    800027a2:	0685bd83          	ld	s11,104(a1)
    800027a6:	8082                	ret

00000000800027a8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800027a8:	1141                	addi	sp,sp,-16
    800027aa:	e406                	sd	ra,8(sp)
    800027ac:	e022                	sd	s0,0(sp)
    800027ae:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800027b0:	00006597          	auipc	a1,0x6
    800027b4:	b4858593          	addi	a1,a1,-1208 # 800082f8 <states.1746+0x30>
    800027b8:	00014517          	auipc	a0,0x14
    800027bc:	1d850513          	addi	a0,a0,472 # 80016990 <tickslock>
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	39a080e7          	jalr	922(ra) # 80000b5a <initlock>
}
    800027c8:	60a2                	ld	ra,8(sp)
    800027ca:	6402                	ld	s0,0(sp)
    800027cc:	0141                	addi	sp,sp,16
    800027ce:	8082                	ret

00000000800027d0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800027d0:	1141                	addi	sp,sp,-16
    800027d2:	e422                	sd	s0,8(sp)
    800027d4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027d6:	00003797          	auipc	a5,0x3
    800027da:	58a78793          	addi	a5,a5,1418 # 80005d60 <kernelvec>
    800027de:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027e2:	6422                	ld	s0,8(sp)
    800027e4:	0141                	addi	sp,sp,16
    800027e6:	8082                	ret

00000000800027e8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027e8:	1141                	addi	sp,sp,-16
    800027ea:	e406                	sd	ra,8(sp)
    800027ec:	e022                	sd	s0,0(sp)
    800027ee:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027f0:	fffff097          	auipc	ra,0xfffff
    800027f4:	1d6080e7          	jalr	470(ra) # 800019c6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027fc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027fe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002802:	00004617          	auipc	a2,0x4
    80002806:	7fe60613          	addi	a2,a2,2046 # 80007000 <_trampoline>
    8000280a:	00004697          	auipc	a3,0x4
    8000280e:	7f668693          	addi	a3,a3,2038 # 80007000 <_trampoline>
    80002812:	8e91                	sub	a3,a3,a2
    80002814:	040007b7          	lui	a5,0x4000
    80002818:	17fd                	addi	a5,a5,-1
    8000281a:	07b2                	slli	a5,a5,0xc
    8000281c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000281e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002822:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002824:	180026f3          	csrr	a3,satp
    80002828:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000282a:	6d38                	ld	a4,88(a0)
    8000282c:	6134                	ld	a3,64(a0)
    8000282e:	6585                	lui	a1,0x1
    80002830:	96ae                	add	a3,a3,a1
    80002832:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002834:	6d38                	ld	a4,88(a0)
    80002836:	00000697          	auipc	a3,0x0
    8000283a:	13068693          	addi	a3,a3,304 # 80002966 <usertrap>
    8000283e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002840:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002842:	8692                	mv	a3,tp
    80002844:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002846:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000284a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000284e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002852:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002856:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002858:	6f18                	ld	a4,24(a4)
    8000285a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000285e:	6928                	ld	a0,80(a0)
    80002860:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002862:	00005717          	auipc	a4,0x5
    80002866:	83a70713          	addi	a4,a4,-1990 # 8000709c <userret>
    8000286a:	8f11                	sub	a4,a4,a2
    8000286c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000286e:	577d                	li	a4,-1
    80002870:	177e                	slli	a4,a4,0x3f
    80002872:	8d59                	or	a0,a0,a4
    80002874:	9782                	jalr	a5
}
    80002876:	60a2                	ld	ra,8(sp)
    80002878:	6402                	ld	s0,0(sp)
    8000287a:	0141                	addi	sp,sp,16
    8000287c:	8082                	ret

000000008000287e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000287e:	1101                	addi	sp,sp,-32
    80002880:	ec06                	sd	ra,24(sp)
    80002882:	e822                	sd	s0,16(sp)
    80002884:	e426                	sd	s1,8(sp)
    80002886:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002888:	00014497          	auipc	s1,0x14
    8000288c:	10848493          	addi	s1,s1,264 # 80016990 <tickslock>
    80002890:	8526                	mv	a0,s1
    80002892:	ffffe097          	auipc	ra,0xffffe
    80002896:	358080e7          	jalr	856(ra) # 80000bea <acquire>
  ticks++;
    8000289a:	00006517          	auipc	a0,0x6
    8000289e:	05650513          	addi	a0,a0,86 # 800088f0 <ticks>
    800028a2:	411c                	lw	a5,0(a0)
    800028a4:	2785                	addiw	a5,a5,1
    800028a6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800028a8:	00000097          	auipc	ra,0x0
    800028ac:	874080e7          	jalr	-1932(ra) # 8000211c <wakeup>
  release(&tickslock);
    800028b0:	8526                	mv	a0,s1
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	3ec080e7          	jalr	1004(ra) # 80000c9e <release>
}
    800028ba:	60e2                	ld	ra,24(sp)
    800028bc:	6442                	ld	s0,16(sp)
    800028be:	64a2                	ld	s1,8(sp)
    800028c0:	6105                	addi	sp,sp,32
    800028c2:	8082                	ret

00000000800028c4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800028c4:	1101                	addi	sp,sp,-32
    800028c6:	ec06                	sd	ra,24(sp)
    800028c8:	e822                	sd	s0,16(sp)
    800028ca:	e426                	sd	s1,8(sp)
    800028cc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028ce:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800028d2:	00074d63          	bltz	a4,800028ec <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800028d6:	57fd                	li	a5,-1
    800028d8:	17fe                	slli	a5,a5,0x3f
    800028da:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800028dc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028de:	06f70363          	beq	a4,a5,80002944 <devintr+0x80>
  }
}
    800028e2:	60e2                	ld	ra,24(sp)
    800028e4:	6442                	ld	s0,16(sp)
    800028e6:	64a2                	ld	s1,8(sp)
    800028e8:	6105                	addi	sp,sp,32
    800028ea:	8082                	ret
     (scause & 0xff) == 9){
    800028ec:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800028f0:	46a5                	li	a3,9
    800028f2:	fed792e3          	bne	a5,a3,800028d6 <devintr+0x12>
    int irq = plic_claim();
    800028f6:	00003097          	auipc	ra,0x3
    800028fa:	572080e7          	jalr	1394(ra) # 80005e68 <plic_claim>
    800028fe:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002900:	47a9                	li	a5,10
    80002902:	02f50763          	beq	a0,a5,80002930 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002906:	4785                	li	a5,1
    80002908:	02f50963          	beq	a0,a5,8000293a <devintr+0x76>
    return 1;
    8000290c:	4505                	li	a0,1
    } else if(irq){
    8000290e:	d8f1                	beqz	s1,800028e2 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002910:	85a6                	mv	a1,s1
    80002912:	00006517          	auipc	a0,0x6
    80002916:	9ee50513          	addi	a0,a0,-1554 # 80008300 <states.1746+0x38>
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	c74080e7          	jalr	-908(ra) # 8000058e <printf>
      plic_complete(irq);
    80002922:	8526                	mv	a0,s1
    80002924:	00003097          	auipc	ra,0x3
    80002928:	568080e7          	jalr	1384(ra) # 80005e8c <plic_complete>
    return 1;
    8000292c:	4505                	li	a0,1
    8000292e:	bf55                	j	800028e2 <devintr+0x1e>
      uartintr();
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	07e080e7          	jalr	126(ra) # 800009ae <uartintr>
    80002938:	b7ed                	j	80002922 <devintr+0x5e>
      virtio_disk_intr();
    8000293a:	00004097          	auipc	ra,0x4
    8000293e:	a7c080e7          	jalr	-1412(ra) # 800063b6 <virtio_disk_intr>
    80002942:	b7c5                	j	80002922 <devintr+0x5e>
    if(cpuid() == 0){
    80002944:	fffff097          	auipc	ra,0xfffff
    80002948:	056080e7          	jalr	86(ra) # 8000199a <cpuid>
    8000294c:	c901                	beqz	a0,8000295c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000294e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002952:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002954:	14479073          	csrw	sip,a5
    return 2;
    80002958:	4509                	li	a0,2
    8000295a:	b761                	j	800028e2 <devintr+0x1e>
      clockintr();
    8000295c:	00000097          	auipc	ra,0x0
    80002960:	f22080e7          	jalr	-222(ra) # 8000287e <clockintr>
    80002964:	b7ed                	j	8000294e <devintr+0x8a>

0000000080002966 <usertrap>:
{
    80002966:	1101                	addi	sp,sp,-32
    80002968:	ec06                	sd	ra,24(sp)
    8000296a:	e822                	sd	s0,16(sp)
    8000296c:	e426                	sd	s1,8(sp)
    8000296e:	e04a                	sd	s2,0(sp)
    80002970:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002972:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002976:	1007f793          	andi	a5,a5,256
    8000297a:	e3b1                	bnez	a5,800029be <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000297c:	00003797          	auipc	a5,0x3
    80002980:	3e478793          	addi	a5,a5,996 # 80005d60 <kernelvec>
    80002984:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002988:	fffff097          	auipc	ra,0xfffff
    8000298c:	03e080e7          	jalr	62(ra) # 800019c6 <myproc>
    80002990:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002992:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002994:	14102773          	csrr	a4,sepc
    80002998:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000299a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000299e:	47a1                	li	a5,8
    800029a0:	02f70763          	beq	a4,a5,800029ce <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    800029a4:	00000097          	auipc	ra,0x0
    800029a8:	f20080e7          	jalr	-224(ra) # 800028c4 <devintr>
    800029ac:	892a                	mv	s2,a0
    800029ae:	c151                	beqz	a0,80002a32 <usertrap+0xcc>
  if(killed(p))
    800029b0:	8526                	mv	a0,s1
    800029b2:	00000097          	auipc	ra,0x0
    800029b6:	9ae080e7          	jalr	-1618(ra) # 80002360 <killed>
    800029ba:	c929                	beqz	a0,80002a0c <usertrap+0xa6>
    800029bc:	a099                	j	80002a02 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	96250513          	addi	a0,a0,-1694 # 80008320 <states.1746+0x58>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	b7e080e7          	jalr	-1154(ra) # 80000544 <panic>
    if(killed(p))
    800029ce:	00000097          	auipc	ra,0x0
    800029d2:	992080e7          	jalr	-1646(ra) # 80002360 <killed>
    800029d6:	e921                	bnez	a0,80002a26 <usertrap+0xc0>
    p->trapframe->epc += 4;
    800029d8:	6cb8                	ld	a4,88(s1)
    800029da:	6f1c                	ld	a5,24(a4)
    800029dc:	0791                	addi	a5,a5,4
    800029de:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029e4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029e8:	10079073          	csrw	sstatus,a5
    syscall();
    800029ec:	00000097          	auipc	ra,0x0
    800029f0:	33a080e7          	jalr	826(ra) # 80002d26 <syscall>
  if(killed(p))
    800029f4:	8526                	mv	a0,s1
    800029f6:	00000097          	auipc	ra,0x0
    800029fa:	96a080e7          	jalr	-1686(ra) # 80002360 <killed>
    800029fe:	c911                	beqz	a0,80002a12 <usertrap+0xac>
    80002a00:	4901                	li	s2,0
    exit(-1);
    80002a02:	557d                	li	a0,-1
    80002a04:	fffff097          	auipc	ra,0xfffff
    80002a08:	7e8080e7          	jalr	2024(ra) # 800021ec <exit>
  if(which_dev == 2)
    80002a0c:	4789                	li	a5,2
    80002a0e:	04f90f63          	beq	s2,a5,80002a6c <usertrap+0x106>
  usertrapret();
    80002a12:	00000097          	auipc	ra,0x0
    80002a16:	dd6080e7          	jalr	-554(ra) # 800027e8 <usertrapret>
}
    80002a1a:	60e2                	ld	ra,24(sp)
    80002a1c:	6442                	ld	s0,16(sp)
    80002a1e:	64a2                	ld	s1,8(sp)
    80002a20:	6902                	ld	s2,0(sp)
    80002a22:	6105                	addi	sp,sp,32
    80002a24:	8082                	ret
      exit(-1);
    80002a26:	557d                	li	a0,-1
    80002a28:	fffff097          	auipc	ra,0xfffff
    80002a2c:	7c4080e7          	jalr	1988(ra) # 800021ec <exit>
    80002a30:	b765                	j	800029d8 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a32:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a36:	5890                	lw	a2,48(s1)
    80002a38:	00006517          	auipc	a0,0x6
    80002a3c:	90850513          	addi	a0,a0,-1784 # 80008340 <states.1746+0x78>
    80002a40:	ffffe097          	auipc	ra,0xffffe
    80002a44:	b4e080e7          	jalr	-1202(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a48:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a4c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a50:	00006517          	auipc	a0,0x6
    80002a54:	92050513          	addi	a0,a0,-1760 # 80008370 <states.1746+0xa8>
    80002a58:	ffffe097          	auipc	ra,0xffffe
    80002a5c:	b36080e7          	jalr	-1226(ra) # 8000058e <printf>
    setkilled(p);
    80002a60:	8526                	mv	a0,s1
    80002a62:	00000097          	auipc	ra,0x0
    80002a66:	8d2080e7          	jalr	-1838(ra) # 80002334 <setkilled>
    80002a6a:	b769                	j	800029f4 <usertrap+0x8e>
    yield();
    80002a6c:	fffff097          	auipc	ra,0xfffff
    80002a70:	610080e7          	jalr	1552(ra) # 8000207c <yield>
    80002a74:	bf79                	j	80002a12 <usertrap+0xac>

0000000080002a76 <kerneltrap>:
{
    80002a76:	7179                	addi	sp,sp,-48
    80002a78:	f406                	sd	ra,40(sp)
    80002a7a:	f022                	sd	s0,32(sp)
    80002a7c:	ec26                	sd	s1,24(sp)
    80002a7e:	e84a                	sd	s2,16(sp)
    80002a80:	e44e                	sd	s3,8(sp)
    80002a82:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a84:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a88:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a8c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a90:	1004f793          	andi	a5,s1,256
    80002a94:	cb85                	beqz	a5,80002ac4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a96:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a9a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a9c:	ef85                	bnez	a5,80002ad4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a9e:	00000097          	auipc	ra,0x0
    80002aa2:	e26080e7          	jalr	-474(ra) # 800028c4 <devintr>
    80002aa6:	cd1d                	beqz	a0,80002ae4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002aa8:	4789                	li	a5,2
    80002aaa:	06f50a63          	beq	a0,a5,80002b1e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002aae:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ab2:	10049073          	csrw	sstatus,s1
}
    80002ab6:	70a2                	ld	ra,40(sp)
    80002ab8:	7402                	ld	s0,32(sp)
    80002aba:	64e2                	ld	s1,24(sp)
    80002abc:	6942                	ld	s2,16(sp)
    80002abe:	69a2                	ld	s3,8(sp)
    80002ac0:	6145                	addi	sp,sp,48
    80002ac2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ac4:	00006517          	auipc	a0,0x6
    80002ac8:	8cc50513          	addi	a0,a0,-1844 # 80008390 <states.1746+0xc8>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	a78080e7          	jalr	-1416(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ad4:	00006517          	auipc	a0,0x6
    80002ad8:	8e450513          	addi	a0,a0,-1820 # 800083b8 <states.1746+0xf0>
    80002adc:	ffffe097          	auipc	ra,0xffffe
    80002ae0:	a68080e7          	jalr	-1432(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002ae4:	85ce                	mv	a1,s3
    80002ae6:	00006517          	auipc	a0,0x6
    80002aea:	8f250513          	addi	a0,a0,-1806 # 800083d8 <states.1746+0x110>
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	aa0080e7          	jalr	-1376(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002af6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002afa:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002afe:	00006517          	auipc	a0,0x6
    80002b02:	8ea50513          	addi	a0,a0,-1814 # 800083e8 <states.1746+0x120>
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	a88080e7          	jalr	-1400(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002b0e:	00006517          	auipc	a0,0x6
    80002b12:	8f250513          	addi	a0,a0,-1806 # 80008400 <states.1746+0x138>
    80002b16:	ffffe097          	auipc	ra,0xffffe
    80002b1a:	a2e080e7          	jalr	-1490(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b1e:	fffff097          	auipc	ra,0xfffff
    80002b22:	ea8080e7          	jalr	-344(ra) # 800019c6 <myproc>
    80002b26:	d541                	beqz	a0,80002aae <kerneltrap+0x38>
    80002b28:	fffff097          	auipc	ra,0xfffff
    80002b2c:	e9e080e7          	jalr	-354(ra) # 800019c6 <myproc>
    80002b30:	4d18                	lw	a4,24(a0)
    80002b32:	4791                	li	a5,4
    80002b34:	f6f71de3          	bne	a4,a5,80002aae <kerneltrap+0x38>
    yield();
    80002b38:	fffff097          	auipc	ra,0xfffff
    80002b3c:	544080e7          	jalr	1348(ra) # 8000207c <yield>
    80002b40:	b7bd                	j	80002aae <kerneltrap+0x38>

0000000080002b42 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b42:	1101                	addi	sp,sp,-32
    80002b44:	ec06                	sd	ra,24(sp)
    80002b46:	e822                	sd	s0,16(sp)
    80002b48:	e426                	sd	s1,8(sp)
    80002b4a:	1000                	addi	s0,sp,32
    80002b4c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	e78080e7          	jalr	-392(ra) # 800019c6 <myproc>
  switch (n) {
    80002b56:	4795                	li	a5,5
    80002b58:	0497e163          	bltu	a5,s1,80002b9a <argraw+0x58>
    80002b5c:	048a                	slli	s1,s1,0x2
    80002b5e:	00006717          	auipc	a4,0x6
    80002b62:	8da70713          	addi	a4,a4,-1830 # 80008438 <states.1746+0x170>
    80002b66:	94ba                	add	s1,s1,a4
    80002b68:	409c                	lw	a5,0(s1)
    80002b6a:	97ba                	add	a5,a5,a4
    80002b6c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b6e:	6d3c                	ld	a5,88(a0)
    80002b70:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b72:	60e2                	ld	ra,24(sp)
    80002b74:	6442                	ld	s0,16(sp)
    80002b76:	64a2                	ld	s1,8(sp)
    80002b78:	6105                	addi	sp,sp,32
    80002b7a:	8082                	ret
    return p->trapframe->a1;
    80002b7c:	6d3c                	ld	a5,88(a0)
    80002b7e:	7fa8                	ld	a0,120(a5)
    80002b80:	bfcd                	j	80002b72 <argraw+0x30>
    return p->trapframe->a2;
    80002b82:	6d3c                	ld	a5,88(a0)
    80002b84:	63c8                	ld	a0,128(a5)
    80002b86:	b7f5                	j	80002b72 <argraw+0x30>
    return p->trapframe->a3;
    80002b88:	6d3c                	ld	a5,88(a0)
    80002b8a:	67c8                	ld	a0,136(a5)
    80002b8c:	b7dd                	j	80002b72 <argraw+0x30>
    return p->trapframe->a4;
    80002b8e:	6d3c                	ld	a5,88(a0)
    80002b90:	6bc8                	ld	a0,144(a5)
    80002b92:	b7c5                	j	80002b72 <argraw+0x30>
    return p->trapframe->a5;
    80002b94:	6d3c                	ld	a5,88(a0)
    80002b96:	6fc8                	ld	a0,152(a5)
    80002b98:	bfe9                	j	80002b72 <argraw+0x30>
  panic("argraw");
    80002b9a:	00006517          	auipc	a0,0x6
    80002b9e:	87650513          	addi	a0,a0,-1930 # 80008410 <states.1746+0x148>
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	9a2080e7          	jalr	-1630(ra) # 80000544 <panic>

0000000080002baa <fetchaddr>:
{
    80002baa:	1101                	addi	sp,sp,-32
    80002bac:	ec06                	sd	ra,24(sp)
    80002bae:	e822                	sd	s0,16(sp)
    80002bb0:	e426                	sd	s1,8(sp)
    80002bb2:	e04a                	sd	s2,0(sp)
    80002bb4:	1000                	addi	s0,sp,32
    80002bb6:	84aa                	mv	s1,a0
    80002bb8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bba:	fffff097          	auipc	ra,0xfffff
    80002bbe:	e0c080e7          	jalr	-500(ra) # 800019c6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002bc2:	653c                	ld	a5,72(a0)
    80002bc4:	02f4f863          	bgeu	s1,a5,80002bf4 <fetchaddr+0x4a>
    80002bc8:	00848713          	addi	a4,s1,8
    80002bcc:	02e7e663          	bltu	a5,a4,80002bf8 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002bd0:	46a1                	li	a3,8
    80002bd2:	8626                	mv	a2,s1
    80002bd4:	85ca                	mv	a1,s2
    80002bd6:	6928                	ld	a0,80(a0)
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	b38080e7          	jalr	-1224(ra) # 80001710 <copyin>
    80002be0:	00a03533          	snez	a0,a0
    80002be4:	40a00533          	neg	a0,a0
}
    80002be8:	60e2                	ld	ra,24(sp)
    80002bea:	6442                	ld	s0,16(sp)
    80002bec:	64a2                	ld	s1,8(sp)
    80002bee:	6902                	ld	s2,0(sp)
    80002bf0:	6105                	addi	sp,sp,32
    80002bf2:	8082                	ret
    return -1;
    80002bf4:	557d                	li	a0,-1
    80002bf6:	bfcd                	j	80002be8 <fetchaddr+0x3e>
    80002bf8:	557d                	li	a0,-1
    80002bfa:	b7fd                	j	80002be8 <fetchaddr+0x3e>

0000000080002bfc <fetchstr>:
{
    80002bfc:	7179                	addi	sp,sp,-48
    80002bfe:	f406                	sd	ra,40(sp)
    80002c00:	f022                	sd	s0,32(sp)
    80002c02:	ec26                	sd	s1,24(sp)
    80002c04:	e84a                	sd	s2,16(sp)
    80002c06:	e44e                	sd	s3,8(sp)
    80002c08:	1800                	addi	s0,sp,48
    80002c0a:	892a                	mv	s2,a0
    80002c0c:	84ae                	mv	s1,a1
    80002c0e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c10:	fffff097          	auipc	ra,0xfffff
    80002c14:	db6080e7          	jalr	-586(ra) # 800019c6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c18:	86ce                	mv	a3,s3
    80002c1a:	864a                	mv	a2,s2
    80002c1c:	85a6                	mv	a1,s1
    80002c1e:	6928                	ld	a0,80(a0)
    80002c20:	fffff097          	auipc	ra,0xfffff
    80002c24:	b7c080e7          	jalr	-1156(ra) # 8000179c <copyinstr>
    80002c28:	00054e63          	bltz	a0,80002c44 <fetchstr+0x48>
  return strlen(buf);
    80002c2c:	8526                	mv	a0,s1
    80002c2e:	ffffe097          	auipc	ra,0xffffe
    80002c32:	23c080e7          	jalr	572(ra) # 80000e6a <strlen>
}
    80002c36:	70a2                	ld	ra,40(sp)
    80002c38:	7402                	ld	s0,32(sp)
    80002c3a:	64e2                	ld	s1,24(sp)
    80002c3c:	6942                	ld	s2,16(sp)
    80002c3e:	69a2                	ld	s3,8(sp)
    80002c40:	6145                	addi	sp,sp,48
    80002c42:	8082                	ret
    return -1;
    80002c44:	557d                	li	a0,-1
    80002c46:	bfc5                	j	80002c36 <fetchstr+0x3a>

0000000080002c48 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	e426                	sd	s1,8(sp)
    80002c50:	1000                	addi	s0,sp,32
    80002c52:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c54:	00000097          	auipc	ra,0x0
    80002c58:	eee080e7          	jalr	-274(ra) # 80002b42 <argraw>
    80002c5c:	c088                	sw	a0,0(s1)
}
    80002c5e:	60e2                	ld	ra,24(sp)
    80002c60:	6442                	ld	s0,16(sp)
    80002c62:	64a2                	ld	s1,8(sp)
    80002c64:	6105                	addi	sp,sp,32
    80002c66:	8082                	ret

0000000080002c68 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c68:	1101                	addi	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	1000                	addi	s0,sp,32
    80002c72:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c74:	00000097          	auipc	ra,0x0
    80002c78:	ece080e7          	jalr	-306(ra) # 80002b42 <argraw>
    80002c7c:	e088                	sd	a0,0(s1)
}
    80002c7e:	60e2                	ld	ra,24(sp)
    80002c80:	6442                	ld	s0,16(sp)
    80002c82:	64a2                	ld	s1,8(sp)
    80002c84:	6105                	addi	sp,sp,32
    80002c86:	8082                	ret

0000000080002c88 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c88:	7179                	addi	sp,sp,-48
    80002c8a:	f406                	sd	ra,40(sp)
    80002c8c:	f022                	sd	s0,32(sp)
    80002c8e:	ec26                	sd	s1,24(sp)
    80002c90:	e84a                	sd	s2,16(sp)
    80002c92:	1800                	addi	s0,sp,48
    80002c94:	84ae                	mv	s1,a1
    80002c96:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c98:	fd840593          	addi	a1,s0,-40
    80002c9c:	00000097          	auipc	ra,0x0
    80002ca0:	fcc080e7          	jalr	-52(ra) # 80002c68 <argaddr>
  return fetchstr(addr, buf, max);
    80002ca4:	864a                	mv	a2,s2
    80002ca6:	85a6                	mv	a1,s1
    80002ca8:	fd843503          	ld	a0,-40(s0)
    80002cac:	00000097          	auipc	ra,0x0
    80002cb0:	f50080e7          	jalr	-176(ra) # 80002bfc <fetchstr>
}
    80002cb4:	70a2                	ld	ra,40(sp)
    80002cb6:	7402                	ld	s0,32(sp)
    80002cb8:	64e2                	ld	s1,24(sp)
    80002cba:	6942                	ld	s2,16(sp)
    80002cbc:	6145                	addi	sp,sp,48
    80002cbe:	8082                	ret

0000000080002cc0 <argpstat>:

//////////////////////////////////////////////
//Initializes struct pstat, and checks if there is enogh size for it.
int
argpstat(int n, struct pstat *pp, int size)
{
    80002cc0:	7139                	addi	sp,sp,-64
    80002cc2:	fc06                	sd	ra,56(sp)
    80002cc4:	f822                	sd	s0,48(sp)
    80002cc6:	f426                	sd	s1,40(sp)
    80002cc8:	f04a                	sd	s2,32(sp)
    80002cca:	ec4e                	sd	s3,24(sp)
    80002ccc:	0080                	addi	s0,sp,64
    80002cce:	892a                	mv	s2,a0
    80002cd0:	84b2                	mv	s1,a2
  struct proc *curproc = myproc();
    80002cd2:	fffff097          	auipc	ra,0xfffff
    80002cd6:	cf4080e7          	jalr	-780(ra) # 800019c6 <myproc>
    80002cda:	89aa                	mv	s3,a0
 
  int i;
  argint(n, &i);
    80002cdc:	fcc40593          	addi	a1,s0,-52
    80002ce0:	854a                	mv	a0,s2
    80002ce2:	00000097          	auipc	ra,0x0
    80002ce6:	f66080e7          	jalr	-154(ra) # 80002c48 <argint>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    80002cea:	0204ca63          	bltz	s1,80002d1e <argpstat+0x5e>
    80002cee:	fcc42603          	lw	a2,-52(s0)
    80002cf2:	0489b503          	ld	a0,72(s3)
    80002cf6:	02061793          	slli	a5,a2,0x20
    80002cfa:	9381                	srli	a5,a5,0x20
    80002cfc:	02a7f363          	bgeu	a5,a0,80002d22 <argpstat+0x62>
    80002d00:	9cb1                	addw	s1,s1,a2
    80002d02:	1482                	slli	s1,s1,0x20
    80002d04:	9081                	srli	s1,s1,0x20
    80002d06:	00953533          	sltu	a0,a0,s1
    80002d0a:	40a0053b          	negw	a0,a0
    80002d0e:	2501                	sext.w	a0,a0
    return -1;

  struct pstat p;
  pp = (struct pstat*)&p;
  return 0;
}
    80002d10:	70e2                	ld	ra,56(sp)
    80002d12:	7442                	ld	s0,48(sp)
    80002d14:	74a2                	ld	s1,40(sp)
    80002d16:	7902                	ld	s2,32(sp)
    80002d18:	69e2                	ld	s3,24(sp)
    80002d1a:	6121                	addi	sp,sp,64
    80002d1c:	8082                	ret
    return -1;
    80002d1e:	557d                	li	a0,-1
    80002d20:	bfc5                	j	80002d10 <argpstat+0x50>
    80002d22:	557d                	li	a0,-1
    80002d24:	b7f5                	j	80002d10 <argpstat+0x50>

0000000080002d26 <syscall>:

};

void
syscall(void)
{
    80002d26:	1101                	addi	sp,sp,-32
    80002d28:	ec06                	sd	ra,24(sp)
    80002d2a:	e822                	sd	s0,16(sp)
    80002d2c:	e426                	sd	s1,8(sp)
    80002d2e:	e04a                	sd	s2,0(sp)
    80002d30:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	c94080e7          	jalr	-876(ra) # 800019c6 <myproc>
    80002d3a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d3c:	05853903          	ld	s2,88(a0)
    80002d40:	0a893783          	ld	a5,168(s2)
    80002d44:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d48:	37fd                	addiw	a5,a5,-1
    80002d4a:	4759                	li	a4,22
    80002d4c:	00f76f63          	bltu	a4,a5,80002d6a <syscall+0x44>
    80002d50:	00369713          	slli	a4,a3,0x3
    80002d54:	00005797          	auipc	a5,0x5
    80002d58:	6fc78793          	addi	a5,a5,1788 # 80008450 <syscalls>
    80002d5c:	97ba                	add	a5,a5,a4
    80002d5e:	639c                	ld	a5,0(a5)
    80002d60:	c789                	beqz	a5,80002d6a <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d62:	9782                	jalr	a5
    80002d64:	06a93823          	sd	a0,112(s2)
    80002d68:	a839                	j	80002d86 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d6a:	15848613          	addi	a2,s1,344
    80002d6e:	588c                	lw	a1,48(s1)
    80002d70:	00005517          	auipc	a0,0x5
    80002d74:	6a850513          	addi	a0,a0,1704 # 80008418 <states.1746+0x150>
    80002d78:	ffffe097          	auipc	ra,0xffffe
    80002d7c:	816080e7          	jalr	-2026(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d80:	6cbc                	ld	a5,88(s1)
    80002d82:	577d                	li	a4,-1
    80002d84:	fbb8                	sd	a4,112(a5)
  }
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6902                	ld	s2,0(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <sys_exit>:
#include "proc.h"


uint64
sys_exit(void)
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002d9a:	fec40593          	addi	a1,s0,-20
    80002d9e:	4501                	li	a0,0
    80002da0:	00000097          	auipc	ra,0x0
    80002da4:	ea8080e7          	jalr	-344(ra) # 80002c48 <argint>
  exit(n);
    80002da8:	fec42503          	lw	a0,-20(s0)
    80002dac:	fffff097          	auipc	ra,0xfffff
    80002db0:	440080e7          	jalr	1088(ra) # 800021ec <exit>
  return 0;  // not reached
}
    80002db4:	4501                	li	a0,0
    80002db6:	60e2                	ld	ra,24(sp)
    80002db8:	6442                	ld	s0,16(sp)
    80002dba:	6105                	addi	sp,sp,32
    80002dbc:	8082                	ret

0000000080002dbe <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dbe:	1141                	addi	sp,sp,-16
    80002dc0:	e406                	sd	ra,8(sp)
    80002dc2:	e022                	sd	s0,0(sp)
    80002dc4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	c00080e7          	jalr	-1024(ra) # 800019c6 <myproc>
}
    80002dce:	5908                	lw	a0,48(a0)
    80002dd0:	60a2                	ld	ra,8(sp)
    80002dd2:	6402                	ld	s0,0(sp)
    80002dd4:	0141                	addi	sp,sp,16
    80002dd6:	8082                	ret

0000000080002dd8 <sys_fork>:

uint64
sys_fork(void)
{
    80002dd8:	1141                	addi	sp,sp,-16
    80002dda:	e406                	sd	ra,8(sp)
    80002ddc:	e022                	sd	s0,0(sp)
    80002dde:	0800                	addi	s0,sp,16
  return fork();
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	fa0080e7          	jalr	-96(ra) # 80001d80 <fork>
}
    80002de8:	60a2                	ld	ra,8(sp)
    80002dea:	6402                	ld	s0,0(sp)
    80002dec:	0141                	addi	sp,sp,16
    80002dee:	8082                	ret

0000000080002df0 <sys_wait>:

uint64
sys_wait(void)
{
    80002df0:	1101                	addi	sp,sp,-32
    80002df2:	ec06                	sd	ra,24(sp)
    80002df4:	e822                	sd	s0,16(sp)
    80002df6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002df8:	fe840593          	addi	a1,s0,-24
    80002dfc:	4501                	li	a0,0
    80002dfe:	00000097          	auipc	ra,0x0
    80002e02:	e6a080e7          	jalr	-406(ra) # 80002c68 <argaddr>
  return wait(p);
    80002e06:	fe843503          	ld	a0,-24(s0)
    80002e0a:	fffff097          	auipc	ra,0xfffff
    80002e0e:	588080e7          	jalr	1416(ra) # 80002392 <wait>
}
    80002e12:	60e2                	ld	ra,24(sp)
    80002e14:	6442                	ld	s0,16(sp)
    80002e16:	6105                	addi	sp,sp,32
    80002e18:	8082                	ret

0000000080002e1a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e1a:	7179                	addi	sp,sp,-48
    80002e1c:	f406                	sd	ra,40(sp)
    80002e1e:	f022                	sd	s0,32(sp)
    80002e20:	ec26                	sd	s1,24(sp)
    80002e22:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002e24:	fdc40593          	addi	a1,s0,-36
    80002e28:	4501                	li	a0,0
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	e1e080e7          	jalr	-482(ra) # 80002c48 <argint>
  addr = myproc()->sz;
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	b94080e7          	jalr	-1132(ra) # 800019c6 <myproc>
    80002e3a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002e3c:	fdc42503          	lw	a0,-36(s0)
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	ee4080e7          	jalr	-284(ra) # 80001d24 <growproc>
    80002e48:	00054863          	bltz	a0,80002e58 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002e4c:	8526                	mv	a0,s1
    80002e4e:	70a2                	ld	ra,40(sp)
    80002e50:	7402                	ld	s0,32(sp)
    80002e52:	64e2                	ld	s1,24(sp)
    80002e54:	6145                	addi	sp,sp,48
    80002e56:	8082                	ret
    return -1;
    80002e58:	54fd                	li	s1,-1
    80002e5a:	bfcd                	j	80002e4c <sys_sbrk+0x32>

0000000080002e5c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e5c:	7139                	addi	sp,sp,-64
    80002e5e:	fc06                	sd	ra,56(sp)
    80002e60:	f822                	sd	s0,48(sp)
    80002e62:	f426                	sd	s1,40(sp)
    80002e64:	f04a                	sd	s2,32(sp)
    80002e66:	ec4e                	sd	s3,24(sp)
    80002e68:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e6a:	fcc40593          	addi	a1,s0,-52
    80002e6e:	4501                	li	a0,0
    80002e70:	00000097          	auipc	ra,0x0
    80002e74:	dd8080e7          	jalr	-552(ra) # 80002c48 <argint>
  acquire(&tickslock);
    80002e78:	00014517          	auipc	a0,0x14
    80002e7c:	b1850513          	addi	a0,a0,-1256 # 80016990 <tickslock>
    80002e80:	ffffe097          	auipc	ra,0xffffe
    80002e84:	d6a080e7          	jalr	-662(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80002e88:	00006917          	auipc	s2,0x6
    80002e8c:	a6892903          	lw	s2,-1432(s2) # 800088f0 <ticks>
  while(ticks - ticks0 < n){
    80002e90:	fcc42783          	lw	a5,-52(s0)
    80002e94:	cf9d                	beqz	a5,80002ed2 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e96:	00014997          	auipc	s3,0x14
    80002e9a:	afa98993          	addi	s3,s3,-1286 # 80016990 <tickslock>
    80002e9e:	00006497          	auipc	s1,0x6
    80002ea2:	a5248493          	addi	s1,s1,-1454 # 800088f0 <ticks>
    if(killed(myproc())){
    80002ea6:	fffff097          	auipc	ra,0xfffff
    80002eaa:	b20080e7          	jalr	-1248(ra) # 800019c6 <myproc>
    80002eae:	fffff097          	auipc	ra,0xfffff
    80002eb2:	4b2080e7          	jalr	1202(ra) # 80002360 <killed>
    80002eb6:	ed15                	bnez	a0,80002ef2 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002eb8:	85ce                	mv	a1,s3
    80002eba:	8526                	mv	a0,s1
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	1fc080e7          	jalr	508(ra) # 800020b8 <sleep>
  while(ticks - ticks0 < n){
    80002ec4:	409c                	lw	a5,0(s1)
    80002ec6:	412787bb          	subw	a5,a5,s2
    80002eca:	fcc42703          	lw	a4,-52(s0)
    80002ece:	fce7ece3          	bltu	a5,a4,80002ea6 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002ed2:	00014517          	auipc	a0,0x14
    80002ed6:	abe50513          	addi	a0,a0,-1346 # 80016990 <tickslock>
    80002eda:	ffffe097          	auipc	ra,0xffffe
    80002ede:	dc4080e7          	jalr	-572(ra) # 80000c9e <release>
  return 0;
    80002ee2:	4501                	li	a0,0
}
    80002ee4:	70e2                	ld	ra,56(sp)
    80002ee6:	7442                	ld	s0,48(sp)
    80002ee8:	74a2                	ld	s1,40(sp)
    80002eea:	7902                	ld	s2,32(sp)
    80002eec:	69e2                	ld	s3,24(sp)
    80002eee:	6121                	addi	sp,sp,64
    80002ef0:	8082                	ret
      release(&tickslock);
    80002ef2:	00014517          	auipc	a0,0x14
    80002ef6:	a9e50513          	addi	a0,a0,-1378 # 80016990 <tickslock>
    80002efa:	ffffe097          	auipc	ra,0xffffe
    80002efe:	da4080e7          	jalr	-604(ra) # 80000c9e <release>
      return -1;
    80002f02:	557d                	li	a0,-1
    80002f04:	b7c5                	j	80002ee4 <sys_sleep+0x88>

0000000080002f06 <sys_kill>:

uint64
sys_kill(void)
{
    80002f06:	1101                	addi	sp,sp,-32
    80002f08:	ec06                	sd	ra,24(sp)
    80002f0a:	e822                	sd	s0,16(sp)
    80002f0c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f0e:	fec40593          	addi	a1,s0,-20
    80002f12:	4501                	li	a0,0
    80002f14:	00000097          	auipc	ra,0x0
    80002f18:	d34080e7          	jalr	-716(ra) # 80002c48 <argint>
  return kill(pid);
    80002f1c:	fec42503          	lw	a0,-20(s0)
    80002f20:	fffff097          	auipc	ra,0xfffff
    80002f24:	3a2080e7          	jalr	930(ra) # 800022c2 <kill>
}
    80002f28:	60e2                	ld	ra,24(sp)
    80002f2a:	6442                	ld	s0,16(sp)
    80002f2c:	6105                	addi	sp,sp,32
    80002f2e:	8082                	ret

0000000080002f30 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f30:	1101                	addi	sp,sp,-32
    80002f32:	ec06                	sd	ra,24(sp)
    80002f34:	e822                	sd	s0,16(sp)
    80002f36:	e426                	sd	s1,8(sp)
    80002f38:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f3a:	00014517          	auipc	a0,0x14
    80002f3e:	a5650513          	addi	a0,a0,-1450 # 80016990 <tickslock>
    80002f42:	ffffe097          	auipc	ra,0xffffe
    80002f46:	ca8080e7          	jalr	-856(ra) # 80000bea <acquire>
  xticks = ticks;
    80002f4a:	00006497          	auipc	s1,0x6
    80002f4e:	9a64a483          	lw	s1,-1626(s1) # 800088f0 <ticks>
  release(&tickslock);
    80002f52:	00014517          	auipc	a0,0x14
    80002f56:	a3e50513          	addi	a0,a0,-1474 # 80016990 <tickslock>
    80002f5a:	ffffe097          	auipc	ra,0xffffe
    80002f5e:	d44080e7          	jalr	-700(ra) # 80000c9e <release>
  return xticks;
}
    80002f62:	02049513          	slli	a0,s1,0x20
    80002f66:	9101                	srli	a0,a0,0x20
    80002f68:	60e2                	ld	ra,24(sp)
    80002f6a:	6442                	ld	s0,16(sp)
    80002f6c:	64a2                	ld	s1,8(sp)
    80002f6e:	6105                	addi	sp,sp,32
    80002f70:	8082                	ret

0000000080002f72 <sys_setpriority>:

/////////////////////////////////////////////////////////////////////////////////////////////////////
uint64
sys_setpriority(void)
{
    80002f72:	1101                	addi	sp,sp,-32
    80002f74:	ec06                	sd	ra,24(sp)
    80002f76:	e822                	sd	s0,16(sp)
    80002f78:	1000                	addi	s0,sp,32
  int priority;
  argint(0, &priority);
    80002f7a:	fec40593          	addi	a1,s0,-20
    80002f7e:	4501                	li	a0,0
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	cc8080e7          	jalr	-824(ra) # 80002c48 <argint>
  return setpriority(priority);
    80002f88:	fec42503          	lw	a0,-20(s0)
    80002f8c:	fffff097          	auipc	ra,0xfffff
    80002f90:	68e080e7          	jalr	1678(ra) # 8000261a <setpriority>
}
    80002f94:	60e2                	ld	ra,24(sp)
    80002f96:	6442                	ld	s0,16(sp)
    80002f98:	6105                	addi	sp,sp,32
    80002f9a:	8082                	ret

0000000080002f9c <sys_getpinfo>:


uint64
sys_getpinfo(void)
{
    80002f9c:	7179                	addi	sp,sp,-48
    80002f9e:	f406                	sd	ra,40(sp)
    80002fa0:	f022                	sd	s0,32(sp)
    80002fa2:	ec26                	sd	s1,24(sp)
    80002fa4:	1800                	addi	s0,sp,48
    80002fa6:	81010113          	addi	sp,sp,-2032
  struct pstat pstats;

  //Checks if the current instantiation of the struct pstat is allowed.
  if(argpstat (0 , &pstats ,sizeof(struct pstat)) < 0)
    80002faa:	6605                	lui	a2,0x1
    80002fac:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80002fb0:	74fd                	lui	s1,0xfffff
    80002fb2:	7f048793          	addi	a5,s1,2032 # fffffffffffff7f0 <end+0xffffffff7ffdda80>
    80002fb6:	ff040713          	addi	a4,s0,-16
    80002fba:	00f705b3          	add	a1,a4,a5
    80002fbe:	4501                	li	a0,0
    80002fc0:	00000097          	auipc	ra,0x0
    80002fc4:	d00080e7          	jalr	-768(ra) # 80002cc0 <argpstat>
    80002fc8:	87aa                	mv	a5,a0
    return -1;
    80002fca:	557d                	li	a0,-1
  if(argpstat (0 , &pstats ,sizeof(struct pstat)) < 0)
    80002fcc:	0007cc63          	bltz	a5,80002fe4 <sys_getpinfo+0x48>

  return getpinfo(&pstats);
    80002fd0:	7f048793          	addi	a5,s1,2032
    80002fd4:	ff040713          	addi	a4,s0,-16
    80002fd8:	00f70533          	add	a0,a4,a5
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	68e080e7          	jalr	1678(ra) # 8000266a <getpinfo>
    80002fe4:	7f010113          	addi	sp,sp,2032
    80002fe8:	70a2                	ld	ra,40(sp)
    80002fea:	7402                	ld	s0,32(sp)
    80002fec:	64e2                	ld	s1,24(sp)
    80002fee:	6145                	addi	sp,sp,48
    80002ff0:	8082                	ret

0000000080002ff2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ff2:	7179                	addi	sp,sp,-48
    80002ff4:	f406                	sd	ra,40(sp)
    80002ff6:	f022                	sd	s0,32(sp)
    80002ff8:	ec26                	sd	s1,24(sp)
    80002ffa:	e84a                	sd	s2,16(sp)
    80002ffc:	e44e                	sd	s3,8(sp)
    80002ffe:	e052                	sd	s4,0(sp)
    80003000:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003002:	00005597          	auipc	a1,0x5
    80003006:	50e58593          	addi	a1,a1,1294 # 80008510 <syscalls+0xc0>
    8000300a:	00014517          	auipc	a0,0x14
    8000300e:	99e50513          	addi	a0,a0,-1634 # 800169a8 <bcache>
    80003012:	ffffe097          	auipc	ra,0xffffe
    80003016:	b48080e7          	jalr	-1208(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000301a:	0001c797          	auipc	a5,0x1c
    8000301e:	98e78793          	addi	a5,a5,-1650 # 8001e9a8 <bcache+0x8000>
    80003022:	0001c717          	auipc	a4,0x1c
    80003026:	bee70713          	addi	a4,a4,-1042 # 8001ec10 <bcache+0x8268>
    8000302a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000302e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003032:	00014497          	auipc	s1,0x14
    80003036:	98e48493          	addi	s1,s1,-1650 # 800169c0 <bcache+0x18>
    b->next = bcache.head.next;
    8000303a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000303c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000303e:	00005a17          	auipc	s4,0x5
    80003042:	4daa0a13          	addi	s4,s4,1242 # 80008518 <syscalls+0xc8>
    b->next = bcache.head.next;
    80003046:	2b893783          	ld	a5,696(s2)
    8000304a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000304c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003050:	85d2                	mv	a1,s4
    80003052:	01048513          	addi	a0,s1,16
    80003056:	00001097          	auipc	ra,0x1
    8000305a:	4c4080e7          	jalr	1220(ra) # 8000451a <initsleeplock>
    bcache.head.next->prev = b;
    8000305e:	2b893783          	ld	a5,696(s2)
    80003062:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003064:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003068:	45848493          	addi	s1,s1,1112
    8000306c:	fd349de3          	bne	s1,s3,80003046 <binit+0x54>
  }
}
    80003070:	70a2                	ld	ra,40(sp)
    80003072:	7402                	ld	s0,32(sp)
    80003074:	64e2                	ld	s1,24(sp)
    80003076:	6942                	ld	s2,16(sp)
    80003078:	69a2                	ld	s3,8(sp)
    8000307a:	6a02                	ld	s4,0(sp)
    8000307c:	6145                	addi	sp,sp,48
    8000307e:	8082                	ret

0000000080003080 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003080:	7179                	addi	sp,sp,-48
    80003082:	f406                	sd	ra,40(sp)
    80003084:	f022                	sd	s0,32(sp)
    80003086:	ec26                	sd	s1,24(sp)
    80003088:	e84a                	sd	s2,16(sp)
    8000308a:	e44e                	sd	s3,8(sp)
    8000308c:	1800                	addi	s0,sp,48
    8000308e:	89aa                	mv	s3,a0
    80003090:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003092:	00014517          	auipc	a0,0x14
    80003096:	91650513          	addi	a0,a0,-1770 # 800169a8 <bcache>
    8000309a:	ffffe097          	auipc	ra,0xffffe
    8000309e:	b50080e7          	jalr	-1200(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030a2:	0001c497          	auipc	s1,0x1c
    800030a6:	bbe4b483          	ld	s1,-1090(s1) # 8001ec60 <bcache+0x82b8>
    800030aa:	0001c797          	auipc	a5,0x1c
    800030ae:	b6678793          	addi	a5,a5,-1178 # 8001ec10 <bcache+0x8268>
    800030b2:	02f48f63          	beq	s1,a5,800030f0 <bread+0x70>
    800030b6:	873e                	mv	a4,a5
    800030b8:	a021                	j	800030c0 <bread+0x40>
    800030ba:	68a4                	ld	s1,80(s1)
    800030bc:	02e48a63          	beq	s1,a4,800030f0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030c0:	449c                	lw	a5,8(s1)
    800030c2:	ff379ce3          	bne	a5,s3,800030ba <bread+0x3a>
    800030c6:	44dc                	lw	a5,12(s1)
    800030c8:	ff2799e3          	bne	a5,s2,800030ba <bread+0x3a>
      b->refcnt++;
    800030cc:	40bc                	lw	a5,64(s1)
    800030ce:	2785                	addiw	a5,a5,1
    800030d0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030d2:	00014517          	auipc	a0,0x14
    800030d6:	8d650513          	addi	a0,a0,-1834 # 800169a8 <bcache>
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	bc4080e7          	jalr	-1084(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800030e2:	01048513          	addi	a0,s1,16
    800030e6:	00001097          	auipc	ra,0x1
    800030ea:	46e080e7          	jalr	1134(ra) # 80004554 <acquiresleep>
      return b;
    800030ee:	a8b9                	j	8000314c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030f0:	0001c497          	auipc	s1,0x1c
    800030f4:	b684b483          	ld	s1,-1176(s1) # 8001ec58 <bcache+0x82b0>
    800030f8:	0001c797          	auipc	a5,0x1c
    800030fc:	b1878793          	addi	a5,a5,-1256 # 8001ec10 <bcache+0x8268>
    80003100:	00f48863          	beq	s1,a5,80003110 <bread+0x90>
    80003104:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003106:	40bc                	lw	a5,64(s1)
    80003108:	cf81                	beqz	a5,80003120 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000310a:	64a4                	ld	s1,72(s1)
    8000310c:	fee49de3          	bne	s1,a4,80003106 <bread+0x86>
  panic("bget: no buffers");
    80003110:	00005517          	auipc	a0,0x5
    80003114:	41050513          	addi	a0,a0,1040 # 80008520 <syscalls+0xd0>
    80003118:	ffffd097          	auipc	ra,0xffffd
    8000311c:	42c080e7          	jalr	1068(ra) # 80000544 <panic>
      b->dev = dev;
    80003120:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003124:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003128:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000312c:	4785                	li	a5,1
    8000312e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003130:	00014517          	auipc	a0,0x14
    80003134:	87850513          	addi	a0,a0,-1928 # 800169a8 <bcache>
    80003138:	ffffe097          	auipc	ra,0xffffe
    8000313c:	b66080e7          	jalr	-1178(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003140:	01048513          	addi	a0,s1,16
    80003144:	00001097          	auipc	ra,0x1
    80003148:	410080e7          	jalr	1040(ra) # 80004554 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000314c:	409c                	lw	a5,0(s1)
    8000314e:	cb89                	beqz	a5,80003160 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003150:	8526                	mv	a0,s1
    80003152:	70a2                	ld	ra,40(sp)
    80003154:	7402                	ld	s0,32(sp)
    80003156:	64e2                	ld	s1,24(sp)
    80003158:	6942                	ld	s2,16(sp)
    8000315a:	69a2                	ld	s3,8(sp)
    8000315c:	6145                	addi	sp,sp,48
    8000315e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003160:	4581                	li	a1,0
    80003162:	8526                	mv	a0,s1
    80003164:	00003097          	auipc	ra,0x3
    80003168:	fc4080e7          	jalr	-60(ra) # 80006128 <virtio_disk_rw>
    b->valid = 1;
    8000316c:	4785                	li	a5,1
    8000316e:	c09c                	sw	a5,0(s1)
  return b;
    80003170:	b7c5                	j	80003150 <bread+0xd0>

0000000080003172 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	e426                	sd	s1,8(sp)
    8000317a:	1000                	addi	s0,sp,32
    8000317c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000317e:	0541                	addi	a0,a0,16
    80003180:	00001097          	auipc	ra,0x1
    80003184:	46e080e7          	jalr	1134(ra) # 800045ee <holdingsleep>
    80003188:	cd01                	beqz	a0,800031a0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000318a:	4585                	li	a1,1
    8000318c:	8526                	mv	a0,s1
    8000318e:	00003097          	auipc	ra,0x3
    80003192:	f9a080e7          	jalr	-102(ra) # 80006128 <virtio_disk_rw>
}
    80003196:	60e2                	ld	ra,24(sp)
    80003198:	6442                	ld	s0,16(sp)
    8000319a:	64a2                	ld	s1,8(sp)
    8000319c:	6105                	addi	sp,sp,32
    8000319e:	8082                	ret
    panic("bwrite");
    800031a0:	00005517          	auipc	a0,0x5
    800031a4:	39850513          	addi	a0,a0,920 # 80008538 <syscalls+0xe8>
    800031a8:	ffffd097          	auipc	ra,0xffffd
    800031ac:	39c080e7          	jalr	924(ra) # 80000544 <panic>

00000000800031b0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031b0:	1101                	addi	sp,sp,-32
    800031b2:	ec06                	sd	ra,24(sp)
    800031b4:	e822                	sd	s0,16(sp)
    800031b6:	e426                	sd	s1,8(sp)
    800031b8:	e04a                	sd	s2,0(sp)
    800031ba:	1000                	addi	s0,sp,32
    800031bc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031be:	01050913          	addi	s2,a0,16
    800031c2:	854a                	mv	a0,s2
    800031c4:	00001097          	auipc	ra,0x1
    800031c8:	42a080e7          	jalr	1066(ra) # 800045ee <holdingsleep>
    800031cc:	c92d                	beqz	a0,8000323e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800031ce:	854a                	mv	a0,s2
    800031d0:	00001097          	auipc	ra,0x1
    800031d4:	3da080e7          	jalr	986(ra) # 800045aa <releasesleep>

  acquire(&bcache.lock);
    800031d8:	00013517          	auipc	a0,0x13
    800031dc:	7d050513          	addi	a0,a0,2000 # 800169a8 <bcache>
    800031e0:	ffffe097          	auipc	ra,0xffffe
    800031e4:	a0a080e7          	jalr	-1526(ra) # 80000bea <acquire>
  b->refcnt--;
    800031e8:	40bc                	lw	a5,64(s1)
    800031ea:	37fd                	addiw	a5,a5,-1
    800031ec:	0007871b          	sext.w	a4,a5
    800031f0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031f2:	eb05                	bnez	a4,80003222 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031f4:	68bc                	ld	a5,80(s1)
    800031f6:	64b8                	ld	a4,72(s1)
    800031f8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031fa:	64bc                	ld	a5,72(s1)
    800031fc:	68b8                	ld	a4,80(s1)
    800031fe:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003200:	0001b797          	auipc	a5,0x1b
    80003204:	7a878793          	addi	a5,a5,1960 # 8001e9a8 <bcache+0x8000>
    80003208:	2b87b703          	ld	a4,696(a5)
    8000320c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000320e:	0001c717          	auipc	a4,0x1c
    80003212:	a0270713          	addi	a4,a4,-1534 # 8001ec10 <bcache+0x8268>
    80003216:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003218:	2b87b703          	ld	a4,696(a5)
    8000321c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000321e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003222:	00013517          	auipc	a0,0x13
    80003226:	78650513          	addi	a0,a0,1926 # 800169a8 <bcache>
    8000322a:	ffffe097          	auipc	ra,0xffffe
    8000322e:	a74080e7          	jalr	-1420(ra) # 80000c9e <release>
}
    80003232:	60e2                	ld	ra,24(sp)
    80003234:	6442                	ld	s0,16(sp)
    80003236:	64a2                	ld	s1,8(sp)
    80003238:	6902                	ld	s2,0(sp)
    8000323a:	6105                	addi	sp,sp,32
    8000323c:	8082                	ret
    panic("brelse");
    8000323e:	00005517          	auipc	a0,0x5
    80003242:	30250513          	addi	a0,a0,770 # 80008540 <syscalls+0xf0>
    80003246:	ffffd097          	auipc	ra,0xffffd
    8000324a:	2fe080e7          	jalr	766(ra) # 80000544 <panic>

000000008000324e <bpin>:

void
bpin(struct buf *b) {
    8000324e:	1101                	addi	sp,sp,-32
    80003250:	ec06                	sd	ra,24(sp)
    80003252:	e822                	sd	s0,16(sp)
    80003254:	e426                	sd	s1,8(sp)
    80003256:	1000                	addi	s0,sp,32
    80003258:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000325a:	00013517          	auipc	a0,0x13
    8000325e:	74e50513          	addi	a0,a0,1870 # 800169a8 <bcache>
    80003262:	ffffe097          	auipc	ra,0xffffe
    80003266:	988080e7          	jalr	-1656(ra) # 80000bea <acquire>
  b->refcnt++;
    8000326a:	40bc                	lw	a5,64(s1)
    8000326c:	2785                	addiw	a5,a5,1
    8000326e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003270:	00013517          	auipc	a0,0x13
    80003274:	73850513          	addi	a0,a0,1848 # 800169a8 <bcache>
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	a26080e7          	jalr	-1498(ra) # 80000c9e <release>
}
    80003280:	60e2                	ld	ra,24(sp)
    80003282:	6442                	ld	s0,16(sp)
    80003284:	64a2                	ld	s1,8(sp)
    80003286:	6105                	addi	sp,sp,32
    80003288:	8082                	ret

000000008000328a <bunpin>:

void
bunpin(struct buf *b) {
    8000328a:	1101                	addi	sp,sp,-32
    8000328c:	ec06                	sd	ra,24(sp)
    8000328e:	e822                	sd	s0,16(sp)
    80003290:	e426                	sd	s1,8(sp)
    80003292:	1000                	addi	s0,sp,32
    80003294:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003296:	00013517          	auipc	a0,0x13
    8000329a:	71250513          	addi	a0,a0,1810 # 800169a8 <bcache>
    8000329e:	ffffe097          	auipc	ra,0xffffe
    800032a2:	94c080e7          	jalr	-1716(ra) # 80000bea <acquire>
  b->refcnt--;
    800032a6:	40bc                	lw	a5,64(s1)
    800032a8:	37fd                	addiw	a5,a5,-1
    800032aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032ac:	00013517          	auipc	a0,0x13
    800032b0:	6fc50513          	addi	a0,a0,1788 # 800169a8 <bcache>
    800032b4:	ffffe097          	auipc	ra,0xffffe
    800032b8:	9ea080e7          	jalr	-1558(ra) # 80000c9e <release>
}
    800032bc:	60e2                	ld	ra,24(sp)
    800032be:	6442                	ld	s0,16(sp)
    800032c0:	64a2                	ld	s1,8(sp)
    800032c2:	6105                	addi	sp,sp,32
    800032c4:	8082                	ret

00000000800032c6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032c6:	1101                	addi	sp,sp,-32
    800032c8:	ec06                	sd	ra,24(sp)
    800032ca:	e822                	sd	s0,16(sp)
    800032cc:	e426                	sd	s1,8(sp)
    800032ce:	e04a                	sd	s2,0(sp)
    800032d0:	1000                	addi	s0,sp,32
    800032d2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032d4:	00d5d59b          	srliw	a1,a1,0xd
    800032d8:	0001c797          	auipc	a5,0x1c
    800032dc:	dac7a783          	lw	a5,-596(a5) # 8001f084 <sb+0x1c>
    800032e0:	9dbd                	addw	a1,a1,a5
    800032e2:	00000097          	auipc	ra,0x0
    800032e6:	d9e080e7          	jalr	-610(ra) # 80003080 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032ea:	0074f713          	andi	a4,s1,7
    800032ee:	4785                	li	a5,1
    800032f0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032f4:	14ce                	slli	s1,s1,0x33
    800032f6:	90d9                	srli	s1,s1,0x36
    800032f8:	00950733          	add	a4,a0,s1
    800032fc:	05874703          	lbu	a4,88(a4)
    80003300:	00e7f6b3          	and	a3,a5,a4
    80003304:	c69d                	beqz	a3,80003332 <bfree+0x6c>
    80003306:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003308:	94aa                	add	s1,s1,a0
    8000330a:	fff7c793          	not	a5,a5
    8000330e:	8ff9                	and	a5,a5,a4
    80003310:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003314:	00001097          	auipc	ra,0x1
    80003318:	120080e7          	jalr	288(ra) # 80004434 <log_write>
  brelse(bp);
    8000331c:	854a                	mv	a0,s2
    8000331e:	00000097          	auipc	ra,0x0
    80003322:	e92080e7          	jalr	-366(ra) # 800031b0 <brelse>
}
    80003326:	60e2                	ld	ra,24(sp)
    80003328:	6442                	ld	s0,16(sp)
    8000332a:	64a2                	ld	s1,8(sp)
    8000332c:	6902                	ld	s2,0(sp)
    8000332e:	6105                	addi	sp,sp,32
    80003330:	8082                	ret
    panic("freeing free block");
    80003332:	00005517          	auipc	a0,0x5
    80003336:	21650513          	addi	a0,a0,534 # 80008548 <syscalls+0xf8>
    8000333a:	ffffd097          	auipc	ra,0xffffd
    8000333e:	20a080e7          	jalr	522(ra) # 80000544 <panic>

0000000080003342 <balloc>:
{
    80003342:	711d                	addi	sp,sp,-96
    80003344:	ec86                	sd	ra,88(sp)
    80003346:	e8a2                	sd	s0,80(sp)
    80003348:	e4a6                	sd	s1,72(sp)
    8000334a:	e0ca                	sd	s2,64(sp)
    8000334c:	fc4e                	sd	s3,56(sp)
    8000334e:	f852                	sd	s4,48(sp)
    80003350:	f456                	sd	s5,40(sp)
    80003352:	f05a                	sd	s6,32(sp)
    80003354:	ec5e                	sd	s7,24(sp)
    80003356:	e862                	sd	s8,16(sp)
    80003358:	e466                	sd	s9,8(sp)
    8000335a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000335c:	0001c797          	auipc	a5,0x1c
    80003360:	d107a783          	lw	a5,-752(a5) # 8001f06c <sb+0x4>
    80003364:	10078163          	beqz	a5,80003466 <balloc+0x124>
    80003368:	8baa                	mv	s7,a0
    8000336a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000336c:	0001cb17          	auipc	s6,0x1c
    80003370:	cfcb0b13          	addi	s6,s6,-772 # 8001f068 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003374:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003376:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003378:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000337a:	6c89                	lui	s9,0x2
    8000337c:	a061                	j	80003404 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000337e:	974a                	add	a4,a4,s2
    80003380:	8fd5                	or	a5,a5,a3
    80003382:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003386:	854a                	mv	a0,s2
    80003388:	00001097          	auipc	ra,0x1
    8000338c:	0ac080e7          	jalr	172(ra) # 80004434 <log_write>
        brelse(bp);
    80003390:	854a                	mv	a0,s2
    80003392:	00000097          	auipc	ra,0x0
    80003396:	e1e080e7          	jalr	-482(ra) # 800031b0 <brelse>
  bp = bread(dev, bno);
    8000339a:	85a6                	mv	a1,s1
    8000339c:	855e                	mv	a0,s7
    8000339e:	00000097          	auipc	ra,0x0
    800033a2:	ce2080e7          	jalr	-798(ra) # 80003080 <bread>
    800033a6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033a8:	40000613          	li	a2,1024
    800033ac:	4581                	li	a1,0
    800033ae:	05850513          	addi	a0,a0,88
    800033b2:	ffffe097          	auipc	ra,0xffffe
    800033b6:	934080e7          	jalr	-1740(ra) # 80000ce6 <memset>
  log_write(bp);
    800033ba:	854a                	mv	a0,s2
    800033bc:	00001097          	auipc	ra,0x1
    800033c0:	078080e7          	jalr	120(ra) # 80004434 <log_write>
  brelse(bp);
    800033c4:	854a                	mv	a0,s2
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	dea080e7          	jalr	-534(ra) # 800031b0 <brelse>
}
    800033ce:	8526                	mv	a0,s1
    800033d0:	60e6                	ld	ra,88(sp)
    800033d2:	6446                	ld	s0,80(sp)
    800033d4:	64a6                	ld	s1,72(sp)
    800033d6:	6906                	ld	s2,64(sp)
    800033d8:	79e2                	ld	s3,56(sp)
    800033da:	7a42                	ld	s4,48(sp)
    800033dc:	7aa2                	ld	s5,40(sp)
    800033de:	7b02                	ld	s6,32(sp)
    800033e0:	6be2                	ld	s7,24(sp)
    800033e2:	6c42                	ld	s8,16(sp)
    800033e4:	6ca2                	ld	s9,8(sp)
    800033e6:	6125                	addi	sp,sp,96
    800033e8:	8082                	ret
    brelse(bp);
    800033ea:	854a                	mv	a0,s2
    800033ec:	00000097          	auipc	ra,0x0
    800033f0:	dc4080e7          	jalr	-572(ra) # 800031b0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033f4:	015c87bb          	addw	a5,s9,s5
    800033f8:	00078a9b          	sext.w	s5,a5
    800033fc:	004b2703          	lw	a4,4(s6)
    80003400:	06eaf363          	bgeu	s5,a4,80003466 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003404:	41fad79b          	sraiw	a5,s5,0x1f
    80003408:	0137d79b          	srliw	a5,a5,0x13
    8000340c:	015787bb          	addw	a5,a5,s5
    80003410:	40d7d79b          	sraiw	a5,a5,0xd
    80003414:	01cb2583          	lw	a1,28(s6)
    80003418:	9dbd                	addw	a1,a1,a5
    8000341a:	855e                	mv	a0,s7
    8000341c:	00000097          	auipc	ra,0x0
    80003420:	c64080e7          	jalr	-924(ra) # 80003080 <bread>
    80003424:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003426:	004b2503          	lw	a0,4(s6)
    8000342a:	000a849b          	sext.w	s1,s5
    8000342e:	8662                	mv	a2,s8
    80003430:	faa4fde3          	bgeu	s1,a0,800033ea <balloc+0xa8>
      m = 1 << (bi % 8);
    80003434:	41f6579b          	sraiw	a5,a2,0x1f
    80003438:	01d7d69b          	srliw	a3,a5,0x1d
    8000343c:	00c6873b          	addw	a4,a3,a2
    80003440:	00777793          	andi	a5,a4,7
    80003444:	9f95                	subw	a5,a5,a3
    80003446:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000344a:	4037571b          	sraiw	a4,a4,0x3
    8000344e:	00e906b3          	add	a3,s2,a4
    80003452:	0586c683          	lbu	a3,88(a3)
    80003456:	00d7f5b3          	and	a1,a5,a3
    8000345a:	d195                	beqz	a1,8000337e <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000345c:	2605                	addiw	a2,a2,1
    8000345e:	2485                	addiw	s1,s1,1
    80003460:	fd4618e3          	bne	a2,s4,80003430 <balloc+0xee>
    80003464:	b759                	j	800033ea <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003466:	00005517          	auipc	a0,0x5
    8000346a:	0fa50513          	addi	a0,a0,250 # 80008560 <syscalls+0x110>
    8000346e:	ffffd097          	auipc	ra,0xffffd
    80003472:	120080e7          	jalr	288(ra) # 8000058e <printf>
  return 0;
    80003476:	4481                	li	s1,0
    80003478:	bf99                	j	800033ce <balloc+0x8c>

000000008000347a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000347a:	7179                	addi	sp,sp,-48
    8000347c:	f406                	sd	ra,40(sp)
    8000347e:	f022                	sd	s0,32(sp)
    80003480:	ec26                	sd	s1,24(sp)
    80003482:	e84a                	sd	s2,16(sp)
    80003484:	e44e                	sd	s3,8(sp)
    80003486:	e052                	sd	s4,0(sp)
    80003488:	1800                	addi	s0,sp,48
    8000348a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000348c:	47ad                	li	a5,11
    8000348e:	02b7e763          	bltu	a5,a1,800034bc <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003492:	02059493          	slli	s1,a1,0x20
    80003496:	9081                	srli	s1,s1,0x20
    80003498:	048a                	slli	s1,s1,0x2
    8000349a:	94aa                	add	s1,s1,a0
    8000349c:	0504a903          	lw	s2,80(s1)
    800034a0:	06091e63          	bnez	s2,8000351c <bmap+0xa2>
      addr = balloc(ip->dev);
    800034a4:	4108                	lw	a0,0(a0)
    800034a6:	00000097          	auipc	ra,0x0
    800034aa:	e9c080e7          	jalr	-356(ra) # 80003342 <balloc>
    800034ae:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034b2:	06090563          	beqz	s2,8000351c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800034b6:	0524a823          	sw	s2,80(s1)
    800034ba:	a08d                	j	8000351c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034bc:	ff45849b          	addiw	s1,a1,-12
    800034c0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034c4:	0ff00793          	li	a5,255
    800034c8:	08e7e563          	bltu	a5,a4,80003552 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034cc:	08052903          	lw	s2,128(a0)
    800034d0:	00091d63          	bnez	s2,800034ea <bmap+0x70>
      addr = balloc(ip->dev);
    800034d4:	4108                	lw	a0,0(a0)
    800034d6:	00000097          	auipc	ra,0x0
    800034da:	e6c080e7          	jalr	-404(ra) # 80003342 <balloc>
    800034de:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034e2:	02090d63          	beqz	s2,8000351c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034e6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800034ea:	85ca                	mv	a1,s2
    800034ec:	0009a503          	lw	a0,0(s3)
    800034f0:	00000097          	auipc	ra,0x0
    800034f4:	b90080e7          	jalr	-1136(ra) # 80003080 <bread>
    800034f8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034fa:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034fe:	02049593          	slli	a1,s1,0x20
    80003502:	9181                	srli	a1,a1,0x20
    80003504:	058a                	slli	a1,a1,0x2
    80003506:	00b784b3          	add	s1,a5,a1
    8000350a:	0004a903          	lw	s2,0(s1)
    8000350e:	02090063          	beqz	s2,8000352e <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003512:	8552                	mv	a0,s4
    80003514:	00000097          	auipc	ra,0x0
    80003518:	c9c080e7          	jalr	-868(ra) # 800031b0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000351c:	854a                	mv	a0,s2
    8000351e:	70a2                	ld	ra,40(sp)
    80003520:	7402                	ld	s0,32(sp)
    80003522:	64e2                	ld	s1,24(sp)
    80003524:	6942                	ld	s2,16(sp)
    80003526:	69a2                	ld	s3,8(sp)
    80003528:	6a02                	ld	s4,0(sp)
    8000352a:	6145                	addi	sp,sp,48
    8000352c:	8082                	ret
      addr = balloc(ip->dev);
    8000352e:	0009a503          	lw	a0,0(s3)
    80003532:	00000097          	auipc	ra,0x0
    80003536:	e10080e7          	jalr	-496(ra) # 80003342 <balloc>
    8000353a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000353e:	fc090ae3          	beqz	s2,80003512 <bmap+0x98>
        a[bn] = addr;
    80003542:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003546:	8552                	mv	a0,s4
    80003548:	00001097          	auipc	ra,0x1
    8000354c:	eec080e7          	jalr	-276(ra) # 80004434 <log_write>
    80003550:	b7c9                	j	80003512 <bmap+0x98>
  panic("bmap: out of range");
    80003552:	00005517          	auipc	a0,0x5
    80003556:	02650513          	addi	a0,a0,38 # 80008578 <syscalls+0x128>
    8000355a:	ffffd097          	auipc	ra,0xffffd
    8000355e:	fea080e7          	jalr	-22(ra) # 80000544 <panic>

0000000080003562 <iget>:
{
    80003562:	7179                	addi	sp,sp,-48
    80003564:	f406                	sd	ra,40(sp)
    80003566:	f022                	sd	s0,32(sp)
    80003568:	ec26                	sd	s1,24(sp)
    8000356a:	e84a                	sd	s2,16(sp)
    8000356c:	e44e                	sd	s3,8(sp)
    8000356e:	e052                	sd	s4,0(sp)
    80003570:	1800                	addi	s0,sp,48
    80003572:	89aa                	mv	s3,a0
    80003574:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003576:	0001c517          	auipc	a0,0x1c
    8000357a:	b1250513          	addi	a0,a0,-1262 # 8001f088 <itable>
    8000357e:	ffffd097          	auipc	ra,0xffffd
    80003582:	66c080e7          	jalr	1644(ra) # 80000bea <acquire>
  empty = 0;
    80003586:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003588:	0001c497          	auipc	s1,0x1c
    8000358c:	b1848493          	addi	s1,s1,-1256 # 8001f0a0 <itable+0x18>
    80003590:	0001d697          	auipc	a3,0x1d
    80003594:	5a068693          	addi	a3,a3,1440 # 80020b30 <log>
    80003598:	a039                	j	800035a6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000359a:	02090b63          	beqz	s2,800035d0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000359e:	08848493          	addi	s1,s1,136
    800035a2:	02d48a63          	beq	s1,a3,800035d6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035a6:	449c                	lw	a5,8(s1)
    800035a8:	fef059e3          	blez	a5,8000359a <iget+0x38>
    800035ac:	4098                	lw	a4,0(s1)
    800035ae:	ff3716e3          	bne	a4,s3,8000359a <iget+0x38>
    800035b2:	40d8                	lw	a4,4(s1)
    800035b4:	ff4713e3          	bne	a4,s4,8000359a <iget+0x38>
      ip->ref++;
    800035b8:	2785                	addiw	a5,a5,1
    800035ba:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035bc:	0001c517          	auipc	a0,0x1c
    800035c0:	acc50513          	addi	a0,a0,-1332 # 8001f088 <itable>
    800035c4:	ffffd097          	auipc	ra,0xffffd
    800035c8:	6da080e7          	jalr	1754(ra) # 80000c9e <release>
      return ip;
    800035cc:	8926                	mv	s2,s1
    800035ce:	a03d                	j	800035fc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035d0:	f7f9                	bnez	a5,8000359e <iget+0x3c>
    800035d2:	8926                	mv	s2,s1
    800035d4:	b7e9                	j	8000359e <iget+0x3c>
  if(empty == 0)
    800035d6:	02090c63          	beqz	s2,8000360e <iget+0xac>
  ip->dev = dev;
    800035da:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035de:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035e2:	4785                	li	a5,1
    800035e4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035e8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035ec:	0001c517          	auipc	a0,0x1c
    800035f0:	a9c50513          	addi	a0,a0,-1380 # 8001f088 <itable>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	6aa080e7          	jalr	1706(ra) # 80000c9e <release>
}
    800035fc:	854a                	mv	a0,s2
    800035fe:	70a2                	ld	ra,40(sp)
    80003600:	7402                	ld	s0,32(sp)
    80003602:	64e2                	ld	s1,24(sp)
    80003604:	6942                	ld	s2,16(sp)
    80003606:	69a2                	ld	s3,8(sp)
    80003608:	6a02                	ld	s4,0(sp)
    8000360a:	6145                	addi	sp,sp,48
    8000360c:	8082                	ret
    panic("iget: no inodes");
    8000360e:	00005517          	auipc	a0,0x5
    80003612:	f8250513          	addi	a0,a0,-126 # 80008590 <syscalls+0x140>
    80003616:	ffffd097          	auipc	ra,0xffffd
    8000361a:	f2e080e7          	jalr	-210(ra) # 80000544 <panic>

000000008000361e <fsinit>:
fsinit(int dev) {
    8000361e:	7179                	addi	sp,sp,-48
    80003620:	f406                	sd	ra,40(sp)
    80003622:	f022                	sd	s0,32(sp)
    80003624:	ec26                	sd	s1,24(sp)
    80003626:	e84a                	sd	s2,16(sp)
    80003628:	e44e                	sd	s3,8(sp)
    8000362a:	1800                	addi	s0,sp,48
    8000362c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000362e:	4585                	li	a1,1
    80003630:	00000097          	auipc	ra,0x0
    80003634:	a50080e7          	jalr	-1456(ra) # 80003080 <bread>
    80003638:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000363a:	0001c997          	auipc	s3,0x1c
    8000363e:	a2e98993          	addi	s3,s3,-1490 # 8001f068 <sb>
    80003642:	02000613          	li	a2,32
    80003646:	05850593          	addi	a1,a0,88
    8000364a:	854e                	mv	a0,s3
    8000364c:	ffffd097          	auipc	ra,0xffffd
    80003650:	6fa080e7          	jalr	1786(ra) # 80000d46 <memmove>
  brelse(bp);
    80003654:	8526                	mv	a0,s1
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	b5a080e7          	jalr	-1190(ra) # 800031b0 <brelse>
  if(sb.magic != FSMAGIC)
    8000365e:	0009a703          	lw	a4,0(s3)
    80003662:	102037b7          	lui	a5,0x10203
    80003666:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000366a:	02f71263          	bne	a4,a5,8000368e <fsinit+0x70>
  initlog(dev, &sb);
    8000366e:	0001c597          	auipc	a1,0x1c
    80003672:	9fa58593          	addi	a1,a1,-1542 # 8001f068 <sb>
    80003676:	854a                	mv	a0,s2
    80003678:	00001097          	auipc	ra,0x1
    8000367c:	b40080e7          	jalr	-1216(ra) # 800041b8 <initlog>
}
    80003680:	70a2                	ld	ra,40(sp)
    80003682:	7402                	ld	s0,32(sp)
    80003684:	64e2                	ld	s1,24(sp)
    80003686:	6942                	ld	s2,16(sp)
    80003688:	69a2                	ld	s3,8(sp)
    8000368a:	6145                	addi	sp,sp,48
    8000368c:	8082                	ret
    panic("invalid file system");
    8000368e:	00005517          	auipc	a0,0x5
    80003692:	f1250513          	addi	a0,a0,-238 # 800085a0 <syscalls+0x150>
    80003696:	ffffd097          	auipc	ra,0xffffd
    8000369a:	eae080e7          	jalr	-338(ra) # 80000544 <panic>

000000008000369e <iinit>:
{
    8000369e:	7179                	addi	sp,sp,-48
    800036a0:	f406                	sd	ra,40(sp)
    800036a2:	f022                	sd	s0,32(sp)
    800036a4:	ec26                	sd	s1,24(sp)
    800036a6:	e84a                	sd	s2,16(sp)
    800036a8:	e44e                	sd	s3,8(sp)
    800036aa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036ac:	00005597          	auipc	a1,0x5
    800036b0:	f0c58593          	addi	a1,a1,-244 # 800085b8 <syscalls+0x168>
    800036b4:	0001c517          	auipc	a0,0x1c
    800036b8:	9d450513          	addi	a0,a0,-1580 # 8001f088 <itable>
    800036bc:	ffffd097          	auipc	ra,0xffffd
    800036c0:	49e080e7          	jalr	1182(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    800036c4:	0001c497          	auipc	s1,0x1c
    800036c8:	9ec48493          	addi	s1,s1,-1556 # 8001f0b0 <itable+0x28>
    800036cc:	0001d997          	auipc	s3,0x1d
    800036d0:	47498993          	addi	s3,s3,1140 # 80020b40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036d4:	00005917          	auipc	s2,0x5
    800036d8:	eec90913          	addi	s2,s2,-276 # 800085c0 <syscalls+0x170>
    800036dc:	85ca                	mv	a1,s2
    800036de:	8526                	mv	a0,s1
    800036e0:	00001097          	auipc	ra,0x1
    800036e4:	e3a080e7          	jalr	-454(ra) # 8000451a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036e8:	08848493          	addi	s1,s1,136
    800036ec:	ff3498e3          	bne	s1,s3,800036dc <iinit+0x3e>
}
    800036f0:	70a2                	ld	ra,40(sp)
    800036f2:	7402                	ld	s0,32(sp)
    800036f4:	64e2                	ld	s1,24(sp)
    800036f6:	6942                	ld	s2,16(sp)
    800036f8:	69a2                	ld	s3,8(sp)
    800036fa:	6145                	addi	sp,sp,48
    800036fc:	8082                	ret

00000000800036fe <ialloc>:
{
    800036fe:	715d                	addi	sp,sp,-80
    80003700:	e486                	sd	ra,72(sp)
    80003702:	e0a2                	sd	s0,64(sp)
    80003704:	fc26                	sd	s1,56(sp)
    80003706:	f84a                	sd	s2,48(sp)
    80003708:	f44e                	sd	s3,40(sp)
    8000370a:	f052                	sd	s4,32(sp)
    8000370c:	ec56                	sd	s5,24(sp)
    8000370e:	e85a                	sd	s6,16(sp)
    80003710:	e45e                	sd	s7,8(sp)
    80003712:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003714:	0001c717          	auipc	a4,0x1c
    80003718:	96072703          	lw	a4,-1696(a4) # 8001f074 <sb+0xc>
    8000371c:	4785                	li	a5,1
    8000371e:	04e7fa63          	bgeu	a5,a4,80003772 <ialloc+0x74>
    80003722:	8aaa                	mv	s5,a0
    80003724:	8bae                	mv	s7,a1
    80003726:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003728:	0001ca17          	auipc	s4,0x1c
    8000372c:	940a0a13          	addi	s4,s4,-1728 # 8001f068 <sb>
    80003730:	00048b1b          	sext.w	s6,s1
    80003734:	0044d593          	srli	a1,s1,0x4
    80003738:	018a2783          	lw	a5,24(s4)
    8000373c:	9dbd                	addw	a1,a1,a5
    8000373e:	8556                	mv	a0,s5
    80003740:	00000097          	auipc	ra,0x0
    80003744:	940080e7          	jalr	-1728(ra) # 80003080 <bread>
    80003748:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000374a:	05850993          	addi	s3,a0,88
    8000374e:	00f4f793          	andi	a5,s1,15
    80003752:	079a                	slli	a5,a5,0x6
    80003754:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003756:	00099783          	lh	a5,0(s3)
    8000375a:	c3a1                	beqz	a5,8000379a <ialloc+0x9c>
    brelse(bp);
    8000375c:	00000097          	auipc	ra,0x0
    80003760:	a54080e7          	jalr	-1452(ra) # 800031b0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003764:	0485                	addi	s1,s1,1
    80003766:	00ca2703          	lw	a4,12(s4)
    8000376a:	0004879b          	sext.w	a5,s1
    8000376e:	fce7e1e3          	bltu	a5,a4,80003730 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003772:	00005517          	auipc	a0,0x5
    80003776:	e5650513          	addi	a0,a0,-426 # 800085c8 <syscalls+0x178>
    8000377a:	ffffd097          	auipc	ra,0xffffd
    8000377e:	e14080e7          	jalr	-492(ra) # 8000058e <printf>
  return 0;
    80003782:	4501                	li	a0,0
}
    80003784:	60a6                	ld	ra,72(sp)
    80003786:	6406                	ld	s0,64(sp)
    80003788:	74e2                	ld	s1,56(sp)
    8000378a:	7942                	ld	s2,48(sp)
    8000378c:	79a2                	ld	s3,40(sp)
    8000378e:	7a02                	ld	s4,32(sp)
    80003790:	6ae2                	ld	s5,24(sp)
    80003792:	6b42                	ld	s6,16(sp)
    80003794:	6ba2                	ld	s7,8(sp)
    80003796:	6161                	addi	sp,sp,80
    80003798:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000379a:	04000613          	li	a2,64
    8000379e:	4581                	li	a1,0
    800037a0:	854e                	mv	a0,s3
    800037a2:	ffffd097          	auipc	ra,0xffffd
    800037a6:	544080e7          	jalr	1348(ra) # 80000ce6 <memset>
      dip->type = type;
    800037aa:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037ae:	854a                	mv	a0,s2
    800037b0:	00001097          	auipc	ra,0x1
    800037b4:	c84080e7          	jalr	-892(ra) # 80004434 <log_write>
      brelse(bp);
    800037b8:	854a                	mv	a0,s2
    800037ba:	00000097          	auipc	ra,0x0
    800037be:	9f6080e7          	jalr	-1546(ra) # 800031b0 <brelse>
      return iget(dev, inum);
    800037c2:	85da                	mv	a1,s6
    800037c4:	8556                	mv	a0,s5
    800037c6:	00000097          	auipc	ra,0x0
    800037ca:	d9c080e7          	jalr	-612(ra) # 80003562 <iget>
    800037ce:	bf5d                	j	80003784 <ialloc+0x86>

00000000800037d0 <iupdate>:
{
    800037d0:	1101                	addi	sp,sp,-32
    800037d2:	ec06                	sd	ra,24(sp)
    800037d4:	e822                	sd	s0,16(sp)
    800037d6:	e426                	sd	s1,8(sp)
    800037d8:	e04a                	sd	s2,0(sp)
    800037da:	1000                	addi	s0,sp,32
    800037dc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037de:	415c                	lw	a5,4(a0)
    800037e0:	0047d79b          	srliw	a5,a5,0x4
    800037e4:	0001c597          	auipc	a1,0x1c
    800037e8:	89c5a583          	lw	a1,-1892(a1) # 8001f080 <sb+0x18>
    800037ec:	9dbd                	addw	a1,a1,a5
    800037ee:	4108                	lw	a0,0(a0)
    800037f0:	00000097          	auipc	ra,0x0
    800037f4:	890080e7          	jalr	-1904(ra) # 80003080 <bread>
    800037f8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037fa:	05850793          	addi	a5,a0,88
    800037fe:	40c8                	lw	a0,4(s1)
    80003800:	893d                	andi	a0,a0,15
    80003802:	051a                	slli	a0,a0,0x6
    80003804:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003806:	04449703          	lh	a4,68(s1)
    8000380a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000380e:	04649703          	lh	a4,70(s1)
    80003812:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003816:	04849703          	lh	a4,72(s1)
    8000381a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000381e:	04a49703          	lh	a4,74(s1)
    80003822:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003826:	44f8                	lw	a4,76(s1)
    80003828:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000382a:	03400613          	li	a2,52
    8000382e:	05048593          	addi	a1,s1,80
    80003832:	0531                	addi	a0,a0,12
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	512080e7          	jalr	1298(ra) # 80000d46 <memmove>
  log_write(bp);
    8000383c:	854a                	mv	a0,s2
    8000383e:	00001097          	auipc	ra,0x1
    80003842:	bf6080e7          	jalr	-1034(ra) # 80004434 <log_write>
  brelse(bp);
    80003846:	854a                	mv	a0,s2
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	968080e7          	jalr	-1688(ra) # 800031b0 <brelse>
}
    80003850:	60e2                	ld	ra,24(sp)
    80003852:	6442                	ld	s0,16(sp)
    80003854:	64a2                	ld	s1,8(sp)
    80003856:	6902                	ld	s2,0(sp)
    80003858:	6105                	addi	sp,sp,32
    8000385a:	8082                	ret

000000008000385c <idup>:
{
    8000385c:	1101                	addi	sp,sp,-32
    8000385e:	ec06                	sd	ra,24(sp)
    80003860:	e822                	sd	s0,16(sp)
    80003862:	e426                	sd	s1,8(sp)
    80003864:	1000                	addi	s0,sp,32
    80003866:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003868:	0001c517          	auipc	a0,0x1c
    8000386c:	82050513          	addi	a0,a0,-2016 # 8001f088 <itable>
    80003870:	ffffd097          	auipc	ra,0xffffd
    80003874:	37a080e7          	jalr	890(ra) # 80000bea <acquire>
  ip->ref++;
    80003878:	449c                	lw	a5,8(s1)
    8000387a:	2785                	addiw	a5,a5,1
    8000387c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000387e:	0001c517          	auipc	a0,0x1c
    80003882:	80a50513          	addi	a0,a0,-2038 # 8001f088 <itable>
    80003886:	ffffd097          	auipc	ra,0xffffd
    8000388a:	418080e7          	jalr	1048(ra) # 80000c9e <release>
}
    8000388e:	8526                	mv	a0,s1
    80003890:	60e2                	ld	ra,24(sp)
    80003892:	6442                	ld	s0,16(sp)
    80003894:	64a2                	ld	s1,8(sp)
    80003896:	6105                	addi	sp,sp,32
    80003898:	8082                	ret

000000008000389a <ilock>:
{
    8000389a:	1101                	addi	sp,sp,-32
    8000389c:	ec06                	sd	ra,24(sp)
    8000389e:	e822                	sd	s0,16(sp)
    800038a0:	e426                	sd	s1,8(sp)
    800038a2:	e04a                	sd	s2,0(sp)
    800038a4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038a6:	c115                	beqz	a0,800038ca <ilock+0x30>
    800038a8:	84aa                	mv	s1,a0
    800038aa:	451c                	lw	a5,8(a0)
    800038ac:	00f05f63          	blez	a5,800038ca <ilock+0x30>
  acquiresleep(&ip->lock);
    800038b0:	0541                	addi	a0,a0,16
    800038b2:	00001097          	auipc	ra,0x1
    800038b6:	ca2080e7          	jalr	-862(ra) # 80004554 <acquiresleep>
  if(ip->valid == 0){
    800038ba:	40bc                	lw	a5,64(s1)
    800038bc:	cf99                	beqz	a5,800038da <ilock+0x40>
}
    800038be:	60e2                	ld	ra,24(sp)
    800038c0:	6442                	ld	s0,16(sp)
    800038c2:	64a2                	ld	s1,8(sp)
    800038c4:	6902                	ld	s2,0(sp)
    800038c6:	6105                	addi	sp,sp,32
    800038c8:	8082                	ret
    panic("ilock");
    800038ca:	00005517          	auipc	a0,0x5
    800038ce:	d1650513          	addi	a0,a0,-746 # 800085e0 <syscalls+0x190>
    800038d2:	ffffd097          	auipc	ra,0xffffd
    800038d6:	c72080e7          	jalr	-910(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038da:	40dc                	lw	a5,4(s1)
    800038dc:	0047d79b          	srliw	a5,a5,0x4
    800038e0:	0001b597          	auipc	a1,0x1b
    800038e4:	7a05a583          	lw	a1,1952(a1) # 8001f080 <sb+0x18>
    800038e8:	9dbd                	addw	a1,a1,a5
    800038ea:	4088                	lw	a0,0(s1)
    800038ec:	fffff097          	auipc	ra,0xfffff
    800038f0:	794080e7          	jalr	1940(ra) # 80003080 <bread>
    800038f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038f6:	05850593          	addi	a1,a0,88
    800038fa:	40dc                	lw	a5,4(s1)
    800038fc:	8bbd                	andi	a5,a5,15
    800038fe:	079a                	slli	a5,a5,0x6
    80003900:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003902:	00059783          	lh	a5,0(a1)
    80003906:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000390a:	00259783          	lh	a5,2(a1)
    8000390e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003912:	00459783          	lh	a5,4(a1)
    80003916:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000391a:	00659783          	lh	a5,6(a1)
    8000391e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003922:	459c                	lw	a5,8(a1)
    80003924:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003926:	03400613          	li	a2,52
    8000392a:	05b1                	addi	a1,a1,12
    8000392c:	05048513          	addi	a0,s1,80
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	416080e7          	jalr	1046(ra) # 80000d46 <memmove>
    brelse(bp);
    80003938:	854a                	mv	a0,s2
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	876080e7          	jalr	-1930(ra) # 800031b0 <brelse>
    ip->valid = 1;
    80003942:	4785                	li	a5,1
    80003944:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003946:	04449783          	lh	a5,68(s1)
    8000394a:	fbb5                	bnez	a5,800038be <ilock+0x24>
      panic("ilock: no type");
    8000394c:	00005517          	auipc	a0,0x5
    80003950:	c9c50513          	addi	a0,a0,-868 # 800085e8 <syscalls+0x198>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	bf0080e7          	jalr	-1040(ra) # 80000544 <panic>

000000008000395c <iunlock>:
{
    8000395c:	1101                	addi	sp,sp,-32
    8000395e:	ec06                	sd	ra,24(sp)
    80003960:	e822                	sd	s0,16(sp)
    80003962:	e426                	sd	s1,8(sp)
    80003964:	e04a                	sd	s2,0(sp)
    80003966:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003968:	c905                	beqz	a0,80003998 <iunlock+0x3c>
    8000396a:	84aa                	mv	s1,a0
    8000396c:	01050913          	addi	s2,a0,16
    80003970:	854a                	mv	a0,s2
    80003972:	00001097          	auipc	ra,0x1
    80003976:	c7c080e7          	jalr	-900(ra) # 800045ee <holdingsleep>
    8000397a:	cd19                	beqz	a0,80003998 <iunlock+0x3c>
    8000397c:	449c                	lw	a5,8(s1)
    8000397e:	00f05d63          	blez	a5,80003998 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003982:	854a                	mv	a0,s2
    80003984:	00001097          	auipc	ra,0x1
    80003988:	c26080e7          	jalr	-986(ra) # 800045aa <releasesleep>
}
    8000398c:	60e2                	ld	ra,24(sp)
    8000398e:	6442                	ld	s0,16(sp)
    80003990:	64a2                	ld	s1,8(sp)
    80003992:	6902                	ld	s2,0(sp)
    80003994:	6105                	addi	sp,sp,32
    80003996:	8082                	ret
    panic("iunlock");
    80003998:	00005517          	auipc	a0,0x5
    8000399c:	c6050513          	addi	a0,a0,-928 # 800085f8 <syscalls+0x1a8>
    800039a0:	ffffd097          	auipc	ra,0xffffd
    800039a4:	ba4080e7          	jalr	-1116(ra) # 80000544 <panic>

00000000800039a8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039a8:	7179                	addi	sp,sp,-48
    800039aa:	f406                	sd	ra,40(sp)
    800039ac:	f022                	sd	s0,32(sp)
    800039ae:	ec26                	sd	s1,24(sp)
    800039b0:	e84a                	sd	s2,16(sp)
    800039b2:	e44e                	sd	s3,8(sp)
    800039b4:	e052                	sd	s4,0(sp)
    800039b6:	1800                	addi	s0,sp,48
    800039b8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039ba:	05050493          	addi	s1,a0,80
    800039be:	08050913          	addi	s2,a0,128
    800039c2:	a021                	j	800039ca <itrunc+0x22>
    800039c4:	0491                	addi	s1,s1,4
    800039c6:	01248d63          	beq	s1,s2,800039e0 <itrunc+0x38>
    if(ip->addrs[i]){
    800039ca:	408c                	lw	a1,0(s1)
    800039cc:	dde5                	beqz	a1,800039c4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800039ce:	0009a503          	lw	a0,0(s3)
    800039d2:	00000097          	auipc	ra,0x0
    800039d6:	8f4080e7          	jalr	-1804(ra) # 800032c6 <bfree>
      ip->addrs[i] = 0;
    800039da:	0004a023          	sw	zero,0(s1)
    800039de:	b7dd                	j	800039c4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039e0:	0809a583          	lw	a1,128(s3)
    800039e4:	e185                	bnez	a1,80003a04 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039e6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039ea:	854e                	mv	a0,s3
    800039ec:	00000097          	auipc	ra,0x0
    800039f0:	de4080e7          	jalr	-540(ra) # 800037d0 <iupdate>
}
    800039f4:	70a2                	ld	ra,40(sp)
    800039f6:	7402                	ld	s0,32(sp)
    800039f8:	64e2                	ld	s1,24(sp)
    800039fa:	6942                	ld	s2,16(sp)
    800039fc:	69a2                	ld	s3,8(sp)
    800039fe:	6a02                	ld	s4,0(sp)
    80003a00:	6145                	addi	sp,sp,48
    80003a02:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a04:	0009a503          	lw	a0,0(s3)
    80003a08:	fffff097          	auipc	ra,0xfffff
    80003a0c:	678080e7          	jalr	1656(ra) # 80003080 <bread>
    80003a10:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a12:	05850493          	addi	s1,a0,88
    80003a16:	45850913          	addi	s2,a0,1112
    80003a1a:	a811                	j	80003a2e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a1c:	0009a503          	lw	a0,0(s3)
    80003a20:	00000097          	auipc	ra,0x0
    80003a24:	8a6080e7          	jalr	-1882(ra) # 800032c6 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a28:	0491                	addi	s1,s1,4
    80003a2a:	01248563          	beq	s1,s2,80003a34 <itrunc+0x8c>
      if(a[j])
    80003a2e:	408c                	lw	a1,0(s1)
    80003a30:	dde5                	beqz	a1,80003a28 <itrunc+0x80>
    80003a32:	b7ed                	j	80003a1c <itrunc+0x74>
    brelse(bp);
    80003a34:	8552                	mv	a0,s4
    80003a36:	fffff097          	auipc	ra,0xfffff
    80003a3a:	77a080e7          	jalr	1914(ra) # 800031b0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a3e:	0809a583          	lw	a1,128(s3)
    80003a42:	0009a503          	lw	a0,0(s3)
    80003a46:	00000097          	auipc	ra,0x0
    80003a4a:	880080e7          	jalr	-1920(ra) # 800032c6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a4e:	0809a023          	sw	zero,128(s3)
    80003a52:	bf51                	j	800039e6 <itrunc+0x3e>

0000000080003a54 <iput>:
{
    80003a54:	1101                	addi	sp,sp,-32
    80003a56:	ec06                	sd	ra,24(sp)
    80003a58:	e822                	sd	s0,16(sp)
    80003a5a:	e426                	sd	s1,8(sp)
    80003a5c:	e04a                	sd	s2,0(sp)
    80003a5e:	1000                	addi	s0,sp,32
    80003a60:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a62:	0001b517          	auipc	a0,0x1b
    80003a66:	62650513          	addi	a0,a0,1574 # 8001f088 <itable>
    80003a6a:	ffffd097          	auipc	ra,0xffffd
    80003a6e:	180080e7          	jalr	384(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a72:	4498                	lw	a4,8(s1)
    80003a74:	4785                	li	a5,1
    80003a76:	02f70363          	beq	a4,a5,80003a9c <iput+0x48>
  ip->ref--;
    80003a7a:	449c                	lw	a5,8(s1)
    80003a7c:	37fd                	addiw	a5,a5,-1
    80003a7e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a80:	0001b517          	auipc	a0,0x1b
    80003a84:	60850513          	addi	a0,a0,1544 # 8001f088 <itable>
    80003a88:	ffffd097          	auipc	ra,0xffffd
    80003a8c:	216080e7          	jalr	534(ra) # 80000c9e <release>
}
    80003a90:	60e2                	ld	ra,24(sp)
    80003a92:	6442                	ld	s0,16(sp)
    80003a94:	64a2                	ld	s1,8(sp)
    80003a96:	6902                	ld	s2,0(sp)
    80003a98:	6105                	addi	sp,sp,32
    80003a9a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a9c:	40bc                	lw	a5,64(s1)
    80003a9e:	dff1                	beqz	a5,80003a7a <iput+0x26>
    80003aa0:	04a49783          	lh	a5,74(s1)
    80003aa4:	fbf9                	bnez	a5,80003a7a <iput+0x26>
    acquiresleep(&ip->lock);
    80003aa6:	01048913          	addi	s2,s1,16
    80003aaa:	854a                	mv	a0,s2
    80003aac:	00001097          	auipc	ra,0x1
    80003ab0:	aa8080e7          	jalr	-1368(ra) # 80004554 <acquiresleep>
    release(&itable.lock);
    80003ab4:	0001b517          	auipc	a0,0x1b
    80003ab8:	5d450513          	addi	a0,a0,1492 # 8001f088 <itable>
    80003abc:	ffffd097          	auipc	ra,0xffffd
    80003ac0:	1e2080e7          	jalr	482(ra) # 80000c9e <release>
    itrunc(ip);
    80003ac4:	8526                	mv	a0,s1
    80003ac6:	00000097          	auipc	ra,0x0
    80003aca:	ee2080e7          	jalr	-286(ra) # 800039a8 <itrunc>
    ip->type = 0;
    80003ace:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ad2:	8526                	mv	a0,s1
    80003ad4:	00000097          	auipc	ra,0x0
    80003ad8:	cfc080e7          	jalr	-772(ra) # 800037d0 <iupdate>
    ip->valid = 0;
    80003adc:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ae0:	854a                	mv	a0,s2
    80003ae2:	00001097          	auipc	ra,0x1
    80003ae6:	ac8080e7          	jalr	-1336(ra) # 800045aa <releasesleep>
    acquire(&itable.lock);
    80003aea:	0001b517          	auipc	a0,0x1b
    80003aee:	59e50513          	addi	a0,a0,1438 # 8001f088 <itable>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	0f8080e7          	jalr	248(ra) # 80000bea <acquire>
    80003afa:	b741                	j	80003a7a <iput+0x26>

0000000080003afc <iunlockput>:
{
    80003afc:	1101                	addi	sp,sp,-32
    80003afe:	ec06                	sd	ra,24(sp)
    80003b00:	e822                	sd	s0,16(sp)
    80003b02:	e426                	sd	s1,8(sp)
    80003b04:	1000                	addi	s0,sp,32
    80003b06:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b08:	00000097          	auipc	ra,0x0
    80003b0c:	e54080e7          	jalr	-428(ra) # 8000395c <iunlock>
  iput(ip);
    80003b10:	8526                	mv	a0,s1
    80003b12:	00000097          	auipc	ra,0x0
    80003b16:	f42080e7          	jalr	-190(ra) # 80003a54 <iput>
}
    80003b1a:	60e2                	ld	ra,24(sp)
    80003b1c:	6442                	ld	s0,16(sp)
    80003b1e:	64a2                	ld	s1,8(sp)
    80003b20:	6105                	addi	sp,sp,32
    80003b22:	8082                	ret

0000000080003b24 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b24:	1141                	addi	sp,sp,-16
    80003b26:	e422                	sd	s0,8(sp)
    80003b28:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b2a:	411c                	lw	a5,0(a0)
    80003b2c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b2e:	415c                	lw	a5,4(a0)
    80003b30:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b32:	04451783          	lh	a5,68(a0)
    80003b36:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b3a:	04a51783          	lh	a5,74(a0)
    80003b3e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b42:	04c56783          	lwu	a5,76(a0)
    80003b46:	e99c                	sd	a5,16(a1)
}
    80003b48:	6422                	ld	s0,8(sp)
    80003b4a:	0141                	addi	sp,sp,16
    80003b4c:	8082                	ret

0000000080003b4e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b4e:	457c                	lw	a5,76(a0)
    80003b50:	0ed7e963          	bltu	a5,a3,80003c42 <readi+0xf4>
{
    80003b54:	7159                	addi	sp,sp,-112
    80003b56:	f486                	sd	ra,104(sp)
    80003b58:	f0a2                	sd	s0,96(sp)
    80003b5a:	eca6                	sd	s1,88(sp)
    80003b5c:	e8ca                	sd	s2,80(sp)
    80003b5e:	e4ce                	sd	s3,72(sp)
    80003b60:	e0d2                	sd	s4,64(sp)
    80003b62:	fc56                	sd	s5,56(sp)
    80003b64:	f85a                	sd	s6,48(sp)
    80003b66:	f45e                	sd	s7,40(sp)
    80003b68:	f062                	sd	s8,32(sp)
    80003b6a:	ec66                	sd	s9,24(sp)
    80003b6c:	e86a                	sd	s10,16(sp)
    80003b6e:	e46e                	sd	s11,8(sp)
    80003b70:	1880                	addi	s0,sp,112
    80003b72:	8b2a                	mv	s6,a0
    80003b74:	8bae                	mv	s7,a1
    80003b76:	8a32                	mv	s4,a2
    80003b78:	84b6                	mv	s1,a3
    80003b7a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b7c:	9f35                	addw	a4,a4,a3
    return 0;
    80003b7e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b80:	0ad76063          	bltu	a4,a3,80003c20 <readi+0xd2>
  if(off + n > ip->size)
    80003b84:	00e7f463          	bgeu	a5,a4,80003b8c <readi+0x3e>
    n = ip->size - off;
    80003b88:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b8c:	0a0a8963          	beqz	s5,80003c3e <readi+0xf0>
    80003b90:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b92:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b96:	5c7d                	li	s8,-1
    80003b98:	a82d                	j	80003bd2 <readi+0x84>
    80003b9a:	020d1d93          	slli	s11,s10,0x20
    80003b9e:	020ddd93          	srli	s11,s11,0x20
    80003ba2:	05890613          	addi	a2,s2,88
    80003ba6:	86ee                	mv	a3,s11
    80003ba8:	963a                	add	a2,a2,a4
    80003baa:	85d2                	mv	a1,s4
    80003bac:	855e                	mv	a0,s7
    80003bae:	fffff097          	auipc	ra,0xfffff
    80003bb2:	912080e7          	jalr	-1774(ra) # 800024c0 <either_copyout>
    80003bb6:	05850d63          	beq	a0,s8,80003c10 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bba:	854a                	mv	a0,s2
    80003bbc:	fffff097          	auipc	ra,0xfffff
    80003bc0:	5f4080e7          	jalr	1524(ra) # 800031b0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bc4:	013d09bb          	addw	s3,s10,s3
    80003bc8:	009d04bb          	addw	s1,s10,s1
    80003bcc:	9a6e                	add	s4,s4,s11
    80003bce:	0559f763          	bgeu	s3,s5,80003c1c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003bd2:	00a4d59b          	srliw	a1,s1,0xa
    80003bd6:	855a                	mv	a0,s6
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	8a2080e7          	jalr	-1886(ra) # 8000347a <bmap>
    80003be0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003be4:	cd85                	beqz	a1,80003c1c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003be6:	000b2503          	lw	a0,0(s6)
    80003bea:	fffff097          	auipc	ra,0xfffff
    80003bee:	496080e7          	jalr	1174(ra) # 80003080 <bread>
    80003bf2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf4:	3ff4f713          	andi	a4,s1,1023
    80003bf8:	40ec87bb          	subw	a5,s9,a4
    80003bfc:	413a86bb          	subw	a3,s5,s3
    80003c00:	8d3e                	mv	s10,a5
    80003c02:	2781                	sext.w	a5,a5
    80003c04:	0006861b          	sext.w	a2,a3
    80003c08:	f8f679e3          	bgeu	a2,a5,80003b9a <readi+0x4c>
    80003c0c:	8d36                	mv	s10,a3
    80003c0e:	b771                	j	80003b9a <readi+0x4c>
      brelse(bp);
    80003c10:	854a                	mv	a0,s2
    80003c12:	fffff097          	auipc	ra,0xfffff
    80003c16:	59e080e7          	jalr	1438(ra) # 800031b0 <brelse>
      tot = -1;
    80003c1a:	59fd                	li	s3,-1
  }
  return tot;
    80003c1c:	0009851b          	sext.w	a0,s3
}
    80003c20:	70a6                	ld	ra,104(sp)
    80003c22:	7406                	ld	s0,96(sp)
    80003c24:	64e6                	ld	s1,88(sp)
    80003c26:	6946                	ld	s2,80(sp)
    80003c28:	69a6                	ld	s3,72(sp)
    80003c2a:	6a06                	ld	s4,64(sp)
    80003c2c:	7ae2                	ld	s5,56(sp)
    80003c2e:	7b42                	ld	s6,48(sp)
    80003c30:	7ba2                	ld	s7,40(sp)
    80003c32:	7c02                	ld	s8,32(sp)
    80003c34:	6ce2                	ld	s9,24(sp)
    80003c36:	6d42                	ld	s10,16(sp)
    80003c38:	6da2                	ld	s11,8(sp)
    80003c3a:	6165                	addi	sp,sp,112
    80003c3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c3e:	89d6                	mv	s3,s5
    80003c40:	bff1                	j	80003c1c <readi+0xce>
    return 0;
    80003c42:	4501                	li	a0,0
}
    80003c44:	8082                	ret

0000000080003c46 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c46:	457c                	lw	a5,76(a0)
    80003c48:	10d7e863          	bltu	a5,a3,80003d58 <writei+0x112>
{
    80003c4c:	7159                	addi	sp,sp,-112
    80003c4e:	f486                	sd	ra,104(sp)
    80003c50:	f0a2                	sd	s0,96(sp)
    80003c52:	eca6                	sd	s1,88(sp)
    80003c54:	e8ca                	sd	s2,80(sp)
    80003c56:	e4ce                	sd	s3,72(sp)
    80003c58:	e0d2                	sd	s4,64(sp)
    80003c5a:	fc56                	sd	s5,56(sp)
    80003c5c:	f85a                	sd	s6,48(sp)
    80003c5e:	f45e                	sd	s7,40(sp)
    80003c60:	f062                	sd	s8,32(sp)
    80003c62:	ec66                	sd	s9,24(sp)
    80003c64:	e86a                	sd	s10,16(sp)
    80003c66:	e46e                	sd	s11,8(sp)
    80003c68:	1880                	addi	s0,sp,112
    80003c6a:	8aaa                	mv	s5,a0
    80003c6c:	8bae                	mv	s7,a1
    80003c6e:	8a32                	mv	s4,a2
    80003c70:	8936                	mv	s2,a3
    80003c72:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c74:	00e687bb          	addw	a5,a3,a4
    80003c78:	0ed7e263          	bltu	a5,a3,80003d5c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c7c:	00043737          	lui	a4,0x43
    80003c80:	0ef76063          	bltu	a4,a5,80003d60 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c84:	0c0b0863          	beqz	s6,80003d54 <writei+0x10e>
    80003c88:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c8a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c8e:	5c7d                	li	s8,-1
    80003c90:	a091                	j	80003cd4 <writei+0x8e>
    80003c92:	020d1d93          	slli	s11,s10,0x20
    80003c96:	020ddd93          	srli	s11,s11,0x20
    80003c9a:	05848513          	addi	a0,s1,88
    80003c9e:	86ee                	mv	a3,s11
    80003ca0:	8652                	mv	a2,s4
    80003ca2:	85de                	mv	a1,s7
    80003ca4:	953a                	add	a0,a0,a4
    80003ca6:	fffff097          	auipc	ra,0xfffff
    80003caa:	870080e7          	jalr	-1936(ra) # 80002516 <either_copyin>
    80003cae:	07850263          	beq	a0,s8,80003d12 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cb2:	8526                	mv	a0,s1
    80003cb4:	00000097          	auipc	ra,0x0
    80003cb8:	780080e7          	jalr	1920(ra) # 80004434 <log_write>
    brelse(bp);
    80003cbc:	8526                	mv	a0,s1
    80003cbe:	fffff097          	auipc	ra,0xfffff
    80003cc2:	4f2080e7          	jalr	1266(ra) # 800031b0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cc6:	013d09bb          	addw	s3,s10,s3
    80003cca:	012d093b          	addw	s2,s10,s2
    80003cce:	9a6e                	add	s4,s4,s11
    80003cd0:	0569f663          	bgeu	s3,s6,80003d1c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003cd4:	00a9559b          	srliw	a1,s2,0xa
    80003cd8:	8556                	mv	a0,s5
    80003cda:	fffff097          	auipc	ra,0xfffff
    80003cde:	7a0080e7          	jalr	1952(ra) # 8000347a <bmap>
    80003ce2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ce6:	c99d                	beqz	a1,80003d1c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003ce8:	000aa503          	lw	a0,0(s5)
    80003cec:	fffff097          	auipc	ra,0xfffff
    80003cf0:	394080e7          	jalr	916(ra) # 80003080 <bread>
    80003cf4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cf6:	3ff97713          	andi	a4,s2,1023
    80003cfa:	40ec87bb          	subw	a5,s9,a4
    80003cfe:	413b06bb          	subw	a3,s6,s3
    80003d02:	8d3e                	mv	s10,a5
    80003d04:	2781                	sext.w	a5,a5
    80003d06:	0006861b          	sext.w	a2,a3
    80003d0a:	f8f674e3          	bgeu	a2,a5,80003c92 <writei+0x4c>
    80003d0e:	8d36                	mv	s10,a3
    80003d10:	b749                	j	80003c92 <writei+0x4c>
      brelse(bp);
    80003d12:	8526                	mv	a0,s1
    80003d14:	fffff097          	auipc	ra,0xfffff
    80003d18:	49c080e7          	jalr	1180(ra) # 800031b0 <brelse>
  }

  if(off > ip->size)
    80003d1c:	04caa783          	lw	a5,76(s5)
    80003d20:	0127f463          	bgeu	a5,s2,80003d28 <writei+0xe2>
    ip->size = off;
    80003d24:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d28:	8556                	mv	a0,s5
    80003d2a:	00000097          	auipc	ra,0x0
    80003d2e:	aa6080e7          	jalr	-1370(ra) # 800037d0 <iupdate>

  return tot;
    80003d32:	0009851b          	sext.w	a0,s3
}
    80003d36:	70a6                	ld	ra,104(sp)
    80003d38:	7406                	ld	s0,96(sp)
    80003d3a:	64e6                	ld	s1,88(sp)
    80003d3c:	6946                	ld	s2,80(sp)
    80003d3e:	69a6                	ld	s3,72(sp)
    80003d40:	6a06                	ld	s4,64(sp)
    80003d42:	7ae2                	ld	s5,56(sp)
    80003d44:	7b42                	ld	s6,48(sp)
    80003d46:	7ba2                	ld	s7,40(sp)
    80003d48:	7c02                	ld	s8,32(sp)
    80003d4a:	6ce2                	ld	s9,24(sp)
    80003d4c:	6d42                	ld	s10,16(sp)
    80003d4e:	6da2                	ld	s11,8(sp)
    80003d50:	6165                	addi	sp,sp,112
    80003d52:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d54:	89da                	mv	s3,s6
    80003d56:	bfc9                	j	80003d28 <writei+0xe2>
    return -1;
    80003d58:	557d                	li	a0,-1
}
    80003d5a:	8082                	ret
    return -1;
    80003d5c:	557d                	li	a0,-1
    80003d5e:	bfe1                	j	80003d36 <writei+0xf0>
    return -1;
    80003d60:	557d                	li	a0,-1
    80003d62:	bfd1                	j	80003d36 <writei+0xf0>

0000000080003d64 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d64:	1141                	addi	sp,sp,-16
    80003d66:	e406                	sd	ra,8(sp)
    80003d68:	e022                	sd	s0,0(sp)
    80003d6a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d6c:	4639                	li	a2,14
    80003d6e:	ffffd097          	auipc	ra,0xffffd
    80003d72:	050080e7          	jalr	80(ra) # 80000dbe <strncmp>
}
    80003d76:	60a2                	ld	ra,8(sp)
    80003d78:	6402                	ld	s0,0(sp)
    80003d7a:	0141                	addi	sp,sp,16
    80003d7c:	8082                	ret

0000000080003d7e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d7e:	7139                	addi	sp,sp,-64
    80003d80:	fc06                	sd	ra,56(sp)
    80003d82:	f822                	sd	s0,48(sp)
    80003d84:	f426                	sd	s1,40(sp)
    80003d86:	f04a                	sd	s2,32(sp)
    80003d88:	ec4e                	sd	s3,24(sp)
    80003d8a:	e852                	sd	s4,16(sp)
    80003d8c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d8e:	04451703          	lh	a4,68(a0)
    80003d92:	4785                	li	a5,1
    80003d94:	00f71a63          	bne	a4,a5,80003da8 <dirlookup+0x2a>
    80003d98:	892a                	mv	s2,a0
    80003d9a:	89ae                	mv	s3,a1
    80003d9c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d9e:	457c                	lw	a5,76(a0)
    80003da0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003da2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da4:	e79d                	bnez	a5,80003dd2 <dirlookup+0x54>
    80003da6:	a8a5                	j	80003e1e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003da8:	00005517          	auipc	a0,0x5
    80003dac:	85850513          	addi	a0,a0,-1960 # 80008600 <syscalls+0x1b0>
    80003db0:	ffffc097          	auipc	ra,0xffffc
    80003db4:	794080e7          	jalr	1940(ra) # 80000544 <panic>
      panic("dirlookup read");
    80003db8:	00005517          	auipc	a0,0x5
    80003dbc:	86050513          	addi	a0,a0,-1952 # 80008618 <syscalls+0x1c8>
    80003dc0:	ffffc097          	auipc	ra,0xffffc
    80003dc4:	784080e7          	jalr	1924(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dc8:	24c1                	addiw	s1,s1,16
    80003dca:	04c92783          	lw	a5,76(s2)
    80003dce:	04f4f763          	bgeu	s1,a5,80003e1c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dd2:	4741                	li	a4,16
    80003dd4:	86a6                	mv	a3,s1
    80003dd6:	fc040613          	addi	a2,s0,-64
    80003dda:	4581                	li	a1,0
    80003ddc:	854a                	mv	a0,s2
    80003dde:	00000097          	auipc	ra,0x0
    80003de2:	d70080e7          	jalr	-656(ra) # 80003b4e <readi>
    80003de6:	47c1                	li	a5,16
    80003de8:	fcf518e3          	bne	a0,a5,80003db8 <dirlookup+0x3a>
    if(de.inum == 0)
    80003dec:	fc045783          	lhu	a5,-64(s0)
    80003df0:	dfe1                	beqz	a5,80003dc8 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003df2:	fc240593          	addi	a1,s0,-62
    80003df6:	854e                	mv	a0,s3
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	f6c080e7          	jalr	-148(ra) # 80003d64 <namecmp>
    80003e00:	f561                	bnez	a0,80003dc8 <dirlookup+0x4a>
      if(poff)
    80003e02:	000a0463          	beqz	s4,80003e0a <dirlookup+0x8c>
        *poff = off;
    80003e06:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e0a:	fc045583          	lhu	a1,-64(s0)
    80003e0e:	00092503          	lw	a0,0(s2)
    80003e12:	fffff097          	auipc	ra,0xfffff
    80003e16:	750080e7          	jalr	1872(ra) # 80003562 <iget>
    80003e1a:	a011                	j	80003e1e <dirlookup+0xa0>
  return 0;
    80003e1c:	4501                	li	a0,0
}
    80003e1e:	70e2                	ld	ra,56(sp)
    80003e20:	7442                	ld	s0,48(sp)
    80003e22:	74a2                	ld	s1,40(sp)
    80003e24:	7902                	ld	s2,32(sp)
    80003e26:	69e2                	ld	s3,24(sp)
    80003e28:	6a42                	ld	s4,16(sp)
    80003e2a:	6121                	addi	sp,sp,64
    80003e2c:	8082                	ret

0000000080003e2e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e2e:	711d                	addi	sp,sp,-96
    80003e30:	ec86                	sd	ra,88(sp)
    80003e32:	e8a2                	sd	s0,80(sp)
    80003e34:	e4a6                	sd	s1,72(sp)
    80003e36:	e0ca                	sd	s2,64(sp)
    80003e38:	fc4e                	sd	s3,56(sp)
    80003e3a:	f852                	sd	s4,48(sp)
    80003e3c:	f456                	sd	s5,40(sp)
    80003e3e:	f05a                	sd	s6,32(sp)
    80003e40:	ec5e                	sd	s7,24(sp)
    80003e42:	e862                	sd	s8,16(sp)
    80003e44:	e466                	sd	s9,8(sp)
    80003e46:	1080                	addi	s0,sp,96
    80003e48:	84aa                	mv	s1,a0
    80003e4a:	8b2e                	mv	s6,a1
    80003e4c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e4e:	00054703          	lbu	a4,0(a0)
    80003e52:	02f00793          	li	a5,47
    80003e56:	02f70363          	beq	a4,a5,80003e7c <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e5a:	ffffe097          	auipc	ra,0xffffe
    80003e5e:	b6c080e7          	jalr	-1172(ra) # 800019c6 <myproc>
    80003e62:	15053503          	ld	a0,336(a0)
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	9f6080e7          	jalr	-1546(ra) # 8000385c <idup>
    80003e6e:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e70:	02f00913          	li	s2,47
  len = path - s;
    80003e74:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003e76:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e78:	4c05                	li	s8,1
    80003e7a:	a865                	j	80003f32 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e7c:	4585                	li	a1,1
    80003e7e:	4505                	li	a0,1
    80003e80:	fffff097          	auipc	ra,0xfffff
    80003e84:	6e2080e7          	jalr	1762(ra) # 80003562 <iget>
    80003e88:	89aa                	mv	s3,a0
    80003e8a:	b7dd                	j	80003e70 <namex+0x42>
      iunlockput(ip);
    80003e8c:	854e                	mv	a0,s3
    80003e8e:	00000097          	auipc	ra,0x0
    80003e92:	c6e080e7          	jalr	-914(ra) # 80003afc <iunlockput>
      return 0;
    80003e96:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e98:	854e                	mv	a0,s3
    80003e9a:	60e6                	ld	ra,88(sp)
    80003e9c:	6446                	ld	s0,80(sp)
    80003e9e:	64a6                	ld	s1,72(sp)
    80003ea0:	6906                	ld	s2,64(sp)
    80003ea2:	79e2                	ld	s3,56(sp)
    80003ea4:	7a42                	ld	s4,48(sp)
    80003ea6:	7aa2                	ld	s5,40(sp)
    80003ea8:	7b02                	ld	s6,32(sp)
    80003eaa:	6be2                	ld	s7,24(sp)
    80003eac:	6c42                	ld	s8,16(sp)
    80003eae:	6ca2                	ld	s9,8(sp)
    80003eb0:	6125                	addi	sp,sp,96
    80003eb2:	8082                	ret
      iunlock(ip);
    80003eb4:	854e                	mv	a0,s3
    80003eb6:	00000097          	auipc	ra,0x0
    80003eba:	aa6080e7          	jalr	-1370(ra) # 8000395c <iunlock>
      return ip;
    80003ebe:	bfe9                	j	80003e98 <namex+0x6a>
      iunlockput(ip);
    80003ec0:	854e                	mv	a0,s3
    80003ec2:	00000097          	auipc	ra,0x0
    80003ec6:	c3a080e7          	jalr	-966(ra) # 80003afc <iunlockput>
      return 0;
    80003eca:	89d2                	mv	s3,s4
    80003ecc:	b7f1                	j	80003e98 <namex+0x6a>
  len = path - s;
    80003ece:	40b48633          	sub	a2,s1,a1
    80003ed2:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003ed6:	094cd463          	bge	s9,s4,80003f5e <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003eda:	4639                	li	a2,14
    80003edc:	8556                	mv	a0,s5
    80003ede:	ffffd097          	auipc	ra,0xffffd
    80003ee2:	e68080e7          	jalr	-408(ra) # 80000d46 <memmove>
  while(*path == '/')
    80003ee6:	0004c783          	lbu	a5,0(s1)
    80003eea:	01279763          	bne	a5,s2,80003ef8 <namex+0xca>
    path++;
    80003eee:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ef0:	0004c783          	lbu	a5,0(s1)
    80003ef4:	ff278de3          	beq	a5,s2,80003eee <namex+0xc0>
    ilock(ip);
    80003ef8:	854e                	mv	a0,s3
    80003efa:	00000097          	auipc	ra,0x0
    80003efe:	9a0080e7          	jalr	-1632(ra) # 8000389a <ilock>
    if(ip->type != T_DIR){
    80003f02:	04499783          	lh	a5,68(s3)
    80003f06:	f98793e3          	bne	a5,s8,80003e8c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f0a:	000b0563          	beqz	s6,80003f14 <namex+0xe6>
    80003f0e:	0004c783          	lbu	a5,0(s1)
    80003f12:	d3cd                	beqz	a5,80003eb4 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f14:	865e                	mv	a2,s7
    80003f16:	85d6                	mv	a1,s5
    80003f18:	854e                	mv	a0,s3
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	e64080e7          	jalr	-412(ra) # 80003d7e <dirlookup>
    80003f22:	8a2a                	mv	s4,a0
    80003f24:	dd51                	beqz	a0,80003ec0 <namex+0x92>
    iunlockput(ip);
    80003f26:	854e                	mv	a0,s3
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	bd4080e7          	jalr	-1068(ra) # 80003afc <iunlockput>
    ip = next;
    80003f30:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f32:	0004c783          	lbu	a5,0(s1)
    80003f36:	05279763          	bne	a5,s2,80003f84 <namex+0x156>
    path++;
    80003f3a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f3c:	0004c783          	lbu	a5,0(s1)
    80003f40:	ff278de3          	beq	a5,s2,80003f3a <namex+0x10c>
  if(*path == 0)
    80003f44:	c79d                	beqz	a5,80003f72 <namex+0x144>
    path++;
    80003f46:	85a6                	mv	a1,s1
  len = path - s;
    80003f48:	8a5e                	mv	s4,s7
    80003f4a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f4c:	01278963          	beq	a5,s2,80003f5e <namex+0x130>
    80003f50:	dfbd                	beqz	a5,80003ece <namex+0xa0>
    path++;
    80003f52:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f54:	0004c783          	lbu	a5,0(s1)
    80003f58:	ff279ce3          	bne	a5,s2,80003f50 <namex+0x122>
    80003f5c:	bf8d                	j	80003ece <namex+0xa0>
    memmove(name, s, len);
    80003f5e:	2601                	sext.w	a2,a2
    80003f60:	8556                	mv	a0,s5
    80003f62:	ffffd097          	auipc	ra,0xffffd
    80003f66:	de4080e7          	jalr	-540(ra) # 80000d46 <memmove>
    name[len] = 0;
    80003f6a:	9a56                	add	s4,s4,s5
    80003f6c:	000a0023          	sb	zero,0(s4)
    80003f70:	bf9d                	j	80003ee6 <namex+0xb8>
  if(nameiparent){
    80003f72:	f20b03e3          	beqz	s6,80003e98 <namex+0x6a>
    iput(ip);
    80003f76:	854e                	mv	a0,s3
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	adc080e7          	jalr	-1316(ra) # 80003a54 <iput>
    return 0;
    80003f80:	4981                	li	s3,0
    80003f82:	bf19                	j	80003e98 <namex+0x6a>
  if(*path == 0)
    80003f84:	d7fd                	beqz	a5,80003f72 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f86:	0004c783          	lbu	a5,0(s1)
    80003f8a:	85a6                	mv	a1,s1
    80003f8c:	b7d1                	j	80003f50 <namex+0x122>

0000000080003f8e <dirlink>:
{
    80003f8e:	7139                	addi	sp,sp,-64
    80003f90:	fc06                	sd	ra,56(sp)
    80003f92:	f822                	sd	s0,48(sp)
    80003f94:	f426                	sd	s1,40(sp)
    80003f96:	f04a                	sd	s2,32(sp)
    80003f98:	ec4e                	sd	s3,24(sp)
    80003f9a:	e852                	sd	s4,16(sp)
    80003f9c:	0080                	addi	s0,sp,64
    80003f9e:	892a                	mv	s2,a0
    80003fa0:	8a2e                	mv	s4,a1
    80003fa2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fa4:	4601                	li	a2,0
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	dd8080e7          	jalr	-552(ra) # 80003d7e <dirlookup>
    80003fae:	e93d                	bnez	a0,80004024 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fb0:	04c92483          	lw	s1,76(s2)
    80003fb4:	c49d                	beqz	s1,80003fe2 <dirlink+0x54>
    80003fb6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fb8:	4741                	li	a4,16
    80003fba:	86a6                	mv	a3,s1
    80003fbc:	fc040613          	addi	a2,s0,-64
    80003fc0:	4581                	li	a1,0
    80003fc2:	854a                	mv	a0,s2
    80003fc4:	00000097          	auipc	ra,0x0
    80003fc8:	b8a080e7          	jalr	-1142(ra) # 80003b4e <readi>
    80003fcc:	47c1                	li	a5,16
    80003fce:	06f51163          	bne	a0,a5,80004030 <dirlink+0xa2>
    if(de.inum == 0)
    80003fd2:	fc045783          	lhu	a5,-64(s0)
    80003fd6:	c791                	beqz	a5,80003fe2 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd8:	24c1                	addiw	s1,s1,16
    80003fda:	04c92783          	lw	a5,76(s2)
    80003fde:	fcf4ede3          	bltu	s1,a5,80003fb8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fe2:	4639                	li	a2,14
    80003fe4:	85d2                	mv	a1,s4
    80003fe6:	fc240513          	addi	a0,s0,-62
    80003fea:	ffffd097          	auipc	ra,0xffffd
    80003fee:	e10080e7          	jalr	-496(ra) # 80000dfa <strncpy>
  de.inum = inum;
    80003ff2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ff6:	4741                	li	a4,16
    80003ff8:	86a6                	mv	a3,s1
    80003ffa:	fc040613          	addi	a2,s0,-64
    80003ffe:	4581                	li	a1,0
    80004000:	854a                	mv	a0,s2
    80004002:	00000097          	auipc	ra,0x0
    80004006:	c44080e7          	jalr	-956(ra) # 80003c46 <writei>
    8000400a:	1541                	addi	a0,a0,-16
    8000400c:	00a03533          	snez	a0,a0
    80004010:	40a00533          	neg	a0,a0
}
    80004014:	70e2                	ld	ra,56(sp)
    80004016:	7442                	ld	s0,48(sp)
    80004018:	74a2                	ld	s1,40(sp)
    8000401a:	7902                	ld	s2,32(sp)
    8000401c:	69e2                	ld	s3,24(sp)
    8000401e:	6a42                	ld	s4,16(sp)
    80004020:	6121                	addi	sp,sp,64
    80004022:	8082                	ret
    iput(ip);
    80004024:	00000097          	auipc	ra,0x0
    80004028:	a30080e7          	jalr	-1488(ra) # 80003a54 <iput>
    return -1;
    8000402c:	557d                	li	a0,-1
    8000402e:	b7dd                	j	80004014 <dirlink+0x86>
      panic("dirlink read");
    80004030:	00004517          	auipc	a0,0x4
    80004034:	5f850513          	addi	a0,a0,1528 # 80008628 <syscalls+0x1d8>
    80004038:	ffffc097          	auipc	ra,0xffffc
    8000403c:	50c080e7          	jalr	1292(ra) # 80000544 <panic>

0000000080004040 <namei>:

struct inode*
namei(char *path)
{
    80004040:	1101                	addi	sp,sp,-32
    80004042:	ec06                	sd	ra,24(sp)
    80004044:	e822                	sd	s0,16(sp)
    80004046:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004048:	fe040613          	addi	a2,s0,-32
    8000404c:	4581                	li	a1,0
    8000404e:	00000097          	auipc	ra,0x0
    80004052:	de0080e7          	jalr	-544(ra) # 80003e2e <namex>
}
    80004056:	60e2                	ld	ra,24(sp)
    80004058:	6442                	ld	s0,16(sp)
    8000405a:	6105                	addi	sp,sp,32
    8000405c:	8082                	ret

000000008000405e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000405e:	1141                	addi	sp,sp,-16
    80004060:	e406                	sd	ra,8(sp)
    80004062:	e022                	sd	s0,0(sp)
    80004064:	0800                	addi	s0,sp,16
    80004066:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004068:	4585                	li	a1,1
    8000406a:	00000097          	auipc	ra,0x0
    8000406e:	dc4080e7          	jalr	-572(ra) # 80003e2e <namex>
}
    80004072:	60a2                	ld	ra,8(sp)
    80004074:	6402                	ld	s0,0(sp)
    80004076:	0141                	addi	sp,sp,16
    80004078:	8082                	ret

000000008000407a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000407a:	1101                	addi	sp,sp,-32
    8000407c:	ec06                	sd	ra,24(sp)
    8000407e:	e822                	sd	s0,16(sp)
    80004080:	e426                	sd	s1,8(sp)
    80004082:	e04a                	sd	s2,0(sp)
    80004084:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004086:	0001d917          	auipc	s2,0x1d
    8000408a:	aaa90913          	addi	s2,s2,-1366 # 80020b30 <log>
    8000408e:	01892583          	lw	a1,24(s2)
    80004092:	02892503          	lw	a0,40(s2)
    80004096:	fffff097          	auipc	ra,0xfffff
    8000409a:	fea080e7          	jalr	-22(ra) # 80003080 <bread>
    8000409e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040a0:	02c92683          	lw	a3,44(s2)
    800040a4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040a6:	02d05763          	blez	a3,800040d4 <write_head+0x5a>
    800040aa:	0001d797          	auipc	a5,0x1d
    800040ae:	ab678793          	addi	a5,a5,-1354 # 80020b60 <log+0x30>
    800040b2:	05c50713          	addi	a4,a0,92
    800040b6:	36fd                	addiw	a3,a3,-1
    800040b8:	1682                	slli	a3,a3,0x20
    800040ba:	9281                	srli	a3,a3,0x20
    800040bc:	068a                	slli	a3,a3,0x2
    800040be:	0001d617          	auipc	a2,0x1d
    800040c2:	aa660613          	addi	a2,a2,-1370 # 80020b64 <log+0x34>
    800040c6:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040c8:	4390                	lw	a2,0(a5)
    800040ca:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040cc:	0791                	addi	a5,a5,4
    800040ce:	0711                	addi	a4,a4,4
    800040d0:	fed79ce3          	bne	a5,a3,800040c8 <write_head+0x4e>
  }
  bwrite(buf);
    800040d4:	8526                	mv	a0,s1
    800040d6:	fffff097          	auipc	ra,0xfffff
    800040da:	09c080e7          	jalr	156(ra) # 80003172 <bwrite>
  brelse(buf);
    800040de:	8526                	mv	a0,s1
    800040e0:	fffff097          	auipc	ra,0xfffff
    800040e4:	0d0080e7          	jalr	208(ra) # 800031b0 <brelse>
}
    800040e8:	60e2                	ld	ra,24(sp)
    800040ea:	6442                	ld	s0,16(sp)
    800040ec:	64a2                	ld	s1,8(sp)
    800040ee:	6902                	ld	s2,0(sp)
    800040f0:	6105                	addi	sp,sp,32
    800040f2:	8082                	ret

00000000800040f4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040f4:	0001d797          	auipc	a5,0x1d
    800040f8:	a687a783          	lw	a5,-1432(a5) # 80020b5c <log+0x2c>
    800040fc:	0af05d63          	blez	a5,800041b6 <install_trans+0xc2>
{
    80004100:	7139                	addi	sp,sp,-64
    80004102:	fc06                	sd	ra,56(sp)
    80004104:	f822                	sd	s0,48(sp)
    80004106:	f426                	sd	s1,40(sp)
    80004108:	f04a                	sd	s2,32(sp)
    8000410a:	ec4e                	sd	s3,24(sp)
    8000410c:	e852                	sd	s4,16(sp)
    8000410e:	e456                	sd	s5,8(sp)
    80004110:	e05a                	sd	s6,0(sp)
    80004112:	0080                	addi	s0,sp,64
    80004114:	8b2a                	mv	s6,a0
    80004116:	0001da97          	auipc	s5,0x1d
    8000411a:	a4aa8a93          	addi	s5,s5,-1462 # 80020b60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000411e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004120:	0001d997          	auipc	s3,0x1d
    80004124:	a1098993          	addi	s3,s3,-1520 # 80020b30 <log>
    80004128:	a035                	j	80004154 <install_trans+0x60>
      bunpin(dbuf);
    8000412a:	8526                	mv	a0,s1
    8000412c:	fffff097          	auipc	ra,0xfffff
    80004130:	15e080e7          	jalr	350(ra) # 8000328a <bunpin>
    brelse(lbuf);
    80004134:	854a                	mv	a0,s2
    80004136:	fffff097          	auipc	ra,0xfffff
    8000413a:	07a080e7          	jalr	122(ra) # 800031b0 <brelse>
    brelse(dbuf);
    8000413e:	8526                	mv	a0,s1
    80004140:	fffff097          	auipc	ra,0xfffff
    80004144:	070080e7          	jalr	112(ra) # 800031b0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004148:	2a05                	addiw	s4,s4,1
    8000414a:	0a91                	addi	s5,s5,4
    8000414c:	02c9a783          	lw	a5,44(s3)
    80004150:	04fa5963          	bge	s4,a5,800041a2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004154:	0189a583          	lw	a1,24(s3)
    80004158:	014585bb          	addw	a1,a1,s4
    8000415c:	2585                	addiw	a1,a1,1
    8000415e:	0289a503          	lw	a0,40(s3)
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	f1e080e7          	jalr	-226(ra) # 80003080 <bread>
    8000416a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000416c:	000aa583          	lw	a1,0(s5)
    80004170:	0289a503          	lw	a0,40(s3)
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	f0c080e7          	jalr	-244(ra) # 80003080 <bread>
    8000417c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000417e:	40000613          	li	a2,1024
    80004182:	05890593          	addi	a1,s2,88
    80004186:	05850513          	addi	a0,a0,88
    8000418a:	ffffd097          	auipc	ra,0xffffd
    8000418e:	bbc080e7          	jalr	-1092(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004192:	8526                	mv	a0,s1
    80004194:	fffff097          	auipc	ra,0xfffff
    80004198:	fde080e7          	jalr	-34(ra) # 80003172 <bwrite>
    if(recovering == 0)
    8000419c:	f80b1ce3          	bnez	s6,80004134 <install_trans+0x40>
    800041a0:	b769                	j	8000412a <install_trans+0x36>
}
    800041a2:	70e2                	ld	ra,56(sp)
    800041a4:	7442                	ld	s0,48(sp)
    800041a6:	74a2                	ld	s1,40(sp)
    800041a8:	7902                	ld	s2,32(sp)
    800041aa:	69e2                	ld	s3,24(sp)
    800041ac:	6a42                	ld	s4,16(sp)
    800041ae:	6aa2                	ld	s5,8(sp)
    800041b0:	6b02                	ld	s6,0(sp)
    800041b2:	6121                	addi	sp,sp,64
    800041b4:	8082                	ret
    800041b6:	8082                	ret

00000000800041b8 <initlog>:
{
    800041b8:	7179                	addi	sp,sp,-48
    800041ba:	f406                	sd	ra,40(sp)
    800041bc:	f022                	sd	s0,32(sp)
    800041be:	ec26                	sd	s1,24(sp)
    800041c0:	e84a                	sd	s2,16(sp)
    800041c2:	e44e                	sd	s3,8(sp)
    800041c4:	1800                	addi	s0,sp,48
    800041c6:	892a                	mv	s2,a0
    800041c8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041ca:	0001d497          	auipc	s1,0x1d
    800041ce:	96648493          	addi	s1,s1,-1690 # 80020b30 <log>
    800041d2:	00004597          	auipc	a1,0x4
    800041d6:	46658593          	addi	a1,a1,1126 # 80008638 <syscalls+0x1e8>
    800041da:	8526                	mv	a0,s1
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	97e080e7          	jalr	-1666(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800041e4:	0149a583          	lw	a1,20(s3)
    800041e8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041ea:	0109a783          	lw	a5,16(s3)
    800041ee:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041f0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041f4:	854a                	mv	a0,s2
    800041f6:	fffff097          	auipc	ra,0xfffff
    800041fa:	e8a080e7          	jalr	-374(ra) # 80003080 <bread>
  log.lh.n = lh->n;
    800041fe:	4d3c                	lw	a5,88(a0)
    80004200:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004202:	02f05563          	blez	a5,8000422c <initlog+0x74>
    80004206:	05c50713          	addi	a4,a0,92
    8000420a:	0001d697          	auipc	a3,0x1d
    8000420e:	95668693          	addi	a3,a3,-1706 # 80020b60 <log+0x30>
    80004212:	37fd                	addiw	a5,a5,-1
    80004214:	1782                	slli	a5,a5,0x20
    80004216:	9381                	srli	a5,a5,0x20
    80004218:	078a                	slli	a5,a5,0x2
    8000421a:	06050613          	addi	a2,a0,96
    8000421e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004220:	4310                	lw	a2,0(a4)
    80004222:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004224:	0711                	addi	a4,a4,4
    80004226:	0691                	addi	a3,a3,4
    80004228:	fef71ce3          	bne	a4,a5,80004220 <initlog+0x68>
  brelse(buf);
    8000422c:	fffff097          	auipc	ra,0xfffff
    80004230:	f84080e7          	jalr	-124(ra) # 800031b0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004234:	4505                	li	a0,1
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	ebe080e7          	jalr	-322(ra) # 800040f4 <install_trans>
  log.lh.n = 0;
    8000423e:	0001d797          	auipc	a5,0x1d
    80004242:	9007af23          	sw	zero,-1762(a5) # 80020b5c <log+0x2c>
  write_head(); // clear the log
    80004246:	00000097          	auipc	ra,0x0
    8000424a:	e34080e7          	jalr	-460(ra) # 8000407a <write_head>
}
    8000424e:	70a2                	ld	ra,40(sp)
    80004250:	7402                	ld	s0,32(sp)
    80004252:	64e2                	ld	s1,24(sp)
    80004254:	6942                	ld	s2,16(sp)
    80004256:	69a2                	ld	s3,8(sp)
    80004258:	6145                	addi	sp,sp,48
    8000425a:	8082                	ret

000000008000425c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000425c:	1101                	addi	sp,sp,-32
    8000425e:	ec06                	sd	ra,24(sp)
    80004260:	e822                	sd	s0,16(sp)
    80004262:	e426                	sd	s1,8(sp)
    80004264:	e04a                	sd	s2,0(sp)
    80004266:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004268:	0001d517          	auipc	a0,0x1d
    8000426c:	8c850513          	addi	a0,a0,-1848 # 80020b30 <log>
    80004270:	ffffd097          	auipc	ra,0xffffd
    80004274:	97a080e7          	jalr	-1670(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    80004278:	0001d497          	auipc	s1,0x1d
    8000427c:	8b848493          	addi	s1,s1,-1864 # 80020b30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004280:	4979                	li	s2,30
    80004282:	a039                	j	80004290 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004284:	85a6                	mv	a1,s1
    80004286:	8526                	mv	a0,s1
    80004288:	ffffe097          	auipc	ra,0xffffe
    8000428c:	e30080e7          	jalr	-464(ra) # 800020b8 <sleep>
    if(log.committing){
    80004290:	50dc                	lw	a5,36(s1)
    80004292:	fbed                	bnez	a5,80004284 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004294:	509c                	lw	a5,32(s1)
    80004296:	0017871b          	addiw	a4,a5,1
    8000429a:	0007069b          	sext.w	a3,a4
    8000429e:	0027179b          	slliw	a5,a4,0x2
    800042a2:	9fb9                	addw	a5,a5,a4
    800042a4:	0017979b          	slliw	a5,a5,0x1
    800042a8:	54d8                	lw	a4,44(s1)
    800042aa:	9fb9                	addw	a5,a5,a4
    800042ac:	00f95963          	bge	s2,a5,800042be <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042b0:	85a6                	mv	a1,s1
    800042b2:	8526                	mv	a0,s1
    800042b4:	ffffe097          	auipc	ra,0xffffe
    800042b8:	e04080e7          	jalr	-508(ra) # 800020b8 <sleep>
    800042bc:	bfd1                	j	80004290 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042be:	0001d517          	auipc	a0,0x1d
    800042c2:	87250513          	addi	a0,a0,-1934 # 80020b30 <log>
    800042c6:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800042c8:	ffffd097          	auipc	ra,0xffffd
    800042cc:	9d6080e7          	jalr	-1578(ra) # 80000c9e <release>
      break;
    }
  }
}
    800042d0:	60e2                	ld	ra,24(sp)
    800042d2:	6442                	ld	s0,16(sp)
    800042d4:	64a2                	ld	s1,8(sp)
    800042d6:	6902                	ld	s2,0(sp)
    800042d8:	6105                	addi	sp,sp,32
    800042da:	8082                	ret

00000000800042dc <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042dc:	7139                	addi	sp,sp,-64
    800042de:	fc06                	sd	ra,56(sp)
    800042e0:	f822                	sd	s0,48(sp)
    800042e2:	f426                	sd	s1,40(sp)
    800042e4:	f04a                	sd	s2,32(sp)
    800042e6:	ec4e                	sd	s3,24(sp)
    800042e8:	e852                	sd	s4,16(sp)
    800042ea:	e456                	sd	s5,8(sp)
    800042ec:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042ee:	0001d497          	auipc	s1,0x1d
    800042f2:	84248493          	addi	s1,s1,-1982 # 80020b30 <log>
    800042f6:	8526                	mv	a0,s1
    800042f8:	ffffd097          	auipc	ra,0xffffd
    800042fc:	8f2080e7          	jalr	-1806(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004300:	509c                	lw	a5,32(s1)
    80004302:	37fd                	addiw	a5,a5,-1
    80004304:	0007891b          	sext.w	s2,a5
    80004308:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000430a:	50dc                	lw	a5,36(s1)
    8000430c:	efb9                	bnez	a5,8000436a <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000430e:	06091663          	bnez	s2,8000437a <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004312:	0001d497          	auipc	s1,0x1d
    80004316:	81e48493          	addi	s1,s1,-2018 # 80020b30 <log>
    8000431a:	4785                	li	a5,1
    8000431c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000431e:	8526                	mv	a0,s1
    80004320:	ffffd097          	auipc	ra,0xffffd
    80004324:	97e080e7          	jalr	-1666(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004328:	54dc                	lw	a5,44(s1)
    8000432a:	06f04763          	bgtz	a5,80004398 <end_op+0xbc>
    acquire(&log.lock);
    8000432e:	0001d497          	auipc	s1,0x1d
    80004332:	80248493          	addi	s1,s1,-2046 # 80020b30 <log>
    80004336:	8526                	mv	a0,s1
    80004338:	ffffd097          	auipc	ra,0xffffd
    8000433c:	8b2080e7          	jalr	-1870(ra) # 80000bea <acquire>
    log.committing = 0;
    80004340:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004344:	8526                	mv	a0,s1
    80004346:	ffffe097          	auipc	ra,0xffffe
    8000434a:	dd6080e7          	jalr	-554(ra) # 8000211c <wakeup>
    release(&log.lock);
    8000434e:	8526                	mv	a0,s1
    80004350:	ffffd097          	auipc	ra,0xffffd
    80004354:	94e080e7          	jalr	-1714(ra) # 80000c9e <release>
}
    80004358:	70e2                	ld	ra,56(sp)
    8000435a:	7442                	ld	s0,48(sp)
    8000435c:	74a2                	ld	s1,40(sp)
    8000435e:	7902                	ld	s2,32(sp)
    80004360:	69e2                	ld	s3,24(sp)
    80004362:	6a42                	ld	s4,16(sp)
    80004364:	6aa2                	ld	s5,8(sp)
    80004366:	6121                	addi	sp,sp,64
    80004368:	8082                	ret
    panic("log.committing");
    8000436a:	00004517          	auipc	a0,0x4
    8000436e:	2d650513          	addi	a0,a0,726 # 80008640 <syscalls+0x1f0>
    80004372:	ffffc097          	auipc	ra,0xffffc
    80004376:	1d2080e7          	jalr	466(ra) # 80000544 <panic>
    wakeup(&log);
    8000437a:	0001c497          	auipc	s1,0x1c
    8000437e:	7b648493          	addi	s1,s1,1974 # 80020b30 <log>
    80004382:	8526                	mv	a0,s1
    80004384:	ffffe097          	auipc	ra,0xffffe
    80004388:	d98080e7          	jalr	-616(ra) # 8000211c <wakeup>
  release(&log.lock);
    8000438c:	8526                	mv	a0,s1
    8000438e:	ffffd097          	auipc	ra,0xffffd
    80004392:	910080e7          	jalr	-1776(ra) # 80000c9e <release>
  if(do_commit){
    80004396:	b7c9                	j	80004358 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004398:	0001ca97          	auipc	s5,0x1c
    8000439c:	7c8a8a93          	addi	s5,s5,1992 # 80020b60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043a0:	0001ca17          	auipc	s4,0x1c
    800043a4:	790a0a13          	addi	s4,s4,1936 # 80020b30 <log>
    800043a8:	018a2583          	lw	a1,24(s4)
    800043ac:	012585bb          	addw	a1,a1,s2
    800043b0:	2585                	addiw	a1,a1,1
    800043b2:	028a2503          	lw	a0,40(s4)
    800043b6:	fffff097          	auipc	ra,0xfffff
    800043ba:	cca080e7          	jalr	-822(ra) # 80003080 <bread>
    800043be:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043c0:	000aa583          	lw	a1,0(s5)
    800043c4:	028a2503          	lw	a0,40(s4)
    800043c8:	fffff097          	auipc	ra,0xfffff
    800043cc:	cb8080e7          	jalr	-840(ra) # 80003080 <bread>
    800043d0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043d2:	40000613          	li	a2,1024
    800043d6:	05850593          	addi	a1,a0,88
    800043da:	05848513          	addi	a0,s1,88
    800043de:	ffffd097          	auipc	ra,0xffffd
    800043e2:	968080e7          	jalr	-1688(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    800043e6:	8526                	mv	a0,s1
    800043e8:	fffff097          	auipc	ra,0xfffff
    800043ec:	d8a080e7          	jalr	-630(ra) # 80003172 <bwrite>
    brelse(from);
    800043f0:	854e                	mv	a0,s3
    800043f2:	fffff097          	auipc	ra,0xfffff
    800043f6:	dbe080e7          	jalr	-578(ra) # 800031b0 <brelse>
    brelse(to);
    800043fa:	8526                	mv	a0,s1
    800043fc:	fffff097          	auipc	ra,0xfffff
    80004400:	db4080e7          	jalr	-588(ra) # 800031b0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004404:	2905                	addiw	s2,s2,1
    80004406:	0a91                	addi	s5,s5,4
    80004408:	02ca2783          	lw	a5,44(s4)
    8000440c:	f8f94ee3          	blt	s2,a5,800043a8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004410:	00000097          	auipc	ra,0x0
    80004414:	c6a080e7          	jalr	-918(ra) # 8000407a <write_head>
    install_trans(0); // Now install writes to home locations
    80004418:	4501                	li	a0,0
    8000441a:	00000097          	auipc	ra,0x0
    8000441e:	cda080e7          	jalr	-806(ra) # 800040f4 <install_trans>
    log.lh.n = 0;
    80004422:	0001c797          	auipc	a5,0x1c
    80004426:	7207ad23          	sw	zero,1850(a5) # 80020b5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000442a:	00000097          	auipc	ra,0x0
    8000442e:	c50080e7          	jalr	-944(ra) # 8000407a <write_head>
    80004432:	bdf5                	j	8000432e <end_op+0x52>

0000000080004434 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004434:	1101                	addi	sp,sp,-32
    80004436:	ec06                	sd	ra,24(sp)
    80004438:	e822                	sd	s0,16(sp)
    8000443a:	e426                	sd	s1,8(sp)
    8000443c:	e04a                	sd	s2,0(sp)
    8000443e:	1000                	addi	s0,sp,32
    80004440:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004442:	0001c917          	auipc	s2,0x1c
    80004446:	6ee90913          	addi	s2,s2,1774 # 80020b30 <log>
    8000444a:	854a                	mv	a0,s2
    8000444c:	ffffc097          	auipc	ra,0xffffc
    80004450:	79e080e7          	jalr	1950(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004454:	02c92603          	lw	a2,44(s2)
    80004458:	47f5                	li	a5,29
    8000445a:	06c7c563          	blt	a5,a2,800044c4 <log_write+0x90>
    8000445e:	0001c797          	auipc	a5,0x1c
    80004462:	6ee7a783          	lw	a5,1774(a5) # 80020b4c <log+0x1c>
    80004466:	37fd                	addiw	a5,a5,-1
    80004468:	04f65e63          	bge	a2,a5,800044c4 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000446c:	0001c797          	auipc	a5,0x1c
    80004470:	6e47a783          	lw	a5,1764(a5) # 80020b50 <log+0x20>
    80004474:	06f05063          	blez	a5,800044d4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004478:	4781                	li	a5,0
    8000447a:	06c05563          	blez	a2,800044e4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000447e:	44cc                	lw	a1,12(s1)
    80004480:	0001c717          	auipc	a4,0x1c
    80004484:	6e070713          	addi	a4,a4,1760 # 80020b60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004488:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000448a:	4314                	lw	a3,0(a4)
    8000448c:	04b68c63          	beq	a3,a1,800044e4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004490:	2785                	addiw	a5,a5,1
    80004492:	0711                	addi	a4,a4,4
    80004494:	fef61be3          	bne	a2,a5,8000448a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004498:	0621                	addi	a2,a2,8
    8000449a:	060a                	slli	a2,a2,0x2
    8000449c:	0001c797          	auipc	a5,0x1c
    800044a0:	69478793          	addi	a5,a5,1684 # 80020b30 <log>
    800044a4:	963e                	add	a2,a2,a5
    800044a6:	44dc                	lw	a5,12(s1)
    800044a8:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044aa:	8526                	mv	a0,s1
    800044ac:	fffff097          	auipc	ra,0xfffff
    800044b0:	da2080e7          	jalr	-606(ra) # 8000324e <bpin>
    log.lh.n++;
    800044b4:	0001c717          	auipc	a4,0x1c
    800044b8:	67c70713          	addi	a4,a4,1660 # 80020b30 <log>
    800044bc:	575c                	lw	a5,44(a4)
    800044be:	2785                	addiw	a5,a5,1
    800044c0:	d75c                	sw	a5,44(a4)
    800044c2:	a835                	j	800044fe <log_write+0xca>
    panic("too big a transaction");
    800044c4:	00004517          	auipc	a0,0x4
    800044c8:	18c50513          	addi	a0,a0,396 # 80008650 <syscalls+0x200>
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	078080e7          	jalr	120(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    800044d4:	00004517          	auipc	a0,0x4
    800044d8:	19450513          	addi	a0,a0,404 # 80008668 <syscalls+0x218>
    800044dc:	ffffc097          	auipc	ra,0xffffc
    800044e0:	068080e7          	jalr	104(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    800044e4:	00878713          	addi	a4,a5,8
    800044e8:	00271693          	slli	a3,a4,0x2
    800044ec:	0001c717          	auipc	a4,0x1c
    800044f0:	64470713          	addi	a4,a4,1604 # 80020b30 <log>
    800044f4:	9736                	add	a4,a4,a3
    800044f6:	44d4                	lw	a3,12(s1)
    800044f8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044fa:	faf608e3          	beq	a2,a5,800044aa <log_write+0x76>
  }
  release(&log.lock);
    800044fe:	0001c517          	auipc	a0,0x1c
    80004502:	63250513          	addi	a0,a0,1586 # 80020b30 <log>
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	798080e7          	jalr	1944(ra) # 80000c9e <release>
}
    8000450e:	60e2                	ld	ra,24(sp)
    80004510:	6442                	ld	s0,16(sp)
    80004512:	64a2                	ld	s1,8(sp)
    80004514:	6902                	ld	s2,0(sp)
    80004516:	6105                	addi	sp,sp,32
    80004518:	8082                	ret

000000008000451a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000451a:	1101                	addi	sp,sp,-32
    8000451c:	ec06                	sd	ra,24(sp)
    8000451e:	e822                	sd	s0,16(sp)
    80004520:	e426                	sd	s1,8(sp)
    80004522:	e04a                	sd	s2,0(sp)
    80004524:	1000                	addi	s0,sp,32
    80004526:	84aa                	mv	s1,a0
    80004528:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000452a:	00004597          	auipc	a1,0x4
    8000452e:	15e58593          	addi	a1,a1,350 # 80008688 <syscalls+0x238>
    80004532:	0521                	addi	a0,a0,8
    80004534:	ffffc097          	auipc	ra,0xffffc
    80004538:	626080e7          	jalr	1574(ra) # 80000b5a <initlock>
  lk->name = name;
    8000453c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004540:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004544:	0204a423          	sw	zero,40(s1)
}
    80004548:	60e2                	ld	ra,24(sp)
    8000454a:	6442                	ld	s0,16(sp)
    8000454c:	64a2                	ld	s1,8(sp)
    8000454e:	6902                	ld	s2,0(sp)
    80004550:	6105                	addi	sp,sp,32
    80004552:	8082                	ret

0000000080004554 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004554:	1101                	addi	sp,sp,-32
    80004556:	ec06                	sd	ra,24(sp)
    80004558:	e822                	sd	s0,16(sp)
    8000455a:	e426                	sd	s1,8(sp)
    8000455c:	e04a                	sd	s2,0(sp)
    8000455e:	1000                	addi	s0,sp,32
    80004560:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004562:	00850913          	addi	s2,a0,8
    80004566:	854a                	mv	a0,s2
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	682080e7          	jalr	1666(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004570:	409c                	lw	a5,0(s1)
    80004572:	cb89                	beqz	a5,80004584 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004574:	85ca                	mv	a1,s2
    80004576:	8526                	mv	a0,s1
    80004578:	ffffe097          	auipc	ra,0xffffe
    8000457c:	b40080e7          	jalr	-1216(ra) # 800020b8 <sleep>
  while (lk->locked) {
    80004580:	409c                	lw	a5,0(s1)
    80004582:	fbed                	bnez	a5,80004574 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004584:	4785                	li	a5,1
    80004586:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004588:	ffffd097          	auipc	ra,0xffffd
    8000458c:	43e080e7          	jalr	1086(ra) # 800019c6 <myproc>
    80004590:	591c                	lw	a5,48(a0)
    80004592:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004594:	854a                	mv	a0,s2
    80004596:	ffffc097          	auipc	ra,0xffffc
    8000459a:	708080e7          	jalr	1800(ra) # 80000c9e <release>
}
    8000459e:	60e2                	ld	ra,24(sp)
    800045a0:	6442                	ld	s0,16(sp)
    800045a2:	64a2                	ld	s1,8(sp)
    800045a4:	6902                	ld	s2,0(sp)
    800045a6:	6105                	addi	sp,sp,32
    800045a8:	8082                	ret

00000000800045aa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045aa:	1101                	addi	sp,sp,-32
    800045ac:	ec06                	sd	ra,24(sp)
    800045ae:	e822                	sd	s0,16(sp)
    800045b0:	e426                	sd	s1,8(sp)
    800045b2:	e04a                	sd	s2,0(sp)
    800045b4:	1000                	addi	s0,sp,32
    800045b6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045b8:	00850913          	addi	s2,a0,8
    800045bc:	854a                	mv	a0,s2
    800045be:	ffffc097          	auipc	ra,0xffffc
    800045c2:	62c080e7          	jalr	1580(ra) # 80000bea <acquire>
  lk->locked = 0;
    800045c6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ca:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045ce:	8526                	mv	a0,s1
    800045d0:	ffffe097          	auipc	ra,0xffffe
    800045d4:	b4c080e7          	jalr	-1204(ra) # 8000211c <wakeup>
  release(&lk->lk);
    800045d8:	854a                	mv	a0,s2
    800045da:	ffffc097          	auipc	ra,0xffffc
    800045de:	6c4080e7          	jalr	1732(ra) # 80000c9e <release>
}
    800045e2:	60e2                	ld	ra,24(sp)
    800045e4:	6442                	ld	s0,16(sp)
    800045e6:	64a2                	ld	s1,8(sp)
    800045e8:	6902                	ld	s2,0(sp)
    800045ea:	6105                	addi	sp,sp,32
    800045ec:	8082                	ret

00000000800045ee <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045ee:	7179                	addi	sp,sp,-48
    800045f0:	f406                	sd	ra,40(sp)
    800045f2:	f022                	sd	s0,32(sp)
    800045f4:	ec26                	sd	s1,24(sp)
    800045f6:	e84a                	sd	s2,16(sp)
    800045f8:	e44e                	sd	s3,8(sp)
    800045fa:	1800                	addi	s0,sp,48
    800045fc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045fe:	00850913          	addi	s2,a0,8
    80004602:	854a                	mv	a0,s2
    80004604:	ffffc097          	auipc	ra,0xffffc
    80004608:	5e6080e7          	jalr	1510(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000460c:	409c                	lw	a5,0(s1)
    8000460e:	ef99                	bnez	a5,8000462c <holdingsleep+0x3e>
    80004610:	4481                	li	s1,0
  release(&lk->lk);
    80004612:	854a                	mv	a0,s2
    80004614:	ffffc097          	auipc	ra,0xffffc
    80004618:	68a080e7          	jalr	1674(ra) # 80000c9e <release>
  return r;
}
    8000461c:	8526                	mv	a0,s1
    8000461e:	70a2                	ld	ra,40(sp)
    80004620:	7402                	ld	s0,32(sp)
    80004622:	64e2                	ld	s1,24(sp)
    80004624:	6942                	ld	s2,16(sp)
    80004626:	69a2                	ld	s3,8(sp)
    80004628:	6145                	addi	sp,sp,48
    8000462a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000462c:	0284a983          	lw	s3,40(s1)
    80004630:	ffffd097          	auipc	ra,0xffffd
    80004634:	396080e7          	jalr	918(ra) # 800019c6 <myproc>
    80004638:	5904                	lw	s1,48(a0)
    8000463a:	413484b3          	sub	s1,s1,s3
    8000463e:	0014b493          	seqz	s1,s1
    80004642:	bfc1                	j	80004612 <holdingsleep+0x24>

0000000080004644 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004644:	1141                	addi	sp,sp,-16
    80004646:	e406                	sd	ra,8(sp)
    80004648:	e022                	sd	s0,0(sp)
    8000464a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000464c:	00004597          	auipc	a1,0x4
    80004650:	04c58593          	addi	a1,a1,76 # 80008698 <syscalls+0x248>
    80004654:	0001c517          	auipc	a0,0x1c
    80004658:	62450513          	addi	a0,a0,1572 # 80020c78 <ftable>
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	4fe080e7          	jalr	1278(ra) # 80000b5a <initlock>
}
    80004664:	60a2                	ld	ra,8(sp)
    80004666:	6402                	ld	s0,0(sp)
    80004668:	0141                	addi	sp,sp,16
    8000466a:	8082                	ret

000000008000466c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000466c:	1101                	addi	sp,sp,-32
    8000466e:	ec06                	sd	ra,24(sp)
    80004670:	e822                	sd	s0,16(sp)
    80004672:	e426                	sd	s1,8(sp)
    80004674:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004676:	0001c517          	auipc	a0,0x1c
    8000467a:	60250513          	addi	a0,a0,1538 # 80020c78 <ftable>
    8000467e:	ffffc097          	auipc	ra,0xffffc
    80004682:	56c080e7          	jalr	1388(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004686:	0001c497          	auipc	s1,0x1c
    8000468a:	60a48493          	addi	s1,s1,1546 # 80020c90 <ftable+0x18>
    8000468e:	0001d717          	auipc	a4,0x1d
    80004692:	5a270713          	addi	a4,a4,1442 # 80021c30 <disk>
    if(f->ref == 0){
    80004696:	40dc                	lw	a5,4(s1)
    80004698:	cf99                	beqz	a5,800046b6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000469a:	02848493          	addi	s1,s1,40
    8000469e:	fee49ce3          	bne	s1,a4,80004696 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046a2:	0001c517          	auipc	a0,0x1c
    800046a6:	5d650513          	addi	a0,a0,1494 # 80020c78 <ftable>
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	5f4080e7          	jalr	1524(ra) # 80000c9e <release>
  return 0;
    800046b2:	4481                	li	s1,0
    800046b4:	a819                	j	800046ca <filealloc+0x5e>
      f->ref = 1;
    800046b6:	4785                	li	a5,1
    800046b8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046ba:	0001c517          	auipc	a0,0x1c
    800046be:	5be50513          	addi	a0,a0,1470 # 80020c78 <ftable>
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	5dc080e7          	jalr	1500(ra) # 80000c9e <release>
}
    800046ca:	8526                	mv	a0,s1
    800046cc:	60e2                	ld	ra,24(sp)
    800046ce:	6442                	ld	s0,16(sp)
    800046d0:	64a2                	ld	s1,8(sp)
    800046d2:	6105                	addi	sp,sp,32
    800046d4:	8082                	ret

00000000800046d6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046d6:	1101                	addi	sp,sp,-32
    800046d8:	ec06                	sd	ra,24(sp)
    800046da:	e822                	sd	s0,16(sp)
    800046dc:	e426                	sd	s1,8(sp)
    800046de:	1000                	addi	s0,sp,32
    800046e0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046e2:	0001c517          	auipc	a0,0x1c
    800046e6:	59650513          	addi	a0,a0,1430 # 80020c78 <ftable>
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	500080e7          	jalr	1280(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800046f2:	40dc                	lw	a5,4(s1)
    800046f4:	02f05263          	blez	a5,80004718 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046f8:	2785                	addiw	a5,a5,1
    800046fa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046fc:	0001c517          	auipc	a0,0x1c
    80004700:	57c50513          	addi	a0,a0,1404 # 80020c78 <ftable>
    80004704:	ffffc097          	auipc	ra,0xffffc
    80004708:	59a080e7          	jalr	1434(ra) # 80000c9e <release>
  return f;
}
    8000470c:	8526                	mv	a0,s1
    8000470e:	60e2                	ld	ra,24(sp)
    80004710:	6442                	ld	s0,16(sp)
    80004712:	64a2                	ld	s1,8(sp)
    80004714:	6105                	addi	sp,sp,32
    80004716:	8082                	ret
    panic("filedup");
    80004718:	00004517          	auipc	a0,0x4
    8000471c:	f8850513          	addi	a0,a0,-120 # 800086a0 <syscalls+0x250>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	e24080e7          	jalr	-476(ra) # 80000544 <panic>

0000000080004728 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004728:	7139                	addi	sp,sp,-64
    8000472a:	fc06                	sd	ra,56(sp)
    8000472c:	f822                	sd	s0,48(sp)
    8000472e:	f426                	sd	s1,40(sp)
    80004730:	f04a                	sd	s2,32(sp)
    80004732:	ec4e                	sd	s3,24(sp)
    80004734:	e852                	sd	s4,16(sp)
    80004736:	e456                	sd	s5,8(sp)
    80004738:	0080                	addi	s0,sp,64
    8000473a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000473c:	0001c517          	auipc	a0,0x1c
    80004740:	53c50513          	addi	a0,a0,1340 # 80020c78 <ftable>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	4a6080e7          	jalr	1190(ra) # 80000bea <acquire>
  if(f->ref < 1)
    8000474c:	40dc                	lw	a5,4(s1)
    8000474e:	06f05163          	blez	a5,800047b0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004752:	37fd                	addiw	a5,a5,-1
    80004754:	0007871b          	sext.w	a4,a5
    80004758:	c0dc                	sw	a5,4(s1)
    8000475a:	06e04363          	bgtz	a4,800047c0 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000475e:	0004a903          	lw	s2,0(s1)
    80004762:	0094ca83          	lbu	s5,9(s1)
    80004766:	0104ba03          	ld	s4,16(s1)
    8000476a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000476e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004772:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004776:	0001c517          	auipc	a0,0x1c
    8000477a:	50250513          	addi	a0,a0,1282 # 80020c78 <ftable>
    8000477e:	ffffc097          	auipc	ra,0xffffc
    80004782:	520080e7          	jalr	1312(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004786:	4785                	li	a5,1
    80004788:	04f90d63          	beq	s2,a5,800047e2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000478c:	3979                	addiw	s2,s2,-2
    8000478e:	4785                	li	a5,1
    80004790:	0527e063          	bltu	a5,s2,800047d0 <fileclose+0xa8>
    begin_op();
    80004794:	00000097          	auipc	ra,0x0
    80004798:	ac8080e7          	jalr	-1336(ra) # 8000425c <begin_op>
    iput(ff.ip);
    8000479c:	854e                	mv	a0,s3
    8000479e:	fffff097          	auipc	ra,0xfffff
    800047a2:	2b6080e7          	jalr	694(ra) # 80003a54 <iput>
    end_op();
    800047a6:	00000097          	auipc	ra,0x0
    800047aa:	b36080e7          	jalr	-1226(ra) # 800042dc <end_op>
    800047ae:	a00d                	j	800047d0 <fileclose+0xa8>
    panic("fileclose");
    800047b0:	00004517          	auipc	a0,0x4
    800047b4:	ef850513          	addi	a0,a0,-264 # 800086a8 <syscalls+0x258>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	d8c080e7          	jalr	-628(ra) # 80000544 <panic>
    release(&ftable.lock);
    800047c0:	0001c517          	auipc	a0,0x1c
    800047c4:	4b850513          	addi	a0,a0,1208 # 80020c78 <ftable>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	4d6080e7          	jalr	1238(ra) # 80000c9e <release>
  }
}
    800047d0:	70e2                	ld	ra,56(sp)
    800047d2:	7442                	ld	s0,48(sp)
    800047d4:	74a2                	ld	s1,40(sp)
    800047d6:	7902                	ld	s2,32(sp)
    800047d8:	69e2                	ld	s3,24(sp)
    800047da:	6a42                	ld	s4,16(sp)
    800047dc:	6aa2                	ld	s5,8(sp)
    800047de:	6121                	addi	sp,sp,64
    800047e0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047e2:	85d6                	mv	a1,s5
    800047e4:	8552                	mv	a0,s4
    800047e6:	00000097          	auipc	ra,0x0
    800047ea:	34c080e7          	jalr	844(ra) # 80004b32 <pipeclose>
    800047ee:	b7cd                	j	800047d0 <fileclose+0xa8>

00000000800047f0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047f0:	715d                	addi	sp,sp,-80
    800047f2:	e486                	sd	ra,72(sp)
    800047f4:	e0a2                	sd	s0,64(sp)
    800047f6:	fc26                	sd	s1,56(sp)
    800047f8:	f84a                	sd	s2,48(sp)
    800047fa:	f44e                	sd	s3,40(sp)
    800047fc:	0880                	addi	s0,sp,80
    800047fe:	84aa                	mv	s1,a0
    80004800:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004802:	ffffd097          	auipc	ra,0xffffd
    80004806:	1c4080e7          	jalr	452(ra) # 800019c6 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000480a:	409c                	lw	a5,0(s1)
    8000480c:	37f9                	addiw	a5,a5,-2
    8000480e:	4705                	li	a4,1
    80004810:	04f76763          	bltu	a4,a5,8000485e <filestat+0x6e>
    80004814:	892a                	mv	s2,a0
    ilock(f->ip);
    80004816:	6c88                	ld	a0,24(s1)
    80004818:	fffff097          	auipc	ra,0xfffff
    8000481c:	082080e7          	jalr	130(ra) # 8000389a <ilock>
    stati(f->ip, &st);
    80004820:	fb840593          	addi	a1,s0,-72
    80004824:	6c88                	ld	a0,24(s1)
    80004826:	fffff097          	auipc	ra,0xfffff
    8000482a:	2fe080e7          	jalr	766(ra) # 80003b24 <stati>
    iunlock(f->ip);
    8000482e:	6c88                	ld	a0,24(s1)
    80004830:	fffff097          	auipc	ra,0xfffff
    80004834:	12c080e7          	jalr	300(ra) # 8000395c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004838:	46e1                	li	a3,24
    8000483a:	fb840613          	addi	a2,s0,-72
    8000483e:	85ce                	mv	a1,s3
    80004840:	05093503          	ld	a0,80(s2)
    80004844:	ffffd097          	auipc	ra,0xffffd
    80004848:	e40080e7          	jalr	-448(ra) # 80001684 <copyout>
    8000484c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004850:	60a6                	ld	ra,72(sp)
    80004852:	6406                	ld	s0,64(sp)
    80004854:	74e2                	ld	s1,56(sp)
    80004856:	7942                	ld	s2,48(sp)
    80004858:	79a2                	ld	s3,40(sp)
    8000485a:	6161                	addi	sp,sp,80
    8000485c:	8082                	ret
  return -1;
    8000485e:	557d                	li	a0,-1
    80004860:	bfc5                	j	80004850 <filestat+0x60>

0000000080004862 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004862:	7179                	addi	sp,sp,-48
    80004864:	f406                	sd	ra,40(sp)
    80004866:	f022                	sd	s0,32(sp)
    80004868:	ec26                	sd	s1,24(sp)
    8000486a:	e84a                	sd	s2,16(sp)
    8000486c:	e44e                	sd	s3,8(sp)
    8000486e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004870:	00854783          	lbu	a5,8(a0)
    80004874:	c3d5                	beqz	a5,80004918 <fileread+0xb6>
    80004876:	84aa                	mv	s1,a0
    80004878:	89ae                	mv	s3,a1
    8000487a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000487c:	411c                	lw	a5,0(a0)
    8000487e:	4705                	li	a4,1
    80004880:	04e78963          	beq	a5,a4,800048d2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004884:	470d                	li	a4,3
    80004886:	04e78d63          	beq	a5,a4,800048e0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000488a:	4709                	li	a4,2
    8000488c:	06e79e63          	bne	a5,a4,80004908 <fileread+0xa6>
    ilock(f->ip);
    80004890:	6d08                	ld	a0,24(a0)
    80004892:	fffff097          	auipc	ra,0xfffff
    80004896:	008080e7          	jalr	8(ra) # 8000389a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000489a:	874a                	mv	a4,s2
    8000489c:	5094                	lw	a3,32(s1)
    8000489e:	864e                	mv	a2,s3
    800048a0:	4585                	li	a1,1
    800048a2:	6c88                	ld	a0,24(s1)
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	2aa080e7          	jalr	682(ra) # 80003b4e <readi>
    800048ac:	892a                	mv	s2,a0
    800048ae:	00a05563          	blez	a0,800048b8 <fileread+0x56>
      f->off += r;
    800048b2:	509c                	lw	a5,32(s1)
    800048b4:	9fa9                	addw	a5,a5,a0
    800048b6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048b8:	6c88                	ld	a0,24(s1)
    800048ba:	fffff097          	auipc	ra,0xfffff
    800048be:	0a2080e7          	jalr	162(ra) # 8000395c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048c2:	854a                	mv	a0,s2
    800048c4:	70a2                	ld	ra,40(sp)
    800048c6:	7402                	ld	s0,32(sp)
    800048c8:	64e2                	ld	s1,24(sp)
    800048ca:	6942                	ld	s2,16(sp)
    800048cc:	69a2                	ld	s3,8(sp)
    800048ce:	6145                	addi	sp,sp,48
    800048d0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048d2:	6908                	ld	a0,16(a0)
    800048d4:	00000097          	auipc	ra,0x0
    800048d8:	3ce080e7          	jalr	974(ra) # 80004ca2 <piperead>
    800048dc:	892a                	mv	s2,a0
    800048de:	b7d5                	j	800048c2 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048e0:	02451783          	lh	a5,36(a0)
    800048e4:	03079693          	slli	a3,a5,0x30
    800048e8:	92c1                	srli	a3,a3,0x30
    800048ea:	4725                	li	a4,9
    800048ec:	02d76863          	bltu	a4,a3,8000491c <fileread+0xba>
    800048f0:	0792                	slli	a5,a5,0x4
    800048f2:	0001c717          	auipc	a4,0x1c
    800048f6:	2e670713          	addi	a4,a4,742 # 80020bd8 <devsw>
    800048fa:	97ba                	add	a5,a5,a4
    800048fc:	639c                	ld	a5,0(a5)
    800048fe:	c38d                	beqz	a5,80004920 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004900:	4505                	li	a0,1
    80004902:	9782                	jalr	a5
    80004904:	892a                	mv	s2,a0
    80004906:	bf75                	j	800048c2 <fileread+0x60>
    panic("fileread");
    80004908:	00004517          	auipc	a0,0x4
    8000490c:	db050513          	addi	a0,a0,-592 # 800086b8 <syscalls+0x268>
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	c34080e7          	jalr	-972(ra) # 80000544 <panic>
    return -1;
    80004918:	597d                	li	s2,-1
    8000491a:	b765                	j	800048c2 <fileread+0x60>
      return -1;
    8000491c:	597d                	li	s2,-1
    8000491e:	b755                	j	800048c2 <fileread+0x60>
    80004920:	597d                	li	s2,-1
    80004922:	b745                	j	800048c2 <fileread+0x60>

0000000080004924 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004924:	715d                	addi	sp,sp,-80
    80004926:	e486                	sd	ra,72(sp)
    80004928:	e0a2                	sd	s0,64(sp)
    8000492a:	fc26                	sd	s1,56(sp)
    8000492c:	f84a                	sd	s2,48(sp)
    8000492e:	f44e                	sd	s3,40(sp)
    80004930:	f052                	sd	s4,32(sp)
    80004932:	ec56                	sd	s5,24(sp)
    80004934:	e85a                	sd	s6,16(sp)
    80004936:	e45e                	sd	s7,8(sp)
    80004938:	e062                	sd	s8,0(sp)
    8000493a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000493c:	00954783          	lbu	a5,9(a0)
    80004940:	10078663          	beqz	a5,80004a4c <filewrite+0x128>
    80004944:	892a                	mv	s2,a0
    80004946:	8aae                	mv	s5,a1
    80004948:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000494a:	411c                	lw	a5,0(a0)
    8000494c:	4705                	li	a4,1
    8000494e:	02e78263          	beq	a5,a4,80004972 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004952:	470d                	li	a4,3
    80004954:	02e78663          	beq	a5,a4,80004980 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004958:	4709                	li	a4,2
    8000495a:	0ee79163          	bne	a5,a4,80004a3c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000495e:	0ac05d63          	blez	a2,80004a18 <filewrite+0xf4>
    int i = 0;
    80004962:	4981                	li	s3,0
    80004964:	6b05                	lui	s6,0x1
    80004966:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000496a:	6b85                	lui	s7,0x1
    8000496c:	c00b8b9b          	addiw	s7,s7,-1024
    80004970:	a861                	j	80004a08 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004972:	6908                	ld	a0,16(a0)
    80004974:	00000097          	auipc	ra,0x0
    80004978:	22e080e7          	jalr	558(ra) # 80004ba2 <pipewrite>
    8000497c:	8a2a                	mv	s4,a0
    8000497e:	a045                	j	80004a1e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004980:	02451783          	lh	a5,36(a0)
    80004984:	03079693          	slli	a3,a5,0x30
    80004988:	92c1                	srli	a3,a3,0x30
    8000498a:	4725                	li	a4,9
    8000498c:	0cd76263          	bltu	a4,a3,80004a50 <filewrite+0x12c>
    80004990:	0792                	slli	a5,a5,0x4
    80004992:	0001c717          	auipc	a4,0x1c
    80004996:	24670713          	addi	a4,a4,582 # 80020bd8 <devsw>
    8000499a:	97ba                	add	a5,a5,a4
    8000499c:	679c                	ld	a5,8(a5)
    8000499e:	cbdd                	beqz	a5,80004a54 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800049a0:	4505                	li	a0,1
    800049a2:	9782                	jalr	a5
    800049a4:	8a2a                	mv	s4,a0
    800049a6:	a8a5                	j	80004a1e <filewrite+0xfa>
    800049a8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049ac:	00000097          	auipc	ra,0x0
    800049b0:	8b0080e7          	jalr	-1872(ra) # 8000425c <begin_op>
      ilock(f->ip);
    800049b4:	01893503          	ld	a0,24(s2)
    800049b8:	fffff097          	auipc	ra,0xfffff
    800049bc:	ee2080e7          	jalr	-286(ra) # 8000389a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049c0:	8762                	mv	a4,s8
    800049c2:	02092683          	lw	a3,32(s2)
    800049c6:	01598633          	add	a2,s3,s5
    800049ca:	4585                	li	a1,1
    800049cc:	01893503          	ld	a0,24(s2)
    800049d0:	fffff097          	auipc	ra,0xfffff
    800049d4:	276080e7          	jalr	630(ra) # 80003c46 <writei>
    800049d8:	84aa                	mv	s1,a0
    800049da:	00a05763          	blez	a0,800049e8 <filewrite+0xc4>
        f->off += r;
    800049de:	02092783          	lw	a5,32(s2)
    800049e2:	9fa9                	addw	a5,a5,a0
    800049e4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049e8:	01893503          	ld	a0,24(s2)
    800049ec:	fffff097          	auipc	ra,0xfffff
    800049f0:	f70080e7          	jalr	-144(ra) # 8000395c <iunlock>
      end_op();
    800049f4:	00000097          	auipc	ra,0x0
    800049f8:	8e8080e7          	jalr	-1816(ra) # 800042dc <end_op>

      if(r != n1){
    800049fc:	009c1f63          	bne	s8,s1,80004a1a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a00:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a04:	0149db63          	bge	s3,s4,80004a1a <filewrite+0xf6>
      int n1 = n - i;
    80004a08:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a0c:	84be                	mv	s1,a5
    80004a0e:	2781                	sext.w	a5,a5
    80004a10:	f8fb5ce3          	bge	s6,a5,800049a8 <filewrite+0x84>
    80004a14:	84de                	mv	s1,s7
    80004a16:	bf49                	j	800049a8 <filewrite+0x84>
    int i = 0;
    80004a18:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a1a:	013a1f63          	bne	s4,s3,80004a38 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a1e:	8552                	mv	a0,s4
    80004a20:	60a6                	ld	ra,72(sp)
    80004a22:	6406                	ld	s0,64(sp)
    80004a24:	74e2                	ld	s1,56(sp)
    80004a26:	7942                	ld	s2,48(sp)
    80004a28:	79a2                	ld	s3,40(sp)
    80004a2a:	7a02                	ld	s4,32(sp)
    80004a2c:	6ae2                	ld	s5,24(sp)
    80004a2e:	6b42                	ld	s6,16(sp)
    80004a30:	6ba2                	ld	s7,8(sp)
    80004a32:	6c02                	ld	s8,0(sp)
    80004a34:	6161                	addi	sp,sp,80
    80004a36:	8082                	ret
    ret = (i == n ? n : -1);
    80004a38:	5a7d                	li	s4,-1
    80004a3a:	b7d5                	j	80004a1e <filewrite+0xfa>
    panic("filewrite");
    80004a3c:	00004517          	auipc	a0,0x4
    80004a40:	c8c50513          	addi	a0,a0,-884 # 800086c8 <syscalls+0x278>
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	b00080e7          	jalr	-1280(ra) # 80000544 <panic>
    return -1;
    80004a4c:	5a7d                	li	s4,-1
    80004a4e:	bfc1                	j	80004a1e <filewrite+0xfa>
      return -1;
    80004a50:	5a7d                	li	s4,-1
    80004a52:	b7f1                	j	80004a1e <filewrite+0xfa>
    80004a54:	5a7d                	li	s4,-1
    80004a56:	b7e1                	j	80004a1e <filewrite+0xfa>

0000000080004a58 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a58:	7179                	addi	sp,sp,-48
    80004a5a:	f406                	sd	ra,40(sp)
    80004a5c:	f022                	sd	s0,32(sp)
    80004a5e:	ec26                	sd	s1,24(sp)
    80004a60:	e84a                	sd	s2,16(sp)
    80004a62:	e44e                	sd	s3,8(sp)
    80004a64:	e052                	sd	s4,0(sp)
    80004a66:	1800                	addi	s0,sp,48
    80004a68:	84aa                	mv	s1,a0
    80004a6a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a6c:	0005b023          	sd	zero,0(a1)
    80004a70:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a74:	00000097          	auipc	ra,0x0
    80004a78:	bf8080e7          	jalr	-1032(ra) # 8000466c <filealloc>
    80004a7c:	e088                	sd	a0,0(s1)
    80004a7e:	c551                	beqz	a0,80004b0a <pipealloc+0xb2>
    80004a80:	00000097          	auipc	ra,0x0
    80004a84:	bec080e7          	jalr	-1044(ra) # 8000466c <filealloc>
    80004a88:	00aa3023          	sd	a0,0(s4)
    80004a8c:	c92d                	beqz	a0,80004afe <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a8e:	ffffc097          	auipc	ra,0xffffc
    80004a92:	06c080e7          	jalr	108(ra) # 80000afa <kalloc>
    80004a96:	892a                	mv	s2,a0
    80004a98:	c125                	beqz	a0,80004af8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a9a:	4985                	li	s3,1
    80004a9c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004aa0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004aa4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004aa8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004aac:	00004597          	auipc	a1,0x4
    80004ab0:	c2c58593          	addi	a1,a1,-980 # 800086d8 <syscalls+0x288>
    80004ab4:	ffffc097          	auipc	ra,0xffffc
    80004ab8:	0a6080e7          	jalr	166(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004abc:	609c                	ld	a5,0(s1)
    80004abe:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ac2:	609c                	ld	a5,0(s1)
    80004ac4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ac8:	609c                	ld	a5,0(s1)
    80004aca:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ace:	609c                	ld	a5,0(s1)
    80004ad0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ad4:	000a3783          	ld	a5,0(s4)
    80004ad8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004adc:	000a3783          	ld	a5,0(s4)
    80004ae0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ae4:	000a3783          	ld	a5,0(s4)
    80004ae8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004aec:	000a3783          	ld	a5,0(s4)
    80004af0:	0127b823          	sd	s2,16(a5)
  return 0;
    80004af4:	4501                	li	a0,0
    80004af6:	a025                	j	80004b1e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004af8:	6088                	ld	a0,0(s1)
    80004afa:	e501                	bnez	a0,80004b02 <pipealloc+0xaa>
    80004afc:	a039                	j	80004b0a <pipealloc+0xb2>
    80004afe:	6088                	ld	a0,0(s1)
    80004b00:	c51d                	beqz	a0,80004b2e <pipealloc+0xd6>
    fileclose(*f0);
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	c26080e7          	jalr	-986(ra) # 80004728 <fileclose>
  if(*f1)
    80004b0a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b0e:	557d                	li	a0,-1
  if(*f1)
    80004b10:	c799                	beqz	a5,80004b1e <pipealloc+0xc6>
    fileclose(*f1);
    80004b12:	853e                	mv	a0,a5
    80004b14:	00000097          	auipc	ra,0x0
    80004b18:	c14080e7          	jalr	-1004(ra) # 80004728 <fileclose>
  return -1;
    80004b1c:	557d                	li	a0,-1
}
    80004b1e:	70a2                	ld	ra,40(sp)
    80004b20:	7402                	ld	s0,32(sp)
    80004b22:	64e2                	ld	s1,24(sp)
    80004b24:	6942                	ld	s2,16(sp)
    80004b26:	69a2                	ld	s3,8(sp)
    80004b28:	6a02                	ld	s4,0(sp)
    80004b2a:	6145                	addi	sp,sp,48
    80004b2c:	8082                	ret
  return -1;
    80004b2e:	557d                	li	a0,-1
    80004b30:	b7fd                	j	80004b1e <pipealloc+0xc6>

0000000080004b32 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b32:	1101                	addi	sp,sp,-32
    80004b34:	ec06                	sd	ra,24(sp)
    80004b36:	e822                	sd	s0,16(sp)
    80004b38:	e426                	sd	s1,8(sp)
    80004b3a:	e04a                	sd	s2,0(sp)
    80004b3c:	1000                	addi	s0,sp,32
    80004b3e:	84aa                	mv	s1,a0
    80004b40:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	0a8080e7          	jalr	168(ra) # 80000bea <acquire>
  if(writable){
    80004b4a:	02090d63          	beqz	s2,80004b84 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b4e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b52:	21848513          	addi	a0,s1,536
    80004b56:	ffffd097          	auipc	ra,0xffffd
    80004b5a:	5c6080e7          	jalr	1478(ra) # 8000211c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b5e:	2204b783          	ld	a5,544(s1)
    80004b62:	eb95                	bnez	a5,80004b96 <pipeclose+0x64>
    release(&pi->lock);
    80004b64:	8526                	mv	a0,s1
    80004b66:	ffffc097          	auipc	ra,0xffffc
    80004b6a:	138080e7          	jalr	312(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004b6e:	8526                	mv	a0,s1
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	e8e080e7          	jalr	-370(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004b78:	60e2                	ld	ra,24(sp)
    80004b7a:	6442                	ld	s0,16(sp)
    80004b7c:	64a2                	ld	s1,8(sp)
    80004b7e:	6902                	ld	s2,0(sp)
    80004b80:	6105                	addi	sp,sp,32
    80004b82:	8082                	ret
    pi->readopen = 0;
    80004b84:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b88:	21c48513          	addi	a0,s1,540
    80004b8c:	ffffd097          	auipc	ra,0xffffd
    80004b90:	590080e7          	jalr	1424(ra) # 8000211c <wakeup>
    80004b94:	b7e9                	j	80004b5e <pipeclose+0x2c>
    release(&pi->lock);
    80004b96:	8526                	mv	a0,s1
    80004b98:	ffffc097          	auipc	ra,0xffffc
    80004b9c:	106080e7          	jalr	262(ra) # 80000c9e <release>
}
    80004ba0:	bfe1                	j	80004b78 <pipeclose+0x46>

0000000080004ba2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ba2:	7159                	addi	sp,sp,-112
    80004ba4:	f486                	sd	ra,104(sp)
    80004ba6:	f0a2                	sd	s0,96(sp)
    80004ba8:	eca6                	sd	s1,88(sp)
    80004baa:	e8ca                	sd	s2,80(sp)
    80004bac:	e4ce                	sd	s3,72(sp)
    80004bae:	e0d2                	sd	s4,64(sp)
    80004bb0:	fc56                	sd	s5,56(sp)
    80004bb2:	f85a                	sd	s6,48(sp)
    80004bb4:	f45e                	sd	s7,40(sp)
    80004bb6:	f062                	sd	s8,32(sp)
    80004bb8:	ec66                	sd	s9,24(sp)
    80004bba:	1880                	addi	s0,sp,112
    80004bbc:	84aa                	mv	s1,a0
    80004bbe:	8aae                	mv	s5,a1
    80004bc0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004bc2:	ffffd097          	auipc	ra,0xffffd
    80004bc6:	e04080e7          	jalr	-508(ra) # 800019c6 <myproc>
    80004bca:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004bcc:	8526                	mv	a0,s1
    80004bce:	ffffc097          	auipc	ra,0xffffc
    80004bd2:	01c080e7          	jalr	28(ra) # 80000bea <acquire>
  while(i < n){
    80004bd6:	0d405463          	blez	s4,80004c9e <pipewrite+0xfc>
    80004bda:	8ba6                	mv	s7,s1
  int i = 0;
    80004bdc:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bde:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004be0:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004be4:	21c48c13          	addi	s8,s1,540
    80004be8:	a08d                	j	80004c4a <pipewrite+0xa8>
      release(&pi->lock);
    80004bea:	8526                	mv	a0,s1
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	0b2080e7          	jalr	178(ra) # 80000c9e <release>
      return -1;
    80004bf4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bf6:	854a                	mv	a0,s2
    80004bf8:	70a6                	ld	ra,104(sp)
    80004bfa:	7406                	ld	s0,96(sp)
    80004bfc:	64e6                	ld	s1,88(sp)
    80004bfe:	6946                	ld	s2,80(sp)
    80004c00:	69a6                	ld	s3,72(sp)
    80004c02:	6a06                	ld	s4,64(sp)
    80004c04:	7ae2                	ld	s5,56(sp)
    80004c06:	7b42                	ld	s6,48(sp)
    80004c08:	7ba2                	ld	s7,40(sp)
    80004c0a:	7c02                	ld	s8,32(sp)
    80004c0c:	6ce2                	ld	s9,24(sp)
    80004c0e:	6165                	addi	sp,sp,112
    80004c10:	8082                	ret
      wakeup(&pi->nread);
    80004c12:	8566                	mv	a0,s9
    80004c14:	ffffd097          	auipc	ra,0xffffd
    80004c18:	508080e7          	jalr	1288(ra) # 8000211c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c1c:	85de                	mv	a1,s7
    80004c1e:	8562                	mv	a0,s8
    80004c20:	ffffd097          	auipc	ra,0xffffd
    80004c24:	498080e7          	jalr	1176(ra) # 800020b8 <sleep>
    80004c28:	a839                	j	80004c46 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c2a:	21c4a783          	lw	a5,540(s1)
    80004c2e:	0017871b          	addiw	a4,a5,1
    80004c32:	20e4ae23          	sw	a4,540(s1)
    80004c36:	1ff7f793          	andi	a5,a5,511
    80004c3a:	97a6                	add	a5,a5,s1
    80004c3c:	f9f44703          	lbu	a4,-97(s0)
    80004c40:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c44:	2905                	addiw	s2,s2,1
  while(i < n){
    80004c46:	05495063          	bge	s2,s4,80004c86 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004c4a:	2204a783          	lw	a5,544(s1)
    80004c4e:	dfd1                	beqz	a5,80004bea <pipewrite+0x48>
    80004c50:	854e                	mv	a0,s3
    80004c52:	ffffd097          	auipc	ra,0xffffd
    80004c56:	70e080e7          	jalr	1806(ra) # 80002360 <killed>
    80004c5a:	f941                	bnez	a0,80004bea <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c5c:	2184a783          	lw	a5,536(s1)
    80004c60:	21c4a703          	lw	a4,540(s1)
    80004c64:	2007879b          	addiw	a5,a5,512
    80004c68:	faf705e3          	beq	a4,a5,80004c12 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c6c:	4685                	li	a3,1
    80004c6e:	01590633          	add	a2,s2,s5
    80004c72:	f9f40593          	addi	a1,s0,-97
    80004c76:	0509b503          	ld	a0,80(s3)
    80004c7a:	ffffd097          	auipc	ra,0xffffd
    80004c7e:	a96080e7          	jalr	-1386(ra) # 80001710 <copyin>
    80004c82:	fb6514e3          	bne	a0,s6,80004c2a <pipewrite+0x88>
  wakeup(&pi->nread);
    80004c86:	21848513          	addi	a0,s1,536
    80004c8a:	ffffd097          	auipc	ra,0xffffd
    80004c8e:	492080e7          	jalr	1170(ra) # 8000211c <wakeup>
  release(&pi->lock);
    80004c92:	8526                	mv	a0,s1
    80004c94:	ffffc097          	auipc	ra,0xffffc
    80004c98:	00a080e7          	jalr	10(ra) # 80000c9e <release>
  return i;
    80004c9c:	bfa9                	j	80004bf6 <pipewrite+0x54>
  int i = 0;
    80004c9e:	4901                	li	s2,0
    80004ca0:	b7dd                	j	80004c86 <pipewrite+0xe4>

0000000080004ca2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ca2:	715d                	addi	sp,sp,-80
    80004ca4:	e486                	sd	ra,72(sp)
    80004ca6:	e0a2                	sd	s0,64(sp)
    80004ca8:	fc26                	sd	s1,56(sp)
    80004caa:	f84a                	sd	s2,48(sp)
    80004cac:	f44e                	sd	s3,40(sp)
    80004cae:	f052                	sd	s4,32(sp)
    80004cb0:	ec56                	sd	s5,24(sp)
    80004cb2:	e85a                	sd	s6,16(sp)
    80004cb4:	0880                	addi	s0,sp,80
    80004cb6:	84aa                	mv	s1,a0
    80004cb8:	892e                	mv	s2,a1
    80004cba:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004cbc:	ffffd097          	auipc	ra,0xffffd
    80004cc0:	d0a080e7          	jalr	-758(ra) # 800019c6 <myproc>
    80004cc4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004cc6:	8b26                	mv	s6,s1
    80004cc8:	8526                	mv	a0,s1
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	f20080e7          	jalr	-224(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cd2:	2184a703          	lw	a4,536(s1)
    80004cd6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cda:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cde:	02f71763          	bne	a4,a5,80004d0c <piperead+0x6a>
    80004ce2:	2244a783          	lw	a5,548(s1)
    80004ce6:	c39d                	beqz	a5,80004d0c <piperead+0x6a>
    if(killed(pr)){
    80004ce8:	8552                	mv	a0,s4
    80004cea:	ffffd097          	auipc	ra,0xffffd
    80004cee:	676080e7          	jalr	1654(ra) # 80002360 <killed>
    80004cf2:	e941                	bnez	a0,80004d82 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cf4:	85da                	mv	a1,s6
    80004cf6:	854e                	mv	a0,s3
    80004cf8:	ffffd097          	auipc	ra,0xffffd
    80004cfc:	3c0080e7          	jalr	960(ra) # 800020b8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d00:	2184a703          	lw	a4,536(s1)
    80004d04:	21c4a783          	lw	a5,540(s1)
    80004d08:	fcf70de3          	beq	a4,a5,80004ce2 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d0c:	09505263          	blez	s5,80004d90 <piperead+0xee>
    80004d10:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d12:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004d14:	2184a783          	lw	a5,536(s1)
    80004d18:	21c4a703          	lw	a4,540(s1)
    80004d1c:	02f70d63          	beq	a4,a5,80004d56 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d20:	0017871b          	addiw	a4,a5,1
    80004d24:	20e4ac23          	sw	a4,536(s1)
    80004d28:	1ff7f793          	andi	a5,a5,511
    80004d2c:	97a6                	add	a5,a5,s1
    80004d2e:	0187c783          	lbu	a5,24(a5)
    80004d32:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d36:	4685                	li	a3,1
    80004d38:	fbf40613          	addi	a2,s0,-65
    80004d3c:	85ca                	mv	a1,s2
    80004d3e:	050a3503          	ld	a0,80(s4)
    80004d42:	ffffd097          	auipc	ra,0xffffd
    80004d46:	942080e7          	jalr	-1726(ra) # 80001684 <copyout>
    80004d4a:	01650663          	beq	a0,s6,80004d56 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d4e:	2985                	addiw	s3,s3,1
    80004d50:	0905                	addi	s2,s2,1
    80004d52:	fd3a91e3          	bne	s5,s3,80004d14 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d56:	21c48513          	addi	a0,s1,540
    80004d5a:	ffffd097          	auipc	ra,0xffffd
    80004d5e:	3c2080e7          	jalr	962(ra) # 8000211c <wakeup>
  release(&pi->lock);
    80004d62:	8526                	mv	a0,s1
    80004d64:	ffffc097          	auipc	ra,0xffffc
    80004d68:	f3a080e7          	jalr	-198(ra) # 80000c9e <release>
  return i;
}
    80004d6c:	854e                	mv	a0,s3
    80004d6e:	60a6                	ld	ra,72(sp)
    80004d70:	6406                	ld	s0,64(sp)
    80004d72:	74e2                	ld	s1,56(sp)
    80004d74:	7942                	ld	s2,48(sp)
    80004d76:	79a2                	ld	s3,40(sp)
    80004d78:	7a02                	ld	s4,32(sp)
    80004d7a:	6ae2                	ld	s5,24(sp)
    80004d7c:	6b42                	ld	s6,16(sp)
    80004d7e:	6161                	addi	sp,sp,80
    80004d80:	8082                	ret
      release(&pi->lock);
    80004d82:	8526                	mv	a0,s1
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	f1a080e7          	jalr	-230(ra) # 80000c9e <release>
      return -1;
    80004d8c:	59fd                	li	s3,-1
    80004d8e:	bff9                	j	80004d6c <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d90:	4981                	li	s3,0
    80004d92:	b7d1                	j	80004d56 <piperead+0xb4>

0000000080004d94 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004d94:	1141                	addi	sp,sp,-16
    80004d96:	e422                	sd	s0,8(sp)
    80004d98:	0800                	addi	s0,sp,16
    80004d9a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004d9c:	8905                	andi	a0,a0,1
    80004d9e:	c111                	beqz	a0,80004da2 <flags2perm+0xe>
      perm = PTE_X;
    80004da0:	4521                	li	a0,8
    if(flags & 0x2)
    80004da2:	8b89                	andi	a5,a5,2
    80004da4:	c399                	beqz	a5,80004daa <flags2perm+0x16>
      perm |= PTE_W;
    80004da6:	00456513          	ori	a0,a0,4
    return perm;
}
    80004daa:	6422                	ld	s0,8(sp)
    80004dac:	0141                	addi	sp,sp,16
    80004dae:	8082                	ret

0000000080004db0 <exec>:

int
exec(char *path, char **argv)
{
    80004db0:	df010113          	addi	sp,sp,-528
    80004db4:	20113423          	sd	ra,520(sp)
    80004db8:	20813023          	sd	s0,512(sp)
    80004dbc:	ffa6                	sd	s1,504(sp)
    80004dbe:	fbca                	sd	s2,496(sp)
    80004dc0:	f7ce                	sd	s3,488(sp)
    80004dc2:	f3d2                	sd	s4,480(sp)
    80004dc4:	efd6                	sd	s5,472(sp)
    80004dc6:	ebda                	sd	s6,464(sp)
    80004dc8:	e7de                	sd	s7,456(sp)
    80004dca:	e3e2                	sd	s8,448(sp)
    80004dcc:	ff66                	sd	s9,440(sp)
    80004dce:	fb6a                	sd	s10,432(sp)
    80004dd0:	f76e                	sd	s11,424(sp)
    80004dd2:	0c00                	addi	s0,sp,528
    80004dd4:	84aa                	mv	s1,a0
    80004dd6:	dea43c23          	sd	a0,-520(s0)
    80004dda:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004dde:	ffffd097          	auipc	ra,0xffffd
    80004de2:	be8080e7          	jalr	-1048(ra) # 800019c6 <myproc>
    80004de6:	892a                	mv	s2,a0

  begin_op();
    80004de8:	fffff097          	auipc	ra,0xfffff
    80004dec:	474080e7          	jalr	1140(ra) # 8000425c <begin_op>

  if((ip = namei(path)) == 0){
    80004df0:	8526                	mv	a0,s1
    80004df2:	fffff097          	auipc	ra,0xfffff
    80004df6:	24e080e7          	jalr	590(ra) # 80004040 <namei>
    80004dfa:	c92d                	beqz	a0,80004e6c <exec+0xbc>
    80004dfc:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004dfe:	fffff097          	auipc	ra,0xfffff
    80004e02:	a9c080e7          	jalr	-1380(ra) # 8000389a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e06:	04000713          	li	a4,64
    80004e0a:	4681                	li	a3,0
    80004e0c:	e5040613          	addi	a2,s0,-432
    80004e10:	4581                	li	a1,0
    80004e12:	8526                	mv	a0,s1
    80004e14:	fffff097          	auipc	ra,0xfffff
    80004e18:	d3a080e7          	jalr	-710(ra) # 80003b4e <readi>
    80004e1c:	04000793          	li	a5,64
    80004e20:	00f51a63          	bne	a0,a5,80004e34 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004e24:	e5042703          	lw	a4,-432(s0)
    80004e28:	464c47b7          	lui	a5,0x464c4
    80004e2c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e30:	04f70463          	beq	a4,a5,80004e78 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e34:	8526                	mv	a0,s1
    80004e36:	fffff097          	auipc	ra,0xfffff
    80004e3a:	cc6080e7          	jalr	-826(ra) # 80003afc <iunlockput>
    end_op();
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	49e080e7          	jalr	1182(ra) # 800042dc <end_op>
  }
  return -1;
    80004e46:	557d                	li	a0,-1
}
    80004e48:	20813083          	ld	ra,520(sp)
    80004e4c:	20013403          	ld	s0,512(sp)
    80004e50:	74fe                	ld	s1,504(sp)
    80004e52:	795e                	ld	s2,496(sp)
    80004e54:	79be                	ld	s3,488(sp)
    80004e56:	7a1e                	ld	s4,480(sp)
    80004e58:	6afe                	ld	s5,472(sp)
    80004e5a:	6b5e                	ld	s6,464(sp)
    80004e5c:	6bbe                	ld	s7,456(sp)
    80004e5e:	6c1e                	ld	s8,448(sp)
    80004e60:	7cfa                	ld	s9,440(sp)
    80004e62:	7d5a                	ld	s10,432(sp)
    80004e64:	7dba                	ld	s11,424(sp)
    80004e66:	21010113          	addi	sp,sp,528
    80004e6a:	8082                	ret
    end_op();
    80004e6c:	fffff097          	auipc	ra,0xfffff
    80004e70:	470080e7          	jalr	1136(ra) # 800042dc <end_op>
    return -1;
    80004e74:	557d                	li	a0,-1
    80004e76:	bfc9                	j	80004e48 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e78:	854a                	mv	a0,s2
    80004e7a:	ffffd097          	auipc	ra,0xffffd
    80004e7e:	c10080e7          	jalr	-1008(ra) # 80001a8a <proc_pagetable>
    80004e82:	8baa                	mv	s7,a0
    80004e84:	d945                	beqz	a0,80004e34 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e86:	e7042983          	lw	s3,-400(s0)
    80004e8a:	e8845783          	lhu	a5,-376(s0)
    80004e8e:	c7ad                	beqz	a5,80004ef8 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e90:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e92:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004e94:	6c85                	lui	s9,0x1
    80004e96:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e9a:	def43823          	sd	a5,-528(s0)
    80004e9e:	ac0d                	j	800050d0 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ea0:	00004517          	auipc	a0,0x4
    80004ea4:	84050513          	addi	a0,a0,-1984 # 800086e0 <syscalls+0x290>
    80004ea8:	ffffb097          	auipc	ra,0xffffb
    80004eac:	69c080e7          	jalr	1692(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eb0:	8756                	mv	a4,s5
    80004eb2:	012d86bb          	addw	a3,s11,s2
    80004eb6:	4581                	li	a1,0
    80004eb8:	8526                	mv	a0,s1
    80004eba:	fffff097          	auipc	ra,0xfffff
    80004ebe:	c94080e7          	jalr	-876(ra) # 80003b4e <readi>
    80004ec2:	2501                	sext.w	a0,a0
    80004ec4:	1aaa9a63          	bne	s5,a0,80005078 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80004ec8:	6785                	lui	a5,0x1
    80004eca:	0127893b          	addw	s2,a5,s2
    80004ece:	77fd                	lui	a5,0xfffff
    80004ed0:	01478a3b          	addw	s4,a5,s4
    80004ed4:	1f897563          	bgeu	s2,s8,800050be <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80004ed8:	02091593          	slli	a1,s2,0x20
    80004edc:	9181                	srli	a1,a1,0x20
    80004ede:	95ea                	add	a1,a1,s10
    80004ee0:	855e                	mv	a0,s7
    80004ee2:	ffffc097          	auipc	ra,0xffffc
    80004ee6:	196080e7          	jalr	406(ra) # 80001078 <walkaddr>
    80004eea:	862a                	mv	a2,a0
    if(pa == 0)
    80004eec:	d955                	beqz	a0,80004ea0 <exec+0xf0>
      n = PGSIZE;
    80004eee:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004ef0:	fd9a70e3          	bgeu	s4,s9,80004eb0 <exec+0x100>
      n = sz - i;
    80004ef4:	8ad2                	mv	s5,s4
    80004ef6:	bf6d                	j	80004eb0 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ef8:	4a01                	li	s4,0
  iunlockput(ip);
    80004efa:	8526                	mv	a0,s1
    80004efc:	fffff097          	auipc	ra,0xfffff
    80004f00:	c00080e7          	jalr	-1024(ra) # 80003afc <iunlockput>
  end_op();
    80004f04:	fffff097          	auipc	ra,0xfffff
    80004f08:	3d8080e7          	jalr	984(ra) # 800042dc <end_op>
  p = myproc();
    80004f0c:	ffffd097          	auipc	ra,0xffffd
    80004f10:	aba080e7          	jalr	-1350(ra) # 800019c6 <myproc>
    80004f14:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f16:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f1a:	6785                	lui	a5,0x1
    80004f1c:	17fd                	addi	a5,a5,-1
    80004f1e:	9a3e                	add	s4,s4,a5
    80004f20:	757d                	lui	a0,0xfffff
    80004f22:	00aa77b3          	and	a5,s4,a0
    80004f26:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f2a:	4691                	li	a3,4
    80004f2c:	6609                	lui	a2,0x2
    80004f2e:	963e                	add	a2,a2,a5
    80004f30:	85be                	mv	a1,a5
    80004f32:	855e                	mv	a0,s7
    80004f34:	ffffc097          	auipc	ra,0xffffc
    80004f38:	4f8080e7          	jalr	1272(ra) # 8000142c <uvmalloc>
    80004f3c:	8b2a                	mv	s6,a0
  ip = 0;
    80004f3e:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f40:	12050c63          	beqz	a0,80005078 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f44:	75f9                	lui	a1,0xffffe
    80004f46:	95aa                	add	a1,a1,a0
    80004f48:	855e                	mv	a0,s7
    80004f4a:	ffffc097          	auipc	ra,0xffffc
    80004f4e:	708080e7          	jalr	1800(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f52:	7c7d                	lui	s8,0xfffff
    80004f54:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f56:	e0043783          	ld	a5,-512(s0)
    80004f5a:	6388                	ld	a0,0(a5)
    80004f5c:	c535                	beqz	a0,80004fc8 <exec+0x218>
    80004f5e:	e9040993          	addi	s3,s0,-368
    80004f62:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f66:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004f68:	ffffc097          	auipc	ra,0xffffc
    80004f6c:	f02080e7          	jalr	-254(ra) # 80000e6a <strlen>
    80004f70:	2505                	addiw	a0,a0,1
    80004f72:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f76:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f7a:	13896663          	bltu	s2,s8,800050a6 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f7e:	e0043d83          	ld	s11,-512(s0)
    80004f82:	000dba03          	ld	s4,0(s11)
    80004f86:	8552                	mv	a0,s4
    80004f88:	ffffc097          	auipc	ra,0xffffc
    80004f8c:	ee2080e7          	jalr	-286(ra) # 80000e6a <strlen>
    80004f90:	0015069b          	addiw	a3,a0,1
    80004f94:	8652                	mv	a2,s4
    80004f96:	85ca                	mv	a1,s2
    80004f98:	855e                	mv	a0,s7
    80004f9a:	ffffc097          	auipc	ra,0xffffc
    80004f9e:	6ea080e7          	jalr	1770(ra) # 80001684 <copyout>
    80004fa2:	10054663          	bltz	a0,800050ae <exec+0x2fe>
    ustack[argc] = sp;
    80004fa6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004faa:	0485                	addi	s1,s1,1
    80004fac:	008d8793          	addi	a5,s11,8
    80004fb0:	e0f43023          	sd	a5,-512(s0)
    80004fb4:	008db503          	ld	a0,8(s11)
    80004fb8:	c911                	beqz	a0,80004fcc <exec+0x21c>
    if(argc >= MAXARG)
    80004fba:	09a1                	addi	s3,s3,8
    80004fbc:	fb3c96e3          	bne	s9,s3,80004f68 <exec+0x1b8>
  sz = sz1;
    80004fc0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fc4:	4481                	li	s1,0
    80004fc6:	a84d                	j	80005078 <exec+0x2c8>
  sp = sz;
    80004fc8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fca:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fcc:	00349793          	slli	a5,s1,0x3
    80004fd0:	f9040713          	addi	a4,s0,-112
    80004fd4:	97ba                	add	a5,a5,a4
    80004fd6:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80004fda:	00148693          	addi	a3,s1,1
    80004fde:	068e                	slli	a3,a3,0x3
    80004fe0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004fe4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004fe8:	01897663          	bgeu	s2,s8,80004ff4 <exec+0x244>
  sz = sz1;
    80004fec:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ff0:	4481                	li	s1,0
    80004ff2:	a059                	j	80005078 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ff4:	e9040613          	addi	a2,s0,-368
    80004ff8:	85ca                	mv	a1,s2
    80004ffa:	855e                	mv	a0,s7
    80004ffc:	ffffc097          	auipc	ra,0xffffc
    80005000:	688080e7          	jalr	1672(ra) # 80001684 <copyout>
    80005004:	0a054963          	bltz	a0,800050b6 <exec+0x306>
  p->trapframe->a1 = sp;
    80005008:	058ab783          	ld	a5,88(s5)
    8000500c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005010:	df843783          	ld	a5,-520(s0)
    80005014:	0007c703          	lbu	a4,0(a5)
    80005018:	cf11                	beqz	a4,80005034 <exec+0x284>
    8000501a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000501c:	02f00693          	li	a3,47
    80005020:	a039                	j	8000502e <exec+0x27e>
      last = s+1;
    80005022:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005026:	0785                	addi	a5,a5,1
    80005028:	fff7c703          	lbu	a4,-1(a5)
    8000502c:	c701                	beqz	a4,80005034 <exec+0x284>
    if(*s == '/')
    8000502e:	fed71ce3          	bne	a4,a3,80005026 <exec+0x276>
    80005032:	bfc5                	j	80005022 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80005034:	4641                	li	a2,16
    80005036:	df843583          	ld	a1,-520(s0)
    8000503a:	158a8513          	addi	a0,s5,344
    8000503e:	ffffc097          	auipc	ra,0xffffc
    80005042:	dfa080e7          	jalr	-518(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    80005046:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000504a:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    8000504e:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005052:	058ab783          	ld	a5,88(s5)
    80005056:	e6843703          	ld	a4,-408(s0)
    8000505a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000505c:	058ab783          	ld	a5,88(s5)
    80005060:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005064:	85ea                	mv	a1,s10
    80005066:	ffffd097          	auipc	ra,0xffffd
    8000506a:	ac0080e7          	jalr	-1344(ra) # 80001b26 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000506e:	0004851b          	sext.w	a0,s1
    80005072:	bbd9                	j	80004e48 <exec+0x98>
    80005074:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005078:	e0843583          	ld	a1,-504(s0)
    8000507c:	855e                	mv	a0,s7
    8000507e:	ffffd097          	auipc	ra,0xffffd
    80005082:	aa8080e7          	jalr	-1368(ra) # 80001b26 <proc_freepagetable>
  if(ip){
    80005086:	da0497e3          	bnez	s1,80004e34 <exec+0x84>
  return -1;
    8000508a:	557d                	li	a0,-1
    8000508c:	bb75                	j	80004e48 <exec+0x98>
    8000508e:	e1443423          	sd	s4,-504(s0)
    80005092:	b7dd                	j	80005078 <exec+0x2c8>
    80005094:	e1443423          	sd	s4,-504(s0)
    80005098:	b7c5                	j	80005078 <exec+0x2c8>
    8000509a:	e1443423          	sd	s4,-504(s0)
    8000509e:	bfe9                	j	80005078 <exec+0x2c8>
    800050a0:	e1443423          	sd	s4,-504(s0)
    800050a4:	bfd1                	j	80005078 <exec+0x2c8>
  sz = sz1;
    800050a6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050aa:	4481                	li	s1,0
    800050ac:	b7f1                	j	80005078 <exec+0x2c8>
  sz = sz1;
    800050ae:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050b2:	4481                	li	s1,0
    800050b4:	b7d1                	j	80005078 <exec+0x2c8>
  sz = sz1;
    800050b6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050ba:	4481                	li	s1,0
    800050bc:	bf75                	j	80005078 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050be:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050c2:	2b05                	addiw	s6,s6,1
    800050c4:	0389899b          	addiw	s3,s3,56
    800050c8:	e8845783          	lhu	a5,-376(s0)
    800050cc:	e2fb57e3          	bge	s6,a5,80004efa <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050d0:	2981                	sext.w	s3,s3
    800050d2:	03800713          	li	a4,56
    800050d6:	86ce                	mv	a3,s3
    800050d8:	e1840613          	addi	a2,s0,-488
    800050dc:	4581                	li	a1,0
    800050de:	8526                	mv	a0,s1
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	a6e080e7          	jalr	-1426(ra) # 80003b4e <readi>
    800050e8:	03800793          	li	a5,56
    800050ec:	f8f514e3          	bne	a0,a5,80005074 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800050f0:	e1842783          	lw	a5,-488(s0)
    800050f4:	4705                	li	a4,1
    800050f6:	fce796e3          	bne	a5,a4,800050c2 <exec+0x312>
    if(ph.memsz < ph.filesz)
    800050fa:	e4043903          	ld	s2,-448(s0)
    800050fe:	e3843783          	ld	a5,-456(s0)
    80005102:	f8f966e3          	bltu	s2,a5,8000508e <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005106:	e2843783          	ld	a5,-472(s0)
    8000510a:	993e                	add	s2,s2,a5
    8000510c:	f8f964e3          	bltu	s2,a5,80005094 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005110:	df043703          	ld	a4,-528(s0)
    80005114:	8ff9                	and	a5,a5,a4
    80005116:	f3d1                	bnez	a5,8000509a <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005118:	e1c42503          	lw	a0,-484(s0)
    8000511c:	00000097          	auipc	ra,0x0
    80005120:	c78080e7          	jalr	-904(ra) # 80004d94 <flags2perm>
    80005124:	86aa                	mv	a3,a0
    80005126:	864a                	mv	a2,s2
    80005128:	85d2                	mv	a1,s4
    8000512a:	855e                	mv	a0,s7
    8000512c:	ffffc097          	auipc	ra,0xffffc
    80005130:	300080e7          	jalr	768(ra) # 8000142c <uvmalloc>
    80005134:	e0a43423          	sd	a0,-504(s0)
    80005138:	d525                	beqz	a0,800050a0 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000513a:	e2843d03          	ld	s10,-472(s0)
    8000513e:	e2042d83          	lw	s11,-480(s0)
    80005142:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005146:	f60c0ce3          	beqz	s8,800050be <exec+0x30e>
    8000514a:	8a62                	mv	s4,s8
    8000514c:	4901                	li	s2,0
    8000514e:	b369                	j	80004ed8 <exec+0x128>

0000000080005150 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005150:	7179                	addi	sp,sp,-48
    80005152:	f406                	sd	ra,40(sp)
    80005154:	f022                	sd	s0,32(sp)
    80005156:	ec26                	sd	s1,24(sp)
    80005158:	e84a                	sd	s2,16(sp)
    8000515a:	1800                	addi	s0,sp,48
    8000515c:	892e                	mv	s2,a1
    8000515e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005160:	fdc40593          	addi	a1,s0,-36
    80005164:	ffffe097          	auipc	ra,0xffffe
    80005168:	ae4080e7          	jalr	-1308(ra) # 80002c48 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000516c:	fdc42703          	lw	a4,-36(s0)
    80005170:	47bd                	li	a5,15
    80005172:	02e7eb63          	bltu	a5,a4,800051a8 <argfd+0x58>
    80005176:	ffffd097          	auipc	ra,0xffffd
    8000517a:	850080e7          	jalr	-1968(ra) # 800019c6 <myproc>
    8000517e:	fdc42703          	lw	a4,-36(s0)
    80005182:	01a70793          	addi	a5,a4,26
    80005186:	078e                	slli	a5,a5,0x3
    80005188:	953e                	add	a0,a0,a5
    8000518a:	611c                	ld	a5,0(a0)
    8000518c:	c385                	beqz	a5,800051ac <argfd+0x5c>
    return -1;
  if(pfd)
    8000518e:	00090463          	beqz	s2,80005196 <argfd+0x46>
    *pfd = fd;
    80005192:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005196:	4501                	li	a0,0
  if(pf)
    80005198:	c091                	beqz	s1,8000519c <argfd+0x4c>
    *pf = f;
    8000519a:	e09c                	sd	a5,0(s1)
}
    8000519c:	70a2                	ld	ra,40(sp)
    8000519e:	7402                	ld	s0,32(sp)
    800051a0:	64e2                	ld	s1,24(sp)
    800051a2:	6942                	ld	s2,16(sp)
    800051a4:	6145                	addi	sp,sp,48
    800051a6:	8082                	ret
    return -1;
    800051a8:	557d                	li	a0,-1
    800051aa:	bfcd                	j	8000519c <argfd+0x4c>
    800051ac:	557d                	li	a0,-1
    800051ae:	b7fd                	j	8000519c <argfd+0x4c>

00000000800051b0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051b0:	1101                	addi	sp,sp,-32
    800051b2:	ec06                	sd	ra,24(sp)
    800051b4:	e822                	sd	s0,16(sp)
    800051b6:	e426                	sd	s1,8(sp)
    800051b8:	1000                	addi	s0,sp,32
    800051ba:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051bc:	ffffd097          	auipc	ra,0xffffd
    800051c0:	80a080e7          	jalr	-2038(ra) # 800019c6 <myproc>
    800051c4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051c6:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdd360>
    800051ca:	4501                	li	a0,0
    800051cc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051ce:	6398                	ld	a4,0(a5)
    800051d0:	cb19                	beqz	a4,800051e6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800051d2:	2505                	addiw	a0,a0,1
    800051d4:	07a1                	addi	a5,a5,8
    800051d6:	fed51ce3          	bne	a0,a3,800051ce <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051da:	557d                	li	a0,-1
}
    800051dc:	60e2                	ld	ra,24(sp)
    800051de:	6442                	ld	s0,16(sp)
    800051e0:	64a2                	ld	s1,8(sp)
    800051e2:	6105                	addi	sp,sp,32
    800051e4:	8082                	ret
      p->ofile[fd] = f;
    800051e6:	01a50793          	addi	a5,a0,26
    800051ea:	078e                	slli	a5,a5,0x3
    800051ec:	963e                	add	a2,a2,a5
    800051ee:	e204                	sd	s1,0(a2)
      return fd;
    800051f0:	b7f5                	j	800051dc <fdalloc+0x2c>

00000000800051f2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051f2:	715d                	addi	sp,sp,-80
    800051f4:	e486                	sd	ra,72(sp)
    800051f6:	e0a2                	sd	s0,64(sp)
    800051f8:	fc26                	sd	s1,56(sp)
    800051fa:	f84a                	sd	s2,48(sp)
    800051fc:	f44e                	sd	s3,40(sp)
    800051fe:	f052                	sd	s4,32(sp)
    80005200:	ec56                	sd	s5,24(sp)
    80005202:	e85a                	sd	s6,16(sp)
    80005204:	0880                	addi	s0,sp,80
    80005206:	8b2e                	mv	s6,a1
    80005208:	89b2                	mv	s3,a2
    8000520a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000520c:	fb040593          	addi	a1,s0,-80
    80005210:	fffff097          	auipc	ra,0xfffff
    80005214:	e4e080e7          	jalr	-434(ra) # 8000405e <nameiparent>
    80005218:	84aa                	mv	s1,a0
    8000521a:	16050063          	beqz	a0,8000537a <create+0x188>
    return 0;

  ilock(dp);
    8000521e:	ffffe097          	auipc	ra,0xffffe
    80005222:	67c080e7          	jalr	1660(ra) # 8000389a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005226:	4601                	li	a2,0
    80005228:	fb040593          	addi	a1,s0,-80
    8000522c:	8526                	mv	a0,s1
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	b50080e7          	jalr	-1200(ra) # 80003d7e <dirlookup>
    80005236:	8aaa                	mv	s5,a0
    80005238:	c931                	beqz	a0,8000528c <create+0x9a>
    iunlockput(dp);
    8000523a:	8526                	mv	a0,s1
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	8c0080e7          	jalr	-1856(ra) # 80003afc <iunlockput>
    ilock(ip);
    80005244:	8556                	mv	a0,s5
    80005246:	ffffe097          	auipc	ra,0xffffe
    8000524a:	654080e7          	jalr	1620(ra) # 8000389a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000524e:	000b059b          	sext.w	a1,s6
    80005252:	4789                	li	a5,2
    80005254:	02f59563          	bne	a1,a5,8000527e <create+0x8c>
    80005258:	044ad783          	lhu	a5,68(s5)
    8000525c:	37f9                	addiw	a5,a5,-2
    8000525e:	17c2                	slli	a5,a5,0x30
    80005260:	93c1                	srli	a5,a5,0x30
    80005262:	4705                	li	a4,1
    80005264:	00f76d63          	bltu	a4,a5,8000527e <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005268:	8556                	mv	a0,s5
    8000526a:	60a6                	ld	ra,72(sp)
    8000526c:	6406                	ld	s0,64(sp)
    8000526e:	74e2                	ld	s1,56(sp)
    80005270:	7942                	ld	s2,48(sp)
    80005272:	79a2                	ld	s3,40(sp)
    80005274:	7a02                	ld	s4,32(sp)
    80005276:	6ae2                	ld	s5,24(sp)
    80005278:	6b42                	ld	s6,16(sp)
    8000527a:	6161                	addi	sp,sp,80
    8000527c:	8082                	ret
    iunlockput(ip);
    8000527e:	8556                	mv	a0,s5
    80005280:	fffff097          	auipc	ra,0xfffff
    80005284:	87c080e7          	jalr	-1924(ra) # 80003afc <iunlockput>
    return 0;
    80005288:	4a81                	li	s5,0
    8000528a:	bff9                	j	80005268 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000528c:	85da                	mv	a1,s6
    8000528e:	4088                	lw	a0,0(s1)
    80005290:	ffffe097          	auipc	ra,0xffffe
    80005294:	46e080e7          	jalr	1134(ra) # 800036fe <ialloc>
    80005298:	8a2a                	mv	s4,a0
    8000529a:	c921                	beqz	a0,800052ea <create+0xf8>
  ilock(ip);
    8000529c:	ffffe097          	auipc	ra,0xffffe
    800052a0:	5fe080e7          	jalr	1534(ra) # 8000389a <ilock>
  ip->major = major;
    800052a4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800052a8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800052ac:	4785                	li	a5,1
    800052ae:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800052b2:	8552                	mv	a0,s4
    800052b4:	ffffe097          	auipc	ra,0xffffe
    800052b8:	51c080e7          	jalr	1308(ra) # 800037d0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052bc:	000b059b          	sext.w	a1,s6
    800052c0:	4785                	li	a5,1
    800052c2:	02f58b63          	beq	a1,a5,800052f8 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800052c6:	004a2603          	lw	a2,4(s4)
    800052ca:	fb040593          	addi	a1,s0,-80
    800052ce:	8526                	mv	a0,s1
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	cbe080e7          	jalr	-834(ra) # 80003f8e <dirlink>
    800052d8:	06054f63          	bltz	a0,80005356 <create+0x164>
  iunlockput(dp);
    800052dc:	8526                	mv	a0,s1
    800052de:	fffff097          	auipc	ra,0xfffff
    800052e2:	81e080e7          	jalr	-2018(ra) # 80003afc <iunlockput>
  return ip;
    800052e6:	8ad2                	mv	s5,s4
    800052e8:	b741                	j	80005268 <create+0x76>
    iunlockput(dp);
    800052ea:	8526                	mv	a0,s1
    800052ec:	fffff097          	auipc	ra,0xfffff
    800052f0:	810080e7          	jalr	-2032(ra) # 80003afc <iunlockput>
    return 0;
    800052f4:	8ad2                	mv	s5,s4
    800052f6:	bf8d                	j	80005268 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052f8:	004a2603          	lw	a2,4(s4)
    800052fc:	00003597          	auipc	a1,0x3
    80005300:	40458593          	addi	a1,a1,1028 # 80008700 <syscalls+0x2b0>
    80005304:	8552                	mv	a0,s4
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	c88080e7          	jalr	-888(ra) # 80003f8e <dirlink>
    8000530e:	04054463          	bltz	a0,80005356 <create+0x164>
    80005312:	40d0                	lw	a2,4(s1)
    80005314:	00003597          	auipc	a1,0x3
    80005318:	3f458593          	addi	a1,a1,1012 # 80008708 <syscalls+0x2b8>
    8000531c:	8552                	mv	a0,s4
    8000531e:	fffff097          	auipc	ra,0xfffff
    80005322:	c70080e7          	jalr	-912(ra) # 80003f8e <dirlink>
    80005326:	02054863          	bltz	a0,80005356 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    8000532a:	004a2603          	lw	a2,4(s4)
    8000532e:	fb040593          	addi	a1,s0,-80
    80005332:	8526                	mv	a0,s1
    80005334:	fffff097          	auipc	ra,0xfffff
    80005338:	c5a080e7          	jalr	-934(ra) # 80003f8e <dirlink>
    8000533c:	00054d63          	bltz	a0,80005356 <create+0x164>
    dp->nlink++;  // for ".."
    80005340:	04a4d783          	lhu	a5,74(s1)
    80005344:	2785                	addiw	a5,a5,1
    80005346:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000534a:	8526                	mv	a0,s1
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	484080e7          	jalr	1156(ra) # 800037d0 <iupdate>
    80005354:	b761                	j	800052dc <create+0xea>
  ip->nlink = 0;
    80005356:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000535a:	8552                	mv	a0,s4
    8000535c:	ffffe097          	auipc	ra,0xffffe
    80005360:	474080e7          	jalr	1140(ra) # 800037d0 <iupdate>
  iunlockput(ip);
    80005364:	8552                	mv	a0,s4
    80005366:	ffffe097          	auipc	ra,0xffffe
    8000536a:	796080e7          	jalr	1942(ra) # 80003afc <iunlockput>
  iunlockput(dp);
    8000536e:	8526                	mv	a0,s1
    80005370:	ffffe097          	auipc	ra,0xffffe
    80005374:	78c080e7          	jalr	1932(ra) # 80003afc <iunlockput>
  return 0;
    80005378:	bdc5                	j	80005268 <create+0x76>
    return 0;
    8000537a:	8aaa                	mv	s5,a0
    8000537c:	b5f5                	j	80005268 <create+0x76>

000000008000537e <sys_dup>:
{
    8000537e:	7179                	addi	sp,sp,-48
    80005380:	f406                	sd	ra,40(sp)
    80005382:	f022                	sd	s0,32(sp)
    80005384:	ec26                	sd	s1,24(sp)
    80005386:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005388:	fd840613          	addi	a2,s0,-40
    8000538c:	4581                	li	a1,0
    8000538e:	4501                	li	a0,0
    80005390:	00000097          	auipc	ra,0x0
    80005394:	dc0080e7          	jalr	-576(ra) # 80005150 <argfd>
    return -1;
    80005398:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000539a:	02054363          	bltz	a0,800053c0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000539e:	fd843503          	ld	a0,-40(s0)
    800053a2:	00000097          	auipc	ra,0x0
    800053a6:	e0e080e7          	jalr	-498(ra) # 800051b0 <fdalloc>
    800053aa:	84aa                	mv	s1,a0
    return -1;
    800053ac:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053ae:	00054963          	bltz	a0,800053c0 <sys_dup+0x42>
  filedup(f);
    800053b2:	fd843503          	ld	a0,-40(s0)
    800053b6:	fffff097          	auipc	ra,0xfffff
    800053ba:	320080e7          	jalr	800(ra) # 800046d6 <filedup>
  return fd;
    800053be:	87a6                	mv	a5,s1
}
    800053c0:	853e                	mv	a0,a5
    800053c2:	70a2                	ld	ra,40(sp)
    800053c4:	7402                	ld	s0,32(sp)
    800053c6:	64e2                	ld	s1,24(sp)
    800053c8:	6145                	addi	sp,sp,48
    800053ca:	8082                	ret

00000000800053cc <sys_read>:
{
    800053cc:	7179                	addi	sp,sp,-48
    800053ce:	f406                	sd	ra,40(sp)
    800053d0:	f022                	sd	s0,32(sp)
    800053d2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053d4:	fd840593          	addi	a1,s0,-40
    800053d8:	4505                	li	a0,1
    800053da:	ffffe097          	auipc	ra,0xffffe
    800053de:	88e080e7          	jalr	-1906(ra) # 80002c68 <argaddr>
  argint(2, &n);
    800053e2:	fe440593          	addi	a1,s0,-28
    800053e6:	4509                	li	a0,2
    800053e8:	ffffe097          	auipc	ra,0xffffe
    800053ec:	860080e7          	jalr	-1952(ra) # 80002c48 <argint>
  if(argfd(0, 0, &f) < 0)
    800053f0:	fe840613          	addi	a2,s0,-24
    800053f4:	4581                	li	a1,0
    800053f6:	4501                	li	a0,0
    800053f8:	00000097          	auipc	ra,0x0
    800053fc:	d58080e7          	jalr	-680(ra) # 80005150 <argfd>
    80005400:	87aa                	mv	a5,a0
    return -1;
    80005402:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005404:	0007cc63          	bltz	a5,8000541c <sys_read+0x50>
  return fileread(f, p, n);
    80005408:	fe442603          	lw	a2,-28(s0)
    8000540c:	fd843583          	ld	a1,-40(s0)
    80005410:	fe843503          	ld	a0,-24(s0)
    80005414:	fffff097          	auipc	ra,0xfffff
    80005418:	44e080e7          	jalr	1102(ra) # 80004862 <fileread>
}
    8000541c:	70a2                	ld	ra,40(sp)
    8000541e:	7402                	ld	s0,32(sp)
    80005420:	6145                	addi	sp,sp,48
    80005422:	8082                	ret

0000000080005424 <sys_write>:
{
    80005424:	7179                	addi	sp,sp,-48
    80005426:	f406                	sd	ra,40(sp)
    80005428:	f022                	sd	s0,32(sp)
    8000542a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000542c:	fd840593          	addi	a1,s0,-40
    80005430:	4505                	li	a0,1
    80005432:	ffffe097          	auipc	ra,0xffffe
    80005436:	836080e7          	jalr	-1994(ra) # 80002c68 <argaddr>
  argint(2, &n);
    8000543a:	fe440593          	addi	a1,s0,-28
    8000543e:	4509                	li	a0,2
    80005440:	ffffe097          	auipc	ra,0xffffe
    80005444:	808080e7          	jalr	-2040(ra) # 80002c48 <argint>
  if(argfd(0, 0, &f) < 0)
    80005448:	fe840613          	addi	a2,s0,-24
    8000544c:	4581                	li	a1,0
    8000544e:	4501                	li	a0,0
    80005450:	00000097          	auipc	ra,0x0
    80005454:	d00080e7          	jalr	-768(ra) # 80005150 <argfd>
    80005458:	87aa                	mv	a5,a0
    return -1;
    8000545a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000545c:	0007cc63          	bltz	a5,80005474 <sys_write+0x50>
  return filewrite(f, p, n);
    80005460:	fe442603          	lw	a2,-28(s0)
    80005464:	fd843583          	ld	a1,-40(s0)
    80005468:	fe843503          	ld	a0,-24(s0)
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	4b8080e7          	jalr	1208(ra) # 80004924 <filewrite>
}
    80005474:	70a2                	ld	ra,40(sp)
    80005476:	7402                	ld	s0,32(sp)
    80005478:	6145                	addi	sp,sp,48
    8000547a:	8082                	ret

000000008000547c <sys_close>:
{
    8000547c:	1101                	addi	sp,sp,-32
    8000547e:	ec06                	sd	ra,24(sp)
    80005480:	e822                	sd	s0,16(sp)
    80005482:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005484:	fe040613          	addi	a2,s0,-32
    80005488:	fec40593          	addi	a1,s0,-20
    8000548c:	4501                	li	a0,0
    8000548e:	00000097          	auipc	ra,0x0
    80005492:	cc2080e7          	jalr	-830(ra) # 80005150 <argfd>
    return -1;
    80005496:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005498:	02054463          	bltz	a0,800054c0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000549c:	ffffc097          	auipc	ra,0xffffc
    800054a0:	52a080e7          	jalr	1322(ra) # 800019c6 <myproc>
    800054a4:	fec42783          	lw	a5,-20(s0)
    800054a8:	07e9                	addi	a5,a5,26
    800054aa:	078e                	slli	a5,a5,0x3
    800054ac:	97aa                	add	a5,a5,a0
    800054ae:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800054b2:	fe043503          	ld	a0,-32(s0)
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	272080e7          	jalr	626(ra) # 80004728 <fileclose>
  return 0;
    800054be:	4781                	li	a5,0
}
    800054c0:	853e                	mv	a0,a5
    800054c2:	60e2                	ld	ra,24(sp)
    800054c4:	6442                	ld	s0,16(sp)
    800054c6:	6105                	addi	sp,sp,32
    800054c8:	8082                	ret

00000000800054ca <sys_fstat>:
{
    800054ca:	1101                	addi	sp,sp,-32
    800054cc:	ec06                	sd	ra,24(sp)
    800054ce:	e822                	sd	s0,16(sp)
    800054d0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800054d2:	fe040593          	addi	a1,s0,-32
    800054d6:	4505                	li	a0,1
    800054d8:	ffffd097          	auipc	ra,0xffffd
    800054dc:	790080e7          	jalr	1936(ra) # 80002c68 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800054e0:	fe840613          	addi	a2,s0,-24
    800054e4:	4581                	li	a1,0
    800054e6:	4501                	li	a0,0
    800054e8:	00000097          	auipc	ra,0x0
    800054ec:	c68080e7          	jalr	-920(ra) # 80005150 <argfd>
    800054f0:	87aa                	mv	a5,a0
    return -1;
    800054f2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054f4:	0007ca63          	bltz	a5,80005508 <sys_fstat+0x3e>
  return filestat(f, st);
    800054f8:	fe043583          	ld	a1,-32(s0)
    800054fc:	fe843503          	ld	a0,-24(s0)
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	2f0080e7          	jalr	752(ra) # 800047f0 <filestat>
}
    80005508:	60e2                	ld	ra,24(sp)
    8000550a:	6442                	ld	s0,16(sp)
    8000550c:	6105                	addi	sp,sp,32
    8000550e:	8082                	ret

0000000080005510 <sys_link>:
{
    80005510:	7169                	addi	sp,sp,-304
    80005512:	f606                	sd	ra,296(sp)
    80005514:	f222                	sd	s0,288(sp)
    80005516:	ee26                	sd	s1,280(sp)
    80005518:	ea4a                	sd	s2,272(sp)
    8000551a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000551c:	08000613          	li	a2,128
    80005520:	ed040593          	addi	a1,s0,-304
    80005524:	4501                	li	a0,0
    80005526:	ffffd097          	auipc	ra,0xffffd
    8000552a:	762080e7          	jalr	1890(ra) # 80002c88 <argstr>
    return -1;
    8000552e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005530:	10054e63          	bltz	a0,8000564c <sys_link+0x13c>
    80005534:	08000613          	li	a2,128
    80005538:	f5040593          	addi	a1,s0,-176
    8000553c:	4505                	li	a0,1
    8000553e:	ffffd097          	auipc	ra,0xffffd
    80005542:	74a080e7          	jalr	1866(ra) # 80002c88 <argstr>
    return -1;
    80005546:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005548:	10054263          	bltz	a0,8000564c <sys_link+0x13c>
  begin_op();
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	d10080e7          	jalr	-752(ra) # 8000425c <begin_op>
  if((ip = namei(old)) == 0){
    80005554:	ed040513          	addi	a0,s0,-304
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	ae8080e7          	jalr	-1304(ra) # 80004040 <namei>
    80005560:	84aa                	mv	s1,a0
    80005562:	c551                	beqz	a0,800055ee <sys_link+0xde>
  ilock(ip);
    80005564:	ffffe097          	auipc	ra,0xffffe
    80005568:	336080e7          	jalr	822(ra) # 8000389a <ilock>
  if(ip->type == T_DIR){
    8000556c:	04449703          	lh	a4,68(s1)
    80005570:	4785                	li	a5,1
    80005572:	08f70463          	beq	a4,a5,800055fa <sys_link+0xea>
  ip->nlink++;
    80005576:	04a4d783          	lhu	a5,74(s1)
    8000557a:	2785                	addiw	a5,a5,1
    8000557c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005580:	8526                	mv	a0,s1
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	24e080e7          	jalr	590(ra) # 800037d0 <iupdate>
  iunlock(ip);
    8000558a:	8526                	mv	a0,s1
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	3d0080e7          	jalr	976(ra) # 8000395c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005594:	fd040593          	addi	a1,s0,-48
    80005598:	f5040513          	addi	a0,s0,-176
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	ac2080e7          	jalr	-1342(ra) # 8000405e <nameiparent>
    800055a4:	892a                	mv	s2,a0
    800055a6:	c935                	beqz	a0,8000561a <sys_link+0x10a>
  ilock(dp);
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	2f2080e7          	jalr	754(ra) # 8000389a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055b0:	00092703          	lw	a4,0(s2)
    800055b4:	409c                	lw	a5,0(s1)
    800055b6:	04f71d63          	bne	a4,a5,80005610 <sys_link+0x100>
    800055ba:	40d0                	lw	a2,4(s1)
    800055bc:	fd040593          	addi	a1,s0,-48
    800055c0:	854a                	mv	a0,s2
    800055c2:	fffff097          	auipc	ra,0xfffff
    800055c6:	9cc080e7          	jalr	-1588(ra) # 80003f8e <dirlink>
    800055ca:	04054363          	bltz	a0,80005610 <sys_link+0x100>
  iunlockput(dp);
    800055ce:	854a                	mv	a0,s2
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	52c080e7          	jalr	1324(ra) # 80003afc <iunlockput>
  iput(ip);
    800055d8:	8526                	mv	a0,s1
    800055da:	ffffe097          	auipc	ra,0xffffe
    800055de:	47a080e7          	jalr	1146(ra) # 80003a54 <iput>
  end_op();
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	cfa080e7          	jalr	-774(ra) # 800042dc <end_op>
  return 0;
    800055ea:	4781                	li	a5,0
    800055ec:	a085                	j	8000564c <sys_link+0x13c>
    end_op();
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	cee080e7          	jalr	-786(ra) # 800042dc <end_op>
    return -1;
    800055f6:	57fd                	li	a5,-1
    800055f8:	a891                	j	8000564c <sys_link+0x13c>
    iunlockput(ip);
    800055fa:	8526                	mv	a0,s1
    800055fc:	ffffe097          	auipc	ra,0xffffe
    80005600:	500080e7          	jalr	1280(ra) # 80003afc <iunlockput>
    end_op();
    80005604:	fffff097          	auipc	ra,0xfffff
    80005608:	cd8080e7          	jalr	-808(ra) # 800042dc <end_op>
    return -1;
    8000560c:	57fd                	li	a5,-1
    8000560e:	a83d                	j	8000564c <sys_link+0x13c>
    iunlockput(dp);
    80005610:	854a                	mv	a0,s2
    80005612:	ffffe097          	auipc	ra,0xffffe
    80005616:	4ea080e7          	jalr	1258(ra) # 80003afc <iunlockput>
  ilock(ip);
    8000561a:	8526                	mv	a0,s1
    8000561c:	ffffe097          	auipc	ra,0xffffe
    80005620:	27e080e7          	jalr	638(ra) # 8000389a <ilock>
  ip->nlink--;
    80005624:	04a4d783          	lhu	a5,74(s1)
    80005628:	37fd                	addiw	a5,a5,-1
    8000562a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000562e:	8526                	mv	a0,s1
    80005630:	ffffe097          	auipc	ra,0xffffe
    80005634:	1a0080e7          	jalr	416(ra) # 800037d0 <iupdate>
  iunlockput(ip);
    80005638:	8526                	mv	a0,s1
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	4c2080e7          	jalr	1218(ra) # 80003afc <iunlockput>
  end_op();
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	c9a080e7          	jalr	-870(ra) # 800042dc <end_op>
  return -1;
    8000564a:	57fd                	li	a5,-1
}
    8000564c:	853e                	mv	a0,a5
    8000564e:	70b2                	ld	ra,296(sp)
    80005650:	7412                	ld	s0,288(sp)
    80005652:	64f2                	ld	s1,280(sp)
    80005654:	6952                	ld	s2,272(sp)
    80005656:	6155                	addi	sp,sp,304
    80005658:	8082                	ret

000000008000565a <sys_unlink>:
{
    8000565a:	7151                	addi	sp,sp,-240
    8000565c:	f586                	sd	ra,232(sp)
    8000565e:	f1a2                	sd	s0,224(sp)
    80005660:	eda6                	sd	s1,216(sp)
    80005662:	e9ca                	sd	s2,208(sp)
    80005664:	e5ce                	sd	s3,200(sp)
    80005666:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005668:	08000613          	li	a2,128
    8000566c:	f3040593          	addi	a1,s0,-208
    80005670:	4501                	li	a0,0
    80005672:	ffffd097          	auipc	ra,0xffffd
    80005676:	616080e7          	jalr	1558(ra) # 80002c88 <argstr>
    8000567a:	18054163          	bltz	a0,800057fc <sys_unlink+0x1a2>
  begin_op();
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	bde080e7          	jalr	-1058(ra) # 8000425c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005686:	fb040593          	addi	a1,s0,-80
    8000568a:	f3040513          	addi	a0,s0,-208
    8000568e:	fffff097          	auipc	ra,0xfffff
    80005692:	9d0080e7          	jalr	-1584(ra) # 8000405e <nameiparent>
    80005696:	84aa                	mv	s1,a0
    80005698:	c979                	beqz	a0,8000576e <sys_unlink+0x114>
  ilock(dp);
    8000569a:	ffffe097          	auipc	ra,0xffffe
    8000569e:	200080e7          	jalr	512(ra) # 8000389a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056a2:	00003597          	auipc	a1,0x3
    800056a6:	05e58593          	addi	a1,a1,94 # 80008700 <syscalls+0x2b0>
    800056aa:	fb040513          	addi	a0,s0,-80
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	6b6080e7          	jalr	1718(ra) # 80003d64 <namecmp>
    800056b6:	14050a63          	beqz	a0,8000580a <sys_unlink+0x1b0>
    800056ba:	00003597          	auipc	a1,0x3
    800056be:	04e58593          	addi	a1,a1,78 # 80008708 <syscalls+0x2b8>
    800056c2:	fb040513          	addi	a0,s0,-80
    800056c6:	ffffe097          	auipc	ra,0xffffe
    800056ca:	69e080e7          	jalr	1694(ra) # 80003d64 <namecmp>
    800056ce:	12050e63          	beqz	a0,8000580a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056d2:	f2c40613          	addi	a2,s0,-212
    800056d6:	fb040593          	addi	a1,s0,-80
    800056da:	8526                	mv	a0,s1
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	6a2080e7          	jalr	1698(ra) # 80003d7e <dirlookup>
    800056e4:	892a                	mv	s2,a0
    800056e6:	12050263          	beqz	a0,8000580a <sys_unlink+0x1b0>
  ilock(ip);
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	1b0080e7          	jalr	432(ra) # 8000389a <ilock>
  if(ip->nlink < 1)
    800056f2:	04a91783          	lh	a5,74(s2)
    800056f6:	08f05263          	blez	a5,8000577a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056fa:	04491703          	lh	a4,68(s2)
    800056fe:	4785                	li	a5,1
    80005700:	08f70563          	beq	a4,a5,8000578a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005704:	4641                	li	a2,16
    80005706:	4581                	li	a1,0
    80005708:	fc040513          	addi	a0,s0,-64
    8000570c:	ffffb097          	auipc	ra,0xffffb
    80005710:	5da080e7          	jalr	1498(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005714:	4741                	li	a4,16
    80005716:	f2c42683          	lw	a3,-212(s0)
    8000571a:	fc040613          	addi	a2,s0,-64
    8000571e:	4581                	li	a1,0
    80005720:	8526                	mv	a0,s1
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	524080e7          	jalr	1316(ra) # 80003c46 <writei>
    8000572a:	47c1                	li	a5,16
    8000572c:	0af51563          	bne	a0,a5,800057d6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005730:	04491703          	lh	a4,68(s2)
    80005734:	4785                	li	a5,1
    80005736:	0af70863          	beq	a4,a5,800057e6 <sys_unlink+0x18c>
  iunlockput(dp);
    8000573a:	8526                	mv	a0,s1
    8000573c:	ffffe097          	auipc	ra,0xffffe
    80005740:	3c0080e7          	jalr	960(ra) # 80003afc <iunlockput>
  ip->nlink--;
    80005744:	04a95783          	lhu	a5,74(s2)
    80005748:	37fd                	addiw	a5,a5,-1
    8000574a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000574e:	854a                	mv	a0,s2
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	080080e7          	jalr	128(ra) # 800037d0 <iupdate>
  iunlockput(ip);
    80005758:	854a                	mv	a0,s2
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	3a2080e7          	jalr	930(ra) # 80003afc <iunlockput>
  end_op();
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	b7a080e7          	jalr	-1158(ra) # 800042dc <end_op>
  return 0;
    8000576a:	4501                	li	a0,0
    8000576c:	a84d                	j	8000581e <sys_unlink+0x1c4>
    end_op();
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	b6e080e7          	jalr	-1170(ra) # 800042dc <end_op>
    return -1;
    80005776:	557d                	li	a0,-1
    80005778:	a05d                	j	8000581e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000577a:	00003517          	auipc	a0,0x3
    8000577e:	f9650513          	addi	a0,a0,-106 # 80008710 <syscalls+0x2c0>
    80005782:	ffffb097          	auipc	ra,0xffffb
    80005786:	dc2080e7          	jalr	-574(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000578a:	04c92703          	lw	a4,76(s2)
    8000578e:	02000793          	li	a5,32
    80005792:	f6e7f9e3          	bgeu	a5,a4,80005704 <sys_unlink+0xaa>
    80005796:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000579a:	4741                	li	a4,16
    8000579c:	86ce                	mv	a3,s3
    8000579e:	f1840613          	addi	a2,s0,-232
    800057a2:	4581                	li	a1,0
    800057a4:	854a                	mv	a0,s2
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	3a8080e7          	jalr	936(ra) # 80003b4e <readi>
    800057ae:	47c1                	li	a5,16
    800057b0:	00f51b63          	bne	a0,a5,800057c6 <sys_unlink+0x16c>
    if(de.inum != 0)
    800057b4:	f1845783          	lhu	a5,-232(s0)
    800057b8:	e7a1                	bnez	a5,80005800 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057ba:	29c1                	addiw	s3,s3,16
    800057bc:	04c92783          	lw	a5,76(s2)
    800057c0:	fcf9ede3          	bltu	s3,a5,8000579a <sys_unlink+0x140>
    800057c4:	b781                	j	80005704 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800057c6:	00003517          	auipc	a0,0x3
    800057ca:	f6250513          	addi	a0,a0,-158 # 80008728 <syscalls+0x2d8>
    800057ce:	ffffb097          	auipc	ra,0xffffb
    800057d2:	d76080e7          	jalr	-650(ra) # 80000544 <panic>
    panic("unlink: writei");
    800057d6:	00003517          	auipc	a0,0x3
    800057da:	f6a50513          	addi	a0,a0,-150 # 80008740 <syscalls+0x2f0>
    800057de:	ffffb097          	auipc	ra,0xffffb
    800057e2:	d66080e7          	jalr	-666(ra) # 80000544 <panic>
    dp->nlink--;
    800057e6:	04a4d783          	lhu	a5,74(s1)
    800057ea:	37fd                	addiw	a5,a5,-1
    800057ec:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057f0:	8526                	mv	a0,s1
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	fde080e7          	jalr	-34(ra) # 800037d0 <iupdate>
    800057fa:	b781                	j	8000573a <sys_unlink+0xe0>
    return -1;
    800057fc:	557d                	li	a0,-1
    800057fe:	a005                	j	8000581e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005800:	854a                	mv	a0,s2
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	2fa080e7          	jalr	762(ra) # 80003afc <iunlockput>
  iunlockput(dp);
    8000580a:	8526                	mv	a0,s1
    8000580c:	ffffe097          	auipc	ra,0xffffe
    80005810:	2f0080e7          	jalr	752(ra) # 80003afc <iunlockput>
  end_op();
    80005814:	fffff097          	auipc	ra,0xfffff
    80005818:	ac8080e7          	jalr	-1336(ra) # 800042dc <end_op>
  return -1;
    8000581c:	557d                	li	a0,-1
}
    8000581e:	70ae                	ld	ra,232(sp)
    80005820:	740e                	ld	s0,224(sp)
    80005822:	64ee                	ld	s1,216(sp)
    80005824:	694e                	ld	s2,208(sp)
    80005826:	69ae                	ld	s3,200(sp)
    80005828:	616d                	addi	sp,sp,240
    8000582a:	8082                	ret

000000008000582c <sys_open>:

uint64
sys_open(void)
{
    8000582c:	7131                	addi	sp,sp,-192
    8000582e:	fd06                	sd	ra,184(sp)
    80005830:	f922                	sd	s0,176(sp)
    80005832:	f526                	sd	s1,168(sp)
    80005834:	f14a                	sd	s2,160(sp)
    80005836:	ed4e                	sd	s3,152(sp)
    80005838:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000583a:	f4c40593          	addi	a1,s0,-180
    8000583e:	4505                	li	a0,1
    80005840:	ffffd097          	auipc	ra,0xffffd
    80005844:	408080e7          	jalr	1032(ra) # 80002c48 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005848:	08000613          	li	a2,128
    8000584c:	f5040593          	addi	a1,s0,-176
    80005850:	4501                	li	a0,0
    80005852:	ffffd097          	auipc	ra,0xffffd
    80005856:	436080e7          	jalr	1078(ra) # 80002c88 <argstr>
    8000585a:	87aa                	mv	a5,a0
    return -1;
    8000585c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000585e:	0a07c963          	bltz	a5,80005910 <sys_open+0xe4>

  begin_op();
    80005862:	fffff097          	auipc	ra,0xfffff
    80005866:	9fa080e7          	jalr	-1542(ra) # 8000425c <begin_op>

  if(omode & O_CREATE){
    8000586a:	f4c42783          	lw	a5,-180(s0)
    8000586e:	2007f793          	andi	a5,a5,512
    80005872:	cfc5                	beqz	a5,8000592a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005874:	4681                	li	a3,0
    80005876:	4601                	li	a2,0
    80005878:	4589                	li	a1,2
    8000587a:	f5040513          	addi	a0,s0,-176
    8000587e:	00000097          	auipc	ra,0x0
    80005882:	974080e7          	jalr	-1676(ra) # 800051f2 <create>
    80005886:	84aa                	mv	s1,a0
    if(ip == 0){
    80005888:	c959                	beqz	a0,8000591e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000588a:	04449703          	lh	a4,68(s1)
    8000588e:	478d                	li	a5,3
    80005890:	00f71763          	bne	a4,a5,8000589e <sys_open+0x72>
    80005894:	0464d703          	lhu	a4,70(s1)
    80005898:	47a5                	li	a5,9
    8000589a:	0ce7ed63          	bltu	a5,a4,80005974 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	dce080e7          	jalr	-562(ra) # 8000466c <filealloc>
    800058a6:	89aa                	mv	s3,a0
    800058a8:	10050363          	beqz	a0,800059ae <sys_open+0x182>
    800058ac:	00000097          	auipc	ra,0x0
    800058b0:	904080e7          	jalr	-1788(ra) # 800051b0 <fdalloc>
    800058b4:	892a                	mv	s2,a0
    800058b6:	0e054763          	bltz	a0,800059a4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058ba:	04449703          	lh	a4,68(s1)
    800058be:	478d                	li	a5,3
    800058c0:	0cf70563          	beq	a4,a5,8000598a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058c4:	4789                	li	a5,2
    800058c6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800058ca:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800058ce:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800058d2:	f4c42783          	lw	a5,-180(s0)
    800058d6:	0017c713          	xori	a4,a5,1
    800058da:	8b05                	andi	a4,a4,1
    800058dc:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058e0:	0037f713          	andi	a4,a5,3
    800058e4:	00e03733          	snez	a4,a4
    800058e8:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058ec:	4007f793          	andi	a5,a5,1024
    800058f0:	c791                	beqz	a5,800058fc <sys_open+0xd0>
    800058f2:	04449703          	lh	a4,68(s1)
    800058f6:	4789                	li	a5,2
    800058f8:	0af70063          	beq	a4,a5,80005998 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800058fc:	8526                	mv	a0,s1
    800058fe:	ffffe097          	auipc	ra,0xffffe
    80005902:	05e080e7          	jalr	94(ra) # 8000395c <iunlock>
  end_op();
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	9d6080e7          	jalr	-1578(ra) # 800042dc <end_op>

  return fd;
    8000590e:	854a                	mv	a0,s2
}
    80005910:	70ea                	ld	ra,184(sp)
    80005912:	744a                	ld	s0,176(sp)
    80005914:	74aa                	ld	s1,168(sp)
    80005916:	790a                	ld	s2,160(sp)
    80005918:	69ea                	ld	s3,152(sp)
    8000591a:	6129                	addi	sp,sp,192
    8000591c:	8082                	ret
      end_op();
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	9be080e7          	jalr	-1602(ra) # 800042dc <end_op>
      return -1;
    80005926:	557d                	li	a0,-1
    80005928:	b7e5                	j	80005910 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000592a:	f5040513          	addi	a0,s0,-176
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	712080e7          	jalr	1810(ra) # 80004040 <namei>
    80005936:	84aa                	mv	s1,a0
    80005938:	c905                	beqz	a0,80005968 <sys_open+0x13c>
    ilock(ip);
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	f60080e7          	jalr	-160(ra) # 8000389a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005942:	04449703          	lh	a4,68(s1)
    80005946:	4785                	li	a5,1
    80005948:	f4f711e3          	bne	a4,a5,8000588a <sys_open+0x5e>
    8000594c:	f4c42783          	lw	a5,-180(s0)
    80005950:	d7b9                	beqz	a5,8000589e <sys_open+0x72>
      iunlockput(ip);
    80005952:	8526                	mv	a0,s1
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	1a8080e7          	jalr	424(ra) # 80003afc <iunlockput>
      end_op();
    8000595c:	fffff097          	auipc	ra,0xfffff
    80005960:	980080e7          	jalr	-1664(ra) # 800042dc <end_op>
      return -1;
    80005964:	557d                	li	a0,-1
    80005966:	b76d                	j	80005910 <sys_open+0xe4>
      end_op();
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	974080e7          	jalr	-1676(ra) # 800042dc <end_op>
      return -1;
    80005970:	557d                	li	a0,-1
    80005972:	bf79                	j	80005910 <sys_open+0xe4>
    iunlockput(ip);
    80005974:	8526                	mv	a0,s1
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	186080e7          	jalr	390(ra) # 80003afc <iunlockput>
    end_op();
    8000597e:	fffff097          	auipc	ra,0xfffff
    80005982:	95e080e7          	jalr	-1698(ra) # 800042dc <end_op>
    return -1;
    80005986:	557d                	li	a0,-1
    80005988:	b761                	j	80005910 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000598a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000598e:	04649783          	lh	a5,70(s1)
    80005992:	02f99223          	sh	a5,36(s3)
    80005996:	bf25                	j	800058ce <sys_open+0xa2>
    itrunc(ip);
    80005998:	8526                	mv	a0,s1
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	00e080e7          	jalr	14(ra) # 800039a8 <itrunc>
    800059a2:	bfa9                	j	800058fc <sys_open+0xd0>
      fileclose(f);
    800059a4:	854e                	mv	a0,s3
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	d82080e7          	jalr	-638(ra) # 80004728 <fileclose>
    iunlockput(ip);
    800059ae:	8526                	mv	a0,s1
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	14c080e7          	jalr	332(ra) # 80003afc <iunlockput>
    end_op();
    800059b8:	fffff097          	auipc	ra,0xfffff
    800059bc:	924080e7          	jalr	-1756(ra) # 800042dc <end_op>
    return -1;
    800059c0:	557d                	li	a0,-1
    800059c2:	b7b9                	j	80005910 <sys_open+0xe4>

00000000800059c4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059c4:	7175                	addi	sp,sp,-144
    800059c6:	e506                	sd	ra,136(sp)
    800059c8:	e122                	sd	s0,128(sp)
    800059ca:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	890080e7          	jalr	-1904(ra) # 8000425c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059d4:	08000613          	li	a2,128
    800059d8:	f7040593          	addi	a1,s0,-144
    800059dc:	4501                	li	a0,0
    800059de:	ffffd097          	auipc	ra,0xffffd
    800059e2:	2aa080e7          	jalr	682(ra) # 80002c88 <argstr>
    800059e6:	02054963          	bltz	a0,80005a18 <sys_mkdir+0x54>
    800059ea:	4681                	li	a3,0
    800059ec:	4601                	li	a2,0
    800059ee:	4585                	li	a1,1
    800059f0:	f7040513          	addi	a0,s0,-144
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	7fe080e7          	jalr	2046(ra) # 800051f2 <create>
    800059fc:	cd11                	beqz	a0,80005a18 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	0fe080e7          	jalr	254(ra) # 80003afc <iunlockput>
  end_op();
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	8d6080e7          	jalr	-1834(ra) # 800042dc <end_op>
  return 0;
    80005a0e:	4501                	li	a0,0
}
    80005a10:	60aa                	ld	ra,136(sp)
    80005a12:	640a                	ld	s0,128(sp)
    80005a14:	6149                	addi	sp,sp,144
    80005a16:	8082                	ret
    end_op();
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	8c4080e7          	jalr	-1852(ra) # 800042dc <end_op>
    return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	b7fd                	j	80005a10 <sys_mkdir+0x4c>

0000000080005a24 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a24:	7135                	addi	sp,sp,-160
    80005a26:	ed06                	sd	ra,152(sp)
    80005a28:	e922                	sd	s0,144(sp)
    80005a2a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	830080e7          	jalr	-2000(ra) # 8000425c <begin_op>
  argint(1, &major);
    80005a34:	f6c40593          	addi	a1,s0,-148
    80005a38:	4505                	li	a0,1
    80005a3a:	ffffd097          	auipc	ra,0xffffd
    80005a3e:	20e080e7          	jalr	526(ra) # 80002c48 <argint>
  argint(2, &minor);
    80005a42:	f6840593          	addi	a1,s0,-152
    80005a46:	4509                	li	a0,2
    80005a48:	ffffd097          	auipc	ra,0xffffd
    80005a4c:	200080e7          	jalr	512(ra) # 80002c48 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a50:	08000613          	li	a2,128
    80005a54:	f7040593          	addi	a1,s0,-144
    80005a58:	4501                	li	a0,0
    80005a5a:	ffffd097          	auipc	ra,0xffffd
    80005a5e:	22e080e7          	jalr	558(ra) # 80002c88 <argstr>
    80005a62:	02054b63          	bltz	a0,80005a98 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a66:	f6841683          	lh	a3,-152(s0)
    80005a6a:	f6c41603          	lh	a2,-148(s0)
    80005a6e:	458d                	li	a1,3
    80005a70:	f7040513          	addi	a0,s0,-144
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	77e080e7          	jalr	1918(ra) # 800051f2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a7c:	cd11                	beqz	a0,80005a98 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a7e:	ffffe097          	auipc	ra,0xffffe
    80005a82:	07e080e7          	jalr	126(ra) # 80003afc <iunlockput>
  end_op();
    80005a86:	fffff097          	auipc	ra,0xfffff
    80005a8a:	856080e7          	jalr	-1962(ra) # 800042dc <end_op>
  return 0;
    80005a8e:	4501                	li	a0,0
}
    80005a90:	60ea                	ld	ra,152(sp)
    80005a92:	644a                	ld	s0,144(sp)
    80005a94:	610d                	addi	sp,sp,160
    80005a96:	8082                	ret
    end_op();
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	844080e7          	jalr	-1980(ra) # 800042dc <end_op>
    return -1;
    80005aa0:	557d                	li	a0,-1
    80005aa2:	b7fd                	j	80005a90 <sys_mknod+0x6c>

0000000080005aa4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005aa4:	7135                	addi	sp,sp,-160
    80005aa6:	ed06                	sd	ra,152(sp)
    80005aa8:	e922                	sd	s0,144(sp)
    80005aaa:	e526                	sd	s1,136(sp)
    80005aac:	e14a                	sd	s2,128(sp)
    80005aae:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ab0:	ffffc097          	auipc	ra,0xffffc
    80005ab4:	f16080e7          	jalr	-234(ra) # 800019c6 <myproc>
    80005ab8:	892a                	mv	s2,a0
  
  begin_op();
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	7a2080e7          	jalr	1954(ra) # 8000425c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ac2:	08000613          	li	a2,128
    80005ac6:	f6040593          	addi	a1,s0,-160
    80005aca:	4501                	li	a0,0
    80005acc:	ffffd097          	auipc	ra,0xffffd
    80005ad0:	1bc080e7          	jalr	444(ra) # 80002c88 <argstr>
    80005ad4:	04054b63          	bltz	a0,80005b2a <sys_chdir+0x86>
    80005ad8:	f6040513          	addi	a0,s0,-160
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	564080e7          	jalr	1380(ra) # 80004040 <namei>
    80005ae4:	84aa                	mv	s1,a0
    80005ae6:	c131                	beqz	a0,80005b2a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	db2080e7          	jalr	-590(ra) # 8000389a <ilock>
  if(ip->type != T_DIR){
    80005af0:	04449703          	lh	a4,68(s1)
    80005af4:	4785                	li	a5,1
    80005af6:	04f71063          	bne	a4,a5,80005b36 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005afa:	8526                	mv	a0,s1
    80005afc:	ffffe097          	auipc	ra,0xffffe
    80005b00:	e60080e7          	jalr	-416(ra) # 8000395c <iunlock>
  iput(p->cwd);
    80005b04:	15093503          	ld	a0,336(s2)
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	f4c080e7          	jalr	-180(ra) # 80003a54 <iput>
  end_op();
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	7cc080e7          	jalr	1996(ra) # 800042dc <end_op>
  p->cwd = ip;
    80005b18:	14993823          	sd	s1,336(s2)
  return 0;
    80005b1c:	4501                	li	a0,0
}
    80005b1e:	60ea                	ld	ra,152(sp)
    80005b20:	644a                	ld	s0,144(sp)
    80005b22:	64aa                	ld	s1,136(sp)
    80005b24:	690a                	ld	s2,128(sp)
    80005b26:	610d                	addi	sp,sp,160
    80005b28:	8082                	ret
    end_op();
    80005b2a:	ffffe097          	auipc	ra,0xffffe
    80005b2e:	7b2080e7          	jalr	1970(ra) # 800042dc <end_op>
    return -1;
    80005b32:	557d                	li	a0,-1
    80005b34:	b7ed                	j	80005b1e <sys_chdir+0x7a>
    iunlockput(ip);
    80005b36:	8526                	mv	a0,s1
    80005b38:	ffffe097          	auipc	ra,0xffffe
    80005b3c:	fc4080e7          	jalr	-60(ra) # 80003afc <iunlockput>
    end_op();
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	79c080e7          	jalr	1948(ra) # 800042dc <end_op>
    return -1;
    80005b48:	557d                	li	a0,-1
    80005b4a:	bfd1                	j	80005b1e <sys_chdir+0x7a>

0000000080005b4c <sys_exec>:

uint64
sys_exec(void)
{
    80005b4c:	7145                	addi	sp,sp,-464
    80005b4e:	e786                	sd	ra,456(sp)
    80005b50:	e3a2                	sd	s0,448(sp)
    80005b52:	ff26                	sd	s1,440(sp)
    80005b54:	fb4a                	sd	s2,432(sp)
    80005b56:	f74e                	sd	s3,424(sp)
    80005b58:	f352                	sd	s4,416(sp)
    80005b5a:	ef56                	sd	s5,408(sp)
    80005b5c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b5e:	e3840593          	addi	a1,s0,-456
    80005b62:	4505                	li	a0,1
    80005b64:	ffffd097          	auipc	ra,0xffffd
    80005b68:	104080e7          	jalr	260(ra) # 80002c68 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b6c:	08000613          	li	a2,128
    80005b70:	f4040593          	addi	a1,s0,-192
    80005b74:	4501                	li	a0,0
    80005b76:	ffffd097          	auipc	ra,0xffffd
    80005b7a:	112080e7          	jalr	274(ra) # 80002c88 <argstr>
    80005b7e:	87aa                	mv	a5,a0
    return -1;
    80005b80:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b82:	0c07c263          	bltz	a5,80005c46 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005b86:	10000613          	li	a2,256
    80005b8a:	4581                	li	a1,0
    80005b8c:	e4040513          	addi	a0,s0,-448
    80005b90:	ffffb097          	auipc	ra,0xffffb
    80005b94:	156080e7          	jalr	342(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b98:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b9c:	89a6                	mv	s3,s1
    80005b9e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ba0:	02000a13          	li	s4,32
    80005ba4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ba8:	00391513          	slli	a0,s2,0x3
    80005bac:	e3040593          	addi	a1,s0,-464
    80005bb0:	e3843783          	ld	a5,-456(s0)
    80005bb4:	953e                	add	a0,a0,a5
    80005bb6:	ffffd097          	auipc	ra,0xffffd
    80005bba:	ff4080e7          	jalr	-12(ra) # 80002baa <fetchaddr>
    80005bbe:	02054a63          	bltz	a0,80005bf2 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005bc2:	e3043783          	ld	a5,-464(s0)
    80005bc6:	c3b9                	beqz	a5,80005c0c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005bc8:	ffffb097          	auipc	ra,0xffffb
    80005bcc:	f32080e7          	jalr	-206(ra) # 80000afa <kalloc>
    80005bd0:	85aa                	mv	a1,a0
    80005bd2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005bd6:	cd11                	beqz	a0,80005bf2 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005bd8:	6605                	lui	a2,0x1
    80005bda:	e3043503          	ld	a0,-464(s0)
    80005bde:	ffffd097          	auipc	ra,0xffffd
    80005be2:	01e080e7          	jalr	30(ra) # 80002bfc <fetchstr>
    80005be6:	00054663          	bltz	a0,80005bf2 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005bea:	0905                	addi	s2,s2,1
    80005bec:	09a1                	addi	s3,s3,8
    80005bee:	fb491be3          	bne	s2,s4,80005ba4 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bf2:	10048913          	addi	s2,s1,256
    80005bf6:	6088                	ld	a0,0(s1)
    80005bf8:	c531                	beqz	a0,80005c44 <sys_exec+0xf8>
    kfree(argv[i]);
    80005bfa:	ffffb097          	auipc	ra,0xffffb
    80005bfe:	e04080e7          	jalr	-508(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c02:	04a1                	addi	s1,s1,8
    80005c04:	ff2499e3          	bne	s1,s2,80005bf6 <sys_exec+0xaa>
  return -1;
    80005c08:	557d                	li	a0,-1
    80005c0a:	a835                	j	80005c46 <sys_exec+0xfa>
      argv[i] = 0;
    80005c0c:	0a8e                	slli	s5,s5,0x3
    80005c0e:	fc040793          	addi	a5,s0,-64
    80005c12:	9abe                	add	s5,s5,a5
    80005c14:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c18:	e4040593          	addi	a1,s0,-448
    80005c1c:	f4040513          	addi	a0,s0,-192
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	190080e7          	jalr	400(ra) # 80004db0 <exec>
    80005c28:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c2a:	10048993          	addi	s3,s1,256
    80005c2e:	6088                	ld	a0,0(s1)
    80005c30:	c901                	beqz	a0,80005c40 <sys_exec+0xf4>
    kfree(argv[i]);
    80005c32:	ffffb097          	auipc	ra,0xffffb
    80005c36:	dcc080e7          	jalr	-564(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c3a:	04a1                	addi	s1,s1,8
    80005c3c:	ff3499e3          	bne	s1,s3,80005c2e <sys_exec+0xe2>
  return ret;
    80005c40:	854a                	mv	a0,s2
    80005c42:	a011                	j	80005c46 <sys_exec+0xfa>
  return -1;
    80005c44:	557d                	li	a0,-1
}
    80005c46:	60be                	ld	ra,456(sp)
    80005c48:	641e                	ld	s0,448(sp)
    80005c4a:	74fa                	ld	s1,440(sp)
    80005c4c:	795a                	ld	s2,432(sp)
    80005c4e:	79ba                	ld	s3,424(sp)
    80005c50:	7a1a                	ld	s4,416(sp)
    80005c52:	6afa                	ld	s5,408(sp)
    80005c54:	6179                	addi	sp,sp,464
    80005c56:	8082                	ret

0000000080005c58 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c58:	7139                	addi	sp,sp,-64
    80005c5a:	fc06                	sd	ra,56(sp)
    80005c5c:	f822                	sd	s0,48(sp)
    80005c5e:	f426                	sd	s1,40(sp)
    80005c60:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c62:	ffffc097          	auipc	ra,0xffffc
    80005c66:	d64080e7          	jalr	-668(ra) # 800019c6 <myproc>
    80005c6a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c6c:	fd840593          	addi	a1,s0,-40
    80005c70:	4501                	li	a0,0
    80005c72:	ffffd097          	auipc	ra,0xffffd
    80005c76:	ff6080e7          	jalr	-10(ra) # 80002c68 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c7a:	fc840593          	addi	a1,s0,-56
    80005c7e:	fd040513          	addi	a0,s0,-48
    80005c82:	fffff097          	auipc	ra,0xfffff
    80005c86:	dd6080e7          	jalr	-554(ra) # 80004a58 <pipealloc>
    return -1;
    80005c8a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c8c:	0c054463          	bltz	a0,80005d54 <sys_pipe+0xfc>
  fd0 = -1;
    80005c90:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c94:	fd043503          	ld	a0,-48(s0)
    80005c98:	fffff097          	auipc	ra,0xfffff
    80005c9c:	518080e7          	jalr	1304(ra) # 800051b0 <fdalloc>
    80005ca0:	fca42223          	sw	a0,-60(s0)
    80005ca4:	08054b63          	bltz	a0,80005d3a <sys_pipe+0xe2>
    80005ca8:	fc843503          	ld	a0,-56(s0)
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	504080e7          	jalr	1284(ra) # 800051b0 <fdalloc>
    80005cb4:	fca42023          	sw	a0,-64(s0)
    80005cb8:	06054863          	bltz	a0,80005d28 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cbc:	4691                	li	a3,4
    80005cbe:	fc440613          	addi	a2,s0,-60
    80005cc2:	fd843583          	ld	a1,-40(s0)
    80005cc6:	68a8                	ld	a0,80(s1)
    80005cc8:	ffffc097          	auipc	ra,0xffffc
    80005ccc:	9bc080e7          	jalr	-1604(ra) # 80001684 <copyout>
    80005cd0:	02054063          	bltz	a0,80005cf0 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cd4:	4691                	li	a3,4
    80005cd6:	fc040613          	addi	a2,s0,-64
    80005cda:	fd843583          	ld	a1,-40(s0)
    80005cde:	0591                	addi	a1,a1,4
    80005ce0:	68a8                	ld	a0,80(s1)
    80005ce2:	ffffc097          	auipc	ra,0xffffc
    80005ce6:	9a2080e7          	jalr	-1630(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005cea:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cec:	06055463          	bgez	a0,80005d54 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005cf0:	fc442783          	lw	a5,-60(s0)
    80005cf4:	07e9                	addi	a5,a5,26
    80005cf6:	078e                	slli	a5,a5,0x3
    80005cf8:	97a6                	add	a5,a5,s1
    80005cfa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005cfe:	fc042503          	lw	a0,-64(s0)
    80005d02:	0569                	addi	a0,a0,26
    80005d04:	050e                	slli	a0,a0,0x3
    80005d06:	94aa                	add	s1,s1,a0
    80005d08:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d0c:	fd043503          	ld	a0,-48(s0)
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	a18080e7          	jalr	-1512(ra) # 80004728 <fileclose>
    fileclose(wf);
    80005d18:	fc843503          	ld	a0,-56(s0)
    80005d1c:	fffff097          	auipc	ra,0xfffff
    80005d20:	a0c080e7          	jalr	-1524(ra) # 80004728 <fileclose>
    return -1;
    80005d24:	57fd                	li	a5,-1
    80005d26:	a03d                	j	80005d54 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005d28:	fc442783          	lw	a5,-60(s0)
    80005d2c:	0007c763          	bltz	a5,80005d3a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005d30:	07e9                	addi	a5,a5,26
    80005d32:	078e                	slli	a5,a5,0x3
    80005d34:	94be                	add	s1,s1,a5
    80005d36:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d3a:	fd043503          	ld	a0,-48(s0)
    80005d3e:	fffff097          	auipc	ra,0xfffff
    80005d42:	9ea080e7          	jalr	-1558(ra) # 80004728 <fileclose>
    fileclose(wf);
    80005d46:	fc843503          	ld	a0,-56(s0)
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	9de080e7          	jalr	-1570(ra) # 80004728 <fileclose>
    return -1;
    80005d52:	57fd                	li	a5,-1
}
    80005d54:	853e                	mv	a0,a5
    80005d56:	70e2                	ld	ra,56(sp)
    80005d58:	7442                	ld	s0,48(sp)
    80005d5a:	74a2                	ld	s1,40(sp)
    80005d5c:	6121                	addi	sp,sp,64
    80005d5e:	8082                	ret

0000000080005d60 <kernelvec>:
    80005d60:	7111                	addi	sp,sp,-256
    80005d62:	e006                	sd	ra,0(sp)
    80005d64:	e40a                	sd	sp,8(sp)
    80005d66:	e80e                	sd	gp,16(sp)
    80005d68:	ec12                	sd	tp,24(sp)
    80005d6a:	f016                	sd	t0,32(sp)
    80005d6c:	f41a                	sd	t1,40(sp)
    80005d6e:	f81e                	sd	t2,48(sp)
    80005d70:	fc22                	sd	s0,56(sp)
    80005d72:	e0a6                	sd	s1,64(sp)
    80005d74:	e4aa                	sd	a0,72(sp)
    80005d76:	e8ae                	sd	a1,80(sp)
    80005d78:	ecb2                	sd	a2,88(sp)
    80005d7a:	f0b6                	sd	a3,96(sp)
    80005d7c:	f4ba                	sd	a4,104(sp)
    80005d7e:	f8be                	sd	a5,112(sp)
    80005d80:	fcc2                	sd	a6,120(sp)
    80005d82:	e146                	sd	a7,128(sp)
    80005d84:	e54a                	sd	s2,136(sp)
    80005d86:	e94e                	sd	s3,144(sp)
    80005d88:	ed52                	sd	s4,152(sp)
    80005d8a:	f156                	sd	s5,160(sp)
    80005d8c:	f55a                	sd	s6,168(sp)
    80005d8e:	f95e                	sd	s7,176(sp)
    80005d90:	fd62                	sd	s8,184(sp)
    80005d92:	e1e6                	sd	s9,192(sp)
    80005d94:	e5ea                	sd	s10,200(sp)
    80005d96:	e9ee                	sd	s11,208(sp)
    80005d98:	edf2                	sd	t3,216(sp)
    80005d9a:	f1f6                	sd	t4,224(sp)
    80005d9c:	f5fa                	sd	t5,232(sp)
    80005d9e:	f9fe                	sd	t6,240(sp)
    80005da0:	cd7fc0ef          	jal	ra,80002a76 <kerneltrap>
    80005da4:	6082                	ld	ra,0(sp)
    80005da6:	6122                	ld	sp,8(sp)
    80005da8:	61c2                	ld	gp,16(sp)
    80005daa:	7282                	ld	t0,32(sp)
    80005dac:	7322                	ld	t1,40(sp)
    80005dae:	73c2                	ld	t2,48(sp)
    80005db0:	7462                	ld	s0,56(sp)
    80005db2:	6486                	ld	s1,64(sp)
    80005db4:	6526                	ld	a0,72(sp)
    80005db6:	65c6                	ld	a1,80(sp)
    80005db8:	6666                	ld	a2,88(sp)
    80005dba:	7686                	ld	a3,96(sp)
    80005dbc:	7726                	ld	a4,104(sp)
    80005dbe:	77c6                	ld	a5,112(sp)
    80005dc0:	7866                	ld	a6,120(sp)
    80005dc2:	688a                	ld	a7,128(sp)
    80005dc4:	692a                	ld	s2,136(sp)
    80005dc6:	69ca                	ld	s3,144(sp)
    80005dc8:	6a6a                	ld	s4,152(sp)
    80005dca:	7a8a                	ld	s5,160(sp)
    80005dcc:	7b2a                	ld	s6,168(sp)
    80005dce:	7bca                	ld	s7,176(sp)
    80005dd0:	7c6a                	ld	s8,184(sp)
    80005dd2:	6c8e                	ld	s9,192(sp)
    80005dd4:	6d2e                	ld	s10,200(sp)
    80005dd6:	6dce                	ld	s11,208(sp)
    80005dd8:	6e6e                	ld	t3,216(sp)
    80005dda:	7e8e                	ld	t4,224(sp)
    80005ddc:	7f2e                	ld	t5,232(sp)
    80005dde:	7fce                	ld	t6,240(sp)
    80005de0:	6111                	addi	sp,sp,256
    80005de2:	10200073          	sret
    80005de6:	00000013          	nop
    80005dea:	00000013          	nop
    80005dee:	0001                	nop

0000000080005df0 <timervec>:
    80005df0:	34051573          	csrrw	a0,mscratch,a0
    80005df4:	e10c                	sd	a1,0(a0)
    80005df6:	e510                	sd	a2,8(a0)
    80005df8:	e914                	sd	a3,16(a0)
    80005dfa:	6d0c                	ld	a1,24(a0)
    80005dfc:	7110                	ld	a2,32(a0)
    80005dfe:	6194                	ld	a3,0(a1)
    80005e00:	96b2                	add	a3,a3,a2
    80005e02:	e194                	sd	a3,0(a1)
    80005e04:	4589                	li	a1,2
    80005e06:	14459073          	csrw	sip,a1
    80005e0a:	6914                	ld	a3,16(a0)
    80005e0c:	6510                	ld	a2,8(a0)
    80005e0e:	610c                	ld	a1,0(a0)
    80005e10:	34051573          	csrrw	a0,mscratch,a0
    80005e14:	30200073          	mret
	...

0000000080005e1a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e1a:	1141                	addi	sp,sp,-16
    80005e1c:	e422                	sd	s0,8(sp)
    80005e1e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e20:	0c0007b7          	lui	a5,0xc000
    80005e24:	4705                	li	a4,1
    80005e26:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e28:	c3d8                	sw	a4,4(a5)
}
    80005e2a:	6422                	ld	s0,8(sp)
    80005e2c:	0141                	addi	sp,sp,16
    80005e2e:	8082                	ret

0000000080005e30 <plicinithart>:

void
plicinithart(void)
{
    80005e30:	1141                	addi	sp,sp,-16
    80005e32:	e406                	sd	ra,8(sp)
    80005e34:	e022                	sd	s0,0(sp)
    80005e36:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e38:	ffffc097          	auipc	ra,0xffffc
    80005e3c:	b62080e7          	jalr	-1182(ra) # 8000199a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e40:	0085171b          	slliw	a4,a0,0x8
    80005e44:	0c0027b7          	lui	a5,0xc002
    80005e48:	97ba                	add	a5,a5,a4
    80005e4a:	40200713          	li	a4,1026
    80005e4e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e52:	00d5151b          	slliw	a0,a0,0xd
    80005e56:	0c2017b7          	lui	a5,0xc201
    80005e5a:	953e                	add	a0,a0,a5
    80005e5c:	00052023          	sw	zero,0(a0)
}
    80005e60:	60a2                	ld	ra,8(sp)
    80005e62:	6402                	ld	s0,0(sp)
    80005e64:	0141                	addi	sp,sp,16
    80005e66:	8082                	ret

0000000080005e68 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e68:	1141                	addi	sp,sp,-16
    80005e6a:	e406                	sd	ra,8(sp)
    80005e6c:	e022                	sd	s0,0(sp)
    80005e6e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e70:	ffffc097          	auipc	ra,0xffffc
    80005e74:	b2a080e7          	jalr	-1238(ra) # 8000199a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e78:	00d5179b          	slliw	a5,a0,0xd
    80005e7c:	0c201537          	lui	a0,0xc201
    80005e80:	953e                	add	a0,a0,a5
  return irq;
}
    80005e82:	4148                	lw	a0,4(a0)
    80005e84:	60a2                	ld	ra,8(sp)
    80005e86:	6402                	ld	s0,0(sp)
    80005e88:	0141                	addi	sp,sp,16
    80005e8a:	8082                	ret

0000000080005e8c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e8c:	1101                	addi	sp,sp,-32
    80005e8e:	ec06                	sd	ra,24(sp)
    80005e90:	e822                	sd	s0,16(sp)
    80005e92:	e426                	sd	s1,8(sp)
    80005e94:	1000                	addi	s0,sp,32
    80005e96:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e98:	ffffc097          	auipc	ra,0xffffc
    80005e9c:	b02080e7          	jalr	-1278(ra) # 8000199a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ea0:	00d5151b          	slliw	a0,a0,0xd
    80005ea4:	0c2017b7          	lui	a5,0xc201
    80005ea8:	97aa                	add	a5,a5,a0
    80005eaa:	c3c4                	sw	s1,4(a5)
}
    80005eac:	60e2                	ld	ra,24(sp)
    80005eae:	6442                	ld	s0,16(sp)
    80005eb0:	64a2                	ld	s1,8(sp)
    80005eb2:	6105                	addi	sp,sp,32
    80005eb4:	8082                	ret

0000000080005eb6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005eb6:	1141                	addi	sp,sp,-16
    80005eb8:	e406                	sd	ra,8(sp)
    80005eba:	e022                	sd	s0,0(sp)
    80005ebc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005ebe:	479d                	li	a5,7
    80005ec0:	04a7cc63          	blt	a5,a0,80005f18 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005ec4:	0001c797          	auipc	a5,0x1c
    80005ec8:	d6c78793          	addi	a5,a5,-660 # 80021c30 <disk>
    80005ecc:	97aa                	add	a5,a5,a0
    80005ece:	0187c783          	lbu	a5,24(a5)
    80005ed2:	ebb9                	bnez	a5,80005f28 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ed4:	00451613          	slli	a2,a0,0x4
    80005ed8:	0001c797          	auipc	a5,0x1c
    80005edc:	d5878793          	addi	a5,a5,-680 # 80021c30 <disk>
    80005ee0:	6394                	ld	a3,0(a5)
    80005ee2:	96b2                	add	a3,a3,a2
    80005ee4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005ee8:	6398                	ld	a4,0(a5)
    80005eea:	9732                	add	a4,a4,a2
    80005eec:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ef0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ef4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ef8:	953e                	add	a0,a0,a5
    80005efa:	4785                	li	a5,1
    80005efc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005f00:	0001c517          	auipc	a0,0x1c
    80005f04:	d4850513          	addi	a0,a0,-696 # 80021c48 <disk+0x18>
    80005f08:	ffffc097          	auipc	ra,0xffffc
    80005f0c:	214080e7          	jalr	532(ra) # 8000211c <wakeup>
}
    80005f10:	60a2                	ld	ra,8(sp)
    80005f12:	6402                	ld	s0,0(sp)
    80005f14:	0141                	addi	sp,sp,16
    80005f16:	8082                	ret
    panic("free_desc 1");
    80005f18:	00003517          	auipc	a0,0x3
    80005f1c:	83850513          	addi	a0,a0,-1992 # 80008750 <syscalls+0x300>
    80005f20:	ffffa097          	auipc	ra,0xffffa
    80005f24:	624080e7          	jalr	1572(ra) # 80000544 <panic>
    panic("free_desc 2");
    80005f28:	00003517          	auipc	a0,0x3
    80005f2c:	83850513          	addi	a0,a0,-1992 # 80008760 <syscalls+0x310>
    80005f30:	ffffa097          	auipc	ra,0xffffa
    80005f34:	614080e7          	jalr	1556(ra) # 80000544 <panic>

0000000080005f38 <virtio_disk_init>:
{
    80005f38:	1101                	addi	sp,sp,-32
    80005f3a:	ec06                	sd	ra,24(sp)
    80005f3c:	e822                	sd	s0,16(sp)
    80005f3e:	e426                	sd	s1,8(sp)
    80005f40:	e04a                	sd	s2,0(sp)
    80005f42:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f44:	00003597          	auipc	a1,0x3
    80005f48:	82c58593          	addi	a1,a1,-2004 # 80008770 <syscalls+0x320>
    80005f4c:	0001c517          	auipc	a0,0x1c
    80005f50:	e0c50513          	addi	a0,a0,-500 # 80021d58 <disk+0x128>
    80005f54:	ffffb097          	auipc	ra,0xffffb
    80005f58:	c06080e7          	jalr	-1018(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f5c:	100017b7          	lui	a5,0x10001
    80005f60:	4398                	lw	a4,0(a5)
    80005f62:	2701                	sext.w	a4,a4
    80005f64:	747277b7          	lui	a5,0x74727
    80005f68:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f6c:	14f71e63          	bne	a4,a5,800060c8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f70:	100017b7          	lui	a5,0x10001
    80005f74:	43dc                	lw	a5,4(a5)
    80005f76:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f78:	4709                	li	a4,2
    80005f7a:	14e79763          	bne	a5,a4,800060c8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f7e:	100017b7          	lui	a5,0x10001
    80005f82:	479c                	lw	a5,8(a5)
    80005f84:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f86:	14e79163          	bne	a5,a4,800060c8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f8a:	100017b7          	lui	a5,0x10001
    80005f8e:	47d8                	lw	a4,12(a5)
    80005f90:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f92:	554d47b7          	lui	a5,0x554d4
    80005f96:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f9a:	12f71763          	bne	a4,a5,800060c8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f9e:	100017b7          	lui	a5,0x10001
    80005fa2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fa6:	4705                	li	a4,1
    80005fa8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005faa:	470d                	li	a4,3
    80005fac:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005fae:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005fb0:	c7ffe737          	lui	a4,0xc7ffe
    80005fb4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9ef>
    80005fb8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fba:	2701                	sext.w	a4,a4
    80005fbc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fbe:	472d                	li	a4,11
    80005fc0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005fc2:	0707a903          	lw	s2,112(a5)
    80005fc6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005fc8:	00897793          	andi	a5,s2,8
    80005fcc:	10078663          	beqz	a5,800060d8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005fd0:	100017b7          	lui	a5,0x10001
    80005fd4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005fd8:	43fc                	lw	a5,68(a5)
    80005fda:	2781                	sext.w	a5,a5
    80005fdc:	10079663          	bnez	a5,800060e8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005fe0:	100017b7          	lui	a5,0x10001
    80005fe4:	5bdc                	lw	a5,52(a5)
    80005fe6:	2781                	sext.w	a5,a5
  if(max == 0)
    80005fe8:	10078863          	beqz	a5,800060f8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    80005fec:	471d                	li	a4,7
    80005fee:	10f77d63          	bgeu	a4,a5,80006108 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80005ff2:	ffffb097          	auipc	ra,0xffffb
    80005ff6:	b08080e7          	jalr	-1272(ra) # 80000afa <kalloc>
    80005ffa:	0001c497          	auipc	s1,0x1c
    80005ffe:	c3648493          	addi	s1,s1,-970 # 80021c30 <disk>
    80006002:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006004:	ffffb097          	auipc	ra,0xffffb
    80006008:	af6080e7          	jalr	-1290(ra) # 80000afa <kalloc>
    8000600c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000600e:	ffffb097          	auipc	ra,0xffffb
    80006012:	aec080e7          	jalr	-1300(ra) # 80000afa <kalloc>
    80006016:	87aa                	mv	a5,a0
    80006018:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000601a:	6088                	ld	a0,0(s1)
    8000601c:	cd75                	beqz	a0,80006118 <virtio_disk_init+0x1e0>
    8000601e:	0001c717          	auipc	a4,0x1c
    80006022:	c1a73703          	ld	a4,-998(a4) # 80021c38 <disk+0x8>
    80006026:	cb6d                	beqz	a4,80006118 <virtio_disk_init+0x1e0>
    80006028:	cbe5                	beqz	a5,80006118 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000602a:	6605                	lui	a2,0x1
    8000602c:	4581                	li	a1,0
    8000602e:	ffffb097          	auipc	ra,0xffffb
    80006032:	cb8080e7          	jalr	-840(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006036:	0001c497          	auipc	s1,0x1c
    8000603a:	bfa48493          	addi	s1,s1,-1030 # 80021c30 <disk>
    8000603e:	6605                	lui	a2,0x1
    80006040:	4581                	li	a1,0
    80006042:	6488                	ld	a0,8(s1)
    80006044:	ffffb097          	auipc	ra,0xffffb
    80006048:	ca2080e7          	jalr	-862(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000604c:	6605                	lui	a2,0x1
    8000604e:	4581                	li	a1,0
    80006050:	6888                	ld	a0,16(s1)
    80006052:	ffffb097          	auipc	ra,0xffffb
    80006056:	c94080e7          	jalr	-876(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000605a:	100017b7          	lui	a5,0x10001
    8000605e:	4721                	li	a4,8
    80006060:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006062:	4098                	lw	a4,0(s1)
    80006064:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006068:	40d8                	lw	a4,4(s1)
    8000606a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000606e:	6498                	ld	a4,8(s1)
    80006070:	0007069b          	sext.w	a3,a4
    80006074:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006078:	9701                	srai	a4,a4,0x20
    8000607a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000607e:	6898                	ld	a4,16(s1)
    80006080:	0007069b          	sext.w	a3,a4
    80006084:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006088:	9701                	srai	a4,a4,0x20
    8000608a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000608e:	4685                	li	a3,1
    80006090:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006092:	4705                	li	a4,1
    80006094:	00d48c23          	sb	a3,24(s1)
    80006098:	00e48ca3          	sb	a4,25(s1)
    8000609c:	00e48d23          	sb	a4,26(s1)
    800060a0:	00e48da3          	sb	a4,27(s1)
    800060a4:	00e48e23          	sb	a4,28(s1)
    800060a8:	00e48ea3          	sb	a4,29(s1)
    800060ac:	00e48f23          	sb	a4,30(s1)
    800060b0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800060b4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800060b8:	0727a823          	sw	s2,112(a5)
}
    800060bc:	60e2                	ld	ra,24(sp)
    800060be:	6442                	ld	s0,16(sp)
    800060c0:	64a2                	ld	s1,8(sp)
    800060c2:	6902                	ld	s2,0(sp)
    800060c4:	6105                	addi	sp,sp,32
    800060c6:	8082                	ret
    panic("could not find virtio disk");
    800060c8:	00002517          	auipc	a0,0x2
    800060cc:	6b850513          	addi	a0,a0,1720 # 80008780 <syscalls+0x330>
    800060d0:	ffffa097          	auipc	ra,0xffffa
    800060d4:	474080e7          	jalr	1140(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800060d8:	00002517          	auipc	a0,0x2
    800060dc:	6c850513          	addi	a0,a0,1736 # 800087a0 <syscalls+0x350>
    800060e0:	ffffa097          	auipc	ra,0xffffa
    800060e4:	464080e7          	jalr	1124(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	6d850513          	addi	a0,a0,1752 # 800087c0 <syscalls+0x370>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	454080e7          	jalr	1108(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    800060f8:	00002517          	auipc	a0,0x2
    800060fc:	6e850513          	addi	a0,a0,1768 # 800087e0 <syscalls+0x390>
    80006100:	ffffa097          	auipc	ra,0xffffa
    80006104:	444080e7          	jalr	1092(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006108:	00002517          	auipc	a0,0x2
    8000610c:	6f850513          	addi	a0,a0,1784 # 80008800 <syscalls+0x3b0>
    80006110:	ffffa097          	auipc	ra,0xffffa
    80006114:	434080e7          	jalr	1076(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006118:	00002517          	auipc	a0,0x2
    8000611c:	70850513          	addi	a0,a0,1800 # 80008820 <syscalls+0x3d0>
    80006120:	ffffa097          	auipc	ra,0xffffa
    80006124:	424080e7          	jalr	1060(ra) # 80000544 <panic>

0000000080006128 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006128:	7159                	addi	sp,sp,-112
    8000612a:	f486                	sd	ra,104(sp)
    8000612c:	f0a2                	sd	s0,96(sp)
    8000612e:	eca6                	sd	s1,88(sp)
    80006130:	e8ca                	sd	s2,80(sp)
    80006132:	e4ce                	sd	s3,72(sp)
    80006134:	e0d2                	sd	s4,64(sp)
    80006136:	fc56                	sd	s5,56(sp)
    80006138:	f85a                	sd	s6,48(sp)
    8000613a:	f45e                	sd	s7,40(sp)
    8000613c:	f062                	sd	s8,32(sp)
    8000613e:	ec66                	sd	s9,24(sp)
    80006140:	e86a                	sd	s10,16(sp)
    80006142:	1880                	addi	s0,sp,112
    80006144:	892a                	mv	s2,a0
    80006146:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006148:	00c52c83          	lw	s9,12(a0)
    8000614c:	001c9c9b          	slliw	s9,s9,0x1
    80006150:	1c82                	slli	s9,s9,0x20
    80006152:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006156:	0001c517          	auipc	a0,0x1c
    8000615a:	c0250513          	addi	a0,a0,-1022 # 80021d58 <disk+0x128>
    8000615e:	ffffb097          	auipc	ra,0xffffb
    80006162:	a8c080e7          	jalr	-1396(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006166:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006168:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000616a:	0001cb17          	auipc	s6,0x1c
    8000616e:	ac6b0b13          	addi	s6,s6,-1338 # 80021c30 <disk>
  for(int i = 0; i < 3; i++){
    80006172:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006174:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006176:	0001cc17          	auipc	s8,0x1c
    8000617a:	be2c0c13          	addi	s8,s8,-1054 # 80021d58 <disk+0x128>
    8000617e:	a8b5                	j	800061fa <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006180:	00fb06b3          	add	a3,s6,a5
    80006184:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006188:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000618a:	0207c563          	bltz	a5,800061b4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000618e:	2485                	addiw	s1,s1,1
    80006190:	0711                	addi	a4,a4,4
    80006192:	1f548a63          	beq	s1,s5,80006386 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006196:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006198:	0001c697          	auipc	a3,0x1c
    8000619c:	a9868693          	addi	a3,a3,-1384 # 80021c30 <disk>
    800061a0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800061a2:	0186c583          	lbu	a1,24(a3)
    800061a6:	fde9                	bnez	a1,80006180 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800061a8:	2785                	addiw	a5,a5,1
    800061aa:	0685                	addi	a3,a3,1
    800061ac:	ff779be3          	bne	a5,s7,800061a2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800061b0:	57fd                	li	a5,-1
    800061b2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800061b4:	02905a63          	blez	s1,800061e8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061b8:	f9042503          	lw	a0,-112(s0)
    800061bc:	00000097          	auipc	ra,0x0
    800061c0:	cfa080e7          	jalr	-774(ra) # 80005eb6 <free_desc>
      for(int j = 0; j < i; j++)
    800061c4:	4785                	li	a5,1
    800061c6:	0297d163          	bge	a5,s1,800061e8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061ca:	f9442503          	lw	a0,-108(s0)
    800061ce:	00000097          	auipc	ra,0x0
    800061d2:	ce8080e7          	jalr	-792(ra) # 80005eb6 <free_desc>
      for(int j = 0; j < i; j++)
    800061d6:	4789                	li	a5,2
    800061d8:	0097d863          	bge	a5,s1,800061e8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061dc:	f9842503          	lw	a0,-104(s0)
    800061e0:	00000097          	auipc	ra,0x0
    800061e4:	cd6080e7          	jalr	-810(ra) # 80005eb6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061e8:	85e2                	mv	a1,s8
    800061ea:	0001c517          	auipc	a0,0x1c
    800061ee:	a5e50513          	addi	a0,a0,-1442 # 80021c48 <disk+0x18>
    800061f2:	ffffc097          	auipc	ra,0xffffc
    800061f6:	ec6080e7          	jalr	-314(ra) # 800020b8 <sleep>
  for(int i = 0; i < 3; i++){
    800061fa:	f9040713          	addi	a4,s0,-112
    800061fe:	84ce                	mv	s1,s3
    80006200:	bf59                	j	80006196 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006202:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006206:	00479693          	slli	a3,a5,0x4
    8000620a:	0001c797          	auipc	a5,0x1c
    8000620e:	a2678793          	addi	a5,a5,-1498 # 80021c30 <disk>
    80006212:	97b6                	add	a5,a5,a3
    80006214:	4685                	li	a3,1
    80006216:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006218:	0001c597          	auipc	a1,0x1c
    8000621c:	a1858593          	addi	a1,a1,-1512 # 80021c30 <disk>
    80006220:	00a60793          	addi	a5,a2,10
    80006224:	0792                	slli	a5,a5,0x4
    80006226:	97ae                	add	a5,a5,a1
    80006228:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000622c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006230:	f6070693          	addi	a3,a4,-160
    80006234:	619c                	ld	a5,0(a1)
    80006236:	97b6                	add	a5,a5,a3
    80006238:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000623a:	6188                	ld	a0,0(a1)
    8000623c:	96aa                	add	a3,a3,a0
    8000623e:	47c1                	li	a5,16
    80006240:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006242:	4785                	li	a5,1
    80006244:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006248:	f9442783          	lw	a5,-108(s0)
    8000624c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006250:	0792                	slli	a5,a5,0x4
    80006252:	953e                	add	a0,a0,a5
    80006254:	05890693          	addi	a3,s2,88
    80006258:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000625a:	6188                	ld	a0,0(a1)
    8000625c:	97aa                	add	a5,a5,a0
    8000625e:	40000693          	li	a3,1024
    80006262:	c794                	sw	a3,8(a5)
  if(write)
    80006264:	100d0d63          	beqz	s10,8000637e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006268:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000626c:	00c7d683          	lhu	a3,12(a5)
    80006270:	0016e693          	ori	a3,a3,1
    80006274:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006278:	f9842583          	lw	a1,-104(s0)
    8000627c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006280:	0001c697          	auipc	a3,0x1c
    80006284:	9b068693          	addi	a3,a3,-1616 # 80021c30 <disk>
    80006288:	00260793          	addi	a5,a2,2
    8000628c:	0792                	slli	a5,a5,0x4
    8000628e:	97b6                	add	a5,a5,a3
    80006290:	587d                	li	a6,-1
    80006292:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006296:	0592                	slli	a1,a1,0x4
    80006298:	952e                	add	a0,a0,a1
    8000629a:	f9070713          	addi	a4,a4,-112
    8000629e:	9736                	add	a4,a4,a3
    800062a0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800062a2:	6298                	ld	a4,0(a3)
    800062a4:	972e                	add	a4,a4,a1
    800062a6:	4585                	li	a1,1
    800062a8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062aa:	4509                	li	a0,2
    800062ac:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800062b0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062b4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062b8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800062bc:	6698                	ld	a4,8(a3)
    800062be:	00275783          	lhu	a5,2(a4)
    800062c2:	8b9d                	andi	a5,a5,7
    800062c4:	0786                	slli	a5,a5,0x1
    800062c6:	97ba                	add	a5,a5,a4
    800062c8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800062cc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800062d0:	6698                	ld	a4,8(a3)
    800062d2:	00275783          	lhu	a5,2(a4)
    800062d6:	2785                	addiw	a5,a5,1
    800062d8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800062dc:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062e0:	100017b7          	lui	a5,0x10001
    800062e4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062e8:	00492703          	lw	a4,4(s2)
    800062ec:	4785                	li	a5,1
    800062ee:	02f71163          	bne	a4,a5,80006310 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800062f2:	0001c997          	auipc	s3,0x1c
    800062f6:	a6698993          	addi	s3,s3,-1434 # 80021d58 <disk+0x128>
  while(b->disk == 1) {
    800062fa:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800062fc:	85ce                	mv	a1,s3
    800062fe:	854a                	mv	a0,s2
    80006300:	ffffc097          	auipc	ra,0xffffc
    80006304:	db8080e7          	jalr	-584(ra) # 800020b8 <sleep>
  while(b->disk == 1) {
    80006308:	00492783          	lw	a5,4(s2)
    8000630c:	fe9788e3          	beq	a5,s1,800062fc <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006310:	f9042903          	lw	s2,-112(s0)
    80006314:	00290793          	addi	a5,s2,2
    80006318:	00479713          	slli	a4,a5,0x4
    8000631c:	0001c797          	auipc	a5,0x1c
    80006320:	91478793          	addi	a5,a5,-1772 # 80021c30 <disk>
    80006324:	97ba                	add	a5,a5,a4
    80006326:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000632a:	0001c997          	auipc	s3,0x1c
    8000632e:	90698993          	addi	s3,s3,-1786 # 80021c30 <disk>
    80006332:	00491713          	slli	a4,s2,0x4
    80006336:	0009b783          	ld	a5,0(s3)
    8000633a:	97ba                	add	a5,a5,a4
    8000633c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006340:	854a                	mv	a0,s2
    80006342:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006346:	00000097          	auipc	ra,0x0
    8000634a:	b70080e7          	jalr	-1168(ra) # 80005eb6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000634e:	8885                	andi	s1,s1,1
    80006350:	f0ed                	bnez	s1,80006332 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006352:	0001c517          	auipc	a0,0x1c
    80006356:	a0650513          	addi	a0,a0,-1530 # 80021d58 <disk+0x128>
    8000635a:	ffffb097          	auipc	ra,0xffffb
    8000635e:	944080e7          	jalr	-1724(ra) # 80000c9e <release>
}
    80006362:	70a6                	ld	ra,104(sp)
    80006364:	7406                	ld	s0,96(sp)
    80006366:	64e6                	ld	s1,88(sp)
    80006368:	6946                	ld	s2,80(sp)
    8000636a:	69a6                	ld	s3,72(sp)
    8000636c:	6a06                	ld	s4,64(sp)
    8000636e:	7ae2                	ld	s5,56(sp)
    80006370:	7b42                	ld	s6,48(sp)
    80006372:	7ba2                	ld	s7,40(sp)
    80006374:	7c02                	ld	s8,32(sp)
    80006376:	6ce2                	ld	s9,24(sp)
    80006378:	6d42                	ld	s10,16(sp)
    8000637a:	6165                	addi	sp,sp,112
    8000637c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000637e:	4689                	li	a3,2
    80006380:	00d79623          	sh	a3,12(a5)
    80006384:	b5e5                	j	8000626c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006386:	f9042603          	lw	a2,-112(s0)
    8000638a:	00a60713          	addi	a4,a2,10
    8000638e:	0712                	slli	a4,a4,0x4
    80006390:	0001c517          	auipc	a0,0x1c
    80006394:	8a850513          	addi	a0,a0,-1880 # 80021c38 <disk+0x8>
    80006398:	953a                	add	a0,a0,a4
  if(write)
    8000639a:	e60d14e3          	bnez	s10,80006202 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000639e:	00a60793          	addi	a5,a2,10
    800063a2:	00479693          	slli	a3,a5,0x4
    800063a6:	0001c797          	auipc	a5,0x1c
    800063aa:	88a78793          	addi	a5,a5,-1910 # 80021c30 <disk>
    800063ae:	97b6                	add	a5,a5,a3
    800063b0:	0007a423          	sw	zero,8(a5)
    800063b4:	b595                	j	80006218 <virtio_disk_rw+0xf0>

00000000800063b6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063b6:	1101                	addi	sp,sp,-32
    800063b8:	ec06                	sd	ra,24(sp)
    800063ba:	e822                	sd	s0,16(sp)
    800063bc:	e426                	sd	s1,8(sp)
    800063be:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063c0:	0001c497          	auipc	s1,0x1c
    800063c4:	87048493          	addi	s1,s1,-1936 # 80021c30 <disk>
    800063c8:	0001c517          	auipc	a0,0x1c
    800063cc:	99050513          	addi	a0,a0,-1648 # 80021d58 <disk+0x128>
    800063d0:	ffffb097          	auipc	ra,0xffffb
    800063d4:	81a080e7          	jalr	-2022(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063d8:	10001737          	lui	a4,0x10001
    800063dc:	533c                	lw	a5,96(a4)
    800063de:	8b8d                	andi	a5,a5,3
    800063e0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800063e2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063e6:	689c                	ld	a5,16(s1)
    800063e8:	0204d703          	lhu	a4,32(s1)
    800063ec:	0027d783          	lhu	a5,2(a5)
    800063f0:	04f70863          	beq	a4,a5,80006440 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800063f4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063f8:	6898                	ld	a4,16(s1)
    800063fa:	0204d783          	lhu	a5,32(s1)
    800063fe:	8b9d                	andi	a5,a5,7
    80006400:	078e                	slli	a5,a5,0x3
    80006402:	97ba                	add	a5,a5,a4
    80006404:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006406:	00278713          	addi	a4,a5,2
    8000640a:	0712                	slli	a4,a4,0x4
    8000640c:	9726                	add	a4,a4,s1
    8000640e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006412:	e721                	bnez	a4,8000645a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006414:	0789                	addi	a5,a5,2
    80006416:	0792                	slli	a5,a5,0x4
    80006418:	97a6                	add	a5,a5,s1
    8000641a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000641c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006420:	ffffc097          	auipc	ra,0xffffc
    80006424:	cfc080e7          	jalr	-772(ra) # 8000211c <wakeup>

    disk.used_idx += 1;
    80006428:	0204d783          	lhu	a5,32(s1)
    8000642c:	2785                	addiw	a5,a5,1
    8000642e:	17c2                	slli	a5,a5,0x30
    80006430:	93c1                	srli	a5,a5,0x30
    80006432:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006436:	6898                	ld	a4,16(s1)
    80006438:	00275703          	lhu	a4,2(a4)
    8000643c:	faf71ce3          	bne	a4,a5,800063f4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006440:	0001c517          	auipc	a0,0x1c
    80006444:	91850513          	addi	a0,a0,-1768 # 80021d58 <disk+0x128>
    80006448:	ffffb097          	auipc	ra,0xffffb
    8000644c:	856080e7          	jalr	-1962(ra) # 80000c9e <release>
}
    80006450:	60e2                	ld	ra,24(sp)
    80006452:	6442                	ld	s0,16(sp)
    80006454:	64a2                	ld	s1,8(sp)
    80006456:	6105                	addi	sp,sp,32
    80006458:	8082                	ret
      panic("virtio_disk_intr status");
    8000645a:	00002517          	auipc	a0,0x2
    8000645e:	3de50513          	addi	a0,a0,990 # 80008838 <syscalls+0x3e8>
    80006462:	ffffa097          	auipc	ra,0xffffa
    80006466:	0e2080e7          	jalr	226(ra) # 80000544 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
