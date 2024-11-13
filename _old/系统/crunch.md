---
layout: post
title: crunch
subtitle:
date:       2023-04-11 10:28:53
categories: [系统]
tags: [系统,crunch]
---



CRUNCH(1)                                                                             General Commands Manual                                                                             CRUNCH(1)

NAME
       crunch - generate wordlists from a character set

SYNOPSIS 概要
       crunch <min-len> <max-len> [<charset string>] [options]

DESCRIPTION
       Crunch can create a wordlist based on criteria you specify .  The output from crunch can be sent to the screen, file, or to another program.  The required parameters are:
	   
	   Crunch 可以根据您指定的条件创建一个词表。 crunch 的输出可以发送到屏幕、文件或另一个程序。 所需的参数是：

       min-len 最小长度
              The minimum length string you want crunch to start at.  This option is required even for parameters that won't use the value.	
			  
			  您希望 crunch 开始的最小长度字符串。 即使对于不使用该值的参数，此选项也是必需的。

       max-len
              The maximum length string you want crunch to end at.  This option is required even for parameters that won't use the value.
			  
			  您希望 crunch 结束的最大长度字符串。 即使对于不使用该值的参数，此选项也是必需的。

       charset string
              You  may  specify character sets for crunch to use on the command line or if you leave it blank crunch will use the default character sets.  The order MUST BE lower case characters,
              upper case characters, numbers, and then symbols.  If you don't follow this order you will not get the results you want.  You MUST specify either values for the character type or  a
              plus sign.  NOTE: If you want to include the space character in your character set you must escape it using the \ character or enclose your character set in quotes i.e. "abc ".  See
              the examples 3, 11, 12, and 13 for examples.
			  
			  您可以指定 crunch 在命令行上使用的字符集，或者如果您将其留空，则 crunch 将使用默认字符集。 订单必须是小写字符，
			  大写字符、数字，然后是符号。 如果您不遵循此顺序，您将得不到想要的结果。 您必须指定字符类型的值或加号。
			  注意：如果你想在你的字符集中包含空格字符，你必须使用 \ 字符将其转义或用引号将你的字符集括起来，即“abc”。 
			  看示例 3、11、12 和 13 为例。

