
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
    80000068:	d9c78793          	addi	a5,a5,-612 # 80005e00 <timervec>
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
    80000130:	3f0080e7          	jalr	1008(ra) # 8000251c <either_copyin>
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
    800001d0:	19a080e7          	jalr	410(ra) # 80002366 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	ee4080e7          	jalr	-284(ra) # 800020be <sleep>
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
    8000021a:	2b0080e7          	jalr	688(ra) # 800024c6 <either_copyout>
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
    800002fc:	27a080e7          	jalr	634(ra) # 80002572 <procdump>
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
    80000450:	cd6080e7          	jalr	-810(ra) # 80002122 <wakeup>
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
    800008aa:	87c080e7          	jalr	-1924(ra) # 80002122 <wakeup>
    
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
    80000934:	78e080e7          	jalr	1934(ra) # 800020be <sleep>
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
    80000ede:	8fc080e7          	jalr	-1796(ra) # 800027d6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	f5e080e7          	jalr	-162(ra) # 80005e40 <plicinithart>
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
    80000f56:	85c080e7          	jalr	-1956(ra) # 800027ae <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	87c080e7          	jalr	-1924(ra) # 800027d6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	ec8080e7          	jalr	-312(ra) # 80005e2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	ed6080e7          	jalr	-298(ra) # 80005e40 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	086080e7          	jalr	134(ra) # 80002ff8 <binit>
    iinit();         // inode table
    80000f7a:	00002097          	auipc	ra,0x2
    80000f7e:	72a080e7          	jalr	1834(ra) # 800036a4 <iinit>
    fileinit();      // file table
    80000f82:	00003097          	auipc	ra,0x3
    80000f86:	6c8080e7          	jalr	1736(ra) # 8000464a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	fbe080e7          	jalr	-66(ra) # 80005f48 <virtio_disk_init>
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
    80001a24:	e307a783          	lw	a5,-464(a5) # 80008850 <first.1702>
    80001a28:	eb89                	bnez	a5,80001a3a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a2a:	00001097          	auipc	ra,0x1
    80001a2e:	dc4080e7          	jalr	-572(ra) # 800027ee <usertrapret>
}
    80001a32:	60a2                	ld	ra,8(sp)
    80001a34:	6402                	ld	s0,0(sp)
    80001a36:	0141                	addi	sp,sp,16
    80001a38:	8082                	ret
    first = 0;
    80001a3a:	00007797          	auipc	a5,0x7
    80001a3e:	e007ab23          	sw	zero,-490(a5) # 80008850 <first.1702>
    fsinit(ROOTDEV);
    80001a42:	4505                	li	a0,1
    80001a44:	00002097          	auipc	ra,0x2
    80001a48:	be0080e7          	jalr	-1056(ra) # 80003624 <fsinit>
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
    80001d0a:	340080e7          	jalr	832(ra) # 80004046 <namei>
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
    80001e28:	8b8080e7          	jalr	-1864(ra) # 800046dc <filedup>
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
    80001e4a:	a1c080e7          	jalr	-1508(ra) # 80003862 <idup>
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
    80001ec2:	715d                	addi	sp,sp,-80
    80001ec4:	e486                	sd	ra,72(sp)
    80001ec6:	e0a2                	sd	s0,64(sp)
    80001ec8:	fc26                	sd	s1,56(sp)
    80001eca:	f84a                	sd	s2,48(sp)
    80001ecc:	f44e                	sd	s3,40(sp)
    80001ece:	f052                	sd	s4,32(sp)
    80001ed0:	ec56                	sd	s5,24(sp)
    80001ed2:	e85a                	sd	s6,16(sp)
    80001ed4:	e45e                	sd	s7,8(sp)
    80001ed6:	e062                	sd	s8,0(sp)
    80001ed8:	0880                	addi	s0,sp,80
    80001eda:	8792                	mv	a5,tp
  int id = r_tp();
    80001edc:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ede:	00779b13          	slli	s6,a5,0x7
    80001ee2:	0000f717          	auipc	a4,0xf
    80001ee6:	c7e70713          	addi	a4,a4,-898 # 80010b60 <pid_lock>
    80001eea:	975a                	add	a4,a4,s6
    80001eec:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ef0:	0000f717          	auipc	a4,0xf
    80001ef4:	ca870713          	addi	a4,a4,-856 # 80010b98 <cpus+0x8>
    80001ef8:	9b3a                	add	s6,s6,a4
      if(p->state == RUNNABLE && p->priority < highest_prio){
    80001efa:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++){
    80001efc:	00015917          	auipc	s2,0x15
    80001f00:	a9490913          	addi	s2,s2,-1388 # 80016990 <tickslock>
        p->state = RUNNING;
    80001f04:	4b91                	li	s7,4
        c->proc = p;
    80001f06:	079e                	slli	a5,a5,0x7
    80001f08:	0000fa97          	auipc	s5,0xf
    80001f0c:	c58a8a93          	addi	s5,s5,-936 # 80010b60 <pid_lock>
    80001f10:	9abe                	add	s5,s5,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f16:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f1a:	10079073          	csrw	sstatus,a5
    80001f1e:	4a55                	li	s4,21
    for(p = proc; p < &proc[NPROC]; p++){
    80001f20:	0000f497          	auipc	s1,0xf
    80001f24:	07048493          	addi	s1,s1,112 # 80010f90 <proc>
    80001f28:	a821                	j	80001f40 <scheduler+0x7e>
    80001f2a:	00078a1b          	sext.w	s4,a5
      release(&p->lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	d6e080e7          	jalr	-658(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001f38:	16848493          	addi	s1,s1,360
    80001f3c:	03248163          	beq	s1,s2,80001f5e <scheduler+0x9c>
      acquire(&p->lock);
    80001f40:	8526                	mv	a0,s1
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	ca8080e7          	jalr	-856(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE && p->priority < highest_prio){
    80001f4a:	4c9c                	lw	a5,24(s1)
    80001f4c:	ff3791e3          	bne	a5,s3,80001f2e <scheduler+0x6c>
    80001f50:	58dc                	lw	a5,52(s1)
    80001f52:	0007871b          	sext.w	a4,a5
    80001f56:	fcea5ae3          	bge	s4,a4,80001f2a <scheduler+0x68>
    80001f5a:	87d2                	mv	a5,s4
    80001f5c:	b7f9                	j	80001f2a <scheduler+0x68>
    for(p = proc; p < &proc[NPROC]; p++){
    80001f5e:	0000f497          	auipc	s1,0xf
    80001f62:	03248493          	addi	s1,s1,50 # 80010f90 <proc>
    80001f66:	a03d                	j	80001f94 <scheduler+0xd2>
        p->state = RUNNING;
    80001f68:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001f6c:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001f70:	06048593          	addi	a1,s1,96
    80001f74:	855a                	mv	a0,s6
    80001f76:	00000097          	auipc	ra,0x0
    80001f7a:	7ce080e7          	jalr	1998(ra) # 80002744 <swtch>
        c->proc = 0;
    80001f7e:	020ab823          	sd	zero,48(s5)
      release(&p->lock);
    80001f82:	8526                	mv	a0,s1
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	d1a080e7          	jalr	-742(ra) # 80000c9e <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001f8c:	16848493          	addi	s1,s1,360
    80001f90:	f92481e3          	beq	s1,s2,80001f12 <scheduler+0x50>
      acquire(&p->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	c54080e7          	jalr	-940(ra) # 80000bea <acquire>
      if(p->state == RUNNABLE && p->priority <= highest_prio){
    80001f9e:	4c9c                	lw	a5,24(s1)
    80001fa0:	ff3791e3          	bne	a5,s3,80001f82 <scheduler+0xc0>
    80001fa4:	58dc                	lw	a5,52(s1)
    80001fa6:	fcfa4ee3          	blt	s4,a5,80001f82 <scheduler+0xc0>
    80001faa:	bf7d                	j	80001f68 <scheduler+0xa6>

0000000080001fac <sched>:
{
    80001fac:	7179                	addi	sp,sp,-48
    80001fae:	f406                	sd	ra,40(sp)
    80001fb0:	f022                	sd	s0,32(sp)
    80001fb2:	ec26                	sd	s1,24(sp)
    80001fb4:	e84a                	sd	s2,16(sp)
    80001fb6:	e44e                	sd	s3,8(sp)
    80001fb8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fba:	00000097          	auipc	ra,0x0
    80001fbe:	a16080e7          	jalr	-1514(ra) # 800019d0 <myproc>
    80001fc2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	bac080e7          	jalr	-1108(ra) # 80000b70 <holding>
    80001fcc:	c93d                	beqz	a0,80002042 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fce:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fd0:	2781                	sext.w	a5,a5
    80001fd2:	079e                	slli	a5,a5,0x7
    80001fd4:	0000f717          	auipc	a4,0xf
    80001fd8:	b8c70713          	addi	a4,a4,-1140 # 80010b60 <pid_lock>
    80001fdc:	97ba                	add	a5,a5,a4
    80001fde:	0a87a703          	lw	a4,168(a5)
    80001fe2:	4785                	li	a5,1
    80001fe4:	06f71763          	bne	a4,a5,80002052 <sched+0xa6>
  if(p->state == RUNNING)
    80001fe8:	4c98                	lw	a4,24(s1)
    80001fea:	4791                	li	a5,4
    80001fec:	06f70b63          	beq	a4,a5,80002062 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ff0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ff4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001ff6:	efb5                	bnez	a5,80002072 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ff8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ffa:	0000f917          	auipc	s2,0xf
    80001ffe:	b6690913          	addi	s2,s2,-1178 # 80010b60 <pid_lock>
    80002002:	2781                	sext.w	a5,a5
    80002004:	079e                	slli	a5,a5,0x7
    80002006:	97ca                	add	a5,a5,s2
    80002008:	0ac7a983          	lw	s3,172(a5)
    8000200c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000200e:	2781                	sext.w	a5,a5
    80002010:	079e                	slli	a5,a5,0x7
    80002012:	0000f597          	auipc	a1,0xf
    80002016:	b8658593          	addi	a1,a1,-1146 # 80010b98 <cpus+0x8>
    8000201a:	95be                	add	a1,a1,a5
    8000201c:	06048513          	addi	a0,s1,96
    80002020:	00000097          	auipc	ra,0x0
    80002024:	724080e7          	jalr	1828(ra) # 80002744 <swtch>
    80002028:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000202a:	2781                	sext.w	a5,a5
    8000202c:	079e                	slli	a5,a5,0x7
    8000202e:	97ca                	add	a5,a5,s2
    80002030:	0b37a623          	sw	s3,172(a5)
}
    80002034:	70a2                	ld	ra,40(sp)
    80002036:	7402                	ld	s0,32(sp)
    80002038:	64e2                	ld	s1,24(sp)
    8000203a:	6942                	ld	s2,16(sp)
    8000203c:	69a2                	ld	s3,8(sp)
    8000203e:	6145                	addi	sp,sp,48
    80002040:	8082                	ret
    panic("sched p->lock");
    80002042:	00006517          	auipc	a0,0x6
    80002046:	1d650513          	addi	a0,a0,470 # 80008218 <digits+0x1d8>
    8000204a:	ffffe097          	auipc	ra,0xffffe
    8000204e:	4fa080e7          	jalr	1274(ra) # 80000544 <panic>
    panic("sched locks");
    80002052:	00006517          	auipc	a0,0x6
    80002056:	1d650513          	addi	a0,a0,470 # 80008228 <digits+0x1e8>
    8000205a:	ffffe097          	auipc	ra,0xffffe
    8000205e:	4ea080e7          	jalr	1258(ra) # 80000544 <panic>
    panic("sched running");
    80002062:	00006517          	auipc	a0,0x6
    80002066:	1d650513          	addi	a0,a0,470 # 80008238 <digits+0x1f8>
    8000206a:	ffffe097          	auipc	ra,0xffffe
    8000206e:	4da080e7          	jalr	1242(ra) # 80000544 <panic>
    panic("sched interruptible");
    80002072:	00006517          	auipc	a0,0x6
    80002076:	1d650513          	addi	a0,a0,470 # 80008248 <digits+0x208>
    8000207a:	ffffe097          	auipc	ra,0xffffe
    8000207e:	4ca080e7          	jalr	1226(ra) # 80000544 <panic>

0000000080002082 <yield>:
{
    80002082:	1101                	addi	sp,sp,-32
    80002084:	ec06                	sd	ra,24(sp)
    80002086:	e822                	sd	s0,16(sp)
    80002088:	e426                	sd	s1,8(sp)
    8000208a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000208c:	00000097          	auipc	ra,0x0
    80002090:	944080e7          	jalr	-1724(ra) # 800019d0 <myproc>
    80002094:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002096:	fffff097          	auipc	ra,0xfffff
    8000209a:	b54080e7          	jalr	-1196(ra) # 80000bea <acquire>
  p->state = RUNNABLE;
    8000209e:	478d                	li	a5,3
    800020a0:	cc9c                	sw	a5,24(s1)
  sched();
    800020a2:	00000097          	auipc	ra,0x0
    800020a6:	f0a080e7          	jalr	-246(ra) # 80001fac <sched>
  release(&p->lock);
    800020aa:	8526                	mv	a0,s1
    800020ac:	fffff097          	auipc	ra,0xfffff
    800020b0:	bf2080e7          	jalr	-1038(ra) # 80000c9e <release>
}
    800020b4:	60e2                	ld	ra,24(sp)
    800020b6:	6442                	ld	s0,16(sp)
    800020b8:	64a2                	ld	s1,8(sp)
    800020ba:	6105                	addi	sp,sp,32
    800020bc:	8082                	ret

00000000800020be <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020be:	7179                	addi	sp,sp,-48
    800020c0:	f406                	sd	ra,40(sp)
    800020c2:	f022                	sd	s0,32(sp)
    800020c4:	ec26                	sd	s1,24(sp)
    800020c6:	e84a                	sd	s2,16(sp)
    800020c8:	e44e                	sd	s3,8(sp)
    800020ca:	1800                	addi	s0,sp,48
    800020cc:	89aa                	mv	s3,a0
    800020ce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	900080e7          	jalr	-1792(ra) # 800019d0 <myproc>
    800020d8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	b10080e7          	jalr	-1264(ra) # 80000bea <acquire>
  release(lk);
    800020e2:	854a                	mv	a0,s2
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	bba080e7          	jalr	-1094(ra) # 80000c9e <release>

  // Go to sleep.
  p->chan = chan;
    800020ec:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020f0:	4789                	li	a5,2
    800020f2:	cc9c                	sw	a5,24(s1)

  sched();
    800020f4:	00000097          	auipc	ra,0x0
    800020f8:	eb8080e7          	jalr	-328(ra) # 80001fac <sched>

  // Tidy up.
  p->chan = 0;
    800020fc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	b9c080e7          	jalr	-1124(ra) # 80000c9e <release>
  acquire(lk);
    8000210a:	854a                	mv	a0,s2
    8000210c:	fffff097          	auipc	ra,0xfffff
    80002110:	ade080e7          	jalr	-1314(ra) # 80000bea <acquire>
}
    80002114:	70a2                	ld	ra,40(sp)
    80002116:	7402                	ld	s0,32(sp)
    80002118:	64e2                	ld	s1,24(sp)
    8000211a:	6942                	ld	s2,16(sp)
    8000211c:	69a2                	ld	s3,8(sp)
    8000211e:	6145                	addi	sp,sp,48
    80002120:	8082                	ret

0000000080002122 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002122:	7139                	addi	sp,sp,-64
    80002124:	fc06                	sd	ra,56(sp)
    80002126:	f822                	sd	s0,48(sp)
    80002128:	f426                	sd	s1,40(sp)
    8000212a:	f04a                	sd	s2,32(sp)
    8000212c:	ec4e                	sd	s3,24(sp)
    8000212e:	e852                	sd	s4,16(sp)
    80002130:	e456                	sd	s5,8(sp)
    80002132:	0080                	addi	s0,sp,64
    80002134:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002136:	0000f497          	auipc	s1,0xf
    8000213a:	e5a48493          	addi	s1,s1,-422 # 80010f90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000213e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002140:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002142:	00015917          	auipc	s2,0x15
    80002146:	84e90913          	addi	s2,s2,-1970 # 80016990 <tickslock>
    8000214a:	a821                	j	80002162 <wakeup+0x40>
        p->state = RUNNABLE;
    8000214c:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	b4c080e7          	jalr	-1204(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000215a:	16848493          	addi	s1,s1,360
    8000215e:	03248463          	beq	s1,s2,80002186 <wakeup+0x64>
    if(p != myproc()){
    80002162:	00000097          	auipc	ra,0x0
    80002166:	86e080e7          	jalr	-1938(ra) # 800019d0 <myproc>
    8000216a:	fea488e3          	beq	s1,a0,8000215a <wakeup+0x38>
      acquire(&p->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	a7a080e7          	jalr	-1414(ra) # 80000bea <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002178:	4c9c                	lw	a5,24(s1)
    8000217a:	fd379be3          	bne	a5,s3,80002150 <wakeup+0x2e>
    8000217e:	709c                	ld	a5,32(s1)
    80002180:	fd4798e3          	bne	a5,s4,80002150 <wakeup+0x2e>
    80002184:	b7e1                	j	8000214c <wakeup+0x2a>
    }
  }
}
    80002186:	70e2                	ld	ra,56(sp)
    80002188:	7442                	ld	s0,48(sp)
    8000218a:	74a2                	ld	s1,40(sp)
    8000218c:	7902                	ld	s2,32(sp)
    8000218e:	69e2                	ld	s3,24(sp)
    80002190:	6a42                	ld	s4,16(sp)
    80002192:	6aa2                	ld	s5,8(sp)
    80002194:	6121                	addi	sp,sp,64
    80002196:	8082                	ret

0000000080002198 <reparent>:
{
    80002198:	7179                	addi	sp,sp,-48
    8000219a:	f406                	sd	ra,40(sp)
    8000219c:	f022                	sd	s0,32(sp)
    8000219e:	ec26                	sd	s1,24(sp)
    800021a0:	e84a                	sd	s2,16(sp)
    800021a2:	e44e                	sd	s3,8(sp)
    800021a4:	e052                	sd	s4,0(sp)
    800021a6:	1800                	addi	s0,sp,48
    800021a8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021aa:	0000f497          	auipc	s1,0xf
    800021ae:	de648493          	addi	s1,s1,-538 # 80010f90 <proc>
      pp->parent = initproc;
    800021b2:	00006a17          	auipc	s4,0x6
    800021b6:	736a0a13          	addi	s4,s4,1846 # 800088e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ba:	00014997          	auipc	s3,0x14
    800021be:	7d698993          	addi	s3,s3,2006 # 80016990 <tickslock>
    800021c2:	a029                	j	800021cc <reparent+0x34>
    800021c4:	16848493          	addi	s1,s1,360
    800021c8:	01348d63          	beq	s1,s3,800021e2 <reparent+0x4a>
    if(pp->parent == p){
    800021cc:	7c9c                	ld	a5,56(s1)
    800021ce:	ff279be3          	bne	a5,s2,800021c4 <reparent+0x2c>
      pp->parent = initproc;
    800021d2:	000a3503          	ld	a0,0(s4)
    800021d6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021d8:	00000097          	auipc	ra,0x0
    800021dc:	f4a080e7          	jalr	-182(ra) # 80002122 <wakeup>
    800021e0:	b7d5                	j	800021c4 <reparent+0x2c>
}
    800021e2:	70a2                	ld	ra,40(sp)
    800021e4:	7402                	ld	s0,32(sp)
    800021e6:	64e2                	ld	s1,24(sp)
    800021e8:	6942                	ld	s2,16(sp)
    800021ea:	69a2                	ld	s3,8(sp)
    800021ec:	6a02                	ld	s4,0(sp)
    800021ee:	6145                	addi	sp,sp,48
    800021f0:	8082                	ret

00000000800021f2 <exit>:
{
    800021f2:	7179                	addi	sp,sp,-48
    800021f4:	f406                	sd	ra,40(sp)
    800021f6:	f022                	sd	s0,32(sp)
    800021f8:	ec26                	sd	s1,24(sp)
    800021fa:	e84a                	sd	s2,16(sp)
    800021fc:	e44e                	sd	s3,8(sp)
    800021fe:	e052                	sd	s4,0(sp)
    80002200:	1800                	addi	s0,sp,48
    80002202:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	7cc080e7          	jalr	1996(ra) # 800019d0 <myproc>
    8000220c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000220e:	00006797          	auipc	a5,0x6
    80002212:	6da7b783          	ld	a5,1754(a5) # 800088e8 <initproc>
    80002216:	0d050493          	addi	s1,a0,208
    8000221a:	15050913          	addi	s2,a0,336
    8000221e:	02a79363          	bne	a5,a0,80002244 <exit+0x52>
    panic("init exiting");
    80002222:	00006517          	auipc	a0,0x6
    80002226:	03e50513          	addi	a0,a0,62 # 80008260 <digits+0x220>
    8000222a:	ffffe097          	auipc	ra,0xffffe
    8000222e:	31a080e7          	jalr	794(ra) # 80000544 <panic>
      fileclose(f);
    80002232:	00002097          	auipc	ra,0x2
    80002236:	4fc080e7          	jalr	1276(ra) # 8000472e <fileclose>
      p->ofile[fd] = 0;
    8000223a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000223e:	04a1                	addi	s1,s1,8
    80002240:	01248563          	beq	s1,s2,8000224a <exit+0x58>
    if(p->ofile[fd]){
    80002244:	6088                	ld	a0,0(s1)
    80002246:	f575                	bnez	a0,80002232 <exit+0x40>
    80002248:	bfdd                	j	8000223e <exit+0x4c>
  begin_op();
    8000224a:	00002097          	auipc	ra,0x2
    8000224e:	018080e7          	jalr	24(ra) # 80004262 <begin_op>
  iput(p->cwd);
    80002252:	1509b503          	ld	a0,336(s3)
    80002256:	00002097          	auipc	ra,0x2
    8000225a:	804080e7          	jalr	-2044(ra) # 80003a5a <iput>
  end_op();
    8000225e:	00002097          	auipc	ra,0x2
    80002262:	084080e7          	jalr	132(ra) # 800042e2 <end_op>
  p->cwd = 0;
    80002266:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000226a:	0000f497          	auipc	s1,0xf
    8000226e:	90e48493          	addi	s1,s1,-1778 # 80010b78 <wait_lock>
    80002272:	8526                	mv	a0,s1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	976080e7          	jalr	-1674(ra) # 80000bea <acquire>
  reparent(p);
    8000227c:	854e                	mv	a0,s3
    8000227e:	00000097          	auipc	ra,0x0
    80002282:	f1a080e7          	jalr	-230(ra) # 80002198 <reparent>
  wakeup(p->parent);
    80002286:	0389b503          	ld	a0,56(s3)
    8000228a:	00000097          	auipc	ra,0x0
    8000228e:	e98080e7          	jalr	-360(ra) # 80002122 <wakeup>
  acquire(&p->lock);
    80002292:	854e                	mv	a0,s3
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	956080e7          	jalr	-1706(ra) # 80000bea <acquire>
  p->xstate = status;
    8000229c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022a0:	4795                	li	a5,5
    800022a2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022a6:	8526                	mv	a0,s1
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	9f6080e7          	jalr	-1546(ra) # 80000c9e <release>
  sched();
    800022b0:	00000097          	auipc	ra,0x0
    800022b4:	cfc080e7          	jalr	-772(ra) # 80001fac <sched>
  panic("zombie exit");
    800022b8:	00006517          	auipc	a0,0x6
    800022bc:	fb850513          	addi	a0,a0,-72 # 80008270 <digits+0x230>
    800022c0:	ffffe097          	auipc	ra,0xffffe
    800022c4:	284080e7          	jalr	644(ra) # 80000544 <panic>

00000000800022c8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022c8:	7179                	addi	sp,sp,-48
    800022ca:	f406                	sd	ra,40(sp)
    800022cc:	f022                	sd	s0,32(sp)
    800022ce:	ec26                	sd	s1,24(sp)
    800022d0:	e84a                	sd	s2,16(sp)
    800022d2:	e44e                	sd	s3,8(sp)
    800022d4:	1800                	addi	s0,sp,48
    800022d6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022d8:	0000f497          	auipc	s1,0xf
    800022dc:	cb848493          	addi	s1,s1,-840 # 80010f90 <proc>
    800022e0:	00014997          	auipc	s3,0x14
    800022e4:	6b098993          	addi	s3,s3,1712 # 80016990 <tickslock>
    acquire(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	900080e7          	jalr	-1792(ra) # 80000bea <acquire>
    if(p->pid == pid){
    800022f2:	589c                	lw	a5,48(s1)
    800022f4:	01278d63          	beq	a5,s2,8000230e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	9a4080e7          	jalr	-1628(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002302:	16848493          	addi	s1,s1,360
    80002306:	ff3491e3          	bne	s1,s3,800022e8 <kill+0x20>
  }
  return -1;
    8000230a:	557d                	li	a0,-1
    8000230c:	a829                	j	80002326 <kill+0x5e>
      p->killed = 1;
    8000230e:	4785                	li	a5,1
    80002310:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002312:	4c98                	lw	a4,24(s1)
    80002314:	4789                	li	a5,2
    80002316:	00f70f63          	beq	a4,a5,80002334 <kill+0x6c>
      release(&p->lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	982080e7          	jalr	-1662(ra) # 80000c9e <release>
      return 0;
    80002324:	4501                	li	a0,0
}
    80002326:	70a2                	ld	ra,40(sp)
    80002328:	7402                	ld	s0,32(sp)
    8000232a:	64e2                	ld	s1,24(sp)
    8000232c:	6942                	ld	s2,16(sp)
    8000232e:	69a2                	ld	s3,8(sp)
    80002330:	6145                	addi	sp,sp,48
    80002332:	8082                	ret
        p->state = RUNNABLE;
    80002334:	478d                	li	a5,3
    80002336:	cc9c                	sw	a5,24(s1)
    80002338:	b7cd                	j	8000231a <kill+0x52>

000000008000233a <setkilled>:

void
setkilled(struct proc *p)
{
    8000233a:	1101                	addi	sp,sp,-32
    8000233c:	ec06                	sd	ra,24(sp)
    8000233e:	e822                	sd	s0,16(sp)
    80002340:	e426                	sd	s1,8(sp)
    80002342:	1000                	addi	s0,sp,32
    80002344:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	8a4080e7          	jalr	-1884(ra) # 80000bea <acquire>
  p->killed = 1;
    8000234e:	4785                	li	a5,1
    80002350:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002352:	8526                	mv	a0,s1
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	94a080e7          	jalr	-1718(ra) # 80000c9e <release>
}
    8000235c:	60e2                	ld	ra,24(sp)
    8000235e:	6442                	ld	s0,16(sp)
    80002360:	64a2                	ld	s1,8(sp)
    80002362:	6105                	addi	sp,sp,32
    80002364:	8082                	ret

0000000080002366 <killed>:

int
killed(struct proc *p)
{
    80002366:	1101                	addi	sp,sp,-32
    80002368:	ec06                	sd	ra,24(sp)
    8000236a:	e822                	sd	s0,16(sp)
    8000236c:	e426                	sd	s1,8(sp)
    8000236e:	e04a                	sd	s2,0(sp)
    80002370:	1000                	addi	s0,sp,32
    80002372:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	876080e7          	jalr	-1930(ra) # 80000bea <acquire>
  k = p->killed;
    8000237c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002380:	8526                	mv	a0,s1
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	91c080e7          	jalr	-1764(ra) # 80000c9e <release>
  return k;
}
    8000238a:	854a                	mv	a0,s2
    8000238c:	60e2                	ld	ra,24(sp)
    8000238e:	6442                	ld	s0,16(sp)
    80002390:	64a2                	ld	s1,8(sp)
    80002392:	6902                	ld	s2,0(sp)
    80002394:	6105                	addi	sp,sp,32
    80002396:	8082                	ret

0000000080002398 <wait>:
{
    80002398:	715d                	addi	sp,sp,-80
    8000239a:	e486                	sd	ra,72(sp)
    8000239c:	e0a2                	sd	s0,64(sp)
    8000239e:	fc26                	sd	s1,56(sp)
    800023a0:	f84a                	sd	s2,48(sp)
    800023a2:	f44e                	sd	s3,40(sp)
    800023a4:	f052                	sd	s4,32(sp)
    800023a6:	ec56                	sd	s5,24(sp)
    800023a8:	e85a                	sd	s6,16(sp)
    800023aa:	e45e                	sd	s7,8(sp)
    800023ac:	e062                	sd	s8,0(sp)
    800023ae:	0880                	addi	s0,sp,80
    800023b0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	61e080e7          	jalr	1566(ra) # 800019d0 <myproc>
    800023ba:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023bc:	0000e517          	auipc	a0,0xe
    800023c0:	7bc50513          	addi	a0,a0,1980 # 80010b78 <wait_lock>
    800023c4:	fffff097          	auipc	ra,0xfffff
    800023c8:	826080e7          	jalr	-2010(ra) # 80000bea <acquire>
    havekids = 0;
    800023cc:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023ce:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023d0:	00014997          	auipc	s3,0x14
    800023d4:	5c098993          	addi	s3,s3,1472 # 80016990 <tickslock>
        havekids = 1;
    800023d8:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023da:	0000ec17          	auipc	s8,0xe
    800023de:	79ec0c13          	addi	s8,s8,1950 # 80010b78 <wait_lock>
    havekids = 0;
    800023e2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e4:	0000f497          	auipc	s1,0xf
    800023e8:	bac48493          	addi	s1,s1,-1108 # 80010f90 <proc>
    800023ec:	a0bd                	j	8000245a <wait+0xc2>
          pid = pp->pid;
    800023ee:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023f2:	000b0e63          	beqz	s6,8000240e <wait+0x76>
    800023f6:	4691                	li	a3,4
    800023f8:	02c48613          	addi	a2,s1,44
    800023fc:	85da                	mv	a1,s6
    800023fe:	05093503          	ld	a0,80(s2)
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	282080e7          	jalr	642(ra) # 80001684 <copyout>
    8000240a:	02054563          	bltz	a0,80002434 <wait+0x9c>
          freeproc(pp);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	772080e7          	jalr	1906(ra) # 80001b82 <freeproc>
          release(&pp->lock);
    80002418:	8526                	mv	a0,s1
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	884080e7          	jalr	-1916(ra) # 80000c9e <release>
          release(&wait_lock);
    80002422:	0000e517          	auipc	a0,0xe
    80002426:	75650513          	addi	a0,a0,1878 # 80010b78 <wait_lock>
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	874080e7          	jalr	-1932(ra) # 80000c9e <release>
          return pid;
    80002432:	a0b5                	j	8000249e <wait+0x106>
            release(&pp->lock);
    80002434:	8526                	mv	a0,s1
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	868080e7          	jalr	-1944(ra) # 80000c9e <release>
            release(&wait_lock);
    8000243e:	0000e517          	auipc	a0,0xe
    80002442:	73a50513          	addi	a0,a0,1850 # 80010b78 <wait_lock>
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	858080e7          	jalr	-1960(ra) # 80000c9e <release>
            return -1;
    8000244e:	59fd                	li	s3,-1
    80002450:	a0b9                	j	8000249e <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002452:	16848493          	addi	s1,s1,360
    80002456:	03348463          	beq	s1,s3,8000247e <wait+0xe6>
      if(pp->parent == p){
    8000245a:	7c9c                	ld	a5,56(s1)
    8000245c:	ff279be3          	bne	a5,s2,80002452 <wait+0xba>
        acquire(&pp->lock);
    80002460:	8526                	mv	a0,s1
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	788080e7          	jalr	1928(ra) # 80000bea <acquire>
        if(pp->state == ZOMBIE){
    8000246a:	4c9c                	lw	a5,24(s1)
    8000246c:	f94781e3          	beq	a5,s4,800023ee <wait+0x56>
        release(&pp->lock);
    80002470:	8526                	mv	a0,s1
    80002472:	fffff097          	auipc	ra,0xfffff
    80002476:	82c080e7          	jalr	-2004(ra) # 80000c9e <release>
        havekids = 1;
    8000247a:	8756                	mv	a4,s5
    8000247c:	bfd9                	j	80002452 <wait+0xba>
    if(!havekids || killed(p)){
    8000247e:	c719                	beqz	a4,8000248c <wait+0xf4>
    80002480:	854a                	mv	a0,s2
    80002482:	00000097          	auipc	ra,0x0
    80002486:	ee4080e7          	jalr	-284(ra) # 80002366 <killed>
    8000248a:	c51d                	beqz	a0,800024b8 <wait+0x120>
      release(&wait_lock);
    8000248c:	0000e517          	auipc	a0,0xe
    80002490:	6ec50513          	addi	a0,a0,1772 # 80010b78 <wait_lock>
    80002494:	fffff097          	auipc	ra,0xfffff
    80002498:	80a080e7          	jalr	-2038(ra) # 80000c9e <release>
      return -1;
    8000249c:	59fd                	li	s3,-1
}
    8000249e:	854e                	mv	a0,s3
    800024a0:	60a6                	ld	ra,72(sp)
    800024a2:	6406                	ld	s0,64(sp)
    800024a4:	74e2                	ld	s1,56(sp)
    800024a6:	7942                	ld	s2,48(sp)
    800024a8:	79a2                	ld	s3,40(sp)
    800024aa:	7a02                	ld	s4,32(sp)
    800024ac:	6ae2                	ld	s5,24(sp)
    800024ae:	6b42                	ld	s6,16(sp)
    800024b0:	6ba2                	ld	s7,8(sp)
    800024b2:	6c02                	ld	s8,0(sp)
    800024b4:	6161                	addi	sp,sp,80
    800024b6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024b8:	85e2                	mv	a1,s8
    800024ba:	854a                	mv	a0,s2
    800024bc:	00000097          	auipc	ra,0x0
    800024c0:	c02080e7          	jalr	-1022(ra) # 800020be <sleep>
    havekids = 0;
    800024c4:	bf39                	j	800023e2 <wait+0x4a>

00000000800024c6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024c6:	7179                	addi	sp,sp,-48
    800024c8:	f406                	sd	ra,40(sp)
    800024ca:	f022                	sd	s0,32(sp)
    800024cc:	ec26                	sd	s1,24(sp)
    800024ce:	e84a                	sd	s2,16(sp)
    800024d0:	e44e                	sd	s3,8(sp)
    800024d2:	e052                	sd	s4,0(sp)
    800024d4:	1800                	addi	s0,sp,48
    800024d6:	84aa                	mv	s1,a0
    800024d8:	892e                	mv	s2,a1
    800024da:	89b2                	mv	s3,a2
    800024dc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024de:	fffff097          	auipc	ra,0xfffff
    800024e2:	4f2080e7          	jalr	1266(ra) # 800019d0 <myproc>
  if(user_dst){
    800024e6:	c08d                	beqz	s1,80002508 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024e8:	86d2                	mv	a3,s4
    800024ea:	864e                	mv	a2,s3
    800024ec:	85ca                	mv	a1,s2
    800024ee:	6928                	ld	a0,80(a0)
    800024f0:	fffff097          	auipc	ra,0xfffff
    800024f4:	194080e7          	jalr	404(ra) # 80001684 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024f8:	70a2                	ld	ra,40(sp)
    800024fa:	7402                	ld	s0,32(sp)
    800024fc:	64e2                	ld	s1,24(sp)
    800024fe:	6942                	ld	s2,16(sp)
    80002500:	69a2                	ld	s3,8(sp)
    80002502:	6a02                	ld	s4,0(sp)
    80002504:	6145                	addi	sp,sp,48
    80002506:	8082                	ret
    memmove((char *)dst, src, len);
    80002508:	000a061b          	sext.w	a2,s4
    8000250c:	85ce                	mv	a1,s3
    8000250e:	854a                	mv	a0,s2
    80002510:	fffff097          	auipc	ra,0xfffff
    80002514:	836080e7          	jalr	-1994(ra) # 80000d46 <memmove>
    return 0;
    80002518:	8526                	mv	a0,s1
    8000251a:	bff9                	j	800024f8 <either_copyout+0x32>

000000008000251c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000251c:	7179                	addi	sp,sp,-48
    8000251e:	f406                	sd	ra,40(sp)
    80002520:	f022                	sd	s0,32(sp)
    80002522:	ec26                	sd	s1,24(sp)
    80002524:	e84a                	sd	s2,16(sp)
    80002526:	e44e                	sd	s3,8(sp)
    80002528:	e052                	sd	s4,0(sp)
    8000252a:	1800                	addi	s0,sp,48
    8000252c:	892a                	mv	s2,a0
    8000252e:	84ae                	mv	s1,a1
    80002530:	89b2                	mv	s3,a2
    80002532:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002534:	fffff097          	auipc	ra,0xfffff
    80002538:	49c080e7          	jalr	1180(ra) # 800019d0 <myproc>
  if(user_src){
    8000253c:	c08d                	beqz	s1,8000255e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000253e:	86d2                	mv	a3,s4
    80002540:	864e                	mv	a2,s3
    80002542:	85ca                	mv	a1,s2
    80002544:	6928                	ld	a0,80(a0)
    80002546:	fffff097          	auipc	ra,0xfffff
    8000254a:	1ca080e7          	jalr	458(ra) # 80001710 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000254e:	70a2                	ld	ra,40(sp)
    80002550:	7402                	ld	s0,32(sp)
    80002552:	64e2                	ld	s1,24(sp)
    80002554:	6942                	ld	s2,16(sp)
    80002556:	69a2                	ld	s3,8(sp)
    80002558:	6a02                	ld	s4,0(sp)
    8000255a:	6145                	addi	sp,sp,48
    8000255c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000255e:	000a061b          	sext.w	a2,s4
    80002562:	85ce                	mv	a1,s3
    80002564:	854a                	mv	a0,s2
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	7e0080e7          	jalr	2016(ra) # 80000d46 <memmove>
    return 0;
    8000256e:	8526                	mv	a0,s1
    80002570:	bff9                	j	8000254e <either_copyin+0x32>

0000000080002572 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002572:	715d                	addi	sp,sp,-80
    80002574:	e486                	sd	ra,72(sp)
    80002576:	e0a2                	sd	s0,64(sp)
    80002578:	fc26                	sd	s1,56(sp)
    8000257a:	f84a                	sd	s2,48(sp)
    8000257c:	f44e                	sd	s3,40(sp)
    8000257e:	f052                	sd	s4,32(sp)
    80002580:	ec56                	sd	s5,24(sp)
    80002582:	e85a                	sd	s6,16(sp)
    80002584:	e45e                	sd	s7,8(sp)
    80002586:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002588:	00006517          	auipc	a0,0x6
    8000258c:	b4050513          	addi	a0,a0,-1216 # 800080c8 <digits+0x88>
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	ffe080e7          	jalr	-2(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002598:	0000f497          	auipc	s1,0xf
    8000259c:	b5048493          	addi	s1,s1,-1200 # 800110e8 <proc+0x158>
    800025a0:	00014917          	auipc	s2,0x14
    800025a4:	54890913          	addi	s2,s2,1352 # 80016ae8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025aa:	00006997          	auipc	s3,0x6
    800025ae:	cd698993          	addi	s3,s3,-810 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025b2:	00006a97          	auipc	s5,0x6
    800025b6:	cd6a8a93          	addi	s5,s5,-810 # 80008288 <digits+0x248>
    printf("\n");
    800025ba:	00006a17          	auipc	s4,0x6
    800025be:	b0ea0a13          	addi	s4,s4,-1266 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c2:	00006b97          	auipc	s7,0x6
    800025c6:	d06b8b93          	addi	s7,s7,-762 # 800082c8 <states.1746>
    800025ca:	a00d                	j	800025ec <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025cc:	ed86a583          	lw	a1,-296(a3)
    800025d0:	8556                	mv	a0,s5
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	fbc080e7          	jalr	-68(ra) # 8000058e <printf>
    printf("\n");
    800025da:	8552                	mv	a0,s4
    800025dc:	ffffe097          	auipc	ra,0xffffe
    800025e0:	fb2080e7          	jalr	-78(ra) # 8000058e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e4:	16848493          	addi	s1,s1,360
    800025e8:	03248163          	beq	s1,s2,8000260a <procdump+0x98>
    if(p->state == UNUSED)
    800025ec:	86a6                	mv	a3,s1
    800025ee:	ec04a783          	lw	a5,-320(s1)
    800025f2:	dbed                	beqz	a5,800025e4 <procdump+0x72>
      state = "???";
    800025f4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f6:	fcfb6be3          	bltu	s6,a5,800025cc <procdump+0x5a>
    800025fa:	1782                	slli	a5,a5,0x20
    800025fc:	9381                	srli	a5,a5,0x20
    800025fe:	078e                	slli	a5,a5,0x3
    80002600:	97de                	add	a5,a5,s7
    80002602:	6390                	ld	a2,0(a5)
    80002604:	f661                	bnez	a2,800025cc <procdump+0x5a>
      state = "???";
    80002606:	864e                	mv	a2,s3
    80002608:	b7d1                	j	800025cc <procdump+0x5a>
  }
}
    8000260a:	60a6                	ld	ra,72(sp)
    8000260c:	6406                	ld	s0,64(sp)
    8000260e:	74e2                	ld	s1,56(sp)
    80002610:	7942                	ld	s2,48(sp)
    80002612:	79a2                	ld	s3,40(sp)
    80002614:	7a02                	ld	s4,32(sp)
    80002616:	6ae2                	ld	s5,24(sp)
    80002618:	6b42                	ld	s6,16(sp)
    8000261a:	6ba2                	ld	s7,8(sp)
    8000261c:	6161                	addi	sp,sp,80
    8000261e:	8082                	ret

0000000080002620 <setpriority>:



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int setpriority(int priority)
{
    80002620:	1101                	addi	sp,sp,-32
    80002622:	ec06                	sd	ra,24(sp)
    80002624:	e822                	sd	s0,16(sp)
    80002626:	e426                	sd	s1,8(sp)
    80002628:	e04a                	sd	s2,0(sp)
    8000262a:	1000                	addi	s0,sp,32
    8000262c:	892a                	mv	s2,a0
  struct proc* current_proc = myproc();
    8000262e:	fffff097          	auipc	ra,0xfffff
    80002632:	3a2080e7          	jalr	930(ra) # 800019d0 <myproc>
    80002636:	84aa                	mv	s1,a0

  acquire(&current_proc->lock);
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	5b2080e7          	jalr	1458(ra) # 80000bea <acquire>

  //Priority given is not in the available bounds, or current process is null.
  if(priority < H_PRIO || priority > L_PRIO || !current_proc)
    80002640:	fff9071b          	addiw	a4,s2,-1
    80002644:	47cd                	li	a5,19
    80002646:	02e7e163          	bltu	a5,a4,80002668 <setpriority+0x48>
    8000264a:	c08d                	beqz	s1,8000266c <setpriority+0x4c>
    return  -1;

  //Set priority = priority.
  current_proc->priority = priority;  
    8000264c:	0324aa23          	sw	s2,52(s1)

  release(&current_proc->lock);
    80002650:	8526                	mv	a0,s1
    80002652:	ffffe097          	auipc	ra,0xffffe
    80002656:	64c080e7          	jalr	1612(ra) # 80000c9e <release>

  return 0;
    8000265a:	4501                	li	a0,0
}
    8000265c:	60e2                	ld	ra,24(sp)
    8000265e:	6442                	ld	s0,16(sp)
    80002660:	64a2                	ld	s1,8(sp)
    80002662:	6902                	ld	s2,0(sp)
    80002664:	6105                	addi	sp,sp,32
    80002666:	8082                	ret
    return  -1;
    80002668:	557d                	li	a0,-1
    8000266a:	bfcd                	j	8000265c <setpriority+0x3c>
    8000266c:	557d                	li	a0,-1
    8000266e:	b7fd                	j	8000265c <setpriority+0x3c>

0000000080002670 <getpinfo>:

int getpinfo(struct pstat* stats){
    80002670:	715d                	addi	sp,sp,-80
    80002672:	e486                	sd	ra,72(sp)
    80002674:	e0a2                	sd	s0,64(sp)
    80002676:	fc26                	sd	s1,56(sp)
    80002678:	f84a                	sd	s2,48(sp)
    8000267a:	f44e                	sd	s3,40(sp)
    8000267c:	f052                	sd	s4,32(sp)
    8000267e:	ec56                	sd	s5,24(sp)
    80002680:	e85a                	sd	s6,16(sp)
    80002682:	0880                	addi	s0,sp,80
    80002684:	8b2a                	mv	s6,a0
  struct proc* p;

  uint64 addr; 
  argaddr(0, &addr); //User pointer to struct pstat stored in addr variable.
    80002686:	fb840593          	addi	a1,s0,-72
    8000268a:	4501                	li	a0,0
    8000268c:	00000097          	auipc	ra,0x0
    80002690:	5e2080e7          	jalr	1506(ra) # 80002c6e <argaddr>

  int index = 0;
  for(p = proc; p < &proc[NPROC]; p++) {
    80002694:	895a                	mv	s2,s6
    80002696:	002b1a93          	slli	s5,s6,0x2
    8000269a:	415b0ab3          	sub	s5,s6,s5
    8000269e:	0000f497          	auipc	s1,0xf
    800026a2:	8f248493          	addi	s1,s1,-1806 # 80010f90 <proc>
      else  
        stats->ppid[index] = 0;

      stats->pid[index] = p->pid;
      stats->priority[index] = p->priority;
      strncpy(stats->name[index], p->name, 16);
    800026a6:	300a8a93          	addi	s5,s5,768
  for(p = proc; p < &proc[NPROC]; p++) {
    800026aa:	00014a17          	auipc	s4,0x14
    800026ae:	2e6a0a13          	addi	s4,s4,742 # 80016990 <tickslock>
    800026b2:	a081                	j	800026f2 <getpinfo+0x82>
        stats->ppid[index] = 0;
    800026b4:	10092023          	sw	zero,256(s2)
      stats->pid[index] = p->pid;
    800026b8:	589c                	lw	a5,48(s1)
    800026ba:	00f92023          	sw	a5,0(s2)
      stats->priority[index] = p->priority;
    800026be:	58dc                	lw	a5,52(s1)
    800026c0:	20f92023          	sw	a5,512(s2)
      strncpy(stats->name[index], p->name, 16);
    800026c4:	00291513          	slli	a0,s2,0x2
    800026c8:	4641                	li	a2,16
    800026ca:	15898593          	addi	a1,s3,344
    800026ce:	9556                	add	a0,a0,s5
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	72a080e7          	jalr	1834(ra) # 80000dfa <strncpy>
    }
    stats->state[index] = p->state;
    800026d8:	4c9c                	lw	a5,24(s1)
    800026da:	70f92023          	sw	a5,1792(s2)
    index++;

    release(&p->lock);
    800026de:	8526                	mv	a0,s1
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	5be080e7          	jalr	1470(ra) # 80000c9e <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026e8:	16848493          	addi	s1,s1,360
    800026ec:	0911                	addi	s2,s2,4
    800026ee:	03448063          	beq	s1,s4,8000270e <getpinfo+0x9e>
    acquire(&p->lock);
    800026f2:	89a6                	mv	s3,s1
    800026f4:	8526                	mv	a0,s1
    800026f6:	ffffe097          	auipc	ra,0xffffe
    800026fa:	4f4080e7          	jalr	1268(ra) # 80000bea <acquire>
    if(p->state != UNUSED){
    800026fe:	4c9c                	lw	a5,24(s1)
    80002700:	dfe1                	beqz	a5,800026d8 <getpinfo+0x68>
      if(p->parent != 0)
    80002702:	7c9c                	ld	a5,56(s1)
    80002704:	dbc5                	beqz	a5,800026b4 <getpinfo+0x44>
        stats->ppid[index] = p->parent->pid;
    80002706:	5b9c                	lw	a5,48(a5)
    80002708:	10f92023          	sw	a5,256(s2)
    8000270c:	b775                	j	800026b8 <getpinfo+0x48>
  }
  
  //Copy struct pstat from kernel to user.
  if(copyout(myproc()->pagetable, addr, (char *)stats, sizeof(struct pstat)) < 0)
    8000270e:	fffff097          	auipc	ra,0xfffff
    80002712:	2c2080e7          	jalr	706(ra) # 800019d0 <myproc>
    80002716:	6685                	lui	a3,0x1
    80002718:	80068693          	addi	a3,a3,-2048 # 800 <_entry-0x7ffff800>
    8000271c:	865a                	mv	a2,s6
    8000271e:	fb843583          	ld	a1,-72(s0)
    80002722:	6928                	ld	a0,80(a0)
    80002724:	fffff097          	auipc	ra,0xfffff
    80002728:	f60080e7          	jalr	-160(ra) # 80001684 <copyout>
    return -1;

  return 0;
    8000272c:	41f5551b          	sraiw	a0,a0,0x1f
    80002730:	60a6                	ld	ra,72(sp)
    80002732:	6406                	ld	s0,64(sp)
    80002734:	74e2                	ld	s1,56(sp)
    80002736:	7942                	ld	s2,48(sp)
    80002738:	79a2                	ld	s3,40(sp)
    8000273a:	7a02                	ld	s4,32(sp)
    8000273c:	6ae2                	ld	s5,24(sp)
    8000273e:	6b42                	ld	s6,16(sp)
    80002740:	6161                	addi	sp,sp,80
    80002742:	8082                	ret

0000000080002744 <swtch>:
    80002744:	00153023          	sd	ra,0(a0)
    80002748:	00253423          	sd	sp,8(a0)
    8000274c:	e900                	sd	s0,16(a0)
    8000274e:	ed04                	sd	s1,24(a0)
    80002750:	03253023          	sd	s2,32(a0)
    80002754:	03353423          	sd	s3,40(a0)
    80002758:	03453823          	sd	s4,48(a0)
    8000275c:	03553c23          	sd	s5,56(a0)
    80002760:	05653023          	sd	s6,64(a0)
    80002764:	05753423          	sd	s7,72(a0)
    80002768:	05853823          	sd	s8,80(a0)
    8000276c:	05953c23          	sd	s9,88(a0)
    80002770:	07a53023          	sd	s10,96(a0)
    80002774:	07b53423          	sd	s11,104(a0)
    80002778:	0005b083          	ld	ra,0(a1)
    8000277c:	0085b103          	ld	sp,8(a1)
    80002780:	6980                	ld	s0,16(a1)
    80002782:	6d84                	ld	s1,24(a1)
    80002784:	0205b903          	ld	s2,32(a1)
    80002788:	0285b983          	ld	s3,40(a1)
    8000278c:	0305ba03          	ld	s4,48(a1)
    80002790:	0385ba83          	ld	s5,56(a1)
    80002794:	0405bb03          	ld	s6,64(a1)
    80002798:	0485bb83          	ld	s7,72(a1)
    8000279c:	0505bc03          	ld	s8,80(a1)
    800027a0:	0585bc83          	ld	s9,88(a1)
    800027a4:	0605bd03          	ld	s10,96(a1)
    800027a8:	0685bd83          	ld	s11,104(a1)
    800027ac:	8082                	ret

00000000800027ae <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800027ae:	1141                	addi	sp,sp,-16
    800027b0:	e406                	sd	ra,8(sp)
    800027b2:	e022                	sd	s0,0(sp)
    800027b4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800027b6:	00006597          	auipc	a1,0x6
    800027ba:	b4258593          	addi	a1,a1,-1214 # 800082f8 <states.1746+0x30>
    800027be:	00014517          	auipc	a0,0x14
    800027c2:	1d250513          	addi	a0,a0,466 # 80016990 <tickslock>
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	394080e7          	jalr	916(ra) # 80000b5a <initlock>
}
    800027ce:	60a2                	ld	ra,8(sp)
    800027d0:	6402                	ld	s0,0(sp)
    800027d2:	0141                	addi	sp,sp,16
    800027d4:	8082                	ret

00000000800027d6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800027d6:	1141                	addi	sp,sp,-16
    800027d8:	e422                	sd	s0,8(sp)
    800027da:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027dc:	00003797          	auipc	a5,0x3
    800027e0:	59478793          	addi	a5,a5,1428 # 80005d70 <kernelvec>
    800027e4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027e8:	6422                	ld	s0,8(sp)
    800027ea:	0141                	addi	sp,sp,16
    800027ec:	8082                	ret

00000000800027ee <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027ee:	1141                	addi	sp,sp,-16
    800027f0:	e406                	sd	ra,8(sp)
    800027f2:	e022                	sd	s0,0(sp)
    800027f4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027f6:	fffff097          	auipc	ra,0xfffff
    800027fa:	1da080e7          	jalr	474(ra) # 800019d0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027fe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002802:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002804:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002808:	00004617          	auipc	a2,0x4
    8000280c:	7f860613          	addi	a2,a2,2040 # 80007000 <_trampoline>
    80002810:	00004697          	auipc	a3,0x4
    80002814:	7f068693          	addi	a3,a3,2032 # 80007000 <_trampoline>
    80002818:	8e91                	sub	a3,a3,a2
    8000281a:	040007b7          	lui	a5,0x4000
    8000281e:	17fd                	addi	a5,a5,-1
    80002820:	07b2                	slli	a5,a5,0xc
    80002822:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002824:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002828:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000282a:	180026f3          	csrr	a3,satp
    8000282e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002830:	6d38                	ld	a4,88(a0)
    80002832:	6134                	ld	a3,64(a0)
    80002834:	6585                	lui	a1,0x1
    80002836:	96ae                	add	a3,a3,a1
    80002838:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000283a:	6d38                	ld	a4,88(a0)
    8000283c:	00000697          	auipc	a3,0x0
    80002840:	13068693          	addi	a3,a3,304 # 8000296c <usertrap>
    80002844:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002846:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002848:	8692                	mv	a3,tp
    8000284a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000284c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002850:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002854:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002858:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000285c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000285e:	6f18                	ld	a4,24(a4)
    80002860:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002864:	6928                	ld	a0,80(a0)
    80002866:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002868:	00005717          	auipc	a4,0x5
    8000286c:	83470713          	addi	a4,a4,-1996 # 8000709c <userret>
    80002870:	8f11                	sub	a4,a4,a2
    80002872:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002874:	577d                	li	a4,-1
    80002876:	177e                	slli	a4,a4,0x3f
    80002878:	8d59                	or	a0,a0,a4
    8000287a:	9782                	jalr	a5
}
    8000287c:	60a2                	ld	ra,8(sp)
    8000287e:	6402                	ld	s0,0(sp)
    80002880:	0141                	addi	sp,sp,16
    80002882:	8082                	ret

0000000080002884 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002884:	1101                	addi	sp,sp,-32
    80002886:	ec06                	sd	ra,24(sp)
    80002888:	e822                	sd	s0,16(sp)
    8000288a:	e426                	sd	s1,8(sp)
    8000288c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000288e:	00014497          	auipc	s1,0x14
    80002892:	10248493          	addi	s1,s1,258 # 80016990 <tickslock>
    80002896:	8526                	mv	a0,s1
    80002898:	ffffe097          	auipc	ra,0xffffe
    8000289c:	352080e7          	jalr	850(ra) # 80000bea <acquire>
  ticks++;
    800028a0:	00006517          	auipc	a0,0x6
    800028a4:	05050513          	addi	a0,a0,80 # 800088f0 <ticks>
    800028a8:	411c                	lw	a5,0(a0)
    800028aa:	2785                	addiw	a5,a5,1
    800028ac:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800028ae:	00000097          	auipc	ra,0x0
    800028b2:	874080e7          	jalr	-1932(ra) # 80002122 <wakeup>
  release(&tickslock);
    800028b6:	8526                	mv	a0,s1
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	3e6080e7          	jalr	998(ra) # 80000c9e <release>
}
    800028c0:	60e2                	ld	ra,24(sp)
    800028c2:	6442                	ld	s0,16(sp)
    800028c4:	64a2                	ld	s1,8(sp)
    800028c6:	6105                	addi	sp,sp,32
    800028c8:	8082                	ret

00000000800028ca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800028ca:	1101                	addi	sp,sp,-32
    800028cc:	ec06                	sd	ra,24(sp)
    800028ce:	e822                	sd	s0,16(sp)
    800028d0:	e426                	sd	s1,8(sp)
    800028d2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800028d8:	00074d63          	bltz	a4,800028f2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800028dc:	57fd                	li	a5,-1
    800028de:	17fe                	slli	a5,a5,0x3f
    800028e0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800028e2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028e4:	06f70363          	beq	a4,a5,8000294a <devintr+0x80>
  }
}
    800028e8:	60e2                	ld	ra,24(sp)
    800028ea:	6442                	ld	s0,16(sp)
    800028ec:	64a2                	ld	s1,8(sp)
    800028ee:	6105                	addi	sp,sp,32
    800028f0:	8082                	ret
     (scause & 0xff) == 9){
    800028f2:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800028f6:	46a5                	li	a3,9
    800028f8:	fed792e3          	bne	a5,a3,800028dc <devintr+0x12>
    int irq = plic_claim();
    800028fc:	00003097          	auipc	ra,0x3
    80002900:	57c080e7          	jalr	1404(ra) # 80005e78 <plic_claim>
    80002904:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002906:	47a9                	li	a5,10
    80002908:	02f50763          	beq	a0,a5,80002936 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000290c:	4785                	li	a5,1
    8000290e:	02f50963          	beq	a0,a5,80002940 <devintr+0x76>
    return 1;
    80002912:	4505                	li	a0,1
    } else if(irq){
    80002914:	d8f1                	beqz	s1,800028e8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002916:	85a6                	mv	a1,s1
    80002918:	00006517          	auipc	a0,0x6
    8000291c:	9e850513          	addi	a0,a0,-1560 # 80008300 <states.1746+0x38>
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	c6e080e7          	jalr	-914(ra) # 8000058e <printf>
      plic_complete(irq);
    80002928:	8526                	mv	a0,s1
    8000292a:	00003097          	auipc	ra,0x3
    8000292e:	572080e7          	jalr	1394(ra) # 80005e9c <plic_complete>
    return 1;
    80002932:	4505                	li	a0,1
    80002934:	bf55                	j	800028e8 <devintr+0x1e>
      uartintr();
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	078080e7          	jalr	120(ra) # 800009ae <uartintr>
    8000293e:	b7ed                	j	80002928 <devintr+0x5e>
      virtio_disk_intr();
    80002940:	00004097          	auipc	ra,0x4
    80002944:	a86080e7          	jalr	-1402(ra) # 800063c6 <virtio_disk_intr>
    80002948:	b7c5                	j	80002928 <devintr+0x5e>
    if(cpuid() == 0){
    8000294a:	fffff097          	auipc	ra,0xfffff
    8000294e:	05a080e7          	jalr	90(ra) # 800019a4 <cpuid>
    80002952:	c901                	beqz	a0,80002962 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002954:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002958:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000295a:	14479073          	csrw	sip,a5
    return 2;
    8000295e:	4509                	li	a0,2
    80002960:	b761                	j	800028e8 <devintr+0x1e>
      clockintr();
    80002962:	00000097          	auipc	ra,0x0
    80002966:	f22080e7          	jalr	-222(ra) # 80002884 <clockintr>
    8000296a:	b7ed                	j	80002954 <devintr+0x8a>

000000008000296c <usertrap>:
{
    8000296c:	1101                	addi	sp,sp,-32
    8000296e:	ec06                	sd	ra,24(sp)
    80002970:	e822                	sd	s0,16(sp)
    80002972:	e426                	sd	s1,8(sp)
    80002974:	e04a                	sd	s2,0(sp)
    80002976:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002978:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000297c:	1007f793          	andi	a5,a5,256
    80002980:	e3b1                	bnez	a5,800029c4 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002982:	00003797          	auipc	a5,0x3
    80002986:	3ee78793          	addi	a5,a5,1006 # 80005d70 <kernelvec>
    8000298a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000298e:	fffff097          	auipc	ra,0xfffff
    80002992:	042080e7          	jalr	66(ra) # 800019d0 <myproc>
    80002996:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002998:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000299a:	14102773          	csrr	a4,sepc
    8000299e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029a0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800029a4:	47a1                	li	a5,8
    800029a6:	02f70763          	beq	a4,a5,800029d4 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    800029aa:	00000097          	auipc	ra,0x0
    800029ae:	f20080e7          	jalr	-224(ra) # 800028ca <devintr>
    800029b2:	892a                	mv	s2,a0
    800029b4:	c151                	beqz	a0,80002a38 <usertrap+0xcc>
  if(killed(p))
    800029b6:	8526                	mv	a0,s1
    800029b8:	00000097          	auipc	ra,0x0
    800029bc:	9ae080e7          	jalr	-1618(ra) # 80002366 <killed>
    800029c0:	c929                	beqz	a0,80002a12 <usertrap+0xa6>
    800029c2:	a099                	j	80002a08 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800029c4:	00006517          	auipc	a0,0x6
    800029c8:	95c50513          	addi	a0,a0,-1700 # 80008320 <states.1746+0x58>
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	b78080e7          	jalr	-1160(ra) # 80000544 <panic>
    if(killed(p))
    800029d4:	00000097          	auipc	ra,0x0
    800029d8:	992080e7          	jalr	-1646(ra) # 80002366 <killed>
    800029dc:	e921                	bnez	a0,80002a2c <usertrap+0xc0>
    p->trapframe->epc += 4;
    800029de:	6cb8                	ld	a4,88(s1)
    800029e0:	6f1c                	ld	a5,24(a4)
    800029e2:	0791                	addi	a5,a5,4
    800029e4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029ea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ee:	10079073          	csrw	sstatus,a5
    syscall();
    800029f2:	00000097          	auipc	ra,0x0
    800029f6:	33a080e7          	jalr	826(ra) # 80002d2c <syscall>
  if(killed(p))
    800029fa:	8526                	mv	a0,s1
    800029fc:	00000097          	auipc	ra,0x0
    80002a00:	96a080e7          	jalr	-1686(ra) # 80002366 <killed>
    80002a04:	c911                	beqz	a0,80002a18 <usertrap+0xac>
    80002a06:	4901                	li	s2,0
    exit(-1);
    80002a08:	557d                	li	a0,-1
    80002a0a:	fffff097          	auipc	ra,0xfffff
    80002a0e:	7e8080e7          	jalr	2024(ra) # 800021f2 <exit>
  if(which_dev == 2)
    80002a12:	4789                	li	a5,2
    80002a14:	04f90f63          	beq	s2,a5,80002a72 <usertrap+0x106>
  usertrapret();
    80002a18:	00000097          	auipc	ra,0x0
    80002a1c:	dd6080e7          	jalr	-554(ra) # 800027ee <usertrapret>
}
    80002a20:	60e2                	ld	ra,24(sp)
    80002a22:	6442                	ld	s0,16(sp)
    80002a24:	64a2                	ld	s1,8(sp)
    80002a26:	6902                	ld	s2,0(sp)
    80002a28:	6105                	addi	sp,sp,32
    80002a2a:	8082                	ret
      exit(-1);
    80002a2c:	557d                	li	a0,-1
    80002a2e:	fffff097          	auipc	ra,0xfffff
    80002a32:	7c4080e7          	jalr	1988(ra) # 800021f2 <exit>
    80002a36:	b765                	j	800029de <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a38:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a3c:	5890                	lw	a2,48(s1)
    80002a3e:	00006517          	auipc	a0,0x6
    80002a42:	90250513          	addi	a0,a0,-1790 # 80008340 <states.1746+0x78>
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	b48080e7          	jalr	-1208(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a4e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a52:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a56:	00006517          	auipc	a0,0x6
    80002a5a:	91a50513          	addi	a0,a0,-1766 # 80008370 <states.1746+0xa8>
    80002a5e:	ffffe097          	auipc	ra,0xffffe
    80002a62:	b30080e7          	jalr	-1232(ra) # 8000058e <printf>
    setkilled(p);
    80002a66:	8526                	mv	a0,s1
    80002a68:	00000097          	auipc	ra,0x0
    80002a6c:	8d2080e7          	jalr	-1838(ra) # 8000233a <setkilled>
    80002a70:	b769                	j	800029fa <usertrap+0x8e>
    yield();
    80002a72:	fffff097          	auipc	ra,0xfffff
    80002a76:	610080e7          	jalr	1552(ra) # 80002082 <yield>
    80002a7a:	bf79                	j	80002a18 <usertrap+0xac>

0000000080002a7c <kerneltrap>:
{
    80002a7c:	7179                	addi	sp,sp,-48
    80002a7e:	f406                	sd	ra,40(sp)
    80002a80:	f022                	sd	s0,32(sp)
    80002a82:	ec26                	sd	s1,24(sp)
    80002a84:	e84a                	sd	s2,16(sp)
    80002a86:	e44e                	sd	s3,8(sp)
    80002a88:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a8a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a8e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a92:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a96:	1004f793          	andi	a5,s1,256
    80002a9a:	cb85                	beqz	a5,80002aca <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002aa0:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002aa2:	ef85                	bnez	a5,80002ada <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002aa4:	00000097          	auipc	ra,0x0
    80002aa8:	e26080e7          	jalr	-474(ra) # 800028ca <devintr>
    80002aac:	cd1d                	beqz	a0,80002aea <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002aae:	4789                	li	a5,2
    80002ab0:	06f50a63          	beq	a0,a5,80002b24 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ab4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ab8:	10049073          	csrw	sstatus,s1
}
    80002abc:	70a2                	ld	ra,40(sp)
    80002abe:	7402                	ld	s0,32(sp)
    80002ac0:	64e2                	ld	s1,24(sp)
    80002ac2:	6942                	ld	s2,16(sp)
    80002ac4:	69a2                	ld	s3,8(sp)
    80002ac6:	6145                	addi	sp,sp,48
    80002ac8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002aca:	00006517          	auipc	a0,0x6
    80002ace:	8c650513          	addi	a0,a0,-1850 # 80008390 <states.1746+0xc8>
    80002ad2:	ffffe097          	auipc	ra,0xffffe
    80002ad6:	a72080e7          	jalr	-1422(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ada:	00006517          	auipc	a0,0x6
    80002ade:	8de50513          	addi	a0,a0,-1826 # 800083b8 <states.1746+0xf0>
    80002ae2:	ffffe097          	auipc	ra,0xffffe
    80002ae6:	a62080e7          	jalr	-1438(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80002aea:	85ce                	mv	a1,s3
    80002aec:	00006517          	auipc	a0,0x6
    80002af0:	8ec50513          	addi	a0,a0,-1812 # 800083d8 <states.1746+0x110>
    80002af4:	ffffe097          	auipc	ra,0xffffe
    80002af8:	a9a080e7          	jalr	-1382(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002afc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b00:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b04:	00006517          	auipc	a0,0x6
    80002b08:	8e450513          	addi	a0,a0,-1820 # 800083e8 <states.1746+0x120>
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	a82080e7          	jalr	-1406(ra) # 8000058e <printf>
    panic("kerneltrap");
    80002b14:	00006517          	auipc	a0,0x6
    80002b18:	8ec50513          	addi	a0,a0,-1812 # 80008400 <states.1746+0x138>
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	a28080e7          	jalr	-1496(ra) # 80000544 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b24:	fffff097          	auipc	ra,0xfffff
    80002b28:	eac080e7          	jalr	-340(ra) # 800019d0 <myproc>
    80002b2c:	d541                	beqz	a0,80002ab4 <kerneltrap+0x38>
    80002b2e:	fffff097          	auipc	ra,0xfffff
    80002b32:	ea2080e7          	jalr	-350(ra) # 800019d0 <myproc>
    80002b36:	4d18                	lw	a4,24(a0)
    80002b38:	4791                	li	a5,4
    80002b3a:	f6f71de3          	bne	a4,a5,80002ab4 <kerneltrap+0x38>
    yield();
    80002b3e:	fffff097          	auipc	ra,0xfffff
    80002b42:	544080e7          	jalr	1348(ra) # 80002082 <yield>
    80002b46:	b7bd                	j	80002ab4 <kerneltrap+0x38>

0000000080002b48 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b48:	1101                	addi	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	e426                	sd	s1,8(sp)
    80002b50:	1000                	addi	s0,sp,32
    80002b52:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b54:	fffff097          	auipc	ra,0xfffff
    80002b58:	e7c080e7          	jalr	-388(ra) # 800019d0 <myproc>
  switch (n) {
    80002b5c:	4795                	li	a5,5
    80002b5e:	0497e163          	bltu	a5,s1,80002ba0 <argraw+0x58>
    80002b62:	048a                	slli	s1,s1,0x2
    80002b64:	00006717          	auipc	a4,0x6
    80002b68:	8d470713          	addi	a4,a4,-1836 # 80008438 <states.1746+0x170>
    80002b6c:	94ba                	add	s1,s1,a4
    80002b6e:	409c                	lw	a5,0(s1)
    80002b70:	97ba                	add	a5,a5,a4
    80002b72:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b74:	6d3c                	ld	a5,88(a0)
    80002b76:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b78:	60e2                	ld	ra,24(sp)
    80002b7a:	6442                	ld	s0,16(sp)
    80002b7c:	64a2                	ld	s1,8(sp)
    80002b7e:	6105                	addi	sp,sp,32
    80002b80:	8082                	ret
    return p->trapframe->a1;
    80002b82:	6d3c                	ld	a5,88(a0)
    80002b84:	7fa8                	ld	a0,120(a5)
    80002b86:	bfcd                	j	80002b78 <argraw+0x30>
    return p->trapframe->a2;
    80002b88:	6d3c                	ld	a5,88(a0)
    80002b8a:	63c8                	ld	a0,128(a5)
    80002b8c:	b7f5                	j	80002b78 <argraw+0x30>
    return p->trapframe->a3;
    80002b8e:	6d3c                	ld	a5,88(a0)
    80002b90:	67c8                	ld	a0,136(a5)
    80002b92:	b7dd                	j	80002b78 <argraw+0x30>
    return p->trapframe->a4;
    80002b94:	6d3c                	ld	a5,88(a0)
    80002b96:	6bc8                	ld	a0,144(a5)
    80002b98:	b7c5                	j	80002b78 <argraw+0x30>
    return p->trapframe->a5;
    80002b9a:	6d3c                	ld	a5,88(a0)
    80002b9c:	6fc8                	ld	a0,152(a5)
    80002b9e:	bfe9                	j	80002b78 <argraw+0x30>
  panic("argraw");
    80002ba0:	00006517          	auipc	a0,0x6
    80002ba4:	87050513          	addi	a0,a0,-1936 # 80008410 <states.1746+0x148>
    80002ba8:	ffffe097          	auipc	ra,0xffffe
    80002bac:	99c080e7          	jalr	-1636(ra) # 80000544 <panic>

0000000080002bb0 <fetchaddr>:
{
    80002bb0:	1101                	addi	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	e04a                	sd	s2,0(sp)
    80002bba:	1000                	addi	s0,sp,32
    80002bbc:	84aa                	mv	s1,a0
    80002bbe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bc0:	fffff097          	auipc	ra,0xfffff
    80002bc4:	e10080e7          	jalr	-496(ra) # 800019d0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002bc8:	653c                	ld	a5,72(a0)
    80002bca:	02f4f863          	bgeu	s1,a5,80002bfa <fetchaddr+0x4a>
    80002bce:	00848713          	addi	a4,s1,8
    80002bd2:	02e7e663          	bltu	a5,a4,80002bfe <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002bd6:	46a1                	li	a3,8
    80002bd8:	8626                	mv	a2,s1
    80002bda:	85ca                	mv	a1,s2
    80002bdc:	6928                	ld	a0,80(a0)
    80002bde:	fffff097          	auipc	ra,0xfffff
    80002be2:	b32080e7          	jalr	-1230(ra) # 80001710 <copyin>
    80002be6:	00a03533          	snez	a0,a0
    80002bea:	40a00533          	neg	a0,a0
}
    80002bee:	60e2                	ld	ra,24(sp)
    80002bf0:	6442                	ld	s0,16(sp)
    80002bf2:	64a2                	ld	s1,8(sp)
    80002bf4:	6902                	ld	s2,0(sp)
    80002bf6:	6105                	addi	sp,sp,32
    80002bf8:	8082                	ret
    return -1;
    80002bfa:	557d                	li	a0,-1
    80002bfc:	bfcd                	j	80002bee <fetchaddr+0x3e>
    80002bfe:	557d                	li	a0,-1
    80002c00:	b7fd                	j	80002bee <fetchaddr+0x3e>

0000000080002c02 <fetchstr>:
{
    80002c02:	7179                	addi	sp,sp,-48
    80002c04:	f406                	sd	ra,40(sp)
    80002c06:	f022                	sd	s0,32(sp)
    80002c08:	ec26                	sd	s1,24(sp)
    80002c0a:	e84a                	sd	s2,16(sp)
    80002c0c:	e44e                	sd	s3,8(sp)
    80002c0e:	1800                	addi	s0,sp,48
    80002c10:	892a                	mv	s2,a0
    80002c12:	84ae                	mv	s1,a1
    80002c14:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c16:	fffff097          	auipc	ra,0xfffff
    80002c1a:	dba080e7          	jalr	-582(ra) # 800019d0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c1e:	86ce                	mv	a3,s3
    80002c20:	864a                	mv	a2,s2
    80002c22:	85a6                	mv	a1,s1
    80002c24:	6928                	ld	a0,80(a0)
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	b76080e7          	jalr	-1162(ra) # 8000179c <copyinstr>
    80002c2e:	00054e63          	bltz	a0,80002c4a <fetchstr+0x48>
  return strlen(buf);
    80002c32:	8526                	mv	a0,s1
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	236080e7          	jalr	566(ra) # 80000e6a <strlen>
}
    80002c3c:	70a2                	ld	ra,40(sp)
    80002c3e:	7402                	ld	s0,32(sp)
    80002c40:	64e2                	ld	s1,24(sp)
    80002c42:	6942                	ld	s2,16(sp)
    80002c44:	69a2                	ld	s3,8(sp)
    80002c46:	6145                	addi	sp,sp,48
    80002c48:	8082                	ret
    return -1;
    80002c4a:	557d                	li	a0,-1
    80002c4c:	bfc5                	j	80002c3c <fetchstr+0x3a>

0000000080002c4e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c4e:	1101                	addi	sp,sp,-32
    80002c50:	ec06                	sd	ra,24(sp)
    80002c52:	e822                	sd	s0,16(sp)
    80002c54:	e426                	sd	s1,8(sp)
    80002c56:	1000                	addi	s0,sp,32
    80002c58:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c5a:	00000097          	auipc	ra,0x0
    80002c5e:	eee080e7          	jalr	-274(ra) # 80002b48 <argraw>
    80002c62:	c088                	sw	a0,0(s1)
}
    80002c64:	60e2                	ld	ra,24(sp)
    80002c66:	6442                	ld	s0,16(sp)
    80002c68:	64a2                	ld	s1,8(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret

0000000080002c6e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c6e:	1101                	addi	sp,sp,-32
    80002c70:	ec06                	sd	ra,24(sp)
    80002c72:	e822                	sd	s0,16(sp)
    80002c74:	e426                	sd	s1,8(sp)
    80002c76:	1000                	addi	s0,sp,32
    80002c78:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	ece080e7          	jalr	-306(ra) # 80002b48 <argraw>
    80002c82:	e088                	sd	a0,0(s1)
}
    80002c84:	60e2                	ld	ra,24(sp)
    80002c86:	6442                	ld	s0,16(sp)
    80002c88:	64a2                	ld	s1,8(sp)
    80002c8a:	6105                	addi	sp,sp,32
    80002c8c:	8082                	ret

0000000080002c8e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c8e:	7179                	addi	sp,sp,-48
    80002c90:	f406                	sd	ra,40(sp)
    80002c92:	f022                	sd	s0,32(sp)
    80002c94:	ec26                	sd	s1,24(sp)
    80002c96:	e84a                	sd	s2,16(sp)
    80002c98:	1800                	addi	s0,sp,48
    80002c9a:	84ae                	mv	s1,a1
    80002c9c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c9e:	fd840593          	addi	a1,s0,-40
    80002ca2:	00000097          	auipc	ra,0x0
    80002ca6:	fcc080e7          	jalr	-52(ra) # 80002c6e <argaddr>
  return fetchstr(addr, buf, max);
    80002caa:	864a                	mv	a2,s2
    80002cac:	85a6                	mv	a1,s1
    80002cae:	fd843503          	ld	a0,-40(s0)
    80002cb2:	00000097          	auipc	ra,0x0
    80002cb6:	f50080e7          	jalr	-176(ra) # 80002c02 <fetchstr>
}
    80002cba:	70a2                	ld	ra,40(sp)
    80002cbc:	7402                	ld	s0,32(sp)
    80002cbe:	64e2                	ld	s1,24(sp)
    80002cc0:	6942                	ld	s2,16(sp)
    80002cc2:	6145                	addi	sp,sp,48
    80002cc4:	8082                	ret

0000000080002cc6 <argpstat>:

//////////////////////////////////////////////
int
argpstat(int n, struct pstat *pp, int size)
{
    80002cc6:	7139                	addi	sp,sp,-64
    80002cc8:	fc06                	sd	ra,56(sp)
    80002cca:	f822                	sd	s0,48(sp)
    80002ccc:	f426                	sd	s1,40(sp)
    80002cce:	f04a                	sd	s2,32(sp)
    80002cd0:	ec4e                	sd	s3,24(sp)
    80002cd2:	0080                	addi	s0,sp,64
    80002cd4:	892a                	mv	s2,a0
    80002cd6:	84b2                	mv	s1,a2
  int i;
  struct proc *curproc = myproc();
    80002cd8:	fffff097          	auipc	ra,0xfffff
    80002cdc:	cf8080e7          	jalr	-776(ra) # 800019d0 <myproc>
    80002ce0:	89aa                	mv	s3,a0
  struct pstat p;
 
  argint(n, &i);
    80002ce2:	fcc40593          	addi	a1,s0,-52
    80002ce6:	854a                	mv	a0,s2
    80002ce8:	00000097          	auipc	ra,0x0
    80002cec:	f66080e7          	jalr	-154(ra) # 80002c4e <argint>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    80002cf0:	0204ca63          	bltz	s1,80002d24 <argpstat+0x5e>
    80002cf4:	fcc42603          	lw	a2,-52(s0)
    80002cf8:	0489b503          	ld	a0,72(s3)
    80002cfc:	02061793          	slli	a5,a2,0x20
    80002d00:	9381                	srli	a5,a5,0x20
    80002d02:	02a7f363          	bgeu	a5,a0,80002d28 <argpstat+0x62>
    80002d06:	9cb1                	addw	s1,s1,a2
    80002d08:	1482                	slli	s1,s1,0x20
    80002d0a:	9081                	srli	s1,s1,0x20
    80002d0c:	00953533          	sltu	a0,a0,s1
    80002d10:	40a0053b          	negw	a0,a0
    80002d14:	2501                	sext.w	a0,a0
    return -1;

  pp = (struct pstat*)&p;
  return 0;
}
    80002d16:	70e2                	ld	ra,56(sp)
    80002d18:	7442                	ld	s0,48(sp)
    80002d1a:	74a2                	ld	s1,40(sp)
    80002d1c:	7902                	ld	s2,32(sp)
    80002d1e:	69e2                	ld	s3,24(sp)
    80002d20:	6121                	addi	sp,sp,64
    80002d22:	8082                	ret
    return -1;
    80002d24:	557d                	li	a0,-1
    80002d26:	bfc5                	j	80002d16 <argpstat+0x50>
    80002d28:	557d                	li	a0,-1
    80002d2a:	b7f5                	j	80002d16 <argpstat+0x50>

0000000080002d2c <syscall>:

};

void
syscall(void)
{
    80002d2c:	1101                	addi	sp,sp,-32
    80002d2e:	ec06                	sd	ra,24(sp)
    80002d30:	e822                	sd	s0,16(sp)
    80002d32:	e426                	sd	s1,8(sp)
    80002d34:	e04a                	sd	s2,0(sp)
    80002d36:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d38:	fffff097          	auipc	ra,0xfffff
    80002d3c:	c98080e7          	jalr	-872(ra) # 800019d0 <myproc>
    80002d40:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d42:	05853903          	ld	s2,88(a0)
    80002d46:	0a893783          	ld	a5,168(s2)
    80002d4a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d4e:	37fd                	addiw	a5,a5,-1
    80002d50:	4759                	li	a4,22
    80002d52:	00f76f63          	bltu	a4,a5,80002d70 <syscall+0x44>
    80002d56:	00369713          	slli	a4,a3,0x3
    80002d5a:	00005797          	auipc	a5,0x5
    80002d5e:	6f678793          	addi	a5,a5,1782 # 80008450 <syscalls>
    80002d62:	97ba                	add	a5,a5,a4
    80002d64:	639c                	ld	a5,0(a5)
    80002d66:	c789                	beqz	a5,80002d70 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d68:	9782                	jalr	a5
    80002d6a:	06a93823          	sd	a0,112(s2)
    80002d6e:	a839                	j	80002d8c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d70:	15848613          	addi	a2,s1,344
    80002d74:	588c                	lw	a1,48(s1)
    80002d76:	00005517          	auipc	a0,0x5
    80002d7a:	6a250513          	addi	a0,a0,1698 # 80008418 <states.1746+0x150>
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	810080e7          	jalr	-2032(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d86:	6cbc                	ld	a5,88(s1)
    80002d88:	577d                	li	a4,-1
    80002d8a:	fbb8                	sd	a4,112(a5)
  }
}
    80002d8c:	60e2                	ld	ra,24(sp)
    80002d8e:	6442                	ld	s0,16(sp)
    80002d90:	64a2                	ld	s1,8(sp)
    80002d92:	6902                	ld	s2,0(sp)
    80002d94:	6105                	addi	sp,sp,32
    80002d96:	8082                	ret

0000000080002d98 <sys_exit>:
#include "proc.h"


uint64
sys_exit(void)
{
    80002d98:	1101                	addi	sp,sp,-32
    80002d9a:	ec06                	sd	ra,24(sp)
    80002d9c:	e822                	sd	s0,16(sp)
    80002d9e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002da0:	fec40593          	addi	a1,s0,-20
    80002da4:	4501                	li	a0,0
    80002da6:	00000097          	auipc	ra,0x0
    80002daa:	ea8080e7          	jalr	-344(ra) # 80002c4e <argint>
  exit(n);
    80002dae:	fec42503          	lw	a0,-20(s0)
    80002db2:	fffff097          	auipc	ra,0xfffff
    80002db6:	440080e7          	jalr	1088(ra) # 800021f2 <exit>
  return 0;  // not reached
}
    80002dba:	4501                	li	a0,0
    80002dbc:	60e2                	ld	ra,24(sp)
    80002dbe:	6442                	ld	s0,16(sp)
    80002dc0:	6105                	addi	sp,sp,32
    80002dc2:	8082                	ret

0000000080002dc4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dc4:	1141                	addi	sp,sp,-16
    80002dc6:	e406                	sd	ra,8(sp)
    80002dc8:	e022                	sd	s0,0(sp)
    80002dca:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	c04080e7          	jalr	-1020(ra) # 800019d0 <myproc>
}
    80002dd4:	5908                	lw	a0,48(a0)
    80002dd6:	60a2                	ld	ra,8(sp)
    80002dd8:	6402                	ld	s0,0(sp)
    80002dda:	0141                	addi	sp,sp,16
    80002ddc:	8082                	ret

0000000080002dde <sys_fork>:

uint64
sys_fork(void)
{
    80002dde:	1141                	addi	sp,sp,-16
    80002de0:	e406                	sd	ra,8(sp)
    80002de2:	e022                	sd	s0,0(sp)
    80002de4:	0800                	addi	s0,sp,16
  return fork();
    80002de6:	fffff097          	auipc	ra,0xfffff
    80002dea:	fa0080e7          	jalr	-96(ra) # 80001d86 <fork>
}
    80002dee:	60a2                	ld	ra,8(sp)
    80002df0:	6402                	ld	s0,0(sp)
    80002df2:	0141                	addi	sp,sp,16
    80002df4:	8082                	ret

0000000080002df6 <sys_wait>:

uint64
sys_wait(void)
{
    80002df6:	1101                	addi	sp,sp,-32
    80002df8:	ec06                	sd	ra,24(sp)
    80002dfa:	e822                	sd	s0,16(sp)
    80002dfc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002dfe:	fe840593          	addi	a1,s0,-24
    80002e02:	4501                	li	a0,0
    80002e04:	00000097          	auipc	ra,0x0
    80002e08:	e6a080e7          	jalr	-406(ra) # 80002c6e <argaddr>
  return wait(p);
    80002e0c:	fe843503          	ld	a0,-24(s0)
    80002e10:	fffff097          	auipc	ra,0xfffff
    80002e14:	588080e7          	jalr	1416(ra) # 80002398 <wait>
}
    80002e18:	60e2                	ld	ra,24(sp)
    80002e1a:	6442                	ld	s0,16(sp)
    80002e1c:	6105                	addi	sp,sp,32
    80002e1e:	8082                	ret

0000000080002e20 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e20:	7179                	addi	sp,sp,-48
    80002e22:	f406                	sd	ra,40(sp)
    80002e24:	f022                	sd	s0,32(sp)
    80002e26:	ec26                	sd	s1,24(sp)
    80002e28:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002e2a:	fdc40593          	addi	a1,s0,-36
    80002e2e:	4501                	li	a0,0
    80002e30:	00000097          	auipc	ra,0x0
    80002e34:	e1e080e7          	jalr	-482(ra) # 80002c4e <argint>
  addr = myproc()->sz;
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	b98080e7          	jalr	-1128(ra) # 800019d0 <myproc>
    80002e40:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002e42:	fdc42503          	lw	a0,-36(s0)
    80002e46:	fffff097          	auipc	ra,0xfffff
    80002e4a:	ee4080e7          	jalr	-284(ra) # 80001d2a <growproc>
    80002e4e:	00054863          	bltz	a0,80002e5e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002e52:	8526                	mv	a0,s1
    80002e54:	70a2                	ld	ra,40(sp)
    80002e56:	7402                	ld	s0,32(sp)
    80002e58:	64e2                	ld	s1,24(sp)
    80002e5a:	6145                	addi	sp,sp,48
    80002e5c:	8082                	ret
    return -1;
    80002e5e:	54fd                	li	s1,-1
    80002e60:	bfcd                	j	80002e52 <sys_sbrk+0x32>

0000000080002e62 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e62:	7139                	addi	sp,sp,-64
    80002e64:	fc06                	sd	ra,56(sp)
    80002e66:	f822                	sd	s0,48(sp)
    80002e68:	f426                	sd	s1,40(sp)
    80002e6a:	f04a                	sd	s2,32(sp)
    80002e6c:	ec4e                	sd	s3,24(sp)
    80002e6e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e70:	fcc40593          	addi	a1,s0,-52
    80002e74:	4501                	li	a0,0
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	dd8080e7          	jalr	-552(ra) # 80002c4e <argint>
  acquire(&tickslock);
    80002e7e:	00014517          	auipc	a0,0x14
    80002e82:	b1250513          	addi	a0,a0,-1262 # 80016990 <tickslock>
    80002e86:	ffffe097          	auipc	ra,0xffffe
    80002e8a:	d64080e7          	jalr	-668(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80002e8e:	00006917          	auipc	s2,0x6
    80002e92:	a6292903          	lw	s2,-1438(s2) # 800088f0 <ticks>
  while(ticks - ticks0 < n){
    80002e96:	fcc42783          	lw	a5,-52(s0)
    80002e9a:	cf9d                	beqz	a5,80002ed8 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e9c:	00014997          	auipc	s3,0x14
    80002ea0:	af498993          	addi	s3,s3,-1292 # 80016990 <tickslock>
    80002ea4:	00006497          	auipc	s1,0x6
    80002ea8:	a4c48493          	addi	s1,s1,-1460 # 800088f0 <ticks>
    if(killed(myproc())){
    80002eac:	fffff097          	auipc	ra,0xfffff
    80002eb0:	b24080e7          	jalr	-1244(ra) # 800019d0 <myproc>
    80002eb4:	fffff097          	auipc	ra,0xfffff
    80002eb8:	4b2080e7          	jalr	1202(ra) # 80002366 <killed>
    80002ebc:	ed15                	bnez	a0,80002ef8 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002ebe:	85ce                	mv	a1,s3
    80002ec0:	8526                	mv	a0,s1
    80002ec2:	fffff097          	auipc	ra,0xfffff
    80002ec6:	1fc080e7          	jalr	508(ra) # 800020be <sleep>
  while(ticks - ticks0 < n){
    80002eca:	409c                	lw	a5,0(s1)
    80002ecc:	412787bb          	subw	a5,a5,s2
    80002ed0:	fcc42703          	lw	a4,-52(s0)
    80002ed4:	fce7ece3          	bltu	a5,a4,80002eac <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002ed8:	00014517          	auipc	a0,0x14
    80002edc:	ab850513          	addi	a0,a0,-1352 # 80016990 <tickslock>
    80002ee0:	ffffe097          	auipc	ra,0xffffe
    80002ee4:	dbe080e7          	jalr	-578(ra) # 80000c9e <release>
  return 0;
    80002ee8:	4501                	li	a0,0
}
    80002eea:	70e2                	ld	ra,56(sp)
    80002eec:	7442                	ld	s0,48(sp)
    80002eee:	74a2                	ld	s1,40(sp)
    80002ef0:	7902                	ld	s2,32(sp)
    80002ef2:	69e2                	ld	s3,24(sp)
    80002ef4:	6121                	addi	sp,sp,64
    80002ef6:	8082                	ret
      release(&tickslock);
    80002ef8:	00014517          	auipc	a0,0x14
    80002efc:	a9850513          	addi	a0,a0,-1384 # 80016990 <tickslock>
    80002f00:	ffffe097          	auipc	ra,0xffffe
    80002f04:	d9e080e7          	jalr	-610(ra) # 80000c9e <release>
      return -1;
    80002f08:	557d                	li	a0,-1
    80002f0a:	b7c5                	j	80002eea <sys_sleep+0x88>

0000000080002f0c <sys_kill>:

uint64
sys_kill(void)
{
    80002f0c:	1101                	addi	sp,sp,-32
    80002f0e:	ec06                	sd	ra,24(sp)
    80002f10:	e822                	sd	s0,16(sp)
    80002f12:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f14:	fec40593          	addi	a1,s0,-20
    80002f18:	4501                	li	a0,0
    80002f1a:	00000097          	auipc	ra,0x0
    80002f1e:	d34080e7          	jalr	-716(ra) # 80002c4e <argint>
  return kill(pid);
    80002f22:	fec42503          	lw	a0,-20(s0)
    80002f26:	fffff097          	auipc	ra,0xfffff
    80002f2a:	3a2080e7          	jalr	930(ra) # 800022c8 <kill>
}
    80002f2e:	60e2                	ld	ra,24(sp)
    80002f30:	6442                	ld	s0,16(sp)
    80002f32:	6105                	addi	sp,sp,32
    80002f34:	8082                	ret

0000000080002f36 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f36:	1101                	addi	sp,sp,-32
    80002f38:	ec06                	sd	ra,24(sp)
    80002f3a:	e822                	sd	s0,16(sp)
    80002f3c:	e426                	sd	s1,8(sp)
    80002f3e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f40:	00014517          	auipc	a0,0x14
    80002f44:	a5050513          	addi	a0,a0,-1456 # 80016990 <tickslock>
    80002f48:	ffffe097          	auipc	ra,0xffffe
    80002f4c:	ca2080e7          	jalr	-862(ra) # 80000bea <acquire>
  xticks = ticks;
    80002f50:	00006497          	auipc	s1,0x6
    80002f54:	9a04a483          	lw	s1,-1632(s1) # 800088f0 <ticks>
  release(&tickslock);
    80002f58:	00014517          	auipc	a0,0x14
    80002f5c:	a3850513          	addi	a0,a0,-1480 # 80016990 <tickslock>
    80002f60:	ffffe097          	auipc	ra,0xffffe
    80002f64:	d3e080e7          	jalr	-706(ra) # 80000c9e <release>
  return xticks;
}
    80002f68:	02049513          	slli	a0,s1,0x20
    80002f6c:	9101                	srli	a0,a0,0x20
    80002f6e:	60e2                	ld	ra,24(sp)
    80002f70:	6442                	ld	s0,16(sp)
    80002f72:	64a2                	ld	s1,8(sp)
    80002f74:	6105                	addi	sp,sp,32
    80002f76:	8082                	ret

0000000080002f78 <sys_setpriority>:

/////////////////////////////////////////////////////////////////////////////////////////////////////
uint64
sys_setpriority(void)
{
    80002f78:	1101                	addi	sp,sp,-32
    80002f7a:	ec06                	sd	ra,24(sp)
    80002f7c:	e822                	sd	s0,16(sp)
    80002f7e:	1000                	addi	s0,sp,32
  int priority;
  argint(0, &priority);
    80002f80:	fec40593          	addi	a1,s0,-20
    80002f84:	4501                	li	a0,0
    80002f86:	00000097          	auipc	ra,0x0
    80002f8a:	cc8080e7          	jalr	-824(ra) # 80002c4e <argint>
  return setpriority(priority);
    80002f8e:	fec42503          	lw	a0,-20(s0)
    80002f92:	fffff097          	auipc	ra,0xfffff
    80002f96:	68e080e7          	jalr	1678(ra) # 80002620 <setpriority>
}
    80002f9a:	60e2                	ld	ra,24(sp)
    80002f9c:	6442                	ld	s0,16(sp)
    80002f9e:	6105                	addi	sp,sp,32
    80002fa0:	8082                	ret

0000000080002fa2 <sys_getpinfo>:


uint64
sys_getpinfo(void)
{
    80002fa2:	7179                	addi	sp,sp,-48
    80002fa4:	f406                	sd	ra,40(sp)
    80002fa6:	f022                	sd	s0,32(sp)
    80002fa8:	ec26                	sd	s1,24(sp)
    80002faa:	1800                	addi	s0,sp,48
    80002fac:	81010113          	addi	sp,sp,-2032
  struct pstat stats;

  if(argpstat (0 , &stats ,sizeof(struct pstat)) < 0)
    80002fb0:	6605                	lui	a2,0x1
    80002fb2:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80002fb6:	74fd                	lui	s1,0xfffff
    80002fb8:	7f048793          	addi	a5,s1,2032 # fffffffffffff7f0 <end+0xffffffff7ffdda80>
    80002fbc:	ff040713          	addi	a4,s0,-16
    80002fc0:	00f705b3          	add	a1,a4,a5
    80002fc4:	4501                	li	a0,0
    80002fc6:	00000097          	auipc	ra,0x0
    80002fca:	d00080e7          	jalr	-768(ra) # 80002cc6 <argpstat>
    80002fce:	87aa                	mv	a5,a0
    return -1;
    80002fd0:	557d                	li	a0,-1
  if(argpstat (0 , &stats ,sizeof(struct pstat)) < 0)
    80002fd2:	0007cc63          	bltz	a5,80002fea <sys_getpinfo+0x48>

  return getpinfo(&stats);
    80002fd6:	7f048793          	addi	a5,s1,2032
    80002fda:	ff040713          	addi	a4,s0,-16
    80002fde:	00f70533          	add	a0,a4,a5
    80002fe2:	fffff097          	auipc	ra,0xfffff
    80002fe6:	68e080e7          	jalr	1678(ra) # 80002670 <getpinfo>
    80002fea:	7f010113          	addi	sp,sp,2032
    80002fee:	70a2                	ld	ra,40(sp)
    80002ff0:	7402                	ld	s0,32(sp)
    80002ff2:	64e2                	ld	s1,24(sp)
    80002ff4:	6145                	addi	sp,sp,48
    80002ff6:	8082                	ret

0000000080002ff8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ff8:	7179                	addi	sp,sp,-48
    80002ffa:	f406                	sd	ra,40(sp)
    80002ffc:	f022                	sd	s0,32(sp)
    80002ffe:	ec26                	sd	s1,24(sp)
    80003000:	e84a                	sd	s2,16(sp)
    80003002:	e44e                	sd	s3,8(sp)
    80003004:	e052                	sd	s4,0(sp)
    80003006:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003008:	00005597          	auipc	a1,0x5
    8000300c:	50858593          	addi	a1,a1,1288 # 80008510 <syscalls+0xc0>
    80003010:	00014517          	auipc	a0,0x14
    80003014:	99850513          	addi	a0,a0,-1640 # 800169a8 <bcache>
    80003018:	ffffe097          	auipc	ra,0xffffe
    8000301c:	b42080e7          	jalr	-1214(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003020:	0001c797          	auipc	a5,0x1c
    80003024:	98878793          	addi	a5,a5,-1656 # 8001e9a8 <bcache+0x8000>
    80003028:	0001c717          	auipc	a4,0x1c
    8000302c:	be870713          	addi	a4,a4,-1048 # 8001ec10 <bcache+0x8268>
    80003030:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003034:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003038:	00014497          	auipc	s1,0x14
    8000303c:	98848493          	addi	s1,s1,-1656 # 800169c0 <bcache+0x18>
    b->next = bcache.head.next;
    80003040:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003042:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003044:	00005a17          	auipc	s4,0x5
    80003048:	4d4a0a13          	addi	s4,s4,1236 # 80008518 <syscalls+0xc8>
    b->next = bcache.head.next;
    8000304c:	2b893783          	ld	a5,696(s2)
    80003050:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003052:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003056:	85d2                	mv	a1,s4
    80003058:	01048513          	addi	a0,s1,16
    8000305c:	00001097          	auipc	ra,0x1
    80003060:	4c4080e7          	jalr	1220(ra) # 80004520 <initsleeplock>
    bcache.head.next->prev = b;
    80003064:	2b893783          	ld	a5,696(s2)
    80003068:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000306a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000306e:	45848493          	addi	s1,s1,1112
    80003072:	fd349de3          	bne	s1,s3,8000304c <binit+0x54>
  }
}
    80003076:	70a2                	ld	ra,40(sp)
    80003078:	7402                	ld	s0,32(sp)
    8000307a:	64e2                	ld	s1,24(sp)
    8000307c:	6942                	ld	s2,16(sp)
    8000307e:	69a2                	ld	s3,8(sp)
    80003080:	6a02                	ld	s4,0(sp)
    80003082:	6145                	addi	sp,sp,48
    80003084:	8082                	ret

0000000080003086 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003086:	7179                	addi	sp,sp,-48
    80003088:	f406                	sd	ra,40(sp)
    8000308a:	f022                	sd	s0,32(sp)
    8000308c:	ec26                	sd	s1,24(sp)
    8000308e:	e84a                	sd	s2,16(sp)
    80003090:	e44e                	sd	s3,8(sp)
    80003092:	1800                	addi	s0,sp,48
    80003094:	89aa                	mv	s3,a0
    80003096:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003098:	00014517          	auipc	a0,0x14
    8000309c:	91050513          	addi	a0,a0,-1776 # 800169a8 <bcache>
    800030a0:	ffffe097          	auipc	ra,0xffffe
    800030a4:	b4a080e7          	jalr	-1206(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030a8:	0001c497          	auipc	s1,0x1c
    800030ac:	bb84b483          	ld	s1,-1096(s1) # 8001ec60 <bcache+0x82b8>
    800030b0:	0001c797          	auipc	a5,0x1c
    800030b4:	b6078793          	addi	a5,a5,-1184 # 8001ec10 <bcache+0x8268>
    800030b8:	02f48f63          	beq	s1,a5,800030f6 <bread+0x70>
    800030bc:	873e                	mv	a4,a5
    800030be:	a021                	j	800030c6 <bread+0x40>
    800030c0:	68a4                	ld	s1,80(s1)
    800030c2:	02e48a63          	beq	s1,a4,800030f6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030c6:	449c                	lw	a5,8(s1)
    800030c8:	ff379ce3          	bne	a5,s3,800030c0 <bread+0x3a>
    800030cc:	44dc                	lw	a5,12(s1)
    800030ce:	ff2799e3          	bne	a5,s2,800030c0 <bread+0x3a>
      b->refcnt++;
    800030d2:	40bc                	lw	a5,64(s1)
    800030d4:	2785                	addiw	a5,a5,1
    800030d6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030d8:	00014517          	auipc	a0,0x14
    800030dc:	8d050513          	addi	a0,a0,-1840 # 800169a8 <bcache>
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	bbe080e7          	jalr	-1090(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800030e8:	01048513          	addi	a0,s1,16
    800030ec:	00001097          	auipc	ra,0x1
    800030f0:	46e080e7          	jalr	1134(ra) # 8000455a <acquiresleep>
      return b;
    800030f4:	a8b9                	j	80003152 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030f6:	0001c497          	auipc	s1,0x1c
    800030fa:	b624b483          	ld	s1,-1182(s1) # 8001ec58 <bcache+0x82b0>
    800030fe:	0001c797          	auipc	a5,0x1c
    80003102:	b1278793          	addi	a5,a5,-1262 # 8001ec10 <bcache+0x8268>
    80003106:	00f48863          	beq	s1,a5,80003116 <bread+0x90>
    8000310a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000310c:	40bc                	lw	a5,64(s1)
    8000310e:	cf81                	beqz	a5,80003126 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003110:	64a4                	ld	s1,72(s1)
    80003112:	fee49de3          	bne	s1,a4,8000310c <bread+0x86>
  panic("bget: no buffers");
    80003116:	00005517          	auipc	a0,0x5
    8000311a:	40a50513          	addi	a0,a0,1034 # 80008520 <syscalls+0xd0>
    8000311e:	ffffd097          	auipc	ra,0xffffd
    80003122:	426080e7          	jalr	1062(ra) # 80000544 <panic>
      b->dev = dev;
    80003126:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000312a:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000312e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003132:	4785                	li	a5,1
    80003134:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003136:	00014517          	auipc	a0,0x14
    8000313a:	87250513          	addi	a0,a0,-1934 # 800169a8 <bcache>
    8000313e:	ffffe097          	auipc	ra,0xffffe
    80003142:	b60080e7          	jalr	-1184(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003146:	01048513          	addi	a0,s1,16
    8000314a:	00001097          	auipc	ra,0x1
    8000314e:	410080e7          	jalr	1040(ra) # 8000455a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003152:	409c                	lw	a5,0(s1)
    80003154:	cb89                	beqz	a5,80003166 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003156:	8526                	mv	a0,s1
    80003158:	70a2                	ld	ra,40(sp)
    8000315a:	7402                	ld	s0,32(sp)
    8000315c:	64e2                	ld	s1,24(sp)
    8000315e:	6942                	ld	s2,16(sp)
    80003160:	69a2                	ld	s3,8(sp)
    80003162:	6145                	addi	sp,sp,48
    80003164:	8082                	ret
    virtio_disk_rw(b, 0);
    80003166:	4581                	li	a1,0
    80003168:	8526                	mv	a0,s1
    8000316a:	00003097          	auipc	ra,0x3
    8000316e:	fce080e7          	jalr	-50(ra) # 80006138 <virtio_disk_rw>
    b->valid = 1;
    80003172:	4785                	li	a5,1
    80003174:	c09c                	sw	a5,0(s1)
  return b;
    80003176:	b7c5                	j	80003156 <bread+0xd0>

0000000080003178 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003178:	1101                	addi	sp,sp,-32
    8000317a:	ec06                	sd	ra,24(sp)
    8000317c:	e822                	sd	s0,16(sp)
    8000317e:	e426                	sd	s1,8(sp)
    80003180:	1000                	addi	s0,sp,32
    80003182:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003184:	0541                	addi	a0,a0,16
    80003186:	00001097          	auipc	ra,0x1
    8000318a:	46e080e7          	jalr	1134(ra) # 800045f4 <holdingsleep>
    8000318e:	cd01                	beqz	a0,800031a6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003190:	4585                	li	a1,1
    80003192:	8526                	mv	a0,s1
    80003194:	00003097          	auipc	ra,0x3
    80003198:	fa4080e7          	jalr	-92(ra) # 80006138 <virtio_disk_rw>
}
    8000319c:	60e2                	ld	ra,24(sp)
    8000319e:	6442                	ld	s0,16(sp)
    800031a0:	64a2                	ld	s1,8(sp)
    800031a2:	6105                	addi	sp,sp,32
    800031a4:	8082                	ret
    panic("bwrite");
    800031a6:	00005517          	auipc	a0,0x5
    800031aa:	39250513          	addi	a0,a0,914 # 80008538 <syscalls+0xe8>
    800031ae:	ffffd097          	auipc	ra,0xffffd
    800031b2:	396080e7          	jalr	918(ra) # 80000544 <panic>

00000000800031b6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031b6:	1101                	addi	sp,sp,-32
    800031b8:	ec06                	sd	ra,24(sp)
    800031ba:	e822                	sd	s0,16(sp)
    800031bc:	e426                	sd	s1,8(sp)
    800031be:	e04a                	sd	s2,0(sp)
    800031c0:	1000                	addi	s0,sp,32
    800031c2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031c4:	01050913          	addi	s2,a0,16
    800031c8:	854a                	mv	a0,s2
    800031ca:	00001097          	auipc	ra,0x1
    800031ce:	42a080e7          	jalr	1066(ra) # 800045f4 <holdingsleep>
    800031d2:	c92d                	beqz	a0,80003244 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800031d4:	854a                	mv	a0,s2
    800031d6:	00001097          	auipc	ra,0x1
    800031da:	3da080e7          	jalr	986(ra) # 800045b0 <releasesleep>

  acquire(&bcache.lock);
    800031de:	00013517          	auipc	a0,0x13
    800031e2:	7ca50513          	addi	a0,a0,1994 # 800169a8 <bcache>
    800031e6:	ffffe097          	auipc	ra,0xffffe
    800031ea:	a04080e7          	jalr	-1532(ra) # 80000bea <acquire>
  b->refcnt--;
    800031ee:	40bc                	lw	a5,64(s1)
    800031f0:	37fd                	addiw	a5,a5,-1
    800031f2:	0007871b          	sext.w	a4,a5
    800031f6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031f8:	eb05                	bnez	a4,80003228 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031fa:	68bc                	ld	a5,80(s1)
    800031fc:	64b8                	ld	a4,72(s1)
    800031fe:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003200:	64bc                	ld	a5,72(s1)
    80003202:	68b8                	ld	a4,80(s1)
    80003204:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003206:	0001b797          	auipc	a5,0x1b
    8000320a:	7a278793          	addi	a5,a5,1954 # 8001e9a8 <bcache+0x8000>
    8000320e:	2b87b703          	ld	a4,696(a5)
    80003212:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003214:	0001c717          	auipc	a4,0x1c
    80003218:	9fc70713          	addi	a4,a4,-1540 # 8001ec10 <bcache+0x8268>
    8000321c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000321e:	2b87b703          	ld	a4,696(a5)
    80003222:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003224:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003228:	00013517          	auipc	a0,0x13
    8000322c:	78050513          	addi	a0,a0,1920 # 800169a8 <bcache>
    80003230:	ffffe097          	auipc	ra,0xffffe
    80003234:	a6e080e7          	jalr	-1426(ra) # 80000c9e <release>
}
    80003238:	60e2                	ld	ra,24(sp)
    8000323a:	6442                	ld	s0,16(sp)
    8000323c:	64a2                	ld	s1,8(sp)
    8000323e:	6902                	ld	s2,0(sp)
    80003240:	6105                	addi	sp,sp,32
    80003242:	8082                	ret
    panic("brelse");
    80003244:	00005517          	auipc	a0,0x5
    80003248:	2fc50513          	addi	a0,a0,764 # 80008540 <syscalls+0xf0>
    8000324c:	ffffd097          	auipc	ra,0xffffd
    80003250:	2f8080e7          	jalr	760(ra) # 80000544 <panic>

0000000080003254 <bpin>:

void
bpin(struct buf *b) {
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	e426                	sd	s1,8(sp)
    8000325c:	1000                	addi	s0,sp,32
    8000325e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003260:	00013517          	auipc	a0,0x13
    80003264:	74850513          	addi	a0,a0,1864 # 800169a8 <bcache>
    80003268:	ffffe097          	auipc	ra,0xffffe
    8000326c:	982080e7          	jalr	-1662(ra) # 80000bea <acquire>
  b->refcnt++;
    80003270:	40bc                	lw	a5,64(s1)
    80003272:	2785                	addiw	a5,a5,1
    80003274:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003276:	00013517          	auipc	a0,0x13
    8000327a:	73250513          	addi	a0,a0,1842 # 800169a8 <bcache>
    8000327e:	ffffe097          	auipc	ra,0xffffe
    80003282:	a20080e7          	jalr	-1504(ra) # 80000c9e <release>
}
    80003286:	60e2                	ld	ra,24(sp)
    80003288:	6442                	ld	s0,16(sp)
    8000328a:	64a2                	ld	s1,8(sp)
    8000328c:	6105                	addi	sp,sp,32
    8000328e:	8082                	ret

0000000080003290 <bunpin>:

void
bunpin(struct buf *b) {
    80003290:	1101                	addi	sp,sp,-32
    80003292:	ec06                	sd	ra,24(sp)
    80003294:	e822                	sd	s0,16(sp)
    80003296:	e426                	sd	s1,8(sp)
    80003298:	1000                	addi	s0,sp,32
    8000329a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000329c:	00013517          	auipc	a0,0x13
    800032a0:	70c50513          	addi	a0,a0,1804 # 800169a8 <bcache>
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	946080e7          	jalr	-1722(ra) # 80000bea <acquire>
  b->refcnt--;
    800032ac:	40bc                	lw	a5,64(s1)
    800032ae:	37fd                	addiw	a5,a5,-1
    800032b0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032b2:	00013517          	auipc	a0,0x13
    800032b6:	6f650513          	addi	a0,a0,1782 # 800169a8 <bcache>
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	9e4080e7          	jalr	-1564(ra) # 80000c9e <release>
}
    800032c2:	60e2                	ld	ra,24(sp)
    800032c4:	6442                	ld	s0,16(sp)
    800032c6:	64a2                	ld	s1,8(sp)
    800032c8:	6105                	addi	sp,sp,32
    800032ca:	8082                	ret

00000000800032cc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032cc:	1101                	addi	sp,sp,-32
    800032ce:	ec06                	sd	ra,24(sp)
    800032d0:	e822                	sd	s0,16(sp)
    800032d2:	e426                	sd	s1,8(sp)
    800032d4:	e04a                	sd	s2,0(sp)
    800032d6:	1000                	addi	s0,sp,32
    800032d8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032da:	00d5d59b          	srliw	a1,a1,0xd
    800032de:	0001c797          	auipc	a5,0x1c
    800032e2:	da67a783          	lw	a5,-602(a5) # 8001f084 <sb+0x1c>
    800032e6:	9dbd                	addw	a1,a1,a5
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	d9e080e7          	jalr	-610(ra) # 80003086 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032f0:	0074f713          	andi	a4,s1,7
    800032f4:	4785                	li	a5,1
    800032f6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032fa:	14ce                	slli	s1,s1,0x33
    800032fc:	90d9                	srli	s1,s1,0x36
    800032fe:	00950733          	add	a4,a0,s1
    80003302:	05874703          	lbu	a4,88(a4)
    80003306:	00e7f6b3          	and	a3,a5,a4
    8000330a:	c69d                	beqz	a3,80003338 <bfree+0x6c>
    8000330c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000330e:	94aa                	add	s1,s1,a0
    80003310:	fff7c793          	not	a5,a5
    80003314:	8ff9                	and	a5,a5,a4
    80003316:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000331a:	00001097          	auipc	ra,0x1
    8000331e:	120080e7          	jalr	288(ra) # 8000443a <log_write>
  brelse(bp);
    80003322:	854a                	mv	a0,s2
    80003324:	00000097          	auipc	ra,0x0
    80003328:	e92080e7          	jalr	-366(ra) # 800031b6 <brelse>
}
    8000332c:	60e2                	ld	ra,24(sp)
    8000332e:	6442                	ld	s0,16(sp)
    80003330:	64a2                	ld	s1,8(sp)
    80003332:	6902                	ld	s2,0(sp)
    80003334:	6105                	addi	sp,sp,32
    80003336:	8082                	ret
    panic("freeing free block");
    80003338:	00005517          	auipc	a0,0x5
    8000333c:	21050513          	addi	a0,a0,528 # 80008548 <syscalls+0xf8>
    80003340:	ffffd097          	auipc	ra,0xffffd
    80003344:	204080e7          	jalr	516(ra) # 80000544 <panic>

0000000080003348 <balloc>:
{
    80003348:	711d                	addi	sp,sp,-96
    8000334a:	ec86                	sd	ra,88(sp)
    8000334c:	e8a2                	sd	s0,80(sp)
    8000334e:	e4a6                	sd	s1,72(sp)
    80003350:	e0ca                	sd	s2,64(sp)
    80003352:	fc4e                	sd	s3,56(sp)
    80003354:	f852                	sd	s4,48(sp)
    80003356:	f456                	sd	s5,40(sp)
    80003358:	f05a                	sd	s6,32(sp)
    8000335a:	ec5e                	sd	s7,24(sp)
    8000335c:	e862                	sd	s8,16(sp)
    8000335e:	e466                	sd	s9,8(sp)
    80003360:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003362:	0001c797          	auipc	a5,0x1c
    80003366:	d0a7a783          	lw	a5,-758(a5) # 8001f06c <sb+0x4>
    8000336a:	10078163          	beqz	a5,8000346c <balloc+0x124>
    8000336e:	8baa                	mv	s7,a0
    80003370:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003372:	0001cb17          	auipc	s6,0x1c
    80003376:	cf6b0b13          	addi	s6,s6,-778 # 8001f068 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000337a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000337c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000337e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003380:	6c89                	lui	s9,0x2
    80003382:	a061                	j	8000340a <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003384:	974a                	add	a4,a4,s2
    80003386:	8fd5                	or	a5,a5,a3
    80003388:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000338c:	854a                	mv	a0,s2
    8000338e:	00001097          	auipc	ra,0x1
    80003392:	0ac080e7          	jalr	172(ra) # 8000443a <log_write>
        brelse(bp);
    80003396:	854a                	mv	a0,s2
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	e1e080e7          	jalr	-482(ra) # 800031b6 <brelse>
  bp = bread(dev, bno);
    800033a0:	85a6                	mv	a1,s1
    800033a2:	855e                	mv	a0,s7
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	ce2080e7          	jalr	-798(ra) # 80003086 <bread>
    800033ac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033ae:	40000613          	li	a2,1024
    800033b2:	4581                	li	a1,0
    800033b4:	05850513          	addi	a0,a0,88
    800033b8:	ffffe097          	auipc	ra,0xffffe
    800033bc:	92e080e7          	jalr	-1746(ra) # 80000ce6 <memset>
  log_write(bp);
    800033c0:	854a                	mv	a0,s2
    800033c2:	00001097          	auipc	ra,0x1
    800033c6:	078080e7          	jalr	120(ra) # 8000443a <log_write>
  brelse(bp);
    800033ca:	854a                	mv	a0,s2
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	dea080e7          	jalr	-534(ra) # 800031b6 <brelse>
}
    800033d4:	8526                	mv	a0,s1
    800033d6:	60e6                	ld	ra,88(sp)
    800033d8:	6446                	ld	s0,80(sp)
    800033da:	64a6                	ld	s1,72(sp)
    800033dc:	6906                	ld	s2,64(sp)
    800033de:	79e2                	ld	s3,56(sp)
    800033e0:	7a42                	ld	s4,48(sp)
    800033e2:	7aa2                	ld	s5,40(sp)
    800033e4:	7b02                	ld	s6,32(sp)
    800033e6:	6be2                	ld	s7,24(sp)
    800033e8:	6c42                	ld	s8,16(sp)
    800033ea:	6ca2                	ld	s9,8(sp)
    800033ec:	6125                	addi	sp,sp,96
    800033ee:	8082                	ret
    brelse(bp);
    800033f0:	854a                	mv	a0,s2
    800033f2:	00000097          	auipc	ra,0x0
    800033f6:	dc4080e7          	jalr	-572(ra) # 800031b6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033fa:	015c87bb          	addw	a5,s9,s5
    800033fe:	00078a9b          	sext.w	s5,a5
    80003402:	004b2703          	lw	a4,4(s6)
    80003406:	06eaf363          	bgeu	s5,a4,8000346c <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000340a:	41fad79b          	sraiw	a5,s5,0x1f
    8000340e:	0137d79b          	srliw	a5,a5,0x13
    80003412:	015787bb          	addw	a5,a5,s5
    80003416:	40d7d79b          	sraiw	a5,a5,0xd
    8000341a:	01cb2583          	lw	a1,28(s6)
    8000341e:	9dbd                	addw	a1,a1,a5
    80003420:	855e                	mv	a0,s7
    80003422:	00000097          	auipc	ra,0x0
    80003426:	c64080e7          	jalr	-924(ra) # 80003086 <bread>
    8000342a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000342c:	004b2503          	lw	a0,4(s6)
    80003430:	000a849b          	sext.w	s1,s5
    80003434:	8662                	mv	a2,s8
    80003436:	faa4fde3          	bgeu	s1,a0,800033f0 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000343a:	41f6579b          	sraiw	a5,a2,0x1f
    8000343e:	01d7d69b          	srliw	a3,a5,0x1d
    80003442:	00c6873b          	addw	a4,a3,a2
    80003446:	00777793          	andi	a5,a4,7
    8000344a:	9f95                	subw	a5,a5,a3
    8000344c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003450:	4037571b          	sraiw	a4,a4,0x3
    80003454:	00e906b3          	add	a3,s2,a4
    80003458:	0586c683          	lbu	a3,88(a3)
    8000345c:	00d7f5b3          	and	a1,a5,a3
    80003460:	d195                	beqz	a1,80003384 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003462:	2605                	addiw	a2,a2,1
    80003464:	2485                	addiw	s1,s1,1
    80003466:	fd4618e3          	bne	a2,s4,80003436 <balloc+0xee>
    8000346a:	b759                	j	800033f0 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000346c:	00005517          	auipc	a0,0x5
    80003470:	0f450513          	addi	a0,a0,244 # 80008560 <syscalls+0x110>
    80003474:	ffffd097          	auipc	ra,0xffffd
    80003478:	11a080e7          	jalr	282(ra) # 8000058e <printf>
  return 0;
    8000347c:	4481                	li	s1,0
    8000347e:	bf99                	j	800033d4 <balloc+0x8c>

0000000080003480 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003480:	7179                	addi	sp,sp,-48
    80003482:	f406                	sd	ra,40(sp)
    80003484:	f022                	sd	s0,32(sp)
    80003486:	ec26                	sd	s1,24(sp)
    80003488:	e84a                	sd	s2,16(sp)
    8000348a:	e44e                	sd	s3,8(sp)
    8000348c:	e052                	sd	s4,0(sp)
    8000348e:	1800                	addi	s0,sp,48
    80003490:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003492:	47ad                	li	a5,11
    80003494:	02b7e763          	bltu	a5,a1,800034c2 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003498:	02059493          	slli	s1,a1,0x20
    8000349c:	9081                	srli	s1,s1,0x20
    8000349e:	048a                	slli	s1,s1,0x2
    800034a0:	94aa                	add	s1,s1,a0
    800034a2:	0504a903          	lw	s2,80(s1)
    800034a6:	06091e63          	bnez	s2,80003522 <bmap+0xa2>
      addr = balloc(ip->dev);
    800034aa:	4108                	lw	a0,0(a0)
    800034ac:	00000097          	auipc	ra,0x0
    800034b0:	e9c080e7          	jalr	-356(ra) # 80003348 <balloc>
    800034b4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034b8:	06090563          	beqz	s2,80003522 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800034bc:	0524a823          	sw	s2,80(s1)
    800034c0:	a08d                	j	80003522 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034c2:	ff45849b          	addiw	s1,a1,-12
    800034c6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034ca:	0ff00793          	li	a5,255
    800034ce:	08e7e563          	bltu	a5,a4,80003558 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034d2:	08052903          	lw	s2,128(a0)
    800034d6:	00091d63          	bnez	s2,800034f0 <bmap+0x70>
      addr = balloc(ip->dev);
    800034da:	4108                	lw	a0,0(a0)
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	e6c080e7          	jalr	-404(ra) # 80003348 <balloc>
    800034e4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034e8:	02090d63          	beqz	s2,80003522 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034ec:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800034f0:	85ca                	mv	a1,s2
    800034f2:	0009a503          	lw	a0,0(s3)
    800034f6:	00000097          	auipc	ra,0x0
    800034fa:	b90080e7          	jalr	-1136(ra) # 80003086 <bread>
    800034fe:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003500:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003504:	02049593          	slli	a1,s1,0x20
    80003508:	9181                	srli	a1,a1,0x20
    8000350a:	058a                	slli	a1,a1,0x2
    8000350c:	00b784b3          	add	s1,a5,a1
    80003510:	0004a903          	lw	s2,0(s1)
    80003514:	02090063          	beqz	s2,80003534 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003518:	8552                	mv	a0,s4
    8000351a:	00000097          	auipc	ra,0x0
    8000351e:	c9c080e7          	jalr	-868(ra) # 800031b6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003522:	854a                	mv	a0,s2
    80003524:	70a2                	ld	ra,40(sp)
    80003526:	7402                	ld	s0,32(sp)
    80003528:	64e2                	ld	s1,24(sp)
    8000352a:	6942                	ld	s2,16(sp)
    8000352c:	69a2                	ld	s3,8(sp)
    8000352e:	6a02                	ld	s4,0(sp)
    80003530:	6145                	addi	sp,sp,48
    80003532:	8082                	ret
      addr = balloc(ip->dev);
    80003534:	0009a503          	lw	a0,0(s3)
    80003538:	00000097          	auipc	ra,0x0
    8000353c:	e10080e7          	jalr	-496(ra) # 80003348 <balloc>
    80003540:	0005091b          	sext.w	s2,a0
      if(addr){
    80003544:	fc090ae3          	beqz	s2,80003518 <bmap+0x98>
        a[bn] = addr;
    80003548:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000354c:	8552                	mv	a0,s4
    8000354e:	00001097          	auipc	ra,0x1
    80003552:	eec080e7          	jalr	-276(ra) # 8000443a <log_write>
    80003556:	b7c9                	j	80003518 <bmap+0x98>
  panic("bmap: out of range");
    80003558:	00005517          	auipc	a0,0x5
    8000355c:	02050513          	addi	a0,a0,32 # 80008578 <syscalls+0x128>
    80003560:	ffffd097          	auipc	ra,0xffffd
    80003564:	fe4080e7          	jalr	-28(ra) # 80000544 <panic>

0000000080003568 <iget>:
{
    80003568:	7179                	addi	sp,sp,-48
    8000356a:	f406                	sd	ra,40(sp)
    8000356c:	f022                	sd	s0,32(sp)
    8000356e:	ec26                	sd	s1,24(sp)
    80003570:	e84a                	sd	s2,16(sp)
    80003572:	e44e                	sd	s3,8(sp)
    80003574:	e052                	sd	s4,0(sp)
    80003576:	1800                	addi	s0,sp,48
    80003578:	89aa                	mv	s3,a0
    8000357a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000357c:	0001c517          	auipc	a0,0x1c
    80003580:	b0c50513          	addi	a0,a0,-1268 # 8001f088 <itable>
    80003584:	ffffd097          	auipc	ra,0xffffd
    80003588:	666080e7          	jalr	1638(ra) # 80000bea <acquire>
  empty = 0;
    8000358c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000358e:	0001c497          	auipc	s1,0x1c
    80003592:	b1248493          	addi	s1,s1,-1262 # 8001f0a0 <itable+0x18>
    80003596:	0001d697          	auipc	a3,0x1d
    8000359a:	59a68693          	addi	a3,a3,1434 # 80020b30 <log>
    8000359e:	a039                	j	800035ac <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035a0:	02090b63          	beqz	s2,800035d6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035a4:	08848493          	addi	s1,s1,136
    800035a8:	02d48a63          	beq	s1,a3,800035dc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035ac:	449c                	lw	a5,8(s1)
    800035ae:	fef059e3          	blez	a5,800035a0 <iget+0x38>
    800035b2:	4098                	lw	a4,0(s1)
    800035b4:	ff3716e3          	bne	a4,s3,800035a0 <iget+0x38>
    800035b8:	40d8                	lw	a4,4(s1)
    800035ba:	ff4713e3          	bne	a4,s4,800035a0 <iget+0x38>
      ip->ref++;
    800035be:	2785                	addiw	a5,a5,1
    800035c0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035c2:	0001c517          	auipc	a0,0x1c
    800035c6:	ac650513          	addi	a0,a0,-1338 # 8001f088 <itable>
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	6d4080e7          	jalr	1748(ra) # 80000c9e <release>
      return ip;
    800035d2:	8926                	mv	s2,s1
    800035d4:	a03d                	j	80003602 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035d6:	f7f9                	bnez	a5,800035a4 <iget+0x3c>
    800035d8:	8926                	mv	s2,s1
    800035da:	b7e9                	j	800035a4 <iget+0x3c>
  if(empty == 0)
    800035dc:	02090c63          	beqz	s2,80003614 <iget+0xac>
  ip->dev = dev;
    800035e0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035e4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035e8:	4785                	li	a5,1
    800035ea:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035ee:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035f2:	0001c517          	auipc	a0,0x1c
    800035f6:	a9650513          	addi	a0,a0,-1386 # 8001f088 <itable>
    800035fa:	ffffd097          	auipc	ra,0xffffd
    800035fe:	6a4080e7          	jalr	1700(ra) # 80000c9e <release>
}
    80003602:	854a                	mv	a0,s2
    80003604:	70a2                	ld	ra,40(sp)
    80003606:	7402                	ld	s0,32(sp)
    80003608:	64e2                	ld	s1,24(sp)
    8000360a:	6942                	ld	s2,16(sp)
    8000360c:	69a2                	ld	s3,8(sp)
    8000360e:	6a02                	ld	s4,0(sp)
    80003610:	6145                	addi	sp,sp,48
    80003612:	8082                	ret
    panic("iget: no inodes");
    80003614:	00005517          	auipc	a0,0x5
    80003618:	f7c50513          	addi	a0,a0,-132 # 80008590 <syscalls+0x140>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	f28080e7          	jalr	-216(ra) # 80000544 <panic>

0000000080003624 <fsinit>:
fsinit(int dev) {
    80003624:	7179                	addi	sp,sp,-48
    80003626:	f406                	sd	ra,40(sp)
    80003628:	f022                	sd	s0,32(sp)
    8000362a:	ec26                	sd	s1,24(sp)
    8000362c:	e84a                	sd	s2,16(sp)
    8000362e:	e44e                	sd	s3,8(sp)
    80003630:	1800                	addi	s0,sp,48
    80003632:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003634:	4585                	li	a1,1
    80003636:	00000097          	auipc	ra,0x0
    8000363a:	a50080e7          	jalr	-1456(ra) # 80003086 <bread>
    8000363e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003640:	0001c997          	auipc	s3,0x1c
    80003644:	a2898993          	addi	s3,s3,-1496 # 8001f068 <sb>
    80003648:	02000613          	li	a2,32
    8000364c:	05850593          	addi	a1,a0,88
    80003650:	854e                	mv	a0,s3
    80003652:	ffffd097          	auipc	ra,0xffffd
    80003656:	6f4080e7          	jalr	1780(ra) # 80000d46 <memmove>
  brelse(bp);
    8000365a:	8526                	mv	a0,s1
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	b5a080e7          	jalr	-1190(ra) # 800031b6 <brelse>
  if(sb.magic != FSMAGIC)
    80003664:	0009a703          	lw	a4,0(s3)
    80003668:	102037b7          	lui	a5,0x10203
    8000366c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003670:	02f71263          	bne	a4,a5,80003694 <fsinit+0x70>
  initlog(dev, &sb);
    80003674:	0001c597          	auipc	a1,0x1c
    80003678:	9f458593          	addi	a1,a1,-1548 # 8001f068 <sb>
    8000367c:	854a                	mv	a0,s2
    8000367e:	00001097          	auipc	ra,0x1
    80003682:	b40080e7          	jalr	-1216(ra) # 800041be <initlog>
}
    80003686:	70a2                	ld	ra,40(sp)
    80003688:	7402                	ld	s0,32(sp)
    8000368a:	64e2                	ld	s1,24(sp)
    8000368c:	6942                	ld	s2,16(sp)
    8000368e:	69a2                	ld	s3,8(sp)
    80003690:	6145                	addi	sp,sp,48
    80003692:	8082                	ret
    panic("invalid file system");
    80003694:	00005517          	auipc	a0,0x5
    80003698:	f0c50513          	addi	a0,a0,-244 # 800085a0 <syscalls+0x150>
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	ea8080e7          	jalr	-344(ra) # 80000544 <panic>

00000000800036a4 <iinit>:
{
    800036a4:	7179                	addi	sp,sp,-48
    800036a6:	f406                	sd	ra,40(sp)
    800036a8:	f022                	sd	s0,32(sp)
    800036aa:	ec26                	sd	s1,24(sp)
    800036ac:	e84a                	sd	s2,16(sp)
    800036ae:	e44e                	sd	s3,8(sp)
    800036b0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036b2:	00005597          	auipc	a1,0x5
    800036b6:	f0658593          	addi	a1,a1,-250 # 800085b8 <syscalls+0x168>
    800036ba:	0001c517          	auipc	a0,0x1c
    800036be:	9ce50513          	addi	a0,a0,-1586 # 8001f088 <itable>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	498080e7          	jalr	1176(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    800036ca:	0001c497          	auipc	s1,0x1c
    800036ce:	9e648493          	addi	s1,s1,-1562 # 8001f0b0 <itable+0x28>
    800036d2:	0001d997          	auipc	s3,0x1d
    800036d6:	46e98993          	addi	s3,s3,1134 # 80020b40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036da:	00005917          	auipc	s2,0x5
    800036de:	ee690913          	addi	s2,s2,-282 # 800085c0 <syscalls+0x170>
    800036e2:	85ca                	mv	a1,s2
    800036e4:	8526                	mv	a0,s1
    800036e6:	00001097          	auipc	ra,0x1
    800036ea:	e3a080e7          	jalr	-454(ra) # 80004520 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036ee:	08848493          	addi	s1,s1,136
    800036f2:	ff3498e3          	bne	s1,s3,800036e2 <iinit+0x3e>
}
    800036f6:	70a2                	ld	ra,40(sp)
    800036f8:	7402                	ld	s0,32(sp)
    800036fa:	64e2                	ld	s1,24(sp)
    800036fc:	6942                	ld	s2,16(sp)
    800036fe:	69a2                	ld	s3,8(sp)
    80003700:	6145                	addi	sp,sp,48
    80003702:	8082                	ret

0000000080003704 <ialloc>:
{
    80003704:	715d                	addi	sp,sp,-80
    80003706:	e486                	sd	ra,72(sp)
    80003708:	e0a2                	sd	s0,64(sp)
    8000370a:	fc26                	sd	s1,56(sp)
    8000370c:	f84a                	sd	s2,48(sp)
    8000370e:	f44e                	sd	s3,40(sp)
    80003710:	f052                	sd	s4,32(sp)
    80003712:	ec56                	sd	s5,24(sp)
    80003714:	e85a                	sd	s6,16(sp)
    80003716:	e45e                	sd	s7,8(sp)
    80003718:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000371a:	0001c717          	auipc	a4,0x1c
    8000371e:	95a72703          	lw	a4,-1702(a4) # 8001f074 <sb+0xc>
    80003722:	4785                	li	a5,1
    80003724:	04e7fa63          	bgeu	a5,a4,80003778 <ialloc+0x74>
    80003728:	8aaa                	mv	s5,a0
    8000372a:	8bae                	mv	s7,a1
    8000372c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000372e:	0001ca17          	auipc	s4,0x1c
    80003732:	93aa0a13          	addi	s4,s4,-1734 # 8001f068 <sb>
    80003736:	00048b1b          	sext.w	s6,s1
    8000373a:	0044d593          	srli	a1,s1,0x4
    8000373e:	018a2783          	lw	a5,24(s4)
    80003742:	9dbd                	addw	a1,a1,a5
    80003744:	8556                	mv	a0,s5
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	940080e7          	jalr	-1728(ra) # 80003086 <bread>
    8000374e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003750:	05850993          	addi	s3,a0,88
    80003754:	00f4f793          	andi	a5,s1,15
    80003758:	079a                	slli	a5,a5,0x6
    8000375a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000375c:	00099783          	lh	a5,0(s3)
    80003760:	c3a1                	beqz	a5,800037a0 <ialloc+0x9c>
    brelse(bp);
    80003762:	00000097          	auipc	ra,0x0
    80003766:	a54080e7          	jalr	-1452(ra) # 800031b6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000376a:	0485                	addi	s1,s1,1
    8000376c:	00ca2703          	lw	a4,12(s4)
    80003770:	0004879b          	sext.w	a5,s1
    80003774:	fce7e1e3          	bltu	a5,a4,80003736 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003778:	00005517          	auipc	a0,0x5
    8000377c:	e5050513          	addi	a0,a0,-432 # 800085c8 <syscalls+0x178>
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	e0e080e7          	jalr	-498(ra) # 8000058e <printf>
  return 0;
    80003788:	4501                	li	a0,0
}
    8000378a:	60a6                	ld	ra,72(sp)
    8000378c:	6406                	ld	s0,64(sp)
    8000378e:	74e2                	ld	s1,56(sp)
    80003790:	7942                	ld	s2,48(sp)
    80003792:	79a2                	ld	s3,40(sp)
    80003794:	7a02                	ld	s4,32(sp)
    80003796:	6ae2                	ld	s5,24(sp)
    80003798:	6b42                	ld	s6,16(sp)
    8000379a:	6ba2                	ld	s7,8(sp)
    8000379c:	6161                	addi	sp,sp,80
    8000379e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800037a0:	04000613          	li	a2,64
    800037a4:	4581                	li	a1,0
    800037a6:	854e                	mv	a0,s3
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	53e080e7          	jalr	1342(ra) # 80000ce6 <memset>
      dip->type = type;
    800037b0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037b4:	854a                	mv	a0,s2
    800037b6:	00001097          	auipc	ra,0x1
    800037ba:	c84080e7          	jalr	-892(ra) # 8000443a <log_write>
      brelse(bp);
    800037be:	854a                	mv	a0,s2
    800037c0:	00000097          	auipc	ra,0x0
    800037c4:	9f6080e7          	jalr	-1546(ra) # 800031b6 <brelse>
      return iget(dev, inum);
    800037c8:	85da                	mv	a1,s6
    800037ca:	8556                	mv	a0,s5
    800037cc:	00000097          	auipc	ra,0x0
    800037d0:	d9c080e7          	jalr	-612(ra) # 80003568 <iget>
    800037d4:	bf5d                	j	8000378a <ialloc+0x86>

00000000800037d6 <iupdate>:
{
    800037d6:	1101                	addi	sp,sp,-32
    800037d8:	ec06                	sd	ra,24(sp)
    800037da:	e822                	sd	s0,16(sp)
    800037dc:	e426                	sd	s1,8(sp)
    800037de:	e04a                	sd	s2,0(sp)
    800037e0:	1000                	addi	s0,sp,32
    800037e2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037e4:	415c                	lw	a5,4(a0)
    800037e6:	0047d79b          	srliw	a5,a5,0x4
    800037ea:	0001c597          	auipc	a1,0x1c
    800037ee:	8965a583          	lw	a1,-1898(a1) # 8001f080 <sb+0x18>
    800037f2:	9dbd                	addw	a1,a1,a5
    800037f4:	4108                	lw	a0,0(a0)
    800037f6:	00000097          	auipc	ra,0x0
    800037fa:	890080e7          	jalr	-1904(ra) # 80003086 <bread>
    800037fe:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003800:	05850793          	addi	a5,a0,88
    80003804:	40c8                	lw	a0,4(s1)
    80003806:	893d                	andi	a0,a0,15
    80003808:	051a                	slli	a0,a0,0x6
    8000380a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000380c:	04449703          	lh	a4,68(s1)
    80003810:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003814:	04649703          	lh	a4,70(s1)
    80003818:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000381c:	04849703          	lh	a4,72(s1)
    80003820:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003824:	04a49703          	lh	a4,74(s1)
    80003828:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000382c:	44f8                	lw	a4,76(s1)
    8000382e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003830:	03400613          	li	a2,52
    80003834:	05048593          	addi	a1,s1,80
    80003838:	0531                	addi	a0,a0,12
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	50c080e7          	jalr	1292(ra) # 80000d46 <memmove>
  log_write(bp);
    80003842:	854a                	mv	a0,s2
    80003844:	00001097          	auipc	ra,0x1
    80003848:	bf6080e7          	jalr	-1034(ra) # 8000443a <log_write>
  brelse(bp);
    8000384c:	854a                	mv	a0,s2
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	968080e7          	jalr	-1688(ra) # 800031b6 <brelse>
}
    80003856:	60e2                	ld	ra,24(sp)
    80003858:	6442                	ld	s0,16(sp)
    8000385a:	64a2                	ld	s1,8(sp)
    8000385c:	6902                	ld	s2,0(sp)
    8000385e:	6105                	addi	sp,sp,32
    80003860:	8082                	ret

0000000080003862 <idup>:
{
    80003862:	1101                	addi	sp,sp,-32
    80003864:	ec06                	sd	ra,24(sp)
    80003866:	e822                	sd	s0,16(sp)
    80003868:	e426                	sd	s1,8(sp)
    8000386a:	1000                	addi	s0,sp,32
    8000386c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000386e:	0001c517          	auipc	a0,0x1c
    80003872:	81a50513          	addi	a0,a0,-2022 # 8001f088 <itable>
    80003876:	ffffd097          	auipc	ra,0xffffd
    8000387a:	374080e7          	jalr	884(ra) # 80000bea <acquire>
  ip->ref++;
    8000387e:	449c                	lw	a5,8(s1)
    80003880:	2785                	addiw	a5,a5,1
    80003882:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003884:	0001c517          	auipc	a0,0x1c
    80003888:	80450513          	addi	a0,a0,-2044 # 8001f088 <itable>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	412080e7          	jalr	1042(ra) # 80000c9e <release>
}
    80003894:	8526                	mv	a0,s1
    80003896:	60e2                	ld	ra,24(sp)
    80003898:	6442                	ld	s0,16(sp)
    8000389a:	64a2                	ld	s1,8(sp)
    8000389c:	6105                	addi	sp,sp,32
    8000389e:	8082                	ret

00000000800038a0 <ilock>:
{
    800038a0:	1101                	addi	sp,sp,-32
    800038a2:	ec06                	sd	ra,24(sp)
    800038a4:	e822                	sd	s0,16(sp)
    800038a6:	e426                	sd	s1,8(sp)
    800038a8:	e04a                	sd	s2,0(sp)
    800038aa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038ac:	c115                	beqz	a0,800038d0 <ilock+0x30>
    800038ae:	84aa                	mv	s1,a0
    800038b0:	451c                	lw	a5,8(a0)
    800038b2:	00f05f63          	blez	a5,800038d0 <ilock+0x30>
  acquiresleep(&ip->lock);
    800038b6:	0541                	addi	a0,a0,16
    800038b8:	00001097          	auipc	ra,0x1
    800038bc:	ca2080e7          	jalr	-862(ra) # 8000455a <acquiresleep>
  if(ip->valid == 0){
    800038c0:	40bc                	lw	a5,64(s1)
    800038c2:	cf99                	beqz	a5,800038e0 <ilock+0x40>
}
    800038c4:	60e2                	ld	ra,24(sp)
    800038c6:	6442                	ld	s0,16(sp)
    800038c8:	64a2                	ld	s1,8(sp)
    800038ca:	6902                	ld	s2,0(sp)
    800038cc:	6105                	addi	sp,sp,32
    800038ce:	8082                	ret
    panic("ilock");
    800038d0:	00005517          	auipc	a0,0x5
    800038d4:	d1050513          	addi	a0,a0,-752 # 800085e0 <syscalls+0x190>
    800038d8:	ffffd097          	auipc	ra,0xffffd
    800038dc:	c6c080e7          	jalr	-916(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038e0:	40dc                	lw	a5,4(s1)
    800038e2:	0047d79b          	srliw	a5,a5,0x4
    800038e6:	0001b597          	auipc	a1,0x1b
    800038ea:	79a5a583          	lw	a1,1946(a1) # 8001f080 <sb+0x18>
    800038ee:	9dbd                	addw	a1,a1,a5
    800038f0:	4088                	lw	a0,0(s1)
    800038f2:	fffff097          	auipc	ra,0xfffff
    800038f6:	794080e7          	jalr	1940(ra) # 80003086 <bread>
    800038fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038fc:	05850593          	addi	a1,a0,88
    80003900:	40dc                	lw	a5,4(s1)
    80003902:	8bbd                	andi	a5,a5,15
    80003904:	079a                	slli	a5,a5,0x6
    80003906:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003908:	00059783          	lh	a5,0(a1)
    8000390c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003910:	00259783          	lh	a5,2(a1)
    80003914:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003918:	00459783          	lh	a5,4(a1)
    8000391c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003920:	00659783          	lh	a5,6(a1)
    80003924:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003928:	459c                	lw	a5,8(a1)
    8000392a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000392c:	03400613          	li	a2,52
    80003930:	05b1                	addi	a1,a1,12
    80003932:	05048513          	addi	a0,s1,80
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	410080e7          	jalr	1040(ra) # 80000d46 <memmove>
    brelse(bp);
    8000393e:	854a                	mv	a0,s2
    80003940:	00000097          	auipc	ra,0x0
    80003944:	876080e7          	jalr	-1930(ra) # 800031b6 <brelse>
    ip->valid = 1;
    80003948:	4785                	li	a5,1
    8000394a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000394c:	04449783          	lh	a5,68(s1)
    80003950:	fbb5                	bnez	a5,800038c4 <ilock+0x24>
      panic("ilock: no type");
    80003952:	00005517          	auipc	a0,0x5
    80003956:	c9650513          	addi	a0,a0,-874 # 800085e8 <syscalls+0x198>
    8000395a:	ffffd097          	auipc	ra,0xffffd
    8000395e:	bea080e7          	jalr	-1046(ra) # 80000544 <panic>

0000000080003962 <iunlock>:
{
    80003962:	1101                	addi	sp,sp,-32
    80003964:	ec06                	sd	ra,24(sp)
    80003966:	e822                	sd	s0,16(sp)
    80003968:	e426                	sd	s1,8(sp)
    8000396a:	e04a                	sd	s2,0(sp)
    8000396c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000396e:	c905                	beqz	a0,8000399e <iunlock+0x3c>
    80003970:	84aa                	mv	s1,a0
    80003972:	01050913          	addi	s2,a0,16
    80003976:	854a                	mv	a0,s2
    80003978:	00001097          	auipc	ra,0x1
    8000397c:	c7c080e7          	jalr	-900(ra) # 800045f4 <holdingsleep>
    80003980:	cd19                	beqz	a0,8000399e <iunlock+0x3c>
    80003982:	449c                	lw	a5,8(s1)
    80003984:	00f05d63          	blez	a5,8000399e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003988:	854a                	mv	a0,s2
    8000398a:	00001097          	auipc	ra,0x1
    8000398e:	c26080e7          	jalr	-986(ra) # 800045b0 <releasesleep>
}
    80003992:	60e2                	ld	ra,24(sp)
    80003994:	6442                	ld	s0,16(sp)
    80003996:	64a2                	ld	s1,8(sp)
    80003998:	6902                	ld	s2,0(sp)
    8000399a:	6105                	addi	sp,sp,32
    8000399c:	8082                	ret
    panic("iunlock");
    8000399e:	00005517          	auipc	a0,0x5
    800039a2:	c5a50513          	addi	a0,a0,-934 # 800085f8 <syscalls+0x1a8>
    800039a6:	ffffd097          	auipc	ra,0xffffd
    800039aa:	b9e080e7          	jalr	-1122(ra) # 80000544 <panic>

00000000800039ae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039ae:	7179                	addi	sp,sp,-48
    800039b0:	f406                	sd	ra,40(sp)
    800039b2:	f022                	sd	s0,32(sp)
    800039b4:	ec26                	sd	s1,24(sp)
    800039b6:	e84a                	sd	s2,16(sp)
    800039b8:	e44e                	sd	s3,8(sp)
    800039ba:	e052                	sd	s4,0(sp)
    800039bc:	1800                	addi	s0,sp,48
    800039be:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800039c0:	05050493          	addi	s1,a0,80
    800039c4:	08050913          	addi	s2,a0,128
    800039c8:	a021                	j	800039d0 <itrunc+0x22>
    800039ca:	0491                	addi	s1,s1,4
    800039cc:	01248d63          	beq	s1,s2,800039e6 <itrunc+0x38>
    if(ip->addrs[i]){
    800039d0:	408c                	lw	a1,0(s1)
    800039d2:	dde5                	beqz	a1,800039ca <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800039d4:	0009a503          	lw	a0,0(s3)
    800039d8:	00000097          	auipc	ra,0x0
    800039dc:	8f4080e7          	jalr	-1804(ra) # 800032cc <bfree>
      ip->addrs[i] = 0;
    800039e0:	0004a023          	sw	zero,0(s1)
    800039e4:	b7dd                	j	800039ca <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039e6:	0809a583          	lw	a1,128(s3)
    800039ea:	e185                	bnez	a1,80003a0a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039ec:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039f0:	854e                	mv	a0,s3
    800039f2:	00000097          	auipc	ra,0x0
    800039f6:	de4080e7          	jalr	-540(ra) # 800037d6 <iupdate>
}
    800039fa:	70a2                	ld	ra,40(sp)
    800039fc:	7402                	ld	s0,32(sp)
    800039fe:	64e2                	ld	s1,24(sp)
    80003a00:	6942                	ld	s2,16(sp)
    80003a02:	69a2                	ld	s3,8(sp)
    80003a04:	6a02                	ld	s4,0(sp)
    80003a06:	6145                	addi	sp,sp,48
    80003a08:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a0a:	0009a503          	lw	a0,0(s3)
    80003a0e:	fffff097          	auipc	ra,0xfffff
    80003a12:	678080e7          	jalr	1656(ra) # 80003086 <bread>
    80003a16:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a18:	05850493          	addi	s1,a0,88
    80003a1c:	45850913          	addi	s2,a0,1112
    80003a20:	a811                	j	80003a34 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003a22:	0009a503          	lw	a0,0(s3)
    80003a26:	00000097          	auipc	ra,0x0
    80003a2a:	8a6080e7          	jalr	-1882(ra) # 800032cc <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003a2e:	0491                	addi	s1,s1,4
    80003a30:	01248563          	beq	s1,s2,80003a3a <itrunc+0x8c>
      if(a[j])
    80003a34:	408c                	lw	a1,0(s1)
    80003a36:	dde5                	beqz	a1,80003a2e <itrunc+0x80>
    80003a38:	b7ed                	j	80003a22 <itrunc+0x74>
    brelse(bp);
    80003a3a:	8552                	mv	a0,s4
    80003a3c:	fffff097          	auipc	ra,0xfffff
    80003a40:	77a080e7          	jalr	1914(ra) # 800031b6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a44:	0809a583          	lw	a1,128(s3)
    80003a48:	0009a503          	lw	a0,0(s3)
    80003a4c:	00000097          	auipc	ra,0x0
    80003a50:	880080e7          	jalr	-1920(ra) # 800032cc <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a54:	0809a023          	sw	zero,128(s3)
    80003a58:	bf51                	j	800039ec <itrunc+0x3e>

0000000080003a5a <iput>:
{
    80003a5a:	1101                	addi	sp,sp,-32
    80003a5c:	ec06                	sd	ra,24(sp)
    80003a5e:	e822                	sd	s0,16(sp)
    80003a60:	e426                	sd	s1,8(sp)
    80003a62:	e04a                	sd	s2,0(sp)
    80003a64:	1000                	addi	s0,sp,32
    80003a66:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a68:	0001b517          	auipc	a0,0x1b
    80003a6c:	62050513          	addi	a0,a0,1568 # 8001f088 <itable>
    80003a70:	ffffd097          	auipc	ra,0xffffd
    80003a74:	17a080e7          	jalr	378(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a78:	4498                	lw	a4,8(s1)
    80003a7a:	4785                	li	a5,1
    80003a7c:	02f70363          	beq	a4,a5,80003aa2 <iput+0x48>
  ip->ref--;
    80003a80:	449c                	lw	a5,8(s1)
    80003a82:	37fd                	addiw	a5,a5,-1
    80003a84:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a86:	0001b517          	auipc	a0,0x1b
    80003a8a:	60250513          	addi	a0,a0,1538 # 8001f088 <itable>
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	210080e7          	jalr	528(ra) # 80000c9e <release>
}
    80003a96:	60e2                	ld	ra,24(sp)
    80003a98:	6442                	ld	s0,16(sp)
    80003a9a:	64a2                	ld	s1,8(sp)
    80003a9c:	6902                	ld	s2,0(sp)
    80003a9e:	6105                	addi	sp,sp,32
    80003aa0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003aa2:	40bc                	lw	a5,64(s1)
    80003aa4:	dff1                	beqz	a5,80003a80 <iput+0x26>
    80003aa6:	04a49783          	lh	a5,74(s1)
    80003aaa:	fbf9                	bnez	a5,80003a80 <iput+0x26>
    acquiresleep(&ip->lock);
    80003aac:	01048913          	addi	s2,s1,16
    80003ab0:	854a                	mv	a0,s2
    80003ab2:	00001097          	auipc	ra,0x1
    80003ab6:	aa8080e7          	jalr	-1368(ra) # 8000455a <acquiresleep>
    release(&itable.lock);
    80003aba:	0001b517          	auipc	a0,0x1b
    80003abe:	5ce50513          	addi	a0,a0,1486 # 8001f088 <itable>
    80003ac2:	ffffd097          	auipc	ra,0xffffd
    80003ac6:	1dc080e7          	jalr	476(ra) # 80000c9e <release>
    itrunc(ip);
    80003aca:	8526                	mv	a0,s1
    80003acc:	00000097          	auipc	ra,0x0
    80003ad0:	ee2080e7          	jalr	-286(ra) # 800039ae <itrunc>
    ip->type = 0;
    80003ad4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ad8:	8526                	mv	a0,s1
    80003ada:	00000097          	auipc	ra,0x0
    80003ade:	cfc080e7          	jalr	-772(ra) # 800037d6 <iupdate>
    ip->valid = 0;
    80003ae2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	00001097          	auipc	ra,0x1
    80003aec:	ac8080e7          	jalr	-1336(ra) # 800045b0 <releasesleep>
    acquire(&itable.lock);
    80003af0:	0001b517          	auipc	a0,0x1b
    80003af4:	59850513          	addi	a0,a0,1432 # 8001f088 <itable>
    80003af8:	ffffd097          	auipc	ra,0xffffd
    80003afc:	0f2080e7          	jalr	242(ra) # 80000bea <acquire>
    80003b00:	b741                	j	80003a80 <iput+0x26>

0000000080003b02 <iunlockput>:
{
    80003b02:	1101                	addi	sp,sp,-32
    80003b04:	ec06                	sd	ra,24(sp)
    80003b06:	e822                	sd	s0,16(sp)
    80003b08:	e426                	sd	s1,8(sp)
    80003b0a:	1000                	addi	s0,sp,32
    80003b0c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b0e:	00000097          	auipc	ra,0x0
    80003b12:	e54080e7          	jalr	-428(ra) # 80003962 <iunlock>
  iput(ip);
    80003b16:	8526                	mv	a0,s1
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	f42080e7          	jalr	-190(ra) # 80003a5a <iput>
}
    80003b20:	60e2                	ld	ra,24(sp)
    80003b22:	6442                	ld	s0,16(sp)
    80003b24:	64a2                	ld	s1,8(sp)
    80003b26:	6105                	addi	sp,sp,32
    80003b28:	8082                	ret

0000000080003b2a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b2a:	1141                	addi	sp,sp,-16
    80003b2c:	e422                	sd	s0,8(sp)
    80003b2e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b30:	411c                	lw	a5,0(a0)
    80003b32:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b34:	415c                	lw	a5,4(a0)
    80003b36:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b38:	04451783          	lh	a5,68(a0)
    80003b3c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b40:	04a51783          	lh	a5,74(a0)
    80003b44:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b48:	04c56783          	lwu	a5,76(a0)
    80003b4c:	e99c                	sd	a5,16(a1)
}
    80003b4e:	6422                	ld	s0,8(sp)
    80003b50:	0141                	addi	sp,sp,16
    80003b52:	8082                	ret

0000000080003b54 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b54:	457c                	lw	a5,76(a0)
    80003b56:	0ed7e963          	bltu	a5,a3,80003c48 <readi+0xf4>
{
    80003b5a:	7159                	addi	sp,sp,-112
    80003b5c:	f486                	sd	ra,104(sp)
    80003b5e:	f0a2                	sd	s0,96(sp)
    80003b60:	eca6                	sd	s1,88(sp)
    80003b62:	e8ca                	sd	s2,80(sp)
    80003b64:	e4ce                	sd	s3,72(sp)
    80003b66:	e0d2                	sd	s4,64(sp)
    80003b68:	fc56                	sd	s5,56(sp)
    80003b6a:	f85a                	sd	s6,48(sp)
    80003b6c:	f45e                	sd	s7,40(sp)
    80003b6e:	f062                	sd	s8,32(sp)
    80003b70:	ec66                	sd	s9,24(sp)
    80003b72:	e86a                	sd	s10,16(sp)
    80003b74:	e46e                	sd	s11,8(sp)
    80003b76:	1880                	addi	s0,sp,112
    80003b78:	8b2a                	mv	s6,a0
    80003b7a:	8bae                	mv	s7,a1
    80003b7c:	8a32                	mv	s4,a2
    80003b7e:	84b6                	mv	s1,a3
    80003b80:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b82:	9f35                	addw	a4,a4,a3
    return 0;
    80003b84:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b86:	0ad76063          	bltu	a4,a3,80003c26 <readi+0xd2>
  if(off + n > ip->size)
    80003b8a:	00e7f463          	bgeu	a5,a4,80003b92 <readi+0x3e>
    n = ip->size - off;
    80003b8e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b92:	0a0a8963          	beqz	s5,80003c44 <readi+0xf0>
    80003b96:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b98:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b9c:	5c7d                	li	s8,-1
    80003b9e:	a82d                	j	80003bd8 <readi+0x84>
    80003ba0:	020d1d93          	slli	s11,s10,0x20
    80003ba4:	020ddd93          	srli	s11,s11,0x20
    80003ba8:	05890613          	addi	a2,s2,88
    80003bac:	86ee                	mv	a3,s11
    80003bae:	963a                	add	a2,a2,a4
    80003bb0:	85d2                	mv	a1,s4
    80003bb2:	855e                	mv	a0,s7
    80003bb4:	fffff097          	auipc	ra,0xfffff
    80003bb8:	912080e7          	jalr	-1774(ra) # 800024c6 <either_copyout>
    80003bbc:	05850d63          	beq	a0,s8,80003c16 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bc0:	854a                	mv	a0,s2
    80003bc2:	fffff097          	auipc	ra,0xfffff
    80003bc6:	5f4080e7          	jalr	1524(ra) # 800031b6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bca:	013d09bb          	addw	s3,s10,s3
    80003bce:	009d04bb          	addw	s1,s10,s1
    80003bd2:	9a6e                	add	s4,s4,s11
    80003bd4:	0559f763          	bgeu	s3,s5,80003c22 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003bd8:	00a4d59b          	srliw	a1,s1,0xa
    80003bdc:	855a                	mv	a0,s6
    80003bde:	00000097          	auipc	ra,0x0
    80003be2:	8a2080e7          	jalr	-1886(ra) # 80003480 <bmap>
    80003be6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bea:	cd85                	beqz	a1,80003c22 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003bec:	000b2503          	lw	a0,0(s6)
    80003bf0:	fffff097          	auipc	ra,0xfffff
    80003bf4:	496080e7          	jalr	1174(ra) # 80003086 <bread>
    80003bf8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bfa:	3ff4f713          	andi	a4,s1,1023
    80003bfe:	40ec87bb          	subw	a5,s9,a4
    80003c02:	413a86bb          	subw	a3,s5,s3
    80003c06:	8d3e                	mv	s10,a5
    80003c08:	2781                	sext.w	a5,a5
    80003c0a:	0006861b          	sext.w	a2,a3
    80003c0e:	f8f679e3          	bgeu	a2,a5,80003ba0 <readi+0x4c>
    80003c12:	8d36                	mv	s10,a3
    80003c14:	b771                	j	80003ba0 <readi+0x4c>
      brelse(bp);
    80003c16:	854a                	mv	a0,s2
    80003c18:	fffff097          	auipc	ra,0xfffff
    80003c1c:	59e080e7          	jalr	1438(ra) # 800031b6 <brelse>
      tot = -1;
    80003c20:	59fd                	li	s3,-1
  }
  return tot;
    80003c22:	0009851b          	sext.w	a0,s3
}
    80003c26:	70a6                	ld	ra,104(sp)
    80003c28:	7406                	ld	s0,96(sp)
    80003c2a:	64e6                	ld	s1,88(sp)
    80003c2c:	6946                	ld	s2,80(sp)
    80003c2e:	69a6                	ld	s3,72(sp)
    80003c30:	6a06                	ld	s4,64(sp)
    80003c32:	7ae2                	ld	s5,56(sp)
    80003c34:	7b42                	ld	s6,48(sp)
    80003c36:	7ba2                	ld	s7,40(sp)
    80003c38:	7c02                	ld	s8,32(sp)
    80003c3a:	6ce2                	ld	s9,24(sp)
    80003c3c:	6d42                	ld	s10,16(sp)
    80003c3e:	6da2                	ld	s11,8(sp)
    80003c40:	6165                	addi	sp,sp,112
    80003c42:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c44:	89d6                	mv	s3,s5
    80003c46:	bff1                	j	80003c22 <readi+0xce>
    return 0;
    80003c48:	4501                	li	a0,0
}
    80003c4a:	8082                	ret

0000000080003c4c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c4c:	457c                	lw	a5,76(a0)
    80003c4e:	10d7e863          	bltu	a5,a3,80003d5e <writei+0x112>
{
    80003c52:	7159                	addi	sp,sp,-112
    80003c54:	f486                	sd	ra,104(sp)
    80003c56:	f0a2                	sd	s0,96(sp)
    80003c58:	eca6                	sd	s1,88(sp)
    80003c5a:	e8ca                	sd	s2,80(sp)
    80003c5c:	e4ce                	sd	s3,72(sp)
    80003c5e:	e0d2                	sd	s4,64(sp)
    80003c60:	fc56                	sd	s5,56(sp)
    80003c62:	f85a                	sd	s6,48(sp)
    80003c64:	f45e                	sd	s7,40(sp)
    80003c66:	f062                	sd	s8,32(sp)
    80003c68:	ec66                	sd	s9,24(sp)
    80003c6a:	e86a                	sd	s10,16(sp)
    80003c6c:	e46e                	sd	s11,8(sp)
    80003c6e:	1880                	addi	s0,sp,112
    80003c70:	8aaa                	mv	s5,a0
    80003c72:	8bae                	mv	s7,a1
    80003c74:	8a32                	mv	s4,a2
    80003c76:	8936                	mv	s2,a3
    80003c78:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c7a:	00e687bb          	addw	a5,a3,a4
    80003c7e:	0ed7e263          	bltu	a5,a3,80003d62 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c82:	00043737          	lui	a4,0x43
    80003c86:	0ef76063          	bltu	a4,a5,80003d66 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c8a:	0c0b0863          	beqz	s6,80003d5a <writei+0x10e>
    80003c8e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c90:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c94:	5c7d                	li	s8,-1
    80003c96:	a091                	j	80003cda <writei+0x8e>
    80003c98:	020d1d93          	slli	s11,s10,0x20
    80003c9c:	020ddd93          	srli	s11,s11,0x20
    80003ca0:	05848513          	addi	a0,s1,88
    80003ca4:	86ee                	mv	a3,s11
    80003ca6:	8652                	mv	a2,s4
    80003ca8:	85de                	mv	a1,s7
    80003caa:	953a                	add	a0,a0,a4
    80003cac:	fffff097          	auipc	ra,0xfffff
    80003cb0:	870080e7          	jalr	-1936(ra) # 8000251c <either_copyin>
    80003cb4:	07850263          	beq	a0,s8,80003d18 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cb8:	8526                	mv	a0,s1
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	780080e7          	jalr	1920(ra) # 8000443a <log_write>
    brelse(bp);
    80003cc2:	8526                	mv	a0,s1
    80003cc4:	fffff097          	auipc	ra,0xfffff
    80003cc8:	4f2080e7          	jalr	1266(ra) # 800031b6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ccc:	013d09bb          	addw	s3,s10,s3
    80003cd0:	012d093b          	addw	s2,s10,s2
    80003cd4:	9a6e                	add	s4,s4,s11
    80003cd6:	0569f663          	bgeu	s3,s6,80003d22 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003cda:	00a9559b          	srliw	a1,s2,0xa
    80003cde:	8556                	mv	a0,s5
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	7a0080e7          	jalr	1952(ra) # 80003480 <bmap>
    80003ce8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003cec:	c99d                	beqz	a1,80003d22 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003cee:	000aa503          	lw	a0,0(s5)
    80003cf2:	fffff097          	auipc	ra,0xfffff
    80003cf6:	394080e7          	jalr	916(ra) # 80003086 <bread>
    80003cfa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cfc:	3ff97713          	andi	a4,s2,1023
    80003d00:	40ec87bb          	subw	a5,s9,a4
    80003d04:	413b06bb          	subw	a3,s6,s3
    80003d08:	8d3e                	mv	s10,a5
    80003d0a:	2781                	sext.w	a5,a5
    80003d0c:	0006861b          	sext.w	a2,a3
    80003d10:	f8f674e3          	bgeu	a2,a5,80003c98 <writei+0x4c>
    80003d14:	8d36                	mv	s10,a3
    80003d16:	b749                	j	80003c98 <writei+0x4c>
      brelse(bp);
    80003d18:	8526                	mv	a0,s1
    80003d1a:	fffff097          	auipc	ra,0xfffff
    80003d1e:	49c080e7          	jalr	1180(ra) # 800031b6 <brelse>
  }

  if(off > ip->size)
    80003d22:	04caa783          	lw	a5,76(s5)
    80003d26:	0127f463          	bgeu	a5,s2,80003d2e <writei+0xe2>
    ip->size = off;
    80003d2a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d2e:	8556                	mv	a0,s5
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	aa6080e7          	jalr	-1370(ra) # 800037d6 <iupdate>

  return tot;
    80003d38:	0009851b          	sext.w	a0,s3
}
    80003d3c:	70a6                	ld	ra,104(sp)
    80003d3e:	7406                	ld	s0,96(sp)
    80003d40:	64e6                	ld	s1,88(sp)
    80003d42:	6946                	ld	s2,80(sp)
    80003d44:	69a6                	ld	s3,72(sp)
    80003d46:	6a06                	ld	s4,64(sp)
    80003d48:	7ae2                	ld	s5,56(sp)
    80003d4a:	7b42                	ld	s6,48(sp)
    80003d4c:	7ba2                	ld	s7,40(sp)
    80003d4e:	7c02                	ld	s8,32(sp)
    80003d50:	6ce2                	ld	s9,24(sp)
    80003d52:	6d42                	ld	s10,16(sp)
    80003d54:	6da2                	ld	s11,8(sp)
    80003d56:	6165                	addi	sp,sp,112
    80003d58:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d5a:	89da                	mv	s3,s6
    80003d5c:	bfc9                	j	80003d2e <writei+0xe2>
    return -1;
    80003d5e:	557d                	li	a0,-1
}
    80003d60:	8082                	ret
    return -1;
    80003d62:	557d                	li	a0,-1
    80003d64:	bfe1                	j	80003d3c <writei+0xf0>
    return -1;
    80003d66:	557d                	li	a0,-1
    80003d68:	bfd1                	j	80003d3c <writei+0xf0>

0000000080003d6a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d6a:	1141                	addi	sp,sp,-16
    80003d6c:	e406                	sd	ra,8(sp)
    80003d6e:	e022                	sd	s0,0(sp)
    80003d70:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d72:	4639                	li	a2,14
    80003d74:	ffffd097          	auipc	ra,0xffffd
    80003d78:	04a080e7          	jalr	74(ra) # 80000dbe <strncmp>
}
    80003d7c:	60a2                	ld	ra,8(sp)
    80003d7e:	6402                	ld	s0,0(sp)
    80003d80:	0141                	addi	sp,sp,16
    80003d82:	8082                	ret

0000000080003d84 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d84:	7139                	addi	sp,sp,-64
    80003d86:	fc06                	sd	ra,56(sp)
    80003d88:	f822                	sd	s0,48(sp)
    80003d8a:	f426                	sd	s1,40(sp)
    80003d8c:	f04a                	sd	s2,32(sp)
    80003d8e:	ec4e                	sd	s3,24(sp)
    80003d90:	e852                	sd	s4,16(sp)
    80003d92:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d94:	04451703          	lh	a4,68(a0)
    80003d98:	4785                	li	a5,1
    80003d9a:	00f71a63          	bne	a4,a5,80003dae <dirlookup+0x2a>
    80003d9e:	892a                	mv	s2,a0
    80003da0:	89ae                	mv	s3,a1
    80003da2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da4:	457c                	lw	a5,76(a0)
    80003da6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003da8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003daa:	e79d                	bnez	a5,80003dd8 <dirlookup+0x54>
    80003dac:	a8a5                	j	80003e24 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003dae:	00005517          	auipc	a0,0x5
    80003db2:	85250513          	addi	a0,a0,-1966 # 80008600 <syscalls+0x1b0>
    80003db6:	ffffc097          	auipc	ra,0xffffc
    80003dba:	78e080e7          	jalr	1934(ra) # 80000544 <panic>
      panic("dirlookup read");
    80003dbe:	00005517          	auipc	a0,0x5
    80003dc2:	85a50513          	addi	a0,a0,-1958 # 80008618 <syscalls+0x1c8>
    80003dc6:	ffffc097          	auipc	ra,0xffffc
    80003dca:	77e080e7          	jalr	1918(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dce:	24c1                	addiw	s1,s1,16
    80003dd0:	04c92783          	lw	a5,76(s2)
    80003dd4:	04f4f763          	bgeu	s1,a5,80003e22 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dd8:	4741                	li	a4,16
    80003dda:	86a6                	mv	a3,s1
    80003ddc:	fc040613          	addi	a2,s0,-64
    80003de0:	4581                	li	a1,0
    80003de2:	854a                	mv	a0,s2
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	d70080e7          	jalr	-656(ra) # 80003b54 <readi>
    80003dec:	47c1                	li	a5,16
    80003dee:	fcf518e3          	bne	a0,a5,80003dbe <dirlookup+0x3a>
    if(de.inum == 0)
    80003df2:	fc045783          	lhu	a5,-64(s0)
    80003df6:	dfe1                	beqz	a5,80003dce <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003df8:	fc240593          	addi	a1,s0,-62
    80003dfc:	854e                	mv	a0,s3
    80003dfe:	00000097          	auipc	ra,0x0
    80003e02:	f6c080e7          	jalr	-148(ra) # 80003d6a <namecmp>
    80003e06:	f561                	bnez	a0,80003dce <dirlookup+0x4a>
      if(poff)
    80003e08:	000a0463          	beqz	s4,80003e10 <dirlookup+0x8c>
        *poff = off;
    80003e0c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e10:	fc045583          	lhu	a1,-64(s0)
    80003e14:	00092503          	lw	a0,0(s2)
    80003e18:	fffff097          	auipc	ra,0xfffff
    80003e1c:	750080e7          	jalr	1872(ra) # 80003568 <iget>
    80003e20:	a011                	j	80003e24 <dirlookup+0xa0>
  return 0;
    80003e22:	4501                	li	a0,0
}
    80003e24:	70e2                	ld	ra,56(sp)
    80003e26:	7442                	ld	s0,48(sp)
    80003e28:	74a2                	ld	s1,40(sp)
    80003e2a:	7902                	ld	s2,32(sp)
    80003e2c:	69e2                	ld	s3,24(sp)
    80003e2e:	6a42                	ld	s4,16(sp)
    80003e30:	6121                	addi	sp,sp,64
    80003e32:	8082                	ret

0000000080003e34 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e34:	711d                	addi	sp,sp,-96
    80003e36:	ec86                	sd	ra,88(sp)
    80003e38:	e8a2                	sd	s0,80(sp)
    80003e3a:	e4a6                	sd	s1,72(sp)
    80003e3c:	e0ca                	sd	s2,64(sp)
    80003e3e:	fc4e                	sd	s3,56(sp)
    80003e40:	f852                	sd	s4,48(sp)
    80003e42:	f456                	sd	s5,40(sp)
    80003e44:	f05a                	sd	s6,32(sp)
    80003e46:	ec5e                	sd	s7,24(sp)
    80003e48:	e862                	sd	s8,16(sp)
    80003e4a:	e466                	sd	s9,8(sp)
    80003e4c:	1080                	addi	s0,sp,96
    80003e4e:	84aa                	mv	s1,a0
    80003e50:	8b2e                	mv	s6,a1
    80003e52:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e54:	00054703          	lbu	a4,0(a0)
    80003e58:	02f00793          	li	a5,47
    80003e5c:	02f70363          	beq	a4,a5,80003e82 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e60:	ffffe097          	auipc	ra,0xffffe
    80003e64:	b70080e7          	jalr	-1168(ra) # 800019d0 <myproc>
    80003e68:	15053503          	ld	a0,336(a0)
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	9f6080e7          	jalr	-1546(ra) # 80003862 <idup>
    80003e74:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e76:	02f00913          	li	s2,47
  len = path - s;
    80003e7a:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003e7c:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e7e:	4c05                	li	s8,1
    80003e80:	a865                	j	80003f38 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e82:	4585                	li	a1,1
    80003e84:	4505                	li	a0,1
    80003e86:	fffff097          	auipc	ra,0xfffff
    80003e8a:	6e2080e7          	jalr	1762(ra) # 80003568 <iget>
    80003e8e:	89aa                	mv	s3,a0
    80003e90:	b7dd                	j	80003e76 <namex+0x42>
      iunlockput(ip);
    80003e92:	854e                	mv	a0,s3
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	c6e080e7          	jalr	-914(ra) # 80003b02 <iunlockput>
      return 0;
    80003e9c:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e9e:	854e                	mv	a0,s3
    80003ea0:	60e6                	ld	ra,88(sp)
    80003ea2:	6446                	ld	s0,80(sp)
    80003ea4:	64a6                	ld	s1,72(sp)
    80003ea6:	6906                	ld	s2,64(sp)
    80003ea8:	79e2                	ld	s3,56(sp)
    80003eaa:	7a42                	ld	s4,48(sp)
    80003eac:	7aa2                	ld	s5,40(sp)
    80003eae:	7b02                	ld	s6,32(sp)
    80003eb0:	6be2                	ld	s7,24(sp)
    80003eb2:	6c42                	ld	s8,16(sp)
    80003eb4:	6ca2                	ld	s9,8(sp)
    80003eb6:	6125                	addi	sp,sp,96
    80003eb8:	8082                	ret
      iunlock(ip);
    80003eba:	854e                	mv	a0,s3
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	aa6080e7          	jalr	-1370(ra) # 80003962 <iunlock>
      return ip;
    80003ec4:	bfe9                	j	80003e9e <namex+0x6a>
      iunlockput(ip);
    80003ec6:	854e                	mv	a0,s3
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	c3a080e7          	jalr	-966(ra) # 80003b02 <iunlockput>
      return 0;
    80003ed0:	89d2                	mv	s3,s4
    80003ed2:	b7f1                	j	80003e9e <namex+0x6a>
  len = path - s;
    80003ed4:	40b48633          	sub	a2,s1,a1
    80003ed8:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003edc:	094cd463          	bge	s9,s4,80003f64 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003ee0:	4639                	li	a2,14
    80003ee2:	8556                	mv	a0,s5
    80003ee4:	ffffd097          	auipc	ra,0xffffd
    80003ee8:	e62080e7          	jalr	-414(ra) # 80000d46 <memmove>
  while(*path == '/')
    80003eec:	0004c783          	lbu	a5,0(s1)
    80003ef0:	01279763          	bne	a5,s2,80003efe <namex+0xca>
    path++;
    80003ef4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ef6:	0004c783          	lbu	a5,0(s1)
    80003efa:	ff278de3          	beq	a5,s2,80003ef4 <namex+0xc0>
    ilock(ip);
    80003efe:	854e                	mv	a0,s3
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	9a0080e7          	jalr	-1632(ra) # 800038a0 <ilock>
    if(ip->type != T_DIR){
    80003f08:	04499783          	lh	a5,68(s3)
    80003f0c:	f98793e3          	bne	a5,s8,80003e92 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003f10:	000b0563          	beqz	s6,80003f1a <namex+0xe6>
    80003f14:	0004c783          	lbu	a5,0(s1)
    80003f18:	d3cd                	beqz	a5,80003eba <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f1a:	865e                	mv	a2,s7
    80003f1c:	85d6                	mv	a1,s5
    80003f1e:	854e                	mv	a0,s3
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	e64080e7          	jalr	-412(ra) # 80003d84 <dirlookup>
    80003f28:	8a2a                	mv	s4,a0
    80003f2a:	dd51                	beqz	a0,80003ec6 <namex+0x92>
    iunlockput(ip);
    80003f2c:	854e                	mv	a0,s3
    80003f2e:	00000097          	auipc	ra,0x0
    80003f32:	bd4080e7          	jalr	-1068(ra) # 80003b02 <iunlockput>
    ip = next;
    80003f36:	89d2                	mv	s3,s4
  while(*path == '/')
    80003f38:	0004c783          	lbu	a5,0(s1)
    80003f3c:	05279763          	bne	a5,s2,80003f8a <namex+0x156>
    path++;
    80003f40:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f42:	0004c783          	lbu	a5,0(s1)
    80003f46:	ff278de3          	beq	a5,s2,80003f40 <namex+0x10c>
  if(*path == 0)
    80003f4a:	c79d                	beqz	a5,80003f78 <namex+0x144>
    path++;
    80003f4c:	85a6                	mv	a1,s1
  len = path - s;
    80003f4e:	8a5e                	mv	s4,s7
    80003f50:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003f52:	01278963          	beq	a5,s2,80003f64 <namex+0x130>
    80003f56:	dfbd                	beqz	a5,80003ed4 <namex+0xa0>
    path++;
    80003f58:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f5a:	0004c783          	lbu	a5,0(s1)
    80003f5e:	ff279ce3          	bne	a5,s2,80003f56 <namex+0x122>
    80003f62:	bf8d                	j	80003ed4 <namex+0xa0>
    memmove(name, s, len);
    80003f64:	2601                	sext.w	a2,a2
    80003f66:	8556                	mv	a0,s5
    80003f68:	ffffd097          	auipc	ra,0xffffd
    80003f6c:	dde080e7          	jalr	-546(ra) # 80000d46 <memmove>
    name[len] = 0;
    80003f70:	9a56                	add	s4,s4,s5
    80003f72:	000a0023          	sb	zero,0(s4)
    80003f76:	bf9d                	j	80003eec <namex+0xb8>
  if(nameiparent){
    80003f78:	f20b03e3          	beqz	s6,80003e9e <namex+0x6a>
    iput(ip);
    80003f7c:	854e                	mv	a0,s3
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	adc080e7          	jalr	-1316(ra) # 80003a5a <iput>
    return 0;
    80003f86:	4981                	li	s3,0
    80003f88:	bf19                	j	80003e9e <namex+0x6a>
  if(*path == 0)
    80003f8a:	d7fd                	beqz	a5,80003f78 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f8c:	0004c783          	lbu	a5,0(s1)
    80003f90:	85a6                	mv	a1,s1
    80003f92:	b7d1                	j	80003f56 <namex+0x122>

0000000080003f94 <dirlink>:
{
    80003f94:	7139                	addi	sp,sp,-64
    80003f96:	fc06                	sd	ra,56(sp)
    80003f98:	f822                	sd	s0,48(sp)
    80003f9a:	f426                	sd	s1,40(sp)
    80003f9c:	f04a                	sd	s2,32(sp)
    80003f9e:	ec4e                	sd	s3,24(sp)
    80003fa0:	e852                	sd	s4,16(sp)
    80003fa2:	0080                	addi	s0,sp,64
    80003fa4:	892a                	mv	s2,a0
    80003fa6:	8a2e                	mv	s4,a1
    80003fa8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003faa:	4601                	li	a2,0
    80003fac:	00000097          	auipc	ra,0x0
    80003fb0:	dd8080e7          	jalr	-552(ra) # 80003d84 <dirlookup>
    80003fb4:	e93d                	bnez	a0,8000402a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fb6:	04c92483          	lw	s1,76(s2)
    80003fba:	c49d                	beqz	s1,80003fe8 <dirlink+0x54>
    80003fbc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fbe:	4741                	li	a4,16
    80003fc0:	86a6                	mv	a3,s1
    80003fc2:	fc040613          	addi	a2,s0,-64
    80003fc6:	4581                	li	a1,0
    80003fc8:	854a                	mv	a0,s2
    80003fca:	00000097          	auipc	ra,0x0
    80003fce:	b8a080e7          	jalr	-1142(ra) # 80003b54 <readi>
    80003fd2:	47c1                	li	a5,16
    80003fd4:	06f51163          	bne	a0,a5,80004036 <dirlink+0xa2>
    if(de.inum == 0)
    80003fd8:	fc045783          	lhu	a5,-64(s0)
    80003fdc:	c791                	beqz	a5,80003fe8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fde:	24c1                	addiw	s1,s1,16
    80003fe0:	04c92783          	lw	a5,76(s2)
    80003fe4:	fcf4ede3          	bltu	s1,a5,80003fbe <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fe8:	4639                	li	a2,14
    80003fea:	85d2                	mv	a1,s4
    80003fec:	fc240513          	addi	a0,s0,-62
    80003ff0:	ffffd097          	auipc	ra,0xffffd
    80003ff4:	e0a080e7          	jalr	-502(ra) # 80000dfa <strncpy>
  de.inum = inum;
    80003ff8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ffc:	4741                	li	a4,16
    80003ffe:	86a6                	mv	a3,s1
    80004000:	fc040613          	addi	a2,s0,-64
    80004004:	4581                	li	a1,0
    80004006:	854a                	mv	a0,s2
    80004008:	00000097          	auipc	ra,0x0
    8000400c:	c44080e7          	jalr	-956(ra) # 80003c4c <writei>
    80004010:	1541                	addi	a0,a0,-16
    80004012:	00a03533          	snez	a0,a0
    80004016:	40a00533          	neg	a0,a0
}
    8000401a:	70e2                	ld	ra,56(sp)
    8000401c:	7442                	ld	s0,48(sp)
    8000401e:	74a2                	ld	s1,40(sp)
    80004020:	7902                	ld	s2,32(sp)
    80004022:	69e2                	ld	s3,24(sp)
    80004024:	6a42                	ld	s4,16(sp)
    80004026:	6121                	addi	sp,sp,64
    80004028:	8082                	ret
    iput(ip);
    8000402a:	00000097          	auipc	ra,0x0
    8000402e:	a30080e7          	jalr	-1488(ra) # 80003a5a <iput>
    return -1;
    80004032:	557d                	li	a0,-1
    80004034:	b7dd                	j	8000401a <dirlink+0x86>
      panic("dirlink read");
    80004036:	00004517          	auipc	a0,0x4
    8000403a:	5f250513          	addi	a0,a0,1522 # 80008628 <syscalls+0x1d8>
    8000403e:	ffffc097          	auipc	ra,0xffffc
    80004042:	506080e7          	jalr	1286(ra) # 80000544 <panic>

0000000080004046 <namei>:

struct inode*
namei(char *path)
{
    80004046:	1101                	addi	sp,sp,-32
    80004048:	ec06                	sd	ra,24(sp)
    8000404a:	e822                	sd	s0,16(sp)
    8000404c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000404e:	fe040613          	addi	a2,s0,-32
    80004052:	4581                	li	a1,0
    80004054:	00000097          	auipc	ra,0x0
    80004058:	de0080e7          	jalr	-544(ra) # 80003e34 <namex>
}
    8000405c:	60e2                	ld	ra,24(sp)
    8000405e:	6442                	ld	s0,16(sp)
    80004060:	6105                	addi	sp,sp,32
    80004062:	8082                	ret

0000000080004064 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004064:	1141                	addi	sp,sp,-16
    80004066:	e406                	sd	ra,8(sp)
    80004068:	e022                	sd	s0,0(sp)
    8000406a:	0800                	addi	s0,sp,16
    8000406c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000406e:	4585                	li	a1,1
    80004070:	00000097          	auipc	ra,0x0
    80004074:	dc4080e7          	jalr	-572(ra) # 80003e34 <namex>
}
    80004078:	60a2                	ld	ra,8(sp)
    8000407a:	6402                	ld	s0,0(sp)
    8000407c:	0141                	addi	sp,sp,16
    8000407e:	8082                	ret

0000000080004080 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004080:	1101                	addi	sp,sp,-32
    80004082:	ec06                	sd	ra,24(sp)
    80004084:	e822                	sd	s0,16(sp)
    80004086:	e426                	sd	s1,8(sp)
    80004088:	e04a                	sd	s2,0(sp)
    8000408a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000408c:	0001d917          	auipc	s2,0x1d
    80004090:	aa490913          	addi	s2,s2,-1372 # 80020b30 <log>
    80004094:	01892583          	lw	a1,24(s2)
    80004098:	02892503          	lw	a0,40(s2)
    8000409c:	fffff097          	auipc	ra,0xfffff
    800040a0:	fea080e7          	jalr	-22(ra) # 80003086 <bread>
    800040a4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040a6:	02c92683          	lw	a3,44(s2)
    800040aa:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040ac:	02d05763          	blez	a3,800040da <write_head+0x5a>
    800040b0:	0001d797          	auipc	a5,0x1d
    800040b4:	ab078793          	addi	a5,a5,-1360 # 80020b60 <log+0x30>
    800040b8:	05c50713          	addi	a4,a0,92
    800040bc:	36fd                	addiw	a3,a3,-1
    800040be:	1682                	slli	a3,a3,0x20
    800040c0:	9281                	srli	a3,a3,0x20
    800040c2:	068a                	slli	a3,a3,0x2
    800040c4:	0001d617          	auipc	a2,0x1d
    800040c8:	aa060613          	addi	a2,a2,-1376 # 80020b64 <log+0x34>
    800040cc:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800040ce:	4390                	lw	a2,0(a5)
    800040d0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040d2:	0791                	addi	a5,a5,4
    800040d4:	0711                	addi	a4,a4,4
    800040d6:	fed79ce3          	bne	a5,a3,800040ce <write_head+0x4e>
  }
  bwrite(buf);
    800040da:	8526                	mv	a0,s1
    800040dc:	fffff097          	auipc	ra,0xfffff
    800040e0:	09c080e7          	jalr	156(ra) # 80003178 <bwrite>
  brelse(buf);
    800040e4:	8526                	mv	a0,s1
    800040e6:	fffff097          	auipc	ra,0xfffff
    800040ea:	0d0080e7          	jalr	208(ra) # 800031b6 <brelse>
}
    800040ee:	60e2                	ld	ra,24(sp)
    800040f0:	6442                	ld	s0,16(sp)
    800040f2:	64a2                	ld	s1,8(sp)
    800040f4:	6902                	ld	s2,0(sp)
    800040f6:	6105                	addi	sp,sp,32
    800040f8:	8082                	ret

00000000800040fa <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040fa:	0001d797          	auipc	a5,0x1d
    800040fe:	a627a783          	lw	a5,-1438(a5) # 80020b5c <log+0x2c>
    80004102:	0af05d63          	blez	a5,800041bc <install_trans+0xc2>
{
    80004106:	7139                	addi	sp,sp,-64
    80004108:	fc06                	sd	ra,56(sp)
    8000410a:	f822                	sd	s0,48(sp)
    8000410c:	f426                	sd	s1,40(sp)
    8000410e:	f04a                	sd	s2,32(sp)
    80004110:	ec4e                	sd	s3,24(sp)
    80004112:	e852                	sd	s4,16(sp)
    80004114:	e456                	sd	s5,8(sp)
    80004116:	e05a                	sd	s6,0(sp)
    80004118:	0080                	addi	s0,sp,64
    8000411a:	8b2a                	mv	s6,a0
    8000411c:	0001da97          	auipc	s5,0x1d
    80004120:	a44a8a93          	addi	s5,s5,-1468 # 80020b60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004124:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004126:	0001d997          	auipc	s3,0x1d
    8000412a:	a0a98993          	addi	s3,s3,-1526 # 80020b30 <log>
    8000412e:	a035                	j	8000415a <install_trans+0x60>
      bunpin(dbuf);
    80004130:	8526                	mv	a0,s1
    80004132:	fffff097          	auipc	ra,0xfffff
    80004136:	15e080e7          	jalr	350(ra) # 80003290 <bunpin>
    brelse(lbuf);
    8000413a:	854a                	mv	a0,s2
    8000413c:	fffff097          	auipc	ra,0xfffff
    80004140:	07a080e7          	jalr	122(ra) # 800031b6 <brelse>
    brelse(dbuf);
    80004144:	8526                	mv	a0,s1
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	070080e7          	jalr	112(ra) # 800031b6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000414e:	2a05                	addiw	s4,s4,1
    80004150:	0a91                	addi	s5,s5,4
    80004152:	02c9a783          	lw	a5,44(s3)
    80004156:	04fa5963          	bge	s4,a5,800041a8 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000415a:	0189a583          	lw	a1,24(s3)
    8000415e:	014585bb          	addw	a1,a1,s4
    80004162:	2585                	addiw	a1,a1,1
    80004164:	0289a503          	lw	a0,40(s3)
    80004168:	fffff097          	auipc	ra,0xfffff
    8000416c:	f1e080e7          	jalr	-226(ra) # 80003086 <bread>
    80004170:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004172:	000aa583          	lw	a1,0(s5)
    80004176:	0289a503          	lw	a0,40(s3)
    8000417a:	fffff097          	auipc	ra,0xfffff
    8000417e:	f0c080e7          	jalr	-244(ra) # 80003086 <bread>
    80004182:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004184:	40000613          	li	a2,1024
    80004188:	05890593          	addi	a1,s2,88
    8000418c:	05850513          	addi	a0,a0,88
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	bb6080e7          	jalr	-1098(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004198:	8526                	mv	a0,s1
    8000419a:	fffff097          	auipc	ra,0xfffff
    8000419e:	fde080e7          	jalr	-34(ra) # 80003178 <bwrite>
    if(recovering == 0)
    800041a2:	f80b1ce3          	bnez	s6,8000413a <install_trans+0x40>
    800041a6:	b769                	j	80004130 <install_trans+0x36>
}
    800041a8:	70e2                	ld	ra,56(sp)
    800041aa:	7442                	ld	s0,48(sp)
    800041ac:	74a2                	ld	s1,40(sp)
    800041ae:	7902                	ld	s2,32(sp)
    800041b0:	69e2                	ld	s3,24(sp)
    800041b2:	6a42                	ld	s4,16(sp)
    800041b4:	6aa2                	ld	s5,8(sp)
    800041b6:	6b02                	ld	s6,0(sp)
    800041b8:	6121                	addi	sp,sp,64
    800041ba:	8082                	ret
    800041bc:	8082                	ret

00000000800041be <initlog>:
{
    800041be:	7179                	addi	sp,sp,-48
    800041c0:	f406                	sd	ra,40(sp)
    800041c2:	f022                	sd	s0,32(sp)
    800041c4:	ec26                	sd	s1,24(sp)
    800041c6:	e84a                	sd	s2,16(sp)
    800041c8:	e44e                	sd	s3,8(sp)
    800041ca:	1800                	addi	s0,sp,48
    800041cc:	892a                	mv	s2,a0
    800041ce:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041d0:	0001d497          	auipc	s1,0x1d
    800041d4:	96048493          	addi	s1,s1,-1696 # 80020b30 <log>
    800041d8:	00004597          	auipc	a1,0x4
    800041dc:	46058593          	addi	a1,a1,1120 # 80008638 <syscalls+0x1e8>
    800041e0:	8526                	mv	a0,s1
    800041e2:	ffffd097          	auipc	ra,0xffffd
    800041e6:	978080e7          	jalr	-1672(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800041ea:	0149a583          	lw	a1,20(s3)
    800041ee:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041f0:	0109a783          	lw	a5,16(s3)
    800041f4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041f6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041fa:	854a                	mv	a0,s2
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	e8a080e7          	jalr	-374(ra) # 80003086 <bread>
  log.lh.n = lh->n;
    80004204:	4d3c                	lw	a5,88(a0)
    80004206:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004208:	02f05563          	blez	a5,80004232 <initlog+0x74>
    8000420c:	05c50713          	addi	a4,a0,92
    80004210:	0001d697          	auipc	a3,0x1d
    80004214:	95068693          	addi	a3,a3,-1712 # 80020b60 <log+0x30>
    80004218:	37fd                	addiw	a5,a5,-1
    8000421a:	1782                	slli	a5,a5,0x20
    8000421c:	9381                	srli	a5,a5,0x20
    8000421e:	078a                	slli	a5,a5,0x2
    80004220:	06050613          	addi	a2,a0,96
    80004224:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004226:	4310                	lw	a2,0(a4)
    80004228:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000422a:	0711                	addi	a4,a4,4
    8000422c:	0691                	addi	a3,a3,4
    8000422e:	fef71ce3          	bne	a4,a5,80004226 <initlog+0x68>
  brelse(buf);
    80004232:	fffff097          	auipc	ra,0xfffff
    80004236:	f84080e7          	jalr	-124(ra) # 800031b6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000423a:	4505                	li	a0,1
    8000423c:	00000097          	auipc	ra,0x0
    80004240:	ebe080e7          	jalr	-322(ra) # 800040fa <install_trans>
  log.lh.n = 0;
    80004244:	0001d797          	auipc	a5,0x1d
    80004248:	9007ac23          	sw	zero,-1768(a5) # 80020b5c <log+0x2c>
  write_head(); // clear the log
    8000424c:	00000097          	auipc	ra,0x0
    80004250:	e34080e7          	jalr	-460(ra) # 80004080 <write_head>
}
    80004254:	70a2                	ld	ra,40(sp)
    80004256:	7402                	ld	s0,32(sp)
    80004258:	64e2                	ld	s1,24(sp)
    8000425a:	6942                	ld	s2,16(sp)
    8000425c:	69a2                	ld	s3,8(sp)
    8000425e:	6145                	addi	sp,sp,48
    80004260:	8082                	ret

0000000080004262 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004262:	1101                	addi	sp,sp,-32
    80004264:	ec06                	sd	ra,24(sp)
    80004266:	e822                	sd	s0,16(sp)
    80004268:	e426                	sd	s1,8(sp)
    8000426a:	e04a                	sd	s2,0(sp)
    8000426c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000426e:	0001d517          	auipc	a0,0x1d
    80004272:	8c250513          	addi	a0,a0,-1854 # 80020b30 <log>
    80004276:	ffffd097          	auipc	ra,0xffffd
    8000427a:	974080e7          	jalr	-1676(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    8000427e:	0001d497          	auipc	s1,0x1d
    80004282:	8b248493          	addi	s1,s1,-1870 # 80020b30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004286:	4979                	li	s2,30
    80004288:	a039                	j	80004296 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000428a:	85a6                	mv	a1,s1
    8000428c:	8526                	mv	a0,s1
    8000428e:	ffffe097          	auipc	ra,0xffffe
    80004292:	e30080e7          	jalr	-464(ra) # 800020be <sleep>
    if(log.committing){
    80004296:	50dc                	lw	a5,36(s1)
    80004298:	fbed                	bnez	a5,8000428a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000429a:	509c                	lw	a5,32(s1)
    8000429c:	0017871b          	addiw	a4,a5,1
    800042a0:	0007069b          	sext.w	a3,a4
    800042a4:	0027179b          	slliw	a5,a4,0x2
    800042a8:	9fb9                	addw	a5,a5,a4
    800042aa:	0017979b          	slliw	a5,a5,0x1
    800042ae:	54d8                	lw	a4,44(s1)
    800042b0:	9fb9                	addw	a5,a5,a4
    800042b2:	00f95963          	bge	s2,a5,800042c4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042b6:	85a6                	mv	a1,s1
    800042b8:	8526                	mv	a0,s1
    800042ba:	ffffe097          	auipc	ra,0xffffe
    800042be:	e04080e7          	jalr	-508(ra) # 800020be <sleep>
    800042c2:	bfd1                	j	80004296 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042c4:	0001d517          	auipc	a0,0x1d
    800042c8:	86c50513          	addi	a0,a0,-1940 # 80020b30 <log>
    800042cc:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800042ce:	ffffd097          	auipc	ra,0xffffd
    800042d2:	9d0080e7          	jalr	-1584(ra) # 80000c9e <release>
      break;
    }
  }
}
    800042d6:	60e2                	ld	ra,24(sp)
    800042d8:	6442                	ld	s0,16(sp)
    800042da:	64a2                	ld	s1,8(sp)
    800042dc:	6902                	ld	s2,0(sp)
    800042de:	6105                	addi	sp,sp,32
    800042e0:	8082                	ret

00000000800042e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042e2:	7139                	addi	sp,sp,-64
    800042e4:	fc06                	sd	ra,56(sp)
    800042e6:	f822                	sd	s0,48(sp)
    800042e8:	f426                	sd	s1,40(sp)
    800042ea:	f04a                	sd	s2,32(sp)
    800042ec:	ec4e                	sd	s3,24(sp)
    800042ee:	e852                	sd	s4,16(sp)
    800042f0:	e456                	sd	s5,8(sp)
    800042f2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042f4:	0001d497          	auipc	s1,0x1d
    800042f8:	83c48493          	addi	s1,s1,-1988 # 80020b30 <log>
    800042fc:	8526                	mv	a0,s1
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	8ec080e7          	jalr	-1812(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004306:	509c                	lw	a5,32(s1)
    80004308:	37fd                	addiw	a5,a5,-1
    8000430a:	0007891b          	sext.w	s2,a5
    8000430e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004310:	50dc                	lw	a5,36(s1)
    80004312:	efb9                	bnez	a5,80004370 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004314:	06091663          	bnez	s2,80004380 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004318:	0001d497          	auipc	s1,0x1d
    8000431c:	81848493          	addi	s1,s1,-2024 # 80020b30 <log>
    80004320:	4785                	li	a5,1
    80004322:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004324:	8526                	mv	a0,s1
    80004326:	ffffd097          	auipc	ra,0xffffd
    8000432a:	978080e7          	jalr	-1672(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000432e:	54dc                	lw	a5,44(s1)
    80004330:	06f04763          	bgtz	a5,8000439e <end_op+0xbc>
    acquire(&log.lock);
    80004334:	0001c497          	auipc	s1,0x1c
    80004338:	7fc48493          	addi	s1,s1,2044 # 80020b30 <log>
    8000433c:	8526                	mv	a0,s1
    8000433e:	ffffd097          	auipc	ra,0xffffd
    80004342:	8ac080e7          	jalr	-1876(ra) # 80000bea <acquire>
    log.committing = 0;
    80004346:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000434a:	8526                	mv	a0,s1
    8000434c:	ffffe097          	auipc	ra,0xffffe
    80004350:	dd6080e7          	jalr	-554(ra) # 80002122 <wakeup>
    release(&log.lock);
    80004354:	8526                	mv	a0,s1
    80004356:	ffffd097          	auipc	ra,0xffffd
    8000435a:	948080e7          	jalr	-1720(ra) # 80000c9e <release>
}
    8000435e:	70e2                	ld	ra,56(sp)
    80004360:	7442                	ld	s0,48(sp)
    80004362:	74a2                	ld	s1,40(sp)
    80004364:	7902                	ld	s2,32(sp)
    80004366:	69e2                	ld	s3,24(sp)
    80004368:	6a42                	ld	s4,16(sp)
    8000436a:	6aa2                	ld	s5,8(sp)
    8000436c:	6121                	addi	sp,sp,64
    8000436e:	8082                	ret
    panic("log.committing");
    80004370:	00004517          	auipc	a0,0x4
    80004374:	2d050513          	addi	a0,a0,720 # 80008640 <syscalls+0x1f0>
    80004378:	ffffc097          	auipc	ra,0xffffc
    8000437c:	1cc080e7          	jalr	460(ra) # 80000544 <panic>
    wakeup(&log);
    80004380:	0001c497          	auipc	s1,0x1c
    80004384:	7b048493          	addi	s1,s1,1968 # 80020b30 <log>
    80004388:	8526                	mv	a0,s1
    8000438a:	ffffe097          	auipc	ra,0xffffe
    8000438e:	d98080e7          	jalr	-616(ra) # 80002122 <wakeup>
  release(&log.lock);
    80004392:	8526                	mv	a0,s1
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	90a080e7          	jalr	-1782(ra) # 80000c9e <release>
  if(do_commit){
    8000439c:	b7c9                	j	8000435e <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000439e:	0001ca97          	auipc	s5,0x1c
    800043a2:	7c2a8a93          	addi	s5,s5,1986 # 80020b60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043a6:	0001ca17          	auipc	s4,0x1c
    800043aa:	78aa0a13          	addi	s4,s4,1930 # 80020b30 <log>
    800043ae:	018a2583          	lw	a1,24(s4)
    800043b2:	012585bb          	addw	a1,a1,s2
    800043b6:	2585                	addiw	a1,a1,1
    800043b8:	028a2503          	lw	a0,40(s4)
    800043bc:	fffff097          	auipc	ra,0xfffff
    800043c0:	cca080e7          	jalr	-822(ra) # 80003086 <bread>
    800043c4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043c6:	000aa583          	lw	a1,0(s5)
    800043ca:	028a2503          	lw	a0,40(s4)
    800043ce:	fffff097          	auipc	ra,0xfffff
    800043d2:	cb8080e7          	jalr	-840(ra) # 80003086 <bread>
    800043d6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043d8:	40000613          	li	a2,1024
    800043dc:	05850593          	addi	a1,a0,88
    800043e0:	05848513          	addi	a0,s1,88
    800043e4:	ffffd097          	auipc	ra,0xffffd
    800043e8:	962080e7          	jalr	-1694(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    800043ec:	8526                	mv	a0,s1
    800043ee:	fffff097          	auipc	ra,0xfffff
    800043f2:	d8a080e7          	jalr	-630(ra) # 80003178 <bwrite>
    brelse(from);
    800043f6:	854e                	mv	a0,s3
    800043f8:	fffff097          	auipc	ra,0xfffff
    800043fc:	dbe080e7          	jalr	-578(ra) # 800031b6 <brelse>
    brelse(to);
    80004400:	8526                	mv	a0,s1
    80004402:	fffff097          	auipc	ra,0xfffff
    80004406:	db4080e7          	jalr	-588(ra) # 800031b6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000440a:	2905                	addiw	s2,s2,1
    8000440c:	0a91                	addi	s5,s5,4
    8000440e:	02ca2783          	lw	a5,44(s4)
    80004412:	f8f94ee3          	blt	s2,a5,800043ae <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004416:	00000097          	auipc	ra,0x0
    8000441a:	c6a080e7          	jalr	-918(ra) # 80004080 <write_head>
    install_trans(0); // Now install writes to home locations
    8000441e:	4501                	li	a0,0
    80004420:	00000097          	auipc	ra,0x0
    80004424:	cda080e7          	jalr	-806(ra) # 800040fa <install_trans>
    log.lh.n = 0;
    80004428:	0001c797          	auipc	a5,0x1c
    8000442c:	7207aa23          	sw	zero,1844(a5) # 80020b5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004430:	00000097          	auipc	ra,0x0
    80004434:	c50080e7          	jalr	-944(ra) # 80004080 <write_head>
    80004438:	bdf5                	j	80004334 <end_op+0x52>

000000008000443a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000443a:	1101                	addi	sp,sp,-32
    8000443c:	ec06                	sd	ra,24(sp)
    8000443e:	e822                	sd	s0,16(sp)
    80004440:	e426                	sd	s1,8(sp)
    80004442:	e04a                	sd	s2,0(sp)
    80004444:	1000                	addi	s0,sp,32
    80004446:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004448:	0001c917          	auipc	s2,0x1c
    8000444c:	6e890913          	addi	s2,s2,1768 # 80020b30 <log>
    80004450:	854a                	mv	a0,s2
    80004452:	ffffc097          	auipc	ra,0xffffc
    80004456:	798080e7          	jalr	1944(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000445a:	02c92603          	lw	a2,44(s2)
    8000445e:	47f5                	li	a5,29
    80004460:	06c7c563          	blt	a5,a2,800044ca <log_write+0x90>
    80004464:	0001c797          	auipc	a5,0x1c
    80004468:	6e87a783          	lw	a5,1768(a5) # 80020b4c <log+0x1c>
    8000446c:	37fd                	addiw	a5,a5,-1
    8000446e:	04f65e63          	bge	a2,a5,800044ca <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004472:	0001c797          	auipc	a5,0x1c
    80004476:	6de7a783          	lw	a5,1758(a5) # 80020b50 <log+0x20>
    8000447a:	06f05063          	blez	a5,800044da <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000447e:	4781                	li	a5,0
    80004480:	06c05563          	blez	a2,800044ea <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004484:	44cc                	lw	a1,12(s1)
    80004486:	0001c717          	auipc	a4,0x1c
    8000448a:	6da70713          	addi	a4,a4,1754 # 80020b60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000448e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004490:	4314                	lw	a3,0(a4)
    80004492:	04b68c63          	beq	a3,a1,800044ea <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004496:	2785                	addiw	a5,a5,1
    80004498:	0711                	addi	a4,a4,4
    8000449a:	fef61be3          	bne	a2,a5,80004490 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000449e:	0621                	addi	a2,a2,8
    800044a0:	060a                	slli	a2,a2,0x2
    800044a2:	0001c797          	auipc	a5,0x1c
    800044a6:	68e78793          	addi	a5,a5,1678 # 80020b30 <log>
    800044aa:	963e                	add	a2,a2,a5
    800044ac:	44dc                	lw	a5,12(s1)
    800044ae:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044b0:	8526                	mv	a0,s1
    800044b2:	fffff097          	auipc	ra,0xfffff
    800044b6:	da2080e7          	jalr	-606(ra) # 80003254 <bpin>
    log.lh.n++;
    800044ba:	0001c717          	auipc	a4,0x1c
    800044be:	67670713          	addi	a4,a4,1654 # 80020b30 <log>
    800044c2:	575c                	lw	a5,44(a4)
    800044c4:	2785                	addiw	a5,a5,1
    800044c6:	d75c                	sw	a5,44(a4)
    800044c8:	a835                	j	80004504 <log_write+0xca>
    panic("too big a transaction");
    800044ca:	00004517          	auipc	a0,0x4
    800044ce:	18650513          	addi	a0,a0,390 # 80008650 <syscalls+0x200>
    800044d2:	ffffc097          	auipc	ra,0xffffc
    800044d6:	072080e7          	jalr	114(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    800044da:	00004517          	auipc	a0,0x4
    800044de:	18e50513          	addi	a0,a0,398 # 80008668 <syscalls+0x218>
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	062080e7          	jalr	98(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    800044ea:	00878713          	addi	a4,a5,8
    800044ee:	00271693          	slli	a3,a4,0x2
    800044f2:	0001c717          	auipc	a4,0x1c
    800044f6:	63e70713          	addi	a4,a4,1598 # 80020b30 <log>
    800044fa:	9736                	add	a4,a4,a3
    800044fc:	44d4                	lw	a3,12(s1)
    800044fe:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004500:	faf608e3          	beq	a2,a5,800044b0 <log_write+0x76>
  }
  release(&log.lock);
    80004504:	0001c517          	auipc	a0,0x1c
    80004508:	62c50513          	addi	a0,a0,1580 # 80020b30 <log>
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	792080e7          	jalr	1938(ra) # 80000c9e <release>
}
    80004514:	60e2                	ld	ra,24(sp)
    80004516:	6442                	ld	s0,16(sp)
    80004518:	64a2                	ld	s1,8(sp)
    8000451a:	6902                	ld	s2,0(sp)
    8000451c:	6105                	addi	sp,sp,32
    8000451e:	8082                	ret

0000000080004520 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004520:	1101                	addi	sp,sp,-32
    80004522:	ec06                	sd	ra,24(sp)
    80004524:	e822                	sd	s0,16(sp)
    80004526:	e426                	sd	s1,8(sp)
    80004528:	e04a                	sd	s2,0(sp)
    8000452a:	1000                	addi	s0,sp,32
    8000452c:	84aa                	mv	s1,a0
    8000452e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004530:	00004597          	auipc	a1,0x4
    80004534:	15858593          	addi	a1,a1,344 # 80008688 <syscalls+0x238>
    80004538:	0521                	addi	a0,a0,8
    8000453a:	ffffc097          	auipc	ra,0xffffc
    8000453e:	620080e7          	jalr	1568(ra) # 80000b5a <initlock>
  lk->name = name;
    80004542:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004546:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000454a:	0204a423          	sw	zero,40(s1)
}
    8000454e:	60e2                	ld	ra,24(sp)
    80004550:	6442                	ld	s0,16(sp)
    80004552:	64a2                	ld	s1,8(sp)
    80004554:	6902                	ld	s2,0(sp)
    80004556:	6105                	addi	sp,sp,32
    80004558:	8082                	ret

000000008000455a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000455a:	1101                	addi	sp,sp,-32
    8000455c:	ec06                	sd	ra,24(sp)
    8000455e:	e822                	sd	s0,16(sp)
    80004560:	e426                	sd	s1,8(sp)
    80004562:	e04a                	sd	s2,0(sp)
    80004564:	1000                	addi	s0,sp,32
    80004566:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004568:	00850913          	addi	s2,a0,8
    8000456c:	854a                	mv	a0,s2
    8000456e:	ffffc097          	auipc	ra,0xffffc
    80004572:	67c080e7          	jalr	1660(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004576:	409c                	lw	a5,0(s1)
    80004578:	cb89                	beqz	a5,8000458a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000457a:	85ca                	mv	a1,s2
    8000457c:	8526                	mv	a0,s1
    8000457e:	ffffe097          	auipc	ra,0xffffe
    80004582:	b40080e7          	jalr	-1216(ra) # 800020be <sleep>
  while (lk->locked) {
    80004586:	409c                	lw	a5,0(s1)
    80004588:	fbed                	bnez	a5,8000457a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000458a:	4785                	li	a5,1
    8000458c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000458e:	ffffd097          	auipc	ra,0xffffd
    80004592:	442080e7          	jalr	1090(ra) # 800019d0 <myproc>
    80004596:	591c                	lw	a5,48(a0)
    80004598:	d49c                	sw	a5,40(s1)
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

00000000800045b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045b0:	1101                	addi	sp,sp,-32
    800045b2:	ec06                	sd	ra,24(sp)
    800045b4:	e822                	sd	s0,16(sp)
    800045b6:	e426                	sd	s1,8(sp)
    800045b8:	e04a                	sd	s2,0(sp)
    800045ba:	1000                	addi	s0,sp,32
    800045bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045be:	00850913          	addi	s2,a0,8
    800045c2:	854a                	mv	a0,s2
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	626080e7          	jalr	1574(ra) # 80000bea <acquire>
  lk->locked = 0;
    800045cc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045d0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045d4:	8526                	mv	a0,s1
    800045d6:	ffffe097          	auipc	ra,0xffffe
    800045da:	b4c080e7          	jalr	-1204(ra) # 80002122 <wakeup>
  release(&lk->lk);
    800045de:	854a                	mv	a0,s2
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	6be080e7          	jalr	1726(ra) # 80000c9e <release>
}
    800045e8:	60e2                	ld	ra,24(sp)
    800045ea:	6442                	ld	s0,16(sp)
    800045ec:	64a2                	ld	s1,8(sp)
    800045ee:	6902                	ld	s2,0(sp)
    800045f0:	6105                	addi	sp,sp,32
    800045f2:	8082                	ret

00000000800045f4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045f4:	7179                	addi	sp,sp,-48
    800045f6:	f406                	sd	ra,40(sp)
    800045f8:	f022                	sd	s0,32(sp)
    800045fa:	ec26                	sd	s1,24(sp)
    800045fc:	e84a                	sd	s2,16(sp)
    800045fe:	e44e                	sd	s3,8(sp)
    80004600:	1800                	addi	s0,sp,48
    80004602:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004604:	00850913          	addi	s2,a0,8
    80004608:	854a                	mv	a0,s2
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	5e0080e7          	jalr	1504(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004612:	409c                	lw	a5,0(s1)
    80004614:	ef99                	bnez	a5,80004632 <holdingsleep+0x3e>
    80004616:	4481                	li	s1,0
  release(&lk->lk);
    80004618:	854a                	mv	a0,s2
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	684080e7          	jalr	1668(ra) # 80000c9e <release>
  return r;
}
    80004622:	8526                	mv	a0,s1
    80004624:	70a2                	ld	ra,40(sp)
    80004626:	7402                	ld	s0,32(sp)
    80004628:	64e2                	ld	s1,24(sp)
    8000462a:	6942                	ld	s2,16(sp)
    8000462c:	69a2                	ld	s3,8(sp)
    8000462e:	6145                	addi	sp,sp,48
    80004630:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004632:	0284a983          	lw	s3,40(s1)
    80004636:	ffffd097          	auipc	ra,0xffffd
    8000463a:	39a080e7          	jalr	922(ra) # 800019d0 <myproc>
    8000463e:	5904                	lw	s1,48(a0)
    80004640:	413484b3          	sub	s1,s1,s3
    80004644:	0014b493          	seqz	s1,s1
    80004648:	bfc1                	j	80004618 <holdingsleep+0x24>

000000008000464a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000464a:	1141                	addi	sp,sp,-16
    8000464c:	e406                	sd	ra,8(sp)
    8000464e:	e022                	sd	s0,0(sp)
    80004650:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004652:	00004597          	auipc	a1,0x4
    80004656:	04658593          	addi	a1,a1,70 # 80008698 <syscalls+0x248>
    8000465a:	0001c517          	auipc	a0,0x1c
    8000465e:	61e50513          	addi	a0,a0,1566 # 80020c78 <ftable>
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	4f8080e7          	jalr	1272(ra) # 80000b5a <initlock>
}
    8000466a:	60a2                	ld	ra,8(sp)
    8000466c:	6402                	ld	s0,0(sp)
    8000466e:	0141                	addi	sp,sp,16
    80004670:	8082                	ret

0000000080004672 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004672:	1101                	addi	sp,sp,-32
    80004674:	ec06                	sd	ra,24(sp)
    80004676:	e822                	sd	s0,16(sp)
    80004678:	e426                	sd	s1,8(sp)
    8000467a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000467c:	0001c517          	auipc	a0,0x1c
    80004680:	5fc50513          	addi	a0,a0,1532 # 80020c78 <ftable>
    80004684:	ffffc097          	auipc	ra,0xffffc
    80004688:	566080e7          	jalr	1382(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000468c:	0001c497          	auipc	s1,0x1c
    80004690:	60448493          	addi	s1,s1,1540 # 80020c90 <ftable+0x18>
    80004694:	0001d717          	auipc	a4,0x1d
    80004698:	59c70713          	addi	a4,a4,1436 # 80021c30 <disk>
    if(f->ref == 0){
    8000469c:	40dc                	lw	a5,4(s1)
    8000469e:	cf99                	beqz	a5,800046bc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046a0:	02848493          	addi	s1,s1,40
    800046a4:	fee49ce3          	bne	s1,a4,8000469c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046a8:	0001c517          	auipc	a0,0x1c
    800046ac:	5d050513          	addi	a0,a0,1488 # 80020c78 <ftable>
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	5ee080e7          	jalr	1518(ra) # 80000c9e <release>
  return 0;
    800046b8:	4481                	li	s1,0
    800046ba:	a819                	j	800046d0 <filealloc+0x5e>
      f->ref = 1;
    800046bc:	4785                	li	a5,1
    800046be:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046c0:	0001c517          	auipc	a0,0x1c
    800046c4:	5b850513          	addi	a0,a0,1464 # 80020c78 <ftable>
    800046c8:	ffffc097          	auipc	ra,0xffffc
    800046cc:	5d6080e7          	jalr	1494(ra) # 80000c9e <release>
}
    800046d0:	8526                	mv	a0,s1
    800046d2:	60e2                	ld	ra,24(sp)
    800046d4:	6442                	ld	s0,16(sp)
    800046d6:	64a2                	ld	s1,8(sp)
    800046d8:	6105                	addi	sp,sp,32
    800046da:	8082                	ret

00000000800046dc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046dc:	1101                	addi	sp,sp,-32
    800046de:	ec06                	sd	ra,24(sp)
    800046e0:	e822                	sd	s0,16(sp)
    800046e2:	e426                	sd	s1,8(sp)
    800046e4:	1000                	addi	s0,sp,32
    800046e6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046e8:	0001c517          	auipc	a0,0x1c
    800046ec:	59050513          	addi	a0,a0,1424 # 80020c78 <ftable>
    800046f0:	ffffc097          	auipc	ra,0xffffc
    800046f4:	4fa080e7          	jalr	1274(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800046f8:	40dc                	lw	a5,4(s1)
    800046fa:	02f05263          	blez	a5,8000471e <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046fe:	2785                	addiw	a5,a5,1
    80004700:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004702:	0001c517          	auipc	a0,0x1c
    80004706:	57650513          	addi	a0,a0,1398 # 80020c78 <ftable>
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	594080e7          	jalr	1428(ra) # 80000c9e <release>
  return f;
}
    80004712:	8526                	mv	a0,s1
    80004714:	60e2                	ld	ra,24(sp)
    80004716:	6442                	ld	s0,16(sp)
    80004718:	64a2                	ld	s1,8(sp)
    8000471a:	6105                	addi	sp,sp,32
    8000471c:	8082                	ret
    panic("filedup");
    8000471e:	00004517          	auipc	a0,0x4
    80004722:	f8250513          	addi	a0,a0,-126 # 800086a0 <syscalls+0x250>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	e1e080e7          	jalr	-482(ra) # 80000544 <panic>

000000008000472e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000472e:	7139                	addi	sp,sp,-64
    80004730:	fc06                	sd	ra,56(sp)
    80004732:	f822                	sd	s0,48(sp)
    80004734:	f426                	sd	s1,40(sp)
    80004736:	f04a                	sd	s2,32(sp)
    80004738:	ec4e                	sd	s3,24(sp)
    8000473a:	e852                	sd	s4,16(sp)
    8000473c:	e456                	sd	s5,8(sp)
    8000473e:	0080                	addi	s0,sp,64
    80004740:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004742:	0001c517          	auipc	a0,0x1c
    80004746:	53650513          	addi	a0,a0,1334 # 80020c78 <ftable>
    8000474a:	ffffc097          	auipc	ra,0xffffc
    8000474e:	4a0080e7          	jalr	1184(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004752:	40dc                	lw	a5,4(s1)
    80004754:	06f05163          	blez	a5,800047b6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004758:	37fd                	addiw	a5,a5,-1
    8000475a:	0007871b          	sext.w	a4,a5
    8000475e:	c0dc                	sw	a5,4(s1)
    80004760:	06e04363          	bgtz	a4,800047c6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004764:	0004a903          	lw	s2,0(s1)
    80004768:	0094ca83          	lbu	s5,9(s1)
    8000476c:	0104ba03          	ld	s4,16(s1)
    80004770:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004774:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004778:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000477c:	0001c517          	auipc	a0,0x1c
    80004780:	4fc50513          	addi	a0,a0,1276 # 80020c78 <ftable>
    80004784:	ffffc097          	auipc	ra,0xffffc
    80004788:	51a080e7          	jalr	1306(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    8000478c:	4785                	li	a5,1
    8000478e:	04f90d63          	beq	s2,a5,800047e8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004792:	3979                	addiw	s2,s2,-2
    80004794:	4785                	li	a5,1
    80004796:	0527e063          	bltu	a5,s2,800047d6 <fileclose+0xa8>
    begin_op();
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	ac8080e7          	jalr	-1336(ra) # 80004262 <begin_op>
    iput(ff.ip);
    800047a2:	854e                	mv	a0,s3
    800047a4:	fffff097          	auipc	ra,0xfffff
    800047a8:	2b6080e7          	jalr	694(ra) # 80003a5a <iput>
    end_op();
    800047ac:	00000097          	auipc	ra,0x0
    800047b0:	b36080e7          	jalr	-1226(ra) # 800042e2 <end_op>
    800047b4:	a00d                	j	800047d6 <fileclose+0xa8>
    panic("fileclose");
    800047b6:	00004517          	auipc	a0,0x4
    800047ba:	ef250513          	addi	a0,a0,-270 # 800086a8 <syscalls+0x258>
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	d86080e7          	jalr	-634(ra) # 80000544 <panic>
    release(&ftable.lock);
    800047c6:	0001c517          	auipc	a0,0x1c
    800047ca:	4b250513          	addi	a0,a0,1202 # 80020c78 <ftable>
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	4d0080e7          	jalr	1232(ra) # 80000c9e <release>
  }
}
    800047d6:	70e2                	ld	ra,56(sp)
    800047d8:	7442                	ld	s0,48(sp)
    800047da:	74a2                	ld	s1,40(sp)
    800047dc:	7902                	ld	s2,32(sp)
    800047de:	69e2                	ld	s3,24(sp)
    800047e0:	6a42                	ld	s4,16(sp)
    800047e2:	6aa2                	ld	s5,8(sp)
    800047e4:	6121                	addi	sp,sp,64
    800047e6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047e8:	85d6                	mv	a1,s5
    800047ea:	8552                	mv	a0,s4
    800047ec:	00000097          	auipc	ra,0x0
    800047f0:	34c080e7          	jalr	844(ra) # 80004b38 <pipeclose>
    800047f4:	b7cd                	j	800047d6 <fileclose+0xa8>

00000000800047f6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047f6:	715d                	addi	sp,sp,-80
    800047f8:	e486                	sd	ra,72(sp)
    800047fa:	e0a2                	sd	s0,64(sp)
    800047fc:	fc26                	sd	s1,56(sp)
    800047fe:	f84a                	sd	s2,48(sp)
    80004800:	f44e                	sd	s3,40(sp)
    80004802:	0880                	addi	s0,sp,80
    80004804:	84aa                	mv	s1,a0
    80004806:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004808:	ffffd097          	auipc	ra,0xffffd
    8000480c:	1c8080e7          	jalr	456(ra) # 800019d0 <myproc>
  struct stat st;

  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004810:	409c                	lw	a5,0(s1)
    80004812:	37f9                	addiw	a5,a5,-2
    80004814:	4705                	li	a4,1
    80004816:	04f76763          	bltu	a4,a5,80004864 <filestat+0x6e>
    8000481a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000481c:	6c88                	ld	a0,24(s1)
    8000481e:	fffff097          	auipc	ra,0xfffff
    80004822:	082080e7          	jalr	130(ra) # 800038a0 <ilock>
    stati(f->ip, &st);
    80004826:	fb840593          	addi	a1,s0,-72
    8000482a:	6c88                	ld	a0,24(s1)
    8000482c:	fffff097          	auipc	ra,0xfffff
    80004830:	2fe080e7          	jalr	766(ra) # 80003b2a <stati>
    iunlock(f->ip);
    80004834:	6c88                	ld	a0,24(s1)
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	12c080e7          	jalr	300(ra) # 80003962 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000483e:	46e1                	li	a3,24
    80004840:	fb840613          	addi	a2,s0,-72
    80004844:	85ce                	mv	a1,s3
    80004846:	05093503          	ld	a0,80(s2)
    8000484a:	ffffd097          	auipc	ra,0xffffd
    8000484e:	e3a080e7          	jalr	-454(ra) # 80001684 <copyout>
    80004852:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004856:	60a6                	ld	ra,72(sp)
    80004858:	6406                	ld	s0,64(sp)
    8000485a:	74e2                	ld	s1,56(sp)
    8000485c:	7942                	ld	s2,48(sp)
    8000485e:	79a2                	ld	s3,40(sp)
    80004860:	6161                	addi	sp,sp,80
    80004862:	8082                	ret
  return -1;
    80004864:	557d                	li	a0,-1
    80004866:	bfc5                	j	80004856 <filestat+0x60>

0000000080004868 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004868:	7179                	addi	sp,sp,-48
    8000486a:	f406                	sd	ra,40(sp)
    8000486c:	f022                	sd	s0,32(sp)
    8000486e:	ec26                	sd	s1,24(sp)
    80004870:	e84a                	sd	s2,16(sp)
    80004872:	e44e                	sd	s3,8(sp)
    80004874:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004876:	00854783          	lbu	a5,8(a0)
    8000487a:	c3d5                	beqz	a5,8000491e <fileread+0xb6>
    8000487c:	84aa                	mv	s1,a0
    8000487e:	89ae                	mv	s3,a1
    80004880:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004882:	411c                	lw	a5,0(a0)
    80004884:	4705                	li	a4,1
    80004886:	04e78963          	beq	a5,a4,800048d8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000488a:	470d                	li	a4,3
    8000488c:	04e78d63          	beq	a5,a4,800048e6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004890:	4709                	li	a4,2
    80004892:	06e79e63          	bne	a5,a4,8000490e <fileread+0xa6>
    ilock(f->ip);
    80004896:	6d08                	ld	a0,24(a0)
    80004898:	fffff097          	auipc	ra,0xfffff
    8000489c:	008080e7          	jalr	8(ra) # 800038a0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048a0:	874a                	mv	a4,s2
    800048a2:	5094                	lw	a3,32(s1)
    800048a4:	864e                	mv	a2,s3
    800048a6:	4585                	li	a1,1
    800048a8:	6c88                	ld	a0,24(s1)
    800048aa:	fffff097          	auipc	ra,0xfffff
    800048ae:	2aa080e7          	jalr	682(ra) # 80003b54 <readi>
    800048b2:	892a                	mv	s2,a0
    800048b4:	00a05563          	blez	a0,800048be <fileread+0x56>
      f->off += r;
    800048b8:	509c                	lw	a5,32(s1)
    800048ba:	9fa9                	addw	a5,a5,a0
    800048bc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048be:	6c88                	ld	a0,24(s1)
    800048c0:	fffff097          	auipc	ra,0xfffff
    800048c4:	0a2080e7          	jalr	162(ra) # 80003962 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800048c8:	854a                	mv	a0,s2
    800048ca:	70a2                	ld	ra,40(sp)
    800048cc:	7402                	ld	s0,32(sp)
    800048ce:	64e2                	ld	s1,24(sp)
    800048d0:	6942                	ld	s2,16(sp)
    800048d2:	69a2                	ld	s3,8(sp)
    800048d4:	6145                	addi	sp,sp,48
    800048d6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048d8:	6908                	ld	a0,16(a0)
    800048da:	00000097          	auipc	ra,0x0
    800048de:	3ce080e7          	jalr	974(ra) # 80004ca8 <piperead>
    800048e2:	892a                	mv	s2,a0
    800048e4:	b7d5                	j	800048c8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048e6:	02451783          	lh	a5,36(a0)
    800048ea:	03079693          	slli	a3,a5,0x30
    800048ee:	92c1                	srli	a3,a3,0x30
    800048f0:	4725                	li	a4,9
    800048f2:	02d76863          	bltu	a4,a3,80004922 <fileread+0xba>
    800048f6:	0792                	slli	a5,a5,0x4
    800048f8:	0001c717          	auipc	a4,0x1c
    800048fc:	2e070713          	addi	a4,a4,736 # 80020bd8 <devsw>
    80004900:	97ba                	add	a5,a5,a4
    80004902:	639c                	ld	a5,0(a5)
    80004904:	c38d                	beqz	a5,80004926 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004906:	4505                	li	a0,1
    80004908:	9782                	jalr	a5
    8000490a:	892a                	mv	s2,a0
    8000490c:	bf75                	j	800048c8 <fileread+0x60>
    panic("fileread");
    8000490e:	00004517          	auipc	a0,0x4
    80004912:	daa50513          	addi	a0,a0,-598 # 800086b8 <syscalls+0x268>
    80004916:	ffffc097          	auipc	ra,0xffffc
    8000491a:	c2e080e7          	jalr	-978(ra) # 80000544 <panic>
    return -1;
    8000491e:	597d                	li	s2,-1
    80004920:	b765                	j	800048c8 <fileread+0x60>
      return -1;
    80004922:	597d                	li	s2,-1
    80004924:	b755                	j	800048c8 <fileread+0x60>
    80004926:	597d                	li	s2,-1
    80004928:	b745                	j	800048c8 <fileread+0x60>

000000008000492a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000492a:	715d                	addi	sp,sp,-80
    8000492c:	e486                	sd	ra,72(sp)
    8000492e:	e0a2                	sd	s0,64(sp)
    80004930:	fc26                	sd	s1,56(sp)
    80004932:	f84a                	sd	s2,48(sp)
    80004934:	f44e                	sd	s3,40(sp)
    80004936:	f052                	sd	s4,32(sp)
    80004938:	ec56                	sd	s5,24(sp)
    8000493a:	e85a                	sd	s6,16(sp)
    8000493c:	e45e                	sd	s7,8(sp)
    8000493e:	e062                	sd	s8,0(sp)
    80004940:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004942:	00954783          	lbu	a5,9(a0)
    80004946:	10078663          	beqz	a5,80004a52 <filewrite+0x128>
    8000494a:	892a                	mv	s2,a0
    8000494c:	8aae                	mv	s5,a1
    8000494e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004950:	411c                	lw	a5,0(a0)
    80004952:	4705                	li	a4,1
    80004954:	02e78263          	beq	a5,a4,80004978 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004958:	470d                	li	a4,3
    8000495a:	02e78663          	beq	a5,a4,80004986 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000495e:	4709                	li	a4,2
    80004960:	0ee79163          	bne	a5,a4,80004a42 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004964:	0ac05d63          	blez	a2,80004a1e <filewrite+0xf4>
    int i = 0;
    80004968:	4981                	li	s3,0
    8000496a:	6b05                	lui	s6,0x1
    8000496c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004970:	6b85                	lui	s7,0x1
    80004972:	c00b8b9b          	addiw	s7,s7,-1024
    80004976:	a861                	j	80004a0e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004978:	6908                	ld	a0,16(a0)
    8000497a:	00000097          	auipc	ra,0x0
    8000497e:	22e080e7          	jalr	558(ra) # 80004ba8 <pipewrite>
    80004982:	8a2a                	mv	s4,a0
    80004984:	a045                	j	80004a24 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004986:	02451783          	lh	a5,36(a0)
    8000498a:	03079693          	slli	a3,a5,0x30
    8000498e:	92c1                	srli	a3,a3,0x30
    80004990:	4725                	li	a4,9
    80004992:	0cd76263          	bltu	a4,a3,80004a56 <filewrite+0x12c>
    80004996:	0792                	slli	a5,a5,0x4
    80004998:	0001c717          	auipc	a4,0x1c
    8000499c:	24070713          	addi	a4,a4,576 # 80020bd8 <devsw>
    800049a0:	97ba                	add	a5,a5,a4
    800049a2:	679c                	ld	a5,8(a5)
    800049a4:	cbdd                	beqz	a5,80004a5a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800049a6:	4505                	li	a0,1
    800049a8:	9782                	jalr	a5
    800049aa:	8a2a                	mv	s4,a0
    800049ac:	a8a5                	j	80004a24 <filewrite+0xfa>
    800049ae:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049b2:	00000097          	auipc	ra,0x0
    800049b6:	8b0080e7          	jalr	-1872(ra) # 80004262 <begin_op>
      ilock(f->ip);
    800049ba:	01893503          	ld	a0,24(s2)
    800049be:	fffff097          	auipc	ra,0xfffff
    800049c2:	ee2080e7          	jalr	-286(ra) # 800038a0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049c6:	8762                	mv	a4,s8
    800049c8:	02092683          	lw	a3,32(s2)
    800049cc:	01598633          	add	a2,s3,s5
    800049d0:	4585                	li	a1,1
    800049d2:	01893503          	ld	a0,24(s2)
    800049d6:	fffff097          	auipc	ra,0xfffff
    800049da:	276080e7          	jalr	630(ra) # 80003c4c <writei>
    800049de:	84aa                	mv	s1,a0
    800049e0:	00a05763          	blez	a0,800049ee <filewrite+0xc4>
        f->off += r;
    800049e4:	02092783          	lw	a5,32(s2)
    800049e8:	9fa9                	addw	a5,a5,a0
    800049ea:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049ee:	01893503          	ld	a0,24(s2)
    800049f2:	fffff097          	auipc	ra,0xfffff
    800049f6:	f70080e7          	jalr	-144(ra) # 80003962 <iunlock>
      end_op();
    800049fa:	00000097          	auipc	ra,0x0
    800049fe:	8e8080e7          	jalr	-1816(ra) # 800042e2 <end_op>

      if(r != n1){
    80004a02:	009c1f63          	bne	s8,s1,80004a20 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a06:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a0a:	0149db63          	bge	s3,s4,80004a20 <filewrite+0xf6>
      int n1 = n - i;
    80004a0e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004a12:	84be                	mv	s1,a5
    80004a14:	2781                	sext.w	a5,a5
    80004a16:	f8fb5ce3          	bge	s6,a5,800049ae <filewrite+0x84>
    80004a1a:	84de                	mv	s1,s7
    80004a1c:	bf49                	j	800049ae <filewrite+0x84>
    int i = 0;
    80004a1e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a20:	013a1f63          	bne	s4,s3,80004a3e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a24:	8552                	mv	a0,s4
    80004a26:	60a6                	ld	ra,72(sp)
    80004a28:	6406                	ld	s0,64(sp)
    80004a2a:	74e2                	ld	s1,56(sp)
    80004a2c:	7942                	ld	s2,48(sp)
    80004a2e:	79a2                	ld	s3,40(sp)
    80004a30:	7a02                	ld	s4,32(sp)
    80004a32:	6ae2                	ld	s5,24(sp)
    80004a34:	6b42                	ld	s6,16(sp)
    80004a36:	6ba2                	ld	s7,8(sp)
    80004a38:	6c02                	ld	s8,0(sp)
    80004a3a:	6161                	addi	sp,sp,80
    80004a3c:	8082                	ret
    ret = (i == n ? n : -1);
    80004a3e:	5a7d                	li	s4,-1
    80004a40:	b7d5                	j	80004a24 <filewrite+0xfa>
    panic("filewrite");
    80004a42:	00004517          	auipc	a0,0x4
    80004a46:	c8650513          	addi	a0,a0,-890 # 800086c8 <syscalls+0x278>
    80004a4a:	ffffc097          	auipc	ra,0xffffc
    80004a4e:	afa080e7          	jalr	-1286(ra) # 80000544 <panic>
    return -1;
    80004a52:	5a7d                	li	s4,-1
    80004a54:	bfc1                	j	80004a24 <filewrite+0xfa>
      return -1;
    80004a56:	5a7d                	li	s4,-1
    80004a58:	b7f1                	j	80004a24 <filewrite+0xfa>
    80004a5a:	5a7d                	li	s4,-1
    80004a5c:	b7e1                	j	80004a24 <filewrite+0xfa>

0000000080004a5e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a5e:	7179                	addi	sp,sp,-48
    80004a60:	f406                	sd	ra,40(sp)
    80004a62:	f022                	sd	s0,32(sp)
    80004a64:	ec26                	sd	s1,24(sp)
    80004a66:	e84a                	sd	s2,16(sp)
    80004a68:	e44e                	sd	s3,8(sp)
    80004a6a:	e052                	sd	s4,0(sp)
    80004a6c:	1800                	addi	s0,sp,48
    80004a6e:	84aa                	mv	s1,a0
    80004a70:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a72:	0005b023          	sd	zero,0(a1)
    80004a76:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a7a:	00000097          	auipc	ra,0x0
    80004a7e:	bf8080e7          	jalr	-1032(ra) # 80004672 <filealloc>
    80004a82:	e088                	sd	a0,0(s1)
    80004a84:	c551                	beqz	a0,80004b10 <pipealloc+0xb2>
    80004a86:	00000097          	auipc	ra,0x0
    80004a8a:	bec080e7          	jalr	-1044(ra) # 80004672 <filealloc>
    80004a8e:	00aa3023          	sd	a0,0(s4)
    80004a92:	c92d                	beqz	a0,80004b04 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a94:	ffffc097          	auipc	ra,0xffffc
    80004a98:	066080e7          	jalr	102(ra) # 80000afa <kalloc>
    80004a9c:	892a                	mv	s2,a0
    80004a9e:	c125                	beqz	a0,80004afe <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004aa0:	4985                	li	s3,1
    80004aa2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004aa6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004aaa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004aae:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ab2:	00004597          	auipc	a1,0x4
    80004ab6:	c2658593          	addi	a1,a1,-986 # 800086d8 <syscalls+0x288>
    80004aba:	ffffc097          	auipc	ra,0xffffc
    80004abe:	0a0080e7          	jalr	160(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004ac2:	609c                	ld	a5,0(s1)
    80004ac4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ac8:	609c                	ld	a5,0(s1)
    80004aca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ace:	609c                	ld	a5,0(s1)
    80004ad0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ad4:	609c                	ld	a5,0(s1)
    80004ad6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ada:	000a3783          	ld	a5,0(s4)
    80004ade:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ae2:	000a3783          	ld	a5,0(s4)
    80004ae6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004aea:	000a3783          	ld	a5,0(s4)
    80004aee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004af2:	000a3783          	ld	a5,0(s4)
    80004af6:	0127b823          	sd	s2,16(a5)
  return 0;
    80004afa:	4501                	li	a0,0
    80004afc:	a025                	j	80004b24 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004afe:	6088                	ld	a0,0(s1)
    80004b00:	e501                	bnez	a0,80004b08 <pipealloc+0xaa>
    80004b02:	a039                	j	80004b10 <pipealloc+0xb2>
    80004b04:	6088                	ld	a0,0(s1)
    80004b06:	c51d                	beqz	a0,80004b34 <pipealloc+0xd6>
    fileclose(*f0);
    80004b08:	00000097          	auipc	ra,0x0
    80004b0c:	c26080e7          	jalr	-986(ra) # 8000472e <fileclose>
  if(*f1)
    80004b10:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b14:	557d                	li	a0,-1
  if(*f1)
    80004b16:	c799                	beqz	a5,80004b24 <pipealloc+0xc6>
    fileclose(*f1);
    80004b18:	853e                	mv	a0,a5
    80004b1a:	00000097          	auipc	ra,0x0
    80004b1e:	c14080e7          	jalr	-1004(ra) # 8000472e <fileclose>
  return -1;
    80004b22:	557d                	li	a0,-1
}
    80004b24:	70a2                	ld	ra,40(sp)
    80004b26:	7402                	ld	s0,32(sp)
    80004b28:	64e2                	ld	s1,24(sp)
    80004b2a:	6942                	ld	s2,16(sp)
    80004b2c:	69a2                	ld	s3,8(sp)
    80004b2e:	6a02                	ld	s4,0(sp)
    80004b30:	6145                	addi	sp,sp,48
    80004b32:	8082                	ret
  return -1;
    80004b34:	557d                	li	a0,-1
    80004b36:	b7fd                	j	80004b24 <pipealloc+0xc6>

0000000080004b38 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b38:	1101                	addi	sp,sp,-32
    80004b3a:	ec06                	sd	ra,24(sp)
    80004b3c:	e822                	sd	s0,16(sp)
    80004b3e:	e426                	sd	s1,8(sp)
    80004b40:	e04a                	sd	s2,0(sp)
    80004b42:	1000                	addi	s0,sp,32
    80004b44:	84aa                	mv	s1,a0
    80004b46:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b48:	ffffc097          	auipc	ra,0xffffc
    80004b4c:	0a2080e7          	jalr	162(ra) # 80000bea <acquire>
  if(writable){
    80004b50:	02090d63          	beqz	s2,80004b8a <pipeclose+0x52>
    pi->writeopen = 0;
    80004b54:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b58:	21848513          	addi	a0,s1,536
    80004b5c:	ffffd097          	auipc	ra,0xffffd
    80004b60:	5c6080e7          	jalr	1478(ra) # 80002122 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b64:	2204b783          	ld	a5,544(s1)
    80004b68:	eb95                	bnez	a5,80004b9c <pipeclose+0x64>
    release(&pi->lock);
    80004b6a:	8526                	mv	a0,s1
    80004b6c:	ffffc097          	auipc	ra,0xffffc
    80004b70:	132080e7          	jalr	306(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004b74:	8526                	mv	a0,s1
    80004b76:	ffffc097          	auipc	ra,0xffffc
    80004b7a:	e88080e7          	jalr	-376(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004b7e:	60e2                	ld	ra,24(sp)
    80004b80:	6442                	ld	s0,16(sp)
    80004b82:	64a2                	ld	s1,8(sp)
    80004b84:	6902                	ld	s2,0(sp)
    80004b86:	6105                	addi	sp,sp,32
    80004b88:	8082                	ret
    pi->readopen = 0;
    80004b8a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b8e:	21c48513          	addi	a0,s1,540
    80004b92:	ffffd097          	auipc	ra,0xffffd
    80004b96:	590080e7          	jalr	1424(ra) # 80002122 <wakeup>
    80004b9a:	b7e9                	j	80004b64 <pipeclose+0x2c>
    release(&pi->lock);
    80004b9c:	8526                	mv	a0,s1
    80004b9e:	ffffc097          	auipc	ra,0xffffc
    80004ba2:	100080e7          	jalr	256(ra) # 80000c9e <release>
}
    80004ba6:	bfe1                	j	80004b7e <pipeclose+0x46>

0000000080004ba8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ba8:	7159                	addi	sp,sp,-112
    80004baa:	f486                	sd	ra,104(sp)
    80004bac:	f0a2                	sd	s0,96(sp)
    80004bae:	eca6                	sd	s1,88(sp)
    80004bb0:	e8ca                	sd	s2,80(sp)
    80004bb2:	e4ce                	sd	s3,72(sp)
    80004bb4:	e0d2                	sd	s4,64(sp)
    80004bb6:	fc56                	sd	s5,56(sp)
    80004bb8:	f85a                	sd	s6,48(sp)
    80004bba:	f45e                	sd	s7,40(sp)
    80004bbc:	f062                	sd	s8,32(sp)
    80004bbe:	ec66                	sd	s9,24(sp)
    80004bc0:	1880                	addi	s0,sp,112
    80004bc2:	84aa                	mv	s1,a0
    80004bc4:	8aae                	mv	s5,a1
    80004bc6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004bc8:	ffffd097          	auipc	ra,0xffffd
    80004bcc:	e08080e7          	jalr	-504(ra) # 800019d0 <myproc>
    80004bd0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004bd2:	8526                	mv	a0,s1
    80004bd4:	ffffc097          	auipc	ra,0xffffc
    80004bd8:	016080e7          	jalr	22(ra) # 80000bea <acquire>
  while(i < n){
    80004bdc:	0d405463          	blez	s4,80004ca4 <pipewrite+0xfc>
    80004be0:	8ba6                	mv	s7,s1
  int i = 0;
    80004be2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004be4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004be6:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004bea:	21c48c13          	addi	s8,s1,540
    80004bee:	a08d                	j	80004c50 <pipewrite+0xa8>
      release(&pi->lock);
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	0ac080e7          	jalr	172(ra) # 80000c9e <release>
      return -1;
    80004bfa:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004bfc:	854a                	mv	a0,s2
    80004bfe:	70a6                	ld	ra,104(sp)
    80004c00:	7406                	ld	s0,96(sp)
    80004c02:	64e6                	ld	s1,88(sp)
    80004c04:	6946                	ld	s2,80(sp)
    80004c06:	69a6                	ld	s3,72(sp)
    80004c08:	6a06                	ld	s4,64(sp)
    80004c0a:	7ae2                	ld	s5,56(sp)
    80004c0c:	7b42                	ld	s6,48(sp)
    80004c0e:	7ba2                	ld	s7,40(sp)
    80004c10:	7c02                	ld	s8,32(sp)
    80004c12:	6ce2                	ld	s9,24(sp)
    80004c14:	6165                	addi	sp,sp,112
    80004c16:	8082                	ret
      wakeup(&pi->nread);
    80004c18:	8566                	mv	a0,s9
    80004c1a:	ffffd097          	auipc	ra,0xffffd
    80004c1e:	508080e7          	jalr	1288(ra) # 80002122 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c22:	85de                	mv	a1,s7
    80004c24:	8562                	mv	a0,s8
    80004c26:	ffffd097          	auipc	ra,0xffffd
    80004c2a:	498080e7          	jalr	1176(ra) # 800020be <sleep>
    80004c2e:	a839                	j	80004c4c <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c30:	21c4a783          	lw	a5,540(s1)
    80004c34:	0017871b          	addiw	a4,a5,1
    80004c38:	20e4ae23          	sw	a4,540(s1)
    80004c3c:	1ff7f793          	andi	a5,a5,511
    80004c40:	97a6                	add	a5,a5,s1
    80004c42:	f9f44703          	lbu	a4,-97(s0)
    80004c46:	00e78c23          	sb	a4,24(a5)
      i++;
    80004c4a:	2905                	addiw	s2,s2,1
  while(i < n){
    80004c4c:	05495063          	bge	s2,s4,80004c8c <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004c50:	2204a783          	lw	a5,544(s1)
    80004c54:	dfd1                	beqz	a5,80004bf0 <pipewrite+0x48>
    80004c56:	854e                	mv	a0,s3
    80004c58:	ffffd097          	auipc	ra,0xffffd
    80004c5c:	70e080e7          	jalr	1806(ra) # 80002366 <killed>
    80004c60:	f941                	bnez	a0,80004bf0 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c62:	2184a783          	lw	a5,536(s1)
    80004c66:	21c4a703          	lw	a4,540(s1)
    80004c6a:	2007879b          	addiw	a5,a5,512
    80004c6e:	faf705e3          	beq	a4,a5,80004c18 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c72:	4685                	li	a3,1
    80004c74:	01590633          	add	a2,s2,s5
    80004c78:	f9f40593          	addi	a1,s0,-97
    80004c7c:	0509b503          	ld	a0,80(s3)
    80004c80:	ffffd097          	auipc	ra,0xffffd
    80004c84:	a90080e7          	jalr	-1392(ra) # 80001710 <copyin>
    80004c88:	fb6514e3          	bne	a0,s6,80004c30 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004c8c:	21848513          	addi	a0,s1,536
    80004c90:	ffffd097          	auipc	ra,0xffffd
    80004c94:	492080e7          	jalr	1170(ra) # 80002122 <wakeup>
  release(&pi->lock);
    80004c98:	8526                	mv	a0,s1
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	004080e7          	jalr	4(ra) # 80000c9e <release>
  return i;
    80004ca2:	bfa9                	j	80004bfc <pipewrite+0x54>
  int i = 0;
    80004ca4:	4901                	li	s2,0
    80004ca6:	b7dd                	j	80004c8c <pipewrite+0xe4>

0000000080004ca8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ca8:	715d                	addi	sp,sp,-80
    80004caa:	e486                	sd	ra,72(sp)
    80004cac:	e0a2                	sd	s0,64(sp)
    80004cae:	fc26                	sd	s1,56(sp)
    80004cb0:	f84a                	sd	s2,48(sp)
    80004cb2:	f44e                	sd	s3,40(sp)
    80004cb4:	f052                	sd	s4,32(sp)
    80004cb6:	ec56                	sd	s5,24(sp)
    80004cb8:	e85a                	sd	s6,16(sp)
    80004cba:	0880                	addi	s0,sp,80
    80004cbc:	84aa                	mv	s1,a0
    80004cbe:	892e                	mv	s2,a1
    80004cc0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004cc2:	ffffd097          	auipc	ra,0xffffd
    80004cc6:	d0e080e7          	jalr	-754(ra) # 800019d0 <myproc>
    80004cca:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ccc:	8b26                	mv	s6,s1
    80004cce:	8526                	mv	a0,s1
    80004cd0:	ffffc097          	auipc	ra,0xffffc
    80004cd4:	f1a080e7          	jalr	-230(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cd8:	2184a703          	lw	a4,536(s1)
    80004cdc:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ce0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ce4:	02f71763          	bne	a4,a5,80004d12 <piperead+0x6a>
    80004ce8:	2244a783          	lw	a5,548(s1)
    80004cec:	c39d                	beqz	a5,80004d12 <piperead+0x6a>
    if(killed(pr)){
    80004cee:	8552                	mv	a0,s4
    80004cf0:	ffffd097          	auipc	ra,0xffffd
    80004cf4:	676080e7          	jalr	1654(ra) # 80002366 <killed>
    80004cf8:	e941                	bnez	a0,80004d88 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004cfa:	85da                	mv	a1,s6
    80004cfc:	854e                	mv	a0,s3
    80004cfe:	ffffd097          	auipc	ra,0xffffd
    80004d02:	3c0080e7          	jalr	960(ra) # 800020be <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d06:	2184a703          	lw	a4,536(s1)
    80004d0a:	21c4a783          	lw	a5,540(s1)
    80004d0e:	fcf70de3          	beq	a4,a5,80004ce8 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d12:	09505263          	blez	s5,80004d96 <piperead+0xee>
    80004d16:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d18:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004d1a:	2184a783          	lw	a5,536(s1)
    80004d1e:	21c4a703          	lw	a4,540(s1)
    80004d22:	02f70d63          	beq	a4,a5,80004d5c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d26:	0017871b          	addiw	a4,a5,1
    80004d2a:	20e4ac23          	sw	a4,536(s1)
    80004d2e:	1ff7f793          	andi	a5,a5,511
    80004d32:	97a6                	add	a5,a5,s1
    80004d34:	0187c783          	lbu	a5,24(a5)
    80004d38:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d3c:	4685                	li	a3,1
    80004d3e:	fbf40613          	addi	a2,s0,-65
    80004d42:	85ca                	mv	a1,s2
    80004d44:	050a3503          	ld	a0,80(s4)
    80004d48:	ffffd097          	auipc	ra,0xffffd
    80004d4c:	93c080e7          	jalr	-1732(ra) # 80001684 <copyout>
    80004d50:	01650663          	beq	a0,s6,80004d5c <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d54:	2985                	addiw	s3,s3,1
    80004d56:	0905                	addi	s2,s2,1
    80004d58:	fd3a91e3          	bne	s5,s3,80004d1a <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d5c:	21c48513          	addi	a0,s1,540
    80004d60:	ffffd097          	auipc	ra,0xffffd
    80004d64:	3c2080e7          	jalr	962(ra) # 80002122 <wakeup>
  release(&pi->lock);
    80004d68:	8526                	mv	a0,s1
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	f34080e7          	jalr	-204(ra) # 80000c9e <release>
  return i;
}
    80004d72:	854e                	mv	a0,s3
    80004d74:	60a6                	ld	ra,72(sp)
    80004d76:	6406                	ld	s0,64(sp)
    80004d78:	74e2                	ld	s1,56(sp)
    80004d7a:	7942                	ld	s2,48(sp)
    80004d7c:	79a2                	ld	s3,40(sp)
    80004d7e:	7a02                	ld	s4,32(sp)
    80004d80:	6ae2                	ld	s5,24(sp)
    80004d82:	6b42                	ld	s6,16(sp)
    80004d84:	6161                	addi	sp,sp,80
    80004d86:	8082                	ret
      release(&pi->lock);
    80004d88:	8526                	mv	a0,s1
    80004d8a:	ffffc097          	auipc	ra,0xffffc
    80004d8e:	f14080e7          	jalr	-236(ra) # 80000c9e <release>
      return -1;
    80004d92:	59fd                	li	s3,-1
    80004d94:	bff9                	j	80004d72 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d96:	4981                	li	s3,0
    80004d98:	b7d1                	j	80004d5c <piperead+0xb4>

0000000080004d9a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004d9a:	1141                	addi	sp,sp,-16
    80004d9c:	e422                	sd	s0,8(sp)
    80004d9e:	0800                	addi	s0,sp,16
    80004da0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004da2:	8905                	andi	a0,a0,1
    80004da4:	c111                	beqz	a0,80004da8 <flags2perm+0xe>
      perm = PTE_X;
    80004da6:	4521                	li	a0,8
    if(flags & 0x2)
    80004da8:	8b89                	andi	a5,a5,2
    80004daa:	c399                	beqz	a5,80004db0 <flags2perm+0x16>
      perm |= PTE_W;
    80004dac:	00456513          	ori	a0,a0,4
    return perm;
}
    80004db0:	6422                	ld	s0,8(sp)
    80004db2:	0141                	addi	sp,sp,16
    80004db4:	8082                	ret

0000000080004db6 <exec>:

int
exec(char *path, char **argv)
{
    80004db6:	df010113          	addi	sp,sp,-528
    80004dba:	20113423          	sd	ra,520(sp)
    80004dbe:	20813023          	sd	s0,512(sp)
    80004dc2:	ffa6                	sd	s1,504(sp)
    80004dc4:	fbca                	sd	s2,496(sp)
    80004dc6:	f7ce                	sd	s3,488(sp)
    80004dc8:	f3d2                	sd	s4,480(sp)
    80004dca:	efd6                	sd	s5,472(sp)
    80004dcc:	ebda                	sd	s6,464(sp)
    80004dce:	e7de                	sd	s7,456(sp)
    80004dd0:	e3e2                	sd	s8,448(sp)
    80004dd2:	ff66                	sd	s9,440(sp)
    80004dd4:	fb6a                	sd	s10,432(sp)
    80004dd6:	f76e                	sd	s11,424(sp)
    80004dd8:	0c00                	addi	s0,sp,528
    80004dda:	84aa                	mv	s1,a0
    80004ddc:	dea43c23          	sd	a0,-520(s0)
    80004de0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004de4:	ffffd097          	auipc	ra,0xffffd
    80004de8:	bec080e7          	jalr	-1044(ra) # 800019d0 <myproc>
    80004dec:	892a                	mv	s2,a0

  begin_op();
    80004dee:	fffff097          	auipc	ra,0xfffff
    80004df2:	474080e7          	jalr	1140(ra) # 80004262 <begin_op>

  if((ip = namei(path)) == 0){
    80004df6:	8526                	mv	a0,s1
    80004df8:	fffff097          	auipc	ra,0xfffff
    80004dfc:	24e080e7          	jalr	590(ra) # 80004046 <namei>
    80004e00:	c92d                	beqz	a0,80004e72 <exec+0xbc>
    80004e02:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e04:	fffff097          	auipc	ra,0xfffff
    80004e08:	a9c080e7          	jalr	-1380(ra) # 800038a0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e0c:	04000713          	li	a4,64
    80004e10:	4681                	li	a3,0
    80004e12:	e5040613          	addi	a2,s0,-432
    80004e16:	4581                	li	a1,0
    80004e18:	8526                	mv	a0,s1
    80004e1a:	fffff097          	auipc	ra,0xfffff
    80004e1e:	d3a080e7          	jalr	-710(ra) # 80003b54 <readi>
    80004e22:	04000793          	li	a5,64
    80004e26:	00f51a63          	bne	a0,a5,80004e3a <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004e2a:	e5042703          	lw	a4,-432(s0)
    80004e2e:	464c47b7          	lui	a5,0x464c4
    80004e32:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e36:	04f70463          	beq	a4,a5,80004e7e <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	cc6080e7          	jalr	-826(ra) # 80003b02 <iunlockput>
    end_op();
    80004e44:	fffff097          	auipc	ra,0xfffff
    80004e48:	49e080e7          	jalr	1182(ra) # 800042e2 <end_op>
  }
  return -1;
    80004e4c:	557d                	li	a0,-1
}
    80004e4e:	20813083          	ld	ra,520(sp)
    80004e52:	20013403          	ld	s0,512(sp)
    80004e56:	74fe                	ld	s1,504(sp)
    80004e58:	795e                	ld	s2,496(sp)
    80004e5a:	79be                	ld	s3,488(sp)
    80004e5c:	7a1e                	ld	s4,480(sp)
    80004e5e:	6afe                	ld	s5,472(sp)
    80004e60:	6b5e                	ld	s6,464(sp)
    80004e62:	6bbe                	ld	s7,456(sp)
    80004e64:	6c1e                	ld	s8,448(sp)
    80004e66:	7cfa                	ld	s9,440(sp)
    80004e68:	7d5a                	ld	s10,432(sp)
    80004e6a:	7dba                	ld	s11,424(sp)
    80004e6c:	21010113          	addi	sp,sp,528
    80004e70:	8082                	ret
    end_op();
    80004e72:	fffff097          	auipc	ra,0xfffff
    80004e76:	470080e7          	jalr	1136(ra) # 800042e2 <end_op>
    return -1;
    80004e7a:	557d                	li	a0,-1
    80004e7c:	bfc9                	j	80004e4e <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e7e:	854a                	mv	a0,s2
    80004e80:	ffffd097          	auipc	ra,0xffffd
    80004e84:	c14080e7          	jalr	-1004(ra) # 80001a94 <proc_pagetable>
    80004e88:	8baa                	mv	s7,a0
    80004e8a:	d945                	beqz	a0,80004e3a <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e8c:	e7042983          	lw	s3,-400(s0)
    80004e90:	e8845783          	lhu	a5,-376(s0)
    80004e94:	c7ad                	beqz	a5,80004efe <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e96:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e98:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004e9a:	6c85                	lui	s9,0x1
    80004e9c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004ea0:	def43823          	sd	a5,-528(s0)
    80004ea4:	ac0d                	j	800050d6 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ea6:	00004517          	auipc	a0,0x4
    80004eaa:	83a50513          	addi	a0,a0,-1990 # 800086e0 <syscalls+0x290>
    80004eae:	ffffb097          	auipc	ra,0xffffb
    80004eb2:	696080e7          	jalr	1686(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eb6:	8756                	mv	a4,s5
    80004eb8:	012d86bb          	addw	a3,s11,s2
    80004ebc:	4581                	li	a1,0
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	c94080e7          	jalr	-876(ra) # 80003b54 <readi>
    80004ec8:	2501                	sext.w	a0,a0
    80004eca:	1aaa9a63          	bne	s5,a0,8000507e <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80004ece:	6785                	lui	a5,0x1
    80004ed0:	0127893b          	addw	s2,a5,s2
    80004ed4:	77fd                	lui	a5,0xfffff
    80004ed6:	01478a3b          	addw	s4,a5,s4
    80004eda:	1f897563          	bgeu	s2,s8,800050c4 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80004ede:	02091593          	slli	a1,s2,0x20
    80004ee2:	9181                	srli	a1,a1,0x20
    80004ee4:	95ea                	add	a1,a1,s10
    80004ee6:	855e                	mv	a0,s7
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	190080e7          	jalr	400(ra) # 80001078 <walkaddr>
    80004ef0:	862a                	mv	a2,a0
    if(pa == 0)
    80004ef2:	d955                	beqz	a0,80004ea6 <exec+0xf0>
      n = PGSIZE;
    80004ef4:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004ef6:	fd9a70e3          	bgeu	s4,s9,80004eb6 <exec+0x100>
      n = sz - i;
    80004efa:	8ad2                	mv	s5,s4
    80004efc:	bf6d                	j	80004eb6 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004efe:	4a01                	li	s4,0
  iunlockput(ip);
    80004f00:	8526                	mv	a0,s1
    80004f02:	fffff097          	auipc	ra,0xfffff
    80004f06:	c00080e7          	jalr	-1024(ra) # 80003b02 <iunlockput>
  end_op();
    80004f0a:	fffff097          	auipc	ra,0xfffff
    80004f0e:	3d8080e7          	jalr	984(ra) # 800042e2 <end_op>
  p = myproc();
    80004f12:	ffffd097          	auipc	ra,0xffffd
    80004f16:	abe080e7          	jalr	-1346(ra) # 800019d0 <myproc>
    80004f1a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004f1c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f20:	6785                	lui	a5,0x1
    80004f22:	17fd                	addi	a5,a5,-1
    80004f24:	9a3e                	add	s4,s4,a5
    80004f26:	757d                	lui	a0,0xfffff
    80004f28:	00aa77b3          	and	a5,s4,a0
    80004f2c:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f30:	4691                	li	a3,4
    80004f32:	6609                	lui	a2,0x2
    80004f34:	963e                	add	a2,a2,a5
    80004f36:	85be                	mv	a1,a5
    80004f38:	855e                	mv	a0,s7
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	4f2080e7          	jalr	1266(ra) # 8000142c <uvmalloc>
    80004f42:	8b2a                	mv	s6,a0
  ip = 0;
    80004f44:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f46:	12050c63          	beqz	a0,8000507e <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f4a:	75f9                	lui	a1,0xffffe
    80004f4c:	95aa                	add	a1,a1,a0
    80004f4e:	855e                	mv	a0,s7
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	702080e7          	jalr	1794(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f58:	7c7d                	lui	s8,0xfffff
    80004f5a:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f5c:	e0043783          	ld	a5,-512(s0)
    80004f60:	6388                	ld	a0,0(a5)
    80004f62:	c535                	beqz	a0,80004fce <exec+0x218>
    80004f64:	e9040993          	addi	s3,s0,-368
    80004f68:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004f6c:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004f6e:	ffffc097          	auipc	ra,0xffffc
    80004f72:	efc080e7          	jalr	-260(ra) # 80000e6a <strlen>
    80004f76:	2505                	addiw	a0,a0,1
    80004f78:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f7c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004f80:	13896663          	bltu	s2,s8,800050ac <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f84:	e0043d83          	ld	s11,-512(s0)
    80004f88:	000dba03          	ld	s4,0(s11)
    80004f8c:	8552                	mv	a0,s4
    80004f8e:	ffffc097          	auipc	ra,0xffffc
    80004f92:	edc080e7          	jalr	-292(ra) # 80000e6a <strlen>
    80004f96:	0015069b          	addiw	a3,a0,1
    80004f9a:	8652                	mv	a2,s4
    80004f9c:	85ca                	mv	a1,s2
    80004f9e:	855e                	mv	a0,s7
    80004fa0:	ffffc097          	auipc	ra,0xffffc
    80004fa4:	6e4080e7          	jalr	1764(ra) # 80001684 <copyout>
    80004fa8:	10054663          	bltz	a0,800050b4 <exec+0x2fe>
    ustack[argc] = sp;
    80004fac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fb0:	0485                	addi	s1,s1,1
    80004fb2:	008d8793          	addi	a5,s11,8
    80004fb6:	e0f43023          	sd	a5,-512(s0)
    80004fba:	008db503          	ld	a0,8(s11)
    80004fbe:	c911                	beqz	a0,80004fd2 <exec+0x21c>
    if(argc >= MAXARG)
    80004fc0:	09a1                	addi	s3,s3,8
    80004fc2:	fb3c96e3          	bne	s9,s3,80004f6e <exec+0x1b8>
  sz = sz1;
    80004fc6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fca:	4481                	li	s1,0
    80004fcc:	a84d                	j	8000507e <exec+0x2c8>
  sp = sz;
    80004fce:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004fd0:	4481                	li	s1,0
  ustack[argc] = 0;
    80004fd2:	00349793          	slli	a5,s1,0x3
    80004fd6:	f9040713          	addi	a4,s0,-112
    80004fda:	97ba                	add	a5,a5,a4
    80004fdc:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80004fe0:	00148693          	addi	a3,s1,1
    80004fe4:	068e                	slli	a3,a3,0x3
    80004fe6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004fea:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004fee:	01897663          	bgeu	s2,s8,80004ffa <exec+0x244>
  sz = sz1;
    80004ff2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ff6:	4481                	li	s1,0
    80004ff8:	a059                	j	8000507e <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ffa:	e9040613          	addi	a2,s0,-368
    80004ffe:	85ca                	mv	a1,s2
    80005000:	855e                	mv	a0,s7
    80005002:	ffffc097          	auipc	ra,0xffffc
    80005006:	682080e7          	jalr	1666(ra) # 80001684 <copyout>
    8000500a:	0a054963          	bltz	a0,800050bc <exec+0x306>
  p->trapframe->a1 = sp;
    8000500e:	058ab783          	ld	a5,88(s5)
    80005012:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005016:	df843783          	ld	a5,-520(s0)
    8000501a:	0007c703          	lbu	a4,0(a5)
    8000501e:	cf11                	beqz	a4,8000503a <exec+0x284>
    80005020:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005022:	02f00693          	li	a3,47
    80005026:	a039                	j	80005034 <exec+0x27e>
      last = s+1;
    80005028:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000502c:	0785                	addi	a5,a5,1
    8000502e:	fff7c703          	lbu	a4,-1(a5)
    80005032:	c701                	beqz	a4,8000503a <exec+0x284>
    if(*s == '/')
    80005034:	fed71ce3          	bne	a4,a3,8000502c <exec+0x276>
    80005038:	bfc5                	j	80005028 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000503a:	4641                	li	a2,16
    8000503c:	df843583          	ld	a1,-520(s0)
    80005040:	158a8513          	addi	a0,s5,344
    80005044:	ffffc097          	auipc	ra,0xffffc
    80005048:	df4080e7          	jalr	-524(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    8000504c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005050:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005054:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005058:	058ab783          	ld	a5,88(s5)
    8000505c:	e6843703          	ld	a4,-408(s0)
    80005060:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005062:	058ab783          	ld	a5,88(s5)
    80005066:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000506a:	85ea                	mv	a1,s10
    8000506c:	ffffd097          	auipc	ra,0xffffd
    80005070:	ac4080e7          	jalr	-1340(ra) # 80001b30 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005074:	0004851b          	sext.w	a0,s1
    80005078:	bbd9                	j	80004e4e <exec+0x98>
    8000507a:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000507e:	e0843583          	ld	a1,-504(s0)
    80005082:	855e                	mv	a0,s7
    80005084:	ffffd097          	auipc	ra,0xffffd
    80005088:	aac080e7          	jalr	-1364(ra) # 80001b30 <proc_freepagetable>
  if(ip){
    8000508c:	da0497e3          	bnez	s1,80004e3a <exec+0x84>
  return -1;
    80005090:	557d                	li	a0,-1
    80005092:	bb75                	j	80004e4e <exec+0x98>
    80005094:	e1443423          	sd	s4,-504(s0)
    80005098:	b7dd                	j	8000507e <exec+0x2c8>
    8000509a:	e1443423          	sd	s4,-504(s0)
    8000509e:	b7c5                	j	8000507e <exec+0x2c8>
    800050a0:	e1443423          	sd	s4,-504(s0)
    800050a4:	bfe9                	j	8000507e <exec+0x2c8>
    800050a6:	e1443423          	sd	s4,-504(s0)
    800050aa:	bfd1                	j	8000507e <exec+0x2c8>
  sz = sz1;
    800050ac:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050b0:	4481                	li	s1,0
    800050b2:	b7f1                	j	8000507e <exec+0x2c8>
  sz = sz1;
    800050b4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050b8:	4481                	li	s1,0
    800050ba:	b7d1                	j	8000507e <exec+0x2c8>
  sz = sz1;
    800050bc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800050c0:	4481                	li	s1,0
    800050c2:	bf75                	j	8000507e <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050c4:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050c8:	2b05                	addiw	s6,s6,1
    800050ca:	0389899b          	addiw	s3,s3,56
    800050ce:	e8845783          	lhu	a5,-376(s0)
    800050d2:	e2fb57e3          	bge	s6,a5,80004f00 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050d6:	2981                	sext.w	s3,s3
    800050d8:	03800713          	li	a4,56
    800050dc:	86ce                	mv	a3,s3
    800050de:	e1840613          	addi	a2,s0,-488
    800050e2:	4581                	li	a1,0
    800050e4:	8526                	mv	a0,s1
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	a6e080e7          	jalr	-1426(ra) # 80003b54 <readi>
    800050ee:	03800793          	li	a5,56
    800050f2:	f8f514e3          	bne	a0,a5,8000507a <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800050f6:	e1842783          	lw	a5,-488(s0)
    800050fa:	4705                	li	a4,1
    800050fc:	fce796e3          	bne	a5,a4,800050c8 <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005100:	e4043903          	ld	s2,-448(s0)
    80005104:	e3843783          	ld	a5,-456(s0)
    80005108:	f8f966e3          	bltu	s2,a5,80005094 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000510c:	e2843783          	ld	a5,-472(s0)
    80005110:	993e                	add	s2,s2,a5
    80005112:	f8f964e3          	bltu	s2,a5,8000509a <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005116:	df043703          	ld	a4,-528(s0)
    8000511a:	8ff9                	and	a5,a5,a4
    8000511c:	f3d1                	bnez	a5,800050a0 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000511e:	e1c42503          	lw	a0,-484(s0)
    80005122:	00000097          	auipc	ra,0x0
    80005126:	c78080e7          	jalr	-904(ra) # 80004d9a <flags2perm>
    8000512a:	86aa                	mv	a3,a0
    8000512c:	864a                	mv	a2,s2
    8000512e:	85d2                	mv	a1,s4
    80005130:	855e                	mv	a0,s7
    80005132:	ffffc097          	auipc	ra,0xffffc
    80005136:	2fa080e7          	jalr	762(ra) # 8000142c <uvmalloc>
    8000513a:	e0a43423          	sd	a0,-504(s0)
    8000513e:	d525                	beqz	a0,800050a6 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005140:	e2843d03          	ld	s10,-472(s0)
    80005144:	e2042d83          	lw	s11,-480(s0)
    80005148:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000514c:	f60c0ce3          	beqz	s8,800050c4 <exec+0x30e>
    80005150:	8a62                	mv	s4,s8
    80005152:	4901                	li	s2,0
    80005154:	b369                	j	80004ede <exec+0x128>

0000000080005156 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005156:	7179                	addi	sp,sp,-48
    80005158:	f406                	sd	ra,40(sp)
    8000515a:	f022                	sd	s0,32(sp)
    8000515c:	ec26                	sd	s1,24(sp)
    8000515e:	e84a                	sd	s2,16(sp)
    80005160:	1800                	addi	s0,sp,48
    80005162:	892e                	mv	s2,a1
    80005164:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005166:	fdc40593          	addi	a1,s0,-36
    8000516a:	ffffe097          	auipc	ra,0xffffe
    8000516e:	ae4080e7          	jalr	-1308(ra) # 80002c4e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005172:	fdc42703          	lw	a4,-36(s0)
    80005176:	47bd                	li	a5,15
    80005178:	02e7eb63          	bltu	a5,a4,800051ae <argfd+0x58>
    8000517c:	ffffd097          	auipc	ra,0xffffd
    80005180:	854080e7          	jalr	-1964(ra) # 800019d0 <myproc>
    80005184:	fdc42703          	lw	a4,-36(s0)
    80005188:	01a70793          	addi	a5,a4,26
    8000518c:	078e                	slli	a5,a5,0x3
    8000518e:	953e                	add	a0,a0,a5
    80005190:	611c                	ld	a5,0(a0)
    80005192:	c385                	beqz	a5,800051b2 <argfd+0x5c>
    return -1;
  if(pfd)
    80005194:	00090463          	beqz	s2,8000519c <argfd+0x46>
    *pfd = fd;
    80005198:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000519c:	4501                	li	a0,0
  if(pf)
    8000519e:	c091                	beqz	s1,800051a2 <argfd+0x4c>
    *pf = f;
    800051a0:	e09c                	sd	a5,0(s1)
}
    800051a2:	70a2                	ld	ra,40(sp)
    800051a4:	7402                	ld	s0,32(sp)
    800051a6:	64e2                	ld	s1,24(sp)
    800051a8:	6942                	ld	s2,16(sp)
    800051aa:	6145                	addi	sp,sp,48
    800051ac:	8082                	ret
    return -1;
    800051ae:	557d                	li	a0,-1
    800051b0:	bfcd                	j	800051a2 <argfd+0x4c>
    800051b2:	557d                	li	a0,-1
    800051b4:	b7fd                	j	800051a2 <argfd+0x4c>

00000000800051b6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051b6:	1101                	addi	sp,sp,-32
    800051b8:	ec06                	sd	ra,24(sp)
    800051ba:	e822                	sd	s0,16(sp)
    800051bc:	e426                	sd	s1,8(sp)
    800051be:	1000                	addi	s0,sp,32
    800051c0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800051c2:	ffffd097          	auipc	ra,0xffffd
    800051c6:	80e080e7          	jalr	-2034(ra) # 800019d0 <myproc>
    800051ca:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800051cc:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdd360>
    800051d0:	4501                	li	a0,0
    800051d2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800051d4:	6398                	ld	a4,0(a5)
    800051d6:	cb19                	beqz	a4,800051ec <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800051d8:	2505                	addiw	a0,a0,1
    800051da:	07a1                	addi	a5,a5,8
    800051dc:	fed51ce3          	bne	a0,a3,800051d4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800051e0:	557d                	li	a0,-1
}
    800051e2:	60e2                	ld	ra,24(sp)
    800051e4:	6442                	ld	s0,16(sp)
    800051e6:	64a2                	ld	s1,8(sp)
    800051e8:	6105                	addi	sp,sp,32
    800051ea:	8082                	ret
      p->ofile[fd] = f;
    800051ec:	01a50793          	addi	a5,a0,26
    800051f0:	078e                	slli	a5,a5,0x3
    800051f2:	963e                	add	a2,a2,a5
    800051f4:	e204                	sd	s1,0(a2)
      return fd;
    800051f6:	b7f5                	j	800051e2 <fdalloc+0x2c>

00000000800051f8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800051f8:	715d                	addi	sp,sp,-80
    800051fa:	e486                	sd	ra,72(sp)
    800051fc:	e0a2                	sd	s0,64(sp)
    800051fe:	fc26                	sd	s1,56(sp)
    80005200:	f84a                	sd	s2,48(sp)
    80005202:	f44e                	sd	s3,40(sp)
    80005204:	f052                	sd	s4,32(sp)
    80005206:	ec56                	sd	s5,24(sp)
    80005208:	e85a                	sd	s6,16(sp)
    8000520a:	0880                	addi	s0,sp,80
    8000520c:	8b2e                	mv	s6,a1
    8000520e:	89b2                	mv	s3,a2
    80005210:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005212:	fb040593          	addi	a1,s0,-80
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	e4e080e7          	jalr	-434(ra) # 80004064 <nameiparent>
    8000521e:	84aa                	mv	s1,a0
    80005220:	16050063          	beqz	a0,80005380 <create+0x188>
    return 0;

  ilock(dp);
    80005224:	ffffe097          	auipc	ra,0xffffe
    80005228:	67c080e7          	jalr	1660(ra) # 800038a0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000522c:	4601                	li	a2,0
    8000522e:	fb040593          	addi	a1,s0,-80
    80005232:	8526                	mv	a0,s1
    80005234:	fffff097          	auipc	ra,0xfffff
    80005238:	b50080e7          	jalr	-1200(ra) # 80003d84 <dirlookup>
    8000523c:	8aaa                	mv	s5,a0
    8000523e:	c931                	beqz	a0,80005292 <create+0x9a>
    iunlockput(dp);
    80005240:	8526                	mv	a0,s1
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	8c0080e7          	jalr	-1856(ra) # 80003b02 <iunlockput>
    ilock(ip);
    8000524a:	8556                	mv	a0,s5
    8000524c:	ffffe097          	auipc	ra,0xffffe
    80005250:	654080e7          	jalr	1620(ra) # 800038a0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005254:	000b059b          	sext.w	a1,s6
    80005258:	4789                	li	a5,2
    8000525a:	02f59563          	bne	a1,a5,80005284 <create+0x8c>
    8000525e:	044ad783          	lhu	a5,68(s5)
    80005262:	37f9                	addiw	a5,a5,-2
    80005264:	17c2                	slli	a5,a5,0x30
    80005266:	93c1                	srli	a5,a5,0x30
    80005268:	4705                	li	a4,1
    8000526a:	00f76d63          	bltu	a4,a5,80005284 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000526e:	8556                	mv	a0,s5
    80005270:	60a6                	ld	ra,72(sp)
    80005272:	6406                	ld	s0,64(sp)
    80005274:	74e2                	ld	s1,56(sp)
    80005276:	7942                	ld	s2,48(sp)
    80005278:	79a2                	ld	s3,40(sp)
    8000527a:	7a02                	ld	s4,32(sp)
    8000527c:	6ae2                	ld	s5,24(sp)
    8000527e:	6b42                	ld	s6,16(sp)
    80005280:	6161                	addi	sp,sp,80
    80005282:	8082                	ret
    iunlockput(ip);
    80005284:	8556                	mv	a0,s5
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	87c080e7          	jalr	-1924(ra) # 80003b02 <iunlockput>
    return 0;
    8000528e:	4a81                	li	s5,0
    80005290:	bff9                	j	8000526e <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005292:	85da                	mv	a1,s6
    80005294:	4088                	lw	a0,0(s1)
    80005296:	ffffe097          	auipc	ra,0xffffe
    8000529a:	46e080e7          	jalr	1134(ra) # 80003704 <ialloc>
    8000529e:	8a2a                	mv	s4,a0
    800052a0:	c921                	beqz	a0,800052f0 <create+0xf8>
  ilock(ip);
    800052a2:	ffffe097          	auipc	ra,0xffffe
    800052a6:	5fe080e7          	jalr	1534(ra) # 800038a0 <ilock>
  ip->major = major;
    800052aa:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800052ae:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800052b2:	4785                	li	a5,1
    800052b4:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800052b8:	8552                	mv	a0,s4
    800052ba:	ffffe097          	auipc	ra,0xffffe
    800052be:	51c080e7          	jalr	1308(ra) # 800037d6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052c2:	000b059b          	sext.w	a1,s6
    800052c6:	4785                	li	a5,1
    800052c8:	02f58b63          	beq	a1,a5,800052fe <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800052cc:	004a2603          	lw	a2,4(s4)
    800052d0:	fb040593          	addi	a1,s0,-80
    800052d4:	8526                	mv	a0,s1
    800052d6:	fffff097          	auipc	ra,0xfffff
    800052da:	cbe080e7          	jalr	-834(ra) # 80003f94 <dirlink>
    800052de:	06054f63          	bltz	a0,8000535c <create+0x164>
  iunlockput(dp);
    800052e2:	8526                	mv	a0,s1
    800052e4:	fffff097          	auipc	ra,0xfffff
    800052e8:	81e080e7          	jalr	-2018(ra) # 80003b02 <iunlockput>
  return ip;
    800052ec:	8ad2                	mv	s5,s4
    800052ee:	b741                	j	8000526e <create+0x76>
    iunlockput(dp);
    800052f0:	8526                	mv	a0,s1
    800052f2:	fffff097          	auipc	ra,0xfffff
    800052f6:	810080e7          	jalr	-2032(ra) # 80003b02 <iunlockput>
    return 0;
    800052fa:	8ad2                	mv	s5,s4
    800052fc:	bf8d                	j	8000526e <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800052fe:	004a2603          	lw	a2,4(s4)
    80005302:	00003597          	auipc	a1,0x3
    80005306:	3fe58593          	addi	a1,a1,1022 # 80008700 <syscalls+0x2b0>
    8000530a:	8552                	mv	a0,s4
    8000530c:	fffff097          	auipc	ra,0xfffff
    80005310:	c88080e7          	jalr	-888(ra) # 80003f94 <dirlink>
    80005314:	04054463          	bltz	a0,8000535c <create+0x164>
    80005318:	40d0                	lw	a2,4(s1)
    8000531a:	00003597          	auipc	a1,0x3
    8000531e:	3ee58593          	addi	a1,a1,1006 # 80008708 <syscalls+0x2b8>
    80005322:	8552                	mv	a0,s4
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	c70080e7          	jalr	-912(ra) # 80003f94 <dirlink>
    8000532c:	02054863          	bltz	a0,8000535c <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005330:	004a2603          	lw	a2,4(s4)
    80005334:	fb040593          	addi	a1,s0,-80
    80005338:	8526                	mv	a0,s1
    8000533a:	fffff097          	auipc	ra,0xfffff
    8000533e:	c5a080e7          	jalr	-934(ra) # 80003f94 <dirlink>
    80005342:	00054d63          	bltz	a0,8000535c <create+0x164>
    dp->nlink++;  // for ".."
    80005346:	04a4d783          	lhu	a5,74(s1)
    8000534a:	2785                	addiw	a5,a5,1
    8000534c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005350:	8526                	mv	a0,s1
    80005352:	ffffe097          	auipc	ra,0xffffe
    80005356:	484080e7          	jalr	1156(ra) # 800037d6 <iupdate>
    8000535a:	b761                	j	800052e2 <create+0xea>
  ip->nlink = 0;
    8000535c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005360:	8552                	mv	a0,s4
    80005362:	ffffe097          	auipc	ra,0xffffe
    80005366:	474080e7          	jalr	1140(ra) # 800037d6 <iupdate>
  iunlockput(ip);
    8000536a:	8552                	mv	a0,s4
    8000536c:	ffffe097          	auipc	ra,0xffffe
    80005370:	796080e7          	jalr	1942(ra) # 80003b02 <iunlockput>
  iunlockput(dp);
    80005374:	8526                	mv	a0,s1
    80005376:	ffffe097          	auipc	ra,0xffffe
    8000537a:	78c080e7          	jalr	1932(ra) # 80003b02 <iunlockput>
  return 0;
    8000537e:	bdc5                	j	8000526e <create+0x76>
    return 0;
    80005380:	8aaa                	mv	s5,a0
    80005382:	b5f5                	j	8000526e <create+0x76>

0000000080005384 <sys_dup>:
{
    80005384:	7179                	addi	sp,sp,-48
    80005386:	f406                	sd	ra,40(sp)
    80005388:	f022                	sd	s0,32(sp)
    8000538a:	ec26                	sd	s1,24(sp)
    8000538c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000538e:	fd840613          	addi	a2,s0,-40
    80005392:	4581                	li	a1,0
    80005394:	4501                	li	a0,0
    80005396:	00000097          	auipc	ra,0x0
    8000539a:	dc0080e7          	jalr	-576(ra) # 80005156 <argfd>
    return -1;
    8000539e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053a0:	02054363          	bltz	a0,800053c6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800053a4:	fd843503          	ld	a0,-40(s0)
    800053a8:	00000097          	auipc	ra,0x0
    800053ac:	e0e080e7          	jalr	-498(ra) # 800051b6 <fdalloc>
    800053b0:	84aa                	mv	s1,a0
    return -1;
    800053b2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053b4:	00054963          	bltz	a0,800053c6 <sys_dup+0x42>
  filedup(f);
    800053b8:	fd843503          	ld	a0,-40(s0)
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	320080e7          	jalr	800(ra) # 800046dc <filedup>
  return fd;
    800053c4:	87a6                	mv	a5,s1
}
    800053c6:	853e                	mv	a0,a5
    800053c8:	70a2                	ld	ra,40(sp)
    800053ca:	7402                	ld	s0,32(sp)
    800053cc:	64e2                	ld	s1,24(sp)
    800053ce:	6145                	addi	sp,sp,48
    800053d0:	8082                	ret

00000000800053d2 <sys_read>:
{
    800053d2:	7179                	addi	sp,sp,-48
    800053d4:	f406                	sd	ra,40(sp)
    800053d6:	f022                	sd	s0,32(sp)
    800053d8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053da:	fd840593          	addi	a1,s0,-40
    800053de:	4505                	li	a0,1
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	88e080e7          	jalr	-1906(ra) # 80002c6e <argaddr>
  argint(2, &n);
    800053e8:	fe440593          	addi	a1,s0,-28
    800053ec:	4509                	li	a0,2
    800053ee:	ffffe097          	auipc	ra,0xffffe
    800053f2:	860080e7          	jalr	-1952(ra) # 80002c4e <argint>
  if(argfd(0, 0, &f) < 0)
    800053f6:	fe840613          	addi	a2,s0,-24
    800053fa:	4581                	li	a1,0
    800053fc:	4501                	li	a0,0
    800053fe:	00000097          	auipc	ra,0x0
    80005402:	d58080e7          	jalr	-680(ra) # 80005156 <argfd>
    80005406:	87aa                	mv	a5,a0
    return -1;
    80005408:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000540a:	0007cc63          	bltz	a5,80005422 <sys_read+0x50>
  return fileread(f, p, n);
    8000540e:	fe442603          	lw	a2,-28(s0)
    80005412:	fd843583          	ld	a1,-40(s0)
    80005416:	fe843503          	ld	a0,-24(s0)
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	44e080e7          	jalr	1102(ra) # 80004868 <fileread>
}
    80005422:	70a2                	ld	ra,40(sp)
    80005424:	7402                	ld	s0,32(sp)
    80005426:	6145                	addi	sp,sp,48
    80005428:	8082                	ret

000000008000542a <sys_write>:
{
    8000542a:	7179                	addi	sp,sp,-48
    8000542c:	f406                	sd	ra,40(sp)
    8000542e:	f022                	sd	s0,32(sp)
    80005430:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005432:	fd840593          	addi	a1,s0,-40
    80005436:	4505                	li	a0,1
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	836080e7          	jalr	-1994(ra) # 80002c6e <argaddr>
  argint(2, &n);
    80005440:	fe440593          	addi	a1,s0,-28
    80005444:	4509                	li	a0,2
    80005446:	ffffe097          	auipc	ra,0xffffe
    8000544a:	808080e7          	jalr	-2040(ra) # 80002c4e <argint>
  if(argfd(0, 0, &f) < 0)
    8000544e:	fe840613          	addi	a2,s0,-24
    80005452:	4581                	li	a1,0
    80005454:	4501                	li	a0,0
    80005456:	00000097          	auipc	ra,0x0
    8000545a:	d00080e7          	jalr	-768(ra) # 80005156 <argfd>
    8000545e:	87aa                	mv	a5,a0
    return -1;
    80005460:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005462:	0007cc63          	bltz	a5,8000547a <sys_write+0x50>
  return filewrite(f, p, n);
    80005466:	fe442603          	lw	a2,-28(s0)
    8000546a:	fd843583          	ld	a1,-40(s0)
    8000546e:	fe843503          	ld	a0,-24(s0)
    80005472:	fffff097          	auipc	ra,0xfffff
    80005476:	4b8080e7          	jalr	1208(ra) # 8000492a <filewrite>
}
    8000547a:	70a2                	ld	ra,40(sp)
    8000547c:	7402                	ld	s0,32(sp)
    8000547e:	6145                	addi	sp,sp,48
    80005480:	8082                	ret

0000000080005482 <sys_close>:
{
    80005482:	1101                	addi	sp,sp,-32
    80005484:	ec06                	sd	ra,24(sp)
    80005486:	e822                	sd	s0,16(sp)
    80005488:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000548a:	fe040613          	addi	a2,s0,-32
    8000548e:	fec40593          	addi	a1,s0,-20
    80005492:	4501                	li	a0,0
    80005494:	00000097          	auipc	ra,0x0
    80005498:	cc2080e7          	jalr	-830(ra) # 80005156 <argfd>
    return -1;
    8000549c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000549e:	02054463          	bltz	a0,800054c6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054a2:	ffffc097          	auipc	ra,0xffffc
    800054a6:	52e080e7          	jalr	1326(ra) # 800019d0 <myproc>
    800054aa:	fec42783          	lw	a5,-20(s0)
    800054ae:	07e9                	addi	a5,a5,26
    800054b0:	078e                	slli	a5,a5,0x3
    800054b2:	97aa                	add	a5,a5,a0
    800054b4:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800054b8:	fe043503          	ld	a0,-32(s0)
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	272080e7          	jalr	626(ra) # 8000472e <fileclose>
  return 0;
    800054c4:	4781                	li	a5,0
}
    800054c6:	853e                	mv	a0,a5
    800054c8:	60e2                	ld	ra,24(sp)
    800054ca:	6442                	ld	s0,16(sp)
    800054cc:	6105                	addi	sp,sp,32
    800054ce:	8082                	ret

00000000800054d0 <sys_fstat>:
{
    800054d0:	1101                	addi	sp,sp,-32
    800054d2:	ec06                	sd	ra,24(sp)
    800054d4:	e822                	sd	s0,16(sp)
    800054d6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800054d8:	fe040593          	addi	a1,s0,-32
    800054dc:	4505                	li	a0,1
    800054de:	ffffd097          	auipc	ra,0xffffd
    800054e2:	790080e7          	jalr	1936(ra) # 80002c6e <argaddr>
  if(argfd(0, 0, &f) < 0)
    800054e6:	fe840613          	addi	a2,s0,-24
    800054ea:	4581                	li	a1,0
    800054ec:	4501                	li	a0,0
    800054ee:	00000097          	auipc	ra,0x0
    800054f2:	c68080e7          	jalr	-920(ra) # 80005156 <argfd>
    800054f6:	87aa                	mv	a5,a0
    return -1;
    800054f8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054fa:	0007ca63          	bltz	a5,8000550e <sys_fstat+0x3e>
  return filestat(f, st);
    800054fe:	fe043583          	ld	a1,-32(s0)
    80005502:	fe843503          	ld	a0,-24(s0)
    80005506:	fffff097          	auipc	ra,0xfffff
    8000550a:	2f0080e7          	jalr	752(ra) # 800047f6 <filestat>
}
    8000550e:	60e2                	ld	ra,24(sp)
    80005510:	6442                	ld	s0,16(sp)
    80005512:	6105                	addi	sp,sp,32
    80005514:	8082                	ret

0000000080005516 <sys_link>:
{
    80005516:	7169                	addi	sp,sp,-304
    80005518:	f606                	sd	ra,296(sp)
    8000551a:	f222                	sd	s0,288(sp)
    8000551c:	ee26                	sd	s1,280(sp)
    8000551e:	ea4a                	sd	s2,272(sp)
    80005520:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005522:	08000613          	li	a2,128
    80005526:	ed040593          	addi	a1,s0,-304
    8000552a:	4501                	li	a0,0
    8000552c:	ffffd097          	auipc	ra,0xffffd
    80005530:	762080e7          	jalr	1890(ra) # 80002c8e <argstr>
    return -1;
    80005534:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005536:	10054e63          	bltz	a0,80005652 <sys_link+0x13c>
    8000553a:	08000613          	li	a2,128
    8000553e:	f5040593          	addi	a1,s0,-176
    80005542:	4505                	li	a0,1
    80005544:	ffffd097          	auipc	ra,0xffffd
    80005548:	74a080e7          	jalr	1866(ra) # 80002c8e <argstr>
    return -1;
    8000554c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000554e:	10054263          	bltz	a0,80005652 <sys_link+0x13c>
  begin_op();
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	d10080e7          	jalr	-752(ra) # 80004262 <begin_op>
  if((ip = namei(old)) == 0){
    8000555a:	ed040513          	addi	a0,s0,-304
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	ae8080e7          	jalr	-1304(ra) # 80004046 <namei>
    80005566:	84aa                	mv	s1,a0
    80005568:	c551                	beqz	a0,800055f4 <sys_link+0xde>
  ilock(ip);
    8000556a:	ffffe097          	auipc	ra,0xffffe
    8000556e:	336080e7          	jalr	822(ra) # 800038a0 <ilock>
  if(ip->type == T_DIR){
    80005572:	04449703          	lh	a4,68(s1)
    80005576:	4785                	li	a5,1
    80005578:	08f70463          	beq	a4,a5,80005600 <sys_link+0xea>
  ip->nlink++;
    8000557c:	04a4d783          	lhu	a5,74(s1)
    80005580:	2785                	addiw	a5,a5,1
    80005582:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005586:	8526                	mv	a0,s1
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	24e080e7          	jalr	590(ra) # 800037d6 <iupdate>
  iunlock(ip);
    80005590:	8526                	mv	a0,s1
    80005592:	ffffe097          	auipc	ra,0xffffe
    80005596:	3d0080e7          	jalr	976(ra) # 80003962 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000559a:	fd040593          	addi	a1,s0,-48
    8000559e:	f5040513          	addi	a0,s0,-176
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	ac2080e7          	jalr	-1342(ra) # 80004064 <nameiparent>
    800055aa:	892a                	mv	s2,a0
    800055ac:	c935                	beqz	a0,80005620 <sys_link+0x10a>
  ilock(dp);
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	2f2080e7          	jalr	754(ra) # 800038a0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800055b6:	00092703          	lw	a4,0(s2)
    800055ba:	409c                	lw	a5,0(s1)
    800055bc:	04f71d63          	bne	a4,a5,80005616 <sys_link+0x100>
    800055c0:	40d0                	lw	a2,4(s1)
    800055c2:	fd040593          	addi	a1,s0,-48
    800055c6:	854a                	mv	a0,s2
    800055c8:	fffff097          	auipc	ra,0xfffff
    800055cc:	9cc080e7          	jalr	-1588(ra) # 80003f94 <dirlink>
    800055d0:	04054363          	bltz	a0,80005616 <sys_link+0x100>
  iunlockput(dp);
    800055d4:	854a                	mv	a0,s2
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	52c080e7          	jalr	1324(ra) # 80003b02 <iunlockput>
  iput(ip);
    800055de:	8526                	mv	a0,s1
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	47a080e7          	jalr	1146(ra) # 80003a5a <iput>
  end_op();
    800055e8:	fffff097          	auipc	ra,0xfffff
    800055ec:	cfa080e7          	jalr	-774(ra) # 800042e2 <end_op>
  return 0;
    800055f0:	4781                	li	a5,0
    800055f2:	a085                	j	80005652 <sys_link+0x13c>
    end_op();
    800055f4:	fffff097          	auipc	ra,0xfffff
    800055f8:	cee080e7          	jalr	-786(ra) # 800042e2 <end_op>
    return -1;
    800055fc:	57fd                	li	a5,-1
    800055fe:	a891                	j	80005652 <sys_link+0x13c>
    iunlockput(ip);
    80005600:	8526                	mv	a0,s1
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	500080e7          	jalr	1280(ra) # 80003b02 <iunlockput>
    end_op();
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	cd8080e7          	jalr	-808(ra) # 800042e2 <end_op>
    return -1;
    80005612:	57fd                	li	a5,-1
    80005614:	a83d                	j	80005652 <sys_link+0x13c>
    iunlockput(dp);
    80005616:	854a                	mv	a0,s2
    80005618:	ffffe097          	auipc	ra,0xffffe
    8000561c:	4ea080e7          	jalr	1258(ra) # 80003b02 <iunlockput>
  ilock(ip);
    80005620:	8526                	mv	a0,s1
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	27e080e7          	jalr	638(ra) # 800038a0 <ilock>
  ip->nlink--;
    8000562a:	04a4d783          	lhu	a5,74(s1)
    8000562e:	37fd                	addiw	a5,a5,-1
    80005630:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	1a0080e7          	jalr	416(ra) # 800037d6 <iupdate>
  iunlockput(ip);
    8000563e:	8526                	mv	a0,s1
    80005640:	ffffe097          	auipc	ra,0xffffe
    80005644:	4c2080e7          	jalr	1218(ra) # 80003b02 <iunlockput>
  end_op();
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	c9a080e7          	jalr	-870(ra) # 800042e2 <end_op>
  return -1;
    80005650:	57fd                	li	a5,-1
}
    80005652:	853e                	mv	a0,a5
    80005654:	70b2                	ld	ra,296(sp)
    80005656:	7412                	ld	s0,288(sp)
    80005658:	64f2                	ld	s1,280(sp)
    8000565a:	6952                	ld	s2,272(sp)
    8000565c:	6155                	addi	sp,sp,304
    8000565e:	8082                	ret

0000000080005660 <sys_unlink>:
{
    80005660:	7151                	addi	sp,sp,-240
    80005662:	f586                	sd	ra,232(sp)
    80005664:	f1a2                	sd	s0,224(sp)
    80005666:	eda6                	sd	s1,216(sp)
    80005668:	e9ca                	sd	s2,208(sp)
    8000566a:	e5ce                	sd	s3,200(sp)
    8000566c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000566e:	08000613          	li	a2,128
    80005672:	f3040593          	addi	a1,s0,-208
    80005676:	4501                	li	a0,0
    80005678:	ffffd097          	auipc	ra,0xffffd
    8000567c:	616080e7          	jalr	1558(ra) # 80002c8e <argstr>
    80005680:	18054163          	bltz	a0,80005802 <sys_unlink+0x1a2>
  begin_op();
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	bde080e7          	jalr	-1058(ra) # 80004262 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000568c:	fb040593          	addi	a1,s0,-80
    80005690:	f3040513          	addi	a0,s0,-208
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	9d0080e7          	jalr	-1584(ra) # 80004064 <nameiparent>
    8000569c:	84aa                	mv	s1,a0
    8000569e:	c979                	beqz	a0,80005774 <sys_unlink+0x114>
  ilock(dp);
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	200080e7          	jalr	512(ra) # 800038a0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056a8:	00003597          	auipc	a1,0x3
    800056ac:	05858593          	addi	a1,a1,88 # 80008700 <syscalls+0x2b0>
    800056b0:	fb040513          	addi	a0,s0,-80
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	6b6080e7          	jalr	1718(ra) # 80003d6a <namecmp>
    800056bc:	14050a63          	beqz	a0,80005810 <sys_unlink+0x1b0>
    800056c0:	00003597          	auipc	a1,0x3
    800056c4:	04858593          	addi	a1,a1,72 # 80008708 <syscalls+0x2b8>
    800056c8:	fb040513          	addi	a0,s0,-80
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	69e080e7          	jalr	1694(ra) # 80003d6a <namecmp>
    800056d4:	12050e63          	beqz	a0,80005810 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800056d8:	f2c40613          	addi	a2,s0,-212
    800056dc:	fb040593          	addi	a1,s0,-80
    800056e0:	8526                	mv	a0,s1
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	6a2080e7          	jalr	1698(ra) # 80003d84 <dirlookup>
    800056ea:	892a                	mv	s2,a0
    800056ec:	12050263          	beqz	a0,80005810 <sys_unlink+0x1b0>
  ilock(ip);
    800056f0:	ffffe097          	auipc	ra,0xffffe
    800056f4:	1b0080e7          	jalr	432(ra) # 800038a0 <ilock>
  if(ip->nlink < 1)
    800056f8:	04a91783          	lh	a5,74(s2)
    800056fc:	08f05263          	blez	a5,80005780 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005700:	04491703          	lh	a4,68(s2)
    80005704:	4785                	li	a5,1
    80005706:	08f70563          	beq	a4,a5,80005790 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000570a:	4641                	li	a2,16
    8000570c:	4581                	li	a1,0
    8000570e:	fc040513          	addi	a0,s0,-64
    80005712:	ffffb097          	auipc	ra,0xffffb
    80005716:	5d4080e7          	jalr	1492(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000571a:	4741                	li	a4,16
    8000571c:	f2c42683          	lw	a3,-212(s0)
    80005720:	fc040613          	addi	a2,s0,-64
    80005724:	4581                	li	a1,0
    80005726:	8526                	mv	a0,s1
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	524080e7          	jalr	1316(ra) # 80003c4c <writei>
    80005730:	47c1                	li	a5,16
    80005732:	0af51563          	bne	a0,a5,800057dc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005736:	04491703          	lh	a4,68(s2)
    8000573a:	4785                	li	a5,1
    8000573c:	0af70863          	beq	a4,a5,800057ec <sys_unlink+0x18c>
  iunlockput(dp);
    80005740:	8526                	mv	a0,s1
    80005742:	ffffe097          	auipc	ra,0xffffe
    80005746:	3c0080e7          	jalr	960(ra) # 80003b02 <iunlockput>
  ip->nlink--;
    8000574a:	04a95783          	lhu	a5,74(s2)
    8000574e:	37fd                	addiw	a5,a5,-1
    80005750:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005754:	854a                	mv	a0,s2
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	080080e7          	jalr	128(ra) # 800037d6 <iupdate>
  iunlockput(ip);
    8000575e:	854a                	mv	a0,s2
    80005760:	ffffe097          	auipc	ra,0xffffe
    80005764:	3a2080e7          	jalr	930(ra) # 80003b02 <iunlockput>
  end_op();
    80005768:	fffff097          	auipc	ra,0xfffff
    8000576c:	b7a080e7          	jalr	-1158(ra) # 800042e2 <end_op>
  return 0;
    80005770:	4501                	li	a0,0
    80005772:	a84d                	j	80005824 <sys_unlink+0x1c4>
    end_op();
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	b6e080e7          	jalr	-1170(ra) # 800042e2 <end_op>
    return -1;
    8000577c:	557d                	li	a0,-1
    8000577e:	a05d                	j	80005824 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005780:	00003517          	auipc	a0,0x3
    80005784:	f9050513          	addi	a0,a0,-112 # 80008710 <syscalls+0x2c0>
    80005788:	ffffb097          	auipc	ra,0xffffb
    8000578c:	dbc080e7          	jalr	-580(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005790:	04c92703          	lw	a4,76(s2)
    80005794:	02000793          	li	a5,32
    80005798:	f6e7f9e3          	bgeu	a5,a4,8000570a <sys_unlink+0xaa>
    8000579c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057a0:	4741                	li	a4,16
    800057a2:	86ce                	mv	a3,s3
    800057a4:	f1840613          	addi	a2,s0,-232
    800057a8:	4581                	li	a1,0
    800057aa:	854a                	mv	a0,s2
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	3a8080e7          	jalr	936(ra) # 80003b54 <readi>
    800057b4:	47c1                	li	a5,16
    800057b6:	00f51b63          	bne	a0,a5,800057cc <sys_unlink+0x16c>
    if(de.inum != 0)
    800057ba:	f1845783          	lhu	a5,-232(s0)
    800057be:	e7a1                	bnez	a5,80005806 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057c0:	29c1                	addiw	s3,s3,16
    800057c2:	04c92783          	lw	a5,76(s2)
    800057c6:	fcf9ede3          	bltu	s3,a5,800057a0 <sys_unlink+0x140>
    800057ca:	b781                	j	8000570a <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800057cc:	00003517          	auipc	a0,0x3
    800057d0:	f5c50513          	addi	a0,a0,-164 # 80008728 <syscalls+0x2d8>
    800057d4:	ffffb097          	auipc	ra,0xffffb
    800057d8:	d70080e7          	jalr	-656(ra) # 80000544 <panic>
    panic("unlink: writei");
    800057dc:	00003517          	auipc	a0,0x3
    800057e0:	f6450513          	addi	a0,a0,-156 # 80008740 <syscalls+0x2f0>
    800057e4:	ffffb097          	auipc	ra,0xffffb
    800057e8:	d60080e7          	jalr	-672(ra) # 80000544 <panic>
    dp->nlink--;
    800057ec:	04a4d783          	lhu	a5,74(s1)
    800057f0:	37fd                	addiw	a5,a5,-1
    800057f2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800057f6:	8526                	mv	a0,s1
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	fde080e7          	jalr	-34(ra) # 800037d6 <iupdate>
    80005800:	b781                	j	80005740 <sys_unlink+0xe0>
    return -1;
    80005802:	557d                	li	a0,-1
    80005804:	a005                	j	80005824 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005806:	854a                	mv	a0,s2
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	2fa080e7          	jalr	762(ra) # 80003b02 <iunlockput>
  iunlockput(dp);
    80005810:	8526                	mv	a0,s1
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	2f0080e7          	jalr	752(ra) # 80003b02 <iunlockput>
  end_op();
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	ac8080e7          	jalr	-1336(ra) # 800042e2 <end_op>
  return -1;
    80005822:	557d                	li	a0,-1
}
    80005824:	70ae                	ld	ra,232(sp)
    80005826:	740e                	ld	s0,224(sp)
    80005828:	64ee                	ld	s1,216(sp)
    8000582a:	694e                	ld	s2,208(sp)
    8000582c:	69ae                	ld	s3,200(sp)
    8000582e:	616d                	addi	sp,sp,240
    80005830:	8082                	ret

0000000080005832 <sys_open>:

uint64
sys_open(void)
{
    80005832:	7131                	addi	sp,sp,-192
    80005834:	fd06                	sd	ra,184(sp)
    80005836:	f922                	sd	s0,176(sp)
    80005838:	f526                	sd	s1,168(sp)
    8000583a:	f14a                	sd	s2,160(sp)
    8000583c:	ed4e                	sd	s3,152(sp)
    8000583e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005840:	f4c40593          	addi	a1,s0,-180
    80005844:	4505                	li	a0,1
    80005846:	ffffd097          	auipc	ra,0xffffd
    8000584a:	408080e7          	jalr	1032(ra) # 80002c4e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000584e:	08000613          	li	a2,128
    80005852:	f5040593          	addi	a1,s0,-176
    80005856:	4501                	li	a0,0
    80005858:	ffffd097          	auipc	ra,0xffffd
    8000585c:	436080e7          	jalr	1078(ra) # 80002c8e <argstr>
    80005860:	87aa                	mv	a5,a0
    return -1;
    80005862:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005864:	0a07c963          	bltz	a5,80005916 <sys_open+0xe4>

  begin_op();
    80005868:	fffff097          	auipc	ra,0xfffff
    8000586c:	9fa080e7          	jalr	-1542(ra) # 80004262 <begin_op>

  if(omode & O_CREATE){
    80005870:	f4c42783          	lw	a5,-180(s0)
    80005874:	2007f793          	andi	a5,a5,512
    80005878:	cfc5                	beqz	a5,80005930 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000587a:	4681                	li	a3,0
    8000587c:	4601                	li	a2,0
    8000587e:	4589                	li	a1,2
    80005880:	f5040513          	addi	a0,s0,-176
    80005884:	00000097          	auipc	ra,0x0
    80005888:	974080e7          	jalr	-1676(ra) # 800051f8 <create>
    8000588c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000588e:	c959                	beqz	a0,80005924 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005890:	04449703          	lh	a4,68(s1)
    80005894:	478d                	li	a5,3
    80005896:	00f71763          	bne	a4,a5,800058a4 <sys_open+0x72>
    8000589a:	0464d703          	lhu	a4,70(s1)
    8000589e:	47a5                	li	a5,9
    800058a0:	0ce7ed63          	bltu	a5,a4,8000597a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058a4:	fffff097          	auipc	ra,0xfffff
    800058a8:	dce080e7          	jalr	-562(ra) # 80004672 <filealloc>
    800058ac:	89aa                	mv	s3,a0
    800058ae:	10050363          	beqz	a0,800059b4 <sys_open+0x182>
    800058b2:	00000097          	auipc	ra,0x0
    800058b6:	904080e7          	jalr	-1788(ra) # 800051b6 <fdalloc>
    800058ba:	892a                	mv	s2,a0
    800058bc:	0e054763          	bltz	a0,800059aa <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058c0:	04449703          	lh	a4,68(s1)
    800058c4:	478d                	li	a5,3
    800058c6:	0cf70563          	beq	a4,a5,80005990 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058ca:	4789                	li	a5,2
    800058cc:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800058d0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800058d4:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800058d8:	f4c42783          	lw	a5,-180(s0)
    800058dc:	0017c713          	xori	a4,a5,1
    800058e0:	8b05                	andi	a4,a4,1
    800058e2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058e6:	0037f713          	andi	a4,a5,3
    800058ea:	00e03733          	snez	a4,a4
    800058ee:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058f2:	4007f793          	andi	a5,a5,1024
    800058f6:	c791                	beqz	a5,80005902 <sys_open+0xd0>
    800058f8:	04449703          	lh	a4,68(s1)
    800058fc:	4789                	li	a5,2
    800058fe:	0af70063          	beq	a4,a5,8000599e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005902:	8526                	mv	a0,s1
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	05e080e7          	jalr	94(ra) # 80003962 <iunlock>
  end_op();
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	9d6080e7          	jalr	-1578(ra) # 800042e2 <end_op>

  return fd;
    80005914:	854a                	mv	a0,s2
}
    80005916:	70ea                	ld	ra,184(sp)
    80005918:	744a                	ld	s0,176(sp)
    8000591a:	74aa                	ld	s1,168(sp)
    8000591c:	790a                	ld	s2,160(sp)
    8000591e:	69ea                	ld	s3,152(sp)
    80005920:	6129                	addi	sp,sp,192
    80005922:	8082                	ret
      end_op();
    80005924:	fffff097          	auipc	ra,0xfffff
    80005928:	9be080e7          	jalr	-1602(ra) # 800042e2 <end_op>
      return -1;
    8000592c:	557d                	li	a0,-1
    8000592e:	b7e5                	j	80005916 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005930:	f5040513          	addi	a0,s0,-176
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	712080e7          	jalr	1810(ra) # 80004046 <namei>
    8000593c:	84aa                	mv	s1,a0
    8000593e:	c905                	beqz	a0,8000596e <sys_open+0x13c>
    ilock(ip);
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	f60080e7          	jalr	-160(ra) # 800038a0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005948:	04449703          	lh	a4,68(s1)
    8000594c:	4785                	li	a5,1
    8000594e:	f4f711e3          	bne	a4,a5,80005890 <sys_open+0x5e>
    80005952:	f4c42783          	lw	a5,-180(s0)
    80005956:	d7b9                	beqz	a5,800058a4 <sys_open+0x72>
      iunlockput(ip);
    80005958:	8526                	mv	a0,s1
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	1a8080e7          	jalr	424(ra) # 80003b02 <iunlockput>
      end_op();
    80005962:	fffff097          	auipc	ra,0xfffff
    80005966:	980080e7          	jalr	-1664(ra) # 800042e2 <end_op>
      return -1;
    8000596a:	557d                	li	a0,-1
    8000596c:	b76d                	j	80005916 <sys_open+0xe4>
      end_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	974080e7          	jalr	-1676(ra) # 800042e2 <end_op>
      return -1;
    80005976:	557d                	li	a0,-1
    80005978:	bf79                	j	80005916 <sys_open+0xe4>
    iunlockput(ip);
    8000597a:	8526                	mv	a0,s1
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	186080e7          	jalr	390(ra) # 80003b02 <iunlockput>
    end_op();
    80005984:	fffff097          	auipc	ra,0xfffff
    80005988:	95e080e7          	jalr	-1698(ra) # 800042e2 <end_op>
    return -1;
    8000598c:	557d                	li	a0,-1
    8000598e:	b761                	j	80005916 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005990:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005994:	04649783          	lh	a5,70(s1)
    80005998:	02f99223          	sh	a5,36(s3)
    8000599c:	bf25                	j	800058d4 <sys_open+0xa2>
    itrunc(ip);
    8000599e:	8526                	mv	a0,s1
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	00e080e7          	jalr	14(ra) # 800039ae <itrunc>
    800059a8:	bfa9                	j	80005902 <sys_open+0xd0>
      fileclose(f);
    800059aa:	854e                	mv	a0,s3
    800059ac:	fffff097          	auipc	ra,0xfffff
    800059b0:	d82080e7          	jalr	-638(ra) # 8000472e <fileclose>
    iunlockput(ip);
    800059b4:	8526                	mv	a0,s1
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	14c080e7          	jalr	332(ra) # 80003b02 <iunlockput>
    end_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	924080e7          	jalr	-1756(ra) # 800042e2 <end_op>
    return -1;
    800059c6:	557d                	li	a0,-1
    800059c8:	b7b9                	j	80005916 <sys_open+0xe4>

00000000800059ca <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059ca:	7175                	addi	sp,sp,-144
    800059cc:	e506                	sd	ra,136(sp)
    800059ce:	e122                	sd	s0,128(sp)
    800059d0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	890080e7          	jalr	-1904(ra) # 80004262 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059da:	08000613          	li	a2,128
    800059de:	f7040593          	addi	a1,s0,-144
    800059e2:	4501                	li	a0,0
    800059e4:	ffffd097          	auipc	ra,0xffffd
    800059e8:	2aa080e7          	jalr	682(ra) # 80002c8e <argstr>
    800059ec:	02054963          	bltz	a0,80005a1e <sys_mkdir+0x54>
    800059f0:	4681                	li	a3,0
    800059f2:	4601                	li	a2,0
    800059f4:	4585                	li	a1,1
    800059f6:	f7040513          	addi	a0,s0,-144
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	7fe080e7          	jalr	2046(ra) # 800051f8 <create>
    80005a02:	cd11                	beqz	a0,80005a1e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	0fe080e7          	jalr	254(ra) # 80003b02 <iunlockput>
  end_op();
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	8d6080e7          	jalr	-1834(ra) # 800042e2 <end_op>
  return 0;
    80005a14:	4501                	li	a0,0
}
    80005a16:	60aa                	ld	ra,136(sp)
    80005a18:	640a                	ld	s0,128(sp)
    80005a1a:	6149                	addi	sp,sp,144
    80005a1c:	8082                	ret
    end_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	8c4080e7          	jalr	-1852(ra) # 800042e2 <end_op>
    return -1;
    80005a26:	557d                	li	a0,-1
    80005a28:	b7fd                	j	80005a16 <sys_mkdir+0x4c>

0000000080005a2a <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a2a:	7135                	addi	sp,sp,-160
    80005a2c:	ed06                	sd	ra,152(sp)
    80005a2e:	e922                	sd	s0,144(sp)
    80005a30:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	830080e7          	jalr	-2000(ra) # 80004262 <begin_op>
  argint(1, &major);
    80005a3a:	f6c40593          	addi	a1,s0,-148
    80005a3e:	4505                	li	a0,1
    80005a40:	ffffd097          	auipc	ra,0xffffd
    80005a44:	20e080e7          	jalr	526(ra) # 80002c4e <argint>
  argint(2, &minor);
    80005a48:	f6840593          	addi	a1,s0,-152
    80005a4c:	4509                	li	a0,2
    80005a4e:	ffffd097          	auipc	ra,0xffffd
    80005a52:	200080e7          	jalr	512(ra) # 80002c4e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a56:	08000613          	li	a2,128
    80005a5a:	f7040593          	addi	a1,s0,-144
    80005a5e:	4501                	li	a0,0
    80005a60:	ffffd097          	auipc	ra,0xffffd
    80005a64:	22e080e7          	jalr	558(ra) # 80002c8e <argstr>
    80005a68:	02054b63          	bltz	a0,80005a9e <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a6c:	f6841683          	lh	a3,-152(s0)
    80005a70:	f6c41603          	lh	a2,-148(s0)
    80005a74:	458d                	li	a1,3
    80005a76:	f7040513          	addi	a0,s0,-144
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	77e080e7          	jalr	1918(ra) # 800051f8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a82:	cd11                	beqz	a0,80005a9e <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	07e080e7          	jalr	126(ra) # 80003b02 <iunlockput>
  end_op();
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	856080e7          	jalr	-1962(ra) # 800042e2 <end_op>
  return 0;
    80005a94:	4501                	li	a0,0
}
    80005a96:	60ea                	ld	ra,152(sp)
    80005a98:	644a                	ld	s0,144(sp)
    80005a9a:	610d                	addi	sp,sp,160
    80005a9c:	8082                	ret
    end_op();
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	844080e7          	jalr	-1980(ra) # 800042e2 <end_op>
    return -1;
    80005aa6:	557d                	li	a0,-1
    80005aa8:	b7fd                	j	80005a96 <sys_mknod+0x6c>

0000000080005aaa <sys_chdir>:

uint64
sys_chdir(void)
{
    80005aaa:	7135                	addi	sp,sp,-160
    80005aac:	ed06                	sd	ra,152(sp)
    80005aae:	e922                	sd	s0,144(sp)
    80005ab0:	e526                	sd	s1,136(sp)
    80005ab2:	e14a                	sd	s2,128(sp)
    80005ab4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ab6:	ffffc097          	auipc	ra,0xffffc
    80005aba:	f1a080e7          	jalr	-230(ra) # 800019d0 <myproc>
    80005abe:	892a                	mv	s2,a0
  
  begin_op();
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	7a2080e7          	jalr	1954(ra) # 80004262 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ac8:	08000613          	li	a2,128
    80005acc:	f6040593          	addi	a1,s0,-160
    80005ad0:	4501                	li	a0,0
    80005ad2:	ffffd097          	auipc	ra,0xffffd
    80005ad6:	1bc080e7          	jalr	444(ra) # 80002c8e <argstr>
    80005ada:	04054b63          	bltz	a0,80005b30 <sys_chdir+0x86>
    80005ade:	f6040513          	addi	a0,s0,-160
    80005ae2:	ffffe097          	auipc	ra,0xffffe
    80005ae6:	564080e7          	jalr	1380(ra) # 80004046 <namei>
    80005aea:	84aa                	mv	s1,a0
    80005aec:	c131                	beqz	a0,80005b30 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005aee:	ffffe097          	auipc	ra,0xffffe
    80005af2:	db2080e7          	jalr	-590(ra) # 800038a0 <ilock>
  if(ip->type != T_DIR){
    80005af6:	04449703          	lh	a4,68(s1)
    80005afa:	4785                	li	a5,1
    80005afc:	04f71063          	bne	a4,a5,80005b3c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b00:	8526                	mv	a0,s1
    80005b02:	ffffe097          	auipc	ra,0xffffe
    80005b06:	e60080e7          	jalr	-416(ra) # 80003962 <iunlock>
  iput(p->cwd);
    80005b0a:	15093503          	ld	a0,336(s2)
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	f4c080e7          	jalr	-180(ra) # 80003a5a <iput>
  end_op();
    80005b16:	ffffe097          	auipc	ra,0xffffe
    80005b1a:	7cc080e7          	jalr	1996(ra) # 800042e2 <end_op>
  p->cwd = ip;
    80005b1e:	14993823          	sd	s1,336(s2)
  return 0;
    80005b22:	4501                	li	a0,0
}
    80005b24:	60ea                	ld	ra,152(sp)
    80005b26:	644a                	ld	s0,144(sp)
    80005b28:	64aa                	ld	s1,136(sp)
    80005b2a:	690a                	ld	s2,128(sp)
    80005b2c:	610d                	addi	sp,sp,160
    80005b2e:	8082                	ret
    end_op();
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	7b2080e7          	jalr	1970(ra) # 800042e2 <end_op>
    return -1;
    80005b38:	557d                	li	a0,-1
    80005b3a:	b7ed                	j	80005b24 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b3c:	8526                	mv	a0,s1
    80005b3e:	ffffe097          	auipc	ra,0xffffe
    80005b42:	fc4080e7          	jalr	-60(ra) # 80003b02 <iunlockput>
    end_op();
    80005b46:	ffffe097          	auipc	ra,0xffffe
    80005b4a:	79c080e7          	jalr	1948(ra) # 800042e2 <end_op>
    return -1;
    80005b4e:	557d                	li	a0,-1
    80005b50:	bfd1                	j	80005b24 <sys_chdir+0x7a>

0000000080005b52 <sys_exec>:

uint64
sys_exec(void)
{
    80005b52:	7145                	addi	sp,sp,-464
    80005b54:	e786                	sd	ra,456(sp)
    80005b56:	e3a2                	sd	s0,448(sp)
    80005b58:	ff26                	sd	s1,440(sp)
    80005b5a:	fb4a                	sd	s2,432(sp)
    80005b5c:	f74e                	sd	s3,424(sp)
    80005b5e:	f352                	sd	s4,416(sp)
    80005b60:	ef56                	sd	s5,408(sp)
    80005b62:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005b64:	e3840593          	addi	a1,s0,-456
    80005b68:	4505                	li	a0,1
    80005b6a:	ffffd097          	auipc	ra,0xffffd
    80005b6e:	104080e7          	jalr	260(ra) # 80002c6e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005b72:	08000613          	li	a2,128
    80005b76:	f4040593          	addi	a1,s0,-192
    80005b7a:	4501                	li	a0,0
    80005b7c:	ffffd097          	auipc	ra,0xffffd
    80005b80:	112080e7          	jalr	274(ra) # 80002c8e <argstr>
    80005b84:	87aa                	mv	a5,a0
    return -1;
    80005b86:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b88:	0c07c263          	bltz	a5,80005c4c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005b8c:	10000613          	li	a2,256
    80005b90:	4581                	li	a1,0
    80005b92:	e4040513          	addi	a0,s0,-448
    80005b96:	ffffb097          	auipc	ra,0xffffb
    80005b9a:	150080e7          	jalr	336(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b9e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ba2:	89a6                	mv	s3,s1
    80005ba4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ba6:	02000a13          	li	s4,32
    80005baa:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005bae:	00391513          	slli	a0,s2,0x3
    80005bb2:	e3040593          	addi	a1,s0,-464
    80005bb6:	e3843783          	ld	a5,-456(s0)
    80005bba:	953e                	add	a0,a0,a5
    80005bbc:	ffffd097          	auipc	ra,0xffffd
    80005bc0:	ff4080e7          	jalr	-12(ra) # 80002bb0 <fetchaddr>
    80005bc4:	02054a63          	bltz	a0,80005bf8 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005bc8:	e3043783          	ld	a5,-464(s0)
    80005bcc:	c3b9                	beqz	a5,80005c12 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005bce:	ffffb097          	auipc	ra,0xffffb
    80005bd2:	f2c080e7          	jalr	-212(ra) # 80000afa <kalloc>
    80005bd6:	85aa                	mv	a1,a0
    80005bd8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005bdc:	cd11                	beqz	a0,80005bf8 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005bde:	6605                	lui	a2,0x1
    80005be0:	e3043503          	ld	a0,-464(s0)
    80005be4:	ffffd097          	auipc	ra,0xffffd
    80005be8:	01e080e7          	jalr	30(ra) # 80002c02 <fetchstr>
    80005bec:	00054663          	bltz	a0,80005bf8 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005bf0:	0905                	addi	s2,s2,1
    80005bf2:	09a1                	addi	s3,s3,8
    80005bf4:	fb491be3          	bne	s2,s4,80005baa <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bf8:	10048913          	addi	s2,s1,256
    80005bfc:	6088                	ld	a0,0(s1)
    80005bfe:	c531                	beqz	a0,80005c4a <sys_exec+0xf8>
    kfree(argv[i]);
    80005c00:	ffffb097          	auipc	ra,0xffffb
    80005c04:	dfe080e7          	jalr	-514(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c08:	04a1                	addi	s1,s1,8
    80005c0a:	ff2499e3          	bne	s1,s2,80005bfc <sys_exec+0xaa>
  return -1;
    80005c0e:	557d                	li	a0,-1
    80005c10:	a835                	j	80005c4c <sys_exec+0xfa>
      argv[i] = 0;
    80005c12:	0a8e                	slli	s5,s5,0x3
    80005c14:	fc040793          	addi	a5,s0,-64
    80005c18:	9abe                	add	s5,s5,a5
    80005c1a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c1e:	e4040593          	addi	a1,s0,-448
    80005c22:	f4040513          	addi	a0,s0,-192
    80005c26:	fffff097          	auipc	ra,0xfffff
    80005c2a:	190080e7          	jalr	400(ra) # 80004db6 <exec>
    80005c2e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c30:	10048993          	addi	s3,s1,256
    80005c34:	6088                	ld	a0,0(s1)
    80005c36:	c901                	beqz	a0,80005c46 <sys_exec+0xf4>
    kfree(argv[i]);
    80005c38:	ffffb097          	auipc	ra,0xffffb
    80005c3c:	dc6080e7          	jalr	-570(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c40:	04a1                	addi	s1,s1,8
    80005c42:	ff3499e3          	bne	s1,s3,80005c34 <sys_exec+0xe2>
  return ret;
    80005c46:	854a                	mv	a0,s2
    80005c48:	a011                	j	80005c4c <sys_exec+0xfa>
  return -1;
    80005c4a:	557d                	li	a0,-1
}
    80005c4c:	60be                	ld	ra,456(sp)
    80005c4e:	641e                	ld	s0,448(sp)
    80005c50:	74fa                	ld	s1,440(sp)
    80005c52:	795a                	ld	s2,432(sp)
    80005c54:	79ba                	ld	s3,424(sp)
    80005c56:	7a1a                	ld	s4,416(sp)
    80005c58:	6afa                	ld	s5,408(sp)
    80005c5a:	6179                	addi	sp,sp,464
    80005c5c:	8082                	ret

0000000080005c5e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005c5e:	7139                	addi	sp,sp,-64
    80005c60:	fc06                	sd	ra,56(sp)
    80005c62:	f822                	sd	s0,48(sp)
    80005c64:	f426                	sd	s1,40(sp)
    80005c66:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005c68:	ffffc097          	auipc	ra,0xffffc
    80005c6c:	d68080e7          	jalr	-664(ra) # 800019d0 <myproc>
    80005c70:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005c72:	fd840593          	addi	a1,s0,-40
    80005c76:	4501                	li	a0,0
    80005c78:	ffffd097          	auipc	ra,0xffffd
    80005c7c:	ff6080e7          	jalr	-10(ra) # 80002c6e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c80:	fc840593          	addi	a1,s0,-56
    80005c84:	fd040513          	addi	a0,s0,-48
    80005c88:	fffff097          	auipc	ra,0xfffff
    80005c8c:	dd6080e7          	jalr	-554(ra) # 80004a5e <pipealloc>
    return -1;
    80005c90:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c92:	0c054463          	bltz	a0,80005d5a <sys_pipe+0xfc>
  fd0 = -1;
    80005c96:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c9a:	fd043503          	ld	a0,-48(s0)
    80005c9e:	fffff097          	auipc	ra,0xfffff
    80005ca2:	518080e7          	jalr	1304(ra) # 800051b6 <fdalloc>
    80005ca6:	fca42223          	sw	a0,-60(s0)
    80005caa:	08054b63          	bltz	a0,80005d40 <sys_pipe+0xe2>
    80005cae:	fc843503          	ld	a0,-56(s0)
    80005cb2:	fffff097          	auipc	ra,0xfffff
    80005cb6:	504080e7          	jalr	1284(ra) # 800051b6 <fdalloc>
    80005cba:	fca42023          	sw	a0,-64(s0)
    80005cbe:	06054863          	bltz	a0,80005d2e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cc2:	4691                	li	a3,4
    80005cc4:	fc440613          	addi	a2,s0,-60
    80005cc8:	fd843583          	ld	a1,-40(s0)
    80005ccc:	68a8                	ld	a0,80(s1)
    80005cce:	ffffc097          	auipc	ra,0xffffc
    80005cd2:	9b6080e7          	jalr	-1610(ra) # 80001684 <copyout>
    80005cd6:	02054063          	bltz	a0,80005cf6 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005cda:	4691                	li	a3,4
    80005cdc:	fc040613          	addi	a2,s0,-64
    80005ce0:	fd843583          	ld	a1,-40(s0)
    80005ce4:	0591                	addi	a1,a1,4
    80005ce6:	68a8                	ld	a0,80(s1)
    80005ce8:	ffffc097          	auipc	ra,0xffffc
    80005cec:	99c080e7          	jalr	-1636(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005cf0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005cf2:	06055463          	bgez	a0,80005d5a <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005cf6:	fc442783          	lw	a5,-60(s0)
    80005cfa:	07e9                	addi	a5,a5,26
    80005cfc:	078e                	slli	a5,a5,0x3
    80005cfe:	97a6                	add	a5,a5,s1
    80005d00:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d04:	fc042503          	lw	a0,-64(s0)
    80005d08:	0569                	addi	a0,a0,26
    80005d0a:	050e                	slli	a0,a0,0x3
    80005d0c:	94aa                	add	s1,s1,a0
    80005d0e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d12:	fd043503          	ld	a0,-48(s0)
    80005d16:	fffff097          	auipc	ra,0xfffff
    80005d1a:	a18080e7          	jalr	-1512(ra) # 8000472e <fileclose>
    fileclose(wf);
    80005d1e:	fc843503          	ld	a0,-56(s0)
    80005d22:	fffff097          	auipc	ra,0xfffff
    80005d26:	a0c080e7          	jalr	-1524(ra) # 8000472e <fileclose>
    return -1;
    80005d2a:	57fd                	li	a5,-1
    80005d2c:	a03d                	j	80005d5a <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005d2e:	fc442783          	lw	a5,-60(s0)
    80005d32:	0007c763          	bltz	a5,80005d40 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005d36:	07e9                	addi	a5,a5,26
    80005d38:	078e                	slli	a5,a5,0x3
    80005d3a:	94be                	add	s1,s1,a5
    80005d3c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d40:	fd043503          	ld	a0,-48(s0)
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	9ea080e7          	jalr	-1558(ra) # 8000472e <fileclose>
    fileclose(wf);
    80005d4c:	fc843503          	ld	a0,-56(s0)
    80005d50:	fffff097          	auipc	ra,0xfffff
    80005d54:	9de080e7          	jalr	-1570(ra) # 8000472e <fileclose>
    return -1;
    80005d58:	57fd                	li	a5,-1
}
    80005d5a:	853e                	mv	a0,a5
    80005d5c:	70e2                	ld	ra,56(sp)
    80005d5e:	7442                	ld	s0,48(sp)
    80005d60:	74a2                	ld	s1,40(sp)
    80005d62:	6121                	addi	sp,sp,64
    80005d64:	8082                	ret
	...

0000000080005d70 <kernelvec>:
    80005d70:	7111                	addi	sp,sp,-256
    80005d72:	e006                	sd	ra,0(sp)
    80005d74:	e40a                	sd	sp,8(sp)
    80005d76:	e80e                	sd	gp,16(sp)
    80005d78:	ec12                	sd	tp,24(sp)
    80005d7a:	f016                	sd	t0,32(sp)
    80005d7c:	f41a                	sd	t1,40(sp)
    80005d7e:	f81e                	sd	t2,48(sp)
    80005d80:	fc22                	sd	s0,56(sp)
    80005d82:	e0a6                	sd	s1,64(sp)
    80005d84:	e4aa                	sd	a0,72(sp)
    80005d86:	e8ae                	sd	a1,80(sp)
    80005d88:	ecb2                	sd	a2,88(sp)
    80005d8a:	f0b6                	sd	a3,96(sp)
    80005d8c:	f4ba                	sd	a4,104(sp)
    80005d8e:	f8be                	sd	a5,112(sp)
    80005d90:	fcc2                	sd	a6,120(sp)
    80005d92:	e146                	sd	a7,128(sp)
    80005d94:	e54a                	sd	s2,136(sp)
    80005d96:	e94e                	sd	s3,144(sp)
    80005d98:	ed52                	sd	s4,152(sp)
    80005d9a:	f156                	sd	s5,160(sp)
    80005d9c:	f55a                	sd	s6,168(sp)
    80005d9e:	f95e                	sd	s7,176(sp)
    80005da0:	fd62                	sd	s8,184(sp)
    80005da2:	e1e6                	sd	s9,192(sp)
    80005da4:	e5ea                	sd	s10,200(sp)
    80005da6:	e9ee                	sd	s11,208(sp)
    80005da8:	edf2                	sd	t3,216(sp)
    80005daa:	f1f6                	sd	t4,224(sp)
    80005dac:	f5fa                	sd	t5,232(sp)
    80005dae:	f9fe                	sd	t6,240(sp)
    80005db0:	ccdfc0ef          	jal	ra,80002a7c <kerneltrap>
    80005db4:	6082                	ld	ra,0(sp)
    80005db6:	6122                	ld	sp,8(sp)
    80005db8:	61c2                	ld	gp,16(sp)
    80005dba:	7282                	ld	t0,32(sp)
    80005dbc:	7322                	ld	t1,40(sp)
    80005dbe:	73c2                	ld	t2,48(sp)
    80005dc0:	7462                	ld	s0,56(sp)
    80005dc2:	6486                	ld	s1,64(sp)
    80005dc4:	6526                	ld	a0,72(sp)
    80005dc6:	65c6                	ld	a1,80(sp)
    80005dc8:	6666                	ld	a2,88(sp)
    80005dca:	7686                	ld	a3,96(sp)
    80005dcc:	7726                	ld	a4,104(sp)
    80005dce:	77c6                	ld	a5,112(sp)
    80005dd0:	7866                	ld	a6,120(sp)
    80005dd2:	688a                	ld	a7,128(sp)
    80005dd4:	692a                	ld	s2,136(sp)
    80005dd6:	69ca                	ld	s3,144(sp)
    80005dd8:	6a6a                	ld	s4,152(sp)
    80005dda:	7a8a                	ld	s5,160(sp)
    80005ddc:	7b2a                	ld	s6,168(sp)
    80005dde:	7bca                	ld	s7,176(sp)
    80005de0:	7c6a                	ld	s8,184(sp)
    80005de2:	6c8e                	ld	s9,192(sp)
    80005de4:	6d2e                	ld	s10,200(sp)
    80005de6:	6dce                	ld	s11,208(sp)
    80005de8:	6e6e                	ld	t3,216(sp)
    80005dea:	7e8e                	ld	t4,224(sp)
    80005dec:	7f2e                	ld	t5,232(sp)
    80005dee:	7fce                	ld	t6,240(sp)
    80005df0:	6111                	addi	sp,sp,256
    80005df2:	10200073          	sret
    80005df6:	00000013          	nop
    80005dfa:	00000013          	nop
    80005dfe:	0001                	nop

0000000080005e00 <timervec>:
    80005e00:	34051573          	csrrw	a0,mscratch,a0
    80005e04:	e10c                	sd	a1,0(a0)
    80005e06:	e510                	sd	a2,8(a0)
    80005e08:	e914                	sd	a3,16(a0)
    80005e0a:	6d0c                	ld	a1,24(a0)
    80005e0c:	7110                	ld	a2,32(a0)
    80005e0e:	6194                	ld	a3,0(a1)
    80005e10:	96b2                	add	a3,a3,a2
    80005e12:	e194                	sd	a3,0(a1)
    80005e14:	4589                	li	a1,2
    80005e16:	14459073          	csrw	sip,a1
    80005e1a:	6914                	ld	a3,16(a0)
    80005e1c:	6510                	ld	a2,8(a0)
    80005e1e:	610c                	ld	a1,0(a0)
    80005e20:	34051573          	csrrw	a0,mscratch,a0
    80005e24:	30200073          	mret
	...

0000000080005e2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e2a:	1141                	addi	sp,sp,-16
    80005e2c:	e422                	sd	s0,8(sp)
    80005e2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e30:	0c0007b7          	lui	a5,0xc000
    80005e34:	4705                	li	a4,1
    80005e36:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e38:	c3d8                	sw	a4,4(a5)
}
    80005e3a:	6422                	ld	s0,8(sp)
    80005e3c:	0141                	addi	sp,sp,16
    80005e3e:	8082                	ret

0000000080005e40 <plicinithart>:

void
plicinithart(void)
{
    80005e40:	1141                	addi	sp,sp,-16
    80005e42:	e406                	sd	ra,8(sp)
    80005e44:	e022                	sd	s0,0(sp)
    80005e46:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e48:	ffffc097          	auipc	ra,0xffffc
    80005e4c:	b5c080e7          	jalr	-1188(ra) # 800019a4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e50:	0085171b          	slliw	a4,a0,0x8
    80005e54:	0c0027b7          	lui	a5,0xc002
    80005e58:	97ba                	add	a5,a5,a4
    80005e5a:	40200713          	li	a4,1026
    80005e5e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e62:	00d5151b          	slliw	a0,a0,0xd
    80005e66:	0c2017b7          	lui	a5,0xc201
    80005e6a:	953e                	add	a0,a0,a5
    80005e6c:	00052023          	sw	zero,0(a0)
}
    80005e70:	60a2                	ld	ra,8(sp)
    80005e72:	6402                	ld	s0,0(sp)
    80005e74:	0141                	addi	sp,sp,16
    80005e76:	8082                	ret

0000000080005e78 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e78:	1141                	addi	sp,sp,-16
    80005e7a:	e406                	sd	ra,8(sp)
    80005e7c:	e022                	sd	s0,0(sp)
    80005e7e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e80:	ffffc097          	auipc	ra,0xffffc
    80005e84:	b24080e7          	jalr	-1244(ra) # 800019a4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e88:	00d5179b          	slliw	a5,a0,0xd
    80005e8c:	0c201537          	lui	a0,0xc201
    80005e90:	953e                	add	a0,a0,a5
  return irq;
}
    80005e92:	4148                	lw	a0,4(a0)
    80005e94:	60a2                	ld	ra,8(sp)
    80005e96:	6402                	ld	s0,0(sp)
    80005e98:	0141                	addi	sp,sp,16
    80005e9a:	8082                	ret

0000000080005e9c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e9c:	1101                	addi	sp,sp,-32
    80005e9e:	ec06                	sd	ra,24(sp)
    80005ea0:	e822                	sd	s0,16(sp)
    80005ea2:	e426                	sd	s1,8(sp)
    80005ea4:	1000                	addi	s0,sp,32
    80005ea6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ea8:	ffffc097          	auipc	ra,0xffffc
    80005eac:	afc080e7          	jalr	-1284(ra) # 800019a4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005eb0:	00d5151b          	slliw	a0,a0,0xd
    80005eb4:	0c2017b7          	lui	a5,0xc201
    80005eb8:	97aa                	add	a5,a5,a0
    80005eba:	c3c4                	sw	s1,4(a5)
}
    80005ebc:	60e2                	ld	ra,24(sp)
    80005ebe:	6442                	ld	s0,16(sp)
    80005ec0:	64a2                	ld	s1,8(sp)
    80005ec2:	6105                	addi	sp,sp,32
    80005ec4:	8082                	ret

0000000080005ec6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005ec6:	1141                	addi	sp,sp,-16
    80005ec8:	e406                	sd	ra,8(sp)
    80005eca:	e022                	sd	s0,0(sp)
    80005ecc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005ece:	479d                	li	a5,7
    80005ed0:	04a7cc63          	blt	a5,a0,80005f28 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005ed4:	0001c797          	auipc	a5,0x1c
    80005ed8:	d5c78793          	addi	a5,a5,-676 # 80021c30 <disk>
    80005edc:	97aa                	add	a5,a5,a0
    80005ede:	0187c783          	lbu	a5,24(a5)
    80005ee2:	ebb9                	bnez	a5,80005f38 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ee4:	00451613          	slli	a2,a0,0x4
    80005ee8:	0001c797          	auipc	a5,0x1c
    80005eec:	d4878793          	addi	a5,a5,-696 # 80021c30 <disk>
    80005ef0:	6394                	ld	a3,0(a5)
    80005ef2:	96b2                	add	a3,a3,a2
    80005ef4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005ef8:	6398                	ld	a4,0(a5)
    80005efa:	9732                	add	a4,a4,a2
    80005efc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f00:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f04:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f08:	953e                	add	a0,a0,a5
    80005f0a:	4785                	li	a5,1
    80005f0c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005f10:	0001c517          	auipc	a0,0x1c
    80005f14:	d3850513          	addi	a0,a0,-712 # 80021c48 <disk+0x18>
    80005f18:	ffffc097          	auipc	ra,0xffffc
    80005f1c:	20a080e7          	jalr	522(ra) # 80002122 <wakeup>
}
    80005f20:	60a2                	ld	ra,8(sp)
    80005f22:	6402                	ld	s0,0(sp)
    80005f24:	0141                	addi	sp,sp,16
    80005f26:	8082                	ret
    panic("free_desc 1");
    80005f28:	00003517          	auipc	a0,0x3
    80005f2c:	82850513          	addi	a0,a0,-2008 # 80008750 <syscalls+0x300>
    80005f30:	ffffa097          	auipc	ra,0xffffa
    80005f34:	614080e7          	jalr	1556(ra) # 80000544 <panic>
    panic("free_desc 2");
    80005f38:	00003517          	auipc	a0,0x3
    80005f3c:	82850513          	addi	a0,a0,-2008 # 80008760 <syscalls+0x310>
    80005f40:	ffffa097          	auipc	ra,0xffffa
    80005f44:	604080e7          	jalr	1540(ra) # 80000544 <panic>

0000000080005f48 <virtio_disk_init>:
{
    80005f48:	1101                	addi	sp,sp,-32
    80005f4a:	ec06                	sd	ra,24(sp)
    80005f4c:	e822                	sd	s0,16(sp)
    80005f4e:	e426                	sd	s1,8(sp)
    80005f50:	e04a                	sd	s2,0(sp)
    80005f52:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005f54:	00003597          	auipc	a1,0x3
    80005f58:	81c58593          	addi	a1,a1,-2020 # 80008770 <syscalls+0x320>
    80005f5c:	0001c517          	auipc	a0,0x1c
    80005f60:	dfc50513          	addi	a0,a0,-516 # 80021d58 <disk+0x128>
    80005f64:	ffffb097          	auipc	ra,0xffffb
    80005f68:	bf6080e7          	jalr	-1034(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f6c:	100017b7          	lui	a5,0x10001
    80005f70:	4398                	lw	a4,0(a5)
    80005f72:	2701                	sext.w	a4,a4
    80005f74:	747277b7          	lui	a5,0x74727
    80005f78:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f7c:	14f71e63          	bne	a4,a5,800060d8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f80:	100017b7          	lui	a5,0x10001
    80005f84:	43dc                	lw	a5,4(a5)
    80005f86:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f88:	4709                	li	a4,2
    80005f8a:	14e79763          	bne	a5,a4,800060d8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f8e:	100017b7          	lui	a5,0x10001
    80005f92:	479c                	lw	a5,8(a5)
    80005f94:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f96:	14e79163          	bne	a5,a4,800060d8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f9a:	100017b7          	lui	a5,0x10001
    80005f9e:	47d8                	lw	a4,12(a5)
    80005fa0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fa2:	554d47b7          	lui	a5,0x554d4
    80005fa6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005faa:	12f71763          	bne	a4,a5,800060d8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fae:	100017b7          	lui	a5,0x10001
    80005fb2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fb6:	4705                	li	a4,1
    80005fb8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fba:	470d                	li	a4,3
    80005fbc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005fbe:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005fc0:	c7ffe737          	lui	a4,0xc7ffe
    80005fc4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9ef>
    80005fc8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005fca:	2701                	sext.w	a4,a4
    80005fcc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fce:	472d                	li	a4,11
    80005fd0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005fd2:	0707a903          	lw	s2,112(a5)
    80005fd6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005fd8:	00897793          	andi	a5,s2,8
    80005fdc:	10078663          	beqz	a5,800060e8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005fe0:	100017b7          	lui	a5,0x10001
    80005fe4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005fe8:	43fc                	lw	a5,68(a5)
    80005fea:	2781                	sext.w	a5,a5
    80005fec:	10079663          	bnez	a5,800060f8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ff0:	100017b7          	lui	a5,0x10001
    80005ff4:	5bdc                	lw	a5,52(a5)
    80005ff6:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ff8:	10078863          	beqz	a5,80006108 <virtio_disk_init+0x1c0>
  if(max < NUM)
    80005ffc:	471d                	li	a4,7
    80005ffe:	10f77d63          	bgeu	a4,a5,80006118 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006002:	ffffb097          	auipc	ra,0xffffb
    80006006:	af8080e7          	jalr	-1288(ra) # 80000afa <kalloc>
    8000600a:	0001c497          	auipc	s1,0x1c
    8000600e:	c2648493          	addi	s1,s1,-986 # 80021c30 <disk>
    80006012:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006014:	ffffb097          	auipc	ra,0xffffb
    80006018:	ae6080e7          	jalr	-1306(ra) # 80000afa <kalloc>
    8000601c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000601e:	ffffb097          	auipc	ra,0xffffb
    80006022:	adc080e7          	jalr	-1316(ra) # 80000afa <kalloc>
    80006026:	87aa                	mv	a5,a0
    80006028:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000602a:	6088                	ld	a0,0(s1)
    8000602c:	cd75                	beqz	a0,80006128 <virtio_disk_init+0x1e0>
    8000602e:	0001c717          	auipc	a4,0x1c
    80006032:	c0a73703          	ld	a4,-1014(a4) # 80021c38 <disk+0x8>
    80006036:	cb6d                	beqz	a4,80006128 <virtio_disk_init+0x1e0>
    80006038:	cbe5                	beqz	a5,80006128 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000603a:	6605                	lui	a2,0x1
    8000603c:	4581                	li	a1,0
    8000603e:	ffffb097          	auipc	ra,0xffffb
    80006042:	ca8080e7          	jalr	-856(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006046:	0001c497          	auipc	s1,0x1c
    8000604a:	bea48493          	addi	s1,s1,-1046 # 80021c30 <disk>
    8000604e:	6605                	lui	a2,0x1
    80006050:	4581                	li	a1,0
    80006052:	6488                	ld	a0,8(s1)
    80006054:	ffffb097          	auipc	ra,0xffffb
    80006058:	c92080e7          	jalr	-878(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000605c:	6605                	lui	a2,0x1
    8000605e:	4581                	li	a1,0
    80006060:	6888                	ld	a0,16(s1)
    80006062:	ffffb097          	auipc	ra,0xffffb
    80006066:	c84080e7          	jalr	-892(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000606a:	100017b7          	lui	a5,0x10001
    8000606e:	4721                	li	a4,8
    80006070:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006072:	4098                	lw	a4,0(s1)
    80006074:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006078:	40d8                	lw	a4,4(s1)
    8000607a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000607e:	6498                	ld	a4,8(s1)
    80006080:	0007069b          	sext.w	a3,a4
    80006084:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006088:	9701                	srai	a4,a4,0x20
    8000608a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000608e:	6898                	ld	a4,16(s1)
    80006090:	0007069b          	sext.w	a3,a4
    80006094:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006098:	9701                	srai	a4,a4,0x20
    8000609a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000609e:	4685                	li	a3,1
    800060a0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800060a2:	4705                	li	a4,1
    800060a4:	00d48c23          	sb	a3,24(s1)
    800060a8:	00e48ca3          	sb	a4,25(s1)
    800060ac:	00e48d23          	sb	a4,26(s1)
    800060b0:	00e48da3          	sb	a4,27(s1)
    800060b4:	00e48e23          	sb	a4,28(s1)
    800060b8:	00e48ea3          	sb	a4,29(s1)
    800060bc:	00e48f23          	sb	a4,30(s1)
    800060c0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800060c4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800060c8:	0727a823          	sw	s2,112(a5)
}
    800060cc:	60e2                	ld	ra,24(sp)
    800060ce:	6442                	ld	s0,16(sp)
    800060d0:	64a2                	ld	s1,8(sp)
    800060d2:	6902                	ld	s2,0(sp)
    800060d4:	6105                	addi	sp,sp,32
    800060d6:	8082                	ret
    panic("could not find virtio disk");
    800060d8:	00002517          	auipc	a0,0x2
    800060dc:	6a850513          	addi	a0,a0,1704 # 80008780 <syscalls+0x330>
    800060e0:	ffffa097          	auipc	ra,0xffffa
    800060e4:	464080e7          	jalr	1124(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	6b850513          	addi	a0,a0,1720 # 800087a0 <syscalls+0x350>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	454080e7          	jalr	1108(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800060f8:	00002517          	auipc	a0,0x2
    800060fc:	6c850513          	addi	a0,a0,1736 # 800087c0 <syscalls+0x370>
    80006100:	ffffa097          	auipc	ra,0xffffa
    80006104:	444080e7          	jalr	1092(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006108:	00002517          	auipc	a0,0x2
    8000610c:	6d850513          	addi	a0,a0,1752 # 800087e0 <syscalls+0x390>
    80006110:	ffffa097          	auipc	ra,0xffffa
    80006114:	434080e7          	jalr	1076(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006118:	00002517          	auipc	a0,0x2
    8000611c:	6e850513          	addi	a0,a0,1768 # 80008800 <syscalls+0x3b0>
    80006120:	ffffa097          	auipc	ra,0xffffa
    80006124:	424080e7          	jalr	1060(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006128:	00002517          	auipc	a0,0x2
    8000612c:	6f850513          	addi	a0,a0,1784 # 80008820 <syscalls+0x3d0>
    80006130:	ffffa097          	auipc	ra,0xffffa
    80006134:	414080e7          	jalr	1044(ra) # 80000544 <panic>

0000000080006138 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006138:	7159                	addi	sp,sp,-112
    8000613a:	f486                	sd	ra,104(sp)
    8000613c:	f0a2                	sd	s0,96(sp)
    8000613e:	eca6                	sd	s1,88(sp)
    80006140:	e8ca                	sd	s2,80(sp)
    80006142:	e4ce                	sd	s3,72(sp)
    80006144:	e0d2                	sd	s4,64(sp)
    80006146:	fc56                	sd	s5,56(sp)
    80006148:	f85a                	sd	s6,48(sp)
    8000614a:	f45e                	sd	s7,40(sp)
    8000614c:	f062                	sd	s8,32(sp)
    8000614e:	ec66                	sd	s9,24(sp)
    80006150:	e86a                	sd	s10,16(sp)
    80006152:	1880                	addi	s0,sp,112
    80006154:	892a                	mv	s2,a0
    80006156:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006158:	00c52c83          	lw	s9,12(a0)
    8000615c:	001c9c9b          	slliw	s9,s9,0x1
    80006160:	1c82                	slli	s9,s9,0x20
    80006162:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006166:	0001c517          	auipc	a0,0x1c
    8000616a:	bf250513          	addi	a0,a0,-1038 # 80021d58 <disk+0x128>
    8000616e:	ffffb097          	auipc	ra,0xffffb
    80006172:	a7c080e7          	jalr	-1412(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006176:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006178:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000617a:	0001cb17          	auipc	s6,0x1c
    8000617e:	ab6b0b13          	addi	s6,s6,-1354 # 80021c30 <disk>
  for(int i = 0; i < 3; i++){
    80006182:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006184:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006186:	0001cc17          	auipc	s8,0x1c
    8000618a:	bd2c0c13          	addi	s8,s8,-1070 # 80021d58 <disk+0x128>
    8000618e:	a8b5                	j	8000620a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006190:	00fb06b3          	add	a3,s6,a5
    80006194:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006198:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000619a:	0207c563          	bltz	a5,800061c4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000619e:	2485                	addiw	s1,s1,1
    800061a0:	0711                	addi	a4,a4,4
    800061a2:	1f548a63          	beq	s1,s5,80006396 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800061a6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800061a8:	0001c697          	auipc	a3,0x1c
    800061ac:	a8868693          	addi	a3,a3,-1400 # 80021c30 <disk>
    800061b0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800061b2:	0186c583          	lbu	a1,24(a3)
    800061b6:	fde9                	bnez	a1,80006190 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800061b8:	2785                	addiw	a5,a5,1
    800061ba:	0685                	addi	a3,a3,1
    800061bc:	ff779be3          	bne	a5,s7,800061b2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800061c0:	57fd                	li	a5,-1
    800061c2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800061c4:	02905a63          	blez	s1,800061f8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061c8:	f9042503          	lw	a0,-112(s0)
    800061cc:	00000097          	auipc	ra,0x0
    800061d0:	cfa080e7          	jalr	-774(ra) # 80005ec6 <free_desc>
      for(int j = 0; j < i; j++)
    800061d4:	4785                	li	a5,1
    800061d6:	0297d163          	bge	a5,s1,800061f8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061da:	f9442503          	lw	a0,-108(s0)
    800061de:	00000097          	auipc	ra,0x0
    800061e2:	ce8080e7          	jalr	-792(ra) # 80005ec6 <free_desc>
      for(int j = 0; j < i; j++)
    800061e6:	4789                	li	a5,2
    800061e8:	0097d863          	bge	a5,s1,800061f8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800061ec:	f9842503          	lw	a0,-104(s0)
    800061f0:	00000097          	auipc	ra,0x0
    800061f4:	cd6080e7          	jalr	-810(ra) # 80005ec6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061f8:	85e2                	mv	a1,s8
    800061fa:	0001c517          	auipc	a0,0x1c
    800061fe:	a4e50513          	addi	a0,a0,-1458 # 80021c48 <disk+0x18>
    80006202:	ffffc097          	auipc	ra,0xffffc
    80006206:	ebc080e7          	jalr	-324(ra) # 800020be <sleep>
  for(int i = 0; i < 3; i++){
    8000620a:	f9040713          	addi	a4,s0,-112
    8000620e:	84ce                	mv	s1,s3
    80006210:	bf59                	j	800061a6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006212:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006216:	00479693          	slli	a3,a5,0x4
    8000621a:	0001c797          	auipc	a5,0x1c
    8000621e:	a1678793          	addi	a5,a5,-1514 # 80021c30 <disk>
    80006222:	97b6                	add	a5,a5,a3
    80006224:	4685                	li	a3,1
    80006226:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006228:	0001c597          	auipc	a1,0x1c
    8000622c:	a0858593          	addi	a1,a1,-1528 # 80021c30 <disk>
    80006230:	00a60793          	addi	a5,a2,10
    80006234:	0792                	slli	a5,a5,0x4
    80006236:	97ae                	add	a5,a5,a1
    80006238:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000623c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006240:	f6070693          	addi	a3,a4,-160
    80006244:	619c                	ld	a5,0(a1)
    80006246:	97b6                	add	a5,a5,a3
    80006248:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000624a:	6188                	ld	a0,0(a1)
    8000624c:	96aa                	add	a3,a3,a0
    8000624e:	47c1                	li	a5,16
    80006250:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006252:	4785                	li	a5,1
    80006254:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006258:	f9442783          	lw	a5,-108(s0)
    8000625c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006260:	0792                	slli	a5,a5,0x4
    80006262:	953e                	add	a0,a0,a5
    80006264:	05890693          	addi	a3,s2,88
    80006268:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000626a:	6188                	ld	a0,0(a1)
    8000626c:	97aa                	add	a5,a5,a0
    8000626e:	40000693          	li	a3,1024
    80006272:	c794                	sw	a3,8(a5)
  if(write)
    80006274:	100d0d63          	beqz	s10,8000638e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006278:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000627c:	00c7d683          	lhu	a3,12(a5)
    80006280:	0016e693          	ori	a3,a3,1
    80006284:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006288:	f9842583          	lw	a1,-104(s0)
    8000628c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006290:	0001c697          	auipc	a3,0x1c
    80006294:	9a068693          	addi	a3,a3,-1632 # 80021c30 <disk>
    80006298:	00260793          	addi	a5,a2,2
    8000629c:	0792                	slli	a5,a5,0x4
    8000629e:	97b6                	add	a5,a5,a3
    800062a0:	587d                	li	a6,-1
    800062a2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062a6:	0592                	slli	a1,a1,0x4
    800062a8:	952e                	add	a0,a0,a1
    800062aa:	f9070713          	addi	a4,a4,-112
    800062ae:	9736                	add	a4,a4,a3
    800062b0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800062b2:	6298                	ld	a4,0(a3)
    800062b4:	972e                	add	a4,a4,a1
    800062b6:	4585                	li	a1,1
    800062b8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062ba:	4509                	li	a0,2
    800062bc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800062c0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062c4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800062c8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800062cc:	6698                	ld	a4,8(a3)
    800062ce:	00275783          	lhu	a5,2(a4)
    800062d2:	8b9d                	andi	a5,a5,7
    800062d4:	0786                	slli	a5,a5,0x1
    800062d6:	97ba                	add	a5,a5,a4
    800062d8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800062dc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800062e0:	6698                	ld	a4,8(a3)
    800062e2:	00275783          	lhu	a5,2(a4)
    800062e6:	2785                	addiw	a5,a5,1
    800062e8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800062ec:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062f0:	100017b7          	lui	a5,0x10001
    800062f4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062f8:	00492703          	lw	a4,4(s2)
    800062fc:	4785                	li	a5,1
    800062fe:	02f71163          	bne	a4,a5,80006320 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006302:	0001c997          	auipc	s3,0x1c
    80006306:	a5698993          	addi	s3,s3,-1450 # 80021d58 <disk+0x128>
  while(b->disk == 1) {
    8000630a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000630c:	85ce                	mv	a1,s3
    8000630e:	854a                	mv	a0,s2
    80006310:	ffffc097          	auipc	ra,0xffffc
    80006314:	dae080e7          	jalr	-594(ra) # 800020be <sleep>
  while(b->disk == 1) {
    80006318:	00492783          	lw	a5,4(s2)
    8000631c:	fe9788e3          	beq	a5,s1,8000630c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006320:	f9042903          	lw	s2,-112(s0)
    80006324:	00290793          	addi	a5,s2,2
    80006328:	00479713          	slli	a4,a5,0x4
    8000632c:	0001c797          	auipc	a5,0x1c
    80006330:	90478793          	addi	a5,a5,-1788 # 80021c30 <disk>
    80006334:	97ba                	add	a5,a5,a4
    80006336:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000633a:	0001c997          	auipc	s3,0x1c
    8000633e:	8f698993          	addi	s3,s3,-1802 # 80021c30 <disk>
    80006342:	00491713          	slli	a4,s2,0x4
    80006346:	0009b783          	ld	a5,0(s3)
    8000634a:	97ba                	add	a5,a5,a4
    8000634c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006350:	854a                	mv	a0,s2
    80006352:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006356:	00000097          	auipc	ra,0x0
    8000635a:	b70080e7          	jalr	-1168(ra) # 80005ec6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000635e:	8885                	andi	s1,s1,1
    80006360:	f0ed                	bnez	s1,80006342 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006362:	0001c517          	auipc	a0,0x1c
    80006366:	9f650513          	addi	a0,a0,-1546 # 80021d58 <disk+0x128>
    8000636a:	ffffb097          	auipc	ra,0xffffb
    8000636e:	934080e7          	jalr	-1740(ra) # 80000c9e <release>
}
    80006372:	70a6                	ld	ra,104(sp)
    80006374:	7406                	ld	s0,96(sp)
    80006376:	64e6                	ld	s1,88(sp)
    80006378:	6946                	ld	s2,80(sp)
    8000637a:	69a6                	ld	s3,72(sp)
    8000637c:	6a06                	ld	s4,64(sp)
    8000637e:	7ae2                	ld	s5,56(sp)
    80006380:	7b42                	ld	s6,48(sp)
    80006382:	7ba2                	ld	s7,40(sp)
    80006384:	7c02                	ld	s8,32(sp)
    80006386:	6ce2                	ld	s9,24(sp)
    80006388:	6d42                	ld	s10,16(sp)
    8000638a:	6165                	addi	sp,sp,112
    8000638c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000638e:	4689                	li	a3,2
    80006390:	00d79623          	sh	a3,12(a5)
    80006394:	b5e5                	j	8000627c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006396:	f9042603          	lw	a2,-112(s0)
    8000639a:	00a60713          	addi	a4,a2,10
    8000639e:	0712                	slli	a4,a4,0x4
    800063a0:	0001c517          	auipc	a0,0x1c
    800063a4:	89850513          	addi	a0,a0,-1896 # 80021c38 <disk+0x8>
    800063a8:	953a                	add	a0,a0,a4
  if(write)
    800063aa:	e60d14e3          	bnez	s10,80006212 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800063ae:	00a60793          	addi	a5,a2,10
    800063b2:	00479693          	slli	a3,a5,0x4
    800063b6:	0001c797          	auipc	a5,0x1c
    800063ba:	87a78793          	addi	a5,a5,-1926 # 80021c30 <disk>
    800063be:	97b6                	add	a5,a5,a3
    800063c0:	0007a423          	sw	zero,8(a5)
    800063c4:	b595                	j	80006228 <virtio_disk_rw+0xf0>

00000000800063c6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063c6:	1101                	addi	sp,sp,-32
    800063c8:	ec06                	sd	ra,24(sp)
    800063ca:	e822                	sd	s0,16(sp)
    800063cc:	e426                	sd	s1,8(sp)
    800063ce:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063d0:	0001c497          	auipc	s1,0x1c
    800063d4:	86048493          	addi	s1,s1,-1952 # 80021c30 <disk>
    800063d8:	0001c517          	auipc	a0,0x1c
    800063dc:	98050513          	addi	a0,a0,-1664 # 80021d58 <disk+0x128>
    800063e0:	ffffb097          	auipc	ra,0xffffb
    800063e4:	80a080e7          	jalr	-2038(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063e8:	10001737          	lui	a4,0x10001
    800063ec:	533c                	lw	a5,96(a4)
    800063ee:	8b8d                	andi	a5,a5,3
    800063f0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800063f2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063f6:	689c                	ld	a5,16(s1)
    800063f8:	0204d703          	lhu	a4,32(s1)
    800063fc:	0027d783          	lhu	a5,2(a5)
    80006400:	04f70863          	beq	a4,a5,80006450 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006404:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006408:	6898                	ld	a4,16(s1)
    8000640a:	0204d783          	lhu	a5,32(s1)
    8000640e:	8b9d                	andi	a5,a5,7
    80006410:	078e                	slli	a5,a5,0x3
    80006412:	97ba                	add	a5,a5,a4
    80006414:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006416:	00278713          	addi	a4,a5,2
    8000641a:	0712                	slli	a4,a4,0x4
    8000641c:	9726                	add	a4,a4,s1
    8000641e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006422:	e721                	bnez	a4,8000646a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006424:	0789                	addi	a5,a5,2
    80006426:	0792                	slli	a5,a5,0x4
    80006428:	97a6                	add	a5,a5,s1
    8000642a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000642c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006430:	ffffc097          	auipc	ra,0xffffc
    80006434:	cf2080e7          	jalr	-782(ra) # 80002122 <wakeup>

    disk.used_idx += 1;
    80006438:	0204d783          	lhu	a5,32(s1)
    8000643c:	2785                	addiw	a5,a5,1
    8000643e:	17c2                	slli	a5,a5,0x30
    80006440:	93c1                	srli	a5,a5,0x30
    80006442:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006446:	6898                	ld	a4,16(s1)
    80006448:	00275703          	lhu	a4,2(a4)
    8000644c:	faf71ce3          	bne	a4,a5,80006404 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006450:	0001c517          	auipc	a0,0x1c
    80006454:	90850513          	addi	a0,a0,-1784 # 80021d58 <disk+0x128>
    80006458:	ffffb097          	auipc	ra,0xffffb
    8000645c:	846080e7          	jalr	-1978(ra) # 80000c9e <release>
}
    80006460:	60e2                	ld	ra,24(sp)
    80006462:	6442                	ld	s0,16(sp)
    80006464:	64a2                	ld	s1,8(sp)
    80006466:	6105                	addi	sp,sp,32
    80006468:	8082                	ret
      panic("virtio_disk_intr status");
    8000646a:	00002517          	auipc	a0,0x2
    8000646e:	3ce50513          	addi	a0,a0,974 # 80008838 <syscalls+0x3e8>
    80006472:	ffffa097          	auipc	ra,0xffffa
    80006476:	0d2080e7          	jalr	210(ra) # 80000544 <panic>
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
