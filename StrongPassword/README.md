Get strong passwords by combining up to three sources — [https://www.grc.com/passwords.htm](https://www.grc.com/passwords.htm) (unless you choose to have a password without special characters), http://www.random.org/passwords/, and `ruby` itself. There’s at the end a technical explanation on how it works.
 
Call `sp` and the workflow will get a (default and maximum of) 64 characters random password, and copy it to your clipboard.

![](https://i.imgur.com/FYSmmRX.png)
![](https://i.imgur.com/tzN4O8E.png)<br>
 
You can also specify a number after the keyword, and it’ll truncate the password to that.

![](https://i.imgur.com/SqOlIOn.png)

#### Technical Details
I strived to keep the code very readable; inspect it at will. What this does is get a (about, due to some HTML escaping) 63 characters password from https://www.grc.com/passwords.htm and another (8 passwords, each consisting of 24 characters, joined together) from http://www.random.org/passwords/. If you opt for a password without special characters, only the latter will be used. It then picks a pseudorandom number (one of the instances where `ruby` is used, for speed) between one and two thirds of your chosen password length (truncated at, and by default, 64), saving that number (lets call it “x”) and the remainder (lets call it “y”) separately. From the first password, x number of characters will be chosen from random positions on the string (it’s actually an array, but that may start to become a bit too technical), and from the second one, y characters will be picked. The results are then joined together, and shuffled a last time between them, to produce the final result.
