
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
  5a:	4aa080e7          	jalr	1194(ra) # 500 <setpriority>
  5e:	57fd                	li	a5,-1
  60:	06f50163          	beq	a0,a5,c2 <useless+0x80>
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
  80:	c3678793          	addi	a5,a5,-970 # 48d81c36 <base+0x48d80c26>
  84:	00001a17          	auipc	s4,0x1
  88:	90ca0a13          	addi	s4,s4,-1780 # 990 <malloc+0xea>
  8c:	00f48663          	beq	s1,a5,98 <useless+0x56>
  90:	00001a17          	auipc	s4,0x1
  94:	908a0a13          	addi	s4,s4,-1784 # 998 <malloc+0xf2>
  // Need to print uselesss sum to suppress warning.
  printf("Child pid %d, %s, with priority %d finished. Useless sum: %d\n", getpid(), spent,  priority, sum);
  98:	00000097          	auipc	ra,0x0
  9c:	448080e7          	jalr	1096(ra) # 4e0 <getpid>
  a0:	85aa                	mv	a1,a0
  a2:	874e                	mv	a4,s3
  a4:	86ca                	mv	a3,s2
  a6:	8652                	mv	a2,s4
  a8:	00001517          	auipc	a0,0x1
  ac:	91050513          	addi	a0,a0,-1776 # 9b8 <malloc+0x112>
  b0:	00000097          	auipc	ra,0x0
  b4:	738080e7          	jalr	1848(ra) # 7e8 <printf>
  exit(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	3a6080e7          	jalr	934(ra) # 460 <exit>
    fprintf(2, "setpriority error\n");
  c2:	00001597          	auipc	a1,0x1
  c6:	8de58593          	addi	a1,a1,-1826 # 9a0 <malloc+0xfa>
  ca:	4509                	li	a0,2
  cc:	00000097          	auipc	ra,0x0
  d0:	6ee080e7          	jalr	1774(ra) # 7ba <fprintf>
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
  ea:	41a080e7          	jalr	1050(ra) # 500 <setpriority>
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
  fa:	90290913          	addi	s2,s2,-1790 # 9f8 <malloc+0x152>
  fe:	a03d                	j	12c <main+0x56>
    fprintf(2, "setpriority error\n");
 100:	00001597          	auipc	a1,0x1
 104:	8a058593          	addi	a1,a1,-1888 # 9a0 <malloc+0xfa>
 108:	4509                	li	a0,2
 10a:	00000097          	auipc	ra,0x0
 10e:	6b0080e7          	jalr	1712(ra) # 7ba <fprintf>
 112:	b7cd                	j	f4 <main+0x1e>
      printf("%d failed in fork!\n", getpid());
 114:	00000097          	auipc	ra,0x0
 118:	3cc080e7          	jalr	972(ra) # 4e0 <getpid>
 11c:	85aa                	mv	a1,a0
 11e:	854a                	mv	a0,s2
 120:	00000097          	auipc	ra,0x0
 124:	6c8080e7          	jalr	1736(ra) # 7e8 <printf>
  for (int i=0; i < 4; i++)
 128:	34fd                	addiw	s1,s1,-1
 12a:	c885                	beqz	s1,15a <main+0x84>
    id = fork();
 12c:	00000097          	auipc	ra,0x0
 130:	32c080e7          	jalr	812(ra) # 458 <fork>
    if(id < 0)
 134:	fe0540e3          	bltz	a0,114 <main+0x3e>
    else if(id == 0) {
 138:	f965                	bnez	a0,128 <main+0x52>
      // Child
      int pid = getpid();
 13a:	00000097          	auipc	ra,0x0
 13e:	3a6080e7          	jalr	934(ra) # 4e0 <getpid>
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
 162:	89a98993          	addi	s3,s3,-1894 # 9f8 <malloc+0x152>
 166:	a831                	j	182 <main+0xac>
 168:	00000097          	auipc	ra,0x0
 16c:	378080e7          	jalr	888(ra) # 4e0 <getpid>
 170:	85aa                	mv	a1,a0
 172:	854e                	mv	a0,s3
 174:	00000097          	auipc	ra,0x0
 178:	674080e7          	jalr	1652(ra) # 7e8 <printf>
  for (int i=0; i<n; i++) {
 17c:	397d                	addiw	s2,s2,-1
 17e:	02090963          	beqz	s2,1b0 <main+0xda>
    id = fork();
 182:	00000097          	auipc	ra,0x0
 186:	2d6080e7          	jalr	726(ra) # 458 <fork>
 18a:	84aa                	mv	s1,a0
    if(id < 0)
 18c:	fc054ee3          	bltz	a0,168 <main+0x92>
    else if(id == 0) {
 190:	f575                	bnez	a0,17c <main+0xa6>
      // Child
      //sleep(1);
      int pid = getpid();
 192:	00000097          	auipc	ra,0x0
 196:	34e080e7          	jalr	846(ra) # 4e0 <getpid>
      int priority = pid % 19 + 2; // Priority range: 2-20
 19a:	47cd                	li	a5,19
 19c:	02f5653b          	remw	a0,a0,a5
      useless(priority, SMALL_TIME); // never returns
 1a0:	0748d5b7          	lui	a1,0x748d
 1a4:	1595                	addi	a1,a1,-27
 1a6:	2509                	addiw	a0,a0,2
 1a8:	00000097          	auipc	ra,0x0
 1ac:	e9a080e7          	jalr	-358(ra) # 42 <useless>
    }
  }

  // Father waits for all the children (n+4)
  if (id > 0) {
 1b0:	00905b63          	blez	s1,1c6 <main+0xf0>
 1b4:	02c00493          	li	s1,44
    for (int i = 0; i < n+4; i++) {
      wait((int*)0);
 1b8:	4501                	li	a0,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	2ae080e7          	jalr	686(ra) # 468 <wait>
    for (int i = 0; i < n+4; i++) {
 1c2:	34fd                	addiw	s1,s1,-1
 1c4:	f8f5                	bnez	s1,1b8 <main+0xe2>
    }
  }
  exit(0);
 1c6:	4501                	li	a0,0
 1c8:	00000097          	auipc	ra,0x0
 1cc:	298080e7          	jalr	664(ra) # 460 <exit>

00000000000001d0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e406                	sd	ra,8(sp)
 1d4:	e022                	sd	s0,0(sp)
 1d6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1d8:	00000097          	auipc	ra,0x0
 1dc:	efe080e7          	jalr	-258(ra) # d6 <main>
  exit(0);
 1e0:	4501                	li	a0,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	27e080e7          	jalr	638(ra) # 460 <exit>

00000000000001ea <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f0:	87aa                	mv	a5,a0
 1f2:	0585                	addi	a1,a1,1
 1f4:	0785                	addi	a5,a5,1
 1f6:	fff5c703          	lbu	a4,-1(a1) # 748cfff <base+0x748bfef>
 1fa:	fee78fa3          	sb	a4,-1(a5)
 1fe:	fb75                	bnez	a4,1f2 <strcpy+0x8>
    ;
  return os;
}
 200:	6422                	ld	s0,8(sp)
 202:	0141                	addi	sp,sp,16
 204:	8082                	ret

0000000000000206 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 20c:	00054783          	lbu	a5,0(a0)
 210:	cb91                	beqz	a5,224 <strcmp+0x1e>
 212:	0005c703          	lbu	a4,0(a1)
 216:	00f71763          	bne	a4,a5,224 <strcmp+0x1e>
    p++, q++;
 21a:	0505                	addi	a0,a0,1
 21c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 21e:	00054783          	lbu	a5,0(a0)
 222:	fbe5                	bnez	a5,212 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 224:	0005c503          	lbu	a0,0(a1)
}
 228:	40a7853b          	subw	a0,a5,a0
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret

0000000000000232 <strlen>:

uint
strlen(const char *s)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 238:	00054783          	lbu	a5,0(a0)
 23c:	cf91                	beqz	a5,258 <strlen+0x26>
 23e:	0505                	addi	a0,a0,1
 240:	87aa                	mv	a5,a0
 242:	4685                	li	a3,1
 244:	9e89                	subw	a3,a3,a0
 246:	00f6853b          	addw	a0,a3,a5
 24a:	0785                	addi	a5,a5,1
 24c:	fff7c703          	lbu	a4,-1(a5)
 250:	fb7d                	bnez	a4,246 <strlen+0x14>
    ;
  return n;
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  for(n = 0; s[n]; n++)
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <strlen+0x20>

000000000000025c <memset>:

void*
memset(void *dst, int c, uint n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 262:	ce09                	beqz	a2,27c <memset+0x20>
 264:	87aa                	mv	a5,a0
 266:	fff6071b          	addiw	a4,a2,-1
 26a:	1702                	slli	a4,a4,0x20
 26c:	9301                	srli	a4,a4,0x20
 26e:	0705                	addi	a4,a4,1
 270:	972a                	add	a4,a4,a0
    cdst[i] = c;
 272:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 276:	0785                	addi	a5,a5,1
 278:	fee79de3          	bne	a5,a4,272 <memset+0x16>
  }
  return dst;
}
 27c:	6422                	ld	s0,8(sp)
 27e:	0141                	addi	sp,sp,16
 280:	8082                	ret