OPTIONS
       -b number[type]
              Specifies the size of the output file, only works if -o START is used, i.e.: 60MB  The output files will be in the format of starting letter-ending letter for example: ./crunch 4  5
              -b  20mib -o START will generate 4 files: aaaa-gvfed.txt, gvfee-ombqy.txt, ombqz-wcydt.txt, wcydu-zzzzz.txt valid values for type are kb, mb, gb, kib, mib, and gib.  The first three
              types are based on 1000 while the last three types are based on 1024.  NOTE There is no space between the number and type.  For example 500mb is correct 500 mb is NOT correct.
			  
			  指定输出文件的大小，仅在使用 -o START 时有效，即：60MB 输出文件将采用开头字母结尾字母的格式，
			  例如：./crunch 4 5 -b 20mib -o START 将生成 4 个文件：aaaa-gvfed.txt、gvfee-ombqy.txt、ombqz-wcydt.txt、wcydu-zzzzz.txt 
			  类型的有效值为 kb、mb、gb、kib、mib 和 gib。 前三个类型以 1000 为基础，而后三种类型以 1024 为基础。
			  注意 数字和类型之间没有空格。 例如 500mb 是正确的，500 mb 是不正确的。

       -c number
              Specifies the number of lines to write to output file, only works if -o START is used, i.e.: 60  The output files will be in the format of starting letter-ending letter for example:
              ./crunch  1 1 -f /pentest/password/crunch/charset.lst mixalpha-numeric-all-space -o START -c 60 will result in 2 files: a-7.txt and 8-\ .txt  The reason for the slash in  the second
              filename is the ending character is space and ls has to escape it to print it.  Yes you will need to put in the \ when specifying the filename because the last character is a space.
			  
			  指定写入输出文件的行数，仅在使用 -o START 时有效，即：60 输出文件将采用开头字母结尾字母的格式，
			  例如：./crunch 1 1 -f /pentest/password/crunch/charset.lst mixalpha-numeric-all-space -o START -c 60 会产生2个文件：a-7.txt和8-\ .txt 
			  原因是第二个斜线文件名是结束字符是空格，ls 必须转义它才能打印它。 是的，您需要在指定文件名时放入 \，因为最后一个字符是空格。

       -d numbersymbol
              Limits the number of duplicate characters.  -d 2@ limits the lower case alphabet to output like aab and aac.  aaa would not be generated as that is 3 consecutive letters of a.   The
              format  is  number then symbol where number is the maximum number of consecutive characters and symbol is the symbol of the the character set you want to limit i.e. @,%^   See exam‐
              ples 17-19.
			  
			  限制重复字符的数量。 -d 2@ 将小写字母限制为像 aab 和 aac 一样输出。 aaa 不会生成，因为它是 a 的 3 个连续字母。
			  这 format is number then symbol 其中 number 是连续字符的最大数量，symbol 是您要限制的字符集的符号，即 @,%^ 参见 See exam‐ ples 17-19。

       -e string
              Specifies when crunch should stop early
			  
			  指定紧缩何时应该提前停止

       -f /path/to/charset.lst charset-name
              Specifies a character set from the charset.lst
			  从 charset.lst 指定一个字符集

       -i Inverts the output so instead of aaa,aab,aac,aad,aba、abb etc you get aaa,baa,caa,daa,aba,bba, etc
		  反转输出，所以你得到的不是 aaa、aab、aac、aad、aba、abb 等，而是 aaa、baa、caa、daa、aba、bba 等

       -l When you use the -t option this option tells crunch which symbols should be treated as literals.  This will allow you to use the placeholders as letters in the pattern.  The  -l  option
              should be the same length as the -t option.  See example 15.
			  
			  当你使用 -t 选项时，这个选项告诉 crunch 哪些符号应该被视为文字。 这将允许您将占位符用作模式中的字母。 
			  -l 选项应与 -t 选项的长度相同。 参见示例 15。

       -m Merged with -p.  Please use -p instead.
			与 -p 合并，请改用 -p。

       -o wordlist.txt
              Specifies the file to write the output to, eg: wordlist.txt
			  指定将输出写入的文件，例如：wordlist.txt

       -p charset OR -p word1 word2 ...
              Tells crunch to generate words that don't have repeating characters.  By default crunch will generate a wordlist size of #of_chars_in_charset ^ max_length.  This option will instead
              generate #of_chars_in_charset!.  The ! stands for factorial.  For example say the charset is abc and max length is 4..  Crunch will by default generate 3^4 = 81 words.  This  option
              will  instead generate 3! = 3x2x1 = 6 words (abc, acb, bac, bca, cab, cba).  THIS MUST BE THE LAST OPTION!  This option CANNOT be used with -s and it ignores min and max length how‐
              ever you must still specify two numbers.
			  
			  告诉 crunch 生成没有重复字符的单词。 默认情况下，crunch 将生成大小为#of_chars_in_charset ^ max_length 的单词表。 
			  此选项将代替生成#of_chars_in_charset!。 这 ！ 代表阶乘。 
			  例如，假设字符集是 abc，最大长度是 4.. Crunch 默认会生成 3^4 = 81 个单词。 
			  这个选项而是生成 3! = 3x2x1 = 6 个单词（abc、acb、bac、bca、cab、cba）。 这必须是最后的选择！ 
			  此选项不能与 -s 一起使用，它会忽略最小和最大长度，但你仍然必须指定两个数字。

       -q filename.txt
              Tells crunch to read filename.txt and permute what is read.  This is like the -p option except it gets the input from filename.txt.
			  告诉 crunch 读取 filename.txt 并排列读取的内容。 这类似于 -p 选项，只是它从 filename.txt 获取输入。
       -r Tells crunch to resume generate words from where it left off.  -r only works if you use -o.  You must use the same command as the original command used to generate the words.  The  only
              exception to this is the -s option.  If your original command used the -s option you MUST remove it before you resume the session.  Just add -r to the end of the original command.
		  告诉 crunch 从中断的地方继续生成单词。 -r 仅在使用 -o 时有效。 您必须使用与用于生成单词的原始命令相同的命令。
		  唯一的例外情况是 -s 选项。 如果您的原始命令使用了 -s 选项，您必须在恢复会话之前将其删除。 只需将 -r 添加到原始命令的末尾即可。

       -s startblock
              Specifies a starting string, eg: 03god22fs
			  指定起始字符串，例如：03god22fs

       -t @,%^
              Specifies a pattern, eg: @@god@@@@ where the only the @'s, ,'s, %'s, and ^'s will change.
              @ will insert lower case characters
              , will insert upper case characters
              % will insert numbers
              ^ will insert symbols
			  
			  指定一个模式，例如：@@god@@@@ 其中只有@'s, ,'s, %'s, and ^'s 会改变。
               @ 将插入小写字符
               , 将插入大写字符
               % 将插入数字
               ^ 将插入符号

       -u
              The -u option disables the printpercentage thread.  This should be the last option.
			  -u 选项禁用 printpercentage 线程。 这应该是最后的选择。

       -z gzip, bzip2, lzma, and 7z
              Compresses the output from the -o option.  Valid parameters are gzip, bzip2, lzma, and 7z.
              gzip is the fastest but the compression is minimal.  bzip2 is a little slower than gzip but has better compression.  7z is slowest but has the best compression.
			  压缩 -o 选项的输出。 有效参数为 gzip、bzip2、lzma 和 7z。
			  gzip 是最快的，但压缩是最小的。 bzip2 比 gzip 慢一点，但压缩效果更好。 7z 最慢但压缩效果最好。

