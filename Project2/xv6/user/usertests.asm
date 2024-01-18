
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	add	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	add	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	sll	a0,a0,0x1f
      10:	00006097          	auipc	ra,0x6
      14:	c2c080e7          	jalr	-980(ra) # 5c3c <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00006097          	auipc	ra,0x6
      26:	c1a080e7          	jalr	-998(ra) # 5c3c <open>
    if(fd >= 0){
      2a:	55fd                	li	a1,-1
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	add	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	sll	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	0f250513          	add	a0,a0,242 # 6130 <malloc+0x104>
      46:	00006097          	auipc	ra,0x6
      4a:	f2e080e7          	jalr	-210(ra) # 5f74 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00006097          	auipc	ra,0x6
      54:	bac080e7          	jalr	-1108(ra) # 5bfc <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	0000a797          	auipc	a5,0xa
      5c:	51078793          	add	a5,a5,1296 # a568 <uninit>
      60:	0000d697          	auipc	a3,0xd
      64:	c1868693          	add	a3,a3,-1000 # cc78 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	add	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	add	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	add	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	0d050513          	add	a0,a0,208 # 6150 <malloc+0x124>
      88:	00006097          	auipc	ra,0x6
      8c:	eec080e7          	jalr	-276(ra) # 5f74 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00006097          	auipc	ra,0x6
      96:	b6a080e7          	jalr	-1174(ra) # 5bfc <exit>

000000000000009a <opentest>:
{
      9a:	1101                	add	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	add	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	0c050513          	add	a0,a0,192 # 6168 <malloc+0x13c>
      b0:	00006097          	auipc	ra,0x6
      b4:	b8c080e7          	jalr	-1140(ra) # 5c3c <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00006097          	auipc	ra,0x6
      c0:	b68080e7          	jalr	-1176(ra) # 5c24 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	0c250513          	add	a0,a0,194 # 6188 <malloc+0x15c>
      ce:	00006097          	auipc	ra,0x6
      d2:	b6e080e7          	jalr	-1170(ra) # 5c3c <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	add	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	08a50513          	add	a0,a0,138 # 6170 <malloc+0x144>
      ee:	00006097          	auipc	ra,0x6
      f2:	e86080e7          	jalr	-378(ra) # 5f74 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00006097          	auipc	ra,0x6
      fc:	b04080e7          	jalr	-1276(ra) # 5bfc <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	09650513          	add	a0,a0,150 # 6198 <malloc+0x16c>
     10a:	00006097          	auipc	ra,0x6
     10e:	e6a080e7          	jalr	-406(ra) # 5f74 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00006097          	auipc	ra,0x6
     118:	ae8080e7          	jalr	-1304(ra) # 5bfc <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	add	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	add	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	09450513          	add	a0,a0,148 # 61c0 <malloc+0x194>
     134:	00006097          	auipc	ra,0x6
     138:	b18080e7          	jalr	-1256(ra) # 5c4c <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	08050513          	add	a0,a0,128 # 61c0 <malloc+0x194>
     148:	00006097          	auipc	ra,0x6
     14c:	af4080e7          	jalr	-1292(ra) # 5c3c <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	07c58593          	add	a1,a1,124 # 61d0 <malloc+0x1a4>
     15c:	00006097          	auipc	ra,0x6
     160:	ac0080e7          	jalr	-1344(ra) # 5c1c <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	05850513          	add	a0,a0,88 # 61c0 <malloc+0x194>
     170:	00006097          	auipc	ra,0x6
     174:	acc080e7          	jalr	-1332(ra) # 5c3c <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	05c58593          	add	a1,a1,92 # 61d8 <malloc+0x1ac>
     184:	8526                	mv	a0,s1
     186:	00006097          	auipc	ra,0x6
     18a:	a96080e7          	jalr	-1386(ra) # 5c1c <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	02c50513          	add	a0,a0,44 # 61c0 <malloc+0x194>
     19c:	00006097          	auipc	ra,0x6
     1a0:	ab0080e7          	jalr	-1360(ra) # 5c4c <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00006097          	auipc	ra,0x6
     1aa:	a7e080e7          	jalr	-1410(ra) # 5c24 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00006097          	auipc	ra,0x6
     1b4:	a74080e7          	jalr	-1420(ra) # 5c24 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	add	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	01650513          	add	a0,a0,22 # 61e0 <malloc+0x1b4>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	da2080e7          	jalr	-606(ra) # 5f74 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00006097          	auipc	ra,0x6
     1e0:	a20080e7          	jalr	-1504(ra) # 5bfc <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	add	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	add	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	add	a0,s0,-40
     210:	00006097          	auipc	ra,0x6
     214:	a2c080e7          	jalr	-1492(ra) # 5c3c <open>
    close(fd);
     218:	00006097          	auipc	ra,0x6
     21c:	a0c080e7          	jalr	-1524(ra) # 5c24 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addw	s1,s1,1
     222:	0ff4f493          	zext.b	s1,s1
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	add	a0,s0,-40
     246:	00006097          	auipc	ra,0x6
     24a:	a06080e7          	jalr	-1530(ra) # 5c4c <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addw	s1,s1,1
     250:	0ff4f493          	zext.b	s1,s1
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	add	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	add	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	add	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	f8c50513          	add	a0,a0,-116 # 6208 <malloc+0x1dc>
     284:	00006097          	auipc	ra,0x6
     288:	9c8080e7          	jalr	-1592(ra) # 5c4c <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	f78a8a93          	add	s5,s5,-136 # 6208 <malloc+0x1dc>
      int cc = write(fd, buf, sz);
     298:	0000da17          	auipc	s4,0xd
     29c:	9e0a0a13          	add	s4,s4,-1568 # cc78 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	add	s6,s6,457 # 31c9 <fourteen+0x157>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00006097          	auipc	ra,0x6
     2b0:	990080e7          	jalr	-1648(ra) # 5c3c <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00006097          	auipc	ra,0x6
     2c2:	95e080e7          	jalr	-1698(ra) # 5c1c <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49263          	bne	s1,a0,32c <bigwrite+0xc8>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00006097          	auipc	ra,0x6
     2d6:	94a080e7          	jalr	-1718(ra) # 5c1c <write>
      if(cc != sz){
     2da:	04951a63          	bne	a0,s1,32e <bigwrite+0xca>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00006097          	auipc	ra,0x6
     2e4:	944080e7          	jalr	-1724(ra) # 5c24 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00006097          	auipc	ra,0x6
     2ee:	962080e7          	jalr	-1694(ra) # 5c4c <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	add	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	f0650513          	add	a0,a0,-250 # 6218 <malloc+0x1ec>
     31a:	00006097          	auipc	ra,0x6
     31e:	c5a080e7          	jalr	-934(ra) # 5f74 <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00006097          	auipc	ra,0x6
     328:	8d8080e7          	jalr	-1832(ra) # 5bfc <exit>
      if(cc != sz){
     32c:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     32e:	86aa                	mv	a3,a0
     330:	864e                	mv	a2,s3
     332:	85de                	mv	a1,s7
     334:	00006517          	auipc	a0,0x6
     338:	f0450513          	add	a0,a0,-252 # 6238 <malloc+0x20c>
     33c:	00006097          	auipc	ra,0x6
     340:	c38080e7          	jalr	-968(ra) # 5f74 <printf>
        exit(1);
     344:	4505                	li	a0,1
     346:	00006097          	auipc	ra,0x6
     34a:	8b6080e7          	jalr	-1866(ra) # 5bfc <exit>

000000000000034e <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     34e:	7179                	add	sp,sp,-48
     350:	f406                	sd	ra,40(sp)
     352:	f022                	sd	s0,32(sp)
     354:	ec26                	sd	s1,24(sp)
     356:	e84a                	sd	s2,16(sp)
     358:	e44e                	sd	s3,8(sp)
     35a:	e052                	sd	s4,0(sp)
     35c:	1800                	add	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     35e:	00006517          	auipc	a0,0x6
     362:	ef250513          	add	a0,a0,-270 # 6250 <malloc+0x224>
     366:	00006097          	auipc	ra,0x6
     36a:	8e6080e7          	jalr	-1818(ra) # 5c4c <unlink>
     36e:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     372:	00006997          	auipc	s3,0x6
     376:	ede98993          	add	s3,s3,-290 # 6250 <malloc+0x224>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     37a:	5a7d                	li	s4,-1
     37c:	018a5a13          	srl	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     380:	20100593          	li	a1,513
     384:	854e                	mv	a0,s3
     386:	00006097          	auipc	ra,0x6
     38a:	8b6080e7          	jalr	-1866(ra) # 5c3c <open>
     38e:	84aa                	mv	s1,a0
    if(fd < 0){
     390:	06054b63          	bltz	a0,406 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
     394:	4605                	li	a2,1
     396:	85d2                	mv	a1,s4
     398:	00006097          	auipc	ra,0x6
     39c:	884080e7          	jalr	-1916(ra) # 5c1c <write>
    close(fd);
     3a0:	8526                	mv	a0,s1
     3a2:	00006097          	auipc	ra,0x6
     3a6:	882080e7          	jalr	-1918(ra) # 5c24 <close>
    unlink("junk");
     3aa:	854e                	mv	a0,s3
     3ac:	00006097          	auipc	ra,0x6
     3b0:	8a0080e7          	jalr	-1888(ra) # 5c4c <unlink>
  for(int i = 0; i < assumed_free; i++){
     3b4:	397d                	addw	s2,s2,-1
     3b6:	fc0915e3          	bnez	s2,380 <badwrite+0x32>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     3ba:	20100593          	li	a1,513
     3be:	00006517          	auipc	a0,0x6
     3c2:	e9250513          	add	a0,a0,-366 # 6250 <malloc+0x224>
     3c6:	00006097          	auipc	ra,0x6
     3ca:	876080e7          	jalr	-1930(ra) # 5c3c <open>
     3ce:	84aa                	mv	s1,a0
  if(fd < 0){
     3d0:	04054863          	bltz	a0,420 <badwrite+0xd2>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     3d4:	4605                	li	a2,1
     3d6:	00006597          	auipc	a1,0x6
     3da:	e0258593          	add	a1,a1,-510 # 61d8 <malloc+0x1ac>
     3de:	00006097          	auipc	ra,0x6
     3e2:	83e080e7          	jalr	-1986(ra) # 5c1c <write>
     3e6:	4785                	li	a5,1
     3e8:	04f50963          	beq	a0,a5,43a <badwrite+0xec>
    printf("write failed\n");
     3ec:	00006517          	auipc	a0,0x6
     3f0:	e8450513          	add	a0,a0,-380 # 6270 <malloc+0x244>
     3f4:	00006097          	auipc	ra,0x6
     3f8:	b80080e7          	jalr	-1152(ra) # 5f74 <printf>
    exit(1);
     3fc:	4505                	li	a0,1
     3fe:	00005097          	auipc	ra,0x5
     402:	7fe080e7          	jalr	2046(ra) # 5bfc <exit>
      printf("open junk failed\n");
     406:	00006517          	auipc	a0,0x6
     40a:	e5250513          	add	a0,a0,-430 # 6258 <malloc+0x22c>
     40e:	00006097          	auipc	ra,0x6
     412:	b66080e7          	jalr	-1178(ra) # 5f74 <printf>
      exit(1);
     416:	4505                	li	a0,1
     418:	00005097          	auipc	ra,0x5
     41c:	7e4080e7          	jalr	2020(ra) # 5bfc <exit>
    printf("open junk failed\n");
     420:	00006517          	auipc	a0,0x6
     424:	e3850513          	add	a0,a0,-456 # 6258 <malloc+0x22c>
     428:	00006097          	auipc	ra,0x6
     42c:	b4c080e7          	jalr	-1204(ra) # 5f74 <printf>
    exit(1);
     430:	4505                	li	a0,1
     432:	00005097          	auipc	ra,0x5
     436:	7ca080e7          	jalr	1994(ra) # 5bfc <exit>
  }
  close(fd);
     43a:	8526                	mv	a0,s1
     43c:	00005097          	auipc	ra,0x5
     440:	7e8080e7          	jalr	2024(ra) # 5c24 <close>
  unlink("junk");
     444:	00006517          	auipc	a0,0x6
     448:	e0c50513          	add	a0,a0,-500 # 6250 <malloc+0x224>
     44c:	00006097          	auipc	ra,0x6
     450:	800080e7          	jalr	-2048(ra) # 5c4c <unlink>

  exit(0);
     454:	4501                	li	a0,0
     456:	00005097          	auipc	ra,0x5
     45a:	7a6080e7          	jalr	1958(ra) # 5bfc <exit>

000000000000045e <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     45e:	715d                	add	sp,sp,-80
     460:	e486                	sd	ra,72(sp)
     462:	e0a2                	sd	s0,64(sp)
     464:	fc26                	sd	s1,56(sp)
     466:	f84a                	sd	s2,48(sp)
     468:	f44e                	sd	s3,40(sp)
     46a:	0880                	add	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     46c:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     46e:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     472:	40000993          	li	s3,1024
    name[0] = 'z';
     476:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     47a:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     47e:	41f4d71b          	sraw	a4,s1,0x1f
     482:	01b7571b          	srlw	a4,a4,0x1b
     486:	009707bb          	addw	a5,a4,s1
     48a:	4057d69b          	sraw	a3,a5,0x5
     48e:	0306869b          	addw	a3,a3,48
     492:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     496:	8bfd                	and	a5,a5,31
     498:	9f99                	subw	a5,a5,a4
     49a:	0307879b          	addw	a5,a5,48
     49e:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     4a2:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     4a6:	fb040513          	add	a0,s0,-80
     4aa:	00005097          	auipc	ra,0x5
     4ae:	7a2080e7          	jalr	1954(ra) # 5c4c <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     4b2:	60200593          	li	a1,1538
     4b6:	fb040513          	add	a0,s0,-80
     4ba:	00005097          	auipc	ra,0x5
     4be:	782080e7          	jalr	1922(ra) # 5c3c <open>
    if(fd < 0){
     4c2:	00054963          	bltz	a0,4d4 <outofinodes+0x76>
      // failure is eventually expected.
      break;
    }
    close(fd);
     4c6:	00005097          	auipc	ra,0x5
     4ca:	75e080e7          	jalr	1886(ra) # 5c24 <close>
  for(int i = 0; i < nzz; i++){
     4ce:	2485                	addw	s1,s1,1
     4d0:	fb3493e3          	bne	s1,s3,476 <outofinodes+0x18>
     4d4:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     4d6:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     4da:	40000993          	li	s3,1024
    name[0] = 'z';
     4de:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     4e2:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     4e6:	41f4d71b          	sraw	a4,s1,0x1f
     4ea:	01b7571b          	srlw	a4,a4,0x1b
     4ee:	009707bb          	addw	a5,a4,s1
     4f2:	4057d69b          	sraw	a3,a5,0x5
     4f6:	0306869b          	addw	a3,a3,48
     4fa:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     4fe:	8bfd                	and	a5,a5,31
     500:	9f99                	subw	a5,a5,a4
     502:	0307879b          	addw	a5,a5,48
     506:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     50a:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     50e:	fb040513          	add	a0,s0,-80
     512:	00005097          	auipc	ra,0x5
     516:	73a080e7          	jalr	1850(ra) # 5c4c <unlink>
  for(int i = 0; i < nzz; i++){
     51a:	2485                	addw	s1,s1,1
     51c:	fd3491e3          	bne	s1,s3,4de <outofinodes+0x80>
  }
}
     520:	60a6                	ld	ra,72(sp)
     522:	6406                	ld	s0,64(sp)
     524:	74e2                	ld	s1,56(sp)
     526:	7942                	ld	s2,48(sp)
     528:	79a2                	ld	s3,40(sp)
     52a:	6161                	add	sp,sp,80
     52c:	8082                	ret

000000000000052e <copyin>:
{
     52e:	715d                	add	sp,sp,-80
     530:	e486                	sd	ra,72(sp)
     532:	e0a2                	sd	s0,64(sp)
     534:	fc26                	sd	s1,56(sp)
     536:	f84a                	sd	s2,48(sp)
     538:	f44e                	sd	s3,40(sp)
     53a:	f052                	sd	s4,32(sp)
     53c:	0880                	add	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     53e:	4785                	li	a5,1
     540:	07fe                	sll	a5,a5,0x1f
     542:	fcf43023          	sd	a5,-64(s0)
     546:	57fd                	li	a5,-1
     548:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     54c:	fc040913          	add	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     550:	00006a17          	auipc	s4,0x6
     554:	d30a0a13          	add	s4,s4,-720 # 6280 <malloc+0x254>
    uint64 addr = addrs[ai];
     558:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     55c:	20100593          	li	a1,513
     560:	8552                	mv	a0,s4
     562:	00005097          	auipc	ra,0x5
     566:	6da080e7          	jalr	1754(ra) # 5c3c <open>
     56a:	84aa                	mv	s1,a0
    if(fd < 0){
     56c:	08054863          	bltz	a0,5fc <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     570:	6609                	lui	a2,0x2
     572:	85ce                	mv	a1,s3
     574:	00005097          	auipc	ra,0x5
     578:	6a8080e7          	jalr	1704(ra) # 5c1c <write>
    if(n >= 0){
     57c:	08055d63          	bgez	a0,616 <copyin+0xe8>
    close(fd);
     580:	8526                	mv	a0,s1
     582:	00005097          	auipc	ra,0x5
     586:	6a2080e7          	jalr	1698(ra) # 5c24 <close>
    unlink("copyin1");
     58a:	8552                	mv	a0,s4
     58c:	00005097          	auipc	ra,0x5
     590:	6c0080e7          	jalr	1728(ra) # 5c4c <unlink>
    n = write(1, (char*)addr, 8192);
     594:	6609                	lui	a2,0x2
     596:	85ce                	mv	a1,s3
     598:	4505                	li	a0,1
     59a:	00005097          	auipc	ra,0x5
     59e:	682080e7          	jalr	1666(ra) # 5c1c <write>
    if(n > 0){
     5a2:	08a04963          	bgtz	a0,634 <copyin+0x106>
    if(pipe(fds) < 0){
     5a6:	fb840513          	add	a0,s0,-72
     5aa:	00005097          	auipc	ra,0x5
     5ae:	662080e7          	jalr	1634(ra) # 5c0c <pipe>
     5b2:	0a054063          	bltz	a0,652 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     5b6:	6609                	lui	a2,0x2
     5b8:	85ce                	mv	a1,s3
     5ba:	fbc42503          	lw	a0,-68(s0)
     5be:	00005097          	auipc	ra,0x5
     5c2:	65e080e7          	jalr	1630(ra) # 5c1c <write>
    if(n > 0){
     5c6:	0aa04363          	bgtz	a0,66c <copyin+0x13e>
    close(fds[0]);
     5ca:	fb842503          	lw	a0,-72(s0)
     5ce:	00005097          	auipc	ra,0x5
     5d2:	656080e7          	jalr	1622(ra) # 5c24 <close>
    close(fds[1]);
     5d6:	fbc42503          	lw	a0,-68(s0)
     5da:	00005097          	auipc	ra,0x5
     5de:	64a080e7          	jalr	1610(ra) # 5c24 <close>
  for(int ai = 0; ai < 2; ai++){
     5e2:	0921                	add	s2,s2,8
     5e4:	fd040793          	add	a5,s0,-48
     5e8:	f6f918e3          	bne	s2,a5,558 <copyin+0x2a>
}
     5ec:	60a6                	ld	ra,72(sp)
     5ee:	6406                	ld	s0,64(sp)
     5f0:	74e2                	ld	s1,56(sp)
     5f2:	7942                	ld	s2,48(sp)
     5f4:	79a2                	ld	s3,40(sp)
     5f6:	7a02                	ld	s4,32(sp)
     5f8:	6161                	add	sp,sp,80
     5fa:	8082                	ret
      printf("open(copyin1) failed\n");
     5fc:	00006517          	auipc	a0,0x6
     600:	c8c50513          	add	a0,a0,-884 # 6288 <malloc+0x25c>
     604:	00006097          	auipc	ra,0x6
     608:	970080e7          	jalr	-1680(ra) # 5f74 <printf>
      exit(1);
     60c:	4505                	li	a0,1
     60e:	00005097          	auipc	ra,0x5
     612:	5ee080e7          	jalr	1518(ra) # 5bfc <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     616:	862a                	mv	a2,a0
     618:	85ce                	mv	a1,s3
     61a:	00006517          	auipc	a0,0x6
     61e:	c8650513          	add	a0,a0,-890 # 62a0 <malloc+0x274>
     622:	00006097          	auipc	ra,0x6
     626:	952080e7          	jalr	-1710(ra) # 5f74 <printf>
      exit(1);
     62a:	4505                	li	a0,1
     62c:	00005097          	auipc	ra,0x5
     630:	5d0080e7          	jalr	1488(ra) # 5bfc <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     634:	862a                	mv	a2,a0
     636:	85ce                	mv	a1,s3
     638:	00006517          	auipc	a0,0x6
     63c:	c9850513          	add	a0,a0,-872 # 62d0 <malloc+0x2a4>
     640:	00006097          	auipc	ra,0x6
     644:	934080e7          	jalr	-1740(ra) # 5f74 <printf>
      exit(1);
     648:	4505                	li	a0,1
     64a:	00005097          	auipc	ra,0x5
     64e:	5b2080e7          	jalr	1458(ra) # 5bfc <exit>
      printf("pipe() failed\n");
     652:	00006517          	auipc	a0,0x6
     656:	cae50513          	add	a0,a0,-850 # 6300 <malloc+0x2d4>
     65a:	00006097          	auipc	ra,0x6
     65e:	91a080e7          	jalr	-1766(ra) # 5f74 <printf>
      exit(1);
     662:	4505                	li	a0,1
     664:	00005097          	auipc	ra,0x5
     668:	598080e7          	jalr	1432(ra) # 5bfc <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     66c:	862a                	mv	a2,a0
     66e:	85ce                	mv	a1,s3
     670:	00006517          	auipc	a0,0x6
     674:	ca050513          	add	a0,a0,-864 # 6310 <malloc+0x2e4>
     678:	00006097          	auipc	ra,0x6
     67c:	8fc080e7          	jalr	-1796(ra) # 5f74 <printf>
      exit(1);
     680:	4505                	li	a0,1
     682:	00005097          	auipc	ra,0x5
     686:	57a080e7          	jalr	1402(ra) # 5bfc <exit>

000000000000068a <copyout>:
{
     68a:	711d                	add	sp,sp,-96
     68c:	ec86                	sd	ra,88(sp)
     68e:	e8a2                	sd	s0,80(sp)
     690:	e4a6                	sd	s1,72(sp)
     692:	e0ca                	sd	s2,64(sp)
     694:	fc4e                	sd	s3,56(sp)
     696:	f852                	sd	s4,48(sp)
     698:	f456                	sd	s5,40(sp)
     69a:	1080                	add	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     69c:	4785                	li	a5,1
     69e:	07fe                	sll	a5,a5,0x1f
     6a0:	faf43823          	sd	a5,-80(s0)
     6a4:	57fd                	li	a5,-1
     6a6:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     6aa:	fb040913          	add	s2,s0,-80
    int fd = open("README", 0);
     6ae:	00006a17          	auipc	s4,0x6
     6b2:	c92a0a13          	add	s4,s4,-878 # 6340 <malloc+0x314>
    n = write(fds[1], "x", 1);
     6b6:	00006a97          	auipc	s5,0x6
     6ba:	b22a8a93          	add	s5,s5,-1246 # 61d8 <malloc+0x1ac>
    uint64 addr = addrs[ai];
     6be:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     6c2:	4581                	li	a1,0
     6c4:	8552                	mv	a0,s4
     6c6:	00005097          	auipc	ra,0x5
     6ca:	576080e7          	jalr	1398(ra) # 5c3c <open>
     6ce:	84aa                	mv	s1,a0
    if(fd < 0){
     6d0:	08054663          	bltz	a0,75c <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     6d4:	6609                	lui	a2,0x2
     6d6:	85ce                	mv	a1,s3
     6d8:	00005097          	auipc	ra,0x5
     6dc:	53c080e7          	jalr	1340(ra) # 5c14 <read>
    if(n > 0){
     6e0:	08a04b63          	bgtz	a0,776 <copyout+0xec>
    close(fd);
     6e4:	8526                	mv	a0,s1
     6e6:	00005097          	auipc	ra,0x5
     6ea:	53e080e7          	jalr	1342(ra) # 5c24 <close>
    if(pipe(fds) < 0){
     6ee:	fa840513          	add	a0,s0,-88
     6f2:	00005097          	auipc	ra,0x5
     6f6:	51a080e7          	jalr	1306(ra) # 5c0c <pipe>
     6fa:	08054d63          	bltz	a0,794 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     6fe:	4605                	li	a2,1
     700:	85d6                	mv	a1,s5
     702:	fac42503          	lw	a0,-84(s0)
     706:	00005097          	auipc	ra,0x5
     70a:	516080e7          	jalr	1302(ra) # 5c1c <write>
    if(n != 1){
     70e:	4785                	li	a5,1
     710:	08f51f63          	bne	a0,a5,7ae <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     714:	6609                	lui	a2,0x2
     716:	85ce                	mv	a1,s3
     718:	fa842503          	lw	a0,-88(s0)
     71c:	00005097          	auipc	ra,0x5
     720:	4f8080e7          	jalr	1272(ra) # 5c14 <read>
    if(n > 0){
     724:	0aa04263          	bgtz	a0,7c8 <copyout+0x13e>
    close(fds[0]);
     728:	fa842503          	lw	a0,-88(s0)
     72c:	00005097          	auipc	ra,0x5
     730:	4f8080e7          	jalr	1272(ra) # 5c24 <close>
    close(fds[1]);
     734:	fac42503          	lw	a0,-84(s0)
     738:	00005097          	auipc	ra,0x5
     73c:	4ec080e7          	jalr	1260(ra) # 5c24 <close>
  for(int ai = 0; ai < 2; ai++){
     740:	0921                	add	s2,s2,8
     742:	fc040793          	add	a5,s0,-64
     746:	f6f91ce3          	bne	s2,a5,6be <copyout+0x34>
}
     74a:	60e6                	ld	ra,88(sp)
     74c:	6446                	ld	s0,80(sp)
     74e:	64a6                	ld	s1,72(sp)
     750:	6906                	ld	s2,64(sp)
     752:	79e2                	ld	s3,56(sp)
     754:	7a42                	ld	s4,48(sp)
     756:	7aa2                	ld	s5,40(sp)
     758:	6125                	add	sp,sp,96
     75a:	8082                	ret
      printf("open(README) failed\n");
     75c:	00006517          	auipc	a0,0x6
     760:	bec50513          	add	a0,a0,-1044 # 6348 <malloc+0x31c>
     764:	00006097          	auipc	ra,0x6
     768:	810080e7          	jalr	-2032(ra) # 5f74 <printf>
      exit(1);
     76c:	4505                	li	a0,1
     76e:	00005097          	auipc	ra,0x5
     772:	48e080e7          	jalr	1166(ra) # 5bfc <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     776:	862a                	mv	a2,a0
     778:	85ce                	mv	a1,s3
     77a:	00006517          	auipc	a0,0x6
     77e:	be650513          	add	a0,a0,-1050 # 6360 <malloc+0x334>
     782:	00005097          	auipc	ra,0x5
     786:	7f2080e7          	jalr	2034(ra) # 5f74 <printf>
      exit(1);
     78a:	4505                	li	a0,1
     78c:	00005097          	auipc	ra,0x5
     790:	470080e7          	jalr	1136(ra) # 5bfc <exit>
      printf("pipe() failed\n");
     794:	00006517          	auipc	a0,0x6
     798:	b6c50513          	add	a0,a0,-1172 # 6300 <malloc+0x2d4>
     79c:	00005097          	auipc	ra,0x5
     7a0:	7d8080e7          	jalr	2008(ra) # 5f74 <printf>
      exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	456080e7          	jalr	1110(ra) # 5bfc <exit>
      printf("pipe write failed\n");
     7ae:	00006517          	auipc	a0,0x6
     7b2:	be250513          	add	a0,a0,-1054 # 6390 <malloc+0x364>
     7b6:	00005097          	auipc	ra,0x5
     7ba:	7be080e7          	jalr	1982(ra) # 5f74 <printf>
      exit(1);
     7be:	4505                	li	a0,1
     7c0:	00005097          	auipc	ra,0x5
     7c4:	43c080e7          	jalr	1084(ra) # 5bfc <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     7c8:	862a                	mv	a2,a0
     7ca:	85ce                	mv	a1,s3
     7cc:	00006517          	auipc	a0,0x6
     7d0:	bdc50513          	add	a0,a0,-1060 # 63a8 <malloc+0x37c>
     7d4:	00005097          	auipc	ra,0x5
     7d8:	7a0080e7          	jalr	1952(ra) # 5f74 <printf>
      exit(1);
     7dc:	4505                	li	a0,1
     7de:	00005097          	auipc	ra,0x5
     7e2:	41e080e7          	jalr	1054(ra) # 5bfc <exit>

00000000000007e6 <truncate1>:
{
     7e6:	711d                	add	sp,sp,-96
     7e8:	ec86                	sd	ra,88(sp)
     7ea:	e8a2                	sd	s0,80(sp)
     7ec:	e4a6                	sd	s1,72(sp)
     7ee:	e0ca                	sd	s2,64(sp)
     7f0:	fc4e                	sd	s3,56(sp)
     7f2:	f852                	sd	s4,48(sp)
     7f4:	f456                	sd	s5,40(sp)
     7f6:	1080                	add	s0,sp,96
     7f8:	8aaa                	mv	s5,a0
  unlink("truncfile");
     7fa:	00006517          	auipc	a0,0x6
     7fe:	9c650513          	add	a0,a0,-1594 # 61c0 <malloc+0x194>
     802:	00005097          	auipc	ra,0x5
     806:	44a080e7          	jalr	1098(ra) # 5c4c <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     80a:	60100593          	li	a1,1537
     80e:	00006517          	auipc	a0,0x6
     812:	9b250513          	add	a0,a0,-1614 # 61c0 <malloc+0x194>
     816:	00005097          	auipc	ra,0x5
     81a:	426080e7          	jalr	1062(ra) # 5c3c <open>
     81e:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     820:	4611                	li	a2,4
     822:	00006597          	auipc	a1,0x6
     826:	9ae58593          	add	a1,a1,-1618 # 61d0 <malloc+0x1a4>
     82a:	00005097          	auipc	ra,0x5
     82e:	3f2080e7          	jalr	1010(ra) # 5c1c <write>
  close(fd1);
     832:	8526                	mv	a0,s1
     834:	00005097          	auipc	ra,0x5
     838:	3f0080e7          	jalr	1008(ra) # 5c24 <close>
  int fd2 = open("truncfile", O_RDONLY);
     83c:	4581                	li	a1,0
     83e:	00006517          	auipc	a0,0x6
     842:	98250513          	add	a0,a0,-1662 # 61c0 <malloc+0x194>
     846:	00005097          	auipc	ra,0x5
     84a:	3f6080e7          	jalr	1014(ra) # 5c3c <open>
     84e:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     850:	02000613          	li	a2,32
     854:	fa040593          	add	a1,s0,-96
     858:	00005097          	auipc	ra,0x5
     85c:	3bc080e7          	jalr	956(ra) # 5c14 <read>
  if(n != 4){
     860:	4791                	li	a5,4
     862:	0cf51e63          	bne	a0,a5,93e <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     866:	40100593          	li	a1,1025
     86a:	00006517          	auipc	a0,0x6
     86e:	95650513          	add	a0,a0,-1706 # 61c0 <malloc+0x194>
     872:	00005097          	auipc	ra,0x5
     876:	3ca080e7          	jalr	970(ra) # 5c3c <open>
     87a:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     87c:	4581                	li	a1,0
     87e:	00006517          	auipc	a0,0x6
     882:	94250513          	add	a0,a0,-1726 # 61c0 <malloc+0x194>
     886:	00005097          	auipc	ra,0x5
     88a:	3b6080e7          	jalr	950(ra) # 5c3c <open>
     88e:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     890:	02000613          	li	a2,32
     894:	fa040593          	add	a1,s0,-96
     898:	00005097          	auipc	ra,0x5
     89c:	37c080e7          	jalr	892(ra) # 5c14 <read>
     8a0:	8a2a                	mv	s4,a0
  if(n != 0){
     8a2:	ed4d                	bnez	a0,95c <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     8a4:	02000613          	li	a2,32
     8a8:	fa040593          	add	a1,s0,-96
     8ac:	8526                	mv	a0,s1
     8ae:	00005097          	auipc	ra,0x5
     8b2:	366080e7          	jalr	870(ra) # 5c14 <read>
     8b6:	8a2a                	mv	s4,a0
  if(n != 0){
     8b8:	e971                	bnez	a0,98c <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     8ba:	4619                	li	a2,6
     8bc:	00006597          	auipc	a1,0x6
     8c0:	b7c58593          	add	a1,a1,-1156 # 6438 <malloc+0x40c>
     8c4:	854e                	mv	a0,s3
     8c6:	00005097          	auipc	ra,0x5
     8ca:	356080e7          	jalr	854(ra) # 5c1c <write>
  n = read(fd3, buf, sizeof(buf));
     8ce:	02000613          	li	a2,32
     8d2:	fa040593          	add	a1,s0,-96
     8d6:	854a                	mv	a0,s2
     8d8:	00005097          	auipc	ra,0x5
     8dc:	33c080e7          	jalr	828(ra) # 5c14 <read>
  if(n != 6){
     8e0:	4799                	li	a5,6
     8e2:	0cf51d63          	bne	a0,a5,9bc <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     8e6:	02000613          	li	a2,32
     8ea:	fa040593          	add	a1,s0,-96
     8ee:	8526                	mv	a0,s1
     8f0:	00005097          	auipc	ra,0x5
     8f4:	324080e7          	jalr	804(ra) # 5c14 <read>
  if(n != 2){
     8f8:	4789                	li	a5,2
     8fa:	0ef51063          	bne	a0,a5,9da <truncate1+0x1f4>
  unlink("truncfile");
     8fe:	00006517          	auipc	a0,0x6
     902:	8c250513          	add	a0,a0,-1854 # 61c0 <malloc+0x194>
     906:	00005097          	auipc	ra,0x5
     90a:	346080e7          	jalr	838(ra) # 5c4c <unlink>
  close(fd1);
     90e:	854e                	mv	a0,s3
     910:	00005097          	auipc	ra,0x5
     914:	314080e7          	jalr	788(ra) # 5c24 <close>
  close(fd2);
     918:	8526                	mv	a0,s1
     91a:	00005097          	auipc	ra,0x5
     91e:	30a080e7          	jalr	778(ra) # 5c24 <close>
  close(fd3);
     922:	854a                	mv	a0,s2
     924:	00005097          	auipc	ra,0x5
     928:	300080e7          	jalr	768(ra) # 5c24 <close>
}
     92c:	60e6                	ld	ra,88(sp)
     92e:	6446                	ld	s0,80(sp)
     930:	64a6                	ld	s1,72(sp)
     932:	6906                	ld	s2,64(sp)
     934:	79e2                	ld	s3,56(sp)
     936:	7a42                	ld	s4,48(sp)
     938:	7aa2                	ld	s5,40(sp)
     93a:	6125                	add	sp,sp,96
     93c:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     93e:	862a                	mv	a2,a0
     940:	85d6                	mv	a1,s5
     942:	00006517          	auipc	a0,0x6
     946:	a9650513          	add	a0,a0,-1386 # 63d8 <malloc+0x3ac>
     94a:	00005097          	auipc	ra,0x5
     94e:	62a080e7          	jalr	1578(ra) # 5f74 <printf>
    exit(1);
     952:	4505                	li	a0,1
     954:	00005097          	auipc	ra,0x5
     958:	2a8080e7          	jalr	680(ra) # 5bfc <exit>
    printf("aaa fd3=%d\n", fd3);
     95c:	85ca                	mv	a1,s2
     95e:	00006517          	auipc	a0,0x6
     962:	a9a50513          	add	a0,a0,-1382 # 63f8 <malloc+0x3cc>
     966:	00005097          	auipc	ra,0x5
     96a:	60e080e7          	jalr	1550(ra) # 5f74 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     96e:	8652                	mv	a2,s4
     970:	85d6                	mv	a1,s5
     972:	00006517          	auipc	a0,0x6
     976:	a9650513          	add	a0,a0,-1386 # 6408 <malloc+0x3dc>
     97a:	00005097          	auipc	ra,0x5
     97e:	5fa080e7          	jalr	1530(ra) # 5f74 <printf>
    exit(1);
     982:	4505                	li	a0,1
     984:	00005097          	auipc	ra,0x5
     988:	278080e7          	jalr	632(ra) # 5bfc <exit>
    printf("bbb fd2=%d\n", fd2);
     98c:	85a6                	mv	a1,s1
     98e:	00006517          	auipc	a0,0x6
     992:	a9a50513          	add	a0,a0,-1382 # 6428 <malloc+0x3fc>
     996:	00005097          	auipc	ra,0x5
     99a:	5de080e7          	jalr	1502(ra) # 5f74 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     99e:	8652                	mv	a2,s4
     9a0:	85d6                	mv	a1,s5
     9a2:	00006517          	auipc	a0,0x6
     9a6:	a6650513          	add	a0,a0,-1434 # 6408 <malloc+0x3dc>
     9aa:	00005097          	auipc	ra,0x5
     9ae:	5ca080e7          	jalr	1482(ra) # 5f74 <printf>
    exit(1);
     9b2:	4505                	li	a0,1
     9b4:	00005097          	auipc	ra,0x5
     9b8:	248080e7          	jalr	584(ra) # 5bfc <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     9bc:	862a                	mv	a2,a0
     9be:	85d6                	mv	a1,s5
     9c0:	00006517          	auipc	a0,0x6
     9c4:	a8050513          	add	a0,a0,-1408 # 6440 <malloc+0x414>
     9c8:	00005097          	auipc	ra,0x5
     9cc:	5ac080e7          	jalr	1452(ra) # 5f74 <printf>
    exit(1);
     9d0:	4505                	li	a0,1
     9d2:	00005097          	auipc	ra,0x5
     9d6:	22a080e7          	jalr	554(ra) # 5bfc <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     9da:	862a                	mv	a2,a0
     9dc:	85d6                	mv	a1,s5
     9de:	00006517          	auipc	a0,0x6
     9e2:	a8250513          	add	a0,a0,-1406 # 6460 <malloc+0x434>
     9e6:	00005097          	auipc	ra,0x5
     9ea:	58e080e7          	jalr	1422(ra) # 5f74 <printf>
    exit(1);
     9ee:	4505                	li	a0,1
     9f0:	00005097          	auipc	ra,0x5
     9f4:	20c080e7          	jalr	524(ra) # 5bfc <exit>

00000000000009f8 <writetest>:
{
     9f8:	7139                	add	sp,sp,-64
     9fa:	fc06                	sd	ra,56(sp)
     9fc:	f822                	sd	s0,48(sp)
     9fe:	f426                	sd	s1,40(sp)
     a00:	f04a                	sd	s2,32(sp)
     a02:	ec4e                	sd	s3,24(sp)
     a04:	e852                	sd	s4,16(sp)
     a06:	e456                	sd	s5,8(sp)
     a08:	e05a                	sd	s6,0(sp)
     a0a:	0080                	add	s0,sp,64
     a0c:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     a0e:	20200593          	li	a1,514
     a12:	00006517          	auipc	a0,0x6
     a16:	a6e50513          	add	a0,a0,-1426 # 6480 <malloc+0x454>
     a1a:	00005097          	auipc	ra,0x5
     a1e:	222080e7          	jalr	546(ra) # 5c3c <open>
  if(fd < 0){
     a22:	0a054d63          	bltz	a0,adc <writetest+0xe4>
     a26:	892a                	mv	s2,a0
     a28:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a2a:	00006997          	auipc	s3,0x6
     a2e:	a7e98993          	add	s3,s3,-1410 # 64a8 <malloc+0x47c>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a32:	00006a97          	auipc	s5,0x6
     a36:	aaea8a93          	add	s5,s5,-1362 # 64e0 <malloc+0x4b4>
  for(i = 0; i < N; i++){
     a3a:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     a3e:	4629                	li	a2,10
     a40:	85ce                	mv	a1,s3
     a42:	854a                	mv	a0,s2
     a44:	00005097          	auipc	ra,0x5
     a48:	1d8080e7          	jalr	472(ra) # 5c1c <write>
     a4c:	47a9                	li	a5,10
     a4e:	0af51563          	bne	a0,a5,af8 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     a52:	4629                	li	a2,10
     a54:	85d6                	mv	a1,s5
     a56:	854a                	mv	a0,s2
     a58:	00005097          	auipc	ra,0x5
     a5c:	1c4080e7          	jalr	452(ra) # 5c1c <write>
     a60:	47a9                	li	a5,10
     a62:	0af51a63          	bne	a0,a5,b16 <writetest+0x11e>
  for(i = 0; i < N; i++){
     a66:	2485                	addw	s1,s1,1
     a68:	fd449be3          	bne	s1,s4,a3e <writetest+0x46>
  close(fd);
     a6c:	854a                	mv	a0,s2
     a6e:	00005097          	auipc	ra,0x5
     a72:	1b6080e7          	jalr	438(ra) # 5c24 <close>
  fd = open("small", O_RDONLY);
     a76:	4581                	li	a1,0
     a78:	00006517          	auipc	a0,0x6
     a7c:	a0850513          	add	a0,a0,-1528 # 6480 <malloc+0x454>
     a80:	00005097          	auipc	ra,0x5
     a84:	1bc080e7          	jalr	444(ra) # 5c3c <open>
     a88:	84aa                	mv	s1,a0
  if(fd < 0){
     a8a:	0a054563          	bltz	a0,b34 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     a8e:	7d000613          	li	a2,2000
     a92:	0000c597          	auipc	a1,0xc
     a96:	1e658593          	add	a1,a1,486 # cc78 <buf>
     a9a:	00005097          	auipc	ra,0x5
     a9e:	17a080e7          	jalr	378(ra) # 5c14 <read>
  if(i != N*SZ*2){
     aa2:	7d000793          	li	a5,2000
     aa6:	0af51563          	bne	a0,a5,b50 <writetest+0x158>
  close(fd);
     aaa:	8526                	mv	a0,s1
     aac:	00005097          	auipc	ra,0x5
     ab0:	178080e7          	jalr	376(ra) # 5c24 <close>
  if(unlink("small") < 0){
     ab4:	00006517          	auipc	a0,0x6
     ab8:	9cc50513          	add	a0,a0,-1588 # 6480 <malloc+0x454>
     abc:	00005097          	auipc	ra,0x5
     ac0:	190080e7          	jalr	400(ra) # 5c4c <unlink>
     ac4:	0a054463          	bltz	a0,b6c <writetest+0x174>
}
     ac8:	70e2                	ld	ra,56(sp)
     aca:	7442                	ld	s0,48(sp)
     acc:	74a2                	ld	s1,40(sp)
     ace:	7902                	ld	s2,32(sp)
     ad0:	69e2                	ld	s3,24(sp)
     ad2:	6a42                	ld	s4,16(sp)
     ad4:	6aa2                	ld	s5,8(sp)
     ad6:	6b02                	ld	s6,0(sp)
     ad8:	6121                	add	sp,sp,64
     ada:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     adc:	85da                	mv	a1,s6
     ade:	00006517          	auipc	a0,0x6
     ae2:	9aa50513          	add	a0,a0,-1622 # 6488 <malloc+0x45c>
     ae6:	00005097          	auipc	ra,0x5
     aea:	48e080e7          	jalr	1166(ra) # 5f74 <printf>
    exit(1);
     aee:	4505                	li	a0,1
     af0:	00005097          	auipc	ra,0x5
     af4:	10c080e7          	jalr	268(ra) # 5bfc <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     af8:	8626                	mv	a2,s1
     afa:	85da                	mv	a1,s6
     afc:	00006517          	auipc	a0,0x6
     b00:	9bc50513          	add	a0,a0,-1604 # 64b8 <malloc+0x48c>
     b04:	00005097          	auipc	ra,0x5
     b08:	470080e7          	jalr	1136(ra) # 5f74 <printf>
      exit(1);
     b0c:	4505                	li	a0,1
     b0e:	00005097          	auipc	ra,0x5
     b12:	0ee080e7          	jalr	238(ra) # 5bfc <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     b16:	8626                	mv	a2,s1
     b18:	85da                	mv	a1,s6
     b1a:	00006517          	auipc	a0,0x6
     b1e:	9d650513          	add	a0,a0,-1578 # 64f0 <malloc+0x4c4>
     b22:	00005097          	auipc	ra,0x5
     b26:	452080e7          	jalr	1106(ra) # 5f74 <printf>
      exit(1);
     b2a:	4505                	li	a0,1
     b2c:	00005097          	auipc	ra,0x5
     b30:	0d0080e7          	jalr	208(ra) # 5bfc <exit>
    printf("%s: error: open small failed!\n", s);
     b34:	85da                	mv	a1,s6
     b36:	00006517          	auipc	a0,0x6
     b3a:	9e250513          	add	a0,a0,-1566 # 6518 <malloc+0x4ec>
     b3e:	00005097          	auipc	ra,0x5
     b42:	436080e7          	jalr	1078(ra) # 5f74 <printf>
    exit(1);
     b46:	4505                	li	a0,1
     b48:	00005097          	auipc	ra,0x5
     b4c:	0b4080e7          	jalr	180(ra) # 5bfc <exit>
    printf("%s: read failed\n", s);
     b50:	85da                	mv	a1,s6
     b52:	00006517          	auipc	a0,0x6
     b56:	9e650513          	add	a0,a0,-1562 # 6538 <malloc+0x50c>
     b5a:	00005097          	auipc	ra,0x5
     b5e:	41a080e7          	jalr	1050(ra) # 5f74 <printf>
    exit(1);
     b62:	4505                	li	a0,1
     b64:	00005097          	auipc	ra,0x5
     b68:	098080e7          	jalr	152(ra) # 5bfc <exit>
    printf("%s: unlink small failed\n", s);
     b6c:	85da                	mv	a1,s6
     b6e:	00006517          	auipc	a0,0x6
     b72:	9e250513          	add	a0,a0,-1566 # 6550 <malloc+0x524>
     b76:	00005097          	auipc	ra,0x5
     b7a:	3fe080e7          	jalr	1022(ra) # 5f74 <printf>
    exit(1);
     b7e:	4505                	li	a0,1
     b80:	00005097          	auipc	ra,0x5
     b84:	07c080e7          	jalr	124(ra) # 5bfc <exit>

0000000000000b88 <writebig>:
{
     b88:	7139                	add	sp,sp,-64
     b8a:	fc06                	sd	ra,56(sp)
     b8c:	f822                	sd	s0,48(sp)
     b8e:	f426                	sd	s1,40(sp)
     b90:	f04a                	sd	s2,32(sp)
     b92:	ec4e                	sd	s3,24(sp)
     b94:	e852                	sd	s4,16(sp)
     b96:	e456                	sd	s5,8(sp)
     b98:	0080                	add	s0,sp,64
     b9a:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     b9c:	20200593          	li	a1,514
     ba0:	00006517          	auipc	a0,0x6
     ba4:	9d050513          	add	a0,a0,-1584 # 6570 <malloc+0x544>
     ba8:	00005097          	auipc	ra,0x5
     bac:	094080e7          	jalr	148(ra) # 5c3c <open>
     bb0:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     bb2:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     bb4:	0000c917          	auipc	s2,0xc
     bb8:	0c490913          	add	s2,s2,196 # cc78 <buf>
  for(i = 0; i < MAXFILE; i++){
     bbc:	10c00a13          	li	s4,268
  if(fd < 0){
     bc0:	06054c63          	bltz	a0,c38 <writebig+0xb0>
    ((int*)buf)[0] = i;
     bc4:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     bc8:	40000613          	li	a2,1024
     bcc:	85ca                	mv	a1,s2
     bce:	854e                	mv	a0,s3
     bd0:	00005097          	auipc	ra,0x5
     bd4:	04c080e7          	jalr	76(ra) # 5c1c <write>
     bd8:	40000793          	li	a5,1024
     bdc:	06f51c63          	bne	a0,a5,c54 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     be0:	2485                	addw	s1,s1,1
     be2:	ff4491e3          	bne	s1,s4,bc4 <writebig+0x3c>
  close(fd);
     be6:	854e                	mv	a0,s3
     be8:	00005097          	auipc	ra,0x5
     bec:	03c080e7          	jalr	60(ra) # 5c24 <close>
  fd = open("big", O_RDONLY);
     bf0:	4581                	li	a1,0
     bf2:	00006517          	auipc	a0,0x6
     bf6:	97e50513          	add	a0,a0,-1666 # 6570 <malloc+0x544>
     bfa:	00005097          	auipc	ra,0x5
     bfe:	042080e7          	jalr	66(ra) # 5c3c <open>
     c02:	89aa                	mv	s3,a0
  n = 0;
     c04:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     c06:	0000c917          	auipc	s2,0xc
     c0a:	07290913          	add	s2,s2,114 # cc78 <buf>
  if(fd < 0){
     c0e:	06054263          	bltz	a0,c72 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     c12:	40000613          	li	a2,1024
     c16:	85ca                	mv	a1,s2
     c18:	854e                	mv	a0,s3
     c1a:	00005097          	auipc	ra,0x5
     c1e:	ffa080e7          	jalr	-6(ra) # 5c14 <read>
    if(i == 0){
     c22:	c535                	beqz	a0,c8e <writebig+0x106>
    } else if(i != BSIZE){
     c24:	40000793          	li	a5,1024
     c28:	0af51f63          	bne	a0,a5,ce6 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     c2c:	00092683          	lw	a3,0(s2)
     c30:	0c969a63          	bne	a3,s1,d04 <writebig+0x17c>
    n++;
     c34:	2485                	addw	s1,s1,1
    i = read(fd, buf, BSIZE);
     c36:	bff1                	j	c12 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     c38:	85d6                	mv	a1,s5
     c3a:	00006517          	auipc	a0,0x6
     c3e:	93e50513          	add	a0,a0,-1730 # 6578 <malloc+0x54c>
     c42:	00005097          	auipc	ra,0x5
     c46:	332080e7          	jalr	818(ra) # 5f74 <printf>
    exit(1);
     c4a:	4505                	li	a0,1
     c4c:	00005097          	auipc	ra,0x5
     c50:	fb0080e7          	jalr	-80(ra) # 5bfc <exit>
      printf("%s: error: write big file failed\n", s, i);
     c54:	8626                	mv	a2,s1
     c56:	85d6                	mv	a1,s5
     c58:	00006517          	auipc	a0,0x6
     c5c:	94050513          	add	a0,a0,-1728 # 6598 <malloc+0x56c>
     c60:	00005097          	auipc	ra,0x5
     c64:	314080e7          	jalr	788(ra) # 5f74 <printf>
      exit(1);
     c68:	4505                	li	a0,1
     c6a:	00005097          	auipc	ra,0x5
     c6e:	f92080e7          	jalr	-110(ra) # 5bfc <exit>
    printf("%s: error: open big failed!\n", s);
     c72:	85d6                	mv	a1,s5
     c74:	00006517          	auipc	a0,0x6
     c78:	94c50513          	add	a0,a0,-1716 # 65c0 <malloc+0x594>
     c7c:	00005097          	auipc	ra,0x5
     c80:	2f8080e7          	jalr	760(ra) # 5f74 <printf>
    exit(1);
     c84:	4505                	li	a0,1
     c86:	00005097          	auipc	ra,0x5
     c8a:	f76080e7          	jalr	-138(ra) # 5bfc <exit>
      if(n == MAXFILE - 1){
     c8e:	10b00793          	li	a5,267
     c92:	02f48a63          	beq	s1,a5,cc6 <writebig+0x13e>
  close(fd);
     c96:	854e                	mv	a0,s3
     c98:	00005097          	auipc	ra,0x5
     c9c:	f8c080e7          	jalr	-116(ra) # 5c24 <close>
  if(unlink("big") < 0){
     ca0:	00006517          	auipc	a0,0x6
     ca4:	8d050513          	add	a0,a0,-1840 # 6570 <malloc+0x544>
     ca8:	00005097          	auipc	ra,0x5
     cac:	fa4080e7          	jalr	-92(ra) # 5c4c <unlink>
     cb0:	06054963          	bltz	a0,d22 <writebig+0x19a>
}
     cb4:	70e2                	ld	ra,56(sp)
     cb6:	7442                	ld	s0,48(sp)
     cb8:	74a2                	ld	s1,40(sp)
     cba:	7902                	ld	s2,32(sp)
     cbc:	69e2                	ld	s3,24(sp)
     cbe:	6a42                	ld	s4,16(sp)
     cc0:	6aa2                	ld	s5,8(sp)
     cc2:	6121                	add	sp,sp,64
     cc4:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     cc6:	10b00613          	li	a2,267
     cca:	85d6                	mv	a1,s5
     ccc:	00006517          	auipc	a0,0x6
     cd0:	91450513          	add	a0,a0,-1772 # 65e0 <malloc+0x5b4>
     cd4:	00005097          	auipc	ra,0x5
     cd8:	2a0080e7          	jalr	672(ra) # 5f74 <printf>
        exit(1);
     cdc:	4505                	li	a0,1
     cde:	00005097          	auipc	ra,0x5
     ce2:	f1e080e7          	jalr	-226(ra) # 5bfc <exit>
      printf("%s: read failed %d\n", s, i);
     ce6:	862a                	mv	a2,a0
     ce8:	85d6                	mv	a1,s5
     cea:	00006517          	auipc	a0,0x6
     cee:	91e50513          	add	a0,a0,-1762 # 6608 <malloc+0x5dc>
     cf2:	00005097          	auipc	ra,0x5
     cf6:	282080e7          	jalr	642(ra) # 5f74 <printf>
      exit(1);
     cfa:	4505                	li	a0,1
     cfc:	00005097          	auipc	ra,0x5
     d00:	f00080e7          	jalr	-256(ra) # 5bfc <exit>
      printf("%s: read content of block %d is %d\n", s,
     d04:	8626                	mv	a2,s1
     d06:	85d6                	mv	a1,s5
     d08:	00006517          	auipc	a0,0x6
     d0c:	91850513          	add	a0,a0,-1768 # 6620 <malloc+0x5f4>
     d10:	00005097          	auipc	ra,0x5
     d14:	264080e7          	jalr	612(ra) # 5f74 <printf>
      exit(1);
     d18:	4505                	li	a0,1
     d1a:	00005097          	auipc	ra,0x5
     d1e:	ee2080e7          	jalr	-286(ra) # 5bfc <exit>
    printf("%s: unlink big failed\n", s);
     d22:	85d6                	mv	a1,s5
     d24:	00006517          	auipc	a0,0x6
     d28:	92450513          	add	a0,a0,-1756 # 6648 <malloc+0x61c>
     d2c:	00005097          	auipc	ra,0x5
     d30:	248080e7          	jalr	584(ra) # 5f74 <printf>
    exit(1);
     d34:	4505                	li	a0,1
     d36:	00005097          	auipc	ra,0x5
     d3a:	ec6080e7          	jalr	-314(ra) # 5bfc <exit>

0000000000000d3e <unlinkread>:
{
     d3e:	7179                	add	sp,sp,-48
     d40:	f406                	sd	ra,40(sp)
     d42:	f022                	sd	s0,32(sp)
     d44:	ec26                	sd	s1,24(sp)
     d46:	e84a                	sd	s2,16(sp)
     d48:	e44e                	sd	s3,8(sp)
     d4a:	1800                	add	s0,sp,48
     d4c:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     d4e:	20200593          	li	a1,514
     d52:	00006517          	auipc	a0,0x6
     d56:	90e50513          	add	a0,a0,-1778 # 6660 <malloc+0x634>
     d5a:	00005097          	auipc	ra,0x5
     d5e:	ee2080e7          	jalr	-286(ra) # 5c3c <open>
  if(fd < 0){
     d62:	0e054563          	bltz	a0,e4c <unlinkread+0x10e>
     d66:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     d68:	4615                	li	a2,5
     d6a:	00006597          	auipc	a1,0x6
     d6e:	92658593          	add	a1,a1,-1754 # 6690 <malloc+0x664>
     d72:	00005097          	auipc	ra,0x5
     d76:	eaa080e7          	jalr	-342(ra) # 5c1c <write>
  close(fd);
     d7a:	8526                	mv	a0,s1
     d7c:	00005097          	auipc	ra,0x5
     d80:	ea8080e7          	jalr	-344(ra) # 5c24 <close>
  fd = open("unlinkread", O_RDWR);
     d84:	4589                	li	a1,2
     d86:	00006517          	auipc	a0,0x6
     d8a:	8da50513          	add	a0,a0,-1830 # 6660 <malloc+0x634>
     d8e:	00005097          	auipc	ra,0x5
     d92:	eae080e7          	jalr	-338(ra) # 5c3c <open>
     d96:	84aa                	mv	s1,a0
  if(fd < 0){
     d98:	0c054863          	bltz	a0,e68 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     d9c:	00006517          	auipc	a0,0x6
     da0:	8c450513          	add	a0,a0,-1852 # 6660 <malloc+0x634>
     da4:	00005097          	auipc	ra,0x5
     da8:	ea8080e7          	jalr	-344(ra) # 5c4c <unlink>
     dac:	ed61                	bnez	a0,e84 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     dae:	20200593          	li	a1,514
     db2:	00006517          	auipc	a0,0x6
     db6:	8ae50513          	add	a0,a0,-1874 # 6660 <malloc+0x634>
     dba:	00005097          	auipc	ra,0x5
     dbe:	e82080e7          	jalr	-382(ra) # 5c3c <open>
     dc2:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     dc4:	460d                	li	a2,3
     dc6:	00006597          	auipc	a1,0x6
     dca:	91258593          	add	a1,a1,-1774 # 66d8 <malloc+0x6ac>
     dce:	00005097          	auipc	ra,0x5
     dd2:	e4e080e7          	jalr	-434(ra) # 5c1c <write>
  close(fd1);
     dd6:	854a                	mv	a0,s2
     dd8:	00005097          	auipc	ra,0x5
     ddc:	e4c080e7          	jalr	-436(ra) # 5c24 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     de0:	660d                	lui	a2,0x3
     de2:	0000c597          	auipc	a1,0xc
     de6:	e9658593          	add	a1,a1,-362 # cc78 <buf>
     dea:	8526                	mv	a0,s1
     dec:	00005097          	auipc	ra,0x5
     df0:	e28080e7          	jalr	-472(ra) # 5c14 <read>
     df4:	4795                	li	a5,5
     df6:	0af51563          	bne	a0,a5,ea0 <unlinkread+0x162>
  if(buf[0] != 'h'){
     dfa:	0000c717          	auipc	a4,0xc
     dfe:	e7e74703          	lbu	a4,-386(a4) # cc78 <buf>
     e02:	06800793          	li	a5,104
     e06:	0af71b63          	bne	a4,a5,ebc <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     e0a:	4629                	li	a2,10
     e0c:	0000c597          	auipc	a1,0xc
     e10:	e6c58593          	add	a1,a1,-404 # cc78 <buf>
     e14:	8526                	mv	a0,s1
     e16:	00005097          	auipc	ra,0x5
     e1a:	e06080e7          	jalr	-506(ra) # 5c1c <write>
     e1e:	47a9                	li	a5,10
     e20:	0af51c63          	bne	a0,a5,ed8 <unlinkread+0x19a>
  close(fd);
     e24:	8526                	mv	a0,s1
     e26:	00005097          	auipc	ra,0x5
     e2a:	dfe080e7          	jalr	-514(ra) # 5c24 <close>
  unlink("unlinkread");
     e2e:	00006517          	auipc	a0,0x6
     e32:	83250513          	add	a0,a0,-1998 # 6660 <malloc+0x634>
     e36:	00005097          	auipc	ra,0x5
     e3a:	e16080e7          	jalr	-490(ra) # 5c4c <unlink>
}
     e3e:	70a2                	ld	ra,40(sp)
     e40:	7402                	ld	s0,32(sp)
     e42:	64e2                	ld	s1,24(sp)
     e44:	6942                	ld	s2,16(sp)
     e46:	69a2                	ld	s3,8(sp)
     e48:	6145                	add	sp,sp,48
     e4a:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     e4c:	85ce                	mv	a1,s3
     e4e:	00006517          	auipc	a0,0x6
     e52:	82250513          	add	a0,a0,-2014 # 6670 <malloc+0x644>
     e56:	00005097          	auipc	ra,0x5
     e5a:	11e080e7          	jalr	286(ra) # 5f74 <printf>
    exit(1);
     e5e:	4505                	li	a0,1
     e60:	00005097          	auipc	ra,0x5
     e64:	d9c080e7          	jalr	-612(ra) # 5bfc <exit>
    printf("%s: open unlinkread failed\n", s);
     e68:	85ce                	mv	a1,s3
     e6a:	00006517          	auipc	a0,0x6
     e6e:	82e50513          	add	a0,a0,-2002 # 6698 <malloc+0x66c>
     e72:	00005097          	auipc	ra,0x5
     e76:	102080e7          	jalr	258(ra) # 5f74 <printf>
    exit(1);
     e7a:	4505                	li	a0,1
     e7c:	00005097          	auipc	ra,0x5
     e80:	d80080e7          	jalr	-640(ra) # 5bfc <exit>
    printf("%s: unlink unlinkread failed\n", s);
     e84:	85ce                	mv	a1,s3
     e86:	00006517          	auipc	a0,0x6
     e8a:	83250513          	add	a0,a0,-1998 # 66b8 <malloc+0x68c>
     e8e:	00005097          	auipc	ra,0x5
     e92:	0e6080e7          	jalr	230(ra) # 5f74 <printf>
    exit(1);
     e96:	4505                	li	a0,1
     e98:	00005097          	auipc	ra,0x5
     e9c:	d64080e7          	jalr	-668(ra) # 5bfc <exit>
    printf("%s: unlinkread read failed", s);
     ea0:	85ce                	mv	a1,s3
     ea2:	00006517          	auipc	a0,0x6
     ea6:	83e50513          	add	a0,a0,-1986 # 66e0 <malloc+0x6b4>
     eaa:	00005097          	auipc	ra,0x5
     eae:	0ca080e7          	jalr	202(ra) # 5f74 <printf>
    exit(1);
     eb2:	4505                	li	a0,1
     eb4:	00005097          	auipc	ra,0x5
     eb8:	d48080e7          	jalr	-696(ra) # 5bfc <exit>
    printf("%s: unlinkread wrong data\n", s);
     ebc:	85ce                	mv	a1,s3
     ebe:	00006517          	auipc	a0,0x6
     ec2:	84250513          	add	a0,a0,-1982 # 6700 <malloc+0x6d4>
     ec6:	00005097          	auipc	ra,0x5
     eca:	0ae080e7          	jalr	174(ra) # 5f74 <printf>
    exit(1);
     ece:	4505                	li	a0,1
     ed0:	00005097          	auipc	ra,0x5
     ed4:	d2c080e7          	jalr	-724(ra) # 5bfc <exit>
    printf("%s: unlinkread write failed\n", s);
     ed8:	85ce                	mv	a1,s3
     eda:	00006517          	auipc	a0,0x6
     ede:	84650513          	add	a0,a0,-1978 # 6720 <malloc+0x6f4>
     ee2:	00005097          	auipc	ra,0x5
     ee6:	092080e7          	jalr	146(ra) # 5f74 <printf>
    exit(1);
     eea:	4505                	li	a0,1
     eec:	00005097          	auipc	ra,0x5
     ef0:	d10080e7          	jalr	-752(ra) # 5bfc <exit>

0000000000000ef4 <linktest>:
{
     ef4:	1101                	add	sp,sp,-32
     ef6:	ec06                	sd	ra,24(sp)
     ef8:	e822                	sd	s0,16(sp)
     efa:	e426                	sd	s1,8(sp)
     efc:	e04a                	sd	s2,0(sp)
     efe:	1000                	add	s0,sp,32
     f00:	892a                	mv	s2,a0
  unlink("lf1");
     f02:	00006517          	auipc	a0,0x6
     f06:	83e50513          	add	a0,a0,-1986 # 6740 <malloc+0x714>
     f0a:	00005097          	auipc	ra,0x5
     f0e:	d42080e7          	jalr	-702(ra) # 5c4c <unlink>
  unlink("lf2");
     f12:	00006517          	auipc	a0,0x6
     f16:	83650513          	add	a0,a0,-1994 # 6748 <malloc+0x71c>
     f1a:	00005097          	auipc	ra,0x5
     f1e:	d32080e7          	jalr	-718(ra) # 5c4c <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     f22:	20200593          	li	a1,514
     f26:	00006517          	auipc	a0,0x6
     f2a:	81a50513          	add	a0,a0,-2022 # 6740 <malloc+0x714>
     f2e:	00005097          	auipc	ra,0x5
     f32:	d0e080e7          	jalr	-754(ra) # 5c3c <open>
  if(fd < 0){
     f36:	10054763          	bltz	a0,1044 <linktest+0x150>
     f3a:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     f3c:	4615                	li	a2,5
     f3e:	00005597          	auipc	a1,0x5
     f42:	75258593          	add	a1,a1,1874 # 6690 <malloc+0x664>
     f46:	00005097          	auipc	ra,0x5
     f4a:	cd6080e7          	jalr	-810(ra) # 5c1c <write>
     f4e:	4795                	li	a5,5
     f50:	10f51863          	bne	a0,a5,1060 <linktest+0x16c>
  close(fd);
     f54:	8526                	mv	a0,s1
     f56:	00005097          	auipc	ra,0x5
     f5a:	cce080e7          	jalr	-818(ra) # 5c24 <close>
  if(link("lf1", "lf2") < 0){
     f5e:	00005597          	auipc	a1,0x5
     f62:	7ea58593          	add	a1,a1,2026 # 6748 <malloc+0x71c>
     f66:	00005517          	auipc	a0,0x5
     f6a:	7da50513          	add	a0,a0,2010 # 6740 <malloc+0x714>
     f6e:	00005097          	auipc	ra,0x5
     f72:	cee080e7          	jalr	-786(ra) # 5c5c <link>
     f76:	10054363          	bltz	a0,107c <linktest+0x188>
  unlink("lf1");
     f7a:	00005517          	auipc	a0,0x5
     f7e:	7c650513          	add	a0,a0,1990 # 6740 <malloc+0x714>
     f82:	00005097          	auipc	ra,0x5
     f86:	cca080e7          	jalr	-822(ra) # 5c4c <unlink>
  if(open("lf1", 0) >= 0){
     f8a:	4581                	li	a1,0
     f8c:	00005517          	auipc	a0,0x5
     f90:	7b450513          	add	a0,a0,1972 # 6740 <malloc+0x714>
     f94:	00005097          	auipc	ra,0x5
     f98:	ca8080e7          	jalr	-856(ra) # 5c3c <open>
     f9c:	0e055e63          	bgez	a0,1098 <linktest+0x1a4>
  fd = open("lf2", 0);
     fa0:	4581                	li	a1,0
     fa2:	00005517          	auipc	a0,0x5
     fa6:	7a650513          	add	a0,a0,1958 # 6748 <malloc+0x71c>
     faa:	00005097          	auipc	ra,0x5
     fae:	c92080e7          	jalr	-878(ra) # 5c3c <open>
     fb2:	84aa                	mv	s1,a0
  if(fd < 0){
     fb4:	10054063          	bltz	a0,10b4 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     fb8:	660d                	lui	a2,0x3
     fba:	0000c597          	auipc	a1,0xc
     fbe:	cbe58593          	add	a1,a1,-834 # cc78 <buf>
     fc2:	00005097          	auipc	ra,0x5
     fc6:	c52080e7          	jalr	-942(ra) # 5c14 <read>
     fca:	4795                	li	a5,5
     fcc:	10f51263          	bne	a0,a5,10d0 <linktest+0x1dc>
  close(fd);
     fd0:	8526                	mv	a0,s1
     fd2:	00005097          	auipc	ra,0x5
     fd6:	c52080e7          	jalr	-942(ra) # 5c24 <close>
  if(link("lf2", "lf2") >= 0){
     fda:	00005597          	auipc	a1,0x5
     fde:	76e58593          	add	a1,a1,1902 # 6748 <malloc+0x71c>
     fe2:	852e                	mv	a0,a1
     fe4:	00005097          	auipc	ra,0x5
     fe8:	c78080e7          	jalr	-904(ra) # 5c5c <link>
     fec:	10055063          	bgez	a0,10ec <linktest+0x1f8>
  unlink("lf2");
     ff0:	00005517          	auipc	a0,0x5
     ff4:	75850513          	add	a0,a0,1880 # 6748 <malloc+0x71c>
     ff8:	00005097          	auipc	ra,0x5
     ffc:	c54080e7          	jalr	-940(ra) # 5c4c <unlink>
  if(link("lf2", "lf1") >= 0){
    1000:	00005597          	auipc	a1,0x5
    1004:	74058593          	add	a1,a1,1856 # 6740 <malloc+0x714>
    1008:	00005517          	auipc	a0,0x5
    100c:	74050513          	add	a0,a0,1856 # 6748 <malloc+0x71c>
    1010:	00005097          	auipc	ra,0x5
    1014:	c4c080e7          	jalr	-948(ra) # 5c5c <link>
    1018:	0e055863          	bgez	a0,1108 <linktest+0x214>
  if(link(".", "lf1") >= 0){
    101c:	00005597          	auipc	a1,0x5
    1020:	72458593          	add	a1,a1,1828 # 6740 <malloc+0x714>
    1024:	00006517          	auipc	a0,0x6
    1028:	82c50513          	add	a0,a0,-2004 # 6850 <malloc+0x824>
    102c:	00005097          	auipc	ra,0x5
    1030:	c30080e7          	jalr	-976(ra) # 5c5c <link>
    1034:	0e055863          	bgez	a0,1124 <linktest+0x230>
}
    1038:	60e2                	ld	ra,24(sp)
    103a:	6442                	ld	s0,16(sp)
    103c:	64a2                	ld	s1,8(sp)
    103e:	6902                	ld	s2,0(sp)
    1040:	6105                	add	sp,sp,32
    1042:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1044:	85ca                	mv	a1,s2
    1046:	00005517          	auipc	a0,0x5
    104a:	70a50513          	add	a0,a0,1802 # 6750 <malloc+0x724>
    104e:	00005097          	auipc	ra,0x5
    1052:	f26080e7          	jalr	-218(ra) # 5f74 <printf>
    exit(1);
    1056:	4505                	li	a0,1
    1058:	00005097          	auipc	ra,0x5
    105c:	ba4080e7          	jalr	-1116(ra) # 5bfc <exit>
    printf("%s: write lf1 failed\n", s);
    1060:	85ca                	mv	a1,s2
    1062:	00005517          	auipc	a0,0x5
    1066:	70650513          	add	a0,a0,1798 # 6768 <malloc+0x73c>
    106a:	00005097          	auipc	ra,0x5
    106e:	f0a080e7          	jalr	-246(ra) # 5f74 <printf>
    exit(1);
    1072:	4505                	li	a0,1
    1074:	00005097          	auipc	ra,0x5
    1078:	b88080e7          	jalr	-1144(ra) # 5bfc <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    107c:	85ca                	mv	a1,s2
    107e:	00005517          	auipc	a0,0x5
    1082:	70250513          	add	a0,a0,1794 # 6780 <malloc+0x754>
    1086:	00005097          	auipc	ra,0x5
    108a:	eee080e7          	jalr	-274(ra) # 5f74 <printf>
    exit(1);
    108e:	4505                	li	a0,1
    1090:	00005097          	auipc	ra,0x5
    1094:	b6c080e7          	jalr	-1172(ra) # 5bfc <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    1098:	85ca                	mv	a1,s2
    109a:	00005517          	auipc	a0,0x5
    109e:	70650513          	add	a0,a0,1798 # 67a0 <malloc+0x774>
    10a2:	00005097          	auipc	ra,0x5
    10a6:	ed2080e7          	jalr	-302(ra) # 5f74 <printf>
    exit(1);
    10aa:	4505                	li	a0,1
    10ac:	00005097          	auipc	ra,0x5
    10b0:	b50080e7          	jalr	-1200(ra) # 5bfc <exit>
    printf("%s: open lf2 failed\n", s);
    10b4:	85ca                	mv	a1,s2
    10b6:	00005517          	auipc	a0,0x5
    10ba:	71a50513          	add	a0,a0,1818 # 67d0 <malloc+0x7a4>
    10be:	00005097          	auipc	ra,0x5
    10c2:	eb6080e7          	jalr	-330(ra) # 5f74 <printf>
    exit(1);
    10c6:	4505                	li	a0,1
    10c8:	00005097          	auipc	ra,0x5
    10cc:	b34080e7          	jalr	-1228(ra) # 5bfc <exit>
    printf("%s: read lf2 failed\n", s);
    10d0:	85ca                	mv	a1,s2
    10d2:	00005517          	auipc	a0,0x5
    10d6:	71650513          	add	a0,a0,1814 # 67e8 <malloc+0x7bc>
    10da:	00005097          	auipc	ra,0x5
    10de:	e9a080e7          	jalr	-358(ra) # 5f74 <printf>
    exit(1);
    10e2:	4505                	li	a0,1
    10e4:	00005097          	auipc	ra,0x5
    10e8:	b18080e7          	jalr	-1256(ra) # 5bfc <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    10ec:	85ca                	mv	a1,s2
    10ee:	00005517          	auipc	a0,0x5
    10f2:	71250513          	add	a0,a0,1810 # 6800 <malloc+0x7d4>
    10f6:	00005097          	auipc	ra,0x5
    10fa:	e7e080e7          	jalr	-386(ra) # 5f74 <printf>
    exit(1);
    10fe:	4505                	li	a0,1
    1100:	00005097          	auipc	ra,0x5
    1104:	afc080e7          	jalr	-1284(ra) # 5bfc <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    1108:	85ca                	mv	a1,s2
    110a:	00005517          	auipc	a0,0x5
    110e:	71e50513          	add	a0,a0,1822 # 6828 <malloc+0x7fc>
    1112:	00005097          	auipc	ra,0x5
    1116:	e62080e7          	jalr	-414(ra) # 5f74 <printf>
    exit(1);
    111a:	4505                	li	a0,1
    111c:	00005097          	auipc	ra,0x5
    1120:	ae0080e7          	jalr	-1312(ra) # 5bfc <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1124:	85ca                	mv	a1,s2
    1126:	00005517          	auipc	a0,0x5
    112a:	73250513          	add	a0,a0,1842 # 6858 <malloc+0x82c>
    112e:	00005097          	auipc	ra,0x5
    1132:	e46080e7          	jalr	-442(ra) # 5f74 <printf>
    exit(1);
    1136:	4505                	li	a0,1
    1138:	00005097          	auipc	ra,0x5
    113c:	ac4080e7          	jalr	-1340(ra) # 5bfc <exit>

0000000000001140 <validatetest>:
{
    1140:	7139                	add	sp,sp,-64
    1142:	fc06                	sd	ra,56(sp)
    1144:	f822                	sd	s0,48(sp)
    1146:	f426                	sd	s1,40(sp)
    1148:	f04a                	sd	s2,32(sp)
    114a:	ec4e                	sd	s3,24(sp)
    114c:	e852                	sd	s4,16(sp)
    114e:	e456                	sd	s5,8(sp)
    1150:	e05a                	sd	s6,0(sp)
    1152:	0080                	add	s0,sp,64
    1154:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1156:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    1158:	00005997          	auipc	s3,0x5
    115c:	72098993          	add	s3,s3,1824 # 6878 <malloc+0x84c>
    1160:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1162:	6a85                	lui	s5,0x1
    1164:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1168:	85a6                	mv	a1,s1
    116a:	854e                	mv	a0,s3
    116c:	00005097          	auipc	ra,0x5
    1170:	af0080e7          	jalr	-1296(ra) # 5c5c <link>
    1174:	01251f63          	bne	a0,s2,1192 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1178:	94d6                	add	s1,s1,s5
    117a:	ff4497e3          	bne	s1,s4,1168 <validatetest+0x28>
}
    117e:	70e2                	ld	ra,56(sp)
    1180:	7442                	ld	s0,48(sp)
    1182:	74a2                	ld	s1,40(sp)
    1184:	7902                	ld	s2,32(sp)
    1186:	69e2                	ld	s3,24(sp)
    1188:	6a42                	ld	s4,16(sp)
    118a:	6aa2                	ld	s5,8(sp)
    118c:	6b02                	ld	s6,0(sp)
    118e:	6121                	add	sp,sp,64
    1190:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1192:	85da                	mv	a1,s6
    1194:	00005517          	auipc	a0,0x5
    1198:	6f450513          	add	a0,a0,1780 # 6888 <malloc+0x85c>
    119c:	00005097          	auipc	ra,0x5
    11a0:	dd8080e7          	jalr	-552(ra) # 5f74 <printf>
      exit(1);
    11a4:	4505                	li	a0,1
    11a6:	00005097          	auipc	ra,0x5
    11aa:	a56080e7          	jalr	-1450(ra) # 5bfc <exit>

00000000000011ae <bigdir>:
{
    11ae:	715d                	add	sp,sp,-80
    11b0:	e486                	sd	ra,72(sp)
    11b2:	e0a2                	sd	s0,64(sp)
    11b4:	fc26                	sd	s1,56(sp)
    11b6:	f84a                	sd	s2,48(sp)
    11b8:	f44e                	sd	s3,40(sp)
    11ba:	f052                	sd	s4,32(sp)
    11bc:	ec56                	sd	s5,24(sp)
    11be:	e85a                	sd	s6,16(sp)
    11c0:	0880                	add	s0,sp,80
    11c2:	89aa                	mv	s3,a0
  unlink("bd");
    11c4:	00005517          	auipc	a0,0x5
    11c8:	6e450513          	add	a0,a0,1764 # 68a8 <malloc+0x87c>
    11cc:	00005097          	auipc	ra,0x5
    11d0:	a80080e7          	jalr	-1408(ra) # 5c4c <unlink>
  fd = open("bd", O_CREATE);
    11d4:	20000593          	li	a1,512
    11d8:	00005517          	auipc	a0,0x5
    11dc:	6d050513          	add	a0,a0,1744 # 68a8 <malloc+0x87c>
    11e0:	00005097          	auipc	ra,0x5
    11e4:	a5c080e7          	jalr	-1444(ra) # 5c3c <open>
  if(fd < 0){
    11e8:	0c054963          	bltz	a0,12ba <bigdir+0x10c>
  close(fd);
    11ec:	00005097          	auipc	ra,0x5
    11f0:	a38080e7          	jalr	-1480(ra) # 5c24 <close>
  for(i = 0; i < N; i++){
    11f4:	4901                	li	s2,0
    name[0] = 'x';
    11f6:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    11fa:	00005a17          	auipc	s4,0x5
    11fe:	6aea0a13          	add	s4,s4,1710 # 68a8 <malloc+0x87c>
  for(i = 0; i < N; i++){
    1202:	1f400b13          	li	s6,500
    name[0] = 'x';
    1206:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    120a:	41f9571b          	sraw	a4,s2,0x1f
    120e:	01a7571b          	srlw	a4,a4,0x1a
    1212:	012707bb          	addw	a5,a4,s2
    1216:	4067d69b          	sraw	a3,a5,0x6
    121a:	0306869b          	addw	a3,a3,48
    121e:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1222:	03f7f793          	and	a5,a5,63
    1226:	9f99                	subw	a5,a5,a4
    1228:	0307879b          	addw	a5,a5,48
    122c:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1230:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    1234:	fb040593          	add	a1,s0,-80
    1238:	8552                	mv	a0,s4
    123a:	00005097          	auipc	ra,0x5
    123e:	a22080e7          	jalr	-1502(ra) # 5c5c <link>
    1242:	84aa                	mv	s1,a0
    1244:	e949                	bnez	a0,12d6 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1246:	2905                	addw	s2,s2,1
    1248:	fb691fe3          	bne	s2,s6,1206 <bigdir+0x58>
  unlink("bd");
    124c:	00005517          	auipc	a0,0x5
    1250:	65c50513          	add	a0,a0,1628 # 68a8 <malloc+0x87c>
    1254:	00005097          	auipc	ra,0x5
    1258:	9f8080e7          	jalr	-1544(ra) # 5c4c <unlink>
    name[0] = 'x';
    125c:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1260:	1f400a13          	li	s4,500
    name[0] = 'x';
    1264:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1268:	41f4d71b          	sraw	a4,s1,0x1f
    126c:	01a7571b          	srlw	a4,a4,0x1a
    1270:	009707bb          	addw	a5,a4,s1
    1274:	4067d69b          	sraw	a3,a5,0x6
    1278:	0306869b          	addw	a3,a3,48
    127c:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1280:	03f7f793          	and	a5,a5,63
    1284:	9f99                	subw	a5,a5,a4
    1286:	0307879b          	addw	a5,a5,48
    128a:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    128e:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1292:	fb040513          	add	a0,s0,-80
    1296:	00005097          	auipc	ra,0x5
    129a:	9b6080e7          	jalr	-1610(ra) # 5c4c <unlink>
    129e:	ed21                	bnez	a0,12f6 <bigdir+0x148>
  for(i = 0; i < N; i++){
    12a0:	2485                	addw	s1,s1,1
    12a2:	fd4491e3          	bne	s1,s4,1264 <bigdir+0xb6>
}
    12a6:	60a6                	ld	ra,72(sp)
    12a8:	6406                	ld	s0,64(sp)
    12aa:	74e2                	ld	s1,56(sp)
    12ac:	7942                	ld	s2,48(sp)
    12ae:	79a2                	ld	s3,40(sp)
    12b0:	7a02                	ld	s4,32(sp)
    12b2:	6ae2                	ld	s5,24(sp)
    12b4:	6b42                	ld	s6,16(sp)
    12b6:	6161                	add	sp,sp,80
    12b8:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    12ba:	85ce                	mv	a1,s3
    12bc:	00005517          	auipc	a0,0x5
    12c0:	5f450513          	add	a0,a0,1524 # 68b0 <malloc+0x884>
    12c4:	00005097          	auipc	ra,0x5
    12c8:	cb0080e7          	jalr	-848(ra) # 5f74 <printf>
    exit(1);
    12cc:	4505                	li	a0,1
    12ce:	00005097          	auipc	ra,0x5
    12d2:	92e080e7          	jalr	-1746(ra) # 5bfc <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    12d6:	fb040613          	add	a2,s0,-80
    12da:	85ce                	mv	a1,s3
    12dc:	00005517          	auipc	a0,0x5
    12e0:	5f450513          	add	a0,a0,1524 # 68d0 <malloc+0x8a4>
    12e4:	00005097          	auipc	ra,0x5
    12e8:	c90080e7          	jalr	-880(ra) # 5f74 <printf>
      exit(1);
    12ec:	4505                	li	a0,1
    12ee:	00005097          	auipc	ra,0x5
    12f2:	90e080e7          	jalr	-1778(ra) # 5bfc <exit>
      printf("%s: bigdir unlink failed", s);
    12f6:	85ce                	mv	a1,s3
    12f8:	00005517          	auipc	a0,0x5
    12fc:	5f850513          	add	a0,a0,1528 # 68f0 <malloc+0x8c4>
    1300:	00005097          	auipc	ra,0x5
    1304:	c74080e7          	jalr	-908(ra) # 5f74 <printf>
      exit(1);
    1308:	4505                	li	a0,1
    130a:	00005097          	auipc	ra,0x5
    130e:	8f2080e7          	jalr	-1806(ra) # 5bfc <exit>

0000000000001312 <pgbug>:
{
    1312:	7179                	add	sp,sp,-48
    1314:	f406                	sd	ra,40(sp)
    1316:	f022                	sd	s0,32(sp)
    1318:	ec26                	sd	s1,24(sp)
    131a:	1800                	add	s0,sp,48
  argv[0] = 0;
    131c:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
    1320:	00008497          	auipc	s1,0x8
    1324:	ce048493          	add	s1,s1,-800 # 9000 <big>
    1328:	fd840593          	add	a1,s0,-40
    132c:	6088                	ld	a0,0(s1)
    132e:	00005097          	auipc	ra,0x5
    1332:	906080e7          	jalr	-1786(ra) # 5c34 <exec>
  pipe(big);
    1336:	6088                	ld	a0,0(s1)
    1338:	00005097          	auipc	ra,0x5
    133c:	8d4080e7          	jalr	-1836(ra) # 5c0c <pipe>
  exit(0);
    1340:	4501                	li	a0,0
    1342:	00005097          	auipc	ra,0x5
    1346:	8ba080e7          	jalr	-1862(ra) # 5bfc <exit>

000000000000134a <badarg>:
{
    134a:	7139                	add	sp,sp,-64
    134c:	fc06                	sd	ra,56(sp)
    134e:	f822                	sd	s0,48(sp)
    1350:	f426                	sd	s1,40(sp)
    1352:	f04a                	sd	s2,32(sp)
    1354:	ec4e                	sd	s3,24(sp)
    1356:	0080                	add	s0,sp,64
    1358:	64b1                	lui	s1,0xc
    135a:	35048493          	add	s1,s1,848 # c350 <uninit+0x1de8>
    argv[0] = (char*)0xffffffff;
    135e:	597d                	li	s2,-1
    1360:	02095913          	srl	s2,s2,0x20
    exec("echo", argv);
    1364:	00005997          	auipc	s3,0x5
    1368:	e0498993          	add	s3,s3,-508 # 6168 <malloc+0x13c>
    argv[0] = (char*)0xffffffff;
    136c:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1370:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1374:	fc040593          	add	a1,s0,-64
    1378:	854e                	mv	a0,s3
    137a:	00005097          	auipc	ra,0x5
    137e:	8ba080e7          	jalr	-1862(ra) # 5c34 <exec>
  for(int i = 0; i < 50000; i++){
    1382:	34fd                	addw	s1,s1,-1
    1384:	f4e5                	bnez	s1,136c <badarg+0x22>
  exit(0);
    1386:	4501                	li	a0,0
    1388:	00005097          	auipc	ra,0x5
    138c:	874080e7          	jalr	-1932(ra) # 5bfc <exit>

0000000000001390 <copyinstr2>:
{
    1390:	7155                	add	sp,sp,-208
    1392:	e586                	sd	ra,200(sp)
    1394:	e1a2                	sd	s0,192(sp)
    1396:	0980                	add	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1398:	f6840793          	add	a5,s0,-152
    139c:	fe840693          	add	a3,s0,-24
    b[i] = 'x';
    13a0:	07800713          	li	a4,120
    13a4:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    13a8:	0785                	add	a5,a5,1
    13aa:	fed79de3          	bne	a5,a3,13a4 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    13ae:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    13b2:	f6840513          	add	a0,s0,-152
    13b6:	00005097          	auipc	ra,0x5
    13ba:	896080e7          	jalr	-1898(ra) # 5c4c <unlink>
  if(ret != -1){
    13be:	57fd                	li	a5,-1
    13c0:	0ef51063          	bne	a0,a5,14a0 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    13c4:	20100593          	li	a1,513
    13c8:	f6840513          	add	a0,s0,-152
    13cc:	00005097          	auipc	ra,0x5
    13d0:	870080e7          	jalr	-1936(ra) # 5c3c <open>
  if(fd != -1){
    13d4:	57fd                	li	a5,-1
    13d6:	0ef51563          	bne	a0,a5,14c0 <copyinstr2+0x130>
  ret = link(b, b);
    13da:	f6840593          	add	a1,s0,-152
    13de:	852e                	mv	a0,a1
    13e0:	00005097          	auipc	ra,0x5
    13e4:	87c080e7          	jalr	-1924(ra) # 5c5c <link>
  if(ret != -1){
    13e8:	57fd                	li	a5,-1
    13ea:	0ef51b63          	bne	a0,a5,14e0 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    13ee:	00006797          	auipc	a5,0x6
    13f2:	75a78793          	add	a5,a5,1882 # 7b48 <malloc+0x1b1c>
    13f6:	f4f43c23          	sd	a5,-168(s0)
    13fa:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    13fe:	f5840593          	add	a1,s0,-168
    1402:	f6840513          	add	a0,s0,-152
    1406:	00005097          	auipc	ra,0x5
    140a:	82e080e7          	jalr	-2002(ra) # 5c34 <exec>
  if(ret != -1){
    140e:	57fd                	li	a5,-1
    1410:	0ef51963          	bne	a0,a5,1502 <copyinstr2+0x172>
  int pid = fork();
    1414:	00004097          	auipc	ra,0x4
    1418:	7e0080e7          	jalr	2016(ra) # 5bf4 <fork>
  if(pid < 0){
    141c:	10054363          	bltz	a0,1522 <copyinstr2+0x192>
  if(pid == 0){
    1420:	12051463          	bnez	a0,1548 <copyinstr2+0x1b8>
    1424:	00008797          	auipc	a5,0x8
    1428:	13c78793          	add	a5,a5,316 # 9560 <big.0>
    142c:	00009697          	auipc	a3,0x9
    1430:	13468693          	add	a3,a3,308 # a560 <big.0+0x1000>
      big[i] = 'x';
    1434:	07800713          	li	a4,120
    1438:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    143c:	0785                	add	a5,a5,1
    143e:	fed79de3          	bne	a5,a3,1438 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1442:	00009797          	auipc	a5,0x9
    1446:	10078f23          	sb	zero,286(a5) # a560 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    144a:	00007797          	auipc	a5,0x7
    144e:	14678793          	add	a5,a5,326 # 8590 <malloc+0x2564>
    1452:	6390                	ld	a2,0(a5)
    1454:	6794                	ld	a3,8(a5)
    1456:	6b98                	ld	a4,16(a5)
    1458:	6f9c                	ld	a5,24(a5)
    145a:	f2c43823          	sd	a2,-208(s0)
    145e:	f2d43c23          	sd	a3,-200(s0)
    1462:	f4e43023          	sd	a4,-192(s0)
    1466:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    146a:	f3040593          	add	a1,s0,-208
    146e:	00005517          	auipc	a0,0x5
    1472:	cfa50513          	add	a0,a0,-774 # 6168 <malloc+0x13c>
    1476:	00004097          	auipc	ra,0x4
    147a:	7be080e7          	jalr	1982(ra) # 5c34 <exec>
    if(ret != -1){
    147e:	57fd                	li	a5,-1
    1480:	0af50e63          	beq	a0,a5,153c <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1484:	55fd                	li	a1,-1
    1486:	00005517          	auipc	a0,0x5
    148a:	51250513          	add	a0,a0,1298 # 6998 <malloc+0x96c>
    148e:	00005097          	auipc	ra,0x5
    1492:	ae6080e7          	jalr	-1306(ra) # 5f74 <printf>
      exit(1);
    1496:	4505                	li	a0,1
    1498:	00004097          	auipc	ra,0x4
    149c:	764080e7          	jalr	1892(ra) # 5bfc <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    14a0:	862a                	mv	a2,a0
    14a2:	f6840593          	add	a1,s0,-152
    14a6:	00005517          	auipc	a0,0x5
    14aa:	46a50513          	add	a0,a0,1130 # 6910 <malloc+0x8e4>
    14ae:	00005097          	auipc	ra,0x5
    14b2:	ac6080e7          	jalr	-1338(ra) # 5f74 <printf>
    exit(1);
    14b6:	4505                	li	a0,1
    14b8:	00004097          	auipc	ra,0x4
    14bc:	744080e7          	jalr	1860(ra) # 5bfc <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    14c0:	862a                	mv	a2,a0
    14c2:	f6840593          	add	a1,s0,-152
    14c6:	00005517          	auipc	a0,0x5
    14ca:	46a50513          	add	a0,a0,1130 # 6930 <malloc+0x904>
    14ce:	00005097          	auipc	ra,0x5
    14d2:	aa6080e7          	jalr	-1370(ra) # 5f74 <printf>
    exit(1);
    14d6:	4505                	li	a0,1
    14d8:	00004097          	auipc	ra,0x4
    14dc:	724080e7          	jalr	1828(ra) # 5bfc <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    14e0:	86aa                	mv	a3,a0
    14e2:	f6840613          	add	a2,s0,-152
    14e6:	85b2                	mv	a1,a2
    14e8:	00005517          	auipc	a0,0x5
    14ec:	46850513          	add	a0,a0,1128 # 6950 <malloc+0x924>
    14f0:	00005097          	auipc	ra,0x5
    14f4:	a84080e7          	jalr	-1404(ra) # 5f74 <printf>
    exit(1);
    14f8:	4505                	li	a0,1
    14fa:	00004097          	auipc	ra,0x4
    14fe:	702080e7          	jalr	1794(ra) # 5bfc <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1502:	567d                	li	a2,-1
    1504:	f6840593          	add	a1,s0,-152
    1508:	00005517          	auipc	a0,0x5
    150c:	47050513          	add	a0,a0,1136 # 6978 <malloc+0x94c>
    1510:	00005097          	auipc	ra,0x5
    1514:	a64080e7          	jalr	-1436(ra) # 5f74 <printf>
    exit(1);
    1518:	4505                	li	a0,1
    151a:	00004097          	auipc	ra,0x4
    151e:	6e2080e7          	jalr	1762(ra) # 5bfc <exit>
    printf("fork failed\n");
    1522:	00006517          	auipc	a0,0x6
    1526:	8d650513          	add	a0,a0,-1834 # 6df8 <malloc+0xdcc>
    152a:	00005097          	auipc	ra,0x5
    152e:	a4a080e7          	jalr	-1462(ra) # 5f74 <printf>
    exit(1);
    1532:	4505                	li	a0,1
    1534:	00004097          	auipc	ra,0x4
    1538:	6c8080e7          	jalr	1736(ra) # 5bfc <exit>
    exit(747); // OK
    153c:	2eb00513          	li	a0,747
    1540:	00004097          	auipc	ra,0x4
    1544:	6bc080e7          	jalr	1724(ra) # 5bfc <exit>
  int st = 0;
    1548:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    154c:	f5440513          	add	a0,s0,-172
    1550:	00004097          	auipc	ra,0x4
    1554:	6b4080e7          	jalr	1716(ra) # 5c04 <wait>
  if(st != 747){
    1558:	f5442703          	lw	a4,-172(s0)
    155c:	2eb00793          	li	a5,747
    1560:	00f71663          	bne	a4,a5,156c <copyinstr2+0x1dc>
}
    1564:	60ae                	ld	ra,200(sp)
    1566:	640e                	ld	s0,192(sp)
    1568:	6169                	add	sp,sp,208
    156a:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    156c:	00005517          	auipc	a0,0x5
    1570:	45450513          	add	a0,a0,1108 # 69c0 <malloc+0x994>
    1574:	00005097          	auipc	ra,0x5
    1578:	a00080e7          	jalr	-1536(ra) # 5f74 <printf>
    exit(1);
    157c:	4505                	li	a0,1
    157e:	00004097          	auipc	ra,0x4
    1582:	67e080e7          	jalr	1662(ra) # 5bfc <exit>

0000000000001586 <truncate3>:
{
    1586:	7159                	add	sp,sp,-112
    1588:	f486                	sd	ra,104(sp)
    158a:	f0a2                	sd	s0,96(sp)
    158c:	e8ca                	sd	s2,80(sp)
    158e:	1880                	add	s0,sp,112
    1590:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    1592:	60100593          	li	a1,1537
    1596:	00005517          	auipc	a0,0x5
    159a:	c2a50513          	add	a0,a0,-982 # 61c0 <malloc+0x194>
    159e:	00004097          	auipc	ra,0x4
    15a2:	69e080e7          	jalr	1694(ra) # 5c3c <open>
    15a6:	00004097          	auipc	ra,0x4
    15aa:	67e080e7          	jalr	1662(ra) # 5c24 <close>
  pid = fork();
    15ae:	00004097          	auipc	ra,0x4
    15b2:	646080e7          	jalr	1606(ra) # 5bf4 <fork>
  if(pid < 0){
    15b6:	08054463          	bltz	a0,163e <truncate3+0xb8>
  if(pid == 0){
    15ba:	e16d                	bnez	a0,169c <truncate3+0x116>
    15bc:	eca6                	sd	s1,88(sp)
    15be:	e4ce                	sd	s3,72(sp)
    15c0:	e0d2                	sd	s4,64(sp)
    15c2:	fc56                	sd	s5,56(sp)
    15c4:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    15c8:	00005a17          	auipc	s4,0x5
    15cc:	bf8a0a13          	add	s4,s4,-1032 # 61c0 <malloc+0x194>
      int n = write(fd, "1234567890", 10);
    15d0:	00005a97          	auipc	s5,0x5
    15d4:	450a8a93          	add	s5,s5,1104 # 6a20 <malloc+0x9f4>
      int fd = open("truncfile", O_WRONLY);
    15d8:	4585                	li	a1,1
    15da:	8552                	mv	a0,s4
    15dc:	00004097          	auipc	ra,0x4
    15e0:	660080e7          	jalr	1632(ra) # 5c3c <open>
    15e4:	84aa                	mv	s1,a0
      if(fd < 0){
    15e6:	06054e63          	bltz	a0,1662 <truncate3+0xdc>
      int n = write(fd, "1234567890", 10);
    15ea:	4629                	li	a2,10
    15ec:	85d6                	mv	a1,s5
    15ee:	00004097          	auipc	ra,0x4
    15f2:	62e080e7          	jalr	1582(ra) # 5c1c <write>
      if(n != 10){
    15f6:	47a9                	li	a5,10
    15f8:	08f51363          	bne	a0,a5,167e <truncate3+0xf8>
      close(fd);
    15fc:	8526                	mv	a0,s1
    15fe:	00004097          	auipc	ra,0x4
    1602:	626080e7          	jalr	1574(ra) # 5c24 <close>
      fd = open("truncfile", O_RDONLY);
    1606:	4581                	li	a1,0
    1608:	8552                	mv	a0,s4
    160a:	00004097          	auipc	ra,0x4
    160e:	632080e7          	jalr	1586(ra) # 5c3c <open>
    1612:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1614:	02000613          	li	a2,32
    1618:	f9840593          	add	a1,s0,-104
    161c:	00004097          	auipc	ra,0x4
    1620:	5f8080e7          	jalr	1528(ra) # 5c14 <read>
      close(fd);
    1624:	8526                	mv	a0,s1
    1626:	00004097          	auipc	ra,0x4
    162a:	5fe080e7          	jalr	1534(ra) # 5c24 <close>
    for(int i = 0; i < 100; i++){
    162e:	39fd                	addw	s3,s3,-1
    1630:	fa0994e3          	bnez	s3,15d8 <truncate3+0x52>
    exit(0);
    1634:	4501                	li	a0,0
    1636:	00004097          	auipc	ra,0x4
    163a:	5c6080e7          	jalr	1478(ra) # 5bfc <exit>
    163e:	eca6                	sd	s1,88(sp)
    1640:	e4ce                	sd	s3,72(sp)
    1642:	e0d2                	sd	s4,64(sp)
    1644:	fc56                	sd	s5,56(sp)
    printf("%s: fork failed\n", s);
    1646:	85ca                	mv	a1,s2
    1648:	00005517          	auipc	a0,0x5
    164c:	3a850513          	add	a0,a0,936 # 69f0 <malloc+0x9c4>
    1650:	00005097          	auipc	ra,0x5
    1654:	924080e7          	jalr	-1756(ra) # 5f74 <printf>
    exit(1);
    1658:	4505                	li	a0,1
    165a:	00004097          	auipc	ra,0x4
    165e:	5a2080e7          	jalr	1442(ra) # 5bfc <exit>
        printf("%s: open failed\n", s);
    1662:	85ca                	mv	a1,s2
    1664:	00005517          	auipc	a0,0x5
    1668:	3a450513          	add	a0,a0,932 # 6a08 <malloc+0x9dc>
    166c:	00005097          	auipc	ra,0x5
    1670:	908080e7          	jalr	-1784(ra) # 5f74 <printf>
        exit(1);
    1674:	4505                	li	a0,1
    1676:	00004097          	auipc	ra,0x4
    167a:	586080e7          	jalr	1414(ra) # 5bfc <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    167e:	862a                	mv	a2,a0
    1680:	85ca                	mv	a1,s2
    1682:	00005517          	auipc	a0,0x5
    1686:	3ae50513          	add	a0,a0,942 # 6a30 <malloc+0xa04>
    168a:	00005097          	auipc	ra,0x5
    168e:	8ea080e7          	jalr	-1814(ra) # 5f74 <printf>
        exit(1);
    1692:	4505                	li	a0,1
    1694:	00004097          	auipc	ra,0x4
    1698:	568080e7          	jalr	1384(ra) # 5bfc <exit>
    169c:	eca6                	sd	s1,88(sp)
    169e:	e4ce                	sd	s3,72(sp)
    16a0:	e0d2                	sd	s4,64(sp)
    16a2:	fc56                	sd	s5,56(sp)
    16a4:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16a8:	00005a17          	auipc	s4,0x5
    16ac:	b18a0a13          	add	s4,s4,-1256 # 61c0 <malloc+0x194>
    int n = write(fd, "xxx", 3);
    16b0:	00005a97          	auipc	s5,0x5
    16b4:	3a0a8a93          	add	s5,s5,928 # 6a50 <malloc+0xa24>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    16b8:	60100593          	li	a1,1537
    16bc:	8552                	mv	a0,s4
    16be:	00004097          	auipc	ra,0x4
    16c2:	57e080e7          	jalr	1406(ra) # 5c3c <open>
    16c6:	84aa                	mv	s1,a0
    if(fd < 0){
    16c8:	04054763          	bltz	a0,1716 <truncate3+0x190>
    int n = write(fd, "xxx", 3);
    16cc:	460d                	li	a2,3
    16ce:	85d6                	mv	a1,s5
    16d0:	00004097          	auipc	ra,0x4
    16d4:	54c080e7          	jalr	1356(ra) # 5c1c <write>
    if(n != 3){
    16d8:	478d                	li	a5,3
    16da:	04f51c63          	bne	a0,a5,1732 <truncate3+0x1ac>
    close(fd);
    16de:	8526                	mv	a0,s1
    16e0:	00004097          	auipc	ra,0x4
    16e4:	544080e7          	jalr	1348(ra) # 5c24 <close>
  for(int i = 0; i < 150; i++){
    16e8:	39fd                	addw	s3,s3,-1
    16ea:	fc0997e3          	bnez	s3,16b8 <truncate3+0x132>
  wait(&xstatus);
    16ee:	fbc40513          	add	a0,s0,-68
    16f2:	00004097          	auipc	ra,0x4
    16f6:	512080e7          	jalr	1298(ra) # 5c04 <wait>
  unlink("truncfile");
    16fa:	00005517          	auipc	a0,0x5
    16fe:	ac650513          	add	a0,a0,-1338 # 61c0 <malloc+0x194>
    1702:	00004097          	auipc	ra,0x4
    1706:	54a080e7          	jalr	1354(ra) # 5c4c <unlink>
  exit(xstatus);
    170a:	fbc42503          	lw	a0,-68(s0)
    170e:	00004097          	auipc	ra,0x4
    1712:	4ee080e7          	jalr	1262(ra) # 5bfc <exit>
      printf("%s: open failed\n", s);
    1716:	85ca                	mv	a1,s2
    1718:	00005517          	auipc	a0,0x5
    171c:	2f050513          	add	a0,a0,752 # 6a08 <malloc+0x9dc>
    1720:	00005097          	auipc	ra,0x5
    1724:	854080e7          	jalr	-1964(ra) # 5f74 <printf>
      exit(1);
    1728:	4505                	li	a0,1
    172a:	00004097          	auipc	ra,0x4
    172e:	4d2080e7          	jalr	1234(ra) # 5bfc <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1732:	862a                	mv	a2,a0
    1734:	85ca                	mv	a1,s2
    1736:	00005517          	auipc	a0,0x5
    173a:	32250513          	add	a0,a0,802 # 6a58 <malloc+0xa2c>
    173e:	00005097          	auipc	ra,0x5
    1742:	836080e7          	jalr	-1994(ra) # 5f74 <printf>
      exit(1);
    1746:	4505                	li	a0,1
    1748:	00004097          	auipc	ra,0x4
    174c:	4b4080e7          	jalr	1204(ra) # 5bfc <exit>

0000000000001750 <exectest>:
{
    1750:	715d                	add	sp,sp,-80
    1752:	e486                	sd	ra,72(sp)
    1754:	e0a2                	sd	s0,64(sp)
    1756:	f84a                	sd	s2,48(sp)
    1758:	0880                	add	s0,sp,80
    175a:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    175c:	00005797          	auipc	a5,0x5
    1760:	a0c78793          	add	a5,a5,-1524 # 6168 <malloc+0x13c>
    1764:	fcf43023          	sd	a5,-64(s0)
    1768:	00005797          	auipc	a5,0x5
    176c:	31078793          	add	a5,a5,784 # 6a78 <malloc+0xa4c>
    1770:	fcf43423          	sd	a5,-56(s0)
    1774:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1778:	00005517          	auipc	a0,0x5
    177c:	30850513          	add	a0,a0,776 # 6a80 <malloc+0xa54>
    1780:	00004097          	auipc	ra,0x4
    1784:	4cc080e7          	jalr	1228(ra) # 5c4c <unlink>
  pid = fork();
    1788:	00004097          	auipc	ra,0x4
    178c:	46c080e7          	jalr	1132(ra) # 5bf4 <fork>
  if(pid < 0) {
    1790:	04054763          	bltz	a0,17de <exectest+0x8e>
    1794:	fc26                	sd	s1,56(sp)
    1796:	84aa                	mv	s1,a0
  if(pid == 0) {
    1798:	ed41                	bnez	a0,1830 <exectest+0xe0>
    close(1);
    179a:	4505                	li	a0,1
    179c:	00004097          	auipc	ra,0x4
    17a0:	488080e7          	jalr	1160(ra) # 5c24 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    17a4:	20100593          	li	a1,513
    17a8:	00005517          	auipc	a0,0x5
    17ac:	2d850513          	add	a0,a0,728 # 6a80 <malloc+0xa54>
    17b0:	00004097          	auipc	ra,0x4
    17b4:	48c080e7          	jalr	1164(ra) # 5c3c <open>
    if(fd < 0) {
    17b8:	04054263          	bltz	a0,17fc <exectest+0xac>
    if(fd != 1) {
    17bc:	4785                	li	a5,1
    17be:	04f50d63          	beq	a0,a5,1818 <exectest+0xc8>
      printf("%s: wrong fd\n", s);
    17c2:	85ca                	mv	a1,s2
    17c4:	00005517          	auipc	a0,0x5
    17c8:	2dc50513          	add	a0,a0,732 # 6aa0 <malloc+0xa74>
    17cc:	00004097          	auipc	ra,0x4
    17d0:	7a8080e7          	jalr	1960(ra) # 5f74 <printf>
      exit(1);
    17d4:	4505                	li	a0,1
    17d6:	00004097          	auipc	ra,0x4
    17da:	426080e7          	jalr	1062(ra) # 5bfc <exit>
    17de:	fc26                	sd	s1,56(sp)
     printf("%s: fork failed\n", s);
    17e0:	85ca                	mv	a1,s2
    17e2:	00005517          	auipc	a0,0x5
    17e6:	20e50513          	add	a0,a0,526 # 69f0 <malloc+0x9c4>
    17ea:	00004097          	auipc	ra,0x4
    17ee:	78a080e7          	jalr	1930(ra) # 5f74 <printf>
     exit(1);
    17f2:	4505                	li	a0,1
    17f4:	00004097          	auipc	ra,0x4
    17f8:	408080e7          	jalr	1032(ra) # 5bfc <exit>
      printf("%s: create failed\n", s);
    17fc:	85ca                	mv	a1,s2
    17fe:	00005517          	auipc	a0,0x5
    1802:	28a50513          	add	a0,a0,650 # 6a88 <malloc+0xa5c>
    1806:	00004097          	auipc	ra,0x4
    180a:	76e080e7          	jalr	1902(ra) # 5f74 <printf>
      exit(1);
    180e:	4505                	li	a0,1
    1810:	00004097          	auipc	ra,0x4
    1814:	3ec080e7          	jalr	1004(ra) # 5bfc <exit>
    if(exec("echo", echoargv) < 0){
    1818:	fc040593          	add	a1,s0,-64
    181c:	00005517          	auipc	a0,0x5
    1820:	94c50513          	add	a0,a0,-1716 # 6168 <malloc+0x13c>
    1824:	00004097          	auipc	ra,0x4
    1828:	410080e7          	jalr	1040(ra) # 5c34 <exec>
    182c:	02054163          	bltz	a0,184e <exectest+0xfe>
  if (wait(&xstatus) != pid) {
    1830:	fdc40513          	add	a0,s0,-36
    1834:	00004097          	auipc	ra,0x4
    1838:	3d0080e7          	jalr	976(ra) # 5c04 <wait>
    183c:	02951763          	bne	a0,s1,186a <exectest+0x11a>
  if(xstatus != 0)
    1840:	fdc42503          	lw	a0,-36(s0)
    1844:	cd0d                	beqz	a0,187e <exectest+0x12e>
    exit(xstatus);
    1846:	00004097          	auipc	ra,0x4
    184a:	3b6080e7          	jalr	950(ra) # 5bfc <exit>
      printf("%s: exec echo failed\n", s);
    184e:	85ca                	mv	a1,s2
    1850:	00005517          	auipc	a0,0x5
    1854:	26050513          	add	a0,a0,608 # 6ab0 <malloc+0xa84>
    1858:	00004097          	auipc	ra,0x4
    185c:	71c080e7          	jalr	1820(ra) # 5f74 <printf>
      exit(1);
    1860:	4505                	li	a0,1
    1862:	00004097          	auipc	ra,0x4
    1866:	39a080e7          	jalr	922(ra) # 5bfc <exit>
    printf("%s: wait failed!\n", s);
    186a:	85ca                	mv	a1,s2
    186c:	00005517          	auipc	a0,0x5
    1870:	25c50513          	add	a0,a0,604 # 6ac8 <malloc+0xa9c>
    1874:	00004097          	auipc	ra,0x4
    1878:	700080e7          	jalr	1792(ra) # 5f74 <printf>
    187c:	b7d1                	j	1840 <exectest+0xf0>
  fd = open("echo-ok", O_RDONLY);
    187e:	4581                	li	a1,0
    1880:	00005517          	auipc	a0,0x5
    1884:	20050513          	add	a0,a0,512 # 6a80 <malloc+0xa54>
    1888:	00004097          	auipc	ra,0x4
    188c:	3b4080e7          	jalr	948(ra) # 5c3c <open>
  if(fd < 0) {
    1890:	02054a63          	bltz	a0,18c4 <exectest+0x174>
  if (read(fd, buf, 2) != 2) {
    1894:	4609                	li	a2,2
    1896:	fb840593          	add	a1,s0,-72
    189a:	00004097          	auipc	ra,0x4
    189e:	37a080e7          	jalr	890(ra) # 5c14 <read>
    18a2:	4789                	li	a5,2
    18a4:	02f50e63          	beq	a0,a5,18e0 <exectest+0x190>
    printf("%s: read failed\n", s);
    18a8:	85ca                	mv	a1,s2
    18aa:	00005517          	auipc	a0,0x5
    18ae:	c8e50513          	add	a0,a0,-882 # 6538 <malloc+0x50c>
    18b2:	00004097          	auipc	ra,0x4
    18b6:	6c2080e7          	jalr	1730(ra) # 5f74 <printf>
    exit(1);
    18ba:	4505                	li	a0,1
    18bc:	00004097          	auipc	ra,0x4
    18c0:	340080e7          	jalr	832(ra) # 5bfc <exit>
    printf("%s: open failed\n", s);
    18c4:	85ca                	mv	a1,s2
    18c6:	00005517          	auipc	a0,0x5
    18ca:	14250513          	add	a0,a0,322 # 6a08 <malloc+0x9dc>
    18ce:	00004097          	auipc	ra,0x4
    18d2:	6a6080e7          	jalr	1702(ra) # 5f74 <printf>
    exit(1);
    18d6:	4505                	li	a0,1
    18d8:	00004097          	auipc	ra,0x4
    18dc:	324080e7          	jalr	804(ra) # 5bfc <exit>
  unlink("echo-ok");
    18e0:	00005517          	auipc	a0,0x5
    18e4:	1a050513          	add	a0,a0,416 # 6a80 <malloc+0xa54>
    18e8:	00004097          	auipc	ra,0x4
    18ec:	364080e7          	jalr	868(ra) # 5c4c <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    18f0:	fb844703          	lbu	a4,-72(s0)
    18f4:	04f00793          	li	a5,79
    18f8:	00f71863          	bne	a4,a5,1908 <exectest+0x1b8>
    18fc:	fb944703          	lbu	a4,-71(s0)
    1900:	04b00793          	li	a5,75
    1904:	02f70063          	beq	a4,a5,1924 <exectest+0x1d4>
    printf("%s: wrong output\n", s);
    1908:	85ca                	mv	a1,s2
    190a:	00005517          	auipc	a0,0x5
    190e:	1d650513          	add	a0,a0,470 # 6ae0 <malloc+0xab4>
    1912:	00004097          	auipc	ra,0x4
    1916:	662080e7          	jalr	1634(ra) # 5f74 <printf>
    exit(1);
    191a:	4505                	li	a0,1
    191c:	00004097          	auipc	ra,0x4
    1920:	2e0080e7          	jalr	736(ra) # 5bfc <exit>
    exit(0);
    1924:	4501                	li	a0,0
    1926:	00004097          	auipc	ra,0x4
    192a:	2d6080e7          	jalr	726(ra) # 5bfc <exit>

000000000000192e <pipe1>:
{
    192e:	711d                	add	sp,sp,-96
    1930:	ec86                	sd	ra,88(sp)
    1932:	e8a2                	sd	s0,80(sp)
    1934:	fc4e                	sd	s3,56(sp)
    1936:	1080                	add	s0,sp,96
    1938:	89aa                	mv	s3,a0
  if(pipe(fds) != 0){
    193a:	fa840513          	add	a0,s0,-88
    193e:	00004097          	auipc	ra,0x4
    1942:	2ce080e7          	jalr	718(ra) # 5c0c <pipe>
    1946:	ed3d                	bnez	a0,19c4 <pipe1+0x96>
    1948:	e4a6                	sd	s1,72(sp)
    194a:	f852                	sd	s4,48(sp)
    194c:	84aa                	mv	s1,a0
  pid = fork();
    194e:	00004097          	auipc	ra,0x4
    1952:	2a6080e7          	jalr	678(ra) # 5bf4 <fork>
    1956:	8a2a                	mv	s4,a0
  if(pid == 0){
    1958:	c951                	beqz	a0,19ec <pipe1+0xbe>
  } else if(pid > 0){
    195a:	18a05b63          	blez	a0,1af0 <pipe1+0x1c2>
    195e:	e0ca                	sd	s2,64(sp)
    1960:	f456                	sd	s5,40(sp)
    close(fds[1]);
    1962:	fac42503          	lw	a0,-84(s0)
    1966:	00004097          	auipc	ra,0x4
    196a:	2be080e7          	jalr	702(ra) # 5c24 <close>
    total = 0;
    196e:	8a26                	mv	s4,s1
    cc = 1;
    1970:	4905                	li	s2,1
    while((n = read(fds[0], buf, cc)) > 0){
    1972:	0000ba97          	auipc	s5,0xb
    1976:	306a8a93          	add	s5,s5,774 # cc78 <buf>
    197a:	864a                	mv	a2,s2
    197c:	85d6                	mv	a1,s5
    197e:	fa842503          	lw	a0,-88(s0)
    1982:	00004097          	auipc	ra,0x4
    1986:	292080e7          	jalr	658(ra) # 5c14 <read>
    198a:	10a05a63          	blez	a0,1a9e <pipe1+0x170>
      for(i = 0; i < n; i++){
    198e:	0000b717          	auipc	a4,0xb
    1992:	2ea70713          	add	a4,a4,746 # cc78 <buf>
    1996:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    199a:	00074683          	lbu	a3,0(a4)
    199e:	0ff4f793          	zext.b	a5,s1
    19a2:	2485                	addw	s1,s1,1
    19a4:	0cf69b63          	bne	a3,a5,1a7a <pipe1+0x14c>
      for(i = 0; i < n; i++){
    19a8:	0705                	add	a4,a4,1
    19aa:	fec498e3          	bne	s1,a2,199a <pipe1+0x6c>
      total += n;
    19ae:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    19b2:	0019179b          	sllw	a5,s2,0x1
    19b6:	0007891b          	sext.w	s2,a5
      if(cc > sizeof(buf))
    19ba:	670d                	lui	a4,0x3
    19bc:	fb277fe3          	bgeu	a4,s2,197a <pipe1+0x4c>
        cc = sizeof(buf);
    19c0:	690d                	lui	s2,0x3
    19c2:	bf65                	j	197a <pipe1+0x4c>
    19c4:	e4a6                	sd	s1,72(sp)
    19c6:	e0ca                	sd	s2,64(sp)
    19c8:	f852                	sd	s4,48(sp)
    19ca:	f456                	sd	s5,40(sp)
    19cc:	f05a                	sd	s6,32(sp)
    19ce:	ec5e                	sd	s7,24(sp)
    printf("%s: pipe() failed\n", s);
    19d0:	85ce                	mv	a1,s3
    19d2:	00005517          	auipc	a0,0x5
    19d6:	12650513          	add	a0,a0,294 # 6af8 <malloc+0xacc>
    19da:	00004097          	auipc	ra,0x4
    19de:	59a080e7          	jalr	1434(ra) # 5f74 <printf>
    exit(1);
    19e2:	4505                	li	a0,1
    19e4:	00004097          	auipc	ra,0x4
    19e8:	218080e7          	jalr	536(ra) # 5bfc <exit>
    19ec:	e0ca                	sd	s2,64(sp)
    19ee:	f456                	sd	s5,40(sp)
    19f0:	f05a                	sd	s6,32(sp)
    19f2:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    19f4:	fa842503          	lw	a0,-88(s0)
    19f8:	00004097          	auipc	ra,0x4
    19fc:	22c080e7          	jalr	556(ra) # 5c24 <close>
    for(n = 0; n < N; n++){
    1a00:	0000bb17          	auipc	s6,0xb
    1a04:	278b0b13          	add	s6,s6,632 # cc78 <buf>
    1a08:	416004bb          	negw	s1,s6
    1a0c:	0ff4f493          	zext.b	s1,s1
    1a10:	409b0913          	add	s2,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a14:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1a16:	6a85                	lui	s5,0x1
    1a18:	42da8a93          	add	s5,s5,1069 # 142d <copyinstr2+0x9d>
{
    1a1c:	87da                	mv	a5,s6
        buf[i] = seq++;
    1a1e:	0097873b          	addw	a4,a5,s1
    1a22:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1a26:	0785                	add	a5,a5,1
    1a28:	ff279be3          	bne	a5,s2,1a1e <pipe1+0xf0>
    1a2c:	409a0a1b          	addw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1a30:	40900613          	li	a2,1033
    1a34:	85de                	mv	a1,s7
    1a36:	fac42503          	lw	a0,-84(s0)
    1a3a:	00004097          	auipc	ra,0x4
    1a3e:	1e2080e7          	jalr	482(ra) # 5c1c <write>
    1a42:	40900793          	li	a5,1033
    1a46:	00f51c63          	bne	a0,a5,1a5e <pipe1+0x130>
    for(n = 0; n < N; n++){
    1a4a:	24a5                	addw	s1,s1,9
    1a4c:	0ff4f493          	zext.b	s1,s1
    1a50:	fd5a16e3          	bne	s4,s5,1a1c <pipe1+0xee>
    exit(0);
    1a54:	4501                	li	a0,0
    1a56:	00004097          	auipc	ra,0x4
    1a5a:	1a6080e7          	jalr	422(ra) # 5bfc <exit>
        printf("%s: pipe1 oops 1\n", s);
    1a5e:	85ce                	mv	a1,s3
    1a60:	00005517          	auipc	a0,0x5
    1a64:	0b050513          	add	a0,a0,176 # 6b10 <malloc+0xae4>
    1a68:	00004097          	auipc	ra,0x4
    1a6c:	50c080e7          	jalr	1292(ra) # 5f74 <printf>
        exit(1);
    1a70:	4505                	li	a0,1
    1a72:	00004097          	auipc	ra,0x4
    1a76:	18a080e7          	jalr	394(ra) # 5bfc <exit>
          printf("%s: pipe1 oops 2\n", s);
    1a7a:	85ce                	mv	a1,s3
    1a7c:	00005517          	auipc	a0,0x5
    1a80:	0ac50513          	add	a0,a0,172 # 6b28 <malloc+0xafc>
    1a84:	00004097          	auipc	ra,0x4
    1a88:	4f0080e7          	jalr	1264(ra) # 5f74 <printf>
          return;
    1a8c:	64a6                	ld	s1,72(sp)
    1a8e:	6906                	ld	s2,64(sp)
    1a90:	7a42                	ld	s4,48(sp)
    1a92:	7aa2                	ld	s5,40(sp)
}
    1a94:	60e6                	ld	ra,88(sp)
    1a96:	6446                	ld	s0,80(sp)
    1a98:	79e2                	ld	s3,56(sp)
    1a9a:	6125                	add	sp,sp,96
    1a9c:	8082                	ret
    if(total != N * SZ){
    1a9e:	6785                	lui	a5,0x1
    1aa0:	42d78793          	add	a5,a5,1069 # 142d <copyinstr2+0x9d>
    1aa4:	02fa0263          	beq	s4,a5,1ac8 <pipe1+0x19a>
    1aa8:	f05a                	sd	s6,32(sp)
    1aaa:	ec5e                	sd	s7,24(sp)
      printf("%s: pipe1 oops 3 total %d\n", total);
    1aac:	85d2                	mv	a1,s4
    1aae:	00005517          	auipc	a0,0x5
    1ab2:	09250513          	add	a0,a0,146 # 6b40 <malloc+0xb14>
    1ab6:	00004097          	auipc	ra,0x4
    1aba:	4be080e7          	jalr	1214(ra) # 5f74 <printf>
      exit(1);
    1abe:	4505                	li	a0,1
    1ac0:	00004097          	auipc	ra,0x4
    1ac4:	13c080e7          	jalr	316(ra) # 5bfc <exit>
    1ac8:	f05a                	sd	s6,32(sp)
    1aca:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    1acc:	fa842503          	lw	a0,-88(s0)
    1ad0:	00004097          	auipc	ra,0x4
    1ad4:	154080e7          	jalr	340(ra) # 5c24 <close>
    wait(&xstatus);
    1ad8:	fa440513          	add	a0,s0,-92
    1adc:	00004097          	auipc	ra,0x4
    1ae0:	128080e7          	jalr	296(ra) # 5c04 <wait>
    exit(xstatus);
    1ae4:	fa442503          	lw	a0,-92(s0)
    1ae8:	00004097          	auipc	ra,0x4
    1aec:	114080e7          	jalr	276(ra) # 5bfc <exit>
    1af0:	e0ca                	sd	s2,64(sp)
    1af2:	f456                	sd	s5,40(sp)
    1af4:	f05a                	sd	s6,32(sp)
    1af6:	ec5e                	sd	s7,24(sp)
    printf("%s: fork() failed\n", s);
    1af8:	85ce                	mv	a1,s3
    1afa:	00005517          	auipc	a0,0x5
    1afe:	06650513          	add	a0,a0,102 # 6b60 <malloc+0xb34>
    1b02:	00004097          	auipc	ra,0x4
    1b06:	472080e7          	jalr	1138(ra) # 5f74 <printf>
    exit(1);
    1b0a:	4505                	li	a0,1
    1b0c:	00004097          	auipc	ra,0x4
    1b10:	0f0080e7          	jalr	240(ra) # 5bfc <exit>

0000000000001b14 <exitwait>:
{
    1b14:	7139                	add	sp,sp,-64
    1b16:	fc06                	sd	ra,56(sp)
    1b18:	f822                	sd	s0,48(sp)
    1b1a:	f426                	sd	s1,40(sp)
    1b1c:	f04a                	sd	s2,32(sp)
    1b1e:	ec4e                	sd	s3,24(sp)
    1b20:	e852                	sd	s4,16(sp)
    1b22:	0080                	add	s0,sp,64
    1b24:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1b26:	4901                	li	s2,0
    1b28:	06400993          	li	s3,100
    pid = fork();
    1b2c:	00004097          	auipc	ra,0x4
    1b30:	0c8080e7          	jalr	200(ra) # 5bf4 <fork>
    1b34:	84aa                	mv	s1,a0
    if(pid < 0){
    1b36:	02054a63          	bltz	a0,1b6a <exitwait+0x56>
    if(pid){
    1b3a:	c151                	beqz	a0,1bbe <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1b3c:	fcc40513          	add	a0,s0,-52
    1b40:	00004097          	auipc	ra,0x4
    1b44:	0c4080e7          	jalr	196(ra) # 5c04 <wait>
    1b48:	02951f63          	bne	a0,s1,1b86 <exitwait+0x72>
      if(i != xstate) {
    1b4c:	fcc42783          	lw	a5,-52(s0)
    1b50:	05279963          	bne	a5,s2,1ba2 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1b54:	2905                	addw	s2,s2,1 # 3001 <execout+0x53>
    1b56:	fd391be3          	bne	s2,s3,1b2c <exitwait+0x18>
}
    1b5a:	70e2                	ld	ra,56(sp)
    1b5c:	7442                	ld	s0,48(sp)
    1b5e:	74a2                	ld	s1,40(sp)
    1b60:	7902                	ld	s2,32(sp)
    1b62:	69e2                	ld	s3,24(sp)
    1b64:	6a42                	ld	s4,16(sp)
    1b66:	6121                	add	sp,sp,64
    1b68:	8082                	ret
      printf("%s: fork failed\n", s);
    1b6a:	85d2                	mv	a1,s4
    1b6c:	00005517          	auipc	a0,0x5
    1b70:	e8450513          	add	a0,a0,-380 # 69f0 <malloc+0x9c4>
    1b74:	00004097          	auipc	ra,0x4
    1b78:	400080e7          	jalr	1024(ra) # 5f74 <printf>
      exit(1);
    1b7c:	4505                	li	a0,1
    1b7e:	00004097          	auipc	ra,0x4
    1b82:	07e080e7          	jalr	126(ra) # 5bfc <exit>
        printf("%s: wait wrong pid\n", s);
    1b86:	85d2                	mv	a1,s4
    1b88:	00005517          	auipc	a0,0x5
    1b8c:	ff050513          	add	a0,a0,-16 # 6b78 <malloc+0xb4c>
    1b90:	00004097          	auipc	ra,0x4
    1b94:	3e4080e7          	jalr	996(ra) # 5f74 <printf>
        exit(1);
    1b98:	4505                	li	a0,1
    1b9a:	00004097          	auipc	ra,0x4
    1b9e:	062080e7          	jalr	98(ra) # 5bfc <exit>
        printf("%s: wait wrong exit status\n", s);
    1ba2:	85d2                	mv	a1,s4
    1ba4:	00005517          	auipc	a0,0x5
    1ba8:	fec50513          	add	a0,a0,-20 # 6b90 <malloc+0xb64>
    1bac:	00004097          	auipc	ra,0x4
    1bb0:	3c8080e7          	jalr	968(ra) # 5f74 <printf>
        exit(1);
    1bb4:	4505                	li	a0,1
    1bb6:	00004097          	auipc	ra,0x4
    1bba:	046080e7          	jalr	70(ra) # 5bfc <exit>
      exit(i);
    1bbe:	854a                	mv	a0,s2
    1bc0:	00004097          	auipc	ra,0x4
    1bc4:	03c080e7          	jalr	60(ra) # 5bfc <exit>

0000000000001bc8 <twochildren>:
{
    1bc8:	1101                	add	sp,sp,-32
    1bca:	ec06                	sd	ra,24(sp)
    1bcc:	e822                	sd	s0,16(sp)
    1bce:	e426                	sd	s1,8(sp)
    1bd0:	e04a                	sd	s2,0(sp)
    1bd2:	1000                	add	s0,sp,32
    1bd4:	892a                	mv	s2,a0
    1bd6:	3e800493          	li	s1,1000
    int pid1 = fork();
    1bda:	00004097          	auipc	ra,0x4
    1bde:	01a080e7          	jalr	26(ra) # 5bf4 <fork>
    if(pid1 < 0){
    1be2:	02054c63          	bltz	a0,1c1a <twochildren+0x52>
    if(pid1 == 0){
    1be6:	c921                	beqz	a0,1c36 <twochildren+0x6e>
      int pid2 = fork();
    1be8:	00004097          	auipc	ra,0x4
    1bec:	00c080e7          	jalr	12(ra) # 5bf4 <fork>
      if(pid2 < 0){
    1bf0:	04054763          	bltz	a0,1c3e <twochildren+0x76>
      if(pid2 == 0){
    1bf4:	c13d                	beqz	a0,1c5a <twochildren+0x92>
        wait(0);
    1bf6:	4501                	li	a0,0
    1bf8:	00004097          	auipc	ra,0x4
    1bfc:	00c080e7          	jalr	12(ra) # 5c04 <wait>
        wait(0);
    1c00:	4501                	li	a0,0
    1c02:	00004097          	auipc	ra,0x4
    1c06:	002080e7          	jalr	2(ra) # 5c04 <wait>
  for(int i = 0; i < 1000; i++){
    1c0a:	34fd                	addw	s1,s1,-1
    1c0c:	f4f9                	bnez	s1,1bda <twochildren+0x12>
}
    1c0e:	60e2                	ld	ra,24(sp)
    1c10:	6442                	ld	s0,16(sp)
    1c12:	64a2                	ld	s1,8(sp)
    1c14:	6902                	ld	s2,0(sp)
    1c16:	6105                	add	sp,sp,32
    1c18:	8082                	ret
      printf("%s: fork failed\n", s);
    1c1a:	85ca                	mv	a1,s2
    1c1c:	00005517          	auipc	a0,0x5
    1c20:	dd450513          	add	a0,a0,-556 # 69f0 <malloc+0x9c4>
    1c24:	00004097          	auipc	ra,0x4
    1c28:	350080e7          	jalr	848(ra) # 5f74 <printf>
      exit(1);
    1c2c:	4505                	li	a0,1
    1c2e:	00004097          	auipc	ra,0x4
    1c32:	fce080e7          	jalr	-50(ra) # 5bfc <exit>
      exit(0);
    1c36:	00004097          	auipc	ra,0x4
    1c3a:	fc6080e7          	jalr	-58(ra) # 5bfc <exit>
        printf("%s: fork failed\n", s);
    1c3e:	85ca                	mv	a1,s2
    1c40:	00005517          	auipc	a0,0x5
    1c44:	db050513          	add	a0,a0,-592 # 69f0 <malloc+0x9c4>
    1c48:	00004097          	auipc	ra,0x4
    1c4c:	32c080e7          	jalr	812(ra) # 5f74 <printf>
        exit(1);
    1c50:	4505                	li	a0,1
    1c52:	00004097          	auipc	ra,0x4
    1c56:	faa080e7          	jalr	-86(ra) # 5bfc <exit>
        exit(0);
    1c5a:	00004097          	auipc	ra,0x4
    1c5e:	fa2080e7          	jalr	-94(ra) # 5bfc <exit>

0000000000001c62 <forkfork>:
{
    1c62:	7179                	add	sp,sp,-48
    1c64:	f406                	sd	ra,40(sp)
    1c66:	f022                	sd	s0,32(sp)
    1c68:	ec26                	sd	s1,24(sp)
    1c6a:	1800                	add	s0,sp,48
    1c6c:	84aa                	mv	s1,a0
    int pid = fork();
    1c6e:	00004097          	auipc	ra,0x4
    1c72:	f86080e7          	jalr	-122(ra) # 5bf4 <fork>
    if(pid < 0){
    1c76:	04054163          	bltz	a0,1cb8 <forkfork+0x56>
    if(pid == 0){
    1c7a:	cd29                	beqz	a0,1cd4 <forkfork+0x72>
    int pid = fork();
    1c7c:	00004097          	auipc	ra,0x4
    1c80:	f78080e7          	jalr	-136(ra) # 5bf4 <fork>
    if(pid < 0){
    1c84:	02054a63          	bltz	a0,1cb8 <forkfork+0x56>
    if(pid == 0){
    1c88:	c531                	beqz	a0,1cd4 <forkfork+0x72>
    wait(&xstatus);
    1c8a:	fdc40513          	add	a0,s0,-36
    1c8e:	00004097          	auipc	ra,0x4
    1c92:	f76080e7          	jalr	-138(ra) # 5c04 <wait>
    if(xstatus != 0) {
    1c96:	fdc42783          	lw	a5,-36(s0)
    1c9a:	ebbd                	bnez	a5,1d10 <forkfork+0xae>
    wait(&xstatus);
    1c9c:	fdc40513          	add	a0,s0,-36
    1ca0:	00004097          	auipc	ra,0x4
    1ca4:	f64080e7          	jalr	-156(ra) # 5c04 <wait>
    if(xstatus != 0) {
    1ca8:	fdc42783          	lw	a5,-36(s0)
    1cac:	e3b5                	bnez	a5,1d10 <forkfork+0xae>
}
    1cae:	70a2                	ld	ra,40(sp)
    1cb0:	7402                	ld	s0,32(sp)
    1cb2:	64e2                	ld	s1,24(sp)
    1cb4:	6145                	add	sp,sp,48
    1cb6:	8082                	ret
      printf("%s: fork failed", s);
    1cb8:	85a6                	mv	a1,s1
    1cba:	00005517          	auipc	a0,0x5
    1cbe:	ef650513          	add	a0,a0,-266 # 6bb0 <malloc+0xb84>
    1cc2:	00004097          	auipc	ra,0x4
    1cc6:	2b2080e7          	jalr	690(ra) # 5f74 <printf>
      exit(1);
    1cca:	4505                	li	a0,1
    1ccc:	00004097          	auipc	ra,0x4
    1cd0:	f30080e7          	jalr	-208(ra) # 5bfc <exit>
{
    1cd4:	0c800493          	li	s1,200
        int pid1 = fork();
    1cd8:	00004097          	auipc	ra,0x4
    1cdc:	f1c080e7          	jalr	-228(ra) # 5bf4 <fork>
        if(pid1 < 0){
    1ce0:	00054f63          	bltz	a0,1cfe <forkfork+0x9c>
        if(pid1 == 0){
    1ce4:	c115                	beqz	a0,1d08 <forkfork+0xa6>
        wait(0);
    1ce6:	4501                	li	a0,0
    1ce8:	00004097          	auipc	ra,0x4
    1cec:	f1c080e7          	jalr	-228(ra) # 5c04 <wait>
      for(int j = 0; j < 200; j++){
    1cf0:	34fd                	addw	s1,s1,-1
    1cf2:	f0fd                	bnez	s1,1cd8 <forkfork+0x76>
      exit(0);
    1cf4:	4501                	li	a0,0
    1cf6:	00004097          	auipc	ra,0x4
    1cfa:	f06080e7          	jalr	-250(ra) # 5bfc <exit>
          exit(1);
    1cfe:	4505                	li	a0,1
    1d00:	00004097          	auipc	ra,0x4
    1d04:	efc080e7          	jalr	-260(ra) # 5bfc <exit>
          exit(0);
    1d08:	00004097          	auipc	ra,0x4
    1d0c:	ef4080e7          	jalr	-268(ra) # 5bfc <exit>
      printf("%s: fork in child failed", s);
    1d10:	85a6                	mv	a1,s1
    1d12:	00005517          	auipc	a0,0x5
    1d16:	eae50513          	add	a0,a0,-338 # 6bc0 <malloc+0xb94>
    1d1a:	00004097          	auipc	ra,0x4
    1d1e:	25a080e7          	jalr	602(ra) # 5f74 <printf>
      exit(1);
    1d22:	4505                	li	a0,1
    1d24:	00004097          	auipc	ra,0x4
    1d28:	ed8080e7          	jalr	-296(ra) # 5bfc <exit>

0000000000001d2c <reparent2>:
{
    1d2c:	1101                	add	sp,sp,-32
    1d2e:	ec06                	sd	ra,24(sp)
    1d30:	e822                	sd	s0,16(sp)
    1d32:	e426                	sd	s1,8(sp)
    1d34:	1000                	add	s0,sp,32
    1d36:	32000493          	li	s1,800
    int pid1 = fork();
    1d3a:	00004097          	auipc	ra,0x4
    1d3e:	eba080e7          	jalr	-326(ra) # 5bf4 <fork>
    if(pid1 < 0){
    1d42:	00054f63          	bltz	a0,1d60 <reparent2+0x34>
    if(pid1 == 0){
    1d46:	c915                	beqz	a0,1d7a <reparent2+0x4e>
    wait(0);
    1d48:	4501                	li	a0,0
    1d4a:	00004097          	auipc	ra,0x4
    1d4e:	eba080e7          	jalr	-326(ra) # 5c04 <wait>
  for(int i = 0; i < 800; i++){
    1d52:	34fd                	addw	s1,s1,-1
    1d54:	f0fd                	bnez	s1,1d3a <reparent2+0xe>
  exit(0);
    1d56:	4501                	li	a0,0
    1d58:	00004097          	auipc	ra,0x4
    1d5c:	ea4080e7          	jalr	-348(ra) # 5bfc <exit>
      printf("fork failed\n");
    1d60:	00005517          	auipc	a0,0x5
    1d64:	09850513          	add	a0,a0,152 # 6df8 <malloc+0xdcc>
    1d68:	00004097          	auipc	ra,0x4
    1d6c:	20c080e7          	jalr	524(ra) # 5f74 <printf>
      exit(1);
    1d70:	4505                	li	a0,1
    1d72:	00004097          	auipc	ra,0x4
    1d76:	e8a080e7          	jalr	-374(ra) # 5bfc <exit>
      fork();
    1d7a:	00004097          	auipc	ra,0x4
    1d7e:	e7a080e7          	jalr	-390(ra) # 5bf4 <fork>
      fork();
    1d82:	00004097          	auipc	ra,0x4
    1d86:	e72080e7          	jalr	-398(ra) # 5bf4 <fork>
      exit(0);
    1d8a:	4501                	li	a0,0
    1d8c:	00004097          	auipc	ra,0x4
    1d90:	e70080e7          	jalr	-400(ra) # 5bfc <exit>

0000000000001d94 <createdelete>:
{
    1d94:	7175                	add	sp,sp,-144
    1d96:	e506                	sd	ra,136(sp)
    1d98:	e122                	sd	s0,128(sp)
    1d9a:	fca6                	sd	s1,120(sp)
    1d9c:	f8ca                	sd	s2,112(sp)
    1d9e:	f4ce                	sd	s3,104(sp)
    1da0:	f0d2                	sd	s4,96(sp)
    1da2:	ecd6                	sd	s5,88(sp)
    1da4:	e8da                	sd	s6,80(sp)
    1da6:	e4de                	sd	s7,72(sp)
    1da8:	e0e2                	sd	s8,64(sp)
    1daa:	fc66                	sd	s9,56(sp)
    1dac:	0900                	add	s0,sp,144
    1dae:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1db0:	4901                	li	s2,0
    1db2:	4991                	li	s3,4
    pid = fork();
    1db4:	00004097          	auipc	ra,0x4
    1db8:	e40080e7          	jalr	-448(ra) # 5bf4 <fork>
    1dbc:	84aa                	mv	s1,a0
    if(pid < 0){
    1dbe:	02054f63          	bltz	a0,1dfc <createdelete+0x68>
    if(pid == 0){
    1dc2:	c939                	beqz	a0,1e18 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1dc4:	2905                	addw	s2,s2,1
    1dc6:	ff3917e3          	bne	s2,s3,1db4 <createdelete+0x20>
    1dca:	4491                	li	s1,4
    wait(&xstatus);
    1dcc:	f7c40513          	add	a0,s0,-132
    1dd0:	00004097          	auipc	ra,0x4
    1dd4:	e34080e7          	jalr	-460(ra) # 5c04 <wait>
    if(xstatus != 0)
    1dd8:	f7c42903          	lw	s2,-132(s0)
    1ddc:	0e091263          	bnez	s2,1ec0 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1de0:	34fd                	addw	s1,s1,-1
    1de2:	f4ed                	bnez	s1,1dcc <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1de4:	f8040123          	sb	zero,-126(s0)
    1de8:	03000993          	li	s3,48
    1dec:	5a7d                	li	s4,-1
    1dee:	07000c13          	li	s8,112
      if((i == 0 || i >= N/2) && fd < 0){
    1df2:	4b25                	li	s6,9
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1df4:	4ba1                	li	s7,8
    for(pi = 0; pi < NCHILD; pi++){
    1df6:	07400a93          	li	s5,116
    1dfa:	a28d                	j	1f5c <createdelete+0x1c8>
      printf("fork failed\n", s);
    1dfc:	85e6                	mv	a1,s9
    1dfe:	00005517          	auipc	a0,0x5
    1e02:	ffa50513          	add	a0,a0,-6 # 6df8 <malloc+0xdcc>
    1e06:	00004097          	auipc	ra,0x4
    1e0a:	16e080e7          	jalr	366(ra) # 5f74 <printf>
      exit(1);
    1e0e:	4505                	li	a0,1
    1e10:	00004097          	auipc	ra,0x4
    1e14:	dec080e7          	jalr	-532(ra) # 5bfc <exit>
      name[0] = 'p' + pi;
    1e18:	0709091b          	addw	s2,s2,112
    1e1c:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1e20:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1e24:	4951                	li	s2,20
    1e26:	a015                	j	1e4a <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1e28:	85e6                	mv	a1,s9
    1e2a:	00005517          	auipc	a0,0x5
    1e2e:	c5e50513          	add	a0,a0,-930 # 6a88 <malloc+0xa5c>
    1e32:	00004097          	auipc	ra,0x4
    1e36:	142080e7          	jalr	322(ra) # 5f74 <printf>
          exit(1);
    1e3a:	4505                	li	a0,1
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	dc0080e7          	jalr	-576(ra) # 5bfc <exit>
      for(i = 0; i < N; i++){
    1e44:	2485                	addw	s1,s1,1
    1e46:	07248863          	beq	s1,s2,1eb6 <createdelete+0x122>
        name[1] = '0' + i;
    1e4a:	0304879b          	addw	a5,s1,48
    1e4e:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1e52:	20200593          	li	a1,514
    1e56:	f8040513          	add	a0,s0,-128
    1e5a:	00004097          	auipc	ra,0x4
    1e5e:	de2080e7          	jalr	-542(ra) # 5c3c <open>
        if(fd < 0){
    1e62:	fc0543e3          	bltz	a0,1e28 <createdelete+0x94>
        close(fd);
    1e66:	00004097          	auipc	ra,0x4
    1e6a:	dbe080e7          	jalr	-578(ra) # 5c24 <close>
        if(i > 0 && (i % 2 ) == 0){
    1e6e:	12905763          	blez	s1,1f9c <createdelete+0x208>
    1e72:	0014f793          	and	a5,s1,1
    1e76:	f7f9                	bnez	a5,1e44 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1e78:	01f4d79b          	srlw	a5,s1,0x1f
    1e7c:	9fa5                	addw	a5,a5,s1
    1e7e:	4017d79b          	sraw	a5,a5,0x1
    1e82:	0307879b          	addw	a5,a5,48
    1e86:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1e8a:	f8040513          	add	a0,s0,-128
    1e8e:	00004097          	auipc	ra,0x4
    1e92:	dbe080e7          	jalr	-578(ra) # 5c4c <unlink>
    1e96:	fa0557e3          	bgez	a0,1e44 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1e9a:	85e6                	mv	a1,s9
    1e9c:	00005517          	auipc	a0,0x5
    1ea0:	d4450513          	add	a0,a0,-700 # 6be0 <malloc+0xbb4>
    1ea4:	00004097          	auipc	ra,0x4
    1ea8:	0d0080e7          	jalr	208(ra) # 5f74 <printf>
            exit(1);
    1eac:	4505                	li	a0,1
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	d4e080e7          	jalr	-690(ra) # 5bfc <exit>
      exit(0);
    1eb6:	4501                	li	a0,0
    1eb8:	00004097          	auipc	ra,0x4
    1ebc:	d44080e7          	jalr	-700(ra) # 5bfc <exit>
      exit(1);
    1ec0:	4505                	li	a0,1
    1ec2:	00004097          	auipc	ra,0x4
    1ec6:	d3a080e7          	jalr	-710(ra) # 5bfc <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1eca:	f8040613          	add	a2,s0,-128
    1ece:	85e6                	mv	a1,s9
    1ed0:	00005517          	auipc	a0,0x5
    1ed4:	d2850513          	add	a0,a0,-728 # 6bf8 <malloc+0xbcc>
    1ed8:	00004097          	auipc	ra,0x4
    1edc:	09c080e7          	jalr	156(ra) # 5f74 <printf>
        exit(1);
    1ee0:	4505                	li	a0,1
    1ee2:	00004097          	auipc	ra,0x4
    1ee6:	d1a080e7          	jalr	-742(ra) # 5bfc <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1eea:	034bff63          	bgeu	s7,s4,1f28 <createdelete+0x194>
      if(fd >= 0)
    1eee:	02055863          	bgez	a0,1f1e <createdelete+0x18a>
    for(pi = 0; pi < NCHILD; pi++){
    1ef2:	2485                	addw	s1,s1,1
    1ef4:	0ff4f493          	zext.b	s1,s1
    1ef8:	05548a63          	beq	s1,s5,1f4c <createdelete+0x1b8>
      name[0] = 'p' + pi;
    1efc:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1f00:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1f04:	4581                	li	a1,0
    1f06:	f8040513          	add	a0,s0,-128
    1f0a:	00004097          	auipc	ra,0x4
    1f0e:	d32080e7          	jalr	-718(ra) # 5c3c <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1f12:	00090463          	beqz	s2,1f1a <createdelete+0x186>
    1f16:	fd2b5ae3          	bge	s6,s2,1eea <createdelete+0x156>
    1f1a:	fa0548e3          	bltz	a0,1eca <createdelete+0x136>
        close(fd);
    1f1e:	00004097          	auipc	ra,0x4
    1f22:	d06080e7          	jalr	-762(ra) # 5c24 <close>
    1f26:	b7f1                	j	1ef2 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1f28:	fc0545e3          	bltz	a0,1ef2 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1f2c:	f8040613          	add	a2,s0,-128
    1f30:	85e6                	mv	a1,s9
    1f32:	00005517          	auipc	a0,0x5
    1f36:	cee50513          	add	a0,a0,-786 # 6c20 <malloc+0xbf4>
    1f3a:	00004097          	auipc	ra,0x4
    1f3e:	03a080e7          	jalr	58(ra) # 5f74 <printf>
        exit(1);
    1f42:	4505                	li	a0,1
    1f44:	00004097          	auipc	ra,0x4
    1f48:	cb8080e7          	jalr	-840(ra) # 5bfc <exit>
  for(i = 0; i < N; i++){
    1f4c:	2905                	addw	s2,s2,1
    1f4e:	2a05                	addw	s4,s4,1
    1f50:	2985                	addw	s3,s3,1
    1f52:	0ff9f993          	zext.b	s3,s3
    1f56:	47d1                	li	a5,20
    1f58:	02f90a63          	beq	s2,a5,1f8c <createdelete+0x1f8>
    for(pi = 0; pi < NCHILD; pi++){
    1f5c:	84e2                	mv	s1,s8
    1f5e:	bf79                	j	1efc <createdelete+0x168>
  for(i = 0; i < N; i++){
    1f60:	2905                	addw	s2,s2,1
    1f62:	0ff97913          	zext.b	s2,s2
    1f66:	2985                	addw	s3,s3,1
    1f68:	0ff9f993          	zext.b	s3,s3
    1f6c:	03490a63          	beq	s2,s4,1fa0 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1f70:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1f72:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1f76:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1f7a:	f8040513          	add	a0,s0,-128
    1f7e:	00004097          	auipc	ra,0x4
    1f82:	cce080e7          	jalr	-818(ra) # 5c4c <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1f86:	34fd                	addw	s1,s1,-1
    1f88:	f4ed                	bnez	s1,1f72 <createdelete+0x1de>
    1f8a:	bfd9                	j	1f60 <createdelete+0x1cc>
    1f8c:	03000993          	li	s3,48
    1f90:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1f94:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1f96:	08400a13          	li	s4,132
    1f9a:	bfd9                	j	1f70 <createdelete+0x1dc>
      for(i = 0; i < N; i++){
    1f9c:	2485                	addw	s1,s1,1
    1f9e:	b575                	j	1e4a <createdelete+0xb6>
}
    1fa0:	60aa                	ld	ra,136(sp)
    1fa2:	640a                	ld	s0,128(sp)
    1fa4:	74e6                	ld	s1,120(sp)
    1fa6:	7946                	ld	s2,112(sp)
    1fa8:	79a6                	ld	s3,104(sp)
    1faa:	7a06                	ld	s4,96(sp)
    1fac:	6ae6                	ld	s5,88(sp)
    1fae:	6b46                	ld	s6,80(sp)
    1fb0:	6ba6                	ld	s7,72(sp)
    1fb2:	6c06                	ld	s8,64(sp)
    1fb4:	7ce2                	ld	s9,56(sp)
    1fb6:	6149                	add	sp,sp,144
    1fb8:	8082                	ret

0000000000001fba <linkunlink>:
{
    1fba:	711d                	add	sp,sp,-96
    1fbc:	ec86                	sd	ra,88(sp)
    1fbe:	e8a2                	sd	s0,80(sp)
    1fc0:	e4a6                	sd	s1,72(sp)
    1fc2:	e0ca                	sd	s2,64(sp)
    1fc4:	fc4e                	sd	s3,56(sp)
    1fc6:	f852                	sd	s4,48(sp)
    1fc8:	f456                	sd	s5,40(sp)
    1fca:	f05a                	sd	s6,32(sp)
    1fcc:	ec5e                	sd	s7,24(sp)
    1fce:	e862                	sd	s8,16(sp)
    1fd0:	e466                	sd	s9,8(sp)
    1fd2:	1080                	add	s0,sp,96
    1fd4:	84aa                	mv	s1,a0
  unlink("x");
    1fd6:	00004517          	auipc	a0,0x4
    1fda:	20250513          	add	a0,a0,514 # 61d8 <malloc+0x1ac>
    1fde:	00004097          	auipc	ra,0x4
    1fe2:	c6e080e7          	jalr	-914(ra) # 5c4c <unlink>
  pid = fork();
    1fe6:	00004097          	auipc	ra,0x4
    1fea:	c0e080e7          	jalr	-1010(ra) # 5bf4 <fork>
  if(pid < 0){
    1fee:	02054b63          	bltz	a0,2024 <linkunlink+0x6a>
    1ff2:	8caa                	mv	s9,a0
  unsigned int x = (pid ? 1 : 97);
    1ff4:	06100913          	li	s2,97
    1ff8:	c111                	beqz	a0,1ffc <linkunlink+0x42>
    1ffa:	4905                	li	s2,1
    1ffc:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    2000:	41c65a37          	lui	s4,0x41c65
    2004:	e6da0a1b          	addw	s4,s4,-403 # 41c64e6d <base+0x41c551f5>
    2008:	698d                	lui	s3,0x3
    200a:	0399899b          	addw	s3,s3,57 # 3039 <execout+0x8b>
    if((x % 3) == 0){
    200e:	4a8d                	li	s5,3
    } else if((x % 3) == 1){
    2010:	4b85                	li	s7,1
      unlink("x");
    2012:	00004b17          	auipc	s6,0x4
    2016:	1c6b0b13          	add	s6,s6,454 # 61d8 <malloc+0x1ac>
      link("cat", "x");
    201a:	00005c17          	auipc	s8,0x5
    201e:	c2ec0c13          	add	s8,s8,-978 # 6c48 <malloc+0xc1c>
    2022:	a825                	j	205a <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    2024:	85a6                	mv	a1,s1
    2026:	00005517          	auipc	a0,0x5
    202a:	9ca50513          	add	a0,a0,-1590 # 69f0 <malloc+0x9c4>
    202e:	00004097          	auipc	ra,0x4
    2032:	f46080e7          	jalr	-186(ra) # 5f74 <printf>
    exit(1);
    2036:	4505                	li	a0,1
    2038:	00004097          	auipc	ra,0x4
    203c:	bc4080e7          	jalr	-1084(ra) # 5bfc <exit>
      close(open("x", O_RDWR | O_CREATE));
    2040:	20200593          	li	a1,514
    2044:	855a                	mv	a0,s6
    2046:	00004097          	auipc	ra,0x4
    204a:	bf6080e7          	jalr	-1034(ra) # 5c3c <open>
    204e:	00004097          	auipc	ra,0x4
    2052:	bd6080e7          	jalr	-1066(ra) # 5c24 <close>
  for(i = 0; i < 100; i++){
    2056:	34fd                	addw	s1,s1,-1
    2058:	c895                	beqz	s1,208c <linkunlink+0xd2>
    x = x * 1103515245 + 12345;
    205a:	034907bb          	mulw	a5,s2,s4
    205e:	013787bb          	addw	a5,a5,s3
    2062:	0007891b          	sext.w	s2,a5
    if((x % 3) == 0){
    2066:	0357f7bb          	remuw	a5,a5,s5
    206a:	2781                	sext.w	a5,a5
    206c:	dbf1                	beqz	a5,2040 <linkunlink+0x86>
    } else if((x % 3) == 1){
    206e:	01778863          	beq	a5,s7,207e <linkunlink+0xc4>
      unlink("x");
    2072:	855a                	mv	a0,s6
    2074:	00004097          	auipc	ra,0x4
    2078:	bd8080e7          	jalr	-1064(ra) # 5c4c <unlink>
    207c:	bfe9                	j	2056 <linkunlink+0x9c>
      link("cat", "x");
    207e:	85da                	mv	a1,s6
    2080:	8562                	mv	a0,s8
    2082:	00004097          	auipc	ra,0x4
    2086:	bda080e7          	jalr	-1062(ra) # 5c5c <link>
    208a:	b7f1                	j	2056 <linkunlink+0x9c>
  if(pid)
    208c:	020c8463          	beqz	s9,20b4 <linkunlink+0xfa>
    wait(0);
    2090:	4501                	li	a0,0
    2092:	00004097          	auipc	ra,0x4
    2096:	b72080e7          	jalr	-1166(ra) # 5c04 <wait>
}
    209a:	60e6                	ld	ra,88(sp)
    209c:	6446                	ld	s0,80(sp)
    209e:	64a6                	ld	s1,72(sp)
    20a0:	6906                	ld	s2,64(sp)
    20a2:	79e2                	ld	s3,56(sp)
    20a4:	7a42                	ld	s4,48(sp)
    20a6:	7aa2                	ld	s5,40(sp)
    20a8:	7b02                	ld	s6,32(sp)
    20aa:	6be2                	ld	s7,24(sp)
    20ac:	6c42                	ld	s8,16(sp)
    20ae:	6ca2                	ld	s9,8(sp)
    20b0:	6125                	add	sp,sp,96
    20b2:	8082                	ret
    exit(0);
    20b4:	4501                	li	a0,0
    20b6:	00004097          	auipc	ra,0x4
    20ba:	b46080e7          	jalr	-1210(ra) # 5bfc <exit>

00000000000020be <forktest>:
{
    20be:	7179                	add	sp,sp,-48
    20c0:	f406                	sd	ra,40(sp)
    20c2:	f022                	sd	s0,32(sp)
    20c4:	ec26                	sd	s1,24(sp)
    20c6:	e84a                	sd	s2,16(sp)
    20c8:	e44e                	sd	s3,8(sp)
    20ca:	1800                	add	s0,sp,48
    20cc:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    20ce:	4481                	li	s1,0
    20d0:	3e800913          	li	s2,1000
    pid = fork();
    20d4:	00004097          	auipc	ra,0x4
    20d8:	b20080e7          	jalr	-1248(ra) # 5bf4 <fork>
    if(pid < 0)
    20dc:	08054263          	bltz	a0,2160 <forktest+0xa2>
    if(pid == 0)
    20e0:	c115                	beqz	a0,2104 <forktest+0x46>
  for(n=0; n<N; n++){
    20e2:	2485                	addw	s1,s1,1
    20e4:	ff2498e3          	bne	s1,s2,20d4 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    20e8:	85ce                	mv	a1,s3
    20ea:	00005517          	auipc	a0,0x5
    20ee:	bae50513          	add	a0,a0,-1106 # 6c98 <malloc+0xc6c>
    20f2:	00004097          	auipc	ra,0x4
    20f6:	e82080e7          	jalr	-382(ra) # 5f74 <printf>
    exit(1);
    20fa:	4505                	li	a0,1
    20fc:	00004097          	auipc	ra,0x4
    2100:	b00080e7          	jalr	-1280(ra) # 5bfc <exit>
      exit(0);
    2104:	00004097          	auipc	ra,0x4
    2108:	af8080e7          	jalr	-1288(ra) # 5bfc <exit>
    printf("%s: no fork at all!\n", s);
    210c:	85ce                	mv	a1,s3
    210e:	00005517          	auipc	a0,0x5
    2112:	b4250513          	add	a0,a0,-1214 # 6c50 <malloc+0xc24>
    2116:	00004097          	auipc	ra,0x4
    211a:	e5e080e7          	jalr	-418(ra) # 5f74 <printf>
    exit(1);
    211e:	4505                	li	a0,1
    2120:	00004097          	auipc	ra,0x4
    2124:	adc080e7          	jalr	-1316(ra) # 5bfc <exit>
      printf("%s: wait stopped early\n", s);
    2128:	85ce                	mv	a1,s3
    212a:	00005517          	auipc	a0,0x5
    212e:	b3e50513          	add	a0,a0,-1218 # 6c68 <malloc+0xc3c>
    2132:	00004097          	auipc	ra,0x4
    2136:	e42080e7          	jalr	-446(ra) # 5f74 <printf>
      exit(1);
    213a:	4505                	li	a0,1
    213c:	00004097          	auipc	ra,0x4
    2140:	ac0080e7          	jalr	-1344(ra) # 5bfc <exit>
    printf("%s: wait got too many\n", s);
    2144:	85ce                	mv	a1,s3
    2146:	00005517          	auipc	a0,0x5
    214a:	b3a50513          	add	a0,a0,-1222 # 6c80 <malloc+0xc54>
    214e:	00004097          	auipc	ra,0x4
    2152:	e26080e7          	jalr	-474(ra) # 5f74 <printf>
    exit(1);
    2156:	4505                	li	a0,1
    2158:	00004097          	auipc	ra,0x4
    215c:	aa4080e7          	jalr	-1372(ra) # 5bfc <exit>
  if (n == 0) {
    2160:	d4d5                	beqz	s1,210c <forktest+0x4e>
  for(; n > 0; n--){
    2162:	00905b63          	blez	s1,2178 <forktest+0xba>
    if(wait(0) < 0){
    2166:	4501                	li	a0,0
    2168:	00004097          	auipc	ra,0x4
    216c:	a9c080e7          	jalr	-1380(ra) # 5c04 <wait>
    2170:	fa054ce3          	bltz	a0,2128 <forktest+0x6a>
  for(; n > 0; n--){
    2174:	34fd                	addw	s1,s1,-1
    2176:	f8e5                	bnez	s1,2166 <forktest+0xa8>
  if(wait(0) != -1){
    2178:	4501                	li	a0,0
    217a:	00004097          	auipc	ra,0x4
    217e:	a8a080e7          	jalr	-1398(ra) # 5c04 <wait>
    2182:	57fd                	li	a5,-1
    2184:	fcf510e3          	bne	a0,a5,2144 <forktest+0x86>
}
    2188:	70a2                	ld	ra,40(sp)
    218a:	7402                	ld	s0,32(sp)
    218c:	64e2                	ld	s1,24(sp)
    218e:	6942                	ld	s2,16(sp)
    2190:	69a2                	ld	s3,8(sp)
    2192:	6145                	add	sp,sp,48
    2194:	8082                	ret

0000000000002196 <kernmem>:
{
    2196:	715d                	add	sp,sp,-80
    2198:	e486                	sd	ra,72(sp)
    219a:	e0a2                	sd	s0,64(sp)
    219c:	fc26                	sd	s1,56(sp)
    219e:	f84a                	sd	s2,48(sp)
    21a0:	f44e                	sd	s3,40(sp)
    21a2:	f052                	sd	s4,32(sp)
    21a4:	ec56                	sd	s5,24(sp)
    21a6:	0880                	add	s0,sp,80
    21a8:	8aaa                	mv	s5,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21aa:	4485                	li	s1,1
    21ac:	04fe                	sll	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    21ae:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21b0:	69b1                	lui	s3,0xc
    21b2:	35098993          	add	s3,s3,848 # c350 <uninit+0x1de8>
    21b6:	1003d937          	lui	s2,0x1003d
    21ba:	090e                	sll	s2,s2,0x3
    21bc:	48090913          	add	s2,s2,1152 # 1003d480 <base+0x1002d808>
    pid = fork();
    21c0:	00004097          	auipc	ra,0x4
    21c4:	a34080e7          	jalr	-1484(ra) # 5bf4 <fork>
    if(pid < 0){
    21c8:	02054963          	bltz	a0,21fa <kernmem+0x64>
    if(pid == 0){
    21cc:	c529                	beqz	a0,2216 <kernmem+0x80>
    wait(&xstatus);
    21ce:	fbc40513          	add	a0,s0,-68
    21d2:	00004097          	auipc	ra,0x4
    21d6:	a32080e7          	jalr	-1486(ra) # 5c04 <wait>
    if(xstatus != -1)  // did kernel kill child?
    21da:	fbc42783          	lw	a5,-68(s0)
    21de:	05479d63          	bne	a5,s4,2238 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    21e2:	94ce                	add	s1,s1,s3
    21e4:	fd249ee3          	bne	s1,s2,21c0 <kernmem+0x2a>
}
    21e8:	60a6                	ld	ra,72(sp)
    21ea:	6406                	ld	s0,64(sp)
    21ec:	74e2                	ld	s1,56(sp)
    21ee:	7942                	ld	s2,48(sp)
    21f0:	79a2                	ld	s3,40(sp)
    21f2:	7a02                	ld	s4,32(sp)
    21f4:	6ae2                	ld	s5,24(sp)
    21f6:	6161                	add	sp,sp,80
    21f8:	8082                	ret
      printf("%s: fork failed\n", s);
    21fa:	85d6                	mv	a1,s5
    21fc:	00004517          	auipc	a0,0x4
    2200:	7f450513          	add	a0,a0,2036 # 69f0 <malloc+0x9c4>
    2204:	00004097          	auipc	ra,0x4
    2208:	d70080e7          	jalr	-656(ra) # 5f74 <printf>
      exit(1);
    220c:	4505                	li	a0,1
    220e:	00004097          	auipc	ra,0x4
    2212:	9ee080e7          	jalr	-1554(ra) # 5bfc <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2216:	0004c683          	lbu	a3,0(s1)
    221a:	8626                	mv	a2,s1
    221c:	85d6                	mv	a1,s5
    221e:	00005517          	auipc	a0,0x5
    2222:	aa250513          	add	a0,a0,-1374 # 6cc0 <malloc+0xc94>
    2226:	00004097          	auipc	ra,0x4
    222a:	d4e080e7          	jalr	-690(ra) # 5f74 <printf>
      exit(1);
    222e:	4505                	li	a0,1
    2230:	00004097          	auipc	ra,0x4
    2234:	9cc080e7          	jalr	-1588(ra) # 5bfc <exit>
      exit(1);
    2238:	4505                	li	a0,1
    223a:	00004097          	auipc	ra,0x4
    223e:	9c2080e7          	jalr	-1598(ra) # 5bfc <exit>

0000000000002242 <MAXVAplus>:
{
    2242:	7179                	add	sp,sp,-48
    2244:	f406                	sd	ra,40(sp)
    2246:	f022                	sd	s0,32(sp)
    2248:	1800                	add	s0,sp,48
  volatile uint64 a = MAXVA;
    224a:	4785                	li	a5,1
    224c:	179a                	sll	a5,a5,0x26
    224e:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    2252:	fd843783          	ld	a5,-40(s0)
    2256:	c3a1                	beqz	a5,2296 <MAXVAplus+0x54>
    2258:	ec26                	sd	s1,24(sp)
    225a:	e84a                	sd	s2,16(sp)
    225c:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    225e:	54fd                	li	s1,-1
    pid = fork();
    2260:	00004097          	auipc	ra,0x4
    2264:	994080e7          	jalr	-1644(ra) # 5bf4 <fork>
    if(pid < 0){
    2268:	02054b63          	bltz	a0,229e <MAXVAplus+0x5c>
    if(pid == 0){
    226c:	c539                	beqz	a0,22ba <MAXVAplus+0x78>
    wait(&xstatus);
    226e:	fd440513          	add	a0,s0,-44
    2272:	00004097          	auipc	ra,0x4
    2276:	992080e7          	jalr	-1646(ra) # 5c04 <wait>
    if(xstatus != -1)  // did kernel kill child?
    227a:	fd442783          	lw	a5,-44(s0)
    227e:	06979463          	bne	a5,s1,22e6 <MAXVAplus+0xa4>
  for( ; a != 0; a <<= 1){
    2282:	fd843783          	ld	a5,-40(s0)
    2286:	0786                	sll	a5,a5,0x1
    2288:	fcf43c23          	sd	a5,-40(s0)
    228c:	fd843783          	ld	a5,-40(s0)
    2290:	fbe1                	bnez	a5,2260 <MAXVAplus+0x1e>
    2292:	64e2                	ld	s1,24(sp)
    2294:	6942                	ld	s2,16(sp)
}
    2296:	70a2                	ld	ra,40(sp)
    2298:	7402                	ld	s0,32(sp)
    229a:	6145                	add	sp,sp,48
    229c:	8082                	ret
      printf("%s: fork failed\n", s);
    229e:	85ca                	mv	a1,s2
    22a0:	00004517          	auipc	a0,0x4
    22a4:	75050513          	add	a0,a0,1872 # 69f0 <malloc+0x9c4>
    22a8:	00004097          	auipc	ra,0x4
    22ac:	ccc080e7          	jalr	-820(ra) # 5f74 <printf>
      exit(1);
    22b0:	4505                	li	a0,1
    22b2:	00004097          	auipc	ra,0x4
    22b6:	94a080e7          	jalr	-1718(ra) # 5bfc <exit>
      *(char*)a = 99;
    22ba:	fd843783          	ld	a5,-40(s0)
    22be:	06300713          	li	a4,99
    22c2:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %x\n", s, a);
    22c6:	fd843603          	ld	a2,-40(s0)
    22ca:	85ca                	mv	a1,s2
    22cc:	00005517          	auipc	a0,0x5
    22d0:	a1450513          	add	a0,a0,-1516 # 6ce0 <malloc+0xcb4>
    22d4:	00004097          	auipc	ra,0x4
    22d8:	ca0080e7          	jalr	-864(ra) # 5f74 <printf>
      exit(1);
    22dc:	4505                	li	a0,1
    22de:	00004097          	auipc	ra,0x4
    22e2:	91e080e7          	jalr	-1762(ra) # 5bfc <exit>
      exit(1);
    22e6:	4505                	li	a0,1
    22e8:	00004097          	auipc	ra,0x4
    22ec:	914080e7          	jalr	-1772(ra) # 5bfc <exit>

00000000000022f0 <bigargtest>:
{
    22f0:	7179                	add	sp,sp,-48
    22f2:	f406                	sd	ra,40(sp)
    22f4:	f022                	sd	s0,32(sp)
    22f6:	ec26                	sd	s1,24(sp)
    22f8:	1800                	add	s0,sp,48
    22fa:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    22fc:	00005517          	auipc	a0,0x5
    2300:	9fc50513          	add	a0,a0,-1540 # 6cf8 <malloc+0xccc>
    2304:	00004097          	auipc	ra,0x4
    2308:	948080e7          	jalr	-1720(ra) # 5c4c <unlink>
  pid = fork();
    230c:	00004097          	auipc	ra,0x4
    2310:	8e8080e7          	jalr	-1816(ra) # 5bf4 <fork>
  if(pid == 0){
    2314:	c121                	beqz	a0,2354 <bigargtest+0x64>
  } else if(pid < 0){
    2316:	0a054063          	bltz	a0,23b6 <bigargtest+0xc6>
  wait(&xstatus);
    231a:	fdc40513          	add	a0,s0,-36
    231e:	00004097          	auipc	ra,0x4
    2322:	8e6080e7          	jalr	-1818(ra) # 5c04 <wait>
  if(xstatus != 0)
    2326:	fdc42503          	lw	a0,-36(s0)
    232a:	e545                	bnez	a0,23d2 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    232c:	4581                	li	a1,0
    232e:	00005517          	auipc	a0,0x5
    2332:	9ca50513          	add	a0,a0,-1590 # 6cf8 <malloc+0xccc>
    2336:	00004097          	auipc	ra,0x4
    233a:	906080e7          	jalr	-1786(ra) # 5c3c <open>
  if(fd < 0){
    233e:	08054e63          	bltz	a0,23da <bigargtest+0xea>
  close(fd);
    2342:	00004097          	auipc	ra,0x4
    2346:	8e2080e7          	jalr	-1822(ra) # 5c24 <close>
}
    234a:	70a2                	ld	ra,40(sp)
    234c:	7402                	ld	s0,32(sp)
    234e:	64e2                	ld	s1,24(sp)
    2350:	6145                	add	sp,sp,48
    2352:	8082                	ret
    2354:	00007797          	auipc	a5,0x7
    2358:	10c78793          	add	a5,a5,268 # 9460 <args.1>
    235c:	00007697          	auipc	a3,0x7
    2360:	1fc68693          	add	a3,a3,508 # 9558 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    2364:	00005717          	auipc	a4,0x5
    2368:	9a470713          	add	a4,a4,-1628 # 6d08 <malloc+0xcdc>
    236c:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    236e:	07a1                	add	a5,a5,8
    2370:	fed79ee3          	bne	a5,a3,236c <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    2374:	00007597          	auipc	a1,0x7
    2378:	0ec58593          	add	a1,a1,236 # 9460 <args.1>
    237c:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2380:	00004517          	auipc	a0,0x4
    2384:	de850513          	add	a0,a0,-536 # 6168 <malloc+0x13c>
    2388:	00004097          	auipc	ra,0x4
    238c:	8ac080e7          	jalr	-1876(ra) # 5c34 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2390:	20000593          	li	a1,512
    2394:	00005517          	auipc	a0,0x5
    2398:	96450513          	add	a0,a0,-1692 # 6cf8 <malloc+0xccc>
    239c:	00004097          	auipc	ra,0x4
    23a0:	8a0080e7          	jalr	-1888(ra) # 5c3c <open>
    close(fd);
    23a4:	00004097          	auipc	ra,0x4
    23a8:	880080e7          	jalr	-1920(ra) # 5c24 <close>
    exit(0);
    23ac:	4501                	li	a0,0
    23ae:	00004097          	auipc	ra,0x4
    23b2:	84e080e7          	jalr	-1970(ra) # 5bfc <exit>
    printf("%s: bigargtest: fork failed\n", s);
    23b6:	85a6                	mv	a1,s1
    23b8:	00005517          	auipc	a0,0x5
    23bc:	a3050513          	add	a0,a0,-1488 # 6de8 <malloc+0xdbc>
    23c0:	00004097          	auipc	ra,0x4
    23c4:	bb4080e7          	jalr	-1100(ra) # 5f74 <printf>
    exit(1);
    23c8:	4505                	li	a0,1
    23ca:	00004097          	auipc	ra,0x4
    23ce:	832080e7          	jalr	-1998(ra) # 5bfc <exit>
    exit(xstatus);
    23d2:	00004097          	auipc	ra,0x4
    23d6:	82a080e7          	jalr	-2006(ra) # 5bfc <exit>
    printf("%s: bigarg test failed!\n", s);
    23da:	85a6                	mv	a1,s1
    23dc:	00005517          	auipc	a0,0x5
    23e0:	a2c50513          	add	a0,a0,-1492 # 6e08 <malloc+0xddc>
    23e4:	00004097          	auipc	ra,0x4
    23e8:	b90080e7          	jalr	-1136(ra) # 5f74 <printf>
    exit(1);
    23ec:	4505                	li	a0,1
    23ee:	00004097          	auipc	ra,0x4
    23f2:	80e080e7          	jalr	-2034(ra) # 5bfc <exit>

00000000000023f6 <stacktest>:
{
    23f6:	7179                	add	sp,sp,-48
    23f8:	f406                	sd	ra,40(sp)
    23fa:	f022                	sd	s0,32(sp)
    23fc:	ec26                	sd	s1,24(sp)
    23fe:	1800                	add	s0,sp,48
    2400:	84aa                	mv	s1,a0
  pid = fork();
    2402:	00003097          	auipc	ra,0x3
    2406:	7f2080e7          	jalr	2034(ra) # 5bf4 <fork>
  if(pid == 0) {
    240a:	c115                	beqz	a0,242e <stacktest+0x38>
  } else if(pid < 0){
    240c:	04054463          	bltz	a0,2454 <stacktest+0x5e>
  wait(&xstatus);
    2410:	fdc40513          	add	a0,s0,-36
    2414:	00003097          	auipc	ra,0x3
    2418:	7f0080e7          	jalr	2032(ra) # 5c04 <wait>
  if(xstatus == -1)  // kernel killed child?
    241c:	fdc42503          	lw	a0,-36(s0)
    2420:	57fd                	li	a5,-1
    2422:	04f50763          	beq	a0,a5,2470 <stacktest+0x7a>
    exit(xstatus);
    2426:	00003097          	auipc	ra,0x3
    242a:	7d6080e7          	jalr	2006(ra) # 5bfc <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    242e:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    2430:	77fd                	lui	a5,0xfffff
    2432:	97ba                	add	a5,a5,a4
    2434:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xfffffffffffef388>
    2438:	85a6                	mv	a1,s1
    243a:	00005517          	auipc	a0,0x5
    243e:	9ee50513          	add	a0,a0,-1554 # 6e28 <malloc+0xdfc>
    2442:	00004097          	auipc	ra,0x4
    2446:	b32080e7          	jalr	-1230(ra) # 5f74 <printf>
    exit(1);
    244a:	4505                	li	a0,1
    244c:	00003097          	auipc	ra,0x3
    2450:	7b0080e7          	jalr	1968(ra) # 5bfc <exit>
    printf("%s: fork failed\n", s);
    2454:	85a6                	mv	a1,s1
    2456:	00004517          	auipc	a0,0x4
    245a:	59a50513          	add	a0,a0,1434 # 69f0 <malloc+0x9c4>
    245e:	00004097          	auipc	ra,0x4
    2462:	b16080e7          	jalr	-1258(ra) # 5f74 <printf>
    exit(1);
    2466:	4505                	li	a0,1
    2468:	00003097          	auipc	ra,0x3
    246c:	794080e7          	jalr	1940(ra) # 5bfc <exit>
    exit(0);
    2470:	4501                	li	a0,0
    2472:	00003097          	auipc	ra,0x3
    2476:	78a080e7          	jalr	1930(ra) # 5bfc <exit>

000000000000247a <textwrite>:
{
    247a:	7179                	add	sp,sp,-48
    247c:	f406                	sd	ra,40(sp)
    247e:	f022                	sd	s0,32(sp)
    2480:	ec26                	sd	s1,24(sp)
    2482:	1800                	add	s0,sp,48
    2484:	84aa                	mv	s1,a0
  pid = fork();
    2486:	00003097          	auipc	ra,0x3
    248a:	76e080e7          	jalr	1902(ra) # 5bf4 <fork>
  if(pid == 0) {
    248e:	c115                	beqz	a0,24b2 <textwrite+0x38>
  } else if(pid < 0){
    2490:	02054963          	bltz	a0,24c2 <textwrite+0x48>
  wait(&xstatus);
    2494:	fdc40513          	add	a0,s0,-36
    2498:	00003097          	auipc	ra,0x3
    249c:	76c080e7          	jalr	1900(ra) # 5c04 <wait>
  if(xstatus == -1)  // kernel killed child?
    24a0:	fdc42503          	lw	a0,-36(s0)
    24a4:	57fd                	li	a5,-1
    24a6:	02f50c63          	beq	a0,a5,24de <textwrite+0x64>
    exit(xstatus);
    24aa:	00003097          	auipc	ra,0x3
    24ae:	752080e7          	jalr	1874(ra) # 5bfc <exit>
    *addr = 10;
    24b2:	47a9                	li	a5,10
    24b4:	00f02023          	sw	a5,0(zero) # 0 <copyinstr1>
    exit(1);
    24b8:	4505                	li	a0,1
    24ba:	00003097          	auipc	ra,0x3
    24be:	742080e7          	jalr	1858(ra) # 5bfc <exit>
    printf("%s: fork failed\n", s);
    24c2:	85a6                	mv	a1,s1
    24c4:	00004517          	auipc	a0,0x4
    24c8:	52c50513          	add	a0,a0,1324 # 69f0 <malloc+0x9c4>
    24cc:	00004097          	auipc	ra,0x4
    24d0:	aa8080e7          	jalr	-1368(ra) # 5f74 <printf>
    exit(1);
    24d4:	4505                	li	a0,1
    24d6:	00003097          	auipc	ra,0x3
    24da:	726080e7          	jalr	1830(ra) # 5bfc <exit>
    exit(0);
    24de:	4501                	li	a0,0
    24e0:	00003097          	auipc	ra,0x3
    24e4:	71c080e7          	jalr	1820(ra) # 5bfc <exit>

00000000000024e8 <manywrites>:
{
    24e8:	711d                	add	sp,sp,-96
    24ea:	ec86                	sd	ra,88(sp)
    24ec:	e8a2                	sd	s0,80(sp)
    24ee:	e4a6                	sd	s1,72(sp)
    24f0:	e0ca                	sd	s2,64(sp)
    24f2:	fc4e                	sd	s3,56(sp)
    24f4:	f456                	sd	s5,40(sp)
    24f6:	1080                	add	s0,sp,96
    24f8:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    24fa:	4981                	li	s3,0
    24fc:	4911                	li	s2,4
    int pid = fork();
    24fe:	00003097          	auipc	ra,0x3
    2502:	6f6080e7          	jalr	1782(ra) # 5bf4 <fork>
    2506:	84aa                	mv	s1,a0
    if(pid < 0){
    2508:	02054d63          	bltz	a0,2542 <manywrites+0x5a>
    if(pid == 0){
    250c:	c939                	beqz	a0,2562 <manywrites+0x7a>
  for(int ci = 0; ci < nchildren; ci++){
    250e:	2985                	addw	s3,s3,1
    2510:	ff2997e3          	bne	s3,s2,24fe <manywrites+0x16>
    2514:	f852                	sd	s4,48(sp)
    2516:	f05a                	sd	s6,32(sp)
    2518:	ec5e                	sd	s7,24(sp)
    251a:	4491                	li	s1,4
    int st = 0;
    251c:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    2520:	fa840513          	add	a0,s0,-88
    2524:	00003097          	auipc	ra,0x3
    2528:	6e0080e7          	jalr	1760(ra) # 5c04 <wait>
    if(st != 0)
    252c:	fa842503          	lw	a0,-88(s0)
    2530:	10051463          	bnez	a0,2638 <manywrites+0x150>
  for(int ci = 0; ci < nchildren; ci++){
    2534:	34fd                	addw	s1,s1,-1
    2536:	f0fd                	bnez	s1,251c <manywrites+0x34>
  exit(0);
    2538:	4501                	li	a0,0
    253a:	00003097          	auipc	ra,0x3
    253e:	6c2080e7          	jalr	1730(ra) # 5bfc <exit>
    2542:	f852                	sd	s4,48(sp)
    2544:	f05a                	sd	s6,32(sp)
    2546:	ec5e                	sd	s7,24(sp)
      printf("fork failed\n");
    2548:	00005517          	auipc	a0,0x5
    254c:	8b050513          	add	a0,a0,-1872 # 6df8 <malloc+0xdcc>
    2550:	00004097          	auipc	ra,0x4
    2554:	a24080e7          	jalr	-1500(ra) # 5f74 <printf>
      exit(1);
    2558:	4505                	li	a0,1
    255a:	00003097          	auipc	ra,0x3
    255e:	6a2080e7          	jalr	1698(ra) # 5bfc <exit>
    2562:	f852                	sd	s4,48(sp)
    2564:	f05a                	sd	s6,32(sp)
    2566:	ec5e                	sd	s7,24(sp)
      name[0] = 'b';
    2568:	06200793          	li	a5,98
    256c:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    2570:	0619879b          	addw	a5,s3,97
    2574:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    2578:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    257c:	fa840513          	add	a0,s0,-88
    2580:	00003097          	auipc	ra,0x3
    2584:	6cc080e7          	jalr	1740(ra) # 5c4c <unlink>
    2588:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    258a:	0000ab17          	auipc	s6,0xa
    258e:	6eeb0b13          	add	s6,s6,1774 # cc78 <buf>
        for(int i = 0; i < ci+1; i++){
    2592:	8a26                	mv	s4,s1
    2594:	0209ce63          	bltz	s3,25d0 <manywrites+0xe8>
          int fd = open(name, O_CREATE | O_RDWR);
    2598:	20200593          	li	a1,514
    259c:	fa840513          	add	a0,s0,-88
    25a0:	00003097          	auipc	ra,0x3
    25a4:	69c080e7          	jalr	1692(ra) # 5c3c <open>
    25a8:	892a                	mv	s2,a0
          if(fd < 0){
    25aa:	04054763          	bltz	a0,25f8 <manywrites+0x110>
          int cc = write(fd, buf, sz);
    25ae:	660d                	lui	a2,0x3
    25b0:	85da                	mv	a1,s6
    25b2:	00003097          	auipc	ra,0x3
    25b6:	66a080e7          	jalr	1642(ra) # 5c1c <write>
          if(cc != sz){
    25ba:	678d                	lui	a5,0x3
    25bc:	04f51e63          	bne	a0,a5,2618 <manywrites+0x130>
          close(fd);
    25c0:	854a                	mv	a0,s2
    25c2:	00003097          	auipc	ra,0x3
    25c6:	662080e7          	jalr	1634(ra) # 5c24 <close>
        for(int i = 0; i < ci+1; i++){
    25ca:	2a05                	addw	s4,s4,1
    25cc:	fd49d6e3          	bge	s3,s4,2598 <manywrites+0xb0>
        unlink(name);
    25d0:	fa840513          	add	a0,s0,-88
    25d4:	00003097          	auipc	ra,0x3
    25d8:	678080e7          	jalr	1656(ra) # 5c4c <unlink>
      for(int iters = 0; iters < howmany; iters++){
    25dc:	3bfd                	addw	s7,s7,-1
    25de:	fa0b9ae3          	bnez	s7,2592 <manywrites+0xaa>
      unlink(name);
    25e2:	fa840513          	add	a0,s0,-88
    25e6:	00003097          	auipc	ra,0x3
    25ea:	666080e7          	jalr	1638(ra) # 5c4c <unlink>
      exit(0);
    25ee:	4501                	li	a0,0
    25f0:	00003097          	auipc	ra,0x3
    25f4:	60c080e7          	jalr	1548(ra) # 5bfc <exit>
            printf("%s: cannot create %s\n", s, name);
    25f8:	fa840613          	add	a2,s0,-88
    25fc:	85d6                	mv	a1,s5
    25fe:	00005517          	auipc	a0,0x5
    2602:	85250513          	add	a0,a0,-1966 # 6e50 <malloc+0xe24>
    2606:	00004097          	auipc	ra,0x4
    260a:	96e080e7          	jalr	-1682(ra) # 5f74 <printf>
            exit(1);
    260e:	4505                	li	a0,1
    2610:	00003097          	auipc	ra,0x3
    2614:	5ec080e7          	jalr	1516(ra) # 5bfc <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    2618:	86aa                	mv	a3,a0
    261a:	660d                	lui	a2,0x3
    261c:	85d6                	mv	a1,s5
    261e:	00004517          	auipc	a0,0x4
    2622:	c1a50513          	add	a0,a0,-998 # 6238 <malloc+0x20c>
    2626:	00004097          	auipc	ra,0x4
    262a:	94e080e7          	jalr	-1714(ra) # 5f74 <printf>
            exit(1);
    262e:	4505                	li	a0,1
    2630:	00003097          	auipc	ra,0x3
    2634:	5cc080e7          	jalr	1484(ra) # 5bfc <exit>
      exit(st);
    2638:	00003097          	auipc	ra,0x3
    263c:	5c4080e7          	jalr	1476(ra) # 5bfc <exit>

0000000000002640 <copyinstr3>:
{
    2640:	7179                	add	sp,sp,-48
    2642:	f406                	sd	ra,40(sp)
    2644:	f022                	sd	s0,32(sp)
    2646:	ec26                	sd	s1,24(sp)
    2648:	1800                	add	s0,sp,48
  sbrk(8192);
    264a:	6509                	lui	a0,0x2
    264c:	00003097          	auipc	ra,0x3
    2650:	638080e7          	jalr	1592(ra) # 5c84 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2654:	4501                	li	a0,0
    2656:	00003097          	auipc	ra,0x3
    265a:	62e080e7          	jalr	1582(ra) # 5c84 <sbrk>
  if((top % PGSIZE) != 0){
    265e:	03451793          	sll	a5,a0,0x34
    2662:	e3c9                	bnez	a5,26e4 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2664:	4501                	li	a0,0
    2666:	00003097          	auipc	ra,0x3
    266a:	61e080e7          	jalr	1566(ra) # 5c84 <sbrk>
  if(top % PGSIZE){
    266e:	03451793          	sll	a5,a0,0x34
    2672:	e3d9                	bnez	a5,26f8 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2674:	fff50493          	add	s1,a0,-1 # 1fff <linkunlink+0x45>
  *b = 'x';
    2678:	07800793          	li	a5,120
    267c:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2680:	8526                	mv	a0,s1
    2682:	00003097          	auipc	ra,0x3
    2686:	5ca080e7          	jalr	1482(ra) # 5c4c <unlink>
  if(ret != -1){
    268a:	57fd                	li	a5,-1
    268c:	08f51363          	bne	a0,a5,2712 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2690:	20100593          	li	a1,513
    2694:	8526                	mv	a0,s1
    2696:	00003097          	auipc	ra,0x3
    269a:	5a6080e7          	jalr	1446(ra) # 5c3c <open>
  if(fd != -1){
    269e:	57fd                	li	a5,-1
    26a0:	08f51863          	bne	a0,a5,2730 <copyinstr3+0xf0>
  ret = link(b, b);
    26a4:	85a6                	mv	a1,s1
    26a6:	8526                	mv	a0,s1
    26a8:	00003097          	auipc	ra,0x3
    26ac:	5b4080e7          	jalr	1460(ra) # 5c5c <link>
  if(ret != -1){
    26b0:	57fd                	li	a5,-1
    26b2:	08f51e63          	bne	a0,a5,274e <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    26b6:	00005797          	auipc	a5,0x5
    26ba:	49278793          	add	a5,a5,1170 # 7b48 <malloc+0x1b1c>
    26be:	fcf43823          	sd	a5,-48(s0)
    26c2:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    26c6:	fd040593          	add	a1,s0,-48
    26ca:	8526                	mv	a0,s1
    26cc:	00003097          	auipc	ra,0x3
    26d0:	568080e7          	jalr	1384(ra) # 5c34 <exec>
  if(ret != -1){
    26d4:	57fd                	li	a5,-1
    26d6:	08f51c63          	bne	a0,a5,276e <copyinstr3+0x12e>
}
    26da:	70a2                	ld	ra,40(sp)
    26dc:	7402                	ld	s0,32(sp)
    26de:	64e2                	ld	s1,24(sp)
    26e0:	6145                	add	sp,sp,48
    26e2:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    26e4:	0347d513          	srl	a0,a5,0x34
    26e8:	6785                	lui	a5,0x1
    26ea:	40a7853b          	subw	a0,a5,a0
    26ee:	00003097          	auipc	ra,0x3
    26f2:	596080e7          	jalr	1430(ra) # 5c84 <sbrk>
    26f6:	b7bd                	j	2664 <copyinstr3+0x24>
    printf("oops\n");
    26f8:	00004517          	auipc	a0,0x4
    26fc:	77050513          	add	a0,a0,1904 # 6e68 <malloc+0xe3c>
    2700:	00004097          	auipc	ra,0x4
    2704:	874080e7          	jalr	-1932(ra) # 5f74 <printf>
    exit(1);
    2708:	4505                	li	a0,1
    270a:	00003097          	auipc	ra,0x3
    270e:	4f2080e7          	jalr	1266(ra) # 5bfc <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    2712:	862a                	mv	a2,a0
    2714:	85a6                	mv	a1,s1
    2716:	00004517          	auipc	a0,0x4
    271a:	1fa50513          	add	a0,a0,506 # 6910 <malloc+0x8e4>
    271e:	00004097          	auipc	ra,0x4
    2722:	856080e7          	jalr	-1962(ra) # 5f74 <printf>
    exit(1);
    2726:	4505                	li	a0,1
    2728:	00003097          	auipc	ra,0x3
    272c:	4d4080e7          	jalr	1236(ra) # 5bfc <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2730:	862a                	mv	a2,a0
    2732:	85a6                	mv	a1,s1
    2734:	00004517          	auipc	a0,0x4
    2738:	1fc50513          	add	a0,a0,508 # 6930 <malloc+0x904>
    273c:	00004097          	auipc	ra,0x4
    2740:	838080e7          	jalr	-1992(ra) # 5f74 <printf>
    exit(1);
    2744:	4505                	li	a0,1
    2746:	00003097          	auipc	ra,0x3
    274a:	4b6080e7          	jalr	1206(ra) # 5bfc <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    274e:	86aa                	mv	a3,a0
    2750:	8626                	mv	a2,s1
    2752:	85a6                	mv	a1,s1
    2754:	00004517          	auipc	a0,0x4
    2758:	1fc50513          	add	a0,a0,508 # 6950 <malloc+0x924>
    275c:	00004097          	auipc	ra,0x4
    2760:	818080e7          	jalr	-2024(ra) # 5f74 <printf>
    exit(1);
    2764:	4505                	li	a0,1
    2766:	00003097          	auipc	ra,0x3
    276a:	496080e7          	jalr	1174(ra) # 5bfc <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    276e:	567d                	li	a2,-1
    2770:	85a6                	mv	a1,s1
    2772:	00004517          	auipc	a0,0x4
    2776:	20650513          	add	a0,a0,518 # 6978 <malloc+0x94c>
    277a:	00003097          	auipc	ra,0x3
    277e:	7fa080e7          	jalr	2042(ra) # 5f74 <printf>
    exit(1);
    2782:	4505                	li	a0,1
    2784:	00003097          	auipc	ra,0x3
    2788:	478080e7          	jalr	1144(ra) # 5bfc <exit>

000000000000278c <rwsbrk>:
{
    278c:	1101                	add	sp,sp,-32
    278e:	ec06                	sd	ra,24(sp)
    2790:	e822                	sd	s0,16(sp)
    2792:	1000                	add	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2794:	6509                	lui	a0,0x2
    2796:	00003097          	auipc	ra,0x3
    279a:	4ee080e7          	jalr	1262(ra) # 5c84 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    279e:	57fd                	li	a5,-1
    27a0:	06f50463          	beq	a0,a5,2808 <rwsbrk+0x7c>
    27a4:	e426                	sd	s1,8(sp)
    27a6:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    27a8:	7579                	lui	a0,0xffffe
    27aa:	00003097          	auipc	ra,0x3
    27ae:	4da080e7          	jalr	1242(ra) # 5c84 <sbrk>
    27b2:	57fd                	li	a5,-1
    27b4:	06f50963          	beq	a0,a5,2826 <rwsbrk+0x9a>
    27b8:	e04a                	sd	s2,0(sp)
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    27ba:	20100593          	li	a1,513
    27be:	00004517          	auipc	a0,0x4
    27c2:	6ea50513          	add	a0,a0,1770 # 6ea8 <malloc+0xe7c>
    27c6:	00003097          	auipc	ra,0x3
    27ca:	476080e7          	jalr	1142(ra) # 5c3c <open>
    27ce:	892a                	mv	s2,a0
  if(fd < 0){
    27d0:	06054963          	bltz	a0,2842 <rwsbrk+0xb6>
  n = write(fd, (void*)(a+4096), 1024);
    27d4:	6785                	lui	a5,0x1
    27d6:	94be                	add	s1,s1,a5
    27d8:	40000613          	li	a2,1024
    27dc:	85a6                	mv	a1,s1
    27de:	00003097          	auipc	ra,0x3
    27e2:	43e080e7          	jalr	1086(ra) # 5c1c <write>
    27e6:	862a                	mv	a2,a0
  if(n >= 0){
    27e8:	06054a63          	bltz	a0,285c <rwsbrk+0xd0>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    27ec:	85a6                	mv	a1,s1
    27ee:	00004517          	auipc	a0,0x4
    27f2:	6da50513          	add	a0,a0,1754 # 6ec8 <malloc+0xe9c>
    27f6:	00003097          	auipc	ra,0x3
    27fa:	77e080e7          	jalr	1918(ra) # 5f74 <printf>
    exit(1);
    27fe:	4505                	li	a0,1
    2800:	00003097          	auipc	ra,0x3
    2804:	3fc080e7          	jalr	1020(ra) # 5bfc <exit>
    2808:	e426                	sd	s1,8(sp)
    280a:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) failed\n");
    280c:	00004517          	auipc	a0,0x4
    2810:	66450513          	add	a0,a0,1636 # 6e70 <malloc+0xe44>
    2814:	00003097          	auipc	ra,0x3
    2818:	760080e7          	jalr	1888(ra) # 5f74 <printf>
    exit(1);
    281c:	4505                	li	a0,1
    281e:	00003097          	auipc	ra,0x3
    2822:	3de080e7          	jalr	990(ra) # 5bfc <exit>
    2826:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) shrink failed\n");
    2828:	00004517          	auipc	a0,0x4
    282c:	66050513          	add	a0,a0,1632 # 6e88 <malloc+0xe5c>
    2830:	00003097          	auipc	ra,0x3
    2834:	744080e7          	jalr	1860(ra) # 5f74 <printf>
    exit(1);
    2838:	4505                	li	a0,1
    283a:	00003097          	auipc	ra,0x3
    283e:	3c2080e7          	jalr	962(ra) # 5bfc <exit>
    printf("open(rwsbrk) failed\n");
    2842:	00004517          	auipc	a0,0x4
    2846:	66e50513          	add	a0,a0,1646 # 6eb0 <malloc+0xe84>
    284a:	00003097          	auipc	ra,0x3
    284e:	72a080e7          	jalr	1834(ra) # 5f74 <printf>
    exit(1);
    2852:	4505                	li	a0,1
    2854:	00003097          	auipc	ra,0x3
    2858:	3a8080e7          	jalr	936(ra) # 5bfc <exit>
  close(fd);
    285c:	854a                	mv	a0,s2
    285e:	00003097          	auipc	ra,0x3
    2862:	3c6080e7          	jalr	966(ra) # 5c24 <close>
  unlink("rwsbrk");
    2866:	00004517          	auipc	a0,0x4
    286a:	64250513          	add	a0,a0,1602 # 6ea8 <malloc+0xe7c>
    286e:	00003097          	auipc	ra,0x3
    2872:	3de080e7          	jalr	990(ra) # 5c4c <unlink>
  fd = open("README", O_RDONLY);
    2876:	4581                	li	a1,0
    2878:	00004517          	auipc	a0,0x4
    287c:	ac850513          	add	a0,a0,-1336 # 6340 <malloc+0x314>
    2880:	00003097          	auipc	ra,0x3
    2884:	3bc080e7          	jalr	956(ra) # 5c3c <open>
    2888:	892a                	mv	s2,a0
  if(fd < 0){
    288a:	02054963          	bltz	a0,28bc <rwsbrk+0x130>
  n = read(fd, (void*)(a+4096), 10);
    288e:	4629                	li	a2,10
    2890:	85a6                	mv	a1,s1
    2892:	00003097          	auipc	ra,0x3
    2896:	382080e7          	jalr	898(ra) # 5c14 <read>
    289a:	862a                	mv	a2,a0
  if(n >= 0){
    289c:	02054d63          	bltz	a0,28d6 <rwsbrk+0x14a>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    28a0:	85a6                	mv	a1,s1
    28a2:	00004517          	auipc	a0,0x4
    28a6:	65650513          	add	a0,a0,1622 # 6ef8 <malloc+0xecc>
    28aa:	00003097          	auipc	ra,0x3
    28ae:	6ca080e7          	jalr	1738(ra) # 5f74 <printf>
    exit(1);
    28b2:	4505                	li	a0,1
    28b4:	00003097          	auipc	ra,0x3
    28b8:	348080e7          	jalr	840(ra) # 5bfc <exit>
    printf("open(rwsbrk) failed\n");
    28bc:	00004517          	auipc	a0,0x4
    28c0:	5f450513          	add	a0,a0,1524 # 6eb0 <malloc+0xe84>
    28c4:	00003097          	auipc	ra,0x3
    28c8:	6b0080e7          	jalr	1712(ra) # 5f74 <printf>
    exit(1);
    28cc:	4505                	li	a0,1
    28ce:	00003097          	auipc	ra,0x3
    28d2:	32e080e7          	jalr	814(ra) # 5bfc <exit>
  close(fd);
    28d6:	854a                	mv	a0,s2
    28d8:	00003097          	auipc	ra,0x3
    28dc:	34c080e7          	jalr	844(ra) # 5c24 <close>
  exit(0);
    28e0:	4501                	li	a0,0
    28e2:	00003097          	auipc	ra,0x3
    28e6:	31a080e7          	jalr	794(ra) # 5bfc <exit>

00000000000028ea <sbrkbasic>:
{
    28ea:	7139                	add	sp,sp,-64
    28ec:	fc06                	sd	ra,56(sp)
    28ee:	f822                	sd	s0,48(sp)
    28f0:	ec4e                	sd	s3,24(sp)
    28f2:	0080                	add	s0,sp,64
    28f4:	89aa                	mv	s3,a0
  pid = fork();
    28f6:	00003097          	auipc	ra,0x3
    28fa:	2fe080e7          	jalr	766(ra) # 5bf4 <fork>
  if(pid < 0){
    28fe:	02054f63          	bltz	a0,293c <sbrkbasic+0x52>
  if(pid == 0){
    2902:	e52d                	bnez	a0,296c <sbrkbasic+0x82>
    a = sbrk(TOOMUCH);
    2904:	40000537          	lui	a0,0x40000
    2908:	00003097          	auipc	ra,0x3
    290c:	37c080e7          	jalr	892(ra) # 5c84 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    2910:	57fd                	li	a5,-1
    2912:	04f50563          	beq	a0,a5,295c <sbrkbasic+0x72>
    2916:	f426                	sd	s1,40(sp)
    2918:	f04a                	sd	s2,32(sp)
    291a:	e852                	sd	s4,16(sp)
    for(b = a; b < a+TOOMUCH; b += 4096){
    291c:	400007b7          	lui	a5,0x40000
    2920:	97aa                	add	a5,a5,a0
      *b = 99;
    2922:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2926:	6705                	lui	a4,0x1
      *b = 99;
    2928:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff0388>
    for(b = a; b < a+TOOMUCH; b += 4096){
    292c:	953a                	add	a0,a0,a4
    292e:	fef51de3          	bne	a0,a5,2928 <sbrkbasic+0x3e>
    exit(1);
    2932:	4505                	li	a0,1
    2934:	00003097          	auipc	ra,0x3
    2938:	2c8080e7          	jalr	712(ra) # 5bfc <exit>
    293c:	f426                	sd	s1,40(sp)
    293e:	f04a                	sd	s2,32(sp)
    2940:	e852                	sd	s4,16(sp)
    printf("fork failed in sbrkbasic\n");
    2942:	00004517          	auipc	a0,0x4
    2946:	5de50513          	add	a0,a0,1502 # 6f20 <malloc+0xef4>
    294a:	00003097          	auipc	ra,0x3
    294e:	62a080e7          	jalr	1578(ra) # 5f74 <printf>
    exit(1);
    2952:	4505                	li	a0,1
    2954:	00003097          	auipc	ra,0x3
    2958:	2a8080e7          	jalr	680(ra) # 5bfc <exit>
    295c:	f426                	sd	s1,40(sp)
    295e:	f04a                	sd	s2,32(sp)
    2960:	e852                	sd	s4,16(sp)
      exit(0);
    2962:	4501                	li	a0,0
    2964:	00003097          	auipc	ra,0x3
    2968:	298080e7          	jalr	664(ra) # 5bfc <exit>
  wait(&xstatus);
    296c:	fcc40513          	add	a0,s0,-52
    2970:	00003097          	auipc	ra,0x3
    2974:	294080e7          	jalr	660(ra) # 5c04 <wait>
  if(xstatus == 1){
    2978:	fcc42703          	lw	a4,-52(s0)
    297c:	4785                	li	a5,1
    297e:	02f70063          	beq	a4,a5,299e <sbrkbasic+0xb4>
    2982:	f426                	sd	s1,40(sp)
    2984:	f04a                	sd	s2,32(sp)
    2986:	e852                	sd	s4,16(sp)
  a = sbrk(0);
    2988:	4501                	li	a0,0
    298a:	00003097          	auipc	ra,0x3
    298e:	2fa080e7          	jalr	762(ra) # 5c84 <sbrk>
    2992:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2994:	4901                	li	s2,0
    2996:	6a05                	lui	s4,0x1
    2998:	388a0a13          	add	s4,s4,904 # 1388 <badarg+0x3e>
    299c:	a01d                	j	29c2 <sbrkbasic+0xd8>
    299e:	f426                	sd	s1,40(sp)
    29a0:	f04a                	sd	s2,32(sp)
    29a2:	e852                	sd	s4,16(sp)
    printf("%s: too much memory allocated!\n", s);
    29a4:	85ce                	mv	a1,s3
    29a6:	00004517          	auipc	a0,0x4
    29aa:	59a50513          	add	a0,a0,1434 # 6f40 <malloc+0xf14>
    29ae:	00003097          	auipc	ra,0x3
    29b2:	5c6080e7          	jalr	1478(ra) # 5f74 <printf>
    exit(1);
    29b6:	4505                	li	a0,1
    29b8:	00003097          	auipc	ra,0x3
    29bc:	244080e7          	jalr	580(ra) # 5bfc <exit>
    29c0:	84be                	mv	s1,a5
    b = sbrk(1);
    29c2:	4505                	li	a0,1
    29c4:	00003097          	auipc	ra,0x3
    29c8:	2c0080e7          	jalr	704(ra) # 5c84 <sbrk>
    if(b != a){
    29cc:	04951c63          	bne	a0,s1,2a24 <sbrkbasic+0x13a>
    *b = 1;
    29d0:	4785                	li	a5,1
    29d2:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    29d6:	00148793          	add	a5,s1,1
  for(i = 0; i < 5000; i++){
    29da:	2905                	addw	s2,s2,1
    29dc:	ff4912e3          	bne	s2,s4,29c0 <sbrkbasic+0xd6>
  pid = fork();
    29e0:	00003097          	auipc	ra,0x3
    29e4:	214080e7          	jalr	532(ra) # 5bf4 <fork>
    29e8:	892a                	mv	s2,a0
  if(pid < 0){
    29ea:	04054e63          	bltz	a0,2a46 <sbrkbasic+0x15c>
  c = sbrk(1);
    29ee:	4505                	li	a0,1
    29f0:	00003097          	auipc	ra,0x3
    29f4:	294080e7          	jalr	660(ra) # 5c84 <sbrk>
  c = sbrk(1);
    29f8:	4505                	li	a0,1
    29fa:	00003097          	auipc	ra,0x3
    29fe:	28a080e7          	jalr	650(ra) # 5c84 <sbrk>
  if(c != a + 1){
    2a02:	0489                	add	s1,s1,2
    2a04:	04a48f63          	beq	s1,a0,2a62 <sbrkbasic+0x178>
    printf("%s: sbrk test failed post-fork\n", s);
    2a08:	85ce                	mv	a1,s3
    2a0a:	00004517          	auipc	a0,0x4
    2a0e:	59650513          	add	a0,a0,1430 # 6fa0 <malloc+0xf74>
    2a12:	00003097          	auipc	ra,0x3
    2a16:	562080e7          	jalr	1378(ra) # 5f74 <printf>
    exit(1);
    2a1a:	4505                	li	a0,1
    2a1c:	00003097          	auipc	ra,0x3
    2a20:	1e0080e7          	jalr	480(ra) # 5bfc <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    2a24:	872a                	mv	a4,a0
    2a26:	86a6                	mv	a3,s1
    2a28:	864a                	mv	a2,s2
    2a2a:	85ce                	mv	a1,s3
    2a2c:	00004517          	auipc	a0,0x4
    2a30:	53450513          	add	a0,a0,1332 # 6f60 <malloc+0xf34>
    2a34:	00003097          	auipc	ra,0x3
    2a38:	540080e7          	jalr	1344(ra) # 5f74 <printf>
      exit(1);
    2a3c:	4505                	li	a0,1
    2a3e:	00003097          	auipc	ra,0x3
    2a42:	1be080e7          	jalr	446(ra) # 5bfc <exit>
    printf("%s: sbrk test fork failed\n", s);
    2a46:	85ce                	mv	a1,s3
    2a48:	00004517          	auipc	a0,0x4
    2a4c:	53850513          	add	a0,a0,1336 # 6f80 <malloc+0xf54>
    2a50:	00003097          	auipc	ra,0x3
    2a54:	524080e7          	jalr	1316(ra) # 5f74 <printf>
    exit(1);
    2a58:	4505                	li	a0,1
    2a5a:	00003097          	auipc	ra,0x3
    2a5e:	1a2080e7          	jalr	418(ra) # 5bfc <exit>
  if(pid == 0)
    2a62:	00091763          	bnez	s2,2a70 <sbrkbasic+0x186>
    exit(0);
    2a66:	4501                	li	a0,0
    2a68:	00003097          	auipc	ra,0x3
    2a6c:	194080e7          	jalr	404(ra) # 5bfc <exit>
  wait(&xstatus);
    2a70:	fcc40513          	add	a0,s0,-52
    2a74:	00003097          	auipc	ra,0x3
    2a78:	190080e7          	jalr	400(ra) # 5c04 <wait>
  exit(xstatus);
    2a7c:	fcc42503          	lw	a0,-52(s0)
    2a80:	00003097          	auipc	ra,0x3
    2a84:	17c080e7          	jalr	380(ra) # 5bfc <exit>

0000000000002a88 <sbrkmuch>:
{
    2a88:	7179                	add	sp,sp,-48
    2a8a:	f406                	sd	ra,40(sp)
    2a8c:	f022                	sd	s0,32(sp)
    2a8e:	ec26                	sd	s1,24(sp)
    2a90:	e84a                	sd	s2,16(sp)
    2a92:	e44e                	sd	s3,8(sp)
    2a94:	e052                	sd	s4,0(sp)
    2a96:	1800                	add	s0,sp,48
    2a98:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2a9a:	4501                	li	a0,0
    2a9c:	00003097          	auipc	ra,0x3
    2aa0:	1e8080e7          	jalr	488(ra) # 5c84 <sbrk>
    2aa4:	892a                	mv	s2,a0
  a = sbrk(0);
    2aa6:	4501                	li	a0,0
    2aa8:	00003097          	auipc	ra,0x3
    2aac:	1dc080e7          	jalr	476(ra) # 5c84 <sbrk>
    2ab0:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2ab2:	06400537          	lui	a0,0x6400
    2ab6:	9d05                	subw	a0,a0,s1
    2ab8:	00003097          	auipc	ra,0x3
    2abc:	1cc080e7          	jalr	460(ra) # 5c84 <sbrk>
  if (p != a) {
    2ac0:	0ca49863          	bne	s1,a0,2b90 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2ac4:	4501                	li	a0,0
    2ac6:	00003097          	auipc	ra,0x3
    2aca:	1be080e7          	jalr	446(ra) # 5c84 <sbrk>
    2ace:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2ad0:	00a4f963          	bgeu	s1,a0,2ae2 <sbrkmuch+0x5a>
    *pp = 1;
    2ad4:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    2ad6:	6705                	lui	a4,0x1
    *pp = 1;
    2ad8:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2adc:	94ba                	add	s1,s1,a4
    2ade:	fef4ede3          	bltu	s1,a5,2ad8 <sbrkmuch+0x50>
  *lastaddr = 99;
    2ae2:	064007b7          	lui	a5,0x6400
    2ae6:	06300713          	li	a4,99
    2aea:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f0387>
  a = sbrk(0);
    2aee:	4501                	li	a0,0
    2af0:	00003097          	auipc	ra,0x3
    2af4:	194080e7          	jalr	404(ra) # 5c84 <sbrk>
    2af8:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2afa:	757d                	lui	a0,0xfffff
    2afc:	00003097          	auipc	ra,0x3
    2b00:	188080e7          	jalr	392(ra) # 5c84 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    2b04:	57fd                	li	a5,-1
    2b06:	0af50363          	beq	a0,a5,2bac <sbrkmuch+0x124>
  c = sbrk(0);
    2b0a:	4501                	li	a0,0
    2b0c:	00003097          	auipc	ra,0x3
    2b10:	178080e7          	jalr	376(ra) # 5c84 <sbrk>
  if(c != a - PGSIZE){
    2b14:	77fd                	lui	a5,0xfffff
    2b16:	97a6                	add	a5,a5,s1
    2b18:	0af51863          	bne	a0,a5,2bc8 <sbrkmuch+0x140>
  a = sbrk(0);
    2b1c:	4501                	li	a0,0
    2b1e:	00003097          	auipc	ra,0x3
    2b22:	166080e7          	jalr	358(ra) # 5c84 <sbrk>
    2b26:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2b28:	6505                	lui	a0,0x1
    2b2a:	00003097          	auipc	ra,0x3
    2b2e:	15a080e7          	jalr	346(ra) # 5c84 <sbrk>
    2b32:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2b34:	0aa49a63          	bne	s1,a0,2be8 <sbrkmuch+0x160>
    2b38:	4501                	li	a0,0
    2b3a:	00003097          	auipc	ra,0x3
    2b3e:	14a080e7          	jalr	330(ra) # 5c84 <sbrk>
    2b42:	6785                	lui	a5,0x1
    2b44:	97a6                	add	a5,a5,s1
    2b46:	0af51163          	bne	a0,a5,2be8 <sbrkmuch+0x160>
  if(*lastaddr == 99){
    2b4a:	064007b7          	lui	a5,0x6400
    2b4e:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f0387>
    2b52:	06300793          	li	a5,99
    2b56:	0af70963          	beq	a4,a5,2c08 <sbrkmuch+0x180>
  a = sbrk(0);
    2b5a:	4501                	li	a0,0
    2b5c:	00003097          	auipc	ra,0x3
    2b60:	128080e7          	jalr	296(ra) # 5c84 <sbrk>
    2b64:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2b66:	4501                	li	a0,0
    2b68:	00003097          	auipc	ra,0x3
    2b6c:	11c080e7          	jalr	284(ra) # 5c84 <sbrk>
    2b70:	40a9053b          	subw	a0,s2,a0
    2b74:	00003097          	auipc	ra,0x3
    2b78:	110080e7          	jalr	272(ra) # 5c84 <sbrk>
  if(c != a){
    2b7c:	0aa49463          	bne	s1,a0,2c24 <sbrkmuch+0x19c>
}
    2b80:	70a2                	ld	ra,40(sp)
    2b82:	7402                	ld	s0,32(sp)
    2b84:	64e2                	ld	s1,24(sp)
    2b86:	6942                	ld	s2,16(sp)
    2b88:	69a2                	ld	s3,8(sp)
    2b8a:	6a02                	ld	s4,0(sp)
    2b8c:	6145                	add	sp,sp,48
    2b8e:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2b90:	85ce                	mv	a1,s3
    2b92:	00004517          	auipc	a0,0x4
    2b96:	42e50513          	add	a0,a0,1070 # 6fc0 <malloc+0xf94>
    2b9a:	00003097          	auipc	ra,0x3
    2b9e:	3da080e7          	jalr	986(ra) # 5f74 <printf>
    exit(1);
    2ba2:	4505                	li	a0,1
    2ba4:	00003097          	auipc	ra,0x3
    2ba8:	058080e7          	jalr	88(ra) # 5bfc <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2bac:	85ce                	mv	a1,s3
    2bae:	00004517          	auipc	a0,0x4
    2bb2:	45a50513          	add	a0,a0,1114 # 7008 <malloc+0xfdc>
    2bb6:	00003097          	auipc	ra,0x3
    2bba:	3be080e7          	jalr	958(ra) # 5f74 <printf>
    exit(1);
    2bbe:	4505                	li	a0,1
    2bc0:	00003097          	auipc	ra,0x3
    2bc4:	03c080e7          	jalr	60(ra) # 5bfc <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2bc8:	86aa                	mv	a3,a0
    2bca:	8626                	mv	a2,s1
    2bcc:	85ce                	mv	a1,s3
    2bce:	00004517          	auipc	a0,0x4
    2bd2:	45a50513          	add	a0,a0,1114 # 7028 <malloc+0xffc>
    2bd6:	00003097          	auipc	ra,0x3
    2bda:	39e080e7          	jalr	926(ra) # 5f74 <printf>
    exit(1);
    2bde:	4505                	li	a0,1
    2be0:	00003097          	auipc	ra,0x3
    2be4:	01c080e7          	jalr	28(ra) # 5bfc <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2be8:	86d2                	mv	a3,s4
    2bea:	8626                	mv	a2,s1
    2bec:	85ce                	mv	a1,s3
    2bee:	00004517          	auipc	a0,0x4
    2bf2:	47a50513          	add	a0,a0,1146 # 7068 <malloc+0x103c>
    2bf6:	00003097          	auipc	ra,0x3
    2bfa:	37e080e7          	jalr	894(ra) # 5f74 <printf>
    exit(1);
    2bfe:	4505                	li	a0,1
    2c00:	00003097          	auipc	ra,0x3
    2c04:	ffc080e7          	jalr	-4(ra) # 5bfc <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2c08:	85ce                	mv	a1,s3
    2c0a:	00004517          	auipc	a0,0x4
    2c0e:	48e50513          	add	a0,a0,1166 # 7098 <malloc+0x106c>
    2c12:	00003097          	auipc	ra,0x3
    2c16:	362080e7          	jalr	866(ra) # 5f74 <printf>
    exit(1);
    2c1a:	4505                	li	a0,1
    2c1c:	00003097          	auipc	ra,0x3
    2c20:	fe0080e7          	jalr	-32(ra) # 5bfc <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2c24:	86aa                	mv	a3,a0
    2c26:	8626                	mv	a2,s1
    2c28:	85ce                	mv	a1,s3
    2c2a:	00004517          	auipc	a0,0x4
    2c2e:	4a650513          	add	a0,a0,1190 # 70d0 <malloc+0x10a4>
    2c32:	00003097          	auipc	ra,0x3
    2c36:	342080e7          	jalr	834(ra) # 5f74 <printf>
    exit(1);
    2c3a:	4505                	li	a0,1
    2c3c:	00003097          	auipc	ra,0x3
    2c40:	fc0080e7          	jalr	-64(ra) # 5bfc <exit>

0000000000002c44 <sbrkarg>:
{
    2c44:	7179                	add	sp,sp,-48
    2c46:	f406                	sd	ra,40(sp)
    2c48:	f022                	sd	s0,32(sp)
    2c4a:	ec26                	sd	s1,24(sp)
    2c4c:	e84a                	sd	s2,16(sp)
    2c4e:	e44e                	sd	s3,8(sp)
    2c50:	1800                	add	s0,sp,48
    2c52:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2c54:	6505                	lui	a0,0x1
    2c56:	00003097          	auipc	ra,0x3
    2c5a:	02e080e7          	jalr	46(ra) # 5c84 <sbrk>
    2c5e:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2c60:	20100593          	li	a1,513
    2c64:	00004517          	auipc	a0,0x4
    2c68:	49450513          	add	a0,a0,1172 # 70f8 <malloc+0x10cc>
    2c6c:	00003097          	auipc	ra,0x3
    2c70:	fd0080e7          	jalr	-48(ra) # 5c3c <open>
    2c74:	84aa                	mv	s1,a0
  unlink("sbrk");
    2c76:	00004517          	auipc	a0,0x4
    2c7a:	48250513          	add	a0,a0,1154 # 70f8 <malloc+0x10cc>
    2c7e:	00003097          	auipc	ra,0x3
    2c82:	fce080e7          	jalr	-50(ra) # 5c4c <unlink>
  if(fd < 0)  {
    2c86:	0404c163          	bltz	s1,2cc8 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2c8a:	6605                	lui	a2,0x1
    2c8c:	85ca                	mv	a1,s2
    2c8e:	8526                	mv	a0,s1
    2c90:	00003097          	auipc	ra,0x3
    2c94:	f8c080e7          	jalr	-116(ra) # 5c1c <write>
    2c98:	04054663          	bltz	a0,2ce4 <sbrkarg+0xa0>
  close(fd);
    2c9c:	8526                	mv	a0,s1
    2c9e:	00003097          	auipc	ra,0x3
    2ca2:	f86080e7          	jalr	-122(ra) # 5c24 <close>
  a = sbrk(PGSIZE);
    2ca6:	6505                	lui	a0,0x1
    2ca8:	00003097          	auipc	ra,0x3
    2cac:	fdc080e7          	jalr	-36(ra) # 5c84 <sbrk>
  if(pipe((int *) a) != 0){
    2cb0:	00003097          	auipc	ra,0x3
    2cb4:	f5c080e7          	jalr	-164(ra) # 5c0c <pipe>
    2cb8:	e521                	bnez	a0,2d00 <sbrkarg+0xbc>
}
    2cba:	70a2                	ld	ra,40(sp)
    2cbc:	7402                	ld	s0,32(sp)
    2cbe:	64e2                	ld	s1,24(sp)
    2cc0:	6942                	ld	s2,16(sp)
    2cc2:	69a2                	ld	s3,8(sp)
    2cc4:	6145                	add	sp,sp,48
    2cc6:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2cc8:	85ce                	mv	a1,s3
    2cca:	00004517          	auipc	a0,0x4
    2cce:	43650513          	add	a0,a0,1078 # 7100 <malloc+0x10d4>
    2cd2:	00003097          	auipc	ra,0x3
    2cd6:	2a2080e7          	jalr	674(ra) # 5f74 <printf>
    exit(1);
    2cda:	4505                	li	a0,1
    2cdc:	00003097          	auipc	ra,0x3
    2ce0:	f20080e7          	jalr	-224(ra) # 5bfc <exit>
    printf("%s: write sbrk failed\n", s);
    2ce4:	85ce                	mv	a1,s3
    2ce6:	00004517          	auipc	a0,0x4
    2cea:	43250513          	add	a0,a0,1074 # 7118 <malloc+0x10ec>
    2cee:	00003097          	auipc	ra,0x3
    2cf2:	286080e7          	jalr	646(ra) # 5f74 <printf>
    exit(1);
    2cf6:	4505                	li	a0,1
    2cf8:	00003097          	auipc	ra,0x3
    2cfc:	f04080e7          	jalr	-252(ra) # 5bfc <exit>
    printf("%s: pipe() failed\n", s);
    2d00:	85ce                	mv	a1,s3
    2d02:	00004517          	auipc	a0,0x4
    2d06:	df650513          	add	a0,a0,-522 # 6af8 <malloc+0xacc>
    2d0a:	00003097          	auipc	ra,0x3
    2d0e:	26a080e7          	jalr	618(ra) # 5f74 <printf>
    exit(1);
    2d12:	4505                	li	a0,1
    2d14:	00003097          	auipc	ra,0x3
    2d18:	ee8080e7          	jalr	-280(ra) # 5bfc <exit>

0000000000002d1c <argptest>:
{
    2d1c:	1101                	add	sp,sp,-32
    2d1e:	ec06                	sd	ra,24(sp)
    2d20:	e822                	sd	s0,16(sp)
    2d22:	e426                	sd	s1,8(sp)
    2d24:	e04a                	sd	s2,0(sp)
    2d26:	1000                	add	s0,sp,32
    2d28:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2d2a:	4581                	li	a1,0
    2d2c:	00004517          	auipc	a0,0x4
    2d30:	40450513          	add	a0,a0,1028 # 7130 <malloc+0x1104>
    2d34:	00003097          	auipc	ra,0x3
    2d38:	f08080e7          	jalr	-248(ra) # 5c3c <open>
  if (fd < 0) {
    2d3c:	02054b63          	bltz	a0,2d72 <argptest+0x56>
    2d40:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2d42:	4501                	li	a0,0
    2d44:	00003097          	auipc	ra,0x3
    2d48:	f40080e7          	jalr	-192(ra) # 5c84 <sbrk>
    2d4c:	567d                	li	a2,-1
    2d4e:	fff50593          	add	a1,a0,-1
    2d52:	8526                	mv	a0,s1
    2d54:	00003097          	auipc	ra,0x3
    2d58:	ec0080e7          	jalr	-320(ra) # 5c14 <read>
  close(fd);
    2d5c:	8526                	mv	a0,s1
    2d5e:	00003097          	auipc	ra,0x3
    2d62:	ec6080e7          	jalr	-314(ra) # 5c24 <close>
}
    2d66:	60e2                	ld	ra,24(sp)
    2d68:	6442                	ld	s0,16(sp)
    2d6a:	64a2                	ld	s1,8(sp)
    2d6c:	6902                	ld	s2,0(sp)
    2d6e:	6105                	add	sp,sp,32
    2d70:	8082                	ret
    printf("%s: open failed\n", s);
    2d72:	85ca                	mv	a1,s2
    2d74:	00004517          	auipc	a0,0x4
    2d78:	c9450513          	add	a0,a0,-876 # 6a08 <malloc+0x9dc>
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	1f8080e7          	jalr	504(ra) # 5f74 <printf>
    exit(1);
    2d84:	4505                	li	a0,1
    2d86:	00003097          	auipc	ra,0x3
    2d8a:	e76080e7          	jalr	-394(ra) # 5bfc <exit>

0000000000002d8e <sbrkbugs>:
{
    2d8e:	1141                	add	sp,sp,-16
    2d90:	e406                	sd	ra,8(sp)
    2d92:	e022                	sd	s0,0(sp)
    2d94:	0800                	add	s0,sp,16
  int pid = fork();
    2d96:	00003097          	auipc	ra,0x3
    2d9a:	e5e080e7          	jalr	-418(ra) # 5bf4 <fork>
  if(pid < 0){
    2d9e:	02054263          	bltz	a0,2dc2 <sbrkbugs+0x34>
  if(pid == 0){
    2da2:	ed0d                	bnez	a0,2ddc <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2da4:	00003097          	auipc	ra,0x3
    2da8:	ee0080e7          	jalr	-288(ra) # 5c84 <sbrk>
    sbrk(-sz);
    2dac:	40a0053b          	negw	a0,a0
    2db0:	00003097          	auipc	ra,0x3
    2db4:	ed4080e7          	jalr	-300(ra) # 5c84 <sbrk>
    exit(0);
    2db8:	4501                	li	a0,0
    2dba:	00003097          	auipc	ra,0x3
    2dbe:	e42080e7          	jalr	-446(ra) # 5bfc <exit>
    printf("fork failed\n");
    2dc2:	00004517          	auipc	a0,0x4
    2dc6:	03650513          	add	a0,a0,54 # 6df8 <malloc+0xdcc>
    2dca:	00003097          	auipc	ra,0x3
    2dce:	1aa080e7          	jalr	426(ra) # 5f74 <printf>
    exit(1);
    2dd2:	4505                	li	a0,1
    2dd4:	00003097          	auipc	ra,0x3
    2dd8:	e28080e7          	jalr	-472(ra) # 5bfc <exit>
  wait(0);
    2ddc:	4501                	li	a0,0
    2dde:	00003097          	auipc	ra,0x3
    2de2:	e26080e7          	jalr	-474(ra) # 5c04 <wait>
  pid = fork();
    2de6:	00003097          	auipc	ra,0x3
    2dea:	e0e080e7          	jalr	-498(ra) # 5bf4 <fork>
  if(pid < 0){
    2dee:	02054563          	bltz	a0,2e18 <sbrkbugs+0x8a>
  if(pid == 0){
    2df2:	e121                	bnez	a0,2e32 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2df4:	00003097          	auipc	ra,0x3
    2df8:	e90080e7          	jalr	-368(ra) # 5c84 <sbrk>
    sbrk(-(sz - 3500));
    2dfc:	6785                	lui	a5,0x1
    2dfe:	dac7879b          	addw	a5,a5,-596 # dac <unlinkread+0x6e>
    2e02:	40a7853b          	subw	a0,a5,a0
    2e06:	00003097          	auipc	ra,0x3
    2e0a:	e7e080e7          	jalr	-386(ra) # 5c84 <sbrk>
    exit(0);
    2e0e:	4501                	li	a0,0
    2e10:	00003097          	auipc	ra,0x3
    2e14:	dec080e7          	jalr	-532(ra) # 5bfc <exit>
    printf("fork failed\n");
    2e18:	00004517          	auipc	a0,0x4
    2e1c:	fe050513          	add	a0,a0,-32 # 6df8 <malloc+0xdcc>
    2e20:	00003097          	auipc	ra,0x3
    2e24:	154080e7          	jalr	340(ra) # 5f74 <printf>
    exit(1);
    2e28:	4505                	li	a0,1
    2e2a:	00003097          	auipc	ra,0x3
    2e2e:	dd2080e7          	jalr	-558(ra) # 5bfc <exit>
  wait(0);
    2e32:	4501                	li	a0,0
    2e34:	00003097          	auipc	ra,0x3
    2e38:	dd0080e7          	jalr	-560(ra) # 5c04 <wait>
  pid = fork();
    2e3c:	00003097          	auipc	ra,0x3
    2e40:	db8080e7          	jalr	-584(ra) # 5bf4 <fork>
  if(pid < 0){
    2e44:	02054a63          	bltz	a0,2e78 <sbrkbugs+0xea>
  if(pid == 0){
    2e48:	e529                	bnez	a0,2e92 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2e4a:	00003097          	auipc	ra,0x3
    2e4e:	e3a080e7          	jalr	-454(ra) # 5c84 <sbrk>
    2e52:	67ad                	lui	a5,0xb
    2e54:	8007879b          	addw	a5,a5,-2048 # a800 <uninit+0x298>
    2e58:	40a7853b          	subw	a0,a5,a0
    2e5c:	00003097          	auipc	ra,0x3
    2e60:	e28080e7          	jalr	-472(ra) # 5c84 <sbrk>
    sbrk(-10);
    2e64:	5559                	li	a0,-10
    2e66:	00003097          	auipc	ra,0x3
    2e6a:	e1e080e7          	jalr	-482(ra) # 5c84 <sbrk>
    exit(0);
    2e6e:	4501                	li	a0,0
    2e70:	00003097          	auipc	ra,0x3
    2e74:	d8c080e7          	jalr	-628(ra) # 5bfc <exit>
    printf("fork failed\n");
    2e78:	00004517          	auipc	a0,0x4
    2e7c:	f8050513          	add	a0,a0,-128 # 6df8 <malloc+0xdcc>
    2e80:	00003097          	auipc	ra,0x3
    2e84:	0f4080e7          	jalr	244(ra) # 5f74 <printf>
    exit(1);
    2e88:	4505                	li	a0,1
    2e8a:	00003097          	auipc	ra,0x3
    2e8e:	d72080e7          	jalr	-654(ra) # 5bfc <exit>
  wait(0);
    2e92:	4501                	li	a0,0
    2e94:	00003097          	auipc	ra,0x3
    2e98:	d70080e7          	jalr	-656(ra) # 5c04 <wait>
  exit(0);
    2e9c:	4501                	li	a0,0
    2e9e:	00003097          	auipc	ra,0x3
    2ea2:	d5e080e7          	jalr	-674(ra) # 5bfc <exit>

0000000000002ea6 <sbrklast>:
{
    2ea6:	7179                	add	sp,sp,-48
    2ea8:	f406                	sd	ra,40(sp)
    2eaa:	f022                	sd	s0,32(sp)
    2eac:	ec26                	sd	s1,24(sp)
    2eae:	e84a                	sd	s2,16(sp)
    2eb0:	e44e                	sd	s3,8(sp)
    2eb2:	e052                	sd	s4,0(sp)
    2eb4:	1800                	add	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    2eb6:	4501                	li	a0,0
    2eb8:	00003097          	auipc	ra,0x3
    2ebc:	dcc080e7          	jalr	-564(ra) # 5c84 <sbrk>
  if((top % 4096) != 0)
    2ec0:	03451793          	sll	a5,a0,0x34
    2ec4:	ebd9                	bnez	a5,2f5a <sbrklast+0xb4>
  sbrk(4096);
    2ec6:	6505                	lui	a0,0x1
    2ec8:	00003097          	auipc	ra,0x3
    2ecc:	dbc080e7          	jalr	-580(ra) # 5c84 <sbrk>
  sbrk(10);
    2ed0:	4529                	li	a0,10
    2ed2:	00003097          	auipc	ra,0x3
    2ed6:	db2080e7          	jalr	-590(ra) # 5c84 <sbrk>
  sbrk(-20);
    2eda:	5531                	li	a0,-20
    2edc:	00003097          	auipc	ra,0x3
    2ee0:	da8080e7          	jalr	-600(ra) # 5c84 <sbrk>
  top = (uint64) sbrk(0);
    2ee4:	4501                	li	a0,0
    2ee6:	00003097          	auipc	ra,0x3
    2eea:	d9e080e7          	jalr	-610(ra) # 5c84 <sbrk>
    2eee:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2ef0:	fc050913          	add	s2,a0,-64 # fc0 <linktest+0xcc>
  p[0] = 'x';
    2ef4:	07800a13          	li	s4,120
    2ef8:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2efc:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2f00:	20200593          	li	a1,514
    2f04:	854a                	mv	a0,s2
    2f06:	00003097          	auipc	ra,0x3
    2f0a:	d36080e7          	jalr	-714(ra) # 5c3c <open>
    2f0e:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2f10:	4605                	li	a2,1
    2f12:	85ca                	mv	a1,s2
    2f14:	00003097          	auipc	ra,0x3
    2f18:	d08080e7          	jalr	-760(ra) # 5c1c <write>
  close(fd);
    2f1c:	854e                	mv	a0,s3
    2f1e:	00003097          	auipc	ra,0x3
    2f22:	d06080e7          	jalr	-762(ra) # 5c24 <close>
  fd = open(p, O_RDWR);
    2f26:	4589                	li	a1,2
    2f28:	854a                	mv	a0,s2
    2f2a:	00003097          	auipc	ra,0x3
    2f2e:	d12080e7          	jalr	-750(ra) # 5c3c <open>
  p[0] = '\0';
    2f32:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    2f36:	4605                	li	a2,1
    2f38:	85ca                	mv	a1,s2
    2f3a:	00003097          	auipc	ra,0x3
    2f3e:	cda080e7          	jalr	-806(ra) # 5c14 <read>
  if(p[0] != 'x')
    2f42:	fc04c783          	lbu	a5,-64(s1)
    2f46:	03479463          	bne	a5,s4,2f6e <sbrklast+0xc8>
}
    2f4a:	70a2                	ld	ra,40(sp)
    2f4c:	7402                	ld	s0,32(sp)
    2f4e:	64e2                	ld	s1,24(sp)
    2f50:	6942                	ld	s2,16(sp)
    2f52:	69a2                	ld	s3,8(sp)
    2f54:	6a02                	ld	s4,0(sp)
    2f56:	6145                	add	sp,sp,48
    2f58:	8082                	ret
    sbrk(4096 - (top % 4096));
    2f5a:	0347d513          	srl	a0,a5,0x34
    2f5e:	6785                	lui	a5,0x1
    2f60:	40a7853b          	subw	a0,a5,a0
    2f64:	00003097          	auipc	ra,0x3
    2f68:	d20080e7          	jalr	-736(ra) # 5c84 <sbrk>
    2f6c:	bfa9                	j	2ec6 <sbrklast+0x20>
    exit(1);
    2f6e:	4505                	li	a0,1
    2f70:	00003097          	auipc	ra,0x3
    2f74:	c8c080e7          	jalr	-884(ra) # 5bfc <exit>

0000000000002f78 <sbrk8000>:
{
    2f78:	1141                	add	sp,sp,-16
    2f7a:	e406                	sd	ra,8(sp)
    2f7c:	e022                	sd	s0,0(sp)
    2f7e:	0800                	add	s0,sp,16
  sbrk(0x80000004);
    2f80:	80000537          	lui	a0,0x80000
    2f84:	0511                	add	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff038c>
    2f86:	00003097          	auipc	ra,0x3
    2f8a:	cfe080e7          	jalr	-770(ra) # 5c84 <sbrk>
  volatile char *top = sbrk(0);
    2f8e:	4501                	li	a0,0
    2f90:	00003097          	auipc	ra,0x3
    2f94:	cf4080e7          	jalr	-780(ra) # 5c84 <sbrk>
  *(top-1) = *(top-1) + 1;
    2f98:	fff54783          	lbu	a5,-1(a0)
    2f9c:	2785                	addw	a5,a5,1 # 1001 <linktest+0x10d>
    2f9e:	0ff7f793          	zext.b	a5,a5
    2fa2:	fef50fa3          	sb	a5,-1(a0)
}
    2fa6:	60a2                	ld	ra,8(sp)
    2fa8:	6402                	ld	s0,0(sp)
    2faa:	0141                	add	sp,sp,16
    2fac:	8082                	ret

0000000000002fae <execout>:
{
    2fae:	715d                	add	sp,sp,-80
    2fb0:	e486                	sd	ra,72(sp)
    2fb2:	e0a2                	sd	s0,64(sp)
    2fb4:	fc26                	sd	s1,56(sp)
    2fb6:	f84a                	sd	s2,48(sp)
    2fb8:	f44e                	sd	s3,40(sp)
    2fba:	f052                	sd	s4,32(sp)
    2fbc:	0880                	add	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2fbe:	4901                	li	s2,0
    2fc0:	49bd                	li	s3,15
    int pid = fork();
    2fc2:	00003097          	auipc	ra,0x3
    2fc6:	c32080e7          	jalr	-974(ra) # 5bf4 <fork>
    2fca:	84aa                	mv	s1,a0
    if(pid < 0){
    2fcc:	02054063          	bltz	a0,2fec <execout+0x3e>
    } else if(pid == 0){
    2fd0:	c91d                	beqz	a0,3006 <execout+0x58>
      wait((int*)0);
    2fd2:	4501                	li	a0,0
    2fd4:	00003097          	auipc	ra,0x3
    2fd8:	c30080e7          	jalr	-976(ra) # 5c04 <wait>
  for(int avail = 0; avail < 15; avail++){
    2fdc:	2905                	addw	s2,s2,1
    2fde:	ff3912e3          	bne	s2,s3,2fc2 <execout+0x14>
  exit(0);
    2fe2:	4501                	li	a0,0
    2fe4:	00003097          	auipc	ra,0x3
    2fe8:	c18080e7          	jalr	-1000(ra) # 5bfc <exit>
      printf("fork failed\n");
    2fec:	00004517          	auipc	a0,0x4
    2ff0:	e0c50513          	add	a0,a0,-500 # 6df8 <malloc+0xdcc>
    2ff4:	00003097          	auipc	ra,0x3
    2ff8:	f80080e7          	jalr	-128(ra) # 5f74 <printf>
      exit(1);
    2ffc:	4505                	li	a0,1
    2ffe:	00003097          	auipc	ra,0x3
    3002:	bfe080e7          	jalr	-1026(ra) # 5bfc <exit>
        if(a == 0xffffffffffffffffLL)
    3006:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    3008:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    300a:	6505                	lui	a0,0x1
    300c:	00003097          	auipc	ra,0x3
    3010:	c78080e7          	jalr	-904(ra) # 5c84 <sbrk>
        if(a == 0xffffffffffffffffLL)
    3014:	01350763          	beq	a0,s3,3022 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    3018:	6785                	lui	a5,0x1
    301a:	97aa                	add	a5,a5,a0
    301c:	ff478fa3          	sb	s4,-1(a5) # fff <linktest+0x10b>
      while(1){
    3020:	b7ed                	j	300a <execout+0x5c>
      for(int i = 0; i < avail; i++)
    3022:	01205a63          	blez	s2,3036 <execout+0x88>
        sbrk(-4096);
    3026:	757d                	lui	a0,0xfffff
    3028:	00003097          	auipc	ra,0x3
    302c:	c5c080e7          	jalr	-932(ra) # 5c84 <sbrk>
      for(int i = 0; i < avail; i++)
    3030:	2485                	addw	s1,s1,1
    3032:	ff249ae3          	bne	s1,s2,3026 <execout+0x78>
      close(1);
    3036:	4505                	li	a0,1
    3038:	00003097          	auipc	ra,0x3
    303c:	bec080e7          	jalr	-1044(ra) # 5c24 <close>
      char *args[] = { "echo", "x", 0 };
    3040:	00003517          	auipc	a0,0x3
    3044:	12850513          	add	a0,a0,296 # 6168 <malloc+0x13c>
    3048:	faa43c23          	sd	a0,-72(s0)
    304c:	00003797          	auipc	a5,0x3
    3050:	18c78793          	add	a5,a5,396 # 61d8 <malloc+0x1ac>
    3054:	fcf43023          	sd	a5,-64(s0)
    3058:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    305c:	fb840593          	add	a1,s0,-72
    3060:	00003097          	auipc	ra,0x3
    3064:	bd4080e7          	jalr	-1068(ra) # 5c34 <exec>
      exit(0);
    3068:	4501                	li	a0,0
    306a:	00003097          	auipc	ra,0x3
    306e:	b92080e7          	jalr	-1134(ra) # 5bfc <exit>

0000000000003072 <fourteen>:
{
    3072:	1101                	add	sp,sp,-32
    3074:	ec06                	sd	ra,24(sp)
    3076:	e822                	sd	s0,16(sp)
    3078:	e426                	sd	s1,8(sp)
    307a:	1000                	add	s0,sp,32
    307c:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    307e:	00004517          	auipc	a0,0x4
    3082:	28a50513          	add	a0,a0,650 # 7308 <malloc+0x12dc>
    3086:	00003097          	auipc	ra,0x3
    308a:	bde080e7          	jalr	-1058(ra) # 5c64 <mkdir>
    308e:	e165                	bnez	a0,316e <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    3090:	00004517          	auipc	a0,0x4
    3094:	0d050513          	add	a0,a0,208 # 7160 <malloc+0x1134>
    3098:	00003097          	auipc	ra,0x3
    309c:	bcc080e7          	jalr	-1076(ra) # 5c64 <mkdir>
    30a0:	e56d                	bnez	a0,318a <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    30a2:	20000593          	li	a1,512
    30a6:	00004517          	auipc	a0,0x4
    30aa:	11250513          	add	a0,a0,274 # 71b8 <malloc+0x118c>
    30ae:	00003097          	auipc	ra,0x3
    30b2:	b8e080e7          	jalr	-1138(ra) # 5c3c <open>
  if(fd < 0){
    30b6:	0e054863          	bltz	a0,31a6 <fourteen+0x134>
  close(fd);
    30ba:	00003097          	auipc	ra,0x3
    30be:	b6a080e7          	jalr	-1174(ra) # 5c24 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    30c2:	4581                	li	a1,0
    30c4:	00004517          	auipc	a0,0x4
    30c8:	16c50513          	add	a0,a0,364 # 7230 <malloc+0x1204>
    30cc:	00003097          	auipc	ra,0x3
    30d0:	b70080e7          	jalr	-1168(ra) # 5c3c <open>
  if(fd < 0){
    30d4:	0e054763          	bltz	a0,31c2 <fourteen+0x150>
  close(fd);
    30d8:	00003097          	auipc	ra,0x3
    30dc:	b4c080e7          	jalr	-1204(ra) # 5c24 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    30e0:	00004517          	auipc	a0,0x4
    30e4:	1c050513          	add	a0,a0,448 # 72a0 <malloc+0x1274>
    30e8:	00003097          	auipc	ra,0x3
    30ec:	b7c080e7          	jalr	-1156(ra) # 5c64 <mkdir>
    30f0:	c57d                	beqz	a0,31de <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    30f2:	00004517          	auipc	a0,0x4
    30f6:	20650513          	add	a0,a0,518 # 72f8 <malloc+0x12cc>
    30fa:	00003097          	auipc	ra,0x3
    30fe:	b6a080e7          	jalr	-1174(ra) # 5c64 <mkdir>
    3102:	cd65                	beqz	a0,31fa <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    3104:	00004517          	auipc	a0,0x4
    3108:	1f450513          	add	a0,a0,500 # 72f8 <malloc+0x12cc>
    310c:	00003097          	auipc	ra,0x3
    3110:	b40080e7          	jalr	-1216(ra) # 5c4c <unlink>
  unlink("12345678901234/12345678901234");
    3114:	00004517          	auipc	a0,0x4
    3118:	18c50513          	add	a0,a0,396 # 72a0 <malloc+0x1274>
    311c:	00003097          	auipc	ra,0x3
    3120:	b30080e7          	jalr	-1232(ra) # 5c4c <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    3124:	00004517          	auipc	a0,0x4
    3128:	10c50513          	add	a0,a0,268 # 7230 <malloc+0x1204>
    312c:	00003097          	auipc	ra,0x3
    3130:	b20080e7          	jalr	-1248(ra) # 5c4c <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    3134:	00004517          	auipc	a0,0x4
    3138:	08450513          	add	a0,a0,132 # 71b8 <malloc+0x118c>
    313c:	00003097          	auipc	ra,0x3
    3140:	b10080e7          	jalr	-1264(ra) # 5c4c <unlink>
  unlink("12345678901234/123456789012345");
    3144:	00004517          	auipc	a0,0x4
    3148:	01c50513          	add	a0,a0,28 # 7160 <malloc+0x1134>
    314c:	00003097          	auipc	ra,0x3
    3150:	b00080e7          	jalr	-1280(ra) # 5c4c <unlink>
  unlink("12345678901234");
    3154:	00004517          	auipc	a0,0x4
    3158:	1b450513          	add	a0,a0,436 # 7308 <malloc+0x12dc>
    315c:	00003097          	auipc	ra,0x3
    3160:	af0080e7          	jalr	-1296(ra) # 5c4c <unlink>
}
    3164:	60e2                	ld	ra,24(sp)
    3166:	6442                	ld	s0,16(sp)
    3168:	64a2                	ld	s1,8(sp)
    316a:	6105                	add	sp,sp,32
    316c:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    316e:	85a6                	mv	a1,s1
    3170:	00004517          	auipc	a0,0x4
    3174:	fc850513          	add	a0,a0,-56 # 7138 <malloc+0x110c>
    3178:	00003097          	auipc	ra,0x3
    317c:	dfc080e7          	jalr	-516(ra) # 5f74 <printf>
    exit(1);
    3180:	4505                	li	a0,1
    3182:	00003097          	auipc	ra,0x3
    3186:	a7a080e7          	jalr	-1414(ra) # 5bfc <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    318a:	85a6                	mv	a1,s1
    318c:	00004517          	auipc	a0,0x4
    3190:	ff450513          	add	a0,a0,-12 # 7180 <malloc+0x1154>
    3194:	00003097          	auipc	ra,0x3
    3198:	de0080e7          	jalr	-544(ra) # 5f74 <printf>
    exit(1);
    319c:	4505                	li	a0,1
    319e:	00003097          	auipc	ra,0x3
    31a2:	a5e080e7          	jalr	-1442(ra) # 5bfc <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    31a6:	85a6                	mv	a1,s1
    31a8:	00004517          	auipc	a0,0x4
    31ac:	04050513          	add	a0,a0,64 # 71e8 <malloc+0x11bc>
    31b0:	00003097          	auipc	ra,0x3
    31b4:	dc4080e7          	jalr	-572(ra) # 5f74 <printf>
    exit(1);
    31b8:	4505                	li	a0,1
    31ba:	00003097          	auipc	ra,0x3
    31be:	a42080e7          	jalr	-1470(ra) # 5bfc <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    31c2:	85a6                	mv	a1,s1
    31c4:	00004517          	auipc	a0,0x4
    31c8:	09c50513          	add	a0,a0,156 # 7260 <malloc+0x1234>
    31cc:	00003097          	auipc	ra,0x3
    31d0:	da8080e7          	jalr	-600(ra) # 5f74 <printf>
    exit(1);
    31d4:	4505                	li	a0,1
    31d6:	00003097          	auipc	ra,0x3
    31da:	a26080e7          	jalr	-1498(ra) # 5bfc <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    31de:	85a6                	mv	a1,s1
    31e0:	00004517          	auipc	a0,0x4
    31e4:	0e050513          	add	a0,a0,224 # 72c0 <malloc+0x1294>
    31e8:	00003097          	auipc	ra,0x3
    31ec:	d8c080e7          	jalr	-628(ra) # 5f74 <printf>
    exit(1);
    31f0:	4505                	li	a0,1
    31f2:	00003097          	auipc	ra,0x3
    31f6:	a0a080e7          	jalr	-1526(ra) # 5bfc <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    31fa:	85a6                	mv	a1,s1
    31fc:	00004517          	auipc	a0,0x4
    3200:	11c50513          	add	a0,a0,284 # 7318 <malloc+0x12ec>
    3204:	00003097          	auipc	ra,0x3
    3208:	d70080e7          	jalr	-656(ra) # 5f74 <printf>
    exit(1);
    320c:	4505                	li	a0,1
    320e:	00003097          	auipc	ra,0x3
    3212:	9ee080e7          	jalr	-1554(ra) # 5bfc <exit>

0000000000003216 <diskfull>:
{
    3216:	b9010113          	add	sp,sp,-1136
    321a:	46113423          	sd	ra,1128(sp)
    321e:	46813023          	sd	s0,1120(sp)
    3222:	44913c23          	sd	s1,1112(sp)
    3226:	45213823          	sd	s2,1104(sp)
    322a:	45313423          	sd	s3,1096(sp)
    322e:	45413023          	sd	s4,1088(sp)
    3232:	43513c23          	sd	s5,1080(sp)
    3236:	43613823          	sd	s6,1072(sp)
    323a:	43713423          	sd	s7,1064(sp)
    323e:	43813023          	sd	s8,1056(sp)
    3242:	47010413          	add	s0,sp,1136
    3246:	8c2a                	mv	s8,a0
  unlink("diskfulldir");
    3248:	00004517          	auipc	a0,0x4
    324c:	10850513          	add	a0,a0,264 # 7350 <malloc+0x1324>
    3250:	00003097          	auipc	ra,0x3
    3254:	9fc080e7          	jalr	-1540(ra) # 5c4c <unlink>
  for(fi = 0; done == 0; fi++){
    3258:	4a01                	li	s4,0
    name[0] = 'b';
    325a:	06200b13          	li	s6,98
    name[1] = 'i';
    325e:	06900a93          	li	s5,105
    name[2] = 'g';
    3262:	06700993          	li	s3,103
    3266:	10c00b93          	li	s7,268
    326a:	aabd                	j	33e8 <diskfull+0x1d2>
      printf("%s: could not create file %s\n", s, name);
    326c:	b9040613          	add	a2,s0,-1136
    3270:	85e2                	mv	a1,s8
    3272:	00004517          	auipc	a0,0x4
    3276:	0ee50513          	add	a0,a0,238 # 7360 <malloc+0x1334>
    327a:	00003097          	auipc	ra,0x3
    327e:	cfa080e7          	jalr	-774(ra) # 5f74 <printf>
      break;
    3282:	a821                	j	329a <diskfull+0x84>
        close(fd);
    3284:	854a                	mv	a0,s2
    3286:	00003097          	auipc	ra,0x3
    328a:	99e080e7          	jalr	-1634(ra) # 5c24 <close>
    close(fd);
    328e:	854a                	mv	a0,s2
    3290:	00003097          	auipc	ra,0x3
    3294:	994080e7          	jalr	-1644(ra) # 5c24 <close>
  for(fi = 0; done == 0; fi++){
    3298:	2a05                	addw	s4,s4,1
  for(int i = 0; i < nzz; i++){
    329a:	4481                	li	s1,0
    name[0] = 'z';
    329c:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    32a0:	08000993          	li	s3,128
    name[0] = 'z';
    32a4:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    32a8:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    32ac:	41f4d71b          	sraw	a4,s1,0x1f
    32b0:	01b7571b          	srlw	a4,a4,0x1b
    32b4:	009707bb          	addw	a5,a4,s1
    32b8:	4057d69b          	sraw	a3,a5,0x5
    32bc:	0306869b          	addw	a3,a3,48
    32c0:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    32c4:	8bfd                	and	a5,a5,31
    32c6:	9f99                	subw	a5,a5,a4
    32c8:	0307879b          	addw	a5,a5,48
    32cc:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    32d0:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    32d4:	bb040513          	add	a0,s0,-1104
    32d8:	00003097          	auipc	ra,0x3
    32dc:	974080e7          	jalr	-1676(ra) # 5c4c <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    32e0:	60200593          	li	a1,1538
    32e4:	bb040513          	add	a0,s0,-1104
    32e8:	00003097          	auipc	ra,0x3
    32ec:	954080e7          	jalr	-1708(ra) # 5c3c <open>
    if(fd < 0)
    32f0:	00054963          	bltz	a0,3302 <diskfull+0xec>
    close(fd);
    32f4:	00003097          	auipc	ra,0x3
    32f8:	930080e7          	jalr	-1744(ra) # 5c24 <close>
  for(int i = 0; i < nzz; i++){
    32fc:	2485                	addw	s1,s1,1
    32fe:	fb3493e3          	bne	s1,s3,32a4 <diskfull+0x8e>
  if(mkdir("diskfulldir") == 0)
    3302:	00004517          	auipc	a0,0x4
    3306:	04e50513          	add	a0,a0,78 # 7350 <malloc+0x1324>
    330a:	00003097          	auipc	ra,0x3
    330e:	95a080e7          	jalr	-1702(ra) # 5c64 <mkdir>
    3312:	12050963          	beqz	a0,3444 <diskfull+0x22e>
  unlink("diskfulldir");
    3316:	00004517          	auipc	a0,0x4
    331a:	03a50513          	add	a0,a0,58 # 7350 <malloc+0x1324>
    331e:	00003097          	auipc	ra,0x3
    3322:	92e080e7          	jalr	-1746(ra) # 5c4c <unlink>
  for(int i = 0; i < nzz; i++){
    3326:	4481                	li	s1,0
    name[0] = 'z';
    3328:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    332c:	08000993          	li	s3,128
    name[0] = 'z';
    3330:	bb240823          	sb	s2,-1104(s0)
    name[1] = 'z';
    3334:	bb2408a3          	sb	s2,-1103(s0)
    name[2] = '0' + (i / 32);
    3338:	41f4d71b          	sraw	a4,s1,0x1f
    333c:	01b7571b          	srlw	a4,a4,0x1b
    3340:	009707bb          	addw	a5,a4,s1
    3344:	4057d69b          	sraw	a3,a5,0x5
    3348:	0306869b          	addw	a3,a3,48
    334c:	bad40923          	sb	a3,-1102(s0)
    name[3] = '0' + (i % 32);
    3350:	8bfd                	and	a5,a5,31
    3352:	9f99                	subw	a5,a5,a4
    3354:	0307879b          	addw	a5,a5,48
    3358:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    335c:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    3360:	bb040513          	add	a0,s0,-1104
    3364:	00003097          	auipc	ra,0x3
    3368:	8e8080e7          	jalr	-1816(ra) # 5c4c <unlink>
  for(int i = 0; i < nzz; i++){
    336c:	2485                	addw	s1,s1,1
    336e:	fd3491e3          	bne	s1,s3,3330 <diskfull+0x11a>
  for(int i = 0; i < fi; i++){
    3372:	03405e63          	blez	s4,33ae <diskfull+0x198>
    3376:	4481                	li	s1,0
    name[0] = 'b';
    3378:	06200a93          	li	s5,98
    name[1] = 'i';
    337c:	06900993          	li	s3,105
    name[2] = 'g';
    3380:	06700913          	li	s2,103
    name[0] = 'b';
    3384:	bb540823          	sb	s5,-1104(s0)
    name[1] = 'i';
    3388:	bb3408a3          	sb	s3,-1103(s0)
    name[2] = 'g';
    338c:	bb240923          	sb	s2,-1102(s0)
    name[3] = '0' + i;
    3390:	0304879b          	addw	a5,s1,48
    3394:	baf409a3          	sb	a5,-1101(s0)
    name[4] = '\0';
    3398:	ba040a23          	sb	zero,-1100(s0)
    unlink(name);
    339c:	bb040513          	add	a0,s0,-1104
    33a0:	00003097          	auipc	ra,0x3
    33a4:	8ac080e7          	jalr	-1876(ra) # 5c4c <unlink>
  for(int i = 0; i < fi; i++){
    33a8:	2485                	addw	s1,s1,1
    33aa:	fd449de3          	bne	s1,s4,3384 <diskfull+0x16e>
}
    33ae:	46813083          	ld	ra,1128(sp)
    33b2:	46013403          	ld	s0,1120(sp)
    33b6:	45813483          	ld	s1,1112(sp)
    33ba:	45013903          	ld	s2,1104(sp)
    33be:	44813983          	ld	s3,1096(sp)
    33c2:	44013a03          	ld	s4,1088(sp)
    33c6:	43813a83          	ld	s5,1080(sp)
    33ca:	43013b03          	ld	s6,1072(sp)
    33ce:	42813b83          	ld	s7,1064(sp)
    33d2:	42013c03          	ld	s8,1056(sp)
    33d6:	47010113          	add	sp,sp,1136
    33da:	8082                	ret
    close(fd);
    33dc:	854a                	mv	a0,s2
    33de:	00003097          	auipc	ra,0x3
    33e2:	846080e7          	jalr	-1978(ra) # 5c24 <close>
  for(fi = 0; done == 0; fi++){
    33e6:	2a05                	addw	s4,s4,1
    name[0] = 'b';
    33e8:	b9640823          	sb	s6,-1136(s0)
    name[1] = 'i';
    33ec:	b95408a3          	sb	s5,-1135(s0)
    name[2] = 'g';
    33f0:	b9340923          	sb	s3,-1134(s0)
    name[3] = '0' + fi;
    33f4:	030a079b          	addw	a5,s4,48
    33f8:	b8f409a3          	sb	a5,-1133(s0)
    name[4] = '\0';
    33fc:	b8040a23          	sb	zero,-1132(s0)
    unlink(name);
    3400:	b9040513          	add	a0,s0,-1136
    3404:	00003097          	auipc	ra,0x3
    3408:	848080e7          	jalr	-1976(ra) # 5c4c <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    340c:	60200593          	li	a1,1538
    3410:	b9040513          	add	a0,s0,-1136
    3414:	00003097          	auipc	ra,0x3
    3418:	828080e7          	jalr	-2008(ra) # 5c3c <open>
    341c:	892a                	mv	s2,a0
    if(fd < 0){
    341e:	e40547e3          	bltz	a0,326c <diskfull+0x56>
    3422:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    3424:	40000613          	li	a2,1024
    3428:	bb040593          	add	a1,s0,-1104
    342c:	854a                	mv	a0,s2
    342e:	00002097          	auipc	ra,0x2
    3432:	7ee080e7          	jalr	2030(ra) # 5c1c <write>
    3436:	40000793          	li	a5,1024
    343a:	e4f515e3          	bne	a0,a5,3284 <diskfull+0x6e>
    for(int i = 0; i < MAXFILE; i++){
    343e:	34fd                	addw	s1,s1,-1
    3440:	f0f5                	bnez	s1,3424 <diskfull+0x20e>
    3442:	bf69                	j	33dc <diskfull+0x1c6>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n");
    3444:	00004517          	auipc	a0,0x4
    3448:	f3c50513          	add	a0,a0,-196 # 7380 <malloc+0x1354>
    344c:	00003097          	auipc	ra,0x3
    3450:	b28080e7          	jalr	-1240(ra) # 5f74 <printf>
    3454:	b5c9                	j	3316 <diskfull+0x100>

0000000000003456 <iputtest>:
{
    3456:	1101                	add	sp,sp,-32
    3458:	ec06                	sd	ra,24(sp)
    345a:	e822                	sd	s0,16(sp)
    345c:	e426                	sd	s1,8(sp)
    345e:	1000                	add	s0,sp,32
    3460:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    3462:	00004517          	auipc	a0,0x4
    3466:	f4e50513          	add	a0,a0,-178 # 73b0 <malloc+0x1384>
    346a:	00002097          	auipc	ra,0x2
    346e:	7fa080e7          	jalr	2042(ra) # 5c64 <mkdir>
    3472:	04054563          	bltz	a0,34bc <iputtest+0x66>
  if(chdir("iputdir") < 0){
    3476:	00004517          	auipc	a0,0x4
    347a:	f3a50513          	add	a0,a0,-198 # 73b0 <malloc+0x1384>
    347e:	00002097          	auipc	ra,0x2
    3482:	7ee080e7          	jalr	2030(ra) # 5c6c <chdir>
    3486:	04054963          	bltz	a0,34d8 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    348a:	00004517          	auipc	a0,0x4
    348e:	f6650513          	add	a0,a0,-154 # 73f0 <malloc+0x13c4>
    3492:	00002097          	auipc	ra,0x2
    3496:	7ba080e7          	jalr	1978(ra) # 5c4c <unlink>
    349a:	04054d63          	bltz	a0,34f4 <iputtest+0x9e>
  if(chdir("/") < 0){
    349e:	00004517          	auipc	a0,0x4
    34a2:	f8250513          	add	a0,a0,-126 # 7420 <malloc+0x13f4>
    34a6:	00002097          	auipc	ra,0x2
    34aa:	7c6080e7          	jalr	1990(ra) # 5c6c <chdir>
    34ae:	06054163          	bltz	a0,3510 <iputtest+0xba>
}
    34b2:	60e2                	ld	ra,24(sp)
    34b4:	6442                	ld	s0,16(sp)
    34b6:	64a2                	ld	s1,8(sp)
    34b8:	6105                	add	sp,sp,32
    34ba:	8082                	ret
    printf("%s: mkdir failed\n", s);
    34bc:	85a6                	mv	a1,s1
    34be:	00004517          	auipc	a0,0x4
    34c2:	efa50513          	add	a0,a0,-262 # 73b8 <malloc+0x138c>
    34c6:	00003097          	auipc	ra,0x3
    34ca:	aae080e7          	jalr	-1362(ra) # 5f74 <printf>
    exit(1);
    34ce:	4505                	li	a0,1
    34d0:	00002097          	auipc	ra,0x2
    34d4:	72c080e7          	jalr	1836(ra) # 5bfc <exit>
    printf("%s: chdir iputdir failed\n", s);
    34d8:	85a6                	mv	a1,s1
    34da:	00004517          	auipc	a0,0x4
    34de:	ef650513          	add	a0,a0,-266 # 73d0 <malloc+0x13a4>
    34e2:	00003097          	auipc	ra,0x3
    34e6:	a92080e7          	jalr	-1390(ra) # 5f74 <printf>
    exit(1);
    34ea:	4505                	li	a0,1
    34ec:	00002097          	auipc	ra,0x2
    34f0:	710080e7          	jalr	1808(ra) # 5bfc <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    34f4:	85a6                	mv	a1,s1
    34f6:	00004517          	auipc	a0,0x4
    34fa:	f0a50513          	add	a0,a0,-246 # 7400 <malloc+0x13d4>
    34fe:	00003097          	auipc	ra,0x3
    3502:	a76080e7          	jalr	-1418(ra) # 5f74 <printf>
    exit(1);
    3506:	4505                	li	a0,1
    3508:	00002097          	auipc	ra,0x2
    350c:	6f4080e7          	jalr	1780(ra) # 5bfc <exit>
    printf("%s: chdir / failed\n", s);
    3510:	85a6                	mv	a1,s1
    3512:	00004517          	auipc	a0,0x4
    3516:	f1650513          	add	a0,a0,-234 # 7428 <malloc+0x13fc>
    351a:	00003097          	auipc	ra,0x3
    351e:	a5a080e7          	jalr	-1446(ra) # 5f74 <printf>
    exit(1);
    3522:	4505                	li	a0,1
    3524:	00002097          	auipc	ra,0x2
    3528:	6d8080e7          	jalr	1752(ra) # 5bfc <exit>

000000000000352c <exitiputtest>:
{
    352c:	7179                	add	sp,sp,-48
    352e:	f406                	sd	ra,40(sp)
    3530:	f022                	sd	s0,32(sp)
    3532:	ec26                	sd	s1,24(sp)
    3534:	1800                	add	s0,sp,48
    3536:	84aa                	mv	s1,a0
  pid = fork();
    3538:	00002097          	auipc	ra,0x2
    353c:	6bc080e7          	jalr	1724(ra) # 5bf4 <fork>
  if(pid < 0){
    3540:	04054663          	bltz	a0,358c <exitiputtest+0x60>
  if(pid == 0){
    3544:	ed45                	bnez	a0,35fc <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    3546:	00004517          	auipc	a0,0x4
    354a:	e6a50513          	add	a0,a0,-406 # 73b0 <malloc+0x1384>
    354e:	00002097          	auipc	ra,0x2
    3552:	716080e7          	jalr	1814(ra) # 5c64 <mkdir>
    3556:	04054963          	bltz	a0,35a8 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    355a:	00004517          	auipc	a0,0x4
    355e:	e5650513          	add	a0,a0,-426 # 73b0 <malloc+0x1384>
    3562:	00002097          	auipc	ra,0x2
    3566:	70a080e7          	jalr	1802(ra) # 5c6c <chdir>
    356a:	04054d63          	bltz	a0,35c4 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    356e:	00004517          	auipc	a0,0x4
    3572:	e8250513          	add	a0,a0,-382 # 73f0 <malloc+0x13c4>
    3576:	00002097          	auipc	ra,0x2
    357a:	6d6080e7          	jalr	1750(ra) # 5c4c <unlink>
    357e:	06054163          	bltz	a0,35e0 <exitiputtest+0xb4>
    exit(0);
    3582:	4501                	li	a0,0
    3584:	00002097          	auipc	ra,0x2
    3588:	678080e7          	jalr	1656(ra) # 5bfc <exit>
    printf("%s: fork failed\n", s);
    358c:	85a6                	mv	a1,s1
    358e:	00003517          	auipc	a0,0x3
    3592:	46250513          	add	a0,a0,1122 # 69f0 <malloc+0x9c4>
    3596:	00003097          	auipc	ra,0x3
    359a:	9de080e7          	jalr	-1570(ra) # 5f74 <printf>
    exit(1);
    359e:	4505                	li	a0,1
    35a0:	00002097          	auipc	ra,0x2
    35a4:	65c080e7          	jalr	1628(ra) # 5bfc <exit>
      printf("%s: mkdir failed\n", s);
    35a8:	85a6                	mv	a1,s1
    35aa:	00004517          	auipc	a0,0x4
    35ae:	e0e50513          	add	a0,a0,-498 # 73b8 <malloc+0x138c>
    35b2:	00003097          	auipc	ra,0x3
    35b6:	9c2080e7          	jalr	-1598(ra) # 5f74 <printf>
      exit(1);
    35ba:	4505                	li	a0,1
    35bc:	00002097          	auipc	ra,0x2
    35c0:	640080e7          	jalr	1600(ra) # 5bfc <exit>
      printf("%s: child chdir failed\n", s);
    35c4:	85a6                	mv	a1,s1
    35c6:	00004517          	auipc	a0,0x4
    35ca:	e7a50513          	add	a0,a0,-390 # 7440 <malloc+0x1414>
    35ce:	00003097          	auipc	ra,0x3
    35d2:	9a6080e7          	jalr	-1626(ra) # 5f74 <printf>
      exit(1);
    35d6:	4505                	li	a0,1
    35d8:	00002097          	auipc	ra,0x2
    35dc:	624080e7          	jalr	1572(ra) # 5bfc <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    35e0:	85a6                	mv	a1,s1
    35e2:	00004517          	auipc	a0,0x4
    35e6:	e1e50513          	add	a0,a0,-482 # 7400 <malloc+0x13d4>
    35ea:	00003097          	auipc	ra,0x3
    35ee:	98a080e7          	jalr	-1654(ra) # 5f74 <printf>
      exit(1);
    35f2:	4505                	li	a0,1
    35f4:	00002097          	auipc	ra,0x2
    35f8:	608080e7          	jalr	1544(ra) # 5bfc <exit>
  wait(&xstatus);
    35fc:	fdc40513          	add	a0,s0,-36
    3600:	00002097          	auipc	ra,0x2
    3604:	604080e7          	jalr	1540(ra) # 5c04 <wait>
  exit(xstatus);
    3608:	fdc42503          	lw	a0,-36(s0)
    360c:	00002097          	auipc	ra,0x2
    3610:	5f0080e7          	jalr	1520(ra) # 5bfc <exit>

0000000000003614 <dirtest>:
{
    3614:	1101                	add	sp,sp,-32
    3616:	ec06                	sd	ra,24(sp)
    3618:	e822                	sd	s0,16(sp)
    361a:	e426                	sd	s1,8(sp)
    361c:	1000                	add	s0,sp,32
    361e:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    3620:	00004517          	auipc	a0,0x4
    3624:	e3850513          	add	a0,a0,-456 # 7458 <malloc+0x142c>
    3628:	00002097          	auipc	ra,0x2
    362c:	63c080e7          	jalr	1596(ra) # 5c64 <mkdir>
    3630:	04054563          	bltz	a0,367a <dirtest+0x66>
  if(chdir("dir0") < 0){
    3634:	00004517          	auipc	a0,0x4
    3638:	e2450513          	add	a0,a0,-476 # 7458 <malloc+0x142c>
    363c:	00002097          	auipc	ra,0x2
    3640:	630080e7          	jalr	1584(ra) # 5c6c <chdir>
    3644:	04054963          	bltz	a0,3696 <dirtest+0x82>
  if(chdir("..") < 0){
    3648:	00004517          	auipc	a0,0x4
    364c:	e3050513          	add	a0,a0,-464 # 7478 <malloc+0x144c>
    3650:	00002097          	auipc	ra,0x2
    3654:	61c080e7          	jalr	1564(ra) # 5c6c <chdir>
    3658:	04054d63          	bltz	a0,36b2 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    365c:	00004517          	auipc	a0,0x4
    3660:	dfc50513          	add	a0,a0,-516 # 7458 <malloc+0x142c>
    3664:	00002097          	auipc	ra,0x2
    3668:	5e8080e7          	jalr	1512(ra) # 5c4c <unlink>
    366c:	06054163          	bltz	a0,36ce <dirtest+0xba>
}
    3670:	60e2                	ld	ra,24(sp)
    3672:	6442                	ld	s0,16(sp)
    3674:	64a2                	ld	s1,8(sp)
    3676:	6105                	add	sp,sp,32
    3678:	8082                	ret
    printf("%s: mkdir failed\n", s);
    367a:	85a6                	mv	a1,s1
    367c:	00004517          	auipc	a0,0x4
    3680:	d3c50513          	add	a0,a0,-708 # 73b8 <malloc+0x138c>
    3684:	00003097          	auipc	ra,0x3
    3688:	8f0080e7          	jalr	-1808(ra) # 5f74 <printf>
    exit(1);
    368c:	4505                	li	a0,1
    368e:	00002097          	auipc	ra,0x2
    3692:	56e080e7          	jalr	1390(ra) # 5bfc <exit>
    printf("%s: chdir dir0 failed\n", s);
    3696:	85a6                	mv	a1,s1
    3698:	00004517          	auipc	a0,0x4
    369c:	dc850513          	add	a0,a0,-568 # 7460 <malloc+0x1434>
    36a0:	00003097          	auipc	ra,0x3
    36a4:	8d4080e7          	jalr	-1836(ra) # 5f74 <printf>
    exit(1);
    36a8:	4505                	li	a0,1
    36aa:	00002097          	auipc	ra,0x2
    36ae:	552080e7          	jalr	1362(ra) # 5bfc <exit>
    printf("%s: chdir .. failed\n", s);
    36b2:	85a6                	mv	a1,s1
    36b4:	00004517          	auipc	a0,0x4
    36b8:	dcc50513          	add	a0,a0,-564 # 7480 <malloc+0x1454>
    36bc:	00003097          	auipc	ra,0x3
    36c0:	8b8080e7          	jalr	-1864(ra) # 5f74 <printf>
    exit(1);
    36c4:	4505                	li	a0,1
    36c6:	00002097          	auipc	ra,0x2
    36ca:	536080e7          	jalr	1334(ra) # 5bfc <exit>
    printf("%s: unlink dir0 failed\n", s);
    36ce:	85a6                	mv	a1,s1
    36d0:	00004517          	auipc	a0,0x4
    36d4:	dc850513          	add	a0,a0,-568 # 7498 <malloc+0x146c>
    36d8:	00003097          	auipc	ra,0x3
    36dc:	89c080e7          	jalr	-1892(ra) # 5f74 <printf>
    exit(1);
    36e0:	4505                	li	a0,1
    36e2:	00002097          	auipc	ra,0x2
    36e6:	51a080e7          	jalr	1306(ra) # 5bfc <exit>

00000000000036ea <subdir>:
{
    36ea:	1101                	add	sp,sp,-32
    36ec:	ec06                	sd	ra,24(sp)
    36ee:	e822                	sd	s0,16(sp)
    36f0:	e426                	sd	s1,8(sp)
    36f2:	e04a                	sd	s2,0(sp)
    36f4:	1000                	add	s0,sp,32
    36f6:	892a                	mv	s2,a0
  unlink("ff");
    36f8:	00004517          	auipc	a0,0x4
    36fc:	ee850513          	add	a0,a0,-280 # 75e0 <malloc+0x15b4>
    3700:	00002097          	auipc	ra,0x2
    3704:	54c080e7          	jalr	1356(ra) # 5c4c <unlink>
  if(mkdir("dd") != 0){
    3708:	00004517          	auipc	a0,0x4
    370c:	da850513          	add	a0,a0,-600 # 74b0 <malloc+0x1484>
    3710:	00002097          	auipc	ra,0x2
    3714:	554080e7          	jalr	1364(ra) # 5c64 <mkdir>
    3718:	38051663          	bnez	a0,3aa4 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    371c:	20200593          	li	a1,514
    3720:	00004517          	auipc	a0,0x4
    3724:	db050513          	add	a0,a0,-592 # 74d0 <malloc+0x14a4>
    3728:	00002097          	auipc	ra,0x2
    372c:	514080e7          	jalr	1300(ra) # 5c3c <open>
    3730:	84aa                	mv	s1,a0
  if(fd < 0){
    3732:	38054763          	bltz	a0,3ac0 <subdir+0x3d6>
  write(fd, "ff", 2);
    3736:	4609                	li	a2,2
    3738:	00004597          	auipc	a1,0x4
    373c:	ea858593          	add	a1,a1,-344 # 75e0 <malloc+0x15b4>
    3740:	00002097          	auipc	ra,0x2
    3744:	4dc080e7          	jalr	1244(ra) # 5c1c <write>
  close(fd);
    3748:	8526                	mv	a0,s1
    374a:	00002097          	auipc	ra,0x2
    374e:	4da080e7          	jalr	1242(ra) # 5c24 <close>
  if(unlink("dd") >= 0){
    3752:	00004517          	auipc	a0,0x4
    3756:	d5e50513          	add	a0,a0,-674 # 74b0 <malloc+0x1484>
    375a:	00002097          	auipc	ra,0x2
    375e:	4f2080e7          	jalr	1266(ra) # 5c4c <unlink>
    3762:	36055d63          	bgez	a0,3adc <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    3766:	00004517          	auipc	a0,0x4
    376a:	dc250513          	add	a0,a0,-574 # 7528 <malloc+0x14fc>
    376e:	00002097          	auipc	ra,0x2
    3772:	4f6080e7          	jalr	1270(ra) # 5c64 <mkdir>
    3776:	38051163          	bnez	a0,3af8 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    377a:	20200593          	li	a1,514
    377e:	00004517          	auipc	a0,0x4
    3782:	dd250513          	add	a0,a0,-558 # 7550 <malloc+0x1524>
    3786:	00002097          	auipc	ra,0x2
    378a:	4b6080e7          	jalr	1206(ra) # 5c3c <open>
    378e:	84aa                	mv	s1,a0
  if(fd < 0){
    3790:	38054263          	bltz	a0,3b14 <subdir+0x42a>
  write(fd, "FF", 2);
    3794:	4609                	li	a2,2
    3796:	00004597          	auipc	a1,0x4
    379a:	dea58593          	add	a1,a1,-534 # 7580 <malloc+0x1554>
    379e:	00002097          	auipc	ra,0x2
    37a2:	47e080e7          	jalr	1150(ra) # 5c1c <write>
  close(fd);
    37a6:	8526                	mv	a0,s1
    37a8:	00002097          	auipc	ra,0x2
    37ac:	47c080e7          	jalr	1148(ra) # 5c24 <close>
  fd = open("dd/dd/../ff", 0);
    37b0:	4581                	li	a1,0
    37b2:	00004517          	auipc	a0,0x4
    37b6:	dd650513          	add	a0,a0,-554 # 7588 <malloc+0x155c>
    37ba:	00002097          	auipc	ra,0x2
    37be:	482080e7          	jalr	1154(ra) # 5c3c <open>
    37c2:	84aa                	mv	s1,a0
  if(fd < 0){
    37c4:	36054663          	bltz	a0,3b30 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    37c8:	660d                	lui	a2,0x3
    37ca:	00009597          	auipc	a1,0x9
    37ce:	4ae58593          	add	a1,a1,1198 # cc78 <buf>
    37d2:	00002097          	auipc	ra,0x2
    37d6:	442080e7          	jalr	1090(ra) # 5c14 <read>
  if(cc != 2 || buf[0] != 'f'){
    37da:	4789                	li	a5,2
    37dc:	36f51863          	bne	a0,a5,3b4c <subdir+0x462>
    37e0:	00009717          	auipc	a4,0x9
    37e4:	49874703          	lbu	a4,1176(a4) # cc78 <buf>
    37e8:	06600793          	li	a5,102
    37ec:	36f71063          	bne	a4,a5,3b4c <subdir+0x462>
  close(fd);
    37f0:	8526                	mv	a0,s1
    37f2:	00002097          	auipc	ra,0x2
    37f6:	432080e7          	jalr	1074(ra) # 5c24 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    37fa:	00004597          	auipc	a1,0x4
    37fe:	dde58593          	add	a1,a1,-546 # 75d8 <malloc+0x15ac>
    3802:	00004517          	auipc	a0,0x4
    3806:	d4e50513          	add	a0,a0,-690 # 7550 <malloc+0x1524>
    380a:	00002097          	auipc	ra,0x2
    380e:	452080e7          	jalr	1106(ra) # 5c5c <link>
    3812:	34051b63          	bnez	a0,3b68 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3816:	00004517          	auipc	a0,0x4
    381a:	d3a50513          	add	a0,a0,-710 # 7550 <malloc+0x1524>
    381e:	00002097          	auipc	ra,0x2
    3822:	42e080e7          	jalr	1070(ra) # 5c4c <unlink>
    3826:	34051f63          	bnez	a0,3b84 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    382a:	4581                	li	a1,0
    382c:	00004517          	auipc	a0,0x4
    3830:	d2450513          	add	a0,a0,-732 # 7550 <malloc+0x1524>
    3834:	00002097          	auipc	ra,0x2
    3838:	408080e7          	jalr	1032(ra) # 5c3c <open>
    383c:	36055263          	bgez	a0,3ba0 <subdir+0x4b6>
  if(chdir("dd") != 0){
    3840:	00004517          	auipc	a0,0x4
    3844:	c7050513          	add	a0,a0,-912 # 74b0 <malloc+0x1484>
    3848:	00002097          	auipc	ra,0x2
    384c:	424080e7          	jalr	1060(ra) # 5c6c <chdir>
    3850:	36051663          	bnez	a0,3bbc <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    3854:	00004517          	auipc	a0,0x4
    3858:	e1c50513          	add	a0,a0,-484 # 7670 <malloc+0x1644>
    385c:	00002097          	auipc	ra,0x2
    3860:	410080e7          	jalr	1040(ra) # 5c6c <chdir>
    3864:	36051a63          	bnez	a0,3bd8 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    3868:	00004517          	auipc	a0,0x4
    386c:	e3850513          	add	a0,a0,-456 # 76a0 <malloc+0x1674>
    3870:	00002097          	auipc	ra,0x2
    3874:	3fc080e7          	jalr	1020(ra) # 5c6c <chdir>
    3878:	36051e63          	bnez	a0,3bf4 <subdir+0x50a>
  if(chdir("./..") != 0){
    387c:	00004517          	auipc	a0,0x4
    3880:	e5450513          	add	a0,a0,-428 # 76d0 <malloc+0x16a4>
    3884:	00002097          	auipc	ra,0x2
    3888:	3e8080e7          	jalr	1000(ra) # 5c6c <chdir>
    388c:	38051263          	bnez	a0,3c10 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3890:	4581                	li	a1,0
    3892:	00004517          	auipc	a0,0x4
    3896:	d4650513          	add	a0,a0,-698 # 75d8 <malloc+0x15ac>
    389a:	00002097          	auipc	ra,0x2
    389e:	3a2080e7          	jalr	930(ra) # 5c3c <open>
    38a2:	84aa                	mv	s1,a0
  if(fd < 0){
    38a4:	38054463          	bltz	a0,3c2c <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    38a8:	660d                	lui	a2,0x3
    38aa:	00009597          	auipc	a1,0x9
    38ae:	3ce58593          	add	a1,a1,974 # cc78 <buf>
    38b2:	00002097          	auipc	ra,0x2
    38b6:	362080e7          	jalr	866(ra) # 5c14 <read>
    38ba:	4789                	li	a5,2
    38bc:	38f51663          	bne	a0,a5,3c48 <subdir+0x55e>
  close(fd);
    38c0:	8526                	mv	a0,s1
    38c2:	00002097          	auipc	ra,0x2
    38c6:	362080e7          	jalr	866(ra) # 5c24 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    38ca:	4581                	li	a1,0
    38cc:	00004517          	auipc	a0,0x4
    38d0:	c8450513          	add	a0,a0,-892 # 7550 <malloc+0x1524>
    38d4:	00002097          	auipc	ra,0x2
    38d8:	368080e7          	jalr	872(ra) # 5c3c <open>
    38dc:	38055463          	bgez	a0,3c64 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    38e0:	20200593          	li	a1,514
    38e4:	00004517          	auipc	a0,0x4
    38e8:	e7c50513          	add	a0,a0,-388 # 7760 <malloc+0x1734>
    38ec:	00002097          	auipc	ra,0x2
    38f0:	350080e7          	jalr	848(ra) # 5c3c <open>
    38f4:	38055663          	bgez	a0,3c80 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    38f8:	20200593          	li	a1,514
    38fc:	00004517          	auipc	a0,0x4
    3900:	e9450513          	add	a0,a0,-364 # 7790 <malloc+0x1764>
    3904:	00002097          	auipc	ra,0x2
    3908:	338080e7          	jalr	824(ra) # 5c3c <open>
    390c:	38055863          	bgez	a0,3c9c <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3910:	20000593          	li	a1,512
    3914:	00004517          	auipc	a0,0x4
    3918:	b9c50513          	add	a0,a0,-1124 # 74b0 <malloc+0x1484>
    391c:	00002097          	auipc	ra,0x2
    3920:	320080e7          	jalr	800(ra) # 5c3c <open>
    3924:	38055a63          	bgez	a0,3cb8 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3928:	4589                	li	a1,2
    392a:	00004517          	auipc	a0,0x4
    392e:	b8650513          	add	a0,a0,-1146 # 74b0 <malloc+0x1484>
    3932:	00002097          	auipc	ra,0x2
    3936:	30a080e7          	jalr	778(ra) # 5c3c <open>
    393a:	38055d63          	bgez	a0,3cd4 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    393e:	4585                	li	a1,1
    3940:	00004517          	auipc	a0,0x4
    3944:	b7050513          	add	a0,a0,-1168 # 74b0 <malloc+0x1484>
    3948:	00002097          	auipc	ra,0x2
    394c:	2f4080e7          	jalr	756(ra) # 5c3c <open>
    3950:	3a055063          	bgez	a0,3cf0 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3954:	00004597          	auipc	a1,0x4
    3958:	ecc58593          	add	a1,a1,-308 # 7820 <malloc+0x17f4>
    395c:	00004517          	auipc	a0,0x4
    3960:	e0450513          	add	a0,a0,-508 # 7760 <malloc+0x1734>
    3964:	00002097          	auipc	ra,0x2
    3968:	2f8080e7          	jalr	760(ra) # 5c5c <link>
    396c:	3a050063          	beqz	a0,3d0c <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3970:	00004597          	auipc	a1,0x4
    3974:	eb058593          	add	a1,a1,-336 # 7820 <malloc+0x17f4>
    3978:	00004517          	auipc	a0,0x4
    397c:	e1850513          	add	a0,a0,-488 # 7790 <malloc+0x1764>
    3980:	00002097          	auipc	ra,0x2
    3984:	2dc080e7          	jalr	732(ra) # 5c5c <link>
    3988:	3a050063          	beqz	a0,3d28 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    398c:	00004597          	auipc	a1,0x4
    3990:	c4c58593          	add	a1,a1,-948 # 75d8 <malloc+0x15ac>
    3994:	00004517          	auipc	a0,0x4
    3998:	b3c50513          	add	a0,a0,-1220 # 74d0 <malloc+0x14a4>
    399c:	00002097          	auipc	ra,0x2
    39a0:	2c0080e7          	jalr	704(ra) # 5c5c <link>
    39a4:	3a050063          	beqz	a0,3d44 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    39a8:	00004517          	auipc	a0,0x4
    39ac:	db850513          	add	a0,a0,-584 # 7760 <malloc+0x1734>
    39b0:	00002097          	auipc	ra,0x2
    39b4:	2b4080e7          	jalr	692(ra) # 5c64 <mkdir>
    39b8:	3a050463          	beqz	a0,3d60 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    39bc:	00004517          	auipc	a0,0x4
    39c0:	dd450513          	add	a0,a0,-556 # 7790 <malloc+0x1764>
    39c4:	00002097          	auipc	ra,0x2
    39c8:	2a0080e7          	jalr	672(ra) # 5c64 <mkdir>
    39cc:	3a050863          	beqz	a0,3d7c <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    39d0:	00004517          	auipc	a0,0x4
    39d4:	c0850513          	add	a0,a0,-1016 # 75d8 <malloc+0x15ac>
    39d8:	00002097          	auipc	ra,0x2
    39dc:	28c080e7          	jalr	652(ra) # 5c64 <mkdir>
    39e0:	3a050c63          	beqz	a0,3d98 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    39e4:	00004517          	auipc	a0,0x4
    39e8:	dac50513          	add	a0,a0,-596 # 7790 <malloc+0x1764>
    39ec:	00002097          	auipc	ra,0x2
    39f0:	260080e7          	jalr	608(ra) # 5c4c <unlink>
    39f4:	3c050063          	beqz	a0,3db4 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    39f8:	00004517          	auipc	a0,0x4
    39fc:	d6850513          	add	a0,a0,-664 # 7760 <malloc+0x1734>
    3a00:	00002097          	auipc	ra,0x2
    3a04:	24c080e7          	jalr	588(ra) # 5c4c <unlink>
    3a08:	3c050463          	beqz	a0,3dd0 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3a0c:	00004517          	auipc	a0,0x4
    3a10:	ac450513          	add	a0,a0,-1340 # 74d0 <malloc+0x14a4>
    3a14:	00002097          	auipc	ra,0x2
    3a18:	258080e7          	jalr	600(ra) # 5c6c <chdir>
    3a1c:	3c050863          	beqz	a0,3dec <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3a20:	00004517          	auipc	a0,0x4
    3a24:	f5050513          	add	a0,a0,-176 # 7970 <malloc+0x1944>
    3a28:	00002097          	auipc	ra,0x2
    3a2c:	244080e7          	jalr	580(ra) # 5c6c <chdir>
    3a30:	3c050c63          	beqz	a0,3e08 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3a34:	00004517          	auipc	a0,0x4
    3a38:	ba450513          	add	a0,a0,-1116 # 75d8 <malloc+0x15ac>
    3a3c:	00002097          	auipc	ra,0x2
    3a40:	210080e7          	jalr	528(ra) # 5c4c <unlink>
    3a44:	3e051063          	bnez	a0,3e24 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    3a48:	00004517          	auipc	a0,0x4
    3a4c:	a8850513          	add	a0,a0,-1400 # 74d0 <malloc+0x14a4>
    3a50:	00002097          	auipc	ra,0x2
    3a54:	1fc080e7          	jalr	508(ra) # 5c4c <unlink>
    3a58:	3e051463          	bnez	a0,3e40 <subdir+0x756>
  if(unlink("dd") == 0){
    3a5c:	00004517          	auipc	a0,0x4
    3a60:	a5450513          	add	a0,a0,-1452 # 74b0 <malloc+0x1484>
    3a64:	00002097          	auipc	ra,0x2
    3a68:	1e8080e7          	jalr	488(ra) # 5c4c <unlink>
    3a6c:	3e050863          	beqz	a0,3e5c <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3a70:	00004517          	auipc	a0,0x4
    3a74:	f7050513          	add	a0,a0,-144 # 79e0 <malloc+0x19b4>
    3a78:	00002097          	auipc	ra,0x2
    3a7c:	1d4080e7          	jalr	468(ra) # 5c4c <unlink>
    3a80:	3e054c63          	bltz	a0,3e78 <subdir+0x78e>
  if(unlink("dd") < 0){
    3a84:	00004517          	auipc	a0,0x4
    3a88:	a2c50513          	add	a0,a0,-1492 # 74b0 <malloc+0x1484>
    3a8c:	00002097          	auipc	ra,0x2
    3a90:	1c0080e7          	jalr	448(ra) # 5c4c <unlink>
    3a94:	40054063          	bltz	a0,3e94 <subdir+0x7aa>
}
    3a98:	60e2                	ld	ra,24(sp)
    3a9a:	6442                	ld	s0,16(sp)
    3a9c:	64a2                	ld	s1,8(sp)
    3a9e:	6902                	ld	s2,0(sp)
    3aa0:	6105                	add	sp,sp,32
    3aa2:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3aa4:	85ca                	mv	a1,s2
    3aa6:	00004517          	auipc	a0,0x4
    3aaa:	a1250513          	add	a0,a0,-1518 # 74b8 <malloc+0x148c>
    3aae:	00002097          	auipc	ra,0x2
    3ab2:	4c6080e7          	jalr	1222(ra) # 5f74 <printf>
    exit(1);
    3ab6:	4505                	li	a0,1
    3ab8:	00002097          	auipc	ra,0x2
    3abc:	144080e7          	jalr	324(ra) # 5bfc <exit>
    printf("%s: create dd/ff failed\n", s);
    3ac0:	85ca                	mv	a1,s2
    3ac2:	00004517          	auipc	a0,0x4
    3ac6:	a1650513          	add	a0,a0,-1514 # 74d8 <malloc+0x14ac>
    3aca:	00002097          	auipc	ra,0x2
    3ace:	4aa080e7          	jalr	1194(ra) # 5f74 <printf>
    exit(1);
    3ad2:	4505                	li	a0,1
    3ad4:	00002097          	auipc	ra,0x2
    3ad8:	128080e7          	jalr	296(ra) # 5bfc <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3adc:	85ca                	mv	a1,s2
    3ade:	00004517          	auipc	a0,0x4
    3ae2:	a1a50513          	add	a0,a0,-1510 # 74f8 <malloc+0x14cc>
    3ae6:	00002097          	auipc	ra,0x2
    3aea:	48e080e7          	jalr	1166(ra) # 5f74 <printf>
    exit(1);
    3aee:	4505                	li	a0,1
    3af0:	00002097          	auipc	ra,0x2
    3af4:	10c080e7          	jalr	268(ra) # 5bfc <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3af8:	85ca                	mv	a1,s2
    3afa:	00004517          	auipc	a0,0x4
    3afe:	a3650513          	add	a0,a0,-1482 # 7530 <malloc+0x1504>
    3b02:	00002097          	auipc	ra,0x2
    3b06:	472080e7          	jalr	1138(ra) # 5f74 <printf>
    exit(1);
    3b0a:	4505                	li	a0,1
    3b0c:	00002097          	auipc	ra,0x2
    3b10:	0f0080e7          	jalr	240(ra) # 5bfc <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3b14:	85ca                	mv	a1,s2
    3b16:	00004517          	auipc	a0,0x4
    3b1a:	a4a50513          	add	a0,a0,-1462 # 7560 <malloc+0x1534>
    3b1e:	00002097          	auipc	ra,0x2
    3b22:	456080e7          	jalr	1110(ra) # 5f74 <printf>
    exit(1);
    3b26:	4505                	li	a0,1
    3b28:	00002097          	auipc	ra,0x2
    3b2c:	0d4080e7          	jalr	212(ra) # 5bfc <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3b30:	85ca                	mv	a1,s2
    3b32:	00004517          	auipc	a0,0x4
    3b36:	a6650513          	add	a0,a0,-1434 # 7598 <malloc+0x156c>
    3b3a:	00002097          	auipc	ra,0x2
    3b3e:	43a080e7          	jalr	1082(ra) # 5f74 <printf>
    exit(1);
    3b42:	4505                	li	a0,1
    3b44:	00002097          	auipc	ra,0x2
    3b48:	0b8080e7          	jalr	184(ra) # 5bfc <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    3b4c:	85ca                	mv	a1,s2
    3b4e:	00004517          	auipc	a0,0x4
    3b52:	a6a50513          	add	a0,a0,-1430 # 75b8 <malloc+0x158c>
    3b56:	00002097          	auipc	ra,0x2
    3b5a:	41e080e7          	jalr	1054(ra) # 5f74 <printf>
    exit(1);
    3b5e:	4505                	li	a0,1
    3b60:	00002097          	auipc	ra,0x2
    3b64:	09c080e7          	jalr	156(ra) # 5bfc <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3b68:	85ca                	mv	a1,s2
    3b6a:	00004517          	auipc	a0,0x4
    3b6e:	a7e50513          	add	a0,a0,-1410 # 75e8 <malloc+0x15bc>
    3b72:	00002097          	auipc	ra,0x2
    3b76:	402080e7          	jalr	1026(ra) # 5f74 <printf>
    exit(1);
    3b7a:	4505                	li	a0,1
    3b7c:	00002097          	auipc	ra,0x2
    3b80:	080080e7          	jalr	128(ra) # 5bfc <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3b84:	85ca                	mv	a1,s2
    3b86:	00004517          	auipc	a0,0x4
    3b8a:	a8a50513          	add	a0,a0,-1398 # 7610 <malloc+0x15e4>
    3b8e:	00002097          	auipc	ra,0x2
    3b92:	3e6080e7          	jalr	998(ra) # 5f74 <printf>
    exit(1);
    3b96:	4505                	li	a0,1
    3b98:	00002097          	auipc	ra,0x2
    3b9c:	064080e7          	jalr	100(ra) # 5bfc <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3ba0:	85ca                	mv	a1,s2
    3ba2:	00004517          	auipc	a0,0x4
    3ba6:	a8e50513          	add	a0,a0,-1394 # 7630 <malloc+0x1604>
    3baa:	00002097          	auipc	ra,0x2
    3bae:	3ca080e7          	jalr	970(ra) # 5f74 <printf>
    exit(1);
    3bb2:	4505                	li	a0,1
    3bb4:	00002097          	auipc	ra,0x2
    3bb8:	048080e7          	jalr	72(ra) # 5bfc <exit>
    printf("%s: chdir dd failed\n", s);
    3bbc:	85ca                	mv	a1,s2
    3bbe:	00004517          	auipc	a0,0x4
    3bc2:	a9a50513          	add	a0,a0,-1382 # 7658 <malloc+0x162c>
    3bc6:	00002097          	auipc	ra,0x2
    3bca:	3ae080e7          	jalr	942(ra) # 5f74 <printf>
    exit(1);
    3bce:	4505                	li	a0,1
    3bd0:	00002097          	auipc	ra,0x2
    3bd4:	02c080e7          	jalr	44(ra) # 5bfc <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3bd8:	85ca                	mv	a1,s2
    3bda:	00004517          	auipc	a0,0x4
    3bde:	aa650513          	add	a0,a0,-1370 # 7680 <malloc+0x1654>
    3be2:	00002097          	auipc	ra,0x2
    3be6:	392080e7          	jalr	914(ra) # 5f74 <printf>
    exit(1);
    3bea:	4505                	li	a0,1
    3bec:	00002097          	auipc	ra,0x2
    3bf0:	010080e7          	jalr	16(ra) # 5bfc <exit>
    printf("chdir dd/../../dd failed\n", s);
    3bf4:	85ca                	mv	a1,s2
    3bf6:	00004517          	auipc	a0,0x4
    3bfa:	aba50513          	add	a0,a0,-1350 # 76b0 <malloc+0x1684>
    3bfe:	00002097          	auipc	ra,0x2
    3c02:	376080e7          	jalr	886(ra) # 5f74 <printf>
    exit(1);
    3c06:	4505                	li	a0,1
    3c08:	00002097          	auipc	ra,0x2
    3c0c:	ff4080e7          	jalr	-12(ra) # 5bfc <exit>
    printf("%s: chdir ./.. failed\n", s);
    3c10:	85ca                	mv	a1,s2
    3c12:	00004517          	auipc	a0,0x4
    3c16:	ac650513          	add	a0,a0,-1338 # 76d8 <malloc+0x16ac>
    3c1a:	00002097          	auipc	ra,0x2
    3c1e:	35a080e7          	jalr	858(ra) # 5f74 <printf>
    exit(1);
    3c22:	4505                	li	a0,1
    3c24:	00002097          	auipc	ra,0x2
    3c28:	fd8080e7          	jalr	-40(ra) # 5bfc <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3c2c:	85ca                	mv	a1,s2
    3c2e:	00004517          	auipc	a0,0x4
    3c32:	ac250513          	add	a0,a0,-1342 # 76f0 <malloc+0x16c4>
    3c36:	00002097          	auipc	ra,0x2
    3c3a:	33e080e7          	jalr	830(ra) # 5f74 <printf>
    exit(1);
    3c3e:	4505                	li	a0,1
    3c40:	00002097          	auipc	ra,0x2
    3c44:	fbc080e7          	jalr	-68(ra) # 5bfc <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    3c48:	85ca                	mv	a1,s2
    3c4a:	00004517          	auipc	a0,0x4
    3c4e:	ac650513          	add	a0,a0,-1338 # 7710 <malloc+0x16e4>
    3c52:	00002097          	auipc	ra,0x2
    3c56:	322080e7          	jalr	802(ra) # 5f74 <printf>
    exit(1);
    3c5a:	4505                	li	a0,1
    3c5c:	00002097          	auipc	ra,0x2
    3c60:	fa0080e7          	jalr	-96(ra) # 5bfc <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3c64:	85ca                	mv	a1,s2
    3c66:	00004517          	auipc	a0,0x4
    3c6a:	aca50513          	add	a0,a0,-1334 # 7730 <malloc+0x1704>
    3c6e:	00002097          	auipc	ra,0x2
    3c72:	306080e7          	jalr	774(ra) # 5f74 <printf>
    exit(1);
    3c76:	4505                	li	a0,1
    3c78:	00002097          	auipc	ra,0x2
    3c7c:	f84080e7          	jalr	-124(ra) # 5bfc <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3c80:	85ca                	mv	a1,s2
    3c82:	00004517          	auipc	a0,0x4
    3c86:	aee50513          	add	a0,a0,-1298 # 7770 <malloc+0x1744>
    3c8a:	00002097          	auipc	ra,0x2
    3c8e:	2ea080e7          	jalr	746(ra) # 5f74 <printf>
    exit(1);
    3c92:	4505                	li	a0,1
    3c94:	00002097          	auipc	ra,0x2
    3c98:	f68080e7          	jalr	-152(ra) # 5bfc <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3c9c:	85ca                	mv	a1,s2
    3c9e:	00004517          	auipc	a0,0x4
    3ca2:	b0250513          	add	a0,a0,-1278 # 77a0 <malloc+0x1774>
    3ca6:	00002097          	auipc	ra,0x2
    3caa:	2ce080e7          	jalr	718(ra) # 5f74 <printf>
    exit(1);
    3cae:	4505                	li	a0,1
    3cb0:	00002097          	auipc	ra,0x2
    3cb4:	f4c080e7          	jalr	-180(ra) # 5bfc <exit>
    printf("%s: create dd succeeded!\n", s);
    3cb8:	85ca                	mv	a1,s2
    3cba:	00004517          	auipc	a0,0x4
    3cbe:	b0650513          	add	a0,a0,-1274 # 77c0 <malloc+0x1794>
    3cc2:	00002097          	auipc	ra,0x2
    3cc6:	2b2080e7          	jalr	690(ra) # 5f74 <printf>
    exit(1);
    3cca:	4505                	li	a0,1
    3ccc:	00002097          	auipc	ra,0x2
    3cd0:	f30080e7          	jalr	-208(ra) # 5bfc <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3cd4:	85ca                	mv	a1,s2
    3cd6:	00004517          	auipc	a0,0x4
    3cda:	b0a50513          	add	a0,a0,-1270 # 77e0 <malloc+0x17b4>
    3cde:	00002097          	auipc	ra,0x2
    3ce2:	296080e7          	jalr	662(ra) # 5f74 <printf>
    exit(1);
    3ce6:	4505                	li	a0,1
    3ce8:	00002097          	auipc	ra,0x2
    3cec:	f14080e7          	jalr	-236(ra) # 5bfc <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3cf0:	85ca                	mv	a1,s2
    3cf2:	00004517          	auipc	a0,0x4
    3cf6:	b0e50513          	add	a0,a0,-1266 # 7800 <malloc+0x17d4>
    3cfa:	00002097          	auipc	ra,0x2
    3cfe:	27a080e7          	jalr	634(ra) # 5f74 <printf>
    exit(1);
    3d02:	4505                	li	a0,1
    3d04:	00002097          	auipc	ra,0x2
    3d08:	ef8080e7          	jalr	-264(ra) # 5bfc <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3d0c:	85ca                	mv	a1,s2
    3d0e:	00004517          	auipc	a0,0x4
    3d12:	b2250513          	add	a0,a0,-1246 # 7830 <malloc+0x1804>
    3d16:	00002097          	auipc	ra,0x2
    3d1a:	25e080e7          	jalr	606(ra) # 5f74 <printf>
    exit(1);
    3d1e:	4505                	li	a0,1
    3d20:	00002097          	auipc	ra,0x2
    3d24:	edc080e7          	jalr	-292(ra) # 5bfc <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3d28:	85ca                	mv	a1,s2
    3d2a:	00004517          	auipc	a0,0x4
    3d2e:	b2e50513          	add	a0,a0,-1234 # 7858 <malloc+0x182c>
    3d32:	00002097          	auipc	ra,0x2
    3d36:	242080e7          	jalr	578(ra) # 5f74 <printf>
    exit(1);
    3d3a:	4505                	li	a0,1
    3d3c:	00002097          	auipc	ra,0x2
    3d40:	ec0080e7          	jalr	-320(ra) # 5bfc <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3d44:	85ca                	mv	a1,s2
    3d46:	00004517          	auipc	a0,0x4
    3d4a:	b3a50513          	add	a0,a0,-1222 # 7880 <malloc+0x1854>
    3d4e:	00002097          	auipc	ra,0x2
    3d52:	226080e7          	jalr	550(ra) # 5f74 <printf>
    exit(1);
    3d56:	4505                	li	a0,1
    3d58:	00002097          	auipc	ra,0x2
    3d5c:	ea4080e7          	jalr	-348(ra) # 5bfc <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3d60:	85ca                	mv	a1,s2
    3d62:	00004517          	auipc	a0,0x4
    3d66:	b4650513          	add	a0,a0,-1210 # 78a8 <malloc+0x187c>
    3d6a:	00002097          	auipc	ra,0x2
    3d6e:	20a080e7          	jalr	522(ra) # 5f74 <printf>
    exit(1);
    3d72:	4505                	li	a0,1
    3d74:	00002097          	auipc	ra,0x2
    3d78:	e88080e7          	jalr	-376(ra) # 5bfc <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3d7c:	85ca                	mv	a1,s2
    3d7e:	00004517          	auipc	a0,0x4
    3d82:	b4a50513          	add	a0,a0,-1206 # 78c8 <malloc+0x189c>
    3d86:	00002097          	auipc	ra,0x2
    3d8a:	1ee080e7          	jalr	494(ra) # 5f74 <printf>
    exit(1);
    3d8e:	4505                	li	a0,1
    3d90:	00002097          	auipc	ra,0x2
    3d94:	e6c080e7          	jalr	-404(ra) # 5bfc <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3d98:	85ca                	mv	a1,s2
    3d9a:	00004517          	auipc	a0,0x4
    3d9e:	b4e50513          	add	a0,a0,-1202 # 78e8 <malloc+0x18bc>
    3da2:	00002097          	auipc	ra,0x2
    3da6:	1d2080e7          	jalr	466(ra) # 5f74 <printf>
    exit(1);
    3daa:	4505                	li	a0,1
    3dac:	00002097          	auipc	ra,0x2
    3db0:	e50080e7          	jalr	-432(ra) # 5bfc <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3db4:	85ca                	mv	a1,s2
    3db6:	00004517          	auipc	a0,0x4
    3dba:	b5a50513          	add	a0,a0,-1190 # 7910 <malloc+0x18e4>
    3dbe:	00002097          	auipc	ra,0x2
    3dc2:	1b6080e7          	jalr	438(ra) # 5f74 <printf>
    exit(1);
    3dc6:	4505                	li	a0,1
    3dc8:	00002097          	auipc	ra,0x2
    3dcc:	e34080e7          	jalr	-460(ra) # 5bfc <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3dd0:	85ca                	mv	a1,s2
    3dd2:	00004517          	auipc	a0,0x4
    3dd6:	b5e50513          	add	a0,a0,-1186 # 7930 <malloc+0x1904>
    3dda:	00002097          	auipc	ra,0x2
    3dde:	19a080e7          	jalr	410(ra) # 5f74 <printf>
    exit(1);
    3de2:	4505                	li	a0,1
    3de4:	00002097          	auipc	ra,0x2
    3de8:	e18080e7          	jalr	-488(ra) # 5bfc <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3dec:	85ca                	mv	a1,s2
    3dee:	00004517          	auipc	a0,0x4
    3df2:	b6250513          	add	a0,a0,-1182 # 7950 <malloc+0x1924>
    3df6:	00002097          	auipc	ra,0x2
    3dfa:	17e080e7          	jalr	382(ra) # 5f74 <printf>
    exit(1);
    3dfe:	4505                	li	a0,1
    3e00:	00002097          	auipc	ra,0x2
    3e04:	dfc080e7          	jalr	-516(ra) # 5bfc <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3e08:	85ca                	mv	a1,s2
    3e0a:	00004517          	auipc	a0,0x4
    3e0e:	b6e50513          	add	a0,a0,-1170 # 7978 <malloc+0x194c>
    3e12:	00002097          	auipc	ra,0x2
    3e16:	162080e7          	jalr	354(ra) # 5f74 <printf>
    exit(1);
    3e1a:	4505                	li	a0,1
    3e1c:	00002097          	auipc	ra,0x2
    3e20:	de0080e7          	jalr	-544(ra) # 5bfc <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3e24:	85ca                	mv	a1,s2
    3e26:	00003517          	auipc	a0,0x3
    3e2a:	7ea50513          	add	a0,a0,2026 # 7610 <malloc+0x15e4>
    3e2e:	00002097          	auipc	ra,0x2
    3e32:	146080e7          	jalr	326(ra) # 5f74 <printf>
    exit(1);
    3e36:	4505                	li	a0,1
    3e38:	00002097          	auipc	ra,0x2
    3e3c:	dc4080e7          	jalr	-572(ra) # 5bfc <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3e40:	85ca                	mv	a1,s2
    3e42:	00004517          	auipc	a0,0x4
    3e46:	b5650513          	add	a0,a0,-1194 # 7998 <malloc+0x196c>
    3e4a:	00002097          	auipc	ra,0x2
    3e4e:	12a080e7          	jalr	298(ra) # 5f74 <printf>
    exit(1);
    3e52:	4505                	li	a0,1
    3e54:	00002097          	auipc	ra,0x2
    3e58:	da8080e7          	jalr	-600(ra) # 5bfc <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3e5c:	85ca                	mv	a1,s2
    3e5e:	00004517          	auipc	a0,0x4
    3e62:	b5a50513          	add	a0,a0,-1190 # 79b8 <malloc+0x198c>
    3e66:	00002097          	auipc	ra,0x2
    3e6a:	10e080e7          	jalr	270(ra) # 5f74 <printf>
    exit(1);
    3e6e:	4505                	li	a0,1
    3e70:	00002097          	auipc	ra,0x2
    3e74:	d8c080e7          	jalr	-628(ra) # 5bfc <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3e78:	85ca                	mv	a1,s2
    3e7a:	00004517          	auipc	a0,0x4
    3e7e:	b6e50513          	add	a0,a0,-1170 # 79e8 <malloc+0x19bc>
    3e82:	00002097          	auipc	ra,0x2
    3e86:	0f2080e7          	jalr	242(ra) # 5f74 <printf>
    exit(1);
    3e8a:	4505                	li	a0,1
    3e8c:	00002097          	auipc	ra,0x2
    3e90:	d70080e7          	jalr	-656(ra) # 5bfc <exit>
    printf("%s: unlink dd failed\n", s);
    3e94:	85ca                	mv	a1,s2
    3e96:	00004517          	auipc	a0,0x4
    3e9a:	b7250513          	add	a0,a0,-1166 # 7a08 <malloc+0x19dc>
    3e9e:	00002097          	auipc	ra,0x2
    3ea2:	0d6080e7          	jalr	214(ra) # 5f74 <printf>
    exit(1);
    3ea6:	4505                	li	a0,1
    3ea8:	00002097          	auipc	ra,0x2
    3eac:	d54080e7          	jalr	-684(ra) # 5bfc <exit>

0000000000003eb0 <rmdot>:
{
    3eb0:	1101                	add	sp,sp,-32
    3eb2:	ec06                	sd	ra,24(sp)
    3eb4:	e822                	sd	s0,16(sp)
    3eb6:	e426                	sd	s1,8(sp)
    3eb8:	1000                	add	s0,sp,32
    3eba:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3ebc:	00004517          	auipc	a0,0x4
    3ec0:	b6450513          	add	a0,a0,-1180 # 7a20 <malloc+0x19f4>
    3ec4:	00002097          	auipc	ra,0x2
    3ec8:	da0080e7          	jalr	-608(ra) # 5c64 <mkdir>
    3ecc:	e549                	bnez	a0,3f56 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3ece:	00004517          	auipc	a0,0x4
    3ed2:	b5250513          	add	a0,a0,-1198 # 7a20 <malloc+0x19f4>
    3ed6:	00002097          	auipc	ra,0x2
    3eda:	d96080e7          	jalr	-618(ra) # 5c6c <chdir>
    3ede:	e951                	bnez	a0,3f72 <rmdot+0xc2>
  if(unlink(".") == 0){
    3ee0:	00003517          	auipc	a0,0x3
    3ee4:	97050513          	add	a0,a0,-1680 # 6850 <malloc+0x824>
    3ee8:	00002097          	auipc	ra,0x2
    3eec:	d64080e7          	jalr	-668(ra) # 5c4c <unlink>
    3ef0:	cd59                	beqz	a0,3f8e <rmdot+0xde>
  if(unlink("..") == 0){
    3ef2:	00003517          	auipc	a0,0x3
    3ef6:	58650513          	add	a0,a0,1414 # 7478 <malloc+0x144c>
    3efa:	00002097          	auipc	ra,0x2
    3efe:	d52080e7          	jalr	-686(ra) # 5c4c <unlink>
    3f02:	c545                	beqz	a0,3faa <rmdot+0xfa>
  if(chdir("/") != 0){
    3f04:	00003517          	auipc	a0,0x3
    3f08:	51c50513          	add	a0,a0,1308 # 7420 <malloc+0x13f4>
    3f0c:	00002097          	auipc	ra,0x2
    3f10:	d60080e7          	jalr	-672(ra) # 5c6c <chdir>
    3f14:	e94d                	bnez	a0,3fc6 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3f16:	00004517          	auipc	a0,0x4
    3f1a:	b7250513          	add	a0,a0,-1166 # 7a88 <malloc+0x1a5c>
    3f1e:	00002097          	auipc	ra,0x2
    3f22:	d2e080e7          	jalr	-722(ra) # 5c4c <unlink>
    3f26:	cd55                	beqz	a0,3fe2 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3f28:	00004517          	auipc	a0,0x4
    3f2c:	b8850513          	add	a0,a0,-1144 # 7ab0 <malloc+0x1a84>
    3f30:	00002097          	auipc	ra,0x2
    3f34:	d1c080e7          	jalr	-740(ra) # 5c4c <unlink>
    3f38:	c179                	beqz	a0,3ffe <rmdot+0x14e>
  if(unlink("dots") != 0){
    3f3a:	00004517          	auipc	a0,0x4
    3f3e:	ae650513          	add	a0,a0,-1306 # 7a20 <malloc+0x19f4>
    3f42:	00002097          	auipc	ra,0x2
    3f46:	d0a080e7          	jalr	-758(ra) # 5c4c <unlink>
    3f4a:	e961                	bnez	a0,401a <rmdot+0x16a>
}
    3f4c:	60e2                	ld	ra,24(sp)
    3f4e:	6442                	ld	s0,16(sp)
    3f50:	64a2                	ld	s1,8(sp)
    3f52:	6105                	add	sp,sp,32
    3f54:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3f56:	85a6                	mv	a1,s1
    3f58:	00004517          	auipc	a0,0x4
    3f5c:	ad050513          	add	a0,a0,-1328 # 7a28 <malloc+0x19fc>
    3f60:	00002097          	auipc	ra,0x2
    3f64:	014080e7          	jalr	20(ra) # 5f74 <printf>
    exit(1);
    3f68:	4505                	li	a0,1
    3f6a:	00002097          	auipc	ra,0x2
    3f6e:	c92080e7          	jalr	-878(ra) # 5bfc <exit>
    printf("%s: chdir dots failed\n", s);
    3f72:	85a6                	mv	a1,s1
    3f74:	00004517          	auipc	a0,0x4
    3f78:	acc50513          	add	a0,a0,-1332 # 7a40 <malloc+0x1a14>
    3f7c:	00002097          	auipc	ra,0x2
    3f80:	ff8080e7          	jalr	-8(ra) # 5f74 <printf>
    exit(1);
    3f84:	4505                	li	a0,1
    3f86:	00002097          	auipc	ra,0x2
    3f8a:	c76080e7          	jalr	-906(ra) # 5bfc <exit>
    printf("%s: rm . worked!\n", s);
    3f8e:	85a6                	mv	a1,s1
    3f90:	00004517          	auipc	a0,0x4
    3f94:	ac850513          	add	a0,a0,-1336 # 7a58 <malloc+0x1a2c>
    3f98:	00002097          	auipc	ra,0x2
    3f9c:	fdc080e7          	jalr	-36(ra) # 5f74 <printf>
    exit(1);
    3fa0:	4505                	li	a0,1
    3fa2:	00002097          	auipc	ra,0x2
    3fa6:	c5a080e7          	jalr	-934(ra) # 5bfc <exit>
    printf("%s: rm .. worked!\n", s);
    3faa:	85a6                	mv	a1,s1
    3fac:	00004517          	auipc	a0,0x4
    3fb0:	ac450513          	add	a0,a0,-1340 # 7a70 <malloc+0x1a44>
    3fb4:	00002097          	auipc	ra,0x2
    3fb8:	fc0080e7          	jalr	-64(ra) # 5f74 <printf>
    exit(1);
    3fbc:	4505                	li	a0,1
    3fbe:	00002097          	auipc	ra,0x2
    3fc2:	c3e080e7          	jalr	-962(ra) # 5bfc <exit>
    printf("%s: chdir / failed\n", s);
    3fc6:	85a6                	mv	a1,s1
    3fc8:	00003517          	auipc	a0,0x3
    3fcc:	46050513          	add	a0,a0,1120 # 7428 <malloc+0x13fc>
    3fd0:	00002097          	auipc	ra,0x2
    3fd4:	fa4080e7          	jalr	-92(ra) # 5f74 <printf>
    exit(1);
    3fd8:	4505                	li	a0,1
    3fda:	00002097          	auipc	ra,0x2
    3fde:	c22080e7          	jalr	-990(ra) # 5bfc <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3fe2:	85a6                	mv	a1,s1
    3fe4:	00004517          	auipc	a0,0x4
    3fe8:	aac50513          	add	a0,a0,-1364 # 7a90 <malloc+0x1a64>
    3fec:	00002097          	auipc	ra,0x2
    3ff0:	f88080e7          	jalr	-120(ra) # 5f74 <printf>
    exit(1);
    3ff4:	4505                	li	a0,1
    3ff6:	00002097          	auipc	ra,0x2
    3ffa:	c06080e7          	jalr	-1018(ra) # 5bfc <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3ffe:	85a6                	mv	a1,s1
    4000:	00004517          	auipc	a0,0x4
    4004:	ab850513          	add	a0,a0,-1352 # 7ab8 <malloc+0x1a8c>
    4008:	00002097          	auipc	ra,0x2
    400c:	f6c080e7          	jalr	-148(ra) # 5f74 <printf>
    exit(1);
    4010:	4505                	li	a0,1
    4012:	00002097          	auipc	ra,0x2
    4016:	bea080e7          	jalr	-1046(ra) # 5bfc <exit>
    printf("%s: unlink dots failed!\n", s);
    401a:	85a6                	mv	a1,s1
    401c:	00004517          	auipc	a0,0x4
    4020:	abc50513          	add	a0,a0,-1348 # 7ad8 <malloc+0x1aac>
    4024:	00002097          	auipc	ra,0x2
    4028:	f50080e7          	jalr	-176(ra) # 5f74 <printf>
    exit(1);
    402c:	4505                	li	a0,1
    402e:	00002097          	auipc	ra,0x2
    4032:	bce080e7          	jalr	-1074(ra) # 5bfc <exit>

0000000000004036 <dirfile>:
{
    4036:	1101                	add	sp,sp,-32
    4038:	ec06                	sd	ra,24(sp)
    403a:	e822                	sd	s0,16(sp)
    403c:	e426                	sd	s1,8(sp)
    403e:	e04a                	sd	s2,0(sp)
    4040:	1000                	add	s0,sp,32
    4042:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    4044:	20000593          	li	a1,512
    4048:	00004517          	auipc	a0,0x4
    404c:	ab050513          	add	a0,a0,-1360 # 7af8 <malloc+0x1acc>
    4050:	00002097          	auipc	ra,0x2
    4054:	bec080e7          	jalr	-1044(ra) # 5c3c <open>
  if(fd < 0){
    4058:	0e054d63          	bltz	a0,4152 <dirfile+0x11c>
  close(fd);
    405c:	00002097          	auipc	ra,0x2
    4060:	bc8080e7          	jalr	-1080(ra) # 5c24 <close>
  if(chdir("dirfile") == 0){
    4064:	00004517          	auipc	a0,0x4
    4068:	a9450513          	add	a0,a0,-1388 # 7af8 <malloc+0x1acc>
    406c:	00002097          	auipc	ra,0x2
    4070:	c00080e7          	jalr	-1024(ra) # 5c6c <chdir>
    4074:	cd6d                	beqz	a0,416e <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    4076:	4581                	li	a1,0
    4078:	00004517          	auipc	a0,0x4
    407c:	ac850513          	add	a0,a0,-1336 # 7b40 <malloc+0x1b14>
    4080:	00002097          	auipc	ra,0x2
    4084:	bbc080e7          	jalr	-1092(ra) # 5c3c <open>
  if(fd >= 0){
    4088:	10055163          	bgez	a0,418a <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    408c:	20000593          	li	a1,512
    4090:	00004517          	auipc	a0,0x4
    4094:	ab050513          	add	a0,a0,-1360 # 7b40 <malloc+0x1b14>
    4098:	00002097          	auipc	ra,0x2
    409c:	ba4080e7          	jalr	-1116(ra) # 5c3c <open>
  if(fd >= 0){
    40a0:	10055363          	bgez	a0,41a6 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    40a4:	00004517          	auipc	a0,0x4
    40a8:	a9c50513          	add	a0,a0,-1380 # 7b40 <malloc+0x1b14>
    40ac:	00002097          	auipc	ra,0x2
    40b0:	bb8080e7          	jalr	-1096(ra) # 5c64 <mkdir>
    40b4:	10050763          	beqz	a0,41c2 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    40b8:	00004517          	auipc	a0,0x4
    40bc:	a8850513          	add	a0,a0,-1400 # 7b40 <malloc+0x1b14>
    40c0:	00002097          	auipc	ra,0x2
    40c4:	b8c080e7          	jalr	-1140(ra) # 5c4c <unlink>
    40c8:	10050b63          	beqz	a0,41de <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    40cc:	00004597          	auipc	a1,0x4
    40d0:	a7458593          	add	a1,a1,-1420 # 7b40 <malloc+0x1b14>
    40d4:	00002517          	auipc	a0,0x2
    40d8:	26c50513          	add	a0,a0,620 # 6340 <malloc+0x314>
    40dc:	00002097          	auipc	ra,0x2
    40e0:	b80080e7          	jalr	-1152(ra) # 5c5c <link>
    40e4:	10050b63          	beqz	a0,41fa <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    40e8:	00004517          	auipc	a0,0x4
    40ec:	a1050513          	add	a0,a0,-1520 # 7af8 <malloc+0x1acc>
    40f0:	00002097          	auipc	ra,0x2
    40f4:	b5c080e7          	jalr	-1188(ra) # 5c4c <unlink>
    40f8:	10051f63          	bnez	a0,4216 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    40fc:	4589                	li	a1,2
    40fe:	00002517          	auipc	a0,0x2
    4102:	75250513          	add	a0,a0,1874 # 6850 <malloc+0x824>
    4106:	00002097          	auipc	ra,0x2
    410a:	b36080e7          	jalr	-1226(ra) # 5c3c <open>
  if(fd >= 0){
    410e:	12055263          	bgez	a0,4232 <dirfile+0x1fc>
  fd = open(".", 0);
    4112:	4581                	li	a1,0
    4114:	00002517          	auipc	a0,0x2
    4118:	73c50513          	add	a0,a0,1852 # 6850 <malloc+0x824>
    411c:	00002097          	auipc	ra,0x2
    4120:	b20080e7          	jalr	-1248(ra) # 5c3c <open>
    4124:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    4126:	4605                	li	a2,1
    4128:	00002597          	auipc	a1,0x2
    412c:	0b058593          	add	a1,a1,176 # 61d8 <malloc+0x1ac>
    4130:	00002097          	auipc	ra,0x2
    4134:	aec080e7          	jalr	-1300(ra) # 5c1c <write>
    4138:	10a04b63          	bgtz	a0,424e <dirfile+0x218>
  close(fd);
    413c:	8526                	mv	a0,s1
    413e:	00002097          	auipc	ra,0x2
    4142:	ae6080e7          	jalr	-1306(ra) # 5c24 <close>
}
    4146:	60e2                	ld	ra,24(sp)
    4148:	6442                	ld	s0,16(sp)
    414a:	64a2                	ld	s1,8(sp)
    414c:	6902                	ld	s2,0(sp)
    414e:	6105                	add	sp,sp,32
    4150:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    4152:	85ca                	mv	a1,s2
    4154:	00004517          	auipc	a0,0x4
    4158:	9ac50513          	add	a0,a0,-1620 # 7b00 <malloc+0x1ad4>
    415c:	00002097          	auipc	ra,0x2
    4160:	e18080e7          	jalr	-488(ra) # 5f74 <printf>
    exit(1);
    4164:	4505                	li	a0,1
    4166:	00002097          	auipc	ra,0x2
    416a:	a96080e7          	jalr	-1386(ra) # 5bfc <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    416e:	85ca                	mv	a1,s2
    4170:	00004517          	auipc	a0,0x4
    4174:	9b050513          	add	a0,a0,-1616 # 7b20 <malloc+0x1af4>
    4178:	00002097          	auipc	ra,0x2
    417c:	dfc080e7          	jalr	-516(ra) # 5f74 <printf>
    exit(1);
    4180:	4505                	li	a0,1
    4182:	00002097          	auipc	ra,0x2
    4186:	a7a080e7          	jalr	-1414(ra) # 5bfc <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    418a:	85ca                	mv	a1,s2
    418c:	00004517          	auipc	a0,0x4
    4190:	9c450513          	add	a0,a0,-1596 # 7b50 <malloc+0x1b24>
    4194:	00002097          	auipc	ra,0x2
    4198:	de0080e7          	jalr	-544(ra) # 5f74 <printf>
    exit(1);
    419c:	4505                	li	a0,1
    419e:	00002097          	auipc	ra,0x2
    41a2:	a5e080e7          	jalr	-1442(ra) # 5bfc <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    41a6:	85ca                	mv	a1,s2
    41a8:	00004517          	auipc	a0,0x4
    41ac:	9a850513          	add	a0,a0,-1624 # 7b50 <malloc+0x1b24>
    41b0:	00002097          	auipc	ra,0x2
    41b4:	dc4080e7          	jalr	-572(ra) # 5f74 <printf>
    exit(1);
    41b8:	4505                	li	a0,1
    41ba:	00002097          	auipc	ra,0x2
    41be:	a42080e7          	jalr	-1470(ra) # 5bfc <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    41c2:	85ca                	mv	a1,s2
    41c4:	00004517          	auipc	a0,0x4
    41c8:	9b450513          	add	a0,a0,-1612 # 7b78 <malloc+0x1b4c>
    41cc:	00002097          	auipc	ra,0x2
    41d0:	da8080e7          	jalr	-600(ra) # 5f74 <printf>
    exit(1);
    41d4:	4505                	li	a0,1
    41d6:	00002097          	auipc	ra,0x2
    41da:	a26080e7          	jalr	-1498(ra) # 5bfc <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    41de:	85ca                	mv	a1,s2
    41e0:	00004517          	auipc	a0,0x4
    41e4:	9c050513          	add	a0,a0,-1600 # 7ba0 <malloc+0x1b74>
    41e8:	00002097          	auipc	ra,0x2
    41ec:	d8c080e7          	jalr	-628(ra) # 5f74 <printf>
    exit(1);
    41f0:	4505                	li	a0,1
    41f2:	00002097          	auipc	ra,0x2
    41f6:	a0a080e7          	jalr	-1526(ra) # 5bfc <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    41fa:	85ca                	mv	a1,s2
    41fc:	00004517          	auipc	a0,0x4
    4200:	9cc50513          	add	a0,a0,-1588 # 7bc8 <malloc+0x1b9c>
    4204:	00002097          	auipc	ra,0x2
    4208:	d70080e7          	jalr	-656(ra) # 5f74 <printf>
    exit(1);
    420c:	4505                	li	a0,1
    420e:	00002097          	auipc	ra,0x2
    4212:	9ee080e7          	jalr	-1554(ra) # 5bfc <exit>
    printf("%s: unlink dirfile failed!\n", s);
    4216:	85ca                	mv	a1,s2
    4218:	00004517          	auipc	a0,0x4
    421c:	9d850513          	add	a0,a0,-1576 # 7bf0 <malloc+0x1bc4>
    4220:	00002097          	auipc	ra,0x2
    4224:	d54080e7          	jalr	-684(ra) # 5f74 <printf>
    exit(1);
    4228:	4505                	li	a0,1
    422a:	00002097          	auipc	ra,0x2
    422e:	9d2080e7          	jalr	-1582(ra) # 5bfc <exit>
    printf("%s: open . for writing succeeded!\n", s);
    4232:	85ca                	mv	a1,s2
    4234:	00004517          	auipc	a0,0x4
    4238:	9dc50513          	add	a0,a0,-1572 # 7c10 <malloc+0x1be4>
    423c:	00002097          	auipc	ra,0x2
    4240:	d38080e7          	jalr	-712(ra) # 5f74 <printf>
    exit(1);
    4244:	4505                	li	a0,1
    4246:	00002097          	auipc	ra,0x2
    424a:	9b6080e7          	jalr	-1610(ra) # 5bfc <exit>
    printf("%s: write . succeeded!\n", s);
    424e:	85ca                	mv	a1,s2
    4250:	00004517          	auipc	a0,0x4
    4254:	9e850513          	add	a0,a0,-1560 # 7c38 <malloc+0x1c0c>
    4258:	00002097          	auipc	ra,0x2
    425c:	d1c080e7          	jalr	-740(ra) # 5f74 <printf>
    exit(1);
    4260:	4505                	li	a0,1
    4262:	00002097          	auipc	ra,0x2
    4266:	99a080e7          	jalr	-1638(ra) # 5bfc <exit>

000000000000426a <iref>:
{
    426a:	7139                	add	sp,sp,-64
    426c:	fc06                	sd	ra,56(sp)
    426e:	f822                	sd	s0,48(sp)
    4270:	f426                	sd	s1,40(sp)
    4272:	f04a                	sd	s2,32(sp)
    4274:	ec4e                	sd	s3,24(sp)
    4276:	e852                	sd	s4,16(sp)
    4278:	e456                	sd	s5,8(sp)
    427a:	e05a                	sd	s6,0(sp)
    427c:	0080                	add	s0,sp,64
    427e:	8b2a                	mv	s6,a0
    4280:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    4284:	00004a17          	auipc	s4,0x4
    4288:	9cca0a13          	add	s4,s4,-1588 # 7c50 <malloc+0x1c24>
    mkdir("");
    428c:	00003497          	auipc	s1,0x3
    4290:	4cc48493          	add	s1,s1,1228 # 7758 <malloc+0x172c>
    link("README", "");
    4294:	00002a97          	auipc	s5,0x2
    4298:	0aca8a93          	add	s5,s5,172 # 6340 <malloc+0x314>
    fd = open("xx", O_CREATE);
    429c:	00004997          	auipc	s3,0x4
    42a0:	8ac98993          	add	s3,s3,-1876 # 7b48 <malloc+0x1b1c>
    42a4:	a891                	j	42f8 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    42a6:	85da                	mv	a1,s6
    42a8:	00004517          	auipc	a0,0x4
    42ac:	9b050513          	add	a0,a0,-1616 # 7c58 <malloc+0x1c2c>
    42b0:	00002097          	auipc	ra,0x2
    42b4:	cc4080e7          	jalr	-828(ra) # 5f74 <printf>
      exit(1);
    42b8:	4505                	li	a0,1
    42ba:	00002097          	auipc	ra,0x2
    42be:	942080e7          	jalr	-1726(ra) # 5bfc <exit>
      printf("%s: chdir irefd failed\n", s);
    42c2:	85da                	mv	a1,s6
    42c4:	00004517          	auipc	a0,0x4
    42c8:	9ac50513          	add	a0,a0,-1620 # 7c70 <malloc+0x1c44>
    42cc:	00002097          	auipc	ra,0x2
    42d0:	ca8080e7          	jalr	-856(ra) # 5f74 <printf>
      exit(1);
    42d4:	4505                	li	a0,1
    42d6:	00002097          	auipc	ra,0x2
    42da:	926080e7          	jalr	-1754(ra) # 5bfc <exit>
      close(fd);
    42de:	00002097          	auipc	ra,0x2
    42e2:	946080e7          	jalr	-1722(ra) # 5c24 <close>
    42e6:	a889                	j	4338 <iref+0xce>
    unlink("xx");
    42e8:	854e                	mv	a0,s3
    42ea:	00002097          	auipc	ra,0x2
    42ee:	962080e7          	jalr	-1694(ra) # 5c4c <unlink>
  for(i = 0; i < NINODE + 1; i++){
    42f2:	397d                	addw	s2,s2,-1
    42f4:	06090063          	beqz	s2,4354 <iref+0xea>
    if(mkdir("irefd") != 0){
    42f8:	8552                	mv	a0,s4
    42fa:	00002097          	auipc	ra,0x2
    42fe:	96a080e7          	jalr	-1686(ra) # 5c64 <mkdir>
    4302:	f155                	bnez	a0,42a6 <iref+0x3c>
    if(chdir("irefd") != 0){
    4304:	8552                	mv	a0,s4
    4306:	00002097          	auipc	ra,0x2
    430a:	966080e7          	jalr	-1690(ra) # 5c6c <chdir>
    430e:	f955                	bnez	a0,42c2 <iref+0x58>
    mkdir("");
    4310:	8526                	mv	a0,s1
    4312:	00002097          	auipc	ra,0x2
    4316:	952080e7          	jalr	-1710(ra) # 5c64 <mkdir>
    link("README", "");
    431a:	85a6                	mv	a1,s1
    431c:	8556                	mv	a0,s5
    431e:	00002097          	auipc	ra,0x2
    4322:	93e080e7          	jalr	-1730(ra) # 5c5c <link>
    fd = open("", O_CREATE);
    4326:	20000593          	li	a1,512
    432a:	8526                	mv	a0,s1
    432c:	00002097          	auipc	ra,0x2
    4330:	910080e7          	jalr	-1776(ra) # 5c3c <open>
    if(fd >= 0)
    4334:	fa0555e3          	bgez	a0,42de <iref+0x74>
    fd = open("xx", O_CREATE);
    4338:	20000593          	li	a1,512
    433c:	854e                	mv	a0,s3
    433e:	00002097          	auipc	ra,0x2
    4342:	8fe080e7          	jalr	-1794(ra) # 5c3c <open>
    if(fd >= 0)
    4346:	fa0541e3          	bltz	a0,42e8 <iref+0x7e>
      close(fd);
    434a:	00002097          	auipc	ra,0x2
    434e:	8da080e7          	jalr	-1830(ra) # 5c24 <close>
    4352:	bf59                	j	42e8 <iref+0x7e>
    4354:	03300493          	li	s1,51
    chdir("..");
    4358:	00003997          	auipc	s3,0x3
    435c:	12098993          	add	s3,s3,288 # 7478 <malloc+0x144c>
    unlink("irefd");
    4360:	00004917          	auipc	s2,0x4
    4364:	8f090913          	add	s2,s2,-1808 # 7c50 <malloc+0x1c24>
    chdir("..");
    4368:	854e                	mv	a0,s3
    436a:	00002097          	auipc	ra,0x2
    436e:	902080e7          	jalr	-1790(ra) # 5c6c <chdir>
    unlink("irefd");
    4372:	854a                	mv	a0,s2
    4374:	00002097          	auipc	ra,0x2
    4378:	8d8080e7          	jalr	-1832(ra) # 5c4c <unlink>
  for(i = 0; i < NINODE + 1; i++){
    437c:	34fd                	addw	s1,s1,-1
    437e:	f4ed                	bnez	s1,4368 <iref+0xfe>
  chdir("/");
    4380:	00003517          	auipc	a0,0x3
    4384:	0a050513          	add	a0,a0,160 # 7420 <malloc+0x13f4>
    4388:	00002097          	auipc	ra,0x2
    438c:	8e4080e7          	jalr	-1820(ra) # 5c6c <chdir>
}
    4390:	70e2                	ld	ra,56(sp)
    4392:	7442                	ld	s0,48(sp)
    4394:	74a2                	ld	s1,40(sp)
    4396:	7902                	ld	s2,32(sp)
    4398:	69e2                	ld	s3,24(sp)
    439a:	6a42                	ld	s4,16(sp)
    439c:	6aa2                	ld	s5,8(sp)
    439e:	6b02                	ld	s6,0(sp)
    43a0:	6121                	add	sp,sp,64
    43a2:	8082                	ret

00000000000043a4 <openiputtest>:
{
    43a4:	7179                	add	sp,sp,-48
    43a6:	f406                	sd	ra,40(sp)
    43a8:	f022                	sd	s0,32(sp)
    43aa:	ec26                	sd	s1,24(sp)
    43ac:	1800                	add	s0,sp,48
    43ae:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    43b0:	00004517          	auipc	a0,0x4
    43b4:	8d850513          	add	a0,a0,-1832 # 7c88 <malloc+0x1c5c>
    43b8:	00002097          	auipc	ra,0x2
    43bc:	8ac080e7          	jalr	-1876(ra) # 5c64 <mkdir>
    43c0:	04054263          	bltz	a0,4404 <openiputtest+0x60>
  pid = fork();
    43c4:	00002097          	auipc	ra,0x2
    43c8:	830080e7          	jalr	-2000(ra) # 5bf4 <fork>
  if(pid < 0){
    43cc:	04054a63          	bltz	a0,4420 <openiputtest+0x7c>
  if(pid == 0){
    43d0:	e93d                	bnez	a0,4446 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    43d2:	4589                	li	a1,2
    43d4:	00004517          	auipc	a0,0x4
    43d8:	8b450513          	add	a0,a0,-1868 # 7c88 <malloc+0x1c5c>
    43dc:	00002097          	auipc	ra,0x2
    43e0:	860080e7          	jalr	-1952(ra) # 5c3c <open>
    if(fd >= 0){
    43e4:	04054c63          	bltz	a0,443c <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    43e8:	85a6                	mv	a1,s1
    43ea:	00004517          	auipc	a0,0x4
    43ee:	8be50513          	add	a0,a0,-1858 # 7ca8 <malloc+0x1c7c>
    43f2:	00002097          	auipc	ra,0x2
    43f6:	b82080e7          	jalr	-1150(ra) # 5f74 <printf>
      exit(1);
    43fa:	4505                	li	a0,1
    43fc:	00002097          	auipc	ra,0x2
    4400:	800080e7          	jalr	-2048(ra) # 5bfc <exit>
    printf("%s: mkdir oidir failed\n", s);
    4404:	85a6                	mv	a1,s1
    4406:	00004517          	auipc	a0,0x4
    440a:	88a50513          	add	a0,a0,-1910 # 7c90 <malloc+0x1c64>
    440e:	00002097          	auipc	ra,0x2
    4412:	b66080e7          	jalr	-1178(ra) # 5f74 <printf>
    exit(1);
    4416:	4505                	li	a0,1
    4418:	00001097          	auipc	ra,0x1
    441c:	7e4080e7          	jalr	2020(ra) # 5bfc <exit>
    printf("%s: fork failed\n", s);
    4420:	85a6                	mv	a1,s1
    4422:	00002517          	auipc	a0,0x2
    4426:	5ce50513          	add	a0,a0,1486 # 69f0 <malloc+0x9c4>
    442a:	00002097          	auipc	ra,0x2
    442e:	b4a080e7          	jalr	-1206(ra) # 5f74 <printf>
    exit(1);
    4432:	4505                	li	a0,1
    4434:	00001097          	auipc	ra,0x1
    4438:	7c8080e7          	jalr	1992(ra) # 5bfc <exit>
    exit(0);
    443c:	4501                	li	a0,0
    443e:	00001097          	auipc	ra,0x1
    4442:	7be080e7          	jalr	1982(ra) # 5bfc <exit>
  sleep(1);
    4446:	4505                	li	a0,1
    4448:	00002097          	auipc	ra,0x2
    444c:	844080e7          	jalr	-1980(ra) # 5c8c <sleep>
  if(unlink("oidir") != 0){
    4450:	00004517          	auipc	a0,0x4
    4454:	83850513          	add	a0,a0,-1992 # 7c88 <malloc+0x1c5c>
    4458:	00001097          	auipc	ra,0x1
    445c:	7f4080e7          	jalr	2036(ra) # 5c4c <unlink>
    4460:	cd19                	beqz	a0,447e <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    4462:	85a6                	mv	a1,s1
    4464:	00002517          	auipc	a0,0x2
    4468:	77c50513          	add	a0,a0,1916 # 6be0 <malloc+0xbb4>
    446c:	00002097          	auipc	ra,0x2
    4470:	b08080e7          	jalr	-1272(ra) # 5f74 <printf>
    exit(1);
    4474:	4505                	li	a0,1
    4476:	00001097          	auipc	ra,0x1
    447a:	786080e7          	jalr	1926(ra) # 5bfc <exit>
  wait(&xstatus);
    447e:	fdc40513          	add	a0,s0,-36
    4482:	00001097          	auipc	ra,0x1
    4486:	782080e7          	jalr	1922(ra) # 5c04 <wait>
  exit(xstatus);
    448a:	fdc42503          	lw	a0,-36(s0)
    448e:	00001097          	auipc	ra,0x1
    4492:	76e080e7          	jalr	1902(ra) # 5bfc <exit>

0000000000004496 <forkforkfork>:
{
    4496:	1101                	add	sp,sp,-32
    4498:	ec06                	sd	ra,24(sp)
    449a:	e822                	sd	s0,16(sp)
    449c:	e426                	sd	s1,8(sp)
    449e:	1000                	add	s0,sp,32
    44a0:	84aa                	mv	s1,a0
  unlink("stopforking");
    44a2:	00004517          	auipc	a0,0x4
    44a6:	82e50513          	add	a0,a0,-2002 # 7cd0 <malloc+0x1ca4>
    44aa:	00001097          	auipc	ra,0x1
    44ae:	7a2080e7          	jalr	1954(ra) # 5c4c <unlink>
  int pid = fork();
    44b2:	00001097          	auipc	ra,0x1
    44b6:	742080e7          	jalr	1858(ra) # 5bf4 <fork>
  if(pid < 0){
    44ba:	04054563          	bltz	a0,4504 <forkforkfork+0x6e>
  if(pid == 0){
    44be:	c12d                	beqz	a0,4520 <forkforkfork+0x8a>
  sleep(20); // two seconds
    44c0:	4551                	li	a0,20
    44c2:	00001097          	auipc	ra,0x1
    44c6:	7ca080e7          	jalr	1994(ra) # 5c8c <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    44ca:	20200593          	li	a1,514
    44ce:	00004517          	auipc	a0,0x4
    44d2:	80250513          	add	a0,a0,-2046 # 7cd0 <malloc+0x1ca4>
    44d6:	00001097          	auipc	ra,0x1
    44da:	766080e7          	jalr	1894(ra) # 5c3c <open>
    44de:	00001097          	auipc	ra,0x1
    44e2:	746080e7          	jalr	1862(ra) # 5c24 <close>
  wait(0);
    44e6:	4501                	li	a0,0
    44e8:	00001097          	auipc	ra,0x1
    44ec:	71c080e7          	jalr	1820(ra) # 5c04 <wait>
  sleep(10); // one second
    44f0:	4529                	li	a0,10
    44f2:	00001097          	auipc	ra,0x1
    44f6:	79a080e7          	jalr	1946(ra) # 5c8c <sleep>
}
    44fa:	60e2                	ld	ra,24(sp)
    44fc:	6442                	ld	s0,16(sp)
    44fe:	64a2                	ld	s1,8(sp)
    4500:	6105                	add	sp,sp,32
    4502:	8082                	ret
    printf("%s: fork failed", s);
    4504:	85a6                	mv	a1,s1
    4506:	00002517          	auipc	a0,0x2
    450a:	6aa50513          	add	a0,a0,1706 # 6bb0 <malloc+0xb84>
    450e:	00002097          	auipc	ra,0x2
    4512:	a66080e7          	jalr	-1434(ra) # 5f74 <printf>
    exit(1);
    4516:	4505                	li	a0,1
    4518:	00001097          	auipc	ra,0x1
    451c:	6e4080e7          	jalr	1764(ra) # 5bfc <exit>
      int fd = open("stopforking", 0);
    4520:	00003497          	auipc	s1,0x3
    4524:	7b048493          	add	s1,s1,1968 # 7cd0 <malloc+0x1ca4>
    4528:	4581                	li	a1,0
    452a:	8526                	mv	a0,s1
    452c:	00001097          	auipc	ra,0x1
    4530:	710080e7          	jalr	1808(ra) # 5c3c <open>
      if(fd >= 0){
    4534:	02055763          	bgez	a0,4562 <forkforkfork+0xcc>
      if(fork() < 0){
    4538:	00001097          	auipc	ra,0x1
    453c:	6bc080e7          	jalr	1724(ra) # 5bf4 <fork>
    4540:	fe0554e3          	bgez	a0,4528 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    4544:	20200593          	li	a1,514
    4548:	00003517          	auipc	a0,0x3
    454c:	78850513          	add	a0,a0,1928 # 7cd0 <malloc+0x1ca4>
    4550:	00001097          	auipc	ra,0x1
    4554:	6ec080e7          	jalr	1772(ra) # 5c3c <open>
    4558:	00001097          	auipc	ra,0x1
    455c:	6cc080e7          	jalr	1740(ra) # 5c24 <close>
    4560:	b7e1                	j	4528 <forkforkfork+0x92>
        exit(0);
    4562:	4501                	li	a0,0
    4564:	00001097          	auipc	ra,0x1
    4568:	698080e7          	jalr	1688(ra) # 5bfc <exit>

000000000000456c <killstatus>:
{
    456c:	7139                	add	sp,sp,-64
    456e:	fc06                	sd	ra,56(sp)
    4570:	f822                	sd	s0,48(sp)
    4572:	f426                	sd	s1,40(sp)
    4574:	f04a                	sd	s2,32(sp)
    4576:	ec4e                	sd	s3,24(sp)
    4578:	e852                	sd	s4,16(sp)
    457a:	0080                	add	s0,sp,64
    457c:	8a2a                	mv	s4,a0
    457e:	06400913          	li	s2,100
    if(xst != -1) {
    4582:	59fd                	li	s3,-1
    int pid1 = fork();
    4584:	00001097          	auipc	ra,0x1
    4588:	670080e7          	jalr	1648(ra) # 5bf4 <fork>
    458c:	84aa                	mv	s1,a0
    if(pid1 < 0){
    458e:	02054f63          	bltz	a0,45cc <killstatus+0x60>
    if(pid1 == 0){
    4592:	c939                	beqz	a0,45e8 <killstatus+0x7c>
    sleep(1);
    4594:	4505                	li	a0,1
    4596:	00001097          	auipc	ra,0x1
    459a:	6f6080e7          	jalr	1782(ra) # 5c8c <sleep>
    kill(pid1);
    459e:	8526                	mv	a0,s1
    45a0:	00001097          	auipc	ra,0x1
    45a4:	68c080e7          	jalr	1676(ra) # 5c2c <kill>
    wait(&xst);
    45a8:	fcc40513          	add	a0,s0,-52
    45ac:	00001097          	auipc	ra,0x1
    45b0:	658080e7          	jalr	1624(ra) # 5c04 <wait>
    if(xst != -1) {
    45b4:	fcc42783          	lw	a5,-52(s0)
    45b8:	03379d63          	bne	a5,s3,45f2 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    45bc:	397d                	addw	s2,s2,-1
    45be:	fc0913e3          	bnez	s2,4584 <killstatus+0x18>
  exit(0);
    45c2:	4501                	li	a0,0
    45c4:	00001097          	auipc	ra,0x1
    45c8:	638080e7          	jalr	1592(ra) # 5bfc <exit>
      printf("%s: fork failed\n", s);
    45cc:	85d2                	mv	a1,s4
    45ce:	00002517          	auipc	a0,0x2
    45d2:	42250513          	add	a0,a0,1058 # 69f0 <malloc+0x9c4>
    45d6:	00002097          	auipc	ra,0x2
    45da:	99e080e7          	jalr	-1634(ra) # 5f74 <printf>
      exit(1);
    45de:	4505                	li	a0,1
    45e0:	00001097          	auipc	ra,0x1
    45e4:	61c080e7          	jalr	1564(ra) # 5bfc <exit>
        getpid();
    45e8:	00001097          	auipc	ra,0x1
    45ec:	694080e7          	jalr	1684(ra) # 5c7c <getpid>
      while(1) {
    45f0:	bfe5                	j	45e8 <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    45f2:	85d2                	mv	a1,s4
    45f4:	00003517          	auipc	a0,0x3
    45f8:	6ec50513          	add	a0,a0,1772 # 7ce0 <malloc+0x1cb4>
    45fc:	00002097          	auipc	ra,0x2
    4600:	978080e7          	jalr	-1672(ra) # 5f74 <printf>
       exit(1);
    4604:	4505                	li	a0,1
    4606:	00001097          	auipc	ra,0x1
    460a:	5f6080e7          	jalr	1526(ra) # 5bfc <exit>

000000000000460e <preempt>:
{
    460e:	7139                	add	sp,sp,-64
    4610:	fc06                	sd	ra,56(sp)
    4612:	f822                	sd	s0,48(sp)
    4614:	f426                	sd	s1,40(sp)
    4616:	f04a                	sd	s2,32(sp)
    4618:	ec4e                	sd	s3,24(sp)
    461a:	e852                	sd	s4,16(sp)
    461c:	0080                	add	s0,sp,64
    461e:	892a                	mv	s2,a0
  pid1 = fork();
    4620:	00001097          	auipc	ra,0x1
    4624:	5d4080e7          	jalr	1492(ra) # 5bf4 <fork>
  if(pid1 < 0) {
    4628:	00054563          	bltz	a0,4632 <preempt+0x24>
    462c:	84aa                	mv	s1,a0
  if(pid1 == 0)
    462e:	e105                	bnez	a0,464e <preempt+0x40>
    for(;;)
    4630:	a001                	j	4630 <preempt+0x22>
    printf("%s: fork failed", s);
    4632:	85ca                	mv	a1,s2
    4634:	00002517          	auipc	a0,0x2
    4638:	57c50513          	add	a0,a0,1404 # 6bb0 <malloc+0xb84>
    463c:	00002097          	auipc	ra,0x2
    4640:	938080e7          	jalr	-1736(ra) # 5f74 <printf>
    exit(1);
    4644:	4505                	li	a0,1
    4646:	00001097          	auipc	ra,0x1
    464a:	5b6080e7          	jalr	1462(ra) # 5bfc <exit>
  pid2 = fork();
    464e:	00001097          	auipc	ra,0x1
    4652:	5a6080e7          	jalr	1446(ra) # 5bf4 <fork>
    4656:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    4658:	00054463          	bltz	a0,4660 <preempt+0x52>
  if(pid2 == 0)
    465c:	e105                	bnez	a0,467c <preempt+0x6e>
    for(;;)
    465e:	a001                	j	465e <preempt+0x50>
    printf("%s: fork failed\n", s);
    4660:	85ca                	mv	a1,s2
    4662:	00002517          	auipc	a0,0x2
    4666:	38e50513          	add	a0,a0,910 # 69f0 <malloc+0x9c4>
    466a:	00002097          	auipc	ra,0x2
    466e:	90a080e7          	jalr	-1782(ra) # 5f74 <printf>
    exit(1);
    4672:	4505                	li	a0,1
    4674:	00001097          	auipc	ra,0x1
    4678:	588080e7          	jalr	1416(ra) # 5bfc <exit>
  pipe(pfds);
    467c:	fc840513          	add	a0,s0,-56
    4680:	00001097          	auipc	ra,0x1
    4684:	58c080e7          	jalr	1420(ra) # 5c0c <pipe>
  pid3 = fork();
    4688:	00001097          	auipc	ra,0x1
    468c:	56c080e7          	jalr	1388(ra) # 5bf4 <fork>
    4690:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    4692:	02054e63          	bltz	a0,46ce <preempt+0xc0>
  if(pid3 == 0){
    4696:	e525                	bnez	a0,46fe <preempt+0xf0>
    close(pfds[0]);
    4698:	fc842503          	lw	a0,-56(s0)
    469c:	00001097          	auipc	ra,0x1
    46a0:	588080e7          	jalr	1416(ra) # 5c24 <close>
    if(write(pfds[1], "x", 1) != 1)
    46a4:	4605                	li	a2,1
    46a6:	00002597          	auipc	a1,0x2
    46aa:	b3258593          	add	a1,a1,-1230 # 61d8 <malloc+0x1ac>
    46ae:	fcc42503          	lw	a0,-52(s0)
    46b2:	00001097          	auipc	ra,0x1
    46b6:	56a080e7          	jalr	1386(ra) # 5c1c <write>
    46ba:	4785                	li	a5,1
    46bc:	02f51763          	bne	a0,a5,46ea <preempt+0xdc>
    close(pfds[1]);
    46c0:	fcc42503          	lw	a0,-52(s0)
    46c4:	00001097          	auipc	ra,0x1
    46c8:	560080e7          	jalr	1376(ra) # 5c24 <close>
    for(;;)
    46cc:	a001                	j	46cc <preempt+0xbe>
     printf("%s: fork failed\n", s);
    46ce:	85ca                	mv	a1,s2
    46d0:	00002517          	auipc	a0,0x2
    46d4:	32050513          	add	a0,a0,800 # 69f0 <malloc+0x9c4>
    46d8:	00002097          	auipc	ra,0x2
    46dc:	89c080e7          	jalr	-1892(ra) # 5f74 <printf>
     exit(1);
    46e0:	4505                	li	a0,1
    46e2:	00001097          	auipc	ra,0x1
    46e6:	51a080e7          	jalr	1306(ra) # 5bfc <exit>
      printf("%s: preempt write error", s);
    46ea:	85ca                	mv	a1,s2
    46ec:	00003517          	auipc	a0,0x3
    46f0:	61450513          	add	a0,a0,1556 # 7d00 <malloc+0x1cd4>
    46f4:	00002097          	auipc	ra,0x2
    46f8:	880080e7          	jalr	-1920(ra) # 5f74 <printf>
    46fc:	b7d1                	j	46c0 <preempt+0xb2>
  close(pfds[1]);
    46fe:	fcc42503          	lw	a0,-52(s0)
    4702:	00001097          	auipc	ra,0x1
    4706:	522080e7          	jalr	1314(ra) # 5c24 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    470a:	660d                	lui	a2,0x3
    470c:	00008597          	auipc	a1,0x8
    4710:	56c58593          	add	a1,a1,1388 # cc78 <buf>
    4714:	fc842503          	lw	a0,-56(s0)
    4718:	00001097          	auipc	ra,0x1
    471c:	4fc080e7          	jalr	1276(ra) # 5c14 <read>
    4720:	4785                	li	a5,1
    4722:	02f50363          	beq	a0,a5,4748 <preempt+0x13a>
    printf("%s: preempt read error", s);
    4726:	85ca                	mv	a1,s2
    4728:	00003517          	auipc	a0,0x3
    472c:	5f050513          	add	a0,a0,1520 # 7d18 <malloc+0x1cec>
    4730:	00002097          	auipc	ra,0x2
    4734:	844080e7          	jalr	-1980(ra) # 5f74 <printf>
}
    4738:	70e2                	ld	ra,56(sp)
    473a:	7442                	ld	s0,48(sp)
    473c:	74a2                	ld	s1,40(sp)
    473e:	7902                	ld	s2,32(sp)
    4740:	69e2                	ld	s3,24(sp)
    4742:	6a42                	ld	s4,16(sp)
    4744:	6121                	add	sp,sp,64
    4746:	8082                	ret
  close(pfds[0]);
    4748:	fc842503          	lw	a0,-56(s0)
    474c:	00001097          	auipc	ra,0x1
    4750:	4d8080e7          	jalr	1240(ra) # 5c24 <close>
  printf("kill... ");
    4754:	00003517          	auipc	a0,0x3
    4758:	5dc50513          	add	a0,a0,1500 # 7d30 <malloc+0x1d04>
    475c:	00002097          	auipc	ra,0x2
    4760:	818080e7          	jalr	-2024(ra) # 5f74 <printf>
  kill(pid1);
    4764:	8526                	mv	a0,s1
    4766:	00001097          	auipc	ra,0x1
    476a:	4c6080e7          	jalr	1222(ra) # 5c2c <kill>
  kill(pid2);
    476e:	854e                	mv	a0,s3
    4770:	00001097          	auipc	ra,0x1
    4774:	4bc080e7          	jalr	1212(ra) # 5c2c <kill>
  kill(pid3);
    4778:	8552                	mv	a0,s4
    477a:	00001097          	auipc	ra,0x1
    477e:	4b2080e7          	jalr	1202(ra) # 5c2c <kill>
  printf("wait... ");
    4782:	00003517          	auipc	a0,0x3
    4786:	5be50513          	add	a0,a0,1470 # 7d40 <malloc+0x1d14>
    478a:	00001097          	auipc	ra,0x1
    478e:	7ea080e7          	jalr	2026(ra) # 5f74 <printf>
  wait(0);
    4792:	4501                	li	a0,0
    4794:	00001097          	auipc	ra,0x1
    4798:	470080e7          	jalr	1136(ra) # 5c04 <wait>
  wait(0);
    479c:	4501                	li	a0,0
    479e:	00001097          	auipc	ra,0x1
    47a2:	466080e7          	jalr	1126(ra) # 5c04 <wait>
  wait(0);
    47a6:	4501                	li	a0,0
    47a8:	00001097          	auipc	ra,0x1
    47ac:	45c080e7          	jalr	1116(ra) # 5c04 <wait>
    47b0:	b761                	j	4738 <preempt+0x12a>

00000000000047b2 <reparent>:
{
    47b2:	7179                	add	sp,sp,-48
    47b4:	f406                	sd	ra,40(sp)
    47b6:	f022                	sd	s0,32(sp)
    47b8:	ec26                	sd	s1,24(sp)
    47ba:	e84a                	sd	s2,16(sp)
    47bc:	e44e                	sd	s3,8(sp)
    47be:	e052                	sd	s4,0(sp)
    47c0:	1800                	add	s0,sp,48
    47c2:	89aa                	mv	s3,a0
  int master_pid = getpid();
    47c4:	00001097          	auipc	ra,0x1
    47c8:	4b8080e7          	jalr	1208(ra) # 5c7c <getpid>
    47cc:	8a2a                	mv	s4,a0
    47ce:	0c800913          	li	s2,200
    int pid = fork();
    47d2:	00001097          	auipc	ra,0x1
    47d6:	422080e7          	jalr	1058(ra) # 5bf4 <fork>
    47da:	84aa                	mv	s1,a0
    if(pid < 0){
    47dc:	02054263          	bltz	a0,4800 <reparent+0x4e>
    if(pid){
    47e0:	cd21                	beqz	a0,4838 <reparent+0x86>
      if(wait(0) != pid){
    47e2:	4501                	li	a0,0
    47e4:	00001097          	auipc	ra,0x1
    47e8:	420080e7          	jalr	1056(ra) # 5c04 <wait>
    47ec:	02951863          	bne	a0,s1,481c <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    47f0:	397d                	addw	s2,s2,-1
    47f2:	fe0910e3          	bnez	s2,47d2 <reparent+0x20>
  exit(0);
    47f6:	4501                	li	a0,0
    47f8:	00001097          	auipc	ra,0x1
    47fc:	404080e7          	jalr	1028(ra) # 5bfc <exit>
      printf("%s: fork failed\n", s);
    4800:	85ce                	mv	a1,s3
    4802:	00002517          	auipc	a0,0x2
    4806:	1ee50513          	add	a0,a0,494 # 69f0 <malloc+0x9c4>
    480a:	00001097          	auipc	ra,0x1
    480e:	76a080e7          	jalr	1898(ra) # 5f74 <printf>
      exit(1);
    4812:	4505                	li	a0,1
    4814:	00001097          	auipc	ra,0x1
    4818:	3e8080e7          	jalr	1000(ra) # 5bfc <exit>
        printf("%s: wait wrong pid\n", s);
    481c:	85ce                	mv	a1,s3
    481e:	00002517          	auipc	a0,0x2
    4822:	35a50513          	add	a0,a0,858 # 6b78 <malloc+0xb4c>
    4826:	00001097          	auipc	ra,0x1
    482a:	74e080e7          	jalr	1870(ra) # 5f74 <printf>
        exit(1);
    482e:	4505                	li	a0,1
    4830:	00001097          	auipc	ra,0x1
    4834:	3cc080e7          	jalr	972(ra) # 5bfc <exit>
      int pid2 = fork();
    4838:	00001097          	auipc	ra,0x1
    483c:	3bc080e7          	jalr	956(ra) # 5bf4 <fork>
      if(pid2 < 0){
    4840:	00054763          	bltz	a0,484e <reparent+0x9c>
      exit(0);
    4844:	4501                	li	a0,0
    4846:	00001097          	auipc	ra,0x1
    484a:	3b6080e7          	jalr	950(ra) # 5bfc <exit>
        kill(master_pid);
    484e:	8552                	mv	a0,s4
    4850:	00001097          	auipc	ra,0x1
    4854:	3dc080e7          	jalr	988(ra) # 5c2c <kill>
        exit(1);
    4858:	4505                	li	a0,1
    485a:	00001097          	auipc	ra,0x1
    485e:	3a2080e7          	jalr	930(ra) # 5bfc <exit>

0000000000004862 <sbrkfail>:
{
    4862:	7119                	add	sp,sp,-128
    4864:	fc86                	sd	ra,120(sp)
    4866:	f8a2                	sd	s0,112(sp)
    4868:	f4a6                	sd	s1,104(sp)
    486a:	f0ca                	sd	s2,96(sp)
    486c:	ecce                	sd	s3,88(sp)
    486e:	e8d2                	sd	s4,80(sp)
    4870:	e4d6                	sd	s5,72(sp)
    4872:	0100                	add	s0,sp,128
    4874:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    4876:	fb040513          	add	a0,s0,-80
    487a:	00001097          	auipc	ra,0x1
    487e:	392080e7          	jalr	914(ra) # 5c0c <pipe>
    4882:	e901                	bnez	a0,4892 <sbrkfail+0x30>
    4884:	f8040493          	add	s1,s0,-128
    4888:	fa840993          	add	s3,s0,-88
    488c:	8926                	mv	s2,s1
    if(pids[i] != -1)
    488e:	5a7d                	li	s4,-1
    4890:	a085                	j	48f0 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    4892:	85d6                	mv	a1,s5
    4894:	00002517          	auipc	a0,0x2
    4898:	26450513          	add	a0,a0,612 # 6af8 <malloc+0xacc>
    489c:	00001097          	auipc	ra,0x1
    48a0:	6d8080e7          	jalr	1752(ra) # 5f74 <printf>
    exit(1);
    48a4:	4505                	li	a0,1
    48a6:	00001097          	auipc	ra,0x1
    48aa:	356080e7          	jalr	854(ra) # 5bfc <exit>
      sbrk(BIG - (uint64)sbrk(0));
    48ae:	00001097          	auipc	ra,0x1
    48b2:	3d6080e7          	jalr	982(ra) # 5c84 <sbrk>
    48b6:	064007b7          	lui	a5,0x6400
    48ba:	40a7853b          	subw	a0,a5,a0
    48be:	00001097          	auipc	ra,0x1
    48c2:	3c6080e7          	jalr	966(ra) # 5c84 <sbrk>
      write(fds[1], "x", 1);
    48c6:	4605                	li	a2,1
    48c8:	00002597          	auipc	a1,0x2
    48cc:	91058593          	add	a1,a1,-1776 # 61d8 <malloc+0x1ac>
    48d0:	fb442503          	lw	a0,-76(s0)
    48d4:	00001097          	auipc	ra,0x1
    48d8:	348080e7          	jalr	840(ra) # 5c1c <write>
      for(;;) sleep(1000);
    48dc:	3e800513          	li	a0,1000
    48e0:	00001097          	auipc	ra,0x1
    48e4:	3ac080e7          	jalr	940(ra) # 5c8c <sleep>
    48e8:	bfd5                	j	48dc <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    48ea:	0911                	add	s2,s2,4
    48ec:	03390563          	beq	s2,s3,4916 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    48f0:	00001097          	auipc	ra,0x1
    48f4:	304080e7          	jalr	772(ra) # 5bf4 <fork>
    48f8:	00a92023          	sw	a0,0(s2)
    48fc:	d94d                	beqz	a0,48ae <sbrkfail+0x4c>
    if(pids[i] != -1)
    48fe:	ff4506e3          	beq	a0,s4,48ea <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4902:	4605                	li	a2,1
    4904:	faf40593          	add	a1,s0,-81
    4908:	fb042503          	lw	a0,-80(s0)
    490c:	00001097          	auipc	ra,0x1
    4910:	308080e7          	jalr	776(ra) # 5c14 <read>
    4914:	bfd9                	j	48ea <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4916:	6505                	lui	a0,0x1
    4918:	00001097          	auipc	ra,0x1
    491c:	36c080e7          	jalr	876(ra) # 5c84 <sbrk>
    4920:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4922:	597d                	li	s2,-1
    4924:	a021                	j	492c <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4926:	0491                	add	s1,s1,4
    4928:	01348f63          	beq	s1,s3,4946 <sbrkfail+0xe4>
    if(pids[i] == -1)
    492c:	4088                	lw	a0,0(s1)
    492e:	ff250ce3          	beq	a0,s2,4926 <sbrkfail+0xc4>
    kill(pids[i]);
    4932:	00001097          	auipc	ra,0x1
    4936:	2fa080e7          	jalr	762(ra) # 5c2c <kill>
    wait(0);
    493a:	4501                	li	a0,0
    493c:	00001097          	auipc	ra,0x1
    4940:	2c8080e7          	jalr	712(ra) # 5c04 <wait>
    4944:	b7cd                	j	4926 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4946:	57fd                	li	a5,-1
    4948:	04fa0163          	beq	s4,a5,498a <sbrkfail+0x128>
  pid = fork();
    494c:	00001097          	auipc	ra,0x1
    4950:	2a8080e7          	jalr	680(ra) # 5bf4 <fork>
    4954:	84aa                	mv	s1,a0
  if(pid < 0){
    4956:	04054863          	bltz	a0,49a6 <sbrkfail+0x144>
  if(pid == 0){
    495a:	c525                	beqz	a0,49c2 <sbrkfail+0x160>
  wait(&xstatus);
    495c:	fbc40513          	add	a0,s0,-68
    4960:	00001097          	auipc	ra,0x1
    4964:	2a4080e7          	jalr	676(ra) # 5c04 <wait>
  if(xstatus != -1 && xstatus != 2)
    4968:	fbc42783          	lw	a5,-68(s0)
    496c:	577d                	li	a4,-1
    496e:	00e78563          	beq	a5,a4,4978 <sbrkfail+0x116>
    4972:	4709                	li	a4,2
    4974:	08e79d63          	bne	a5,a4,4a0e <sbrkfail+0x1ac>
}
    4978:	70e6                	ld	ra,120(sp)
    497a:	7446                	ld	s0,112(sp)
    497c:	74a6                	ld	s1,104(sp)
    497e:	7906                	ld	s2,96(sp)
    4980:	69e6                	ld	s3,88(sp)
    4982:	6a46                	ld	s4,80(sp)
    4984:	6aa6                	ld	s5,72(sp)
    4986:	6109                	add	sp,sp,128
    4988:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    498a:	85d6                	mv	a1,s5
    498c:	00003517          	auipc	a0,0x3
    4990:	3c450513          	add	a0,a0,964 # 7d50 <malloc+0x1d24>
    4994:	00001097          	auipc	ra,0x1
    4998:	5e0080e7          	jalr	1504(ra) # 5f74 <printf>
    exit(1);
    499c:	4505                	li	a0,1
    499e:	00001097          	auipc	ra,0x1
    49a2:	25e080e7          	jalr	606(ra) # 5bfc <exit>
    printf("%s: fork failed\n", s);
    49a6:	85d6                	mv	a1,s5
    49a8:	00002517          	auipc	a0,0x2
    49ac:	04850513          	add	a0,a0,72 # 69f0 <malloc+0x9c4>
    49b0:	00001097          	auipc	ra,0x1
    49b4:	5c4080e7          	jalr	1476(ra) # 5f74 <printf>
    exit(1);
    49b8:	4505                	li	a0,1
    49ba:	00001097          	auipc	ra,0x1
    49be:	242080e7          	jalr	578(ra) # 5bfc <exit>
    a = sbrk(0);
    49c2:	4501                	li	a0,0
    49c4:	00001097          	auipc	ra,0x1
    49c8:	2c0080e7          	jalr	704(ra) # 5c84 <sbrk>
    49cc:	892a                	mv	s2,a0
    sbrk(10*BIG);
    49ce:	3e800537          	lui	a0,0x3e800
    49d2:	00001097          	auipc	ra,0x1
    49d6:	2b2080e7          	jalr	690(ra) # 5c84 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    49da:	87ca                	mv	a5,s2
    49dc:	3e800737          	lui	a4,0x3e800
    49e0:	993a                	add	s2,s2,a4
    49e2:	6705                	lui	a4,0x1
      n += *(a+i);
    49e4:	0007c683          	lbu	a3,0(a5) # 6400000 <base+0x63f0388>
    49e8:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    49ea:	97ba                	add	a5,a5,a4
    49ec:	fef91ce3          	bne	s2,a5,49e4 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    49f0:	8626                	mv	a2,s1
    49f2:	85d6                	mv	a1,s5
    49f4:	00003517          	auipc	a0,0x3
    49f8:	37c50513          	add	a0,a0,892 # 7d70 <malloc+0x1d44>
    49fc:	00001097          	auipc	ra,0x1
    4a00:	578080e7          	jalr	1400(ra) # 5f74 <printf>
    exit(1);
    4a04:	4505                	li	a0,1
    4a06:	00001097          	auipc	ra,0x1
    4a0a:	1f6080e7          	jalr	502(ra) # 5bfc <exit>
    exit(1);
    4a0e:	4505                	li	a0,1
    4a10:	00001097          	auipc	ra,0x1
    4a14:	1ec080e7          	jalr	492(ra) # 5bfc <exit>

0000000000004a18 <mem>:
{
    4a18:	7139                	add	sp,sp,-64
    4a1a:	fc06                	sd	ra,56(sp)
    4a1c:	f822                	sd	s0,48(sp)
    4a1e:	f426                	sd	s1,40(sp)
    4a20:	f04a                	sd	s2,32(sp)
    4a22:	ec4e                	sd	s3,24(sp)
    4a24:	0080                	add	s0,sp,64
    4a26:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    4a28:	00001097          	auipc	ra,0x1
    4a2c:	1cc080e7          	jalr	460(ra) # 5bf4 <fork>
    m1 = 0;
    4a30:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4a32:	6909                	lui	s2,0x2
    4a34:	71190913          	add	s2,s2,1809 # 2711 <copyinstr3+0xd1>
  if((pid = fork()) == 0){
    4a38:	c115                	beqz	a0,4a5c <mem+0x44>
    wait(&xstatus);
    4a3a:	fcc40513          	add	a0,s0,-52
    4a3e:	00001097          	auipc	ra,0x1
    4a42:	1c6080e7          	jalr	454(ra) # 5c04 <wait>
    if(xstatus == -1){
    4a46:	fcc42503          	lw	a0,-52(s0)
    4a4a:	57fd                	li	a5,-1
    4a4c:	06f50363          	beq	a0,a5,4ab2 <mem+0x9a>
    exit(xstatus);
    4a50:	00001097          	auipc	ra,0x1
    4a54:	1ac080e7          	jalr	428(ra) # 5bfc <exit>
      *(char**)m2 = m1;
    4a58:	e104                	sd	s1,0(a0)
      m1 = m2;
    4a5a:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    4a5c:	854a                	mv	a0,s2
    4a5e:	00001097          	auipc	ra,0x1
    4a62:	5ce080e7          	jalr	1486(ra) # 602c <malloc>
    4a66:	f96d                	bnez	a0,4a58 <mem+0x40>
    while(m1){
    4a68:	c881                	beqz	s1,4a78 <mem+0x60>
      m2 = *(char**)m1;
    4a6a:	8526                	mv	a0,s1
    4a6c:	6084                	ld	s1,0(s1)
      free(m1);
    4a6e:	00001097          	auipc	ra,0x1
    4a72:	53c080e7          	jalr	1340(ra) # 5faa <free>
    while(m1){
    4a76:	f8f5                	bnez	s1,4a6a <mem+0x52>
    m1 = malloc(1024*20);
    4a78:	6515                	lui	a0,0x5
    4a7a:	00001097          	auipc	ra,0x1
    4a7e:	5b2080e7          	jalr	1458(ra) # 602c <malloc>
    if(m1 == 0){
    4a82:	c911                	beqz	a0,4a96 <mem+0x7e>
    free(m1);
    4a84:	00001097          	auipc	ra,0x1
    4a88:	526080e7          	jalr	1318(ra) # 5faa <free>
    exit(0);
    4a8c:	4501                	li	a0,0
    4a8e:	00001097          	auipc	ra,0x1
    4a92:	16e080e7          	jalr	366(ra) # 5bfc <exit>
      printf("couldn't allocate mem?!!\n", s);
    4a96:	85ce                	mv	a1,s3
    4a98:	00003517          	auipc	a0,0x3
    4a9c:	30850513          	add	a0,a0,776 # 7da0 <malloc+0x1d74>
    4aa0:	00001097          	auipc	ra,0x1
    4aa4:	4d4080e7          	jalr	1236(ra) # 5f74 <printf>
      exit(1);
    4aa8:	4505                	li	a0,1
    4aaa:	00001097          	auipc	ra,0x1
    4aae:	152080e7          	jalr	338(ra) # 5bfc <exit>
      exit(0);
    4ab2:	4501                	li	a0,0
    4ab4:	00001097          	auipc	ra,0x1
    4ab8:	148080e7          	jalr	328(ra) # 5bfc <exit>

0000000000004abc <sharedfd>:
{
    4abc:	7159                	add	sp,sp,-112
    4abe:	f486                	sd	ra,104(sp)
    4ac0:	f0a2                	sd	s0,96(sp)
    4ac2:	e0d2                	sd	s4,64(sp)
    4ac4:	1880                	add	s0,sp,112
    4ac6:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    4ac8:	00003517          	auipc	a0,0x3
    4acc:	2f850513          	add	a0,a0,760 # 7dc0 <malloc+0x1d94>
    4ad0:	00001097          	auipc	ra,0x1
    4ad4:	17c080e7          	jalr	380(ra) # 5c4c <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4ad8:	20200593          	li	a1,514
    4adc:	00003517          	auipc	a0,0x3
    4ae0:	2e450513          	add	a0,a0,740 # 7dc0 <malloc+0x1d94>
    4ae4:	00001097          	auipc	ra,0x1
    4ae8:	158080e7          	jalr	344(ra) # 5c3c <open>
  if(fd < 0){
    4aec:	06054063          	bltz	a0,4b4c <sharedfd+0x90>
    4af0:	eca6                	sd	s1,88(sp)
    4af2:	e8ca                	sd	s2,80(sp)
    4af4:	e4ce                	sd	s3,72(sp)
    4af6:	fc56                	sd	s5,56(sp)
    4af8:	f85a                	sd	s6,48(sp)
    4afa:	f45e                	sd	s7,40(sp)
    4afc:	892a                	mv	s2,a0
  pid = fork();
    4afe:	00001097          	auipc	ra,0x1
    4b02:	0f6080e7          	jalr	246(ra) # 5bf4 <fork>
    4b06:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4b08:	07000593          	li	a1,112
    4b0c:	e119                	bnez	a0,4b12 <sharedfd+0x56>
    4b0e:	06300593          	li	a1,99
    4b12:	4629                	li	a2,10
    4b14:	fa040513          	add	a0,s0,-96
    4b18:	00001097          	auipc	ra,0x1
    4b1c:	eea080e7          	jalr	-278(ra) # 5a02 <memset>
    4b20:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4b24:	4629                	li	a2,10
    4b26:	fa040593          	add	a1,s0,-96
    4b2a:	854a                	mv	a0,s2
    4b2c:	00001097          	auipc	ra,0x1
    4b30:	0f0080e7          	jalr	240(ra) # 5c1c <write>
    4b34:	47a9                	li	a5,10
    4b36:	02f51f63          	bne	a0,a5,4b74 <sharedfd+0xb8>
  for(i = 0; i < N; i++){
    4b3a:	34fd                	addw	s1,s1,-1
    4b3c:	f4e5                	bnez	s1,4b24 <sharedfd+0x68>
  if(pid == 0) {
    4b3e:	04099963          	bnez	s3,4b90 <sharedfd+0xd4>
    exit(0);
    4b42:	4501                	li	a0,0
    4b44:	00001097          	auipc	ra,0x1
    4b48:	0b8080e7          	jalr	184(ra) # 5bfc <exit>
    4b4c:	eca6                	sd	s1,88(sp)
    4b4e:	e8ca                	sd	s2,80(sp)
    4b50:	e4ce                	sd	s3,72(sp)
    4b52:	fc56                	sd	s5,56(sp)
    4b54:	f85a                	sd	s6,48(sp)
    4b56:	f45e                	sd	s7,40(sp)
    printf("%s: cannot open sharedfd for writing", s);
    4b58:	85d2                	mv	a1,s4
    4b5a:	00003517          	auipc	a0,0x3
    4b5e:	27650513          	add	a0,a0,630 # 7dd0 <malloc+0x1da4>
    4b62:	00001097          	auipc	ra,0x1
    4b66:	412080e7          	jalr	1042(ra) # 5f74 <printf>
    exit(1);
    4b6a:	4505                	li	a0,1
    4b6c:	00001097          	auipc	ra,0x1
    4b70:	090080e7          	jalr	144(ra) # 5bfc <exit>
      printf("%s: write sharedfd failed\n", s);
    4b74:	85d2                	mv	a1,s4
    4b76:	00003517          	auipc	a0,0x3
    4b7a:	28250513          	add	a0,a0,642 # 7df8 <malloc+0x1dcc>
    4b7e:	00001097          	auipc	ra,0x1
    4b82:	3f6080e7          	jalr	1014(ra) # 5f74 <printf>
      exit(1);
    4b86:	4505                	li	a0,1
    4b88:	00001097          	auipc	ra,0x1
    4b8c:	074080e7          	jalr	116(ra) # 5bfc <exit>
    wait(&xstatus);
    4b90:	f9c40513          	add	a0,s0,-100
    4b94:	00001097          	auipc	ra,0x1
    4b98:	070080e7          	jalr	112(ra) # 5c04 <wait>
    if(xstatus != 0)
    4b9c:	f9c42983          	lw	s3,-100(s0)
    4ba0:	00098763          	beqz	s3,4bae <sharedfd+0xf2>
      exit(xstatus);
    4ba4:	854e                	mv	a0,s3
    4ba6:	00001097          	auipc	ra,0x1
    4baa:	056080e7          	jalr	86(ra) # 5bfc <exit>
  close(fd);
    4bae:	854a                	mv	a0,s2
    4bb0:	00001097          	auipc	ra,0x1
    4bb4:	074080e7          	jalr	116(ra) # 5c24 <close>
  fd = open("sharedfd", 0);
    4bb8:	4581                	li	a1,0
    4bba:	00003517          	auipc	a0,0x3
    4bbe:	20650513          	add	a0,a0,518 # 7dc0 <malloc+0x1d94>
    4bc2:	00001097          	auipc	ra,0x1
    4bc6:	07a080e7          	jalr	122(ra) # 5c3c <open>
    4bca:	8baa                	mv	s7,a0
  nc = np = 0;
    4bcc:	8ace                	mv	s5,s3
  if(fd < 0){
    4bce:	02054563          	bltz	a0,4bf8 <sharedfd+0x13c>
    4bd2:	faa40913          	add	s2,s0,-86
      if(buf[i] == 'c')
    4bd6:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4bda:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4bde:	4629                	li	a2,10
    4be0:	fa040593          	add	a1,s0,-96
    4be4:	855e                	mv	a0,s7
    4be6:	00001097          	auipc	ra,0x1
    4bea:	02e080e7          	jalr	46(ra) # 5c14 <read>
    4bee:	02a05f63          	blez	a0,4c2c <sharedfd+0x170>
    4bf2:	fa040793          	add	a5,s0,-96
    4bf6:	a01d                	j	4c1c <sharedfd+0x160>
    printf("%s: cannot open sharedfd for reading\n", s);
    4bf8:	85d2                	mv	a1,s4
    4bfa:	00003517          	auipc	a0,0x3
    4bfe:	21e50513          	add	a0,a0,542 # 7e18 <malloc+0x1dec>
    4c02:	00001097          	auipc	ra,0x1
    4c06:	372080e7          	jalr	882(ra) # 5f74 <printf>
    exit(1);
    4c0a:	4505                	li	a0,1
    4c0c:	00001097          	auipc	ra,0x1
    4c10:	ff0080e7          	jalr	-16(ra) # 5bfc <exit>
        nc++;
    4c14:	2985                	addw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4c16:	0785                	add	a5,a5,1
    4c18:	fd2783e3          	beq	a5,s2,4bde <sharedfd+0x122>
      if(buf[i] == 'c')
    4c1c:	0007c703          	lbu	a4,0(a5)
    4c20:	fe970ae3          	beq	a4,s1,4c14 <sharedfd+0x158>
      if(buf[i] == 'p')
    4c24:	ff6719e3          	bne	a4,s6,4c16 <sharedfd+0x15a>
        np++;
    4c28:	2a85                	addw	s5,s5,1
    4c2a:	b7f5                	j	4c16 <sharedfd+0x15a>
  close(fd);
    4c2c:	855e                	mv	a0,s7
    4c2e:	00001097          	auipc	ra,0x1
    4c32:	ff6080e7          	jalr	-10(ra) # 5c24 <close>
  unlink("sharedfd");
    4c36:	00003517          	auipc	a0,0x3
    4c3a:	18a50513          	add	a0,a0,394 # 7dc0 <malloc+0x1d94>
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	00e080e7          	jalr	14(ra) # 5c4c <unlink>
  if(nc == N*SZ && np == N*SZ){
    4c46:	6789                	lui	a5,0x2
    4c48:	71078793          	add	a5,a5,1808 # 2710 <copyinstr3+0xd0>
    4c4c:	00f99763          	bne	s3,a5,4c5a <sharedfd+0x19e>
    4c50:	6789                	lui	a5,0x2
    4c52:	71078793          	add	a5,a5,1808 # 2710 <copyinstr3+0xd0>
    4c56:	02fa8063          	beq	s5,a5,4c76 <sharedfd+0x1ba>
    printf("%s: nc/np test fails\n", s);
    4c5a:	85d2                	mv	a1,s4
    4c5c:	00003517          	auipc	a0,0x3
    4c60:	1e450513          	add	a0,a0,484 # 7e40 <malloc+0x1e14>
    4c64:	00001097          	auipc	ra,0x1
    4c68:	310080e7          	jalr	784(ra) # 5f74 <printf>
    exit(1);
    4c6c:	4505                	li	a0,1
    4c6e:	00001097          	auipc	ra,0x1
    4c72:	f8e080e7          	jalr	-114(ra) # 5bfc <exit>
    exit(0);
    4c76:	4501                	li	a0,0
    4c78:	00001097          	auipc	ra,0x1
    4c7c:	f84080e7          	jalr	-124(ra) # 5bfc <exit>

0000000000004c80 <fourfiles>:
{
    4c80:	7135                	add	sp,sp,-160
    4c82:	ed06                	sd	ra,152(sp)
    4c84:	e922                	sd	s0,144(sp)
    4c86:	e526                	sd	s1,136(sp)
    4c88:	e14a                	sd	s2,128(sp)
    4c8a:	fcce                	sd	s3,120(sp)
    4c8c:	f8d2                	sd	s4,112(sp)
    4c8e:	f4d6                	sd	s5,104(sp)
    4c90:	f0da                	sd	s6,96(sp)
    4c92:	ecde                	sd	s7,88(sp)
    4c94:	e8e2                	sd	s8,80(sp)
    4c96:	e4e6                	sd	s9,72(sp)
    4c98:	e0ea                	sd	s10,64(sp)
    4c9a:	fc6e                	sd	s11,56(sp)
    4c9c:	1100                	add	s0,sp,160
    4c9e:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4ca0:	00003797          	auipc	a5,0x3
    4ca4:	1b878793          	add	a5,a5,440 # 7e58 <malloc+0x1e2c>
    4ca8:	f6f43823          	sd	a5,-144(s0)
    4cac:	00003797          	auipc	a5,0x3
    4cb0:	1b478793          	add	a5,a5,436 # 7e60 <malloc+0x1e34>
    4cb4:	f6f43c23          	sd	a5,-136(s0)
    4cb8:	00003797          	auipc	a5,0x3
    4cbc:	1b078793          	add	a5,a5,432 # 7e68 <malloc+0x1e3c>
    4cc0:	f8f43023          	sd	a5,-128(s0)
    4cc4:	00003797          	auipc	a5,0x3
    4cc8:	1ac78793          	add	a5,a5,428 # 7e70 <malloc+0x1e44>
    4ccc:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4cd0:	f7040b93          	add	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4cd4:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4cd6:	4481                	li	s1,0
    4cd8:	4a11                	li	s4,4
    fname = names[pi];
    4cda:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4cde:	854e                	mv	a0,s3
    4ce0:	00001097          	auipc	ra,0x1
    4ce4:	f6c080e7          	jalr	-148(ra) # 5c4c <unlink>
    pid = fork();
    4ce8:	00001097          	auipc	ra,0x1
    4cec:	f0c080e7          	jalr	-244(ra) # 5bf4 <fork>
    if(pid < 0){
    4cf0:	04054063          	bltz	a0,4d30 <fourfiles+0xb0>
    if(pid == 0){
    4cf4:	cd21                	beqz	a0,4d4c <fourfiles+0xcc>
  for(pi = 0; pi < NCHILD; pi++){
    4cf6:	2485                	addw	s1,s1,1
    4cf8:	0921                	add	s2,s2,8
    4cfa:	ff4490e3          	bne	s1,s4,4cda <fourfiles+0x5a>
    4cfe:	4491                	li	s1,4
    wait(&xstatus);
    4d00:	f6c40513          	add	a0,s0,-148
    4d04:	00001097          	auipc	ra,0x1
    4d08:	f00080e7          	jalr	-256(ra) # 5c04 <wait>
    if(xstatus != 0)
    4d0c:	f6c42a83          	lw	s5,-148(s0)
    4d10:	0c0a9863          	bnez	s5,4de0 <fourfiles+0x160>
  for(pi = 0; pi < NCHILD; pi++){
    4d14:	34fd                	addw	s1,s1,-1
    4d16:	f4ed                	bnez	s1,4d00 <fourfiles+0x80>
    4d18:	03000b13          	li	s6,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4d1c:	00008a17          	auipc	s4,0x8
    4d20:	f5ca0a13          	add	s4,s4,-164 # cc78 <buf>
    if(total != N*SZ){
    4d24:	6d05                	lui	s10,0x1
    4d26:	770d0d13          	add	s10,s10,1904 # 1770 <exectest+0x20>
  for(i = 0; i < NCHILD; i++){
    4d2a:	03400d93          	li	s11,52
    4d2e:	a22d                	j	4e58 <fourfiles+0x1d8>
      printf("fork failed\n", s);
    4d30:	85e6                	mv	a1,s9
    4d32:	00002517          	auipc	a0,0x2
    4d36:	0c650513          	add	a0,a0,198 # 6df8 <malloc+0xdcc>
    4d3a:	00001097          	auipc	ra,0x1
    4d3e:	23a080e7          	jalr	570(ra) # 5f74 <printf>
      exit(1);
    4d42:	4505                	li	a0,1
    4d44:	00001097          	auipc	ra,0x1
    4d48:	eb8080e7          	jalr	-328(ra) # 5bfc <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4d4c:	20200593          	li	a1,514
    4d50:	854e                	mv	a0,s3
    4d52:	00001097          	auipc	ra,0x1
    4d56:	eea080e7          	jalr	-278(ra) # 5c3c <open>
    4d5a:	892a                	mv	s2,a0
      if(fd < 0){
    4d5c:	04054763          	bltz	a0,4daa <fourfiles+0x12a>
      memset(buf, '0'+pi, SZ);
    4d60:	1f400613          	li	a2,500
    4d64:	0304859b          	addw	a1,s1,48
    4d68:	00008517          	auipc	a0,0x8
    4d6c:	f1050513          	add	a0,a0,-240 # cc78 <buf>
    4d70:	00001097          	auipc	ra,0x1
    4d74:	c92080e7          	jalr	-878(ra) # 5a02 <memset>
    4d78:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4d7a:	00008997          	auipc	s3,0x8
    4d7e:	efe98993          	add	s3,s3,-258 # cc78 <buf>
    4d82:	1f400613          	li	a2,500
    4d86:	85ce                	mv	a1,s3
    4d88:	854a                	mv	a0,s2
    4d8a:	00001097          	auipc	ra,0x1
    4d8e:	e92080e7          	jalr	-366(ra) # 5c1c <write>
    4d92:	85aa                	mv	a1,a0
    4d94:	1f400793          	li	a5,500
    4d98:	02f51763          	bne	a0,a5,4dc6 <fourfiles+0x146>
      for(i = 0; i < N; i++){
    4d9c:	34fd                	addw	s1,s1,-1
    4d9e:	f0f5                	bnez	s1,4d82 <fourfiles+0x102>
      exit(0);
    4da0:	4501                	li	a0,0
    4da2:	00001097          	auipc	ra,0x1
    4da6:	e5a080e7          	jalr	-422(ra) # 5bfc <exit>
        printf("create failed\n", s);
    4daa:	85e6                	mv	a1,s9
    4dac:	00003517          	auipc	a0,0x3
    4db0:	0cc50513          	add	a0,a0,204 # 7e78 <malloc+0x1e4c>
    4db4:	00001097          	auipc	ra,0x1
    4db8:	1c0080e7          	jalr	448(ra) # 5f74 <printf>
        exit(1);
    4dbc:	4505                	li	a0,1
    4dbe:	00001097          	auipc	ra,0x1
    4dc2:	e3e080e7          	jalr	-450(ra) # 5bfc <exit>
          printf("write failed %d\n", n);
    4dc6:	00003517          	auipc	a0,0x3
    4dca:	0c250513          	add	a0,a0,194 # 7e88 <malloc+0x1e5c>
    4dce:	00001097          	auipc	ra,0x1
    4dd2:	1a6080e7          	jalr	422(ra) # 5f74 <printf>
          exit(1);
    4dd6:	4505                	li	a0,1
    4dd8:	00001097          	auipc	ra,0x1
    4ddc:	e24080e7          	jalr	-476(ra) # 5bfc <exit>
      exit(xstatus);
    4de0:	8556                	mv	a0,s5
    4de2:	00001097          	auipc	ra,0x1
    4de6:	e1a080e7          	jalr	-486(ra) # 5bfc <exit>
          printf("wrong char\n", s);
    4dea:	85e6                	mv	a1,s9
    4dec:	00003517          	auipc	a0,0x3
    4df0:	0b450513          	add	a0,a0,180 # 7ea0 <malloc+0x1e74>
    4df4:	00001097          	auipc	ra,0x1
    4df8:	180080e7          	jalr	384(ra) # 5f74 <printf>
          exit(1);
    4dfc:	4505                	li	a0,1
    4dfe:	00001097          	auipc	ra,0x1
    4e02:	dfe080e7          	jalr	-514(ra) # 5bfc <exit>
      total += n;
    4e06:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4e0a:	660d                	lui	a2,0x3
    4e0c:	85d2                	mv	a1,s4
    4e0e:	854e                	mv	a0,s3
    4e10:	00001097          	auipc	ra,0x1
    4e14:	e04080e7          	jalr	-508(ra) # 5c14 <read>
    4e18:	02a05063          	blez	a0,4e38 <fourfiles+0x1b8>
    4e1c:	00008797          	auipc	a5,0x8
    4e20:	e5c78793          	add	a5,a5,-420 # cc78 <buf>
    4e24:	00f506b3          	add	a3,a0,a5
        if(buf[j] != '0'+i){
    4e28:	0007c703          	lbu	a4,0(a5)
    4e2c:	fa971fe3          	bne	a4,s1,4dea <fourfiles+0x16a>
      for(j = 0; j < n; j++){
    4e30:	0785                	add	a5,a5,1
    4e32:	fed79be3          	bne	a5,a3,4e28 <fourfiles+0x1a8>
    4e36:	bfc1                	j	4e06 <fourfiles+0x186>
    close(fd);
    4e38:	854e                	mv	a0,s3
    4e3a:	00001097          	auipc	ra,0x1
    4e3e:	dea080e7          	jalr	-534(ra) # 5c24 <close>
    if(total != N*SZ){
    4e42:	03a91863          	bne	s2,s10,4e72 <fourfiles+0x1f2>
    unlink(fname);
    4e46:	8562                	mv	a0,s8
    4e48:	00001097          	auipc	ra,0x1
    4e4c:	e04080e7          	jalr	-508(ra) # 5c4c <unlink>
  for(i = 0; i < NCHILD; i++){
    4e50:	0ba1                	add	s7,s7,8
    4e52:	2b05                	addw	s6,s6,1
    4e54:	03bb0d63          	beq	s6,s11,4e8e <fourfiles+0x20e>
    fname = names[i];
    4e58:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    4e5c:	4581                	li	a1,0
    4e5e:	8562                	mv	a0,s8
    4e60:	00001097          	auipc	ra,0x1
    4e64:	ddc080e7          	jalr	-548(ra) # 5c3c <open>
    4e68:	89aa                	mv	s3,a0
    total = 0;
    4e6a:	8956                	mv	s2,s5
        if(buf[j] != '0'+i){
    4e6c:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4e70:	bf69                	j	4e0a <fourfiles+0x18a>
      printf("wrong length %d\n", total);
    4e72:	85ca                	mv	a1,s2
    4e74:	00003517          	auipc	a0,0x3
    4e78:	03c50513          	add	a0,a0,60 # 7eb0 <malloc+0x1e84>
    4e7c:	00001097          	auipc	ra,0x1
    4e80:	0f8080e7          	jalr	248(ra) # 5f74 <printf>
      exit(1);
    4e84:	4505                	li	a0,1
    4e86:	00001097          	auipc	ra,0x1
    4e8a:	d76080e7          	jalr	-650(ra) # 5bfc <exit>
}
    4e8e:	60ea                	ld	ra,152(sp)
    4e90:	644a                	ld	s0,144(sp)
    4e92:	64aa                	ld	s1,136(sp)
    4e94:	690a                	ld	s2,128(sp)
    4e96:	79e6                	ld	s3,120(sp)
    4e98:	7a46                	ld	s4,112(sp)
    4e9a:	7aa6                	ld	s5,104(sp)
    4e9c:	7b06                	ld	s6,96(sp)
    4e9e:	6be6                	ld	s7,88(sp)
    4ea0:	6c46                	ld	s8,80(sp)
    4ea2:	6ca6                	ld	s9,72(sp)
    4ea4:	6d06                	ld	s10,64(sp)
    4ea6:	7de2                	ld	s11,56(sp)
    4ea8:	610d                	add	sp,sp,160
    4eaa:	8082                	ret

0000000000004eac <concreate>:
{
    4eac:	7135                	add	sp,sp,-160
    4eae:	ed06                	sd	ra,152(sp)
    4eb0:	e922                	sd	s0,144(sp)
    4eb2:	e526                	sd	s1,136(sp)
    4eb4:	e14a                	sd	s2,128(sp)
    4eb6:	fcce                	sd	s3,120(sp)
    4eb8:	f8d2                	sd	s4,112(sp)
    4eba:	f4d6                	sd	s5,104(sp)
    4ebc:	f0da                	sd	s6,96(sp)
    4ebe:	ecde                	sd	s7,88(sp)
    4ec0:	1100                	add	s0,sp,160
    4ec2:	89aa                	mv	s3,a0
  file[0] = 'C';
    4ec4:	04300793          	li	a5,67
    4ec8:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4ecc:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4ed0:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4ed2:	4b0d                	li	s6,3
    4ed4:	4a85                	li	s5,1
      link("C0", file);
    4ed6:	00003b97          	auipc	s7,0x3
    4eda:	ff2b8b93          	add	s7,s7,-14 # 7ec8 <malloc+0x1e9c>
  for(i = 0; i < N; i++){
    4ede:	02800a13          	li	s4,40
    4ee2:	acc9                	j	51b4 <concreate+0x308>
      link("C0", file);
    4ee4:	fa840593          	add	a1,s0,-88
    4ee8:	855e                	mv	a0,s7
    4eea:	00001097          	auipc	ra,0x1
    4eee:	d72080e7          	jalr	-654(ra) # 5c5c <link>
    if(pid == 0) {
    4ef2:	a465                	j	519a <concreate+0x2ee>
    } else if(pid == 0 && (i % 5) == 1){
    4ef4:	4795                	li	a5,5
    4ef6:	02f9693b          	remw	s2,s2,a5
    4efa:	4785                	li	a5,1
    4efc:	02f90b63          	beq	s2,a5,4f32 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    4f00:	20200593          	li	a1,514
    4f04:	fa840513          	add	a0,s0,-88
    4f08:	00001097          	auipc	ra,0x1
    4f0c:	d34080e7          	jalr	-716(ra) # 5c3c <open>
      if(fd < 0){
    4f10:	26055c63          	bgez	a0,5188 <concreate+0x2dc>
        printf("concreate create %s failed\n", file);
    4f14:	fa840593          	add	a1,s0,-88
    4f18:	00003517          	auipc	a0,0x3
    4f1c:	fb850513          	add	a0,a0,-72 # 7ed0 <malloc+0x1ea4>
    4f20:	00001097          	auipc	ra,0x1
    4f24:	054080e7          	jalr	84(ra) # 5f74 <printf>
        exit(1);
    4f28:	4505                	li	a0,1
    4f2a:	00001097          	auipc	ra,0x1
    4f2e:	cd2080e7          	jalr	-814(ra) # 5bfc <exit>
      link("C0", file);
    4f32:	fa840593          	add	a1,s0,-88
    4f36:	00003517          	auipc	a0,0x3
    4f3a:	f9250513          	add	a0,a0,-110 # 7ec8 <malloc+0x1e9c>
    4f3e:	00001097          	auipc	ra,0x1
    4f42:	d1e080e7          	jalr	-738(ra) # 5c5c <link>
      exit(0);
    4f46:	4501                	li	a0,0
    4f48:	00001097          	auipc	ra,0x1
    4f4c:	cb4080e7          	jalr	-844(ra) # 5bfc <exit>
        exit(1);
    4f50:	4505                	li	a0,1
    4f52:	00001097          	auipc	ra,0x1
    4f56:	caa080e7          	jalr	-854(ra) # 5bfc <exit>
  memset(fa, 0, sizeof(fa));
    4f5a:	02800613          	li	a2,40
    4f5e:	4581                	li	a1,0
    4f60:	f8040513          	add	a0,s0,-128
    4f64:	00001097          	auipc	ra,0x1
    4f68:	a9e080e7          	jalr	-1378(ra) # 5a02 <memset>
  fd = open(".", 0);
    4f6c:	4581                	li	a1,0
    4f6e:	00002517          	auipc	a0,0x2
    4f72:	8e250513          	add	a0,a0,-1822 # 6850 <malloc+0x824>
    4f76:	00001097          	auipc	ra,0x1
    4f7a:	cc6080e7          	jalr	-826(ra) # 5c3c <open>
    4f7e:	892a                	mv	s2,a0
  n = 0;
    4f80:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4f82:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4f86:	02700b13          	li	s6,39
      fa[i] = 1;
    4f8a:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4f8c:	4641                	li	a2,16
    4f8e:	f7040593          	add	a1,s0,-144
    4f92:	854a                	mv	a0,s2
    4f94:	00001097          	auipc	ra,0x1
    4f98:	c80080e7          	jalr	-896(ra) # 5c14 <read>
    4f9c:	08a05263          	blez	a0,5020 <concreate+0x174>
    if(de.inum == 0)
    4fa0:	f7045783          	lhu	a5,-144(s0)
    4fa4:	d7e5                	beqz	a5,4f8c <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4fa6:	f7244783          	lbu	a5,-142(s0)
    4faa:	ff4791e3          	bne	a5,s4,4f8c <concreate+0xe0>
    4fae:	f7444783          	lbu	a5,-140(s0)
    4fb2:	ffe9                	bnez	a5,4f8c <concreate+0xe0>
      i = de.name[1] - '0';
    4fb4:	f7344783          	lbu	a5,-141(s0)
    4fb8:	fd07879b          	addw	a5,a5,-48
    4fbc:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4fc0:	02eb6063          	bltu	s6,a4,4fe0 <concreate+0x134>
      if(fa[i]){
    4fc4:	fb070793          	add	a5,a4,-80 # fb0 <linktest+0xbc>
    4fc8:	97a2                	add	a5,a5,s0
    4fca:	fd07c783          	lbu	a5,-48(a5)
    4fce:	eb8d                	bnez	a5,5000 <concreate+0x154>
      fa[i] = 1;
    4fd0:	fb070793          	add	a5,a4,-80
    4fd4:	00878733          	add	a4,a5,s0
    4fd8:	fd770823          	sb	s7,-48(a4)
      n++;
    4fdc:	2a85                	addw	s5,s5,1
    4fde:	b77d                	j	4f8c <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4fe0:	f7240613          	add	a2,s0,-142
    4fe4:	85ce                	mv	a1,s3
    4fe6:	00003517          	auipc	a0,0x3
    4fea:	f0a50513          	add	a0,a0,-246 # 7ef0 <malloc+0x1ec4>
    4fee:	00001097          	auipc	ra,0x1
    4ff2:	f86080e7          	jalr	-122(ra) # 5f74 <printf>
        exit(1);
    4ff6:	4505                	li	a0,1
    4ff8:	00001097          	auipc	ra,0x1
    4ffc:	c04080e7          	jalr	-1020(ra) # 5bfc <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    5000:	f7240613          	add	a2,s0,-142
    5004:	85ce                	mv	a1,s3
    5006:	00003517          	auipc	a0,0x3
    500a:	f0a50513          	add	a0,a0,-246 # 7f10 <malloc+0x1ee4>
    500e:	00001097          	auipc	ra,0x1
    5012:	f66080e7          	jalr	-154(ra) # 5f74 <printf>
        exit(1);
    5016:	4505                	li	a0,1
    5018:	00001097          	auipc	ra,0x1
    501c:	be4080e7          	jalr	-1052(ra) # 5bfc <exit>
  close(fd);
    5020:	854a                	mv	a0,s2
    5022:	00001097          	auipc	ra,0x1
    5026:	c02080e7          	jalr	-1022(ra) # 5c24 <close>
  if(n != N){
    502a:	02800793          	li	a5,40
    502e:	00fa9763          	bne	s5,a5,503c <concreate+0x190>
    if(((i % 3) == 0 && pid == 0) ||
    5032:	4a8d                	li	s5,3
    5034:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    5036:	02800a13          	li	s4,40
    503a:	a8c9                	j	510c <concreate+0x260>
    printf("%s: concreate not enough files in directory listing\n", s);
    503c:	85ce                	mv	a1,s3
    503e:	00003517          	auipc	a0,0x3
    5042:	efa50513          	add	a0,a0,-262 # 7f38 <malloc+0x1f0c>
    5046:	00001097          	auipc	ra,0x1
    504a:	f2e080e7          	jalr	-210(ra) # 5f74 <printf>
    exit(1);
    504e:	4505                	li	a0,1
    5050:	00001097          	auipc	ra,0x1
    5054:	bac080e7          	jalr	-1108(ra) # 5bfc <exit>
      printf("%s: fork failed\n", s);
    5058:	85ce                	mv	a1,s3
    505a:	00002517          	auipc	a0,0x2
    505e:	99650513          	add	a0,a0,-1642 # 69f0 <malloc+0x9c4>
    5062:	00001097          	auipc	ra,0x1
    5066:	f12080e7          	jalr	-238(ra) # 5f74 <printf>
      exit(1);
    506a:	4505                	li	a0,1
    506c:	00001097          	auipc	ra,0x1
    5070:	b90080e7          	jalr	-1136(ra) # 5bfc <exit>
      close(open(file, 0));
    5074:	4581                	li	a1,0
    5076:	fa840513          	add	a0,s0,-88
    507a:	00001097          	auipc	ra,0x1
    507e:	bc2080e7          	jalr	-1086(ra) # 5c3c <open>
    5082:	00001097          	auipc	ra,0x1
    5086:	ba2080e7          	jalr	-1118(ra) # 5c24 <close>
      close(open(file, 0));
    508a:	4581                	li	a1,0
    508c:	fa840513          	add	a0,s0,-88
    5090:	00001097          	auipc	ra,0x1
    5094:	bac080e7          	jalr	-1108(ra) # 5c3c <open>
    5098:	00001097          	auipc	ra,0x1
    509c:	b8c080e7          	jalr	-1140(ra) # 5c24 <close>
      close(open(file, 0));
    50a0:	4581                	li	a1,0
    50a2:	fa840513          	add	a0,s0,-88
    50a6:	00001097          	auipc	ra,0x1
    50aa:	b96080e7          	jalr	-1130(ra) # 5c3c <open>
    50ae:	00001097          	auipc	ra,0x1
    50b2:	b76080e7          	jalr	-1162(ra) # 5c24 <close>
      close(open(file, 0));
    50b6:	4581                	li	a1,0
    50b8:	fa840513          	add	a0,s0,-88
    50bc:	00001097          	auipc	ra,0x1
    50c0:	b80080e7          	jalr	-1152(ra) # 5c3c <open>
    50c4:	00001097          	auipc	ra,0x1
    50c8:	b60080e7          	jalr	-1184(ra) # 5c24 <close>
      close(open(file, 0));
    50cc:	4581                	li	a1,0
    50ce:	fa840513          	add	a0,s0,-88
    50d2:	00001097          	auipc	ra,0x1
    50d6:	b6a080e7          	jalr	-1174(ra) # 5c3c <open>
    50da:	00001097          	auipc	ra,0x1
    50de:	b4a080e7          	jalr	-1206(ra) # 5c24 <close>
      close(open(file, 0));
    50e2:	4581                	li	a1,0
    50e4:	fa840513          	add	a0,s0,-88
    50e8:	00001097          	auipc	ra,0x1
    50ec:	b54080e7          	jalr	-1196(ra) # 5c3c <open>
    50f0:	00001097          	auipc	ra,0x1
    50f4:	b34080e7          	jalr	-1228(ra) # 5c24 <close>
    if(pid == 0)
    50f8:	08090363          	beqz	s2,517e <concreate+0x2d2>
      wait(0);
    50fc:	4501                	li	a0,0
    50fe:	00001097          	auipc	ra,0x1
    5102:	b06080e7          	jalr	-1274(ra) # 5c04 <wait>
  for(i = 0; i < N; i++){
    5106:	2485                	addw	s1,s1,1
    5108:	0f448563          	beq	s1,s4,51f2 <concreate+0x346>
    file[1] = '0' + i;
    510c:	0304879b          	addw	a5,s1,48
    5110:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    5114:	00001097          	auipc	ra,0x1
    5118:	ae0080e7          	jalr	-1312(ra) # 5bf4 <fork>
    511c:	892a                	mv	s2,a0
    if(pid < 0){
    511e:	f2054de3          	bltz	a0,5058 <concreate+0x1ac>
    if(((i % 3) == 0 && pid == 0) ||
    5122:	0354e73b          	remw	a4,s1,s5
    5126:	00a767b3          	or	a5,a4,a0
    512a:	2781                	sext.w	a5,a5
    512c:	d7a1                	beqz	a5,5074 <concreate+0x1c8>
    512e:	01671363          	bne	a4,s6,5134 <concreate+0x288>
       ((i % 3) == 1 && pid != 0)){
    5132:	f129                	bnez	a0,5074 <concreate+0x1c8>
      unlink(file);
    5134:	fa840513          	add	a0,s0,-88
    5138:	00001097          	auipc	ra,0x1
    513c:	b14080e7          	jalr	-1260(ra) # 5c4c <unlink>
      unlink(file);
    5140:	fa840513          	add	a0,s0,-88
    5144:	00001097          	auipc	ra,0x1
    5148:	b08080e7          	jalr	-1272(ra) # 5c4c <unlink>
      unlink(file);
    514c:	fa840513          	add	a0,s0,-88
    5150:	00001097          	auipc	ra,0x1
    5154:	afc080e7          	jalr	-1284(ra) # 5c4c <unlink>
      unlink(file);
    5158:	fa840513          	add	a0,s0,-88
    515c:	00001097          	auipc	ra,0x1
    5160:	af0080e7          	jalr	-1296(ra) # 5c4c <unlink>
      unlink(file);
    5164:	fa840513          	add	a0,s0,-88
    5168:	00001097          	auipc	ra,0x1
    516c:	ae4080e7          	jalr	-1308(ra) # 5c4c <unlink>
      unlink(file);
    5170:	fa840513          	add	a0,s0,-88
    5174:	00001097          	auipc	ra,0x1
    5178:	ad8080e7          	jalr	-1320(ra) # 5c4c <unlink>
    517c:	bfb5                	j	50f8 <concreate+0x24c>
      exit(0);
    517e:	4501                	li	a0,0
    5180:	00001097          	auipc	ra,0x1
    5184:	a7c080e7          	jalr	-1412(ra) # 5bfc <exit>
      close(fd);
    5188:	00001097          	auipc	ra,0x1
    518c:	a9c080e7          	jalr	-1380(ra) # 5c24 <close>
    if(pid == 0) {
    5190:	bb5d                	j	4f46 <concreate+0x9a>
      close(fd);
    5192:	00001097          	auipc	ra,0x1
    5196:	a92080e7          	jalr	-1390(ra) # 5c24 <close>
      wait(&xstatus);
    519a:	f6c40513          	add	a0,s0,-148
    519e:	00001097          	auipc	ra,0x1
    51a2:	a66080e7          	jalr	-1434(ra) # 5c04 <wait>
      if(xstatus != 0)
    51a6:	f6c42483          	lw	s1,-148(s0)
    51aa:	da0493e3          	bnez	s1,4f50 <concreate+0xa4>
  for(i = 0; i < N; i++){
    51ae:	2905                	addw	s2,s2,1
    51b0:	db4905e3          	beq	s2,s4,4f5a <concreate+0xae>
    file[1] = '0' + i;
    51b4:	0309079b          	addw	a5,s2,48
    51b8:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    51bc:	fa840513          	add	a0,s0,-88
    51c0:	00001097          	auipc	ra,0x1
    51c4:	a8c080e7          	jalr	-1396(ra) # 5c4c <unlink>
    pid = fork();
    51c8:	00001097          	auipc	ra,0x1
    51cc:	a2c080e7          	jalr	-1492(ra) # 5bf4 <fork>
    if(pid && (i % 3) == 1){
    51d0:	d20502e3          	beqz	a0,4ef4 <concreate+0x48>
    51d4:	036967bb          	remw	a5,s2,s6
    51d8:	d15786e3          	beq	a5,s5,4ee4 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    51dc:	20200593          	li	a1,514
    51e0:	fa840513          	add	a0,s0,-88
    51e4:	00001097          	auipc	ra,0x1
    51e8:	a58080e7          	jalr	-1448(ra) # 5c3c <open>
      if(fd < 0){
    51ec:	fa0553e3          	bgez	a0,5192 <concreate+0x2e6>
    51f0:	b315                	j	4f14 <concreate+0x68>
}
    51f2:	60ea                	ld	ra,152(sp)
    51f4:	644a                	ld	s0,144(sp)
    51f6:	64aa                	ld	s1,136(sp)
    51f8:	690a                	ld	s2,128(sp)
    51fa:	79e6                	ld	s3,120(sp)
    51fc:	7a46                	ld	s4,112(sp)
    51fe:	7aa6                	ld	s5,104(sp)
    5200:	7b06                	ld	s6,96(sp)
    5202:	6be6                	ld	s7,88(sp)
    5204:	610d                	add	sp,sp,160
    5206:	8082                	ret

0000000000005208 <bigfile>:
{
    5208:	7139                	add	sp,sp,-64
    520a:	fc06                	sd	ra,56(sp)
    520c:	f822                	sd	s0,48(sp)
    520e:	f426                	sd	s1,40(sp)
    5210:	f04a                	sd	s2,32(sp)
    5212:	ec4e                	sd	s3,24(sp)
    5214:	e852                	sd	s4,16(sp)
    5216:	e456                	sd	s5,8(sp)
    5218:	0080                	add	s0,sp,64
    521a:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    521c:	00003517          	auipc	a0,0x3
    5220:	d5450513          	add	a0,a0,-684 # 7f70 <malloc+0x1f44>
    5224:	00001097          	auipc	ra,0x1
    5228:	a28080e7          	jalr	-1496(ra) # 5c4c <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    522c:	20200593          	li	a1,514
    5230:	00003517          	auipc	a0,0x3
    5234:	d4050513          	add	a0,a0,-704 # 7f70 <malloc+0x1f44>
    5238:	00001097          	auipc	ra,0x1
    523c:	a04080e7          	jalr	-1532(ra) # 5c3c <open>
    5240:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    5242:	4481                	li	s1,0
    memset(buf, i, SZ);
    5244:	00008917          	auipc	s2,0x8
    5248:	a3490913          	add	s2,s2,-1484 # cc78 <buf>
  for(i = 0; i < N; i++){
    524c:	4a51                	li	s4,20
  if(fd < 0){
    524e:	0a054063          	bltz	a0,52ee <bigfile+0xe6>
    memset(buf, i, SZ);
    5252:	25800613          	li	a2,600
    5256:	85a6                	mv	a1,s1
    5258:	854a                	mv	a0,s2
    525a:	00000097          	auipc	ra,0x0
    525e:	7a8080e7          	jalr	1960(ra) # 5a02 <memset>
    if(write(fd, buf, SZ) != SZ){
    5262:	25800613          	li	a2,600
    5266:	85ca                	mv	a1,s2
    5268:	854e                	mv	a0,s3
    526a:	00001097          	auipc	ra,0x1
    526e:	9b2080e7          	jalr	-1614(ra) # 5c1c <write>
    5272:	25800793          	li	a5,600
    5276:	08f51a63          	bne	a0,a5,530a <bigfile+0x102>
  for(i = 0; i < N; i++){
    527a:	2485                	addw	s1,s1,1
    527c:	fd449be3          	bne	s1,s4,5252 <bigfile+0x4a>
  close(fd);
    5280:	854e                	mv	a0,s3
    5282:	00001097          	auipc	ra,0x1
    5286:	9a2080e7          	jalr	-1630(ra) # 5c24 <close>
  fd = open("bigfile.dat", 0);
    528a:	4581                	li	a1,0
    528c:	00003517          	auipc	a0,0x3
    5290:	ce450513          	add	a0,a0,-796 # 7f70 <malloc+0x1f44>
    5294:	00001097          	auipc	ra,0x1
    5298:	9a8080e7          	jalr	-1624(ra) # 5c3c <open>
    529c:	8a2a                	mv	s4,a0
  total = 0;
    529e:	4981                	li	s3,0
  for(i = 0; ; i++){
    52a0:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    52a2:	00008917          	auipc	s2,0x8
    52a6:	9d690913          	add	s2,s2,-1578 # cc78 <buf>
  if(fd < 0){
    52aa:	06054e63          	bltz	a0,5326 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    52ae:	12c00613          	li	a2,300
    52b2:	85ca                	mv	a1,s2
    52b4:	8552                	mv	a0,s4
    52b6:	00001097          	auipc	ra,0x1
    52ba:	95e080e7          	jalr	-1698(ra) # 5c14 <read>
    if(cc < 0){
    52be:	08054263          	bltz	a0,5342 <bigfile+0x13a>
    if(cc == 0)
    52c2:	c971                	beqz	a0,5396 <bigfile+0x18e>
    if(cc != SZ/2){
    52c4:	12c00793          	li	a5,300
    52c8:	08f51b63          	bne	a0,a5,535e <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    52cc:	01f4d79b          	srlw	a5,s1,0x1f
    52d0:	9fa5                	addw	a5,a5,s1
    52d2:	4017d79b          	sraw	a5,a5,0x1
    52d6:	00094703          	lbu	a4,0(s2)
    52da:	0af71063          	bne	a4,a5,537a <bigfile+0x172>
    52de:	12b94703          	lbu	a4,299(s2)
    52e2:	08f71c63          	bne	a4,a5,537a <bigfile+0x172>
    total += cc;
    52e6:	12c9899b          	addw	s3,s3,300
  for(i = 0; ; i++){
    52ea:	2485                	addw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    52ec:	b7c9                	j	52ae <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    52ee:	85d6                	mv	a1,s5
    52f0:	00003517          	auipc	a0,0x3
    52f4:	c9050513          	add	a0,a0,-880 # 7f80 <malloc+0x1f54>
    52f8:	00001097          	auipc	ra,0x1
    52fc:	c7c080e7          	jalr	-900(ra) # 5f74 <printf>
    exit(1);
    5300:	4505                	li	a0,1
    5302:	00001097          	auipc	ra,0x1
    5306:	8fa080e7          	jalr	-1798(ra) # 5bfc <exit>
      printf("%s: write bigfile failed\n", s);
    530a:	85d6                	mv	a1,s5
    530c:	00003517          	auipc	a0,0x3
    5310:	c9450513          	add	a0,a0,-876 # 7fa0 <malloc+0x1f74>
    5314:	00001097          	auipc	ra,0x1
    5318:	c60080e7          	jalr	-928(ra) # 5f74 <printf>
      exit(1);
    531c:	4505                	li	a0,1
    531e:	00001097          	auipc	ra,0x1
    5322:	8de080e7          	jalr	-1826(ra) # 5bfc <exit>
    printf("%s: cannot open bigfile\n", s);
    5326:	85d6                	mv	a1,s5
    5328:	00003517          	auipc	a0,0x3
    532c:	c9850513          	add	a0,a0,-872 # 7fc0 <malloc+0x1f94>
    5330:	00001097          	auipc	ra,0x1
    5334:	c44080e7          	jalr	-956(ra) # 5f74 <printf>
    exit(1);
    5338:	4505                	li	a0,1
    533a:	00001097          	auipc	ra,0x1
    533e:	8c2080e7          	jalr	-1854(ra) # 5bfc <exit>
      printf("%s: read bigfile failed\n", s);
    5342:	85d6                	mv	a1,s5
    5344:	00003517          	auipc	a0,0x3
    5348:	c9c50513          	add	a0,a0,-868 # 7fe0 <malloc+0x1fb4>
    534c:	00001097          	auipc	ra,0x1
    5350:	c28080e7          	jalr	-984(ra) # 5f74 <printf>
      exit(1);
    5354:	4505                	li	a0,1
    5356:	00001097          	auipc	ra,0x1
    535a:	8a6080e7          	jalr	-1882(ra) # 5bfc <exit>
      printf("%s: short read bigfile\n", s);
    535e:	85d6                	mv	a1,s5
    5360:	00003517          	auipc	a0,0x3
    5364:	ca050513          	add	a0,a0,-864 # 8000 <malloc+0x1fd4>
    5368:	00001097          	auipc	ra,0x1
    536c:	c0c080e7          	jalr	-1012(ra) # 5f74 <printf>
      exit(1);
    5370:	4505                	li	a0,1
    5372:	00001097          	auipc	ra,0x1
    5376:	88a080e7          	jalr	-1910(ra) # 5bfc <exit>
      printf("%s: read bigfile wrong data\n", s);
    537a:	85d6                	mv	a1,s5
    537c:	00003517          	auipc	a0,0x3
    5380:	c9c50513          	add	a0,a0,-868 # 8018 <malloc+0x1fec>
    5384:	00001097          	auipc	ra,0x1
    5388:	bf0080e7          	jalr	-1040(ra) # 5f74 <printf>
      exit(1);
    538c:	4505                	li	a0,1
    538e:	00001097          	auipc	ra,0x1
    5392:	86e080e7          	jalr	-1938(ra) # 5bfc <exit>
  close(fd);
    5396:	8552                	mv	a0,s4
    5398:	00001097          	auipc	ra,0x1
    539c:	88c080e7          	jalr	-1908(ra) # 5c24 <close>
  if(total != N*SZ){
    53a0:	678d                	lui	a5,0x3
    53a2:	ee078793          	add	a5,a5,-288 # 2ee0 <sbrklast+0x3a>
    53a6:	02f99363          	bne	s3,a5,53cc <bigfile+0x1c4>
  unlink("bigfile.dat");
    53aa:	00003517          	auipc	a0,0x3
    53ae:	bc650513          	add	a0,a0,-1082 # 7f70 <malloc+0x1f44>
    53b2:	00001097          	auipc	ra,0x1
    53b6:	89a080e7          	jalr	-1894(ra) # 5c4c <unlink>
}
    53ba:	70e2                	ld	ra,56(sp)
    53bc:	7442                	ld	s0,48(sp)
    53be:	74a2                	ld	s1,40(sp)
    53c0:	7902                	ld	s2,32(sp)
    53c2:	69e2                	ld	s3,24(sp)
    53c4:	6a42                	ld	s4,16(sp)
    53c6:	6aa2                	ld	s5,8(sp)
    53c8:	6121                	add	sp,sp,64
    53ca:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    53cc:	85d6                	mv	a1,s5
    53ce:	00003517          	auipc	a0,0x3
    53d2:	c6a50513          	add	a0,a0,-918 # 8038 <malloc+0x200c>
    53d6:	00001097          	auipc	ra,0x1
    53da:	b9e080e7          	jalr	-1122(ra) # 5f74 <printf>
    exit(1);
    53de:	4505                	li	a0,1
    53e0:	00001097          	auipc	ra,0x1
    53e4:	81c080e7          	jalr	-2020(ra) # 5bfc <exit>

00000000000053e8 <fsfull>:
{
    53e8:	7135                	add	sp,sp,-160
    53ea:	ed06                	sd	ra,152(sp)
    53ec:	e922                	sd	s0,144(sp)
    53ee:	e526                	sd	s1,136(sp)
    53f0:	e14a                	sd	s2,128(sp)
    53f2:	fcce                	sd	s3,120(sp)
    53f4:	f8d2                	sd	s4,112(sp)
    53f6:	f4d6                	sd	s5,104(sp)
    53f8:	f0da                	sd	s6,96(sp)
    53fa:	ecde                	sd	s7,88(sp)
    53fc:	e8e2                	sd	s8,80(sp)
    53fe:	e4e6                	sd	s9,72(sp)
    5400:	e0ea                	sd	s10,64(sp)
    5402:	1100                	add	s0,sp,160
  printf("fsfull test\n");
    5404:	00003517          	auipc	a0,0x3
    5408:	c5450513          	add	a0,a0,-940 # 8058 <malloc+0x202c>
    540c:	00001097          	auipc	ra,0x1
    5410:	b68080e7          	jalr	-1176(ra) # 5f74 <printf>
  for(nfiles = 0; ; nfiles++){
    5414:	4481                	li	s1,0
    name[0] = 'f';
    5416:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    541a:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    541e:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    5422:	4b29                	li	s6,10
    printf("writing %s\n", name);
    5424:	00003c97          	auipc	s9,0x3
    5428:	c44c8c93          	add	s9,s9,-956 # 8068 <malloc+0x203c>
    name[0] = 'f';
    542c:	f7a40023          	sb	s10,-160(s0)
    name[1] = '0' + nfiles / 1000;
    5430:	0384c7bb          	divw	a5,s1,s8
    5434:	0307879b          	addw	a5,a5,48
    5438:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    543c:	0384e7bb          	remw	a5,s1,s8
    5440:	0377c7bb          	divw	a5,a5,s7
    5444:	0307879b          	addw	a5,a5,48
    5448:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    544c:	0374e7bb          	remw	a5,s1,s7
    5450:	0367c7bb          	divw	a5,a5,s6
    5454:	0307879b          	addw	a5,a5,48
    5458:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    545c:	0364e7bb          	remw	a5,s1,s6
    5460:	0307879b          	addw	a5,a5,48
    5464:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    5468:	f60402a3          	sb	zero,-155(s0)
    printf("writing %s\n", name);
    546c:	f6040593          	add	a1,s0,-160
    5470:	8566                	mv	a0,s9
    5472:	00001097          	auipc	ra,0x1
    5476:	b02080e7          	jalr	-1278(ra) # 5f74 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    547a:	20200593          	li	a1,514
    547e:	f6040513          	add	a0,s0,-160
    5482:	00000097          	auipc	ra,0x0
    5486:	7ba080e7          	jalr	1978(ra) # 5c3c <open>
    548a:	892a                	mv	s2,a0
    if(fd < 0){
    548c:	0a055563          	bgez	a0,5536 <fsfull+0x14e>
      printf("open %s failed\n", name);
    5490:	f6040593          	add	a1,s0,-160
    5494:	00003517          	auipc	a0,0x3
    5498:	be450513          	add	a0,a0,-1052 # 8078 <malloc+0x204c>
    549c:	00001097          	auipc	ra,0x1
    54a0:	ad8080e7          	jalr	-1320(ra) # 5f74 <printf>
  while(nfiles >= 0){
    54a4:	0604c363          	bltz	s1,550a <fsfull+0x122>
    name[0] = 'f';
    54a8:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    54ac:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    54b0:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    54b4:	4929                	li	s2,10
  while(nfiles >= 0){
    54b6:	5afd                	li	s5,-1
    name[0] = 'f';
    54b8:	f7640023          	sb	s6,-160(s0)
    name[1] = '0' + nfiles / 1000;
    54bc:	0344c7bb          	divw	a5,s1,s4
    54c0:	0307879b          	addw	a5,a5,48
    54c4:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    54c8:	0344e7bb          	remw	a5,s1,s4
    54cc:	0337c7bb          	divw	a5,a5,s3
    54d0:	0307879b          	addw	a5,a5,48
    54d4:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    54d8:	0334e7bb          	remw	a5,s1,s3
    54dc:	0327c7bb          	divw	a5,a5,s2
    54e0:	0307879b          	addw	a5,a5,48
    54e4:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    54e8:	0324e7bb          	remw	a5,s1,s2
    54ec:	0307879b          	addw	a5,a5,48
    54f0:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    54f4:	f60402a3          	sb	zero,-155(s0)
    unlink(name);
    54f8:	f6040513          	add	a0,s0,-160
    54fc:	00000097          	auipc	ra,0x0
    5500:	750080e7          	jalr	1872(ra) # 5c4c <unlink>
    nfiles--;
    5504:	34fd                	addw	s1,s1,-1
  while(nfiles >= 0){
    5506:	fb5499e3          	bne	s1,s5,54b8 <fsfull+0xd0>
  printf("fsfull test finished\n");
    550a:	00003517          	auipc	a0,0x3
    550e:	b8e50513          	add	a0,a0,-1138 # 8098 <malloc+0x206c>
    5512:	00001097          	auipc	ra,0x1
    5516:	a62080e7          	jalr	-1438(ra) # 5f74 <printf>
}
    551a:	60ea                	ld	ra,152(sp)
    551c:	644a                	ld	s0,144(sp)
    551e:	64aa                	ld	s1,136(sp)
    5520:	690a                	ld	s2,128(sp)
    5522:	79e6                	ld	s3,120(sp)
    5524:	7a46                	ld	s4,112(sp)
    5526:	7aa6                	ld	s5,104(sp)
    5528:	7b06                	ld	s6,96(sp)
    552a:	6be6                	ld	s7,88(sp)
    552c:	6c46                	ld	s8,80(sp)
    552e:	6ca6                	ld	s9,72(sp)
    5530:	6d06                	ld	s10,64(sp)
    5532:	610d                	add	sp,sp,160
    5534:	8082                	ret
    int total = 0;
    5536:	4981                	li	s3,0
      int cc = write(fd, buf, BSIZE);
    5538:	00007a97          	auipc	s5,0x7
    553c:	740a8a93          	add	s5,s5,1856 # cc78 <buf>
      if(cc < BSIZE)
    5540:	3ff00a13          	li	s4,1023
      int cc = write(fd, buf, BSIZE);
    5544:	40000613          	li	a2,1024
    5548:	85d6                	mv	a1,s5
    554a:	854a                	mv	a0,s2
    554c:	00000097          	auipc	ra,0x0
    5550:	6d0080e7          	jalr	1744(ra) # 5c1c <write>
      if(cc < BSIZE)
    5554:	00aa5563          	bge	s4,a0,555e <fsfull+0x176>
      total += cc;
    5558:	00a989bb          	addw	s3,s3,a0
    while(1){
    555c:	b7e5                	j	5544 <fsfull+0x15c>
    printf("wrote %d bytes\n", total);
    555e:	85ce                	mv	a1,s3
    5560:	00003517          	auipc	a0,0x3
    5564:	b2850513          	add	a0,a0,-1240 # 8088 <malloc+0x205c>
    5568:	00001097          	auipc	ra,0x1
    556c:	a0c080e7          	jalr	-1524(ra) # 5f74 <printf>
    close(fd);
    5570:	854a                	mv	a0,s2
    5572:	00000097          	auipc	ra,0x0
    5576:	6b2080e7          	jalr	1714(ra) # 5c24 <close>
    if(total == 0)
    557a:	f20985e3          	beqz	s3,54a4 <fsfull+0xbc>
  for(nfiles = 0; ; nfiles++){
    557e:	2485                	addw	s1,s1,1
    5580:	b575                	j	542c <fsfull+0x44>

0000000000005582 <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    5582:	7179                	add	sp,sp,-48
    5584:	f406                	sd	ra,40(sp)
    5586:	f022                	sd	s0,32(sp)
    5588:	ec26                	sd	s1,24(sp)
    558a:	e84a                	sd	s2,16(sp)
    558c:	1800                	add	s0,sp,48
    558e:	84aa                	mv	s1,a0
    5590:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    5592:	00003517          	auipc	a0,0x3
    5596:	b1e50513          	add	a0,a0,-1250 # 80b0 <malloc+0x2084>
    559a:	00001097          	auipc	ra,0x1
    559e:	9da080e7          	jalr	-1574(ra) # 5f74 <printf>
  if((pid = fork()) < 0) {
    55a2:	00000097          	auipc	ra,0x0
    55a6:	652080e7          	jalr	1618(ra) # 5bf4 <fork>
    55aa:	02054e63          	bltz	a0,55e6 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    55ae:	c929                	beqz	a0,5600 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    55b0:	fdc40513          	add	a0,s0,-36
    55b4:	00000097          	auipc	ra,0x0
    55b8:	650080e7          	jalr	1616(ra) # 5c04 <wait>
    if(xstatus != 0) 
    55bc:	fdc42783          	lw	a5,-36(s0)
    55c0:	c7b9                	beqz	a5,560e <run+0x8c>
      printf("FAILED\n");
    55c2:	00003517          	auipc	a0,0x3
    55c6:	b1650513          	add	a0,a0,-1258 # 80d8 <malloc+0x20ac>
    55ca:	00001097          	auipc	ra,0x1
    55ce:	9aa080e7          	jalr	-1622(ra) # 5f74 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    55d2:	fdc42503          	lw	a0,-36(s0)
  }
}
    55d6:	00153513          	seqz	a0,a0
    55da:	70a2                	ld	ra,40(sp)
    55dc:	7402                	ld	s0,32(sp)
    55de:	64e2                	ld	s1,24(sp)
    55e0:	6942                	ld	s2,16(sp)
    55e2:	6145                	add	sp,sp,48
    55e4:	8082                	ret
    printf("runtest: fork error\n");
    55e6:	00003517          	auipc	a0,0x3
    55ea:	ada50513          	add	a0,a0,-1318 # 80c0 <malloc+0x2094>
    55ee:	00001097          	auipc	ra,0x1
    55f2:	986080e7          	jalr	-1658(ra) # 5f74 <printf>
    exit(1);
    55f6:	4505                	li	a0,1
    55f8:	00000097          	auipc	ra,0x0
    55fc:	604080e7          	jalr	1540(ra) # 5bfc <exit>
    f(s);
    5600:	854a                	mv	a0,s2
    5602:	9482                	jalr	s1
    exit(0);
    5604:	4501                	li	a0,0
    5606:	00000097          	auipc	ra,0x0
    560a:	5f6080e7          	jalr	1526(ra) # 5bfc <exit>
      printf("OK\n");
    560e:	00003517          	auipc	a0,0x3
    5612:	ad250513          	add	a0,a0,-1326 # 80e0 <malloc+0x20b4>
    5616:	00001097          	auipc	ra,0x1
    561a:	95e080e7          	jalr	-1698(ra) # 5f74 <printf>
    561e:	bf55                	j	55d2 <run+0x50>

0000000000005620 <runtests>:

int
runtests(struct test *tests, char *justone) {
    5620:	1101                	add	sp,sp,-32
    5622:	ec06                	sd	ra,24(sp)
    5624:	e822                	sd	s0,16(sp)
    5626:	e426                	sd	s1,8(sp)
    5628:	e04a                	sd	s2,0(sp)
    562a:	1000                	add	s0,sp,32
    562c:	84aa                	mv	s1,a0
    562e:	892e                	mv	s2,a1
  for (struct test *t = tests; t->s != 0; t++) {
    5630:	6508                	ld	a0,8(a0)
    5632:	ed09                	bnez	a0,564c <runtests+0x2c>
        printf("SOME TESTS FAILED\n");
        return 1;
      }
    }
  }
  return 0;
    5634:	4501                	li	a0,0
    5636:	a82d                	j	5670 <runtests+0x50>
      if(!run(t->f, t->s)){
    5638:	648c                	ld	a1,8(s1)
    563a:	6088                	ld	a0,0(s1)
    563c:	00000097          	auipc	ra,0x0
    5640:	f46080e7          	jalr	-186(ra) # 5582 <run>
    5644:	cd09                	beqz	a0,565e <runtests+0x3e>
  for (struct test *t = tests; t->s != 0; t++) {
    5646:	04c1                	add	s1,s1,16
    5648:	6488                	ld	a0,8(s1)
    564a:	c11d                	beqz	a0,5670 <runtests+0x50>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    564c:	fe0906e3          	beqz	s2,5638 <runtests+0x18>
    5650:	85ca                	mv	a1,s2
    5652:	00000097          	auipc	ra,0x0
    5656:	35a080e7          	jalr	858(ra) # 59ac <strcmp>
    565a:	f575                	bnez	a0,5646 <runtests+0x26>
    565c:	bff1                	j	5638 <runtests+0x18>
        printf("SOME TESTS FAILED\n");
    565e:	00003517          	auipc	a0,0x3
    5662:	a8a50513          	add	a0,a0,-1398 # 80e8 <malloc+0x20bc>
    5666:	00001097          	auipc	ra,0x1
    566a:	90e080e7          	jalr	-1778(ra) # 5f74 <printf>
        return 1;
    566e:	4505                	li	a0,1
}
    5670:	60e2                	ld	ra,24(sp)
    5672:	6442                	ld	s0,16(sp)
    5674:	64a2                	ld	s1,8(sp)
    5676:	6902                	ld	s2,0(sp)
    5678:	6105                	add	sp,sp,32
    567a:	8082                	ret

000000000000567c <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    567c:	7139                	add	sp,sp,-64
    567e:	fc06                	sd	ra,56(sp)
    5680:	f822                	sd	s0,48(sp)
    5682:	0080                	add	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    5684:	fc840513          	add	a0,s0,-56
    5688:	00000097          	auipc	ra,0x0
    568c:	584080e7          	jalr	1412(ra) # 5c0c <pipe>
    5690:	06054a63          	bltz	a0,5704 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    5694:	00000097          	auipc	ra,0x0
    5698:	560080e7          	jalr	1376(ra) # 5bf4 <fork>

  if(pid < 0){
    569c:	08054463          	bltz	a0,5724 <countfree+0xa8>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    56a0:	e55d                	bnez	a0,574e <countfree+0xd2>
    56a2:	f426                	sd	s1,40(sp)
    56a4:	f04a                	sd	s2,32(sp)
    56a6:	ec4e                	sd	s3,24(sp)
    close(fds[0]);
    56a8:	fc842503          	lw	a0,-56(s0)
    56ac:	00000097          	auipc	ra,0x0
    56b0:	578080e7          	jalr	1400(ra) # 5c24 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    56b4:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    56b6:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    56b8:	00001997          	auipc	s3,0x1
    56bc:	b2098993          	add	s3,s3,-1248 # 61d8 <malloc+0x1ac>
      uint64 a = (uint64) sbrk(4096);
    56c0:	6505                	lui	a0,0x1
    56c2:	00000097          	auipc	ra,0x0
    56c6:	5c2080e7          	jalr	1474(ra) # 5c84 <sbrk>
      if(a == 0xffffffffffffffff){
    56ca:	07250d63          	beq	a0,s2,5744 <countfree+0xc8>
      *(char *)(a + 4096 - 1) = 1;
    56ce:	6785                	lui	a5,0x1
    56d0:	97aa                	add	a5,a5,a0
    56d2:	fe978fa3          	sb	s1,-1(a5) # fff <linktest+0x10b>
      if(write(fds[1], "x", 1) != 1){
    56d6:	8626                	mv	a2,s1
    56d8:	85ce                	mv	a1,s3
    56da:	fcc42503          	lw	a0,-52(s0)
    56de:	00000097          	auipc	ra,0x0
    56e2:	53e080e7          	jalr	1342(ra) # 5c1c <write>
    56e6:	fc950de3          	beq	a0,s1,56c0 <countfree+0x44>
        printf("write() failed in countfree()\n");
    56ea:	00003517          	auipc	a0,0x3
    56ee:	a5650513          	add	a0,a0,-1450 # 8140 <malloc+0x2114>
    56f2:	00001097          	auipc	ra,0x1
    56f6:	882080e7          	jalr	-1918(ra) # 5f74 <printf>
        exit(1);
    56fa:	4505                	li	a0,1
    56fc:	00000097          	auipc	ra,0x0
    5700:	500080e7          	jalr	1280(ra) # 5bfc <exit>
    5704:	f426                	sd	s1,40(sp)
    5706:	f04a                	sd	s2,32(sp)
    5708:	ec4e                	sd	s3,24(sp)
    printf("pipe() failed in countfree()\n");
    570a:	00003517          	auipc	a0,0x3
    570e:	9f650513          	add	a0,a0,-1546 # 8100 <malloc+0x20d4>
    5712:	00001097          	auipc	ra,0x1
    5716:	862080e7          	jalr	-1950(ra) # 5f74 <printf>
    exit(1);
    571a:	4505                	li	a0,1
    571c:	00000097          	auipc	ra,0x0
    5720:	4e0080e7          	jalr	1248(ra) # 5bfc <exit>
    5724:	f426                	sd	s1,40(sp)
    5726:	f04a                	sd	s2,32(sp)
    5728:	ec4e                	sd	s3,24(sp)
    printf("fork failed in countfree()\n");
    572a:	00003517          	auipc	a0,0x3
    572e:	9f650513          	add	a0,a0,-1546 # 8120 <malloc+0x20f4>
    5732:	00001097          	auipc	ra,0x1
    5736:	842080e7          	jalr	-1982(ra) # 5f74 <printf>
    exit(1);
    573a:	4505                	li	a0,1
    573c:	00000097          	auipc	ra,0x0
    5740:	4c0080e7          	jalr	1216(ra) # 5bfc <exit>
      }
    }

    exit(0);
    5744:	4501                	li	a0,0
    5746:	00000097          	auipc	ra,0x0
    574a:	4b6080e7          	jalr	1206(ra) # 5bfc <exit>
    574e:	f426                	sd	s1,40(sp)
  }

  close(fds[1]);
    5750:	fcc42503          	lw	a0,-52(s0)
    5754:	00000097          	auipc	ra,0x0
    5758:	4d0080e7          	jalr	1232(ra) # 5c24 <close>

  int n = 0;
    575c:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    575e:	4605                	li	a2,1
    5760:	fc740593          	add	a1,s0,-57
    5764:	fc842503          	lw	a0,-56(s0)
    5768:	00000097          	auipc	ra,0x0
    576c:	4ac080e7          	jalr	1196(ra) # 5c14 <read>
    if(cc < 0){
    5770:	00054563          	bltz	a0,577a <countfree+0xfe>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5774:	c115                	beqz	a0,5798 <countfree+0x11c>
      break;
    n += 1;
    5776:	2485                	addw	s1,s1,1
  while(1){
    5778:	b7dd                	j	575e <countfree+0xe2>
    577a:	f04a                	sd	s2,32(sp)
    577c:	ec4e                	sd	s3,24(sp)
      printf("read() failed in countfree()\n");
    577e:	00003517          	auipc	a0,0x3
    5782:	9e250513          	add	a0,a0,-1566 # 8160 <malloc+0x2134>
    5786:	00000097          	auipc	ra,0x0
    578a:	7ee080e7          	jalr	2030(ra) # 5f74 <printf>
      exit(1);
    578e:	4505                	li	a0,1
    5790:	00000097          	auipc	ra,0x0
    5794:	46c080e7          	jalr	1132(ra) # 5bfc <exit>
  }

  close(fds[0]);
    5798:	fc842503          	lw	a0,-56(s0)
    579c:	00000097          	auipc	ra,0x0
    57a0:	488080e7          	jalr	1160(ra) # 5c24 <close>
  wait((int*)0);
    57a4:	4501                	li	a0,0
    57a6:	00000097          	auipc	ra,0x0
    57aa:	45e080e7          	jalr	1118(ra) # 5c04 <wait>
  
  return n;
}
    57ae:	8526                	mv	a0,s1
    57b0:	74a2                	ld	s1,40(sp)
    57b2:	70e2                	ld	ra,56(sp)
    57b4:	7442                	ld	s0,48(sp)
    57b6:	6121                	add	sp,sp,64
    57b8:	8082                	ret

00000000000057ba <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    57ba:	711d                	add	sp,sp,-96
    57bc:	ec86                	sd	ra,88(sp)
    57be:	e8a2                	sd	s0,80(sp)
    57c0:	e4a6                	sd	s1,72(sp)
    57c2:	e0ca                	sd	s2,64(sp)
    57c4:	fc4e                	sd	s3,56(sp)
    57c6:	f852                	sd	s4,48(sp)
    57c8:	f456                	sd	s5,40(sp)
    57ca:	f05a                	sd	s6,32(sp)
    57cc:	ec5e                	sd	s7,24(sp)
    57ce:	e862                	sd	s8,16(sp)
    57d0:	e466                	sd	s9,8(sp)
    57d2:	e06a                	sd	s10,0(sp)
    57d4:	1080                	add	s0,sp,96
    57d6:	8aaa                	mv	s5,a0
    57d8:	89ae                	mv	s3,a1
    57da:	8932                	mv	s2,a2
  do {
    printf("usertests starting\n");
    57dc:	00003b97          	auipc	s7,0x3
    57e0:	9a4b8b93          	add	s7,s7,-1628 # 8180 <malloc+0x2154>
    int free0 = countfree();
    int free1 = 0;
    if (runtests(quicktests, justone)) {
    57e4:	00004b17          	auipc	s6,0x4
    57e8:	82cb0b13          	add	s6,s6,-2004 # 9010 <quicktests>
      if(continuous != 2) {
    57ec:	4a09                	li	s4,2
      }
    }
    if(!quick) {
      if (justone == 0)
        printf("usertests slow tests starting\n");
      if (runtests(slowtests, justone)) {
    57ee:	00004c17          	auipc	s8,0x4
    57f2:	bf2c0c13          	add	s8,s8,-1038 # 93e0 <slowtests>
        printf("usertests slow tests starting\n");
    57f6:	00003d17          	auipc	s10,0x3
    57fa:	9a2d0d13          	add	s10,s10,-1630 # 8198 <malloc+0x216c>
          return 1;
        }
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    57fe:	00003c97          	auipc	s9,0x3
    5802:	9bac8c93          	add	s9,s9,-1606 # 81b8 <malloc+0x218c>
    5806:	a839                	j	5824 <drivetests+0x6a>
        printf("usertests slow tests starting\n");
    5808:	856a                	mv	a0,s10
    580a:	00000097          	auipc	ra,0x0
    580e:	76a080e7          	jalr	1898(ra) # 5f74 <printf>
    5812:	a081                	j	5852 <drivetests+0x98>
    if((free1 = countfree()) < free0) {
    5814:	00000097          	auipc	ra,0x0
    5818:	e68080e7          	jalr	-408(ra) # 567c <countfree>
    581c:	04954663          	blt	a0,s1,5868 <drivetests+0xae>
      if(continuous != 2) {
        return 1;
      }
    }
  } while(continuous);
    5820:	06098163          	beqz	s3,5882 <drivetests+0xc8>
    printf("usertests starting\n");
    5824:	855e                	mv	a0,s7
    5826:	00000097          	auipc	ra,0x0
    582a:	74e080e7          	jalr	1870(ra) # 5f74 <printf>
    int free0 = countfree();
    582e:	00000097          	auipc	ra,0x0
    5832:	e4e080e7          	jalr	-434(ra) # 567c <countfree>
    5836:	84aa                	mv	s1,a0
    if (runtests(quicktests, justone)) {
    5838:	85ca                	mv	a1,s2
    583a:	855a                	mv	a0,s6
    583c:	00000097          	auipc	ra,0x0
    5840:	de4080e7          	jalr	-540(ra) # 5620 <runtests>
    5844:	c119                	beqz	a0,584a <drivetests+0x90>
      if(continuous != 2) {
    5846:	03499c63          	bne	s3,s4,587e <drivetests+0xc4>
    if(!quick) {
    584a:	fc0a95e3          	bnez	s5,5814 <drivetests+0x5a>
      if (justone == 0)
    584e:	fa090de3          	beqz	s2,5808 <drivetests+0x4e>
      if (runtests(slowtests, justone)) {
    5852:	85ca                	mv	a1,s2
    5854:	8562                	mv	a0,s8
    5856:	00000097          	auipc	ra,0x0
    585a:	dca080e7          	jalr	-566(ra) # 5620 <runtests>
    585e:	d95d                	beqz	a0,5814 <drivetests+0x5a>
        if(continuous != 2) {
    5860:	fb498ae3          	beq	s3,s4,5814 <drivetests+0x5a>
          return 1;
    5864:	4505                	li	a0,1
    5866:	a839                	j	5884 <drivetests+0xca>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5868:	8626                	mv	a2,s1
    586a:	85aa                	mv	a1,a0
    586c:	8566                	mv	a0,s9
    586e:	00000097          	auipc	ra,0x0
    5872:	706080e7          	jalr	1798(ra) # 5f74 <printf>
      if(continuous != 2) {
    5876:	fb4987e3          	beq	s3,s4,5824 <drivetests+0x6a>
        return 1;
    587a:	4505                	li	a0,1
    587c:	a021                	j	5884 <drivetests+0xca>
        return 1;
    587e:	4505                	li	a0,1
    5880:	a011                	j	5884 <drivetests+0xca>
  return 0;
    5882:	854e                	mv	a0,s3
}
    5884:	60e6                	ld	ra,88(sp)
    5886:	6446                	ld	s0,80(sp)
    5888:	64a6                	ld	s1,72(sp)
    588a:	6906                	ld	s2,64(sp)
    588c:	79e2                	ld	s3,56(sp)
    588e:	7a42                	ld	s4,48(sp)
    5890:	7aa2                	ld	s5,40(sp)
    5892:	7b02                	ld	s6,32(sp)
    5894:	6be2                	ld	s7,24(sp)
    5896:	6c42                	ld	s8,16(sp)
    5898:	6ca2                	ld	s9,8(sp)
    589a:	6d02                	ld	s10,0(sp)
    589c:	6125                	add	sp,sp,96
    589e:	8082                	ret

00000000000058a0 <main>:

int
main(int argc, char *argv[])
{
    58a0:	1101                	add	sp,sp,-32
    58a2:	ec06                	sd	ra,24(sp)
    58a4:	e822                	sd	s0,16(sp)
    58a6:	e426                	sd	s1,8(sp)
    58a8:	e04a                	sd	s2,0(sp)
    58aa:	1000                	add	s0,sp,32
    58ac:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    58ae:	4789                	li	a5,2
    58b0:	02f50263          	beq	a0,a5,58d4 <main+0x34>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    58b4:	4785                	li	a5,1
    58b6:	08a7c063          	blt	a5,a0,5936 <main+0x96>
  char *justone = 0;
    58ba:	4601                	li	a2,0
  int quick = 0;
    58bc:	4501                	li	a0,0
  int continuous = 0;
    58be:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    58c0:	00000097          	auipc	ra,0x0
    58c4:	efa080e7          	jalr	-262(ra) # 57ba <drivetests>
    58c8:	c951                	beqz	a0,595c <main+0xbc>
    exit(1);
    58ca:	4505                	li	a0,1
    58cc:	00000097          	auipc	ra,0x0
    58d0:	330080e7          	jalr	816(ra) # 5bfc <exit>
    58d4:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    58d6:	00003597          	auipc	a1,0x3
    58da:	91258593          	add	a1,a1,-1774 # 81e8 <malloc+0x21bc>
    58de:	00893503          	ld	a0,8(s2)
    58e2:	00000097          	auipc	ra,0x0
    58e6:	0ca080e7          	jalr	202(ra) # 59ac <strcmp>
    58ea:	85aa                	mv	a1,a0
    58ec:	e501                	bnez	a0,58f4 <main+0x54>
  char *justone = 0;
    58ee:	4601                	li	a2,0
    quick = 1;
    58f0:	4505                	li	a0,1
    58f2:	b7f9                	j	58c0 <main+0x20>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    58f4:	00003597          	auipc	a1,0x3
    58f8:	8fc58593          	add	a1,a1,-1796 # 81f0 <malloc+0x21c4>
    58fc:	00893503          	ld	a0,8(s2)
    5900:	00000097          	auipc	ra,0x0
    5904:	0ac080e7          	jalr	172(ra) # 59ac <strcmp>
    5908:	c521                	beqz	a0,5950 <main+0xb0>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    590a:	00003597          	auipc	a1,0x3
    590e:	93658593          	add	a1,a1,-1738 # 8240 <malloc+0x2214>
    5912:	00893503          	ld	a0,8(s2)
    5916:	00000097          	auipc	ra,0x0
    591a:	096080e7          	jalr	150(ra) # 59ac <strcmp>
    591e:	cd05                	beqz	a0,5956 <main+0xb6>
  } else if(argc == 2 && argv[1][0] != '-'){
    5920:	00893603          	ld	a2,8(s2)
    5924:	00064703          	lbu	a4,0(a2) # 3000 <execout+0x52>
    5928:	02d00793          	li	a5,45
    592c:	00f70563          	beq	a4,a5,5936 <main+0x96>
  int quick = 0;
    5930:	4501                	li	a0,0
  int continuous = 0;
    5932:	4581                	li	a1,0
    5934:	b771                	j	58c0 <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    5936:	00003517          	auipc	a0,0x3
    593a:	8c250513          	add	a0,a0,-1854 # 81f8 <malloc+0x21cc>
    593e:	00000097          	auipc	ra,0x0
    5942:	636080e7          	jalr	1590(ra) # 5f74 <printf>
    exit(1);
    5946:	4505                	li	a0,1
    5948:	00000097          	auipc	ra,0x0
    594c:	2b4080e7          	jalr	692(ra) # 5bfc <exit>
  char *justone = 0;
    5950:	4601                	li	a2,0
    continuous = 1;
    5952:	4585                	li	a1,1
    5954:	b7b5                	j	58c0 <main+0x20>
    continuous = 2;
    5956:	85a6                	mv	a1,s1
  char *justone = 0;
    5958:	4601                	li	a2,0
    595a:	b79d                	j	58c0 <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    595c:	00003517          	auipc	a0,0x3
    5960:	8cc50513          	add	a0,a0,-1844 # 8228 <malloc+0x21fc>
    5964:	00000097          	auipc	ra,0x0
    5968:	610080e7          	jalr	1552(ra) # 5f74 <printf>
  exit(0);
    596c:	4501                	li	a0,0
    596e:	00000097          	auipc	ra,0x0
    5972:	28e080e7          	jalr	654(ra) # 5bfc <exit>

0000000000005976 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
    5976:	1141                	add	sp,sp,-16
    5978:	e406                	sd	ra,8(sp)
    597a:	e022                	sd	s0,0(sp)
    597c:	0800                	add	s0,sp,16
  extern int main();
  main();
    597e:	00000097          	auipc	ra,0x0
    5982:	f22080e7          	jalr	-222(ra) # 58a0 <main>
  exit(0);
    5986:	4501                	li	a0,0
    5988:	00000097          	auipc	ra,0x0
    598c:	274080e7          	jalr	628(ra) # 5bfc <exit>

0000000000005990 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    5990:	1141                	add	sp,sp,-16
    5992:	e422                	sd	s0,8(sp)
    5994:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5996:	87aa                	mv	a5,a0
    5998:	0585                	add	a1,a1,1
    599a:	0785                	add	a5,a5,1
    599c:	fff5c703          	lbu	a4,-1(a1)
    59a0:	fee78fa3          	sb	a4,-1(a5)
    59a4:	fb75                	bnez	a4,5998 <strcpy+0x8>
    ;
  return os;
}
    59a6:	6422                	ld	s0,8(sp)
    59a8:	0141                	add	sp,sp,16
    59aa:	8082                	ret

00000000000059ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
    59ac:	1141                	add	sp,sp,-16
    59ae:	e422                	sd	s0,8(sp)
    59b0:	0800                	add	s0,sp,16
  while(*p && *p == *q)
    59b2:	00054783          	lbu	a5,0(a0)
    59b6:	cb91                	beqz	a5,59ca <strcmp+0x1e>
    59b8:	0005c703          	lbu	a4,0(a1)
    59bc:	00f71763          	bne	a4,a5,59ca <strcmp+0x1e>
    p++, q++;
    59c0:	0505                	add	a0,a0,1
    59c2:	0585                	add	a1,a1,1
  while(*p && *p == *q)
    59c4:	00054783          	lbu	a5,0(a0)
    59c8:	fbe5                	bnez	a5,59b8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    59ca:	0005c503          	lbu	a0,0(a1)
}
    59ce:	40a7853b          	subw	a0,a5,a0
    59d2:	6422                	ld	s0,8(sp)
    59d4:	0141                	add	sp,sp,16
    59d6:	8082                	ret

00000000000059d8 <strlen>:

uint
strlen(const char *s)
{
    59d8:	1141                	add	sp,sp,-16
    59da:	e422                	sd	s0,8(sp)
    59dc:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    59de:	00054783          	lbu	a5,0(a0)
    59e2:	cf91                	beqz	a5,59fe <strlen+0x26>
    59e4:	0505                	add	a0,a0,1
    59e6:	87aa                	mv	a5,a0
    59e8:	86be                	mv	a3,a5
    59ea:	0785                	add	a5,a5,1
    59ec:	fff7c703          	lbu	a4,-1(a5)
    59f0:	ff65                	bnez	a4,59e8 <strlen+0x10>
    59f2:	40a6853b          	subw	a0,a3,a0
    59f6:	2505                	addw	a0,a0,1
    ;
  return n;
}
    59f8:	6422                	ld	s0,8(sp)
    59fa:	0141                	add	sp,sp,16
    59fc:	8082                	ret
  for(n = 0; s[n]; n++)
    59fe:	4501                	li	a0,0
    5a00:	bfe5                	j	59f8 <strlen+0x20>

0000000000005a02 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5a02:	1141                	add	sp,sp,-16
    5a04:	e422                	sd	s0,8(sp)
    5a06:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5a08:	ca19                	beqz	a2,5a1e <memset+0x1c>
    5a0a:	87aa                	mv	a5,a0
    5a0c:	1602                	sll	a2,a2,0x20
    5a0e:	9201                	srl	a2,a2,0x20
    5a10:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    5a14:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5a18:	0785                	add	a5,a5,1
    5a1a:	fee79de3          	bne	a5,a4,5a14 <memset+0x12>
  }
  return dst;
}
    5a1e:	6422                	ld	s0,8(sp)
    5a20:	0141                	add	sp,sp,16
    5a22:	8082                	ret

0000000000005a24 <strchr>:

char*
strchr(const char *s, char c)
{
    5a24:	1141                	add	sp,sp,-16
    5a26:	e422                	sd	s0,8(sp)
    5a28:	0800                	add	s0,sp,16
  for(; *s; s++)
    5a2a:	00054783          	lbu	a5,0(a0)
    5a2e:	cb99                	beqz	a5,5a44 <strchr+0x20>
    if(*s == c)
    5a30:	00f58763          	beq	a1,a5,5a3e <strchr+0x1a>
  for(; *s; s++)
    5a34:	0505                	add	a0,a0,1
    5a36:	00054783          	lbu	a5,0(a0)
    5a3a:	fbfd                	bnez	a5,5a30 <strchr+0xc>
      return (char*)s;
  return 0;
    5a3c:	4501                	li	a0,0
}
    5a3e:	6422                	ld	s0,8(sp)
    5a40:	0141                	add	sp,sp,16
    5a42:	8082                	ret
  return 0;
    5a44:	4501                	li	a0,0
    5a46:	bfe5                	j	5a3e <strchr+0x1a>

0000000000005a48 <gets>:

char*
gets(char *buf, int max)
{
    5a48:	711d                	add	sp,sp,-96
    5a4a:	ec86                	sd	ra,88(sp)
    5a4c:	e8a2                	sd	s0,80(sp)
    5a4e:	e4a6                	sd	s1,72(sp)
    5a50:	e0ca                	sd	s2,64(sp)
    5a52:	fc4e                	sd	s3,56(sp)
    5a54:	f852                	sd	s4,48(sp)
    5a56:	f456                	sd	s5,40(sp)
    5a58:	f05a                	sd	s6,32(sp)
    5a5a:	ec5e                	sd	s7,24(sp)
    5a5c:	1080                	add	s0,sp,96
    5a5e:	8baa                	mv	s7,a0
    5a60:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5a62:	892a                	mv	s2,a0
    5a64:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5a66:	4aa9                	li	s5,10
    5a68:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5a6a:	89a6                	mv	s3,s1
    5a6c:	2485                	addw	s1,s1,1
    5a6e:	0344d863          	bge	s1,s4,5a9e <gets+0x56>
    cc = read(0, &c, 1);
    5a72:	4605                	li	a2,1
    5a74:	faf40593          	add	a1,s0,-81
    5a78:	4501                	li	a0,0
    5a7a:	00000097          	auipc	ra,0x0
    5a7e:	19a080e7          	jalr	410(ra) # 5c14 <read>
    if(cc < 1)
    5a82:	00a05e63          	blez	a0,5a9e <gets+0x56>
    buf[i++] = c;
    5a86:	faf44783          	lbu	a5,-81(s0)
    5a8a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5a8e:	01578763          	beq	a5,s5,5a9c <gets+0x54>
    5a92:	0905                	add	s2,s2,1
    5a94:	fd679be3          	bne	a5,s6,5a6a <gets+0x22>
    buf[i++] = c;
    5a98:	89a6                	mv	s3,s1
    5a9a:	a011                	j	5a9e <gets+0x56>
    5a9c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5a9e:	99de                	add	s3,s3,s7
    5aa0:	00098023          	sb	zero,0(s3)
  return buf;
}
    5aa4:	855e                	mv	a0,s7
    5aa6:	60e6                	ld	ra,88(sp)
    5aa8:	6446                	ld	s0,80(sp)
    5aaa:	64a6                	ld	s1,72(sp)
    5aac:	6906                	ld	s2,64(sp)
    5aae:	79e2                	ld	s3,56(sp)
    5ab0:	7a42                	ld	s4,48(sp)
    5ab2:	7aa2                	ld	s5,40(sp)
    5ab4:	7b02                	ld	s6,32(sp)
    5ab6:	6be2                	ld	s7,24(sp)
    5ab8:	6125                	add	sp,sp,96
    5aba:	8082                	ret

0000000000005abc <stat>:

int
stat(const char *n, struct stat *st)
{
    5abc:	1101                	add	sp,sp,-32
    5abe:	ec06                	sd	ra,24(sp)
    5ac0:	e822                	sd	s0,16(sp)
    5ac2:	e04a                	sd	s2,0(sp)
    5ac4:	1000                	add	s0,sp,32
    5ac6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5ac8:	4581                	li	a1,0
    5aca:	00000097          	auipc	ra,0x0
    5ace:	172080e7          	jalr	370(ra) # 5c3c <open>
  if(fd < 0)
    5ad2:	02054663          	bltz	a0,5afe <stat+0x42>
    5ad6:	e426                	sd	s1,8(sp)
    5ad8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5ada:	85ca                	mv	a1,s2
    5adc:	00000097          	auipc	ra,0x0
    5ae0:	178080e7          	jalr	376(ra) # 5c54 <fstat>
    5ae4:	892a                	mv	s2,a0
  close(fd);
    5ae6:	8526                	mv	a0,s1
    5ae8:	00000097          	auipc	ra,0x0
    5aec:	13c080e7          	jalr	316(ra) # 5c24 <close>
  return r;
    5af0:	64a2                	ld	s1,8(sp)
}
    5af2:	854a                	mv	a0,s2
    5af4:	60e2                	ld	ra,24(sp)
    5af6:	6442                	ld	s0,16(sp)
    5af8:	6902                	ld	s2,0(sp)
    5afa:	6105                	add	sp,sp,32
    5afc:	8082                	ret
    return -1;
    5afe:	597d                	li	s2,-1
    5b00:	bfcd                	j	5af2 <stat+0x36>

0000000000005b02 <atoi>:

int
atoi(const char *s)
{
    5b02:	1141                	add	sp,sp,-16
    5b04:	e422                	sd	s0,8(sp)
    5b06:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5b08:	00054683          	lbu	a3,0(a0)
    5b0c:	fd06879b          	addw	a5,a3,-48
    5b10:	0ff7f793          	zext.b	a5,a5
    5b14:	4625                	li	a2,9
    5b16:	02f66863          	bltu	a2,a5,5b46 <atoi+0x44>
    5b1a:	872a                	mv	a4,a0
  n = 0;
    5b1c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    5b1e:	0705                	add	a4,a4,1
    5b20:	0025179b          	sllw	a5,a0,0x2
    5b24:	9fa9                	addw	a5,a5,a0
    5b26:	0017979b          	sllw	a5,a5,0x1
    5b2a:	9fb5                	addw	a5,a5,a3
    5b2c:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5b30:	00074683          	lbu	a3,0(a4)
    5b34:	fd06879b          	addw	a5,a3,-48
    5b38:	0ff7f793          	zext.b	a5,a5
    5b3c:	fef671e3          	bgeu	a2,a5,5b1e <atoi+0x1c>
  return n;
}
    5b40:	6422                	ld	s0,8(sp)
    5b42:	0141                	add	sp,sp,16
    5b44:	8082                	ret
  n = 0;
    5b46:	4501                	li	a0,0
    5b48:	bfe5                	j	5b40 <atoi+0x3e>

0000000000005b4a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5b4a:	1141                	add	sp,sp,-16
    5b4c:	e422                	sd	s0,8(sp)
    5b4e:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5b50:	02b57463          	bgeu	a0,a1,5b78 <memmove+0x2e>
    while(n-- > 0)
    5b54:	00c05f63          	blez	a2,5b72 <memmove+0x28>
    5b58:	1602                	sll	a2,a2,0x20
    5b5a:	9201                	srl	a2,a2,0x20
    5b5c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5b60:	872a                	mv	a4,a0
      *dst++ = *src++;
    5b62:	0585                	add	a1,a1,1
    5b64:	0705                	add	a4,a4,1
    5b66:	fff5c683          	lbu	a3,-1(a1)
    5b6a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5b6e:	fef71ae3          	bne	a4,a5,5b62 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5b72:	6422                	ld	s0,8(sp)
    5b74:	0141                	add	sp,sp,16
    5b76:	8082                	ret
    dst += n;
    5b78:	00c50733          	add	a4,a0,a2
    src += n;
    5b7c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5b7e:	fec05ae3          	blez	a2,5b72 <memmove+0x28>
    5b82:	fff6079b          	addw	a5,a2,-1
    5b86:	1782                	sll	a5,a5,0x20
    5b88:	9381                	srl	a5,a5,0x20
    5b8a:	fff7c793          	not	a5,a5
    5b8e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5b90:	15fd                	add	a1,a1,-1
    5b92:	177d                	add	a4,a4,-1
    5b94:	0005c683          	lbu	a3,0(a1)
    5b98:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5b9c:	fee79ae3          	bne	a5,a4,5b90 <memmove+0x46>
    5ba0:	bfc9                	j	5b72 <memmove+0x28>

0000000000005ba2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5ba2:	1141                	add	sp,sp,-16
    5ba4:	e422                	sd	s0,8(sp)
    5ba6:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5ba8:	ca05                	beqz	a2,5bd8 <memcmp+0x36>
    5baa:	fff6069b          	addw	a3,a2,-1
    5bae:	1682                	sll	a3,a3,0x20
    5bb0:	9281                	srl	a3,a3,0x20
    5bb2:	0685                	add	a3,a3,1
    5bb4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5bb6:	00054783          	lbu	a5,0(a0)
    5bba:	0005c703          	lbu	a4,0(a1)
    5bbe:	00e79863          	bne	a5,a4,5bce <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5bc2:	0505                	add	a0,a0,1
    p2++;
    5bc4:	0585                	add	a1,a1,1
  while (n-- > 0) {
    5bc6:	fed518e3          	bne	a0,a3,5bb6 <memcmp+0x14>
  }
  return 0;
    5bca:	4501                	li	a0,0
    5bcc:	a019                	j	5bd2 <memcmp+0x30>
      return *p1 - *p2;
    5bce:	40e7853b          	subw	a0,a5,a4
}
    5bd2:	6422                	ld	s0,8(sp)
    5bd4:	0141                	add	sp,sp,16
    5bd6:	8082                	ret
  return 0;
    5bd8:	4501                	li	a0,0
    5bda:	bfe5                	j	5bd2 <memcmp+0x30>

0000000000005bdc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5bdc:	1141                	add	sp,sp,-16
    5bde:	e406                	sd	ra,8(sp)
    5be0:	e022                	sd	s0,0(sp)
    5be2:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    5be4:	00000097          	auipc	ra,0x0
    5be8:	f66080e7          	jalr	-154(ra) # 5b4a <memmove>
}
    5bec:	60a2                	ld	ra,8(sp)
    5bee:	6402                	ld	s0,0(sp)
    5bf0:	0141                	add	sp,sp,16
    5bf2:	8082                	ret

0000000000005bf4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5bf4:	4885                	li	a7,1
 ecall
    5bf6:	00000073          	ecall
 ret
    5bfa:	8082                	ret

0000000000005bfc <exit>:
.global exit
exit:
 li a7, SYS_exit
    5bfc:	4889                	li	a7,2
 ecall
    5bfe:	00000073          	ecall
 ret
    5c02:	8082                	ret

0000000000005c04 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5c04:	488d                	li	a7,3
 ecall
    5c06:	00000073          	ecall
 ret
    5c0a:	8082                	ret

0000000000005c0c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5c0c:	4891                	li	a7,4
 ecall
    5c0e:	00000073          	ecall
 ret
    5c12:	8082                	ret

0000000000005c14 <read>:
.global read
read:
 li a7, SYS_read
    5c14:	4895                	li	a7,5
 ecall
    5c16:	00000073          	ecall
 ret
    5c1a:	8082                	ret

0000000000005c1c <write>:
.global write
write:
 li a7, SYS_write
    5c1c:	48c1                	li	a7,16
 ecall
    5c1e:	00000073          	ecall
 ret
    5c22:	8082                	ret

0000000000005c24 <close>:
.global close
close:
 li a7, SYS_close
    5c24:	48d5                	li	a7,21
 ecall
    5c26:	00000073          	ecall
 ret
    5c2a:	8082                	ret

0000000000005c2c <kill>:
.global kill
kill:
 li a7, SYS_kill
    5c2c:	4899                	li	a7,6
 ecall
    5c2e:	00000073          	ecall
 ret
    5c32:	8082                	ret

0000000000005c34 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5c34:	489d                	li	a7,7
 ecall
    5c36:	00000073          	ecall
 ret
    5c3a:	8082                	ret

0000000000005c3c <open>:
.global open
open:
 li a7, SYS_open
    5c3c:	48bd                	li	a7,15
 ecall
    5c3e:	00000073          	ecall
 ret
    5c42:	8082                	ret

0000000000005c44 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5c44:	48c5                	li	a7,17
 ecall
    5c46:	00000073          	ecall
 ret
    5c4a:	8082                	ret

0000000000005c4c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5c4c:	48c9                	li	a7,18
 ecall
    5c4e:	00000073          	ecall
 ret
    5c52:	8082                	ret

0000000000005c54 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5c54:	48a1                	li	a7,8
 ecall
    5c56:	00000073          	ecall
 ret
    5c5a:	8082                	ret

0000000000005c5c <link>:
.global link
link:
 li a7, SYS_link
    5c5c:	48cd                	li	a7,19
 ecall
    5c5e:	00000073          	ecall
 ret
    5c62:	8082                	ret

0000000000005c64 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5c64:	48d1                	li	a7,20
 ecall
    5c66:	00000073          	ecall
 ret
    5c6a:	8082                	ret

0000000000005c6c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    5c6c:	48a5                	li	a7,9
 ecall
    5c6e:	00000073          	ecall
 ret
    5c72:	8082                	ret

0000000000005c74 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5c74:	48a9                	li	a7,10
 ecall
    5c76:	00000073          	ecall
 ret
    5c7a:	8082                	ret

0000000000005c7c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    5c7c:	48ad                	li	a7,11
 ecall
    5c7e:	00000073          	ecall
 ret
    5c82:	8082                	ret

0000000000005c84 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5c84:	48b1                	li	a7,12
 ecall
    5c86:	00000073          	ecall
 ret
    5c8a:	8082                	ret

0000000000005c8c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5c8c:	48b5                	li	a7,13
 ecall
    5c8e:	00000073          	ecall
 ret
    5c92:	8082                	ret

0000000000005c94 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5c94:	48b9                	li	a7,14
 ecall
    5c96:	00000073          	ecall
 ret
    5c9a:	8082                	ret

0000000000005c9c <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
    5c9c:	48d9                	li	a7,22
 ecall
    5c9e:	00000073          	ecall
 ret
    5ca2:	8082                	ret

0000000000005ca4 <getpinfo>:
.global getpinfo
getpinfo:
 li a7, SYS_getpinfo
    5ca4:	48dd                	li	a7,23
 ecall
    5ca6:	00000073          	ecall
 ret
    5caa:	8082                	ret

0000000000005cac <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5cac:	1101                	add	sp,sp,-32
    5cae:	ec06                	sd	ra,24(sp)
    5cb0:	e822                	sd	s0,16(sp)
    5cb2:	1000                	add	s0,sp,32
    5cb4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5cb8:	4605                	li	a2,1
    5cba:	fef40593          	add	a1,s0,-17
    5cbe:	00000097          	auipc	ra,0x0
    5cc2:	f5e080e7          	jalr	-162(ra) # 5c1c <write>
}
    5cc6:	60e2                	ld	ra,24(sp)
    5cc8:	6442                	ld	s0,16(sp)
    5cca:	6105                	add	sp,sp,32
    5ccc:	8082                	ret

0000000000005cce <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5cce:	7139                	add	sp,sp,-64
    5cd0:	fc06                	sd	ra,56(sp)
    5cd2:	f822                	sd	s0,48(sp)
    5cd4:	f426                	sd	s1,40(sp)
    5cd6:	0080                	add	s0,sp,64
    5cd8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5cda:	c299                	beqz	a3,5ce0 <printint+0x12>
    5cdc:	0805cb63          	bltz	a1,5d72 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5ce0:	2581                	sext.w	a1,a1
  neg = 0;
    5ce2:	4881                	li	a7,0
    5ce4:	fc040693          	add	a3,s0,-64
  }

  i = 0;
    5ce8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5cea:	2601                	sext.w	a2,a2
    5cec:	00003517          	auipc	a0,0x3
    5cf0:	91c50513          	add	a0,a0,-1764 # 8608 <digits>
    5cf4:	883a                	mv	a6,a4
    5cf6:	2705                	addw	a4,a4,1
    5cf8:	02c5f7bb          	remuw	a5,a1,a2
    5cfc:	1782                	sll	a5,a5,0x20
    5cfe:	9381                	srl	a5,a5,0x20
    5d00:	97aa                	add	a5,a5,a0
    5d02:	0007c783          	lbu	a5,0(a5)
    5d06:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    5d0a:	0005879b          	sext.w	a5,a1
    5d0e:	02c5d5bb          	divuw	a1,a1,a2
    5d12:	0685                	add	a3,a3,1
    5d14:	fec7f0e3          	bgeu	a5,a2,5cf4 <printint+0x26>
  if(neg)
    5d18:	00088c63          	beqz	a7,5d30 <printint+0x62>
    buf[i++] = '-';
    5d1c:	fd070793          	add	a5,a4,-48
    5d20:	00878733          	add	a4,a5,s0
    5d24:	02d00793          	li	a5,45
    5d28:	fef70823          	sb	a5,-16(a4)
    5d2c:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    5d30:	02e05c63          	blez	a4,5d68 <printint+0x9a>
    5d34:	f04a                	sd	s2,32(sp)
    5d36:	ec4e                	sd	s3,24(sp)
    5d38:	fc040793          	add	a5,s0,-64
    5d3c:	00e78933          	add	s2,a5,a4
    5d40:	fff78993          	add	s3,a5,-1
    5d44:	99ba                	add	s3,s3,a4
    5d46:	377d                	addw	a4,a4,-1
    5d48:	1702                	sll	a4,a4,0x20
    5d4a:	9301                	srl	a4,a4,0x20
    5d4c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    5d50:	fff94583          	lbu	a1,-1(s2)
    5d54:	8526                	mv	a0,s1
    5d56:	00000097          	auipc	ra,0x0
    5d5a:	f56080e7          	jalr	-170(ra) # 5cac <putc>
  while(--i >= 0)
    5d5e:	197d                	add	s2,s2,-1
    5d60:	ff3918e3          	bne	s2,s3,5d50 <printint+0x82>
    5d64:	7902                	ld	s2,32(sp)
    5d66:	69e2                	ld	s3,24(sp)
}
    5d68:	70e2                	ld	ra,56(sp)
    5d6a:	7442                	ld	s0,48(sp)
    5d6c:	74a2                	ld	s1,40(sp)
    5d6e:	6121                	add	sp,sp,64
    5d70:	8082                	ret
    x = -xx;
    5d72:	40b005bb          	negw	a1,a1
    neg = 1;
    5d76:	4885                	li	a7,1
    x = -xx;
    5d78:	b7b5                	j	5ce4 <printint+0x16>

0000000000005d7a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5d7a:	715d                	add	sp,sp,-80
    5d7c:	e486                	sd	ra,72(sp)
    5d7e:	e0a2                	sd	s0,64(sp)
    5d80:	f84a                	sd	s2,48(sp)
    5d82:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5d84:	0005c903          	lbu	s2,0(a1)
    5d88:	1a090a63          	beqz	s2,5f3c <vprintf+0x1c2>
    5d8c:	fc26                	sd	s1,56(sp)
    5d8e:	f44e                	sd	s3,40(sp)
    5d90:	f052                	sd	s4,32(sp)
    5d92:	ec56                	sd	s5,24(sp)
    5d94:	e85a                	sd	s6,16(sp)
    5d96:	e45e                	sd	s7,8(sp)
    5d98:	8aaa                	mv	s5,a0
    5d9a:	8bb2                	mv	s7,a2
    5d9c:	00158493          	add	s1,a1,1
  state = 0;
    5da0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5da2:	02500a13          	li	s4,37
    5da6:	4b55                	li	s6,21
    5da8:	a839                	j	5dc6 <vprintf+0x4c>
        putc(fd, c);
    5daa:	85ca                	mv	a1,s2
    5dac:	8556                	mv	a0,s5
    5dae:	00000097          	auipc	ra,0x0
    5db2:	efe080e7          	jalr	-258(ra) # 5cac <putc>
    5db6:	a019                	j	5dbc <vprintf+0x42>
    } else if(state == '%'){
    5db8:	01498d63          	beq	s3,s4,5dd2 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
    5dbc:	0485                	add	s1,s1,1
    5dbe:	fff4c903          	lbu	s2,-1(s1)
    5dc2:	16090763          	beqz	s2,5f30 <vprintf+0x1b6>
    if(state == 0){
    5dc6:	fe0999e3          	bnez	s3,5db8 <vprintf+0x3e>
      if(c == '%'){
    5dca:	ff4910e3          	bne	s2,s4,5daa <vprintf+0x30>
        state = '%';
    5dce:	89d2                	mv	s3,s4
    5dd0:	b7f5                	j	5dbc <vprintf+0x42>
      if(c == 'd'){
    5dd2:	13490463          	beq	s2,s4,5efa <vprintf+0x180>
    5dd6:	f9d9079b          	addw	a5,s2,-99
    5dda:	0ff7f793          	zext.b	a5,a5
    5dde:	12fb6763          	bltu	s6,a5,5f0c <vprintf+0x192>
    5de2:	f9d9079b          	addw	a5,s2,-99
    5de6:	0ff7f713          	zext.b	a4,a5
    5dea:	12eb6163          	bltu	s6,a4,5f0c <vprintf+0x192>
    5dee:	00271793          	sll	a5,a4,0x2
    5df2:	00002717          	auipc	a4,0x2
    5df6:	7be70713          	add	a4,a4,1982 # 85b0 <malloc+0x2584>
    5dfa:	97ba                	add	a5,a5,a4
    5dfc:	439c                	lw	a5,0(a5)
    5dfe:	97ba                	add	a5,a5,a4
    5e00:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    5e02:	008b8913          	add	s2,s7,8
    5e06:	4685                	li	a3,1
    5e08:	4629                	li	a2,10
    5e0a:	000ba583          	lw	a1,0(s7)
    5e0e:	8556                	mv	a0,s5
    5e10:	00000097          	auipc	ra,0x0
    5e14:	ebe080e7          	jalr	-322(ra) # 5cce <printint>
    5e18:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    5e1a:	4981                	li	s3,0
    5e1c:	b745                	j	5dbc <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5e1e:	008b8913          	add	s2,s7,8
    5e22:	4681                	li	a3,0
    5e24:	4629                	li	a2,10
    5e26:	000ba583          	lw	a1,0(s7)
    5e2a:	8556                	mv	a0,s5
    5e2c:	00000097          	auipc	ra,0x0
    5e30:	ea2080e7          	jalr	-350(ra) # 5cce <printint>
    5e34:	8bca                	mv	s7,s2
      state = 0;
    5e36:	4981                	li	s3,0
    5e38:	b751                	j	5dbc <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    5e3a:	008b8913          	add	s2,s7,8
    5e3e:	4681                	li	a3,0
    5e40:	4641                	li	a2,16
    5e42:	000ba583          	lw	a1,0(s7)
    5e46:	8556                	mv	a0,s5
    5e48:	00000097          	auipc	ra,0x0
    5e4c:	e86080e7          	jalr	-378(ra) # 5cce <printint>
    5e50:	8bca                	mv	s7,s2
      state = 0;
    5e52:	4981                	li	s3,0
    5e54:	b7a5                	j	5dbc <vprintf+0x42>
    5e56:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    5e58:	008b8c13          	add	s8,s7,8
    5e5c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    5e60:	03000593          	li	a1,48
    5e64:	8556                	mv	a0,s5
    5e66:	00000097          	auipc	ra,0x0
    5e6a:	e46080e7          	jalr	-442(ra) # 5cac <putc>
  putc(fd, 'x');
    5e6e:	07800593          	li	a1,120
    5e72:	8556                	mv	a0,s5
    5e74:	00000097          	auipc	ra,0x0
    5e78:	e38080e7          	jalr	-456(ra) # 5cac <putc>
    5e7c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5e7e:	00002b97          	auipc	s7,0x2
    5e82:	78ab8b93          	add	s7,s7,1930 # 8608 <digits>
    5e86:	03c9d793          	srl	a5,s3,0x3c
    5e8a:	97de                	add	a5,a5,s7
    5e8c:	0007c583          	lbu	a1,0(a5)
    5e90:	8556                	mv	a0,s5
    5e92:	00000097          	auipc	ra,0x0
    5e96:	e1a080e7          	jalr	-486(ra) # 5cac <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5e9a:	0992                	sll	s3,s3,0x4
    5e9c:	397d                	addw	s2,s2,-1
    5e9e:	fe0914e3          	bnez	s2,5e86 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    5ea2:	8be2                	mv	s7,s8
      state = 0;
    5ea4:	4981                	li	s3,0
    5ea6:	6c02                	ld	s8,0(sp)
    5ea8:	bf11                	j	5dbc <vprintf+0x42>
        s = va_arg(ap, char*);
    5eaa:	008b8993          	add	s3,s7,8
    5eae:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    5eb2:	02090163          	beqz	s2,5ed4 <vprintf+0x15a>
        while(*s != 0){
    5eb6:	00094583          	lbu	a1,0(s2)
    5eba:	c9a5                	beqz	a1,5f2a <vprintf+0x1b0>
          putc(fd, *s);
    5ebc:	8556                	mv	a0,s5
    5ebe:	00000097          	auipc	ra,0x0
    5ec2:	dee080e7          	jalr	-530(ra) # 5cac <putc>
          s++;
    5ec6:	0905                	add	s2,s2,1
        while(*s != 0){
    5ec8:	00094583          	lbu	a1,0(s2)
    5ecc:	f9e5                	bnez	a1,5ebc <vprintf+0x142>
        s = va_arg(ap, char*);
    5ece:	8bce                	mv	s7,s3
      state = 0;
    5ed0:	4981                	li	s3,0
    5ed2:	b5ed                	j	5dbc <vprintf+0x42>
          s = "(null)";
    5ed4:	00002917          	auipc	s2,0x2
    5ed8:	6b490913          	add	s2,s2,1716 # 8588 <malloc+0x255c>
        while(*s != 0){
    5edc:	02800593          	li	a1,40
    5ee0:	bff1                	j	5ebc <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
    5ee2:	008b8913          	add	s2,s7,8
    5ee6:	000bc583          	lbu	a1,0(s7)
    5eea:	8556                	mv	a0,s5
    5eec:	00000097          	auipc	ra,0x0
    5ef0:	dc0080e7          	jalr	-576(ra) # 5cac <putc>
    5ef4:	8bca                	mv	s7,s2
      state = 0;
    5ef6:	4981                	li	s3,0
    5ef8:	b5d1                	j	5dbc <vprintf+0x42>
        putc(fd, c);
    5efa:	02500593          	li	a1,37
    5efe:	8556                	mv	a0,s5
    5f00:	00000097          	auipc	ra,0x0
    5f04:	dac080e7          	jalr	-596(ra) # 5cac <putc>
      state = 0;
    5f08:	4981                	li	s3,0
    5f0a:	bd4d                	j	5dbc <vprintf+0x42>
        putc(fd, '%');
    5f0c:	02500593          	li	a1,37
    5f10:	8556                	mv	a0,s5
    5f12:	00000097          	auipc	ra,0x0
    5f16:	d9a080e7          	jalr	-614(ra) # 5cac <putc>
        putc(fd, c);
    5f1a:	85ca                	mv	a1,s2
    5f1c:	8556                	mv	a0,s5
    5f1e:	00000097          	auipc	ra,0x0
    5f22:	d8e080e7          	jalr	-626(ra) # 5cac <putc>
      state = 0;
    5f26:	4981                	li	s3,0
    5f28:	bd51                	j	5dbc <vprintf+0x42>
        s = va_arg(ap, char*);
    5f2a:	8bce                	mv	s7,s3
      state = 0;
    5f2c:	4981                	li	s3,0
    5f2e:	b579                	j	5dbc <vprintf+0x42>
    5f30:	74e2                	ld	s1,56(sp)
    5f32:	79a2                	ld	s3,40(sp)
    5f34:	7a02                	ld	s4,32(sp)
    5f36:	6ae2                	ld	s5,24(sp)
    5f38:	6b42                	ld	s6,16(sp)
    5f3a:	6ba2                	ld	s7,8(sp)
    }
  }
}
    5f3c:	60a6                	ld	ra,72(sp)
    5f3e:	6406                	ld	s0,64(sp)
    5f40:	7942                	ld	s2,48(sp)
    5f42:	6161                	add	sp,sp,80
    5f44:	8082                	ret

0000000000005f46 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5f46:	715d                	add	sp,sp,-80
    5f48:	ec06                	sd	ra,24(sp)
    5f4a:	e822                	sd	s0,16(sp)
    5f4c:	1000                	add	s0,sp,32
    5f4e:	e010                	sd	a2,0(s0)
    5f50:	e414                	sd	a3,8(s0)
    5f52:	e818                	sd	a4,16(s0)
    5f54:	ec1c                	sd	a5,24(s0)
    5f56:	03043023          	sd	a6,32(s0)
    5f5a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5f5e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5f62:	8622                	mv	a2,s0
    5f64:	00000097          	auipc	ra,0x0
    5f68:	e16080e7          	jalr	-490(ra) # 5d7a <vprintf>
}
    5f6c:	60e2                	ld	ra,24(sp)
    5f6e:	6442                	ld	s0,16(sp)
    5f70:	6161                	add	sp,sp,80
    5f72:	8082                	ret

0000000000005f74 <printf>:

void
printf(const char *fmt, ...)
{
    5f74:	711d                	add	sp,sp,-96
    5f76:	ec06                	sd	ra,24(sp)
    5f78:	e822                	sd	s0,16(sp)
    5f7a:	1000                	add	s0,sp,32
    5f7c:	e40c                	sd	a1,8(s0)
    5f7e:	e810                	sd	a2,16(s0)
    5f80:	ec14                	sd	a3,24(s0)
    5f82:	f018                	sd	a4,32(s0)
    5f84:	f41c                	sd	a5,40(s0)
    5f86:	03043823          	sd	a6,48(s0)
    5f8a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5f8e:	00840613          	add	a2,s0,8
    5f92:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5f96:	85aa                	mv	a1,a0
    5f98:	4505                	li	a0,1
    5f9a:	00000097          	auipc	ra,0x0
    5f9e:	de0080e7          	jalr	-544(ra) # 5d7a <vprintf>
}
    5fa2:	60e2                	ld	ra,24(sp)
    5fa4:	6442                	ld	s0,16(sp)
    5fa6:	6125                	add	sp,sp,96
    5fa8:	8082                	ret

0000000000005faa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5faa:	1141                	add	sp,sp,-16
    5fac:	e422                	sd	s0,8(sp)
    5fae:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5fb0:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5fb4:	00003797          	auipc	a5,0x3
    5fb8:	49c7b783          	ld	a5,1180(a5) # 9450 <freep>
    5fbc:	a02d                	j	5fe6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5fbe:	4618                	lw	a4,8(a2)
    5fc0:	9f2d                	addw	a4,a4,a1
    5fc2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5fc6:	6398                	ld	a4,0(a5)
    5fc8:	6310                	ld	a2,0(a4)
    5fca:	a83d                	j	6008 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5fcc:	ff852703          	lw	a4,-8(a0)
    5fd0:	9f31                	addw	a4,a4,a2
    5fd2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    5fd4:	ff053683          	ld	a3,-16(a0)
    5fd8:	a091                	j	601c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5fda:	6398                	ld	a4,0(a5)
    5fdc:	00e7e463          	bltu	a5,a4,5fe4 <free+0x3a>
    5fe0:	00e6ea63          	bltu	a3,a4,5ff4 <free+0x4a>
{
    5fe4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5fe6:	fed7fae3          	bgeu	a5,a3,5fda <free+0x30>
    5fea:	6398                	ld	a4,0(a5)
    5fec:	00e6e463          	bltu	a3,a4,5ff4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5ff0:	fee7eae3          	bltu	a5,a4,5fe4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    5ff4:	ff852583          	lw	a1,-8(a0)
    5ff8:	6390                	ld	a2,0(a5)
    5ffa:	02059813          	sll	a6,a1,0x20
    5ffe:	01c85713          	srl	a4,a6,0x1c
    6002:	9736                	add	a4,a4,a3
    6004:	fae60de3          	beq	a2,a4,5fbe <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    6008:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    600c:	4790                	lw	a2,8(a5)
    600e:	02061593          	sll	a1,a2,0x20
    6012:	01c5d713          	srl	a4,a1,0x1c
    6016:	973e                	add	a4,a4,a5
    6018:	fae68ae3          	beq	a3,a4,5fcc <free+0x22>
    p->s.ptr = bp->s.ptr;
    601c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    601e:	00003717          	auipc	a4,0x3
    6022:	42f73923          	sd	a5,1074(a4) # 9450 <freep>
}
    6026:	6422                	ld	s0,8(sp)
    6028:	0141                	add	sp,sp,16
    602a:	8082                	ret

000000000000602c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    602c:	7139                	add	sp,sp,-64
    602e:	fc06                	sd	ra,56(sp)
    6030:	f822                	sd	s0,48(sp)
    6032:	f426                	sd	s1,40(sp)
    6034:	ec4e                	sd	s3,24(sp)
    6036:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    6038:	02051493          	sll	s1,a0,0x20
    603c:	9081                	srl	s1,s1,0x20
    603e:	04bd                	add	s1,s1,15
    6040:	8091                	srl	s1,s1,0x4
    6042:	0014899b          	addw	s3,s1,1
    6046:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
    6048:	00003517          	auipc	a0,0x3
    604c:	40853503          	ld	a0,1032(a0) # 9450 <freep>
    6050:	c915                	beqz	a0,6084 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    6052:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    6054:	4798                	lw	a4,8(a5)
    6056:	08977e63          	bgeu	a4,s1,60f2 <malloc+0xc6>
    605a:	f04a                	sd	s2,32(sp)
    605c:	e852                	sd	s4,16(sp)
    605e:	e456                	sd	s5,8(sp)
    6060:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    6062:	8a4e                	mv	s4,s3
    6064:	0009871b          	sext.w	a4,s3
    6068:	6685                	lui	a3,0x1
    606a:	00d77363          	bgeu	a4,a3,6070 <malloc+0x44>
    606e:	6a05                	lui	s4,0x1
    6070:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    6074:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    6078:	00003917          	auipc	s2,0x3
    607c:	3d890913          	add	s2,s2,984 # 9450 <freep>
  if(p == (char*)-1)
    6080:	5afd                	li	s5,-1
    6082:	a091                	j	60c6 <malloc+0x9a>
    6084:	f04a                	sd	s2,32(sp)
    6086:	e852                	sd	s4,16(sp)
    6088:	e456                	sd	s5,8(sp)
    608a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    608c:	0000a797          	auipc	a5,0xa
    6090:	bec78793          	add	a5,a5,-1044 # fc78 <base>
    6094:	00003717          	auipc	a4,0x3
    6098:	3af73e23          	sd	a5,956(a4) # 9450 <freep>
    609c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    609e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    60a2:	b7c1                	j	6062 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    60a4:	6398                	ld	a4,0(a5)
    60a6:	e118                	sd	a4,0(a0)
    60a8:	a08d                	j	610a <malloc+0xde>
  hp->s.size = nu;
    60aa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    60ae:	0541                	add	a0,a0,16
    60b0:	00000097          	auipc	ra,0x0
    60b4:	efa080e7          	jalr	-262(ra) # 5faa <free>
  return freep;
    60b8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    60bc:	c13d                	beqz	a0,6122 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    60be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    60c0:	4798                	lw	a4,8(a5)
    60c2:	02977463          	bgeu	a4,s1,60ea <malloc+0xbe>
    if(p == freep)
    60c6:	00093703          	ld	a4,0(s2)
    60ca:	853e                	mv	a0,a5
    60cc:	fef719e3          	bne	a4,a5,60be <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
    60d0:	8552                	mv	a0,s4
    60d2:	00000097          	auipc	ra,0x0
    60d6:	bb2080e7          	jalr	-1102(ra) # 5c84 <sbrk>
  if(p == (char*)-1)
    60da:	fd5518e3          	bne	a0,s5,60aa <malloc+0x7e>
        return 0;
    60de:	4501                	li	a0,0
    60e0:	7902                	ld	s2,32(sp)
    60e2:	6a42                	ld	s4,16(sp)
    60e4:	6aa2                	ld	s5,8(sp)
    60e6:	6b02                	ld	s6,0(sp)
    60e8:	a03d                	j	6116 <malloc+0xea>
    60ea:	7902                	ld	s2,32(sp)
    60ec:	6a42                	ld	s4,16(sp)
    60ee:	6aa2                	ld	s5,8(sp)
    60f0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    60f2:	fae489e3          	beq	s1,a4,60a4 <malloc+0x78>
        p->s.size -= nunits;
    60f6:	4137073b          	subw	a4,a4,s3
    60fa:	c798                	sw	a4,8(a5)
        p += p->s.size;
    60fc:	02071693          	sll	a3,a4,0x20
    6100:	01c6d713          	srl	a4,a3,0x1c
    6104:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    6106:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    610a:	00003717          	auipc	a4,0x3
    610e:	34a73323          	sd	a0,838(a4) # 9450 <freep>
      return (void*)(p + 1);
    6112:	01078513          	add	a0,a5,16
  }
}
    6116:	70e2                	ld	ra,56(sp)
    6118:	7442                	ld	s0,48(sp)
    611a:	74a2                	ld	s1,40(sp)
    611c:	69e2                	ld	s3,24(sp)
    611e:	6121                	add	sp,sp,64
    6120:	8082                	ret
    6122:	7902                	ld	s2,32(sp)
    6124:	6a42                	ld	s4,16(sp)
    6126:	6aa2                	ld	s5,8(sp)
    6128:	6b02                	ld	s6,0(sp)
    612a:	b7f5                	j	6116 <malloc+0xea>