0000000000000282 <strchr>:

char*
strchr(const char *s, char c)
{
 282:	1141                	addi	sp,sp,-16
 284:	e422                	sd	s0,8(sp)
 286:	0800                	addi	s0,sp,16
  for(; *s; s++)
 288:	00054783          	lbu	a5,0(a0)
 28c:	cb99                	beqz	a5,2a2 <strchr+0x20>
    if(*s == c)
 28e:	00f58763          	beq	a1,a5,29c <strchr+0x1a>
  for(; *s; s++)
 292:	0505                	addi	a0,a0,1
 294:	00054783          	lbu	a5,0(a0)
 298:	fbfd                	bnez	a5,28e <strchr+0xc>
      return (char*)s;
  return 0;
 29a:	4501                	li	a0,0
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	bfe5                	j	29c <strchr+0x1a>

00000000000002a6 <gets>:

char*
gets(char *buf, int max)
{
 2a6:	711d                	addi	sp,sp,-96
 2a8:	ec86                	sd	ra,88(sp)
 2aa:	e8a2                	sd	s0,80(sp)
 2ac:	e4a6                	sd	s1,72(sp)
 2ae:	e0ca                	sd	s2,64(sp)
 2b0:	fc4e                	sd	s3,56(sp)
 2b2:	f852                	sd	s4,48(sp)
 2b4:	f456                	sd	s5,40(sp)
 2b6:	f05a                	sd	s6,32(sp)
 2b8:	ec5e                	sd	s7,24(sp)
 2ba:	1080                	addi	s0,sp,96
 2bc:	8baa                	mv	s7,a0
 2be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c0:	892a                	mv	s2,a0
 2c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c4:	4aa9                	li	s5,10
 2c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2c8:	89a6                	mv	s3,s1
 2ca:	2485                	addiw	s1,s1,1
 2cc:	0344d863          	bge	s1,s4,2fc <gets+0x56>
    cc = read(0, &c, 1);
 2d0:	4605                	li	a2,1
 2d2:	faf40593          	addi	a1,s0,-81
 2d6:	4501                	li	a0,0
 2d8:	00000097          	auipc	ra,0x0
 2dc:	1a0080e7          	jalr	416(ra) # 478 <read>
    if(cc < 1)
 2e0:	00a05e63          	blez	a0,2fc <gets+0x56>
    buf[i++] = c;
 2e4:	faf44783          	lbu	a5,-81(s0)
 2e8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ec:	01578763          	beq	a5,s5,2fa <gets+0x54>
 2f0:	0905                	addi	s2,s2,1
 2f2:	fd679be3          	bne	a5,s6,2c8 <gets+0x22>
  for(i=0; i+1 < max; ){
 2f6:	89a6                	mv	s3,s1
 2f8:	a011                	j	2fc <gets+0x56>
 2fa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2fc:	99de                	add	s3,s3,s7
 2fe:	00098023          	sb	zero,0(s3)
  return buf;
}
 302:	855e                	mv	a0,s7
 304:	60e6                	ld	ra,88(sp)
 306:	6446                	ld	s0,80(sp)
 308:	64a6                	ld	s1,72(sp)
 30a:	6906                	ld	s2,64(sp)
 30c:	79e2                	ld	s3,56(sp)
 30e:	7a42                	ld	s4,48(sp)
 310:	7aa2                	ld	s5,40(sp)
 312:	7b02                	ld	s6,32(sp)
 314:	6be2                	ld	s7,24(sp)
 316:	6125                	addi	sp,sp,96
 318:	8082                	ret

000000000000031a <stat>:

int
stat(const char *n, struct stat *st)
{
 31a:	1101                	addi	sp,sp,-32
 31c:	ec06                	sd	ra,24(sp)
 31e:	e822                	sd	s0,16(sp)
 320:	e426                	sd	s1,8(sp)
 322:	e04a                	sd	s2,0(sp)
 324:	1000                	addi	s0,sp,32
 326:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 328:	4581                	li	a1,0
 32a:	00000097          	auipc	ra,0x0
 32e:	176080e7          	jalr	374(ra) # 4a0 <open>
  if(fd < 0)
 332:	02054563          	bltz	a0,35c <stat+0x42>
 336:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 338:	85ca                	mv	a1,s2
 33a:	00000097          	auipc	ra,0x0
 33e:	17e080e7          	jalr	382(ra) # 4b8 <fstat>
 342:	892a                	mv	s2,a0
  close(fd);
 344:	8526                	mv	a0,s1
 346:	00000097          	auipc	ra,0x0
 34a:	142080e7          	jalr	322(ra) # 488 <close>
  return r;
}
 34e:	854a                	mv	a0,s2
 350:	60e2                	ld	ra,24(sp)
 352:	6442                	ld	s0,16(sp)
 354:	64a2                	ld	s1,8(sp)
 356:	6902                	ld	s2,0(sp)
 358:	6105                	addi	sp,sp,32
 35a:	8082                	ret
    return -1;
 35c:	597d                	li	s2,-1
 35e:	bfc5                	j	34e <stat+0x34>

0000000000000360 <atoi>:

int
atoi(const char *s)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 366:	00054603          	lbu	a2,0(a0)
 36a:	fd06079b          	addiw	a5,a2,-48
 36e:	0ff7f793          	andi	a5,a5,255
 372:	4725                	li	a4,9
 374:	02f76963          	bltu	a4,a5,3a6 <atoi+0x46>
 378:	86aa                	mv	a3,a0
  n = 0;
 37a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 37c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 37e:	0685                	addi	a3,a3,1
 380:	0025179b          	slliw	a5,a0,0x2
 384:	9fa9                	addw	a5,a5,a0
 386:	0017979b          	slliw	a5,a5,0x1
 38a:	9fb1                	addw	a5,a5,a2
 38c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 390:	0006c603          	lbu	a2,0(a3)
 394:	fd06071b          	addiw	a4,a2,-48
 398:	0ff77713          	andi	a4,a4,255
 39c:	fee5f1e3          	bgeu	a1,a4,37e <atoi+0x1e>
  return n;
}
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret
  n = 0;
 3a6:	4501                	li	a0,0
 3a8:	bfe5                	j	3a0 <atoi+0x40>

00000000000003aa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3aa:	1141                	addi	sp,sp,-16
 3ac:	e422                	sd	s0,8(sp)
 3ae:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b0:	02b57663          	bgeu	a0,a1,3dc <memmove+0x32>
    while(n-- > 0)
 3b4:	02c05163          	blez	a2,3d6 <memmove+0x2c>
 3b8:	fff6079b          	addiw	a5,a2,-1
 3bc:	1782                	slli	a5,a5,0x20
 3be:	9381                	srli	a5,a5,0x20
 3c0:	0785                	addi	a5,a5,1
 3c2:	97aa                	add	a5,a5,a0
  dst = vdst;
 3c4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3c6:	0585                	addi	a1,a1,1
 3c8:	0705                	addi	a4,a4,1
 3ca:	fff5c683          	lbu	a3,-1(a1)
 3ce:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d2:	fee79ae3          	bne	a5,a4,3c6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret
    dst += n;
 3dc:	00c50733          	add	a4,a0,a2
    src += n;
 3e0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e2:	fec05ae3          	blez	a2,3d6 <memmove+0x2c>
 3e6:	fff6079b          	addiw	a5,a2,-1
 3ea:	1782                	slli	a5,a5,0x20
 3ec:	9381                	srli	a5,a5,0x20
 3ee:	fff7c793          	not	a5,a5
 3f2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f4:	15fd                	addi	a1,a1,-1
 3f6:	177d                	addi	a4,a4,-1
 3f8:	0005c683          	lbu	a3,0(a1)
 3fc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 400:	fee79ae3          	bne	a5,a4,3f4 <memmove+0x4a>
 404:	bfc9                	j	3d6 <memmove+0x2c>

0000000000000406 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e422                	sd	s0,8(sp)
 40a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 40c:	ca05                	beqz	a2,43c <memcmp+0x36>
 40e:	fff6069b          	addiw	a3,a2,-1
 412:	1682                	slli	a3,a3,0x20
 414:	9281                	srli	a3,a3,0x20
 416:	0685                	addi	a3,a3,1
 418:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 41a:	00054783          	lbu	a5,0(a0)
 41e:	0005c703          	lbu	a4,0(a1)
 422:	00e79863          	bne	a5,a4,432 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 426:	0505                	addi	a0,a0,1
    p2++;
 428:	0585                	addi	a1,a1,1
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
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret
  return 0;
 43c:	4501                	li	a0,0
 43e:	bfe5                	j	436 <memcmp+0x30>

0000000000000440 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 440:	1141                	addi	sp,sp,-16
 442:	e406                	sd	ra,8(sp)
 444:	e022                	sd	s0,0(sp)
 446:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 448:	00000097          	auipc	ra,0x0
 44c:	f62080e7          	jalr	-158(ra) # 3aa <memmove>
}
 450:	60a2                	ld	ra,8(sp)
 452:	6402                	ld	s0,0(sp)
 454:	0141                	addi	sp,sp,16
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
 510:	1101                	addi	sp,sp,-32
 512:	ec06                	sd	ra,24(sp)
 514:	e822                	sd	s0,16(sp)
 516:	1000                	addi	s0,sp,32
 518:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 51c:	4605                	li	a2,1
 51e:	fef40593          	addi	a1,s0,-17
 522:	00000097          	auipc	ra,0x0
 526:	f5e080e7          	jalr	-162(ra) # 480 <write>
}
 52a:	60e2                	ld	ra,24(sp)
 52c:	6442                	ld	s0,16(sp)
 52e:	6105                	addi	sp,sp,32
 530:	8082                	ret

