
user/_priotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <useless_calc>:
// {
//   return -1;
// }

uint64 useless_calc(uint64 z, uint64 time)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
  volatile uint64 t = z;  // volatile to not be optimized out
   6:	fea43423          	sd	a0,-24(s0)
  volatile uint64 sum = 0;
   a:	fe043023          	sd	zero,-32(s0)
  for (;;) {
    t += 2;
   e:	fe843783          	ld	a5,-24(s0)
  12:	0789                	addi	a5,a5,2
  14:	fef43423          	sd	a5,-24(s0)
    sum += t;
  18:	fe843703          	ld	a4,-24(s0)
  1c:	fe043783          	ld	a5,-32(s0)
  20:	97ba                	add	a5,a5,a4
  22:	fef43023          	sd	a5,-32(s0)
    t -= 1;
  26:	fe843783          	ld	a5,-24(s0)
  2a:	17fd                	addi	a5,a5,-1
  2c:	fef43423          	sd	a5,-24(s0)
    if (t == time)
  30:	fe843783          	ld	a5,-24(s0)
  34:	fcb79de3          	bne	a5,a1,e <useless_calc+0xe>
      break;
  }
  return sum;
  38:	fe043503          	ld	a0,-32(s0)
}
  3c:	6462                	ld	s0,24(sp)
  3e:	6105                	addi	sp,sp,32
  40:	8082                	ret

0000000000000042 <useless>:

int
useless(int priority, uint64 time)
{
  42:	7179                	addi	sp,sp,-48
  44:	f406                	sd	ra,40(sp)
  46:	f022                	sd	s0,32(sp)
  48:	ec26                	sd	s1,24(sp)
  4a:	e84a                	sd	s2,16(sp)
  4c:	e44e                	sd	s3,8(sp)
  4e:	e052                	sd	s4,0(sp)
  50:	1800                	addi	s0,sp,48
  52:	892a                	mv	s2,a0
  54:	84ae                	mv	s1,a1
  if (setpriority(priority) == -1) {
  56:	00000097          	auipc	ra,0x0
  5a:	4b4080e7          	jalr	1204(ra) # 50a <setpriority>
  5e:	57fd                	li	a5,-1
  60:	06f50163          	beq	a0,a5,c2 <useless+0x80>
    fprintf(2, "setpriority error\n");
  }

  sleep(1);
  64:	4505                	li	a0,1
  66:	00000097          	auipc	ra,0x0
  6a:	494080e7          	jalr	1172(ra) # 4fa <sleep>
  uint64 sum = useless_calc(0, time);
  6e:	85a6                	mv	a1,s1
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	f8e080e7          	jalr	-114(ra) # 0 <useless_calc>
  7a:	89aa                	mv	s3,a0
  char* spent = (time == LARGE_TIME) ? "large" : "small";
  7c:	48d827b7          	lui	a5,0x48d82
  80:	c3678793          	addi	a5,a5,-970 # 48d81c36 <base+0x48d80c26>
  84:	00001a17          	auipc	s4,0x1
  88:	91ca0a13          	addi	s4,s4,-1764 # 9a0 <malloc+0xf0>
  8c:	00f48663          	beq	s1,a5,98 <useless+0x56>
  90:	00001a17          	auipc	s4,0x1
  94:	918a0a13          	addi	s4,s4,-1768 # 9a8 <malloc+0xf8>
  // Need to print uselesss sum to suppress warning.
  printf("Child pid %d, %s, with priority %d finished. Useless sum: %d\n", getpid(), spent,  priority, sum);
  98:	00000097          	auipc	ra,0x0
  9c:	452080e7          	jalr	1106(ra) # 4ea <getpid>
  a0:	85aa                	mv	a1,a0
  a2:	874e                	mv	a4,s3
  a4:	86ca                	mv	a3,s2
  a6:	8652                	mv	a2,s4
  a8:	00001517          	auipc	a0,0x1
  ac:	92050513          	addi	a0,a0,-1760 # 9c8 <malloc+0x118>
  b0:	00000097          	auipc	ra,0x0
  b4:	742080e7          	jalr	1858(ra) # 7f2 <printf>
  exit(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	3b0080e7          	jalr	944(ra) # 46a <exit>
    fprintf(2, "setpriority error\n");
  c2:	00001597          	auipc	a1,0x1
  c6:	8ee58593          	addi	a1,a1,-1810 # 9b0 <malloc+0x100>
  ca:	4509                	li	a0,2
  cc:	00000097          	auipc	ra,0x0
  d0:	6f8080e7          	jalr	1784(ra) # 7c4 <fprintf>
  d4:	bf41                	j	64 <useless+0x22>

00000000000000d6 <main>:
}


 int main(int argc, char *argv[])
{
  d6:	7179                	addi	sp,sp,-48
  d8:	f406                	sd	ra,40(sp)
  da:	f022                	sd	s0,32(sp)
  dc:	ec26                	sd	s1,24(sp)
  de:	e84a                	sd	s2,16(sp)
  e0:	e44e                	sd	s3,8(sp)
  e2:	1800                	addi	s0,sp,48
  int id = 0;
  // Fix parent to high priority, so that forking is done
  if (setpriority(1) == -1) {
  e4:	4505                	li	a0,1
  e6:	00000097          	auipc	ra,0x0
  ea:	424080e7          	jalr	1060(ra) # 50a <setpriority>
  ee:	57fd                	li	a5,-1
  f0:	00f50863          	beq	a0,a5,100 <main+0x2a>
{
  f4:	4491                	li	s1,4
  // Create 4 long running children with low priorities
  for (int i=0; i < 4; i++)
  {
    id = fork();
    if(id < 0)
      printf("%d failed in fork!\n", getpid());
  f6:	00001917          	auipc	s2,0x1
  fa:	91290913          	addi	s2,s2,-1774 # a08 <malloc+0x158>
  fe:	a03d                	j	12c <main+0x56>
    fprintf(2, "setpriority error\n");
 100:	00001597          	auipc	a1,0x1
 104:	8b058593          	addi	a1,a1,-1872 # 9b0 <malloc+0x100>
 108:	4509                	li	a0,2
 10a:	00000097          	auipc	ra,0x0
 10e:	6ba080e7          	jalr	1722(ra) # 7c4 <fprintf>
 112:	b7cd                	j	f4 <main+0x1e>
      printf("%d failed in fork!\n", getpid());
 114:	00000097          	auipc	ra,0x0
 118:	3d6080e7          	jalr	982(ra) # 4ea <getpid>
 11c:	85aa                	mv	a1,a0
 11e:	854a                	mv	a0,s2
 120:	00000097          	auipc	ra,0x0
 124:	6d2080e7          	jalr	1746(ra) # 7f2 <printf>
  for (int i=0; i < 4; i++)
 128:	34fd                	addiw	s1,s1,-1
 12a:	c885                	beqz	s1,15a <main+0x84>
    id = fork();
 12c:	00000097          	auipc	ra,0x0
 130:	336080e7          	jalr	822(ra) # 462 <fork>
    if(id < 0)
 134:	fe0540e3          	bltz	a0,114 <main+0x3e>
    else if(id == 0) {
 138:	f965                	bnez	a0,128 <main+0x52>
      // Child
      int pid = getpid();
 13a:	00000097          	auipc	ra,0x0
 13e:	3b0080e7          	jalr	944(ra) # 4ea <getpid>
      int priority = pid % 5 + 16; // Priority range: 15-19
 142:	4795                	li	a5,5
 144:	02f5653b          	remw	a0,a0,a5
      useless(priority, LARGE_TIME); // never returns
 148:	48d825b7          	lui	a1,0x48d82
 14c:	c3658593          	addi	a1,a1,-970 # 48d81c36 <base+0x48d80c26>
 150:	2541                	addiw	a0,a0,16
 152:	00000097          	auipc	ra,0x0
 156:	ef0080e7          	jalr	-272(ra) # 42 <useless>
 15a:	02800913          	li	s2,40
  // Create 40 small processes with varying priorities
  int n = 40;
  for (int i=0; i<n; i++) {
    id = fork();
    if(id < 0)
      printf("%d failed in fork!\n", getpid());
 15e:	00001997          	auipc	s3,0x1
 162:	8aa98993          	addi	s3,s3,-1878 # a08 <malloc+0x158>
 166:	a831                	j	182 <main+0xac>
 168:	00000097          	auipc	ra,0x0
 16c:	382080e7          	jalr	898(ra) # 4ea <getpid>
 170:	85aa                	mv	a1,a0
 172:	854e                	mv	a0,s3
 174:	00000097          	auipc	ra,0x0
 178:	67e080e7          	jalr	1662(ra) # 7f2 <printf>
  for (int i=0; i<n; i++) {
 17c:	397d                	addiw	s2,s2,-1
 17e:	02090e63          	beqz	s2,1ba <main+0xe4>
    id = fork();
 182:	00000097          	auipc	ra,0x0
 186:	2e0080e7          	jalr	736(ra) # 462 <fork>
 18a:	84aa                	mv	s1,a0
    if(id < 0)
 18c:	fc054ee3          	bltz	a0,168 <main+0x92>
    else if(id == 0) {
 190:	f575                	bnez	a0,17c <main+0xa6>
      // Child
      sleep(1);
 192:	4505                	li	a0,1
 194:	00000097          	auipc	ra,0x0
 198:	366080e7          	jalr	870(ra) # 4fa <sleep>
      int pid = getpid();
 19c:	00000097          	auipc	ra,0x0
 1a0:	34e080e7          	jalr	846(ra) # 4ea <getpid>
      int priority = pid % 19 + 2; // Priority range: 2-20
 1a4:	47cd                	li	a5,19
 1a6:	02f5653b          	remw	a0,a0,a5
      useless(priority, SMALL_TIME); // never returns
 1aa:	0748d5b7          	lui	a1,0x748d
 1ae:	1595                	addi	a1,a1,-27
 1b0:	2509                	addiw	a0,a0,2
 1b2:	00000097          	auipc	ra,0x0
 1b6:	e90080e7          	jalr	-368(ra) # 42 <useless>
    }
  }

  // Father waits for all the children (n+4)
  if (id > 0) {
 1ba:	00905b63          	blez	s1,1d0 <main+0xfa>
 1be:	02c00493          	li	s1,44
    for (int i = 0; i < n+4; i++) {
      wait((int*)0);
 1c2:	4501                	li	a0,0
 1c4:	00000097          	auipc	ra,0x0
 1c8:	2ae080e7          	jalr	686(ra) # 472 <wait>
    for (int i = 0; i < n+4; i++) {
 1cc:	34fd                	addiw	s1,s1,-1
 1ce:	f8f5                	bnez	s1,1c2 <main+0xec>
    }
  }
  exit(0);
 1d0:	4501                	li	a0,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	298080e7          	jalr	664(ra) # 46a <exit>

00000000000001da <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e406                	sd	ra,8(sp)
 1de:	e022                	sd	s0,0(sp)
 1e0:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1e2:	00000097          	auipc	ra,0x0
 1e6:	ef4080e7          	jalr	-268(ra) # d6 <main>
  exit(0);
 1ea:	4501                	li	a0,0
 1ec:	00000097          	auipc	ra,0x0
 1f0:	27e080e7          	jalr	638(ra) # 46a <exit>

00000000000001f4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1fa:	87aa                	mv	a5,a0
 1fc:	0585                	addi	a1,a1,1
 1fe:	0785                	addi	a5,a5,1
 200:	fff5c703          	lbu	a4,-1(a1) # 748cfff <base+0x748bfef>
 204:	fee78fa3          	sb	a4,-1(a5)
 208:	fb75                	bnez	a4,1fc <strcpy+0x8>
    ;
  return os;
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret

0000000000000210 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cb91                	beqz	a5,22e <strcmp+0x1e>
 21c:	0005c703          	lbu	a4,0(a1)
 220:	00f71763          	bne	a4,a5,22e <strcmp+0x1e>
    p++, q++;
 224:	0505                	addi	a0,a0,1
 226:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 228:	00054783          	lbu	a5,0(a0)
 22c:	fbe5                	bnez	a5,21c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 22e:	0005c503          	lbu	a0,0(a1)
}
 232:	40a7853b          	subw	a0,a5,a0
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret

000000000000023c <strlen>:

uint
strlen(const char *s)
{
 23c:	1141                	addi	sp,sp,-16
 23e:	e422                	sd	s0,8(sp)
 240:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 242:	00054783          	lbu	a5,0(a0)
 246:	cf91                	beqz	a5,262 <strlen+0x26>
 248:	0505                	addi	a0,a0,1
 24a:	87aa                	mv	a5,a0
 24c:	4685                	li	a3,1
 24e:	9e89                	subw	a3,a3,a0
 250:	00f6853b          	addw	a0,a3,a5
 254:	0785                	addi	a5,a5,1
 256:	fff7c703          	lbu	a4,-1(a5)
 25a:	fb7d                	bnez	a4,250 <strlen+0x14>
    ;
  return n;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
  for(n = 0; s[n]; n++)
 262:	4501                	li	a0,0
 264:	bfe5                	j	25c <strlen+0x20>

0000000000000266 <memset>:

void*
memset(void *dst, int c, uint n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 26c:	ce09                	beqz	a2,286 <memset+0x20>
 26e:	87aa                	mv	a5,a0
 270:	fff6071b          	addiw	a4,a2,-1
 274:	1702                	slli	a4,a4,0x20
 276:	9301                	srli	a4,a4,0x20
 278:	0705                	addi	a4,a4,1
 27a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 27c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 280:	0785                	addi	a5,a5,1
 282:	fee79de3          	bne	a5,a4,27c <memset+0x16>
  }
  return dst;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strchr>:

char*
strchr(const char *s, char c)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  for(; *s; s++)
 292:	00054783          	lbu	a5,0(a0)
 296:	cb99                	beqz	a5,2ac <strchr+0x20>
    if(*s == c)
 298:	00f58763          	beq	a1,a5,2a6 <strchr+0x1a>
  for(; *s; s++)
 29c:	0505                	addi	a0,a0,1
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	fbfd                	bnez	a5,298 <strchr+0xc>
      return (char*)s;
  return 0;
 2a4:	4501                	li	a0,0
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  return 0;
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <strchr+0x1a>

00000000000002b0 <gets>:

char*
gets(char *buf, int max)
{
 2b0:	711d                	addi	sp,sp,-96
 2b2:	ec86                	sd	ra,88(sp)
 2b4:	e8a2                	sd	s0,80(sp)
 2b6:	e4a6                	sd	s1,72(sp)
 2b8:	e0ca                	sd	s2,64(sp)
 2ba:	fc4e                	sd	s3,56(sp)
 2bc:	f852                	sd	s4,48(sp)
 2be:	f456                	sd	s5,40(sp)
 2c0:	f05a                	sd	s6,32(sp)
 2c2:	ec5e                	sd	s7,24(sp)
 2c4:	1080                	addi	s0,sp,96
 2c6:	8baa                	mv	s7,a0
 2c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ca:	892a                	mv	s2,a0
 2cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ce:	4aa9                	li	s5,10
 2d0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2d2:	89a6                	mv	s3,s1
 2d4:	2485                	addiw	s1,s1,1
 2d6:	0344d863          	bge	s1,s4,306 <gets+0x56>
    cc = read(0, &c, 1);
 2da:	4605                	li	a2,1
 2dc:	faf40593          	addi	a1,s0,-81
 2e0:	4501                	li	a0,0
 2e2:	00000097          	auipc	ra,0x0
 2e6:	1a0080e7          	jalr	416(ra) # 482 <read>
    if(cc < 1)
 2ea:	00a05e63          	blez	a0,306 <gets+0x56>
    buf[i++] = c;
 2ee:	faf44783          	lbu	a5,-81(s0)
 2f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f6:	01578763          	beq	a5,s5,304 <gets+0x54>
 2fa:	0905                	addi	s2,s2,1
 2fc:	fd679be3          	bne	a5,s6,2d2 <gets+0x22>
  for(i=0; i+1 < max; ){
 300:	89a6                	mv	s3,s1
 302:	a011                	j	306 <gets+0x56>
 304:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 306:	99de                	add	s3,s3,s7
 308:	00098023          	sb	zero,0(s3)
  return buf;
}
 30c:	855e                	mv	a0,s7
 30e:	60e6                	ld	ra,88(sp)
 310:	6446                	ld	s0,80(sp)
 312:	64a6                	ld	s1,72(sp)
 314:	6906                	ld	s2,64(sp)
 316:	79e2                	ld	s3,56(sp)
 318:	7a42                	ld	s4,48(sp)
 31a:	7aa2                	ld	s5,40(sp)
 31c:	7b02                	ld	s6,32(sp)
 31e:	6be2                	ld	s7,24(sp)
 320:	6125                	addi	sp,sp,96
 322:	8082                	ret

0000000000000324 <stat>:

int
stat(const char *n, struct stat *st)
{
 324:	1101                	addi	sp,sp,-32
 326:	ec06                	sd	ra,24(sp)
 328:	e822                	sd	s0,16(sp)
 32a:	e426                	sd	s1,8(sp)
 32c:	e04a                	sd	s2,0(sp)
 32e:	1000                	addi	s0,sp,32
 330:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 332:	4581                	li	a1,0
 334:	00000097          	auipc	ra,0x0
 338:	176080e7          	jalr	374(ra) # 4aa <open>
  if(fd < 0)
 33c:	02054563          	bltz	a0,366 <stat+0x42>
 340:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 342:	85ca                	mv	a1,s2
 344:	00000097          	auipc	ra,0x0
 348:	17e080e7          	jalr	382(ra) # 4c2 <fstat>
 34c:	892a                	mv	s2,a0
  close(fd);
 34e:	8526                	mv	a0,s1
 350:	00000097          	auipc	ra,0x0
 354:	142080e7          	jalr	322(ra) # 492 <close>
  return r;
}
 358:	854a                	mv	a0,s2
 35a:	60e2                	ld	ra,24(sp)
 35c:	6442                	ld	s0,16(sp)
 35e:	64a2                	ld	s1,8(sp)
 360:	6902                	ld	s2,0(sp)
 362:	6105                	addi	sp,sp,32
 364:	8082                	ret
    return -1;
 366:	597d                	li	s2,-1
 368:	bfc5                	j	358 <stat+0x34>

000000000000036a <atoi>:

int
atoi(const char *s)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 370:	00054603          	lbu	a2,0(a0)
 374:	fd06079b          	addiw	a5,a2,-48
 378:	0ff7f793          	andi	a5,a5,255
 37c:	4725                	li	a4,9
 37e:	02f76963          	bltu	a4,a5,3b0 <atoi+0x46>
 382:	86aa                	mv	a3,a0
  n = 0;
 384:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 386:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 388:	0685                	addi	a3,a3,1
 38a:	0025179b          	slliw	a5,a0,0x2
 38e:	9fa9                	addw	a5,a5,a0
 390:	0017979b          	slliw	a5,a5,0x1
 394:	9fb1                	addw	a5,a5,a2
 396:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 39a:	0006c603          	lbu	a2,0(a3)
 39e:	fd06071b          	addiw	a4,a2,-48
 3a2:	0ff77713          	andi	a4,a4,255
 3a6:	fee5f1e3          	bgeu	a1,a4,388 <atoi+0x1e>
  return n;
}
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  n = 0;
 3b0:	4501                	li	a0,0
 3b2:	bfe5                	j	3aa <atoi+0x40>

00000000000003b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e422                	sd	s0,8(sp)
 3b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ba:	02b57663          	bgeu	a0,a1,3e6 <memmove+0x32>
    while(n-- > 0)
 3be:	02c05163          	blez	a2,3e0 <memmove+0x2c>
 3c2:	fff6079b          	addiw	a5,a2,-1
 3c6:	1782                	slli	a5,a5,0x20
 3c8:	9381                	srli	a5,a5,0x20
 3ca:	0785                	addi	a5,a5,1
 3cc:	97aa                	add	a5,a5,a0
  dst = vdst;
 3ce:	872a                	mv	a4,a0
      *dst++ = *src++;
 3d0:	0585                	addi	a1,a1,1
 3d2:	0705                	addi	a4,a4,1
 3d4:	fff5c683          	lbu	a3,-1(a1)
 3d8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3dc:	fee79ae3          	bne	a5,a4,3d0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3e0:	6422                	ld	s0,8(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret
    dst += n;
 3e6:	00c50733          	add	a4,a0,a2
    src += n;
 3ea:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ec:	fec05ae3          	blez	a2,3e0 <memmove+0x2c>
 3f0:	fff6079b          	addiw	a5,a2,-1
 3f4:	1782                	slli	a5,a5,0x20
 3f6:	9381                	srli	a5,a5,0x20
 3f8:	fff7c793          	not	a5,a5
 3fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fe:	15fd                	addi	a1,a1,-1
 400:	177d                	addi	a4,a4,-1
 402:	0005c683          	lbu	a3,0(a1)
 406:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 40a:	fee79ae3          	bne	a5,a4,3fe <memmove+0x4a>
 40e:	bfc9                	j	3e0 <memmove+0x2c>

0000000000000410 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 410:	1141                	addi	sp,sp,-16
 412:	e422                	sd	s0,8(sp)
 414:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 416:	ca05                	beqz	a2,446 <memcmp+0x36>
 418:	fff6069b          	addiw	a3,a2,-1
 41c:	1682                	slli	a3,a3,0x20
 41e:	9281                	srli	a3,a3,0x20
 420:	0685                	addi	a3,a3,1
 422:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 424:	00054783          	lbu	a5,0(a0)
 428:	0005c703          	lbu	a4,0(a1)
 42c:	00e79863          	bne	a5,a4,43c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 430:	0505                	addi	a0,a0,1
    p2++;
 432:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 434:	fed518e3          	bne	a0,a3,424 <memcmp+0x14>
  }
  return 0;
 438:	4501                	li	a0,0
 43a:	a019                	j	440 <memcmp+0x30>
      return *p1 - *p2;
 43c:	40e7853b          	subw	a0,a5,a4
}
 440:	6422                	ld	s0,8(sp)
 442:	0141                	addi	sp,sp,16
 444:	8082                	ret
  return 0;
 446:	4501                	li	a0,0
 448:	bfe5                	j	440 <memcmp+0x30>

000000000000044a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e406                	sd	ra,8(sp)
 44e:	e022                	sd	s0,0(sp)
 450:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 452:	00000097          	auipc	ra,0x0
 456:	f62080e7          	jalr	-158(ra) # 3b4 <memmove>
}
 45a:	60a2                	ld	ra,8(sp)
 45c:	6402                	ld	s0,0(sp)
 45e:	0141                	addi	sp,sp,16
 460:	8082                	ret

0000000000000462 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 462:	4885                	li	a7,1
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <exit>:
.global exit
exit:
 li a7, SYS_exit
 46a:	4889                	li	a7,2
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <wait>:
.global wait
wait:
 li a7, SYS_wait
 472:	488d                	li	a7,3
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 47a:	4891                	li	a7,4
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <read>:
.global read
read:
 li a7, SYS_read
 482:	4895                	li	a7,5
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <write>:
.global write
write:
 li a7, SYS_write
 48a:	48c1                	li	a7,16
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <close>:
.global close
close:
 li a7, SYS_close
 492:	48d5                	li	a7,21
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <kill>:
.global kill
kill:
 li a7, SYS_kill
 49a:	4899                	li	a7,6
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a2:	489d                	li	a7,7
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <open>:
.global open
open:
 li a7, SYS_open
 4aa:	48bd                	li	a7,15
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b2:	48c5                	li	a7,17
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4ba:	48c9                	li	a7,18
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c2:	48a1                	li	a7,8
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <link>:
.global link
link:
 li a7, SYS_link
 4ca:	48cd                	li	a7,19
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d2:	48d1                	li	a7,20
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4da:	48a5                	li	a7,9
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e2:	48a9                	li	a7,10
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ea:	48ad                	li	a7,11
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4f2:	48b1                	li	a7,12
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4fa:	48b5                	li	a7,13
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 502:	48b9                	li	a7,14
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 50a:	48d9                	li	a7,22
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 512:	48dd                	li	a7,23
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 51a:	1101                	addi	sp,sp,-32
 51c:	ec06                	sd	ra,24(sp)
 51e:	e822                	sd	s0,16(sp)
 520:	1000                	addi	s0,sp,32
 522:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 526:	4605                	li	a2,1
 528:	fef40593          	addi	a1,s0,-17
 52c:	00000097          	auipc	ra,0x0
 530:	f5e080e7          	jalr	-162(ra) # 48a <write>
}
 534:	60e2                	ld	ra,24(sp)
 536:	6442                	ld	s0,16(sp)
 538:	6105                	addi	sp,sp,32
 53a:	8082                	ret

000000000000053c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 53c:	7139                	addi	sp,sp,-64
 53e:	fc06                	sd	ra,56(sp)
 540:	f822                	sd	s0,48(sp)
 542:	f426                	sd	s1,40(sp)
 544:	f04a                	sd	s2,32(sp)
 546:	ec4e                	sd	s3,24(sp)
 548:	0080                	addi	s0,sp,64
 54a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 54c:	c299                	beqz	a3,552 <printint+0x16>
 54e:	0805c863          	bltz	a1,5de <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 552:	2581                	sext.w	a1,a1
  neg = 0;
 554:	4881                	li	a7,0
 556:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 55a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 55c:	2601                	sext.w	a2,a2
 55e:	00000517          	auipc	a0,0x0
 562:	4ca50513          	addi	a0,a0,1226 # a28 <digits>
 566:	883a                	mv	a6,a4
 568:	2705                	addiw	a4,a4,1
 56a:	02c5f7bb          	remuw	a5,a1,a2
 56e:	1782                	slli	a5,a5,0x20
 570:	9381                	srli	a5,a5,0x20
 572:	97aa                	add	a5,a5,a0
 574:	0007c783          	lbu	a5,0(a5)
 578:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 57c:	0005879b          	sext.w	a5,a1
 580:	02c5d5bb          	divuw	a1,a1,a2
 584:	0685                	addi	a3,a3,1
 586:	fec7f0e3          	bgeu	a5,a2,566 <printint+0x2a>
  if(neg)
 58a:	00088b63          	beqz	a7,5a0 <printint+0x64>
    buf[i++] = '-';
 58e:	fd040793          	addi	a5,s0,-48
 592:	973e                	add	a4,a4,a5
 594:	02d00793          	li	a5,45
 598:	fef70823          	sb	a5,-16(a4)
 59c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5a0:	02e05863          	blez	a4,5d0 <printint+0x94>
 5a4:	fc040793          	addi	a5,s0,-64
 5a8:	00e78933          	add	s2,a5,a4
 5ac:	fff78993          	addi	s3,a5,-1
 5b0:	99ba                	add	s3,s3,a4
 5b2:	377d                	addiw	a4,a4,-1
 5b4:	1702                	slli	a4,a4,0x20
 5b6:	9301                	srli	a4,a4,0x20
 5b8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5bc:	fff94583          	lbu	a1,-1(s2)
 5c0:	8526                	mv	a0,s1
 5c2:	00000097          	auipc	ra,0x0
 5c6:	f58080e7          	jalr	-168(ra) # 51a <putc>
  while(--i >= 0)
 5ca:	197d                	addi	s2,s2,-1
 5cc:	ff3918e3          	bne	s2,s3,5bc <printint+0x80>
}
 5d0:	70e2                	ld	ra,56(sp)
 5d2:	7442                	ld	s0,48(sp)
 5d4:	74a2                	ld	s1,40(sp)
 5d6:	7902                	ld	s2,32(sp)
 5d8:	69e2                	ld	s3,24(sp)
 5da:	6121                	addi	sp,sp,64
 5dc:	8082                	ret
    x = -xx;
 5de:	40b005bb          	negw	a1,a1
    neg = 1;
 5e2:	4885                	li	a7,1
    x = -xx;
 5e4:	bf8d                	j	556 <printint+0x1a>

00000000000005e6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5e6:	7119                	addi	sp,sp,-128
 5e8:	fc86                	sd	ra,120(sp)
 5ea:	f8a2                	sd	s0,112(sp)
 5ec:	f4a6                	sd	s1,104(sp)
 5ee:	f0ca                	sd	s2,96(sp)
 5f0:	ecce                	sd	s3,88(sp)
 5f2:	e8d2                	sd	s4,80(sp)
 5f4:	e4d6                	sd	s5,72(sp)
 5f6:	e0da                	sd	s6,64(sp)
 5f8:	fc5e                	sd	s7,56(sp)
 5fa:	f862                	sd	s8,48(sp)
 5fc:	f466                	sd	s9,40(sp)
 5fe:	f06a                	sd	s10,32(sp)
 600:	ec6e                	sd	s11,24(sp)
 602:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 604:	0005c903          	lbu	s2,0(a1)
 608:	18090f63          	beqz	s2,7a6 <vprintf+0x1c0>
 60c:	8aaa                	mv	s5,a0
 60e:	8b32                	mv	s6,a2
 610:	00158493          	addi	s1,a1,1
  state = 0;
 614:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 616:	02500a13          	li	s4,37
      if(c == 'd'){
 61a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 61e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 622:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 626:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 62a:	00000b97          	auipc	s7,0x0
 62e:	3feb8b93          	addi	s7,s7,1022 # a28 <digits>
 632:	a839                	j	650 <vprintf+0x6a>
        putc(fd, c);
 634:	85ca                	mv	a1,s2
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	ee2080e7          	jalr	-286(ra) # 51a <putc>
 640:	a019                	j	646 <vprintf+0x60>
    } else if(state == '%'){
 642:	01498f63          	beq	s3,s4,660 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 646:	0485                	addi	s1,s1,1
 648:	fff4c903          	lbu	s2,-1(s1)
 64c:	14090d63          	beqz	s2,7a6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 650:	0009079b          	sext.w	a5,s2
    if(state == 0){
 654:	fe0997e3          	bnez	s3,642 <vprintf+0x5c>
      if(c == '%'){
 658:	fd479ee3          	bne	a5,s4,634 <vprintf+0x4e>
        state = '%';
 65c:	89be                	mv	s3,a5
 65e:	b7e5                	j	646 <vprintf+0x60>
      if(c == 'd'){
 660:	05878063          	beq	a5,s8,6a0 <vprintf+0xba>
      } else if(c == 'l') {
 664:	05978c63          	beq	a5,s9,6bc <vprintf+0xd6>
      } else if(c == 'x') {
 668:	07a78863          	beq	a5,s10,6d8 <vprintf+0xf2>
      } else if(c == 'p') {
 66c:	09b78463          	beq	a5,s11,6f4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 670:	07300713          	li	a4,115
 674:	0ce78663          	beq	a5,a4,740 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 678:	06300713          	li	a4,99
 67c:	0ee78e63          	beq	a5,a4,778 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 680:	11478863          	beq	a5,s4,790 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 684:	85d2                	mv	a1,s4
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	e92080e7          	jalr	-366(ra) # 51a <putc>
        putc(fd, c);
 690:	85ca                	mv	a1,s2
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e86080e7          	jalr	-378(ra) # 51a <putc>
      }
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b765                	j	646 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6a0:	008b0913          	addi	s2,s6,8
 6a4:	4685                	li	a3,1
 6a6:	4629                	li	a2,10
 6a8:	000b2583          	lw	a1,0(s6)
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	e8e080e7          	jalr	-370(ra) # 53c <printint>
 6b6:	8b4a                	mv	s6,s2
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b771                	j	646 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6bc:	008b0913          	addi	s2,s6,8
 6c0:	4681                	li	a3,0
 6c2:	4629                	li	a2,10
 6c4:	000b2583          	lw	a1,0(s6)
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e72080e7          	jalr	-398(ra) # 53c <printint>
 6d2:	8b4a                	mv	s6,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	bf85                	j	646 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6d8:	008b0913          	addi	s2,s6,8
 6dc:	4681                	li	a3,0
 6de:	4641                	li	a2,16
 6e0:	000b2583          	lw	a1,0(s6)
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	e56080e7          	jalr	-426(ra) # 53c <printint>
 6ee:	8b4a                	mv	s6,s2
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	bf91                	j	646 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6f4:	008b0793          	addi	a5,s6,8
 6f8:	f8f43423          	sd	a5,-120(s0)
 6fc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 700:	03000593          	li	a1,48
 704:	8556                	mv	a0,s5
 706:	00000097          	auipc	ra,0x0
 70a:	e14080e7          	jalr	-492(ra) # 51a <putc>
  putc(fd, 'x');
 70e:	85ea                	mv	a1,s10
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	e08080e7          	jalr	-504(ra) # 51a <putc>
 71a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 71c:	03c9d793          	srli	a5,s3,0x3c
 720:	97de                	add	a5,a5,s7
 722:	0007c583          	lbu	a1,0(a5)
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	df2080e7          	jalr	-526(ra) # 51a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 730:	0992                	slli	s3,s3,0x4
 732:	397d                	addiw	s2,s2,-1
 734:	fe0914e3          	bnez	s2,71c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 738:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b721                	j	646 <vprintf+0x60>
        s = va_arg(ap, char*);
 740:	008b0993          	addi	s3,s6,8
 744:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 748:	02090163          	beqz	s2,76a <vprintf+0x184>
        while(*s != 0){
 74c:	00094583          	lbu	a1,0(s2)
 750:	c9a1                	beqz	a1,7a0 <vprintf+0x1ba>
          putc(fd, *s);
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	dc6080e7          	jalr	-570(ra) # 51a <putc>
          s++;
 75c:	0905                	addi	s2,s2,1
        while(*s != 0){
 75e:	00094583          	lbu	a1,0(s2)
 762:	f9e5                	bnez	a1,752 <vprintf+0x16c>
        s = va_arg(ap, char*);
 764:	8b4e                	mv	s6,s3
      state = 0;
 766:	4981                	li	s3,0
 768:	bdf9                	j	646 <vprintf+0x60>
          s = "(null)";
 76a:	00000917          	auipc	s2,0x0
 76e:	2b690913          	addi	s2,s2,694 # a20 <malloc+0x170>
        while(*s != 0){
 772:	02800593          	li	a1,40
 776:	bff1                	j	752 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 778:	008b0913          	addi	s2,s6,8
 77c:	000b4583          	lbu	a1,0(s6)
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	d98080e7          	jalr	-616(ra) # 51a <putc>
 78a:	8b4a                	mv	s6,s2
      state = 0;
 78c:	4981                	li	s3,0
 78e:	bd65                	j	646 <vprintf+0x60>
        putc(fd, c);
 790:	85d2                	mv	a1,s4
 792:	8556                	mv	a0,s5
 794:	00000097          	auipc	ra,0x0
 798:	d86080e7          	jalr	-634(ra) # 51a <putc>
      state = 0;
 79c:	4981                	li	s3,0
 79e:	b565                	j	646 <vprintf+0x60>
        s = va_arg(ap, char*);
 7a0:	8b4e                	mv	s6,s3
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b54d                	j	646 <vprintf+0x60>
    }
  }
}
 7a6:	70e6                	ld	ra,120(sp)
 7a8:	7446                	ld	s0,112(sp)
 7aa:	74a6                	ld	s1,104(sp)
 7ac:	7906                	ld	s2,96(sp)
 7ae:	69e6                	ld	s3,88(sp)
 7b0:	6a46                	ld	s4,80(sp)
 7b2:	6aa6                	ld	s5,72(sp)
 7b4:	6b06                	ld	s6,64(sp)
 7b6:	7be2                	ld	s7,56(sp)
 7b8:	7c42                	ld	s8,48(sp)
 7ba:	7ca2                	ld	s9,40(sp)
 7bc:	7d02                	ld	s10,32(sp)
 7be:	6de2                	ld	s11,24(sp)
 7c0:	6109                	addi	sp,sp,128
 7c2:	8082                	ret

00000000000007c4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c4:	715d                	addi	sp,sp,-80
 7c6:	ec06                	sd	ra,24(sp)
 7c8:	e822                	sd	s0,16(sp)
 7ca:	1000                	addi	s0,sp,32
 7cc:	e010                	sd	a2,0(s0)
 7ce:	e414                	sd	a3,8(s0)
 7d0:	e818                	sd	a4,16(s0)
 7d2:	ec1c                	sd	a5,24(s0)
 7d4:	03043023          	sd	a6,32(s0)
 7d8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7dc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e0:	8622                	mv	a2,s0
 7e2:	00000097          	auipc	ra,0x0
 7e6:	e04080e7          	jalr	-508(ra) # 5e6 <vprintf>
}
 7ea:	60e2                	ld	ra,24(sp)
 7ec:	6442                	ld	s0,16(sp)
 7ee:	6161                	addi	sp,sp,80
 7f0:	8082                	ret

00000000000007f2 <printf>:

void
printf(const char *fmt, ...)
{
 7f2:	711d                	addi	sp,sp,-96
 7f4:	ec06                	sd	ra,24(sp)
 7f6:	e822                	sd	s0,16(sp)
 7f8:	1000                	addi	s0,sp,32
 7fa:	e40c                	sd	a1,8(s0)
 7fc:	e810                	sd	a2,16(s0)
 7fe:	ec14                	sd	a3,24(s0)
 800:	f018                	sd	a4,32(s0)
 802:	f41c                	sd	a5,40(s0)
 804:	03043823          	sd	a6,48(s0)
 808:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 80c:	00840613          	addi	a2,s0,8
 810:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 814:	85aa                	mv	a1,a0
 816:	4505                	li	a0,1
 818:	00000097          	auipc	ra,0x0
 81c:	dce080e7          	jalr	-562(ra) # 5e6 <vprintf>
}
 820:	60e2                	ld	ra,24(sp)
 822:	6442                	ld	s0,16(sp)
 824:	6125                	addi	sp,sp,96
 826:	8082                	ret

0000000000000828 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 828:	1141                	addi	sp,sp,-16
 82a:	e422                	sd	s0,8(sp)
 82c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 832:	00000797          	auipc	a5,0x0
 836:	7ce7b783          	ld	a5,1998(a5) # 1000 <freep>
 83a:	a805                	j	86a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 83c:	4618                	lw	a4,8(a2)
 83e:	9db9                	addw	a1,a1,a4
 840:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 844:	6398                	ld	a4,0(a5)
 846:	6318                	ld	a4,0(a4)
 848:	fee53823          	sd	a4,-16(a0)
 84c:	a091                	j	890 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 84e:	ff852703          	lw	a4,-8(a0)
 852:	9e39                	addw	a2,a2,a4
 854:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 856:	ff053703          	ld	a4,-16(a0)
 85a:	e398                	sd	a4,0(a5)
 85c:	a099                	j	8a2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85e:	6398                	ld	a4,0(a5)
 860:	00e7e463          	bltu	a5,a4,868 <free+0x40>
 864:	00e6ea63          	bltu	a3,a4,878 <free+0x50>
{
 868:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86a:	fed7fae3          	bgeu	a5,a3,85e <free+0x36>
 86e:	6398                	ld	a4,0(a5)
 870:	00e6e463          	bltu	a3,a4,878 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 874:	fee7eae3          	bltu	a5,a4,868 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 878:	ff852583          	lw	a1,-8(a0)
 87c:	6390                	ld	a2,0(a5)
 87e:	02059713          	slli	a4,a1,0x20
 882:	9301                	srli	a4,a4,0x20
 884:	0712                	slli	a4,a4,0x4
 886:	9736                	add	a4,a4,a3
 888:	fae60ae3          	beq	a2,a4,83c <free+0x14>
    bp->s.ptr = p->s.ptr;
 88c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 890:	4790                	lw	a2,8(a5)
 892:	02061713          	slli	a4,a2,0x20
 896:	9301                	srli	a4,a4,0x20
 898:	0712                	slli	a4,a4,0x4
 89a:	973e                	add	a4,a4,a5
 89c:	fae689e3          	beq	a3,a4,84e <free+0x26>
  } else
    p->s.ptr = bp;
 8a0:	e394                	sd	a3,0(a5)
  freep = p;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	74f73f23          	sd	a5,1886(a4) # 1000 <freep>
}
 8aa:	6422                	ld	s0,8(sp)
 8ac:	0141                	addi	sp,sp,16
 8ae:	8082                	ret

00000000000008b0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b0:	7139                	addi	sp,sp,-64
 8b2:	fc06                	sd	ra,56(sp)
 8b4:	f822                	sd	s0,48(sp)
 8b6:	f426                	sd	s1,40(sp)
 8b8:	f04a                	sd	s2,32(sp)
 8ba:	ec4e                	sd	s3,24(sp)
 8bc:	e852                	sd	s4,16(sp)
 8be:	e456                	sd	s5,8(sp)
 8c0:	e05a                	sd	s6,0(sp)
 8c2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c4:	02051493          	slli	s1,a0,0x20
 8c8:	9081                	srli	s1,s1,0x20
 8ca:	04bd                	addi	s1,s1,15
 8cc:	8091                	srli	s1,s1,0x4
 8ce:	0014899b          	addiw	s3,s1,1
 8d2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d4:	00000517          	auipc	a0,0x0
 8d8:	72c53503          	ld	a0,1836(a0) # 1000 <freep>
 8dc:	c515                	beqz	a0,908 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e0:	4798                	lw	a4,8(a5)
 8e2:	02977f63          	bgeu	a4,s1,920 <malloc+0x70>
 8e6:	8a4e                	mv	s4,s3
 8e8:	0009871b          	sext.w	a4,s3
 8ec:	6685                	lui	a3,0x1
 8ee:	00d77363          	bgeu	a4,a3,8f4 <malloc+0x44>
 8f2:	6a05                	lui	s4,0x1
 8f4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fc:	00000917          	auipc	s2,0x0
 900:	70490913          	addi	s2,s2,1796 # 1000 <freep>
  if(p == (char*)-1)
 904:	5afd                	li	s5,-1
 906:	a88d                	j	978 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 908:	00000797          	auipc	a5,0x0
 90c:	70878793          	addi	a5,a5,1800 # 1010 <base>
 910:	00000717          	auipc	a4,0x0
 914:	6ef73823          	sd	a5,1776(a4) # 1000 <freep>
 918:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 91a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 91e:	b7e1                	j	8e6 <malloc+0x36>
      if(p->s.size == nunits)
 920:	02e48b63          	beq	s1,a4,956 <malloc+0xa6>
        p->s.size -= nunits;
 924:	4137073b          	subw	a4,a4,s3
 928:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92a:	1702                	slli	a4,a4,0x20
 92c:	9301                	srli	a4,a4,0x20
 92e:	0712                	slli	a4,a4,0x4
 930:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 932:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 936:	00000717          	auipc	a4,0x0
 93a:	6ca73523          	sd	a0,1738(a4) # 1000 <freep>
      return (void*)(p + 1);
 93e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 942:	70e2                	ld	ra,56(sp)
 944:	7442                	ld	s0,48(sp)
 946:	74a2                	ld	s1,40(sp)
 948:	7902                	ld	s2,32(sp)
 94a:	69e2                	ld	s3,24(sp)
 94c:	6a42                	ld	s4,16(sp)
 94e:	6aa2                	ld	s5,8(sp)
 950:	6b02                	ld	s6,0(sp)
 952:	6121                	addi	sp,sp,64
 954:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 956:	6398                	ld	a4,0(a5)
 958:	e118                	sd	a4,0(a0)
 95a:	bff1                	j	936 <malloc+0x86>
  hp->s.size = nu;
 95c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 960:	0541                	addi	a0,a0,16
 962:	00000097          	auipc	ra,0x0
 966:	ec6080e7          	jalr	-314(ra) # 828 <free>
  return freep;
 96a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 96e:	d971                	beqz	a0,942 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 970:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 972:	4798                	lw	a4,8(a5)
 974:	fa9776e3          	bgeu	a4,s1,920 <malloc+0x70>
    if(p == freep)
 978:	00093703          	ld	a4,0(s2)
 97c:	853e                	mv	a0,a5
 97e:	fef719e3          	bne	a4,a5,970 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 982:	8552                	mv	a0,s4
 984:	00000097          	auipc	ra,0x0
 988:	b6e080e7          	jalr	-1170(ra) # 4f2 <sbrk>
  if(p == (char*)-1)
 98c:	fd5518e3          	bne	a0,s5,95c <malloc+0xac>
        return 0;
 990:	4501                	li	a0,0
 992:	bf45                	j	942 <malloc+0x92>