EXAMPLES
       Example 1
       crunch 1 8
       crunch will display a wordlist that starts at a and ends at zzzzzzzz
	   crunch 将显示一个以 a 开始并以 zzzzzzzz 结束的单词列表	
	   
       Example 2
       crunch 1 6 abcdefg
       crunch will display a wordlist using the character set abcdefg that starts at a and ends at gggggg
	   crunch 将使用从 a 开始到 gggggg 结束的字符集 abcdefg 显示一个单词表
	   围绕字母而不需要 \，即“abcdefg”。 Crunch 将使用从 a 开始到（6 个空格）结束的字符集 abcdefg 显示单词列表
		
       Example 3
       crunch 1 6 abcdefg\ 
       there  is  a  space  at  the end of the character string.  In order for crunch to use the space you will need to escape it using the \ character.  In this example you could also put quotes
       around the letters and not need the \, i.e. "abcdefg ".  Crunch will display a wordlist using the character set abcdefg  that starts at a and ends at (6 spaces)
	   字符串末尾有一个空格。 为了让 crunch 使用该空格，您需要使用 \ 字符对其进行转义。 在这个例子中你也可以把引号
       
       Example 4
       crunch 1 8 -f charset.lst mixalpha-numeric-all-space -o wordlist.txt
       crunch will use the mixalpha-numeric-all-space character set from charset.lst and will write the wordlist to a file named wordlist.txt.  The file will start with a and end with "        "
	   crunch 将使用 charset.lst 中的 mixalpha-numeric-all-space 字符集，并将单词列表写入名为 wordlist.txt 的文件。 该文件将以 a 开头并以 " " 结尾
	   
       Example 5
       crunch 8 8 -f charset.lst mixalpha-numeric-all-space -o wordlist.txt -t @@dog@@@ -s cbdogaaa
       crunch should generate a 8 character wordlist using the mixalpha-number-all-space character set from charset.lst and will write the wordlist to a file named wordlist.txt.   The  file  will
       start at cbdogaaa and end at "  dog   "
	   
	   crunch 应该使用 charset.lst 中的 mixalpha-number-all-space 字符集生成一个 8 字符的单词列表，并将该单词列表写入名为 wordlist.txt 的文件。 该文件将从 cbdogaaa 开始到 " dog " 结束
		
       Example 6
       crunch 2 3 -f charset.lst ualpha -s BB
       crunch with start generating a wordlist at BB and end with ZZZ.  This is useful if you have to stop generating a wordlist in the middle.  Just do a tail wordlist.txt and set the -s parame‐
       ter to the next word in the sequence.  Be sure to rename the original wordlist BEFORE you begin as crunch will overwrite the existing wordlist.
	   
	   在 BB 处开始生成词表并以 ZZZ 结束。 如果您必须在中间停止生成单词列表，这将很有用。 只需执行 tail wordlist.txt 并设置 -s 参数 -ter 到序列中的下一个单词。 
	   请务必在开始之前重命名原始单词列表，因为紧缩会覆盖现有的单词列表。
	   
       Example 7
       crunch 4 5 -p abc
       The numbers aren't processed but are needed.
       crunch will generate abc, acb, bac, bca, cab, cba.

		这些数字未处理但需要。
        crunch 将生成 abc、acb、bac、bca、cab、cba。
		
       Example 8
       crunch 4 5 -p dog cat bird
       The numbers aren't processed but are needed.
       crunch will generate birdcatdog, birddogcat, catbirddog, catdogbird, dogbirdcat, dogcatbird.
	   这些数字未处理但需要。
        crunch 将生成 birdcatdog、birddogcat、catbirddog、catdogbird、dogbirdcat、dogcatbird。

       Example 9
       crunch 1 5 -o START -c 6000 -z bzip2
       crunch will generate bzip2 compressed files with each file containing 6000 words.  The filenames of the compressed files will be first_word-last_word.txt.bz2
	   crunch 将生成 bzip2 压缩文件，每个文件包含 6000 个单词。 压缩文件的文件名将是 first_word-last_word.txt.bz2

       # time ./crunch 1 4 -o START -c 6000 -z gzip
       real    0m2.729s
       user    0m2.216s
       sys     0m0.360s

       # time ./crunch 1 4 -o START -c 6000 -z bzip2
       real    0m3.414s
       user    0m2.620s
       sys     0m0.580s

       # time ./crunch 1 4 -o START -c 6000 -z lzma
       real    0m43.060s
       user    0m9.965s
       sys     0m32.634s

       size  filename
       30K   aaaa-aiwt.txt
       12K   aaaa-aiwt.txt.gz
       3.8K  aaaa-aiwt.txt.bz2
       1.1K  aaaa-aiwt.txt.lzma

       Example 10
       crunch 4 5 -b 20mib -o START
       will generate 4 files: aaaa-gvfed.txt, gvfee-ombqy.txt, ombqz-wcydt.txt, wcydu-zzzzz.txt
       the first three files are 20MBs (real power of 2 MegaBytes) and the last file is 11MB.
	   
	   将会生成4个文件：aaaa-gvfed.txt、gvfee-ombqy.txt、ombqz-wcydt.txt、wcydu-zzzzz.txt
       前三个文件为 20MB ，最后一个文件为 11MB。

       Example 11
       crunch 3 3 abc + 123 !@# -t @%^  例外的实例:crunch 3 3 abc + 123 @#\ \\$ -t ^@%
       will generate a 3 character long word with a character as the first character, and number as the second character, and a symbol for the third character.  The order in which you specify the
       characters  you want is important.  You must specify the order as lower case character, upper case character, number, and symbol.  If you aren't going to use a particular character set you
       use a plus sign as a placeholder.  As you can see I am not using the upper case character set so I am using the plus sign placeholder.  The above will start at a1! and end at c3#
		
		将生成一个 3 个字符长的单词，第一个字符是一个字符，第二个字符是数字，第三个字符是一个符号。 
		您指定的顺序你想要的角色很重要。 您必须将顺序指定为小写字符、大写字符、数字和符号。 
		如果你不打算使用特定的字符集，你使用加号作为占位符。 如您所见，我没有使用大写字符集（小写 大写 数字 特殊符号），所以我使用的是加号占位符。 
		以上将从 a1 开始！ 并在 c3# 结束
		
		
       Example 12
       crunch 3 3 abc + 123 !@# -t ^%@
       will generate 3 character words starting with !1a and ending with #3c

       Example 13
       crunch 4 4  + + 123 + -t %%@^
       the plus sign (+) is a place holder so you can specify a character set for the character type.  crunch will use the default character set for the character type when crunch encounters a  +
       (plus  sign)  on  the  command line.  You must either specify values for each character type or use the plus sign.  I.E. if you have two characters types you MUST either specify values for
       each type or use a plus sign.  So in this example the character sets will be:
       abcdefghijklmnopqrstuvwxyz
       ABCDEFGHIJKLMNOPQRSTUVWXYZ
       123
       !@#$%^&*()-_+=~`[]{}|\:;"'<>,.?/
       there is a space at the end of the above string
       the output will start at 11a! and end at "33z ".  The quotes show the space at the end of the string.
	  
	   加号 (+) 是一个占位符，因此您可以为字符类型指定一个字符集。 当 crunch 遇到 + 时，crunch 会使用字符类型的默认字符集。 
	   您必须为每种字符类型指定值或使用加号。 I.E. 如果你有两种字符类型，你必须为每种类型或使用加号。 
	   所以在这个例子中，字符集将是：
        abcdefghijklmnopqrstuvwxyz
        ABCDEFGHIJKLMNOPQRSTUVWXYZ
        123
        !@#$%^&*()-_+=~`[]{}|\:;"'<>,.?/
        上面字符串末尾有一个空格
        输出将位: “11a!”并以“33z ”结束。 引号显示字符串末尾的空格。
		
       Example 14
       crunch 5 5 -t ddd@@ -o j -p dog cat bird
       any character other than one of the following: @,%^
       is the placeholder for the words to permute.  The @,%^ symbols have the same function as -t.
       If you want to use @,%^ in your output you can use the -l option to specify which character you want crunch to treat as a literal.
       So the results are
       birdcatdogaa
       birdcatdogab
       birdcatdogac
       <skipped>
       dogcatbirdzy
       dogcatbirdzz
	   
	   除以下之一以外的任何字符：@,%^是要排列的单词的占位符。 @,%^ 符号与 -t 具有相同的功能。
       如果您想在输出中使用 @,%^ ，您可以使用 -l 选项指定您希望 crunch 将哪个字符视为文字。

       Example 15
       crunch 7 7 -t p@ss,%^ -l a@aaaaa
       crunch will now treat the @ symbol as a literal character and not replace the character with a uppercase letter.
       this will generate
       p@ssA0!
       p@ssA0@
       p@ssA0#
       p@ssA0$ 
       p@ssZ9
	   
	   现在会将 @ 符号视为文字字符，而不是用大写字母替换该字符

       Example 16
       crunch 5 5 -s @4#S2 -t @%^,2 -e @8 Q2 -l @dddd -b 10KB -o START
       crunch will generate 5 character strings starting with @4#S2 and ending at @8 Q2.  The output will be broken into 10KB sized files named for the files starting and ending strings.
	
	   crunch 会生成以@4#S2 开头，以@8 Q2 结尾的5 个字符串。 输出将被分成 10KB 大小的文件，这些文件以文件开始和结束字符串命名。
		
       Example 17
       crunch 5 5 -d 2@ -t @@@%%
       crunch will generate 5 character strings staring with aab00 and ending at zzy99.  Notice that aaa and zzz are not present.
	   crunch 会生成 5 个字符串，从 aab00 开始，到 zzy99 结束。 请注意，aaa 和 zzz 不存在。

       Example 18
       crunch 10 10 -t @@@^%%%%^^ -d 2@ -d 3% -b 20mb -o START
       crunch will generate 10 character strings starting with aab!0001!! and ending at zzy 9998    The output will be written to 20mb files.
	   crunch会生成10个以aab!0001!!开头的字符串！ 并以 zzy 9998 结束输出将写入 20mb 文件。

       Example 19
       crunch 8 8 -d 2@
       crunch will generate 8 characters that limit the same number of lower case characters to 2.  Crunch will start at aabaabaa and end at zzyzzyzz.
	   
	   crunch 将生成 8 个字符，将相同数量的小写字符限制为 2 个。Crunch 将从 aabaabaa 开始，到 zzyzzyzz 结束。

       Example 20
       crunch 4 4 -f unicode_test.lst japanese -t @@%% -l @xdd
       crunch will load some Japanese characters from the unicode_test character set file.  The output will start at @日00 and end at @語99.
	   crunch 将从 unicode_test 字符集文件中加载一些日文字符。 输出将从@日00 开始，到@语99 结束。