0000000000000532 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 532:	7139                	addi	sp,sp,-64
 534:	fc06                	sd	ra,56(sp)
 536:	f822                	sd	s0,48(sp)
 538:	f426                	sd	s1,40(sp)
 53a:	f04a                	sd	s2,32(sp)
 53c:	ec4e                	sd	s3,24(sp)
 53e:	0080                	addi	s0,sp,64
 540:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 542:	c299                	beqz	a3,548 <printint+0x16>
 544:	0805c863          	bltz	a1,5d4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 548:	2581                	sext.w	a1,a1
  neg = 0;
 54a:	4881                	li	a7,0
 54c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 550:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 552:	2601                	sext.w	a2,a2
 554:	00000517          	auipc	a0,0x0
 558:	4c450513          	addi	a0,a0,1220 # a18 <digits>
 55c:	883a                	mv	a6,a4
 55e:	2705                	addiw	a4,a4,1
 560:	02c5f7bb          	remuw	a5,a1,a2
 564:	1782                	slli	a5,a5,0x20
 566:	9381                	srli	a5,a5,0x20
 568:	97aa                	add	a5,a5,a0
 56a:	0007c783          	lbu	a5,0(a5)
 56e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 572:	0005879b          	sext.w	a5,a1
 576:	02c5d5bb          	divuw	a1,a1,a2
 57a:	0685                	addi	a3,a3,1
 57c:	fec7f0e3          	bgeu	a5,a2,55c <printint+0x2a>
  if(neg)
 580:	00088b63          	beqz	a7,596 <printint+0x64>
    buf[i++] = '-';
 584:	fd040793          	addi	a5,s0,-48
 588:	973e                	add	a4,a4,a5
 58a:	02d00793          	li	a5,45
 58e:	fef70823          	sb	a5,-16(a4)
 592:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 596:	02e05863          	blez	a4,5c6 <printint+0x94>
 59a:	fc040793          	addi	a5,s0,-64
 59e:	00e78933          	add	s2,a5,a4
 5a2:	fff78993          	addi	s3,a5,-1
 5a6:	99ba                	add	s3,s3,a4
 5a8:	377d                	addiw	a4,a4,-1
 5aa:	1702                	slli	a4,a4,0x20
 5ac:	9301                	srli	a4,a4,0x20
 5ae:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5b2:	fff94583          	lbu	a1,-1(s2)
 5b6:	8526                	mv	a0,s1
 5b8:	00000097          	auipc	ra,0x0
 5bc:	f58080e7          	jalr	-168(ra) # 510 <putc>
  while(--i >= 0)
 5c0:	197d                	addi	s2,s2,-1
 5c2:	ff3918e3          	bne	s2,s3,5b2 <printint+0x80>
}
 5c6:	70e2                	ld	ra,56(sp)
 5c8:	7442                	ld	s0,48(sp)
 5ca:	74a2                	ld	s1,40(sp)
 5cc:	7902                	ld	s2,32(sp)
 5ce:	69e2                	ld	s3,24(sp)
 5d0:	6121                	addi	sp,sp,64
 5d2:	8082                	ret
    x = -xx;
 5d4:	40b005bb          	negw	a1,a1
    neg = 1;
 5d8:	4885                	li	a7,1
    x = -xx;
 5da:	bf8d                	j	54c <printint+0x1a>

