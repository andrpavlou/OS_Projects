
user/_priotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <useless_calc>:
// {
//   return -1;
// }

uint64 useless_calc(uint64 z, uint64 time)
{
   0:	1101                	add	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	add	s0,sp,32
  volatile uint64 t = z;  // volatile to not be optimized out
   6:	fea43423          	sd	a0,-24(s0)
  volatile uint64 sum = 0;
   a:	fe043023          	sd	zero,-32(s0)
  for (;;) {
    t += 2;
   e:	fe843783          	ld	a5,-24(s0)
  12:	0789                	add	a5,a5,2
  14:	fef43423          	sd	a5,-24(s0)
    sum += t;
  18:	fe843703          	ld	a4,-24(s0)
  1c:	fe043783          	ld	a5,-32(s0)
  20:	97ba                	add	a5,a5,a4
  22:	fef43023          	sd	a5,-32(s0)
    t -= 1;
  26:	fe843783          	ld	a5,-24(s0)
  2a:	17fd                	add	a5,a5,-1
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
  3e:	6105                	add	sp,sp,32
  40:	8082                	ret

0000000000000042 <useless>:

int
useless(int priority, uint64 time)
{
  42:	7179                	add	sp,sp,-48
  44:	f406                	sd	ra,40(sp)
  46:	f022                	sd	s0,32(sp)
  48:	ec26                	sd	s1,24(sp)
  4a:	e84a                	sd	s2,16(sp)
  4c:	e44e                	sd	s3,8(sp)
  4e:	e052                	sd	s4,0(sp)
  50:	1800                	add	s0,sp,48
  52:	892a                	mv	s2,a0
  54:	84ae                	mv	s1,a1
  if (setpriority(priority) == -1) {
  56:	00000097          	auipc	ra,0x0
  5a:	4aa080e7          	jalr	1194(ra) # 500 <setpriority>
  5e:	57fd                	li	a5,-1
  60:	04f50d63          	beq	a0,a5,ba <useless+0x78>
    fprintf(2, "setpriority error\n");
  }

  sleep(1);
  64:	4505                	li	a0,1
  66:	00000097          	auipc	ra,0x0
  6a:	48a080e7          	jalr	1162(ra) # 4f0 <sleep>
  uint64 sum = useless_calc(0, time);
  6e:	85a6                	mv	a1,s1
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	f8e080e7          	jalr	-114(ra) # 0 <useless_calc>
  7a:	89aa                	mv	s3,a0
  char* spent = (time == LARGE_TIME) ? "large" : "small";
  7c:	48d827b7          	lui	a5,0x48d82
  80:	c3678793          	add	a5,a5,-970 # 48d81c36 <base+0x48d80c26>
  84:	00001a17          	auipc	s4,0x1
  88:	91ca0a13          	add	s4,s4,-1764 # 9a0 <malloc+0x110>
  8c:	04f48163          	beq	s1,a5,ce <useless+0x8c>
  // Need to print uselesss sum to suppress warning.
  printf("Child pid %d, %s, with priority %d finished. Useless sum: %d\n", getpid(), spent,  priority, sum);
  90:	00000097          	auipc	ra,0x0
  94:	450080e7          	jalr	1104(ra) # 4e0 <getpid>
  98:	85aa                	mv	a1,a0
  9a:	874e                	mv	a4,s3
  9c:	86ca                	mv	a3,s2
  9e:	8652                	mv	a2,s4
  a0:	00001517          	auipc	a0,0x1
  a4:	92050513          	add	a0,a0,-1760 # 9c0 <malloc+0x130>
  a8:	00000097          	auipc	ra,0x0
  ac:	730080e7          	jalr	1840(ra) # 7d8 <printf>
  exit(0);
  b0:	4501                	li	a0,0
  b2:	00000097          	auipc	ra,0x0
  b6:	3ae080e7          	jalr	942(ra) # 460 <exit>
    fprintf(2, "setpriority error\n");
  ba:	00001597          	auipc	a1,0x1
  be:	8ee58593          	add	a1,a1,-1810 # 9a8 <malloc+0x118>
  c2:	4509                	li	a0,2
  c4:	00000097          	auipc	ra,0x0
  c8:	6e6080e7          	jalr	1766(ra) # 7aa <fprintf>
  cc:	bf61                	j	64 <useless+0x22>
  char* spent = (time == LARGE_TIME) ? "large" : "small";
  ce:	00001a17          	auipc	s4,0x1
  d2:	8c2a0a13          	add	s4,s4,-1854 # 990 <malloc+0x100>
  d6:	bf6d                	j	90 <useless+0x4e>

00000000000000d8 <main>:
}


 int main(int argc, char *argv[])
{
  d8:	7179                	add	sp,sp,-48
  da:	f406                	sd	ra,40(sp)
  dc:	f022                	sd	s0,32(sp)
  de:	ec26                	sd	s1,24(sp)
  e0:	e84a                	sd	s2,16(sp)
  e2:	e44e                	sd	s3,8(sp)
  e4:	1800                	add	s0,sp,48
  int id = 0;
  // Fix parent to high priority, so that forking is done
  if (setpriority(1) == -1) {
  e6:	4505                	li	a0,1
  e8:	00000097          	auipc	ra,0x0
  ec:	418080e7          	jalr	1048(ra) # 500 <setpriority>
  f0:	57fd                	li	a5,-1
  f2:	00f50463          	beq	a0,a5,fa <main+0x22>
{
  f6:	4491                	li	s1,4
  f8:	a815                	j	12c <main+0x54>
    fprintf(2, "setpriority error\n");
  fa:	00001597          	auipc	a1,0x1
  fe:	8ae58593          	add	a1,a1,-1874 # 9a8 <malloc+0x118>
 102:	4509                	li	a0,2
 104:	00000097          	auipc	ra,0x0
 108:	6a6080e7          	jalr	1702(ra) # 7aa <fprintf>
 10c:	b7ed                	j	f6 <main+0x1e>
  // Create 4 long running children with low priorities
  for (int i=0; i < 4; i++)
  {
    id = fork();
    if(id < 0)
      printf("%d failed in fork!\n", getpid());
 10e:	00000097          	auipc	ra,0x0
 112:	3d2080e7          	jalr	978(ra) # 4e0 <getpid>
 116:	85aa                	mv	a1,a0
 118:	00001517          	auipc	a0,0x1
 11c:	8e850513          	add	a0,a0,-1816 # a00 <malloc+0x170>
 120:	00000097          	auipc	ra,0x0
 124:	6b8080e7          	jalr	1720(ra) # 7d8 <printf>
  for (int i=0; i < 4; i++)
 128:	34fd                	addw	s1,s1,-1
 12a:	c885                	beqz	s1,15a <main+0x82>
    id = fork();
 12c:	00000097          	auipc	ra,0x0
 130:	32c080e7          	jalr	812(ra) # 458 <fork>
    if(id < 0)
 134:	fc054de3          	bltz	a0,10e <main+0x36>
    else if(id == 0) {
 138:	f965                	bnez	a0,128 <main+0x50>
      // Child
      int pid = getpid();
 13a:	00000097          	auipc	ra,0x0
 13e:	3a6080e7          	jalr	934(ra) # 4e0 <getpid>
      int priority = pid % 5 + 16; // Priority range: 15-19
 142:	4795                	li	a5,5
 144:	02f5653b          	remw	a0,a0,a5
      useless(priority, LARGE_TIME); // never returns
 148:	48d825b7          	lui	a1,0x48d82
 14c:	c3658593          	add	a1,a1,-970 # 48d81c36 <base+0x48d80c26>
 150:	2541                	addw	a0,a0,16
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
 162:	8a298993          	add	s3,s3,-1886 # a00 <malloc+0x170>
 166:	a831                	j	182 <main+0xaa>
 168:	00000097          	auipc	ra,0x0
 16c:	378080e7          	jalr	888(ra) # 4e0 <getpid>
 170:	85aa                	mv	a1,a0
 172:	854e                	mv	a0,s3
 174:	00000097          	auipc	ra,0x0
 178:	664080e7          	jalr	1636(ra) # 7d8 <printf>
  for (int i=0; i<n; i++) {
 17c:	397d                	addw	s2,s2,-1
 17e:	02090e63          	beqz	s2,1ba <main+0xe2>
    id = fork();
 182:	00000097          	auipc	ra,0x0
 186:	2d6080e7          	jalr	726(ra) # 458 <fork>
 18a:	84aa                	mv	s1,a0
    if(id < 0)
 18c:	fc054ee3          	bltz	a0,168 <main+0x90>
    else if(id == 0) {
 190:	f575                	bnez	a0,17c <main+0xa4>
      // Child
      sleep(1);
 192:	4505                	li	a0,1
 194:	00000097          	auipc	ra,0x0
 198:	35c080e7          	jalr	860(ra) # 4f0 <sleep>
      int pid = getpid();
 19c:	00000097          	auipc	ra,0x0
 1a0:	344080e7          	jalr	836(ra) # 4e0 <getpid>
      int priority = pid % 19 + 2; // Priority range: 2-20
 1a4:	47cd                	li	a5,19
 1a6:	02f5653b          	remw	a0,a0,a5
      useless(priority, SMALL_TIME); // never returns
 1aa:	0748d5b7          	lui	a1,0x748d
 1ae:	1595                	add	a1,a1,-27 # 748cfe5 <base+0x748bfd5>
 1b0:	2509                	addw	a0,a0,2
 1b2:	00000097          	auipc	ra,0x0
 1b6:	e90080e7          	jalr	-368(ra) # 42 <useless>
    }
  }

  // Father waits for all the children (n+4)
  if (id > 0) {
 1ba:	00905b63          	blez	s1,1d0 <main+0xf8>
 1be:	02c00493          	li	s1,44
    for (int i = 0; i < n+4; i++) {
      wait((int*)0);
 1c2:	4501                	li	a0,0
 1c4:	00000097          	auipc	ra,0x0
 1c8:	2a4080e7          	jalr	676(ra) # 468 <wait>
    for (int i = 0; i < n+4; i++) {
 1cc:	34fd                	addw	s1,s1,-1
 1ce:	f8f5                	bnez	s1,1c2 <main+0xea>
    }
  }
  exit(0);
 1d0:	4501                	li	a0,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	28e080e7          	jalr	654(ra) # 460 <exit>

00000000000001da <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1da:	1141                	add	sp,sp,-16
 1dc:	e406                	sd	ra,8(sp)
 1de:	e022                	sd	s0,0(sp)
 1e0:	0800                	add	s0,sp,16
  extern int main();
  main();
 1e2:	00000097          	auipc	ra,0x0
 1e6:	ef6080e7          	jalr	-266(ra) # d8 <main>
  exit(0);
 1ea:	4501                	li	a0,0
 1ec:	00000097          	auipc	ra,0x0
 1f0:	274080e7          	jalr	628(ra) # 460 <exit>

00000000000001f4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1f4:	1141                	add	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1fa:	87aa                	mv	a5,a0
 1fc:	0585                	add	a1,a1,1
 1fe:	0785                	add	a5,a5,1
 200:	fff5c703          	lbu	a4,-1(a1)
 204:	fee78fa3          	sb	a4,-1(a5)
 208:	fb75                	bnez	a4,1fc <strcpy+0x8>
    ;
  return os;
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	add	sp,sp,16
 20e:	8082                	ret

0000000000000210 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 210:	1141                	add	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 216:	00054783          	lbu	a5,0(a0)
 21a:	cb91                	beqz	a5,22e <strcmp+0x1e>
 21c:	0005c703          	lbu	a4,0(a1)
 220:	00f71763          	bne	a4,a5,22e <strcmp+0x1e>
    p++, q++;
 224:	0505                	add	a0,a0,1
 226:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 228:	00054783          	lbu	a5,0(a0)
 22c:	fbe5                	bnez	a5,21c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 22e:	0005c503          	lbu	a0,0(a1)
}
 232:	40a7853b          	subw	a0,a5,a0
 236:	6422                	ld	s0,8(sp)
 238:	0141                	add	sp,sp,16
 23a:	8082                	ret

000000000000023c <strlen>:

uint
strlen(const char *s)
{
 23c:	1141                	add	sp,sp,-16
 23e:	e422                	sd	s0,8(sp)
 240:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 242:	00054783          	lbu	a5,0(a0)
 246:	cf91                	beqz	a5,262 <strlen+0x26>
 248:	0505                	add	a0,a0,1
 24a:	87aa                	mv	a5,a0
 24c:	86be                	mv	a3,a5
 24e:	0785                	add	a5,a5,1
 250:	fff7c703          	lbu	a4,-1(a5)
 254:	ff65                	bnez	a4,24c <strlen+0x10>
 256:	40a6853b          	subw	a0,a3,a0
 25a:	2505                	addw	a0,a0,1
    ;
  return n;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	add	sp,sp,16
 260:	8082                	ret
  for(n = 0; s[n]; n++)
 262:	4501                	li	a0,0
 264:	bfe5                	j	25c <strlen+0x20>

0000000000000266 <memset>:

void*
memset(void *dst, int c, uint n)
{
 266:	1141                	add	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 26c:	ca19                	beqz	a2,282 <memset+0x1c>
 26e:	87aa                	mv	a5,a0
 270:	1602                	sll	a2,a2,0x20
 272:	9201                	srl	a2,a2,0x20
 274:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 278:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 27c:	0785                	add	a5,a5,1
 27e:	fee79de3          	bne	a5,a4,278 <memset+0x12>
  }
  return dst;
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	add	sp,sp,16
 286:	8082                	ret

0000000000000288 <strchr>:

char*
strchr(const char *s, char c)
{
 288:	1141                	add	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	add	s0,sp,16
  for(; *s; s++)
 28e:	00054783          	lbu	a5,0(a0)
 292:	cb99                	beqz	a5,2a8 <strchr+0x20>
    if(*s == c)
 294:	00f58763          	beq	a1,a5,2a2 <strchr+0x1a>
  for(; *s; s++)
 298:	0505                	add	a0,a0,1
 29a:	00054783          	lbu	a5,0(a0)
 29e:	fbfd                	bnez	a5,294 <strchr+0xc>
      return (char*)s;
  return 0;
 2a0:	4501                	li	a0,0
}
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	add	sp,sp,16
 2a6:	8082                	ret
  return 0;
 2a8:	4501                	li	a0,0
 2aa:	bfe5                	j	2a2 <strchr+0x1a>

00000000000002ac <gets>:

char*
gets(char *buf, int max)
{
 2ac:	711d                	add	sp,sp,-96
 2ae:	ec86                	sd	ra,88(sp)
 2b0:	e8a2                	sd	s0,80(sp)
 2b2:	e4a6                	sd	s1,72(sp)
 2b4:	e0ca                	sd	s2,64(sp)
 2b6:	fc4e                	sd	s3,56(sp)
 2b8:	f852                	sd	s4,48(sp)
 2ba:	f456                	sd	s5,40(sp)
 2bc:	f05a                	sd	s6,32(sp)
 2be:	ec5e                	sd	s7,24(sp)
 2c0:	1080                	add	s0,sp,96
 2c2:	8baa                	mv	s7,a0
 2c4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c6:	892a                	mv	s2,a0
 2c8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ca:	4aa9                	li	s5,10
 2cc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ce:	89a6                	mv	s3,s1
 2d0:	2485                	addw	s1,s1,1
 2d2:	0344d863          	bge	s1,s4,302 <gets+0x56>
    cc = read(0, &c, 1);
 2d6:	4605                	li	a2,1
 2d8:	faf40593          	add	a1,s0,-81
 2dc:	4501                	li	a0,0
 2de:	00000097          	auipc	ra,0x0
 2e2:	19a080e7          	jalr	410(ra) # 478 <read>
    if(cc < 1)
 2e6:	00a05e63          	blez	a0,302 <gets+0x56>
    buf[i++] = c;
 2ea:	faf44783          	lbu	a5,-81(s0)
 2ee:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f2:	01578763          	beq	a5,s5,300 <gets+0x54>
 2f6:	0905                	add	s2,s2,1
 2f8:	fd679be3          	bne	a5,s6,2ce <gets+0x22>
    buf[i++] = c;
 2fc:	89a6                	mv	s3,s1
 2fe:	a011                	j	302 <gets+0x56>
 300:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 302:	99de                	add	s3,s3,s7
 304:	00098023          	sb	zero,0(s3)
  return buf;
}
 308:	855e                	mv	a0,s7
 30a:	60e6                	ld	ra,88(sp)
 30c:	6446                	ld	s0,80(sp)
 30e:	64a6                	ld	s1,72(sp)
 310:	6906                	ld	s2,64(sp)
 312:	79e2                	ld	s3,56(sp)
 314:	7a42                	ld	s4,48(sp)
 316:	7aa2                	ld	s5,40(sp)
 318:	7b02                	ld	s6,32(sp)
 31a:	6be2                	ld	s7,24(sp)
 31c:	6125                	add	sp,sp,96
 31e:	8082                	ret

0000000000000320 <stat>:

int
stat(const char *n, struct stat *st)
{
 320:	1101                	add	sp,sp,-32
 322:	ec06                	sd	ra,24(sp)
 324:	e822                	sd	s0,16(sp)
 326:	e04a                	sd	s2,0(sp)
 328:	1000                	add	s0,sp,32
 32a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 32c:	4581                	li	a1,0
 32e:	00000097          	auipc	ra,0x0
 332:	172080e7          	jalr	370(ra) # 4a0 <open>
  if(fd < 0)
 336:	02054663          	bltz	a0,362 <stat+0x42>
 33a:	e426                	sd	s1,8(sp)
 33c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 33e:	85ca                	mv	a1,s2
 340:	00000097          	auipc	ra,0x0
 344:	178080e7          	jalr	376(ra) # 4b8 <fstat>
 348:	892a                	mv	s2,a0
  close(fd);
 34a:	8526                	mv	a0,s1
 34c:	00000097          	auipc	ra,0x0
 350:	13c080e7          	jalr	316(ra) # 488 <close>
  return r;
 354:	64a2                	ld	s1,8(sp)
}
 356:	854a                	mv	a0,s2
 358:	60e2                	ld	ra,24(sp)
 35a:	6442                	ld	s0,16(sp)
 35c:	6902                	ld	s2,0(sp)
 35e:	6105                	add	sp,sp,32
 360:	8082                	ret
    return -1;
 362:	597d                	li	s2,-1
 364:	bfcd                	j	356 <stat+0x36>

0000000000000366 <atoi>:

int
atoi(const char *s)
{
 366:	1141                	add	sp,sp,-16
 368:	e422                	sd	s0,8(sp)
 36a:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 36c:	00054683          	lbu	a3,0(a0)
 370:	fd06879b          	addw	a5,a3,-48
 374:	0ff7f793          	zext.b	a5,a5
 378:	4625                	li	a2,9
 37a:	02f66863          	bltu	a2,a5,3aa <atoi+0x44>
 37e:	872a                	mv	a4,a0
  n = 0;
 380:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 382:	0705                	add	a4,a4,1
 384:	0025179b          	sllw	a5,a0,0x2
 388:	9fa9                	addw	a5,a5,a0
 38a:	0017979b          	sllw	a5,a5,0x1
 38e:	9fb5                	addw	a5,a5,a3
 390:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 394:	00074683          	lbu	a3,0(a4)
 398:	fd06879b          	addw	a5,a3,-48
 39c:	0ff7f793          	zext.b	a5,a5
 3a0:	fef671e3          	bgeu	a2,a5,382 <atoi+0x1c>
  return n;
}
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	add	sp,sp,16
 3a8:	8082                	ret
  n = 0;
 3aa:	4501                	li	a0,0
 3ac:	bfe5                	j	3a4 <atoi+0x3e>

00000000000003ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ae:	1141                	add	sp,sp,-16
 3b0:	e422                	sd	s0,8(sp)
 3b2:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b4:	02b57463          	bgeu	a0,a1,3dc <memmove+0x2e>
    while(n-- > 0)
 3b8:	00c05f63          	blez	a2,3d6 <memmove+0x28>
 3bc:	1602                	sll	a2,a2,0x20
 3be:	9201                	srl	a2,a2,0x20
 3c0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3c6:	0585                	add	a1,a1,1
 3c8:	0705                	add	a4,a4,1
 3ca:	fff5c683          	lbu	a3,-1(a1)
 3ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d2:	fef71ae3          	bne	a4,a5,3c6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	add	sp,sp,16
 3da:	8082                	ret
    dst += n;
 3dc:	00c50733          	add	a4,a0,a2
    src += n;
 3e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e2:	fec05ae3          	blez	a2,3d6 <memmove+0x28>
 3e6:	fff6079b          	addw	a5,a2,-1
 3ea:	1782                	sll	a5,a5,0x20
 3ec:	9381                	srl	a5,a5,0x20
 3ee:	fff7c793          	not	a5,a5
 3f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f4:	15fd                	add	a1,a1,-1
 3f6:	177d                	add	a4,a4,-1
 3f8:	0005c683          	lbu	a3,0(a1)
 3fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 400:	fee79ae3          	bne	a5,a4,3f4 <memmove+0x46>
 404:	bfc9                	j	3d6 <memmove+0x28>

0000000000000406 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 406:	1141                	add	sp,sp,-16
 408:	e422                	sd	s0,8(sp)
 40a:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 40c:	ca05                	beqz	a2,43c <memcmp+0x36>
 40e:	fff6069b          	addw	a3,a2,-1
 412:	1682                	sll	a3,a3,0x20
 414:	9281                	srl	a3,a3,0x20
 416:	0685                	add	a3,a3,1
 418:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 41a:	00054783          	lbu	a5,0(a0)
 41e:	0005c703          	lbu	a4,0(a1)
 422:	00e79863          	bne	a5,a4,432 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 426:	0505                	add	a0,a0,1
    p2++;
 428:	0585                	add	a1,a1,1
  while (n-- > 0) {
 42a:	fed518e3          	bne	a0,a3,41a <memcmp+0x14>
  }
  return 0;
 42e:	4501                	li	a0,0
 430:	a019                	j	436 <memcmp+0x30>
      return *p1 - *p2;
 432:	40e7853b          	subw	a0,a5,a4
}
 436:	6422                	ld	s0,8(sp)
 438:	0141                	add	sp,sp,16
 43a:	8082                	ret
  return 0;
 43c:	4501                	li	a0,0
 43e:	bfe5                	j	436 <memcmp+0x30>

0000000000000440 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 440:	1141                	add	sp,sp,-16
 442:	e406                	sd	ra,8(sp)
 444:	e022                	sd	s0,0(sp)
 446:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 448:	00000097          	auipc	ra,0x0
 44c:	f66080e7          	jalr	-154(ra) # 3ae <memmove>
}
 450:	60a2                	ld	ra,8(sp)
 452:	6402                	ld	s0,0(sp)
 454:	0141                	add	sp,sp,16
 456:	8082                	ret

0000000000000458 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 458:	4885                	li	a7,1
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <exit>:
.global exit
exit:
 li a7, SYS_exit
 460:	4889                	li	a7,2
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <wait>:
.global wait
wait:
 li a7, SYS_wait
 468:	488d                	li	a7,3
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 470:	4891                	li	a7,4
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <read>:
.global read
read:
 li a7, SYS_read
 478:	4895                	li	a7,5
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <write>:
.global write
write:
 li a7, SYS_write
 480:	48c1                	li	a7,16
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <close>:
.global close
close:
 li a7, SYS_close
 488:	48d5                	li	a7,21
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <kill>:
.global kill
kill:
 li a7, SYS_kill
 490:	4899                	li	a7,6
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <exec>:
.global exec
exec:
 li a7, SYS_exec
 498:	489d                	li	a7,7
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <open>:
.global open
open:
 li a7, SYS_open
 4a0:	48bd                	li	a7,15
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4a8:	48c5                	li	a7,17
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b0:	48c9                	li	a7,18
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4b8:	48a1                	li	a7,8
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <link>:
.global link
link:
 li a7, SYS_link
 4c0:	48cd                	li	a7,19
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4c8:	48d1                	li	a7,20
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d0:	48a5                	li	a7,9
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4d8:	48a9                	li	a7,10
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e0:	48ad                	li	a7,11
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4e8:	48b1                	li	a7,12
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f0:	48b5                	li	a7,13
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4f8:	48b9                	li	a7,14
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 500:	48d9                	li	a7,22
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
 508:	48dd                	li	a7,23
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 510:	1101                	add	sp,sp,-32
 512:	ec06                	sd	ra,24(sp)
 514:	e822                	sd	s0,16(sp)
 516:	1000                	add	s0,sp,32
 518:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 51c:	4605                	li	a2,1
 51e:	fef40593          	add	a1,s0,-17
 522:	00000097          	auipc	ra,0x0
 526:	f5e080e7          	jalr	-162(ra) # 480 <write>
}
 52a:	60e2                	ld	ra,24(sp)
 52c:	6442                	ld	s0,16(sp)
 52e:	6105                	add	sp,sp,32
 530:	8082                	ret

0000000000000532 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 532:	7139                	add	sp,sp,-64
 534:	fc06                	sd	ra,56(sp)
 536:	f822                	sd	s0,48(sp)
 538:	f426                	sd	s1,40(sp)
 53a:	0080                	add	s0,sp,64
 53c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 53e:	c299                	beqz	a3,544 <printint+0x12>
 540:	0805cb63          	bltz	a1,5d6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 544:	2581                	sext.w	a1,a1
  neg = 0;
 546:	4881                	li	a7,0
 548:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 54c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 54e:	2601                	sext.w	a2,a2
 550:	00000517          	auipc	a0,0x0
 554:	52850513          	add	a0,a0,1320 # a78 <digits>
 558:	883a                	mv	a6,a4
 55a:	2705                	addw	a4,a4,1
 55c:	02c5f7bb          	remuw	a5,a1,a2
 560:	1782                	sll	a5,a5,0x20
 562:	9381                	srl	a5,a5,0x20
 564:	97aa                	add	a5,a5,a0
 566:	0007c783          	lbu	a5,0(a5)
 56a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 56e:	0005879b          	sext.w	a5,a1
 572:	02c5d5bb          	divuw	a1,a1,a2
 576:	0685                	add	a3,a3,1
 578:	fec7f0e3          	bgeu	a5,a2,558 <printint+0x26>
  if(neg)
 57c:	00088c63          	beqz	a7,594 <printint+0x62>
    buf[i++] = '-';
 580:	fd070793          	add	a5,a4,-48
 584:	00878733          	add	a4,a5,s0
 588:	02d00793          	li	a5,45
 58c:	fef70823          	sb	a5,-16(a4)
 590:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 594:	02e05c63          	blez	a4,5cc <printint+0x9a>
 598:	f04a                	sd	s2,32(sp)
 59a:	ec4e                	sd	s3,24(sp)
 59c:	fc040793          	add	a5,s0,-64
 5a0:	00e78933          	add	s2,a5,a4
 5a4:	fff78993          	add	s3,a5,-1
 5a8:	99ba                	add	s3,s3,a4
 5aa:	377d                	addw	a4,a4,-1
 5ac:	1702                	sll	a4,a4,0x20
 5ae:	9301                	srl	a4,a4,0x20
 5b0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5b4:	fff94583          	lbu	a1,-1(s2)
 5b8:	8526                	mv	a0,s1
 5ba:	00000097          	auipc	ra,0x0
 5be:	f56080e7          	jalr	-170(ra) # 510 <putc>
  while(--i >= 0)
 5c2:	197d                	add	s2,s2,-1
 5c4:	ff3918e3          	bne	s2,s3,5b4 <printint+0x82>
 5c8:	7902                	ld	s2,32(sp)
 5ca:	69e2                	ld	s3,24(sp)
}
 5cc:	70e2                	ld	ra,56(sp)
 5ce:	7442                	ld	s0,48(sp)
 5d0:	74a2                	ld	s1,40(sp)
 5d2:	6121                	add	sp,sp,64
 5d4:	8082                	ret
    x = -xx;
 5d6:	40b005bb          	negw	a1,a1
    neg = 1;
 5da:	4885                	li	a7,1
    x = -xx;
 5dc:	b7b5                	j	548 <printint+0x16>

00000000000005de <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5de:	715d                	add	sp,sp,-80
 5e0:	e486                	sd	ra,72(sp)
 5e2:	e0a2                	sd	s0,64(sp)
 5e4:	f84a                	sd	s2,48(sp)
 5e6:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e8:	0005c903          	lbu	s2,0(a1)
 5ec:	1a090a63          	beqz	s2,7a0 <vprintf+0x1c2>
 5f0:	fc26                	sd	s1,56(sp)
 5f2:	f44e                	sd	s3,40(sp)
 5f4:	f052                	sd	s4,32(sp)
 5f6:	ec56                	sd	s5,24(sp)
 5f8:	e85a                	sd	s6,16(sp)
 5fa:	e45e                	sd	s7,8(sp)
 5fc:	8aaa                	mv	s5,a0
 5fe:	8bb2                	mv	s7,a2
 600:	00158493          	add	s1,a1,1
  state = 0;
 604:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 606:	02500a13          	li	s4,37
 60a:	4b55                	li	s6,21
 60c:	a839                	j	62a <vprintf+0x4c>
        putc(fd, c);
 60e:	85ca                	mv	a1,s2
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	efe080e7          	jalr	-258(ra) # 510 <putc>
 61a:	a019                	j	620 <vprintf+0x42>
    } else if(state == '%'){
 61c:	01498d63          	beq	s3,s4,636 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 620:	0485                	add	s1,s1,1
 622:	fff4c903          	lbu	s2,-1(s1)
 626:	16090763          	beqz	s2,794 <vprintf+0x1b6>
    if(state == 0){
 62a:	fe0999e3          	bnez	s3,61c <vprintf+0x3e>
      if(c == '%'){
 62e:	ff4910e3          	bne	s2,s4,60e <vprintf+0x30>
        state = '%';
 632:	89d2                	mv	s3,s4
 634:	b7f5                	j	620 <vprintf+0x42>
      if(c == 'd'){
 636:	13490463          	beq	s2,s4,75e <vprintf+0x180>
 63a:	f9d9079b          	addw	a5,s2,-99
 63e:	0ff7f793          	zext.b	a5,a5
 642:	12fb6763          	bltu	s6,a5,770 <vprintf+0x192>
 646:	f9d9079b          	addw	a5,s2,-99
 64a:	0ff7f713          	zext.b	a4,a5
 64e:	12eb6163          	bltu	s6,a4,770 <vprintf+0x192>
 652:	00271793          	sll	a5,a4,0x2
 656:	00000717          	auipc	a4,0x0
 65a:	3ca70713          	add	a4,a4,970 # a20 <malloc+0x190>
 65e:	97ba                	add	a5,a5,a4
 660:	439c                	lw	a5,0(a5)
 662:	97ba                	add	a5,a5,a4
 664:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 666:	008b8913          	add	s2,s7,8
 66a:	4685                	li	a3,1
 66c:	4629                	li	a2,10
 66e:	000ba583          	lw	a1,0(s7)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	ebe080e7          	jalr	-322(ra) # 532 <printint>
 67c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 67e:	4981                	li	s3,0
 680:	b745                	j	620 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 682:	008b8913          	add	s2,s7,8
 686:	4681                	li	a3,0
 688:	4629                	li	a2,10
 68a:	000ba583          	lw	a1,0(s7)
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	ea2080e7          	jalr	-350(ra) # 532 <printint>
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b751                	j	620 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 69e:	008b8913          	add	s2,s7,8
 6a2:	4681                	li	a3,0
 6a4:	4641                	li	a2,16
 6a6:	000ba583          	lw	a1,0(s7)
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	e86080e7          	jalr	-378(ra) # 532 <printint>
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	b7a5                	j	620 <vprintf+0x42>
 6ba:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6bc:	008b8c13          	add	s8,s7,8
 6c0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6c4:	03000593          	li	a1,48
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e46080e7          	jalr	-442(ra) # 510 <putc>
  putc(fd, 'x');
 6d2:	07800593          	li	a1,120
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e38080e7          	jalr	-456(ra) # 510 <putc>
 6e0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e2:	00000b97          	auipc	s7,0x0
 6e6:	396b8b93          	add	s7,s7,918 # a78 <digits>
 6ea:	03c9d793          	srl	a5,s3,0x3c
 6ee:	97de                	add	a5,a5,s7
 6f0:	0007c583          	lbu	a1,0(a5)
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	e1a080e7          	jalr	-486(ra) # 510 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fe:	0992                	sll	s3,s3,0x4
 700:	397d                	addw	s2,s2,-1
 702:	fe0914e3          	bnez	s2,6ea <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 706:	8be2                	mv	s7,s8
      state = 0;
 708:	4981                	li	s3,0
 70a:	6c02                	ld	s8,0(sp)
 70c:	bf11                	j	620 <vprintf+0x42>
        s = va_arg(ap, char*);
 70e:	008b8993          	add	s3,s7,8
 712:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 716:	02090163          	beqz	s2,738 <vprintf+0x15a>
        while(*s != 0){
 71a:	00094583          	lbu	a1,0(s2)
 71e:	c9a5                	beqz	a1,78e <vprintf+0x1b0>
          putc(fd, *s);
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	dee080e7          	jalr	-530(ra) # 510 <putc>
          s++;
 72a:	0905                	add	s2,s2,1
        while(*s != 0){
 72c:	00094583          	lbu	a1,0(s2)
 730:	f9e5                	bnez	a1,720 <vprintf+0x142>
        s = va_arg(ap, char*);
 732:	8bce                	mv	s7,s3
      state = 0;
 734:	4981                	li	s3,0
 736:	b5ed                	j	620 <vprintf+0x42>
          s = "(null)";
 738:	00000917          	auipc	s2,0x0
 73c:	2e090913          	add	s2,s2,736 # a18 <malloc+0x188>
        while(*s != 0){
 740:	02800593          	li	a1,40
 744:	bff1                	j	720 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 746:	008b8913          	add	s2,s7,8
 74a:	000bc583          	lbu	a1,0(s7)
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	dc0080e7          	jalr	-576(ra) # 510 <putc>
 758:	8bca                	mv	s7,s2
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b5d1                	j	620 <vprintf+0x42>
        putc(fd, c);
 75e:	02500593          	li	a1,37
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	dac080e7          	jalr	-596(ra) # 510 <putc>
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bd4d                	j	620 <vprintf+0x42>
        putc(fd, '%');
 770:	02500593          	li	a1,37
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	d9a080e7          	jalr	-614(ra) # 510 <putc>
        putc(fd, c);
 77e:	85ca                	mv	a1,s2
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	d8e080e7          	jalr	-626(ra) # 510 <putc>
      state = 0;
 78a:	4981                	li	s3,0
 78c:	bd51                	j	620 <vprintf+0x42>
        s = va_arg(ap, char*);
 78e:	8bce                	mv	s7,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	b579                	j	620 <vprintf+0x42>
 794:	74e2                	ld	s1,56(sp)
 796:	79a2                	ld	s3,40(sp)
 798:	7a02                	ld	s4,32(sp)
 79a:	6ae2                	ld	s5,24(sp)
 79c:	6b42                	ld	s6,16(sp)
 79e:	6ba2                	ld	s7,8(sp)
    }
  }
}
 7a0:	60a6                	ld	ra,72(sp)
 7a2:	6406                	ld	s0,64(sp)
 7a4:	7942                	ld	s2,48(sp)
 7a6:	6161                	add	sp,sp,80
 7a8:	8082                	ret

00000000000007aa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7aa:	715d                	add	sp,sp,-80
 7ac:	ec06                	sd	ra,24(sp)
 7ae:	e822                	sd	s0,16(sp)
 7b0:	1000                	add	s0,sp,32
 7b2:	e010                	sd	a2,0(s0)
 7b4:	e414                	sd	a3,8(s0)
 7b6:	e818                	sd	a4,16(s0)
 7b8:	ec1c                	sd	a5,24(s0)
 7ba:	03043023          	sd	a6,32(s0)
 7be:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c6:	8622                	mv	a2,s0
 7c8:	00000097          	auipc	ra,0x0
 7cc:	e16080e7          	jalr	-490(ra) # 5de <vprintf>
}
 7d0:	60e2                	ld	ra,24(sp)
 7d2:	6442                	ld	s0,16(sp)
 7d4:	6161                	add	sp,sp,80
 7d6:	8082                	ret

00000000000007d8 <printf>:

void
printf(const char *fmt, ...)
{
 7d8:	711d                	add	sp,sp,-96
 7da:	ec06                	sd	ra,24(sp)
 7dc:	e822                	sd	s0,16(sp)
 7de:	1000                	add	s0,sp,32
 7e0:	e40c                	sd	a1,8(s0)
 7e2:	e810                	sd	a2,16(s0)
 7e4:	ec14                	sd	a3,24(s0)
 7e6:	f018                	sd	a4,32(s0)
 7e8:	f41c                	sd	a5,40(s0)
 7ea:	03043823          	sd	a6,48(s0)
 7ee:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f2:	00840613          	add	a2,s0,8
 7f6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7fa:	85aa                	mv	a1,a0
 7fc:	4505                	li	a0,1
 7fe:	00000097          	auipc	ra,0x0
 802:	de0080e7          	jalr	-544(ra) # 5de <vprintf>
}
 806:	60e2                	ld	ra,24(sp)
 808:	6442                	ld	s0,16(sp)
 80a:	6125                	add	sp,sp,96
 80c:	8082                	ret

000000000000080e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80e:	1141                	add	sp,sp,-16
 810:	e422                	sd	s0,8(sp)
 812:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 814:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 818:	00000797          	auipc	a5,0x0
 81c:	7e87b783          	ld	a5,2024(a5) # 1000 <freep>
 820:	a02d                	j	84a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 822:	4618                	lw	a4,8(a2)
 824:	9f2d                	addw	a4,a4,a1
 826:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 82a:	6398                	ld	a4,0(a5)
 82c:	6310                	ld	a2,0(a4)
 82e:	a83d                	j	86c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 830:	ff852703          	lw	a4,-8(a0)
 834:	9f31                	addw	a4,a4,a2
 836:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 838:	ff053683          	ld	a3,-16(a0)
 83c:	a091                	j	880 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83e:	6398                	ld	a4,0(a5)
 840:	00e7e463          	bltu	a5,a4,848 <free+0x3a>
 844:	00e6ea63          	bltu	a3,a4,858 <free+0x4a>
{
 848:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84a:	fed7fae3          	bgeu	a5,a3,83e <free+0x30>
 84e:	6398                	ld	a4,0(a5)
 850:	00e6e463          	bltu	a3,a4,858 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 854:	fee7eae3          	bltu	a5,a4,848 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 858:	ff852583          	lw	a1,-8(a0)
 85c:	6390                	ld	a2,0(a5)
 85e:	02059813          	sll	a6,a1,0x20
 862:	01c85713          	srl	a4,a6,0x1c
 866:	9736                	add	a4,a4,a3
 868:	fae60de3          	beq	a2,a4,822 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 86c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 870:	4790                	lw	a2,8(a5)
 872:	02061593          	sll	a1,a2,0x20
 876:	01c5d713          	srl	a4,a1,0x1c
 87a:	973e                	add	a4,a4,a5
 87c:	fae68ae3          	beq	a3,a4,830 <free+0x22>
    p->s.ptr = bp->s.ptr;
 880:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 882:	00000717          	auipc	a4,0x0
 886:	76f73f23          	sd	a5,1918(a4) # 1000 <freep>
}
 88a:	6422                	ld	s0,8(sp)
 88c:	0141                	add	sp,sp,16
 88e:	8082                	ret

0000000000000890 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 890:	7139                	add	sp,sp,-64
 892:	fc06                	sd	ra,56(sp)
 894:	f822                	sd	s0,48(sp)
 896:	f426                	sd	s1,40(sp)
 898:	ec4e                	sd	s3,24(sp)
 89a:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89c:	02051493          	sll	s1,a0,0x20
 8a0:	9081                	srl	s1,s1,0x20
 8a2:	04bd                	add	s1,s1,15
 8a4:	8091                	srl	s1,s1,0x4
 8a6:	0014899b          	addw	s3,s1,1
 8aa:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 8ac:	00000517          	auipc	a0,0x0
 8b0:	75453503          	ld	a0,1876(a0) # 1000 <freep>
 8b4:	c915                	beqz	a0,8e8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b8:	4798                	lw	a4,8(a5)
 8ba:	08977e63          	bgeu	a4,s1,956 <malloc+0xc6>
 8be:	f04a                	sd	s2,32(sp)
 8c0:	e852                	sd	s4,16(sp)
 8c2:	e456                	sd	s5,8(sp)
 8c4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8c6:	8a4e                	mv	s4,s3
 8c8:	0009871b          	sext.w	a4,s3
 8cc:	6685                	lui	a3,0x1
 8ce:	00d77363          	bgeu	a4,a3,8d4 <malloc+0x44>
 8d2:	6a05                	lui	s4,0x1
 8d4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d8:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8dc:	00000917          	auipc	s2,0x0
 8e0:	72490913          	add	s2,s2,1828 # 1000 <freep>
  if(p == (char*)-1)
 8e4:	5afd                	li	s5,-1
 8e6:	a091                	j	92a <malloc+0x9a>
 8e8:	f04a                	sd	s2,32(sp)
 8ea:	e852                	sd	s4,16(sp)
 8ec:	e456                	sd	s5,8(sp)
 8ee:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8f0:	00000797          	auipc	a5,0x0
 8f4:	72078793          	add	a5,a5,1824 # 1010 <base>
 8f8:	00000717          	auipc	a4,0x0
 8fc:	70f73423          	sd	a5,1800(a4) # 1000 <freep>
 900:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 902:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 906:	b7c1                	j	8c6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 908:	6398                	ld	a4,0(a5)
 90a:	e118                	sd	a4,0(a0)
 90c:	a08d                	j	96e <malloc+0xde>
  hp->s.size = nu;
 90e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 912:	0541                	add	a0,a0,16
 914:	00000097          	auipc	ra,0x0
 918:	efa080e7          	jalr	-262(ra) # 80e <free>
  return freep;
 91c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 920:	c13d                	beqz	a0,986 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 922:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 924:	4798                	lw	a4,8(a5)
 926:	02977463          	bgeu	a4,s1,94e <malloc+0xbe>
    if(p == freep)
 92a:	00093703          	ld	a4,0(s2)
 92e:	853e                	mv	a0,a5
 930:	fef719e3          	bne	a4,a5,922 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 934:	8552                	mv	a0,s4
 936:	00000097          	auipc	ra,0x0
 93a:	bb2080e7          	jalr	-1102(ra) # 4e8 <sbrk>
  if(p == (char*)-1)
 93e:	fd5518e3          	bne	a0,s5,90e <malloc+0x7e>
        return 0;
 942:	4501                	li	a0,0
 944:	7902                	ld	s2,32(sp)
 946:	6a42                	ld	s4,16(sp)
 948:	6aa2                	ld	s5,8(sp)
 94a:	6b02                	ld	s6,0(sp)
 94c:	a03d                	j	97a <malloc+0xea>
 94e:	7902                	ld	s2,32(sp)
 950:	6a42                	ld	s4,16(sp)
 952:	6aa2                	ld	s5,8(sp)
 954:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 956:	fae489e3          	beq	s1,a4,908 <malloc+0x78>
        p->s.size -= nunits;
 95a:	4137073b          	subw	a4,a4,s3
 95e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 960:	02071693          	sll	a3,a4,0x20
 964:	01c6d713          	srl	a4,a3,0x1c
 968:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 96a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96e:	00000717          	auipc	a4,0x0
 972:	68a73923          	sd	a0,1682(a4) # 1000 <freep>
      return (void*)(p + 1);
 976:	01078513          	add	a0,a5,16
  }
}
 97a:	70e2                	ld	ra,56(sp)
 97c:	7442                	ld	s0,48(sp)
 97e:	74a2                	ld	s1,40(sp)
 980:	69e2                	ld	s3,24(sp)
 982:	6121                	add	sp,sp,64
 984:	8082                	ret
 986:	7902                	ld	s2,32(sp)
 988:	6a42                	ld	s4,16(sp)
 98a:	6aa2                	ld	s5,8(sp)
 98c:	6b02                	ld	s6,0(sp)
 98e:	b7f5                	j	97a <malloc+0xea>