REDIRECTION
       You can use crunch's output and pipe it into other programs.  The two most popular programs to pipe crunch into are: aircrack-ng and airolib-ng.  The syntax is as follows:
	   您可以使用 crunch 的输出并将其通过管道传输到其他程序中。 管道压缩的两个最流行的程序是：aircrack-ng 和 airolib-ng
       crunch 2 4 abcdefghijklmnopqrstuvwxyz | aircrack-ng /root/Mycapfile.cap -e MyESSID -w-
       crunch 10 10 12345 --stdout | airolib-ng testdb -import passwd -

NOTES
       1. Starting in version 2.6 crunch will display how much data is about to be generated.  In 2.7 it will also display how many lines will be generated.  Crunch will now wait 3 seconds BEFORE
       it begins generating data to give you time to press Ctrl-C to abort crunch if you find the values are too large for your application.
	   
	   从2.6版本开始crunch会显示即将产生多少数据。 在 2.7 中，它还会显示将生成多少行。 
	   Crunch 现在将等待 3 秒之前如果您发现值对您的应用程序来说太大，它会开始生成数据，让您有时间按 Ctrl-C 中止。

       2. I have added hex-lower (0123456789abcdef) and hex-upper (0123456789ABCDEF) to charset.lst.
	   我已将 hex-lower (0123456789abcdef) 和 hex-upper (0123456789ABCDEF) 添加到 charset.lst。

       3.  Several people have requested that I add support for the space character to crunch.  crunch has always supported the space character on the command line and in the charset.lst.  To add
       a space on the command line you must escape it using the / character.  See example 3 for the syntax.  You may need to escape other characters like ! or # depending on your  operating  sys‐
       tem.
	   有些个人要求我在 crunch 中添加对空格字符的支持。 crunch 一直支持命令行和 charset.lst 中的空格字符。 
	   加上命令行上的空格，您必须使用 / 字符将其转义。 有关语法，请参见示例 3。 您可能需要转义其他字符，例如 ! 或 # 取决于您的操作系统温度。

       4. Starting in 2.7 if you are generating a file then every 10 seconds you will receive the % done.
	   从 2.7 开始，如果您正在生成文件，那么每 10 秒您将收到完成百分比。

       5.  Starting in 3.0 I had to change the -t * character to a , as the * is a reserved character.  You could still use it if you put a \ in front of the *.  Yes it breaks crunch's syntax and
       I do my best to avoid doing that, but in this instance it is easier to make the change for long term support.
	   从 3.0 开始，我必须将 -t * 字符更改为 a ，因为 * 是保留字符。 如果在 * 前面放一个 \，您仍然可以使用它。 是的，它打破了紧缩的语法并且
        我尽力避免这样做，但在这种情况下，为了长期支持而做出改变更容易。

       6. Some output is missing.  A file didn't get generated.
       The mostly explanation is you ran out of disk space.  If you have verified you have plenty of disk space then the problem is most likely the filename begins with a period.  In Linux  file‐
       names that begin with a period are hidden.  To view them do a ls -l .*
	   缺少一些输出。 没有生成文件。主要的解释是您的磁盘空间不足。 如果您已确认您有足够的磁盘空间，那么问题很可能是文件名以句点开头。 
	   在 Linux 文件中-以句点开头的名称被隐藏。 要查看它们，请执行 ls -l .*

       7. Crunch says The maximum and minimum length should be the same size as the pattern you specified, however the length is set correctly.
       This usually means your pattern contains a character that needs to be escaped. In bash you need to escape the followings: &, *, space, \, (, ), |, ', ", ;, <, >.
       The escape character in bash is a \.  So a pattern that has a & and a * in it would look like this:
       crunch 4 4 -t \&\*d@
       An alternative to escaping characters is to wrap your string with quotes.  For example:
       crunch 4 4 -t "&*d@"
       If you want to use the " in your pattern you will need to escape it like this: crunch 4 4 -t "&*\"@"
       Please note that different terminals have different escape characters and probably have different characters that will need escaping.  Please check the manpage of your terminal for the es‐
       cape characters and characters that need escaping.
	   
	   Crunch 说最大和最小长度应与您指定的图案大小相同，但长度设置正确。
        这通常意味着您的模式包含需要转义的字符。 在 bash 中你需要逃避 fol下标：&、*、空格、\、(、)、|、'、"、;、<、>。
        bash 中的转义字符是 \。 因此，其中包含 & 和 * 的模式将如下所示：
         crunch 4 4 -t \&\*d@
        转义字符的替代方法是用引号将字符串括起来。 例如：
        crunch 4 4 -t "&*d@"
        如果你想在你的模式中使用 " 你需要像这样转义它： crunch 4 4 -t "&*\"@"
        请注意，不同的终端有不同的转义字符，并且可能有不同的字符需要转义。 请查看终端的联机帮助页以了解 es-需要转义的字符和字符。

       8. When using the -z 7z option, 7z does not delete the original file.  You will have to delete those files by hand.
	   使用-z 7z选项时，7z不删除原文件。 您将不得不手动删除这些文件。

AUTHOR
       This manual page was written by bofh28@gmail.com

       Crunch version 1.0 was written by mimayin@aciiid.ath.cx
       all later versions of crunch have been updated by bofh28@gmail.com

FILES
       None.

BUGS
       If you find any please email bofh28 <bofh28@gmail.com> or post to http://www.backtrack-linux.org

COPYRIGHT
       Copyright (c) 2009-2013 bofh28 <bofh28@gmail.com>

       This file is a part of Crunch.

       Crunch is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 2 only of the  Li‐
       cense.

       Crunch  is  distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
       General Public License for more details.

       You should have received a copy of the GNU General Public License along with Crunch.  If not, see <http://www.gnu.org/licenses/>.

Version 3.6   
