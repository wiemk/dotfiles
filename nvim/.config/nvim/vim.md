**Multiple lines equal alternatives, keys are enclosed within `<key>`, placeholders in `{foo}`.**

**General:**
- add modeline:  
`<leader> ml`
- draw Whitespace:  
`<leader> lw`
- toggle Line-Numbers:  
`<leader> ln`
- write with sudo and reopen with new permissions  
`:w!!`
- resize window to minimal size  
`<leader> y`
- increase size  
`+`
- decrease size  
`-`
- split vertically and create new buffer  
`<leader> |`
- split horizontally and create new buffer  
`<leader> -`
- show current directory (editable) in command line  
`:%%`
- show current directory in command line and edit file (rw buffer)  
`<leader> e`
- show current directory in command line and view file (ro buffer)  
`<leader> v`
- next tab  
`<leader> .`
- previous tab  
`<leader> ,`
- new tab  
`<leader> t`
- close tab  
`<leader> w`
- cycle buffer next  
`<Tab>`
- cycle buffer previous  
`<Shift-Tab>`
- remove highlight from search /  
`<leader> ns`  
`<C-x><C-l>`
- strip shell comments  
`<leader> sc`
- replace word at cursor with `{word}`  
`<leader> src {word}`
- replace `{word1}` in file with `{word2}`  
`<leader> s {word1} / {word2}`
- swap lines at cursor / marked with Visual-Mode  
`<Alt> j`  
`<Alt> k`
- strip trailing whitespaces (careful!)  
`<leader> sw`
- toggle between absolute and relative line numbers  
`<leader> r`

**Advanced:**
- change enclosure for enclosed {word}  
Go inside, press `cs{old}{new}`  
*Example:*
- change quotes in `"Hello World"` from `"` to `'`  
Go inside, press `cs"'`
- enclose in tags  
`cs'<foo>`
- remove enclosures `{enc}`  
`ds{enc}`
- wrap word at cursor in enclosure `{enc}`  
`ysiw{enc}`
- wrap entire line  
`yss{enc}`
- b is short for parenthesis  
`yssb`
- comment line  
`gcc`
- comment 10 lines  
`10gcc`
- comment paragraph  
`gcap`
- comment motion  
`gc`