00000000000005dc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5dc:	7119                	addi	sp,sp,-128
 5de:	fc86                	sd	ra,120(sp)
 5e0:	f8a2                	sd	s0,112(sp)
 5e2:	f4a6                	sd	s1,104(sp)
 5e4:	f0ca                	sd	s2,96(sp)
 5e6:	ecce                	sd	s3,88(sp)
 5e8:	e8d2                	sd	s4,80(sp)
 5ea:	e4d6                	sd	s5,72(sp)
 5ec:	e0da                	sd	s6,64(sp)
 5ee:	fc5e                	sd	s7,56(sp)
 5f0:	f862                	sd	s8,48(sp)
 5f2:	f466                	sd	s9,40(sp)
 5f4:	f06a                	sd	s10,32(sp)
 5f6:	ec6e                	sd	s11,24(sp)
 5f8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5fa:	0005c903          	lbu	s2,0(a1)
 5fe:	18090f63          	beqz	s2,79c <vprintf+0x1c0>
 602:	8aaa                	mv	s5,a0
 604:	8b32                	mv	s6,a2
 606:	00158493          	addi	s1,a1,1
  state = 0;
 60a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 60c:	02500a13          	li	s4,37
      if(c == 'd'){
 610:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 614:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 618:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 61c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 620:	00000b97          	auipc	s7,0x0
 624:	3f8b8b93          	addi	s7,s7,1016 # a18 <digits>
 628:	a839                	j	646 <vprintf+0x6a>
        putc(fd, c);
 62a:	85ca                	mv	a1,s2
 62c:	8556                	mv	a0,s5
 62e:	00000097          	auipc	ra,0x0
 632:	ee2080e7          	jalr	-286(ra) # 510 <putc>
 636:	a019                	j	63c <vprintf+0x60>
    } else if(state == '%'){
 638:	01498f63          	beq	s3,s4,656 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 63c:	0485                	addi	s1,s1,1
 63e:	fff4c903          	lbu	s2,-1(s1)
 642:	14090d63          	beqz	s2,79c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 646:	0009079b          	sext.w	a5,s2
    if(state == 0){
 64a:	fe0997e3          	bnez	s3,638 <vprintf+0x5c>
      if(c == '%'){
 64e:	fd479ee3          	bne	a5,s4,62a <vprintf+0x4e>
        state = '%';
 652:	89be                	mv	s3,a5
 654:	b7e5                	j	63c <vprintf+0x60>
      if(c == 'd'){
 656:	05878063          	beq	a5,s8,696 <vprintf+0xba>
      } else if(c == 'l') {
 65a:	05978c63          	beq	a5,s9,6b2 <vprintf+0xd6>
      } else if(c == 'x') {
 65e:	07a78863          	beq	a5,s10,6ce <vprintf+0xf2>
      } else if(c == 'p') {
 662:	09b78463          	beq	a5,s11,6ea <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 666:	07300713          	li	a4,115
 66a:	0ce78663          	beq	a5,a4,736 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 66e:	06300713          	li	a4,99
 672:	0ee78e63          	beq	a5,a4,76e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 676:	11478863          	beq	a5,s4,786 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 67a:	85d2                	mv	a1,s4
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e92080e7          	jalr	-366(ra) # 510 <putc>
        putc(fd, c);
 686:	85ca                	mv	a1,s2
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e86080e7          	jalr	-378(ra) # 510 <putc>
      }
      state = 0;
 692:	4981                	li	s3,0
 694:	b765                	j	63c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 696:	008b0913          	addi	s2,s6,8
 69a:	4685                	li	a3,1
 69c:	4629                	li	a2,10
 69e:	000b2583          	lw	a1,0(s6)
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	e8e080e7          	jalr	-370(ra) # 532 <printint>
 6ac:	8b4a                	mv	s6,s2
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	b771                	j	63c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b2:	008b0913          	addi	s2,s6,8
 6b6:	4681                	li	a3,0
 6b8:	4629                	li	a2,10
 6ba:	000b2583          	lw	a1,0(s6)
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e72080e7          	jalr	-398(ra) # 532 <printint>
 6c8:	8b4a                	mv	s6,s2
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	bf85                	j	63c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ce:	008b0913          	addi	s2,s6,8
 6d2:	4681                	li	a3,0
 6d4:	4641                	li	a2,16
 6d6:	000b2583          	lw	a1,0(s6)
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	e56080e7          	jalr	-426(ra) # 532 <printint>
 6e4:	8b4a                	mv	s6,s2
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	bf91                	j	63c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6ea:	008b0793          	addi	a5,s6,8
 6ee:	f8f43423          	sd	a5,-120(s0)
 6f2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6f6:	03000593          	li	a1,48
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	e14080e7          	jalr	-492(ra) # 510 <putc>
  putc(fd, 'x');
 704:	85ea                	mv	a1,s10
 706:	8556                	mv	a0,s5
 708:	00000097          	auipc	ra,0x0
 70c:	e08080e7          	jalr	-504(ra) # 510 <putc>
 710:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 712:	03c9d793          	srli	a5,s3,0x3c
 716:	97de                	add	a5,a5,s7
 718:	0007c583          	lbu	a1,0(a5)
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	df2080e7          	jalr	-526(ra) # 510 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 726:	0992                	slli	s3,s3,0x4
 728:	397d                	addiw	s2,s2,-1
 72a:	fe0914e3          	bnez	s2,712 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 72e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 732:	4981                	li	s3,0
 734:	b721                	j	63c <vprintf+0x60>
        s = va_arg(ap, char*);
 736:	008b0993          	addi	s3,s6,8
 73a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 73e:	02090163          	beqz	s2,760 <vprintf+0x184>
        while(*s != 0){
 742:	00094583          	lbu	a1,0(s2)
 746:	c9a1                	beqz	a1,796 <vprintf+0x1ba>
          putc(fd, *s);
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	dc6080e7          	jalr	-570(ra) # 510 <putc>
          s++;
 752:	0905                	addi	s2,s2,1
        while(*s != 0){
 754:	00094583          	lbu	a1,0(s2)
 758:	f9e5                	bnez	a1,748 <vprintf+0x16c>
        s = va_arg(ap, char*);
 75a:	8b4e                	mv	s6,s3
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bdf9                	j	63c <vprintf+0x60>
          s = "(null)";
 760:	00000917          	auipc	s2,0x0
 764:	2b090913          	addi	s2,s2,688 # a10 <malloc+0x16a>
        while(*s != 0){
 768:	02800593          	li	a1,40
 76c:	bff1                	j	748 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 76e:	008b0913          	addi	s2,s6,8
 772:	000b4583          	lbu	a1,0(s6)
 776:	8556                	mv	a0,s5
 778:	00000097          	auipc	ra,0x0
 77c:	d98080e7          	jalr	-616(ra) # 510 <putc>
 780:	8b4a                	mv	s6,s2
      state = 0;
 782:	4981                	li	s3,0
 784:	bd65                	j	63c <vprintf+0x60>
        putc(fd, c);
 786:	85d2                	mv	a1,s4
 788:	8556                	mv	a0,s5
 78a:	00000097          	auipc	ra,0x0
 78e:	d86080e7          	jalr	-634(ra) # 510 <putc>
      state = 0;
 792:	4981                	li	s3,0
 794:	b565                	j	63c <vprintf+0x60>
        s = va_arg(ap, char*);
 796:	8b4e                	mv	s6,s3
      state = 0;
 798:	4981                	li	s3,0
 79a:	b54d                	j	63c <vprintf+0x60>
    }
  }
}
 79c:	70e6                	ld	ra,120(sp)
 79e:	7446                	ld	s0,112(sp)
 7a0:	74a6                	ld	s1,104(sp)
 7a2:	7906                	ld	s2,96(sp)
 7a4:	69e6                	ld	s3,88(sp)
 7a6:	6a46                	ld	s4,80(sp)
 7a8:	6aa6                	ld	s5,72(sp)
 7aa:	6b06                	ld	s6,64(sp)
 7ac:	7be2                	ld	s7,56(sp)
 7ae:	7c42                	ld	s8,48(sp)
 7b0:	7ca2                	ld	s9,40(sp)
 7b2:	7d02                	ld	s10,32(sp)
 7b4:	6de2                	ld	s11,24(sp)
 7b6:	6109                	addi	sp,sp,128
 7b8:	8082                	ret

00000000000007ba <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ba:	715d                	addi	sp,sp,-80
 7bc:	ec06                	sd	ra,24(sp)
 7be:	e822                	sd	s0,16(sp)
 7c0:	1000                	addi	s0,sp,32
 7c2:	e010                	sd	a2,0(s0)
 7c4:	e414                	sd	a3,8(s0)
 7c6:	e818                	sd	a4,16(s0)
 7c8:	ec1c                	sd	a5,24(s0)
 7ca:	03043023          	sd	a6,32(s0)
 7ce:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d6:	8622                	mv	a2,s0
 7d8:	00000097          	auipc	ra,0x0
 7dc:	e04080e7          	jalr	-508(ra) # 5dc <vprintf>
}
 7e0:	60e2                	ld	ra,24(sp)
 7e2:	6442                	ld	s0,16(sp)
 7e4:	6161                	addi	sp,sp,80
 7e6:	8082                	ret

00000000000007e8 <printf>:

void
printf(const char *fmt, ...)
{
 7e8:	711d                	addi	sp,sp,-96
 7ea:	ec06                	sd	ra,24(sp)
 7ec:	e822                	sd	s0,16(sp)
 7ee:	1000                	addi	s0,sp,32
 7f0:	e40c                	sd	a1,8(s0)
 7f2:	e810                	sd	a2,16(s0)
 7f4:	ec14                	sd	a3,24(s0)
 7f6:	f018                	sd	a4,32(s0)
 7f8:	f41c                	sd	a5,40(s0)
 7fa:	03043823          	sd	a6,48(s0)
 7fe:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 802:	00840613          	addi	a2,s0,8
 806:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 80a:	85aa                	mv	a1,a0
 80c:	4505                	li	a0,1
 80e:	00000097          	auipc	ra,0x0
 812:	dce080e7          	jalr	-562(ra) # 5dc <vprintf>
}
 816:	60e2                	ld	ra,24(sp)
 818:	6442                	ld	s0,16(sp)
 81a:	6125                	addi	sp,sp,96
 81c:	8082                	ret

000000000000081e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 81e:	1141                	addi	sp,sp,-16
 820:	e422                	sd	s0,8(sp)
 822:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 824:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 828:	00000797          	auipc	a5,0x0
 82c:	7d87b783          	ld	a5,2008(a5) # 1000 <freep>
 830:	a805                	j	860 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 832:	4618                	lw	a4,8(a2)
 834:	9db9                	addw	a1,a1,a4
 836:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83a:	6398                	ld	a4,0(a5)
 83c:	6318                	ld	a4,0(a4)
 83e:	fee53823          	sd	a4,-16(a0)
 842:	a091                	j	886 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 844:	ff852703          	lw	a4,-8(a0)
 848:	9e39                	addw	a2,a2,a4
 84a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 84c:	ff053703          	ld	a4,-16(a0)
 850:	e398                	sd	a4,0(a5)
 852:	a099                	j	898 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 854:	6398                	ld	a4,0(a5)
 856:	00e7e463          	bltu	a5,a4,85e <free+0x40>
 85a:	00e6ea63          	bltu	a3,a4,86e <free+0x50>
{
 85e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 860:	fed7fae3          	bgeu	a5,a3,854 <free+0x36>
 864:	6398                	ld	a4,0(a5)
 866:	00e6e463          	bltu	a3,a4,86e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86a:	fee7eae3          	bltu	a5,a4,85e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 86e:	ff852583          	lw	a1,-8(a0)
 872:	6390                	ld	a2,0(a5)
 874:	02059713          	slli	a4,a1,0x20
 878:	9301                	srli	a4,a4,0x20
 87a:	0712                	slli	a4,a4,0x4
 87c:	9736                	add	a4,a4,a3
 87e:	fae60ae3          	beq	a2,a4,832 <free+0x14>
    bp->s.ptr = p->s.ptr;
 882:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 886:	4790                	lw	a2,8(a5)
 888:	02061713          	slli	a4,a2,0x20
 88c:	9301                	srli	a4,a4,0x20
 88e:	0712                	slli	a4,a4,0x4
 890:	973e                	add	a4,a4,a5
 892:	fae689e3          	beq	a3,a4,844 <free+0x26>
  } else
    p->s.ptr = bp;
 896:	e394                	sd	a3,0(a5)
  freep = p;
 898:	00000717          	auipc	a4,0x0
 89c:	76f73423          	sd	a5,1896(a4) # 1000 <freep>
}
 8a0:	6422                	ld	s0,8(sp)
 8a2:	0141                	addi	sp,sp,16
 8a4:	8082                	ret

00000000000008a6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a6:	7139                	addi	sp,sp,-64
 8a8:	fc06                	sd	ra,56(sp)
 8aa:	f822                	sd	s0,48(sp)
 8ac:	f426                	sd	s1,40(sp)
 8ae:	f04a                	sd	s2,32(sp)
 8b0:	ec4e                	sd	s3,24(sp)
 8b2:	e852                	sd	s4,16(sp)
 8b4:	e456                	sd	s5,8(sp)
 8b6:	e05a                	sd	s6,0(sp)
 8b8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ba:	02051493          	slli	s1,a0,0x20
 8be:	9081                	srli	s1,s1,0x20
 8c0:	04bd                	addi	s1,s1,15
 8c2:	8091                	srli	s1,s1,0x4
 8c4:	0014899b          	addiw	s3,s1,1
 8c8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ca:	00000517          	auipc	a0,0x0
 8ce:	73653503          	ld	a0,1846(a0) # 1000 <freep>
 8d2:	c515                	beqz	a0,8fe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d6:	4798                	lw	a4,8(a5)
 8d8:	02977f63          	bgeu	a4,s1,916 <malloc+0x70>
 8dc:	8a4e                	mv	s4,s3
 8de:	0009871b          	sext.w	a4,s3
 8e2:	6685                	lui	a3,0x1
 8e4:	00d77363          	bgeu	a4,a3,8ea <malloc+0x44>
 8e8:	6a05                	lui	s4,0x1
 8ea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f2:	00000917          	auipc	s2,0x0
 8f6:	70e90913          	addi	s2,s2,1806 # 1000 <freep>
  if(p == (char*)-1)
 8fa:	5afd                	li	s5,-1
 8fc:	a88d                	j	96e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8fe:	00000797          	auipc	a5,0x0
 902:	71278793          	addi	a5,a5,1810 # 1010 <base>
 906:	00000717          	auipc	a4,0x0
 90a:	6ef73d23          	sd	a5,1786(a4) # 1000 <freep>
 90e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 910:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 914:	b7e1                	j	8dc <malloc+0x36>
      if(p->s.size == nunits)
 916:	02e48b63          	beq	s1,a4,94c <malloc+0xa6>
        p->s.size -= nunits;
 91a:	4137073b          	subw	a4,a4,s3
 91e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 920:	1702                	slli	a4,a4,0x20
 922:	9301                	srli	a4,a4,0x20
 924:	0712                	slli	a4,a4,0x4
 926:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 928:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92c:	00000717          	auipc	a4,0x0
 930:	6ca73a23          	sd	a0,1748(a4) # 1000 <freep>
      return (void*)(p + 1);
 934:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 938:	70e2                	ld	ra,56(sp)
 93a:	7442                	ld	s0,48(sp)
 93c:	74a2                	ld	s1,40(sp)
 93e:	7902                	ld	s2,32(sp)
 940:	69e2                	ld	s3,24(sp)
 942:	6a42                	ld	s4,16(sp)
 944:	6aa2                	ld	s5,8(sp)
 946:	6b02                	ld	s6,0(sp)
 948:	6121                	addi	sp,sp,64
 94a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 94c:	6398                	ld	a4,0(a5)
 94e:	e118                	sd	a4,0(a0)
 950:	bff1                	j	92c <malloc+0x86>
  hp->s.size = nu;
 952:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 956:	0541                	addi	a0,a0,16
 958:	00000097          	auipc	ra,0x0
 95c:	ec6080e7          	jalr	-314(ra) # 81e <free>
  return freep;
 960:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 964:	d971                	beqz	a0,938 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 966:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 968:	4798                	lw	a4,8(a5)
 96a:	fa9776e3          	bgeu	a4,s1,916 <malloc+0x70>
    if(p == freep)
 96e:	00093703          	ld	a4,0(s2)
 972:	853e                	mv	a0,a5
 974:	fef719e3          	bne	a4,a5,966 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 978:	8552                	mv	a0,s4
 97a:	00000097          	auipc	ra,0x0
 97e:	b6e080e7          	jalr	-1170(ra) # 4e8 <sbrk>
  if(p == (char*)-1)
 982:	fd5518e3          	bne	a0,s5,952 <malloc+0xac>
        return 0;
 986:	4501                	li	a0,0
 988:	bf45                	j	938 <malloc+0x92>
