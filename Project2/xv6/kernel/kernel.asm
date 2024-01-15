
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
    80000068:	d5c78793          	addi	a5,a5,-676 # 80005dc0 <timervec>
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
    80000130:	3a6080e7          	jalr	934(ra) # 800024d2 <either_copyin>
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
    800001c8:	80c080e7          	jalr	-2036(ra) # 800019d0 <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	150080e7          	jalr	336(ra) # 8000231c <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	e9a080e7          	jalr	-358(ra) # 80002074 <sleep>
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
    8000021a:	266080e7          	jalr	614(ra) # 8000247c <either_copyout>
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
    800002fc:	230080e7          	jalr	560(ra) # 80002528 <procdump>
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
    80000450:	c8c080e7          	jalr	-884(ra) # 800020d8 <wakeup>
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
    800008aa:	832080e7          	jalr	-1998(ra) # 800020d8 <wakeup>
    
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
    80000934:	744080e7          	jalr	1860(ra) # 80002074 <sleep>
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
    80000b88:	e30080e7          	jalr	-464(ra) # 800019b4 <mycpu>
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
    80000bba:	dfe080e7          	jalr	-514(ra) # 800019b4 <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	df2080e7          	jalr	-526(ra) # 800019b4 <mycpu>
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
    80000bde:	dda080e7          	jalr	-550(ra) # 800019b4 <mycpu>
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
    80000c1e:	d9a080e7          	jalr	-614(ra) # 800019b4 <mycpu>
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
    80000c4a:	d6e080e7          	jalr	-658(ra) # 800019b4 <mycpu>
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
    80000ea0:	b08080e7          	jalr	-1272(ra) # 800019a4 <cpuid>
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
    80000ebc:	aec080e7          	jalr	-1300(ra) # 800019a4 <cpuid>
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
    80000ede:	8b8080e7          	jalr	-1864(ra) # 80002792 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	f1e080e7          	jalr	-226(ra) # 80005e00 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	fd8080e7          	jalr	-40(ra) # 80001ec2 <scheduler>
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
    80000f56:	818080e7          	jalr	-2024(ra) # 8000276a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	838080e7          	jalr	-1992(ra) # 80002792 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	e88080e7          	jalr	-376(ra) # 80005dea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	e96080e7          	jalr	-362(ra) # 80005e00 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	042080e7          	jalr	66(ra) # 80002fb4 <binit>
    iinit();         // inode table
    80000f7a:	00002097          	auipc	ra,0x2
    80000f7e:	6e6080e7          	jalr	1766(ra) # 80003660 <iinit>
    fileinit();      // file table
    80000f82:	00003097          	auipc	ra,0x3
    80000f86:	684080e7          	jalr	1668(ra) # 80004606 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	f7e080e7          	jalr	-130(ra) # 80005f08 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	d16080e7          	jalr	-746(ra) # 80001ca8 <userinit>
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
    800018e6:	715d                	addi	sp,sp,-80
    800018e8:	e486                	sd	ra,72(sp)
    800018ea:	e0a2                	sd	s0,64(sp)
    800018ec:	fc26                	sd	s1,56(sp)
    800018ee:	f84a                	sd	s2,48(sp)
    800018f0:	f44e                	sd	s3,40(sp)
    800018f2:	f052                	sd	s4,32(sp)
    800018f4:	ec56                	sd	s5,24(sp)
    800018f6:	e85a                	sd	s6,16(sp)
    800018f8:	e45e                	sd	s7,8(sp)
    800018fa:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018fc:	00007597          	auipc	a1,0x7
    80001900:	8e458593          	addi	a1,a1,-1820 # 800081e0 <digits+0x1a0>
    80001904:	0000f517          	auipc	a0,0xf
    80001908:	25c50513          	addi	a0,a0,604 # 80010b60 <pid_lock>
    8000190c:	fffff097          	auipc	ra,0xfffff
    80001910:	24e080e7          	jalr	590(ra) # 80000b5a <initlock>
  initlock(&wait_lock, "wait_lock");
    80001914:	00007597          	auipc	a1,0x7
    80001918:	8d458593          	addi	a1,a1,-1836 # 800081e8 <digits+0x1a8>
    8000191c:	0000f517          	auipc	a0,0xf
    80001920:	25c50513          	addi	a0,a0,604 # 80010b78 <wait_lock>
    80001924:	fffff097          	auipc	ra,0xfffff
    80001928:	236080e7          	jalr	566(ra) # 80000b5a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192c:	0000f497          	auipc	s1,0xf
    80001930:	66448493          	addi	s1,s1,1636 # 80010f90 <proc>
      initlock(&p->lock, "proc");
    80001934:	00007b97          	auipc	s7,0x7
    80001938:	8c4b8b93          	addi	s7,s7,-1852 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000193c:	8b26                	mv	s6,s1
    8000193e:	00006a97          	auipc	s5,0x6
    80001942:	6c2a8a93          	addi	s5,s5,1730 # 80008000 <etext>
    80001946:	04000937          	lui	s2,0x4000
    8000194a:	197d                	addi	s2,s2,-1
    8000194c:	0932                	slli	s2,s2,0xc
      p->priority = DEFAULT_PRIORITY;       // set p->priority to default priority given
    8000194e:	4a29                	li	s4,10
  for(p = proc; p < &proc[NPROC]; p++) {
    80001950:	00015997          	auipc	s3,0x15
    80001954:	04098993          	addi	s3,s3,64 # 80016990 <tickslock>
      initlock(&p->lock, "proc");
    80001958:	85de                	mv	a1,s7
    8000195a:	8526                	mv	a0,s1
    8000195c:	fffff097          	auipc	ra,0xfffff
    80001960:	1fe080e7          	jalr	510(ra) # 80000b5a <initlock>
      p->state = UNUSED;
    80001964:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001968:	416487b3          	sub	a5,s1,s6
    8000196c:	878d                	srai	a5,a5,0x3
    8000196e:	000ab703          	ld	a4,0(s5)
    80001972:	02e787b3          	mul	a5,a5,a4
    80001976:	2785                	addiw	a5,a5,1
    80001978:	00d7979b          	slliw	a5,a5,0xd
    8000197c:	40f907b3          	sub	a5,s2,a5
    80001980:	e0bc                	sd	a5,64(s1)
      p->priority = DEFAULT_PRIORITY;       // set p->priority to default priority given
    80001982:	0344aa23          	sw	s4,52(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001986:	16848493          	addi	s1,s1,360
    8000198a:	fd3497e3          	bne	s1,s3,80001958 <procinit+0x72>
  }
}
    8000198e:	60a6                	ld	ra,72(sp)
    80001990:	6406                	ld	s0,64(sp)
    80001992:	74e2                	ld	s1,56(sp)
    80001994:	7942                	ld	s2,48(sp)
    80001996:	79a2                	ld	s3,40(sp)
    80001998:	7a02                	ld	s4,32(sp)
    8000199a:	6ae2                	ld	s5,24(sp)
    8000199c:	6b42                	ld	s6,16(sp)
    8000199e:	6ba2                	ld	s7,8(sp)
    800019a0:	6161                	addi	sp,sp,80
    800019a2:	8082                	ret

00000000800019a4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019a4:	1141                	addi	sp,sp,-16
    800019a6:	e422                	sd	s0,8(sp)
    800019a8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019aa:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019ac:	2501                	sext.w	a0,a0
    800019ae:	6422                	ld	s0,8(sp)
    800019b0:	0141                	addi	sp,sp,16
    800019b2:	8082                	ret

00000000800019b4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019b4:	1141                	addi	sp,sp,-16
    800019b6:	e422                	sd	s0,8(sp)
    800019b8:	0800                	addi	s0,sp,16
    800019ba:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019bc:	2781                	sext.w	a5,a5
    800019be:	079e                	slli	a5,a5,0x7
  return c;
}
    800019c0:	0000f517          	auipc	a0,0xf
    800019c4:	1d050513          	addi	a0,a0,464 # 80010b90 <cpus>
    800019c8:	953e                	add	a0,a0,a5
    800019ca:	6422                	ld	s0,8(sp)
    800019cc:	0141                	addi	sp,sp,16
    800019ce:	8082                	ret

00000000800019d0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019d0:	1101                	addi	sp,sp,-32
    800019d2:	ec06                	sd	ra,24(sp)
    800019d4:	e822                	sd	s0,16(sp)
    800019d6:	e426                	sd	s1,8(sp)
    800019d8:	1000                	addi	s0,sp,32
  push_off();
    800019da:	fffff097          	auipc	ra,0xfffff
    800019de:	1c4080e7          	jalr	452(ra) # 80000b9e <push_off>
    800019e2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019e4:	2781                	sext.w	a5,a5
    800019e6:	079e                	slli	a5,a5,0x7
    800019e8:	0000f717          	auipc	a4,0xf
    800019ec:	17870713          	addi	a4,a4,376 # 80010b60 <pid_lock>
    800019f0:	97ba                	add	a5,a5,a4
    800019f2:	7b84                	ld	s1,48(a5)
  pop_off();
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	24a080e7          	jalr	586(ra) # 80000c3e <pop_off>
  return p;
}
    800019fc:	8526                	mv	a0,s1
    800019fe:	60e2                	ld	ra,24(sp)
    80001a00:	6442                	ld	s0,16(sp)
    80001a02:	64a2                	ld	s1,8(sp)
    80001a04:	6105                	addi	sp,sp,32
    80001a06:	8082                	ret

0000000080001a08 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a08:	1141                	addi	sp,sp,-16
    80001a0a:	e406                	sd	ra,8(sp)
    80001a0c:	e022                	sd	s0,0(sp)
    80001a0e:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a10:	00000097          	auipc	ra,0x0
    80001a14:	fc0080e7          	jalr	-64(ra) # 800019d0 <myproc>
    80001a18:	fffff097          	auipc	ra,0xfffff
    80001a1c:	286080e7          	jalr	646(ra) # 80000c9e <release>

  if (first) {
    80001a20:	00007797          	auipc	a5,0x7
    80001a24:	e307a783          	lw	a5,-464(a5) # 80008850 <first.1698>
    80001a28:	eb89                	bnez	a5,80001a3a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a2a:	00001097          	auipc	ra,0x1
    80001a2e:	d80080e7          	jalr	-640(ra) # 800027aa <usertrapret>
}
    80001a32:	60a2                	ld	ra,8(sp)
    80001a34:	6402                	ld	s0,0(sp)
    80001a36:	0141                	addi	sp,sp,16
    80001a38:	8082                	ret
    first = 0;
    80001a3a:	00007797          	auipc	a5,0x7
    80001a3e:	e007ab23          	sw	zero,-490(a5) # 80008850 <first.1698>
    fsinit(ROOTDEV);
    80001a42:	4505                	li	a0,1
    80001a44:	00002097          	auipc	ra,0x2
    80001a48:	b9c080e7          	jalr	-1124(ra) # 800035e0 <fsinit>
    80001a4c:	bff9                	j	80001a2a <forkret+0x22>

0000000080001a4e <allocpid>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	e04a                	sd	s2,0(sp)
    80001a58:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a5a:	0000f917          	auipc	s2,0xf
    80001a5e:	10690913          	addi	s2,s2,262 # 80010b60 <pid_lock>
    80001a62:	854a                	mv	a0,s2
    80001a64:	fffff097          	auipc	ra,0xfffff
    80001a68:	186080e7          	jalr	390(ra) # 80000bea <acquire>
  pid = nextpid;
    80001a6c:	00007797          	auipc	a5,0x7
    80001a70:	de878793          	addi	a5,a5,-536 # 80008854 <nextpid>
    80001a74:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a76:	0014871b          	addiw	a4,s1,1
    80001a7a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a7c:	854a                	mv	a0,s2
    80001a7e:	fffff097          	auipc	ra,0xfffff
    80001a82:	220080e7          	jalr	544(ra) # 80000c9e <release>
}
    80001a86:	8526                	mv	a0,s1
    80001a88:	60e2                	ld	ra,24(sp)
    80001a8a:	6442                	ld	s0,16(sp)
    80001a8c:	64a2                	ld	s1,8(sp)
    80001a8e:	6902                	ld	s2,0(sp)
    80001a90:	6105                	addi	sp,sp,32
    80001a92:	8082                	ret

0000000080001a94 <proc_pagetable>:
{
    80001a94:	1101                	addi	sp,sp,-32
    80001a96:	ec06                	sd	ra,24(sp)
    80001a98:	e822                	sd	s0,16(sp)
    80001a9a:	e426                	sd	s1,8(sp)
    80001a9c:	e04a                	sd	s2,0(sp)
    80001a9e:	1000                	addi	s0,sp,32
    80001aa0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aa2:	00000097          	auipc	ra,0x0
    80001aa6:	8a2080e7          	jalr	-1886(ra) # 80001344 <uvmcreate>
    80001aaa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aac:	c121                	beqz	a0,80001aec <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aae:	4729                	li	a4,10
    80001ab0:	00005697          	auipc	a3,0x5
    80001ab4:	55068693          	addi	a3,a3,1360 # 80007000 <_trampoline>
    80001ab8:	6605                	lui	a2,0x1
    80001aba:	040005b7          	lui	a1,0x4000
    80001abe:	15fd                	addi	a1,a1,-1
    80001ac0:	05b2                	slli	a1,a1,0xc
    80001ac2:	fffff097          	auipc	ra,0xfffff
    80001ac6:	5f8080e7          	jalr	1528(ra) # 800010ba <mappages>
    80001aca:	02054863          	bltz	a0,80001afa <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ace:	4719                	li	a4,6
    80001ad0:	05893683          	ld	a3,88(s2)
    80001ad4:	6605                	lui	a2,0x1
    80001ad6:	020005b7          	lui	a1,0x2000
    80001ada:	15fd                	addi	a1,a1,-1
    80001adc:	05b6                	slli	a1,a1,0xd
    80001ade:	8526                	mv	a0,s1
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	5da080e7          	jalr	1498(ra) # 800010ba <mappages>
    80001ae8:	02054163          	bltz	a0,80001b0a <proc_pagetable+0x76>
}
    80001aec:	8526                	mv	a0,s1
    80001aee:	60e2                	ld	ra,24(sp)
    80001af0:	6442                	ld	s0,16(sp)
    80001af2:	64a2                	ld	s1,8(sp)
    80001af4:	6902                	ld	s2,0(sp)
    80001af6:	6105                	addi	sp,sp,32
    80001af8:	8082                	ret
    uvmfree(pagetable, 0);
    80001afa:	4581                	li	a1,0
    80001afc:	8526                	mv	a0,s1
    80001afe:	00000097          	auipc	ra,0x0
    80001b02:	a4a080e7          	jalr	-1462(ra) # 80001548 <uvmfree>
    return 0;
    80001b06:	4481                	li	s1,0
    80001b08:	b7d5                	j	80001aec <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b0a:	4681                	li	a3,0
    80001b0c:	4605                	li	a2,1
    80001b0e:	040005b7          	lui	a1,0x4000
    80001b12:	15fd                	addi	a1,a1,-1
    80001b14:	05b2                	slli	a1,a1,0xc
    80001b16:	8526                	mv	a0,s1
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	768080e7          	jalr	1896(ra) # 80001280 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b20:	4581                	li	a1,0
    80001b22:	8526                	mv	a0,s1
    80001b24:	00000097          	auipc	ra,0x0
    80001b28:	a24080e7          	jalr	-1500(ra) # 80001548 <uvmfree>
    return 0;
    80001b2c:	4481                	li	s1,0
    80001b2e:	bf7d                	j	80001aec <proc_pagetable+0x58>

0000000080001b30 <proc_freepagetable>:
{
    80001b30:	1101                	addi	sp,sp,-32
    80001b32:	ec06                	sd	ra,24(sp)
    80001b34:	e822                	sd	s0,16(sp)
    80001b36:	e426                	sd	s1,8(sp)
    80001b38:	e04a                	sd	s2,0(sp)
    80001b3a:	1000                	addi	s0,sp,32
    80001b3c:	84aa                	mv	s1,a0
    80001b3e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b40:	4681                	li	a3,0
    80001b42:	4605                	li	a2,1
    80001b44:	040005b7          	lui	a1,0x4000
    80001b48:	15fd                	addi	a1,a1,-1
    80001b4a:	05b2                	slli	a1,a1,0xc
    80001b4c:	fffff097          	auipc	ra,0xfffff
    80001b50:	734080e7          	jalr	1844(ra) # 80001280 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b54:	4681                	li	a3,0
    80001b56:	4605                	li	a2,1
    80001b58:	020005b7          	lui	a1,0x2000
    80001b5c:	15fd                	addi	a1,a1,-1
    80001b5e:	05b6                	slli	a1,a1,0xd
    80001b60:	8526                	mv	a0,s1
    80001b62:	fffff097          	auipc	ra,0xfffff
    80001b66:	71e080e7          	jalr	1822(ra) # 80001280 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b6a:	85ca                	mv	a1,s2
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	00000097          	auipc	ra,0x0
    80001b72:	9da080e7          	jalr	-1574(ra) # 80001548 <uvmfree>
}
    80001b76:	60e2                	ld	ra,24(sp)
    80001b78:	6442                	ld	s0,16(sp)
    80001b7a:	64a2                	ld	s1,8(sp)
    80001b7c:	6902                	ld	s2,0(sp)
    80001b7e:	6105                	addi	sp,sp,32
    80001b80:	8082                	ret

0000000080001b82 <freeproc>:
{
    80001b82:	1101                	addi	sp,sp,-32
    80001b84:	ec06                	sd	ra,24(sp)
    80001b86:	e822                	sd	s0,16(sp)
    80001b88:	e426                	sd	s1,8(sp)
    80001b8a:	1000                	addi	s0,sp,32
    80001b8c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b8e:	6d28                	ld	a0,88(a0)
    80001b90:	c509                	beqz	a0,80001b9a <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	e6c080e7          	jalr	-404(ra) # 800009fe <kfree>
  p->trapframe = 0;
    80001b9a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b9e:	68a8                	ld	a0,80(s1)
    80001ba0:	c511                	beqz	a0,80001bac <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ba2:	64ac                	ld	a1,72(s1)
    80001ba4:	00000097          	auipc	ra,0x0
    80001ba8:	f8c080e7          	jalr	-116(ra) # 80001b30 <proc_freepagetable>
  p->pagetable = 0;
    80001bac:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bb0:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bb4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bb8:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bbc:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bc0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bc4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bc8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bcc:	0004ac23          	sw	zero,24(s1)
}
    80001bd0:	60e2                	ld	ra,24(sp)
    80001bd2:	6442                	ld	s0,16(sp)
    80001bd4:	64a2                	ld	s1,8(sp)
    80001bd6:	6105                	addi	sp,sp,32
    80001bd8:	8082                	ret

0000000080001bda <allocproc>:
{
    80001bda:	1101                	addi	sp,sp,-32
    80001bdc:	ec06                	sd	ra,24(sp)
    80001bde:	e822                	sd	s0,16(sp)
    80001be0:	e426                	sd	s1,8(sp)
    80001be2:	e04a                	sd	s2,0(sp)
    80001be4:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be6:	0000f497          	auipc	s1,0xf
    80001bea:	3aa48493          	addi	s1,s1,938 # 80010f90 <proc>
    80001bee:	00015917          	auipc	s2,0x15
    80001bf2:	da290913          	addi	s2,s2,-606 # 80016990 <tickslock>
    acquire(&p->lock);
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	fffff097          	auipc	ra,0xfffff
    80001bfc:	ff2080e7          	jalr	-14(ra) # 80000bea <acquire>
    if(p->state == UNUSED) {
    80001c00:	4c9c                	lw	a5,24(s1)
    80001c02:	cf81                	beqz	a5,80001c1a <allocproc+0x40>
      release(&p->lock);
    80001c04:	8526                	mv	a0,s1
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	098080e7          	jalr	152(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c0e:	16848493          	addi	s1,s1,360
    80001c12:	ff2492e3          	bne	s1,s2,80001bf6 <allocproc+0x1c>
  return 0;
    80001c16:	4481                	li	s1,0
    80001c18:	a889                	j	80001c6a <allocproc+0x90>
  p->pid = allocpid();
    80001c1a:	00000097          	auipc	ra,0x0
    80001c1e:	e34080e7          	jalr	-460(ra) # 80001a4e <allocpid>
    80001c22:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c24:	4785                	li	a5,1
    80001c26:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	ed2080e7          	jalr	-302(ra) # 80000afa <kalloc>
    80001c30:	892a                	mv	s2,a0
    80001c32:	eca8                	sd	a0,88(s1)
    80001c34:	c131                	beqz	a0,80001c78 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c36:	8526                	mv	a0,s1
    80001c38:	00000097          	auipc	ra,0x0
    80001c3c:	e5c080e7          	jalr	-420(ra) # 80001a94 <proc_pagetable>
    80001c40:	892a                	mv	s2,a0
    80001c42:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c44:	c531                	beqz	a0,80001c90 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c46:	07000613          	li	a2,112
    80001c4a:	4581                	li	a1,0
    80001c4c:	06048513          	addi	a0,s1,96
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	096080e7          	jalr	150(ra) # 80000ce6 <memset>
  p->context.ra = (uint64)forkret;
    80001c58:	00000797          	auipc	a5,0x0
    80001c5c:	db078793          	addi	a5,a5,-592 # 80001a08 <forkret>
    80001c60:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c62:	60bc                	ld	a5,64(s1)
    80001c64:	6705                	lui	a4,0x1
    80001c66:	97ba                	add	a5,a5,a4
    80001c68:	f4bc                	sd	a5,104(s1)
}
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	60e2                	ld	ra,24(sp)
    80001c6e:	6442                	ld	s0,16(sp)
    80001c70:	64a2                	ld	s1,8(sp)
    80001c72:	6902                	ld	s2,0(sp)
    80001c74:	6105                	addi	sp,sp,32
    80001c76:	8082                	ret
    freeproc(p);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	00000097          	auipc	ra,0x0
    80001c7e:	f08080e7          	jalr	-248(ra) # 80001b82 <freeproc>
    release(&p->lock);
    80001c82:	8526                	mv	a0,s1
    80001c84:	fffff097          	auipc	ra,0xfffff
    80001c88:	01a080e7          	jalr	26(ra) # 80000c9e <release>
    return 0;
    80001c8c:	84ca                	mv	s1,s2
    80001c8e:	bff1                	j	80001c6a <allocproc+0x90>
    freeproc(p);
    80001c90:	8526                	mv	a0,s1
    80001c92:	00000097          	auipc	ra,0x0
    80001c96:	ef0080e7          	jalr	-272(ra) # 80001b82 <freeproc>
    release(&p->lock);
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	002080e7          	jalr	2(ra) # 80000c9e <release>
    return 0;
    80001ca4:	84ca                	mv	s1,s2
    80001ca6:	b7d1                	j	80001c6a <allocproc+0x90>

0000000080001ca8 <userinit>:
{
    80001ca8:	1101                	addi	sp,sp,-32
    80001caa:	ec06                	sd	ra,24(sp)
    80001cac:	e822                	sd	s0,16(sp)
    80001cae:	e426                	sd	s1,8(sp)
    80001cb0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	f28080e7          	jalr	-216(ra) # 80001bda <allocproc>
    80001cba:	84aa                	mv	s1,a0
  initproc = p;
    80001cbc:	00007797          	auipc	a5,0x7
    80001cc0:	c2a7b623          	sd	a0,-980(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cc4:	03400613          	li	a2,52
    80001cc8:	00007597          	auipc	a1,0x7
    80001ccc:	b9858593          	addi	a1,a1,-1128 # 80008860 <initcode>
    80001cd0:	6928                	ld	a0,80(a0)
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	6a0080e7          	jalr	1696(ra) # 80001372 <uvmfirst>
  p->sz = PGSIZE;
    80001cda:	6785                	lui	a5,0x1
    80001cdc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cde:	6cb8                	ld	a4,88(s1)
    80001ce0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ce4:	6cb8                	ld	a4,88(s1)
    80001ce6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce8:	4641                	li	a2,16
    80001cea:	00006597          	auipc	a1,0x6
    80001cee:	51658593          	addi	a1,a1,1302 # 80008200 <digits+0x1c0>
    80001cf2:	15848513          	addi	a0,s1,344
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	142080e7          	jalr	322(ra) # 80000e38 <safestrcpy>
  p->cwd = namei("/");
    80001cfe:	00006517          	auipc	a0,0x6
    80001d02:	51250513          	addi	a0,a0,1298 # 80008210 <digits+0x1d0>
    80001d06:	00002097          	auipc	ra,0x2
    80001d0a:	2fc080e7          	jalr	764(ra) # 80004002 <namei>
    80001d0e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d12:	478d                	li	a5,3
    80001d14:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d16:	8526                	mv	a0,s1
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	f86080e7          	jalr	-122(ra) # 80000c9e <release>
}
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6105                	addi	sp,sp,32
    80001d28:	8082                	ret

0000000080001d2a <growproc>:
{
    80001d2a:	1101                	addi	sp,sp,-32
    80001d2c:	ec06                	sd	ra,24(sp)
    80001d2e:	e822                	sd	s0,16(sp)
    80001d30:	e426                	sd	s1,8(sp)
    80001d32:	e04a                	sd	s2,0(sp)
    80001d34:	1000                	addi	s0,sp,32
    80001d36:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d38:	00000097          	auipc	ra,0x0
    80001d3c:	c98080e7          	jalr	-872(ra) # 800019d0 <myproc>
    80001d40:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d42:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d44:	01204c63          	bgtz	s2,80001d5c <growproc+0x32>
  } else if(n < 0){
    80001d48:	02094663          	bltz	s2,80001d74 <growproc+0x4a>
  p->sz = sz;
    80001d4c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d4e:	4501                	li	a0,0
}
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6902                	ld	s2,0(sp)
    80001d58:	6105                	addi	sp,sp,32
    80001d5a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d5c:	4691                	li	a3,4
    80001d5e:	00b90633          	add	a2,s2,a1
    80001d62:	6928                	ld	a0,80(a0)
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	6c8080e7          	jalr	1736(ra) # 8000142c <uvmalloc>
    80001d6c:	85aa                	mv	a1,a0
    80001d6e:	fd79                	bnez	a0,80001d4c <growproc+0x22>
      return -1;
    80001d70:	557d                	li	a0,-1
    80001d72:	bff9                	j	80001d50 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d74:	00b90633          	add	a2,s2,a1
    80001d78:	6928                	ld	a0,80(a0)
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	66a080e7          	jalr	1642(ra) # 800013e4 <uvmdealloc>
    80001d82:	85aa                	mv	a1,a0
    80001d84:	b7e1                	j	80001d4c <growproc+0x22>

0000000080001d86 <fork>:
{
    80001d86:	7179                	addi	sp,sp,-48
    80001d88:	f406                	sd	ra,40(sp)
    80001d8a:	f022                	sd	s0,32(sp)
    80001d8c:	ec26                	sd	s1,24(sp)
    80001d8e:	e84a                	sd	s2,16(sp)
    80001d90:	e44e                	sd	s3,8(sp)
    80001d92:	e052                	sd	s4,0(sp)
    80001d94:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001d96:	00000097          	auipc	ra,0x0
    80001d9a:	c3a080e7          	jalr	-966(ra) # 800019d0 <myproc>
    80001d9e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001da0:	00000097          	auipc	ra,0x0
    80001da4:	e3a080e7          	jalr	-454(ra) # 80001bda <allocproc>
    80001da8:	10050b63          	beqz	a0,80001ebe <fork+0x138>
    80001dac:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dae:	04893603          	ld	a2,72(s2)
    80001db2:	692c                	ld	a1,80(a0)
    80001db4:	05093503          	ld	a0,80(s2)
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	7c8080e7          	jalr	1992(ra) # 80001580 <uvmcopy>
    80001dc0:	04054663          	bltz	a0,80001e0c <fork+0x86>
  np->sz = p->sz;
    80001dc4:	04893783          	ld	a5,72(s2)
    80001dc8:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dcc:	05893683          	ld	a3,88(s2)
    80001dd0:	87b6                	mv	a5,a3
    80001dd2:	0589b703          	ld	a4,88(s3)
    80001dd6:	12068693          	addi	a3,a3,288
    80001dda:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dde:	6788                	ld	a0,8(a5)
    80001de0:	6b8c                	ld	a1,16(a5)
    80001de2:	6f90                	ld	a2,24(a5)
    80001de4:	01073023          	sd	a6,0(a4)
    80001de8:	e708                	sd	a0,8(a4)
    80001dea:	eb0c                	sd	a1,16(a4)
    80001dec:	ef10                	sd	a2,24(a4)
    80001dee:	02078793          	addi	a5,a5,32
    80001df2:	02070713          	addi	a4,a4,32
    80001df6:	fed792e3          	bne	a5,a3,80001dda <fork+0x54>
  np->trapframe->a0 = 0;
    80001dfa:	0589b783          	ld	a5,88(s3)
    80001dfe:	0607b823          	sd	zero,112(a5)
    80001e02:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e06:	15000a13          	li	s4,336
    80001e0a:	a03d                	j	80001e38 <fork+0xb2>
    freeproc(np);
    80001e0c:	854e                	mv	a0,s3
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	d74080e7          	jalr	-652(ra) # 80001b82 <freeproc>
    release(&np->lock);
    80001e16:	854e                	mv	a0,s3
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	e86080e7          	jalr	-378(ra) # 80000c9e <release>
    return -1;
    80001e20:	5a7d                	li	s4,-1
    80001e22:	a069                	j	80001eac <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e24:	00003097          	auipc	ra,0x3
    80001e28:	874080e7          	jalr	-1932(ra) # 80004698 <filedup>
    80001e2c:	009987b3          	add	a5,s3,s1
    80001e30:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e32:	04a1                	addi	s1,s1,8
    80001e34:	01448763          	beq	s1,s4,80001e42 <fork+0xbc>
    if(p->ofile[i])
    80001e38:	009907b3          	add	a5,s2,s1
    80001e3c:	6388                	ld	a0,0(a5)
    80001e3e:	f17d                	bnez	a0,80001e24 <fork+0x9e>
    80001e40:	bfcd                	j	80001e32 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e42:	15093503          	ld	a0,336(s2)
    80001e46:	00002097          	auipc	ra,0x2
    80001e4a:	9d8080e7          	jalr	-1576(ra) # 8000381e <idup>
    80001e4e:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e52:	4641                	li	a2,16
    80001e54:	15890593          	addi	a1,s2,344
    80001e58:	15898513          	addi	a0,s3,344
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	fdc080e7          	jalr	-36(ra) # 80000e38 <safestrcpy>
  pid = np->pid;
    80001e64:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001e68:	854e                	mv	a0,s3
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	e34080e7          	jalr	-460(ra) # 80000c9e <release>
  acquire(&wait_lock);
    80001e72:	0000f497          	auipc	s1,0xf
    80001e76:	d0648493          	addi	s1,s1,-762 # 80010b78 <wait_lock>
    80001e7a:	8526                	mv	a0,s1
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	d6e080e7          	jalr	-658(ra) # 80000bea <acquire>
  np->parent = p;
    80001e84:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001e88:	8526                	mv	a0,s1
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e14080e7          	jalr	-492(ra) # 80000c9e <release>
  acquire(&np->lock);
    80001e92:	854e                	mv	a0,s3
    80001e94:	fffff097          	auipc	ra,0xfffff
    80001e98:	d56080e7          	jalr	-682(ra) # 80000bea <acquire>
  np->state = RUNNABLE;
    80001e9c:	478d                	li	a5,3
    80001e9e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ea2:	854e                	mv	a0,s3
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	dfa080e7          	jalr	-518(ra) # 80000c9e <release>
}
    80001eac:	8552                	mv	a0,s4
    80001eae:	70a2                	ld	ra,40(sp)
    80001eb0:	7402                	ld	s0,32(sp)
    80001eb2:	64e2                	ld	s1,24(sp)
    80001eb4:	6942                	ld	s2,16(sp)
    80001eb6:	69a2                	ld	s3,8(sp)
    80001eb8:	6a02                	ld	s4,0(sp)
    80001eba:	6145                	addi	sp,sp,48
    80001ebc:	8082                	ret
    return -1;
    80001ebe:	5a7d                	li	s4,-1
    80001ec0:	b7f5                	j	80001eac <fork+0x126>

0000000080001ec2 <scheduler>:
{
    80001ec2:	7139                	addi	sp,sp,-64
    80001ec4:	fc06                	sd	ra,56(sp)
    80001ec6:	f822                	sd	s0,48(sp)
    80001ec8:	f426                	sd	s1,40(sp)
    80001eca:	f04a                	sd	s2,32(sp)
    80001ecc:	ec4e                	sd	s3,24(sp)
    80001ece:	e852                	sd	s4,16(sp)
    80001ed0:	e456                	sd	s5,8(sp)
    80001ed2:	e05a                	sd	s6,0(sp)
    80001ed4:	0080                	addi	s0,sp,64
    80001ed6:	8792                	mv	a5,tp
  int id = r_tp();
    80001ed8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eda:	00779a93          	slli	s5,a5,0x7
    80001ede:	0000f717          	auipc	a4,0xf
    80001ee2:	c8270713          	addi	a4,a4,-894 # 80010b60 <pid_lock>
    80001ee6:	9756                	add	a4,a4,s5
    80001ee8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001eec:	0000f717          	auipc	a4,0xf
    80001ef0:	cac70713          	addi	a4,a4,-852 # 80010b98 <cpus+0x8>
    80001ef4:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ef6:	498d                	li	s3,3
        p->state = RUNNING;
    80001ef8:	4b11                	li	s6,4
        c->proc = p;
    80001efa:	079e                	slli	a5,a5,0x7
    80001efc:	0000fa17          	auipc	s4,0xf
    80001f00:	c64a0a13          	addi	s4,s4,-924 # 80010b60 <pid_lock>
    80001f04:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f06:	00015917          	auipc	s2,0x15
    80001f0a:	a8a90913          	addi	s2,s2,-1398 # 80016990 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f12:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f16:	10079073          	csrw	sstatus,a5
    80001f1a:	0000f497          	auipc	s1,0xf
    80001f1e:	07648493          	addi	s1,s1,118 # 80010f90 <proc>
    80001f22:	a03d                	j	80001f50 <scheduler+0x8e>
        p->state = RUNNING;
    80001f24:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f28:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f2c:	06048593          	addi	a1,s1,96
    80001f30:	8556                	mv	a0,s5
    80001f32:	00000097          	auipc	ra,0x0
    80001f36:	7ce080e7          	jalr	1998(ra) # 80002700 <swtch>
        c->proc = 0;
    80001f3a:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001f3e:	8526                	mv	a0,s1
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	d5e080e7          	jalr	-674(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f48:	16848493          	addi	s1,s1,360
    80001f4c:	fd2481e3          	beq	s1,s2,80001f0e <scheduler+0x4c>
      acquire(&p->lock);
    80001f50:	8526                	mv	a0,s1
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	c98080e7          	jalr	-872(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE) {
    80001f5a:	4c9c                	lw	a5,24(s1)
    80001f5c:	ff3791e3          	bne	a5,s3,80001f3e <scheduler+0x7c>
    80001f60:	b7d1                	j	80001f24 <scheduler+0x62>

0000000080001f62 <sched>:
{
    80001f62:	7179                	addi	sp,sp,-48
    80001f64:	f406                	sd	ra,40(sp)
    80001f66:	f022                	sd	s0,32(sp)
    80001f68:	ec26                	sd	s1,24(sp)
    80001f6a:	e84a                	sd	s2,16(sp)
    80001f6c:	e44e                	sd	s3,8(sp)
    80001f6e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f70:	00000097          	auipc	ra,0x0
    80001f74:	a60080e7          	jalr	-1440(ra) # 800019d0 <myproc>
    80001f78:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	bf6080e7          	jalr	-1034(ra) # 80000b70 <holding>
    80001f82:	c93d                	beqz	a0,80001ff8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f84:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f86:	2781                	sext.w	a5,a5
    80001f88:	079e                	slli	a5,a5,0x7
    80001f8a:	0000f717          	auipc	a4,0xf
    80001f8e:	bd670713          	addi	a4,a4,-1066 # 80010b60 <pid_lock>
    80001f92:	97ba                	add	a5,a5,a4
    80001f94:	0a87a703          	lw	a4,168(a5)
    80001f98:	4785                	li	a5,1
    80001f9a:	06f71763          	bne	a4,a5,80002008 <sched+0xa6>
  if(p->state == RUNNING)
    80001f9e:	4c98                	lw	a4,24(s1)
    80001fa0:	4791                	li	a5,4
    80001fa2:	06f70b63          	beq	a4,a5,80002018 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001faa:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fac:	efb5                	bnez	a5,80002028 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fae:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fb0:	0000f917          	auipc	s2,0xf
    80001fb4:	bb090913          	addi	s2,s2,-1104 # 80010b60 <pid_lock>
    80001fb8:	2781                	sext.w	a5,a5
    80001fba:	079e                	slli	a5,a5,0x7
    80001fbc:	97ca                	add	a5,a5,s2
    80001fbe:	0ac7a983          	lw	s3,172(a5)
    80001fc2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fc4:	2781                	sext.w	a5,a5
    80001fc6:	079e                	slli	a5,a5,0x7
    80001fc8:	0000f597          	auipc	a1,0xf
    80001fcc:	bd058593          	addi	a1,a1,-1072 # 80010b98 <cpus+0x8>
    80001fd0:	95be                	add	a1,a1,a5
    80001fd2:	06048513          	addi	a0,s1,96
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	72a080e7          	jalr	1834(ra) # 80002700 <swtch>
    80001fde:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fe0:	2781                	sext.w	a5,a5
    80001fe2:	079e                	slli	a5,a5,0x7
    80001fe4:	97ca                	add	a5,a5,s2
    80001fe6:	0b37a623          	sw	s3,172(a5)
}
    80001fea:	70a2                	ld	ra,40(sp)
    80001fec:	7402                	ld	s0,32(sp)
    80001fee:	64e2                	ld	s1,24(sp)
    80001ff0:	6942                	ld	s2,16(sp)
    80001ff2:	69a2                	ld	s3,8(sp)
    80001ff4:	6145                	addi	sp,sp,48
    80001ff6:	8082                	ret
    panic("sched p->lock");
    80001ff8:	00006517          	auipc	a0,0x6
    80001ffc:	22050513          	addi	a0,a0,544 # 80008218 <digits+0x1d8>
    80002000:	ffffe097          	auipc	ra,0xffffe
    80002004:	544080e7          	jalr	1348(ra) # 80000544 <panic>
    panic("sched locks");
    80002008:	00006517          	auipc	a0,0x6
    8000200c:	22050513          	addi	a0,a0,544 # 80008228 <digits+0x1e8>
    80002010:	ffffe097          	auipc	ra,0xffffe
    80002014:	534080e7          	jalr	1332(ra) # 80000544 <panic>
    panic("sched running");
    80002018:	00006517          	auipc	a0,0x6
    8000201c:	22050513          	addi	a0,a0,544 # 80008238 <digits+0x1f8>
    80002020:	ffffe097          	auipc	ra,0xffffe
    80002024:	524080e7          	jalr	1316(ra) # 80000544 <panic>
    panic("sched interruptible");
    80002028:	00006517          	auipc	a0,0x6
    8000202c:	22050513          	addi	a0,a0,544 # 80008248 <digits+0x208>
    80002030:	ffffe097          	auipc	ra,0xffffe
    80002034:	514080e7          	jalr	1300(ra) # 80000544 <panic>

0000000080002038 <yield>:
{
    80002038:	1101                	addi	sp,sp,-32
    8000203a:	ec06                	sd	ra,24(sp)
    8000203c:	e822                	sd	s0,16(sp)
    8000203e:	e426                	sd	s1,8(sp)
    80002040:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002042:	00000097          	auipc	ra,0x0
    80002046:	98e080e7          	jalr	-1650(ra) # 800019d0 <myproc>
    8000204a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	b9e080e7          	jalr	-1122(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    80002054:	478d                	li	a5,3
    80002056:	cc9c                	sw	a5,24(s1)
  sched();
    80002058:	00000097          	auipc	ra,0x0
    8000205c:	f0a080e7          	jalr	-246(ra) # 80001f62 <sched>
  release(&p->lock);
    80002060:	8526                	mv	a0,s1
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	c3c080e7          	jalr	-964(ra) # 80000c9e <release>
}
    8000206a:	60e2                	ld	ra,24(sp)
    8000206c:	6442                	ld	s0,16(sp)
    8000206e:	64a2                	ld	s1,8(sp)
    80002070:	6105                	addi	sp,sp,32
    80002072:	8082                	ret

0000000080002074 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002074:	7179                	addi	sp,sp,-48
    80002076:	f406                	sd	ra,40(sp)
    80002078:	f022                	sd	s0,32(sp)
    8000207a:	ec26                	sd	s1,24(sp)
    8000207c:	e84a                	sd	s2,16(sp)
    8000207e:	e44e                	sd	s3,8(sp)
    80002080:	1800                	addi	s0,sp,48
    80002082:	89aa                	mv	s3,a0
    80002084:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002086:	00000097          	auipc	ra,0x0
    8000208a:	94a080e7          	jalr	-1718(ra) # 800019d0 <myproc>
    8000208e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	b5a080e7          	jalr	-1190(ra) # 80000bea <acquire>
  release(lk);
    80002098:	854a                	mv	a0,s2
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	c04080e7          	jalr	-1020(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    800020a2:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020a6:	4789                	li	a5,2
    800020a8:	cc9c                	sw	a5,24(s1)

  sched();
    800020aa:	00000097          	auipc	ra,0x0
    800020ae:	eb8080e7          	jalr	-328(ra) # 80001f62 <sched>

  // Tidy up.
  p->chan = 0;
    800020b2:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020b6:	8526                	mv	a0,s1
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	be6080e7          	jalr	-1050(ra) # 80000c9e <release>
  acquire(lk);
    800020c0:	854a                	mv	a0,s2
    800020c2:	fffff097          	auipc	ra,0xfffff
    800020c6:	b28080e7          	jalr	-1240(ra) # 80000bea <acquire>
}
    800020ca:	70a2                	ld	ra,40(sp)
    800020cc:	7402                	ld	s0,32(sp)
    800020ce:	64e2                	ld	s1,24(sp)
    800020d0:	6942                	ld	s2,16(sp)
    800020d2:	69a2                	ld	s3,8(sp)
    800020d4:	6145                	addi	sp,sp,48
    800020d6:	8082                	ret

00000000800020d8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020d8:	7139                	addi	sp,sp,-64
    800020da:	fc06                	sd	ra,56(sp)
    800020dc:	f822                	sd	s0,48(sp)
    800020de:	f426                	sd	s1,40(sp)
    800020e0:	f04a                	sd	s2,32(sp)
    800020e2:	ec4e                	sd	s3,24(sp)
    800020e4:	e852                	sd	s4,16(sp)
    800020e6:	e456                	sd	s5,8(sp)
    800020e8:	0080                	addi	s0,sp,64
    800020ea:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020ec:	0000f497          	auipc	s1,0xf
    800020f0:	ea448493          	addi	s1,s1,-348 # 80010f90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020f4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020f6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020f8:	00015917          	auipc	s2,0x15
    800020fc:	89890913          	addi	s2,s2,-1896 # 80016990 <tickslock>
    80002100:	a821                	j	80002118 <wakeup+0x40>
        p->state = RUNNABLE;
    80002102:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002106:	8526                	mv	a0,s1
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	b96080e7          	jalr	-1130(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002110:	16848493          	addi	s1,s1,360
    80002114:	03248463          	beq	s1,s2,8000213c <wakeup+0x64>
    if(p != myproc()){
    80002118:	00000097          	auipc	ra,0x0
    8000211c:	8b8080e7          	jalr	-1864(ra) # 800019d0 <myproc>
    80002120:	fea488e3          	beq	s1,a0,80002110 <wakeup+0x38>
      acquire(&p->lock);
    80002124:	8526                	mv	a0,s1
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	ac4080e7          	jalr	-1340(ra) # 80000bea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000212e:	4c9c                	lw	a5,24(s1)
    80002130:	fd379be3          	bne	a5,s3,80002106 <wakeup+0x2e>
    80002134:	709c                	ld	a5,32(s1)
    80002136:	fd4798e3          	bne	a5,s4,80002106 <wakeup+0x2e>
    8000213a:	b7e1                	j	80002102 <wakeup+0x2a>
    }
  }
}
    8000213c:	70e2                	ld	ra,56(sp)
    8000213e:	7442                	ld	s0,48(sp)
    80002140:	74a2                	ld	s1,40(sp)
    80002142:	7902                	ld	s2,32(sp)
    80002144:	69e2                	ld	s3,24(sp)
    80002146:	6a42                	ld	s4,16(sp)
    80002148:	6aa2                	ld	s5,8(sp)
    8000214a:	6121                	addi	sp,sp,64
    8000214c:	8082                	ret

000000008000214e <reparent>:
{
    8000214e:	7179                	addi	sp,sp,-48
    80002150:	f406                	sd	ra,40(sp)
    80002152:	f022                	sd	s0,32(sp)
    80002154:	ec26                	sd	s1,24(sp)
    80002156:	e84a                	sd	s2,16(sp)
    80002158:	e44e                	sd	s3,8(sp)
    8000215a:	e052                	sd	s4,0(sp)
    8000215c:	1800                	addi	s0,sp,48
    8000215e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002160:	0000f497          	auipc	s1,0xf
    80002164:	e3048493          	addi	s1,s1,-464 # 80010f90 <proc>
      pp->parent = initproc;
    80002168:	00006a17          	auipc	s4,0x6
    8000216c:	780a0a13          	addi	s4,s4,1920 # 800088e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002170:	00015997          	auipc	s3,0x15
    80002174:	82098993          	addi	s3,s3,-2016 # 80016990 <tickslock>
    80002178:	a029                	j	80002182 <reparent+0x34>
    8000217a:	16848493          	addi	s1,s1,360
    8000217e:	01348d63          	beq	s1,s3,80002198 <reparent+0x4a>
    if(pp->parent == p){
    80002182:	7c9c                	ld	a5,56(s1)
    80002184:	ff279be3          	bne	a5,s2,8000217a <reparent+0x2c>
      pp->parent = initproc;
    80002188:	000a3503          	ld	a0,0(s4)
    8000218c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	f4a080e7          	jalr	-182(ra) # 800020d8 <wakeup>
    80002196:	b7d5                	j	8000217a <reparent+0x2c>
}
    80002198:	70a2                	ld	ra,40(sp)
    8000219a:	7402                	ld	s0,32(sp)
    8000219c:	64e2                	ld	s1,24(sp)
    8000219e:	6942                	ld	s2,16(sp)
    800021a0:	69a2                	ld	s3,8(sp)
    800021a2:	6a02                	ld	s4,0(sp)
    800021a4:	6145                	addi	sp,sp,48
    800021a6:	8082                	ret

00000000800021a8 <exit>:
{
    800021a8:	7179                	addi	sp,sp,-48
    800021aa:	f406                	sd	ra,40(sp)
    800021ac:	f022                	sd	s0,32(sp)
    800021ae:	ec26                	sd	s1,24(sp)
    800021b0:	e84a                	sd	s2,16(sp)
    800021b2:	e44e                	sd	s3,8(sp)
    800021b4:	e052                	sd	s4,0(sp)
    800021b6:	1800                	addi	s0,sp,48
    800021b8:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021ba:	00000097          	auipc	ra,0x0
    800021be:	816080e7          	jalr	-2026(ra) # 800019d0 <myproc>
    800021c2:	89aa                	mv	s3,a0
  if(p == initproc)
    800021c4:	00006797          	auipc	a5,0x6
    800021c8:	7247b783          	ld	a5,1828(a5) # 800088e8 <initproc>
    800021cc:	0d050493          	addi	s1,a0,208
    800021d0:	15050913          	addi	s2,a0,336
    800021d4:	02a79363          	bne	a5,a0,800021fa <exit+0x52>
    panic("init exiting");
    800021d8:	00006517          	auipc	a0,0x6
    800021dc:	08850513          	addi	a0,a0,136 # 80008260 <digits+0x220>
    800021e0:	ffffe097          	auipc	ra,0xffffe
    800021e4:	364080e7          	jalr	868(ra) # 80000544 <panic>
      fileclose(f);
    800021e8:	00002097          	auipc	ra,0x2
    800021ec:	502080e7          	jalr	1282(ra) # 800046ea <fileclose>
      p->ofile[fd] = 0;
    800021f0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021f4:	04a1                	addi	s1,s1,8
    800021f6:	01248563          	beq	s1,s2,80002200 <exit+0x58>
    if(p->ofile[fd]){
    800021fa:	6088                	ld	a0,0(s1)
    800021fc:	f575                	bnez	a0,800021e8 <exit+0x40>
    800021fe:	bfdd                	j	800021f4 <exit+0x4c>
  begin_op();
    80002200:	00002097          	auipc	ra,0x2
    80002204:	01e080e7          	jalr	30(ra) # 8000421e <begin_op>
  iput(p->cwd);
    80002208:	1509b503          	ld	a0,336(s3)
    8000220c:	00002097          	auipc	ra,0x2
    80002210:	80a080e7          	jalr	-2038(ra) # 80003a16 <iput>
  end_op();
    80002214:	00002097          	auipc	ra,0x2
    80002218:	08a080e7          	jalr	138(ra) # 8000429e <end_op>
  p->cwd = 0;
    8000221c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002220:	0000f497          	auipc	s1,0xf
    80002224:	95848493          	addi	s1,s1,-1704 # 80010b78 <wait_lock>
    80002228:	8526                	mv	a0,s1
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	9c0080e7          	jalr	-1600(ra) # 80000bea <acquire>
  reparent(p);
    80002232:	854e                	mv	a0,s3
    80002234:	00000097          	auipc	ra,0x0
    80002238:	f1a080e7          	jalr	-230(ra) # 8000214e <reparent>
  wakeup(p->parent);
    8000223c:	0389b503          	ld	a0,56(s3)
    80002240:	00000097          	auipc	ra,0x0
    80002244:	e98080e7          	jalr	-360(ra) # 800020d8 <wakeup>
  acquire(&p->lock);
    80002248:	854e                	mv	a0,s3
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	9a0080e7          	jalr	-1632(ra) # 80000bea <acquire>
  p->xstate = status;
    80002252:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002256:	4795                	li	a5,5
    80002258:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	a40080e7          	jalr	-1472(ra) # 80000c9e <release>
  sched();
    80002266:	00000097          	auipc	ra,0x0
    8000226a:	cfc080e7          	jalr	-772(ra) # 80001f62 <sched>
  panic("zombie exit");
    8000226e:	00006517          	auipc	a0,0x6
    80002272:	00250513          	addi	a0,a0,2 # 80008270 <digits+0x230>
    80002276:	ffffe097          	auipc	ra,0xffffe
    8000227a:	2ce080e7          	jalr	718(ra) # 80000544 <panic>

000000008000227e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000227e:	7179                	addi	sp,sp,-48
    80002280:	f406                	sd	ra,40(sp)
    80002282:	f022                	sd	s0,32(sp)
    80002284:	ec26                	sd	s1,24(sp)
    80002286:	e84a                	sd	s2,16(sp)
    80002288:	e44e                	sd	s3,8(sp)
    8000228a:	1800                	addi	s0,sp,48
    8000228c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000228e:	0000f497          	auipc	s1,0xf
    80002292:	d0248493          	addi	s1,s1,-766 # 80010f90 <proc>
    80002296:	00014997          	auipc	s3,0x14
    8000229a:	6fa98993          	addi	s3,s3,1786 # 80016990 <tickslock>
    acquire(&p->lock);
    8000229e:	8526                	mv	a0,s1
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	94a080e7          	jalr	-1718(ra) # 80000bea <acquire>
    if(p->pid == pid){
    800022a8:	589c                	lw	a5,48(s1)
    800022aa:	01278d63          	beq	a5,s2,800022c4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022ae:	8526                	mv	a0,s1
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	9ee080e7          	jalr	-1554(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022b8:	16848493          	addi	s1,s1,360
    800022bc:	ff3491e3          	bne	s1,s3,8000229e <kill+0x20>
  }
  return -1;
    800022c0:	557d                	li	a0,-1
    800022c2:	a829                	j	800022dc <kill+0x5e>
      p->killed = 1;
    800022c4:	4785                	li	a5,1
    800022c6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022c8:	4c98                	lw	a4,24(s1)
    800022ca:	4789                	li	a5,2
    800022cc:	00f70f63          	beq	a4,a5,800022ea <kill+0x6c>
      release(&p->lock);
    800022d0:	8526                	mv	a0,s1
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	9cc080e7          	jalr	-1588(ra) # 80000c9e <release>
      return 0;
    800022da:	4501                	li	a0,0
}
    800022dc:	70a2                	ld	ra,40(sp)
    800022de:	7402                	ld	s0,32(sp)
    800022e0:	64e2                	ld	s1,24(sp)
    800022e2:	6942                	ld	s2,16(sp)
    800022e4:	69a2                	ld	s3,8(sp)
    800022e6:	6145                	addi	sp,sp,48
    800022e8:	8082                	ret
        p->state = RUNNABLE;
    800022ea:	478d                	li	a5,3
    800022ec:	cc9c                	sw	a5,24(s1)
    800022ee:	b7cd                	j	800022d0 <kill+0x52>

00000000800022f0 <setkilled>:

void
setkilled(struct proc *p)
{
    800022f0:	1101                	addi	sp,sp,-32
    800022f2:	ec06                	sd	ra,24(sp)
    800022f4:	e822                	sd	s0,16(sp)
    800022f6:	e426                	sd	s1,8(sp)
    800022f8:	1000                	addi	s0,sp,32
    800022fa:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	8ee080e7          	jalr	-1810(ra) # 80000bea <acquire>
  p->killed = 1;
    80002304:	4785                	li	a5,1
    80002306:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002308:	8526                	mv	a0,s1
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	994080e7          	jalr	-1644(ra) # 80000c9e <release>
}
    80002312:	60e2                	ld	ra,24(sp)
    80002314:	6442                	ld	s0,16(sp)
    80002316:	64a2                	ld	s1,8(sp)
    80002318:	6105                	addi	sp,sp,32
    8000231a:	8082                	ret

000000008000231c <killed>:

int
killed(struct proc *p)
{
    8000231c:	1101                	addi	sp,sp,-32
    8000231e:	ec06                	sd	ra,24(sp)
    80002320:	e822                	sd	s0,16(sp)
    80002322:	e426                	sd	s1,8(sp)
    80002324:	e04a                	sd	s2,0(sp)
    80002326:	1000                	addi	s0,sp,32
    80002328:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	8c0080e7          	jalr	-1856(ra) # 80000bea <acquire>
  k = p->killed;
    80002332:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002336:	8526                	mv	a0,s1
    80002338:	fffff097          	auipc	ra,0xfffff
    8000233c:	966080e7          	jalr	-1690(ra) # 80000c9e <release>
  return k;
}
    80002340:	854a                	mv	a0,s2
    80002342:	60e2                	ld	ra,24(sp)
    80002344:	6442                	ld	s0,16(sp)
    80002346:	64a2                	ld	s1,8(sp)
    80002348:	6902                	ld	s2,0(sp)
    8000234a:	6105                	addi	sp,sp,32
    8000234c:	8082                	ret

000000008000234e <wait>:
{
    8000234e:	715d                	addi	sp,sp,-80
    80002350:	e486                	sd	ra,72(sp)
    80002352:	e0a2                	sd	s0,64(sp)
    80002354:	fc26                	sd	s1,56(sp)
    80002356:	f84a                	sd	s2,48(sp)
    80002358:	f44e                	sd	s3,40(sp)
    8000235a:	f052                	sd	s4,32(sp)
    8000235c:	ec56                	sd	s5,24(sp)
    8000235e:	e85a                	sd	s6,16(sp)
    80002360:	e45e                	sd	s7,8(sp)
    80002362:	e062                	sd	s8,0(sp)
    80002364:	0880                	addi	s0,sp,80
    80002366:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	668080e7          	jalr	1640(ra) # 800019d0 <myproc>
    80002370:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002372:	0000f517          	auipc	a0,0xf
    80002376:	80650513          	addi	a0,a0,-2042 # 80010b78 <wait_lock>
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	870080e7          	jalr	-1936(ra) # 80000bea <acquire>
    havekids = 0;
    80002382:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002384:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002386:	00014997          	auipc	s3,0x14
    8000238a:	60a98993          	addi	s3,s3,1546 # 80016990 <tickslock>
        havekids = 1;
    8000238e:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002390:	0000ec17          	auipc	s8,0xe
    80002394:	7e8c0c13          	addi	s8,s8,2024 # 80010b78 <wait_lock>
    havekids = 0;
    80002398:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000239a:	0000f497          	auipc	s1,0xf
    8000239e:	bf648493          	addi	s1,s1,-1034 # 80010f90 <proc>
    800023a2:	a0bd                	j	80002410 <wait+0xc2>
          pid = pp->pid;
    800023a4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023a8:	000b0e63          	beqz	s6,800023c4 <wait+0x76>
    800023ac:	4691                	li	a3,4
    800023ae:	02c48613          	addi	a2,s1,44
    800023b2:	85da                	mv	a1,s6
    800023b4:	05093503          	ld	a0,80(s2)
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	2cc080e7          	jalr	716(ra) # 80001684 <copyout>
    800023c0:	02054563          	bltz	a0,800023ea <wait+0x9c>
          freeproc(pp);
    800023c4:	8526                	mv	a0,s1
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	7bc080e7          	jalr	1980(ra) # 80001b82 <freeproc>
          release(&pp->lock);
    800023ce:	8526                	mv	a0,s1
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	8ce080e7          	jalr	-1842(ra) # 80000c9e <release>
          release(&wait_lock);
    800023d8:	0000e517          	auipc	a0,0xe
    800023dc:	7a050513          	addi	a0,a0,1952 # 80010b78 <wait_lock>
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8be080e7          	jalr	-1858(ra) # 80000c9e <release>
          return pid;
    800023e8:	a0b5                	j	80002454 <wait+0x106>
            release(&pp->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	8b2080e7          	jalr	-1870(ra) # 80000c9e <release>
            release(&wait_lock);
    800023f4:	0000e517          	auipc	a0,0xe
    800023f8:	78450513          	addi	a0,a0,1924 # 80010b78 <wait_lock>
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	8a2080e7          	jalr	-1886(ra) # 80000c9e <release>
            return -1;
    80002404:	59fd                	li	s3,-1
    80002406:	a0b9                	j	80002454 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002408:	16848493          	addi	s1,s1,360
    8000240c:	03348463          	beq	s1,s3,80002434 <wait+0xe6>
      if(pp->parent == p){
    80002410:	7c9c                	ld	a5,56(s1)
    80002412:	ff279be3          	bne	a5,s2,80002408 <wait+0xba>
        acquire(&pp->lock);
    80002416:	8526                	mv	a0,s1
    80002418:	ffffe097          	auipc	ra,0xffffe
    8000241c:	7d2080e7          	jalr	2002(ra) # 80000bea <acquire>
        if(pp->state == ZOMBIE){
    80002420:	4c9c                	lw	a5,24(s1)
    80002422:	f94781e3          	beq	a5,s4,800023a4 <wait+0x56>
        release(&pp->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	876080e7          	jalr	-1930(ra) # 80000c9e <release>
        havekids = 1;
    80002430:	8756                	mv	a4,s5
    80002432:	bfd9                	j	80002408 <wait+0xba>
    if(!havekids || killed(p)){
    80002434:	c719                	beqz	a4,80002442 <wait+0xf4>
    80002436:	854a                	mv	a0,s2
    80002438:	00000097          	auipc	ra,0x0
    8000243c:	ee4080e7          	jalr	-284(ra) # 8000231c <killed>
    80002440:	c51d                	beqz	a0,8000246e <wait+0x120>
      release(&wait_lock);
    80002442:	0000e517          	auipc	a0,0xe
    80002446:	73650513          	addi	a0,a0,1846 # 80010b78 <wait_lock>
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	854080e7          	jalr	-1964(ra) # 80000c9e <release>
      return -1;
    80002452:	59fd                	li	s3,-1
}
    80002454:	854e                	mv	a0,s3
    80002456:	60a6                	ld	ra,72(sp)
    80002458:	6406                	ld	s0,64(sp)
    8000245a:	74e2                	ld	s1,56(sp)
    8000245c:	7942                	ld	s2,48(sp)
    8000245e:	79a2                	ld	s3,40(sp)
    80002460:	7a02                	ld	s4,32(sp)
    80002462:	6ae2                	ld	s5,24(sp)
    80002464:	6b42                	ld	s6,16(sp)
    80002466:	6ba2                	ld	s7,8(sp)
    80002468:	6c02                	ld	s8,0(sp)
    8000246a:	6161                	addi	sp,sp,80
    8000246c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000246e:	85e2                	mv	a1,s8
    80002470:	854a                	mv	a0,s2
    80002472:	00000097          	auipc	ra,0x0
    80002476:	c02080e7          	jalr	-1022(ra) # 80002074 <sleep>
    havekids = 0;
    8000247a:	bf39                	j	80002398 <wait+0x4a>

000000008000247c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000247c:	7179                	addi	sp,sp,-48
    8000247e:	f406                	sd	ra,40(sp)
    80002480:	f022                	sd	s0,32(sp)
    80002482:	ec26                	sd	s1,24(sp)
    80002484:	e84a                	sd	s2,16(sp)
    80002486:	e44e                	sd	s3,8(sp)
    80002488:	e052                	sd	s4,0(sp)
    8000248a:	1800                	addi	s0,sp,48
    8000248c:	84aa                	mv	s1,a0
    8000248e:	892e                	mv	s2,a1
    80002490:	89b2                	mv	s3,a2
    80002492:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002494:	fffff097          	auipc	ra,0xfffff
    80002498:	53c080e7          	jalr	1340(ra) # 800019d0 <myproc>
  if(user_dst){
    8000249c:	c08d                	beqz	s1,800024be <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000249e:	86d2                	mv	a3,s4
    800024a0:	864e                	mv	a2,s3
    800024a2:	85ca                	mv	a1,s2
    800024a4:	6928                	ld	a0,80(a0)
    800024a6:	fffff097          	auipc	ra,0xfffff
    800024aa:	1de080e7          	jalr	478(ra) # 80001684 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024ae:	70a2                	ld	ra,40(sp)
    800024b0:	7402                	ld	s0,32(sp)
    800024b2:	64e2                	ld	s1,24(sp)
    800024b4:	6942                	ld	s2,16(sp)
    800024b6:	69a2                	ld	s3,8(sp)
    800024b8:	6a02                	ld	s4,0(sp)
    800024ba:	6145                	addi	sp,sp,48
    800024bc:	8082                	ret
    memmove((char *)dst, src, len);
    800024be:	000a061b          	sext.w	a2,s4
    800024c2:	85ce                	mv	a1,s3
    800024c4:	854a                	mv	a0,s2
    800024c6:	fffff097          	auipc	ra,0xfffff
    800024ca:	880080e7          	jalr	-1920(ra) # 80000d46 <memmove>
    return 0;
    800024ce:	8526                	mv	a0,s1
    800024d0:	bff9                	j	800024ae <either_copyout+0x32>

00000000800024d2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024d2:	7179                	addi	sp,sp,-48
    800024d4:	f406                	sd	ra,40(sp)
    800024d6:	f022                	sd	s0,32(sp)
    800024d8:	ec26                	sd	s1,24(sp)
    800024da:	e84a                	sd	s2,16(sp)
    800024dc:	e44e                	sd	s3,8(sp)
    800024de:	e052                	sd	s4,0(sp)
    800024e0:	1800                	addi	s0,sp,48
    800024e2:	892a                	mv	s2,a0
    800024e4:	84ae                	mv	s1,a1
    800024e6:	89b2                	mv	s3,a2
    800024e8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ea:	fffff097          	auipc	ra,0xfffff
    800024ee:	4e6080e7          	jalr	1254(ra) # 800019d0 <myproc>
  if(user_src){
    800024f2:	c08d                	beqz	s1,80002514 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024f4:	86d2                	mv	a3,s4
    800024f6:	864e                	mv	a2,s3
    800024f8:	85ca                	mv	a1,s2
    800024fa:	6928                	ld	a0,80(a0)
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	214080e7          	jalr	532(ra) # 80001710 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002504:	70a2                	ld	ra,40(sp)
    80002506:	7402                	ld	s0,32(sp)
    80002508:	64e2                	ld	s1,24(sp)
    8000250a:	6942                	ld	s2,16(sp)
    8000250c:	69a2                	ld	s3,8(sp)
    8000250e:	6a02                	ld	s4,0(sp)
    80002510:	6145                	addi	sp,sp,48
    80002512:	8082                	ret
    memmove(dst, (char*)src, len);
    80002514:	000a061b          	sext.w	a2,s4
    80002518:	85ce                	mv	a1,s3
    8000251a:	854a                	mv	a0,s2
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	82a080e7          	jalr	-2006(ra) # 80000d46 <memmove>
    return 0;
    80002524:	8526                	mv	a0,s1
    80002526:	bff9                	j	80002504 <either_copyin+0x32>

0000000080002528 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002528:	715d                	addi	sp,sp,-80
    8000252a:	e486                	sd	ra,72(sp)
    8000252c:	e0a2                	sd	s0,64(sp)
    8000252e:	fc26                	sd	s1,56(sp)
    80002530:	f84a                	sd	s2,48(sp)
    80002532:	f44e                	sd	s3,40(sp)
    80002534:	f052                	sd	s4,32(sp)
    80002536:	ec56                	sd	s5,24(sp)
    80002538:	e85a                	sd	s6,16(sp)
    8000253a:	e45e                	sd	s7,8(sp)
    8000253c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000253e:	00006517          	auipc	a0,0x6
    80002542:	b8a50513          	addi	a0,a0,-1142 # 800080c8 <digits+0x88>
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	048080e7          	jalr	72(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000254e:	0000f497          	auipc	s1,0xf
    80002552:	b9a48493          	addi	s1,s1,-1126 # 800110e8 <proc+0x158>
    80002556:	00014917          	auipc	s2,0x14
    8000255a:	59290913          	addi	s2,s2,1426 # 80016ae8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002560:	00006997          	auipc	s3,0x6
    80002564:	d2098993          	addi	s3,s3,-736 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002568:	00006a97          	auipc	s5,0x6
    8000256c:	d20a8a93          	addi	s5,s5,-736 # 80008288 <digits+0x248>
    printf("\n");
    80002570:	00006a17          	auipc	s4,0x6
    80002574:	b58a0a13          	addi	s4,s4,-1192 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002578:	00006b97          	auipc	s7,0x6
    8000257c:	d50b8b93          	addi	s7,s7,-688 # 800082c8 <states.1742>
    80002580:	a00d                	j	800025a2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002582:	ed86a583          	lw	a1,-296(a3)
    80002586:	8556                	mv	a0,s5
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	006080e7          	jalr	6(ra) # 8000058e <printf>
    printf("\n");
    80002590:	8552                	mv	a0,s4
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	ffc080e7          	jalr	-4(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000259a:	16848493          	addi	s1,s1,360
    8000259e:	03248163          	beq	s1,s2,800025c0 <procdump+0x98>
    if(p->state == UNUSED)
    800025a2:	86a6                	mv	a3,s1
    800025a4:	ec04a783          	lw	a5,-320(s1)
    800025a8:	dbed                	beqz	a5,8000259a <procdump+0x72>
      state = "???";
    800025aa:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ac:	fcfb6be3          	bltu	s6,a5,80002582 <procdump+0x5a>
    800025b0:	1782                	slli	a5,a5,0x20
    800025b2:	9381                	srli	a5,a5,0x20
    800025b4:	078e                	slli	a5,a5,0x3
    800025b6:	97de                	add	a5,a5,s7
    800025b8:	6390                	ld	a2,0(a5)
    800025ba:	f661                	bnez	a2,80002582 <procdump+0x5a>
      state = "???";
    800025bc:	864e                	mv	a2,s3
    800025be:	b7d1                	j	80002582 <procdump+0x5a>
  }
}
    800025c0:	60a6                	ld	ra,72(sp)
    800025c2:	6406                	ld	s0,64(sp)
    800025c4:	74e2                	ld	s1,56(sp)
    800025c6:	7942                	ld	s2,48(sp)
    800025c8:	79a2                	ld	s3,40(sp)
    800025ca:	7a02                	ld	s4,32(sp)
    800025cc:	6ae2                	ld	s5,24(sp)
    800025ce:	6b42                	ld	s6,16(sp)
    800025d0:	6ba2                	ld	s7,8(sp)
    800025d2:	6161                	addi	sp,sp,80
    800025d4:	8082                	ret

00000000800025d6 <setpriority>:



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int setpriority(int priority)
{
    800025d6:	1101                	addi	sp,sp,-32
    800025d8:	ec06                	sd	ra,24(sp)
    800025da:	e822                	sd	s0,16(sp)
    800025dc:	e426                	sd	s1,8(sp)
    800025de:	e04a                	sd	s2,0(sp)
    800025e0:	1000                	addi	s0,sp,32
    800025e2:	892a                	mv	s2,a0
  struct proc* current_proc = myproc();
    800025e4:	fffff097          	auipc	ra,0xfffff
    800025e8:	3ec080e7          	jalr	1004(ra) # 800019d0 <myproc>
    800025ec:	84aa                	mv	s1,a0

  acquire(&current_proc->lock);
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	5fc080e7          	jalr	1532(ra) # 80000bea <acquire>

  //Priority given is not in the available bounds, or current process is not available.
  if(priority < 1 || priority > 20 || !current_proc)
    800025f6:	fff9071b          	addiw	a4,s2,-1
    800025fa:	47cd                	li	a5,19
    800025fc:	02e7e163          	bltu	a5,a4,8000261e <setpriority+0x48>
    80002600:	c08d                	beqz	s1,80002622 <setpriority+0x4c>
    return  -1;

  //Set priority = priority.
  current_proc->priority = priority;  
    80002602:	0324aa23          	sw	s2,52(s1)

  release(&current_proc->lock);
    80002606:	8526                	mv	a0,s1
    80002608:	ffffe097          	auipc	ra,0xffffe
    8000260c:	696080e7          	jalr	1686(ra) # 80000c9e <release>

  return 0;
    80002610:	4501                	li	a0,0
}
    80002612:	60e2                	ld	ra,24(sp)
    80002614:	6442                	ld	s0,16(sp)
    80002616:	64a2                	ld	s1,8(sp)
    80002618:	6902                	ld	s2,0(sp)
    8000261a:	6105                	addi	sp,sp,32
    8000261c:	8082                	ret
    return  -1;
    8000261e:	557d                	li	a0,-1
    80002620:	bfcd                	j	80002612 <setpriority+0x3c>
    80002622:	557d                	li	a0,-1
    80002624:	b7fd                	j	80002612 <setpriority+0x3c>

0000000080002626 <getpinfo>:

int getpinfo(struct pstat* stats){
    80002626:	711d                	addi	sp,sp,-96
    80002628:	ec86                	sd	ra,88(sp)
    8000262a:	e8a2                	sd	s0,80(sp)
    8000262c:	e4a6                	sd	s1,72(sp)
    8000262e:	e0ca                	sd	s2,64(sp)
    80002630:	fc4e                	sd	s3,56(sp)
    80002632:	f852                	sd	s4,48(sp)
    80002634:	f456                	sd	s5,40(sp)
    80002636:	f05a                	sd	s6,32(sp)
    80002638:	ec5e                	sd	s7,24(sp)
    8000263a:	1080                	addi	s0,sp,96
    8000263c:	8baa                	mv	s7,a0
  struct proc* p;

  uint64 addr; 
  argaddr(0, &addr); //User pointer to struct pstat stored in addr variable.
    8000263e:	fa840593          	addi	a1,s0,-88
    80002642:	4501                	li	a0,0
    80002644:	00000097          	auipc	ra,0x0
    80002648:	5e6080e7          	jalr	1510(ra) # 80002c2a <argaddr>

  int index = 0;
  for(p = proc; p < &proc[NPROC]; p++) {
    8000264c:	895e                	mv	s2,s7
    8000264e:	002b9a93          	slli	s5,s7,0x2
    80002652:	415b8ab3          	sub	s5,s7,s5
    80002656:	0000f497          	auipc	s1,0xf
    8000265a:	93a48493          	addi	s1,s1,-1734 # 80010f90 <proc>
      else  
        stats->ppid[index] = -1;

      stats->pid[index] = p->pid;
      stats->priority[index] = p->priority;
      strncpy(stats->name[index], p->name, 16);
    8000265e:	300a8a93          	addi	s5,s5,768
        stats->ppid[index] = -1;
    80002662:	5b7d                	li	s6,-1
  for(p = proc; p < &proc[NPROC]; p++) {
    80002664:	00014a17          	auipc	s4,0x14
    80002668:	32ca0a13          	addi	s4,s4,812 # 80016990 <tickslock>
    8000266c:	a081                	j	800026ac <getpinfo+0x86>
        stats->ppid[index] = -1;
    8000266e:	11692023          	sw	s6,256(s2)
      stats->pid[index] = p->pid;
    80002672:	589c                	lw	a5,48(s1)
    80002674:	00f92023          	sw	a5,0(s2)
      stats->priority[index] = p->priority;
    80002678:	58dc                	lw	a5,52(s1)
    8000267a:	20f92023          	sw	a5,512(s2)
      strncpy(stats->name[index], p->name, 16);
    8000267e:	00291513          	slli	a0,s2,0x2
    80002682:	4641                	li	a2,16
    80002684:	15898593          	addi	a1,s3,344
    80002688:	9556                	add	a0,a0,s5
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	770080e7          	jalr	1904(ra) # 80000dfa <strncpy>
    }
    stats->state[index] = p->state;
    80002692:	4c9c                	lw	a5,24(s1)
    80002694:	70f92023          	sw	a5,1792(s2)
    index++;

    release(&p->lock);
    80002698:	8526                	mv	a0,s1
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	604080e7          	jalr	1540(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026a2:	16848493          	addi	s1,s1,360
    800026a6:	0911                	addi	s2,s2,4
    800026a8:	03448063          	beq	s1,s4,800026c8 <getpinfo+0xa2>
    acquire(&p->lock);
    800026ac:	89a6                	mv	s3,s1
    800026ae:	8526                	mv	a0,s1
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	53a080e7          	jalr	1338(ra) # 80000bea <acquire>
    if(p->state != UNUSED){
    800026b8:	4c9c                	lw	a5,24(s1)
    800026ba:	dfe1                	beqz	a5,80002692 <getpinfo+0x6c>
      if(p->parent != 0)
    800026bc:	7c9c                	ld	a5,56(s1)
    800026be:	dbc5                	beqz	a5,8000266e <getpinfo+0x48>
        stats->ppid[index] = p->parent->pid;
    800026c0:	5b9c                	lw	a5,48(a5)
    800026c2:	10f92023          	sw	a5,256(s2)
    800026c6:	b775                	j	80002672 <getpinfo+0x4c>
  }
  
  //Copy struct pstat from kernel to user.
  if(copyout(myproc()->pagetable, addr, (char *)stats, sizeof(struct pstat)) < 0)
    800026c8:	fffff097          	auipc	ra,0xfffff
    800026cc:	308080e7          	jalr	776(ra) # 800019d0 <myproc>
    800026d0:	6685                	lui	a3,0x1
    800026d2:	80068693          	addi	a3,a3,-2048 # 800 <_entry-0x7ffff800>
    800026d6:	865e                	mv	a2,s7
    800026d8:	fa843583          	ld	a1,-88(s0)
    800026dc:	6928                	ld	a0,80(a0)
    800026de:	fffff097          	auipc	ra,0xfffff
    800026e2:	fa6080e7          	jalr	-90(ra) # 80001684 <copyout>
    return -1;

  return 0;
    800026e6:	41f5551b          	sraiw	a0,a0,0x1f
    800026ea:	60e6                	ld	ra,88(sp)
    800026ec:	6446                	ld	s0,80(sp)
    800026ee:	64a6                	ld	s1,72(sp)
    800026f0:	6906                	ld	s2,64(sp)
    800026f2:	79e2                	ld	s3,56(sp)
    800026f4:	7a42                	ld	s4,48(sp)
    800026f6:	7aa2                	ld	s5,40(sp)
    800026f8:	7b02                	ld	s6,32(sp)
    800026fa:	6be2                	ld	s7,24(sp)
    800026fc:	6125                	addi	sp,sp,96
    800026fe:	8082                	ret

0000000080002700 <swtch>:
    80002700:	00153023          	sd	ra,0(a0)
    80002704:	00253423          	sd	sp,8(a0)
    80002708:	e900                	sd	s0,16(a0)
    8000270a:	ed04                	sd	s1,24(a0)
    8000270c:	03253023          	sd	s2,32(a0)
    80002710:	03353423          	sd	s3,40(a0)
    80002714:	03453823          	sd	s4,48(a0)
    80002718:	03553c23          	sd	s5,56(a0)
    8000271c:	05653023          	sd	s6,64(a0)
    80002720:	05753423          	sd	s7,72(a0)
    80002724:	05853823          	sd	s8,80(a0)
    80002728:	05953c23          	sd	s9,88(a0)
    8000272c:	07a53023          	sd	s10,96(a0)
    80002730:	07b53423          	sd	s11,104(a0)
    80002734:	0005b083          	ld	ra,0(a1)
    80002738:	0085b103          	ld	sp,8(a1)
    8000273c:	6980                	ld	s0,16(a1)
    8000273e:	6d84                	ld	s1,24(a1)
    80002740:	0205b903          	ld	s2,32(a1)
    80002744:	0285b983          	ld	s3,40(a1)
    80002748:	0305ba03          	ld	s4,48(a1)
    8000274c:	0385ba83          	ld	s5,56(a1)
    80002750:	0405bb03          	ld	s6,64(a1)
    80002754:	0485bb83          	ld	s7,72(a1)
    80002758:	0505bc03          	ld	s8,80(a1)
    8000275c:	0585bc83          	ld	s9,88(a1)
    80002760:	0605bd03          	ld	s10,96(a1)
    80002764:	0685bd83          	ld	s11,104(a1)
    80002768:	8082                	ret

000000008000276a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000276a:	1141                	addi	sp,sp,-16
    8000276c:	e406                	sd	ra,8(sp)
    8000276e:	e022                	sd	s0,0(sp)
    80002770:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002772:	00006597          	auipc	a1,0x6
    80002776:	b8658593          	addi	a1,a1,-1146 # 800082f8 <states.1742+0x30>
    8000277a:	00014517          	auipc	a0,0x14
    8000277e:	21650513          	addi	a0,a0,534 # 80016990 <tickslock>
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	3d8080e7          	jalr	984(ra) # 80000b5a <initlock>
}
    8000278a:	60a2                	ld	ra,8(sp)
    8000278c:	6402                	ld	s0,0(sp)
    8000278e:	0141                	addi	sp,sp,16
    80002790:	8082                	ret

0000000080002792 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002792:	1141                	addi	sp,sp,-16
    80002794:	e422                	sd	s0,8(sp)
    80002796:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002798:	00003797          	auipc	a5,0x3
    8000279c:	59878793          	addi	a5,a5,1432 # 80005d30 <kernelvec>
    800027a0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027a4:	6422                	ld	s0,8(sp)
    800027a6:	0141                	addi	sp,sp,16
    800027a8:	8082                	ret

00000000800027aa <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027aa:	1141                	addi	sp,sp,-16
    800027ac:	e406                	sd	ra,8(sp)
    800027ae:	e022                	sd	s0,0(sp)
    800027b0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027b2:	fffff097          	auipc	ra,0xfffff
    800027b6:	21e080e7          	jalr	542(ra) # 800019d0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027be:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027c0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027c4:	00005617          	auipc	a2,0x5
    800027c8:	83c60613          	addi	a2,a2,-1988 # 80007000 <_trampoline>
    800027cc:	00005697          	auipc	a3,0x5
    800027d0:	83468693          	addi	a3,a3,-1996 # 80007000 <_trampoline>
    800027d4:	8e91                	sub	a3,a3,a2
    800027d6:	040007b7          	lui	a5,0x4000
    800027da:	17fd                	addi	a5,a5,-1
    800027dc:	07b2                	slli	a5,a5,0xc
    800027de:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027e0:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027e4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027e6:	180026f3          	csrr	a3,satp
    800027ea:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027ec:	6d38                	ld	a4,88(a0)
    800027ee:	6134                	ld	a3,64(a0)
    800027f0:	6585                	lui	a1,0x1
    800027f2:	96ae                	add	a3,a3,a1
    800027f4:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027f6:	6d38                	ld	a4,88(a0)
    800027f8:	00000697          	auipc	a3,0x0
    800027fc:	13068693          	addi	a3,a3,304 # 80002928 <usertrap>
    80002800:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002802:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002804:	8692                	mv	a3,tp
    80002806:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002808:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000280c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002810:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002814:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002818:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000281a:	6f18                	ld	a4,24(a4)
    8000281c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002820:	6928                	ld	a0,80(a0)
    80002822:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002824:	00005717          	auipc	a4,0x5
    80002828:	87870713          	addi	a4,a4,-1928 # 8000709c <userret>
    8000282c:	8f11                	sub	a4,a4,a2
    8000282e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002830:	577d                	li	a4,-1
    80002832:	177e                	slli	a4,a4,0x3f
    80002834:	8d59                	or	a0,a0,a4
    80002836:	9782                	jalr	a5
}
    80002838:	60a2                	ld	ra,8(sp)
    8000283a:	6402                	ld	s0,0(sp)
    8000283c:	0141                	addi	sp,sp,16
    8000283e:	8082                	ret

0000000080002840 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	e426                	sd	s1,8(sp)
    80002848:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000284a:	00014497          	auipc	s1,0x14
    8000284e:	14648493          	addi	s1,s1,326 # 80016990 <tickslock>
    80002852:	8526                	mv	a0,s1
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	396080e7          	jalr	918(ra) # 80000bea <acquire>
  ticks++;
    8000285c:	00006517          	auipc	a0,0x6
    80002860:	09450513          	addi	a0,a0,148 # 800088f0 <ticks>
    80002864:	411c                	lw	a5,0(a0)
    80002866:	2785                	addiw	a5,a5,1
    80002868:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000286a:	00000097          	auipc	ra,0x0
    8000286e:	86e080e7          	jalr	-1938(ra) # 800020d8 <wakeup>
  release(&tickslock);
    80002872:	8526                	mv	a0,s1
    80002874:	ffffe097          	auipc	ra,0xffffe
    80002878:	42a080e7          	jalr	1066(ra) # 80000c9e <release>
}
    8000287c:	60e2                	ld	ra,24(sp)
    8000287e:	6442                	ld	s0,16(sp)
    80002880:	64a2                	ld	s1,8(sp)
    80002882:	6105                	addi	sp,sp,32
    80002884:	8082                	ret

0000000080002886 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002886:	1101                	addi	sp,sp,-32
    80002888:	ec06                	sd	ra,24(sp)
    8000288a:	e822                	sd	s0,16(sp)
    8000288c:	e426                	sd	s1,8(sp)
    8000288e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002890:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002894:	00074d63          	bltz	a4,800028ae <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002898:	57fd                	li	a5,-1
    8000289a:	17fe                	slli	a5,a5,0x3f
    8000289c:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000289e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028a0:	06f70363          	beq	a4,a5,80002906 <devintr+0x80>
  }
}
    800028a4:	60e2                	ld	ra,24(sp)
    800028a6:	6442                	ld	s0,16(sp)
    800028a8:	64a2                	ld	s1,8(sp)
    800028aa:	6105                	addi	sp,sp,32
    800028ac:	8082                	ret
     (scause & 0xff) == 9){
    800028ae:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800028b2:	46a5                	li	a3,9
    800028b4:	fed792e3          	bne	a5,a3,80002898 <devintr+0x12>
    int irq = plic_claim();
    800028b8:	00003097          	auipc	ra,0x3
    800028bc:	580080e7          	jalr	1408(ra) # 80005e38 <plic_claim>
    800028c0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028c2:	47a9                	li	a5,10
    800028c4:	02f50763          	beq	a0,a5,800028f2 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800028c8:	4785                	li	a5,1
    800028ca:	02f50963          	beq	a0,a5,800028fc <devintr+0x76>
    return 1;
    800028ce:	4505                	li	a0,1
    } else if(irq){
    800028d0:	d8f1                	beqz	s1,800028a4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028d2:	85a6                	mv	a1,s1
    800028d4:	00006517          	auipc	a0,0x6
    800028d8:	a2c50513          	addi	a0,a0,-1492 # 80008300 <states.1742+0x38>
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	cb2080e7          	jalr	-846(ra) # 8000058e <printf>
      plic_complete(irq);
    800028e4:	8526                	mv	a0,s1
    800028e6:	00003097          	auipc	ra,0x3
    800028ea:	576080e7          	jalr	1398(ra) # 80005e5c <plic_complete>
    return 1;
    800028ee:	4505                	li	a0,1
    800028f0:	bf55                	j	800028a4 <devintr+0x1e>
      uartintr();
    800028f2:	ffffe097          	auipc	ra,0xffffe
    800028f6:	0bc080e7          	jalr	188(ra) # 800009ae <uartintr>
    800028fa:	b7ed                	j	800028e4 <devintr+0x5e>
      virtio_disk_intr();
    800028fc:	00004097          	auipc	ra,0x4
    80002900:	a8a080e7          	jalr	-1398(ra) # 80006386 <virtio_disk_intr>
    80002904:	b7c5                	j	800028e4 <devintr+0x5e>
    if(cpuid() == 0){
    80002906:	fffff097          	auipc	ra,0xfffff
    8000290a:	09e080e7          	jalr	158(ra) # 800019a4 <cpuid>
    8000290e:	c901                	beqz	a0,8000291e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002910:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002914:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002916:	14479073          	csrw	sip,a5
    return 2;
    8000291a:	4509                	li	a0,2
    8000291c:	b761                	j	800028a4 <devintr+0x1e>
      clockintr();
    8000291e:	00000097          	auipc	ra,0x0
    80002922:	f22080e7          	jalr	-222(ra) # 80002840 <clockintr>
    80002926:	b7ed                	j	80002910 <devintr+0x8a>

0000000080002928 <usertrap>:
{
    80002928:	1101                	addi	sp,sp,-32
    8000292a:	ec06                	sd	ra,24(sp)
    8000292c:	e822                	sd	s0,16(sp)
    8000292e:	e426                	sd	s1,8(sp)
    80002930:	e04a                	sd	s2,0(sp)
    80002932:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002934:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002938:	1007f793          	andi	a5,a5,256
    8000293c:	e3b1                	bnez	a5,80002980 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000293e:	00003797          	auipc	a5,0x3
    80002942:	3f278793          	addi	a5,a5,1010 # 80005d30 <kernelvec>
    80002946:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000294a:	fffff097          	auipc	ra,0xfffff
    8000294e:	086080e7          	jalr	134(ra) # 800019d0 <myproc>
    80002952:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002954:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002956:	14102773          	csrr	a4,sepc
    8000295a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000295c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002960:	47a1                	li	a5,8
    80002962:	02f70763          	beq	a4,a5,80002990 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002966:	00000097          	auipc	ra,0x0
    8000296a:	f20080e7          	jalr	-224(ra) # 80002886 <devintr>
    8000296e:	892a                	mv	s2,a0
    80002970:	c151                	beqz	a0,800029f4 <usertrap+0xcc>
  if(killed(p))
    80002972:	8526                	mv	a0,s1
    80002974:	00000097          	auipc	ra,0x0
    80002978:	9a8080e7          	jalr	-1624(ra) # 8000231c <killed>
    8000297c:	c929                	beqz	a0,800029ce <usertrap+0xa6>
    8000297e:	a099                	j	800029c4 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002980:	00006517          	auipc	a0,0x6
    80002984:	9a050513          	addi	a0,a0,-1632 # 80008320 <states.1742+0x58>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	bbc080e7          	jalr	-1092(ra) # 80000544 <panic>
    if(killed(p))
    80002990:	00000097          	auipc	ra,0x0
    80002994:	98c080e7          	jalr	-1652(ra) # 8000231c <killed>
    80002998:	e921                	bnez	a0,800029e8 <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000299a:	6cb8                	ld	a4,88(s1)
    8000299c:	6f1c                	ld	a5,24(a4)
    8000299e:	0791                	addi	a5,a5,4
    800029a0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029aa:	10079073          	csrw	sstatus,a5
    syscall();
    800029ae:	00000097          	auipc	ra,0x0
    800029b2:	33a080e7          	jalr	826(ra) # 80002ce8 <syscall>
  if(killed(p))
    800029b6:	8526                	mv	a0,s1
    800029b8:	00000097          	auipc	ra,0x0
    800029bc:	964080e7          	jalr	-1692(ra) # 8000231c <killed>
    800029c0:	c911                	beqz	a0,800029d4 <usertrap+0xac>
    800029c2:	4901                	li	s2,0
    exit(-1);
    800029c4:	557d                	li	a0,-1
    800029c6:	fffff097          	auipc	ra,0xfffff
    800029ca:	7e2080e7          	jalr	2018(ra) # 800021a8 <exit>
  if(which_dev == 2)
    800029ce:	4789                	li	a5,2
    800029d0:	04f90f63          	beq	s2,a5,80002a2e <usertrap+0x106>
  usertrapret();
    800029d4:	00000097          	auipc	ra,0x0
    800029d8:	dd6080e7          	jalr	-554(ra) # 800027aa <usertrapret>
}
    800029dc:	60e2                	ld	ra,24(sp)
    800029de:	6442                	ld	s0,16(sp)
    800029e0:	64a2                	ld	s1,8(sp)
    800029e2:	6902                	ld	s2,0(sp)
    800029e4:	6105                	addi	sp,sp,32
    800029e6:	8082                	ret
      exit(-1);
    800029e8:	557d                	li	a0,-1
    800029ea:	fffff097          	auipc	ra,0xfffff
    800029ee:	7be080e7          	jalr	1982(ra) # 800021a8 <exit>
    800029f2:	b765                	j	8000299a <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029f4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029f8:	5890                	lw	a2,48(s1)
    800029fa:	00006517          	auipc	a0,0x6
    800029fe:	94650513          	addi	a0,a0,-1722 # 80008340 <states.1742+0x78>
    80002a02:	ffffe097          	auipc	ra,0xffffe
    80002a06:	b8c080e7          	jalr	-1140(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a0a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a0e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a12:	00006517          	auipc	a0,0x6
    80002a16:	95e50513          	addi	a0,a0,-1698 # 80008370 <states.1742+0xa8>
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	b74080e7          	jalr	-1164(ra) # 8000058e <printf>
    setkilled(p);
    80002a22:	8526                	mv	a0,s1
    80002a24:	00000097          	auipc	ra,0x0
    80002a28:	8cc080e7          	jalr	-1844(ra) # 800022f0 <setkilled>
    80002a2c:	b769                	j	800029b6 <usertrap+0x8e>
    yield();
    80002a2e:	fffff097          	auipc	ra,0xfffff
    80002a32:	60a080e7          	jalr	1546(ra) # 80002038 <yield>
    80002a36:	bf79                	j	800029d4 <usertrap+0xac>

0000000080002a38 <kerneltrap>:
{
    80002a38:	7179                	addi	sp,sp,-48
    80002a3a:	f406                	sd	ra,40(sp)
    80002a3c:	f022                	sd	s0,32(sp)
    80002a3e:	ec26                	sd	s1,24(sp)
    80002a40:	e84a                	sd	s2,16(sp)
    80002a42:	e44e                	sd	s3,8(sp)
    80002a44:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a46:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a4a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a4e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a52:	1004f793          	andi	a5,s1,256
    80002a56:	cb85                	beqz	a5,80002a86 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a58:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a5c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a5e:	ef85                	bnez	a5,80002a96 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a60:	00000097          	auipc	ra,0x0
    80002a64:	e26080e7          	jalr	-474(ra) # 80002886 <devintr>
    80002a68:	cd1d                	beqz	a0,80002aa6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a6a:	4789                	li	a5,2
    80002a6c:	06f50a63          	beq	a0,a5,80002ae0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a70:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a74:	10049073          	csrw	sstatus,s1
}
    80002a78:	70a2                	ld	ra,40(sp)
    80002a7a:	7402                	ld	s0,32(sp)
    80002a7c:	64e2                	ld	s1,24(sp)
    80002a7e:	6942                	ld	s2,16(sp)
    80002a80:	69a2                	ld	s3,8(sp)
    80002a82:	6145                	addi	sp,sp,48
    80002a84:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a86:	00006517          	auipc	a0,0x6
    80002a8a:	90a50513          	addi	a0,a0,-1782 # 80008390 <states.1742+0xc8>
    80002a8e:	ffffe097          	auipc	ra,0xffffe
    80002a92:	ab6080e7          	jalr	-1354(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a96:	00006517          	auipc	a0,0x6
    80002a9a:	92250513          	addi	a0,a0,-1758 # 800083b8 <states.1742+0xf0>
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	aa6080e7          	jalr	-1370(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002aa6:	85ce                	mv	a1,s3
    80002aa8:	00006517          	auipc	a0,0x6
    80002aac:	93050513          	addi	a0,a0,-1744 # 800083d8 <states.1742+0x110>
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	ade080e7          	jalr	-1314(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ab8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002abc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ac0:	00006517          	auipc	a0,0x6
    80002ac4:	92850513          	addi	a0,a0,-1752 # 800083e8 <states.1742+0x120>
    80002ac8:	ffffe097          	auipc	ra,0xffffe
    80002acc:	ac6080e7          	jalr	-1338(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002ad0:	00006517          	auipc	a0,0x6
    80002ad4:	93050513          	addi	a0,a0,-1744 # 80008400 <states.1742+0x138>
    80002ad8:	ffffe097          	auipc	ra,0xffffe
    80002adc:	a6c080e7          	jalr	-1428(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ae0:	fffff097          	auipc	ra,0xfffff
    80002ae4:	ef0080e7          	jalr	-272(ra) # 800019d0 <myproc>
    80002ae8:	d541                	beqz	a0,80002a70 <kerneltrap+0x38>
    80002aea:	fffff097          	auipc	ra,0xfffff
    80002aee:	ee6080e7          	jalr	-282(ra) # 800019d0 <myproc>
    80002af2:	4d18                	lw	a4,24(a0)
    80002af4:	4791                	li	a5,4
    80002af6:	f6f71de3          	bne	a4,a5,80002a70 <kerneltrap+0x38>
    yield();
    80002afa:	fffff097          	auipc	ra,0xfffff
    80002afe:	53e080e7          	jalr	1342(ra) # 80002038 <yield>
    80002b02:	b7bd                	j	80002a70 <kerneltrap+0x38>

0000000080002b04 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b04:	1101                	addi	sp,sp,-32
    80002b06:	ec06                	sd	ra,24(sp)
    80002b08:	e822                	sd	s0,16(sp)
    80002b0a:	e426                	sd	s1,8(sp)
    80002b0c:	1000                	addi	s0,sp,32
    80002b0e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b10:	fffff097          	auipc	ra,0xfffff
    80002b14:	ec0080e7          	jalr	-320(ra) # 800019d0 <myproc>
  switch (n) {
    80002b18:	4795                	li	a5,5
    80002b1a:	0497e163          	bltu	a5,s1,80002b5c <argraw+0x58>
    80002b1e:	048a                	slli	s1,s1,0x2
    80002b20:	00006717          	auipc	a4,0x6
    80002b24:	91870713          	addi	a4,a4,-1768 # 80008438 <states.1742+0x170>
    80002b28:	94ba                	add	s1,s1,a4
    80002b2a:	409c                	lw	a5,0(s1)
    80002b2c:	97ba                	add	a5,a5,a4
    80002b2e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b30:	6d3c                	ld	a5,88(a0)
    80002b32:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b34:	60e2                	ld	ra,24(sp)
    80002b36:	6442                	ld	s0,16(sp)
    80002b38:	64a2                	ld	s1,8(sp)
    80002b3a:	6105                	addi	sp,sp,32
    80002b3c:	8082                	ret
    return p->trapframe->a1;
    80002b3e:	6d3c                	ld	a5,88(a0)
    80002b40:	7fa8                	ld	a0,120(a5)
    80002b42:	bfcd                	j	80002b34 <argraw+0x30>
    return p->trapframe->a2;
    80002b44:	6d3c                	ld	a5,88(a0)
    80002b46:	63c8                	ld	a0,128(a5)
    80002b48:	b7f5                	j	80002b34 <argraw+0x30>
    return p->trapframe->a3;
    80002b4a:	6d3c                	ld	a5,88(a0)
    80002b4c:	67c8                	ld	a0,136(a5)
    80002b4e:	b7dd                	j	80002b34 <argraw+0x30>
    return p->trapframe->a4;
    80002b50:	6d3c                	ld	a5,88(a0)
    80002b52:	6bc8                	ld	a0,144(a5)
    80002b54:	b7c5                	j	80002b34 <argraw+0x30>
    return p->trapframe->a5;
    80002b56:	6d3c                	ld	a5,88(a0)
    80002b58:	6fc8                	ld	a0,152(a5)
    80002b5a:	bfe9                	j	80002b34 <argraw+0x30>
  panic("argraw");
    80002b5c:	00006517          	auipc	a0,0x6
    80002b60:	8b450513          	addi	a0,a0,-1868 # 80008410 <states.1742+0x148>
    80002b64:	ffffe097          	auipc	ra,0xffffe
    80002b68:	9e0080e7          	jalr	-1568(ra) # 80000544 <panic>

0000000080002b6c <fetchaddr>:
{
    80002b6c:	1101                	addi	sp,sp,-32
    80002b6e:	ec06                	sd	ra,24(sp)
    80002b70:	e822                	sd	s0,16(sp)
    80002b72:	e426                	sd	s1,8(sp)
    80002b74:	e04a                	sd	s2,0(sp)
    80002b76:	1000                	addi	s0,sp,32
    80002b78:	84aa                	mv	s1,a0
    80002b7a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b7c:	fffff097          	auipc	ra,0xfffff
    80002b80:	e54080e7          	jalr	-428(ra) # 800019d0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b84:	653c                	ld	a5,72(a0)
    80002b86:	02f4f863          	bgeu	s1,a5,80002bb6 <fetchaddr+0x4a>
    80002b8a:	00848713          	addi	a4,s1,8
    80002b8e:	02e7e663          	bltu	a5,a4,80002bba <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b92:	46a1                	li	a3,8
    80002b94:	8626                	mv	a2,s1
    80002b96:	85ca                	mv	a1,s2
    80002b98:	6928                	ld	a0,80(a0)
    80002b9a:	fffff097          	auipc	ra,0xfffff
    80002b9e:	b76080e7          	jalr	-1162(ra) # 80001710 <copyin>
    80002ba2:	00a03533          	snez	a0,a0
    80002ba6:	40a00533          	neg	a0,a0
}
    80002baa:	60e2                	ld	ra,24(sp)
    80002bac:	6442                	ld	s0,16(sp)
    80002bae:	64a2                	ld	s1,8(sp)
    80002bb0:	6902                	ld	s2,0(sp)
    80002bb2:	6105                	addi	sp,sp,32
    80002bb4:	8082                	ret
    return -1;
    80002bb6:	557d                	li	a0,-1
    80002bb8:	bfcd                	j	80002baa <fetchaddr+0x3e>
    80002bba:	557d                	li	a0,-1
    80002bbc:	b7fd                	j	80002baa <fetchaddr+0x3e>

0000000080002bbe <fetchstr>:
{
    80002bbe:	7179                	addi	sp,sp,-48
    80002bc0:	f406                	sd	ra,40(sp)
    80002bc2:	f022                	sd	s0,32(sp)
    80002bc4:	ec26                	sd	s1,24(sp)
    80002bc6:	e84a                	sd	s2,16(sp)
    80002bc8:	e44e                	sd	s3,8(sp)
    80002bca:	1800                	addi	s0,sp,48
    80002bcc:	892a                	mv	s2,a0
    80002bce:	84ae                	mv	s1,a1
    80002bd0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bd2:	fffff097          	auipc	ra,0xfffff
    80002bd6:	dfe080e7          	jalr	-514(ra) # 800019d0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002bda:	86ce                	mv	a3,s3
    80002bdc:	864a                	mv	a2,s2
    80002bde:	85a6                	mv	a1,s1
    80002be0:	6928                	ld	a0,80(a0)
    80002be2:	fffff097          	auipc	ra,0xfffff
    80002be6:	bba080e7          	jalr	-1094(ra) # 8000179c <copyinstr>
    80002bea:	00054e63          	bltz	a0,80002c06 <fetchstr+0x48>
  return strlen(buf);
    80002bee:	8526                	mv	a0,s1
    80002bf0:	ffffe097          	auipc	ra,0xffffe
    80002bf4:	27a080e7          	jalr	634(ra) # 80000e6a <strlen>
}
    80002bf8:	70a2                	ld	ra,40(sp)
    80002bfa:	7402                	ld	s0,32(sp)
    80002bfc:	64e2                	ld	s1,24(sp)
    80002bfe:	6942                	ld	s2,16(sp)
    80002c00:	69a2                	ld	s3,8(sp)
    80002c02:	6145                	addi	sp,sp,48
    80002c04:	8082                	ret
    return -1;
    80002c06:	557d                	li	a0,-1
    80002c08:	bfc5                	j	80002bf8 <fetchstr+0x3a>

0000000080002c0a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c0a:	1101                	addi	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	e426                	sd	s1,8(sp)
    80002c12:	1000                	addi	s0,sp,32
    80002c14:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c16:	00000097          	auipc	ra,0x0
    80002c1a:	eee080e7          	jalr	-274(ra) # 80002b04 <argraw>
    80002c1e:	c088                	sw	a0,0(s1)
}
    80002c20:	60e2                	ld	ra,24(sp)
    80002c22:	6442                	ld	s0,16(sp)
    80002c24:	64a2                	ld	s1,8(sp)
    80002c26:	6105                	addi	sp,sp,32
    80002c28:	8082                	ret

0000000080002c2a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c2a:	1101                	addi	sp,sp,-32
    80002c2c:	ec06                	sd	ra,24(sp)
    80002c2e:	e822                	sd	s0,16(sp)
    80002c30:	e426                	sd	s1,8(sp)
    80002c32:	1000                	addi	s0,sp,32
    80002c34:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c36:	00000097          	auipc	ra,0x0
    80002c3a:	ece080e7          	jalr	-306(ra) # 80002b04 <argraw>
    80002c3e:	e088                	sd	a0,0(s1)
}
    80002c40:	60e2                	ld	ra,24(sp)
    80002c42:	6442                	ld	s0,16(sp)
    80002c44:	64a2                	ld	s1,8(sp)
    80002c46:	6105                	addi	sp,sp,32
    80002c48:	8082                	ret

0000000080002c4a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c4a:	7179                	addi	sp,sp,-48
    80002c4c:	f406                	sd	ra,40(sp)
    80002c4e:	f022                	sd	s0,32(sp)
    80002c50:	ec26                	sd	s1,24(sp)
    80002c52:	e84a                	sd	s2,16(sp)
    80002c54:	1800                	addi	s0,sp,48
    80002c56:	84ae                	mv	s1,a1
    80002c58:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c5a:	fd840593          	addi	a1,s0,-40
    80002c5e:	00000097          	auipc	ra,0x0
    80002c62:	fcc080e7          	jalr	-52(ra) # 80002c2a <argaddr>
  return fetchstr(addr, buf, max);
    80002c66:	864a                	mv	a2,s2
    80002c68:	85a6                	mv	a1,s1
    80002c6a:	fd843503          	ld	a0,-40(s0)
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	f50080e7          	jalr	-176(ra) # 80002bbe <fetchstr>
}
    80002c76:	70a2                	ld	ra,40(sp)
    80002c78:	7402                	ld	s0,32(sp)
    80002c7a:	64e2                	ld	s1,24(sp)
    80002c7c:	6942                	ld	s2,16(sp)
    80002c7e:	6145                	addi	sp,sp,48
    80002c80:	8082                	ret

0000000080002c82 <argpstat>:

//////////////////////////////////////////////
int
argpstat(int n, struct pstat *pp, int size)
{
    80002c82:	7139                	addi	sp,sp,-64
    80002c84:	fc06                	sd	ra,56(sp)
    80002c86:	f822                	sd	s0,48(sp)
    80002c88:	f426                	sd	s1,40(sp)
    80002c8a:	f04a                	sd	s2,32(sp)
    80002c8c:	ec4e                	sd	s3,24(sp)
    80002c8e:	0080                	addi	s0,sp,64
    80002c90:	892a                	mv	s2,a0
    80002c92:	84b2                	mv	s1,a2
  int i;
  struct proc *curproc = myproc();
    80002c94:	fffff097          	auipc	ra,0xfffff
    80002c98:	d3c080e7          	jalr	-708(ra) # 800019d0 <myproc>
    80002c9c:	89aa                	mv	s3,a0
  struct pstat p;
 
  argint(n, &i);
    80002c9e:	fcc40593          	addi	a1,s0,-52
    80002ca2:	854a                	mv	a0,s2
    80002ca4:	00000097          	auipc	ra,0x0
    80002ca8:	f66080e7          	jalr	-154(ra) # 80002c0a <argint>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    80002cac:	0204ca63          	bltz	s1,80002ce0 <argpstat+0x5e>
    80002cb0:	fcc42603          	lw	a2,-52(s0)
    80002cb4:	0489b503          	ld	a0,72(s3)
    80002cb8:	02061793          	slli	a5,a2,0x20
    80002cbc:	9381                	srli	a5,a5,0x20
    80002cbe:	02a7f363          	bgeu	a5,a0,80002ce4 <argpstat+0x62>
    80002cc2:	9cb1                	addw	s1,s1,a2
    80002cc4:	1482                	slli	s1,s1,0x20
    80002cc6:	9081                	srli	s1,s1,0x20
    80002cc8:	00953533          	sltu	a0,a0,s1
    80002ccc:	40a0053b          	negw	a0,a0
    80002cd0:	2501                	sext.w	a0,a0
    return -1;

  pp = (struct pstat*)&p;
  return 0;
}
    80002cd2:	70e2                	ld	ra,56(sp)
    80002cd4:	7442                	ld	s0,48(sp)
    80002cd6:	74a2                	ld	s1,40(sp)
    80002cd8:	7902                	ld	s2,32(sp)
    80002cda:	69e2                	ld	s3,24(sp)
    80002cdc:	6121                	addi	sp,sp,64
    80002cde:	8082                	ret
    return -1;
    80002ce0:	557d                	li	a0,-1
    80002ce2:	bfc5                	j	80002cd2 <argpstat+0x50>
    80002ce4:	557d                	li	a0,-1
    80002ce6:	b7f5                	j	80002cd2 <argpstat+0x50>

0000000080002ce8 <syscall>:

};

void
syscall(void)
{
    80002ce8:	1101                	addi	sp,sp,-32
    80002cea:	ec06                	sd	ra,24(sp)
    80002cec:	e822                	sd	s0,16(sp)
    80002cee:	e426                	sd	s1,8(sp)
    80002cf0:	e04a                	sd	s2,0(sp)
    80002cf2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002cf4:	fffff097          	auipc	ra,0xfffff
    80002cf8:	cdc080e7          	jalr	-804(ra) # 800019d0 <myproc>
    80002cfc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002cfe:	05853903          	ld	s2,88(a0)
    80002d02:	0a893783          	ld	a5,168(s2)
    80002d06:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d0a:	37fd                	addiw	a5,a5,-1
    80002d0c:	4759                	li	a4,22
    80002d0e:	00f76f63          	bltu	a4,a5,80002d2c <syscall+0x44>
    80002d12:	00369713          	slli	a4,a3,0x3
    80002d16:	00005797          	auipc	a5,0x5
    80002d1a:	73a78793          	addi	a5,a5,1850 # 80008450 <syscalls>
    80002d1e:	97ba                	add	a5,a5,a4
    80002d20:	639c                	ld	a5,0(a5)
    80002d22:	c789                	beqz	a5,80002d2c <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d24:	9782                	jalr	a5
    80002d26:	06a93823          	sd	a0,112(s2)
    80002d2a:	a839                	j	80002d48 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d2c:	15848613          	addi	a2,s1,344
    80002d30:	588c                	lw	a1,48(s1)
    80002d32:	00005517          	auipc	a0,0x5
    80002d36:	6e650513          	addi	a0,a0,1766 # 80008418 <states.1742+0x150>
    80002d3a:	ffffe097          	auipc	ra,0xffffe
    80002d3e:	854080e7          	jalr	-1964(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d42:	6cbc                	ld	a5,88(s1)
    80002d44:	577d                	li	a4,-1
    80002d46:	fbb8                	sd	a4,112(a5)
  }
}
    80002d48:	60e2                	ld	ra,24(sp)
    80002d4a:	6442                	ld	s0,16(sp)
    80002d4c:	64a2                	ld	s1,8(sp)
    80002d4e:	6902                	ld	s2,0(sp)
    80002d50:	6105                	addi	sp,sp,32
    80002d52:	8082                	ret

0000000080002d54 <sys_exit>:
#include "proc.h"


uint64
sys_exit(void)
{
    80002d54:	1101                	addi	sp,sp,-32
    80002d56:	ec06                	sd	ra,24(sp)
    80002d58:	e822                	sd	s0,16(sp)
    80002d5a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002d5c:	fec40593          	addi	a1,s0,-20
    80002d60:	4501                	li	a0,0
    80002d62:	00000097          	auipc	ra,0x0
    80002d66:	ea8080e7          	jalr	-344(ra) # 80002c0a <argint>
  exit(n);
    80002d6a:	fec42503          	lw	a0,-20(s0)
    80002d6e:	fffff097          	auipc	ra,0xfffff
    80002d72:	43a080e7          	jalr	1082(ra) # 800021a8 <exit>
  return 0;  // not reached
}
    80002d76:	4501                	li	a0,0
    80002d78:	60e2                	ld	ra,24(sp)
    80002d7a:	6442                	ld	s0,16(sp)
    80002d7c:	6105                	addi	sp,sp,32
    80002d7e:	8082                	ret

0000000080002d80 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d80:	1141                	addi	sp,sp,-16
    80002d82:	e406                	sd	ra,8(sp)
    80002d84:	e022                	sd	s0,0(sp)
    80002d86:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	c48080e7          	jalr	-952(ra) # 800019d0 <myproc>
}
    80002d90:	5908                	lw	a0,48(a0)
    80002d92:	60a2                	ld	ra,8(sp)
    80002d94:	6402                	ld	s0,0(sp)
    80002d96:	0141                	addi	sp,sp,16
    80002d98:	8082                	ret

0000000080002d9a <sys_fork>:

uint64
sys_fork(void)
{
    80002d9a:	1141                	addi	sp,sp,-16
    80002d9c:	e406                	sd	ra,8(sp)
    80002d9e:	e022                	sd	s0,0(sp)
    80002da0:	0800                	addi	s0,sp,16
  return fork();
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	fe4080e7          	jalr	-28(ra) # 80001d86 <fork>
}
    80002daa:	60a2                	ld	ra,8(sp)
    80002dac:	6402                	ld	s0,0(sp)
    80002dae:	0141                	addi	sp,sp,16
    80002db0:	8082                	ret

0000000080002db2 <sys_wait>:

uint64
sys_wait(void)
{
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002dba:	fe840593          	addi	a1,s0,-24
    80002dbe:	4501                	li	a0,0
    80002dc0:	00000097          	auipc	ra,0x0
    80002dc4:	e6a080e7          	jalr	-406(ra) # 80002c2a <argaddr>
  return wait(p);
    80002dc8:	fe843503          	ld	a0,-24(s0)
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	582080e7          	jalr	1410(ra) # 8000234e <wait>
}
    80002dd4:	60e2                	ld	ra,24(sp)
    80002dd6:	6442                	ld	s0,16(sp)
    80002dd8:	6105                	addi	sp,sp,32
    80002dda:	8082                	ret

0000000080002ddc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ddc:	7179                	addi	sp,sp,-48
    80002dde:	f406                	sd	ra,40(sp)
    80002de0:	f022                	sd	s0,32(sp)
    80002de2:	ec26                	sd	s1,24(sp)
    80002de4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002de6:	fdc40593          	addi	a1,s0,-36
    80002dea:	4501                	li	a0,0
    80002dec:	00000097          	auipc	ra,0x0
    80002df0:	e1e080e7          	jalr	-482(ra) # 80002c0a <argint>
  addr = myproc()->sz;
    80002df4:	fffff097          	auipc	ra,0xfffff
    80002df8:	bdc080e7          	jalr	-1060(ra) # 800019d0 <myproc>
    80002dfc:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002dfe:	fdc42503          	lw	a0,-36(s0)
    80002e02:	fffff097          	auipc	ra,0xfffff
    80002e06:	f28080e7          	jalr	-216(ra) # 80001d2a <growproc>
    80002e0a:	00054863          	bltz	a0,80002e1a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002e0e:	8526                	mv	a0,s1
    80002e10:	70a2                	ld	ra,40(sp)
    80002e12:	7402                	ld	s0,32(sp)
    80002e14:	64e2                	ld	s1,24(sp)
    80002e16:	6145                	addi	sp,sp,48
    80002e18:	8082                	ret
    return -1;
    80002e1a:	54fd                	li	s1,-1
    80002e1c:	bfcd                	j	80002e0e <sys_sbrk+0x32>

0000000080002e1e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e1e:	7139                	addi	sp,sp,-64
    80002e20:	fc06                	sd	ra,56(sp)
    80002e22:	f822                	sd	s0,48(sp)
    80002e24:	f426                	sd	s1,40(sp)
    80002e26:	f04a                	sd	s2,32(sp)
    80002e28:	ec4e                	sd	s3,24(sp)
    80002e2a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e2c:	fcc40593          	addi	a1,s0,-52
    80002e30:	4501                	li	a0,0
    80002e32:	00000097          	auipc	ra,0x0
    80002e36:	dd8080e7          	jalr	-552(ra) # 80002c0a <argint>
  acquire(&tickslock);
    80002e3a:	00014517          	auipc	a0,0x14
    80002e3e:	b5650513          	addi	a0,a0,-1194 # 80016990 <tickslock>
    80002e42:	ffffe097          	auipc	ra,0xffffe
    80002e46:	da8080e7          	jalr	-600(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80002e4a:	00006917          	auipc	s2,0x6
    80002e4e:	aa692903          	lw	s2,-1370(s2) # 800088f0 <ticks>
  while(ticks - ticks0 < n){
    80002e52:	fcc42783          	lw	a5,-52(s0)
    80002e56:	cf9d                	beqz	a5,80002e94 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e58:	00014997          	auipc	s3,0x14
    80002e5c:	b3898993          	addi	s3,s3,-1224 # 80016990 <tickslock>
    80002e60:	00006497          	auipc	s1,0x6
    80002e64:	a9048493          	addi	s1,s1,-1392 # 800088f0 <ticks>
    if(killed(myproc())){
    80002e68:	fffff097          	auipc	ra,0xfffff
    80002e6c:	b68080e7          	jalr	-1176(ra) # 800019d0 <myproc>
    80002e70:	fffff097          	auipc	ra,0xfffff
    80002e74:	4ac080e7          	jalr	1196(ra) # 8000231c <killed>
    80002e78:	ed15                	bnez	a0,80002eb4 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002e7a:	85ce                	mv	a1,s3
    80002e7c:	8526                	mv	a0,s1
    80002e7e:	fffff097          	auipc	ra,0xfffff
    80002e82:	1f6080e7          	jalr	502(ra) # 80002074 <sleep>
  while(ticks - ticks0 < n){
    80002e86:	409c                	lw	a5,0(s1)
    80002e88:	412787bb          	subw	a5,a5,s2
    80002e8c:	fcc42703          	lw	a4,-52(s0)
    80002e90:	fce7ece3          	bltu	a5,a4,80002e68 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e94:	00014517          	auipc	a0,0x14
    80002e98:	afc50513          	addi	a0,a0,-1284 # 80016990 <tickslock>
    80002e9c:	ffffe097          	auipc	ra,0xffffe
    80002ea0:	e02080e7          	jalr	-510(ra) # 80000c9e <release>
  return 0;
    80002ea4:	4501                	li	a0,0
}
    80002ea6:	70e2                	ld	ra,56(sp)
    80002ea8:	7442                	ld	s0,48(sp)
    80002eaa:	74a2                	ld	s1,40(sp)
    80002eac:	7902                	ld	s2,32(sp)
    80002eae:	69e2                	ld	s3,24(sp)
    80002eb0:	6121                	addi	sp,sp,64
    80002eb2:	8082                	ret
      release(&tickslock);
    80002eb4:	00014517          	auipc	a0,0x14
    80002eb8:	adc50513          	addi	a0,a0,-1316 # 80016990 <tickslock>
    80002ebc:	ffffe097          	auipc	ra,0xffffe
    80002ec0:	de2080e7          	jalr	-542(ra) # 80000c9e <release>
      return -1;
    80002ec4:	557d                	li	a0,-1
    80002ec6:	b7c5                	j	80002ea6 <sys_sleep+0x88>

0000000080002ec8 <sys_kill>:

uint64
sys_kill(void)
{
    80002ec8:	1101                	addi	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ed0:	fec40593          	addi	a1,s0,-20
    80002ed4:	4501                	li	a0,0
    80002ed6:	00000097          	auipc	ra,0x0
    80002eda:	d34080e7          	jalr	-716(ra) # 80002c0a <argint>
  return kill(pid);
    80002ede:	fec42503          	lw	a0,-20(s0)
    80002ee2:	fffff097          	auipc	ra,0xfffff
    80002ee6:	39c080e7          	jalr	924(ra) # 8000227e <kill>
}
    80002eea:	60e2                	ld	ra,24(sp)
    80002eec:	6442                	ld	s0,16(sp)
    80002eee:	6105                	addi	sp,sp,32
    80002ef0:	8082                	ret

0000000080002ef2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ef2:	1101                	addi	sp,sp,-32
    80002ef4:	ec06                	sd	ra,24(sp)
    80002ef6:	e822                	sd	s0,16(sp)
    80002ef8:	e426                	sd	s1,8(sp)
    80002efa:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002efc:	00014517          	auipc	a0,0x14
    80002f00:	a9450513          	addi	a0,a0,-1388 # 80016990 <tickslock>
    80002f04:	ffffe097          	auipc	ra,0xffffe
    80002f08:	ce6080e7          	jalr	-794(ra) # 80000bea <acquire>
  xticks = ticks;
    80002f0c:	00006497          	auipc	s1,0x6
    80002f10:	9e44a483          	lw	s1,-1564(s1) # 800088f0 <ticks>
  release(&tickslock);
    80002f14:	00014517          	auipc	a0,0x14
    80002f18:	a7c50513          	addi	a0,a0,-1412 # 80016990 <tickslock>
    80002f1c:	ffffe097          	auipc	ra,0xffffe
    80002f20:	d82080e7          	jalr	-638(ra) # 80000c9e <release>
  return xticks;
}
    80002f24:	02049513          	slli	a0,s1,0x20
    80002f28:	9101                	srli	a0,a0,0x20
    80002f2a:	60e2                	ld	ra,24(sp)
    80002f2c:	6442                	ld	s0,16(sp)
    80002f2e:	64a2                	ld	s1,8(sp)
    80002f30:	6105                	addi	sp,sp,32
    80002f32:	8082                	ret

0000000080002f34 <sys_setpriority>:

/////////////////////////////////////////////////////////////////////////////////////////////////////
uint64
sys_setpriority(void)
{
    80002f34:	1101                	addi	sp,sp,-32
    80002f36:	ec06                	sd	ra,24(sp)
    80002f38:	e822                	sd	s0,16(sp)
    80002f3a:	1000                	addi	s0,sp,32
  int priority;
  argint(0, &priority);
    80002f3c:	fec40593          	addi	a1,s0,-20
    80002f40:	4501                	li	a0,0
    80002f42:	00000097          	auipc	ra,0x0
    80002f46:	cc8080e7          	jalr	-824(ra) # 80002c0a <argint>
  return setpriority(priority);
    80002f4a:	fec42503          	lw	a0,-20(s0)
    80002f4e:	fffff097          	auipc	ra,0xfffff
    80002f52:	688080e7          	jalr	1672(ra) # 800025d6 <setpriority>
}
    80002f56:	60e2                	ld	ra,24(sp)
    80002f58:	6442                	ld	s0,16(sp)
    80002f5a:	6105                	addi	sp,sp,32
    80002f5c:	8082                	ret

0000000080002f5e <sys_getpinfo>:


uint64
sys_getpinfo(void)
{
    80002f5e:	7179                	addi	sp,sp,-48
    80002f60:	f406                	sd	ra,40(sp)
    80002f62:	f022                	sd	s0,32(sp)
    80002f64:	ec26                	sd	s1,24(sp)
    80002f66:	1800                	addi	s0,sp,48
    80002f68:	81010113          	addi	sp,sp,-2032
  struct pstat stats;

  if(argpstat (0 , &stats ,sizeof(struct pstat)) < 0)
    80002f6c:	6605                	lui	a2,0x1
    80002f6e:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80002f72:	74fd                	lui	s1,0xfffff
    80002f74:	7f048793          	addi	a5,s1,2032 # fffffffffffff7f0 <end+0xffffffff7ffdda80>
    80002f78:	ff040713          	addi	a4,s0,-16
    80002f7c:	00f705b3          	add	a1,a4,a5
    80002f80:	4501                	li	a0,0
    80002f82:	00000097          	auipc	ra,0x0
    80002f86:	d00080e7          	jalr	-768(ra) # 80002c82 <argpstat>
    80002f8a:	87aa                	mv	a5,a0
    return -1;
    80002f8c:	557d                	li	a0,-1
  if(argpstat (0 , &stats ,sizeof(struct pstat)) < 0)
    80002f8e:	0007cc63          	bltz	a5,80002fa6 <sys_getpinfo+0x48>

  return getpinfo(&stats);
    80002f92:	7f048793          	addi	a5,s1,2032
    80002f96:	ff040713          	addi	a4,s0,-16
    80002f9a:	00f70533          	add	a0,a4,a5
    80002f9e:	fffff097          	auipc	ra,0xfffff
    80002fa2:	688080e7          	jalr	1672(ra) # 80002626 <getpinfo>
    80002fa6:	7f010113          	addi	sp,sp,2032
    80002faa:	70a2                	ld	ra,40(sp)
    80002fac:	7402                	ld	s0,32(sp)
    80002fae:	64e2                	ld	s1,24(sp)
    80002fb0:	6145                	addi	sp,sp,48
    80002fb2:	8082                	ret

0000000080002fb4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fb4:	7179                	addi	sp,sp,-48
    80002fb6:	f406                	sd	ra,40(sp)
    80002fb8:	f022                	sd	s0,32(sp)
    80002fba:	ec26                	sd	s1,24(sp)
    80002fbc:	e84a                	sd	s2,16(sp)
    80002fbe:	e44e                	sd	s3,8(sp)
    80002fc0:	e052                	sd	s4,0(sp)
    80002fc2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002fc4:	00005597          	auipc	a1,0x5
    80002fc8:	54c58593          	addi	a1,a1,1356 # 80008510 <syscalls+0xc0>
    80002fcc:	00014517          	auipc	a0,0x14
    80002fd0:	9dc50513          	addi	a0,a0,-1572 # 800169a8 <bcache>
    80002fd4:	ffffe097          	auipc	ra,0xffffe
    80002fd8:	b86080e7          	jalr	-1146(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fdc:	0001c797          	auipc	a5,0x1c
    80002fe0:	9cc78793          	addi	a5,a5,-1588 # 8001e9a8 <bcache+0x8000>
    80002fe4:	0001c717          	auipc	a4,0x1c
    80002fe8:	c2c70713          	addi	a4,a4,-980 # 8001ec10 <bcache+0x8268>
    80002fec:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ff0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ff4:	00014497          	auipc	s1,0x14
    80002ff8:	9cc48493          	addi	s1,s1,-1588 # 800169c0 <bcache+0x18>
    b->next = bcache.head.next;
    80002ffc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ffe:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003000:	00005a17          	auipc	s4,0x5
    80003004:	518a0a13          	addi	s4,s4,1304 # 80008518 <syscalls+0xc8>
    b->next = bcache.head.next;
    80003008:	2b893783          	ld	a5,696(s2)
    8000300c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000300e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003012:	85d2                	mv	a1,s4
    80003014:	01048513          	addi	a0,s1,16
    80003018:	00001097          	auipc	ra,0x1
    8000301c:	4c4080e7          	jalr	1220(ra) # 800044dc <initsleeplock>
    bcache.head.next->prev = b;
    80003020:	2b893783          	ld	a5,696(s2)
    80003024:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003026:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000302a:	45848493          	addi	s1,s1,1112
    8000302e:	fd349de3          	bne	s1,s3,80003008 <binit+0x54>
  }
}
    80003032:	70a2                	ld	ra,40(sp)
    80003034:	7402                	ld	s0,32(sp)
    80003036:	64e2                	ld	s1,24(sp)
    80003038:	6942                	ld	s2,16(sp)
    8000303a:	69a2                	ld	s3,8(sp)
    8000303c:	6a02                	ld	s4,0(sp)
    8000303e:	6145                	addi	sp,sp,48
    80003040:	8082                	ret

0000000080003042 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003042:	7179                	addi	sp,sp,-48
    80003044:	f406                	sd	ra,40(sp)
    80003046:	f022                	sd	s0,32(sp)
    80003048:	ec26                	sd	s1,24(sp)
    8000304a:	e84a                	sd	s2,16(sp)
    8000304c:	e44e                	sd	s3,8(sp)
    8000304e:	1800                	addi	s0,sp,48
    80003050:	89aa                	mv	s3,a0
    80003052:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003054:	00014517          	auipc	a0,0x14
    80003058:	95450513          	addi	a0,a0,-1708 # 800169a8 <bcache>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	b8e080e7          	jalr	-1138(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003064:	0001c497          	auipc	s1,0x1c
    80003068:	bfc4b483          	ld	s1,-1028(s1) # 8001ec60 <bcache+0x82b8>
    8000306c:	0001c797          	auipc	a5,0x1c
    80003070:	ba478793          	addi	a5,a5,-1116 # 8001ec10 <bcache+0x8268>
    80003074:	02f48f63          	beq	s1,a5,800030b2 <bread+0x70>
    80003078:	873e                	mv	a4,a5
    8000307a:	a021                	j	80003082 <bread+0x40>
    8000307c:	68a4                	ld	s1,80(s1)
    8000307e:	02e48a63          	beq	s1,a4,800030b2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003082:	449c                	lw	a5,8(s1)
    80003084:	ff379ce3          	bne	a5,s3,8000307c <bread+0x3a>
    80003088:	44dc                	lw	a5,12(s1)
    8000308a:	ff2799e3          	bne	a5,s2,8000307c <bread+0x3a>
      b->refcnt++;
    8000308e:	40bc                	lw	a5,64(s1)
    80003090:	2785                	addiw	a5,a5,1
    80003092:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003094:	00014517          	auipc	a0,0x14
    80003098:	91450513          	addi	a0,a0,-1772 # 800169a8 <bcache>
    8000309c:	ffffe097          	auipc	ra,0xffffe
    800030a0:	c02080e7          	jalr	-1022(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800030a4:	01048513          	addi	a0,s1,16
    800030a8:	00001097          	auipc	ra,0x1
    800030ac:	46e080e7          	jalr	1134(ra) # 80004516 <acquiresleep>
      return b;
    800030b0:	a8b9                	j	8000310e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030b2:	0001c497          	auipc	s1,0x1c
    800030b6:	ba64b483          	ld	s1,-1114(s1) # 8001ec58 <bcache+0x82b0>
    800030ba:	0001c797          	auipc	a5,0x1c
    800030be:	b5678793          	addi	a5,a5,-1194 # 8001ec10 <bcache+0x8268>
    800030c2:	00f48863          	beq	s1,a5,800030d2 <bread+0x90>
    800030c6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030c8:	40bc                	lw	a5,64(s1)
    800030ca:	cf81                	beqz	a5,800030e2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030cc:	64a4                	ld	s1,72(s1)
    800030ce:	fee49de3          	bne	s1,a4,800030c8 <bread+0x86>
  panic("bget: no buffers");
    800030d2:	00005517          	auipc	a0,0x5
    800030d6:	44e50513          	addi	a0,a0,1102 # 80008520 <syscalls+0xd0>
    800030da:	ffffd097          	auipc	ra,0xffffd
    800030de:	46a080e7          	jalr	1130(ra) # 80000544 <panic>
      b->dev = dev;
    800030e2:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800030e6:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800030ea:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030ee:	4785                	li	a5,1
    800030f0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030f2:	00014517          	auipc	a0,0x14
    800030f6:	8b650513          	addi	a0,a0,-1866 # 800169a8 <bcache>
    800030fa:	ffffe097          	auipc	ra,0xffffe
    800030fe:	ba4080e7          	jalr	-1116(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003102:	01048513          	addi	a0,s1,16
    80003106:	00001097          	auipc	ra,0x1
    8000310a:	410080e7          	jalr	1040(ra) # 80004516 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000310e:	409c                	lw	a5,0(s1)
    80003110:	cb89                	beqz	a5,80003122 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003112:	8526                	mv	a0,s1
    80003114:	70a2                	ld	ra,40(sp)
    80003116:	7402                	ld	s0,32(sp)
    80003118:	64e2                	ld	s1,24(sp)
    8000311a:	6942                	ld	s2,16(sp)
    8000311c:	69a2                	ld	s3,8(sp)
    8000311e:	6145                	addi	sp,sp,48
    80003120:	8082                	ret
    virtio_disk_rw(b, 0);
    80003122:	4581                	li	a1,0
    80003124:	8526                	mv	a0,s1
    80003126:	00003097          	auipc	ra,0x3
    8000312a:	fd2080e7          	jalr	-46(ra) # 800060f8 <virtio_disk_rw>
    b->valid = 1;
    8000312e:	4785                	li	a5,1
    80003130:	c09c                	sw	a5,0(s1)
  return b;
    80003132:	b7c5                	j	80003112 <bread+0xd0>

0000000080003134 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003134:	1101                	addi	sp,sp,-32
    80003136:	ec06                	sd	ra,24(sp)
    80003138:	e822                	sd	s0,16(sp)
    8000313a:	e426                	sd	s1,8(sp)
    8000313c:	1000                	addi	s0,sp,32
    8000313e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003140:	0541                	addi	a0,a0,16
    80003142:	00001097          	auipc	ra,0x1
    80003146:	46e080e7          	jalr	1134(ra) # 800045b0 <holdingsleep>
    8000314a:	cd01                	beqz	a0,80003162 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000314c:	4585                	li	a1,1
    8000314e:	8526                	mv	a0,s1
    80003150:	00003097          	auipc	ra,0x3
    80003154:	fa8080e7          	jalr	-88(ra) # 800060f8 <virtio_disk_rw>
}
    80003158:	60e2                	ld	ra,24(sp)
    8000315a:	6442                	ld	s0,16(sp)
    8000315c:	64a2                	ld	s1,8(sp)
    8000315e:	6105                	addi	sp,sp,32
    80003160:	8082                	ret
    panic("bwrite");
    80003162:	00005517          	auipc	a0,0x5
    80003166:	3d650513          	addi	a0,a0,982 # 80008538 <syscalls+0xe8>
    8000316a:	ffffd097          	auipc	ra,0xffffd
    8000316e:	3da080e7          	jalr	986(ra) # 80000544 <panic>

0000000080003172 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003172:	1101                	addi	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	e426                	sd	s1,8(sp)
    8000317a:	e04a                	sd	s2,0(sp)
    8000317c:	1000                	addi	s0,sp,32
    8000317e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003180:	01050913          	addi	s2,a0,16
    80003184:	854a                	mv	a0,s2
    80003186:	00001097          	auipc	ra,0x1
    8000318a:	42a080e7          	jalr	1066(ra) # 800045b0 <holdingsleep>
    8000318e:	c92d                	beqz	a0,80003200 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003190:	854a                	mv	a0,s2
    80003192:	00001097          	auipc	ra,0x1
    80003196:	3da080e7          	jalr	986(ra) # 8000456c <releasesleep>

  acquire(&bcache.lock);
    8000319a:	00014517          	auipc	a0,0x14
    8000319e:	80e50513          	addi	a0,a0,-2034 # 800169a8 <bcache>
    800031a2:	ffffe097          	auipc	ra,0xffffe
    800031a6:	a48080e7          	jalr	-1464(ra) # 80000bea <acquire>
  b->refcnt--;
    800031aa:	40bc                	lw	a5,64(s1)
    800031ac:	37fd                	addiw	a5,a5,-1
    800031ae:	0007871b          	sext.w	a4,a5
    800031b2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031b4:	eb05                	bnez	a4,800031e4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031b6:	68bc                	ld	a5,80(s1)
    800031b8:	64b8                	ld	a4,72(s1)
    800031ba:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800031bc:	64bc                	ld	a5,72(s1)
    800031be:	68b8                	ld	a4,80(s1)
    800031c0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031c2:	0001b797          	auipc	a5,0x1b
    800031c6:	7e678793          	addi	a5,a5,2022 # 8001e9a8 <bcache+0x8000>
    800031ca:	2b87b703          	ld	a4,696(a5)
    800031ce:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800031d0:	0001c717          	auipc	a4,0x1c
    800031d4:	a4070713          	addi	a4,a4,-1472 # 8001ec10 <bcache+0x8268>
    800031d8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800031da:	2b87b703          	ld	a4,696(a5)
    800031de:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800031e0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800031e4:	00013517          	auipc	a0,0x13
    800031e8:	7c450513          	addi	a0,a0,1988 # 800169a8 <bcache>
    800031ec:	ffffe097          	auipc	ra,0xffffe
    800031f0:	ab2080e7          	jalr	-1358(ra) # 80000c9e <release>
}
    800031f4:	60e2                	ld	ra,24(sp)
    800031f6:	6442                	ld	s0,16(sp)
    800031f8:	64a2                	ld	s1,8(sp)
    800031fa:	6902                	ld	s2,0(sp)
    800031fc:	6105                	addi	sp,sp,32
    800031fe:	8082                	ret
    panic("brelse");
    80003200:	00005517          	auipc	a0,0x5
    80003204:	34050513          	addi	a0,a0,832 # 80008540 <syscalls+0xf0>
    80003208:	ffffd097          	auipc	ra,0xffffd
    8000320c:	33c080e7          	jalr	828(ra) # 80000544 <panic>

0000000080003210 <bpin>:

void
bpin(struct buf *b) {
    80003210:	1101                	addi	sp,sp,-32
    80003212:	ec06                	sd	ra,24(sp)
    80003214:	e822                	sd	s0,16(sp)
    80003216:	e426                	sd	s1,8(sp)
    80003218:	1000                	addi	s0,sp,32
    8000321a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000321c:	00013517          	auipc	a0,0x13
    80003220:	78c50513          	addi	a0,a0,1932 # 800169a8 <bcache>
    80003224:	ffffe097          	auipc	ra,0xffffe
    80003228:	9c6080e7          	jalr	-1594(ra) # 80000bea <acquire>
  b->refcnt++;
    8000322c:	40bc                	lw	a5,64(s1)
    8000322e:	2785                	addiw	a5,a5,1
    80003230:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003232:	00013517          	auipc	a0,0x13
    80003236:	77650513          	addi	a0,a0,1910 # 800169a8 <bcache>
    8000323a:	ffffe097          	auipc	ra,0xffffe
    8000323e:	a64080e7          	jalr	-1436(ra) # 80000c9e <release>
}
    80003242:	60e2                	ld	ra,24(sp)
    80003244:	6442                	ld	s0,16(sp)
    80003246:	64a2                	ld	s1,8(sp)
    80003248:	6105                	addi	sp,sp,32
    8000324a:	8082                	ret

000000008000324c <bunpin>:

void
bunpin(struct buf *b) {
    8000324c:	1101                	addi	sp,sp,-32
    8000324e:	ec06                	sd	ra,24(sp)
    80003250:	e822                	sd	s0,16(sp)
    80003252:	e426                	sd	s1,8(sp)
    80003254:	1000                	addi	s0,sp,32
    80003256:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003258:	00013517          	auipc	a0,0x13
    8000325c:	75050513          	addi	a0,a0,1872 # 800169a8 <bcache>
    80003260:	ffffe097          	auipc	ra,0xffffe
    80003264:	98a080e7          	jalr	-1654(ra) # 80000bea <acquire>
  b->refcnt--;
    80003268:	40bc                	lw	a5,64(s1)
    8000326a:	37fd                	addiw	a5,a5,-1
    8000326c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000326e:	00013517          	auipc	a0,0x13
    80003272:	73a50513          	addi	a0,a0,1850 # 800169a8 <bcache>
    80003276:	ffffe097          	auipc	ra,0xffffe
    8000327a:	a28080e7          	jalr	-1496(ra) # 80000c9e <release>
}
    8000327e:	60e2                	ld	ra,24(sp)
    80003280:	6442                	ld	s0,16(sp)
    80003282:	64a2                	ld	s1,8(sp)
    80003284:	6105                	addi	sp,sp,32
    80003286:	8082                	ret

0000000080003288 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003288:	1101                	addi	sp,sp,-32
    8000328a:	ec06                	sd	ra,24(sp)
    8000328c:	e822                	sd	s0,16(sp)
    8000328e:	e426                	sd	s1,8(sp)
    80003290:	e04a                	sd	s2,0(sp)
    80003292:	1000                	addi	s0,sp,32
    80003294:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003296:	00d5d59b          	srliw	a1,a1,0xd
    8000329a:	0001c797          	auipc	a5,0x1c
    8000329e:	dea7a783          	lw	a5,-534(a5) # 8001f084 <sb+0x1c>
    800032a2:	9dbd                	addw	a1,a1,a5
    800032a4:	00000097          	auipc	ra,0x0
    800032a8:	d9e080e7          	jalr	-610(ra) # 80003042 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032ac:	0074f713          	andi	a4,s1,7
    800032b0:	4785                	li	a5,1
    800032b2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032b6:	14ce                	slli	s1,s1,0x33
    800032b8:	90d9                	srli	s1,s1,0x36
    800032ba:	00950733          	add	a4,a0,s1
    800032be:	05874703          	lbu	a4,88(a4)
    800032c2:	00e7f6b3          	and	a3,a5,a4
    800032c6:	c69d                	beqz	a3,800032f4 <bfree+0x6c>
    800032c8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032ca:	94aa                	add	s1,s1,a0
    800032cc:	fff7c793          	not	a5,a5
    800032d0:	8ff9                	and	a5,a5,a4
    800032d2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800032d6:	00001097          	auipc	ra,0x1
    800032da:	120080e7          	jalr	288(ra) # 800043f6 <log_write>
  brelse(bp);
    800032de:	854a                	mv	a0,s2
    800032e0:	00000097          	auipc	ra,0x0
    800032e4:	e92080e7          	jalr	-366(ra) # 80003172 <brelse>
}
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	64a2                	ld	s1,8(sp)
    800032ee:	6902                	ld	s2,0(sp)
    800032f0:	6105                	addi	sp,sp,32
    800032f2:	8082                	ret
    panic("freeing free block");
    800032f4:	00005517          	auipc	a0,0x5
    800032f8:	25450513          	addi	a0,a0,596 # 80008548 <syscalls+0xf8>
    800032fc:	ffffd097          	auipc	ra,0xffffd
    80003300:	248080e7          	jalr	584(ra) # 80000544 <panic>

0000000080003304 <balloc>:
{
    80003304:	711d                	addi	sp,sp,-96
    80003306:	ec86                	sd	ra,88(sp)
    80003308:	e8a2                	sd	s0,80(sp)
    8000330a:	e4a6                	sd	s1,72(sp)
    8000330c:	e0ca                	sd	s2,64(sp)
    8000330e:	fc4e                	sd	s3,56(sp)
    80003310:	f852                	sd	s4,48(sp)
    80003312:	f456                	sd	s5,40(sp)
    80003314:	f05a                	sd	s6,32(sp)
    80003316:	ec5e                	sd	s7,24(sp)
    80003318:	e862                	sd	s8,16(sp)
    8000331a:	e466                	sd	s9,8(sp)
    8000331c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000331e:	0001c797          	auipc	a5,0x1c
    80003322:	d4e7a783          	lw	a5,-690(a5) # 8001f06c <sb+0x4>
    80003326:	10078163          	beqz	a5,80003428 <balloc+0x124>
    8000332a:	8baa                	mv	s7,a0
    8000332c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000332e:	0001cb17          	auipc	s6,0x1c
    80003332:	d3ab0b13          	addi	s6,s6,-710 # 8001f068 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003336:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003338:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000333a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000333c:	6c89                	lui	s9,0x2
    8000333e:	a061                	j	800033c6 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003340:	974a                	add	a4,a4,s2
    80003342:	8fd5                	or	a5,a5,a3
    80003344:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003348:	854a                	mv	a0,s2
    8000334a:	00001097          	auipc	ra,0x1
    8000334e:	0ac080e7          	jalr	172(ra) # 800043f6 <log_write>
        brelse(bp);
    80003352:	854a                	mv	a0,s2
    80003354:	00000097          	auipc	ra,0x0
    80003358:	e1e080e7          	jalr	-482(ra) # 80003172 <brelse>
  bp = bread(dev, bno);
    8000335c:	85a6                	mv	a1,s1
    8000335e:	855e                	mv	a0,s7
    80003360:	00000097          	auipc	ra,0x0
    80003364:	ce2080e7          	jalr	-798(ra) # 80003042 <bread>
    80003368:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000336a:	40000613          	li	a2,1024
    8000336e:	4581                	li	a1,0
    80003370:	05850513          	addi	a0,a0,88
    80003374:	ffffe097          	auipc	ra,0xffffe
    80003378:	972080e7          	jalr	-1678(ra) # 80000ce6 <memset>
  log_write(bp);
    8000337c:	854a                	mv	a0,s2
    8000337e:	00001097          	auipc	ra,0x1
    80003382:	078080e7          	jalr	120(ra) # 800043f6 <log_write>
  brelse(bp);
    80003386:	854a                	mv	a0,s2
    80003388:	00000097          	auipc	ra,0x0
    8000338c:	dea080e7          	jalr	-534(ra) # 80003172 <brelse>
}
    80003390:	8526                	mv	a0,s1
    80003392:	60e6                	ld	ra,88(sp)
    80003394:	6446                	ld	s0,80(sp)
    80003396:	64a6                	ld	s1,72(sp)
    80003398:	6906                	ld	s2,64(sp)
    8000339a:	79e2                	ld	s3,56(sp)
    8000339c:	7a42                	ld	s4,48(sp)
    8000339e:	7aa2                	ld	s5,40(sp)
    800033a0:	7b02                	ld	s6,32(sp)
    800033a2:	6be2                	ld	s7,24(sp)
    800033a4:	6c42                	ld	s8,16(sp)
    800033a6:	6ca2                	ld	s9,8(sp)
    800033a8:	6125                	addi	sp,sp,96
    800033aa:	8082                	ret
    brelse(bp);
    800033ac:	854a                	mv	a0,s2
    800033ae:	00000097          	auipc	ra,0x0
    800033b2:	dc4080e7          	jalr	-572(ra) # 80003172 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033b6:	015c87bb          	addw	a5,s9,s5
    800033ba:	00078a9b          	sext.w	s5,a5
    800033be:	004b2703          	lw	a4,4(s6)
    800033c2:	06eaf363          	bgeu	s5,a4,80003428 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800033c6:	41fad79b          	sraiw	a5,s5,0x1f
    800033ca:	0137d79b          	srliw	a5,a5,0x13
    800033ce:	015787bb          	addw	a5,a5,s5
    800033d2:	40d7d79b          	sraiw	a5,a5,0xd
    800033d6:	01cb2583          	lw	a1,28(s6)
    800033da:	9dbd                	addw	a1,a1,a5
    800033dc:	855e                	mv	a0,s7
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	c64080e7          	jalr	-924(ra) # 80003042 <bread>
    800033e6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033e8:	004b2503          	lw	a0,4(s6)
    800033ec:	000a849b          	sext.w	s1,s5
    800033f0:	8662                	mv	a2,s8
    800033f2:	faa4fde3          	bgeu	s1,a0,800033ac <balloc+0xa8>
      m = 1 << (bi % 8);
    800033f6:	41f6579b          	sraiw	a5,a2,0x1f
    800033fa:	01d7d69b          	srliw	a3,a5,0x1d
    800033fe:	00c6873b          	addw	a4,a3,a2
    80003402:	00777793          	andi	a5,a4,7
    80003406:	9f95                	subw	a5,a5,a3
    80003408:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000340c:	4037571b          	sraiw	a4,a4,0x3
    80003410:	00e906b3          	add	a3,s2,a4
    80003414:	0586c683          	lbu	a3,88(a3)
    80003418:	00d7f5b3          	and	a1,a5,a3
    8000341c:	d195                	beqz	a1,80003340 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000341e:	2605                	addiw	a2,a2,1
    80003420:	2485                	addiw	s1,s1,1
    80003422:	fd4618e3          	bne	a2,s4,800033f2 <balloc+0xee>
    80003426:	b759                	j	800033ac <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003428:	00005517          	auipc	a0,0x5
    8000342c:	13850513          	addi	a0,a0,312 # 80008560 <syscalls+0x110>
    80003430:	ffffd097          	auipc	ra,0xffffd
    80003434:	15e080e7          	jalr	350(ra) # 8000058e <printf>
  return 0;
    80003438:	4481                	li	s1,0
    8000343a:	bf99                	j	80003390 <balloc+0x8c>

000000008000343c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000343c:	7179                	addi	sp,sp,-48
    8000343e:	f406                	sd	ra,40(sp)
    80003440:	f022                	sd	s0,32(sp)
    80003442:	ec26                	sd	s1,24(sp)
    80003444:	e84a                	sd	s2,16(sp)
    80003446:	e44e                	sd	s3,8(sp)
    80003448:	e052                	sd	s4,0(sp)
    8000344a:	1800                	addi	s0,sp,48
    8000344c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000344e:	47ad                	li	a5,11
    80003450:	02b7e763          	bltu	a5,a1,8000347e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003454:	02059493          	slli	s1,a1,0x20
    80003458:	9081                	srli	s1,s1,0x20
    8000345a:	048a                	slli	s1,s1,0x2
    8000345c:	94aa                	add	s1,s1,a0
    8000345e:	0504a903          	lw	s2,80(s1)
    80003462:	06091e63          	bnez	s2,800034de <bmap+0xa2>
      addr = balloc(ip->dev);
    80003466:	4108                	lw	a0,0(a0)
    80003468:	00000097          	auipc	ra,0x0
    8000346c:	e9c080e7          	jalr	-356(ra) # 80003304 <balloc>
    80003470:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003474:	06090563          	beqz	s2,800034de <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003478:	0524a823          	sw	s2,80(s1)
    8000347c:	a08d                	j	800034de <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000347e:	ff45849b          	addiw	s1,a1,-12
    80003482:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003486:	0ff00793          	li	a5,255
    8000348a:	08e7e563          	bltu	a5,a4,80003514 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000348e:	08052903          	lw	s2,128(a0)
    80003492:	00091d63          	bnez	s2,800034ac <bmap+0x70>
      addr = balloc(ip->dev);
    80003496:	4108                	lw	a0,0(a0)
    80003498:	00000097          	auipc	ra,0x0
    8000349c:	e6c080e7          	jalr	-404(ra) # 80003304 <balloc>
    800034a0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034a4:	02090d63          	beqz	s2,800034de <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034a8:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800034ac:	85ca                	mv	a1,s2
    800034ae:	0009a503          	lw	a0,0(s3)
    800034b2:	00000097          	auipc	ra,0x0
    800034b6:	b90080e7          	jalr	-1136(ra) # 80003042 <bread>
    800034ba:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034bc:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800034c0:	02049593          	slli	a1,s1,0x20
    800034c4:	9181                	srli	a1,a1,0x20
    800034c6:	058a                	slli	a1,a1,0x2
    800034c8:	00b784b3          	add	s1,a5,a1
    800034cc:	0004a903          	lw	s2,0(s1)
    800034d0:	02090063          	beqz	s2,800034f0 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800034d4:	8552                	mv	a0,s4
    800034d6:	00000097          	auipc	ra,0x0
    800034da:	c9c080e7          	jalr	-868(ra) # 80003172 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034de:	854a                	mv	a0,s2
    800034e0:	70a2                	ld	ra,40(sp)
    800034e2:	7402                	ld	s0,32(sp)
    800034e4:	64e2                	ld	s1,24(sp)
    800034e6:	6942                	ld	s2,16(sp)
    800034e8:	69a2                	ld	s3,8(sp)
    800034ea:	6a02                	ld	s4,0(sp)
    800034ec:	6145                	addi	sp,sp,48
    800034ee:	8082                	ret
      addr = balloc(ip->dev);
    800034f0:	0009a503          	lw	a0,0(s3)
    800034f4:	00000097          	auipc	ra,0x0
    800034f8:	e10080e7          	jalr	-496(ra) # 80003304 <balloc>
    800034fc:	0005091b          	sext.w	s2,a0
      if(addr){
    80003500:	fc090ae3          	beqz	s2,800034d4 <bmap+0x98>
        a[bn] = addr;
    80003504:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003508:	8552                	mv	a0,s4
    8000350a:	00001097          	auipc	ra,0x1
    8000350e:	eec080e7          	jalr	-276(ra) # 800043f6 <log_write>
    80003512:	b7c9                	j	800034d4 <bmap+0x98>
  panic("bmap: out of range");
    80003514:	00005517          	auipc	a0,0x5
    80003518:	06450513          	addi	a0,a0,100 # 80008578 <syscalls+0x128>
    8000351c:	ffffd097          	auipc	ra,0xffffd
    80003520:	028080e7          	jalr	40(ra) # 80000544 <panic>

0000000080003524 <iget>:
{
    80003524:	7179                	addi	sp,sp,-48
    80003526:	f406                	sd	ra,40(sp)
    80003528:	f022                	sd	s0,32(sp)
    8000352a:	ec26                	sd	s1,24(sp)
    8000352c:	e84a                	sd	s2,16(sp)
    8000352e:	e44e                	sd	s3,8(sp)
    80003530:	e052                	sd	s4,0(sp)
    80003532:	1800                	addi	s0,sp,48
    80003534:	89aa                	mv	s3,a0
    80003536:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003538:	0001c517          	auipc	a0,0x1c
    8000353c:	b5050513          	addi	a0,a0,-1200 # 8001f088 <itable>
    80003540:	ffffd097          	auipc	ra,0xffffd
    80003544:	6aa080e7          	jalr	1706(ra) # 80000bea <acquire>
  empty = 0;
    80003548:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000354a:	0001c497          	auipc	s1,0x1c
    8000354e:	b5648493          	addi	s1,s1,-1194 # 8001f0a0 <itable+0x18>
    80003552:	0001d697          	auipc	a3,0x1d
    80003556:	5de68693          	addi	a3,a3,1502 # 80020b30 <log>
    8000355a:	a039                	j	80003568 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000355c:	02090b63          	beqz	s2,80003592 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003560:	08848493          	addi	s1,s1,136
    80003564:	02d48a63          	beq	s1,a3,80003598 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003568:	449c                	lw	a5,8(s1)
    8000356a:	fef059e3          	blez	a5,8000355c <iget+0x38>
    8000356e:	4098                	lw	a4,0(s1)
    80003570:	ff3716e3          	bne	a4,s3,8000355c <iget+0x38>
    80003574:	40d8                	lw	a4,4(s1)
    80003576:	ff4713e3          	bne	a4,s4,8000355c <iget+0x38>
      ip->ref++;
    8000357a:	2785                	addiw	a5,a5,1
    8000357c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000357e:	0001c517          	auipc	a0,0x1c
    80003582:	b0a50513          	addi	a0,a0,-1270 # 8001f088 <itable>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	718080e7          	jalr	1816(ra) # 80000c9e <release>
      return ip;
    8000358e:	8926                	mv	s2,s1
    80003590:	a03d                	j	800035be <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003592:	f7f9                	bnez	a5,80003560 <iget+0x3c>
    80003594:	8926                	mv	s2,s1
    80003596:	b7e9                	j	80003560 <iget+0x3c>
  if(empty == 0)
    80003598:	02090c63          	beqz	s2,800035d0 <iget+0xac>
  ip->dev = dev;
    8000359c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035a0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035a4:	4785                	li	a5,1
    800035a6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035aa:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035ae:	0001c517          	auipc	a0,0x1c
    800035b2:	ada50513          	addi	a0,a0,-1318 # 8001f088 <itable>
    800035b6:	ffffd097          	auipc	ra,0xffffd
    800035ba:	6e8080e7          	jalr	1768(ra) # 80000c9e <release>
}
    800035be:	854a                	mv	a0,s2
    800035c0:	70a2                	ld	ra,40(sp)
    800035c2:	7402                	ld	s0,32(sp)
    800035c4:	64e2                	ld	s1,24(sp)
    800035c6:	6942                	ld	s2,16(sp)
    800035c8:	69a2                	ld	s3,8(sp)
    800035ca:	6a02                	ld	s4,0(sp)
    800035cc:	6145                	addi	sp,sp,48
    800035ce:	8082                	ret
    panic("iget: no inodes");
    800035d0:	00005517          	auipc	a0,0x5
    800035d4:	fc050513          	addi	a0,a0,-64 # 80008590 <syscalls+0x140>
    800035d8:	ffffd097          	auipc	ra,0xffffd
    800035dc:	f6c080e7          	jalr	-148(ra) # 80000544 <panic>

00000000800035e0 <fsinit>:
fsinit(int dev) {
    800035e0:	7179                	addi	sp,sp,-48
    800035e2:	f406                	sd	ra,40(sp)
    800035e4:	f022                	sd	s0,32(sp)
    800035e6:	ec26                	sd	s1,24(sp)
    800035e8:	e84a                	sd	s2,16(sp)
    800035ea:	e44e                	sd	s3,8(sp)
    800035ec:	1800                	addi	s0,sp,48
    800035ee:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035f0:	4585                	li	a1,1
    800035f2:	00000097          	auipc	ra,0x0
    800035f6:	a50080e7          	jalr	-1456(ra) # 80003042 <bread>
    800035fa:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035fc:	0001c997          	auipc	s3,0x1c
    80003600:	a6c98993          	addi	s3,s3,-1428 # 8001f068 <sb>
    80003604:	02000613          	li	a2,32
    80003608:	05850593          	addi	a1,a0,88
    8000360c:	854e                	mv	a0,s3
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	738080e7          	jalr	1848(ra) # 80000d46 <memmove>
  brelse(bp);
    80003616:	8526                	mv	a0,s1
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	b5a080e7          	jalr	-1190(ra) # 80003172 <brelse>
  if(sb.magic != FSMAGIC)
    80003620:	0009a703          	lw	a4,0(s3)
    80003624:	102037b7          	lui	a5,0x10203
    80003628:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000362c:	02f71263          	bne	a4,a5,80003650 <fsinit+0x70>
  initlog(dev, &sb);
    80003630:	0001c597          	auipc	a1,0x1c
    80003634:	a3858593          	addi	a1,a1,-1480 # 8001f068 <sb>
    80003638:	854a                	mv	a0,s2
    8000363a:	00001097          	auipc	ra,0x1
    8000363e:	b40080e7          	jalr	-1216(ra) # 8000417a <initlog>
}
    80003642:	70a2                	ld	ra,40(sp)
    80003644:	7402                	ld	s0,32(sp)
    80003646:	64e2                	ld	s1,24(sp)
    80003648:	6942                	ld	s2,16(sp)
    8000364a:	69a2                	ld	s3,8(sp)
    8000364c:	6145                	addi	sp,sp,48
    8000364e:	8082                	ret
    panic("invalid file system");
    80003650:	00005517          	auipc	a0,0x5
    80003654:	f5050513          	addi	a0,a0,-176 # 800085a0 <syscalls+0x150>
    80003658:	ffffd097          	auipc	ra,0xffffd
    8000365c:	eec080e7          	jalr	-276(ra) # 80000544 <panic>

0000000080003660 <iinit>:
{
    80003660:	7179                	addi	sp,sp,-48
    80003662:	f406                	sd	ra,40(sp)
    80003664:	f022                	sd	s0,32(sp)
    80003666:	ec26                	sd	s1,24(sp)
    80003668:	e84a                	sd	s2,16(sp)
    8000366a:	e44e                	sd	s3,8(sp)
    8000366c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000366e:	00005597          	auipc	a1,0x5
    80003672:	f4a58593          	addi	a1,a1,-182 # 800085b8 <syscalls+0x168>
    80003676:	0001c517          	auipc	a0,0x1c
    8000367a:	a1250513          	addi	a0,a0,-1518 # 8001f088 <itable>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	4dc080e7          	jalr	1244(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003686:	0001c497          	auipc	s1,0x1c
    8000368a:	a2a48493          	addi	s1,s1,-1494 # 8001f0b0 <itable+0x28>
    8000368e:	0001d997          	auipc	s3,0x1d
    80003692:	4b298993          	addi	s3,s3,1202 # 80020b40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003696:	00005917          	auipc	s2,0x5
    8000369a:	f2a90913          	addi	s2,s2,-214 # 800085c0 <syscalls+0x170>
    8000369e:	85ca                	mv	a1,s2
    800036a0:	8526                	mv	a0,s1
    800036a2:	00001097          	auipc	ra,0x1
    800036a6:	e3a080e7          	jalr	-454(ra) # 800044dc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036aa:	08848493          	addi	s1,s1,136
    800036ae:	ff3498e3          	bne	s1,s3,8000369e <iinit+0x3e>
}
    800036b2:	70a2                	ld	ra,40(sp)
    800036b4:	7402                	ld	s0,32(sp)
    800036b6:	64e2                	ld	s1,24(sp)
    800036b8:	6942                	ld	s2,16(sp)
    800036ba:	69a2                	ld	s3,8(sp)
    800036bc:	6145                	addi	sp,sp,48
    800036be:	8082                	ret

00000000800036c0 <ialloc>:
{
    800036c0:	715d                	addi	sp,sp,-80
    800036c2:	e486                	sd	ra,72(sp)
    800036c4:	e0a2                	sd	s0,64(sp)
    800036c6:	fc26                	sd	s1,56(sp)
    800036c8:	f84a                	sd	s2,48(sp)
    800036ca:	f44e                	sd	s3,40(sp)
    800036cc:	f052                	sd	s4,32(sp)
    800036ce:	ec56                	sd	s5,24(sp)
    800036d0:	e85a                	sd	s6,16(sp)
    800036d2:	e45e                	sd	s7,8(sp)
    800036d4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800036d6:	0001c717          	auipc	a4,0x1c
    800036da:	99e72703          	lw	a4,-1634(a4) # 8001f074 <sb+0xc>
    800036de:	4785                	li	a5,1
    800036e0:	04e7fa63          	bgeu	a5,a4,80003734 <ialloc+0x74>
    800036e4:	8aaa                	mv	s5,a0
    800036e6:	8bae                	mv	s7,a1
    800036e8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036ea:	0001ca17          	auipc	s4,0x1c
    800036ee:	97ea0a13          	addi	s4,s4,-1666 # 8001f068 <sb>
    800036f2:	00048b1b          	sext.w	s6,s1
    800036f6:	0044d593          	srli	a1,s1,0x4
    800036fa:	018a2783          	lw	a5,24(s4)
    800036fe:	9dbd                	addw	a1,a1,a5
    80003700:	8556                	mv	a0,s5
    80003702:	00000097          	auipc	ra,0x0
    80003706:	940080e7          	jalr	-1728(ra) # 80003042 <bread>
    8000370a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000370c:	05850993          	addi	s3,a0,88
    80003710:	00f4f793          	andi	a5,s1,15
    80003714:	079a                	slli	a5,a5,0x6
    80003716:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003718:	00099783          	lh	a5,0(s3)
    8000371c:	c3a1                	beqz	a5,8000375c <ialloc+0x9c>
    brelse(bp);
    8000371e:	00000097          	auipc	ra,0x0
    80003722:	a54080e7          	jalr	-1452(ra) # 80003172 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003726:	0485                	addi	s1,s1,1
    80003728:	00ca2703          	lw	a4,12(s4)
    8000372c:	0004879b          	sext.w	a5,s1
    80003730:	fce7e1e3          	bltu	a5,a4,800036f2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003734:	00005517          	auipc	a0,0x5
    80003738:	e9450513          	addi	a0,a0,-364 # 800085c8 <syscalls+0x178>
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	e52080e7          	jalr	-430(ra) # 8000058e <printf>
  return 0;
    80003744:	4501                	li	a0,0
}
    80003746:	60a6                	ld	ra,72(sp)
    80003748:	6406                	ld	s0,64(sp)
    8000374a:	74e2                	ld	s1,56(sp)
    8000374c:	7942                	ld	s2,48(sp)
    8000374e:	79a2                	ld	s3,40(sp)
    80003750:	7a02                	ld	s4,32(sp)
    80003752:	6ae2                	ld	s5,24(sp)
    80003754:	6b42                	ld	s6,16(sp)
    80003756:	6ba2                	ld	s7,8(sp)
    80003758:	6161                	addi	sp,sp,80
    8000375a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000375c:	04000613          	li	a2,64
    80003760:	4581                	li	a1,0
    80003762:	854e                	mv	a0,s3
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	582080e7          	jalr	1410(ra) # 80000ce6 <memset>
      dip->type = type;
    8000376c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003770:	854a                	mv	a0,s2
    80003772:	00001097          	auipc	ra,0x1
    80003776:	c84080e7          	jalr	-892(ra) # 800043f6 <log_write>
      brelse(bp);
    8000377a:	854a                	mv	a0,s2
    8000377c:	00000097          	auipc	ra,0x0
    80003780:	9f6080e7          	jalr	-1546(ra) # 80003172 <brelse>
      return iget(dev, inum);
    80003784:	85da                	mv	a1,s6
    80003786:	8556                	mv	a0,s5
    80003788:	00000097          	auipc	ra,0x0
    8000378c:	d9c080e7          	jalr	-612(ra) # 80003524 <iget>
    80003790:	bf5d                	j	80003746 <ialloc+0x86>

0000000080003792 <iupdate>:
{
    80003792:	1101                	addi	sp,sp,-32
    80003794:	ec06                	sd	ra,24(sp)
    80003796:	e822                	sd	s0,16(sp)
    80003798:	e426                	sd	s1,8(sp)
    8000379a:	e04a                	sd	s2,0(sp)
    8000379c:	1000                	addi	s0,sp,32
    8000379e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037a0:	415c                	lw	a5,4(a0)
    800037a2:	0047d79b          	srliw	a5,a5,0x4
    800037a6:	0001c597          	auipc	a1,0x1c
    800037aa:	8da5a583          	lw	a1,-1830(a1) # 8001f080 <sb+0x18>
    800037ae:	9dbd                	addw	a1,a1,a5
    800037b0:	4108                	lw	a0,0(a0)
    800037b2:	00000097          	auipc	ra,0x0
    800037b6:	890080e7          	jalr	-1904(ra) # 80003042 <bread>
    800037ba:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037bc:	05850793          	addi	a5,a0,88
    800037c0:	40c8                	lw	a0,4(s1)
    800037c2:	893d                	andi	a0,a0,15
    800037c4:	051a                	slli	a0,a0,0x6
    800037c6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800037c8:	04449703          	lh	a4,68(s1)
    800037cc:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800037d0:	04649703          	lh	a4,70(s1)
    800037d4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800037d8:	04849703          	lh	a4,72(s1)
    800037dc:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800037e0:	04a49703          	lh	a4,74(s1)
    800037e4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800037e8:	44f8                	lw	a4,76(s1)
    800037ea:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037ec:	03400613          	li	a2,52
    800037f0:	05048593          	addi	a1,s1,80
    800037f4:	0531                	addi	a0,a0,12
    800037f6:	ffffd097          	auipc	ra,0xffffd
    800037fa:	550080e7          	jalr	1360(ra) # 80000d46 <memmove>
  log_write(bp);
    800037fe:	854a                	mv	a0,s2
    80003800:	00001097          	auipc	ra,0x1
    80003804:	bf6080e7          	jalr	-1034(ra) # 800043f6 <log_write>
  brelse(bp);
    80003808:	854a                	mv	a0,s2
    8000380a:	00000097          	auipc	ra,0x0
    8000380e:	968080e7          	jalr	-1688(ra) # 80003172 <brelse>
}
    80003812:	60e2                	ld	ra,24(sp)
    80003814:	6442                	ld	s0,16(sp)
    80003816:	64a2                	ld	s1,8(sp)
    80003818:	6902                	ld	s2,0(sp)
    8000381a:	6105                	addi	sp,sp,32
    8000381c:	8082                	ret

000000008000381e <idup>:
{
    8000381e:	1101                	addi	sp,sp,-32
    80003820:	ec06                	sd	ra,24(sp)
    80003822:	e822                	sd	s0,16(sp)
    80003824:	e426                	sd	s1,8(sp)
    80003826:	1000                	addi	s0,sp,32
    80003828:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000382a:	0001c517          	auipc	a0,0x1c
    8000382e:	85e50513          	addi	a0,a0,-1954 # 8001f088 <itable>
    80003832:	ffffd097          	auipc	ra,0xffffd
    80003836:	3b8080e7          	jalr	952(ra) # 80000bea <acquire>
  ip->ref++;
    8000383a:	449c                	lw	a5,8(s1)
    8000383c:	2785                	addiw	a5,a5,1
    8000383e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003840:	0001c517          	auipc	a0,0x1c
    80003844:	84850513          	addi	a0,a0,-1976 # 8001f088 <itable>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	456080e7          	jalr	1110(ra) # 80000c9e <release>
}
    80003850:	8526                	mv	a0,s1
    80003852:	60e2                	ld	ra,24(sp)
    80003854:	6442                	ld	s0,16(sp)
    80003856:	64a2                	ld	s1,8(sp)
    80003858:	6105                	addi	sp,sp,32
    8000385a:	8082                	ret

000000008000385c <ilock>:
{
    8000385c:	1101                	addi	sp,sp,-32
    8000385e:	ec06                	sd	ra,24(sp)
    80003860:	e822                	sd	s0,16(sp)
    80003862:	e426                	sd	s1,8(sp)
    80003864:	e04a                	sd	s2,0(sp)
    80003866:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003868:	c115                	beqz	a0,8000388c <ilock+0x30>
    8000386a:	84aa                	mv	s1,a0
    8000386c:	451c                	lw	a5,8(a0)
    8000386e:	00f05f63          	blez	a5,8000388c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003872:	0541                	addi	a0,a0,16
    80003874:	00001097          	auipc	ra,0x1
    80003878:	ca2080e7          	jalr	-862(ra) # 80004516 <acquiresleep>
  if(ip->valid == 0){
    8000387c:	40bc                	lw	a5,64(s1)
    8000387e:	cf99                	beqz	a5,8000389c <ilock+0x40>
}
    80003880:	60e2                	ld	ra,24(sp)
    80003882:	6442                	ld	s0,16(sp)
    80003884:	64a2                	ld	s1,8(sp)
    80003886:	6902                	ld	s2,0(sp)
    80003888:	6105                	addi	sp,sp,32
    8000388a:	8082                	ret
    panic("ilock");
    8000388c:	00005517          	auipc	a0,0x5
    80003890:	d5450513          	addi	a0,a0,-684 # 800085e0 <syscalls+0x190>
    80003894:	ffffd097          	auipc	ra,0xffffd
    80003898:	cb0080e7          	jalr	-848(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000389c:	40dc                	lw	a5,4(s1)
    8000389e:	0047d79b          	srliw	a5,a5,0x4
    800038a2:	0001b597          	auipc	a1,0x1b
    800038a6:	7de5a583          	lw	a1,2014(a1) # 8001f080 <sb+0x18>
    800038aa:	9dbd                	addw	a1,a1,a5
    800038ac:	4088                	lw	a0,0(s1)
    800038ae:	fffff097          	auipc	ra,0xfffff
    800038b2:	794080e7          	jalr	1940(ra) # 80003042 <bread>
    800038b6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038b8:	05850593          	addi	a1,a0,88
    800038bc:	40dc                	lw	a5,4(s1)
    800038be:	8bbd                	andi	a5,a5,15
    800038c0:	079a                	slli	a5,a5,0x6
    800038c2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038c4:	00059783          	lh	a5,0(a1)
    800038c8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038cc:	00259783          	lh	a5,2(a1)
    800038d0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038d4:	00459783          	lh	a5,4(a1)
    800038d8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038dc:	00659783          	lh	a5,6(a1)
    800038e0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038e4:	459c                	lw	a5,8(a1)
    800038e6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038e8:	03400613          	li	a2,52
    800038ec:	05b1                	addi	a1,a1,12
    800038ee:	05048513          	addi	a0,s1,80
    800038f2:	ffffd097          	auipc	ra,0xffffd
    800038f6:	454080e7          	jalr	1108(ra) # 80000d46 <memmove>
    brelse(bp);
    800038fa:	854a                	mv	a0,s2
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	876080e7          	jalr	-1930(ra) # 80003172 <brelse>
    ip->valid = 1;
    80003904:	4785                	li	a5,1
    80003906:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003908:	04449783          	lh	a5,68(s1)
    8000390c:	fbb5                	bnez	a5,80003880 <ilock+0x24>
      panic("ilock: no type");
    8000390e:	00005517          	auipc	a0,0x5
    80003912:	cda50513          	addi	a0,a0,-806 # 800085e8 <syscalls+0x198>
    80003916:	ffffd097          	auipc	ra,0xffffd
    8000391a:	c2e080e7          	jalr	-978(ra) # 80000544 <panic>

000000008000391e <iunlock>:
{
    8000391e:	1101                	addi	sp,sp,-32
    80003920:	ec06                	sd	ra,24(sp)
    80003922:	e822                	sd	s0,16(sp)
    80003924:	e426                	sd	s1,8(sp)
    80003926:	e04a                	sd	s2,0(sp)
    80003928:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000392a:	c905                	beqz	a0,8000395a <iunlock+0x3c>
    8000392c:	84aa                	mv	s1,a0
    8000392e:	01050913          	addi	s2,a0,16
    80003932:	854a                	mv	a0,s2
    80003934:	00001097          	auipc	ra,0x1
    80003938:	c7c080e7          	jalr	-900(ra) # 800045b0 <holdingsleep>
    8000393c:	cd19                	beqz	a0,8000395a <iunlock+0x3c>
    8000393e:	449c                	lw	a5,8(s1)
    80003940:	00f05d63          	blez	a5,8000395a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003944:	854a                	mv	a0,s2
    80003946:	00001097          	auipc	ra,0x1
    8000394a:	c26080e7          	jalr	-986(ra) # 8000456c <releasesleep>
}
    8000394e:	60e2                	ld	ra,24(sp)
    80003950:	6442                	ld	s0,16(sp)
    80003952:	64a2                	ld	s1,8(sp)
    80003954:	6902                	ld	s2,0(sp)
    80003956:	6105                	addi	sp,sp,32
    80003958:	8082                	ret
    panic("iunlock");
    8000395a:	00005517          	auipc	a0,0x5
    8000395e:	c9e50513          	addi	a0,a0,-866 # 800085f8 <syscalls+0x1a8>
    80003962:	ffffd097          	auipc	ra,0xffffd
    80003966:	be2080e7          	jalr	-1054(ra) # 80000544 <panic>

000000008000396a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000396a:	7179                	addi	sp,sp,-48
    8000396c:	f406                	sd	ra,40(sp)
    8000396e:	f022                	sd	s0,32(sp)
    80003970:	ec26                	sd	s1,24(sp)
    80003972:	e84a                	sd	s2,16(sp)
    80003974:	e44e                	sd	s3,8(sp)
    80003976:	e052                	sd	s4,0(sp)
    80003978:	1800                	addi	s0,sp,48
    8000397a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000397c:	05050493          	addi	s1,a0,80
    80003980:	08050913          	addi	s2,a0,128
    80003984:	a021                	j	8000398c <itrunc+0x22>
    80003986:	0491                	addi	s1,s1,4
    80003988:	01248d63          	beq	s1,s2,800039a2 <itrunc+0x38>
    if(ip->addrs[i]){
    8000398c:	408c                	lw	a1,0(s1)
    8000398e:	dde5                	beqz	a1,80003986 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003990:	0009a503          	lw	a0,0(s3)
    80003994:	00000097          	auipc	ra,0x0
    80003998:	8f4080e7          	jalr	-1804(ra) # 80003288 <bfree>
      ip->addrs[i] = 0;
    8000399c:	0004a023          	sw	zero,0(s1)
    800039a0:	b7dd                	j	80003986 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039a2:	0809a583          	lw	a1,128(s3)
    800039a6:	e185                	bnez	a1,800039c6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039a8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039ac:	854e                	mv	a0,s3
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	de4080e7          	jalr	-540(ra) # 80003792 <iupdate>
}
    800039b6:	70a2                	ld	ra,40(sp)
    800039b8:	7402                	ld	s0,32(sp)
    800039ba:	64e2                	ld	s1,24(sp)
    800039bc:	6942                	ld	s2,16(sp)
    800039be:	69a2                	ld	s3,8(sp)
    800039c0:	6a02                	ld	s4,0(sp)
    800039c2:	6145                	addi	sp,sp,48
    800039c4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039c6:	0009a503          	lw	a0,0(s3)
    800039ca:	fffff097          	auipc	ra,0xfffff
    800039ce:	678080e7          	jalr	1656(ra) # 80003042 <bread>
    800039d2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039d4:	05850493          	addi	s1,a0,88
    800039d8:	45850913          	addi	s2,a0,1112
    800039dc:	a811                	j	800039f0 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800039de:	0009a503          	lw	a0,0(s3)
    800039e2:	00000097          	auipc	ra,0x0
    800039e6:	8a6080e7          	jalr	-1882(ra) # 80003288 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800039ea:	0491                	addi	s1,s1,4
    800039ec:	01248563          	beq	s1,s2,800039f6 <itrunc+0x8c>
      if(a[j])
    800039f0:	408c                	lw	a1,0(s1)
    800039f2:	dde5                	beqz	a1,800039ea <itrunc+0x80>
    800039f4:	b7ed                	j	800039de <itrunc+0x74>
    brelse(bp);
    800039f6:	8552                	mv	a0,s4
    800039f8:	fffff097          	auipc	ra,0xfffff
    800039fc:	77a080e7          	jalr	1914(ra) # 80003172 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a00:	0809a583          	lw	a1,128(s3)
    80003a04:	0009a503          	lw	a0,0(s3)
    80003a08:	00000097          	auipc	ra,0x0
    80003a0c:	880080e7          	jalr	-1920(ra) # 80003288 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a10:	0809a023          	sw	zero,128(s3)
    80003a14:	bf51                	j	800039a8 <itrunc+0x3e>

0000000080003a16 <iput>:
{
    80003a16:	1101                	addi	sp,sp,-32
    80003a18:	ec06                	sd	ra,24(sp)
    80003a1a:	e822                	sd	s0,16(sp)
    80003a1c:	e426                	sd	s1,8(sp)
    80003a1e:	e04a                	sd	s2,0(sp)
    80003a20:	1000                	addi	s0,sp,32
    80003a22:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a24:	0001b517          	auipc	a0,0x1b
    80003a28:	66450513          	addi	a0,a0,1636 # 8001f088 <itable>
    80003a2c:	ffffd097          	auipc	ra,0xffffd
    80003a30:	1be080e7          	jalr	446(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a34:	4498                	lw	a4,8(s1)
    80003a36:	4785                	li	a5,1
    80003a38:	02f70363          	beq	a4,a5,80003a5e <iput+0x48>
  ip->ref--;
    80003a3c:	449c                	lw	a5,8(s1)
    80003a3e:	37fd                	addiw	a5,a5,-1
    80003a40:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a42:	0001b517          	auipc	a0,0x1b
    80003a46:	64650513          	addi	a0,a0,1606 # 8001f088 <itable>
    80003a4a:	ffffd097          	auipc	ra,0xffffd
    80003a4e:	254080e7          	jalr	596(ra) # 80000c9e <release>
}
    80003a52:	60e2                	ld	ra,24(sp)
    80003a54:	6442                	ld	s0,16(sp)
    80003a56:	64a2                	ld	s1,8(sp)
    80003a58:	6902                	ld	s2,0(sp)
    80003a5a:	6105                	addi	sp,sp,32
    80003a5c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a5e:	40bc                	lw	a5,64(s1)
    80003a60:	dff1                	beqz	a5,80003a3c <iput+0x26>
    80003a62:	04a49783          	lh	a5,74(s1)
    80003a66:	fbf9                	bnez	a5,80003a3c <iput+0x26>
    acquiresleep(&ip->lock);
    80003a68:	01048913          	addi	s2,s1,16
    80003a6c:	854a                	mv	a0,s2
    80003a6e:	00001097          	auipc	ra,0x1
    80003a72:	aa8080e7          	jalr	-1368(ra) # 80004516 <acquiresleep>
    release(&itable.lock);
    80003a76:	0001b517          	auipc	a0,0x1b
    80003a7a:	61250513          	addi	a0,a0,1554 # 8001f088 <itable>
    80003a7e:	ffffd097          	auipc	ra,0xffffd
    80003a82:	220080e7          	jalr	544(ra) # 80000c9e <release>
    itrunc(ip);
    80003a86:	8526                	mv	a0,s1
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	ee2080e7          	jalr	-286(ra) # 8000396a <itrunc>
    ip->type = 0;
    80003a90:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a94:	8526                	mv	a0,s1
    80003a96:	00000097          	auipc	ra,0x0
    80003a9a:	cfc080e7          	jalr	-772(ra) # 80003792 <iupdate>
    ip->valid = 0;
    80003a9e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003aa2:	854a                	mv	a0,s2
    80003aa4:	00001097          	auipc	ra,0x1
    80003aa8:	ac8080e7          	jalr	-1336(ra) # 8000456c <releasesleep>
    acquire(&itable.lock);
    80003aac:	0001b517          	auipc	a0,0x1b
    80003ab0:	5dc50513          	addi	a0,a0,1500 # 8001f088 <itable>
    80003ab4:	ffffd097          	auipc	ra,0xffffd
    80003ab8:	136080e7          	jalr	310(ra) # 80000bea <acquire>
    80003abc:	b741                	j	80003a3c <iput+0x26>

0000000080003abe <iunlockput>:
{
    80003abe:	1101                	addi	sp,sp,-32
    80003ac0:	ec06                	sd	ra,24(sp)
    80003ac2:	e822                	sd	s0,16(sp)
    80003ac4:	e426                	sd	s1,8(sp)
    80003ac6:	1000                	addi	s0,sp,32
    80003ac8:	84aa                	mv	s1,a0
  iunlock(ip);
    80003aca:	00000097          	auipc	ra,0x0
    80003ace:	e54080e7          	jalr	-428(ra) # 8000391e <iunlock>
  iput(ip);
    80003ad2:	8526                	mv	a0,s1
    80003ad4:	00000097          	auipc	ra,0x0
    80003ad8:	f42080e7          	jalr	-190(ra) # 80003a16 <iput>
}
    80003adc:	60e2                	ld	ra,24(sp)
    80003ade:	6442                	ld	s0,16(sp)
    80003ae0:	64a2                	ld	s1,8(sp)
    80003ae2:	6105                	addi	sp,sp,32
    80003ae4:	8082                	ret

0000000080003ae6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ae6:	1141                	addi	sp,sp,-16
    80003ae8:	e422                	sd	s0,8(sp)
    80003aea:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003aec:	411c                	lw	a5,0(a0)
    80003aee:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003af0:	415c                	lw	a5,4(a0)
    80003af2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003af4:	04451783          	lh	a5,68(a0)
    80003af8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003afc:	04a51783          	lh	a5,74(a0)
    80003b00:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b04:	04c56783          	lwu	a5,76(a0)
    80003b08:	e99c                	sd	a5,16(a1)
}
    80003b0a:	6422                	ld	s0,8(sp)
    80003b0c:	0141                	addi	sp,sp,16
    80003b0e:	8082                	ret

0000000080003b10 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b10:	457c                	lw	a5,76(a0)
    80003b12:	0ed7e963          	bltu	a5,a3,80003c04 <readi+0xf4>
{
    80003b16:	7159                	addi	sp,sp,-112
    80003b18:	f486                	sd	ra,104(sp)
    80003b1a:	f0a2                	sd	s0,96(sp)
    80003b1c:	eca6                	sd	s1,88(sp)
    80003b1e:	e8ca                	sd	s2,80(sp)
    80003b20:	e4ce                	sd	s3,72(sp)
    80003b22:	e0d2                	sd	s4,64(sp)
    80003b24:	fc56                	sd	s5,56(sp)
    80003b26:	f85a                	sd	s6,48(sp)
    80003b28:	f45e                	sd	s7,40(sp)
    80003b2a:	f062                	sd	s8,32(sp)
    80003b2c:	ec66                	sd	s9,24(sp)
    80003b2e:	e86a                	sd	s10,16(sp)
    80003b30:	e46e                	sd	s11,8(sp)
    80003b32:	1880                	addi	s0,sp,112
    80003b34:	8b2a                	mv	s6,a0
    80003b36:	8bae                	mv	s7,a1
    80003b38:	8a32                	mv	s4,a2
    80003b3a:	84b6                	mv	s1,a3
    80003b3c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b3e:	9f35                	addw	a4,a4,a3
    return 0;
    80003b40:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b42:	0ad76063          	bltu	a4,a3,80003be2 <readi+0xd2>
  if(off + n > ip->size)
    80003b46:	00e7f463          	bgeu	a5,a4,80003b4e <readi+0x3e>
    n = ip->size - off;
    80003b4a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b4e:	0a0a8963          	beqz	s5,80003c00 <readi+0xf0>
    80003b52:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b54:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b58:	5c7d                	li	s8,-1
    80003b5a:	a82d                	j	80003b94 <readi+0x84>
    80003b5c:	020d1d93          	slli	s11,s10,0x20
    80003b60:	020ddd93          	srli	s11,s11,0x20
    80003b64:	05890613          	addi	a2,s2,88
    80003b68:	86ee                	mv	a3,s11
    80003b6a:	963a                	add	a2,a2,a4
    80003b6c:	85d2                	mv	a1,s4
    80003b6e:	855e                	mv	a0,s7
    80003b70:	fffff097          	auipc	ra,0xfffff
    80003b74:	90c080e7          	jalr	-1780(ra) # 8000247c <either_copyout>
    80003b78:	05850d63          	beq	a0,s8,80003bd2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b7c:	854a                	mv	a0,s2
    80003b7e:	fffff097          	auipc	ra,0xfffff
    80003b82:	5f4080e7          	jalr	1524(ra) # 80003172 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b86:	013d09bb          	addw	s3,s10,s3
    80003b8a:	009d04bb          	addw	s1,s10,s1
    80003b8e:	9a6e                	add	s4,s4,s11
    80003b90:	0559f763          	bgeu	s3,s5,80003bde <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003b94:	00a4d59b          	srliw	a1,s1,0xa
    80003b98:	855a                	mv	a0,s6
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	8a2080e7          	jalr	-1886(ra) # 8000343c <bmap>
    80003ba2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ba6:	cd85                	beqz	a1,80003bde <readi+0xce>
    bp = bread(ip->dev, addr);
    80003ba8:	000b2503          	lw	a0,0(s6)
    80003bac:	fffff097          	auipc	ra,0xfffff
    80003bb0:	496080e7          	jalr	1174(ra) # 80003042 <bread>
    80003bb4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bb6:	3ff4f713          	andi	a4,s1,1023
    80003bba:	40ec87bb          	subw	a5,s9,a4
    80003bbe:	413a86bb          	subw	a3,s5,s3
    80003bc2:	8d3e                	mv	s10,a5
    80003bc4:	2781                	sext.w	a5,a5
    80003bc6:	0006861b          	sext.w	a2,a3
    80003bca:	f8f679e3          	bgeu	a2,a5,80003b5c <readi+0x4c>
    80003bce:	8d36                	mv	s10,a3
    80003bd0:	b771                	j	80003b5c <readi+0x4c>
      brelse(bp);
    80003bd2:	854a                	mv	a0,s2
    80003bd4:	fffff097          	auipc	ra,0xfffff
    80003bd8:	59e080e7          	jalr	1438(ra) # 80003172 <brelse>
      tot = -1;
    80003bdc:	59fd                	li	s3,-1
  }
  return tot;
    80003bde:	0009851b          	sext.w	a0,s3
}
    80003be2:	70a6                	ld	ra,104(sp)
    80003be4:	7406                	ld	s0,96(sp)
    80003be6:	64e6                	ld	s1,88(sp)
    80003be8:	6946                	ld	s2,80(sp)
    80003bea:	69a6                	ld	s3,72(sp)
    80003bec:	6a06                	ld	s4,64(sp)
    80003bee:	7ae2                	ld	s5,56(sp)
    80003bf0:	7b42                	ld	s6,48(sp)
    80003bf2:	7ba2                	ld	s7,40(sp)
    80003bf4:	7c02                	ld	s8,32(sp)
    80003bf6:	6ce2                	ld	s9,24(sp)
    80003bf8:	6d42                	ld	s10,16(sp)
    80003bfa:	6da2                	ld	s11,8(sp)
    80003bfc:	6165                	addi	sp,sp,112
    80003bfe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c00:	89d6                	mv	s3,s5
    80003c02:	bff1                	j	80003bde <readi+0xce>
    return 0;
    80003c04:	4501                	li	a0,0
}
    80003c06:	8082                	ret

0000000080003c08 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c08:	457c                	lw	a5,76(a0)
    80003c0a:	10d7e863          	bltu	a5,a3,80003d1a <writei+0x112>
{
    80003c0e:	7159                	addi	sp,sp,-112
    80003c10:	f486                	sd	ra,104(sp)
    80003c12:	f0a2                	sd	s0,96(sp)
    80003c14:	eca6                	sd	s1,88(sp)
    80003c16:	e8ca                	sd	s2,80(sp)
    80003c18:	e4ce                	sd	s3,72(sp)
    80003c1a:	e0d2                	sd	s4,64(sp)
    80003c1c:	fc56                	sd	s5,56(sp)
    80003c1e:	f85a                	sd	s6,48(sp)
    80003c20:	f45e                	sd	s7,40(sp)
    80003c22:	f062                	sd	s8,32(sp)
    80003c24:	ec66                	sd	s9,24(sp)
    80003c26:	e86a                	sd	s10,16(sp)
    80003c28:	e46e                	sd	s11,8(sp)
    80003c2a:	1880                	addi	s0,sp,112
    80003c2c:	8aaa                	mv	s5,a0
    80003c2e:	8bae                	mv	s7,a1
    80003c30:	8a32                	mv	s4,a2
    80003c32:	8936                	mv	s2,a3
    80003c34:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c36:	00e687bb          	addw	a5,a3,a4
    80003c3a:	0ed7e263          	bltu	a5,a3,80003d1e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c3e:	00043737          	lui	a4,0x43
    80003c42:	0ef76063          	bltu	a4,a5,80003d22 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c46:	0c0b0863          	beqz	s6,80003d16 <writei+0x10e>
    80003c4a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c4c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c50:	5c7d                	li	s8,-1
    80003c52:	a091                	j	80003c96 <writei+0x8e>
    80003c54:	020d1d93          	slli	s11,s10,0x20
    80003c58:	020ddd93          	srli	s11,s11,0x20
    80003c5c:	05848513          	addi	a0,s1,88
    80003c60:	86ee                	mv	a3,s11
    80003c62:	8652                	mv	a2,s4
    80003c64:	85de                	mv	a1,s7
    80003c66:	953a                	add	a0,a0,a4
    80003c68:	fffff097          	auipc	ra,0xfffff
    80003c6c:	86a080e7          	jalr	-1942(ra) # 800024d2 <either_copyin>
    80003c70:	07850263          	beq	a0,s8,80003cd4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c74:	8526                	mv	a0,s1
    80003c76:	00000097          	auipc	ra,0x0
    80003c7a:	780080e7          	jalr	1920(ra) # 800043f6 <log_write>
    brelse(bp);
    80003c7e:	8526                	mv	a0,s1
    80003c80:	fffff097          	auipc	ra,0xfffff
    80003c84:	4f2080e7          	jalr	1266(ra) # 80003172 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c88:	013d09bb          	addw	s3,s10,s3
    80003c8c:	012d093b          	addw	s2,s10,s2
    80003c90:	9a6e                	add	s4,s4,s11
    80003c92:	0569f663          	bgeu	s3,s6,80003cde <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003c96:	00a9559b          	srliw	a1,s2,0xa
    80003c9a:	8556                	mv	a0,s5
    80003c9c:	fffff097          	auipc	ra,0xfffff
    80003ca0:	7a0080e7          	jalr	1952(ra) # 8000343c <bmap>
    80003ca4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ca8:	c99d                	beqz	a1,80003cde <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003caa:	000aa503          	lw	a0,0(s5)
    80003cae:	fffff097          	auipc	ra,0xfffff
    80003cb2:	394080e7          	jalr	916(ra) # 80003042 <bread>
    80003cb6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cb8:	3ff97713          	andi	a4,s2,1023
    80003cbc:	40ec87bb          	subw	a5,s9,a4
    80003cc0:	413b06bb          	subw	a3,s6,s3
    80003cc4:	8d3e                	mv	s10,a5
    80003cc6:	2781                	sext.w	a5,a5
    80003cc8:	0006861b          	sext.w	a2,a3
    80003ccc:	f8f674e3          	bgeu	a2,a5,80003c54 <writei+0x4c>
    80003cd0:	8d36                	mv	s10,a3
    80003cd2:	b749                	j	80003c54 <writei+0x4c>
      brelse(bp);
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	fffff097          	auipc	ra,0xfffff
    80003cda:	49c080e7          	jalr	1180(ra) # 80003172 <brelse>
  }

  if(off > ip->size)
    80003cde:	04caa783          	lw	a5,76(s5)
    80003ce2:	0127f463          	bgeu	a5,s2,80003cea <writei+0xe2>
    ip->size = off;
    80003ce6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003cea:	8556                	mv	a0,s5
    80003cec:	00000097          	auipc	ra,0x0
    80003cf0:	aa6080e7          	jalr	-1370(ra) # 80003792 <iupdate>

  return tot;
    80003cf4:	0009851b          	sext.w	a0,s3
}
    80003cf8:	70a6                	ld	ra,104(sp)
    80003cfa:	7406                	ld	s0,96(sp)
    80003cfc:	64e6                	ld	s1,88(sp)
    80003cfe:	6946                	ld	s2,80(sp)
    80003d00:	69a6                	ld	s3,72(sp)
    80003d02:	6a06                	ld	s4,64(sp)
    80003d04:	7ae2                	ld	s5,56(sp)
    80003d06:	7b42                	ld	s6,48(sp)
    80003d08:	7ba2                	ld	s7,40(sp)
    80003d0a:	7c02                	ld	s8,32(sp)
    80003d0c:	6ce2                	ld	s9,24(sp)
    80003d0e:	6d42                	ld	s10,16(sp)
    80003d10:	6da2                	ld	s11,8(sp)
    80003d12:	6165                	addi	sp,sp,112
    80003d14:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d16:	89da                	mv	s3,s6
    80003d18:	bfc9                	j	80003cea <writei+0xe2>
    return -1;
    80003d1a:	557d                	li	a0,-1
}
    80003d1c:	8082                	ret
    return -1;
    80003d1e:	557d                	li	a0,-1
    80003d20:	bfe1                	j	80003cf8 <writei+0xf0>
    return -1;
    80003d22:	557d                	li	a0,-1
    80003d24:	bfd1                	j	80003cf8 <writei+0xf0>

0000000080003d26 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d26:	1141                	addi	sp,sp,-16
    80003d28:	e406                	sd	ra,8(sp)
    80003d2a:	e022                	sd	s0,0(sp)
    80003d2c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d2e:	4639                	li	a2,14
    80003d30:	ffffd097          	auipc	ra,0xffffd
    80003d34:	08e080e7          	jalr	142(ra) # 80000dbe <strncmp>
}
    80003d38:	60a2                	ld	ra,8(sp)
    80003d3a:	6402                	ld	s0,0(sp)
    80003d3c:	0141                	addi	sp,sp,16
    80003d3e:	8082                	ret

0000000080003d40 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d40:	7139                	addi	sp,sp,-64
    80003d42:	fc06                	sd	ra,56(sp)
    80003d44:	f822                	sd	s0,48(sp)
    80003d46:	f426                	sd	s1,40(sp)
    80003d48:	f04a                	sd	s2,32(sp)
    80003d4a:	ec4e                	sd	s3,24(sp)
    80003d4c:	e852                	sd	s4,16(sp)
    80003d4e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d50:	04451703          	lh	a4,68(a0)
    80003d54:	4785                	li	a5,1
    80003d56:	00f71a63          	bne	a4,a5,80003d6a <dirlookup+0x2a>
    80003d5a:	892a                	mv	s2,a0
    80003d5c:	89ae                	mv	s3,a1
    80003d5e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d60:	457c                	lw	a5,76(a0)
    80003d62:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d64:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d66:	e79d                	bnez	a5,80003d94 <dirlookup+0x54>
    80003d68:	a8a5                	j	80003de0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d6a:	00005517          	auipc	a0,0x5
    80003d6e:	89650513          	addi	a0,a0,-1898 # 80008600 <syscalls+0x1b0>
    80003d72:	ffffc097          	auipc	ra,0xffffc
    80003d76:	7d2080e7          	jalr	2002(ra) # 80000544 <panic>
      panic("dirlookup read");
    80003d7a:	00005517          	auipc	a0,0x5
    80003d7e:	89e50513          	addi	a0,a0,-1890 # 80008618 <syscalls+0x1c8>
    80003d82:	ffffc097          	auipc	ra,0xffffc
    80003d86:	7c2080e7          	jalr	1986(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d8a:	24c1                	addiw	s1,s1,16
    80003d8c:	04c92783          	lw	a5,76(s2)
    80003d90:	04f4f763          	bgeu	s1,a5,80003dde <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d94:	4741                	li	a4,16
    80003d96:	86a6                	mv	a3,s1
    80003d98:	fc040613          	addi	a2,s0,-64
    80003d9c:	4581                	li	a1,0
    80003d9e:	854a                	mv	a0,s2
    80003da0:	00000097          	auipc	ra,0x0
    80003da4:	d70080e7          	jalr	-656(ra) # 80003b10 <readi>
    80003da8:	47c1                	li	a5,16
    80003daa:	fcf518e3          	bne	a0,a5,80003d7a <dirlookup+0x3a>
    if(de.inum == 0)
    80003dae:	fc045783          	lhu	a5,-64(s0)
    80003db2:	dfe1                	beqz	a5,80003d8a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003db4:	fc240593          	addi	a1,s0,-62
    80003db8:	854e                	mv	a0,s3
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	f6c080e7          	jalr	-148(ra) # 80003d26 <namecmp>
    80003dc2:	f561                	bnez	a0,80003d8a <dirlookup+0x4a>
      if(poff)
    80003dc4:	000a0463          	beqz	s4,80003dcc <dirlookup+0x8c>
        *poff = off;
    80003dc8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003dcc:	fc045583          	lhu	a1,-64(s0)
    80003dd0:	00092503          	lw	a0,0(s2)
    80003dd4:	fffff097          	auipc	ra,0xfffff
    80003dd8:	750080e7          	jalr	1872(ra) # 80003524 <iget>
    80003ddc:	a011                	j	80003de0 <dirlookup+0xa0>
  return 0;
    80003dde:	4501                	li	a0,0
}
    80003de0:	70e2                	ld	ra,56(sp)
    80003de2:	7442                	ld	s0,48(sp)
    80003de4:	74a2                	ld	s1,40(sp)
    80003de6:	7902                	ld	s2,32(sp)
    80003de8:	69e2                	ld	s3,24(sp)
    80003dea:	6a42                	ld	s4,16(sp)
    80003dec:	6121                	addi	sp,sp,64
    80003dee:	8082                	ret

0000000080003df0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003df0:	711d                	addi	sp,sp,-96
    80003df2:	ec86                	sd	ra,88(sp)
    80003df4:	e8a2                	sd	s0,80(sp)
    80003df6:	e4a6                	sd	s1,72(sp)
    80003df8:	e0ca                	sd	s2,64(sp)
    80003dfa:	fc4e                	sd	s3,56(sp)
    80003dfc:	f852                	sd	s4,48(sp)
    80003dfe:	f456                	sd	s5,40(sp)
    80003e00:	f05a                	sd	s6,32(sp)
    80003e02:	ec5e                	sd	s7,24(sp)
    80003e04:	e862                	sd	s8,16(sp)
    80003e06:	e466                	sd	s9,8(sp)
    80003e08:	1080                	addi	s0,sp,96
    80003e0a:	84aa                	mv	s1,a0
    80003e0c:	8b2e                	mv	s6,a1
    80003e0e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e10:	00054703          	lbu	a4,0(a0)
    80003e14:	02f00793          	li	a5,47
    80003e18:	02f70363          	beq	a4,a5,80003e3e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e1c:	ffffe097          	auipc	ra,0xffffe
    80003e20:	bb4080e7          	jalr	-1100(ra) # 800019d0 <myproc>
    80003e24:	15053503          	ld	a0,336(a0)
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	9f6080e7          	jalr	-1546(ra) # 8000381e <idup>
    80003e30:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e32:	02f00913          	li	s2,47
  len = path - s;
    80003e36:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003e38:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e3a:	4c05                	li	s8,1
    80003e3c:	a865                	j	80003ef4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e3e:	4585                	li	a1,1
    80003e40:	4505                	li	a0,1
    80003e42:	fffff097          	auipc	ra,0xfffff
    80003e46:	6e2080e7          	jalr	1762(ra) # 80003524 <iget>
    80003e4a:	89aa                	mv	s3,a0
    80003e4c:	b7dd                	j	80003e32 <namex+0x42>
      iunlockput(ip);
    80003e4e:	854e                	mv	a0,s3
    80003e50:	00000097          	auipc	ra,0x0
    80003e54:	c6e080e7          	jalr	-914(ra) # 80003abe <iunlockput>
      return 0;
    80003e58:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e5a:	854e                	mv	a0,s3
    80003e5c:	60e6                	ld	ra,88(sp)
    80003e5e:	6446                	ld	s0,80(sp)
    80003e60:	64a6                	ld	s1,72(sp)
    80003e62:	6906                	ld	s2,64(sp)
    80003e64:	79e2                	ld	s3,56(sp)
    80003e66:	7a42                	ld	s4,48(sp)
    80003e68:	7aa2                	ld	s5,40(sp)
    80003e6a:	7b02                	ld	s6,32(sp)
    80003e6c:	6be2                	ld	s7,24(sp)
    80003e6e:	6c42                	ld	s8,16(sp)
    80003e70:	6ca2                	ld	s9,8(sp)
    80003e72:	6125                	addi	sp,sp,96
    80003e74:	8082                	ret
      iunlock(ip);
    80003e76:	854e                	mv	a0,s3
    80003e78:	00000097          	auipc	ra,0x0
    80003e7c:	aa6080e7          	jalr	-1370(ra) # 8000391e <iunlock>
      return ip;
    80003e80:	bfe9                	j	80003e5a <namex+0x6a>
      iunlockput(ip);
    80003e82:	854e                	mv	a0,s3
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	c3a080e7          	jalr	-966(ra) # 80003abe <iunlockput>
      return 0;
    80003e8c:	89d2                	mv	s3,s4
    80003e8e:	b7f1                	j	80003e5a <namex+0x6a>
  len = path - s;
    80003e90:	40b48633          	sub	a2,s1,a1
    80003e94:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003e98:	094cd463          	bge	s9,s4,80003f20 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003e9c:	4639                	li	a2,14
    80003e9e:	8556                	mv	a0,s5
    80003ea0:	ffffd097          	auipc	ra,0xffffd
    80003ea4:	ea6080e7          	jalr	-346(ra) # 80000d46 <memmove>
  while(*path == '/')
    80003ea8:	0004c783          	lbu	a5,0(s1)
    80003eac:	01279763          	bne	a5,s2,80003eba <namex+0xca>
    path++;
    80003eb0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003eb2:	0004c783          	lbu	a5,0(s1)
    80003eb6:	ff278de3          	beq	a5,s2,80003eb0 <namex+0xc0>
    ilock(ip);
    80003eba:	854e                	mv	a0,s3
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	9a0080e7          	jalr	-1632(ra) # 8000385c <ilock>
    if(ip->type != T_DIR){
    80003ec4:	04499783          	lh	a5,68(s3)
    80003ec8:	f98793e3          	bne	a5,s8,80003e4e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ecc:	000b0563          	beqz	s6,80003ed6 <namex+0xe6>
    80003ed0:	0004c783          	lbu	a5,0(s1)
    80003ed4:	d3cd                	beqz	a5,80003e76 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ed6:	865e                	mv	a2,s7
    80003ed8:	85d6                	mv	a1,s5
    80003eda:	854e                	mv	a0,s3
    80003edc:	00000097          	auipc	ra,0x0
    80003ee0:	e64080e7          	jalr	-412(ra) # 80003d40 <dirlookup>
    80003ee4:	8a2a                	mv	s4,a0
    80003ee6:	dd51                	beqz	a0,80003e82 <namex+0x92>
    iunlockput(ip);
    80003ee8:	854e                	mv	a0,s3
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	bd4080e7          	jalr	-1068(ra) # 80003abe <iunlockput>
    ip = next;
    80003ef2:	89d2                	mv	s3,s4
  while(*path == '/')
    80003ef4:	0004c783          	lbu	a5,0(s1)
    80003ef8:	05279763          	bne	a5,s2,80003f46 <namex+0x156>
    path++;
    80003efc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003efe:	0004c783          	lbu	a5,0(s1)
    80003f02:	ff278de3          	beq	a5,s2,80003efc <namex+0x10c>
  if(*path == 0)
    80003f06:	c79d                	beqz	a5,80003f34 <namex+0x144>
    path++;
    80003f08:	85a6                	mv	a1,s1
  len = path - s;
    80003f0a:	8a5e                	mv	s4,s7
    80003f0c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f0e:	01278963          	beq	a5,s2,80003f20 <namex+0x130>
    80003f12:	dfbd                	beqz	a5,80003e90 <namex+0xa0>
    path++;
    80003f14:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f16:	0004c783          	lbu	a5,0(s1)
    80003f1a:	ff279ce3          	bne	a5,s2,80003f12 <namex+0x122>
    80003f1e:	bf8d                	j	80003e90 <namex+0xa0>
    memmove(name, s, len);
    80003f20:	2601                	sext.w	a2,a2
    80003f22:	8556                	mv	a0,s5
    80003f24:	ffffd097          	auipc	ra,0xffffd
    80003f28:	e22080e7          	jalr	-478(ra) # 80000d46 <memmove>
    name[len] = 0;
    80003f2c:	9a56                	add	s4,s4,s5
    80003f2e:	000a0023          	sb	zero,0(s4)
    80003f32:	bf9d                	j	80003ea8 <namex+0xb8>
  if(nameiparent){
    80003f34:	f20b03e3          	beqz	s6,80003e5a <namex+0x6a>
    iput(ip);
    80003f38:	854e                	mv	a0,s3
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	adc080e7          	jalr	-1316(ra) # 80003a16 <iput>
    return 0;
    80003f42:	4981                	li	s3,0
    80003f44:	bf19                	j	80003e5a <namex+0x6a>
  if(*path == 0)
    80003f46:	d7fd                	beqz	a5,80003f34 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f48:	0004c783          	lbu	a5,0(s1)
    80003f4c:	85a6                	mv	a1,s1
    80003f4e:	b7d1                	j	80003f12 <namex+0x122>

0000000080003f50 <dirlink>:
{
    80003f50:	7139                	addi	sp,sp,-64
    80003f52:	fc06                	sd	ra,56(sp)
    80003f54:	f822                	sd	s0,48(sp)
    80003f56:	f426                	sd	s1,40(sp)
    80003f58:	f04a                	sd	s2,32(sp)
    80003f5a:	ec4e                	sd	s3,24(sp)
    80003f5c:	e852                	sd	s4,16(sp)
    80003f5e:	0080                	addi	s0,sp,64
    80003f60:	892a                	mv	s2,a0
    80003f62:	8a2e                	mv	s4,a1
    80003f64:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f66:	4601                	li	a2,0
    80003f68:	00000097          	auipc	ra,0x0
    80003f6c:	dd8080e7          	jalr	-552(ra) # 80003d40 <dirlookup>
    80003f70:	e93d                	bnez	a0,80003fe6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f72:	04c92483          	lw	s1,76(s2)
    80003f76:	c49d                	beqz	s1,80003fa4 <dirlink+0x54>
    80003f78:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f7a:	4741                	li	a4,16
    80003f7c:	86a6                	mv	a3,s1
    80003f7e:	fc040613          	addi	a2,s0,-64
    80003f82:	4581                	li	a1,0
    80003f84:	854a                	mv	a0,s2
    80003f86:	00000097          	auipc	ra,0x0
    80003f8a:	b8a080e7          	jalr	-1142(ra) # 80003b10 <readi>
    80003f8e:	47c1                	li	a5,16
    80003f90:	06f51163          	bne	a0,a5,80003ff2 <dirlink+0xa2>
    if(de.inum == 0)
    80003f94:	fc045783          	lhu	a5,-64(s0)
    80003f98:	c791                	beqz	a5,80003fa4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f9a:	24c1                	addiw	s1,s1,16
    80003f9c:	04c92783          	lw	a5,76(s2)
    80003fa0:	fcf4ede3          	bltu	s1,a5,80003f7a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fa4:	4639                	li	a2,14
    80003fa6:	85d2                	mv	a1,s4
    80003fa8:	fc240513          	addi	a0,s0,-62
    80003fac:	ffffd097          	auipc	ra,0xffffd
    80003fb0:	e4e080e7          	jalr	-434(ra) # 80000dfa <strncpy>
  de.inum = inum;
    80003fb4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fb8:	4741                	li	a4,16
    80003fba:	86a6                	mv	a3,s1
    80003fbc:	fc040613          	addi	a2,s0,-64
    80003fc0:	4581                	li	a1,0
    80003fc2:	854a                	mv	a0,s2
    80003fc4:	00000097          	auipc	ra,0x0
    80003fc8:	c44080e7          	jalr	-956(ra) # 80003c08 <writei>
    80003fcc:	1541                	addi	a0,a0,-16
    80003fce:	00a03533          	snez	a0,a0
    80003fd2:	40a00533          	neg	a0,a0
}
    80003fd6:	70e2                	ld	ra,56(sp)
    80003fd8:	7442                	ld	s0,48(sp)
    80003fda:	74a2                	ld	s1,40(sp)
    80003fdc:	7902                	ld	s2,32(sp)
    80003fde:	69e2                	ld	s3,24(sp)
    80003fe0:	6a42                	ld	s4,16(sp)
    80003fe2:	6121                	addi	sp,sp,64
    80003fe4:	8082                	ret
    iput(ip);
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	a30080e7          	jalr	-1488(ra) # 80003a16 <iput>
    return -1;
    80003fee:	557d                	li	a0,-1
    80003ff0:	b7dd                	j	80003fd6 <dirlink+0x86>
      panic("dirlink read");
    80003ff2:	00004517          	auipc	a0,0x4
    80003ff6:	63650513          	addi	a0,a0,1590 # 80008628 <syscalls+0x1d8>
    80003ffa:	ffffc097          	auipc	ra,0xffffc
    80003ffe:	54a080e7          	jalr	1354(ra) # 80000544 <panic>

0000000080004002 <namei>:

struct inode*
namei(char *path)
{
    80004002:	1101                	addi	sp,sp,-32
    80004004:	ec06                	sd	ra,24(sp)
    80004006:	e822                	sd	s0,16(sp)
    80004008:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000400a:	fe040613          	addi	a2,s0,-32
    8000400e:	4581                	li	a1,0
    80004010:	00000097          	auipc	ra,0x0
    80004014:	de0080e7          	jalr	-544(ra) # 80003df0 <namex>
}
    80004018:	60e2                	ld	ra,24(sp)
    8000401a:	6442                	ld	s0,16(sp)
    8000401c:	6105                	addi	sp,sp,32
    8000401e:	8082                	ret

0000000080004020 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004020:	1141                	addi	sp,sp,-16
    80004022:	e406                	sd	ra,8(sp)
    80004024:	e022                	sd	s0,0(sp)
    80004026:	0800                	addi	s0,sp,16
    80004028:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000402a:	4585                	li	a1,1
    8000402c:	00000097          	auipc	ra,0x0
    80004030:	dc4080e7          	jalr	-572(ra) # 80003df0 <namex>
}
    80004034:	60a2                	ld	ra,8(sp)
    80004036:	6402                	ld	s0,0(sp)
    80004038:	0141                	addi	sp,sp,16
    8000403a:	8082                	ret

000000008000403c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000403c:	1101                	addi	sp,sp,-32
    8000403e:	ec06                	sd	ra,24(sp)
    80004040:	e822                	sd	s0,16(sp)
    80004042:	e426                	sd	s1,8(sp)
    80004044:	e04a                	sd	s2,0(sp)
    80004046:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004048:	0001d917          	auipc	s2,0x1d
    8000404c:	ae890913          	addi	s2,s2,-1304 # 80020b30 <log>
    80004050:	01892583          	lw	a1,24(s2)
    80004054:	02892503          	lw	a0,40(s2)
    80004058:	fffff097          	auipc	ra,0xfffff
    8000405c:	fea080e7          	jalr	-22(ra) # 80003042 <bread>
    80004060:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004062:	02c92683          	lw	a3,44(s2)
    80004066:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004068:	02d05763          	blez	a3,80004096 <write_head+0x5a>
    8000406c:	0001d797          	auipc	a5,0x1d
    80004070:	af478793          	addi	a5,a5,-1292 # 80020b60 <log+0x30>
    80004074:	05c50713          	addi	a4,a0,92
    80004078:	36fd                	addiw	a3,a3,-1
    8000407a:	1682                	slli	a3,a3,0x20
    8000407c:	9281                	srli	a3,a3,0x20
    8000407e:	068a                	slli	a3,a3,0x2
    80004080:	0001d617          	auipc	a2,0x1d
    80004084:	ae460613          	addi	a2,a2,-1308 # 80020b64 <log+0x34>
    80004088:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000408a:	4390                	lw	a2,0(a5)
    8000408c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000408e:	0791                	addi	a5,a5,4
    80004090:	0711                	addi	a4,a4,4
    80004092:	fed79ce3          	bne	a5,a3,8000408a <write_head+0x4e>
  }
  bwrite(buf);
    80004096:	8526                	mv	a0,s1
    80004098:	fffff097          	auipc	ra,0xfffff
    8000409c:	09c080e7          	jalr	156(ra) # 80003134 <bwrite>
  brelse(buf);
    800040a0:	8526                	mv	a0,s1
    800040a2:	fffff097          	auipc	ra,0xfffff
    800040a6:	0d0080e7          	jalr	208(ra) # 80003172 <brelse>
}
    800040aa:	60e2                	ld	ra,24(sp)
    800040ac:	6442                	ld	s0,16(sp)
    800040ae:	64a2                	ld	s1,8(sp)
    800040b0:	6902                	ld	s2,0(sp)
    800040b2:	6105                	addi	sp,sp,32
    800040b4:	8082                	ret

00000000800040b6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040b6:	0001d797          	auipc	a5,0x1d
    800040ba:	aa67a783          	lw	a5,-1370(a5) # 80020b5c <log+0x2c>
    800040be:	0af05d63          	blez	a5,80004178 <install_trans+0xc2>
{
    800040c2:	7139                	addi	sp,sp,-64
    800040c4:	fc06                	sd	ra,56(sp)
    800040c6:	f822                	sd	s0,48(sp)
    800040c8:	f426                	sd	s1,40(sp)
    800040ca:	f04a                	sd	s2,32(sp)
    800040cc:	ec4e                	sd	s3,24(sp)
    800040ce:	e852                	sd	s4,16(sp)
    800040d0:	e456                	sd	s5,8(sp)
    800040d2:	e05a                	sd	s6,0(sp)
    800040d4:	0080                	addi	s0,sp,64
    800040d6:	8b2a                	mv	s6,a0
    800040d8:	0001da97          	auipc	s5,0x1d
    800040dc:	a88a8a93          	addi	s5,s5,-1400 # 80020b60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040e2:	0001d997          	auipc	s3,0x1d
    800040e6:	a4e98993          	addi	s3,s3,-1458 # 80020b30 <log>
    800040ea:	a035                	j	80004116 <install_trans+0x60>
      bunpin(dbuf);
    800040ec:	8526                	mv	a0,s1
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	15e080e7          	jalr	350(ra) # 8000324c <bunpin>
    brelse(lbuf);
    800040f6:	854a                	mv	a0,s2
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	07a080e7          	jalr	122(ra) # 80003172 <brelse>
    brelse(dbuf);
    80004100:	8526                	mv	a0,s1
    80004102:	fffff097          	auipc	ra,0xfffff
    80004106:	070080e7          	jalr	112(ra) # 80003172 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000410a:	2a05                	addiw	s4,s4,1
    8000410c:	0a91                	addi	s5,s5,4
    8000410e:	02c9a783          	lw	a5,44(s3)
    80004112:	04fa5963          	bge	s4,a5,80004164 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004116:	0189a583          	lw	a1,24(s3)
    8000411a:	014585bb          	addw	a1,a1,s4
    8000411e:	2585                	addiw	a1,a1,1
    80004120:	0289a503          	lw	a0,40(s3)
    80004124:	fffff097          	auipc	ra,0xfffff
    80004128:	f1e080e7          	jalr	-226(ra) # 80003042 <bread>
    8000412c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000412e:	000aa583          	lw	a1,0(s5)
    80004132:	0289a503          	lw	a0,40(s3)
    80004136:	fffff097          	auipc	ra,0xfffff
    8000413a:	f0c080e7          	jalr	-244(ra) # 80003042 <bread>
    8000413e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004140:	40000613          	li	a2,1024
    80004144:	05890593          	addi	a1,s2,88
    80004148:	05850513          	addi	a0,a0,88
    8000414c:	ffffd097          	auipc	ra,0xffffd
    80004150:	bfa080e7          	jalr	-1030(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004154:	8526                	mv	a0,s1
    80004156:	fffff097          	auipc	ra,0xfffff
    8000415a:	fde080e7          	jalr	-34(ra) # 80003134 <bwrite>
    if(recovering == 0)
    8000415e:	f80b1ce3          	bnez	s6,800040f6 <install_trans+0x40>
    80004162:	b769                	j	800040ec <install_trans+0x36>
}
    80004164:	70e2                	ld	ra,56(sp)
    80004166:	7442                	ld	s0,48(sp)
    80004168:	74a2                	ld	s1,40(sp)
    8000416a:	7902                	ld	s2,32(sp)
    8000416c:	69e2                	ld	s3,24(sp)
    8000416e:	6a42                	ld	s4,16(sp)
    80004170:	6aa2                	ld	s5,8(sp)
    80004172:	6b02                	ld	s6,0(sp)
    80004174:	6121                	addi	sp,sp,64
    80004176:	8082                	ret
    80004178:	8082                	ret

000000008000417a <initlog>:
{
    8000417a:	7179                	addi	sp,sp,-48
    8000417c:	f406                	sd	ra,40(sp)
    8000417e:	f022                	sd	s0,32(sp)
    80004180:	ec26                	sd	s1,24(sp)
    80004182:	e84a                	sd	s2,16(sp)
    80004184:	e44e                	sd	s3,8(sp)
    80004186:	1800                	addi	s0,sp,48
    80004188:	892a                	mv	s2,a0
    8000418a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000418c:	0001d497          	auipc	s1,0x1d
    80004190:	9a448493          	addi	s1,s1,-1628 # 80020b30 <log>
    80004194:	00004597          	auipc	a1,0x4
    80004198:	4a458593          	addi	a1,a1,1188 # 80008638 <syscalls+0x1e8>
    8000419c:	8526                	mv	a0,s1
    8000419e:	ffffd097          	auipc	ra,0xffffd
    800041a2:	9bc080e7          	jalr	-1604(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800041a6:	0149a583          	lw	a1,20(s3)
    800041aa:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041ac:	0109a783          	lw	a5,16(s3)
    800041b0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041b2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041b6:	854a                	mv	a0,s2
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	e8a080e7          	jalr	-374(ra) # 80003042 <bread>
  log.lh.n = lh->n;
    800041c0:	4d3c                	lw	a5,88(a0)
    800041c2:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041c4:	02f05563          	blez	a5,800041ee <initlog+0x74>
    800041c8:	05c50713          	addi	a4,a0,92
    800041cc:	0001d697          	auipc	a3,0x1d
    800041d0:	99468693          	addi	a3,a3,-1644 # 80020b60 <log+0x30>
    800041d4:	37fd                	addiw	a5,a5,-1
    800041d6:	1782                	slli	a5,a5,0x20
    800041d8:	9381                	srli	a5,a5,0x20
    800041da:	078a                	slli	a5,a5,0x2
    800041dc:	06050613          	addi	a2,a0,96
    800041e0:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800041e2:	4310                	lw	a2,0(a4)
    800041e4:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800041e6:	0711                	addi	a4,a4,4
    800041e8:	0691                	addi	a3,a3,4
    800041ea:	fef71ce3          	bne	a4,a5,800041e2 <initlog+0x68>
  brelse(buf);
    800041ee:	fffff097          	auipc	ra,0xfffff
    800041f2:	f84080e7          	jalr	-124(ra) # 80003172 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800041f6:	4505                	li	a0,1
    800041f8:	00000097          	auipc	ra,0x0
    800041fc:	ebe080e7          	jalr	-322(ra) # 800040b6 <install_trans>
  log.lh.n = 0;
    80004200:	0001d797          	auipc	a5,0x1d
    80004204:	9407ae23          	sw	zero,-1700(a5) # 80020b5c <log+0x2c>
  write_head(); // clear the log
    80004208:	00000097          	auipc	ra,0x0
    8000420c:	e34080e7          	jalr	-460(ra) # 8000403c <write_head>
}
    80004210:	70a2                	ld	ra,40(sp)
    80004212:	7402                	ld	s0,32(sp)
    80004214:	64e2                	ld	s1,24(sp)
    80004216:	6942                	ld	s2,16(sp)
    80004218:	69a2                	ld	s3,8(sp)
    8000421a:	6145                	addi	sp,sp,48
    8000421c:	8082                	ret

000000008000421e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000421e:	1101                	addi	sp,sp,-32
    80004220:	ec06                	sd	ra,24(sp)
    80004222:	e822                	sd	s0,16(sp)
    80004224:	e426                	sd	s1,8(sp)
    80004226:	e04a                	sd	s2,0(sp)
    80004228:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000422a:	0001d517          	auipc	a0,0x1d
    8000422e:	90650513          	addi	a0,a0,-1786 # 80020b30 <log>
    80004232:	ffffd097          	auipc	ra,0xffffd
    80004236:	9b8080e7          	jalr	-1608(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    8000423a:	0001d497          	auipc	s1,0x1d
    8000423e:	8f648493          	addi	s1,s1,-1802 # 80020b30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004242:	4979                	li	s2,30
    80004244:	a039                	j	80004252 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004246:	85a6                	mv	a1,s1
    80004248:	8526                	mv	a0,s1
    8000424a:	ffffe097          	auipc	ra,0xffffe
    8000424e:	e2a080e7          	jalr	-470(ra) # 80002074 <sleep>
    if(log.committing){
    80004252:	50dc                	lw	a5,36(s1)
    80004254:	fbed                	bnez	a5,80004246 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004256:	509c                	lw	a5,32(s1)
    80004258:	0017871b          	addiw	a4,a5,1
    8000425c:	0007069b          	sext.w	a3,a4
    80004260:	0027179b          	slliw	a5,a4,0x2
    80004264:	9fb9                	addw	a5,a5,a4
    80004266:	0017979b          	slliw	a5,a5,0x1
    8000426a:	54d8                	lw	a4,44(s1)
    8000426c:	9fb9                	addw	a5,a5,a4
    8000426e:	00f95963          	bge	s2,a5,80004280 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004272:	85a6                	mv	a1,s1
    80004274:	8526                	mv	a0,s1
    80004276:	ffffe097          	auipc	ra,0xffffe
    8000427a:	dfe080e7          	jalr	-514(ra) # 80002074 <sleep>
    8000427e:	bfd1                	j	80004252 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004280:	0001d517          	auipc	a0,0x1d
    80004284:	8b050513          	addi	a0,a0,-1872 # 80020b30 <log>
    80004288:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000428a:	ffffd097          	auipc	ra,0xffffd
    8000428e:	a14080e7          	jalr	-1516(ra) # 80000c9e <release>
      break;
    }
  }
}
    80004292:	60e2                	ld	ra,24(sp)
    80004294:	6442                	ld	s0,16(sp)
    80004296:	64a2                	ld	s1,8(sp)
    80004298:	6902                	ld	s2,0(sp)
    8000429a:	6105                	addi	sp,sp,32
    8000429c:	8082                	ret

000000008000429e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000429e:	7139                	addi	sp,sp,-64
    800042a0:	fc06                	sd	ra,56(sp)
    800042a2:	f822                	sd	s0,48(sp)
    800042a4:	f426                	sd	s1,40(sp)
    800042a6:	f04a                	sd	s2,32(sp)
    800042a8:	ec4e                	sd	s3,24(sp)
    800042aa:	e852                	sd	s4,16(sp)
    800042ac:	e456                	sd	s5,8(sp)
    800042ae:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042b0:	0001d497          	auipc	s1,0x1d
    800042b4:	88048493          	addi	s1,s1,-1920 # 80020b30 <log>
    800042b8:	8526                	mv	a0,s1
    800042ba:	ffffd097          	auipc	ra,0xffffd
    800042be:	930080e7          	jalr	-1744(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    800042c2:	509c                	lw	a5,32(s1)
    800042c4:	37fd                	addiw	a5,a5,-1
    800042c6:	0007891b          	sext.w	s2,a5
    800042ca:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042cc:	50dc                	lw	a5,36(s1)
    800042ce:	efb9                	bnez	a5,8000432c <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800042d0:	06091663          	bnez	s2,8000433c <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800042d4:	0001d497          	auipc	s1,0x1d
    800042d8:	85c48493          	addi	s1,s1,-1956 # 80020b30 <log>
    800042dc:	4785                	li	a5,1
    800042de:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042e0:	8526                	mv	a0,s1
    800042e2:	ffffd097          	auipc	ra,0xffffd
    800042e6:	9bc080e7          	jalr	-1604(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042ea:	54dc                	lw	a5,44(s1)
    800042ec:	06f04763          	bgtz	a5,8000435a <end_op+0xbc>
    acquire(&log.lock);
    800042f0:	0001d497          	auipc	s1,0x1d
    800042f4:	84048493          	addi	s1,s1,-1984 # 80020b30 <log>
    800042f8:	8526                	mv	a0,s1
    800042fa:	ffffd097          	auipc	ra,0xffffd
    800042fe:	8f0080e7          	jalr	-1808(ra) # 80000bea <acquire>
    log.committing = 0;
    80004302:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004306:	8526                	mv	a0,s1
    80004308:	ffffe097          	auipc	ra,0xffffe
    8000430c:	dd0080e7          	jalr	-560(ra) # 800020d8 <wakeup>
    release(&log.lock);
    80004310:	8526                	mv	a0,s1
    80004312:	ffffd097          	auipc	ra,0xffffd
    80004316:	98c080e7          	jalr	-1652(ra) # 80000c9e <release>
}
    8000431a:	70e2                	ld	ra,56(sp)
    8000431c:	7442                	ld	s0,48(sp)
    8000431e:	74a2                	ld	s1,40(sp)
    80004320:	7902                	ld	s2,32(sp)
    80004322:	69e2                	ld	s3,24(sp)
    80004324:	6a42                	ld	s4,16(sp)
    80004326:	6aa2                	ld	s5,8(sp)
    80004328:	6121                	addi	sp,sp,64
    8000432a:	8082                	ret
    panic("log.committing");
    8000432c:	00004517          	auipc	a0,0x4
    80004330:	31450513          	addi	a0,a0,788 # 80008640 <syscalls+0x1f0>
    80004334:	ffffc097          	auipc	ra,0xffffc
    80004338:	210080e7          	jalr	528(ra) # 80000544 <panic>
    wakeup(&log);
    8000433c:	0001c497          	auipc	s1,0x1c
    80004340:	7f448493          	addi	s1,s1,2036 # 80020b30 <log>
    80004344:	8526                	mv	a0,s1
    80004346:	ffffe097          	auipc	ra,0xffffe
    8000434a:	d92080e7          	jalr	-622(ra) # 800020d8 <wakeup>
  release(&log.lock);
    8000434e:	8526                	mv	a0,s1
    80004350:	ffffd097          	auipc	ra,0xffffd
    80004354:	94e080e7          	jalr	-1714(ra) # 80000c9e <release>
  if(do_commit){
    80004358:	b7c9                	j	8000431a <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000435a:	0001da97          	auipc	s5,0x1d
    8000435e:	806a8a93          	addi	s5,s5,-2042 # 80020b60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004362:	0001ca17          	auipc	s4,0x1c
    80004366:	7cea0a13          	addi	s4,s4,1998 # 80020b30 <log>
    8000436a:	018a2583          	lw	a1,24(s4)
    8000436e:	012585bb          	addw	a1,a1,s2
    80004372:	2585                	addiw	a1,a1,1
    80004374:	028a2503          	lw	a0,40(s4)
    80004378:	fffff097          	auipc	ra,0xfffff
    8000437c:	cca080e7          	jalr	-822(ra) # 80003042 <bread>
    80004380:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004382:	000aa583          	lw	a1,0(s5)
    80004386:	028a2503          	lw	a0,40(s4)
    8000438a:	fffff097          	auipc	ra,0xfffff
    8000438e:	cb8080e7          	jalr	-840(ra) # 80003042 <bread>
    80004392:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004394:	40000613          	li	a2,1024
    80004398:	05850593          	addi	a1,a0,88
    8000439c:	05848513          	addi	a0,s1,88
    800043a0:	ffffd097          	auipc	ra,0xffffd
    800043a4:	9a6080e7          	jalr	-1626(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    800043a8:	8526                	mv	a0,s1
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	d8a080e7          	jalr	-630(ra) # 80003134 <bwrite>
    brelse(from);
    800043b2:	854e                	mv	a0,s3
    800043b4:	fffff097          	auipc	ra,0xfffff
    800043b8:	dbe080e7          	jalr	-578(ra) # 80003172 <brelse>
    brelse(to);
    800043bc:	8526                	mv	a0,s1
    800043be:	fffff097          	auipc	ra,0xfffff
    800043c2:	db4080e7          	jalr	-588(ra) # 80003172 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043c6:	2905                	addiw	s2,s2,1
    800043c8:	0a91                	addi	s5,s5,4
    800043ca:	02ca2783          	lw	a5,44(s4)
    800043ce:	f8f94ee3          	blt	s2,a5,8000436a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043d2:	00000097          	auipc	ra,0x0
    800043d6:	c6a080e7          	jalr	-918(ra) # 8000403c <write_head>
    install_trans(0); // Now install writes to home locations
    800043da:	4501                	li	a0,0
    800043dc:	00000097          	auipc	ra,0x0
    800043e0:	cda080e7          	jalr	-806(ra) # 800040b6 <install_trans>
    log.lh.n = 0;
    800043e4:	0001c797          	auipc	a5,0x1c
    800043e8:	7607ac23          	sw	zero,1912(a5) # 80020b5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800043ec:	00000097          	auipc	ra,0x0
    800043f0:	c50080e7          	jalr	-944(ra) # 8000403c <write_head>
    800043f4:	bdf5                	j	800042f0 <end_op+0x52>

00000000800043f6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043f6:	1101                	addi	sp,sp,-32
    800043f8:	ec06                	sd	ra,24(sp)
    800043fa:	e822                	sd	s0,16(sp)
    800043fc:	e426                	sd	s1,8(sp)
    800043fe:	e04a                	sd	s2,0(sp)
    80004400:	1000                	addi	s0,sp,32
    80004402:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004404:	0001c917          	auipc	s2,0x1c
    80004408:	72c90913          	addi	s2,s2,1836 # 80020b30 <log>
    8000440c:	854a                	mv	a0,s2
    8000440e:	ffffc097          	auipc	ra,0xffffc
    80004412:	7dc080e7          	jalr	2012(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004416:	02c92603          	lw	a2,44(s2)
    8000441a:	47f5                	li	a5,29
    8000441c:	06c7c563          	blt	a5,a2,80004486 <log_write+0x90>
    80004420:	0001c797          	auipc	a5,0x1c
    80004424:	72c7a783          	lw	a5,1836(a5) # 80020b4c <log+0x1c>
    80004428:	37fd                	addiw	a5,a5,-1
    8000442a:	04f65e63          	bge	a2,a5,80004486 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000442e:	0001c797          	auipc	a5,0x1c
    80004432:	7227a783          	lw	a5,1826(a5) # 80020b50 <log+0x20>
    80004436:	06f05063          	blez	a5,80004496 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000443a:	4781                	li	a5,0
    8000443c:	06c05563          	blez	a2,800044a6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004440:	44cc                	lw	a1,12(s1)
    80004442:	0001c717          	auipc	a4,0x1c
    80004446:	71e70713          	addi	a4,a4,1822 # 80020b60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000444a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000444c:	4314                	lw	a3,0(a4)
    8000444e:	04b68c63          	beq	a3,a1,800044a6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004452:	2785                	addiw	a5,a5,1
    80004454:	0711                	addi	a4,a4,4
    80004456:	fef61be3          	bne	a2,a5,8000444c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000445a:	0621                	addi	a2,a2,8
    8000445c:	060a                	slli	a2,a2,0x2
    8000445e:	0001c797          	auipc	a5,0x1c
    80004462:	6d278793          	addi	a5,a5,1746 # 80020b30 <log>
    80004466:	963e                	add	a2,a2,a5
    80004468:	44dc                	lw	a5,12(s1)
    8000446a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000446c:	8526                	mv	a0,s1
    8000446e:	fffff097          	auipc	ra,0xfffff
    80004472:	da2080e7          	jalr	-606(ra) # 80003210 <bpin>
    log.lh.n++;
    80004476:	0001c717          	auipc	a4,0x1c
    8000447a:	6ba70713          	addi	a4,a4,1722 # 80020b30 <log>
    8000447e:	575c                	lw	a5,44(a4)
    80004480:	2785                	addiw	a5,a5,1
    80004482:	d75c                	sw	a5,44(a4)
    80004484:	a835                	j	800044c0 <log_write+0xca>
    panic("too big a transaction");
    80004486:	00004517          	auipc	a0,0x4
    8000448a:	1ca50513          	addi	a0,a0,458 # 80008650 <syscalls+0x200>
    8000448e:	ffffc097          	auipc	ra,0xffffc
    80004492:	0b6080e7          	jalr	182(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004496:	00004517          	auipc	a0,0x4
    8000449a:	1d250513          	addi	a0,a0,466 # 80008668 <syscalls+0x218>
    8000449e:	ffffc097          	auipc	ra,0xffffc
    800044a2:	0a6080e7          	jalr	166(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    800044a6:	00878713          	addi	a4,a5,8
    800044aa:	00271693          	slli	a3,a4,0x2
    800044ae:	0001c717          	auipc	a4,0x1c
    800044b2:	68270713          	addi	a4,a4,1666 # 80020b30 <log>
    800044b6:	9736                	add	a4,a4,a3
    800044b8:	44d4                	lw	a3,12(s1)
    800044ba:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044bc:	faf608e3          	beq	a2,a5,8000446c <log_write+0x76>
  }
  release(&log.lock);
    800044c0:	0001c517          	auipc	a0,0x1c
    800044c4:	67050513          	addi	a0,a0,1648 # 80020b30 <log>
    800044c8:	ffffc097          	auipc	ra,0xffffc
    800044cc:	7d6080e7          	jalr	2006(ra) # 80000c9e <release>
}
    800044d0:	60e2                	ld	ra,24(sp)
    800044d2:	6442                	ld	s0,16(sp)
    800044d4:	64a2                	ld	s1,8(sp)
    800044d6:	6902                	ld	s2,0(sp)
    800044d8:	6105                	addi	sp,sp,32
    800044da:	8082                	ret

00000000800044dc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044dc:	1101                	addi	sp,sp,-32
    800044de:	ec06                	sd	ra,24(sp)
    800044e0:	e822                	sd	s0,16(sp)
    800044e2:	e426                	sd	s1,8(sp)
    800044e4:	e04a                	sd	s2,0(sp)
    800044e6:	1000                	addi	s0,sp,32
    800044e8:	84aa                	mv	s1,a0
    800044ea:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044ec:	00004597          	auipc	a1,0x4
    800044f0:	19c58593          	addi	a1,a1,412 # 80008688 <syscalls+0x238>
    800044f4:	0521                	addi	a0,a0,8
    800044f6:	ffffc097          	auipc	ra,0xffffc
    800044fa:	664080e7          	jalr	1636(ra) # 80000b5a <initlock>
  lk->name = name;
    800044fe:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004502:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004506:	0204a423          	sw	zero,40(s1)
}
    8000450a:	60e2                	ld	ra,24(sp)
    8000450c:	6442                	ld	s0,16(sp)
    8000450e:	64a2                	ld	s1,8(sp)
    80004510:	6902                	ld	s2,0(sp)
    80004512:	6105                	addi	sp,sp,32
    80004514:	8082                	ret

0000000080004516 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004516:	1101                	addi	sp,sp,-32
    80004518:	ec06                	sd	ra,24(sp)
    8000451a:	e822                	sd	s0,16(sp)
    8000451c:	e426                	sd	s1,8(sp)
    8000451e:	e04a                	sd	s2,0(sp)
    80004520:	1000                	addi	s0,sp,32
    80004522:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004524:	00850913          	addi	s2,a0,8
    80004528:	854a                	mv	a0,s2
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	6c0080e7          	jalr	1728(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004532:	409c                	lw	a5,0(s1)
    80004534:	cb89                	beqz	a5,80004546 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004536:	85ca                	mv	a1,s2
    80004538:	8526                	mv	a0,s1
    8000453a:	ffffe097          	auipc	ra,0xffffe
    8000453e:	b3a080e7          	jalr	-1222(ra) # 80002074 <sleep>
  while (lk->locked) {
    80004542:	409c                	lw	a5,0(s1)
    80004544:	fbed                	bnez	a5,80004536 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004546:	4785                	li	a5,1
    80004548:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000454a:	ffffd097          	auipc	ra,0xffffd
    8000454e:	486080e7          	jalr	1158(ra) # 800019d0 <myproc>
    80004552:	591c                	lw	a5,48(a0)
    80004554:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004556:	854a                	mv	a0,s2
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	746080e7          	jalr	1862(ra) # 80000c9e <release>
}
    80004560:	60e2                	ld	ra,24(sp)
    80004562:	6442                	ld	s0,16(sp)
    80004564:	64a2                	ld	s1,8(sp)
    80004566:	6902                	ld	s2,0(sp)
    80004568:	6105                	addi	sp,sp,32
    8000456a:	8082                	ret

000000008000456c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000456c:	1101                	addi	sp,sp,-32
    8000456e:	ec06                	sd	ra,24(sp)
    80004570:	e822                	sd	s0,16(sp)
    80004572:	e426                	sd	s1,8(sp)
    80004574:	e04a                	sd	s2,0(sp)
    80004576:	1000                	addi	s0,sp,32
    80004578:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000457a:	00850913          	addi	s2,a0,8
    8000457e:	854a                	mv	a0,s2
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	66a080e7          	jalr	1642(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004588:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000458c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004590:	8526                	mv	a0,s1
    80004592:	ffffe097          	auipc	ra,0xffffe
    80004596:	b46080e7          	jalr	-1210(ra) # 800020d8 <wakeup>
  release(&lk->lk);
    8000459a:	854a                	mv	a0,s2
    8000459c:	ffffc097          	auipc	ra,0xffffc
    800045a0:	702080e7          	jalr	1794(ra) # 80000c9e <release>
}
    800045a4:	60e2                	ld	ra,24(sp)
    800045a6:	6442                	ld	s0,16(sp)
    800045a8:	64a2                	ld	s1,8(sp)
    800045aa:	6902                	ld	s2,0(sp)
    800045ac:	6105                	addi	sp,sp,32
    800045ae:	8082                	ret

00000000800045b0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045b0:	7179                	addi	sp,sp,-48
    800045b2:	f406                	sd	ra,40(sp)
    800045b4:	f022                	sd	s0,32(sp)
    800045b6:	ec26                	sd	s1,24(sp)
    800045b8:	e84a                	sd	s2,16(sp)
    800045ba:	e44e                	sd	s3,8(sp)
    800045bc:	1800                	addi	s0,sp,48
    800045be:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045c0:	00850913          	addi	s2,a0,8
    800045c4:	854a                	mv	a0,s2
    800045c6:	ffffc097          	auipc	ra,0xffffc
    800045ca:	624080e7          	jalr	1572(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045ce:	409c                	lw	a5,0(s1)
    800045d0:	ef99                	bnez	a5,800045ee <holdingsleep+0x3e>
    800045d2:	4481                	li	s1,0
  release(&lk->lk);
    800045d4:	854a                	mv	a0,s2
    800045d6:	ffffc097          	auipc	ra,0xffffc
    800045da:	6c8080e7          	jalr	1736(ra) # 80000c9e <release>
  return r;
}
    800045de:	8526                	mv	a0,s1
    800045e0:	70a2                	ld	ra,40(sp)
    800045e2:	7402                	ld	s0,32(sp)
    800045e4:	64e2                	ld	s1,24(sp)
    800045e6:	6942                	ld	s2,16(sp)
    800045e8:	69a2                	ld	s3,8(sp)
    800045ea:	6145                	addi	sp,sp,48
    800045ec:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045ee:	0284a983          	lw	s3,40(s1)
    800045f2:	ffffd097          	auipc	ra,0xffffd
    800045f6:	3de080e7          	jalr	990(ra) # 800019d0 <myproc>
    800045fa:	5904                	lw	s1,48(a0)
    800045fc:	413484b3          	sub	s1,s1,s3
    80004600:	0014b493          	seqz	s1,s1
    80004604:	bfc1                	j	800045d4 <holdingsleep+0x24>

0000000080004606 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004606:	1141                	addi	sp,sp,-16
    80004608:	e406                	sd	ra,8(sp)
    8000460a:	e022                	sd	s0,0(sp)
    8000460c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000460e:	00004597          	auipc	a1,0x4
    80004612:	08a58593          	addi	a1,a1,138 # 80008698 <syscalls+0x248>
    80004616:	0001c517          	auipc	a0,0x1c
    8000461a:	66250513          	addi	a0,a0,1634 # 80020c78 <ftable>
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	53c080e7          	jalr	1340(ra) # 80000b5a <initlock>
}
    80004626:	60a2                	ld	ra,8(sp)
    80004628:	6402                	ld	s0,0(sp)
    8000462a:	0141                	addi	sp,sp,16
    8000462c:	8082                	ret

000000008000462e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000462e:	1101                	addi	sp,sp,-32
    80004630:	ec06                	sd	ra,24(sp)
    80004632:	e822                	sd	s0,16(sp)
    80004634:	e426                	sd	s1,8(sp)
    80004636:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004638:	0001c517          	auipc	a0,0x1c
    8000463c:	64050513          	addi	a0,a0,1600 # 80020c78 <ftable>
    80004640:	ffffc097          	auipc	ra,0xffffc
    80004644:	5aa080e7          	jalr	1450(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004648:	0001c497          	auipc	s1,0x1c
    8000464c:	64848493          	addi	s1,s1,1608 # 80020c90 <ftable+0x18>
    80004650:	0001d717          	auipc	a4,0x1d
    80004654:	5e070713          	addi	a4,a4,1504 # 80021c30 <disk>
    if(f->ref == 0){
    80004658:	40dc                	lw	a5,4(s1)
    8000465a:	cf99                	beqz	a5,80004678 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000465c:	02848493          	addi	s1,s1,40
    80004660:	fee49ce3          	bne	s1,a4,80004658 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004664:	0001c517          	auipc	a0,0x1c
    80004668:	61450513          	addi	a0,a0,1556 # 80020c78 <ftable>
    8000466c:	ffffc097          	auipc	ra,0xffffc
    80004670:	632080e7          	jalr	1586(ra) # 80000c9e <release>
  return 0;
    80004674:	4481                	li	s1,0
    80004676:	a819                	j	8000468c <filealloc+0x5e>
      f->ref = 1;
    80004678:	4785                	li	a5,1
    8000467a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000467c:	0001c517          	auipc	a0,0x1c
    80004680:	5fc50513          	addi	a0,a0,1532 # 80020c78 <ftable>
    80004684:	ffffc097          	auipc	ra,0xffffc
    80004688:	61a080e7          	jalr	1562(ra) # 80000c9e <release>
}
    8000468c:	8526                	mv	a0,s1
    8000468e:	60e2                	ld	ra,24(sp)
    80004690:	6442                	ld	s0,16(sp)
    80004692:	64a2                	ld	s1,8(sp)
    80004694:	6105                	addi	sp,sp,32
    80004696:	8082                	ret

0000000080004698 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004698:	1101                	addi	sp,sp,-32
    8000469a:	ec06                	sd	ra,24(sp)
    8000469c:	e822                	sd	s0,16(sp)
    8000469e:	e426                	sd	s1,8(sp)
    800046a0:	1000                	addi	s0,sp,32
    800046a2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046a4:	0001c517          	auipc	a0,0x1c
    800046a8:	5d450513          	addi	a0,a0,1492 # 80020c78 <ftable>
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	53e080e7          	jalr	1342(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800046b4:	40dc                	lw	a5,4(s1)
    800046b6:	02f05263          	blez	a5,800046da <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046ba:	2785                	addiw	a5,a5,1
    800046bc:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046be:	0001c517          	auipc	a0,0x1c
    800046c2:	5ba50513          	addi	a0,a0,1466 # 80020c78 <ftable>
    800046c6:	ffffc097          	auipc	ra,0xffffc
    800046ca:	5d8080e7          	jalr	1496(ra) # 80000c9e <release>
  return f;
}
    800046ce:	8526                	mv	a0,s1
    800046d0:	60e2                	ld	ra,24(sp)
    800046d2:	6442                	ld	s0,16(sp)
    800046d4:	64a2                	ld	s1,8(sp)
    800046d6:	6105                	addi	sp,sp,32
    800046d8:	8082                	ret
    panic("filedup");
    800046da:	00004517          	auipc	a0,0x4
    800046de:	fc650513          	addi	a0,a0,-58 # 800086a0 <syscalls+0x250>
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	e62080e7          	jalr	-414(ra) # 80000544 <panic>

00000000800046ea <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046ea:	7139                	addi	sp,sp,-64
    800046ec:	fc06                	sd	ra,56(sp)
    800046ee:	f822                	sd	s0,48(sp)
    800046f0:	f426                	sd	s1,40(sp)
    800046f2:	f04a                	sd	s2,32(sp)
    800046f4:	ec4e                	sd	s3,24(sp)
    800046f6:	e852                	sd	s4,16(sp)
    800046f8:	e456                	sd	s5,8(sp)
    800046fa:	0080                	addi	s0,sp,64
    800046fc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046fe:	0001c517          	auipc	a0,0x1c
    80004702:	57a50513          	addi	a0,a0,1402 # 80020c78 <ftable>
    80004706:	ffffc097          	auipc	ra,0xffffc
    8000470a:	4e4080e7          	jalr	1252(ra) # 80000bea <acquire>
  if(f->ref < 1)
    8000470e:	40dc                	lw	a5,4(s1)
    80004710:	06f05163          	blez	a5,80004772 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004714:	37fd                	addiw	a5,a5,-1
    80004716:	0007871b          	sext.w	a4,a5
    8000471a:	c0dc                	sw	a5,4(s1)
    8000471c:	06e04363          	bgtz	a4,80004782 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004720:	0004a903          	lw	s2,0(s1)
    80004724:	0094ca83          	lbu	s5,9(s1)
    80004728:	0104ba03          	ld	s4,16(s1)
    8000472c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004730:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004734:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004738:	0001c517          	auipc	a0,0x1c
    8000473c:	54050513          	addi	a0,a0,1344 # 80020c78 <ftable>
    80004740:	ffffc097          	auipc	ra,0xffffc
    80004744:	55e080e7          	jalr	1374(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004748:	4785                	li	a5,1
    8000474a:	04f90d63          	beq	s2,a5,800047a4 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000474e:	3979                	addiw	s2,s2,-2
    80004750:	4785                	li	a5,1
    80004752:	0527e063          	bltu	a5,s2,80004792 <fileclose+0xa8>
    begin_op();
    80004756:	00000097          	auipc	ra,0x0
    8000475a:	ac8080e7          	jalr	-1336(ra) # 8000421e <begin_op>
    iput(ff.ip);
    8000475e:	854e                	mv	a0,s3
    80004760:	fffff097          	auipc	ra,0xfffff
    80004764:	2b6080e7          	jalr	694(ra) # 80003a16 <iput>
    end_op();
    80004768:	00000097          	auipc	ra,0x0
    8000476c:	b36080e7          	jalr	-1226(ra) # 8000429e <end_op>
    80004770:	a00d                	j	80004792 <fileclose+0xa8>
    panic("fileclose");
    80004772:	00004517          	auipc	a0,0x4
    80004776:	f3650513          	addi	a0,a0,-202 # 800086a8 <syscalls+0x258>
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	dca080e7          	jalr	-566(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004782:	0001c517          	auipc	a0,0x1c
    80004786:	4f650513          	addi	a0,a0,1270 # 80020c78 <ftable>
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	514080e7          	jalr	1300(ra) # 80000c9e <release>
  }
}
    80004792:	70e2                	ld	ra,56(sp)
    80004794:	7442                	ld	s0,48(sp)
    80004796:	74a2                	ld	s1,40(sp)
    80004798:	7902                	ld	s2,32(sp)
    8000479a:	69e2                	ld	s3,24(sp)
    8000479c:	6a42                	ld	s4,16(sp)
    8000479e:	6aa2                	ld	s5,8(sp)
    800047a0:	6121                	addi	sp,sp,64
    800047a2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047a4:	85d6                	mv	a1,s5
    800047a6:	8552                	mv	a0,s4
    800047a8:	00000097          	auipc	ra,0x0
    800047ac:	34c080e7          	jalr	844(ra) # 80004af4 <pipeclose>
    800047b0:	b7cd                	j	80004792 <fileclose+0xa8>

00000000800047b2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047b2:	715d                	addi	sp,sp,-80
    800047b4:	e486                	sd	ra,72(sp)
    800047b6:	e0a2                	sd	s0,64(sp)
    800047b8:	fc26                	sd	s1,56(sp)
    800047ba:	f84a                	sd	s2,48(sp)
    800047bc:	f44e                	sd	s3,40(sp)
    800047be:	0880                	addi	s0,sp,80
    800047c0:	84aa                	mv	s1,a0
    800047c2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047c4:	ffffd097          	auipc	ra,0xffffd
    800047c8:	20c080e7          	jalr	524(ra) # 800019d0 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047cc:	409c                	lw	a5,0(s1)
    800047ce:	37f9                	addiw	a5,a5,-2
    800047d0:	4705                	li	a4,1
    800047d2:	04f76763          	bltu	a4,a5,80004820 <filestat+0x6e>
    800047d6:	892a                	mv	s2,a0
    ilock(f->ip);
    800047d8:	6c88                	ld	a0,24(s1)
    800047da:	fffff097          	auipc	ra,0xfffff
    800047de:	082080e7          	jalr	130(ra) # 8000385c <ilock>
    stati(f->ip, &st);
    800047e2:	fb840593          	addi	a1,s0,-72
    800047e6:	6c88                	ld	a0,24(s1)
    800047e8:	fffff097          	auipc	ra,0xfffff
    800047ec:	2fe080e7          	jalr	766(ra) # 80003ae6 <stati>
    iunlock(f->ip);
    800047f0:	6c88                	ld	a0,24(s1)
    800047f2:	fffff097          	auipc	ra,0xfffff
    800047f6:	12c080e7          	jalr	300(ra) # 8000391e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047fa:	46e1                	li	a3,24
    800047fc:	fb840613          	addi	a2,s0,-72
    80004800:	85ce                	mv	a1,s3
    80004802:	05093503          	ld	a0,80(s2)
    80004806:	ffffd097          	auipc	ra,0xffffd
    8000480a:	e7e080e7          	jalr	-386(ra) # 80001684 <copyout>
    8000480e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004812:	60a6                	ld	ra,72(sp)
    80004814:	6406                	ld	s0,64(sp)
    80004816:	74e2                	ld	s1,56(sp)
    80004818:	7942                	ld	s2,48(sp)
    8000481a:	79a2                	ld	s3,40(sp)
    8000481c:	6161                	addi	sp,sp,80
    8000481e:	8082                	ret
  return -1;
    80004820:	557d                	li	a0,-1
    80004822:	bfc5                	j	80004812 <filestat+0x60>

0000000080004824 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004824:	7179                	addi	sp,sp,-48
    80004826:	f406                	sd	ra,40(sp)
    80004828:	f022                	sd	s0,32(sp)
    8000482a:	ec26                	sd	s1,24(sp)
    8000482c:	e84a                	sd	s2,16(sp)
    8000482e:	e44e                	sd	s3,8(sp)
    80004830:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004832:	00854783          	lbu	a5,8(a0)
    80004836:	c3d5                	beqz	a5,800048da <fileread+0xb6>
    80004838:	84aa                	mv	s1,a0
    8000483a:	89ae                	mv	s3,a1
    8000483c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000483e:	411c                	lw	a5,0(a0)
    80004840:	4705                	li	a4,1
    80004842:	04e78963          	beq	a5,a4,80004894 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004846:	470d                	li	a4,3
    80004848:	04e78d63          	beq	a5,a4,800048a2 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000484c:	4709                	li	a4,2
    8000484e:	06e79e63          	bne	a5,a4,800048ca <fileread+0xa6>
    ilock(f->ip);
    80004852:	6d08                	ld	a0,24(a0)
    80004854:	fffff097          	auipc	ra,0xfffff
    80004858:	008080e7          	jalr	8(ra) # 8000385c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000485c:	874a                	mv	a4,s2
    8000485e:	5094                	lw	a3,32(s1)
    80004860:	864e                	mv	a2,s3
    80004862:	4585                	li	a1,1
    80004864:	6c88                	ld	a0,24(s1)
    80004866:	fffff097          	auipc	ra,0xfffff
    8000486a:	2aa080e7          	jalr	682(ra) # 80003b10 <readi>
    8000486e:	892a                	mv	s2,a0
    80004870:	00a05563          	blez	a0,8000487a <fileread+0x56>
      f->off += r;
    80004874:	509c                	lw	a5,32(s1)
    80004876:	9fa9                	addw	a5,a5,a0
    80004878:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000487a:	6c88                	ld	a0,24(s1)
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	0a2080e7          	jalr	162(ra) # 8000391e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004884:	854a                	mv	a0,s2
    80004886:	70a2                	ld	ra,40(sp)
    80004888:	7402                	ld	s0,32(sp)
    8000488a:	64e2                	ld	s1,24(sp)
    8000488c:	6942                	ld	s2,16(sp)
    8000488e:	69a2                	ld	s3,8(sp)
    80004890:	6145                	addi	sp,sp,48
    80004892:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004894:	6908                	ld	a0,16(a0)
    80004896:	00000097          	auipc	ra,0x0
    8000489a:	3ce080e7          	jalr	974(ra) # 80004c64 <piperead>
    8000489e:	892a                	mv	s2,a0
    800048a0:	b7d5                	j	80004884 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048a2:	02451783          	lh	a5,36(a0)
    800048a6:	03079693          	slli	a3,a5,0x30
    800048aa:	92c1                	srli	a3,a3,0x30
    800048ac:	4725                	li	a4,9
    800048ae:	02d76863          	bltu	a4,a3,800048de <fileread+0xba>
    800048b2:	0792                	slli	a5,a5,0x4
    800048b4:	0001c717          	auipc	a4,0x1c
    800048b8:	32470713          	addi	a4,a4,804 # 80020bd8 <devsw>
    800048bc:	97ba                	add	a5,a5,a4
    800048be:	639c                	ld	a5,0(a5)
    800048c0:	c38d                	beqz	a5,800048e2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800048c2:	4505                	li	a0,1
    800048c4:	9782                	jalr	a5
    800048c6:	892a                	mv	s2,a0
    800048c8:	bf75                	j	80004884 <fileread+0x60>
    panic("fileread");
    800048ca:	00004517          	auipc	a0,0x4
    800048ce:	dee50513          	addi	a0,a0,-530 # 800086b8 <syscalls+0x268>
    800048d2:	ffffc097          	auipc	ra,0xffffc
    800048d6:	c72080e7          	jalr	-910(ra) # 80000544 <panic>
    return -1;
    800048da:	597d                	li	s2,-1
    800048dc:	b765                	j	80004884 <fileread+0x60>
      return -1;
    800048de:	597d                	li	s2,-1
    800048e0:	b755                	j	80004884 <fileread+0x60>
    800048e2:	597d                	li	s2,-1
    800048e4:	b745                	j	80004884 <fileread+0x60>

00000000800048e6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800048e6:	715d                	addi	sp,sp,-80
    800048e8:	e486                	sd	ra,72(sp)
    800048ea:	e0a2                	sd	s0,64(sp)
    800048ec:	fc26                	sd	s1,56(sp)
    800048ee:	f84a                	sd	s2,48(sp)
    800048f0:	f44e                	sd	s3,40(sp)
    800048f2:	f052                	sd	s4,32(sp)
    800048f4:	ec56                	sd	s5,24(sp)
    800048f6:	e85a                	sd	s6,16(sp)
    800048f8:	e45e                	sd	s7,8(sp)
    800048fa:	e062                	sd	s8,0(sp)
    800048fc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800048fe:	00954783          	lbu	a5,9(a0)
    80004902:	10078663          	beqz	a5,80004a0e <filewrite+0x128>
    80004906:	892a                	mv	s2,a0
    80004908:	8aae                	mv	s5,a1
    8000490a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000490c:	411c                	lw	a5,0(a0)
    8000490e:	4705                	li	a4,1
    80004910:	02e78263          	beq	a5,a4,80004934 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004914:	470d                	li	a4,3
    80004916:	02e78663          	beq	a5,a4,80004942 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000491a:	4709                	li	a4,2
    8000491c:	0ee79163          	bne	a5,a4,800049fe <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004920:	0ac05d63          	blez	a2,800049da <filewrite+0xf4>
    int i = 0;
    80004924:	4981                	li	s3,0
    80004926:	6b05                	lui	s6,0x1
    80004928:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000492c:	6b85                	lui	s7,0x1
    8000492e:	c00b8b9b          	addiw	s7,s7,-1024
    80004932:	a861                	j	800049ca <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004934:	6908                	ld	a0,16(a0)
    80004936:	00000097          	auipc	ra,0x0
    8000493a:	22e080e7          	jalr	558(ra) # 80004b64 <pipewrite>
    8000493e:	8a2a                	mv	s4,a0
    80004940:	a045                	j	800049e0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004942:	02451783          	lh	a5,36(a0)
    80004946:	03079693          	slli	a3,a5,0x30
    8000494a:	92c1                	srli	a3,a3,0x30
    8000494c:	4725                	li	a4,9
    8000494e:	0cd76263          	bltu	a4,a3,80004a12 <filewrite+0x12c>
    80004952:	0792                	slli	a5,a5,0x4
    80004954:	0001c717          	auipc	a4,0x1c
    80004958:	28470713          	addi	a4,a4,644 # 80020bd8 <devsw>
    8000495c:	97ba                	add	a5,a5,a4
    8000495e:	679c                	ld	a5,8(a5)
    80004960:	cbdd                	beqz	a5,80004a16 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004962:	4505                	li	a0,1
    80004964:	9782                	jalr	a5
    80004966:	8a2a                	mv	s4,a0
    80004968:	a8a5                	j	800049e0 <filewrite+0xfa>
    8000496a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000496e:	00000097          	auipc	ra,0x0
    80004972:	8b0080e7          	jalr	-1872(ra) # 8000421e <begin_op>
      ilock(f->ip);
    80004976:	01893503          	ld	a0,24(s2)
    8000497a:	fffff097          	auipc	ra,0xfffff
    8000497e:	ee2080e7          	jalr	-286(ra) # 8000385c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004982:	8762                	mv	a4,s8
    80004984:	02092683          	lw	a3,32(s2)
    80004988:	01598633          	add	a2,s3,s5
    8000498c:	4585                	li	a1,1
    8000498e:	01893503          	ld	a0,24(s2)
    80004992:	fffff097          	auipc	ra,0xfffff
    80004996:	276080e7          	jalr	630(ra) # 80003c08 <writei>
    8000499a:	84aa                	mv	s1,a0
    8000499c:	00a05763          	blez	a0,800049aa <filewrite+0xc4>
        f->off += r;
    800049a0:	02092783          	lw	a5,32(s2)
    800049a4:	9fa9                	addw	a5,a5,a0
    800049a6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049aa:	01893503          	ld	a0,24(s2)
    800049ae:	fffff097          	auipc	ra,0xfffff
    800049b2:	f70080e7          	jalr	-144(ra) # 8000391e <iunlock>
      end_op();
    800049b6:	00000097          	auipc	ra,0x0
    800049ba:	8e8080e7          	jalr	-1816(ra) # 8000429e <end_op>

      if(r != n1){
    800049be:	009c1f63          	bne	s8,s1,800049dc <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800049c2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800049c6:	0149db63          	bge	s3,s4,800049dc <filewrite+0xf6>
      int n1 = n - i;
    800049ca:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800049ce:	84be                	mv	s1,a5
    800049d0:	2781                	sext.w	a5,a5
    800049d2:	f8fb5ce3          	bge	s6,a5,8000496a <filewrite+0x84>
    800049d6:	84de                	mv	s1,s7
    800049d8:	bf49                	j	8000496a <filewrite+0x84>
    int i = 0;
    800049da:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800049dc:	013a1f63          	bne	s4,s3,800049fa <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049e0:	8552                	mv	a0,s4
    800049e2:	60a6                	ld	ra,72(sp)
    800049e4:	6406                	ld	s0,64(sp)
    800049e6:	74e2                	ld	s1,56(sp)
    800049e8:	7942                	ld	s2,48(sp)
    800049ea:	79a2                	ld	s3,40(sp)
    800049ec:	7a02                	ld	s4,32(sp)
    800049ee:	6ae2                	ld	s5,24(sp)
    800049f0:	6b42                	ld	s6,16(sp)
    800049f2:	6ba2                	ld	s7,8(sp)
    800049f4:	6c02                	ld	s8,0(sp)
    800049f6:	6161                	addi	sp,sp,80
    800049f8:	8082                	ret
    ret = (i == n ? n : -1);
    800049fa:	5a7d                	li	s4,-1
    800049fc:	b7d5                	j	800049e0 <filewrite+0xfa>
    panic("filewrite");
    800049fe:	00004517          	auipc	a0,0x4
    80004a02:	cca50513          	addi	a0,a0,-822 # 800086c8 <syscalls+0x278>
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	b3e080e7          	jalr	-1218(ra) # 80000544 <panic>
    return -1;
    80004a0e:	5a7d                	li	s4,-1
    80004a10:	bfc1                	j	800049e0 <filewrite+0xfa>
      return -1;
    80004a12:	5a7d                	li	s4,-1
    80004a14:	b7f1                	j	800049e0 <filewrite+0xfa>
    80004a16:	5a7d                	li	s4,-1
    80004a18:	b7e1                	j	800049e0 <filewrite+0xfa>

0000000080004a1a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a1a:	7179                	addi	sp,sp,-48
    80004a1c:	f406                	sd	ra,40(sp)
    80004a1e:	f022                	sd	s0,32(sp)
    80004a20:	ec26                	sd	s1,24(sp)
    80004a22:	e84a                	sd	s2,16(sp)
    80004a24:	e44e                	sd	s3,8(sp)
    80004a26:	e052                	sd	s4,0(sp)
    80004a28:	1800                	addi	s0,sp,48
    80004a2a:	84aa                	mv	s1,a0
    80004a2c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a2e:	0005b023          	sd	zero,0(a1)
    80004a32:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a36:	00000097          	auipc	ra,0x0
    80004a3a:	bf8080e7          	jalr	-1032(ra) # 8000462e <filealloc>
    80004a3e:	e088                	sd	a0,0(s1)
    80004a40:	c551                	beqz	a0,80004acc <pipealloc+0xb2>
    80004a42:	00000097          	auipc	ra,0x0
    80004a46:	bec080e7          	jalr	-1044(ra) # 8000462e <filealloc>
    80004a4a:	00aa3023          	sd	a0,0(s4)
    80004a4e:	c92d                	beqz	a0,80004ac0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a50:	ffffc097          	auipc	ra,0xffffc
    80004a54:	0aa080e7          	jalr	170(ra) # 80000afa <kalloc>
    80004a58:	892a                	mv	s2,a0
    80004a5a:	c125                	beqz	a0,80004aba <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a5c:	4985                	li	s3,1
    80004a5e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a62:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a66:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a6a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a6e:	00004597          	auipc	a1,0x4
    80004a72:	c6a58593          	addi	a1,a1,-918 # 800086d8 <syscalls+0x288>
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	0e4080e7          	jalr	228(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004a7e:	609c                	ld	a5,0(s1)
    80004a80:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a84:	609c                	ld	a5,0(s1)
    80004a86:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a8a:	609c                	ld	a5,0(s1)
    80004a8c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a90:	609c                	ld	a5,0(s1)
    80004a92:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a96:	000a3783          	ld	a5,0(s4)
    80004a9a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a9e:	000a3783          	ld	a5,0(s4)
    80004aa2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004aa6:	000a3783          	ld	a5,0(s4)
    80004aaa:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004aae:	000a3783          	ld	a5,0(s4)
    80004ab2:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ab6:	4501                	li	a0,0
    80004ab8:	a025                	j	80004ae0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004aba:	6088                	ld	a0,0(s1)
    80004abc:	e501                	bnez	a0,80004ac4 <pipealloc+0xaa>
    80004abe:	a039                	j	80004acc <pipealloc+0xb2>
    80004ac0:	6088                	ld	a0,0(s1)
    80004ac2:	c51d                	beqz	a0,80004af0 <pipealloc+0xd6>
    fileclose(*f0);
    80004ac4:	00000097          	auipc	ra,0x0
    80004ac8:	c26080e7          	jalr	-986(ra) # 800046ea <fileclose>
  if(*f1)
    80004acc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ad0:	557d                	li	a0,-1
  if(*f1)
    80004ad2:	c799                	beqz	a5,80004ae0 <pipealloc+0xc6>
    fileclose(*f1);
    80004ad4:	853e                	mv	a0,a5
    80004ad6:	00000097          	auipc	ra,0x0
    80004ada:	c14080e7          	jalr	-1004(ra) # 800046ea <fileclose>
  return -1;
    80004ade:	557d                	li	a0,-1
}
    80004ae0:	70a2                	ld	ra,40(sp)
    80004ae2:	7402                	ld	s0,32(sp)
    80004ae4:	64e2                	ld	s1,24(sp)
    80004ae6:	6942                	ld	s2,16(sp)
    80004ae8:	69a2                	ld	s3,8(sp)
    80004aea:	6a02                	ld	s4,0(sp)
    80004aec:	6145                	addi	sp,sp,48
    80004aee:	8082                	ret
  return -1;
    80004af0:	557d                	li	a0,-1
    80004af2:	b7fd                	j	80004ae0 <pipealloc+0xc6>

0000000080004af4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004af4:	1101                	addi	sp,sp,-32
    80004af6:	ec06                	sd	ra,24(sp)
    80004af8:	e822                	sd	s0,16(sp)
    80004afa:	e426                	sd	s1,8(sp)
    80004afc:	e04a                	sd	s2,0(sp)
    80004afe:	1000                	addi	s0,sp,32
    80004b00:	84aa                	mv	s1,a0
    80004b02:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b04:	ffffc097          	auipc	ra,0xffffc
    80004b08:	0e6080e7          	jalr	230(ra) # 80000bea <acquire>
  if(writable){
    80004b0c:	02090d63          	beqz	s2,80004b46 <pipeclose+0x52>
    pi->writeopen = 0;
    80004b10:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b14:	21848513          	addi	a0,s1,536
    80004b18:	ffffd097          	auipc	ra,0xffffd
    80004b1c:	5c0080e7          	jalr	1472(ra) # 800020d8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b20:	2204b783          	ld	a5,544(s1)
    80004b24:	eb95                	bnez	a5,80004b58 <pipeclose+0x64>
    release(&pi->lock);
    80004b26:	8526                	mv	a0,s1
    80004b28:	ffffc097          	auipc	ra,0xffffc
    80004b2c:	176080e7          	jalr	374(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004b30:	8526                	mv	a0,s1
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	ecc080e7          	jalr	-308(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004b3a:	60e2                	ld	ra,24(sp)
    80004b3c:	6442                	ld	s0,16(sp)
    80004b3e:	64a2                	ld	s1,8(sp)
    80004b40:	6902                	ld	s2,0(sp)
    80004b42:	6105                	addi	sp,sp,32
    80004b44:	8082                	ret
    pi->readopen = 0;
    80004b46:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b4a:	21c48513          	addi	a0,s1,540
    80004b4e:	ffffd097          	auipc	ra,0xffffd
    80004b52:	58a080e7          	jalr	1418(ra) # 800020d8 <wakeup>
    80004b56:	b7e9                	j	80004b20 <pipeclose+0x2c>
    release(&pi->lock);
    80004b58:	8526                	mv	a0,s1
    80004b5a:	ffffc097          	auipc	ra,0xffffc
    80004b5e:	144080e7          	jalr	324(ra) # 80000c9e <release>
}
    80004b62:	bfe1                	j	80004b3a <pipeclose+0x46>

0000000080004b64 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b64:	7159                	addi	sp,sp,-112
    80004b66:	f486                	sd	ra,104(sp)
    80004b68:	f0a2                	sd	s0,96(sp)
    80004b6a:	eca6                	sd	s1,88(sp)
    80004b6c:	e8ca                	sd	s2,80(sp)
    80004b6e:	e4ce                	sd	s3,72(sp)
    80004b70:	e0d2                	sd	s4,64(sp)
    80004b72:	fc56                	sd	s5,56(sp)
    80004b74:	f85a                	sd	s6,48(sp)
    80004b76:	f45e                	sd	s7,40(sp)
    80004b78:	f062                	sd	s8,32(sp)
    80004b7a:	ec66                	sd	s9,24(sp)
    80004b7c:	1880                	addi	s0,sp,112
    80004b7e:	84aa                	mv	s1,a0
    80004b80:	8aae                	mv	s5,a1
    80004b82:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b84:	ffffd097          	auipc	ra,0xffffd
    80004b88:	e4c080e7          	jalr	-436(ra) # 800019d0 <myproc>
    80004b8c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b8e:	8526                	mv	a0,s1
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	05a080e7          	jalr	90(ra) # 80000bea <acquire>
  while(i < n){
    80004b98:	0d405463          	blez	s4,80004c60 <pipewrite+0xfc>
    80004b9c:	8ba6                	mv	s7,s1
  int i = 0;
    80004b9e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ba0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ba2:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ba6:	21c48c13          	addi	s8,s1,540
    80004baa:	a08d                	j	80004c0c <pipewrite+0xa8>
      release(&pi->lock);
    80004bac:	8526                	mv	a0,s1
    80004bae:	ffffc097          	auipc	ra,0xffffc
    80004bb2:	0f0080e7          	jalr	240(ra) # 80000c9e <release>
      return -1;
    80004bb6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bb8:	854a                	mv	a0,s2
    80004bba:	70a6                	ld	ra,104(sp)
    80004bbc:	7406                	ld	s0,96(sp)
    80004bbe:	64e6                	ld	s1,88(sp)
    80004bc0:	6946                	ld	s2,80(sp)
    80004bc2:	69a6                	ld	s3,72(sp)
    80004bc4:	6a06                	ld	s4,64(sp)
    80004bc6:	7ae2                	ld	s5,56(sp)
    80004bc8:	7b42                	ld	s6,48(sp)
    80004bca:	7ba2                	ld	s7,40(sp)
    80004bcc:	7c02                	ld	s8,32(sp)
    80004bce:	6ce2                	ld	s9,24(sp)
    80004bd0:	6165                	addi	sp,sp,112
    80004bd2:	8082                	ret
      wakeup(&pi->nread);
    80004bd4:	8566                	mv	a0,s9
    80004bd6:	ffffd097          	auipc	ra,0xffffd
    80004bda:	502080e7          	jalr	1282(ra) # 800020d8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bde:	85de                	mv	a1,s7
    80004be0:	8562                	mv	a0,s8
    80004be2:	ffffd097          	auipc	ra,0xffffd
    80004be6:	492080e7          	jalr	1170(ra) # 80002074 <sleep>
    80004bea:	a839                	j	80004c08 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bec:	21c4a783          	lw	a5,540(s1)
    80004bf0:	0017871b          	addiw	a4,a5,1
    80004bf4:	20e4ae23          	sw	a4,540(s1)
    80004bf8:	1ff7f793          	andi	a5,a5,511
    80004bfc:	97a6                	add	a5,a5,s1
    80004bfe:	f9f44703          	lbu	a4,-97(s0)
    80004c02:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c06:	2905                	addiw	s2,s2,1
  while(i < n){
    80004c08:	05495063          	bge	s2,s4,80004c48 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004c0c:	2204a783          	lw	a5,544(s1)
    80004c10:	dfd1                	beqz	a5,80004bac <pipewrite+0x48>
    80004c12:	854e                	mv	a0,s3
    80004c14:	ffffd097          	auipc	ra,0xffffd
    80004c18:	708080e7          	jalr	1800(ra) # 8000231c <killed>
    80004c1c:	f941                	bnez	a0,80004bac <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c1e:	2184a783          	lw	a5,536(s1)
    80004c22:	21c4a703          	lw	a4,540(s1)
    80004c26:	2007879b          	addiw	a5,a5,512
    80004c2a:	faf705e3          	beq	a4,a5,80004bd4 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c2e:	4685                	li	a3,1
    80004c30:	01590633          	add	a2,s2,s5
    80004c34:	f9f40593          	addi	a1,s0,-97
    80004c38:	0509b503          	ld	a0,80(s3)
    80004c3c:	ffffd097          	auipc	ra,0xffffd
    80004c40:	ad4080e7          	jalr	-1324(ra) # 80001710 <copyin>
    80004c44:	fb6514e3          	bne	a0,s6,80004bec <pipewrite+0x88>
  wakeup(&pi->nread);
    80004c48:	21848513          	addi	a0,s1,536
    80004c4c:	ffffd097          	auipc	ra,0xffffd
    80004c50:	48c080e7          	jalr	1164(ra) # 800020d8 <wakeup>
  release(&pi->lock);
    80004c54:	8526                	mv	a0,s1
    80004c56:	ffffc097          	auipc	ra,0xffffc
    80004c5a:	048080e7          	jalr	72(ra) # 80000c9e <release>
  return i;
    80004c5e:	bfa9                	j	80004bb8 <pipewrite+0x54>
  int i = 0;
    80004c60:	4901                	li	s2,0
    80004c62:	b7dd                	j	80004c48 <pipewrite+0xe4>

0000000080004c64 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c64:	715d                	addi	sp,sp,-80
    80004c66:	e486                	sd	ra,72(sp)
    80004c68:	e0a2                	sd	s0,64(sp)
    80004c6a:	fc26                	sd	s1,56(sp)
    80004c6c:	f84a                	sd	s2,48(sp)
    80004c6e:	f44e                	sd	s3,40(sp)
    80004c70:	f052                	sd	s4,32(sp)
    80004c72:	ec56                	sd	s5,24(sp)
    80004c74:	e85a                	sd	s6,16(sp)
    80004c76:	0880                	addi	s0,sp,80
    80004c78:	84aa                	mv	s1,a0
    80004c7a:	892e                	mv	s2,a1
    80004c7c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c7e:	ffffd097          	auipc	ra,0xffffd
    80004c82:	d52080e7          	jalr	-686(ra) # 800019d0 <myproc>
    80004c86:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c88:	8b26                	mv	s6,s1
    80004c8a:	8526                	mv	a0,s1
    80004c8c:	ffffc097          	auipc	ra,0xffffc
    80004c90:	f5e080e7          	jalr	-162(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c94:	2184a703          	lw	a4,536(s1)
    80004c98:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c9c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ca0:	02f71763          	bne	a4,a5,80004cce <piperead+0x6a>
    80004ca4:	2244a783          	lw	a5,548(s1)
    80004ca8:	c39d                	beqz	a5,80004cce <piperead+0x6a>
    if(killed(pr)){
    80004caa:	8552                	mv	a0,s4
    80004cac:	ffffd097          	auipc	ra,0xffffd
    80004cb0:	670080e7          	jalr	1648(ra) # 8000231c <killed>
    80004cb4:	e941                	bnez	a0,80004d44 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cb6:	85da                	mv	a1,s6
    80004cb8:	854e                	mv	a0,s3
    80004cba:	ffffd097          	auipc	ra,0xffffd
    80004cbe:	3ba080e7          	jalr	954(ra) # 80002074 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cc2:	2184a703          	lw	a4,536(s1)
    80004cc6:	21c4a783          	lw	a5,540(s1)
    80004cca:	fcf70de3          	beq	a4,a5,80004ca4 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cce:	09505263          	blez	s5,80004d52 <piperead+0xee>
    80004cd2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cd4:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004cd6:	2184a783          	lw	a5,536(s1)
    80004cda:	21c4a703          	lw	a4,540(s1)
    80004cde:	02f70d63          	beq	a4,a5,80004d18 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ce2:	0017871b          	addiw	a4,a5,1
    80004ce6:	20e4ac23          	sw	a4,536(s1)
    80004cea:	1ff7f793          	andi	a5,a5,511
    80004cee:	97a6                	add	a5,a5,s1
    80004cf0:	0187c783          	lbu	a5,24(a5)
    80004cf4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cf8:	4685                	li	a3,1
    80004cfa:	fbf40613          	addi	a2,s0,-65
    80004cfe:	85ca                	mv	a1,s2
    80004d00:	050a3503          	ld	a0,80(s4)
    80004d04:	ffffd097          	auipc	ra,0xffffd
    80004d08:	980080e7          	jalr	-1664(ra) # 80001684 <copyout>
    80004d0c:	01650663          	beq	a0,s6,80004d18 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d10:	2985                	addiw	s3,s3,1
    80004d12:	0905                	addi	s2,s2,1
    80004d14:	fd3a91e3          	bne	s5,s3,80004cd6 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d18:	21c48513          	addi	a0,s1,540
    80004d1c:	ffffd097          	auipc	ra,0xffffd
    80004d20:	3bc080e7          	jalr	956(ra) # 800020d8 <wakeup>
  release(&pi->lock);
    80004d24:	8526                	mv	a0,s1
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	f78080e7          	jalr	-136(ra) # 80000c9e <release>
  return i;
}
    80004d2e:	854e                	mv	a0,s3
    80004d30:	60a6                	ld	ra,72(sp)
    80004d32:	6406                	ld	s0,64(sp)
    80004d34:	74e2                	ld	s1,56(sp)
    80004d36:	7942                	ld	s2,48(sp)
    80004d38:	79a2                	ld	s3,40(sp)
    80004d3a:	7a02                	ld	s4,32(sp)
    80004d3c:	6ae2                	ld	s5,24(sp)
    80004d3e:	6b42                	ld	s6,16(sp)
    80004d40:	6161                	addi	sp,sp,80
    80004d42:	8082                	ret
      release(&pi->lock);
    80004d44:	8526                	mv	a0,s1
    80004d46:	ffffc097          	auipc	ra,0xffffc
    80004d4a:	f58080e7          	jalr	-168(ra) # 80000c9e <release>
      return -1;
    80004d4e:	59fd                	li	s3,-1
    80004d50:	bff9                	j	80004d2e <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d52:	4981                	li	s3,0
    80004d54:	b7d1                	j	80004d18 <piperead+0xb4>

0000000080004d56 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004d56:	1141                	addi	sp,sp,-16
    80004d58:	e422                	sd	s0,8(sp)
    80004d5a:	0800                	addi	s0,sp,16
    80004d5c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004d5e:	8905                	andi	a0,a0,1
    80004d60:	c111                	beqz	a0,80004d64 <flags2perm+0xe>
      perm = PTE_X;
    80004d62:	4521                	li	a0,8
    if(flags & 0x2)
    80004d64:	8b89                	andi	a5,a5,2
    80004d66:	c399                	beqz	a5,80004d6c <flags2perm+0x16>
      perm |= PTE_W;
    80004d68:	00456513          	ori	a0,a0,4
    return perm;
}
    80004d6c:	6422                	ld	s0,8(sp)
    80004d6e:	0141                	addi	sp,sp,16
    80004d70:	8082                	ret

0000000080004d72 <exec>:

int
exec(char *path, char **argv)
{
    80004d72:	df010113          	addi	sp,sp,-528
    80004d76:	20113423          	sd	ra,520(sp)
    80004d7a:	20813023          	sd	s0,512(sp)
    80004d7e:	ffa6                	sd	s1,504(sp)
    80004d80:	fbca                	sd	s2,496(sp)
    80004d82:	f7ce                	sd	s3,488(sp)
    80004d84:	f3d2                	sd	s4,480(sp)
    80004d86:	efd6                	sd	s5,472(sp)
    80004d88:	ebda                	sd	s6,464(sp)
    80004d8a:	e7de                	sd	s7,456(sp)
    80004d8c:	e3e2                	sd	s8,448(sp)
    80004d8e:	ff66                	sd	s9,440(sp)
    80004d90:	fb6a                	sd	s10,432(sp)
    80004d92:	f76e                	sd	s11,424(sp)
    80004d94:	0c00                	addi	s0,sp,528
    80004d96:	84aa                	mv	s1,a0
    80004d98:	dea43c23          	sd	a0,-520(s0)
    80004d9c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	c30080e7          	jalr	-976(ra) # 800019d0 <myproc>
    80004da8:	892a                	mv	s2,a0

  begin_op();
    80004daa:	fffff097          	auipc	ra,0xfffff
    80004dae:	474080e7          	jalr	1140(ra) # 8000421e <begin_op>

  if((ip = namei(path)) == 0){
    80004db2:	8526                	mv	a0,s1
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	24e080e7          	jalr	590(ra) # 80004002 <namei>
    80004dbc:	c92d                	beqz	a0,80004e2e <exec+0xbc>
    80004dbe:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004dc0:	fffff097          	auipc	ra,0xfffff
    80004dc4:	a9c080e7          	jalr	-1380(ra) # 8000385c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004dc8:	04000713          	li	a4,64
    80004dcc:	4681                	li	a3,0
    80004dce:	e5040613          	addi	a2,s0,-432
    80004dd2:	4581                	li	a1,0
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	fffff097          	auipc	ra,0xfffff
    80004dda:	d3a080e7          	jalr	-710(ra) # 80003b10 <readi>
    80004dde:	04000793          	li	a5,64
    80004de2:	00f51a63          	bne	a0,a5,80004df6 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004de6:	e5042703          	lw	a4,-432(s0)
    80004dea:	464c47b7          	lui	a5,0x464c4
    80004dee:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004df2:	04f70463          	beq	a4,a5,80004e3a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004df6:	8526                	mv	a0,s1
    80004df8:	fffff097          	auipc	ra,0xfffff
    80004dfc:	cc6080e7          	jalr	-826(ra) # 80003abe <iunlockput>
    end_op();
    80004e00:	fffff097          	auipc	ra,0xfffff
    80004e04:	49e080e7          	jalr	1182(ra) # 8000429e <end_op>
  }
  return -1;
    80004e08:	557d                	li	a0,-1
}
    80004e0a:	20813083          	ld	ra,520(sp)
    80004e0e:	20013403          	ld	s0,512(sp)
    80004e12:	74fe                	ld	s1,504(sp)
    80004e14:	795e                	ld	s2,496(sp)
    80004e16:	79be                	ld	s3,488(sp)
    80004e18:	7a1e                	ld	s4,480(sp)
    80004e1a:	6afe                	ld	s5,472(sp)
    80004e1c:	6b5e                	ld	s6,464(sp)
    80004e1e:	6bbe                	ld	s7,456(sp)
    80004e20:	6c1e                	ld	s8,448(sp)
    80004e22:	7cfa                	ld	s9,440(sp)
    80004e24:	7d5a                	ld	s10,432(sp)
    80004e26:	7dba                	ld	s11,424(sp)
    80004e28:	21010113          	addi	sp,sp,528
    80004e2c:	8082                	ret
    end_op();
    80004e2e:	fffff097          	auipc	ra,0xfffff
    80004e32:	470080e7          	jalr	1136(ra) # 8000429e <end_op>
    return -1;
    80004e36:	557d                	li	a0,-1
    80004e38:	bfc9                	j	80004e0a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e3a:	854a                	mv	a0,s2
    80004e3c:	ffffd097          	auipc	ra,0xffffd
    80004e40:	c58080e7          	jalr	-936(ra) # 80001a94 <proc_pagetable>
    80004e44:	8baa                	mv	s7,a0
    80004e46:	d945                	beqz	a0,80004df6 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e48:	e7042983          	lw	s3,-400(s0)
    80004e4c:	e8845783          	lhu	a5,-376(s0)
    80004e50:	c7ad                	beqz	a5,80004eba <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e52:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e54:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004e56:	6c85                	lui	s9,0x1
    80004e58:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e5c:	def43823          	sd	a5,-528(s0)
    80004e60:	ac0d                	j	80005092 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e62:	00004517          	auipc	a0,0x4
    80004e66:	87e50513          	addi	a0,a0,-1922 # 800086e0 <syscalls+0x290>
    80004e6a:	ffffb097          	auipc	ra,0xffffb
    80004e6e:	6da080e7          	jalr	1754(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e72:	8756                	mv	a4,s5
    80004e74:	012d86bb          	addw	a3,s11,s2
    80004e78:	4581                	li	a1,0
    80004e7a:	8526                	mv	a0,s1
    80004e7c:	fffff097          	auipc	ra,0xfffff
    80004e80:	c94080e7          	jalr	-876(ra) # 80003b10 <readi>
    80004e84:	2501                	sext.w	a0,a0
    80004e86:	1aaa9a63          	bne	s5,a0,8000503a <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80004e8a:	6785                	lui	a5,0x1
    80004e8c:	0127893b          	addw	s2,a5,s2
    80004e90:	77fd                	lui	a5,0xfffff
    80004e92:	01478a3b          	addw	s4,a5,s4
    80004e96:	1f897563          	bgeu	s2,s8,80005080 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80004e9a:	02091593          	slli	a1,s2,0x20
    80004e9e:	9181                	srli	a1,a1,0x20
    80004ea0:	95ea                	add	a1,a1,s10
    80004ea2:	855e                	mv	a0,s7
    80004ea4:	ffffc097          	auipc	ra,0xffffc
    80004ea8:	1d4080e7          	jalr	468(ra) # 80001078 <walkaddr>
    80004eac:	862a                	mv	a2,a0
    if(pa == 0)
    80004eae:	d955                	beqz	a0,80004e62 <exec+0xf0>
      n = PGSIZE;
    80004eb0:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004eb2:	fd9a70e3          	bgeu	s4,s9,80004e72 <exec+0x100>
      n = sz - i;
    80004eb6:	8ad2                	mv	s5,s4
    80004eb8:	bf6d                	j	80004e72 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004eba:	4a01                	li	s4,0
  iunlockput(ip);
    80004ebc:	8526                	mv	a0,s1
    80004ebe:	fffff097          	auipc	ra,0xfffff
    80004ec2:	c00080e7          	jalr	-1024(ra) # 80003abe <iunlockput>
  end_op();
    80004ec6:	fffff097          	auipc	ra,0xfffff
    80004eca:	3d8080e7          	jalr	984(ra) # 8000429e <end_op>
  p = myproc();
    80004ece:	ffffd097          	auipc	ra,0xffffd
    80004ed2:	b02080e7          	jalr	-1278(ra) # 800019d0 <myproc>
    80004ed6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004ed8:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004edc:	6785                	lui	a5,0x1
    80004ede:	17fd                	addi	a5,a5,-1
    80004ee0:	9a3e                	add	s4,s4,a5
    80004ee2:	757d                	lui	a0,0xfffff
    80004ee4:	00aa77b3          	and	a5,s4,a0
    80004ee8:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004eec:	4691                	li	a3,4
    80004eee:	6609                	lui	a2,0x2
    80004ef0:	963e                	add	a2,a2,a5
    80004ef2:	85be                	mv	a1,a5
    80004ef4:	855e                	mv	a0,s7
    80004ef6:	ffffc097          	auipc	ra,0xffffc
    80004efa:	536080e7          	jalr	1334(ra) # 8000142c <uvmalloc>
    80004efe:	8b2a                	mv	s6,a0
  ip = 0;
    80004f00:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f02:	12050c63          	beqz	a0,8000503a <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f06:	75f9                	lui	a1,0xffffe
    80004f08:	95aa                	add	a1,a1,a0
    80004f0a:	855e                	mv	a0,s7
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	746080e7          	jalr	1862(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f14:	7c7d                	lui	s8,0xfffff
    80004f16:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f18:	e0043783          	ld	a5,-512(s0)
    80004f1c:	6388                	ld	a0,0(a5)
    80004f1e:	c535                	beqz	a0,80004f8a <exec+0x218>
    80004f20:	e9040993          	addi	s3,s0,-368
    80004f24:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f28:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004f2a:	ffffc097          	auipc	ra,0xffffc
    80004f2e:	f40080e7          	jalr	-192(ra) # 80000e6a <strlen>
    80004f32:	2505                	addiw	a0,a0,1
    80004f34:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f38:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f3c:	13896663          	bltu	s2,s8,80005068 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f40:	e0043d83          	ld	s11,-512(s0)
    80004f44:	000dba03          	ld	s4,0(s11)
    80004f48:	8552                	mv	a0,s4
    80004f4a:	ffffc097          	auipc	ra,0xffffc
    80004f4e:	f20080e7          	jalr	-224(ra) # 80000e6a <strlen>
    80004f52:	0015069b          	addiw	a3,a0,1
    80004f56:	8652                	mv	a2,s4
    80004f58:	85ca                	mv	a1,s2
    80004f5a:	855e                	mv	a0,s7
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	728080e7          	jalr	1832(ra) # 80001684 <copyout>
    80004f64:	10054663          	bltz	a0,80005070 <exec+0x2fe>
    ustack[argc] = sp;
    80004f68:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f6c:	0485                	addi	s1,s1,1
    80004f6e:	008d8793          	addi	a5,s11,8
    80004f72:	e0f43023          	sd	a5,-512(s0)
    80004f76:	008db503          	ld	a0,8(s11)
    80004f7a:	c911                	beqz	a0,80004f8e <exec+0x21c>
    if(argc >= MAXARG)
    80004f7c:	09a1                	addi	s3,s3,8
    80004f7e:	fb3c96e3          	bne	s9,s3,80004f2a <exec+0x1b8>
  sz = sz1;
    80004f82:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f86:	4481                	li	s1,0
    80004f88:	a84d                	j	8000503a <exec+0x2c8>
  sp = sz;
    80004f8a:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f8c:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f8e:	00349793          	slli	a5,s1,0x3
    80004f92:	f9040713          	addi	a4,s0,-112
    80004f96:	97ba                	add	a5,a5,a4
    80004f98:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80004f9c:	00148693          	addi	a3,s1,1
    80004fa0:	068e                	slli	a3,a3,0x3
    80004fa2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004fa6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004faa:	01897663          	bgeu	s2,s8,80004fb6 <exec+0x244>
  sz = sz1;
    80004fae:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fb2:	4481                	li	s1,0
    80004fb4:	a059                	j	8000503a <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004fb6:	e9040613          	addi	a2,s0,-368
    80004fba:	85ca                	mv	a1,s2
    80004fbc:	855e                	mv	a0,s7
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	6c6080e7          	jalr	1734(ra) # 80001684 <copyout>
    80004fc6:	0a054963          	bltz	a0,80005078 <exec+0x306>
  p->trapframe->a1 = sp;
    80004fca:	058ab783          	ld	a5,88(s5)
    80004fce:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004fd2:	df843783          	ld	a5,-520(s0)
    80004fd6:	0007c703          	lbu	a4,0(a5)
    80004fda:	cf11                	beqz	a4,80004ff6 <exec+0x284>
    80004fdc:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004fde:	02f00693          	li	a3,47
    80004fe2:	a039                	j	80004ff0 <exec+0x27e>
      last = s+1;
    80004fe4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004fe8:	0785                	addi	a5,a5,1
    80004fea:	fff7c703          	lbu	a4,-1(a5)
    80004fee:	c701                	beqz	a4,80004ff6 <exec+0x284>
    if(*s == '/')
    80004ff0:	fed71ce3          	bne	a4,a3,80004fe8 <exec+0x276>
    80004ff4:	bfc5                	j	80004fe4 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ff6:	4641                	li	a2,16
    80004ff8:	df843583          	ld	a1,-520(s0)
    80004ffc:	158a8513          	addi	a0,s5,344
    80005000:	ffffc097          	auipc	ra,0xffffc
    80005004:	e38080e7          	jalr	-456(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    80005008:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000500c:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005010:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005014:	058ab783          	ld	a5,88(s5)
    80005018:	e6843703          	ld	a4,-408(s0)
    8000501c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000501e:	058ab783          	ld	a5,88(s5)
    80005022:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005026:	85ea                	mv	a1,s10
    80005028:	ffffd097          	auipc	ra,0xffffd
    8000502c:	b08080e7          	jalr	-1272(ra) # 80001b30 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005030:	0004851b          	sext.w	a0,s1
    80005034:	bbd9                	j	80004e0a <exec+0x98>
    80005036:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000503a:	e0843583          	ld	a1,-504(s0)
    8000503e:	855e                	mv	a0,s7
    80005040:	ffffd097          	auipc	ra,0xffffd
    80005044:	af0080e7          	jalr	-1296(ra) # 80001b30 <proc_freepagetable>
  if(ip){
    80005048:	da0497e3          	bnez	s1,80004df6 <exec+0x84>
  return -1;
    8000504c:	557d                	li	a0,-1
    8000504e:	bb75                	j	80004e0a <exec+0x98>
    80005050:	e1443423          	sd	s4,-504(s0)
    80005054:	b7dd                	j	8000503a <exec+0x2c8>
    80005056:	e1443423          	sd	s4,-504(s0)
    8000505a:	b7c5                	j	8000503a <exec+0x2c8>
    8000505c:	e1443423          	sd	s4,-504(s0)
    80005060:	bfe9                	j	8000503a <exec+0x2c8>
    80005062:	e1443423          	sd	s4,-504(s0)
    80005066:	bfd1                	j	8000503a <exec+0x2c8>
  sz = sz1;
    80005068:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000506c:	4481                	li	s1,0
    8000506e:	b7f1                	j	8000503a <exec+0x2c8>
  sz = sz1;
    80005070:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005074:	4481                	li	s1,0
    80005076:	b7d1                	j	8000503a <exec+0x2c8>
  sz = sz1;
    80005078:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000507c:	4481                	li	s1,0
    8000507e:	bf75                	j	8000503a <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005080:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005084:	2b05                	addiw	s6,s6,1
    80005086:	0389899b          	addiw	s3,s3,56
    8000508a:	e8845783          	lhu	a5,-376(s0)
    8000508e:	e2fb57e3          	bge	s6,a5,80004ebc <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005092:	2981                	sext.w	s3,s3
    80005094:	03800713          	li	a4,56
    80005098:	86ce                	mv	a3,s3
    8000509a:	e1840613          	addi	a2,s0,-488
    8000509e:	4581                	li	a1,0
    800050a0:	8526                	mv	a0,s1
    800050a2:	fffff097          	auipc	ra,0xfffff
    800050a6:	a6e080e7          	jalr	-1426(ra) # 80003b10 <readi>
    800050aa:	03800793          	li	a5,56
    800050ae:	f8f514e3          	bne	a0,a5,80005036 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800050b2:	e1842783          	lw	a5,-488(s0)
    800050b6:	4705                	li	a4,1
    800050b8:	fce796e3          	bne	a5,a4,80005084 <exec+0x312>
    if(ph.memsz < ph.filesz)
    800050bc:	e4043903          	ld	s2,-448(s0)
    800050c0:	e3843783          	ld	a5,-456(s0)
    800050c4:	f8f966e3          	bltu	s2,a5,80005050 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050c8:	e2843783          	ld	a5,-472(s0)
    800050cc:	993e                	add	s2,s2,a5
    800050ce:	f8f964e3          	bltu	s2,a5,80005056 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800050d2:	df043703          	ld	a4,-528(s0)
    800050d6:	8ff9                	and	a5,a5,a4
    800050d8:	f3d1                	bnez	a5,8000505c <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050da:	e1c42503          	lw	a0,-484(s0)
    800050de:	00000097          	auipc	ra,0x0
    800050e2:	c78080e7          	jalr	-904(ra) # 80004d56 <flags2perm>
    800050e6:	86aa                	mv	a3,a0
    800050e8:	864a                	mv	a2,s2
    800050ea:	85d2                	mv	a1,s4
    800050ec:	855e                	mv	a0,s7
    800050ee:	ffffc097          	auipc	ra,0xffffc
    800050f2:	33e080e7          	jalr	830(ra) # 8000142c <uvmalloc>
    800050f6:	e0a43423          	sd	a0,-504(s0)
    800050fa:	d525                	beqz	a0,80005062 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050fc:	e2843d03          	ld	s10,-472(s0)
    80005100:	e2042d83          	lw	s11,-480(s0)
    80005104:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005108:	f60c0ce3          	beqz	s8,80005080 <exec+0x30e>
    8000510c:	8a62                	mv	s4,s8
    8000510e:	4901                	li	s2,0
    80005110:	b369                	j	80004e9a <exec+0x128>

0000000080005112 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005112:	7179                	addi	sp,sp,-48
    80005114:	f406                	sd	ra,40(sp)
    80005116:	f022                	sd	s0,32(sp)
    80005118:	ec26                	sd	s1,24(sp)
    8000511a:	e84a                	sd	s2,16(sp)
    8000511c:	1800                	addi	s0,sp,48
    8000511e:	892e                	mv	s2,a1
    80005120:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005122:	fdc40593          	addi	a1,s0,-36
    80005126:	ffffe097          	auipc	ra,0xffffe
    8000512a:	ae4080e7          	jalr	-1308(ra) # 80002c0a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000512e:	fdc42703          	lw	a4,-36(s0)
    80005132:	47bd                	li	a5,15
    80005134:	02e7eb63          	bltu	a5,a4,8000516a <argfd+0x58>
    80005138:	ffffd097          	auipc	ra,0xffffd
    8000513c:	898080e7          	jalr	-1896(ra) # 800019d0 <myproc>
    80005140:	fdc42703          	lw	a4,-36(s0)
    80005144:	01a70793          	addi	a5,a4,26
    80005148:	078e                	slli	a5,a5,0x3
    8000514a:	953e                	add	a0,a0,a5
    8000514c:	611c                	ld	a5,0(a0)
    8000514e:	c385                	beqz	a5,8000516e <argfd+0x5c>
    return -1;
  if(pfd)
    80005150:	00090463          	beqz	s2,80005158 <argfd+0x46>
    *pfd = fd;
    80005154:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005158:	4501                	li	a0,0
  if(pf)
    8000515a:	c091                	beqz	s1,8000515e <argfd+0x4c>
    *pf = f;
    8000515c:	e09c                	sd	a5,0(s1)
}
    8000515e:	70a2                	ld	ra,40(sp)
    80005160:	7402                	ld	s0,32(sp)
    80005162:	64e2                	ld	s1,24(sp)
    80005164:	6942                	ld	s2,16(sp)
    80005166:	6145                	addi	sp,sp,48
    80005168:	8082                	ret
    return -1;
    8000516a:	557d                	li	a0,-1
    8000516c:	bfcd                	j	8000515e <argfd+0x4c>
    8000516e:	557d                	li	a0,-1
    80005170:	b7fd                	j	8000515e <argfd+0x4c>

0000000080005172 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005172:	1101                	addi	sp,sp,-32
    80005174:	ec06                	sd	ra,24(sp)
    80005176:	e822                	sd	s0,16(sp)
    80005178:	e426                	sd	s1,8(sp)
    8000517a:	1000                	addi	s0,sp,32
    8000517c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000517e:	ffffd097          	auipc	ra,0xffffd
    80005182:	852080e7          	jalr	-1966(ra) # 800019d0 <myproc>
    80005186:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005188:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdd360>
    8000518c:	4501                	li	a0,0
    8000518e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005190:	6398                	ld	a4,0(a5)
    80005192:	cb19                	beqz	a4,800051a8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005194:	2505                	addiw	a0,a0,1
    80005196:	07a1                	addi	a5,a5,8
    80005198:	fed51ce3          	bne	a0,a3,80005190 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000519c:	557d                	li	a0,-1
}
    8000519e:	60e2                	ld	ra,24(sp)
    800051a0:	6442                	ld	s0,16(sp)
    800051a2:	64a2                	ld	s1,8(sp)
    800051a4:	6105                	addi	sp,sp,32
    800051a6:	8082                	ret
      p->ofile[fd] = f;
    800051a8:	01a50793          	addi	a5,a0,26
    800051ac:	078e                	slli	a5,a5,0x3
    800051ae:	963e                	add	a2,a2,a5
    800051b0:	e204                	sd	s1,0(a2)
      return fd;
    800051b2:	b7f5                	j	8000519e <fdalloc+0x2c>

00000000800051b4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051b4:	715d                	addi	sp,sp,-80
    800051b6:	e486                	sd	ra,72(sp)
    800051b8:	e0a2                	sd	s0,64(sp)
    800051ba:	fc26                	sd	s1,56(sp)
    800051bc:	f84a                	sd	s2,48(sp)
    800051be:	f44e                	sd	s3,40(sp)
    800051c0:	f052                	sd	s4,32(sp)
    800051c2:	ec56                	sd	s5,24(sp)
    800051c4:	e85a                	sd	s6,16(sp)
    800051c6:	0880                	addi	s0,sp,80
    800051c8:	8b2e                	mv	s6,a1
    800051ca:	89b2                	mv	s3,a2
    800051cc:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800051ce:	fb040593          	addi	a1,s0,-80
    800051d2:	fffff097          	auipc	ra,0xfffff
    800051d6:	e4e080e7          	jalr	-434(ra) # 80004020 <nameiparent>
    800051da:	84aa                	mv	s1,a0
    800051dc:	16050063          	beqz	a0,8000533c <create+0x188>
    return 0;

  ilock(dp);
    800051e0:	ffffe097          	auipc	ra,0xffffe
    800051e4:	67c080e7          	jalr	1660(ra) # 8000385c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051e8:	4601                	li	a2,0
    800051ea:	fb040593          	addi	a1,s0,-80
    800051ee:	8526                	mv	a0,s1
    800051f0:	fffff097          	auipc	ra,0xfffff
    800051f4:	b50080e7          	jalr	-1200(ra) # 80003d40 <dirlookup>
    800051f8:	8aaa                	mv	s5,a0
    800051fa:	c931                	beqz	a0,8000524e <create+0x9a>
    iunlockput(dp);
    800051fc:	8526                	mv	a0,s1
    800051fe:	fffff097          	auipc	ra,0xfffff
    80005202:	8c0080e7          	jalr	-1856(ra) # 80003abe <iunlockput>
    ilock(ip);
    80005206:	8556                	mv	a0,s5
    80005208:	ffffe097          	auipc	ra,0xffffe
    8000520c:	654080e7          	jalr	1620(ra) # 8000385c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005210:	000b059b          	sext.w	a1,s6
    80005214:	4789                	li	a5,2
    80005216:	02f59563          	bne	a1,a5,80005240 <create+0x8c>
    8000521a:	044ad783          	lhu	a5,68(s5)
    8000521e:	37f9                	addiw	a5,a5,-2
    80005220:	17c2                	slli	a5,a5,0x30
    80005222:	93c1                	srli	a5,a5,0x30
    80005224:	4705                	li	a4,1
    80005226:	00f76d63          	bltu	a4,a5,80005240 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000522a:	8556                	mv	a0,s5
    8000522c:	60a6                	ld	ra,72(sp)
    8000522e:	6406                	ld	s0,64(sp)
    80005230:	74e2                	ld	s1,56(sp)
    80005232:	7942                	ld	s2,48(sp)
    80005234:	79a2                	ld	s3,40(sp)
    80005236:	7a02                	ld	s4,32(sp)
    80005238:	6ae2                	ld	s5,24(sp)
    8000523a:	6b42                	ld	s6,16(sp)
    8000523c:	6161                	addi	sp,sp,80
    8000523e:	8082                	ret
    iunlockput(ip);
    80005240:	8556                	mv	a0,s5
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	87c080e7          	jalr	-1924(ra) # 80003abe <iunlockput>
    return 0;
    8000524a:	4a81                	li	s5,0
    8000524c:	bff9                	j	8000522a <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000524e:	85da                	mv	a1,s6
    80005250:	4088                	lw	a0,0(s1)
    80005252:	ffffe097          	auipc	ra,0xffffe
    80005256:	46e080e7          	jalr	1134(ra) # 800036c0 <ialloc>
    8000525a:	8a2a                	mv	s4,a0
    8000525c:	c921                	beqz	a0,800052ac <create+0xf8>
  ilock(ip);
    8000525e:	ffffe097          	auipc	ra,0xffffe
    80005262:	5fe080e7          	jalr	1534(ra) # 8000385c <ilock>
  ip->major = major;
    80005266:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000526a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000526e:	4785                	li	a5,1
    80005270:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005274:	8552                	mv	a0,s4
    80005276:	ffffe097          	auipc	ra,0xffffe
    8000527a:	51c080e7          	jalr	1308(ra) # 80003792 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000527e:	000b059b          	sext.w	a1,s6
    80005282:	4785                	li	a5,1
    80005284:	02f58b63          	beq	a1,a5,800052ba <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005288:	004a2603          	lw	a2,4(s4)
    8000528c:	fb040593          	addi	a1,s0,-80
    80005290:	8526                	mv	a0,s1
    80005292:	fffff097          	auipc	ra,0xfffff
    80005296:	cbe080e7          	jalr	-834(ra) # 80003f50 <dirlink>
    8000529a:	06054f63          	bltz	a0,80005318 <create+0x164>
  iunlockput(dp);
    8000529e:	8526                	mv	a0,s1
    800052a0:	fffff097          	auipc	ra,0xfffff
    800052a4:	81e080e7          	jalr	-2018(ra) # 80003abe <iunlockput>
  return ip;
    800052a8:	8ad2                	mv	s5,s4
    800052aa:	b741                	j	8000522a <create+0x76>
    iunlockput(dp);
    800052ac:	8526                	mv	a0,s1
    800052ae:	fffff097          	auipc	ra,0xfffff
    800052b2:	810080e7          	jalr	-2032(ra) # 80003abe <iunlockput>
    return 0;
    800052b6:	8ad2                	mv	s5,s4
    800052b8:	bf8d                	j	8000522a <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052ba:	004a2603          	lw	a2,4(s4)
    800052be:	00003597          	auipc	a1,0x3
    800052c2:	44258593          	addi	a1,a1,1090 # 80008700 <syscalls+0x2b0>
    800052c6:	8552                	mv	a0,s4
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	c88080e7          	jalr	-888(ra) # 80003f50 <dirlink>
    800052d0:	04054463          	bltz	a0,80005318 <create+0x164>
    800052d4:	40d0                	lw	a2,4(s1)
    800052d6:	00003597          	auipc	a1,0x3
    800052da:	43258593          	addi	a1,a1,1074 # 80008708 <syscalls+0x2b8>
    800052de:	8552                	mv	a0,s4
    800052e0:	fffff097          	auipc	ra,0xfffff
    800052e4:	c70080e7          	jalr	-912(ra) # 80003f50 <dirlink>
    800052e8:	02054863          	bltz	a0,80005318 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800052ec:	004a2603          	lw	a2,4(s4)
    800052f0:	fb040593          	addi	a1,s0,-80
    800052f4:	8526                	mv	a0,s1
    800052f6:	fffff097          	auipc	ra,0xfffff
    800052fa:	c5a080e7          	jalr	-934(ra) # 80003f50 <dirlink>
    800052fe:	00054d63          	bltz	a0,80005318 <create+0x164>
    dp->nlink++;  // for ".."
    80005302:	04a4d783          	lhu	a5,74(s1)
    80005306:	2785                	addiw	a5,a5,1
    80005308:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000530c:	8526                	mv	a0,s1
    8000530e:	ffffe097          	auipc	ra,0xffffe
    80005312:	484080e7          	jalr	1156(ra) # 80003792 <iupdate>
    80005316:	b761                	j	8000529e <create+0xea>
  ip->nlink = 0;
    80005318:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000531c:	8552                	mv	a0,s4
    8000531e:	ffffe097          	auipc	ra,0xffffe
    80005322:	474080e7          	jalr	1140(ra) # 80003792 <iupdate>
  iunlockput(ip);
    80005326:	8552                	mv	a0,s4
    80005328:	ffffe097          	auipc	ra,0xffffe
    8000532c:	796080e7          	jalr	1942(ra) # 80003abe <iunlockput>
  iunlockput(dp);
    80005330:	8526                	mv	a0,s1
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	78c080e7          	jalr	1932(ra) # 80003abe <iunlockput>
  return 0;
    8000533a:	bdc5                	j	8000522a <create+0x76>
    return 0;
    8000533c:	8aaa                	mv	s5,a0
    8000533e:	b5f5                	j	8000522a <create+0x76>

0000000080005340 <sys_dup>:
{
    80005340:	7179                	addi	sp,sp,-48
    80005342:	f406                	sd	ra,40(sp)
    80005344:	f022                	sd	s0,32(sp)
    80005346:	ec26                	sd	s1,24(sp)
    80005348:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000534a:	fd840613          	addi	a2,s0,-40
    8000534e:	4581                	li	a1,0
    80005350:	4501                	li	a0,0
    80005352:	00000097          	auipc	ra,0x0
    80005356:	dc0080e7          	jalr	-576(ra) # 80005112 <argfd>
    return -1;
    8000535a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000535c:	02054363          	bltz	a0,80005382 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005360:	fd843503          	ld	a0,-40(s0)
    80005364:	00000097          	auipc	ra,0x0
    80005368:	e0e080e7          	jalr	-498(ra) # 80005172 <fdalloc>
    8000536c:	84aa                	mv	s1,a0
    return -1;
    8000536e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005370:	00054963          	bltz	a0,80005382 <sys_dup+0x42>
  filedup(f);
    80005374:	fd843503          	ld	a0,-40(s0)
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	320080e7          	jalr	800(ra) # 80004698 <filedup>
  return fd;
    80005380:	87a6                	mv	a5,s1
}
    80005382:	853e                	mv	a0,a5
    80005384:	70a2                	ld	ra,40(sp)
    80005386:	7402                	ld	s0,32(sp)
    80005388:	64e2                	ld	s1,24(sp)
    8000538a:	6145                	addi	sp,sp,48
    8000538c:	8082                	ret

000000008000538e <sys_read>:
{
    8000538e:	7179                	addi	sp,sp,-48
    80005390:	f406                	sd	ra,40(sp)
    80005392:	f022                	sd	s0,32(sp)
    80005394:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005396:	fd840593          	addi	a1,s0,-40
    8000539a:	4505                	li	a0,1
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	88e080e7          	jalr	-1906(ra) # 80002c2a <argaddr>
  argint(2, &n);
    800053a4:	fe440593          	addi	a1,s0,-28
    800053a8:	4509                	li	a0,2
    800053aa:	ffffe097          	auipc	ra,0xffffe
    800053ae:	860080e7          	jalr	-1952(ra) # 80002c0a <argint>
  if(argfd(0, 0, &f) < 0)
    800053b2:	fe840613          	addi	a2,s0,-24
    800053b6:	4581                	li	a1,0
    800053b8:	4501                	li	a0,0
    800053ba:	00000097          	auipc	ra,0x0
    800053be:	d58080e7          	jalr	-680(ra) # 80005112 <argfd>
    800053c2:	87aa                	mv	a5,a0
    return -1;
    800053c4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053c6:	0007cc63          	bltz	a5,800053de <sys_read+0x50>
  return fileread(f, p, n);
    800053ca:	fe442603          	lw	a2,-28(s0)
    800053ce:	fd843583          	ld	a1,-40(s0)
    800053d2:	fe843503          	ld	a0,-24(s0)
    800053d6:	fffff097          	auipc	ra,0xfffff
    800053da:	44e080e7          	jalr	1102(ra) # 80004824 <fileread>
}
    800053de:	70a2                	ld	ra,40(sp)
    800053e0:	7402                	ld	s0,32(sp)
    800053e2:	6145                	addi	sp,sp,48
    800053e4:	8082                	ret

00000000800053e6 <sys_write>:
{
    800053e6:	7179                	addi	sp,sp,-48
    800053e8:	f406                	sd	ra,40(sp)
    800053ea:	f022                	sd	s0,32(sp)
    800053ec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053ee:	fd840593          	addi	a1,s0,-40
    800053f2:	4505                	li	a0,1
    800053f4:	ffffe097          	auipc	ra,0xffffe
    800053f8:	836080e7          	jalr	-1994(ra) # 80002c2a <argaddr>
  argint(2, &n);
    800053fc:	fe440593          	addi	a1,s0,-28
    80005400:	4509                	li	a0,2
    80005402:	ffffe097          	auipc	ra,0xffffe
    80005406:	808080e7          	jalr	-2040(ra) # 80002c0a <argint>
  if(argfd(0, 0, &f) < 0)
    8000540a:	fe840613          	addi	a2,s0,-24
    8000540e:	4581                	li	a1,0
    80005410:	4501                	li	a0,0
    80005412:	00000097          	auipc	ra,0x0
    80005416:	d00080e7          	jalr	-768(ra) # 80005112 <argfd>
    8000541a:	87aa                	mv	a5,a0
    return -1;
    8000541c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000541e:	0007cc63          	bltz	a5,80005436 <sys_write+0x50>
  return filewrite(f, p, n);
    80005422:	fe442603          	lw	a2,-28(s0)
    80005426:	fd843583          	ld	a1,-40(s0)
    8000542a:	fe843503          	ld	a0,-24(s0)
    8000542e:	fffff097          	auipc	ra,0xfffff
    80005432:	4b8080e7          	jalr	1208(ra) # 800048e6 <filewrite>
}
    80005436:	70a2                	ld	ra,40(sp)
    80005438:	7402                	ld	s0,32(sp)
    8000543a:	6145                	addi	sp,sp,48
    8000543c:	8082                	ret

000000008000543e <sys_close>:
{
    8000543e:	1101                	addi	sp,sp,-32
    80005440:	ec06                	sd	ra,24(sp)
    80005442:	e822                	sd	s0,16(sp)
    80005444:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005446:	fe040613          	addi	a2,s0,-32
    8000544a:	fec40593          	addi	a1,s0,-20
    8000544e:	4501                	li	a0,0
    80005450:	00000097          	auipc	ra,0x0
    80005454:	cc2080e7          	jalr	-830(ra) # 80005112 <argfd>
    return -1;
    80005458:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000545a:	02054463          	bltz	a0,80005482 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000545e:	ffffc097          	auipc	ra,0xffffc
    80005462:	572080e7          	jalr	1394(ra) # 800019d0 <myproc>
    80005466:	fec42783          	lw	a5,-20(s0)
    8000546a:	07e9                	addi	a5,a5,26
    8000546c:	078e                	slli	a5,a5,0x3
    8000546e:	97aa                	add	a5,a5,a0
    80005470:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005474:	fe043503          	ld	a0,-32(s0)
    80005478:	fffff097          	auipc	ra,0xfffff
    8000547c:	272080e7          	jalr	626(ra) # 800046ea <fileclose>
  return 0;
    80005480:	4781                	li	a5,0
}
    80005482:	853e                	mv	a0,a5
    80005484:	60e2                	ld	ra,24(sp)
    80005486:	6442                	ld	s0,16(sp)
    80005488:	6105                	addi	sp,sp,32
    8000548a:	8082                	ret

000000008000548c <sys_fstat>:
{
    8000548c:	1101                	addi	sp,sp,-32
    8000548e:	ec06                	sd	ra,24(sp)
    80005490:	e822                	sd	s0,16(sp)
    80005492:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005494:	fe040593          	addi	a1,s0,-32
    80005498:	4505                	li	a0,1
    8000549a:	ffffd097          	auipc	ra,0xffffd
    8000549e:	790080e7          	jalr	1936(ra) # 80002c2a <argaddr>
  if(argfd(0, 0, &f) < 0)
    800054a2:	fe840613          	addi	a2,s0,-24
    800054a6:	4581                	li	a1,0
    800054a8:	4501                	li	a0,0
    800054aa:	00000097          	auipc	ra,0x0
    800054ae:	c68080e7          	jalr	-920(ra) # 80005112 <argfd>
    800054b2:	87aa                	mv	a5,a0
    return -1;
    800054b4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054b6:	0007ca63          	bltz	a5,800054ca <sys_fstat+0x3e>
  return filestat(f, st);
    800054ba:	fe043583          	ld	a1,-32(s0)
    800054be:	fe843503          	ld	a0,-24(s0)
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	2f0080e7          	jalr	752(ra) # 800047b2 <filestat>
}
    800054ca:	60e2                	ld	ra,24(sp)
    800054cc:	6442                	ld	s0,16(sp)
    800054ce:	6105                	addi	sp,sp,32
    800054d0:	8082                	ret

00000000800054d2 <sys_link>:
{
    800054d2:	7169                	addi	sp,sp,-304
    800054d4:	f606                	sd	ra,296(sp)
    800054d6:	f222                	sd	s0,288(sp)
    800054d8:	ee26                	sd	s1,280(sp)
    800054da:	ea4a                	sd	s2,272(sp)
    800054dc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054de:	08000613          	li	a2,128
    800054e2:	ed040593          	addi	a1,s0,-304
    800054e6:	4501                	li	a0,0
    800054e8:	ffffd097          	auipc	ra,0xffffd
    800054ec:	762080e7          	jalr	1890(ra) # 80002c4a <argstr>
    return -1;
    800054f0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054f2:	10054e63          	bltz	a0,8000560e <sys_link+0x13c>
    800054f6:	08000613          	li	a2,128
    800054fa:	f5040593          	addi	a1,s0,-176
    800054fe:	4505                	li	a0,1
    80005500:	ffffd097          	auipc	ra,0xffffd
    80005504:	74a080e7          	jalr	1866(ra) # 80002c4a <argstr>
    return -1;
    80005508:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000550a:	10054263          	bltz	a0,8000560e <sys_link+0x13c>
  begin_op();
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	d10080e7          	jalr	-752(ra) # 8000421e <begin_op>
  if((ip = namei(old)) == 0){
    80005516:	ed040513          	addi	a0,s0,-304
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	ae8080e7          	jalr	-1304(ra) # 80004002 <namei>
    80005522:	84aa                	mv	s1,a0
    80005524:	c551                	beqz	a0,800055b0 <sys_link+0xde>
  ilock(ip);
    80005526:	ffffe097          	auipc	ra,0xffffe
    8000552a:	336080e7          	jalr	822(ra) # 8000385c <ilock>
  if(ip->type == T_DIR){
    8000552e:	04449703          	lh	a4,68(s1)
    80005532:	4785                	li	a5,1
    80005534:	08f70463          	beq	a4,a5,800055bc <sys_link+0xea>
  ip->nlink++;
    80005538:	04a4d783          	lhu	a5,74(s1)
    8000553c:	2785                	addiw	a5,a5,1
    8000553e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005542:	8526                	mv	a0,s1
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	24e080e7          	jalr	590(ra) # 80003792 <iupdate>
  iunlock(ip);
    8000554c:	8526                	mv	a0,s1
    8000554e:	ffffe097          	auipc	ra,0xffffe
    80005552:	3d0080e7          	jalr	976(ra) # 8000391e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005556:	fd040593          	addi	a1,s0,-48
    8000555a:	f5040513          	addi	a0,s0,-176
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	ac2080e7          	jalr	-1342(ra) # 80004020 <nameiparent>
    80005566:	892a                	mv	s2,a0
    80005568:	c935                	beqz	a0,800055dc <sys_link+0x10a>
  ilock(dp);
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	2f2080e7          	jalr	754(ra) # 8000385c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005572:	00092703          	lw	a4,0(s2)
    80005576:	409c                	lw	a5,0(s1)
    80005578:	04f71d63          	bne	a4,a5,800055d2 <sys_link+0x100>
    8000557c:	40d0                	lw	a2,4(s1)
    8000557e:	fd040593          	addi	a1,s0,-48
    80005582:	854a                	mv	a0,s2
    80005584:	fffff097          	auipc	ra,0xfffff
    80005588:	9cc080e7          	jalr	-1588(ra) # 80003f50 <dirlink>
    8000558c:	04054363          	bltz	a0,800055d2 <sys_link+0x100>
  iunlockput(dp);
    80005590:	854a                	mv	a0,s2
    80005592:	ffffe097          	auipc	ra,0xffffe
    80005596:	52c080e7          	jalr	1324(ra) # 80003abe <iunlockput>
  iput(ip);
    8000559a:	8526                	mv	a0,s1
    8000559c:	ffffe097          	auipc	ra,0xffffe
    800055a0:	47a080e7          	jalr	1146(ra) # 80003a16 <iput>
  end_op();
    800055a4:	fffff097          	auipc	ra,0xfffff
    800055a8:	cfa080e7          	jalr	-774(ra) # 8000429e <end_op>
  return 0;
    800055ac:	4781                	li	a5,0
    800055ae:	a085                	j	8000560e <sys_link+0x13c>
    end_op();
    800055b0:	fffff097          	auipc	ra,0xfffff
    800055b4:	cee080e7          	jalr	-786(ra) # 8000429e <end_op>
    return -1;
    800055b8:	57fd                	li	a5,-1
    800055ba:	a891                	j	8000560e <sys_link+0x13c>
    iunlockput(ip);
    800055bc:	8526                	mv	a0,s1
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	500080e7          	jalr	1280(ra) # 80003abe <iunlockput>
    end_op();
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	cd8080e7          	jalr	-808(ra) # 8000429e <end_op>
    return -1;
    800055ce:	57fd                	li	a5,-1
    800055d0:	a83d                	j	8000560e <sys_link+0x13c>
    iunlockput(dp);
    800055d2:	854a                	mv	a0,s2
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	4ea080e7          	jalr	1258(ra) # 80003abe <iunlockput>
  ilock(ip);
    800055dc:	8526                	mv	a0,s1
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	27e080e7          	jalr	638(ra) # 8000385c <ilock>
  ip->nlink--;
    800055e6:	04a4d783          	lhu	a5,74(s1)
    800055ea:	37fd                	addiw	a5,a5,-1
    800055ec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055f0:	8526                	mv	a0,s1
    800055f2:	ffffe097          	auipc	ra,0xffffe
    800055f6:	1a0080e7          	jalr	416(ra) # 80003792 <iupdate>
  iunlockput(ip);
    800055fa:	8526                	mv	a0,s1
    800055fc:	ffffe097          	auipc	ra,0xffffe
    80005600:	4c2080e7          	jalr	1218(ra) # 80003abe <iunlockput>
  end_op();
    80005604:	fffff097          	auipc	ra,0xfffff
    80005608:	c9a080e7          	jalr	-870(ra) # 8000429e <end_op>
  return -1;
    8000560c:	57fd                	li	a5,-1
}
    8000560e:	853e                	mv	a0,a5
    80005610:	70b2                	ld	ra,296(sp)
    80005612:	7412                	ld	s0,288(sp)
    80005614:	64f2                	ld	s1,280(sp)
    80005616:	6952                	ld	s2,272(sp)
    80005618:	6155                	addi	sp,sp,304
    8000561a:	8082                	ret

000000008000561c <sys_unlink>:
{
    8000561c:	7151                	addi	sp,sp,-240
    8000561e:	f586                	sd	ra,232(sp)
    80005620:	f1a2                	sd	s0,224(sp)
    80005622:	eda6                	sd	s1,216(sp)
    80005624:	e9ca                	sd	s2,208(sp)
    80005626:	e5ce                	sd	s3,200(sp)
    80005628:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000562a:	08000613          	li	a2,128
    8000562e:	f3040593          	addi	a1,s0,-208
    80005632:	4501                	li	a0,0
    80005634:	ffffd097          	auipc	ra,0xffffd
    80005638:	616080e7          	jalr	1558(ra) # 80002c4a <argstr>
    8000563c:	18054163          	bltz	a0,800057be <sys_unlink+0x1a2>
  begin_op();
    80005640:	fffff097          	auipc	ra,0xfffff
    80005644:	bde080e7          	jalr	-1058(ra) # 8000421e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005648:	fb040593          	addi	a1,s0,-80
    8000564c:	f3040513          	addi	a0,s0,-208
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	9d0080e7          	jalr	-1584(ra) # 80004020 <nameiparent>
    80005658:	84aa                	mv	s1,a0
    8000565a:	c979                	beqz	a0,80005730 <sys_unlink+0x114>
  ilock(dp);
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	200080e7          	jalr	512(ra) # 8000385c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005664:	00003597          	auipc	a1,0x3
    80005668:	09c58593          	addi	a1,a1,156 # 80008700 <syscalls+0x2b0>
    8000566c:	fb040513          	addi	a0,s0,-80
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	6b6080e7          	jalr	1718(ra) # 80003d26 <namecmp>
    80005678:	14050a63          	beqz	a0,800057cc <sys_unlink+0x1b0>
    8000567c:	00003597          	auipc	a1,0x3
    80005680:	08c58593          	addi	a1,a1,140 # 80008708 <syscalls+0x2b8>
    80005684:	fb040513          	addi	a0,s0,-80
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	69e080e7          	jalr	1694(ra) # 80003d26 <namecmp>
    80005690:	12050e63          	beqz	a0,800057cc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005694:	f2c40613          	addi	a2,s0,-212
    80005698:	fb040593          	addi	a1,s0,-80
    8000569c:	8526                	mv	a0,s1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	6a2080e7          	jalr	1698(ra) # 80003d40 <dirlookup>
    800056a6:	892a                	mv	s2,a0
    800056a8:	12050263          	beqz	a0,800057cc <sys_unlink+0x1b0>
  ilock(ip);
    800056ac:	ffffe097          	auipc	ra,0xffffe
    800056b0:	1b0080e7          	jalr	432(ra) # 8000385c <ilock>
  if(ip->nlink < 1)
    800056b4:	04a91783          	lh	a5,74(s2)
    800056b8:	08f05263          	blez	a5,8000573c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800056bc:	04491703          	lh	a4,68(s2)
    800056c0:	4785                	li	a5,1
    800056c2:	08f70563          	beq	a4,a5,8000574c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800056c6:	4641                	li	a2,16
    800056c8:	4581                	li	a1,0
    800056ca:	fc040513          	addi	a0,s0,-64
    800056ce:	ffffb097          	auipc	ra,0xffffb
    800056d2:	618080e7          	jalr	1560(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056d6:	4741                	li	a4,16
    800056d8:	f2c42683          	lw	a3,-212(s0)
    800056dc:	fc040613          	addi	a2,s0,-64
    800056e0:	4581                	li	a1,0
    800056e2:	8526                	mv	a0,s1
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	524080e7          	jalr	1316(ra) # 80003c08 <writei>
    800056ec:	47c1                	li	a5,16
    800056ee:	0af51563          	bne	a0,a5,80005798 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056f2:	04491703          	lh	a4,68(s2)
    800056f6:	4785                	li	a5,1
    800056f8:	0af70863          	beq	a4,a5,800057a8 <sys_unlink+0x18c>
  iunlockput(dp);
    800056fc:	8526                	mv	a0,s1
    800056fe:	ffffe097          	auipc	ra,0xffffe
    80005702:	3c0080e7          	jalr	960(ra) # 80003abe <iunlockput>
  ip->nlink--;
    80005706:	04a95783          	lhu	a5,74(s2)
    8000570a:	37fd                	addiw	a5,a5,-1
    8000570c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005710:	854a                	mv	a0,s2
    80005712:	ffffe097          	auipc	ra,0xffffe
    80005716:	080080e7          	jalr	128(ra) # 80003792 <iupdate>
  iunlockput(ip);
    8000571a:	854a                	mv	a0,s2
    8000571c:	ffffe097          	auipc	ra,0xffffe
    80005720:	3a2080e7          	jalr	930(ra) # 80003abe <iunlockput>
  end_op();
    80005724:	fffff097          	auipc	ra,0xfffff
    80005728:	b7a080e7          	jalr	-1158(ra) # 8000429e <end_op>
  return 0;
    8000572c:	4501                	li	a0,0
    8000572e:	a84d                	j	800057e0 <sys_unlink+0x1c4>
    end_op();
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	b6e080e7          	jalr	-1170(ra) # 8000429e <end_op>
    return -1;
    80005738:	557d                	li	a0,-1
    8000573a:	a05d                	j	800057e0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000573c:	00003517          	auipc	a0,0x3
    80005740:	fd450513          	addi	a0,a0,-44 # 80008710 <syscalls+0x2c0>
    80005744:	ffffb097          	auipc	ra,0xffffb
    80005748:	e00080e7          	jalr	-512(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000574c:	04c92703          	lw	a4,76(s2)
    80005750:	02000793          	li	a5,32
    80005754:	f6e7f9e3          	bgeu	a5,a4,800056c6 <sys_unlink+0xaa>
    80005758:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000575c:	4741                	li	a4,16
    8000575e:	86ce                	mv	a3,s3
    80005760:	f1840613          	addi	a2,s0,-232
    80005764:	4581                	li	a1,0
    80005766:	854a                	mv	a0,s2
    80005768:	ffffe097          	auipc	ra,0xffffe
    8000576c:	3a8080e7          	jalr	936(ra) # 80003b10 <readi>
    80005770:	47c1                	li	a5,16
    80005772:	00f51b63          	bne	a0,a5,80005788 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005776:	f1845783          	lhu	a5,-232(s0)
    8000577a:	e7a1                	bnez	a5,800057c2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000577c:	29c1                	addiw	s3,s3,16
    8000577e:	04c92783          	lw	a5,76(s2)
    80005782:	fcf9ede3          	bltu	s3,a5,8000575c <sys_unlink+0x140>
    80005786:	b781                	j	800056c6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005788:	00003517          	auipc	a0,0x3
    8000578c:	fa050513          	addi	a0,a0,-96 # 80008728 <syscalls+0x2d8>
    80005790:	ffffb097          	auipc	ra,0xffffb
    80005794:	db4080e7          	jalr	-588(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005798:	00003517          	auipc	a0,0x3
    8000579c:	fa850513          	addi	a0,a0,-88 # 80008740 <syscalls+0x2f0>
    800057a0:	ffffb097          	auipc	ra,0xffffb
    800057a4:	da4080e7          	jalr	-604(ra) # 80000544 <panic>
    dp->nlink--;
    800057a8:	04a4d783          	lhu	a5,74(s1)
    800057ac:	37fd                	addiw	a5,a5,-1
    800057ae:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057b2:	8526                	mv	a0,s1
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	fde080e7          	jalr	-34(ra) # 80003792 <iupdate>
    800057bc:	b781                	j	800056fc <sys_unlink+0xe0>
    return -1;
    800057be:	557d                	li	a0,-1
    800057c0:	a005                	j	800057e0 <sys_unlink+0x1c4>
    iunlockput(ip);
    800057c2:	854a                	mv	a0,s2
    800057c4:	ffffe097          	auipc	ra,0xffffe
    800057c8:	2fa080e7          	jalr	762(ra) # 80003abe <iunlockput>
  iunlockput(dp);
    800057cc:	8526                	mv	a0,s1
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	2f0080e7          	jalr	752(ra) # 80003abe <iunlockput>
  end_op();
    800057d6:	fffff097          	auipc	ra,0xfffff
    800057da:	ac8080e7          	jalr	-1336(ra) # 8000429e <end_op>
  return -1;
    800057de:	557d                	li	a0,-1
}
    800057e0:	70ae                	ld	ra,232(sp)
    800057e2:	740e                	ld	s0,224(sp)
    800057e4:	64ee                	ld	s1,216(sp)
    800057e6:	694e                	ld	s2,208(sp)
    800057e8:	69ae                	ld	s3,200(sp)
    800057ea:	616d                	addi	sp,sp,240
    800057ec:	8082                	ret

00000000800057ee <sys_open>:

uint64
sys_open(void)
{
    800057ee:	7131                	addi	sp,sp,-192
    800057f0:	fd06                	sd	ra,184(sp)
    800057f2:	f922                	sd	s0,176(sp)
    800057f4:	f526                	sd	s1,168(sp)
    800057f6:	f14a                	sd	s2,160(sp)
    800057f8:	ed4e                	sd	s3,152(sp)
    800057fa:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800057fc:	f4c40593          	addi	a1,s0,-180
    80005800:	4505                	li	a0,1
    80005802:	ffffd097          	auipc	ra,0xffffd
    80005806:	408080e7          	jalr	1032(ra) # 80002c0a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000580a:	08000613          	li	a2,128
    8000580e:	f5040593          	addi	a1,s0,-176
    80005812:	4501                	li	a0,0
    80005814:	ffffd097          	auipc	ra,0xffffd
    80005818:	436080e7          	jalr	1078(ra) # 80002c4a <argstr>
    8000581c:	87aa                	mv	a5,a0
    return -1;
    8000581e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005820:	0a07c963          	bltz	a5,800058d2 <sys_open+0xe4>

  begin_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	9fa080e7          	jalr	-1542(ra) # 8000421e <begin_op>

  if(omode & O_CREATE){
    8000582c:	f4c42783          	lw	a5,-180(s0)
    80005830:	2007f793          	andi	a5,a5,512
    80005834:	cfc5                	beqz	a5,800058ec <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005836:	4681                	li	a3,0
    80005838:	4601                	li	a2,0
    8000583a:	4589                	li	a1,2
    8000583c:	f5040513          	addi	a0,s0,-176
    80005840:	00000097          	auipc	ra,0x0
    80005844:	974080e7          	jalr	-1676(ra) # 800051b4 <create>
    80005848:	84aa                	mv	s1,a0
    if(ip == 0){
    8000584a:	c959                	beqz	a0,800058e0 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000584c:	04449703          	lh	a4,68(s1)
    80005850:	478d                	li	a5,3
    80005852:	00f71763          	bne	a4,a5,80005860 <sys_open+0x72>
    80005856:	0464d703          	lhu	a4,70(s1)
    8000585a:	47a5                	li	a5,9
    8000585c:	0ce7ed63          	bltu	a5,a4,80005936 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005860:	fffff097          	auipc	ra,0xfffff
    80005864:	dce080e7          	jalr	-562(ra) # 8000462e <filealloc>
    80005868:	89aa                	mv	s3,a0
    8000586a:	10050363          	beqz	a0,80005970 <sys_open+0x182>
    8000586e:	00000097          	auipc	ra,0x0
    80005872:	904080e7          	jalr	-1788(ra) # 80005172 <fdalloc>
    80005876:	892a                	mv	s2,a0
    80005878:	0e054763          	bltz	a0,80005966 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000587c:	04449703          	lh	a4,68(s1)
    80005880:	478d                	li	a5,3
    80005882:	0cf70563          	beq	a4,a5,8000594c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005886:	4789                	li	a5,2
    80005888:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000588c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005890:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005894:	f4c42783          	lw	a5,-180(s0)
    80005898:	0017c713          	xori	a4,a5,1
    8000589c:	8b05                	andi	a4,a4,1
    8000589e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058a2:	0037f713          	andi	a4,a5,3
    800058a6:	00e03733          	snez	a4,a4
    800058aa:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058ae:	4007f793          	andi	a5,a5,1024
    800058b2:	c791                	beqz	a5,800058be <sys_open+0xd0>
    800058b4:	04449703          	lh	a4,68(s1)
    800058b8:	4789                	li	a5,2
    800058ba:	0af70063          	beq	a4,a5,8000595a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800058be:	8526                	mv	a0,s1
    800058c0:	ffffe097          	auipc	ra,0xffffe
    800058c4:	05e080e7          	jalr	94(ra) # 8000391e <iunlock>
  end_op();
    800058c8:	fffff097          	auipc	ra,0xfffff
    800058cc:	9d6080e7          	jalr	-1578(ra) # 8000429e <end_op>

  return fd;
    800058d0:	854a                	mv	a0,s2
}
    800058d2:	70ea                	ld	ra,184(sp)
    800058d4:	744a                	ld	s0,176(sp)
    800058d6:	74aa                	ld	s1,168(sp)
    800058d8:	790a                	ld	s2,160(sp)
    800058da:	69ea                	ld	s3,152(sp)
    800058dc:	6129                	addi	sp,sp,192
    800058de:	8082                	ret
      end_op();
    800058e0:	fffff097          	auipc	ra,0xfffff
    800058e4:	9be080e7          	jalr	-1602(ra) # 8000429e <end_op>
      return -1;
    800058e8:	557d                	li	a0,-1
    800058ea:	b7e5                	j	800058d2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800058ec:	f5040513          	addi	a0,s0,-176
    800058f0:	ffffe097          	auipc	ra,0xffffe
    800058f4:	712080e7          	jalr	1810(ra) # 80004002 <namei>
    800058f8:	84aa                	mv	s1,a0
    800058fa:	c905                	beqz	a0,8000592a <sys_open+0x13c>
    ilock(ip);
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	f60080e7          	jalr	-160(ra) # 8000385c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005904:	04449703          	lh	a4,68(s1)
    80005908:	4785                	li	a5,1
    8000590a:	f4f711e3          	bne	a4,a5,8000584c <sys_open+0x5e>
    8000590e:	f4c42783          	lw	a5,-180(s0)
    80005912:	d7b9                	beqz	a5,80005860 <sys_open+0x72>
      iunlockput(ip);
    80005914:	8526                	mv	a0,s1
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	1a8080e7          	jalr	424(ra) # 80003abe <iunlockput>
      end_op();
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	980080e7          	jalr	-1664(ra) # 8000429e <end_op>
      return -1;
    80005926:	557d                	li	a0,-1
    80005928:	b76d                	j	800058d2 <sys_open+0xe4>
      end_op();
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	974080e7          	jalr	-1676(ra) # 8000429e <end_op>
      return -1;
    80005932:	557d                	li	a0,-1
    80005934:	bf79                	j	800058d2 <sys_open+0xe4>
    iunlockput(ip);
    80005936:	8526                	mv	a0,s1
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	186080e7          	jalr	390(ra) # 80003abe <iunlockput>
    end_op();
    80005940:	fffff097          	auipc	ra,0xfffff
    80005944:	95e080e7          	jalr	-1698(ra) # 8000429e <end_op>
    return -1;
    80005948:	557d                	li	a0,-1
    8000594a:	b761                	j	800058d2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    8000594c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005950:	04649783          	lh	a5,70(s1)
    80005954:	02f99223          	sh	a5,36(s3)
    80005958:	bf25                	j	80005890 <sys_open+0xa2>
    itrunc(ip);
    8000595a:	8526                	mv	a0,s1
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	00e080e7          	jalr	14(ra) # 8000396a <itrunc>
    80005964:	bfa9                	j	800058be <sys_open+0xd0>
      fileclose(f);
    80005966:	854e                	mv	a0,s3
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	d82080e7          	jalr	-638(ra) # 800046ea <fileclose>
    iunlockput(ip);
    80005970:	8526                	mv	a0,s1
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	14c080e7          	jalr	332(ra) # 80003abe <iunlockput>
    end_op();
    8000597a:	fffff097          	auipc	ra,0xfffff
    8000597e:	924080e7          	jalr	-1756(ra) # 8000429e <end_op>
    return -1;
    80005982:	557d                	li	a0,-1
    80005984:	b7b9                	j	800058d2 <sys_open+0xe4>

0000000080005986 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005986:	7175                	addi	sp,sp,-144
    80005988:	e506                	sd	ra,136(sp)
    8000598a:	e122                	sd	s0,128(sp)
    8000598c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000598e:	fffff097          	auipc	ra,0xfffff
    80005992:	890080e7          	jalr	-1904(ra) # 8000421e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005996:	08000613          	li	a2,128
    8000599a:	f7040593          	addi	a1,s0,-144
    8000599e:	4501                	li	a0,0
    800059a0:	ffffd097          	auipc	ra,0xffffd
    800059a4:	2aa080e7          	jalr	682(ra) # 80002c4a <argstr>
    800059a8:	02054963          	bltz	a0,800059da <sys_mkdir+0x54>
    800059ac:	4681                	li	a3,0
    800059ae:	4601                	li	a2,0
    800059b0:	4585                	li	a1,1
    800059b2:	f7040513          	addi	a0,s0,-144
    800059b6:	fffff097          	auipc	ra,0xfffff
    800059ba:	7fe080e7          	jalr	2046(ra) # 800051b4 <create>
    800059be:	cd11                	beqz	a0,800059da <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	0fe080e7          	jalr	254(ra) # 80003abe <iunlockput>
  end_op();
    800059c8:	fffff097          	auipc	ra,0xfffff
    800059cc:	8d6080e7          	jalr	-1834(ra) # 8000429e <end_op>
  return 0;
    800059d0:	4501                	li	a0,0
}
    800059d2:	60aa                	ld	ra,136(sp)
    800059d4:	640a                	ld	s0,128(sp)
    800059d6:	6149                	addi	sp,sp,144
    800059d8:	8082                	ret
    end_op();
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	8c4080e7          	jalr	-1852(ra) # 8000429e <end_op>
    return -1;
    800059e2:	557d                	li	a0,-1
    800059e4:	b7fd                	j	800059d2 <sys_mkdir+0x4c>

00000000800059e6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800059e6:	7135                	addi	sp,sp,-160
    800059e8:	ed06                	sd	ra,152(sp)
    800059ea:	e922                	sd	s0,144(sp)
    800059ec:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	830080e7          	jalr	-2000(ra) # 8000421e <begin_op>
  argint(1, &major);
    800059f6:	f6c40593          	addi	a1,s0,-148
    800059fa:	4505                	li	a0,1
    800059fc:	ffffd097          	auipc	ra,0xffffd
    80005a00:	20e080e7          	jalr	526(ra) # 80002c0a <argint>
  argint(2, &minor);
    80005a04:	f6840593          	addi	a1,s0,-152
    80005a08:	4509                	li	a0,2
    80005a0a:	ffffd097          	auipc	ra,0xffffd
    80005a0e:	200080e7          	jalr	512(ra) # 80002c0a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a12:	08000613          	li	a2,128
    80005a16:	f7040593          	addi	a1,s0,-144
    80005a1a:	4501                	li	a0,0
    80005a1c:	ffffd097          	auipc	ra,0xffffd
    80005a20:	22e080e7          	jalr	558(ra) # 80002c4a <argstr>
    80005a24:	02054b63          	bltz	a0,80005a5a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a28:	f6841683          	lh	a3,-152(s0)
    80005a2c:	f6c41603          	lh	a2,-148(s0)
    80005a30:	458d                	li	a1,3
    80005a32:	f7040513          	addi	a0,s0,-144
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	77e080e7          	jalr	1918(ra) # 800051b4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a3e:	cd11                	beqz	a0,80005a5a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	07e080e7          	jalr	126(ra) # 80003abe <iunlockput>
  end_op();
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	856080e7          	jalr	-1962(ra) # 8000429e <end_op>
  return 0;
    80005a50:	4501                	li	a0,0
}
    80005a52:	60ea                	ld	ra,152(sp)
    80005a54:	644a                	ld	s0,144(sp)
    80005a56:	610d                	addi	sp,sp,160
    80005a58:	8082                	ret
    end_op();
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	844080e7          	jalr	-1980(ra) # 8000429e <end_op>
    return -1;
    80005a62:	557d                	li	a0,-1
    80005a64:	b7fd                	j	80005a52 <sys_mknod+0x6c>

0000000080005a66 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a66:	7135                	addi	sp,sp,-160
    80005a68:	ed06                	sd	ra,152(sp)
    80005a6a:	e922                	sd	s0,144(sp)
    80005a6c:	e526                	sd	s1,136(sp)
    80005a6e:	e14a                	sd	s2,128(sp)
    80005a70:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a72:	ffffc097          	auipc	ra,0xffffc
    80005a76:	f5e080e7          	jalr	-162(ra) # 800019d0 <myproc>
    80005a7a:	892a                	mv	s2,a0
  
  begin_op();
    80005a7c:	ffffe097          	auipc	ra,0xffffe
    80005a80:	7a2080e7          	jalr	1954(ra) # 8000421e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a84:	08000613          	li	a2,128
    80005a88:	f6040593          	addi	a1,s0,-160
    80005a8c:	4501                	li	a0,0
    80005a8e:	ffffd097          	auipc	ra,0xffffd
    80005a92:	1bc080e7          	jalr	444(ra) # 80002c4a <argstr>
    80005a96:	04054b63          	bltz	a0,80005aec <sys_chdir+0x86>
    80005a9a:	f6040513          	addi	a0,s0,-160
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	564080e7          	jalr	1380(ra) # 80004002 <namei>
    80005aa6:	84aa                	mv	s1,a0
    80005aa8:	c131                	beqz	a0,80005aec <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	db2080e7          	jalr	-590(ra) # 8000385c <ilock>
  if(ip->type != T_DIR){
    80005ab2:	04449703          	lh	a4,68(s1)
    80005ab6:	4785                	li	a5,1
    80005ab8:	04f71063          	bne	a4,a5,80005af8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005abc:	8526                	mv	a0,s1
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	e60080e7          	jalr	-416(ra) # 8000391e <iunlock>
  iput(p->cwd);
    80005ac6:	15093503          	ld	a0,336(s2)
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	f4c080e7          	jalr	-180(ra) # 80003a16 <iput>
  end_op();
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	7cc080e7          	jalr	1996(ra) # 8000429e <end_op>
  p->cwd = ip;
    80005ada:	14993823          	sd	s1,336(s2)
  return 0;
    80005ade:	4501                	li	a0,0
}
    80005ae0:	60ea                	ld	ra,152(sp)
    80005ae2:	644a                	ld	s0,144(sp)
    80005ae4:	64aa                	ld	s1,136(sp)
    80005ae6:	690a                	ld	s2,128(sp)
    80005ae8:	610d                	addi	sp,sp,160
    80005aea:	8082                	ret
    end_op();
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	7b2080e7          	jalr	1970(ra) # 8000429e <end_op>
    return -1;
    80005af4:	557d                	li	a0,-1
    80005af6:	b7ed                	j	80005ae0 <sys_chdir+0x7a>
    iunlockput(ip);
    80005af8:	8526                	mv	a0,s1
    80005afa:	ffffe097          	auipc	ra,0xffffe
    80005afe:	fc4080e7          	jalr	-60(ra) # 80003abe <iunlockput>
    end_op();
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	79c080e7          	jalr	1948(ra) # 8000429e <end_op>
    return -1;
    80005b0a:	557d                	li	a0,-1
    80005b0c:	bfd1                	j	80005ae0 <sys_chdir+0x7a>

0000000080005b0e <sys_exec>:

uint64
sys_exec(void)
{
    80005b0e:	7145                	addi	sp,sp,-464
    80005b10:	e786                	sd	ra,456(sp)
    80005b12:	e3a2                	sd	s0,448(sp)
    80005b14:	ff26                	sd	s1,440(sp)
    80005b16:	fb4a                	sd	s2,432(sp)
    80005b18:	f74e                	sd	s3,424(sp)
    80005b1a:	f352                	sd	s4,416(sp)
    80005b1c:	ef56                	sd	s5,408(sp)
    80005b1e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b20:	e3840593          	addi	a1,s0,-456
    80005b24:	4505                	li	a0,1
    80005b26:	ffffd097          	auipc	ra,0xffffd
    80005b2a:	104080e7          	jalr	260(ra) # 80002c2a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b2e:	08000613          	li	a2,128
    80005b32:	f4040593          	addi	a1,s0,-192
    80005b36:	4501                	li	a0,0
    80005b38:	ffffd097          	auipc	ra,0xffffd
    80005b3c:	112080e7          	jalr	274(ra) # 80002c4a <argstr>
    80005b40:	87aa                	mv	a5,a0
    return -1;
    80005b42:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b44:	0c07c263          	bltz	a5,80005c08 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005b48:	10000613          	li	a2,256
    80005b4c:	4581                	li	a1,0
    80005b4e:	e4040513          	addi	a0,s0,-448
    80005b52:	ffffb097          	auipc	ra,0xffffb
    80005b56:	194080e7          	jalr	404(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b5a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b5e:	89a6                	mv	s3,s1
    80005b60:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b62:	02000a13          	li	s4,32
    80005b66:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b6a:	00391513          	slli	a0,s2,0x3
    80005b6e:	e3040593          	addi	a1,s0,-464
    80005b72:	e3843783          	ld	a5,-456(s0)
    80005b76:	953e                	add	a0,a0,a5
    80005b78:	ffffd097          	auipc	ra,0xffffd
    80005b7c:	ff4080e7          	jalr	-12(ra) # 80002b6c <fetchaddr>
    80005b80:	02054a63          	bltz	a0,80005bb4 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005b84:	e3043783          	ld	a5,-464(s0)
    80005b88:	c3b9                	beqz	a5,80005bce <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b8a:	ffffb097          	auipc	ra,0xffffb
    80005b8e:	f70080e7          	jalr	-144(ra) # 80000afa <kalloc>
    80005b92:	85aa                	mv	a1,a0
    80005b94:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b98:	cd11                	beqz	a0,80005bb4 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b9a:	6605                	lui	a2,0x1
    80005b9c:	e3043503          	ld	a0,-464(s0)
    80005ba0:	ffffd097          	auipc	ra,0xffffd
    80005ba4:	01e080e7          	jalr	30(ra) # 80002bbe <fetchstr>
    80005ba8:	00054663          	bltz	a0,80005bb4 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005bac:	0905                	addi	s2,s2,1
    80005bae:	09a1                	addi	s3,s3,8
    80005bb0:	fb491be3          	bne	s2,s4,80005b66 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb4:	10048913          	addi	s2,s1,256
    80005bb8:	6088                	ld	a0,0(s1)
    80005bba:	c531                	beqz	a0,80005c06 <sys_exec+0xf8>
    kfree(argv[i]);
    80005bbc:	ffffb097          	auipc	ra,0xffffb
    80005bc0:	e42080e7          	jalr	-446(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bc4:	04a1                	addi	s1,s1,8
    80005bc6:	ff2499e3          	bne	s1,s2,80005bb8 <sys_exec+0xaa>
  return -1;
    80005bca:	557d                	li	a0,-1
    80005bcc:	a835                	j	80005c08 <sys_exec+0xfa>
      argv[i] = 0;
    80005bce:	0a8e                	slli	s5,s5,0x3
    80005bd0:	fc040793          	addi	a5,s0,-64
    80005bd4:	9abe                	add	s5,s5,a5
    80005bd6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005bda:	e4040593          	addi	a1,s0,-448
    80005bde:	f4040513          	addi	a0,s0,-192
    80005be2:	fffff097          	auipc	ra,0xfffff
    80005be6:	190080e7          	jalr	400(ra) # 80004d72 <exec>
    80005bea:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bec:	10048993          	addi	s3,s1,256
    80005bf0:	6088                	ld	a0,0(s1)
    80005bf2:	c901                	beqz	a0,80005c02 <sys_exec+0xf4>
    kfree(argv[i]);
    80005bf4:	ffffb097          	auipc	ra,0xffffb
    80005bf8:	e0a080e7          	jalr	-502(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bfc:	04a1                	addi	s1,s1,8
    80005bfe:	ff3499e3          	bne	s1,s3,80005bf0 <sys_exec+0xe2>
  return ret;
    80005c02:	854a                	mv	a0,s2
    80005c04:	a011                	j	80005c08 <sys_exec+0xfa>
  return -1;
    80005c06:	557d                	li	a0,-1
}
    80005c08:	60be                	ld	ra,456(sp)
    80005c0a:	641e                	ld	s0,448(sp)
    80005c0c:	74fa                	ld	s1,440(sp)
    80005c0e:	795a                	ld	s2,432(sp)
    80005c10:	79ba                	ld	s3,424(sp)
    80005c12:	7a1a                	ld	s4,416(sp)
    80005c14:	6afa                	ld	s5,408(sp)
    80005c16:	6179                	addi	sp,sp,464
    80005c18:	8082                	ret

0000000080005c1a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c1a:	7139                	addi	sp,sp,-64
    80005c1c:	fc06                	sd	ra,56(sp)
    80005c1e:	f822                	sd	s0,48(sp)
    80005c20:	f426                	sd	s1,40(sp)
    80005c22:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c24:	ffffc097          	auipc	ra,0xffffc
    80005c28:	dac080e7          	jalr	-596(ra) # 800019d0 <myproc>
    80005c2c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c2e:	fd840593          	addi	a1,s0,-40
    80005c32:	4501                	li	a0,0
    80005c34:	ffffd097          	auipc	ra,0xffffd
    80005c38:	ff6080e7          	jalr	-10(ra) # 80002c2a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c3c:	fc840593          	addi	a1,s0,-56
    80005c40:	fd040513          	addi	a0,s0,-48
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	dd6080e7          	jalr	-554(ra) # 80004a1a <pipealloc>
    return -1;
    80005c4c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c4e:	0c054463          	bltz	a0,80005d16 <sys_pipe+0xfc>
  fd0 = -1;
    80005c52:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c56:	fd043503          	ld	a0,-48(s0)
    80005c5a:	fffff097          	auipc	ra,0xfffff
    80005c5e:	518080e7          	jalr	1304(ra) # 80005172 <fdalloc>
    80005c62:	fca42223          	sw	a0,-60(s0)
    80005c66:	08054b63          	bltz	a0,80005cfc <sys_pipe+0xe2>
    80005c6a:	fc843503          	ld	a0,-56(s0)
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	504080e7          	jalr	1284(ra) # 80005172 <fdalloc>
    80005c76:	fca42023          	sw	a0,-64(s0)
    80005c7a:	06054863          	bltz	a0,80005cea <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c7e:	4691                	li	a3,4
    80005c80:	fc440613          	addi	a2,s0,-60
    80005c84:	fd843583          	ld	a1,-40(s0)
    80005c88:	68a8                	ld	a0,80(s1)
    80005c8a:	ffffc097          	auipc	ra,0xffffc
    80005c8e:	9fa080e7          	jalr	-1542(ra) # 80001684 <copyout>
    80005c92:	02054063          	bltz	a0,80005cb2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c96:	4691                	li	a3,4
    80005c98:	fc040613          	addi	a2,s0,-64
    80005c9c:	fd843583          	ld	a1,-40(s0)
    80005ca0:	0591                	addi	a1,a1,4
    80005ca2:	68a8                	ld	a0,80(s1)
    80005ca4:	ffffc097          	auipc	ra,0xffffc
    80005ca8:	9e0080e7          	jalr	-1568(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005cac:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cae:	06055463          	bgez	a0,80005d16 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005cb2:	fc442783          	lw	a5,-60(s0)
    80005cb6:	07e9                	addi	a5,a5,26
    80005cb8:	078e                	slli	a5,a5,0x3
    80005cba:	97a6                	add	a5,a5,s1
    80005cbc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005cc0:	fc042503          	lw	a0,-64(s0)
    80005cc4:	0569                	addi	a0,a0,26
    80005cc6:	050e                	slli	a0,a0,0x3
    80005cc8:	94aa                	add	s1,s1,a0
    80005cca:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005cce:	fd043503          	ld	a0,-48(s0)
    80005cd2:	fffff097          	auipc	ra,0xfffff
    80005cd6:	a18080e7          	jalr	-1512(ra) # 800046ea <fileclose>
    fileclose(wf);
    80005cda:	fc843503          	ld	a0,-56(s0)
    80005cde:	fffff097          	auipc	ra,0xfffff
    80005ce2:	a0c080e7          	jalr	-1524(ra) # 800046ea <fileclose>
    return -1;
    80005ce6:	57fd                	li	a5,-1
    80005ce8:	a03d                	j	80005d16 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005cea:	fc442783          	lw	a5,-60(s0)
    80005cee:	0007c763          	bltz	a5,80005cfc <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005cf2:	07e9                	addi	a5,a5,26
    80005cf4:	078e                	slli	a5,a5,0x3
    80005cf6:	94be                	add	s1,s1,a5
    80005cf8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005cfc:	fd043503          	ld	a0,-48(s0)
    80005d00:	fffff097          	auipc	ra,0xfffff
    80005d04:	9ea080e7          	jalr	-1558(ra) # 800046ea <fileclose>
    fileclose(wf);
    80005d08:	fc843503          	ld	a0,-56(s0)
    80005d0c:	fffff097          	auipc	ra,0xfffff
    80005d10:	9de080e7          	jalr	-1570(ra) # 800046ea <fileclose>
    return -1;
    80005d14:	57fd                	li	a5,-1
}
    80005d16:	853e                	mv	a0,a5
    80005d18:	70e2                	ld	ra,56(sp)
    80005d1a:	7442                	ld	s0,48(sp)
    80005d1c:	74a2                	ld	s1,40(sp)
    80005d1e:	6121                	addi	sp,sp,64
    80005d20:	8082                	ret
	...

0000000080005d30 <kernelvec>:
    80005d30:	7111                	addi	sp,sp,-256
    80005d32:	e006                	sd	ra,0(sp)
    80005d34:	e40a                	sd	sp,8(sp)
    80005d36:	e80e                	sd	gp,16(sp)
    80005d38:	ec12                	sd	tp,24(sp)
    80005d3a:	f016                	sd	t0,32(sp)
    80005d3c:	f41a                	sd	t1,40(sp)
    80005d3e:	f81e                	sd	t2,48(sp)
    80005d40:	fc22                	sd	s0,56(sp)
    80005d42:	e0a6                	sd	s1,64(sp)
    80005d44:	e4aa                	sd	a0,72(sp)
    80005d46:	e8ae                	sd	a1,80(sp)
    80005d48:	ecb2                	sd	a2,88(sp)
    80005d4a:	f0b6                	sd	a3,96(sp)
    80005d4c:	f4ba                	sd	a4,104(sp)
    80005d4e:	f8be                	sd	a5,112(sp)
    80005d50:	fcc2                	sd	a6,120(sp)
    80005d52:	e146                	sd	a7,128(sp)
    80005d54:	e54a                	sd	s2,136(sp)
    80005d56:	e94e                	sd	s3,144(sp)
    80005d58:	ed52                	sd	s4,152(sp)
    80005d5a:	f156                	sd	s5,160(sp)
    80005d5c:	f55a                	sd	s6,168(sp)
    80005d5e:	f95e                	sd	s7,176(sp)
    80005d60:	fd62                	sd	s8,184(sp)
    80005d62:	e1e6                	sd	s9,192(sp)
    80005d64:	e5ea                	sd	s10,200(sp)
    80005d66:	e9ee                	sd	s11,208(sp)
    80005d68:	edf2                	sd	t3,216(sp)
    80005d6a:	f1f6                	sd	t4,224(sp)
    80005d6c:	f5fa                	sd	t5,232(sp)
    80005d6e:	f9fe                	sd	t6,240(sp)
    80005d70:	cc9fc0ef          	jal	ra,80002a38 <kerneltrap>
    80005d74:	6082                	ld	ra,0(sp)
    80005d76:	6122                	ld	sp,8(sp)
    80005d78:	61c2                	ld	gp,16(sp)
    80005d7a:	7282                	ld	t0,32(sp)
    80005d7c:	7322                	ld	t1,40(sp)
    80005d7e:	73c2                	ld	t2,48(sp)
    80005d80:	7462                	ld	s0,56(sp)
    80005d82:	6486                	ld	s1,64(sp)
    80005d84:	6526                	ld	a0,72(sp)
    80005d86:	65c6                	ld	a1,80(sp)
    80005d88:	6666                	ld	a2,88(sp)
    80005d8a:	7686                	ld	a3,96(sp)
    80005d8c:	7726                	ld	a4,104(sp)
    80005d8e:	77c6                	ld	a5,112(sp)
    80005d90:	7866                	ld	a6,120(sp)
    80005d92:	688a                	ld	a7,128(sp)
    80005d94:	692a                	ld	s2,136(sp)
    80005d96:	69ca                	ld	s3,144(sp)
    80005d98:	6a6a                	ld	s4,152(sp)
    80005d9a:	7a8a                	ld	s5,160(sp)
    80005d9c:	7b2a                	ld	s6,168(sp)
    80005d9e:	7bca                	ld	s7,176(sp)
    80005da0:	7c6a                	ld	s8,184(sp)
    80005da2:	6c8e                	ld	s9,192(sp)
    80005da4:	6d2e                	ld	s10,200(sp)
    80005da6:	6dce                	ld	s11,208(sp)
    80005da8:	6e6e                	ld	t3,216(sp)
    80005daa:	7e8e                	ld	t4,224(sp)
    80005dac:	7f2e                	ld	t5,232(sp)
    80005dae:	7fce                	ld	t6,240(sp)
    80005db0:	6111                	addi	sp,sp,256
    80005db2:	10200073          	sret
    80005db6:	00000013          	nop
    80005dba:	00000013          	nop
    80005dbe:	0001                	nop

0000000080005dc0 <timervec>:
    80005dc0:	34051573          	csrrw	a0,mscratch,a0
    80005dc4:	e10c                	sd	a1,0(a0)
    80005dc6:	e510                	sd	a2,8(a0)
    80005dc8:	e914                	sd	a3,16(a0)
    80005dca:	6d0c                	ld	a1,24(a0)
    80005dcc:	7110                	ld	a2,32(a0)
    80005dce:	6194                	ld	a3,0(a1)
    80005dd0:	96b2                	add	a3,a3,a2
    80005dd2:	e194                	sd	a3,0(a1)
    80005dd4:	4589                	li	a1,2
    80005dd6:	14459073          	csrw	sip,a1
    80005dda:	6914                	ld	a3,16(a0)
    80005ddc:	6510                	ld	a2,8(a0)
    80005dde:	610c                	ld	a1,0(a0)
    80005de0:	34051573          	csrrw	a0,mscratch,a0
    80005de4:	30200073          	mret
	...

0000000080005dea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005dea:	1141                	addi	sp,sp,-16
    80005dec:	e422                	sd	s0,8(sp)
    80005dee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005df0:	0c0007b7          	lui	a5,0xc000
    80005df4:	4705                	li	a4,1
    80005df6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005df8:	c3d8                	sw	a4,4(a5)
}
    80005dfa:	6422                	ld	s0,8(sp)
    80005dfc:	0141                	addi	sp,sp,16
    80005dfe:	8082                	ret

0000000080005e00 <plicinithart>:

void
plicinithart(void)
{
    80005e00:	1141                	addi	sp,sp,-16
    80005e02:	e406                	sd	ra,8(sp)
    80005e04:	e022                	sd	s0,0(sp)
    80005e06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e08:	ffffc097          	auipc	ra,0xffffc
    80005e0c:	b9c080e7          	jalr	-1124(ra) # 800019a4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e10:	0085171b          	slliw	a4,a0,0x8
    80005e14:	0c0027b7          	lui	a5,0xc002
    80005e18:	97ba                	add	a5,a5,a4
    80005e1a:	40200713          	li	a4,1026
    80005e1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e22:	00d5151b          	slliw	a0,a0,0xd
    80005e26:	0c2017b7          	lui	a5,0xc201
    80005e2a:	953e                	add	a0,a0,a5
    80005e2c:	00052023          	sw	zero,0(a0)
}
    80005e30:	60a2                	ld	ra,8(sp)
    80005e32:	6402                	ld	s0,0(sp)
    80005e34:	0141                	addi	sp,sp,16
    80005e36:	8082                	ret

0000000080005e38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e38:	1141                	addi	sp,sp,-16
    80005e3a:	e406                	sd	ra,8(sp)
    80005e3c:	e022                	sd	s0,0(sp)
    80005e3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e40:	ffffc097          	auipc	ra,0xffffc
    80005e44:	b64080e7          	jalr	-1180(ra) # 800019a4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e48:	00d5179b          	slliw	a5,a0,0xd
    80005e4c:	0c201537          	lui	a0,0xc201
    80005e50:	953e                	add	a0,a0,a5
  return irq;
}
    80005e52:	4148                	lw	a0,4(a0)
    80005e54:	60a2                	ld	ra,8(sp)
    80005e56:	6402                	ld	s0,0(sp)
    80005e58:	0141                	addi	sp,sp,16
    80005e5a:	8082                	ret

0000000080005e5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e5c:	1101                	addi	sp,sp,-32
    80005e5e:	ec06                	sd	ra,24(sp)
    80005e60:	e822                	sd	s0,16(sp)
    80005e62:	e426                	sd	s1,8(sp)
    80005e64:	1000                	addi	s0,sp,32
    80005e66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e68:	ffffc097          	auipc	ra,0xffffc
    80005e6c:	b3c080e7          	jalr	-1220(ra) # 800019a4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e70:	00d5151b          	slliw	a0,a0,0xd
    80005e74:	0c2017b7          	lui	a5,0xc201
    80005e78:	97aa                	add	a5,a5,a0
    80005e7a:	c3c4                	sw	s1,4(a5)
}
    80005e7c:	60e2                	ld	ra,24(sp)
    80005e7e:	6442                	ld	s0,16(sp)
    80005e80:	64a2                	ld	s1,8(sp)
    80005e82:	6105                	addi	sp,sp,32
    80005e84:	8082                	ret

0000000080005e86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e86:	1141                	addi	sp,sp,-16
    80005e88:	e406                	sd	ra,8(sp)
    80005e8a:	e022                	sd	s0,0(sp)
    80005e8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e8e:	479d                	li	a5,7
    80005e90:	04a7cc63          	blt	a5,a0,80005ee8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005e94:	0001c797          	auipc	a5,0x1c
    80005e98:	d9c78793          	addi	a5,a5,-612 # 80021c30 <disk>
    80005e9c:	97aa                	add	a5,a5,a0
    80005e9e:	0187c783          	lbu	a5,24(a5)
    80005ea2:	ebb9                	bnez	a5,80005ef8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ea4:	00451613          	slli	a2,a0,0x4
    80005ea8:	0001c797          	auipc	a5,0x1c
    80005eac:	d8878793          	addi	a5,a5,-632 # 80021c30 <disk>
    80005eb0:	6394                	ld	a3,0(a5)
    80005eb2:	96b2                	add	a3,a3,a2
    80005eb4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005eb8:	6398                	ld	a4,0(a5)
    80005eba:	9732                	add	a4,a4,a2
    80005ebc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ec0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ec4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ec8:	953e                	add	a0,a0,a5
    80005eca:	4785                	li	a5,1
    80005ecc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005ed0:	0001c517          	auipc	a0,0x1c
    80005ed4:	d7850513          	addi	a0,a0,-648 # 80021c48 <disk+0x18>
    80005ed8:	ffffc097          	auipc	ra,0xffffc
    80005edc:	200080e7          	jalr	512(ra) # 800020d8 <wakeup>
}
    80005ee0:	60a2                	ld	ra,8(sp)
    80005ee2:	6402                	ld	s0,0(sp)
    80005ee4:	0141                	addi	sp,sp,16
    80005ee6:	8082                	ret
    panic("free_desc 1");
    80005ee8:	00003517          	auipc	a0,0x3
    80005eec:	86850513          	addi	a0,a0,-1944 # 80008750 <syscalls+0x300>
    80005ef0:	ffffa097          	auipc	ra,0xffffa
    80005ef4:	654080e7          	jalr	1620(ra) # 80000544 <panic>
    panic("free_desc 2");
    80005ef8:	00003517          	auipc	a0,0x3
    80005efc:	86850513          	addi	a0,a0,-1944 # 80008760 <syscalls+0x310>
    80005f00:	ffffa097          	auipc	ra,0xffffa
    80005f04:	644080e7          	jalr	1604(ra) # 80000544 <panic>

0000000080005f08 <virtio_disk_init>:
{
    80005f08:	1101                	addi	sp,sp,-32
    80005f0a:	ec06                	sd	ra,24(sp)
    80005f0c:	e822                	sd	s0,16(sp)
    80005f0e:	e426                	sd	s1,8(sp)
    80005f10:	e04a                	sd	s2,0(sp)
    80005f12:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f14:	00003597          	auipc	a1,0x3
    80005f18:	85c58593          	addi	a1,a1,-1956 # 80008770 <syscalls+0x320>
    80005f1c:	0001c517          	auipc	a0,0x1c
    80005f20:	e3c50513          	addi	a0,a0,-452 # 80021d58 <disk+0x128>
    80005f24:	ffffb097          	auipc	ra,0xffffb
    80005f28:	c36080e7          	jalr	-970(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f2c:	100017b7          	lui	a5,0x10001
    80005f30:	4398                	lw	a4,0(a5)
    80005f32:	2701                	sext.w	a4,a4
    80005f34:	747277b7          	lui	a5,0x74727
    80005f38:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f3c:	14f71e63          	bne	a4,a5,80006098 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f40:	100017b7          	lui	a5,0x10001
    80005f44:	43dc                	lw	a5,4(a5)
    80005f46:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f48:	4709                	li	a4,2
    80005f4a:	14e79763          	bne	a5,a4,80006098 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f4e:	100017b7          	lui	a5,0x10001
    80005f52:	479c                	lw	a5,8(a5)
    80005f54:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f56:	14e79163          	bne	a5,a4,80006098 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f5a:	100017b7          	lui	a5,0x10001
    80005f5e:	47d8                	lw	a4,12(a5)
    80005f60:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f62:	554d47b7          	lui	a5,0x554d4
    80005f66:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f6a:	12f71763          	bne	a4,a5,80006098 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f6e:	100017b7          	lui	a5,0x10001
    80005f72:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f76:	4705                	li	a4,1
    80005f78:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f7a:	470d                	li	a4,3
    80005f7c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f7e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005f80:	c7ffe737          	lui	a4,0xc7ffe
    80005f84:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9ef>
    80005f88:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f8a:	2701                	sext.w	a4,a4
    80005f8c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f8e:	472d                	li	a4,11
    80005f90:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005f92:	0707a903          	lw	s2,112(a5)
    80005f96:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f98:	00897793          	andi	a5,s2,8
    80005f9c:	10078663          	beqz	a5,800060a8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005fa0:	100017b7          	lui	a5,0x10001
    80005fa4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005fa8:	43fc                	lw	a5,68(a5)
    80005faa:	2781                	sext.w	a5,a5
    80005fac:	10079663          	bnez	a5,800060b8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005fb0:	100017b7          	lui	a5,0x10001
    80005fb4:	5bdc                	lw	a5,52(a5)
    80005fb6:	2781                	sext.w	a5,a5
  if(max == 0)
    80005fb8:	10078863          	beqz	a5,800060c8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    80005fbc:	471d                	li	a4,7
    80005fbe:	10f77d63          	bgeu	a4,a5,800060d8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80005fc2:	ffffb097          	auipc	ra,0xffffb
    80005fc6:	b38080e7          	jalr	-1224(ra) # 80000afa <kalloc>
    80005fca:	0001c497          	auipc	s1,0x1c
    80005fce:	c6648493          	addi	s1,s1,-922 # 80021c30 <disk>
    80005fd2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005fd4:	ffffb097          	auipc	ra,0xffffb
    80005fd8:	b26080e7          	jalr	-1242(ra) # 80000afa <kalloc>
    80005fdc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005fde:	ffffb097          	auipc	ra,0xffffb
    80005fe2:	b1c080e7          	jalr	-1252(ra) # 80000afa <kalloc>
    80005fe6:	87aa                	mv	a5,a0
    80005fe8:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005fea:	6088                	ld	a0,0(s1)
    80005fec:	cd75                	beqz	a0,800060e8 <virtio_disk_init+0x1e0>
    80005fee:	0001c717          	auipc	a4,0x1c
    80005ff2:	c4a73703          	ld	a4,-950(a4) # 80021c38 <disk+0x8>
    80005ff6:	cb6d                	beqz	a4,800060e8 <virtio_disk_init+0x1e0>
    80005ff8:	cbe5                	beqz	a5,800060e8 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    80005ffa:	6605                	lui	a2,0x1
    80005ffc:	4581                	li	a1,0
    80005ffe:	ffffb097          	auipc	ra,0xffffb
    80006002:	ce8080e7          	jalr	-792(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006006:	0001c497          	auipc	s1,0x1c
    8000600a:	c2a48493          	addi	s1,s1,-982 # 80021c30 <disk>
    8000600e:	6605                	lui	a2,0x1
    80006010:	4581                	li	a1,0
    80006012:	6488                	ld	a0,8(s1)
    80006014:	ffffb097          	auipc	ra,0xffffb
    80006018:	cd2080e7          	jalr	-814(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000601c:	6605                	lui	a2,0x1
    8000601e:	4581                	li	a1,0
    80006020:	6888                	ld	a0,16(s1)
    80006022:	ffffb097          	auipc	ra,0xffffb
    80006026:	cc4080e7          	jalr	-828(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000602a:	100017b7          	lui	a5,0x10001
    8000602e:	4721                	li	a4,8
    80006030:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006032:	4098                	lw	a4,0(s1)
    80006034:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006038:	40d8                	lw	a4,4(s1)
    8000603a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000603e:	6498                	ld	a4,8(s1)
    80006040:	0007069b          	sext.w	a3,a4
    80006044:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006048:	9701                	srai	a4,a4,0x20
    8000604a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000604e:	6898                	ld	a4,16(s1)
    80006050:	0007069b          	sext.w	a3,a4
    80006054:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006058:	9701                	srai	a4,a4,0x20
    8000605a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000605e:	4685                	li	a3,1
    80006060:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006062:	4705                	li	a4,1
    80006064:	00d48c23          	sb	a3,24(s1)
    80006068:	00e48ca3          	sb	a4,25(s1)
    8000606c:	00e48d23          	sb	a4,26(s1)
    80006070:	00e48da3          	sb	a4,27(s1)
    80006074:	00e48e23          	sb	a4,28(s1)
    80006078:	00e48ea3          	sb	a4,29(s1)
    8000607c:	00e48f23          	sb	a4,30(s1)
    80006080:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006084:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006088:	0727a823          	sw	s2,112(a5)
}
    8000608c:	60e2                	ld	ra,24(sp)
    8000608e:	6442                	ld	s0,16(sp)
    80006090:	64a2                	ld	s1,8(sp)
    80006092:	6902                	ld	s2,0(sp)
    80006094:	6105                	addi	sp,sp,32
    80006096:	8082                	ret
    panic("could not find virtio disk");
    80006098:	00002517          	auipc	a0,0x2
    8000609c:	6e850513          	addi	a0,a0,1768 # 80008780 <syscalls+0x330>
    800060a0:	ffffa097          	auipc	ra,0xffffa
    800060a4:	4a4080e7          	jalr	1188(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800060a8:	00002517          	auipc	a0,0x2
    800060ac:	6f850513          	addi	a0,a0,1784 # 800087a0 <syscalls+0x350>
    800060b0:	ffffa097          	auipc	ra,0xffffa
    800060b4:	494080e7          	jalr	1172(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800060b8:	00002517          	auipc	a0,0x2
    800060bc:	70850513          	addi	a0,a0,1800 # 800087c0 <syscalls+0x370>
    800060c0:	ffffa097          	auipc	ra,0xffffa
    800060c4:	484080e7          	jalr	1156(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    800060c8:	00002517          	auipc	a0,0x2
    800060cc:	71850513          	addi	a0,a0,1816 # 800087e0 <syscalls+0x390>
    800060d0:	ffffa097          	auipc	ra,0xffffa
    800060d4:	474080e7          	jalr	1140(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    800060d8:	00002517          	auipc	a0,0x2
    800060dc:	72850513          	addi	a0,a0,1832 # 80008800 <syscalls+0x3b0>
    800060e0:	ffffa097          	auipc	ra,0xffffa
    800060e4:	464080e7          	jalr	1124(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	73850513          	addi	a0,a0,1848 # 80008820 <syscalls+0x3d0>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	454080e7          	jalr	1108(ra) # 80000544 <panic>

00000000800060f8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060f8:	7159                	addi	sp,sp,-112
    800060fa:	f486                	sd	ra,104(sp)
    800060fc:	f0a2                	sd	s0,96(sp)
    800060fe:	eca6                	sd	s1,88(sp)
    80006100:	e8ca                	sd	s2,80(sp)
    80006102:	e4ce                	sd	s3,72(sp)
    80006104:	e0d2                	sd	s4,64(sp)
    80006106:	fc56                	sd	s5,56(sp)
    80006108:	f85a                	sd	s6,48(sp)
    8000610a:	f45e                	sd	s7,40(sp)
    8000610c:	f062                	sd	s8,32(sp)
    8000610e:	ec66                	sd	s9,24(sp)
    80006110:	e86a                	sd	s10,16(sp)
    80006112:	1880                	addi	s0,sp,112
    80006114:	892a                	mv	s2,a0
    80006116:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006118:	00c52c83          	lw	s9,12(a0)
    8000611c:	001c9c9b          	slliw	s9,s9,0x1
    80006120:	1c82                	slli	s9,s9,0x20
    80006122:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006126:	0001c517          	auipc	a0,0x1c
    8000612a:	c3250513          	addi	a0,a0,-974 # 80021d58 <disk+0x128>
    8000612e:	ffffb097          	auipc	ra,0xffffb
    80006132:	abc080e7          	jalr	-1348(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006136:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006138:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000613a:	0001cb17          	auipc	s6,0x1c
    8000613e:	af6b0b13          	addi	s6,s6,-1290 # 80021c30 <disk>
  for(int i = 0; i < 3; i++){
    80006142:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006144:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006146:	0001cc17          	auipc	s8,0x1c
    8000614a:	c12c0c13          	addi	s8,s8,-1006 # 80021d58 <disk+0x128>
    8000614e:	a8b5                	j	800061ca <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006150:	00fb06b3          	add	a3,s6,a5
    80006154:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006158:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000615a:	0207c563          	bltz	a5,80006184 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000615e:	2485                	addiw	s1,s1,1
    80006160:	0711                	addi	a4,a4,4
    80006162:	1f548a63          	beq	s1,s5,80006356 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006166:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006168:	0001c697          	auipc	a3,0x1c
    8000616c:	ac868693          	addi	a3,a3,-1336 # 80021c30 <disk>
    80006170:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006172:	0186c583          	lbu	a1,24(a3)
    80006176:	fde9                	bnez	a1,80006150 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006178:	2785                	addiw	a5,a5,1
    8000617a:	0685                	addi	a3,a3,1
    8000617c:	ff779be3          	bne	a5,s7,80006172 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006180:	57fd                	li	a5,-1
    80006182:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006184:	02905a63          	blez	s1,800061b8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006188:	f9042503          	lw	a0,-112(s0)
    8000618c:	00000097          	auipc	ra,0x0
    80006190:	cfa080e7          	jalr	-774(ra) # 80005e86 <free_desc>
      for(int j = 0; j < i; j++)
    80006194:	4785                	li	a5,1
    80006196:	0297d163          	bge	a5,s1,800061b8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000619a:	f9442503          	lw	a0,-108(s0)
    8000619e:	00000097          	auipc	ra,0x0
    800061a2:	ce8080e7          	jalr	-792(ra) # 80005e86 <free_desc>
      for(int j = 0; j < i; j++)
    800061a6:	4789                	li	a5,2
    800061a8:	0097d863          	bge	a5,s1,800061b8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061ac:	f9842503          	lw	a0,-104(s0)
    800061b0:	00000097          	auipc	ra,0x0
    800061b4:	cd6080e7          	jalr	-810(ra) # 80005e86 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061b8:	85e2                	mv	a1,s8
    800061ba:	0001c517          	auipc	a0,0x1c
    800061be:	a8e50513          	addi	a0,a0,-1394 # 80021c48 <disk+0x18>
    800061c2:	ffffc097          	auipc	ra,0xffffc
    800061c6:	eb2080e7          	jalr	-334(ra) # 80002074 <sleep>
  for(int i = 0; i < 3; i++){
    800061ca:	f9040713          	addi	a4,s0,-112
    800061ce:	84ce                	mv	s1,s3
    800061d0:	bf59                	j	80006166 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800061d2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800061d6:	00479693          	slli	a3,a5,0x4
    800061da:	0001c797          	auipc	a5,0x1c
    800061de:	a5678793          	addi	a5,a5,-1450 # 80021c30 <disk>
    800061e2:	97b6                	add	a5,a5,a3
    800061e4:	4685                	li	a3,1
    800061e6:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800061e8:	0001c597          	auipc	a1,0x1c
    800061ec:	a4858593          	addi	a1,a1,-1464 # 80021c30 <disk>
    800061f0:	00a60793          	addi	a5,a2,10
    800061f4:	0792                	slli	a5,a5,0x4
    800061f6:	97ae                	add	a5,a5,a1
    800061f8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800061fc:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006200:	f6070693          	addi	a3,a4,-160
    80006204:	619c                	ld	a5,0(a1)
    80006206:	97b6                	add	a5,a5,a3
    80006208:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000620a:	6188                	ld	a0,0(a1)
    8000620c:	96aa                	add	a3,a3,a0
    8000620e:	47c1                	li	a5,16
    80006210:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006212:	4785                	li	a5,1
    80006214:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006218:	f9442783          	lw	a5,-108(s0)
    8000621c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006220:	0792                	slli	a5,a5,0x4
    80006222:	953e                	add	a0,a0,a5
    80006224:	05890693          	addi	a3,s2,88
    80006228:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000622a:	6188                	ld	a0,0(a1)
    8000622c:	97aa                	add	a5,a5,a0
    8000622e:	40000693          	li	a3,1024
    80006232:	c794                	sw	a3,8(a5)
  if(write)
    80006234:	100d0d63          	beqz	s10,8000634e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006238:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000623c:	00c7d683          	lhu	a3,12(a5)
    80006240:	0016e693          	ori	a3,a3,1
    80006244:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006248:	f9842583          	lw	a1,-104(s0)
    8000624c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006250:	0001c697          	auipc	a3,0x1c
    80006254:	9e068693          	addi	a3,a3,-1568 # 80021c30 <disk>
    80006258:	00260793          	addi	a5,a2,2
    8000625c:	0792                	slli	a5,a5,0x4
    8000625e:	97b6                	add	a5,a5,a3
    80006260:	587d                	li	a6,-1
    80006262:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006266:	0592                	slli	a1,a1,0x4
    80006268:	952e                	add	a0,a0,a1
    8000626a:	f9070713          	addi	a4,a4,-112
    8000626e:	9736                	add	a4,a4,a3
    80006270:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006272:	6298                	ld	a4,0(a3)
    80006274:	972e                	add	a4,a4,a1
    80006276:	4585                	li	a1,1
    80006278:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000627a:	4509                	li	a0,2
    8000627c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006280:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006284:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006288:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000628c:	6698                	ld	a4,8(a3)
    8000628e:	00275783          	lhu	a5,2(a4)
    80006292:	8b9d                	andi	a5,a5,7
    80006294:	0786                	slli	a5,a5,0x1
    80006296:	97ba                	add	a5,a5,a4
    80006298:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000629c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800062a0:	6698                	ld	a4,8(a3)
    800062a2:	00275783          	lhu	a5,2(a4)
    800062a6:	2785                	addiw	a5,a5,1
    800062a8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800062ac:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062b0:	100017b7          	lui	a5,0x10001
    800062b4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062b8:	00492703          	lw	a4,4(s2)
    800062bc:	4785                	li	a5,1
    800062be:	02f71163          	bne	a4,a5,800062e0 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800062c2:	0001c997          	auipc	s3,0x1c
    800062c6:	a9698993          	addi	s3,s3,-1386 # 80021d58 <disk+0x128>
  while(b->disk == 1) {
    800062ca:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800062cc:	85ce                	mv	a1,s3
    800062ce:	854a                	mv	a0,s2
    800062d0:	ffffc097          	auipc	ra,0xffffc
    800062d4:	da4080e7          	jalr	-604(ra) # 80002074 <sleep>
  while(b->disk == 1) {
    800062d8:	00492783          	lw	a5,4(s2)
    800062dc:	fe9788e3          	beq	a5,s1,800062cc <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    800062e0:	f9042903          	lw	s2,-112(s0)
    800062e4:	00290793          	addi	a5,s2,2
    800062e8:	00479713          	slli	a4,a5,0x4
    800062ec:	0001c797          	auipc	a5,0x1c
    800062f0:	94478793          	addi	a5,a5,-1724 # 80021c30 <disk>
    800062f4:	97ba                	add	a5,a5,a4
    800062f6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800062fa:	0001c997          	auipc	s3,0x1c
    800062fe:	93698993          	addi	s3,s3,-1738 # 80021c30 <disk>
    80006302:	00491713          	slli	a4,s2,0x4
    80006306:	0009b783          	ld	a5,0(s3)
    8000630a:	97ba                	add	a5,a5,a4
    8000630c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006310:	854a                	mv	a0,s2
    80006312:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006316:	00000097          	auipc	ra,0x0
    8000631a:	b70080e7          	jalr	-1168(ra) # 80005e86 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000631e:	8885                	andi	s1,s1,1
    80006320:	f0ed                	bnez	s1,80006302 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006322:	0001c517          	auipc	a0,0x1c
    80006326:	a3650513          	addi	a0,a0,-1482 # 80021d58 <disk+0x128>
    8000632a:	ffffb097          	auipc	ra,0xffffb
    8000632e:	974080e7          	jalr	-1676(ra) # 80000c9e <release>
}
    80006332:	70a6                	ld	ra,104(sp)
    80006334:	7406                	ld	s0,96(sp)
    80006336:	64e6                	ld	s1,88(sp)
    80006338:	6946                	ld	s2,80(sp)
    8000633a:	69a6                	ld	s3,72(sp)
    8000633c:	6a06                	ld	s4,64(sp)
    8000633e:	7ae2                	ld	s5,56(sp)
    80006340:	7b42                	ld	s6,48(sp)
    80006342:	7ba2                	ld	s7,40(sp)
    80006344:	7c02                	ld	s8,32(sp)
    80006346:	6ce2                	ld	s9,24(sp)
    80006348:	6d42                	ld	s10,16(sp)
    8000634a:	6165                	addi	sp,sp,112
    8000634c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000634e:	4689                	li	a3,2
    80006350:	00d79623          	sh	a3,12(a5)
    80006354:	b5e5                	j	8000623c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006356:	f9042603          	lw	a2,-112(s0)
    8000635a:	00a60713          	addi	a4,a2,10
    8000635e:	0712                	slli	a4,a4,0x4
    80006360:	0001c517          	auipc	a0,0x1c
    80006364:	8d850513          	addi	a0,a0,-1832 # 80021c38 <disk+0x8>
    80006368:	953a                	add	a0,a0,a4
  if(write)
    8000636a:	e60d14e3          	bnez	s10,800061d2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000636e:	00a60793          	addi	a5,a2,10
    80006372:	00479693          	slli	a3,a5,0x4
    80006376:	0001c797          	auipc	a5,0x1c
    8000637a:	8ba78793          	addi	a5,a5,-1862 # 80021c30 <disk>
    8000637e:	97b6                	add	a5,a5,a3
    80006380:	0007a423          	sw	zero,8(a5)
    80006384:	b595                	j	800061e8 <virtio_disk_rw+0xf0>

0000000080006386 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006386:	1101                	addi	sp,sp,-32
    80006388:	ec06                	sd	ra,24(sp)
    8000638a:	e822                	sd	s0,16(sp)
    8000638c:	e426                	sd	s1,8(sp)
    8000638e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006390:	0001c497          	auipc	s1,0x1c
    80006394:	8a048493          	addi	s1,s1,-1888 # 80021c30 <disk>
    80006398:	0001c517          	auipc	a0,0x1c
    8000639c:	9c050513          	addi	a0,a0,-1600 # 80021d58 <disk+0x128>
    800063a0:	ffffb097          	auipc	ra,0xffffb
    800063a4:	84a080e7          	jalr	-1974(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063a8:	10001737          	lui	a4,0x10001
    800063ac:	533c                	lw	a5,96(a4)
    800063ae:	8b8d                	andi	a5,a5,3
    800063b0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800063b2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063b6:	689c                	ld	a5,16(s1)
    800063b8:	0204d703          	lhu	a4,32(s1)
    800063bc:	0027d783          	lhu	a5,2(a5)
    800063c0:	04f70863          	beq	a4,a5,80006410 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800063c4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800063c8:	6898                	ld	a4,16(s1)
    800063ca:	0204d783          	lhu	a5,32(s1)
    800063ce:	8b9d                	andi	a5,a5,7
    800063d0:	078e                	slli	a5,a5,0x3
    800063d2:	97ba                	add	a5,a5,a4
    800063d4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800063d6:	00278713          	addi	a4,a5,2
    800063da:	0712                	slli	a4,a4,0x4
    800063dc:	9726                	add	a4,a4,s1
    800063de:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800063e2:	e721                	bnez	a4,8000642a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800063e4:	0789                	addi	a5,a5,2
    800063e6:	0792                	slli	a5,a5,0x4
    800063e8:	97a6                	add	a5,a5,s1
    800063ea:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800063ec:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800063f0:	ffffc097          	auipc	ra,0xffffc
    800063f4:	ce8080e7          	jalr	-792(ra) # 800020d8 <wakeup>

    disk.used_idx += 1;
    800063f8:	0204d783          	lhu	a5,32(s1)
    800063fc:	2785                	addiw	a5,a5,1
    800063fe:	17c2                	slli	a5,a5,0x30
    80006400:	93c1                	srli	a5,a5,0x30
    80006402:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006406:	6898                	ld	a4,16(s1)
    80006408:	00275703          	lhu	a4,2(a4)
    8000640c:	faf71ce3          	bne	a4,a5,800063c4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006410:	0001c517          	auipc	a0,0x1c
    80006414:	94850513          	addi	a0,a0,-1720 # 80021d58 <disk+0x128>
    80006418:	ffffb097          	auipc	ra,0xffffb
    8000641c:	886080e7          	jalr	-1914(ra) # 80000c9e <release>
}
    80006420:	60e2                	ld	ra,24(sp)
    80006422:	6442                	ld	s0,16(sp)
    80006424:	64a2                	ld	s1,8(sp)
    80006426:	6105                	addi	sp,sp,32
    80006428:	8082                	ret
      panic("virtio_disk_intr status");
    8000642a:	00002517          	auipc	a0,0x2
    8000642e:	40e50513          	addi	a0,a0,1038 # 80008838 <syscalls+0x3e8>
    80006432:	ffffa097          	auipc	ra,0xffffa
    80006436:	112080e7          	jalr	274(ra) # 80000544 <panic>
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
